From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 1/2] netxen: fix the version code macro
Date: Wed,  1 Jul 2009 14:41:42 -0700
Message-ID: <1246484503-10817-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:55452 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752515AbZGAVlk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jul 2009 17:41:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Correct firmware encoding is 8 bit major, 8 bit minor and
16 bit subversion. Flash has sizes rightly set, but original
driver submission messed it leaving 16 bit major and 8 bit
subversion.

Also fix a infinite loop when cut-thru file firmware is
invalid.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |   13 ++++++++++++-
 drivers/net/netxen/netxen_nic_init.c |   25 ++++++++++++++-----------
 2 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 970cede..26afcb5 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -60,7 +60,18 @@
 #define _NETXEN_NIC_LINUX_SUBVERSION 30
 #define NETXEN_NIC_LINUX_VERSIONID  "4.0.30"
 
-#define NETXEN_VERSION_CODE(a, b, c)	(((a) << 16) + ((b) << 8) + (c))
+#define NETXEN_VERSION_CODE(a, b, c)	(((a) << 24) + ((b) << 16) + (c))
+#define _major(v)	(((v) >> 24) & 0xff)
+#define _minor(v)	(((v) >> 16) & 0xff)
+#define _build(v)	((v) & 0xffff)
+
+/* version in image has weird encoding:
+ *  7:0  - major
+ * 15:8  - minor
+ * 31:16 - build (little endian)
+ */
+#define NETXEN_DECODE_VERSION(v) \
+	NETXEN_VERSION_CODE(((v) & 0xff), (((v) >> 8) & 0xff), ((v) >> 16))
 
 #define NETXEN_NUM_FLASH_SECTORS (64)
 #define NETXEN_FLASH_SECTOR_SIZE (64 * 1024)
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 055bb61..7bdcbc6 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -756,7 +756,7 @@ static int
 netxen_validate_firmware(struct netxen_adapter *adapter, const char *fwname)
 {
 	__le32 val;
-	u32 major, minor, build, ver, min_ver, bios;
+	u32 ver, min_ver, bios;
 	struct pci_dev *pdev = adapter->pdev;
 	const struct firmware *fw = adapter->fw;
 
@@ -768,21 +768,18 @@ netxen_validate_firmware(struct netxen_adapter *adapter, const char *fwname)
 		return -EINVAL;
 
 	val = cpu_to_le32(*(u32 *)&fw->data[NX_FW_VERSION_OFFSET]);
-	major = (__force u32)val & 0xff;
-	minor = ((__force u32)val >> 8) & 0xff;
-	build = (__force u32)val >> 16;
 
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
 		min_ver = NETXEN_VERSION_CODE(4, 0, 216);
 	else
 		min_ver = NETXEN_VERSION_CODE(3, 4, 216);
 
-	ver = NETXEN_VERSION_CODE(major, minor, build);
+	ver = NETXEN_DECODE_VERSION(val);
 
-	if ((major > _NETXEN_NIC_LINUX_MAJOR) || (ver < min_ver)) {
+	if ((_major(ver) > _NETXEN_NIC_LINUX_MAJOR) || (ver < min_ver)) {
 		dev_err(&pdev->dev,
 				"%s: firmware version %d.%d.%d unsupported\n",
-				fwname, major, minor, build);
+				fwname, _major(ver), _minor(ver), _build(ver));
 		return -EINVAL;
 	}
 
@@ -798,11 +795,12 @@ netxen_validate_firmware(struct netxen_adapter *adapter, const char *fwname)
 	if (netxen_rom_fast_read(adapter,
 			NX_FW_VERSION_OFFSET, (int *)&val))
 		return -EIO;
-	major = (__force u32)val & 0xff;
-	minor = ((__force u32)val >> 8) & 0xff;
-	build = (__force u32)val >> 16;
-	if (NETXEN_VERSION_CODE(major, minor, build) > ver)
+	val = NETXEN_DECODE_VERSION(val);
+	if (val > ver) {
+		dev_info(&pdev->dev, "%s: firmware is older than flash\n",
+				fwname);
 		return -EINVAL;
+	}
 
 	NXWR32(adapter, NETXEN_CAM_RAM(0x1fc), NETXEN_BDINFO_MAGIC);
 	return 0;
@@ -830,6 +828,8 @@ request_mn:
 
 	netxen_rom_fast_read(adapter,
 			NX_FW_VERSION_OFFSET, (int *)&flashed_ver);
+	flashed_ver = NETXEN_DECODE_VERSION(flashed_ver);
+
 	if (flashed_ver >= NETXEN_VERSION_CODE(4, 0, 220)) {
 		capability = NXRD32(adapter, NX_PEG_TUNE_CAPABILITY);
 		if (capability & NX_PEG_TUNE_MN_PRESENT) {
@@ -838,6 +838,9 @@ request_mn:
 		}
 	}
 
+	adapter->fw = NULL;
+	goto done;
+
 request_fw:
 	rc = request_firmware(&adapter->fw, fw_name[fw_type], &pdev->dev);
 	if (rc != 0) {
-- 
1.6.0.2

