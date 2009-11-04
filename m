From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/2 09/15] wimax/i2400m: decide properly if using signed vs non-signed firmware loading
Date: Wed,  4 Nov 2009 13:39:50 -0800
Message-ID: <32742e6158657f19ad31653705bef56d983508e7.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20707 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932715AbZKDVmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:00 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The i2400m based devices can boot two main types of firmware images:
signed and non-signed. Signed images have signature data included that
must match that of a certificate stored in the device.

Currently the code is making the decission on what type of firmware
load (signed vs non-signed) is going to be loaded based on a hardcoded
decission in __i2400m_ack_verify(), based on the barker the device
sent upon boot.

This is not flexible enough as future hardware will emit more barkers;
thus the bit has to be set in a place where there is better knowledge
of what is going on. This will be done in follow-up commits -- however
this patch paves the way for it.

So the querying of the mode is packed into i2400m_boot_is_signed();
the main changes are just using i2400m_boot_is_signed() to determine
the method to follow and setting i2400m->sboot in
i2400m_is_boot_barker(). The modifications in i2400m_dnload_init() and
i2400m_dnload_finalize() are just reorganizing the order of the if
blocks and thus look larger than they really are.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/fw.c |   35 +++++++++++++++++++++--------------
 include/linux/wimax/i2400m.h  |   10 ----------
 2 files changed, 21 insertions(+), 24 deletions(-)

diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 92d4d60..c962a8d 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -509,6 +509,17 @@ error_send:
 
 
 /*
+ * Indicate if the device emitted a reboot barker that indicates
+ * "signed boot"
+ */
+static
+unsigned i2400m_boot_is_signed(struct i2400m *i2400m)
+{
+	return likely(i2400m->sboot);
+}
+
+
+/*
  * Do the final steps of uploading firmware
  *
  * Depending on the boot mode (signed vs non-signed), different
@@ -529,7 +540,7 @@ int i2400m_dnload_finalize(struct i2400m *i2400m,
 
 	d_fnstart(3, dev, "offset %zu\n", offset);
 	cmd = (void *) bcf + offset;
-	if (i2400m->sboot == 0) {
+	if (i2400m_boot_is_signed(i2400m) == 0) {
 		struct i2400m_bootrom_header jump_ack;
 		d_printf(1, dev, "unsecure boot, jumping to 0x%08x\n",
 			le32_to_cpu(cmd->target_addr));
@@ -846,28 +857,24 @@ int i2400m_dnload_init(struct i2400m *i2400m, const struct i2400m_bcf_hdr *bcf)
 {
 	int result;
 	struct device *dev = i2400m_dev(i2400m);
-	u32 module_id = le32_to_cpu(bcf->module_id);
 
-	if (i2400m->sboot == 0
-	    && (module_id & I2400M_BCF_MOD_ID_POKES) == 0) {
-		/* non-signed boot process without pokes */
-		result = i2400m_dnload_init_nonsigned(i2400m);
+	if (i2400m_boot_is_signed(i2400m)) {
+		d_printf(1, dev, "signed boot\n");
+		result = i2400m_dnload_init_signed(i2400m, bcf);
 		if (result == -ERESTARTSYS)
 			return result;
 		if (result < 0)
-			dev_err(dev, "fw %s: non-signed download "
+			dev_err(dev, "firmware %s: signed boot download "
 				"initialization failed: %d\n",
 				i2400m->fw_name, result);
-	} else if (i2400m->sboot == 0
-		 && (module_id & I2400M_BCF_MOD_ID_POKES)) {
-		/* non-signed boot process with pokes, nothing to do */
-		result = 0;
-	} else {		 /* signed boot process */
-		result = i2400m_dnload_init_signed(i2400m, bcf);
+	} else {
+		/* non-signed boot process without pokes */
+		d_printf(1, dev, "non-signed boot\n");
+		result = i2400m_dnload_init_nonsigned(i2400m);
 		if (result == -ERESTARTSYS)
 			return result;
 		if (result < 0)
-			dev_err(dev, "fw %s: signed boot download "
+			dev_err(dev, "firmware %s: non-signed download "
 				"initialization failed: %d\n",
 				i2400m->fw_name, result);
 	}
diff --git a/include/linux/wimax/i2400m.h b/include/linux/wimax/i2400m.h
index 433693e..d6e2a35 100644
--- a/include/linux/wimax/i2400m.h
+++ b/include/linux/wimax/i2400m.h
@@ -168,16 +168,6 @@ enum i2400m_brh {
 };
 
 
-/* Constants for bcf->module_id */
-enum i2400m_bcf_mod_id {
-	/* Firmware file carries its own pokes -- pokes are a set of
-	 * magical values that have to be written in certain memory
-	 * addresses to get the device up and ready for firmware
-	 * download when it is in non-signed boot mode. */
-	I2400M_BCF_MOD_ID_POKES = 0x000000001,
-};
-
-
 /**
  * i2400m_bootrom_header - Header for a boot-mode command
  *
-- 
1.6.2.5

