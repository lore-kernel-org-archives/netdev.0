From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 37/45] bna: Adpater and Port Mode Settings
Date: Mon, 18 Jul 2011 01:22:57 -0700
Message-ID: <1310977385-5268-27-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37833 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754714Ab1GRIZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:25:05 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
  - Cache the port mode (active and configured) and capability info in
    bfa_ioc_attr eliminating need to go to fw. This info will be initialize
    to their default value during pci init time, and will be update during
    ioc enable reply time and port mode change reply time.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_defs.h |   25 +++++++++++++++++++++++--
 drivers/net/bna/bfa_ioc.c  |   35 ++++++++++++++++++++++++++++++++++-
 drivers/net/bna/bfa_ioc.h  |    3 +++
 drivers/net/bna/bfi.h      |    6 ++++--
 4 files changed, 64 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bna/bfa_defs.h b/drivers/net/bna/bfa_defs.h
index 3e5d096..ebe5e6c 100644
--- a/drivers/net/bna/bfa_defs.h
+++ b/drivers/net/bna/bfa_defs.h
@@ -180,8 +180,23 @@ struct bfa_ioc_attr {
 	struct bfa_adapter_attr adapter_attr;	/*!< HBA attributes */
 	struct bfa_ioc_driver_attr driver_attr;	/*!< driver attr    */
 	struct bfa_ioc_pci_attr pci_attr;
-	u8				port_id;	/*!< port number    */
-	u8				rsvd[7];	/*!< 64bit align    */
+	u8				port_id;	/*!< port number */
+	u8				port_mode;	/*!< enum bfa_mode */
+	u8				cap_bm;		/*!< capability */
+	u8				port_mode_cfg;	/*!< enum bfa_mode */
+	u8				rsvd[4];	/*!< 64bit align */
+};
+
+/**
+ * Adapter capability mask definition
+ */
+enum {
+	BFA_CM_HBA	=	0x01,
+	BFA_CM_CNA	=	0x02,
+	BFA_CM_NIC	=	0x04,
+	BFA_CM_FC16G	=	0x08,
+	BFA_CM_SRIOV	=	0x10,
+	BFA_CM_MEZZ	=	0x20,
 };
 
 /**
@@ -271,4 +286,10 @@ enum {
 	BFA_PCI_CT2_SSID_FC		= 0x24,
 };
 
+enum bfa_mode {
+	BFA_MODE_HBA		= 1,
+	BFA_MODE_CNA		= 2,
+	BFA_MODE_NIC		= 3
+};
+
 #endif /* __BFA_DEFS_H__ */
diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index d35b91b..6e17abd 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -1706,6 +1706,20 @@ bfa_ioc_reset(struct bfa_ioc *ioc, bool force)
 }
 
 /**
+ * BFA ioc enable reply by firmware
+ */
+static void
+bfa_ioc_enable_reply(struct bfa_ioc *ioc, enum bfa_mode port_mode,
+			u8 cap_bm)
+{
+	struct bfa_iocpf *iocpf = &ioc->iocpf;
+
+	ioc->port_mode = ioc->port_mode_cfg = port_mode;
+	ioc->ad_cap_bm = cap_bm;
+	bfa_fsm_send_event(iocpf, IOCPF_E_FWRSP_ENABLE);
+}
+
+/**
  * @brief
  * Update BFA configuration from firmware configuration.
  */
@@ -1937,7 +1951,9 @@ bfa_ioc_isr(struct bfa_ioc *ioc, struct bfi_mbmsg *m)
 		break;
 
 	case BFI_IOC_I2H_ENABLE_REPLY:
-		bfa_fsm_send_event(iocpf, IOCPF_E_FWRSP_ENABLE);
+		bfa_ioc_enable_reply(ioc,
+			(enum bfa_mode)msg->fw_event.port_mode,
+			(enum bfa_mode)msg->fw_event.cap_bm);
 		break;
 
 	case BFI_IOC_I2H_DISABLE_REPLY:
