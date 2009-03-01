From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH] wimax/i2400m: add the ability to fallback to other firmware
	files if the default is not there
Date: Sun,  1 Mar 2009 01:42:47 -0800
Message-ID: <1235900574-15319-1-git-send-email-inaky@linux.intel.com>
Cc: netdev@vger.kernel.org
To: wimax@linuxwimax.org
Return-path: <wimax-bounces@linuxwimax.org>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

In order to support backwards compatibility with older firmwares when
a driver is updated by a new kernel release, the i2400m bus drivers
can declare a list of firmware files they can work with (in general
these will be each a different version). The firmware loader will try
them in sequence until one loads.

Thus, if a user doesn't have the latest and greatest firmware that a
newly installed kernel would require, the driver would fall back to
the firmware from a previous release.

To support this, the i2400m->bus_fw_name is changed to be a NULL
terminated array firmware file names (and renamed to bus_fw_names) and
we add a new entry (i2400m->fw_name) that points to the name of the
firmware being currently used. All code that needs to print the
firmware file name uses i2400m->fw_name instead of the old
i2400m->bus_fw_name.

The code in i2400m_dev_bootstrap() that loads the firmware is changed
with an iterator over the firmware file name list that tries to load
each form user space, using the first one that succeeds in
request_firmware() (and thus stopping the iteration).

The USB and SDIO bus drivers are updated to take advantage of this and
reflect which firmwares they support.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/fw.c     |   53 +++++++++++++++++++++++--------------
 drivers/net/wimax/i2400m/i2400m.h |   21 ++++++++------
 drivers/net/wimax/i2400m/sdio.c   |   11 +++++--
 drivers/net/wimax/i2400m/usb.c    |   14 +++++++--
 4 files changed, 64 insertions(+), 35 deletions(-)

diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index ecd0cfa..675c6ce 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -483,7 +483,7 @@ ssize_t i2400m_dnload_bcf(struct i2400m *i2400m,
 		if (offset + section_size > bcf_len) {
 			dev_err(dev, "fw %s: bad section #%zu, "
 				"end (@%zu) beyond EOF (@%zu)\n",
-				i2400m->bus_fw_name, section,
+				i2400m->fw_name, section,
 				offset + section_size,  bcf_len);
 			ret = -EINVAL;
 			goto error_section_beyond_eof;
@@ -493,7 +493,7 @@ ssize_t i2400m_dnload_bcf(struct i2400m *i2400m,
 				    &ack, sizeof(ack), I2400M_BM_CMD_RAW);
 		if (ret < 0) {
 			dev_err(dev, "fw %s: section #%zu (@%zu %zu B) "
-				"failed %d\n", i2400m->bus_fw_name, section,
+				"failed %d\n", i2400m->fw_name, section,
 				offset, sizeof(*bh) + data_size, (int) ret);
 			goto error_send;
 		}
@@ -874,7 +874,7 @@ int i2400m_dnload_init(struct i2400m *i2400m, const struct i2400m_bcf_hdr *bcf)
 		if (result < 0)
 			dev_err(dev, "fw %s: non-signed download "
 				"initialization failed: %d\n",
-				i2400m->bus_fw_name, result);
+				i2400m->fw_name, result);
 	} else if (i2400m->sboot == 0
 		 && (module_id & I2400M_BCF_MOD_ID_POKES)) {
 		/* non-signed boot process with pokes, nothing to do */
@@ -886,7 +886,7 @@ int i2400m_dnload_init(struct i2400m *i2400m, const struct i2400m_bcf_hdr *bcf)
 		if (result < 0)
 			dev_err(dev, "fw %s: signed boot download "
 				"initialization failed: %d\n",
-				i2400m->bus_fw_name, result);
+				i2400m->fw_name, result);
 	}
 	return result;
 }
@@ -915,7 +915,7 @@ int i2400m_fw_check(struct i2400m *i2400m,
 	if (bcf_size < sizeof(*bcf)) {	/* big enough header? */
 		dev_err(dev, "firmware %s too short: "
 			"%zu B vs %zu (at least) expected\n",
-			i2400m->bus_fw_name, bcf_size, sizeof(*bcf));
+			i2400m->fw_name, bcf_size, sizeof(*bcf));
 		goto error;
 	}
 
@@ -931,7 +931,7 @@ int i2400m_fw_check(struct i2400m *i2400m,
 	if (bcf_size != size) {		/* annoyingly paranoid */
 		dev_err(dev, "firmware %s: bad size, got "
 			"%zu B vs %u expected\n",
-			i2400m->bus_fw_name, bcf_size, size);
+			i2400m->fw_name, bcf_size, size);
 		goto error;
 	}
 
@@ -943,7 +943,7 @@ int i2400m_fw_check(struct i2400m *i2400m,
 
 	if (module_type != 6) {		/* built for the right hardware? */
 		dev_err(dev, "bad fw %s: unexpected module type 0x%x; "
-			"aborting\n", i2400m->bus_fw_name, module_type);
+			"aborting\n", i2400m->fw_name, module_type);
 		goto error;
 	}
 
