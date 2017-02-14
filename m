From: Manuel Lauss <manuel.lauss@gmail.com>
Subject: [PATCH] net: au1000_eth: get rid of unnecessary header.
Date: Tue, 14 Feb 2017 13:11:07 +0100
Message-ID: <20170214121107.249094-1-manuel.lauss@gmail.com>
Cc: Manuel Lauss <manuel.lauss@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35825 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753051AbdBNMLQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 07:11:16 -0500
Received: by mail-wr0-f194.google.com with SMTP id o16so27411741wra.2
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 04:11:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

au1000_eth.h isn't used anywhere else, merge its contents into
main driver file.

Signed-off-by: Manuel Lauss <manuel.lauss@gmail.com>
---
 drivers/net/ethernet/amd/au1000_eth.c | 113 +++++++++++++++++++++++++++--
 drivers/net/ethernet/amd/au1000_eth.h | 132 ----------------------------------
 2 files changed, 108 insertions(+), 137 deletions(-)
 delete mode 100644 drivers/net/ethernet/amd/au1000_eth.h

diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index a3c90fe5de00..e32bc27f3522 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -63,11 +63,8 @@
 #include <asm/irq.h>
 #include <asm/processor.h>
 
-#include <au1000.h>
-#include <au1xxx_eth.h>
-#include <prom.h>
-
-#include "au1000_eth.h"
+#include <asm/mach-au1x00/au1000.h>
+#include <asm/mach-au1x00/au1xxx_eth.h>
 
 #ifdef AU1000_ETH_DEBUG
 static int au1000_debug = 5;
@@ -207,6 +204,20 @@ MODULE_VERSION(DRV_VERSION);
 #define MAC_RX_BUFF3_STATUS	0x30
 #define MAC_RX_BUFF3_ADDR	0x34
 
