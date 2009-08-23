From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 5/5] netxen: remove netxen_nic_phan_reg.h
Date: Sun, 23 Aug 2009 11:35:13 -0700
Message-ID: <1251052513-27618-5-git-send-email-dhananjay@netxen.com>
References: <1251052513-27618-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:19505 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S933623AbZHWSfN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Aug 2009 14:35:13 -0400
In-Reply-To: <1251052513-27618-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consolidate register definitions in netxen_nic_hdr.h

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h          |   31 +++--
 drivers/net/netxen/netxen_nic_ctx.c      |    1 -
 drivers/net/netxen/netxen_nic_ethtool.c  |    1 -
 drivers/net/netxen/netxen_nic_hdr.h      |   85 ++++++++++++++-
 drivers/net/netxen/netxen_nic_hw.c       |    1 -
 drivers/net/netxen/netxen_nic_hw.h       |   18 ---
 drivers/net/netxen/netxen_nic_init.c     |    1 -
 drivers/net/netxen/netxen_nic_main.c     |    1 -
 drivers/net/netxen/netxen_nic_phan_reg.h |  178 ------------------------------
 9 files changed, 102 insertions(+), 215 deletions(-)
 delete mode 100644 drivers/net/netxen/netxen_nic_phan_reg.h

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index fa43aa0..7a93f82 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -53,6 +53,7 @@
 #include <asm/io.h>
 #include <asm/byteorder.h>
 
+#include "netxen_nic_hdr.h"
 #include "netxen_nic_hw.h"
 
 #define _NETXEN_NIC_LINUX_MAJOR 4
@@ -227,8 +228,6 @@
 #define MPORT_SINGLE_FUNCTION_MODE 0x1111
 #define MPORT_MULTI_FUNCTION_MODE 0x2222
 
-#include "netxen_nic_phan_reg.h"
-
 /*
  * NetXen host-peg signal message structure
  *
@@ -503,17 +502,11 @@ struct netxen_skb_frag {
 	u64 length;
 };
 
-#define _netxen_set_bits(config_word, start, bits, val)	{\
-	unsigned long long __tmask = (((1ULL << (bits)) - 1) << (start));\
-	unsigned long long __tvalue = (val);    \
-	(config_word) &= ~__tmask;      \
-	(config_word) |= (((__tvalue) << (start)) & __tmask); \
-}
-
-#define _netxen_clear_bits(config_word, start, bits) {\
-	unsigned long long __tmask = (((1ULL << (bits)) - 1) << (start));  \
-	(config_word) &= ~__tmask; \
-}
+struct netxen_recv_crb {
+	u32 crb_rcv_producer[NUM_RCV_DESC_RINGS];
+	u32 crb_sts_consumer[NUM_STS_DESC_RINGS];
+	u32 sw_int_mask[NUM_STS_DESC_RINGS];
+};
 
 /*    Following defines are for the state of the buffers    */
 #define	NETXEN_BUFFER_FREE	0
@@ -1194,6 +1187,18 @@ struct netxen_adapter {
 	const struct firmware *fw;
 };
 
+/* Set promiscuous mode for a GbE interface */
+int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter, u32 mode);
+int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
+		u32 mode);
+/* Generic enable for GbE ports. Will detect the speed of the link. */
+int netxen_niu_gbe_init_port(struct netxen_adapter *adapter, int port);
+int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port);
+
+/* Disable a GbE interface */
+int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter);
+int netxen_niu_disable_xg_port(struct netxen_adapter *adapter);
+
 int netxen_niu_xgbe_enable_phy_interrupts(struct netxen_adapter *adapter);
 int netxen_niu_gbe_enable_phy_interrupts(struct netxen_adapter *adapter);
 int netxen_niu_xgbe_disable_phy_interrupts(struct netxen_adapter *adapter);
diff --git a/drivers/net/netxen/netxen_nic_ctx.c b/drivers/net/netxen/netxen_nic_ctx.c
index 9e04696..3d676fe 100644
--- a/drivers/net/netxen/netxen_nic_ctx.c
+++ b/drivers/net/netxen/netxen_nic_ctx.c
@@ -30,7 +30,6 @@
 
 #include "netxen_nic_hw.h"
 #include "netxen_nic.h"
