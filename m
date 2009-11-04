From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/4 09/13] wimax/i2400m: move i2400m_init() out of i2400m.h
Date: Wed,  4 Nov 2009 13:40:04 -0800
Message-ID: <af77dfa7811cd4e533003a9e7e9bf27dece96c6d.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:17987 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932775AbZKDVmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:13 -0500
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Upcoming changes will have to add things to this function that expose
more internals, which would mean more forward declarators.

Frankly, it doesn't need to be an inline, so moved to driver.c, where
the declarations will be taken from the header file.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |   30 ++++++++++++++++++++++++++++++
 drivers/net/wimax/i2400m/i2400m.h |   31 +------------------------------
 2 files changed, 31 insertions(+), 30 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 10673af..9b78e05 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -849,6 +849,36 @@ void i2400m_bm_buf_free(struct i2400m *i2400m)
 
 
 /**
+ * i2400m_init - Initialize a 'struct i2400m' from all zeroes
+ *
+ * This is a bus-generic API call.
+ */
+void i2400m_init(struct i2400m *i2400m)
+{
+	wimax_dev_init(&i2400m->wimax_dev);
+
+	i2400m->boot_mode = 1;
+	i2400m->rx_reorder = 1;
+	init_waitqueue_head(&i2400m->state_wq);
+
+	spin_lock_init(&i2400m->tx_lock);
+	i2400m->tx_pl_min = UINT_MAX;
+	i2400m->tx_size_min = UINT_MAX;
+
+	spin_lock_init(&i2400m->rx_lock);
+	i2400m->rx_pl_min = UINT_MAX;
+	i2400m->rx_size_min = UINT_MAX;
+
+	mutex_init(&i2400m->msg_mutex);
+	init_completion(&i2400m->msg_completion);
+
+	mutex_init(&i2400m->init_mutex);
+	/* wake_tx_ws is initialized in i2400m_tx_setup() */
+}
+EXPORT_SYMBOL_GPL(i2400m_init);
+
+
+/**
  * i2400m_setup - bus-generic setup function for the i2400m device
  *
  * @i2400m: device descriptor (bus-specific parts have been initialized)
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index f5ed7d5..4f8815d 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -576,36 +576,6 @@ struct i2400m {
 
 
 /*
- * Initialize a 'struct i2400m' from all zeroes
- *
- * This is a bus-generic API call.
- */
-static inline
-void i2400m_init(struct i2400m *i2400m)
-{
-	wimax_dev_init(&i2400m->wimax_dev);
-
-	i2400m->boot_mode = 1;
-	i2400m->rx_reorder = 1;
-	init_waitqueue_head(&i2400m->state_wq);
-
-	spin_lock_init(&i2400m->tx_lock);
-	i2400m->tx_pl_min = UINT_MAX;
-	i2400m->tx_size_min = UINT_MAX;
-
-	spin_lock_init(&i2400m->rx_lock);
-	i2400m->rx_pl_min = UINT_MAX;
-	i2400m->rx_size_min = UINT_MAX;
-
-	mutex_init(&i2400m->msg_mutex);
-	init_completion(&i2400m->msg_completion);
-
-	mutex_init(&i2400m->init_mutex);
-	/* wake_tx_ws is initialized in i2400m_tx_setup() */
-}
-
-
-/*
  * Bus-generic internal APIs
  * -------------------------
  */
@@ -737,6 +707,7 @@ unsigned i2400m_brh_get_signature(const struct i2400m_bootrom_header *hdr)
 /*
  * Driver / device setup and internal functions
  */
+extern void i2400m_init(struct i2400m *);
 extern void i2400m_netdev_setup(struct net_device *net_dev);
 extern int i2400m_sysfs_setup(struct device_driver *);
 extern void i2400m_sysfs_release(struct device_driver *);
-- 
1.6.2.5

