From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCHv2 03/11] netxen: add defs for new chip/boards
Date: Fri, 18 Jul 2008 16:44:01 -0700
Message-ID: <1216424649-4597-4-git-send-email-dhananjay@netxen.com>
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.209.101.202] ([64.209.101.202]:55546 "EHLO unm84.unminc.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756067AbYGRXoL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jul 2008 19:44:11 -0400
In-Reply-To: <>
References: <>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add macros for new chip revision and board configurations.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h          |   65 +++++++--
 drivers/net/netxen/netxen_nic_ethtool.c  |   12 ++
 drivers/net/netxen/netxen_nic_hdr.h      |  242 ++++++++++++++++++++++++++++--
 drivers/net/netxen/netxen_nic_hw.c       |   65 ++++-----
 drivers/net/netxen/netxen_nic_init.c     |    3 +-
 drivers/net/netxen/netxen_nic_main.c     |    6 +-
 drivers/net/netxen/netxen_nic_phan_reg.h |    8 +-
 7 files changed, 331 insertions(+), 70 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index fa1fbab..acc7d79 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -111,6 +111,13 @@
 
 #define NX_P2_C0		0x24
 #define NX_P2_C1		0x25
+#define NX_P3_A0		0x30
+#define NX_P3_A2		0x30
+#define NX_P3_B0		0x40
+#define NX_P3_B1		0x41
+
+#define NX_IS_REVISION_P2(REVISION)     (REVISION <= NX_P2_C1)
+#define NX_IS_REVISION_P3(REVISION)     (REVISION >= NX_P3_A0)
 
 #define FIRST_PAGE_GROUP_START	0
 #define FIRST_PAGE_GROUP_END	0x100000
@@ -125,6 +132,15 @@
 #define SECOND_PAGE_GROUP_SIZE SECOND_PAGE_GROUP_END - SECOND_PAGE_GROUP_START
 #define THIRD_PAGE_GROUP_SIZE  THIRD_PAGE_GROUP_END - THIRD_PAGE_GROUP_START
 
+#define P2_MAX_MTU                     (8000)
+#define P3_MAX_MTU                     (9600)
+#define NX_ETHERMTU                    1500
+#define NX_MAX_ETHERHDR                32 /* This contains some padding */
+
+#define NX_RX_NORMAL_BUF_MAX_LEN       (NX_MAX_ETHERHDR + NX_ETHERMTU)
+#define NX_P2_RX_JUMBO_BUF_MAX_LEN     (NX_MAX_ETHERHDR + P2_MAX_MTU)
+#define NX_P3_RX_JUMBO_BUF_MAX_LEN     (NX_MAX_ETHERHDR + P3_MAX_MTU)
+
 #define MAX_RX_BUFFER_LENGTH		1760
 #define MAX_RX_JUMBO_BUFFER_LENGTH 	8062
 #define MAX_RX_LRO_BUFFER_LENGTH	((48*1024)-512)
@@ -139,16 +155,16 @@
 #define MAX_RING_CTX 1
 
 /* Opcodes to be used with the commands */
-enum {
-	TX_ETHER_PKT = 0x01,
-/* The following opcodes are for IP checksum	*/
-	TX_TCP_PKT,
-	TX_UDP_PKT,
-	TX_IP_PKT,
-	TX_TCP_LSO,
-	TX_IPSEC,
-	TX_IPSEC_CMD
-};
+#define TX_ETHER_PKT	0x01
+#define TX_TCP_PKT	0x02
+#define TX_UDP_PKT	0x03
+#define TX_IP_PKT	0x04
+#define TX_TCP_LSO	0x05
+#define TX_TCP_LSO6	0x06
+#define TX_IPSEC	0x07
+#define TX_IPSEC_CMD	0x0a
+#define TX_TCPV6_PKT	0x0b
+#define TX_UDPV6_PKT	0x0c
 
 /* The following opcodes are for internal consumption. */
 #define NETXEN_CONTROL_OP	0x10
@@ -190,6 +206,7 @@ enum {
 #define MAX_RCV_DESCRIPTORS		16384
 #define MAX_CMD_DESCRIPTORS_HOST	(MAX_CMD_DESCRIPTORS / 4)
 #define MAX_RCV_DESCRIPTORS_1G		(MAX_RCV_DESCRIPTORS / 4)
+#define MAX_RCV_DESCRIPTORS_10G		8192
 #define MAX_JUMBO_RCV_DESCRIPTORS	1024
 #define MAX_LRO_RCV_DESCRIPTORS		64
 #define MAX_RCVSTATUS_DESCRIPTORS	MAX_RCV_DESCRIPTORS
@@ -461,7 +478,20 @@ typedef enum {
 
 	NETXEN_BRDTYPE_P2_SB31_10G_IMEZ = 0x000d,
 	NETXEN_BRDTYPE_P2_SB31_10G_HMEZ = 0x000e,
-	NETXEN_BRDTYPE_P2_SB31_10G_CX4 = 0x000f
+	NETXEN_BRDTYPE_P2_SB31_10G_CX4 = 0x000f,
+
+	NETXEN_BRDTYPE_P3_REF_QG = 0x0021,
+	NETXEN_BRDTYPE_P3_HMEZ = 0x0022,
+	NETXEN_BRDTYPE_P3_10G_CX4_LP = 0x0023,
+	NETXEN_BRDTYPE_P3_4_GB = 0x0024,
+	NETXEN_BRDTYPE_P3_IMEZ = 0x0025,
+	NETXEN_BRDTYPE_P3_10G_SFP_PLUS = 0x0026,
+	NETXEN_BRDTYPE_P3_10000_BASE_T = 0x0027,
+	NETXEN_BRDTYPE_P3_XG_LOM = 0x0028,
+	NETXEN_BRDTYPE_P3_4_GB_MM = 0x0029,
+	NETXEN_BRDTYPE_P3_10G_CX4 = 0x0031,
+	NETXEN_BRDTYPE_P3_10G_XFP = 0x0032
+
 } netxen_brdtype_t;
 
 typedef enum {
@@ -1049,7 +1079,7 @@ struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev);
  * NetXen Board information
  */
 
-#define NETXEN_MAX_SHORT_NAME 16
+#define NETXEN_MAX_SHORT_NAME 32
 struct netxen_brdinfo {
 	netxen_brdtype_t brdtype;	/* type of board */
 	long ports;		/* max no of physical ports */
@@ -1063,6 +1093,17 @@ static const struct netxen_brdinfo netxen_boards[] = {
 	{NETXEN_BRDTYPE_P2_SB31_10G, 1, "XGb XFP"},
 	{NETXEN_BRDTYPE_P2_SB35_4G, 4, "Quad Gb"},
 	{NETXEN_BRDTYPE_P2_SB31_2G, 2, "Dual Gb"},
+	{NETXEN_BRDTYPE_P3_REF_QG,  4, "Reference Quad Gig "},
+	{NETXEN_BRDTYPE_P3_HMEZ,    2, "Dual XGb HMEZ"},
+	{NETXEN_BRDTYPE_P3_10G_CX4_LP,   2, "Dual XGb CX4 LP"},
+	{NETXEN_BRDTYPE_P3_4_GB,    4, "Quad Gig LP"},
+	{NETXEN_BRDTYPE_P3_IMEZ,    2, "Dual XGb IMEZ"},
+	{NETXEN_BRDTYPE_P3_10G_SFP_PLUS, 2, "Dual XGb SFP+ LP"},
+	{NETXEN_BRDTYPE_P3_10000_BASE_T, 1, "XGB 10G BaseT LP"},
+	{NETXEN_BRDTYPE_P3_XG_LOM,  2, "Dual XGb LOM"},
+	{NETXEN_BRDTYPE_P3_4_GB_MM, 4, "Quad GB - March Madness"},
+	{NETXEN_BRDTYPE_P3_10G_CX4, 2, "Reference Dual CX4 Option"},
+	{NETXEN_BRDTYPE_P3_10G_XFP, 1, "Reference Single XFP Option"}
 };
 
 #define NUM_SUPPORTED_BOARDS ARRAY_SIZE(netxen_boards)
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index 99071c2..cacc528 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -159,9 +159,16 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	switch ((netxen_brdtype_t) boardinfo->board_type) {
 	case NETXEN_BRDTYPE_P2_SB35_4G:
 	case NETXEN_BRDTYPE_P2_SB31_2G:
+	case NETXEN_BRDTYPE_P3_REF_QG:
+	case NETXEN_BRDTYPE_P3_4_GB:
+	case NETXEN_BRDTYPE_P3_4_GB_MM:
+	case NETXEN_BRDTYPE_P3_10000_BASE_T:
+
 		ecmd->supported |= SUPPORTED_Autoneg;
 		ecmd->advertising |= ADVERTISED_Autoneg;
 	case NETXEN_BRDTYPE_P2_SB31_10G_CX4:
+	case NETXEN_BRDTYPE_P3_10G_CX4:
+	case NETXEN_BRDTYPE_P3_10G_CX4_LP:
 		ecmd->supported |= SUPPORTED_TP;
 		ecmd->advertising |= ADVERTISED_TP;
 		ecmd->port = PORT_TP;
@@ -171,12 +178,17 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		break;
 	case NETXEN_BRDTYPE_P2_SB31_10G_HMEZ:
 	case NETXEN_BRDTYPE_P2_SB31_10G_IMEZ:
+	case NETXEN_BRDTYPE_P3_IMEZ:
+	case NETXEN_BRDTYPE_P3_XG_LOM:
+	case NETXEN_BRDTYPE_P3_HMEZ:
 		ecmd->supported |= SUPPORTED_MII;
 		ecmd->advertising |= ADVERTISED_MII;
 		ecmd->port = PORT_FIBRE;
 		ecmd->autoneg = AUTONEG_DISABLE;
 		break;
 	case NETXEN_BRDTYPE_P2_SB31_10G:
+	case NETXEN_BRDTYPE_P3_10G_SFP_PLUS:
+	case NETXEN_BRDTYPE_P3_10G_XFP:
 		ecmd->supported |= SUPPORTED_FIBRE;
 		ecmd->advertising |= ADVERTISED_FIBRE;
 		ecmd->port = PORT_FIBRE;
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 545180b..2374d8d 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -126,7 +126,8 @@ enum {
 	NETXEN_HW_PEGR0_CRB_AGT_ADR,
 	NETXEN_HW_PEGR1_CRB_AGT_ADR,
 	NETXEN_HW_PEGR2_CRB_AGT_ADR,
-	NETXEN_HW_PEGR3_CRB_AGT_ADR
+	NETXEN_HW_PEGR3_CRB_AGT_ADR,
+	NETXEN_HW_PEGN4_CRB_AGT_ADR
 };
 
 /*  Hub 5 */
@@ -316,6 +317,8 @@ enum {
 	((NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGN2_CRB_AGT_ADR)
 #define NETXEN_HW_CRB_HUB_AGT_ADR_PGN3	\
 	((NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGN3_CRB_AGT_ADR)
+#define NETXEN_HW_CRB_HUB_AGT_ADR_PGN4	\
+	((NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGN4_CRB_AGT_ADR)
 #define NETXEN_HW_CRB_HUB_AGT_ADR_PGNC	\
 	((NETXEN_HW_H4_CH_HUB_ADR << 7) | NETXEN_HW_PEGNC_CRB_AGT_ADR)
 #define NETXEN_HW_CRB_HUB_AGT_ADR_PGR0	\
@@ -435,6 +438,7 @@ enum {
 #define NETXEN_CRB_ROMUSB	\
 	NETXEN_PCI_CRB_WINDOW(NETXEN_HW_PX_MAP_CRB_ROMUSB)
 #define NETXEN_CRB_I2Q		NETXEN_PCI_CRB_WINDOW(NETXEN_HW_PX_MAP_CRB_I2Q)
+#define NETXEN_CRB_SMB		NETXEN_PCI_CRB_WINDOW(NETXEN_HW_PX_MAP_CRB_SMB)
 #define NETXEN_CRB_MAX		NETXEN_PCI_CRB_WINDOW(64)
 
 #define NETXEN_CRB_PCIX_HOST	NETXEN_PCI_CRB_WINDOW(NETXEN_HW_PX_MAP_CRB_PH)
@@ -446,6 +450,7 @@ enum {
 #define NETXEN_CRB_PEG_NET_D	NETXEN_PCI_CRB_WINDOW(NETXEN_HW_PX_MAP_CRB_PGND)
 #define NETXEN_CRB_PEG_NET_I	NETXEN_PCI_CRB_WINDOW(NETXEN_HW_PX_MAP_CRB_PGNI)
 #define NETXEN_CRB_DDR_NET	NETXEN_PCI_CRB_WINDOW(NETXEN_HW_PX_MAP_CRB_MN)
+#define NETXEN_CRB_QDR_NET	NETXEN_PCI_CRB_WINDOW(NETXEN_HW_PX_MAP_CRB_SN)
 
 #define NETXEN_CRB_PCIX_MD	NETXEN_PCI_CRB_WINDOW(NETXEN_HW_PX_MAP_CRB_PS)
 #define NETXEN_CRB_PCIE		NETXEN_CRB_PCIX_MD
@@ -461,11 +466,20 @@ enum {
 #define ISR_INT_TARGET_MASK_F2     (NETXEN_PCIX_PS_REG(PCIX_TARGET_MASK_F2))
 #define ISR_INT_TARGET_STATUS_F3   (NETXEN_PCIX_PS_REG(PCIX_TARGET_STATUS_F3))
 #define ISR_INT_TARGET_MASK_F3     (NETXEN_PCIX_PS_REG(PCIX_TARGET_MASK_F3))
+#define ISR_INT_TARGET_STATUS_F4   (NETXEN_PCIX_PS_REG(PCIX_TARGET_STATUS_F4))
+#define ISR_INT_TARGET_MASK_F4     (NETXEN_PCIX_PS_REG(PCIX_TARGET_MASK_F4))
+#define ISR_INT_TARGET_STATUS_F5   (NETXEN_PCIX_PS_REG(PCIX_TARGET_STATUS_F5))
+#define ISR_INT_TARGET_MASK_F5     (NETXEN_PCIX_PS_REG(PCIX_TARGET_MASK_F5))
+#define ISR_INT_TARGET_STATUS_F6   (NETXEN_PCIX_PS_REG(PCIX_TARGET_STATUS_F6))
+#define ISR_INT_TARGET_MASK_F6     (NETXEN_PCIX_PS_REG(PCIX_TARGET_MASK_F6))
+#define ISR_INT_TARGET_STATUS_F7   (NETXEN_PCIX_PS_REG(PCIX_TARGET_STATUS_F7))
+#define ISR_INT_TARGET_MASK_F7     (NETXEN_PCIX_PS_REG(PCIX_TARGET_MASK_F7))
 
 #define NETXEN_PCI_MAPSIZE	128
 #define NETXEN_PCI_DDR_NET	(0x00000000UL)
 #define NETXEN_PCI_QDR_NET	(0x04000000UL)
 #define NETXEN_PCI_DIRECT_CRB	(0x04400000UL)
+#define NETXEN_PCI_CAMQM	(0x04800000UL)
 #define NETXEN_PCI_CAMQM_MAX	(0x04ffffffUL)
 #define NETXEN_PCI_OCM0		(0x05000000UL)
 #define NETXEN_PCI_OCM0_MAX	(0x050fffffUL)
@@ -474,6 +488,13 @@ enum {
 #define NETXEN_PCI_CRBSPACE	(0x06000000UL)
 #define NETXEN_PCI_128MB_SIZE	(0x08000000UL)
 #define NETXEN_PCI_32MB_SIZE	(0x02000000UL)
+#define NETXEN_PCI_2MB_SIZE	(0x00200000UL)
+
+#define NETXEN_PCI_MN_2M	(0)
+#define NETXEN_PCI_MS_2M	(0x80000)
+#define NETXEN_PCI_OCM0_2M	(0x000c0000UL)
+#define NETXEN_PCI_CAMQM_2M_BASE	(0x000ff800UL)
+#define NETXEN_PCI_CAMQM_2M_END		(0x04800800UL)
 
 #define NETXEN_CRB_CAM	NETXEN_PCI_CRB_WINDOW(NETXEN_HW_PX_MAP_CRB_CAM)
 
@@ -484,7 +505,14 @@ enum {
 #define NETXEN_ADDR_OCM1	(0x0000000200400000ULL)
 #define NETXEN_ADDR_OCM1_MAX	(0x00000002004fffffULL)
 #define NETXEN_ADDR_QDR_NET	(0x0000000300000000ULL)
-#define NETXEN_ADDR_QDR_NET_MAX (0x00000003003fffffULL)
+#define NETXEN_ADDR_QDR_NET_MAX_P2 (0x00000003003fffffULL)
+#define NETXEN_ADDR_QDR_NET_MAX_P3 (0x0000000303ffffffULL)
+
+/*
+ *   Register offsets for MN
+ */
+#define	NETXEN_MIU_CONTROL	(0x000)
+#define	NETXEN_MIU_MN_CONTROL	(NETXEN_CRB_DDR_NET+NETXEN_MIU_CONTROL)
 
 	/* 200ms delay in each loop */
 #define	NETXEN_NIU_PHY_WAITLEN		200000
@@ -633,6 +661,59 @@ enum {
 #define NETXEN_NIU_XG1_CONTROL_CHAR_CNT		(NETXEN_CRB_NIU + 0x80054)
 #define NETXEN_NIU_XG1_PAUSE_FRAME_CNT		(NETXEN_CRB_NIU + 0x80058)
 
+/* P3 802.3ap */
+#define NETXEN_NIU_AP_MAC_CONFIG_0(I)      (NETXEN_CRB_NIU+0xa0000+(I)*0x10000)
+#define NETXEN_NIU_AP_MAC_CONFIG_1(I)      (NETXEN_CRB_NIU+0xa0004+(I)*0x10000)
+#define NETXEN_NIU_AP_MAC_IPG_IFG(I)       (NETXEN_CRB_NIU+0xa0008+(I)*0x10000)
+#define NETXEN_NIU_AP_HALF_DUPLEX_CTRL(I)  (NETXEN_CRB_NIU+0xa000c+(I)*0x10000)
+#define NETXEN_NIU_AP_MAX_FRAME_SIZE(I)    (NETXEN_CRB_NIU+0xa0010+(I)*0x10000)
+#define NETXEN_NIU_AP_TEST_REG(I)          (NETXEN_CRB_NIU+0xa001c+(I)*0x10000)
+#define NETXEN_NIU_AP_MII_MGMT_CONFIG(I)   (NETXEN_CRB_NIU+0xa0020+(I)*0x10000)
+#define NETXEN_NIU_AP_MII_MGMT_COMMAND(I)  (NETXEN_CRB_NIU+0xa0024+(I)*0x10000)
+#define NETXEN_NIU_AP_MII_MGMT_ADDR(I)     (NETXEN_CRB_NIU+0xa0028+(I)*0x10000)
+#define NETXEN_NIU_AP_MII_MGMT_CTRL(I)     (NETXEN_CRB_NIU+0xa002c+(I)*0x10000)
+#define NETXEN_NIU_AP_MII_MGMT_STATUS(I)   (NETXEN_CRB_NIU+0xa0030+(I)*0x10000)
+#define NETXEN_NIU_AP_MII_MGMT_INDICATE(I) (NETXEN_CRB_NIU+0xa0034+(I)*0x10000)
+#define NETXEN_NIU_AP_INTERFACE_CTRL(I)    (NETXEN_CRB_NIU+0xa0038+(I)*0x10000)
+#define NETXEN_NIU_AP_INTERFACE_STATUS(I)  (NETXEN_CRB_NIU+0xa003c+(I)*0x10000)
+#define NETXEN_NIU_AP_STATION_ADDR_0(I)    (NETXEN_CRB_NIU+0xa0040+(I)*0x10000)
+#define NETXEN_NIU_AP_STATION_ADDR_1(I)    (NETXEN_CRB_NIU+0xa0044+(I)*0x10000)
+
+/*
+ *   Register offsets for MN
+ */
+#define	MIU_CONTROL	       (0x000)
+#define MIU_TEST_AGT_CTRL      (0x090)
+#define MIU_TEST_AGT_ADDR_LO   (0x094)
+#define MIU_TEST_AGT_ADDR_HI   (0x098)
+#define MIU_TEST_AGT_WRDATA_LO (0x0a0)
+#define MIU_TEST_AGT_WRDATA_HI (0x0a4)
+#define MIU_TEST_AGT_WRDATA(i) (0x0a0+(4*(i)))
+#define MIU_TEST_AGT_RDDATA_LO (0x0a8)
+#define MIU_TEST_AGT_RDDATA_HI (0x0ac)
+#define MIU_TEST_AGT_RDDATA(i) (0x0a8+(4*(i)))
+#define MIU_TEST_AGT_ADDR_MASK 0xfffffff8
+#define MIU_TEST_AGT_UPPER_ADDR(off) (0)
+
+/* MIU_TEST_AGT_CTRL flags. work for SIU as well */
+#define MIU_TA_CTL_START        1
+#define MIU_TA_CTL_ENABLE       2
+#define MIU_TA_CTL_WRITE        4
+#define MIU_TA_CTL_BUSY         8
+
+#define SIU_TEST_AGT_CTRL      (0x060)
+#define SIU_TEST_AGT_ADDR_LO   (0x064)
+#define SIU_TEST_AGT_ADDR_HI   (0x078)
+#define SIU_TEST_AGT_WRDATA_LO (0x068)
+#define SIU_TEST_AGT_WRDATA_HI (0x06c)
+#define SIU_TEST_AGT_WRDATA(i) (0x068+(4*(i)))
+#define SIU_TEST_AGT_RDDATA_LO (0x070)
+#define SIU_TEST_AGT_RDDATA_HI (0x074)
+#define SIU_TEST_AGT_RDDATA(i) (0x070+(4*(i)))
+
+#define SIU_TEST_AGT_ADDR_MASK 0x3ffff8
+#define SIU_TEST_AGT_UPPER_ADDR(off) ((off)>>22)
+
 /* XG Link status */
 #define XG_LINK_UP	0x10
 #define XG_LINK_DOWN	0x20
@@ -643,6 +724,7 @@ enum {
 #define NETXEN_FW_VERSION_MINOR (NETXEN_CAM_RAM(0x154))
 #define NETXEN_FW_VERSION_SUB	(NETXEN_CAM_RAM(0x158))
 #define NETXEN_ROM_LOCK_ID	(NETXEN_CAM_RAM(0x100))
+#define NETXEN_CRB_WIN_LOCK_ID	(NETXEN_CAM_RAM(0x124))
 
 #define NETXEN_PHY_LOCK_ID	(NETXEN_CAM_RAM(0x120))
 
@@ -657,30 +739,71 @@ enum {
 #define PCIX_INT_VECTOR		(0x10100)
 #define PCIX_INT_MASK		(0x10104)
 
-#define PCIX_MN_WINDOW_F0	(0x10200)
-#define PCIX_MN_WINDOW(_f)	(PCIX_MN_WINDOW_F0 + (0x20 * (_f)))
-#define PCIX_MS_WINDOW		(0x10204)
-#define PCIX_SN_WINDOW_F0	(0x10208)
-#define PCIX_SN_WINDOW(_f)	(PCIX_SN_WINDOW_F0 + (0x20 * (_f)))
 #define PCIX_CRB_WINDOW		(0x10210)
 #define PCIX_CRB_WINDOW_F0	(0x10210)
 #define PCIX_CRB_WINDOW_F1	(0x10230)
 #define PCIX_CRB_WINDOW_F2	(0x10250)
 #define PCIX_CRB_WINDOW_F3	(0x10270)
+#define PCIX_CRB_WINDOW_F4	(0x102ac)
+#define PCIX_CRB_WINDOW_F5	(0x102bc)
+#define PCIX_CRB_WINDOW_F6	(0x102cc)
+#define PCIX_CRB_WINDOW_F7	(0x102dc)
+#define PCIE_CRB_WINDOW_REG(func)	(((func) < 4) ? \
+		(PCIX_CRB_WINDOW_F0 + (0x20 * (func))) :\
+		(PCIX_CRB_WINDOW_F4 + (0x10 * ((func)-4))))
+
+#define PCIX_MN_WINDOW		(0x10200)
+#define PCIX_MN_WINDOW_F0	(0x10200)
+#define PCIX_MN_WINDOW_F1	(0x10220)
+#define PCIX_MN_WINDOW_F2	(0x10240)
+#define PCIX_MN_WINDOW_F3	(0x10260)
+#define PCIX_MN_WINDOW_F4	(0x102a0)
+#define PCIX_MN_WINDOW_F5	(0x102b0)
+#define PCIX_MN_WINDOW_F6	(0x102c0)
+#define PCIX_MN_WINDOW_F7	(0x102d0)
+#define PCIE_MN_WINDOW_REG(func)	(((func) < 4) ? \
+		(PCIX_MN_WINDOW_F0 + (0x20 * (func))) :\
+		(PCIX_MN_WINDOW_F4 + (0x10 * ((func)-4))))
+
+#define PCIX_SN_WINDOW		(0x10208)
+#define PCIX_SN_WINDOW_F0	(0x10208)
+#define PCIX_SN_WINDOW_F1	(0x10228)
+#define PCIX_SN_WINDOW_F2	(0x10248)
+#define PCIX_SN_WINDOW_F3	(0x10268)
+#define PCIX_SN_WINDOW_F4	(0x102a8)
+#define PCIX_SN_WINDOW_F5	(0x102b8)
+#define PCIX_SN_WINDOW_F6	(0x102c8)
+#define PCIX_SN_WINDOW_F7	(0x102d8)
+#define PCIE_SN_WINDOW_REG(func)	(((func) < 4) ? \
+		(PCIX_SN_WINDOW_F0 + (0x20 * (func))) :\
+		(PCIX_SN_WINDOW_F4 + (0x10 * ((func)-4))))
 
 #define PCIX_TARGET_STATUS	(0x10118)
+#define PCIX_TARGET_STATUS_F1	(0x10160)
+#define PCIX_TARGET_STATUS_F2	(0x10164)
+#define PCIX_TARGET_STATUS_F3	(0x10168)
+#define PCIX_TARGET_STATUS_F4	(0x10360)
+#define PCIX_TARGET_STATUS_F5	(0x10364)
+#define PCIX_TARGET_STATUS_F6	(0x10368)
+#define PCIX_TARGET_STATUS_F7	(0x1036c)
+
 #define PCIX_TARGET_MASK	(0x10128)
-#define PCIX_TARGET_STATUS_F1 (0x10160)
-#define PCIX_TARGET_MASK_F1   (0x10170)
-#define PCIX_TARGET_STATUS_F2 (0x10164)
-#define PCIX_TARGET_MASK_F2   (0x10174)
-#define PCIX_TARGET_STATUS_F3 (0x10168)
-#define PCIX_TARGET_MASK_F3   (0x10178)
+#define PCIX_TARGET_MASK_F1	(0x10170)
+#define PCIX_TARGET_MASK_F2	(0x10174)
+#define PCIX_TARGET_MASK_F3	(0x10178)
+#define PCIX_TARGET_MASK_F4	(0x10370)
+#define PCIX_TARGET_MASK_F5	(0x10374)
+#define PCIX_TARGET_MASK_F6	(0x10378)
+#define PCIX_TARGET_MASK_F7	(0x1037c)
 
 #define PCIX_MSI_F0		(0x13000)
 #define PCIX_MSI_F1		(0x13004)
 #define PCIX_MSI_F2		(0x13008)
 #define PCIX_MSI_F3		(0x1300c)
+#define PCIX_MSI_F4		(0x13010)
+#define PCIX_MSI_F5		(0x13014)
+#define PCIX_MSI_F6		(0x13018)
+#define PCIX_MSI_F7		(0x1301c)
 #define PCIX_MSI_F(i)		(0x13000+((i)*4))
 
 #define PCIX_PS_MEM_SPACE	(0x90000)
@@ -698,11 +821,102 @@ enum {
 #define PCIE_SEM2_UNLOCK	(0x1c014)	/* Flash unlock */
 #define PCIE_SEM3_LOCK	  	(0x1c018)	/* Phy lock     */
 #define PCIE_SEM3_UNLOCK	(0x1c01c)	/* Phy unlock   */
-
+#define PCIE_SEM5_LOCK		(0x1c028)	/* API lock     */
+#define PCIE_SEM5_UNLOCK	(0x1c02c)	/* API unlock   */
+#define PCIE_SEM6_LOCK		(0x1c030)	/* sw lock      */
+#define PCIE_SEM6_UNLOCK	(0x1c034)	/* sw unlock    */
+#define PCIE_SEM7_LOCK		(0x1c038)	/* crb win lock */
+#define PCIE_SEM7_UNLOCK	(0x1c03c)	/* crbwin unlock*/
+
+#define PCIE_SETUP_FUNCTION	(0x12040)
+#define PCIE_SETUP_FUNCTION2	(0x12048)
 #define PCIE_TGT_SPLIT_CHICKEN	(0x12080)
+#define PCIE_CHICKEN3		(0x120c8)
 
 #define PCIE_MAX_MASTER_SPLIT	(0x14048)
 
+#define NETXEN_PORT_MODE_NONE		0
+#define NETXEN_PORT_MODE_XG		1
+#define NETXEN_PORT_MODE_GB		2
+#define NETXEN_PORT_MODE_802_3_AP	3
+#define NETXEN_PORT_MODE_AUTO_NEG	4
+#define NETXEN_PORT_MODE_AUTO_NEG_1G	5
+#define NETXEN_PORT_MODE_AUTO_NEG_XG	6
+#define NETXEN_PORT_MODE_ADDR		(NETXEN_CAM_RAM(0x24))
+#define NETXEN_WOL_PORT_MODE		(NETXEN_CAM_RAM(0x198))
+
 #define NETXEN_CAM_RAM_DMA_WATCHDOG_CTRL		(0x14)
 
+#define	ISR_MSI_INT_TRIGGER(FUNC) (NETXEN_PCIX_PS_REG(PCIX_MSI_F(FUNC)))
+
+/*
+ * PCI Interrupt Vector Values.
+ */
+#define	PCIX_INT_VECTOR_BIT_F0	0x0080
+#define	PCIX_INT_VECTOR_BIT_F1	0x0100
+#define	PCIX_INT_VECTOR_BIT_F2	0x0200
+#define	PCIX_INT_VECTOR_BIT_F3	0x0400
+#define	PCIX_INT_VECTOR_BIT_F4	0x0800
+#define	PCIX_INT_VECTOR_BIT_F5	0x1000
+#define	PCIX_INT_VECTOR_BIT_F6	0x2000
+#define	PCIX_INT_VECTOR_BIT_F7	0x4000
+
+struct netxen_legacy_intr_set {
+	uint32_t	int_vec_bit;
+	uint32_t	tgt_status_reg;
+	uint32_t	tgt_mask_reg;
+	uint32_t	pci_int_reg;
+};
+
+#define	NX_LEGACY_INTR_CONFIG						\
+{									\
+	{								\
+		.int_vec_bit	=	PCIX_INT_VECTOR_BIT_F0,		\
+		.tgt_status_reg	=	ISR_INT_TARGET_STATUS,		\
+		.tgt_mask_reg	=	ISR_INT_TARGET_MASK,		\
+		.pci_int_reg	=	ISR_MSI_INT_TRIGGER(0) },	\
+									\
+	{								\
+		.int_vec_bit	=	PCIX_INT_VECTOR_BIT_F1,		\
+		.tgt_status_reg	=	ISR_INT_TARGET_STATUS_F1,	\
+		.tgt_mask_reg	=	ISR_INT_TARGET_MASK_F1,		\
+		.pci_int_reg	=	ISR_MSI_INT_TRIGGER(1) },	\
+									\
+	{								\
+		.int_vec_bit	=	PCIX_INT_VECTOR_BIT_F2,		\
+		.tgt_status_reg	=	ISR_INT_TARGET_STATUS_F2,	\
+		.tgt_mask_reg	=	ISR_INT_TARGET_MASK_F2,		\
+		.pci_int_reg	=	ISR_MSI_INT_TRIGGER(2) },	\
+									\
+	{								\
+		.int_vec_bit	=	PCIX_INT_VECTOR_BIT_F3,		\
+		.tgt_status_reg	=	ISR_INT_TARGET_STATUS_F3,	\
+		.tgt_mask_reg	=	ISR_INT_TARGET_MASK_F3,		\
+		.pci_int_reg	=	ISR_MSI_INT_TRIGGER(3) },	\
+									\
+	{								\
+		.int_vec_bit	=	PCIX_INT_VECTOR_BIT_F4,		\
+		.tgt_status_reg	=	ISR_INT_TARGET_STATUS_F4,	\
+		.tgt_mask_reg	=	ISR_INT_TARGET_MASK_F4,		\
+		.pci_int_reg	=	ISR_MSI_INT_TRIGGER(4) },	\
+									\
+	{								\
+		.int_vec_bit	=	PCIX_INT_VECTOR_BIT_F5,		\
+		.tgt_status_reg	=	ISR_INT_TARGET_STATUS_F5,	\
+		.tgt_mask_reg	=	ISR_INT_TARGET_MASK_F5,		\
+		.pci_int_reg	=	ISR_MSI_INT_TRIGGER(5) },	\
+									\
+	{								\
+		.int_vec_bit	=	PCIX_INT_VECTOR_BIT_F6,		\
+		.tgt_status_reg	=	ISR_INT_TARGET_STATUS_F6,	\
+		.tgt_mask_reg	=	ISR_INT_TARGET_MASK_F6,		\
+		.pci_int_reg	=	ISR_MSI_INT_TRIGGER(6) },	\
+									\
+	{								\
+		.int_vec_bit	=	PCIX_INT_VECTOR_BIT_F7,		\
+		.tgt_status_reg	=	ISR_INT_TARGET_STATUS_F7,	\
+		.tgt_mask_reg	=	ISR_INT_TARGET_MASK_F7,		\
+		.pci_int_reg	=	ISR_MSI_INT_TRIGGER(7) },	\
+}
+
 #endif				/* __NETXEN_NIC_HDR_H_ */
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 93466ec..a472873 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -609,33 +609,10 @@ void netxen_nic_pci_change_crbwindow(struct netxen_adapter *adapter, u32 wndw)
 	void __iomem *offset;
 	u32 tmp;
 	int count = 0;
+	uint8_t func = adapter->ahw.pci_func;
 
 	if (adapter->curr_window == wndw)
 		return;
-	switch(adapter->ahw.pci_func) {
-		case 0:
-			offset = PCI_OFFSET_SECOND_RANGE(adapter,
-					NETXEN_PCIX_PH_REG(PCIX_CRB_WINDOW));
-			break;
-		case 1:
-			offset = PCI_OFFSET_SECOND_RANGE(adapter,
-					NETXEN_PCIX_PH_REG(PCIX_CRB_WINDOW_F1));
-			break;
-		case 2:
-			offset = PCI_OFFSET_SECOND_RANGE(adapter,
-					NETXEN_PCIX_PH_REG(PCIX_CRB_WINDOW_F2));
-			break;
-		case 3:
-			offset = PCI_OFFSET_SECOND_RANGE(adapter,
-					NETXEN_PCIX_PH_REG(PCIX_CRB_WINDOW_F3));
-			break;
-		default:
-			printk(KERN_INFO "Changing the window for PCI function "
-					"%d\n",	adapter->ahw.pci_func);
-			offset = PCI_OFFSET_SECOND_RANGE(adapter,
-					NETXEN_PCIX_PH_REG(PCIX_CRB_WINDOW));
-			break;
-	}
 	/*
 	 * Move the CRB window.
 	 * We need to write to the "direct access" region of PCI
@@ -644,6 +621,8 @@ void netxen_nic_pci_change_crbwindow(struct netxen_adapter *adapter, u32 wndw)
 	 * register address is received by PCI. The direct region bypasses
 	 * the CRB bus.
 	 */
+	offset = PCI_OFFSET_SECOND_RANGE(adapter,
+			NETXEN_PCIX_PH_REG(PCIE_CRB_WINDOW_REG(func)));
 
 	if (wndw & 0x1)
 		wndw = NETXEN_WINDOW_ONE;
@@ -857,9 +836,11 @@ static int netxen_pci_set_window_warning_count;
 static  unsigned long netxen_nic_pci_set_window(struct netxen_adapter *adapter,
 						unsigned long long addr)
 {
+	void __iomem *offset;
 	static int ddr_mn_window = -1;
 	static int qdr_sn_window = -1;
 	int window;
+	uint8_t func = adapter->ahw.pci_func;
 
 	if (ADDR_IN_RANGE(addr, NETXEN_ADDR_DDR_NET, NETXEN_ADDR_DDR_NET_MAX)) {
 		/* DDR network side */
@@ -867,13 +848,11 @@ static  unsigned long netxen_nic_pci_set_window(struct netxen_adapter *adapter,
 		window = (addr >> 25) & 0x3ff;
 		if (ddr_mn_window != window) {
 			ddr_mn_window = window;
-			writel(window, PCI_OFFSET_SECOND_RANGE(adapter,
-							       NETXEN_PCIX_PH_REG
-							       (PCIX_MN_WINDOW(adapter->ahw.pci_func))));
+			offset = PCI_OFFSET_SECOND_RANGE(adapter,
+				NETXEN_PCIX_PH_REG(PCIE_MN_WINDOW_REG(func)));
+			writel(window, offset);
 			/* MUST make sure window is set before we forge on... */
-			readl(PCI_OFFSET_SECOND_RANGE(adapter,
-						      NETXEN_PCIX_PH_REG
-						      (PCIX_MN_WINDOW(adapter->ahw.pci_func))));
+			readl(offset);
 		}
 		addr -= (window * NETXEN_WINDOW_ONE);
 		addr += NETXEN_PCI_DDR_NET;
@@ -885,20 +864,17 @@ static  unsigned long netxen_nic_pci_set_window(struct netxen_adapter *adapter,
 		addr += NETXEN_PCI_OCM1;
 	} else
 	    if (ADDR_IN_RANGE
-		(addr, NETXEN_ADDR_QDR_NET, NETXEN_ADDR_QDR_NET_MAX)) {
+		(addr, NETXEN_ADDR_QDR_NET, NETXEN_ADDR_QDR_NET_MAX_P2)) {
 		/* QDR network side */
 		addr -= NETXEN_ADDR_QDR_NET;
 		window = (addr >> 22) & 0x3f;
 		if (qdr_sn_window != window) {
 			qdr_sn_window = window;
-			writel((window << 22),
-			       PCI_OFFSET_SECOND_RANGE(adapter,
-						       NETXEN_PCIX_PH_REG
-						       (PCIX_SN_WINDOW(adapter->ahw.pci_func))));
+			offset = PCI_OFFSET_SECOND_RANGE(adapter,
+				NETXEN_PCIX_PH_REG(PCIE_SN_WINDOW_REG(func)));
+			writel((window << 22), offset);
 			/* MUST make sure window is set before we forge on... */
-			readl(PCI_OFFSET_SECOND_RANGE(adapter,
-						      NETXEN_PCIX_PH_REG
-						      (PCIX_SN_WINDOW(adapter->ahw.pci_func))));
+			readl(offset);
 		}
 		addr -= (window * 0x400000);
 		addr += NETXEN_PCI_QDR_NET;
@@ -972,12 +948,25 @@ int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 	case NETXEN_BRDTYPE_P2_SB31_10G_IMEZ:
 	case NETXEN_BRDTYPE_P2_SB31_10G_HMEZ:
 	case NETXEN_BRDTYPE_P2_SB31_10G_CX4:
+	case NETXEN_BRDTYPE_P3_HMEZ:
+	case NETXEN_BRDTYPE_P3_XG_LOM:
+	case NETXEN_BRDTYPE_P3_10G_CX4:
+	case NETXEN_BRDTYPE_P3_10G_CX4_LP:
+	case NETXEN_BRDTYPE_P3_IMEZ:
+	case NETXEN_BRDTYPE_P3_10G_SFP_PLUS:
+	case NETXEN_BRDTYPE_P3_10G_XFP:
+	case NETXEN_BRDTYPE_P3_10000_BASE_T:
+
 		adapter->ahw.board_type = NETXEN_NIC_XGBE;
 		break;
 	case NETXEN_BRDTYPE_P1_BD:
 	case NETXEN_BRDTYPE_P1_SB:
 	case NETXEN_BRDTYPE_P1_SMAX:
 	case NETXEN_BRDTYPE_P1_SOCK:
+	case NETXEN_BRDTYPE_P3_REF_QG:
+	case NETXEN_BRDTYPE_P3_4_GB:
+	case NETXEN_BRDTYPE_P3_4_GB_MM:
+
 		adapter->ahw.board_type = NETXEN_NIC_GBE;
 		break;
 	default:
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index e35f1a4..dfde590 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -115,6 +115,8 @@ static void crb_addr_transform_setup(void)
 	crb_addr_transform(C2C1);
 	crb_addr_transform(C2C0);
 	crb_addr_transform(SMB);
+	crb_addr_transform(OCM0);
+	crb_addr_transform(I2C0);
 }
 
 int netxen_init_firmware(struct netxen_adapter *adapter)
@@ -743,7 +745,6 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 				    NETXEN_ROMBUS_RESET);
 
 	if (verbose) {
-		int val;
 		if (netxen_rom_fast_read(adapter, NETXEN_BOARDTYPE, &val) == 0)
 			printk("P2 ROM board type: 0x%08x\n", val);
 		else
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 0ec6e7e..192a22f 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -83,6 +83,7 @@ static struct pci_device_id netxen_pci_tbl[] __devinitdata = {
 	ENTRY(0x0005),
 	ENTRY(0x0024),
 	ENTRY(0x0025),
+	ENTRY(0x0100),
 	{0,}
 };
 
@@ -526,7 +527,6 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->crb_addr_cmd_consumer = crb_cmd_consumer[adapter->portnum];
 	netxen_nic_update_cmd_producer(adapter, 0);
 	netxen_nic_update_cmd_consumer(adapter, 0);
-	writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_HOST_CMD_ADDR_LO));
 
 	if (netxen_is_flash_supported(adapter) == 0 &&
 	    netxen_get_flash_mac_addr(adapter, mac_addr) == 0)
@@ -1099,7 +1099,7 @@ netxen_handle_int(struct netxen_adapter *adapter)
 	napi_schedule(&adapter->napi);
 }
 
-irqreturn_t netxen_intr(int irq, void *data)
+static irqreturn_t netxen_intr(int irq, void *data)
 {
 	struct netxen_adapter *adapter = data;
 	u32 our_int = 0;
@@ -1120,7 +1120,7 @@ irqreturn_t netxen_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-irqreturn_t netxen_msi_intr(int irq, void *data)
+static irqreturn_t netxen_msi_intr(int irq, void *data)
 {
 	struct netxen_adapter *adapter = data;
 
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index db2202a..09d0705 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -42,8 +42,11 @@
 #define CRB_CMD_CONSUMER_OFFSET     NETXEN_NIC_REG(0x0c)
 #define CRB_PAUSE_ADDR_LO           NETXEN_NIC_REG(0x10)	/* C0 EPG BUG  */
 #define CRB_PAUSE_ADDR_HI           NETXEN_NIC_REG(0x14)
-#define CRB_HOST_CMD_ADDR_HI        NETXEN_NIC_REG(0x18)	/* host add:cmd ring */
-#define CRB_HOST_CMD_ADDR_LO        NETXEN_NIC_REG(0x1c)
+#define NX_CDRP_CRB_OFFSET          NETXEN_NIC_REG(0x18)
+#define NX_ARG1_CRB_OFFSET          NETXEN_NIC_REG(0x1c)
+#define NX_ARG2_CRB_OFFSET          NETXEN_NIC_REG(0x20)
+#define NX_ARG3_CRB_OFFSET          NETXEN_NIC_REG(0x24)
+#define NX_SIGN_CRB_OFFSET          NETXEN_NIC_REG(0x28)
 #define CRB_CMD_INTR_LOOP           NETXEN_NIC_REG(0x20)	/* 4 regs for perf */
 #define CRB_CMD_DMA_LOOP            NETXEN_NIC_REG(0x24)
 #define CRB_RCV_INTR_LOOP           NETXEN_NIC_REG(0x28)
@@ -97,6 +100,7 @@
 #define CRB_HOST_BUFFER_CONS        NETXEN_NIC_REG(0xf0)
 #define CRB_JUMBO_BUFFER_PROD       NETXEN_NIC_REG(0xf4)
 #define CRB_JUMBO_BUFFER_CONS       NETXEN_NIC_REG(0xf8)
+#define CRB_HOST_DUMMY_BUF          NETXEN_NIC_REG(0xfc)
 
 #define CRB_RCVPEG_STATE            NETXEN_NIC_REG(0x13c)
 #define CRB_CMD_PRODUCER_OFFSET_1   NETXEN_NIC_REG(0x1ac)
-- 
1.5.4.3

