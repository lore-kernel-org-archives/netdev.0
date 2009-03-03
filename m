From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 2/2] netxen: firmware download improvements
Date: Mon,  2 Mar 2009 18:02:17 -0800
Message-ID: <1236045737-482-2-git-send-email-dhananjay@netxen.com>
References: <1236045737-482-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:49842 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752338AbZCCCCY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 21:02:24 -0500
In-Reply-To: <1236045737-482-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o set port mode after resetting device.
o prefer cut-through firmware (doesn't require on-card memory).
o load flashed firmware if newer.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_hw.c   |   27 ++++++++++++++++++++-------
 drivers/net/netxen/netxen_nic_main.c |    7 ++++---
 2 files changed, 24 insertions(+), 10 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index b15246c..b564d69 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1069,6 +1069,16 @@ netxen_validate_firmware(struct netxen_adapter *adapter, const char *fwname,
 		return -EINVAL;
 	}
 
+	/* check if flashed firmware is newer */
+	if (netxen_rom_fast_read(adapter,
+			NX_FW_VERSION_OFFSET, (int *)&val))
+		return -EIO;
+	major = (__force u32)val & 0xff;
+	minor = ((__force u32)val >> 8) & 0xff;
+	build = (__force u32)val >> 16;
+	if (NETXEN_VERSION_CODE(major, minor, build) > ver)
+		return -EINVAL;
+
 	netxen_nic_reg_write(adapter, NETXEN_CAM_RAM(0x1fc),
 			NETXEN_BDINFO_MAGIC);
 	return 0;
@@ -1087,6 +1097,12 @@ int netxen_load_firmware(struct netxen_adapter *adapter)
 		goto request_fw;
 	}
 
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
+		fw_name = NX_P3_CT_ROMIMAGE;
+		goto request_fw;
+	}
+
+request_mn:
 	capability = 0;
 
 	netxen_rom_fast_read(adapter,
@@ -1100,15 +1116,12 @@ int netxen_load_firmware(struct netxen_adapter *adapter)
 		}
 	}
 
-request_ct:
-	fw_name = NX_P3_CT_ROMIMAGE;
-
 request_fw:
 	rc = request_firmware(&fw, fw_name, &pdev->dev);
 	if (rc != 0) {
-		if (fw_name == NX_P3_MN_ROMIMAGE) {
+		if (fw_name == NX_P3_CT_ROMIMAGE) {
 			msleep(1);
-			goto request_ct;
+			goto request_mn;
 		}
 
 		fw = NULL;
@@ -1119,9 +1132,9 @@ request_fw:
 	if (rc != 0) {
 		release_firmware(fw);
 
-		if (fw_name == NX_P3_MN_ROMIMAGE) {
+		if (fw_name == NX_P3_CT_ROMIMAGE) {
 			msleep(1);
-			goto request_ct;
+			goto request_mn;
 		}
 
 		fw = NULL;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 0ce7cf0..dfd66ea 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -676,16 +676,17 @@ netxen_start_firmware(struct netxen_adapter *adapter)
 		return err;
 	}
 
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
-		netxen_set_port_mode(adapter);
-
 	if (first_boot != 0x55555555) {
 		adapter->pci_write_normalize(adapter,
 					CRB_CMDPEG_STATE, 0);
 		netxen_pinit_from_rom(adapter, 0);
 		msleep(1);
 	}
+
 	netxen_nic_reg_write(adapter, CRB_DMA_SHIFT, 0x55555555);
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		netxen_set_port_mode(adapter);
+
 	netxen_load_firmware(adapter);
 
 	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
-- 
1.6.0.2

