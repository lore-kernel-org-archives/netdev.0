From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/2 15/15] wimax/i2400m: on firmware upload, select BCF header that matches device's request
Date: Wed,  4 Nov 2009 13:39:56 -0800
Message-ID: <10607c86e163e3da8bdf58a934da7dd3a68dcb7c.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20707 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932716AbZKDVmC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:02 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Devices based on the i2400m emit a "barker" (32 bit unsigned) when
they boot. This barker is used to select, in the firmware file image,
which header should be used to process the rest of the file.

This commit implements said support, completing the series started by
previous commits.

We modify the i2400m_fw_dnload() firmware loading path by adding a
call to i2400m_bcf_hdr_find() [new function], in which the right BCF
header [as listed in i2400m->fw_hdrs by i2400m_fw_check()] is
located. Then this header is fed to i2400m_dnload_init() and
i2400m_dnload_finalize().

The changes to i2400m_dnload_finalize() are smaller than they look;
they add the bcf_hdr argument and use that instead of bcf. Likewise in
i2400m_dnload_init().

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/fw.c |  111 ++++++++++++++++++++++++++++++++++-------
 1 files changed, 92 insertions(+), 19 deletions(-)

diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 897e0be..84a39c3 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -665,8 +665,8 @@ static int i2400m_download_chunk(struct i2400m *i2400m, const void *chunk,
  * Download a BCF file's sections to the device
  *
  * @i2400m: device descriptor
- * @bcf: pointer to firmware data (followed by the payloads). Assumed
- *       verified and consistent.
+ * @bcf: pointer to firmware data (first header followed by the
+ *     payloads). Assumed verified and consistent.
  * @bcf_len: length (in bytes) of the @bcf buffer.
  *
  * Returns: < 0 errno code on error or the offset to the jump instruction.
@@ -756,11 +756,17 @@ unsigned i2400m_boot_is_signed(struct i2400m *i2400m)
 /*
  * Do the final steps of uploading firmware
  *
+ * @bcf_hdr: BCF header we are actually using
+ * @bcf: pointer to the firmware image (which matches the first header
+ *     that is followed by the actual payloads).
+ * @offset: [byte] offset into @bcf for the command we need to send.
+ *
  * Depending on the boot mode (signed vs non-signed), different
  * actions need to be taken.
  */
 static
 int i2400m_dnload_finalize(struct i2400m *i2400m,
+			   const struct i2400m_bcf_hdr *bcf_hdr,
 			   const struct i2400m_bcf_hdr *bcf, size_t offset)
 {
 	int ret = 0;
@@ -792,12 +798,13 @@ int i2400m_dnload_finalize(struct i2400m *i2400m,
 		cmd_buf = i2400m->bm_cmd_buf;
 		memcpy(&cmd_buf->cmd, cmd, sizeof(*cmd));
 		signature_block_offset =
-			sizeof(*bcf)
-			+ le32_to_cpu(bcf->key_size) * sizeof(u32)
-			+ le32_to_cpu(bcf->exponent_size) * sizeof(u32);
+			sizeof(*bcf_hdr)
+			+ le32_to_cpu(bcf_hdr->key_size) * sizeof(u32)
+			+ le32_to_cpu(bcf_hdr->exponent_size) * sizeof(u32);
 		signature_block_size =
-			le32_to_cpu(bcf->modulus_size) * sizeof(u32);
-		memcpy(cmd_buf->cmd_pl, (void *) bcf + signature_block_offset,
+			le32_to_cpu(bcf_hdr->modulus_size) * sizeof(u32);
+		memcpy(cmd_buf->cmd_pl,
+		       (void *) bcf_hdr + signature_block_offset,
 		       signature_block_size);
 		ret = i2400m_bm_cmd(i2400m, &cmd_buf->cmd,
 				    sizeof(cmd_buf->cmd) + signature_block_size,
@@ -1122,14 +1129,15 @@ int i2400m_dnload_init_signed(struct i2400m *i2400m,
  * (signed or non-signed).
  */
 static
-int i2400m_dnload_init(struct i2400m *i2400m, const struct i2400m_bcf_hdr *bcf)
+int i2400m_dnload_init(struct i2400m *i2400m,
+		       const struct i2400m_bcf_hdr *bcf_hdr)
 {
 	int result;
 	struct device *dev = i2400m_dev(i2400m);
 
 	if (i2400m_boot_is_signed(i2400m)) {
 		d_printf(1, dev, "signed boot\n");
-		result = i2400m_dnload_init_signed(i2400m, bcf);
+		result = i2400m_dnload_init_signed(i2400m, bcf_hdr);
 		if (result == -ERESTARTSYS)
 			return result;
 		if (result < 0)
@@ -1182,15 +1190,15 @@ int i2400m_fw_hdr_check(struct i2400m *i2400m,
 	date = le32_to_cpu(bcf_hdr->date);
 	size = sizeof(u32) * le32_to_cpu(bcf_hdr->size);
 
-	d_printf(1, dev, "firmware %s #%d@%08x: BCF header "
-		 "type:vendor:id 0x%x:%x:%x v%u.%u (%zu/%zu B) built %08x\n",
+	d_printf(1, dev, "firmware %s #%zd@%08zx: BCF header "
+		 "type:vendor:id 0x%x:%x:%x v%u.%u (%u/%u B) built %08x\n",
 		 i2400m->fw_name, index, offset,
 		 module_type, module_vendor, module_id,
 		 major_version, minor_version, header_len, size, date);
 
 	/* Hard errors */
 	if (major_version != 1) {
-		dev_err(dev, "firmware %s #%d@%08x: major header version "
+		dev_err(dev, "firmware %s #%zd@%08zx: major header version "
 			"v%u.%u not supported\n",
 			i2400m->fw_name, index, offset,
 			major_version, minor_version);
@@ -1198,7 +1206,7 @@ int i2400m_fw_hdr_check(struct i2400m *i2400m,
 	}
 
 	if (module_type != 6) {		/* built for the right hardware? */
-		dev_err(dev, "firmware %s #%d@%08x: unexpected module "
+		dev_err(dev, "firmware %s #%zd@%08zx: unexpected module "
 			"type 0x%x; aborting\n",
 			i2400m->fw_name, index, offset,
 			module_type);
@@ -1206,14 +1214,14 @@ int i2400m_fw_hdr_check(struct i2400m *i2400m,
 	}
 
 	if (module_vendor != 0x8086) {
-		dev_err(dev, "firmware %s #%d@%08x: unexpected module "
+		dev_err(dev, "firmware %s #%zd@%08zx: unexpected module "
 			"vendor 0x%x; aborting\n",
 			i2400m->fw_name, index, offset, module_vendor);
 		return -EBADF;
 	}
 
 	if (date < 0x20080300)
-		dev_warn(dev, "firmware %s #%d@%08x: build date %08x "
+		dev_warn(dev, "firmware %s #%zd@%08zx: build date %08x "
 			 "too old; unsupported\n",
 			 i2400m->fw_name, index, offset, date);
 	return 0;
@@ -1239,7 +1247,7 @@ int i2400m_fw_check(struct i2400m *i2400m, const void *bcf, size_t bcf_size)
 	size_t headers = 0;
 	const struct i2400m_bcf_hdr *bcf_hdr;
 	const void *itr, *next, *top;
-	unsigned slots = 0, used_slots = 0;
+	size_t slots = 0, used_slots = 0;
 
 	for (itr = bcf, top = itr + bcf_size;
 	     itr < top;
@@ -1249,7 +1257,7 @@ int i2400m_fw_check(struct i2400m *i2400m, const void *bcf, size_t bcf_size)
 		leftover = top - itr;
 		offset = itr - (const void *) bcf;
 		if (leftover <= sizeof(*bcf_hdr)) {
-			dev_err(dev, "firmware %s: %zu B left at @%x, "
+			dev_err(dev, "firmware %s: %zu B left at @%zx, "
 				"not enough for BCF header\n",
 				i2400m->fw_name, leftover, offset);
 			break;
@@ -1293,6 +1301,60 @@ error_zrealloc:
 
 
 /*
+ * Match a barker to a BCF header module ID
+ *
+ * The device sends a barker which tells the firmware loader which
+ * header in the BCF file has to be used. This does the matching.
+ */
+static
+unsigned i2400m_bcf_hdr_match(struct i2400m *i2400m,
+			      const struct i2400m_bcf_hdr *bcf_hdr)
+{
+	u32 barker = le32_to_cpu(i2400m->barker->data[0])
+		& 0x7fffffff;
+	u32 module_id = le32_to_cpu(bcf_hdr->module_id)
+		& 0x7fffffff;	/* high bit used for something else */
+
+	/* special case for 5x50 */
+	if (barker == I2400M_SBOOT_BARKER && module_id == 0)
+		return 1;
+	if (module_id == barker)
+		return 1;
+	return 0;
+}
+
+static
+const struct i2400m_bcf_hdr *i2400m_bcf_hdr_find(struct i2400m *i2400m)
+{
+	struct device *dev = i2400m_dev(i2400m);
+	const struct i2400m_bcf_hdr **bcf_itr, *bcf_hdr;
+	unsigned i = 0;
+	u32 barker = le32_to_cpu(i2400m->barker->data[0]);
+
+	d_printf(2, dev, "finding BCF header for barker %08x\n", barker);
+	if (barker == I2400M_NBOOT_BARKER) {
+		bcf_hdr = i2400m->fw_hdrs[0];
+		d_printf(1, dev, "using BCF header #%u/%08x for non-signed "
+			 "barker\n", 0, le32_to_cpu(bcf_hdr->module_id));
+		return bcf_hdr;
+	}
+	for (bcf_itr = i2400m->fw_hdrs; *bcf_itr != NULL; bcf_itr++, i++) {
+		bcf_hdr = *bcf_itr;
+		if (i2400m_bcf_hdr_match(i2400m, bcf_hdr)) {
+			d_printf(1, dev, "hit on BCF hdr #%u/%08x\n",
+				 i, le32_to_cpu(bcf_hdr->module_id));
+			return bcf_hdr;
+		} else
+			d_printf(1, dev, "miss on BCF hdr #%u/%08x\n",
+				 i, le32_to_cpu(bcf_hdr->module_id));
+	}
+	dev_err(dev, "cannot find a matching BCF header for barker %08x\n",
+		barker);
+	return NULL;
+}
+
+
+/*
  * Download the firmware to the device
  *
  * @i2400m: device descriptor
@@ -1313,6 +1375,7 @@ int i2400m_fw_dnload(struct i2400m *i2400m, const struct i2400m_bcf_hdr *bcf,
 	int ret = 0;
 	struct device *dev = i2400m_dev(i2400m);
 	int count = i2400m->bus_bm_retries;
+	const struct i2400m_bcf_hdr *bcf_hdr;
 
 	d_fnstart(5, dev, "(i2400m %p bcf %p size %zu)\n",
 		  i2400m, bcf, bcf_size);
@@ -1337,8 +1400,17 @@ hw_reboot:
 	 * Initialize the download, push the bytes to the device and
 	 * then jump to the new firmware. Note @ret is passed with the
 	 * offset of the jump instruction to _dnload_finalize()
+	 *
+	 * Note we need to use the BCF header in the firmware image
+	 * that matches the barker that the device sent when it
+	 * rebooted, so it has to be passed along.
 	 */
-	ret = i2400m_dnload_init(i2400m, bcf);	/* Init device's dnload */
+	ret = -EBADF;
+	bcf_hdr = i2400m_bcf_hdr_find(i2400m);
+	if (bcf_hdr == NULL)
+		goto error_bcf_hdr_find;
+
+	ret = i2400m_dnload_init(i2400m, bcf_hdr);
 	if (ret == -ERESTARTSYS)
 		goto error_dev_rebooted;
 	if (ret < 0)
@@ -1353,7 +1425,7 @@ hw_reboot:
 		goto error_dnload_bcf;
 	}
 
-	ret = i2400m_dnload_finalize(i2400m, bcf, ret);
+	ret = i2400m_dnload_finalize(i2400m, bcf_hdr, bcf, ret);
 	if (ret == -ERESTARTSYS)
 		goto error_dev_rebooted;
 	if (ret < 0) {
@@ -1370,6 +1442,7 @@ hw_reboot:
 error_dnload_finalize:
 error_dnload_bcf:
 error_dnload_init:
+error_bcf_hdr_find:
 error_bootrom_init:
 error_too_many_reboots:
 	d_fnend(5, dev, "(i2400m %p bcf %p size %zu) = %d\n",
-- 
1.6.2.5

