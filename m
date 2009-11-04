From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/2 14/15] wimax/i2400m: support extended firmware format
Date: Wed,  4 Nov 2009 13:39:55 -0800
Message-ID: <bfc44187bbaeabf597be6566a24e8fa7d689b984.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.21]:20710 "EHLO
	orsmga101.jf.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932726AbZKDVmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:01 -0500
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370736.git.inaky@linux.intel.com>
References: <cover.1257370736.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SBCF firmware format has been extended to support extra headers
after the main payload. These extra headers are used to sign the
firmware code with more than one certificate. This eases up
distributing single code images that work in more than one SKU of the
device.

The changes to support this feature will be spread in a series of
commits. This one just adds the support to parse the extra headers and
store them in i2400m->fw_hdrs. Coming changes to the loader code will
use that to determine which header to upload to the device.

The i2400m_fw_check() function now iterates over all the headers and
for each, calls i2400m_fw_hdr_check(), which does some basic checks on
each header. It then stores the headers for the bootloader code to use.

The i2400m_dev_bootstrap() function has been modified to cleanup
i2400m->fw_hdrs when done.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/fw.c     |  189 +++++++++++++++++++++++++------------
 drivers/net/wimax/i2400m/i2400m.h |    4 +
 2 files changed, 134 insertions(+), 59 deletions(-)

diff --git a/drivers/net/wimax/i2400m/fw.c b/drivers/net/wimax/i2400m/fw.c
index 1fd2fee..897e0be 100644
--- a/drivers/net/wimax/i2400m/fw.c
+++ b/drivers/net/wimax/i2400m/fw.c
@@ -78,11 +78,11 @@
  *
  * We can then upload the firmware file. The file is composed of a BCF
  * header (basic data, keys and signatures) and a list of write
- * commands and payloads. We first upload the header
- * [i2400m_dnload_init()] and then pass the commands and payloads
- * verbatim to the i2400m_bm_cmd() function
- * [i2400m_dnload_bcf()]. Then we tell the device to jump to the new
- * firmware [i2400m_dnload_finalize()].
+ * commands and payloads. Optionally more BCF headers might follow the
+ * main payload. We first upload the header [i2400m_dnload_init()] and
+ * then pass the commands and payloads verbatim to the i2400m_bm_cmd()
+ * function [i2400m_dnload_bcf()]. Then we tell the device to jump to
+ * the new firmware [i2400m_dnload_finalize()].
  *
  * Once firmware is uploaded, we are good to go :)
  *
@@ -115,6 +115,7 @@
  * i2400m_dev_bootstrap               Called by __i2400m_dev_start()
  *   request_firmware
  *   i2400m_fw_check
+ *     i2400m_fw_hdr_check
  *   i2400m_fw_dnload
  *   release_firmware
  *
@@ -1151,75 +1152,142 @@ int i2400m_dnload_init(struct i2400m *i2400m, const struct i2400m_bcf_hdr *bcf)
 
 
 /*
- * Run quick consistency tests on the firmware file
+ * Run consistency tests on the firmware file and load up headers
  *
  * Check for the firmware being made for the i2400m device,
  * etc...These checks are mostly informative, as the device will make
  * them too; but the driver's response is more informative on what
  * went wrong.
+ *
+ * This will also look at all the headers present on the firmware
+ * file, and update i2400m->fw_bcf_hdr to point to them.
  */
 static