@@ -951,10 +951,10 @@ int i2400m_fw_check(struct i2400m *i2400m,
 	result = 0;
 	if (module_vendor != 0x8086)
 		dev_err(dev, "bad fw %s? unexpected vendor 0x%04x\n",
-			i2400m->bus_fw_name, module_vendor);
+			i2400m->fw_name, module_vendor);
 	if (date < 0x20080300)
 		dev_err(dev, "bad fw %s? build date too old %08x\n",
-			i2400m->bus_fw_name, date);
+			i2400m->fw_name, date);
 error:
 	return result;
 }
@@ -1016,7 +1016,7 @@ hw_reboot:
 		goto error_dev_rebooted;
 	if (ret < 0) {
 		dev_err(dev, "fw %s: download failed: %d\n",
-			i2400m->bus_fw_name, ret);
+			i2400m->fw_name, ret);
 		goto error_dnload_bcf;
 	}
 
@@ -1026,12 +1026,12 @@ hw_reboot:
 	if (ret < 0) {
 		dev_err(dev, "fw %s: "
 			"download finalization failed: %d\n",
-			i2400m->bus_fw_name, ret);
+			i2400m->fw_name, ret);
 		goto error_dnload_finalize;
 	}
 
 	d_printf(2, dev, "fw %s successfully uploaded\n",
-		 i2400m->bus_fw_name);
+		 i2400m->fw_name);
 	i2400m->boot_mode = 0;
 error_dnload_finalize:
 error_dnload_bcf:
