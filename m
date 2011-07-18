From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 22/45] bna: Capability Map and MFG Block Changes for New HW
Date: Mon, 18 Jul 2011 01:22:42 -0700
Message-ID: <1310977385-5268-12-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37795 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753522Ab1GRIYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:24:04 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Added capability map and generic model name scheme for manufacturing block.
 - Updated the mfginfo command to handle old h/w alongside new one.
 - Changed firmware code to reduce card types for 1860 cards and derived card
   model from card type, capability fields and initial capability.
 - Removed explicit set/get fcmode. Now this is based on PCI device properties.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_defs.h          |   20 +++++++---
 drivers/net/bna/bfa_defs_mfg_comm.h |   72 ++++++++++++++++++++++++++---------
 drivers/net/bna/bfa_ioc.c           |    5 +-
 3 files changed, 71 insertions(+), 26 deletions(-)

diff --git a/drivers/net/bna/bfa_defs.h b/drivers/net/bna/bfa_defs.h
index f5909d0..e89830f 100644
--- a/drivers/net/bna/bfa_defs.h
+++ b/drivers/net/bna/bfa_defs.h
@@ -220,15 +220,23 @@ struct bfa_mfg_block {
 	u8		rsv[2];
 	char		supplier_id[STRSZ(BFA_MFG_SUPPLIER_ID_SIZE)];
 	char		supplier_partnum[STRSZ(BFA_MFG_SUPPLIER_PARTNUM_SIZE)];
-	char
-		supplier_serialnum[STRSZ(BFA_MFG_SUPPLIER_SERIALNUM_SIZE)];
-	char
-		supplier_revision[STRSZ(BFA_MFG_SUPPLIER_REVISION_SIZE)];
+	char	supplier_serialnum[STRSZ(BFA_MFG_SUPPLIER_SERIALNUM_SIZE)];
+	char	supplier_revision[STRSZ(BFA_MFG_SUPPLIER_REVISION_SIZE)];
 	mac_t		mfg_mac;	/*!< mac address */
 	u8		num_mac;	/*!< number of mac addresses */
 	u8		rsv2;
-	u32	mfg_type;	/*!< card type */
-	u8		rsv3[108];
+	u32		card_type;	/*!< card type */
+	char		cap_nic;	/*!< capability nic */
+	char		cap_cna;	/*!< capability cna */
+	char		cap_hba;	/*!< capability hba */
+	char		cap_fc16g;	/*!< capability fc 16g */
+	char		cap_sriov;	/*!< capability sriov */
+	char		cap_mezz;	/*!< capability mezz */
+	u8		rsv3;
+	u8		mfg_nports;	/*!< number of ports */
+	char		media[8];	/*!< xfi/xaui */
+	char		initial_mode[8];/*!< initial mode: hba/cna/nic */
+	u8		rsv4[84];
 	u8		md5_chksum[BFA_MFG_CHKSUM_SIZE]; /*!< md5 checksum */
 };
 
diff --git a/drivers/net/bna/bfa_defs_mfg_comm.h b/drivers/net/bna/bfa_defs_mfg_comm.h
index 885ef3a..2f00813 100644
--- a/drivers/net/bna/bfa_defs_mfg_comm.h
+++ b/drivers/net/bna/bfa_defs_mfg_comm.h
@@ -19,11 +19,12 @@
 #define __BFA_DEFS_MFG_COMM_H__
 
 #include "cna.h"
+#include "bfa_defs.h"
 
 /**
  * Manufacturing block version
  */
-#define BFA_MFG_VERSION				2
+#define BFA_MFG_VERSION				3
 #define BFA_MFG_VERSION_UNINIT			0xFF
 
 /**
@@ -60,20 +61,17 @@ enum {
 	BFA_MFG_TYPE_ASTRA    = 807,	 /*!< Astra mezz card		*/
 	BFA_MFG_TYPE_LIGHTNING_P0 = 902, /*!< Lightning mezz card - old	*/
 	BFA_MFG_TYPE_LIGHTNING = 1741,	 /*!< Lightning mezz card	*/
+	BFA_MFG_TYPE_PROWLER_F = 1560,	 /*!< Prowler FC only cards	*/
+	BFA_MFG_TYPE_PROWLER_N = 1410,	 /*!< Prowler NIC only cards	*/
+	BFA_MFG_TYPE_PROWLER_C = 1710,	 /*!< Prowler CNA only cards	*/
+	BFA_MFG_TYPE_PROWLER_D = 1860,	 /*!< Prowler Dual cards	*/
+	BFA_MFG_TYPE_CHINOOK   = 1867,	 /*!< Chinook cards		*/
 	BFA_MFG_TYPE_INVALID = 0,	 /*!< Invalid card type		*/
 };
 
 #pragma pack(1)
 
 /**
- * Check if 1-port card
- */
-#define bfa_mfg_is_1port(type) (( \
-	(type) == BFA_MFG_TYPE_FC8P1 || \
-	(type) == BFA_MFG_TYPE_FC4P1 || \
-	(type) == BFA_MFG_TYPE_CNA10P1))
-
-/**
  * Check if Mezz card
  */
 #define bfa_mfg_is_mezz(type) (( \
