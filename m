From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 3/3] nfp: wait for the NSP resource to appear on boot
Date: Wed, 13 Sep 2017 08:51:31 -0700
Message-ID: <20170913155131.18090-4-jakub.kicinski@netronome.com>
References: <20170913155131.18090-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:45578 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751642AbdIMPvq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 11:51:46 -0400
Received: by mail-pg0-f53.google.com with SMTP id 188so1137239pgb.2
        for <netdev@vger.kernel.org>; Wed, 13 Sep 2017 08:51:46 -0700 (PDT)
In-Reply-To: <20170913155131.18090-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The control process (NSP) may take some time to complete its
initialization.  This is not a problem on most servers, but
on very fast-booting machines it may not be ready for operation
when driver probes the device.  There is also a version of the
flash in the wild where NSP tries to train the links as part
of init.  To wait for NSP initialization we should make sure
its resource has already been added to the resource table.
NSP adds itself there as last step of init.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_main.c      |  4 ++
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h   |  2 +
 .../ethernet/netronome/nfp/nfpcore/nfp_resource.c  | 45 ++++++++++++++++++++++
 3 files changed, 51 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index 424707d41fbd..1c17b261a21c 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -390,6 +390,10 @@ static void nfp_fw_unload(struct nfp_pf *pf)
 	struct nfp_nsp *nsp;
 	int err;
 
+	err = nfp_resource_wait(pf->cpp, NFP_RESOURCE_NSP, 30);
+	if (err)
+		return err;
+
 	nsp = nfp_nsp_open(pf->cpp);
 	if (IS_ERR(nsp)) {
 		nfp_err(pf->cpp, "Reset failed, can't open NSP\n");
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
index 1a8d04a1e113..3ce51f03126f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h
@@ -97,6 +97,8 @@ nfp_resource_acquire(struct nfp_cpp *cpp, const char *name);
 
 void nfp_resource_release(struct nfp_resource *res);
 
+int nfp_resource_wait(struct nfp_cpp *cpp, const char *name, unsigned int secs);
+
 u32 nfp_resource_cpp_id(struct nfp_resource *res);
 
 const char *nfp_resource_name(struct nfp_resource *res);
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_resource.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_resource.c
index 072612263dab..b1dd13ff282b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_resource.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_resource.c
@@ -249,6 +249,51 @@ void nfp_resource_release(struct nfp_resource *res)
 	kfree(res);
 }
 
+/**
+ * nfp_resource_wait() - Wait for resource to appear
+ * @cpp:	NFP CPP handle
+ * @name:	Name of the resource
+ * @secs:	Number of seconds to wait
+ *
+ * Wait for resource to appear in the resource table, grab and release
+ * its lock.  The wait is jiffies-based, don't expect fine granularity.
+ *
+ * Return: 0 on success, errno otherwise.
+ */
+int nfp_resource_wait(struct nfp_cpp *cpp, const char *name, unsigned int secs)
+{
+	unsigned long warn_at = jiffies + NFP_MUTEX_WAIT_FIRST_WARN * HZ;
+	unsigned long err_at = jiffies + secs * HZ;
+	struct nfp_resource *res;
+
+	while (true) {
+		res = nfp_resource_acquire(cpp, name);
+		if (!IS_ERR(res)) {
+			nfp_resource_release(res);
+			return 0;
+		}
+
+		if (PTR_ERR(res) != -ENOENT) {
+			nfp_err(cpp, "error waiting for resource %s: %ld\n",
+				name, PTR_ERR(res));
+			return PTR_ERR(res);
+		}
+		if (time_is_before_eq_jiffies(err_at)) {
+			nfp_err(cpp, "timeout waiting for resource %s\n", name);
+			return -ETIMEDOUT;
+		}
+		if (time_is_before_eq_jiffies(warn_at)) {
+			warn_at = jiffies + NFP_MUTEX_WAIT_NEXT_WARN * HZ;
+			nfp_info(cpp, "waiting for NFP resource %s\n", name);
+		}
+		if (msleep_interruptible(10)) {
+			nfp_err(cpp, "wait for resource %s interrupted\n",
+				name);
+			return -ERESTARTSYS;
+		}
+	}
+}
+
 /**
  * nfp_resource_cpp_id() - Return the cpp_id of a resource handle
  * @res:	NFP Resource handle
-- 
2.14.1
