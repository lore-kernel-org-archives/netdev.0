From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/2 10/15] wimax/i2400m: rework bootrom initialization to be more flexible
Date: Wed,  4 Nov 2009 13:39:51 -0800
Message-ID: <aba3792ac2d7c808a2d2fd2adf89531e083bdb90.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20710 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932720AbZKDVmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:00 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This modifies the bootrom initialization code of the i2400m driver so
it can more easily support upcoming hardware.

Currently, the code detects two types of barkers (magic numbers) sent
by the device to indicate the types of firmware it would take (signed
vs non-signed).

This schema is extended so that multiple reboot barkers are
recognized; upcoming hw will expose more types barkers which will have
to match a header in the firmware image before we can load it.

For that, a barker database is introduced; the first time the device
sends a barker, it is matched in the database. That gives the driver
the information needed to decide how to upload the firmware and which
types of firmware to use. The database can be populated from module
parameters.

The execution flow is not altered; a new function
(i2400m_is_boot_barker) is introduced to determine in the RX path if
the device has sent a boot barker. This function is becoming heavier,
so it is put away from the hot reception path [this is why there is
some reorganization in sdio-rx.c:i2400ms_rx and
usb-notifc.c:i2400mu_notification_grok()].

The documentation on the process has also been updated.

All these modifications are heavily based on previous work by Dirk
Brandewie <dirk.brandewie@intel.com>.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c    |   12 ++-
 drivers/net/wimax/i2400m/fw.c        |  313 +++++++++++++++++++++++++++++-----
 drivers/net/wimax/i2400m/i2400m.h    |   36 +++--
 drivers/net/wimax/i2400m/rx.c        |   22 +++
 drivers/net/wimax/i2400m/sdio-rx.c   |   25 ++-
 drivers/net/wimax/i2400m/usb-notif.c |   32 ++---
 6 files changed, 355 insertions(+), 85 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index e3b2c24..73f45ea 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -98,6 +98,15 @@ MODULE_PARM_DESC(debug,
 		 "are the different debug submodules and VALUE are the "
 		 "initial debug value to set.");
 
+static char i2400m_barkers_params[128];
+module_param_string(barkers, i2400m_barkers_params,
+		    sizeof(i2400m_barkers_params), 0644);
+MODULE_PARM_DESC(barkers,
+		 "String of comma-separated 32-bit values; each is "
+		 "recognized as the value the device sends as a reboot "
+		 "signal; values are appended to a list--setting one value "
+		 "as zero cleans the existing list and starts a new one.");
+
 /**
  * i2400m_queue_work - schedule work on a i2400m's queue
  *
@@ -804,7 +813,7 @@ int __init i2400m_driver_init(void)
 {
 	d_parse_params(D_LEVEL, D_LEVEL_SIZE, i2400m_debug_params,
 		       "i2400m.debug");
-	return 0;
+	return i2400m_barker_db_init(i2400m_barkers_params);
 }
 module_init(i2400m_driver_init);
 
@@ -813,6 +822,7 @@ void __exit i2400m_driver_exit(void)
 {
 	/* for scheds i2400m_dev_reset_handle() */
 	flush_scheduled_work();
+	i2400m_barker_db_exit();
 	return;
 }
 module_exit(i2400m_driver_exit);
diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index c962a8d..798564e 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -40,11 +40,9 @@
  *
  * THE PROCEDURE
  *
- * (this is decribed for USB, but for SDIO is similar)
- *
- * The 2400m works in two modes: boot-mode or normal mode. In boot
- * mode we can execute only a handful of commands targeted at
- * uploading the firmware and launching it.
+ * The 2400m and derived devices work in two modes: boot-mode or
+ * normal mode. In boot mode we can execute only a handful of commands
+ * targeted at uploading the firmware and launching it.
  *
  * The 2400m enters boot mode when it is first connected to the
  * system, when it crashes and when you ask it to reboot. There are
@@ -52,18 +50,26 @@
  * firmwares signed with a certain private key, non-signed takes any
  * firmware. Normal hardware takes only signed firmware.
  *
