From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/5 08/12] wimax/i2400m: don't retry SDIO enable in probe() paths
Date: Wed,  4 Nov 2009 13:40:13 -0800
Message-ID: <fae92216da87d1c78aa51c4503acb312a47266e9.1257370738.git.inaky@linux.intel.com>
References: <cover.1257370738.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:28866 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932794AbZKDVmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:20 -0500
In-Reply-To: <cover.1257370738.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370738.git.inaky@linux.intel.com>
References: <cover.1257370738.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The iwmc3200 has a quirk where retrying SDIO enable during the probe()
path causes bad interactions with the TOP function controller that
causes a reset storm. The workaround is simply not to retry an SDIO
enable in said path (and still do in the reset / reinitialization
paths).

The driver does so by checking i2400ms->debugfs_dentry to see if it
has been initialized; if not, it is in the probe() path. Document said
fact in i2400ms->debugfs_entry.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/i2400m-sdio.h |    8 ++++++++
 drivers/net/wimax/i2400m/sdio.c        |   13 ++++++++++++-
 2 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wimax/i2400m/i2400m-sdio.h b/drivers/net/wimax/i2400m/i2400m-sdio.h
index fba482c..b9c4bed 100644
--- a/drivers/net/wimax/i2400m/i2400m-sdio.h
+++ b/drivers/net/wimax/i2400m/i2400m-sdio.h
@@ -100,6 +100,14 @@ enum {
  * @tx_workqueue: workqeueue used for data TX; we don't use the
  *     system's workqueue as that might cause deadlocks with code in
  *     the bus-generic driver.
+ *
+ * @debugfs_dentry: dentry for the SDIO specific debugfs files
+ *
+ *     Note this value is set to NULL upon destruction; this is
+ *     because some routinges use it to determine if we are inside the
+ *     probe() path or some other path. When debugfs is disabled,
+ *     creation sets the dentry to '(void*) -ENODEV', which is valid
+ *     for the test.
  */
 struct i2400ms {
 	struct i2400m i2400m;		/* FIRST! See doc */
diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index 079f900..e8ad85c 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -159,6 +159,10 @@ function_enabled:
 /*
  * Setup minimal device communication infrastructure needed to at
  * least be able to update the firmware.
+ *
+ * Note the ugly trick: if we are in the probe path
+ * (i2400ms->debugfs_dentry == NULL), we only retry function
+ * enablement one, to avoid racing with the iwmc3200 top controller.
  */
 static
 int i2400ms_bus_setup(struct i2400m *i2400m)
@@ -168,6 +172,7 @@ int i2400ms_bus_setup(struct i2400m *i2400m)
 		container_of(i2400m, struct i2400ms, i2400m);
 	struct device *dev = i2400m_dev(i2400m);
 	struct sdio_func *func = i2400ms->func;
+	int retries;
 
 	sdio_claim_host(func);
 	result = sdio_set_block_size(func, I2400MS_BLK_SIZE);
@@ -177,7 +182,11 @@ int i2400ms_bus_setup(struct i2400m *i2400m)
 		goto error_set_blk_size;
 	}
 
-	result = i2400ms_enable_function(i2400ms, 1);
+	if (i2400ms->iwmc3200 && i2400ms->debugfs_dentry == NULL)
+		retries = 0;
+	else
+		retries = 1;
+	result = i2400ms_enable_function(i2400ms, retries);
 	if (result < 0) {
 		dev_err(dev, "Cannot enable SDIO function: %d\n", result);
 		goto error_func_enable;
@@ -415,6 +424,7 @@ int i2400ms_debugfs_add(struct i2400ms *i2400ms)
 
 error:
 	debugfs_remove_recursive(i2400ms->debugfs_dentry);
+	i2400ms->debugfs_dentry = NULL;
 	return result;
 }
 
@@ -531,6 +541,7 @@ void i2400ms_remove(struct sdio_func *func)
 
 	d_fnstart(3, dev, "SDIO func %p\n", func);
 	debugfs_remove_recursive(i2400ms->debugfs_dentry);
+	i2400ms->debugfs_dentry = NULL;
 	i2400m_release(i2400m);
 	sdio_set_drvdata(func, NULL);
 	free_netdev(net_dev);
-- 
1.6.2.5

