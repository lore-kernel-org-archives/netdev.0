From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next] netxen: fix firmware download warnings
Date: Sun, 15 Mar 2009 23:41:02 -0700
Message-ID: <1237185662-16726-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net, sfr@canb.auug.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:47887 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751435AbZCPGlI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Mar 2009 02:41:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix following warnings, by using integer firmware types.

drivers/net/netxen/netxen_nic_hw.c: In function 'netxen_load_firmware':
drivers/net/netxen/netxen_nic_hw.c:1146: warning: comparison with string literal results in unspecified behavior
drivers/net/netxen/netxen_nic_hw.c:1146: warning: comparison with string literal results in unspecified behavior
drivers/net/netxen/netxen_nic_hw.c:1146: warning: comparison with string literal results in unspecified behavior
drivers/net/netxen/netxen_nic_hw.c:1159: warning: comparison with string literal results in unspecified behavior
drivers/net/netxen/netxen_nic_hw.c:1159: warning: comparison with string literal results in unspecified behavior
drivers/net/netxen/netxen_nic_hw.c:1159: warning: comparison with string literal results in unspecified behavior

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h    |    6 +++---
 drivers/net/netxen/netxen_nic_hw.c |   24 ++++++++++++------------
 2 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 2544129..78e6228 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -693,9 +693,9 @@ typedef enum {
 #define NX_BIOS_VERSION_OFFSET	(NETXEN_USER_START+0x83c)
 #define NX_FW_MAGIC_OFFSET	(NETXEN_BRDCFG_START+0x128)
 #define NX_FW_MIN_SIZE		(0x3fffff)
-#define NX_P2_MN_ROMIMAGE	"nxromimg.bin"
-#define NX_P3_CT_ROMIMAGE	"nx3fwct.bin"
-#define NX_P3_MN_ROMIMAGE	"nx3fwmn.bin"
+#define NX_P2_MN_ROMIMAGE	0
+#define NX_P3_CT_ROMIMAGE	1
+#define NX_P3_MN_ROMIMAGE	2
 
 #define NETXEN_USER_START_OLD NETXEN_PXE_START	/* for backward compatibility */
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index c89c791..b24cfdd 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1130,21 +1130,21 @@ netxen_validate_firmware(struct netxen_adapter *adapter, const char *fwname,
 	return 0;
 }
 
+static char *fw_name[] = { "nxromimg.bin", "nx3fwct.bin", "nx3fwmn.bin" };
+
 int netxen_load_firmware(struct netxen_adapter *adapter)
 {
 	u32 capability, flashed_ver;
 	const struct firmware *fw;
-	char *fw_name = NULL;
+	int fw_type;
 	struct pci_dev *pdev = adapter->pdev;
 	int rc = 0;
 
 	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
-		fw_name = NX_P2_MN_ROMIMAGE;
+		fw_type = NX_P2_MN_ROMIMAGE;
 		goto request_fw;
-	}
-
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
-		fw_name = NX_P3_CT_ROMIMAGE;
+	} else {
+		fw_type = NX_P3_CT_ROMIMAGE;
 		goto request_fw;
 	}
 
@@ -1157,15 +1157,15 @@ request_mn:
 		adapter->hw_read_wx(adapter,
 				NX_PEG_TUNE_CAPABILITY, &capability, 4);
 		if (capability & NX_PEG_TUNE_MN_PRESENT) {
-			fw_name = NX_P3_MN_ROMIMAGE;
+			fw_type = NX_P3_MN_ROMIMAGE;
 			goto request_fw;
 		}
 	}
 
 request_fw:
-	rc = request_firmware(&fw, fw_name, &pdev->dev);
+	rc = request_firmware(&fw, fw_name[fw_type], &pdev->dev);
 	if (rc != 0) {
-		if (fw_name == NX_P3_CT_ROMIMAGE) {
+		if (fw_type == NX_P3_CT_ROMIMAGE) {
 			msleep(1);
 			goto request_mn;
 		}
@@ -1174,11 +1174,11 @@ request_fw:
 		goto load_fw;
 	}
 
-	rc = netxen_validate_firmware(adapter, fw_name, fw);
+	rc = netxen_validate_firmware(adapter, fw_name[fw_type], fw);
 	if (rc != 0) {
 		release_firmware(fw);
 
-		if (fw_name == NX_P3_CT_ROMIMAGE) {
+		if (fw_type == NX_P3_CT_ROMIMAGE) {
 			msleep(1);
 			goto request_mn;
 		}
@@ -1187,7 +1187,7 @@ request_fw:
 	}
 
 load_fw:
-	rc = netxen_do_load_firmware(adapter, fw_name, fw);
+	rc = netxen_do_load_firmware(adapter, fw_name[fw_type], fw);
 
 	if (fw)
 		release_firmware(fw);
-- 
1.6.0.2