+
+#define MAC_IOSIZE 0x10000
+#define NUM_RX_DMA 4       /* Au1x00 has 4 rx hardware descriptors */
+#define NUM_TX_DMA 4       /* Au1x00 has 4 tx hardware descriptors */
+
+#define NUM_RX_BUFFS 4
+#define NUM_TX_BUFFS 4
+#define MAX_BUF_SIZE 2048
+
+#define ETH_TX_TIMEOUT (HZ/4)
+#define MAC_MIN_PKT_SIZE 64
+
+#define MULTICAST_FILTER_LIMIT 64
+
 /*
  * Theory of operation
  *
@@ -223,6 +234,98 @@ MODULE_VERSION(DRV_VERSION);
  */
 
 /*
+ * Data Buffer Descriptor. Data buffers must be aligned on 32 byte
+ * boundary for both, receive and transmit.
+ */
+struct db_dest {
+	struct db_dest *pnext;
+	u32 *vaddr;
+	dma_addr_t dma_addr;
+};
+
+/*
+ * The transmit and receive descriptors are memory
+ * mapped registers.
+ */
+struct tx_dma {
+	u32 status;
+	u32 buff_stat;
+	u32 len;
+	u32 pad;
+};
+
+struct rx_dma {
+	u32 status;
+	u32 buff_stat;
+	u32 pad[2];
+};
+
+
+/*
+ * MAC control registers, memory mapped.
+ */
+struct mac_reg {
+	u32 control;
+	u32 mac_addr_high;
+	u32 mac_addr_low;
+	u32 multi_hash_high;
+	u32 multi_hash_low;
+	u32 mii_control;
+	u32 mii_data;
+	u32 flow_control;
+	u32 vlan1_tag;
+	u32 vlan2_tag;
+};
+
+
+struct au1000_private {
+	struct db_dest *pDBfree;
+	struct db_dest db[NUM_RX_BUFFS+NUM_TX_BUFFS];
+	struct rx_dma *rx_dma_ring[NUM_RX_DMA];
+	struct tx_dma *tx_dma_ring[NUM_TX_DMA];
+	struct db_dest *rx_db_inuse[NUM_RX_DMA];
+	struct db_dest *tx_db_inuse[NUM_TX_DMA];
+	u32 rx_head;
+	u32 tx_head;
+	u32 tx_tail;
+	u32 tx_full;
+
+	int mac_id;
+
+	int mac_enabled;       /* whether MAC is currently enabled and running
+				* (req. for mdio)
+				*/
+
+	int old_link;          /* used by au1000_adjust_link */
+	int old_speed;
+	int old_duplex;
+
+	struct mii_bus *mii_bus;
+
+	/* PHY configuration */
+	int phy_static_config;
+	int phy_search_highest_addr;
+	int phy1_search_mac0;
+
+	int phy_addr;
+	int phy_busid;
+	int phy_irq;
+
+	/* These variables are just for quick access
+	 * to certain regs addresses.
+	 */
+	struct mac_reg *mac;  /* mac registers                      */
+	u32 *enable;     /* address of MAC Enable Register     */
+	void __iomem *macdma;	/* base of MAC DMA port */
+	u32 vaddr;                /* virtual address of rx/tx buffers   */
+	dma_addr_t dma_addr;      /* dma address of rx/tx buffers       */
+
+	spinlock_t lock;       /* Serialise access to device */
+
+	u32 msg_enable;
+};
+
+/*
  * board-specific configurations
  *
  * PHY detection algorithm
diff --git a/drivers/net/ethernet/amd/au1000_eth.h b/drivers/net/ethernet/amd/au1000_eth.h
deleted file mode 100644
index 4c47c2377d74..000000000000
--- a/drivers/net/ethernet/amd/au1000_eth.h
+++ /dev/null
@@ -1,132 +0,0 @@
-/*
- *
- * Alchemy Au1x00 ethernet driver include file
- *
- * Author: Pete Popov <ppopov@mvista.com>
- *
- * Copyright 2001 MontaVista Software Inc.
- *
- * ########################################################################
- *
- *  This program is free software; you can distribute it and/or modify it
- *  under the terms of the GNU General Public License (Version 2) as
- *  published by the Free Software Foundation.
- *
- *  This program is distributed in the hope it will be useful, but WITHOUT
- *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
- *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
- *  for more details.
- *
- *  You should have received a copy of the GNU General Public License along
- *  with this program; if not, see <http://www.gnu.org/licenses/>.
- *
- * ########################################################################
- *
- *
- */
-
-
-#define MAC_IOSIZE 0x10000
-#define NUM_RX_DMA 4       /* Au1x00 has 4 rx hardware descriptors */
-#define NUM_TX_DMA 4       /* Au1x00 has 4 tx hardware descriptors */
-
-#define NUM_RX_BUFFS 4
-#define NUM_TX_BUFFS 4
-#define MAX_BUF_SIZE 2048
-
-#define ETH_TX_TIMEOUT (HZ/4)
-#define MAC_MIN_PKT_SIZE 64
-
-#define MULTICAST_FILTER_LIMIT 64
-
-/*
- * Data Buffer Descriptor. Data buffers must be aligned on 32 byte
- * boundary for both, receive and transmit.
- */
-struct db_dest {
-	struct db_dest *pnext;
-	u32 *vaddr;
-	dma_addr_t dma_addr;
-};
-
-/*
- * The transmit and receive descriptors are memory
- * mapped registers.
- */
-struct tx_dma {
-	u32 status;
-	u32 buff_stat;
-	u32 len;
-	u32 pad;
-};
-
-struct rx_dma {
-	u32 status;
-	u32 buff_stat;
-	u32 pad[2];
-};
-
-
-/*
- * MAC control registers, memory mapped.
- */
-struct mac_reg {
-	u32 control;
-	u32 mac_addr_high;
-	u32 mac_addr_low;
-	u32 multi_hash_high;
-	u32 multi_hash_low;
-	u32 mii_control;
-	u32 mii_data;
-	u32 flow_control;
-	u32 vlan1_tag;
-	u32 vlan2_tag;
-};
-
-
-struct au1000_private {
-	struct db_dest *pDBfree;
-	struct db_dest db[NUM_RX_BUFFS+NUM_TX_BUFFS];
-	struct rx_dma *rx_dma_ring[NUM_RX_DMA];
-	struct tx_dma *tx_dma_ring[NUM_TX_DMA];
-	struct db_dest *rx_db_inuse[NUM_RX_DMA];
-	struct db_dest *tx_db_inuse[NUM_TX_DMA];
-	u32 rx_head;
-	u32 tx_head;
-	u32 tx_tail;
-	u32 tx_full;
-
-	int mac_id;
-
-	int mac_enabled;       /* whether MAC is currently enabled and running
-				* (req. for mdio)
-				*/
-
-	int old_link;          /* used by au1000_adjust_link */
-	int old_speed;
-	int old_duplex;
-
-	struct mii_bus *mii_bus;
-
-	/* PHY configuration */
-	int phy_static_config;
-	int phy_search_highest_addr;
-	int phy1_search_mac0;
-
-	int phy_addr;
-	int phy_busid;
-	int phy_irq;
-
-	/* These variables are just for quick access
-	 * to certain regs addresses.
-	 */
-	struct mac_reg *mac;  /* mac registers                      */
-	u32 *enable;     /* address of MAC Enable Register     */
-	void __iomem *macdma;	/* base of MAC DMA port */
-	u32 vaddr;                /* virtual address of rx/tx buffers   */
-	dma_addr_t dma_addr;      /* dma address of rx/tx buffers       */
-
-	spinlock_t lock;       /* Serialise access to device */
-
-	u32 msg_enable;
-};
-- 
2.11.1