- * Upon entrance to boot mode, the device sends a few zero length
- * packets (ZLPs) on the notification endpoint, then a reboot barker
- * (4 le32 words with value I2400M_{S,N}BOOT_BARKER). We ack it by
- * sending the same barker on the bulk out endpoint. The device acks
- * with a reboot ack barker (4 le32 words with value 0xfeedbabe) and
- * then the device is fully rebooted. At this point we can upload the
- * firmware.
+ * On boot mode, in USB, we write to the device using the bulk out
+ * endpoint and read from it in the notification endpoint. In SDIO we
+ * talk to it via the write address and read from the read address.
+ *
+ * Upon entrance to boot mode, the device sends (preceeded with a few
+ * zero length packets (ZLPs) on the notification endpoint in USB) a
+ * reboot barker (4 le32 words with the same value). We ack it by
+ * sending the same barker to the device. The device acks with a
+ * reboot ack barker (4 le32 words with value I2400M_ACK_BARKER) and
+ * then is fully booted. At this point we can upload the firmware.
+ *
+ * Note that different iterations of the device and EEPROM
+ * configurations will send different [re]boot barkers; these are
+ * collected in i2400m_barker_db along with the firmware
+ * characteristics they require.
  *
  * This process is accomplished by the i2400m_bootrom_init()
  * function. All the device interaction happens through the
  * i2400m_bm_cmd() [boot mode command]. Special return values will
- * indicate if the device resets.
+ * indicate if the device did reset during the process.
  *
  * After this, we read the MAC address and then (if needed)
  * reinitialize the device. We need to read it ahead of time because
@@ -101,6 +107,11 @@
  *
  * ROADMAP
  *
+ * i2400m_barker_db_init              Called by i2400m_driver_init()
+ *   i2400m_barker_db_add
+ *
+ * i2400m_barker_db_exit              Called by i2400m_driver_exit()
+ *
  * i2400m_dev_bootstrap               Called by __i2400m_dev_start()
  *   request_firmware
  *   i2400m_fw_check
@@ -125,6 +136,7 @@
  *   i2400m->bus_bm_cmd_send()
  *   i2400m->bus_bm_wait_for_ack
  *   __i2400m_bm_ack_verify
+ *     i2400m_is_boot_barker
  *
  * i2400m_bm_cmd_prepare              Used by bus-drivers to prep
  *                                    commands before sending
