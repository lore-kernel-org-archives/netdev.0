From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [patch next 01/11] netxen: code cleanup
Date: Wed,  8 Apr 2009 01:50:38 -0700
Message-ID: <1239180648-29842-2-git-send-email-dhananjay@netxen.com>
References: <1239180648-29842-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:49847 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761904AbZDHIuy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2009 04:50:54 -0400
In-Reply-To: <1239180648-29842-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o remove unused structure defs.
o remove unnecessary includes.
o replace enums with specific #defines.
o reduce footprint of stats structure.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h          |  246 +++++++++++-------------------
 drivers/net/netxen/netxen_nic_ethtool.c  |   11 +-
 drivers/net/netxen/netxen_nic_hdr.h      |    8 -
 drivers/net/netxen/netxen_nic_hw.c       |   17 ++-
 drivers/net/netxen/netxen_nic_hw.h       |   66 +++------
 drivers/net/netxen/netxen_nic_main.c     |   19 +--
 drivers/net/netxen/netxen_nic_niu.c      |   14 +-
 drivers/net/netxen/netxen_nic_phan_reg.h |   21 +--
 8 files changed, 146 insertions(+), 256 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index c408151..184eb6f 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -34,10 +34,6 @@
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
-#include <linux/compiler.h>
-#include <linux/slab.h>
-#include <linux/delay.h>
-#include <linux/init.h>
 #include <linux/ioport.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
@@ -49,18 +45,12 @@
 
 #include <linux/ethtool.h>
 #include <linux/mii.h>
-#include <linux/interrupt.h>
 #include <linux/timer.h>
 
-#include <linux/mm.h>
-#include <linux/mman.h>
 #include <linux/vmalloc.h>
 
-#include <asm/system.h>
 #include <asm/io.h>
 #include <asm/byteorder.h>
-#include <asm/uaccess.h>
-#include <asm/pgtable.h>
 
 #include "netxen_nic_hw.h"
 
@@ -118,6 +108,7 @@
 #define NX_P3_A2		0x30
 #define NX_P3_B0		0x40
 #define NX_P3_B1		0x41
+#define NX_P3_B2		0x42
 
 #define NX_IS_REVISION_P2(REVISION)     (REVISION <= NX_P2_C1)
 #define NX_IS_REVISION_P3(REVISION)     (REVISION >= NX_P3_A0)
@@ -203,18 +194,8 @@
 #define MAX_RCV_DESCRIPTORS_10G		4096
 #define MAX_JUMBO_RCV_DESCRIPTORS	1024
 #define MAX_LRO_RCV_DESCRIPTORS		8
-#define MAX_RCVSTATUS_DESCRIPTORS	MAX_RCV_DESCRIPTORS
-#define MAX_JUMBO_RCV_DESC	MAX_JUMBO_RCV_DESCRIPTORS
-#define MAX_RCV_DESC		MAX_RCV_DESCRIPTORS
-#define MAX_RCVSTATUS_DESC	MAX_RCV_DESCRIPTORS
-#define MAX_EPG_DESCRIPTORS	(MAX_CMD_DESCRIPTORS * 8)
-#define NUM_RCV_DESC		(MAX_RCV_DESC + MAX_JUMBO_RCV_DESCRIPTORS + \
-				 MAX_LRO_RCV_DESCRIPTORS)
-#define MIN_TX_COUNT	4096
-#define MIN_RX_COUNT	4096
 #define NETXEN_CTX_SIGNATURE	0xdee0
 #define NETXEN_RCV_PRODUCER(ringid)	(ringid)
-#define MAX_FRAME_SIZE	0x10000	/* 64K MAX size for LSO */
 
 #define PHAN_PEG_RCV_INITIALIZED	0xff01
 #define PHAN_PEG_RCV_START_INITIALIZE	0xff00
@@ -384,11 +365,6 @@ struct rcv_desc {
 
 /* Note: sizeof(status_desc) should always be a mutliple of 2 */
 
-#define netxen_get_sts_desc_lro_cnt(status_desc)	\
-	((status_desc)->lro & 0x7F)
-#define netxen_get_sts_desc_lro_last_frag(status_desc)	\
-	(((status_desc)->lro & 0x80) >> 7)
-
 #define netxen_get_sts_port(sts_data)	\
 	((sts_data) & 0x0F)
 #define netxen_get_sts_status(sts_data)	\
@@ -434,10 +410,6 @@ struct status_desc {
 	};
 } __attribute__ ((aligned(16)));
 
-enum {
-	NETXEN_RCV_PEG_0 = 0,
-	NETXEN_RCV_PEG_1
-};
 /* The version of the main data structure */
 #define	NETXEN_BDINFO_VERSION 1
 
