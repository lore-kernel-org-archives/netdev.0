From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 2/2] netxen: avoid frequent firmware reset
Date: Wed,  1 Jul 2009 14:41:43 -0700
Message-ID: <1246484503-10817-2-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:55456 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752542AbZGAVlk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jul 2009 17:41:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Restrict firmware reset to following cases -

o chip rev is NX2031 (firmare doesn't support heartbit).
o firmware is dead.
o previous attempt to init firmware had failed.
o we have got newer file firmware.

This speeds up module load tremendously (by upto 8 sec),
also avoids downtime for NCSI (management) pass-thru
traffic.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h      |    4 +-
 drivers/net/netxen/netxen_nic_hdr.h  |    1 +
 drivers/net/netxen/netxen_nic_init.c |   86 ++++++++++++++++++++++++++++++---
 drivers/net/netxen/netxen_nic_main.c |    4 ++
 4 files changed, 86 insertions(+), 9 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 26afcb5..e1cdba7 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -625,6 +625,7 @@ struct netxen_new_user_info {
 #define NX_P2_MN_ROMIMAGE	0
 #define NX_P3_CT_ROMIMAGE	1
 #define NX_P3_MN_ROMIMAGE	2
+#define NX_FLASH_ROMIMAGE	3
 
 #define NETXEN_USER_START_OLD NETXEN_PXE_START	/* for backward compatibility */
 
@@ -1254,7 +1255,7 @@ struct netxen_adapter {
 	u32 resv3;
 
 	u8 has_link_events;
-	u8 resv1;
+	u8 fw_type;
 	u16 tx_context_id;
 	u16 mtu;
 	u16 is_up;
@@ -1398,6 +1399,7 @@ void netxen_free_adapter_offload(struct netxen_adapter *adapter);
 int netxen_initialize_adapter_offload(struct netxen_adapter *adapter);
 int netxen_phantom_init(struct netxen_adapter *adapter, int pegtune_val);
 int netxen_load_firmware(struct netxen_adapter *adapter);
+int netxen_need_fw_reset(struct netxen_adapter *adapter);
 void netxen_request_firmware(struct netxen_adapter *adapter);
 void netxen_release_firmware(struct netxen_adapter *adapter);
 int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose);
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 3cc0478..8241036 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -853,6 +853,7 @@ enum {
 #define NX_PEG_TUNE_CAPABILITY		(NETXEN_CAM_RAM(0x02c))
 
 #define NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL		(0x14)
+#define NETXEN_PEG_ALIVE_COUNTER	(NETXEN_CAM_RAM(0xb0))
 
 #define	ISR_MSI_INT_TRIGGER(FUNC) (NETXEN_PCIX_PS_REG(PCIX_MSI_F(FUNC)))
 #define ISR_LEGACY_INT_TRIGGERED(VAL)	(((VAL) & 0x300) == 0x200)
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 7bdcbc6..b899bd5 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -684,11 +684,84 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 }
 
 int
+netxen_need_fw_reset(struct netxen_adapter *adapter)
+{
+	u32 count, old_count;
+	u32 val, version, major, minor, build;
+	int i, timeout;
+	u8 fw_type;
+
+	/* NX2031 firmware doesn't support heartbit */
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
+		return 1;
+
+	/* last attempt had failed */
+	if (NXRD32(adapter, CRB_CMDPEG_STATE) == PHAN_INITIALIZE_FAILED)
+		return 1;
+
+	old_count = count = NXRD32(adapter, NETXEN_PEG_ALIVE_COUNTER);
+
+	for (i = 0; i < 10; i++) {
+
+		timeout = msleep_interruptible(200);
+		if (timeout) {
+			NXWR32(adapter, CRB_CMDPEG_STATE,
+					PHAN_INITIALIZE_FAILED);
+			return -EINTR;
+		}
+
+		count = NXRD32(adapter, NETXEN_PEG_ALIVE_COUNTER);
+		if (count != old_count)
+			break;
+	}
+
+	/* firmware is dead */
+	if (count == old_count)
+		return 1;
+
+	/* check if we have got newer or different file firmware */
+	if (adapter->fw) {
+
+		const struct firmware *fw = adapter->fw;
+
+		val = cpu_to_le32(*(u32 *)&fw->data[NX_FW_VERSION_OFFSET]);
+		version = NETXEN_DECODE_VERSION(val);
+
+		major = NXRD32(adapter, NETXEN_FW_VERSION_MAJOR);
+		minor = NXRD32(adapter, NETXEN_FW_VERSION_MINOR);
+		build = NXRD32(adapter, NETXEN_FW_VERSION_SUB);
+
+		if (version > NETXEN_VERSION_CODE(major, minor, build))
+			return 1;
+
+		if (version == NETXEN_VERSION_CODE(major, minor, build)) {
+
+			val = NXRD32(adapter, NETXEN_MIU_MN_CONTROL);
+			fw_type = (val & 0x4) ?
+				NX_P3_CT_ROMIMAGE : NX_P3_MN_ROMIMAGE;
+
+			if (adapter->fw_type != fw_type)
+				return 1;
+		}
+	}
+
+	return 0;
+}
+
+static char *fw_name[] = {
+	"nxromimg.bin", "nx3fwct.bin", "nx3fwmn.bin", "flash",
+};
+
+int
 netxen_load_firmware(struct netxen_adapter *adapter)
 {
 	u64 *ptr64;
 	u32 i, flashaddr, size;
 	const struct firmware *fw = adapter->fw;
+	struct pci_dev *pdev = adapter->pdev;
+
+	dev_info(&pdev->dev, "loading firmware from %s\n",
+			fw_name[adapter->fw_type]);
 
 	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
 		NXWR32(adapter, NETXEN_ROMUSB_GLB_CAS_RST, 1);
@@ -806,12 +879,10 @@ netxen_validate_firmware(struct netxen_adapter *adapter, const char *fwname)
 	return 0;
 }
 
-static char *fw_name[] = { "nxromimg.bin", "nx3fwct.bin", "nx3fwmn.bin" };
-
 void netxen_request_firmware(struct netxen_adapter *adapter)
 {
 	u32 capability, flashed_ver;
-	int fw_type;
+	u8 fw_type;
 	struct pci_dev *pdev = adapter->pdev;
 	int rc = 0;
 
@@ -838,6 +909,7 @@ request_mn:
 		}
 	}
 
+	fw_type = NX_FLASH_ROMIMAGE;
 	adapter->fw = NULL;
 	goto done;
 
@@ -849,6 +921,7 @@ request_fw:
 			goto request_mn;
 		}
 
+		fw_type = NX_FLASH_ROMIMAGE;
 		adapter->fw = NULL;
 		goto done;
 	}
@@ -862,16 +935,13 @@ request_fw:
 			goto request_mn;
 		}
 
+		fw_type = NX_FLASH_ROMIMAGE;
 		adapter->fw = NULL;
 		goto done;
 	}
 
 done:
-	if (adapter->fw)
-		dev_info(&pdev->dev, "loading firmware from file %s\n",
-				fw_name[fw_type]);
-	else
-		dev_info(&pdev->dev, "loading firmware from flash\n");
+	adapter->fw_type = fw_type;
 }
 
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 2919a2d..27539dd 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -718,6 +718,10 @@ netxen_start_firmware(struct netxen_adapter *adapter, int request_fw)
 	if (request_fw)
 		netxen_request_firmware(adapter);
 
+	err = netxen_need_fw_reset(adapter);
+	if (err <= 0)
+		return err;
+
 	if (first_boot != 0x55555555) {
 		NXWR32(adapter, CRB_CMDPEG_STATE, 0);
 		netxen_pinit_from_rom(adapter, 0);
-- 
1.6.0.2