@@ -175,6 +187,237 @@ EXPORT_SYMBOL_GPL(i2400m_bm_cmd_prepare);
 
 
 /*
+ * Database of known barkers.
+ *
+ * A barker is what the device sends indicating he is ready to be
+ * bootloaded. Different versions of the device will send different
+ * barkers. Depending on the barker, it might mean the device wants
+ * some kind of firmware or the other.
+ */
+static struct i2400m_barker_db {
+	__le32 data[4];
+} *i2400m_barker_db;
+static size_t i2400m_barker_db_used, i2400m_barker_db_size;
+
+
+static
+int i2400m_zrealloc_2x(void **ptr, size_t *_count, size_t el_size,
+		       gfp_t gfp_flags)
+{
+	size_t old_count = *_count,
+		new_count = old_count ? 2 * old_count : 2,
+		old_size = el_size * old_count,
+		new_size = el_size * new_count;
+	void *nptr = krealloc(*ptr, new_size, gfp_flags);
+	if (nptr) {
+		/* zero the other half or the whole thing if old_count
+		 * was zero */
+		if (old_size == 0)
+			memset(nptr, 0, new_size);
+		else
+			memset(nptr + old_size, 0, old_size);
+		*_count = new_count;
+		*ptr = nptr;
+		return 0;
+	} else
+		return -ENOMEM;
+}
+
+
+/*
+ * Add a barker to the database
+ *
+ * This cannot used outside of this module and only at at module_init
+ * time. This is to avoid the need to do locking.
+ */
+static
+int i2400m_barker_db_add(u32 barker_id)
+{
+	int result;
+
+	struct i2400m_barker_db *barker;
+	if (i2400m_barker_db_used >= i2400m_barker_db_size) {
+		result = i2400m_zrealloc_2x(
+			(void **) &i2400m_barker_db, &i2400m_barker_db_size,
+			sizeof(i2400m_barker_db[0]), GFP_KERNEL);
+		if (result < 0)
+			return result;
+	}
+	barker = i2400m_barker_db + i2400m_barker_db_used++;
+	barker->data[0] = le32_to_cpu(barker_id);
+	barker->data[1] = le32_to_cpu(barker_id);
+	barker->data[2] = le32_to_cpu(barker_id);
+	barker->data[3] = le32_to_cpu(barker_id);
+	return 0;
+}
+
+
+void i2400m_barker_db_exit(void)
+{
+	kfree(i2400m_barker_db);
+	i2400m_barker_db = NULL;
+	i2400m_barker_db_size = 0;
+	i2400m_barker_db_used = 0;
+}
+
+
+/*
+ * Helper function to add all the known stable barkers to the barker
+ * database.
+ */
+static
+int i2400m_barker_db_known_barkers(void)
+{
+	int result;
+
+	result = i2400m_barker_db_add(I2400M_NBOOT_BARKER);
+	if (result < 0)
+		goto error_add;
+	result = i2400m_barker_db_add(I2400M_SBOOT_BARKER);
+	if (result < 0)
+		goto error_add;
+error_add:
+       return result;
+}
+
+
+/*
+ * Initialize the barker database
+ *
+ * This can only be used from the module_init function for this
+ * module; this is to avoid the need to do locking.
+ *
+ * @options: command line argument with extra barkers to
+ *     recognize. This is a comma-separated list of 32-bit hex
+ *     numbers. They are appended to the existing list. Setting 0
+ *     cleans the existing list and starts a new one.
+ */
+int i2400m_barker_db_init(const char *_options)
+{
+	int result;
+	char *options = NULL, *options_orig, *token;
+
+	i2400m_barker_db = NULL;
+	i2400m_barker_db_size = 0;
+	i2400m_barker_db_used = 0;
+
+	result = i2400m_barker_db_known_barkers();
+	if (result < 0)
+		goto error_add;
+	/* parse command line options from i2400m.barkers */
+	if (_options != NULL) {
+		unsigned barker;
+
+		options_orig = kstrdup(_options, GFP_KERNEL);
+		if (options_orig == NULL)
+			goto error_parse;
+		options = options_orig;
+
+		while ((token = strsep(&options, ",")) != NULL) {
+			if (*token == '\0')	/* eat joint commas */
+				continue;
+			if (sscanf(token, "%x", &barker) != 1
+			    || barker > 0xffffffff) {
+				printk(KERN_ERR "%s: can't recognize "
+				       "i2400m.barkers value '%s' as "
+				       "a 32-bit number\n",
+				       __func__, token);
+				result = -EINVAL;
+				goto error_parse;
+			}
+			if (barker == 0) {
+				/* clean list and start new */
+				i2400m_barker_db_exit();
+				continue;
+			}
+			result = i2400m_barker_db_add(barker);
+			if (result < 0)
+				goto error_add;
+		}
+		kfree(options_orig);
+	}
+	return 0;
+
+error_parse:
+error_add:
+	kfree(i2400m_barker_db);
+	return result;
+}
+
+
+/*
+ * Recognize a boot barker
+ *
+ * @buf: buffer where the boot barker.
+ * @buf_size: size of the buffer (has to be 16 bytes). It is passed
+ *     here so the function can check it for the caller.
+ *
+ * Note that as a side effect, upon identifying the obtained boot
+ * barker, this function will set i2400m->barker to point to the right
+ * barker database entry. Subsequent calls to the function will result
+ * in verifying that the same type of boot barker is returned when the
+ * device [re]boots (as long as the same device instance is used).
+ *
+ * Return: 0 if @buf matches a known boot barker. -ENOENT if the
+ *     buffer in @buf doesn't match any boot barker in the database or
+ *     -EILSEQ if the buffer doesn't have the right size.
+ */
+int i2400m_is_boot_barker(struct i2400m *i2400m,
+			  const void *buf, size_t buf_size)
+{
+	int result;
+	struct device *dev = i2400m_dev(i2400m);
+	struct i2400m_barker_db *barker;
+	int i;
+
+	result = -ENOENT;
+	if (buf_size != sizeof(i2400m_barker_db[i].data))
+		return result;
+
+	/* Short circuit if we have already discovered the barker
+	 * associated with the device. */
+	if (i2400m->barker
+	    && !memcmp(buf, i2400m->barker, sizeof(i2400m->barker->data))) {
+		unsigned index = (i2400m->barker - i2400m_barker_db)
+			/ sizeof(*i2400m->barker);
+		d_printf(2, dev, "boot barker cache-confirmed #%u/%08x\n",
+			 index, le32_to_cpu(i2400m->barker->data[0]));
+		return 0;
+	}
+
+	for (i = 0; i < i2400m_barker_db_used; i++) {
+		barker = &i2400m_barker_db[i];
+		BUILD_BUG_ON(sizeof(barker->data) != 16);
+		if (memcmp(buf, barker->data, sizeof(barker->data)))
+			continue;
+
+		if (i2400m->barker == NULL) {
+			i2400m->barker = barker;
+			d_printf(1, dev, "boot barker set to #%u/%08x\n",
+				 i, le32_to_cpu(barker->data[0]));
+			if (barker->data[0] == le32_to_cpu(I2400M_NBOOT_BARKER))
+				i2400m->sboot = 0;
+			else
+				i2400m->sboot = 1;
+		} else if (i2400m->barker != barker) {
+			dev_err(dev, "HW inconsistency: device "
+				"reports a different boot barker "
+				"than set (from %08x to %08x)\n",
+				le32_to_cpu(i2400m->barker->data[0]),
+				le32_to_cpu(barker->data[0]));
+			result = -EIO;
+		} else
+			d_printf(2, dev, "boot barker confirmed #%u/%08x\n",
+				 i, le32_to_cpu(barker->data[0]));
+		result = 0;
+		break;
+	}
+	return result;
+}
+EXPORT_SYMBOL_GPL(i2400m_is_boot_barker);
+
+
+/*
  * Verify the ack data received
  *
  * Given a reply to a boot mode command, chew it and verify everything
@@ -204,20 +447,10 @@ ssize_t __i2400m_bm_ack_verify(struct i2400m *i2400m, int opcode,
 			opcode, ack_size, sizeof(*ack));
 		goto error_ack_short;
 	}
-	if (ack_size == sizeof(i2400m_NBOOT_BARKER)
-		 && memcmp(ack, i2400m_NBOOT_BARKER, sizeof(*ack)) == 0) {
-		result = -ERESTARTSYS;
-		i2400m->sboot = 0;
-		d_printf(6, dev, "boot-mode cmd %d: "
-			 "HW non-signed boot barker\n", opcode);
-		goto error_reboot;
-	}
-	if (ack_size == sizeof(i2400m_SBOOT_BARKER)
-		 && memcmp(ack, i2400m_SBOOT_BARKER, sizeof(*ack)) == 0) {
+	result = i2400m_is_boot_barker(i2400m, ack, ack_size);
+	if (result >= 0) {
 		result = -ERESTARTSYS;
-		i2400m->sboot = 1;
-		d_printf(6, dev, "boot-mode cmd %d: HW signed reboot barker\n",
-			 opcode);
+		d_printf(6, dev, "boot-mode cmd %d: HW boot barker\n", opcode);
 		goto error_reboot;
 	}
 	if (ack_size == sizeof(i2400m_ACK_BARKER)
@@ -590,9 +823,6 @@ int i2400m_dnload_finalize(struct i2400m *i2400m,
  *
  *     < 0 errno code on error, 0 if ok.
  *
- *     i2400m->sboot set to 0 for unsecure boot process, 1 for secure
- *     boot process.
- *
  * Description:
  *
  * Tries hard enough to put the device in boot-mode. There are two
@@ -619,7 +849,7 @@ int i2400m_bootrom_init(struct i2400m *i2400m, enum i2400m_bri flags)
 	int count = i2400m->bus_bm_retries;
 	int ack_timeout_cnt = 1;
 
-	BUILD_BUG_ON(sizeof(*cmd) != sizeof(i2400m_NBOOT_BARKER));
+	BUILD_BUG_ON(sizeof(*cmd) != sizeof(i2400m_barker_db[0].data));
 	BUILD_BUG_ON(sizeof(ack) != sizeof(i2400m_ACK_BARKER));
 
 	d_fnstart(4, dev, "(i2400m %p flags 0x%08x)\n", i2400m, flags);
@@ -647,8 +877,14 @@ do_reboot:
 	case -ETIMEDOUT:	/* device has timed out, we might be in boot
 				 * mode already and expecting an ack, let's try
 				 * that */
