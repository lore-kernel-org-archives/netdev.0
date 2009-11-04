From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/1 08/12] wimax/i2400m: Ensure boot mode cmd and ack
	buffers are alloc'd before first message
Date: Wed,  4 Nov 2009 13:39:44 -0800
Message-ID: <a134fd6b103b78378e3beb6af94d8d8c2abdd19d.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	wimax@linuxwimax.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
References: <cover.1257370735.git.inaky@linux.intel.com>
List-Unsubscribe: <http://lists.linuxwimax.org/options/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.linuxwimax.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://lists.linuxwimax.org/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

From: Dirk Brandewie <dirk.j.brandewie@intel.com>

The change to the SDIO boot mode RX chain could try to use the cmd and
ack buffers befor they were allocated.  USB does not have the problem
but both were changed for consistency's sake.

Signed-off-by: Dirk Brandewie <dirk.j.brandewie@intel.com>
Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |   54 +++++++++++++++++++++++++++---------
 drivers/net/wimax/i2400m/i2400m.h |    2 +
 drivers/net/wimax/i2400m/sdio.c   |   14 +++++++++
 drivers/net/wimax/i2400m/usb.c    |    8 +++++
 4 files changed, 64 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 304f044..20d574c 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -619,6 +619,46 @@ EXPORT_SYMBOL_GPL(i2400m_dev_reset_handle);
 
 
 /**
+ * i2400m_bm_buf_alloc - Alloc the command and ack buffers for boot mode
+ *
+ * Get the buffers needed to deal with boot mode messages.  These
+ * buffers need to be allocated before the sdio recieve irq is setup.
+ */
+int i2400m_bm_buf_alloc(struct i2400m *i2400m)
+{
+	int result;
+
+	result = -ENOMEM;
+	i2400m->bm_cmd_buf = kzalloc(I2400M_BM_CMD_BUF_SIZE, GFP_KERNEL);
+	if (i2400m->bm_cmd_buf == NULL)
+		goto error_bm_cmd_kzalloc;
+	i2400m->bm_ack_buf = kzalloc(I2400M_BM_ACK_BUF_SIZE, GFP_KERNEL);
+	if (i2400m->bm_ack_buf == NULL)
+		goto error_bm_ack_buf_kzalloc;
+	return 0;
+
+error_bm_ack_buf_kzalloc:
+	kfree(i2400m->bm_cmd_buf);
+error_bm_cmd_kzalloc:
+	return result;
+}
+EXPORT_SYMBOL_GPL(i2400m_bm_buf_alloc);
+
+/**
+ * i2400m_bm_buf_free - Free boot mode command and ack buffers.
+ *
+ * Free the command and ack buffers
+ *
+ */
+void i2400m_bm_buf_free(struct i2400m *i2400m)
+{
+	kfree(i2400m->bm_ack_buf);
+	kfree(i2400m->bm_cmd_buf);
+	return;
+}
+EXPORT_SYMBOL_GPL(i2400m_bm_buf_free
+);
+/**
  * i2400m_setup - bus-generic setup function for the i2400m device
  *
  * @i2400m: device descriptor (bus-specific parts have been initialized)
@@ -645,16 +685,6 @@ int i2400m_setup(struct i2400m *i2400m, enum i2400m_bri bm_flags)
 	snprintf(wimax_dev->name, sizeof(wimax_dev->name),
 		 "i2400m-%s:%s", dev->bus->name, dev_name(dev));
 
-	i2400m->bm_cmd_buf = kzalloc(I2400M_BM_CMD_BUF_SIZE, GFP_KERNEL);
-	if (i2400m->bm_cmd_buf == NULL) {
-		dev_err(dev, "cannot allocate USB command buffer\n");
-		goto error_bm_cmd_kzalloc;
-	}
-	i2400m->bm_ack_buf = kzalloc(I2400M_BM_ACK_BUF_SIZE, GFP_KERNEL);
-	if (i2400m->bm_ack_buf == NULL) {
-		dev_err(dev, "cannot allocate USB ack buffer\n");
-		goto error_bm_ack_buf_kzalloc;
-	}
 	result = i2400m_bootrom_init(i2400m, bm_flags);
 	if (result < 0) {
 		dev_err(dev, "read mac addr: bootrom init "
@@ -713,10 +743,6 @@ error_dev_start:
 error_register_netdev:
 error_read_mac_addr:
 error_bootrom_init:
-	kfree(i2400m->bm_ack_buf);
-error_bm_ack_buf_kzalloc:
-	kfree(i2400m->bm_cmd_buf);
-error_bm_cmd_kzalloc:
 	d_fnend(3, dev, "(i2400m %p) = %d\n", i2400m, result);
 	return result;
 }
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 60330f3..a6e59f1 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -725,6 +725,8 @@ void i2400m_put(struct i2400m *i2400m)
 }
 
 extern int i2400m_dev_reset_handle(struct i2400m *);
+extern int i2400m_bm_buf_alloc(struct i2400m *i2400m);
+extern void i2400m_bm_buf_free(struct i2400m *i2400m);
 
 /*
  * _setup()/_release() are called by the probe/disconnect functions of
diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index c67b026..a68232a 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -451,6 +451,18 @@ int i2400ms_probe(struct sdio_func *func,
 		goto error_func_enable;
 	}
 
+	/*
+	 * Before we are enabling the device interrupt register, make
+	 * sure the buffer used during bootmode operation is setup so
+	 * when the first D2H data interrupt comes, the memory is
+	 * available for copying the D2H data.
+	 */
+	result = i2400m_bm_buf_alloc(i2400m);
+	if (result < 0) {
+		dev_err(dev, "cannot allocate SDIO bootmode buffer\n");
+		goto error_bootmode_buf_setup;
+	}
+
 	result = i2400ms_rx_setup(i2400ms);
 	if (result < 0)
 		goto error_rx_setup;
@@ -474,6 +486,8 @@ error_debugfs_add:
 error_setup:
 	i2400ms_rx_release(i2400ms);
 error_rx_setup:
+	i2400m_bm_buf_free(i2400m);
+error_bootmode_buf_setup:
 	sdio_claim_host(func);
 	sdio_disable_func(func);
 	sdio_release_host(func);
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index bfa45f5..49d7554 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -419,6 +419,12 @@ int i2400mu_probe(struct usb_interface *iface,
 	usb_dev->autosuspend_disabled = 0;
 #endif
 
+	result = i2400m_bm_buf_alloc(i2400m);
+	if (result < 0) {
+		dev_err(dev, "cannot allocate USB bootmode buffer\n");
+		goto error_bm_buf_alloc;
+	}
+
 	result = i2400m_setup(i2400m, I2400M_BRI_MAC_REINIT);
 	if (result < 0) {
 		dev_err(dev, "cannot setup device: %d\n", result);
@@ -434,6 +440,8 @@ int i2400mu_probe(struct usb_interface *iface,
 error_debugfs_add:
 	i2400m_release(i2400m);
 error_setup:
+	i2400m_bm_buf_free(i2400m);
+error_bm_buf_alloc:
 	usb_set_intfdata(iface, NULL);
 	usb_put_dev(i2400mu->usb_dev);
 	free_netdev(net_dev);
-- 
1.6.2.5