-#include "netxen_nic_phan_reg.h"
 
 #define NXHAL_VERSION	1
 
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index db66e70..3886135 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -37,7 +37,6 @@
 
 #include "netxen_nic.h"
 #include "netxen_nic_hw.h"
-#include "netxen_nic_phan_reg.h"
 
 struct netxen_nic_stats {
 	char stat_string[ETH_GSTRING_LEN];
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index a732858..c4a4a8b 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -723,9 +723,92 @@ enum {
 #define NETXEN_FW_VERSION_MINOR (NETXEN_CAM_RAM(0x154))
 #define NETXEN_FW_VERSION_SUB	(NETXEN_CAM_RAM(0x158))
 #define NETXEN_ROM_LOCK_ID	(NETXEN_CAM_RAM(0x100))
+#define NETXEN_PHY_LOCK_ID	(NETXEN_CAM_RAM(0x120))
 #define NETXEN_CRB_WIN_LOCK_ID	(NETXEN_CAM_RAM(0x124))
 
-#define NETXEN_PHY_LOCK_ID	(NETXEN_CAM_RAM(0x120))
+#define NIC_CRB_BASE		(NETXEN_CAM_RAM(0x200))
+#define NIC_CRB_BASE_2		(NETXEN_CAM_RAM(0x700))
+#define NETXEN_NIC_REG(X)	(NIC_CRB_BASE+(X))
+#define NETXEN_NIC_REG_2(X)	(NIC_CRB_BASE_2+(X))
+
+#define NX_CDRP_CRB_OFFSET		(NETXEN_NIC_REG(0x18))
+#define NX_ARG1_CRB_OFFSET		(NETXEN_NIC_REG(0x1c))
+#define NX_ARG2_CRB_OFFSET		(NETXEN_NIC_REG(0x20))
+#define NX_ARG3_CRB_OFFSET		(NETXEN_NIC_REG(0x24))
+#define NX_SIGN_CRB_OFFSET		(NETXEN_NIC_REG(0x28))
+
+#define CRB_HOST_DUMMY_BUF_ADDR_HI	(NETXEN_NIC_REG(0x3c))
+#define CRB_HOST_DUMMY_BUF_ADDR_LO	(NETXEN_NIC_REG(0x40))
+
+#define CRB_CMDPEG_STATE		(NETXEN_NIC_REG(0x50))
+#define CRB_RCVPEG_STATE		(NETXEN_NIC_REG(0x13c))
+
+#define CRB_XG_STATE			(NETXEN_NIC_REG(0x94))
+#define CRB_XG_STATE_P3			(NETXEN_NIC_REG(0x98))
+#define CRB_PF_LINK_SPEED_1		(NETXEN_NIC_REG(0xe8))
+#define CRB_PF_LINK_SPEED_2		(NETXEN_NIC_REG(0xec))
+
+#define CRB_MPORT_MODE			(NETXEN_NIC_REG(0xc4))
+#define CRB_DMA_SHIFT			(NETXEN_NIC_REG(0xcc))
+#define CRB_INT_VECTOR			(NETXEN_NIC_REG(0xd4))
+
+#define CRB_CMD_PRODUCER_OFFSET		(NETXEN_NIC_REG(0x08))
+#define CRB_CMD_CONSUMER_OFFSET		(NETXEN_NIC_REG(0x0c))
+#define CRB_CMD_PRODUCER_OFFSET_1   	(NETXEN_NIC_REG(0x1ac))
+#define CRB_CMD_CONSUMER_OFFSET_1	(NETXEN_NIC_REG(0x1b0))
+#define CRB_CMD_PRODUCER_OFFSET_2	(NETXEN_NIC_REG(0x1b8))
+#define CRB_CMD_CONSUMER_OFFSET_2	(NETXEN_NIC_REG(0x1bc))
+#define CRB_CMD_PRODUCER_OFFSET_3	(NETXEN_NIC_REG(0x1d0))
+#define CRB_CMD_CONSUMER_OFFSET_3	(NETXEN_NIC_REG(0x1d4))
+#define CRB_TEMP_STATE			(NETXEN_NIC_REG(0x1b4))
+
+#define CRB_V2P_0			(NETXEN_NIC_REG(0x290))
+#define CRB_V2P(port)			(CRB_V2P_0+((port)*4))
+#define CRB_DRIVER_VERSION		(NETXEN_NIC_REG(0x2a0))
+
+#define CRB_SW_INT_MASK_0		(NETXEN_NIC_REG(0x1d8))
+#define CRB_SW_INT_MASK_1		(NETXEN_NIC_REG(0x1e0))
+#define CRB_SW_INT_MASK_2		(NETXEN_NIC_REG(0x1e4))
+#define CRB_SW_INT_MASK_3		(NETXEN_NIC_REG(0x1e8))
+
+#define CRB_FW_CAPABILITIES_1		(NETXEN_CAM_RAM(0x128))
+#define CRB_MAC_BLOCK_START		(NETXEN_CAM_RAM(0x1c0))
+
+/*
+ * capabilities register, can be used to selectively enable/disable features
+ * for backward compability
+ */
+#define CRB_NIC_CAPABILITIES_HOST	NETXEN_NIC_REG(0x1a8)
+#define CRB_NIC_CAPABILITIES_FW	  	NETXEN_NIC_REG(0x1dc)
+#define CRB_NIC_MSI_MODE_HOST		NETXEN_NIC_REG(0x270)
+#define CRB_NIC_MSI_MODE_FW	  	NETXEN_NIC_REG(0x274)
+
+#define INTR_SCHEME_PERPORT	      	0x1
+#define MSI_MODE_MULTIFUNC	      	0x1
+
+/* used for ethtool tests */
+#define CRB_SCRATCHPAD_TEST	    NETXEN_NIC_REG(0x280)
+
+/*
+ * CrbPortPhanCntrHi/Lo is used to pass the address of HostPhantomIndex address
+ * which can be read by the Phantom host to get producer/consumer indexes from
+ * Phantom/Casper. If it is not HOST_SHARED_MEMORY, then the following
+ * registers will be used for the addresses of the ring's shared memory
+ * on the Phantom.
+ */
+
+#define nx_get_temp_val(x)		((x) >> 16)
+#define nx_get_temp_state(x)		((x) & 0xffff)
+#define nx_encode_temp(val, state)	(((val) << 16) | (state))
+
+/*
+ * Temperature control.
+ */
+enum {
+	NX_TEMP_NORMAL = 0x1,	/* Normal operating range */
+	NX_TEMP_WARN,		/* Sound alert, temperature getting high */
+	NX_TEMP_PANIC		/* Fatal error, hardware has shut down. */
+};
 
 /* Lock IDs for PHY lock */
 #define PHY_LOCK_DRIVER		0x44524956
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 965f783..9138bbc 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -30,7 +30,6 @@
 
 #include "netxen_nic.h"
 #include "netxen_nic_hw.h"
-#include "netxen_nic_phan_reg.h"
 
 #include <net/ip.h>
 
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index d4e8333..fc0638f 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
@@ -31,8 +31,6 @@
 #ifndef __NETXEN_NIC_HW_H_
 #define __NETXEN_NIC_HW_H_
 
-#include "netxen_nic_hdr.h"
-
 /* Hardware memory size of 128 meg */
 #define NETXEN_MEMADDR_MAX (128 * 1024 * 1024)
 
@@ -387,22 +385,6 @@ void netxen_nic_set_link_parameters(struct netxen_adapter *adapter);
 #define netxen_xg_soft_reset(config_word)	\
 		((config_word) |= 1 << 4)
 
-/* Set promiscuous mode for a GbE interface */
-int netxen_niu_set_promiscuous_mode(struct netxen_adapter *adapter,
-				    u32 mode);
-int netxen_niu_xg_set_promiscuous_mode(struct netxen_adapter *adapter,
-				       u32 mode);
-
-/* Generic enable for GbE ports. Will detect the speed of the link. */
-int netxen_niu_gbe_init_port(struct netxen_adapter *adapter, int port);
-
-int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port);
-
-/* Disable a GbE interface */
-int netxen_niu_disable_gbe_port(struct netxen_adapter *adapter);
-
-int netxen_niu_disable_xg_port(struct netxen_adapter *adapter);
-
 typedef struct {
 	unsigned valid;
 	unsigned start_128M;
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index c3609e4..474c568 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -32,7 +32,6 @@
 #include <linux/delay.h>
 #include "netxen_nic.h"
 #include "netxen_nic_hw.h"
-#include "netxen_nic_phan_reg.h"
 
 struct crb_addr_pair {
 	u32 addr;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 794c19b..bd4589f 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -33,7 +33,6 @@
 #include "netxen_nic_hw.h"
 
 #include "netxen_nic.h"
-#include "netxen_nic_phan_reg.h"
 
 #include <linux/dma-mapping.h>
 #include <linux/if_vlan.h>
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
deleted file mode 100644
index b73a62c..0000000
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ /dev/null
@@ -1,178 +0,0 @@
-/*
- * Copyright (C) 2003 - 2009 NetXen, Inc.
- * All rights reserved.
- *
- * This program is free software; you can redistribute it and/or
- * modify it under the terms of the GNU General Public License
- * as published by the Free Software Foundation; either version 2
- * of the License, or (at your option) any later version.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
- * GNU General Public License for more details.
- *
- * You should have received a copy of the GNU General Public License
- * along with this program; if not, write to the Free Software
- * Foundation, Inc., 59 Temple Place - Suite 330, Boston,
- * MA  02111-1307, USA.
- *
- * The full GNU General Public License is included in this distribution
- * in the file called LICENSE.
- *
- * Contact Information:
- *    info@netxen.com
- * NetXen Inc,
- * 18922 Forge Drive
- * Cupertino, CA 95014-0701
- *
- */
-
-#ifndef __NIC_PHAN_REG_H_
-#define __NIC_PHAN_REG_H_
-
-/*
- * CRB Registers or queue message done only at initialization time.
- */
-#define NIC_CRB_BASE               NETXEN_CAM_RAM(0x200)
-#define NETXEN_NIC_REG(X)             (NIC_CRB_BASE+(X))
-#define NIC_CRB_BASE_2             NETXEN_CAM_RAM(0x700)
-#define NETXEN_NIC_REG_2(X)         (NIC_CRB_BASE_2+(X))
-
-#define CRB_PHAN_CNTRL_LO_OFFSET    NETXEN_NIC_REG(0x00)
-#define CRB_PHAN_CNTRL_HI_OFFSET    NETXEN_NIC_REG(0x04)
-#define CRB_CMD_PRODUCER_OFFSET     NETXEN_NIC_REG(0x08)
-#define CRB_CMD_CONSUMER_OFFSET     NETXEN_NIC_REG(0x0c)
-#define CRB_PAUSE_ADDR_LO           NETXEN_NIC_REG(0x10)
-#define CRB_PAUSE_ADDR_HI           NETXEN_NIC_REG(0x14)
-#define NX_CDRP_CRB_OFFSET          NETXEN_NIC_REG(0x18)
-#define NX_ARG1_CRB_OFFSET          NETXEN_NIC_REG(0x1c)
-#define NX_ARG2_CRB_OFFSET          NETXEN_NIC_REG(0x20)
-#define NX_ARG3_CRB_OFFSET          NETXEN_NIC_REG(0x24)
-#define NX_SIGN_CRB_OFFSET          NETXEN_NIC_REG(0x28)
-#define CRB_CMD_INTR_LOOP           NETXEN_NIC_REG(0x20)
-#define CRB_CMD_DMA_LOOP            NETXEN_NIC_REG(0x24)
-#define CRB_RCV_INTR_LOOP           NETXEN_NIC_REG(0x28)
-#define CRB_RCV_DMA_LOOP            NETXEN_NIC_REG(0x2c)
-#define CRB_ENABLE_TX_INTR          NETXEN_NIC_REG(0x30)
-#define CRB_MMAP_ADDR_3             NETXEN_NIC_REG(0x34)
-#define CRB_CMDPEG_CMDRING          NETXEN_NIC_REG(0x38)
-#define CRB_HOST_DUMMY_BUF_ADDR_HI  NETXEN_NIC_REG(0x3c)
-#define CRB_HOST_DUMMY_BUF_ADDR_LO  NETXEN_NIC_REG(0x40)
-#define CRB_MMAP_ADDR_0             NETXEN_NIC_REG(0x44)
-#define CRB_MMAP_ADDR_1             NETXEN_NIC_REG(0x48)
-#define CRB_MMAP_ADDR_2             NETXEN_NIC_REG(0x4c)
-#define CRB_CMDPEG_STATE            NETXEN_NIC_REG(0x50)
-#define CRB_MMAP_SIZE_0             NETXEN_NIC_REG(0x54)
-#define CRB_MMAP_SIZE_1             NETXEN_NIC_REG(0x58)
-#define CRB_MMAP_SIZE_2             NETXEN_NIC_REG(0x5c)
-#define CRB_MMAP_SIZE_3             NETXEN_NIC_REG(0x60)
-#define CRB_GLOBAL_INT_COAL         NETXEN_NIC_REG(0x64)
-#define CRB_INT_COAL_MODE           NETXEN_NIC_REG(0x68)
-#define CRB_MAX_RCV_BUFS            NETXEN_NIC_REG(0x6c)
-#define CRB_TX_INT_THRESHOLD        NETXEN_NIC_REG(0x70)
-#define CRB_RX_PKT_TIMER            NETXEN_NIC_REG(0x74)
-#define CRB_TX_PKT_TIMER            NETXEN_NIC_REG(0x78)
-#define CRB_RX_PKT_CNT              NETXEN_NIC_REG(0x7c)
-#define CRB_RX_TMR_CNT              NETXEN_NIC_REG(0x80)
-#define CRB_RX_LRO_TIMER            NETXEN_NIC_REG(0x84)
-#define CRB_RX_LRO_MID_TIMER        NETXEN_NIC_REG(0x88)
-#define CRB_DMA_MAX_RCV_BUFS        NETXEN_NIC_REG(0x8c)
-#define CRB_MAX_DMA_ENTRIES         NETXEN_NIC_REG(0x90)
-#define CRB_XG_STATE                NETXEN_NIC_REG(0x94) /* XG Link status */
-#define CRB_XG_STATE_P3             NETXEN_NIC_REG(0x98) /* XG PF Link status */
-#define CRB_AGENT_TX_SIZE           NETXEN_NIC_REG(0x9c)
-#define CRB_AGENT_TX_TYPE           NETXEN_NIC_REG(0xa0)
-#define CRB_AGENT_TX_ADDR           NETXEN_NIC_REG(0xa4)
-#define CRB_AGENT_TX_MSS            NETXEN_NIC_REG(0xa8)
-#define CRB_TX_STATE                NETXEN_NIC_REG(0xac)
-#define CRB_TX_COUNT                NETXEN_NIC_REG(0xb0)
-#define CRB_RX_STATE                NETXEN_NIC_REG(0xb4)
-#define CRB_RX_PERF_DEBUG_1         NETXEN_NIC_REG(0xb8)
-#define CRB_RX_LRO_CONTROL          NETXEN_NIC_REG(0xbc)
-#define CRB_RX_LRO_START_NUM        NETXEN_NIC_REG(0xc0)
-#define CRB_MPORT_MODE              NETXEN_NIC_REG(0xc4)
-#define CRB_CMD_RING_SIZE           NETXEN_NIC_REG(0xc8)
-#define CRB_DMA_SHIFT               NETXEN_NIC_REG(0xcc)
-#define CRB_INT_VECTOR              NETXEN_NIC_REG(0xd4)
-#define CRB_CTX_RESET               NETXEN_NIC_REG(0xd8)
-#define CRB_HOST_STS_PROD           NETXEN_NIC_REG(0xdc)
-#define CRB_HOST_STS_CONS           NETXEN_NIC_REG(0xe0)
-#define CRB_PEG_CMD_PROD            NETXEN_NIC_REG(0xe4)
-#define CRB_PF_LINK_SPEED_1         NETXEN_NIC_REG(0xe8)
-#define CRB_PF_LINK_SPEED_2         NETXEN_NIC_REG(0xec)
-#define CRB_HOST_BUFFER_CONS        NETXEN_NIC_REG(0xf0)
-#define CRB_JUMBO_BUFFER_PROD       NETXEN_NIC_REG(0xf4)
-#define CRB_JUMBO_BUFFER_CONS       NETXEN_NIC_REG(0xf8)
-#define CRB_HOST_DUMMY_BUF          NETXEN_NIC_REG(0xfc)
-
-#define CRB_RCVPEG_STATE            NETXEN_NIC_REG(0x13c)
-#define CRB_CMD_PRODUCER_OFFSET_1   NETXEN_NIC_REG(0x1ac)
-#define CRB_CMD_CONSUMER_OFFSET_1   NETXEN_NIC_REG(0x1b0)
-#define CRB_CMD_PRODUCER_OFFSET_2   NETXEN_NIC_REG(0x1b8)
-#define CRB_CMD_CONSUMER_OFFSET_2   NETXEN_NIC_REG(0x1bc)
-#define CRB_CMD_PRODUCER_OFFSET_3   NETXEN_NIC_REG(0x1d0)
-#define CRB_CMD_CONSUMER_OFFSET_3   NETXEN_NIC_REG(0x1d4)
-#define CRB_TEMP_STATE              NETXEN_NIC_REG(0x1b4)
-
-#define CRB_V2P_0		    NETXEN_NIC_REG(0x290)
-#define CRB_V2P_1		    NETXEN_NIC_REG(0x294)
-#define CRB_V2P_2		    NETXEN_NIC_REG(0x298)
-#define CRB_V2P_3		    NETXEN_NIC_REG(0x29c)
-#define CRB_V2P(port)		    (CRB_V2P_0+((port)*4))
-#define CRB_DRIVER_VERSION	   NETXEN_NIC_REG(0x2a0)
-#define CRB_SW_INT_MASK_0	   NETXEN_NIC_REG(0x1d8)
-#define CRB_SW_INT_MASK_1	   NETXEN_NIC_REG(0x1e0)
-#define CRB_SW_INT_MASK_2	   NETXEN_NIC_REG(0x1e4)
-#define CRB_SW_INT_MASK_3	   NETXEN_NIC_REG(0x1e8)
-
-#define CRB_FW_CAPABILITIES_1      NETXEN_CAM_RAM(0x128)
-#define CRB_MAC_BLOCK_START        NETXEN_CAM_RAM(0x1c0)
-
-/*
- * capabilities register, can be used to selectively enable/disable features
- * for backward compability
- */
-#define CRB_NIC_CAPABILITIES_HOST	NETXEN_NIC_REG(0x1a8)
-#define CRB_NIC_CAPABILITIES_FW	  	NETXEN_NIC_REG(0x1dc)
-#define CRB_NIC_MSI_MODE_HOST		NETXEN_NIC_REG(0x270)
-#define CRB_NIC_MSI_MODE_FW	  	NETXEN_NIC_REG(0x274)
-
-#define INTR_SCHEME_PERPORT	      	0x1
-#define MSI_MODE_MULTIFUNC	      	0x1
-
-/* used for ethtool tests */
-#define CRB_SCRATCHPAD_TEST	    NETXEN_NIC_REG(0x280)
-
-/*
- * CrbPortPhanCntrHi/Lo is used to pass the address of HostPhantomIndex address
- * which can be read by the Phantom host to get producer/consumer indexes from
- * Phantom/Casper. If it is not HOST_SHARED_MEMORY, then the following
- * registers will be used for the addresses of the ring's shared memory
- * on the Phantom.
- */
-
-#define nx_get_temp_val(x)		((x) >> 16)
-#define nx_get_temp_state(x)		((x) & 0xffff)
-#define nx_encode_temp(val, state)	(((val) << 16) | (state))
-
-/*
- * CRB registers used by the receive peg logic.
- */
-
-struct netxen_recv_crb {
-	u32 crb_rcv_producer[NUM_RCV_DESC_RINGS];
-	u32 crb_sts_consumer[NUM_STS_DESC_RINGS];
-	u32 sw_int_mask[NUM_STS_DESC_RINGS];
-};
-
-/*
- * Temperature control.
- */
-enum {
-	NX_TEMP_NORMAL = 0x1,	/* Normal operating range */
-	NX_TEMP_WARN,		/* Sound alert, temperature getting high */
-	NX_TEMP_PANIC		/* Fatal error, hardware has shut down. */
-};
-
-#endif				/* __NIC_PHAN_REG_H_ */
-- 
1.6.0.2