-		dev_info(dev, "warm reset timed out, trying an ack\n");
-		goto do_reboot_ack;
+		if (i2400m->barker == NULL) {
+			dev_info(dev, "warm reset timed out, unknown barker "
+				 "type, rebooting\n");
+			goto do_reboot;
+		} else {
+			dev_info(dev, "warm reset timed out, trying an ack\n");
+			goto do_reboot_ack;
+		}
 	case -EPROTO:
 	case -ESHUTDOWN:	/* dev is gone */
 	case -EINTR:		/* user cancelled */
@@ -664,12 +900,7 @@ do_reboot:
 	 * notification and report it as -EISCONN. */
 do_reboot_ack:
 	d_printf(4, dev, "device reboot ack: sending ack [%d # left]\n", count);
-	if (i2400m->sboot == 0)
-		memcpy(cmd, i2400m_NBOOT_BARKER,
-		       sizeof(i2400m_NBOOT_BARKER));
-	else
-		memcpy(cmd, i2400m_SBOOT_BARKER,
-		       sizeof(i2400m_SBOOT_BARKER));
+	memcpy(cmd, i2400m->barker->data, sizeof(i2400m->barker->data));
 	result = i2400m_bm_cmd(i2400m, cmd, sizeof(*cmd),
 			       &ack, sizeof(ack), I2400M_BM_CMD_RAW);
 	switch (result) {
@@ -682,10 +913,8 @@ do_reboot_ack:
 		d_printf(4, dev, "reboot ack: got ack barker - good\n");
 		break;
 	case -ETIMEDOUT:	/* no response, maybe it is the other type? */
-		if (ack_timeout_cnt-- >= 0) {
-			d_printf(4, dev, "reboot ack timedout: "
-				 "trying the other type?\n");
-			i2400m->sboot = !i2400m->sboot;
+		if (ack_timeout_cnt-- < 0) {
+			d_printf(4, dev, "reboot ack timedout: retrying\n");
 			goto do_reboot_ack;
 		} else {
 			dev_err(dev, "reboot ack timedout too long: "
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 73b4e6a..bcb1882 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -194,6 +194,7 @@ enum i2400m_reset_type {
 
 struct i2400m_reset_ctx;
 struct i2400m_roq;
+struct i2400m_barker_db;
 
 /**
  * struct i2400m - descriptor for an Intel 2400m
@@ -419,6 +420,12 @@ struct i2400m_roq;
  *
  * @fw_version: version of the firmware interface, Major.minor,
  *     encoded in the high word and low word (major << 16 | minor).
+ *
+ * @barker: barker type that the device uses; this is initialized by
+ *     i2400m_is_boot_barker() the first time it is called. Then it
+ *     won't change during the life cycle of the device and everytime
+ *     a boot barker is received, it is just verified for it being the
+ *     same.
  */
 struct i2400m {
 	struct wimax_dev wimax_dev;	/* FIRST! See doc */
@@ -484,6 +491,7 @@ struct i2400m {
 	struct dentry *debugfs_dentry;
 	const char *fw_name;		/* name of the current firmware image */
 	unsigned long fw_version;	/* version of the firmware interface */
+	struct i2400m_barker_db *barker;
 };
 
 
@@ -574,6 +582,14 @@ extern void i2400m_bm_cmd_prepare(struct i2400m_bootrom_header *);
 extern int i2400m_dev_bootstrap(struct i2400m *, enum i2400m_bri);
 extern int i2400m_read_mac_addr(struct i2400m *);
 extern int i2400m_bootrom_init(struct i2400m *, enum i2400m_bri);
+extern int i2400m_is_boot_barker(struct i2400m *, const void *, size_t);
+static inline
+int i2400m_is_d2h_barker(const void *buf)
+{
+	const __le32 *barker = buf;
+	return le32_to_cpu(*barker) == I2400M_D2H_MSG_BARKER;
+}
+extern void i2400m_unknown_barker(struct i2400m *, const void *, size_t);
 
 /* Make/grok boot-rom header commands */
 
@@ -736,20 +752,6 @@ extern int i2400m_rx(struct i2400m *, struct sk_buff *);
 extern struct i2400m_msg_hdr *i2400m_tx_msg_get(struct i2400m *, size_t *);
 extern void i2400m_tx_msg_sent(struct i2400m *);
 
-static const __le32 i2400m_NBOOT_BARKER[4] = {
-	cpu_to_le32(I2400M_NBOOT_BARKER),
-	cpu_to_le32(I2400M_NBOOT_BARKER),
-	cpu_to_le32(I2400M_NBOOT_BARKER),
-	cpu_to_le32(I2400M_NBOOT_BARKER)
-};
-
-static const __le32 i2400m_SBOOT_BARKER[4] = {
-	cpu_to_le32(I2400M_SBOOT_BARKER),
-	cpu_to_le32(I2400M_SBOOT_BARKER),
-	cpu_to_le32(I2400M_SBOOT_BARKER),
-	cpu_to_le32(I2400M_SBOOT_BARKER)
-};
-
 extern int i2400m_power_save_disabled;
 
 /*
@@ -848,6 +850,12 @@ void __i2400m_msleep(unsigned ms)
 #endif
 }
 
+
+/* module initialization helpers */
+extern int i2400m_barker_db_init(const char *);
+extern void i2400m_barker_db_exit(void);
+
+
 /* Module parameters */
 
 extern int i2400m_idle_mode_disabled;
diff --git a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
index 07c32e6..bcd411f 100644
--- a/drivers/net/wimax/i2400m/rx.c
+++ b/drivers/net/wimax/i2400m/rx.c
@@ -1194,6 +1194,28 @@ error_msg_hdr_check:
 EXPORT_SYMBOL_GPL(i2400m_rx);
 
 
+void i2400m_unknown_barker(struct i2400m *i2400m,
+			   const void *buf, size_t size)
+{
+	struct device *dev = i2400m_dev(i2400m);
+	char prefix[64];
+	const __le32 *barker = buf;
+	dev_err(dev, "RX: HW BUG? unknown barker %08x, "
+		"dropping %zu bytes\n", le32_to_cpu(*barker), size);
+	snprintf(prefix, sizeof(prefix), "%s %s: ",
+		 dev_driver_string(dev), dev_name(dev));
+	if (size > 64) {
+		print_hex_dump(KERN_ERR, prefix, DUMP_PREFIX_OFFSET,
+			       8, 4, buf, 64, 0);
+		printk(KERN_ERR "%s... (only first 64 bytes "
+		       "dumped)\n", prefix);
+	} else
+		print_hex_dump(KERN_ERR, prefix, DUMP_PREFIX_OFFSET,
+			       8, 4, buf, size, 0);
+}
+EXPORT_SYMBOL(i2400m_unknown_barker);
+
+
 /*
  * Initialize the RX queue and infrastructure
  *
diff --git a/drivers/net/wimax/i2400m/sdio-rx.c b/drivers/net/wimax/i2400m/sdio-rx.c
index 1c90469..87263be 100644
--- a/drivers/net/wimax/i2400m/sdio-rx.c
+++ b/drivers/net/wimax/i2400m/sdio-rx.c
@@ -53,6 +53,7 @@
  * i2400ms_irq()
  *   i2400ms_rx()
  *     __i2400ms_rx_get_size()
+ *     i2400m_is_boot_barker()
  *     i2400m_rx()
  *
  * i2400ms_rx_setup()
@@ -158,7 +159,7 @@ void i2400ms_rx(struct i2400ms *i2400ms)
 	}
 
 	rmb();	/* make sure we get boot_mode from dev_reset_handle */
-	if (i2400m->boot_mode == 1) {
+	if (unlikely(i2400m->boot_mode == 1)) {
 		spin_lock(&i2400m->rx_lock);
 		i2400ms->bm_ack_size = rx_size;
 		spin_unlock(&i2400m->rx_lock);
@@ -166,17 +167,26 @@ void i2400ms_rx(struct i2400ms *i2400ms)
 		wake_up(&i2400ms->bm_wfa_wq);
 		dev_err(dev, "RX: SDIO boot mode message\n");
 		kfree_skb(skb);
-	} else if (unlikely(!memcmp(skb->data, i2400m_NBOOT_BARKER,
-				    sizeof(i2400m_NBOOT_BARKER))
-			    || !memcmp(skb->data, i2400m_SBOOT_BARKER,
-				       sizeof(i2400m_SBOOT_BARKER)))) {
+		goto out;
+	}
+	ret = -EIO;
+	if (unlikely(rx_size < sizeof(__le32))) {
+		dev_err(dev, "HW BUG? only %zu bytes received\n", rx_size);
+		goto error_bad_size;
+	}
+	if (likely(i2400m_is_d2h_barker(skb->data))) {
+		skb_put(skb, rx_size);
+		i2400m_rx(i2400m, skb);
+	} else if (unlikely(i2400m_is_boot_barker(i2400m,
+						  skb->data, rx_size))) {
 		ret = i2400m_dev_reset_handle(i2400m);
 		dev_err(dev, "RX: SDIO reboot barker\n");
 		kfree_skb(skb);
 	} else {
-		skb_put(skb, rx_size);
-		i2400m_rx(i2400m, skb);
+		i2400m_unknown_barker(i2400m, skb->data, rx_size);
+		kfree_skb(skb);
 	}
+out:
 	d_fnend(7, dev, "(i2400ms %p) = void\n", i2400ms);
 	return;
 
@@ -184,6 +194,7 @@ error_memcpy_fromio:
 	kfree_skb(skb);
 error_alloc_skb:
 error_get_size:
+error_bad_size:
 	d_fnend(7, dev, "(i2400ms %p) = %d\n", i2400ms, ret);
 	return;
 }
diff --git a/drivers/net/wimax/i2400m/usb-notif.c b/drivers/net/wimax/i2400m/usb-notif.c
index 3e11e35..a0751a3 100644
--- a/drivers/net/wimax/i2400m/usb-notif.c
+++ b/drivers/net/wimax/i2400m/usb-notif.c
@@ -51,6 +51,7 @@
  *
  * i2400mu_usb_notification_cb()	Called when a URB is ready
  *   i2400mu_notif_grok()
+ *     i2400m_is_boot_barker()
  *     i2400m_dev_reset_handle()
  *     i2400mu_rx_kick()
  */
@@ -87,32 +88,21 @@ int i2400mu_notification_grok(struct i2400mu *i2400mu, const void *buf,
 	d_fnstart(4, dev, "(i2400m %p buf %p buf_len %zu)\n",
 		  i2400mu, buf, buf_len);
 	ret = -EIO;
-	if (buf_len < sizeof(i2400m_NBOOT_BARKER))
+	if (buf_len < sizeof(i2400m_ZERO_BARKER))
 		/* Not a bug, just ignore */
 		goto error_bad_size;
-	if (!memcmp(i2400m_NBOOT_BARKER, buf, sizeof(i2400m_NBOOT_BARKER))
-	    || !memcmp(i2400m_SBOOT_BARKER, buf, sizeof(i2400m_SBOOT_BARKER)))
-		ret = i2400m_dev_reset_handle(i2400m);
-	else if (!memcmp(i2400m_ZERO_BARKER, buf, sizeof(i2400m_ZERO_BARKER))) {
+	ret = 0;
+	if (!memcmp(i2400m_ZERO_BARKER, buf, sizeof(i2400m_ZERO_BARKER))) {
 		i2400mu_rx_kick(i2400mu);
-		ret = 0;
-	} else {	/* Unknown or unexpected data in the notif message */
-		char prefix[64];
-		ret = -EIO;
-		dev_err(dev, "HW BUG? Unknown/unexpected data in notification "
-			"message (%zu bytes)\n", buf_len);
-		snprintf(prefix, sizeof(prefix), "%s %s: ",
-			 dev_driver_string(dev), dev_name(dev));
-		if (buf_len > 64) {
-			print_hex_dump(KERN_ERR, prefix, DUMP_PREFIX_OFFSET,
-				       8, 4, buf, 64, 0);
-			printk(KERN_ERR "%s... (only first 64 bytes "
-			       "dumped)\n", prefix);
-		} else
-			print_hex_dump(KERN_ERR, prefix, DUMP_PREFIX_OFFSET,
-				       8, 4, buf, buf_len, 0);
+		goto out;
 	}
+	ret = i2400m_is_boot_barker(i2400m, buf, buf_len);
+	if (unlikely(ret >= 0))
+		ret = i2400m_dev_reset_handle(i2400m);
+	else	/* Unknown or unexpected data in the notif message */
+		i2400m_unknown_barker(i2400m, buf, buf_len);
 error_bad_size:
+out:
 	d_fnend(4, dev, "(i2400m %p buf %p buf_len %zu) = %d\n",
 		i2400mu, buf, buf_len, ret);
 	return ret;
-- 
1.6.2.5