@@ -81,7 +79,8 @@ enum {
 	(type) == BFA_MFG_TYPE_WANCHESE || \
 	(type) == BFA_MFG_TYPE_ASTRA || \
 	(type) == BFA_MFG_TYPE_LIGHTNING_P0 || \
-	(type) == BFA_MFG_TYPE_LIGHTNING))
+	(type) == BFA_MFG_TYPE_LIGHTNING || \
+	(type) == BFA_MFG_TYPE_CHINOOK))
 
 /**
  * Check if card type valid
@@ -93,14 +92,16 @@ enum {
 	(type) == BFA_MFG_TYPE_FC4P1 || \
 	(type) == BFA_MFG_TYPE_CNA10P2 || \
 	(type) == BFA_MFG_TYPE_CNA10P1 || \
+	(type) == BFA_MFG_TYPE_PROWLER_F || \
+	(type) == BFA_MFG_TYPE_PROWLER_N || \
+	(type) == BFA_MFG_TYPE_PROWLER_C || \
+	(type) == BFA_MFG_TYPE_PROWLER_D || \
 	bfa_mfg_is_mezz(type)))
 
-#define bfa_mfg_adapter_prop_init_flash(card_type, prop)	\
+#define bfa_mfg_adapter_prop_init_flash_cb(mfgblk, prop)	\
 do {								\
-	switch ((card_type)) {					\
+	switch ((mfgblk)->card_type) {				\
 	case BFA_MFG_TYPE_FC8P2:				\
-	case BFA_MFG_TYPE_JAYHAWK:				\
-	case BFA_MFG_TYPE_ASTRA:				\
 		(prop) = BFI_ADAPTER_SETP(NPORTS, 2) |		\
 			BFI_ADAPTER_SETP(SPEED, 8);		\
 		break;						\
@@ -116,22 +117,57 @@ do {								\
 		(prop) = BFI_ADAPTER_SETP(NPORTS, 1) |		\
 			BFI_ADAPTER_SETP(SPEED, 4);		\
 		break;						\
+	default:						\
+		(prop) = BFI_ADAPTER_UNSUPP;			\
+	}							\
+} while (0)
+
+#define bfa_mfg_adapter_prop_init_flash_ct(mfgblk, prop)	\
+do {								\
+	switch ((mfgblk)->card_type) {				\
+	case BFA_MFG_TYPE_JAYHAWK:				\
+	case BFA_MFG_TYPE_ASTRA:				\
+		(prop) = BFI_ADAPTER_SETP(NPORTS, 2) |		\
+			BFI_ADAPTER_SETP(SPEED, 8);		\
+		break;						\
 	case BFA_MFG_TYPE_CNA10P2:				\
 	case BFA_MFG_TYPE_WANCHESE:				\
 	case BFA_MFG_TYPE_LIGHTNING_P0:				\
 	case BFA_MFG_TYPE_LIGHTNING:				\
-		(prop) = BFI_ADAPTER_SETP(NPORTS, 2);		\
-		(prop) |= BFI_ADAPTER_SETP(SPEED, 10);		\
+		(prop) = BFI_ADAPTER_SETP(NPORTS, 2) |		\
+			BFI_ADAPTER_SETP(SPEED, 10);		\
 		break;						\
 	case BFA_MFG_TYPE_CNA10P1:				\
-		(prop) = BFI_ADAPTER_SETP(NPORTS, 1);		\
-		(prop) |= BFI_ADAPTER_SETP(SPEED, 10);		\
+		(prop) = BFI_ADAPTER_SETP(NPORTS, 1) |		\
+			BFI_ADAPTER_SETP(SPEED, 10);		\
 		break;						\
 	default:						\
 		(prop) = BFI_ADAPTER_UNSUPP;			\
 	}							\
 } while (0)
 
+#define bfa_mfg_adapter_prop_init_flash_ct2(mfgblk, prop)	\
+do {								\
+	int sp, np = (mfgblk)->mfg_nports;			\
+	switch ((mfgblk)->card_type) {				\
+	case BFA_MFG_TYPE_PROWLER_F:				\
+	case BFA_MFG_TYPE_CHINOOK:				\
+		sp = 16;					\
+		break;						\
+	case BFA_MFG_TYPE_PROWLER_N:				\
+	case BFA_MFG_TYPE_PROWLER_C:				\
+		sp = 10;					\
+		break;						\
+	case BFA_MFG_TYPE_PROWLER_D:				\
+		sp = 16;					\
+		break;						\
+	default:						\
+		sp = 16;				\
+	}							\
+	(prop) = BFI_ADAPTER_SETP(NPORTS, np) |			\
+		BFI_ADAPTER_SETP(SPEED, sp);			\
+} while (0)
+
 enum {
 	CB_GPIO_TTV	= (1),		/*!< TTV debug capable cards	*/
 	CB_GPIO_FC8P2   = (2),		/*!< 8G 2port FC card		*/
diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index 3e38cbb..33776da 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -1834,9 +1834,10 @@ bfa_nw_ioc_pci_init(struct bfa_ioc *ioc, struct bfa_pcidev *pcidev,
 
 	case BFA_PCI_DEVICE_ID_CT2:
 		ioc->asic_gen = BFI_ASIC_GEN_CT2;
-		if (clscode == BFI_PCIFN_CLASS_FC)
+		if (clscode == BFI_PCIFN_CLASS_FC) {
 			ioc->asic_mode  = BFI_ASIC_MODE_FC16;
-		else {
+			ioc->fcmode = true;
+		} else {
 			ioc->port0_mode = ioc->port1_mode = BFI_PORT_MODE_ETH;
 			ioc->asic_mode  = BFI_ASIC_MODE_ETH;
 		}
-- 
1.7.1