-int i2400m_fw_check(struct i2400m *i2400m,
-		    const struct i2400m_bcf_hdr *bcf,
-		    size_t bcf_size)
+int i2400m_fw_hdr_check(struct i2400m *i2400m,
+			const struct i2400m_bcf_hdr *bcf_hdr,
+			size_t index, size_t offset)
 {
-	int result;
 	struct device *dev = i2400m_dev(i2400m);
+
 	unsigned module_type, header_len, major_version, minor_version,
 		module_id, module_vendor, date, size;
 
-	/* Check hard errors */
-	result = -EINVAL;
-	if (bcf_size < sizeof(*bcf)) {	/* big enough header? */
-		dev_err(dev, "firmware %s too short: "
-			"%zu B vs %zu (at least) expected\n",
-			i2400m->fw_name, bcf_size, sizeof(*bcf));
-		goto error;
-	}
-
-	module_type = bcf->module_type;
-	header_len = sizeof(u32) * le32_to_cpu(bcf->header_len);
-	major_version = (le32_to_cpu(bcf->header_version) & 0xffff0000) >> 16;
-	minor_version = le32_to_cpu(bcf->header_version) & 0x0000ffff;
-	module_id = le32_to_cpu(bcf->module_id);
-	module_vendor = le32_to_cpu(bcf->module_vendor);
-	date = le32_to_cpu(bcf->date);
-	size = sizeof(u32) * le32_to_cpu(bcf->size);
-
-	if (bcf_size != size) {		/* annoyingly paranoid */
-		dev_err(dev, "firmware %s: bad size, got "
-			"%zu B vs %u expected\n",
-			i2400m->fw_name, bcf_size, size);
-		goto error;
+	module_type = bcf_hdr->module_type;
+	header_len = sizeof(u32) * le32_to_cpu(bcf_hdr->header_len);
+	major_version = (le32_to_cpu(bcf_hdr->header_version) & 0xffff0000)
+		>> 16;
+	minor_version = le32_to_cpu(bcf_hdr->header_version) & 0x0000ffff;
+	module_id = le32_to_cpu(bcf_hdr->module_id);
+	module_vendor = le32_to_cpu(bcf_hdr->module_vendor);
+	date = le32_to_cpu(bcf_hdr->date);
+	size = sizeof(u32) * le32_to_cpu(bcf_hdr->size);
+
+	d_printf(1, dev, "firmware %s #%d@%08x: BCF header "
+		 "type:vendor:id 0x%x:%x:%x v%u.%u (%zu/%zu B) built %08x\n",
+		 i2400m->fw_name, index, offset,
+		 module_type, module_vendor, module_id,
+		 major_version, minor_version, header_len, size, date);
+
+	/* Hard errors */
+	if (major_version != 1) {
+		dev_err(dev, "firmware %s #%d@%08x: major header version "
+			"v%u.%u not supported\n",
+			i2400m->fw_name, index, offset,
+			major_version, minor_version);
+		return -EBADF;
 	}
 
-	d_printf(2, dev, "type 0x%x id 0x%x vendor 0x%x; header v%u.%u (%zu B) "
-		 "date %08x (%zu B)\n",
-		 module_type, module_id, module_vendor,
-		 major_version, minor_version, (size_t) header_len,
-		 date, (size_t) size);
-
 	if (module_type != 6) {		/* built for the right hardware? */
-		dev_err(dev, "bad fw %s: unexpected module type 0x%x; "
-			"aborting\n", i2400m->fw_name, module_type);
-		goto error;
+		dev_err(dev, "firmware %s #%d@%08x: unexpected module "
+			"type 0x%x; aborting\n",
+			i2400m->fw_name, index, offset,
+			module_type);
+		return -EBADF;
 	}
 
-	if (major_version != 1) {
-		dev_err(dev, "%s: major header version v%u.%u not supported\n",
-			i2400m->fw_name, major_version, minor_version);
-		goto error;
+	if (module_vendor != 0x8086) {
+		dev_err(dev, "firmware %s #%d@%08x: unexpected module "
+			"vendor 0x%x; aborting\n",
+			i2400m->fw_name, index, offset, module_vendor);
+		return -EBADF;
 	}
 
-	/* Check soft-er errors */
-	result = 0;
-	if (module_vendor != 0x8086)
-		dev_err(dev, "bad fw %s? unexpected vendor 0x%04x\n",
-			i2400m->fw_name, module_vendor);
 	if (date < 0x20080300)
-		dev_err(dev, "bad fw %s? build date too old %08x\n",
-			i2400m->fw_name, date);
-error:
+		dev_warn(dev, "firmware %s #%d@%08x: build date %08x "
+			 "too old; unsupported\n",
+			 i2400m->fw_name, index, offset, date);
+	return 0;
+}
+
+
+/*
+ * Run consistency tests on the firmware file and load up headers
+ *
+ * Check for the firmware being made for the i2400m device,
+ * etc...These checks are mostly informative, as the device will make
+ * them too; but the driver's response is more informative on what
+ * went wrong.
+ *
+ * This will also look at all the headers present on the firmware
+ * file, and update i2400m->fw_hdrs to point to them.
+ */
+static
+int i2400m_fw_check(struct i2400m *i2400m, const void *bcf, size_t bcf_size)
+{
+	int result;
+	struct device *dev = i2400m_dev(i2400m);
+	size_t headers = 0;
+	const struct i2400m_bcf_hdr *bcf_hdr;
+	const void *itr, *next, *top;
+	unsigned slots = 0, used_slots = 0;
+
+	for (itr = bcf, top = itr + bcf_size;
+	     itr < top;
+	     headers++, itr = next) {
+		size_t leftover, offset, header_len, size;
+
+		leftover = top - itr;
+		offset = itr - (const void *) bcf;
+		if (leftover <= sizeof(*bcf_hdr)) {
+			dev_err(dev, "firmware %s: %zu B left at @%x, "
+				"not enough for BCF header\n",
+				i2400m->fw_name, leftover, offset);
+			break;
+		}
+		bcf_hdr = itr;
+		/* Only the first header is supposed to be followed by
+		 * payload */
+		header_len = sizeof(u32) * le32_to_cpu(bcf_hdr->header_len);
+		size = sizeof(u32) * le32_to_cpu(bcf_hdr->size);
+		if (headers == 0)
+			next = itr + size;
+		else
+			next = itr + header_len;
+
+		result = i2400m_fw_hdr_check(i2400m, bcf_hdr, headers, offset);
+		if (result < 0)
+			continue;
+		if (used_slots + 1 >= slots) {
+			/* +1 -> we need to account for the one we'll
+			 * occupy and at least an extra one for
+			 * always being NULL */
+			result = i2400m_zrealloc_2x(
+				(void **) &i2400m->fw_hdrs, &slots,
+				sizeof(i2400m->fw_hdrs[0]),
+				GFP_KERNEL);
+			if (result < 0)
+				goto error_zrealloc;
+		}
+		i2400m->fw_hdrs[used_slots] = bcf_hdr;
+		used_slots++;
+	}
+	if (headers == 0) {
+		dev_err(dev, "firmware %s: no usable headers found\n",
+			i2400m->fw_name);
+		result = -EBADF;
+	} else
+		result = 0;
+error_zrealloc:
 	return result;
 }
 
@@ -1359,13 +1427,16 @@ int i2400m_dev_bootstrap(struct i2400m *i2400m, enum i2400m_bri flags)
 		bcf = (void *) fw->data;
 		i2400m->fw_name = fw_name;
 		ret = i2400m_fw_check(i2400m, bcf, fw->size);
-		if (ret >= 0) {
+		if (ret >= 0)
 			ret = i2400m_fw_dnload(i2400m, bcf, fw->size, flags);
-			if (ret >= 0)
-				break;
-		} else
-			dev_err(dev, "%s: cannot use, skipping\n", fw_name);
+		if (ret < 0)
+			dev_err(dev, "%s: cannot use: %d, skipping\n",
+				fw_name, ret);
+		kfree(i2400m->fw_hdrs);
+		i2400m->fw_hdrs = NULL;
 		release_firmware(fw);
+		if (ret >= 0)	/* firmware loaded succesfully */
+			break;
 	}
 	d_fnend(5, dev, "(i2400m %p) = %d\n", i2400m, ret);
 	return ret;
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index bcb1882..5ac2cce 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -421,6 +421,9 @@ struct i2400m_barker_db;
  * @fw_version: version of the firmware interface, Major.minor,
  *     encoded in the high word and low word (major << 16 | minor).
  *
+ * @fw_hdrs: NULL terminated array of pointers to the firmware
+ *     headers. This is only available during firmware load time.
+ *
  * @barker: barker type that the device uses; this is initialized by
  *     i2400m_is_boot_barker() the first time it is called. Then it
  *     won't change during the life cycle of the device and everytime
@@ -491,6 +494,7 @@ struct i2400m {
 	struct dentry *debugfs_dentry;
 	const char *fw_name;		/* name of the current firmware image */
 	unsigned long fw_version;	/* version of the firmware interface */
+	const struct i2400m_bcf_hdr **fw_hdrs;
 	struct i2400m_barker_db *barker;
 };
 
-- 
1.6.2.5