@@ -1067,28 +1067,41 @@ error_dev_rebooted:
  */
 int i2400m_dev_bootstrap(struct i2400m *i2400m, enum i2400m_bri flags)
 {
-	int ret = 0;
+	int ret = 0, itr = 0;
 	struct device *dev = i2400m_dev(i2400m);
 	const struct firmware *fw;
 	const struct i2400m_bcf_hdr *bcf;	/* Firmware data */
+	const char *fw_name;
 
 	d_fnstart(5, dev, "(i2400m %p)\n", i2400m);
+
 	/* Load firmware files to memory. */
-	ret = request_firmware(&fw, i2400m->bus_fw_name, dev);
-	if (ret) {
-		dev_err(dev, "fw %s: request failed: %d\n",
-			i2400m->bus_fw_name, ret);
-		goto error_fw_req;
+	itr = 0;
+	while(1) {
+		fw_name = i2400m->bus_fw_names[itr];
+		if (fw_name == NULL) {
+			dev_err(dev, "Could not find a usable firmware image\n");
+			ret = -ENOENT;
+			goto error_no_fw;
+		}
+		ret = request_firmware(&fw, fw_name, dev);
+		if (ret == 0)
+			break;		/* got it */
+		if (ret < 0)
+			dev_err(dev, "fw %s: cannot load file: %d\n",
+				fw_name, ret);
+		itr++;
 	}
-	bcf = (void *) fw->data;
 
+	bcf = (void *) fw->data;
+	i2400m->fw_name = fw_name;
 	ret = i2400m_fw_check(i2400m, bcf, fw->size);
 	if (ret < 0)
 		goto error_fw_bad;
 	ret = i2400m_fw_dnload(i2400m, bcf, fw->size, flags);
 error_fw_bad:
 	release_firmware(fw);
-error_fw_req:
+error_no_fw:
 	d_fnend(5, dev, "(i2400m %p) = %d\n", i2400m, ret);
 	return ret;
 }
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index f9e5539..ad71ad1 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -156,10 +156,6 @@ enum {
 };
 
 
-/* Firmware version we request when pulling the fw image file */
-#define I2400M_FW_VERSION "1.4"
-
-
 /**
  * i2400m_reset_type - methods to reset a device
  *
@@ -242,10 +238,14 @@ struct i2400m_reset_ctx;
  *     The caller to this function will check if the response is a
  *     barker that indicates the device going into reset mode.
  *
- * @bus_fw_name: [fill] name of the firmware image (in most cases,
- *     they are all the same for a single release, except that they
- *     have the type of the bus embedded in the name (eg:
- *     i2400m-fw-X-VERSION.sbcf, where X is the bus name).
+ * @bus_fw_names: [fill] a NULL-terminated array with the names of the
+ *     firmware images to try loading. This is made a list so we can
+ *     support backward compatibility of firmware releases (eg: if we
+ *     can't find the default v1.4, we try v1.3). In general, the name
+ *     should be i2400m-fw-X-VERSION.sbcf, where X is the bus name.
+ *     The list is tried in order and the first one that loads is
+ *     used. The fw loader will set i2400m->fw_name to point to the
+ *     active firmware image.
  *
  * @bus_bm_mac_addr_impaired: [fill] Set to true if the device's MAC
  *     address provided in boot mode is kind of broken and needs to
@@ -364,6 +364,8 @@ struct i2400m_reset_ctx;
  *     These have to be in a separate directory, a child of
  *     (wimax_dev->debugfs_dentry) so they can be removed when the
  *     module unloads, as we don't keep each dentry.
+ *
+ * @fw_name: name of the firmware image that is currently being used.
  */
 struct i2400m {
 	struct wimax_dev wimax_dev;	/* FIRST! See doc */
@@ -388,7 +390,7 @@ struct i2400m {
 				   size_t, int flags);
 	ssize_t (*bus_bm_wait_for_ack)(struct i2400m *,
 				       struct i2400m_bootrom_header *, size_t);
-	const char *bus_fw_name;
+	const char **bus_fw_names;
 	unsigned bus_bm_mac_addr_impaired:1;
 
 	spinlock_t tx_lock;		/* protect TX state */
@@ -421,6 +423,7 @@ struct i2400m {
 	struct sk_buff *wake_tx_skb;
 
 	struct dentry *debugfs_dentry;
+	const char *fw_name;		/* name of the current firmware image */
 };
 
 
diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
index 123a5f8..5ac5e76 100644
--- a/drivers/net/wimax/i2400m/sdio.c
+++ b/drivers/net/wimax/i2400m/sdio.c
@@ -70,8 +70,13 @@
 static int ioe_timeout = 2;
 module_param(ioe_timeout, int, 0);
 
-/* Our firmware file name */
-#define I2400MS_FW_FILE_NAME "i2400m-fw-sdio-" I2400M_FW_VERSION ".sbcf"
+/* Our firmware file name list */
+static const char *i2400ms_bus_fw_names[] = {
+#define I2400MS_FW_FILE_NAME "i2400m-fw-sdio-1.3.sbcf"
+	I2400MS_FW_FILE_NAME,
+	NULL
+};
+
 
 /*
  * Enable the SDIO function
@@ -401,7 +406,7 @@ int i2400ms_probe(struct sdio_func *func,
 	i2400m->bus_reset = i2400ms_bus_reset;
 	i2400m->bus_bm_cmd_send = i2400ms_bus_bm_cmd_send;
 	i2400m->bus_bm_wait_for_ack = i2400ms_bus_bm_wait_for_ack;
-	i2400m->bus_fw_name = I2400MS_FW_FILE_NAME;
+	i2400m->bus_fw_names = i2400ms_bus_fw_names;
 	i2400m->bus_bm_mac_addr_impaired = 1;
 
 	result = i2400ms_enable_function(i2400ms->func);
diff --git a/drivers/net/wimax/i2400m/usb.c b/drivers/net/wimax/i2400m/usb.c
index 7c28610..ca4151a 100644
--- a/drivers/net/wimax/i2400m/usb.c
+++ b/drivers/net/wimax/i2400m/usb.c
@@ -73,7 +73,14 @@
 
 
 /* Our firmware file name */
-#define I2400MU_FW_FILE_NAME "i2400m-fw-usb-" I2400M_FW_VERSION ".sbcf"
+static const char *i2400mu_bus_fw_names[] = {
+#define I2400MU_FW_FILE_NAME_v1_4 "i2400m-fw-usb-1.4.sbcf"
+	I2400MU_FW_FILE_NAME_v1_4,
+#define I2400MU_FW_FILE_NAME_v1_3 "i2400m-fw-usb-1.3.sbcf"
+	I2400MU_FW_FILE_NAME_v1_3,
+	NULL,
+};
+
 
 static
 int i2400mu_bus_dev_start(struct i2400m *i2400m)
@@ -394,7 +401,7 @@ int i2400mu_probe(struct usb_interface *iface,
 	i2400m->bus_reset = i2400mu_bus_reset;
 	i2400m->bus_bm_cmd_send = i2400mu_bus_bm_cmd_send;
 	i2400m->bus_bm_wait_for_ack = i2400mu_bus_bm_wait_for_ack;
-	i2400m->bus_fw_name = I2400MU_FW_FILE_NAME;
+	i2400m->bus_fw_names = i2400mu_bus_fw_names;
 	i2400m->bus_bm_mac_addr_impaired = 0;
 
 #ifdef CONFIG_PM
@@ -594,4 +601,5 @@ module_exit(i2400mu_driver_exit);
 MODULE_AUTHOR("Intel Corporation <linux-wimax@intel.com>");
 MODULE_DESCRIPTION("Intel 2400M WiMAX networking for USB");
 MODULE_LICENSE("GPL");
-MODULE_FIRMWARE(I2400MU_FW_FILE_NAME);
+MODULE_FIRMWARE(I2400MU_FW_FILE_NAME_v1_4);
+MODULE_FIRMWARE(I2400MU_FW_FILE_NAME_v1_3);
-- 
1.5.6.5
