From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 4/7] bna: Brocade 1860 HW Enablement
Date: Mon, 26 Sep 2011 14:12:18 -0700
Message-ID: <1317071541-9662-5-git-send-email-rmody@brocade.com>
References: <1317071541-9662-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Gurunatha Karaje <gkaraje@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:59744 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752722Ab1IZVMk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 17:12:40 -0400
In-Reply-To: <1317071541-9662-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables new HW Brocade 1860. Add BFA_CM_NIC capability mask to
bfa_ioc_attr, Sub-System Device ID Info and support for Brocade 1860 device
ID to bfa_ioc.c bnad.c and pci_ids.h.

Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bfa_defs.h    |   16 +++++++++++++++-
 drivers/net/ethernet/brocade/bna/bfa_ioc.c     |   23 +++++++++++++++++++++++
 drivers/net/ethernet/brocade/bna/bfa_ioc.h     |    1 +
 drivers/net/ethernet/brocade/bna/bna_hw_defs.h |    4 ++++
 drivers/net/ethernet/brocade/bna/bnad.c        |    9 ++++++++-
 include/linux/pci_ids.h                        |    1 +
 6 files changed, 52 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs.h b/drivers/net/ethernet/brocade/bna/bfa_defs.h
index 66a6207..48fa410 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_defs.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_defs.h
@@ -193,6 +193,7 @@ struct bfa_ioc_attr {
 enum {
 	BFA_CM_HBA	=	0x01,
 	BFA_CM_CNA	=	0x02,
+	BFA_CM_NIC	=	0x04,
 };
 
 /**
@@ -264,7 +265,20 @@ struct bfa_mfg_block {
 #define bfa_asic_id_ct(device)			\
 	((device) == PCI_DEVICE_ID_BROCADE_CT ||	\
 	 (device) == PCI_DEVICE_ID_BROCADE_CT_FC)
-#define bfa_asic_id_ctc(device) (bfa_asic_id_ct(device))
+#define bfa_asic_id_ct2(device)			\
+	((device) == PCI_DEVICE_ID_BROCADE_CT2)
+#define bfa_asic_id_ctc(device)			\
+	(bfa_asic_id_ct(device) || bfa_asic_id_ct2(device))
+
+/**
+ * PCI sub-system device and vendor ID information
+ */
+enum {
+	BFA_PCI_FCOE_SSDEVICE_ID	= 0x14,
+	BFA_PCI_CT2_SSID_FCoE		= 0x22,
+	BFA_PCI_CT2_SSID_ETH		= 0x23,
+	BFA_PCI_CT2_SSID_FC		= 0x24,
+};
 
 enum bfa_mode {
 	BFA_MODE_HBA		= 1,
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
index 1e60aa7..2a91cc8 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.c
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
@@ -1977,6 +1977,29 @@ bfa_nw_ioc_pci_init(struct bfa_ioc *ioc, struct bfa_pcidev *pcidev,
 		ioc->ad_cap_bm = BFA_CM_CNA;
 		break;
 
+	case PCI_DEVICE_ID_BROCADE_CT2:
+		ioc->asic_gen = BFI_ASIC_GEN_CT2;
+		if (clscode == BFI_PCIFN_CLASS_FC &&
+			pcidev->ssid == BFA_PCI_CT2_SSID_FC) {
+			ioc->asic_mode  = BFI_ASIC_MODE_FC16;
+			ioc->fcmode = true;
+			ioc->port_mode = ioc->port_mode_cfg = BFA_MODE_HBA;
+			ioc->ad_cap_bm = BFA_CM_HBA;
+		} else {
+			ioc->port0_mode = ioc->port1_mode = BFI_PORT_MODE_ETH;
+			ioc->asic_mode  = BFI_ASIC_MODE_ETH;
+			if (pcidev->ssid == BFA_PCI_CT2_SSID_FCoE) {
+				ioc->port_mode =
+				ioc->port_mode_cfg = BFA_MODE_CNA;
+				ioc->ad_cap_bm = BFA_CM_CNA;
+			} else {
+				ioc->port_mode =
+				ioc->port_mode_cfg = BFA_MODE_NIC;
+				ioc->ad_cap_bm = BFA_CM_NIC;
+			}
+		}
+		break;
+
 	default:
 		BUG_ON(1);
 	}
diff --git a/drivers/net/ethernet/brocade/bna/bfa_ioc.h b/drivers/net/ethernet/brocade/bna/bfa_ioc.h
index 5899a56..c398170 100644
--- a/drivers/net/ethernet/brocade/bna/bfa_ioc.h
+++ b/drivers/net/ethernet/brocade/bna/bfa_ioc.h
@@ -35,6 +35,7 @@ struct bfa_pcidev {
 	int	pci_slot;
 	u8	pci_func;
 	u16	device_id;
+	u16	ssid;
 	void	__iomem *pci_bar_kva;
 };
 
diff --git a/drivers/net/ethernet/brocade/bna/bna_hw_defs.h b/drivers/net/ethernet/brocade/bna/bna_hw_defs.h
index dde8a46..3da6dd9 100644
--- a/drivers/net/ethernet/brocade/bna/bna_hw_defs.h
+++ b/drivers/net/ethernet/brocade/bna/bna_hw_defs.h
@@ -133,6 +133,10 @@
 		ct_reg_addr_init((_bna), (_pcidev));			\
 		ct_bit_defn_init((_bna), (_pcidev));			\
 		break;							\
+	case PCI_DEVICE_ID_BROCADE_CT2:					\
+		ct2_reg_addr_init((_bna), (_pcidev));			\
+		ct2_bit_defn_init((_bna), (_pcidev));			\
+		break;							\
 	}								\
 }
 
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 320f11c..033c26e 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -3428,7 +3428,14 @@ static DEFINE_PCI_DEVICE_TABLE(bnad_pci_id_table) = {
 			PCI_DEVICE_ID_BROCADE_CT),
 		.class = PCI_CLASS_NETWORK_ETHERNET << 8,
 		.class_mask =  0xffff00
-	}, {0,  }
+	},
+	{
+		PCI_DEVICE(PCI_VENDOR_ID_BROCADE,
+			PCI_DEVICE_ID_BROCADE_CT2),
+		.class = PCI_CLASS_NETWORK_ETHERNET << 8,
+		.class_mask =  0xffff00
+	},
+	{0,  },
 };
 
 MODULE_DEVICE_TABLE(pci, bnad_pci_id_table);
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index ae96bbe..b12b7ae 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2224,6 +2224,7 @@
 #define PCI_DEVICE_ID_BROCADE_CT	0x0014
 #define PCI_DEVICE_ID_BROCADE_FC_8G1P	0x0017
 #define PCI_DEVICE_ID_BROCADE_CT_FC	0x0021
+#define PCI_DEVICE_ID_BROCADE_CT2	0x0022
 
 #define PCI_VENDOR_ID_SIBYTE		0x166d
 #define PCI_DEVICE_ID_BCM1250_PCI	0x0001
-- 
1.7.1