@@ -2012,6 +2028,8 @@ bfa_nw_ioc_pci_init(struct bfa_ioc *ioc, struct bfa_pcidev *pcidev,
 		ioc->asic_gen = BFI_ASIC_GEN_CT;
 		ioc->port0_mode = ioc->port1_mode = BFI_PORT_MODE_ETH;
 		ioc->asic_mode  = BFI_ASIC_MODE_ETH;
+		ioc->port_mode = ioc->port_mode_cfg = BFA_MODE_CNA;
+		ioc->ad_cap_bm = BFA_CM_CNA;
 		break;
 
 	case BFA_PCI_DEVICE_ID_CT2:
@@ -2020,9 +2038,20 @@ bfa_nw_ioc_pci_init(struct bfa_ioc *ioc, struct bfa_pcidev *pcidev,
 			pcidev->ssid == BFA_PCI_CT2_SSID_FC) {
 			ioc->asic_mode  = BFI_ASIC_MODE_FC16;
 			ioc->fcmode = true;
+			ioc->port_mode = ioc->port_mode_cfg = BFA_MODE_HBA;
+			ioc->ad_cap_bm = BFA_CM_HBA;
 		} else {
 			ioc->port0_mode = ioc->port1_mode = BFI_PORT_MODE_ETH;
 			ioc->asic_mode  = BFI_ASIC_MODE_ETH;
+			if (pcidev->ssid == BFA_PCI_CT2_SSID_FCoE) {
+				ioc->port_mode =
+				ioc->port_mode_cfg = BFA_MODE_CNA;
+				ioc->ad_cap_bm = BFA_CM_CNA;
+			} else {
+				ioc->port_mode =
+				ioc->port_mode_cfg = BFA_MODE_NIC;
+				ioc->ad_cap_bm = BFA_CM_NIC;
+			}
 		}
 		break;
 
@@ -2382,6 +2411,10 @@ bfa_nw_ioc_get_attr(struct bfa_ioc *ioc, struct bfa_ioc_attr *ioc_attr)
 
 	ioc_attr->state = bfa_ioc_get_state(ioc);
 	ioc_attr->port_id = ioc->port_id;
+	ioc_attr->port_mode = ioc->port_mode;
+
+	ioc_attr->port_mode_cfg = ioc->port_mode_cfg;
+	ioc_attr->cap_bm = ioc->ad_cap_bm;
 
 	ioc_attr->ioc_type = bfa_nw_ioc_get_type(ioc);
 
diff --git a/drivers/net/bna/bfa_ioc.h b/drivers/net/bna/bfa_ioc.h
index 0f7dba1..9ae201a 100644
--- a/drivers/net/bna/bfa_ioc.h
+++ b/drivers/net/bna/bfa_ioc.h
@@ -208,6 +208,9 @@ struct bfa_ioc {
 	enum bfi_asic_mode	asic_mode;
 	enum bfi_port_mode	port0_mode;
 	enum bfi_port_mode	port1_mode;
+	enum bfa_mode		port_mode;
+	u8			ad_cap_bm;	/*!< adapter cap bit mask */
+	u8			port_mode_cfg;	/*!< config port mode */
 };
 
 struct bfa_ioc_hwif {
diff --git a/drivers/net/bna/bfi.h b/drivers/net/bna/bfi.h
index d422857..c534318 100644
--- a/drivers/net/bna/bfi.h
+++ b/drivers/net/bna/bfi.h
@@ -398,9 +398,11 @@ struct bfi_ioc_ctrl_req {
  * BFI_IOC_I2H_ENABLE_REPLY & BFI_IOC_I2H_DISABLE_REPLY messages
  */
 struct bfi_ioc_ctrl_reply {
-	struct bfi_mhdr mh;		/*!< Common msg header     */
+	struct bfi_mhdr mh;			/*!< Common msg header     */
 	u8			status;		/*!< enable/disable status */
-	u8			rsvd[3];
+	u8			port_mode;	/*!< bfa_mode */
+	u8			cap_bm;		/*!< capability bit mask */
+	u8			rsvd;
 };
 
 #define BFI_IOC_MSGSZ   8
-- 
1.7.1