@@ -447,85 +419,35 @@ enum {
 /* Max number of Gig ports on a Phantom board */
 #define NETXEN_MAX_PORTS 4
 
-typedef enum {
-	NETXEN_BRDTYPE_P1_BD = 0x0000,
-	NETXEN_BRDTYPE_P1_SB = 0x0001,
-	NETXEN_BRDTYPE_P1_SMAX = 0x0002,
-	NETXEN_BRDTYPE_P1_SOCK = 0x0003,
-
-	NETXEN_BRDTYPE_P2_SOCK_31 = 0x0008,
-	NETXEN_BRDTYPE_P2_SOCK_35 = 0x0009,
-	NETXEN_BRDTYPE_P2_SB35_4G = 0x000a,
-	NETXEN_BRDTYPE_P2_SB31_10G = 0x000b,
-	NETXEN_BRDTYPE_P2_SB31_2G = 0x000c,
-
-	NETXEN_BRDTYPE_P2_SB31_10G_IMEZ = 0x000d,
-	NETXEN_BRDTYPE_P2_SB31_10G_HMEZ = 0x000e,
-	NETXEN_BRDTYPE_P2_SB31_10G_CX4 = 0x000f,
-
-	NETXEN_BRDTYPE_P3_REF_QG = 0x0021,
-	NETXEN_BRDTYPE_P3_HMEZ = 0x0022,
-	NETXEN_BRDTYPE_P3_10G_CX4_LP = 0x0023,
-	NETXEN_BRDTYPE_P3_4_GB = 0x0024,
-	NETXEN_BRDTYPE_P3_IMEZ = 0x0025,
-	NETXEN_BRDTYPE_P3_10G_SFP_PLUS = 0x0026,
-	NETXEN_BRDTYPE_P3_10000_BASE_T = 0x0027,
-	NETXEN_BRDTYPE_P3_XG_LOM = 0x0028,
-	NETXEN_BRDTYPE_P3_4_GB_MM = 0x0029,
-	NETXEN_BRDTYPE_P3_10G_SFP_CT = 0x002a,
-	NETXEN_BRDTYPE_P3_10G_SFP_QT = 0x002b,
-	NETXEN_BRDTYPE_P3_10G_CX4 = 0x0031,
-	NETXEN_BRDTYPE_P3_10G_XFP = 0x0032,
-	NETXEN_BRDTYPE_P3_10G_TP = 0x0080
-
-} netxen_brdtype_t;
-
-typedef enum {
-	NETXEN_BRDMFG_INVENTEC = 1
-} netxen_brdmfg;
-
-typedef enum {
-	MEM_ORG_128Mbx4 = 0x0,	/* DDR1 only */
-	MEM_ORG_128Mbx8 = 0x1,	/* DDR1 only */
-	MEM_ORG_128Mbx16 = 0x2,	/* DDR1 only */
-	MEM_ORG_256Mbx4 = 0x3,
-	MEM_ORG_256Mbx8 = 0x4,
-	MEM_ORG_256Mbx16 = 0x5,
-	MEM_ORG_512Mbx4 = 0x6,
-	MEM_ORG_512Mbx8 = 0x7,
-	MEM_ORG_512Mbx16 = 0x8,
-	MEM_ORG_1Gbx4 = 0x9,
-	MEM_ORG_1Gbx8 = 0xa,
-	MEM_ORG_1Gbx16 = 0xb,
-	MEM_ORG_2Gbx4 = 0xc,
-	MEM_ORG_2Gbx8 = 0xd,
-	MEM_ORG_2Gbx16 = 0xe,
-	MEM_ORG_128Mbx32 = 0x10002,	/* GDDR only */
-	MEM_ORG_256Mbx32 = 0x10005	/* GDDR only */
-} netxen_mn_mem_org_t;
-
-typedef enum {
-	MEM_ORG_512Kx36 = 0x0,
-	MEM_ORG_1Mx36 = 0x1,
-	MEM_ORG_2Mx36 = 0x2
-} netxen_sn_mem_org_t;
-
-typedef enum {
-	MEM_DEPTH_4MB = 0x1,
-	MEM_DEPTH_8MB = 0x2,
-	MEM_DEPTH_16MB = 0x3,
-	MEM_DEPTH_32MB = 0x4,
-	MEM_DEPTH_64MB = 0x5,
-	MEM_DEPTH_128MB = 0x6,
-	MEM_DEPTH_256MB = 0x7,
-	MEM_DEPTH_512MB = 0x8,
-	MEM_DEPTH_1GB = 0x9,
-	MEM_DEPTH_2GB = 0xa,
-	MEM_DEPTH_4GB = 0xb,
-	MEM_DEPTH_8GB = 0xc,
-	MEM_DEPTH_16GB = 0xd,
-	MEM_DEPTH_32GB = 0xe
-} netxen_mem_depth_t;
+#define NETXEN_BRDTYPE_P1_BD		0x0000
+#define NETXEN_BRDTYPE_P1_SB		0x0001
+#define NETXEN_BRDTYPE_P1_SMAX		0x0002
+#define NETXEN_BRDTYPE_P1_SOCK		0x0003
+
+#define NETXEN_BRDTYPE_P2_SOCK_31	0x0008
+#define NETXEN_BRDTYPE_P2_SOCK_35	0x0009
+#define NETXEN_BRDTYPE_P2_SB35_4G	0x000a
+#define NETXEN_BRDTYPE_P2_SB31_10G	0x000b
+#define NETXEN_BRDTYPE_P2_SB31_2G	0x000c
+
+#define NETXEN_BRDTYPE_P2_SB31_10G_IMEZ		0x000d
+#define NETXEN_BRDTYPE_P2_SB31_10G_HMEZ		0x000e
+#define NETXEN_BRDTYPE_P2_SB31_10G_CX4		0x000f
+
+#define NETXEN_BRDTYPE_P3_REF_QG	0x0021
+#define NETXEN_BRDTYPE_P3_HMEZ		0x0022
+#define NETXEN_BRDTYPE_P3_10G_CX4_LP	0x0023
+#define NETXEN_BRDTYPE_P3_4_GB		0x0024
+#define NETXEN_BRDTYPE_P3_IMEZ		0x0025
+#define NETXEN_BRDTYPE_P3_10G_SFP_PLUS	0x0026
+#define NETXEN_BRDTYPE_P3_10000_BASE_T	0x0027
+#define NETXEN_BRDTYPE_P3_XG_LOM	0x0028
+#define NETXEN_BRDTYPE_P3_4_GB_MM	0x0029
+#define NETXEN_BRDTYPE_P3_10G_SFP_CT	0x002a
+#define NETXEN_BRDTYPE_P3_10G_SFP_QT	0x002b
+#define NETXEN_BRDTYPE_P3_10G_CX4	0x0031
+#define NETXEN_BRDTYPE_P3_10G_XFP	0x0032
+#define NETXEN_BRDTYPE_P3_10G_TP	0x0080
 
 struct netxen_board_info {
 	u32 header_version;
@@ -676,17 +598,15 @@ struct netxen_new_user_info {
 #define PRIMARY_IMAGE_BAD	0xffffffff
 
 /* Flash memory map */
-typedef enum {
-	NETXEN_CRBINIT_START = 0,	/* Crbinit section */
-	NETXEN_BRDCFG_START = 0x4000,	/* board config */
-	NETXEN_INITCODE_START = 0x6000,	/* pegtune code */
-	NETXEN_BOOTLD_START = 0x10000,	/* bootld */
-	NETXEN_IMAGE_START = 0x43000,	/* compressed image */
-	NETXEN_SECONDARY_START = 0x200000,	/* backup images */
-	NETXEN_PXE_START = 0x3E0000,	/* user defined region */
-	NETXEN_USER_START = 0x3E8000,	/* User defined region for new boards */
-	NETXEN_FIXED_START = 0x3F0000	/* backup of crbinit */
-} netxen_flash_map_t;
+#define NETXEN_CRBINIT_START	0	/* crbinit section */
+#define NETXEN_BRDCFG_START	0x4000	/* board config */
+#define NETXEN_INITCODE_START	0x6000	/* pegtune code */
+#define NETXEN_BOOTLD_START	0x10000	/* bootld */
+#define NETXEN_IMAGE_START	0x43000	/* compressed image */
+#define NETXEN_SECONDARY_START	0x200000	/* backup images */
+#define NETXEN_PXE_START	0x3E0000	/* PXE boot rom */
+#define NETXEN_USER_START	0x3E8000	/* Firmare info */
+#define NETXEN_FIXED_START	0x3F0000	/* backup of crbinit */
 
 #define NX_FW_VERSION_OFFSET	(NETXEN_USER_START+0x408)
 #define NX_FW_SIZE_OFFSET	(NETXEN_USER_START+0x40c)
@@ -708,21 +628,8 @@ typedef enum {
 #define NETXEN_FLASH_SECONDARY_SIZE 	(NETXEN_USER_START-NETXEN_SECONDARY_START)
 #define NETXEN_NUM_PRIMARY_SECTORS	(0x20)
 #define NETXEN_NUM_CONFIG_SECTORS 	(1)
-#define PFX "NetXen: "
 extern char netxen_nic_driver_name[];
 
-/* Note: Make sure to not call this before adapter->port is valid */
-#if !defined(NETXEN_DEBUG)
-#define DPRINTK(klevel, fmt, args...)	do { \
-	} while (0)
-#else
-#define DPRINTK(klevel, fmt, args...)	do { \
-	printk(KERN_##klevel PFX "%s: %s: " fmt, __func__,\
-		(adapter != NULL && adapter->netdev != NULL) ? \
-		adapter->netdev->name : NULL, \
-		## args); } while(0)
-#endif
-
 /* Number of status descriptors to handle per interrupt */
 #define MAX_STATUS_HANDLE	(64)
 
@@ -807,20 +714,14 @@ struct netxen_hardware_context {
 #define ETHERNET_FCS_SIZE		4
 
 struct netxen_adapter_stats {
-	u64  rcvdbadskb;
 	u64  xmitcalled;
-	u64  xmitedframes;
 	u64  xmitfinished;
-	u64  badskblen;
-	u64  nocmddescriptor;
-	u64  polled;
 	u64  rxdropped;
 	u64  txdropped;
 	u64  csummed;
 	u64  no_rcv;
 	u64  rxbytes;
 	u64  txbytes;
-	u64  ints;
 };
 
 /*
@@ -1154,26 +1055,53 @@ typedef struct {
 
 #define NX_MAC_EVENT		0x1
 
-enum {
-	NX_NIC_H2C_OPCODE_START = 0,
-	NX_NIC_H2C_OPCODE_CONFIG_RSS,
-	NX_NIC_H2C_OPCODE_CONFIG_RSS_TBL,
-	NX_NIC_H2C_OPCODE_CONFIG_INTR_COALESCE,
-	NX_NIC_H2C_OPCODE_CONFIG_LED,
-	NX_NIC_H2C_OPCODE_CONFIG_PROMISCUOUS,
-	NX_NIC_H2C_OPCODE_CONFIG_L2_MAC,
-	NX_NIC_H2C_OPCODE_LRO_REQUEST,
-	NX_NIC_H2C_OPCODE_GET_SNMP_STATS,
-	NX_NIC_H2C_OPCODE_PROXY_START_REQUEST,
-	NX_NIC_H2C_OPCODE_PROXY_STOP_REQUEST,
-	NX_NIC_H2C_OPCODE_PROXY_SET_MTU,
-	NX_NIC_H2C_OPCODE_PROXY_SET_VPORT_MISS_MODE,
-	NX_H2P_OPCODE_GET_FINGER_PRINT_REQUEST,
-	NX_H2P_OPCODE_INSTALL_LICENSE_REQUEST,
-	NX_H2P_OPCODE_GET_LICENSE_CAPABILITY_REQUEST,
-	NX_NIC_H2C_OPCODE_GET_NET_STATS,
-	NX_NIC_H2C_OPCODE_LAST
-};
+/*
+ * Driver --> Firmware
+ */
+#define NX_NIC_H2C_OPCODE_START				0
+#define NX_NIC_H2C_OPCODE_CONFIG_RSS			1
+#define NX_NIC_H2C_OPCODE_CONFIG_RSS_TBL		2
+#define NX_NIC_H2C_OPCODE_CONFIG_INTR_COALESCE		3
+#define NX_NIC_H2C_OPCODE_CONFIG_LED			4
+#define NX_NIC_H2C_OPCODE_CONFIG_PROMISCUOUS		5
+#define NX_NIC_H2C_OPCODE_CONFIG_L2_MAC			6
+#define NX_NIC_H2C_OPCODE_LRO_REQUEST			7
+#define NX_NIC_H2C_OPCODE_GET_SNMP_STATS		8
+#define NX_NIC_H2C_OPCODE_PROXY_START_REQUEST		9
+#define NX_NIC_H2C_OPCODE_PROXY_STOP_REQUEST		10
+#define NX_NIC_H2C_OPCODE_PROXY_SET_MTU			11
+#define NX_NIC_H2C_OPCODE_PROXY_SET_VPORT_MISS_MODE	12
+#define NX_NIC_H2C_OPCODE_GET_FINGER_PRINT_REQUEST	13
+#define NX_NIC_H2C_OPCODE_INSTALL_LICENSE_REQUEST	14
+#define NX_NIC_H2C_OPCODE_GET_LICENSE_CAPABILITY_REQUEST	15
+#define NX_NIC_H2C_OPCODE_GET_NET_STATS			16
+#define NX_NIC_H2C_OPCODE_PROXY_UPDATE_P2V		17
+#define NX_NIC_H2C_OPCODE_CONFIG_IPADDR			18
+#define NX_NIC_H2C_OPCODE_CONFIG_LOOPBACK		19
+#define NX_NIC_H2C_OPCODE_PROXY_STOP_DONE		20
+#define NX_NIC_H2C_OPCODE_GET_LINKEVENT			21
+#define NX_NIC_C2C_OPCODE				22
+#define NX_NIC_H2C_OPCODE_LAST				23
+
+/*
+ * Firmware --> Driver
+ */
+
+#define NX_NIC_C2H_OPCODE_START				128
+#define NX_NIC_C2H_OPCODE_CONFIG_RSS_RESPONSE		129
+#define NX_NIC_C2H_OPCODE_CONFIG_RSS_TBL_RESPONSE	130
+#define NX_NIC_C2H_OPCODE_CONFIG_MAC_RESPONSE		131
+#define NX_NIC_C2H_OPCODE_CONFIG_PROMISCUOUS_RESPONSE	132
+#define NX_NIC_C2H_OPCODE_CONFIG_L2_MAC_RESPONSE	133
+#define NX_NIC_C2H_OPCODE_LRO_DELETE_RESPONSE		134
+#define NX_NIC_C2H_OPCODE_LRO_ADD_FAILURE_RESPONSE	135
+#define NX_NIC_C2H_OPCODE_GET_SNMP_STATS		136
+#define NX_NIC_C2H_OPCODE_GET_FINGER_PRINT_REPLY	137
+#define NX_NIC_C2H_OPCODE_INSTALL_LICENSE_REPLY		138
+#define NX_NIC_C2H_OPCODE_GET_LICENSE_CAPABILITIES_REPLY 139
+#define NX_NIC_C2H_OPCODE_GET_NET_STATS_RESPONSE	140
+#define NX_NIC_C2H_OPCODE_GET_LINKEVENT_RESPONSE	141
+#define NX_NIC_C2H_OPCODE_LAST				142
 
 #define VPORT_MISS_MODE_DROP		0 /* drop all unmatched */
 #define VPORT_MISS_MODE_ACCEPT_ALL	1 /* accept all packets */
@@ -1491,7 +1419,7 @@ void netxen_nic_update_cmd_producer(struct netxen_adapter *adapter,
 
 #define NETXEN_MAX_SHORT_NAME 32
 struct netxen_brdinfo {
-	netxen_brdtype_t brdtype;	/* type of board */
+	int brdtype;	/* type of board */
 	long ports;		/* max no of physical ports */
 	char short_name[NETXEN_MAX_SHORT_NAME];
 };
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index a677ff8..fe910c1 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -30,7 +30,6 @@
 
 #include <linux/types.h>
 #include <linux/delay.h>
-#include <asm/uaccess.h>
 #include <linux/pci.h>
 #include <asm/io.h>
 #include <linux/netdevice.h>
@@ -53,13 +52,9 @@ struct netxen_nic_stats {
 #define NETXEN_NIC_INVALID_DATA 0xDEADBEEF
 
 static const struct netxen_nic_stats netxen_nic_gstrings_stats[] = {
-	{"rcvd_bad_skb", NETXEN_NIC_STAT(stats.rcvdbadskb)},
 	{"xmit_called", NETXEN_NIC_STAT(stats.xmitcalled)},
-	{"xmited_frames", NETXEN_NIC_STAT(stats.xmitedframes)},
 	{"xmit_finished", NETXEN_NIC_STAT(stats.xmitfinished)},
-	{"bad_skb_len", NETXEN_NIC_STAT(stats.badskblen)},
-	{"no_cmd_desc", NETXEN_NIC_STAT(stats.nocmddescriptor)},
-	{"polled", NETXEN_NIC_STAT(stats.polled)},
+	{"rx_dropped", NETXEN_NIC_STAT(stats.rxdropped)},
 	{"tx_dropped", NETXEN_NIC_STAT(stats.txdropped)},
 	{"csummed", NETXEN_NIC_STAT(stats.csummed)},
 	{"no_rcv", NETXEN_NIC_STAT(stats.no_rcv)},
@@ -168,7 +163,7 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	ecmd->phy_address = adapter->physical_port;
 	ecmd->transceiver = XCVR_EXTERNAL;
 
-	switch ((netxen_brdtype_t)adapter->ahw.board_type) {
+	switch (adapter->ahw.board_type) {
 	case NETXEN_BRDTYPE_P2_SB35_4G:
 	case NETXEN_BRDTYPE_P2_SB31_2G:
 	case NETXEN_BRDTYPE_P3_REF_QG:
@@ -227,7 +222,7 @@ netxen_nic_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		break;
 	default:
 		printk(KERN_ERR "netxen-nic: Unsupported board model %d\n",
-		       (netxen_brdtype_t)adapter->ahw.board_type);
+				adapter->ahw.board_type);
 		return -EIO;
 	}
 
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 016c621..7f0ddbf 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -31,16 +31,8 @@
 #ifndef __NETXEN_NIC_HDR_H_
 #define __NETXEN_NIC_HDR_H_
 
-#include <linux/module.h>
 #include <linux/kernel.h>
-#include <linux/spinlock.h>
-#include <asm/irq.h>
-#include <linux/init.h>
-#include <linux/errno.h>
-#include <linux/pci.h>
 #include <linux/types.h>
-#include <asm/uaccess.h>
-#include <asm/string.h>		/* for memset */
 
 /*
  * The basic unit of access when reading/writing control registers.
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 5026811..67d63ee 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -48,6 +48,21 @@
 #define CRB_HI(off)	((crb_hub_agt[CRB_BLK(off)] << 20) | ((off) & 0xf0000))
 #define CRB_INDIRECT_2M	(0x1e0000UL)
 
+#ifndef readq
+static inline u64 readq(void __iomem *addr)
+{
+	return readl(addr) | (((u64) readl(addr + 4)) << 32LL);
+}
+#endif
+
+#ifndef writeq
+static inline void writeq(u64 val, void __iomem *addr)
+{
+	writel(((u32) (val)), (addr));
+	writel(((u32) (val >> 32)), (addr + 4));
+}
+#endif
+
 #define CRB_WIN_LOCK_TIMEOUT 100000000
 static crb_128M_2M_block_map_t crb_128M_2M_map[64] = {
     {{{0, 0,         0,         0} } },		/* 0: PCI */
@@ -2148,7 +2163,7 @@ int netxen_nic_get_board_info(struct netxen_adapter *adapter)
 			board_type = NETXEN_BRDTYPE_P3_10G_TP;
 	}
 
-	switch ((netxen_brdtype_t)board_type) {
+	switch (board_type) {
 	case NETXEN_BRDTYPE_P2_SB35_4G:
 		adapter->ahw.port_type = NETXEN_NIC_GBE;
 		break;
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index 04b47a7..f20c965 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
@@ -36,35 +36,15 @@
 /* Hardware memory size of 128 meg */
 #define NETXEN_MEMADDR_MAX (128 * 1024 * 1024)
 
-#ifndef readq
-static inline u64 readq(void __iomem * addr)
-{
-	return readl(addr) | (((u64) readl(addr + 4)) << 32LL);
-}
-#endif
-
-#ifndef writeq
-static inline void writeq(u64 val, void __iomem * addr)
-{
-	writel(((u32) (val)), (addr));
-	writel(((u32) (val >> 32)), (addr + 4));
-}
-#endif
-
 struct netxen_adapter;
 
 #define NETXEN_PCI_MAPSIZE_BYTES  (NETXEN_PCI_MAPSIZE << 20)
 
-struct netxen_port;
 void netxen_nic_set_link_parameters(struct netxen_adapter *adapter);
 
 typedef u8 netxen_ethernet_macaddr_t[6];
 
 /* Nibble or Byte mode for phy interface (GbE mode only) */
-typedef enum {
-	NETXEN_NIU_10_100_MB = 0,
-	NETXEN_NIU_1000_MB
-} netxen_niu_gbe_ifmode_t;
 
 #define _netxen_crb_get_bit(var, bit)  ((var >> bit) & 0x1)
 
@@ -222,30 +202,28 @@ typedef enum {
 /*
  * PHY-Specific MII control/status registers.
  */
-typedef enum {
-	NETXEN_NIU_GB_MII_MGMT_ADDR_CONTROL = 0,
-	NETXEN_NIU_GB_MII_MGMT_ADDR_STATUS = 1,
-	NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_ID_0 = 2,
-	NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_ID_1 = 3,
-	NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG = 4,
-	NETXEN_NIU_GB_MII_MGMT_ADDR_LNKPART = 5,
-	NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG_MORE = 6,
-	NETXEN_NIU_GB_MII_MGMT_ADDR_NEXTPAGE_XMIT = 7,
-	NETXEN_NIU_GB_MII_MGMT_ADDR_LNKPART_NEXTPAGE = 8,
-	NETXEN_NIU_GB_MII_MGMT_ADDR_1000BT_CONTROL = 9,
-	NETXEN_NIU_GB_MII_MGMT_ADDR_1000BT_STATUS = 10,
-	NETXEN_NIU_GB_MII_MGMT_ADDR_EXTENDED_STATUS = 15,
-	NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_CONTROL = 16,
-	NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS = 17,
-	NETXEN_NIU_GB_MII_MGMT_ADDR_INT_ENABLE = 18,
-	NETXEN_NIU_GB_MII_MGMT_ADDR_INT_STATUS = 19,
-	NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_CONTROL_MORE = 20,
-	NETXEN_NIU_GB_MII_MGMT_ADDR_RECV_ERROR_COUNT = 21,
-	NETXEN_NIU_GB_MII_MGMT_ADDR_LED_CONTROL = 24,
-	NETXEN_NIU_GB_MII_MGMT_ADDR_LED_OVERRIDE = 25,
-	NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_CONTROL_MORE_YET = 26,
-	NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS_MORE = 27
-} netxen_niu_phy_register_t;
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_CONTROL		0
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_STATUS		1
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_ID_0		2
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_ID_1		3
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG		4
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_LNKPART		5
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_AUTONEG_MORE	6
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_NEXTPAGE_XMIT	7
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_LNKPART_NEXTPAGE	8
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_1000BT_CONTROL	9
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_1000BT_STATUS	10
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_EXTENDED_STATUS	15
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_CONTROL		16
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS		17
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_INT_ENABLE		18
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_INT_STATUS		19
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_CONTROL_MORE	20
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_RECV_ERROR_COUNT	21
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_LED_CONTROL		24
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_LED_OVERRIDE	25
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_CONTROL_MORE_YET	26
+#define NETXEN_NIU_GB_MII_MGMT_ADDR_PHY_STATUS_MORE	27
 
 /*
  * PHY-Specific Status Register (reg 17).
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 1af4725..9b7a292 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -29,7 +29,7 @@
  */
 
 #include <linux/vmalloc.h>
-#include <linux/highmem.h>
+#include <linux/interrupt.h>
 #include "netxen_nic_hw.h"
 
 #include "netxen_nic.h"
@@ -1598,10 +1598,6 @@ static void netxen_tx_timeout_task(struct work_struct *work)
 	netif_wake_queue(adapter->netdev);
 }
 
-/*
- * netxen_nic_get_stats - Get System Network Statistics
- * @netdev: network interface device structure
- */
 struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
@@ -1609,22 +1605,11 @@ struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev)
 
 	memset(stats, 0, sizeof(*stats));
 
-	/* total packets received   */
 	stats->rx_packets = adapter->stats.no_rcv;
-	/* total packets transmitted    */
-	stats->tx_packets = adapter->stats.xmitedframes +
-		adapter->stats.xmitfinished;
-	/* total bytes received     */
+	stats->tx_packets = adapter->stats.xmitfinished;
 	stats->rx_bytes = adapter->stats.rxbytes;
-	/* total bytes transmitted  */
 	stats->tx_bytes = adapter->stats.txbytes;
-	/* bad packets received     */
-	stats->rx_errors = adapter->stats.rcvdbadskb;
-	/* packet transmit problems */
-	stats->tx_errors = adapter->stats.nocmddescriptor;
-	/* no space in linux buffers    */
 	stats->rx_dropped = adapter->stats.rxdropped;
-	/* no space available in linux  */
 	stats->tx_dropped = adapter->stats.txdropped;
 
 	return stats;
diff --git a/drivers/net/netxen/netxen_nic_niu.c b/drivers/net/netxen/netxen_nic_niu.c
index d852032..3310471 100644
--- a/drivers/net/netxen/netxen_nic_niu.c
+++ b/drivers/net/netxen/netxen_nic_niu.c
@@ -342,9 +342,9 @@ static void netxen_niu_gbe_set_mii_mode(struct netxen_adapter *adapter,
 	}
 
 	if (netxen_niu_gbe_enable_phy_interrupts(adapter))
-		printk(KERN_ERR PFX "ERROR enabling PHY interrupts\n");
+		printk(KERN_ERR "ERROR enabling PHY interrupts\n");
 	if (netxen_niu_gbe_clear_phy_interrupts(adapter))
-		printk(KERN_ERR PFX "ERROR clearing PHY interrupts\n");
+		printk(KERN_ERR "ERROR clearing PHY interrupts\n");
 }
 
 /*
@@ -380,9 +380,9 @@ static void netxen_niu_gbe_set_gmii_mode(struct netxen_adapter *adapter,
 	}
 
 	if (netxen_niu_gbe_enable_phy_interrupts(adapter))
-		printk(KERN_ERR PFX "ERROR enabling PHY interrupts\n");
+		printk(KERN_ERR "ERROR enabling PHY interrupts\n");
 	if (netxen_niu_gbe_clear_phy_interrupts(adapter))
-		printk(KERN_ERR PFX "ERROR clearing PHY interrupts\n");
+		printk(KERN_ERR "ERROR clearing PHY interrupts\n");
 }
 
 int netxen_niu_gbe_init_port(struct netxen_adapter *adapter, int port)
@@ -428,13 +428,13 @@ int netxen_niu_gbe_init_port(struct netxen_adapter *adapter, int port)
 						    |
 						    NETXEN_GB_MAC_PAUSED_FRMS);
 			if (netxen_niu_gbe_clear_phy_interrupts(adapter))
-				printk(KERN_ERR PFX
+				printk(KERN_ERR
 				       "ERROR clearing PHY interrupts\n");
 			if (netxen_niu_gbe_enable_phy_interrupts(adapter))
-				printk(KERN_ERR PFX
+				printk(KERN_ERR
 				       "ERROR enabling PHY interrupts\n");
 			if (netxen_niu_gbe_clear_phy_interrupts(adapter))
-				printk(KERN_ERR PFX
+				printk(KERN_ERR
 				       "ERROR clearing PHY interrupts\n");
 			result = -1;
 		}
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index 5018333..18ea35d 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -41,18 +41,18 @@
 #define CRB_PHAN_CNTRL_HI_OFFSET    NETXEN_NIC_REG(0x04)
 #define CRB_CMD_PRODUCER_OFFSET     NETXEN_NIC_REG(0x08)
 #define CRB_CMD_CONSUMER_OFFSET     NETXEN_NIC_REG(0x0c)
-#define CRB_PAUSE_ADDR_LO           NETXEN_NIC_REG(0x10)	/* C0 EPG BUG  */
+#define CRB_PAUSE_ADDR_LO           NETXEN_NIC_REG(0x10)
 #define CRB_PAUSE_ADDR_HI           NETXEN_NIC_REG(0x14)
 #define NX_CDRP_CRB_OFFSET          NETXEN_NIC_REG(0x18)
 #define NX_ARG1_CRB_OFFSET          NETXEN_NIC_REG(0x1c)
 #define NX_ARG2_CRB_OFFSET          NETXEN_NIC_REG(0x20)
 #define NX_ARG3_CRB_OFFSET          NETXEN_NIC_REG(0x24)
 #define NX_SIGN_CRB_OFFSET          NETXEN_NIC_REG(0x28)
-#define CRB_CMD_INTR_LOOP           NETXEN_NIC_REG(0x20)	/* 4 regs for perf */
+#define CRB_CMD_INTR_LOOP           NETXEN_NIC_REG(0x20)
 #define CRB_CMD_DMA_LOOP            NETXEN_NIC_REG(0x24)
 #define CRB_RCV_INTR_LOOP           NETXEN_NIC_REG(0x28)
 #define CRB_RCV_DMA_LOOP            NETXEN_NIC_REG(0x2c)
-#define CRB_ENABLE_TX_INTR          NETXEN_NIC_REG(0x30)	/* phantom init status */
+#define CRB_ENABLE_TX_INTR          NETXEN_NIC_REG(0x30)
 #define CRB_MMAP_ADDR_3             NETXEN_NIC_REG(0x34)
 #define CRB_CMDPEG_CMDRING          NETXEN_NIC_REG(0x38)
 #define CRB_HOST_DUMMY_BUF_ADDR_HI  NETXEN_NIC_REG(0x3c)
@@ -65,7 +65,7 @@
 #define CRB_MMAP_SIZE_1             NETXEN_NIC_REG(0x58)
 #define CRB_MMAP_SIZE_2             NETXEN_NIC_REG(0x5c)
 #define CRB_MMAP_SIZE_3             NETXEN_NIC_REG(0x60)
-#define CRB_GLOBAL_INT_COAL         NETXEN_NIC_REG(0x64)	/* interrupt coalescing */
+#define CRB_GLOBAL_INT_COAL         NETXEN_NIC_REG(0x64)
 #define CRB_INT_COAL_MODE           NETXEN_NIC_REG(0x68)
 #define CRB_MAX_RCV_BUFS            NETXEN_NIC_REG(0x6c)
 #define CRB_TX_INT_THRESHOLD        NETXEN_NIC_REG(0x70)
@@ -83,13 +83,13 @@
 #define CRB_AGENT_TX_TYPE           NETXEN_NIC_REG(0xa0)
 #define CRB_AGENT_TX_ADDR           NETXEN_NIC_REG(0xa4)
 #define CRB_AGENT_TX_MSS            NETXEN_NIC_REG(0xa8)
-#define CRB_TX_STATE                NETXEN_NIC_REG(0xac)	/* Debug -performance */
+#define CRB_TX_STATE                NETXEN_NIC_REG(0xac)
 #define CRB_TX_COUNT                NETXEN_NIC_REG(0xb0)
 #define CRB_RX_STATE                NETXEN_NIC_REG(0xb4)
 #define CRB_RX_PERF_DEBUG_1         NETXEN_NIC_REG(0xb8)
-#define CRB_RX_LRO_CONTROL          NETXEN_NIC_REG(0xbc)	/* LRO On/OFF */
+#define CRB_RX_LRO_CONTROL          NETXEN_NIC_REG(0xbc)
 #define CRB_RX_LRO_START_NUM        NETXEN_NIC_REG(0xc0)
-#define CRB_MPORT_MODE              NETXEN_NIC_REG(0xc4)	/* Multiport Mode */
+#define CRB_MPORT_MODE              NETXEN_NIC_REG(0xc4)
 #define CRB_CMD_RING_SIZE           NETXEN_NIC_REG(0xc8)
 #define CRB_DMA_SHIFT               NETXEN_NIC_REG(0xcc)
 #define CRB_INT_VECTOR              NETXEN_NIC_REG(0xd4)
@@ -109,8 +109,6 @@
 #define CRB_CMD_CONSUMER_OFFSET_1   NETXEN_NIC_REG(0x1b0)
 #define CRB_CMD_PRODUCER_OFFSET_2   NETXEN_NIC_REG(0x1b8)
 #define CRB_CMD_CONSUMER_OFFSET_2   NETXEN_NIC_REG(0x1bc)
-
-// 1c0 to 1cc used for signature reg
 #define CRB_CMD_PRODUCER_OFFSET_3   NETXEN_NIC_REG(0x1d0)
 #define CRB_CMD_CONSUMER_OFFSET_3   NETXEN_NIC_REG(0x1d4)
 #define CRB_TEMP_STATE              NETXEN_NIC_REG(0x1b4)
@@ -120,8 +118,7 @@
 #define CRB_V2P_2		    NETXEN_NIC_REG(0x298)
 #define CRB_V2P_3		    NETXEN_NIC_REG(0x29c)
 #define CRB_V2P(port)		    (CRB_V2P_0+((port)*4))
-#define CRB_DRIVER_VERSION	    NETXEN_NIC_REG(0x2a0)
-/* sw int status/mask registers */
+#define CRB_DRIVER_VERSION	   NETXEN_NIC_REG(0x2a0)
 #define CRB_SW_INT_MASK_0	   NETXEN_NIC_REG(0x1d8)
 #define CRB_SW_INT_MASK_1	   NETXEN_NIC_REG(0x1e0)
 #define CRB_SW_INT_MASK_2	   NETXEN_NIC_REG(0x1e4)
@@ -136,7 +133,7 @@
 #define CRB_NIC_CAPABILITIES_HOST	NETXEN_NIC_REG(0x1a8)
 #define CRB_NIC_CAPABILITIES_FW	  	NETXEN_NIC_REG(0x1dc)
 #define CRB_NIC_MSI_MODE_HOST		NETXEN_NIC_REG(0x270)
-#define CRB_NIC_MSI_MODE_FW	  		NETXEN_NIC_REG(0x274)
+#define CRB_NIC_MSI_MODE_FW	  	NETXEN_NIC_REG(0x274)
 
 #define INTR_SCHEME_PERPORT	      	0x1
 #define MSI_MODE_MULTIFUNC	      	0x1
-- 
1.6.0.2

