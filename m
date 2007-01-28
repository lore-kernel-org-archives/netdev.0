From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 2.6.20-rc5 4/4] atl1: incorporate reviewer comments
Date: Sat, 27 Jan 2007 18:13:46 -0600
Message-ID: <20070128001346.GD10269@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, atl1-devel@lists.sourceforge.net,
	romieu@fr.zoreil.com, randy.dunlap@oracle.com, arjan@infradead.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf21aec.mail.bellsouth.net ([205.152.59.69]:36426 "EHLO
	imf21aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932173AbXA1ANu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jan 2007 19:13:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Jay Cliburn <jacliburn@bellsouth.net>

Incorporate reviewer comments from:
Randy Dunlap, http://lkml.org/lkml/2007/1/21/157
Arjan van de Ven, http://lkml.org/lkml/2007/1/22/21
Francois Romieu, http://lkml.org/lkml/2007/1/22/49

Fixup to follow coding standards, remove MII defines already found in 
mii.h, remove unneeded code, make atl1_clear_phy_int() irq safe.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---

diff --git a/drivers/net/atl1/atl1.h b/drivers/net/atl1/atl1.h
index 0b30e1c..cc18016 100644
--- a/drivers/net/atl1/atl1.h
+++ b/drivers/net/atl1/atl1.h
@@ -1,4 +1,4 @@
-/**
+/*
  * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
  * Copyright(c) 2006 Chris Snook <csnook@redhat.com>
  * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
@@ -19,14 +19,13 @@
  * You should have received a copy of the GNU General Public License along with
  * this program; if not, write to the Free Software Foundation, Inc., 59
  * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
- **/
+ */
 
 #ifndef _ATL1_H_
 #define _ATL1_H_
 
 #include <linux/types.h>
 #include <linux/if_vlan.h>
-#include <linux/mii.h>
 
 #include "atl1_hw.h"
 
@@ -37,6 +36,9 @@ int atl1_reset(struct atl1_adapter *adapter);
 s32 atl1_setup_ring_resources(struct atl1_adapter *adapter);
 void atl1_free_ring_resources(struct atl1_adapter *adapter);
 
+extern char atl1_driver_name[];
+extern char atl1_driver_version[];
+
 struct atl1_adapter;
 
 #define ATL1_MAX_INTR		3
@@ -53,17 +55,17 @@ struct atl1_adapter;
 #define ATL1_TPD_DESC(R, i)	ATL1_GET_DESC(R, i, struct tx_packet_desc)
 #define ATL1_RRD_DESC(R, i)	ATL1_GET_DESC(R, i, struct rx_return_desc)
 
-/**
+/*
  * Some workarounds require millisecond delays and are run during interrupt
  * context.  Most notably, when establishing link, the phy may need tweaking
  * but cannot process phy register reads/writes faster than millisecond
  * intervals...and we establish link due to a "link status change" interrupt.
- **/
+ */
 
-/**
+/*
  * wrapper around a pointer to a socket buffer,
  * so a DMA handle can be stored along with the buffer
- **/
+ */
 struct atl1_buffer {
 	struct sk_buff *skb;
 	u16 length;
@@ -78,7 +80,6 @@ struct atl1_tpd_ring {
 	dma_addr_t dma;		/* physical adress of the descriptor ring */
 	u16 size;		/* length of descriptor ring in bytes */
 	u16 count;		/* number of descriptors in the ring */
-
 	u16 hw_idx;		/* hardware index */
 	atomic_t next_to_clean;
 	atomic_t next_to_use;
@@ -105,12 +106,9 @@ struct atl1_rrd_ring {
 };
 
 struct atl1_ring_header {
-	/* pointer to the descriptor ring memory */
-	void *desc;
-	/* physical adress of the descriptor ring */
-	dma_addr_t dma;
-	/* length of descriptor ring in bytes */
-	unsigned int size;
+	void *desc;		/* pointer to the descriptor ring memory */
+	dma_addr_t dma;		/* physical adress of the descriptor ring */
+	unsigned int size;	/* length of descriptor ring in bytes */
 };
 
 struct atl1_cmb {
@@ -143,16 +141,15 @@ struct atl1_sft_stats {
 	u64 tx_window_errors;
 	u64 tx_carrier_errors;
 
-	u64 tx_pause;		/* The number of Pause packet transmitted. */
-	u64 excecol;		/* The number of transmit packets aborted due to excessive collisions. */
-	u64 deffer;		/* The number of packets transmitted that is deferred. */
-	u64 scc;		/* The number of packets subsequently transmitted successfully with a single prior collision. */
-	u64 mcc;		/* The number of packets subsequently transmitted successfully with multiple prior collisions. */
-	u64 latecol;		/* The number of packets transmitted with late collisions. */
-	u64 tx_underun;		/* The number of transmit packets aborted due to transmit FIFO underrun, or TRD FIFO underrun */
-	u64 tx_trunc;		/* The number of transmit packets truncated due to size exceeding MTU, regardless if it is truncated by Selene or not.
-				 * (The name is not really reflects the meaning in this case here.) */
-	u64 rx_pause;		/* The number of Pause packet received. */
+	u64 tx_pause;		/* num Pause packet transmitted. */
+	u64 excecol;		/* num tx packets aborted due to excessive collisions. */
+	u64 deffer;		/* num deferred tx packets */
+	u64 scc;		/* num packets subsequently transmitted successfully w/ single prior collision. */
+	u64 mcc;		/* num packets subsequently transmitted successfully w/ multiple prior collisions. */
+	u64 latecol;		/* num tx packets  w/ late collisions. */
+	u64 tx_underun;		/* num tx packets aborted due to transmit FIFO underrun, or TRD FIFO underrun */
+	u64 tx_trunc;		/* num tx packets truncated due to size exceeding MTU, regardless whether truncated by Selene or not. (The name doesn't really reflect the meaning in this case.) */
+	u64 rx_pause;		/* num Pause packets received. */
 	u64 rx_rrd_ov;
 	u64 rx_trunc;
 };
@@ -164,29 +161,27 @@ struct atl1_sft_stats {
 struct atl1_hw {
 	u8 __iomem *hw_addr;
 	struct atl1_adapter *back;
-
 	enum atl1_dma_order dma_ord;
 	enum atl1_dma_rcb rcb_value;
 	enum atl1_dma_req_block dmar_block;
 	enum atl1_dma_req_block dmaw_block;
-
 	u8 preamble_len;
-	u8 max_retry;		/* Retransmission maximum , afterwards the packet will be discarded. */
-	u8 jam_ipg;		/* IPG to start JAM for collision based flow control in half-duplex mode. In unit of 8-bit time. */
-	u8 ipgt;		/* Desired back to back inter-packet gap. The default is 96-bit time. */
-	u8 min_ifg;		/* Minimum number of IFG to enforce in between RX frames. Frame gap below such IFP is dropped. */
+	u8 max_retry;		/* Retransmission maximum, after which the packet will be discarded */
+	u8 jam_ipg;		/* IPG to start JAM for collision based flow control in half-duplex mode. In units of 8-bit time */
+	u8 ipgt;		/* Desired back to back inter-packet gap. The default is 96-bit time */
+	u8 min_ifg;		/* Minimum number of IFG to enforce in between RX frames. Frame gap below such IFP is dropped */
 	u8 ipgr1;		/* 64bit Carrier-Sense window */
 	u8 ipgr2;		/* 96-bit IPG window */
-
-	u8 tpd_burst;		/* Number of TPD to prefetch in a cache-aligned burst. Each TPD is 16-byte in length. */
-	u8 rfd_burst;		/* Number of RFD to prefetch in a cache-aligned burst. Each RFD is 12-byte in length. */
+	u8 tpd_burst;		/* Number of TPD to prefetch in cache-aligned burst. Each TPD is 16 bytes long */
+	u8 rfd_burst;		/* Number of RFD to prefetch in cache-aligned burst. Each RFD is 12 bytes long */
 	u8 rfd_fetch_gap;
-	u8 rrd_burst;		/* Threshold of number of RRDs can be retired in a burst. Each RRD is 16-byte in length. */
+	u8 rrd_burst;		/* Threshold number of RRDs that can be retired in a burst. Each RRD is 16 bytes long */
 	u8 tpd_fetch_th;
 	u8 tpd_fetch_gap;
 	u16 tx_jumbo_task_th;
-	u16 txf_burst;		/* Number of data byte to read in a cache-aligned burst. Each SRAM entry is 8-byte in length. */
-	u16 rx_jumbo_th;	/* Jumbo packet size for non-VLAN packet. VLAN packet should add 4-byte */
+	u16 txf_burst;		/* Number of data bytes to read in a cache-aligned burst. Each SRAM entry is
+				   8 bytes long */
+	u16 rx_jumbo_th;	/* Jumbo packet size for non-VLAN packet. VLAN packets should add 4 bytes */
 	u16 rx_jumbo_lkah;
 	u16 rrd_ret_timer;	/* RRD retirement timer. Decrement by 1 after every 512ns passes. */
 	u16 lcol;		/* Collision Window */
@@ -220,8 +215,8 @@ struct atl1_hw {
 	u8 flash_vendor;
 
 	u8 dma_fairness;
-	u8 mac_addr[NODE_ADDRESS_SIZE];
-	u8 perm_mac_addr[NODE_ADDRESS_SIZE];
+	u8 mac_addr[ETH_ALEN];
+	u8 perm_mac_addr[ETH_ALEN];
 
 	/* bool phy_preamble_sup; */
 	bool phy_configured;
diff --git a/drivers/net/atl1/atl1_ethtool.c b/drivers/net/atl1/atl1_ethtool.c
index 4c6e505..8ce4d06 100644
--- a/drivers/net/atl1/atl1_ethtool.c
+++ b/drivers/net/atl1/atl1_ethtool.c
@@ -1,4 +1,4 @@
-/**
+/*
  * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
  * Copyright(c) 2006 Chris Snook <csnook@redhat.com>
  * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
@@ -19,7 +19,7 @@
  * You should have received a copy of the GNU General Public License along with
  * this program; if not, write to the Free Software Foundation, Inc., 59
  * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
- **/
+ */
 
 #include <linux/types.h>
 #include <linux/pci.h>
@@ -30,10 +30,6 @@
 
 #include "atl1.h"
 
-
-extern char atl1_driver_name[];
-extern char atl1_driver_version[];
-
 struct atl1_stats {
 	char stat_string[ETH_GSTRING_LEN];
 	int sizeof_stat;
@@ -97,7 +93,8 @@ static int atl1_get_stats_count(struct net_device *netdev)
 	return ARRAY_SIZE(atl1_gstrings_stats);
 }
 
-static int atl1_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+static int atl1_get_settings(struct net_device *netdev, 
+				struct ethtool_cmd *ecmd)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 	struct atl1_hw *hw = &adapter->hw;
@@ -120,9 +117,9 @@ static int atl1_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd
 			     ADVERTISED_100baseT_Half |
 			     ADVERTISED_100baseT_Full |
 			     ADVERTISED_1000baseT_Full);
-		} else {
-			ecmd->advertising |= (ADVERTISED_1000baseT_Full);
 		}
+		else
+			ecmd->advertising |= (ADVERTISED_1000baseT_Full);
 	}
 	ecmd->port = PORT_TP;
 	ecmd->phy_address = 0;
@@ -141,16 +138,16 @@ static int atl1_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd
 		ecmd->duplex = -1;
 	}
 	if (hw->media_type == MEDIA_TYPE_AUTO_SENSOR ||
-	    hw->media_type == MEDIA_TYPE_1000M_FULL) {
+	    hw->media_type == MEDIA_TYPE_1000M_FULL)
 		ecmd->autoneg = AUTONEG_ENABLE;
-	} else {
+	else
 		ecmd->autoneg = AUTONEG_DISABLE;
-	}
 	
 	return 0;
 }
 
-static int atl1_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
+static int atl1_set_settings(struct net_device *netdev, 
+				struct ethtool_cmd *ecmd)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 	struct atl1_hw *hw = &adapter->hw;
@@ -159,14 +156,14 @@ static int atl1_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd
 	u16 old_media_type = hw->media_type;
 
 	if (netif_running(adapter->netdev)) {
-		printk(KERN_DEBUG "%s: ethtool shutting down link adapter\n", 
+		printk(KERN_DEBUG "%s: ethtool shutting down adapter\n", 
 			atl1_driver_name);
 		atl1_down(adapter);
 	}
 
-	if (ecmd->autoneg == AUTONEG_ENABLE) {
+	if (ecmd->autoneg == AUTONEG_ENABLE)
 		hw->media_type = MEDIA_TYPE_AUTO_SENSOR;
-	} else {
+	else {
 		if (ecmd->speed == SPEED_1000) {
 			if (ecmd->duplex != DUPLEX_FULL) {
 				printk(KERN_WARNING
@@ -179,15 +176,13 @@ static int atl1_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd
 		} else if (ecmd->speed == SPEED_100) {
 			if (ecmd->duplex == DUPLEX_FULL) {
 				hw->media_type = MEDIA_TYPE_100M_FULL;
-			} else {
+			} else 
 				hw->media_type = MEDIA_TYPE_100M_HALF;
-			}
 		} else {
-			if (ecmd->duplex == DUPLEX_FULL) {
+			if (ecmd->duplex == DUPLEX_FULL)
 				hw->media_type = MEDIA_TYPE_10M_FULL;
-			} else {
+			else
 				hw->media_type = MEDIA_TYPE_10M_HALF;
-			}
 		}
 	}
 	switch (hw->media_type) {
@@ -217,9 +212,9 @@ static int atl1_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd
 		goto exit_sset;
 	}
 	if (hw->media_type == MEDIA_TYPE_AUTO_SENSOR ||
-	    hw->media_type == MEDIA_TYPE_1000M_FULL) {
+	    hw->media_type == MEDIA_TYPE_1000M_FULL)
 		phy_data = MII_CR_RESET | MII_CR_AUTO_NEG_EN;
-	} else {
+	else {
 		switch (hw->media_type) {
 		case MEDIA_TYPE_100M_FULL:
 			phy_data =
@@ -240,15 +235,15 @@ static int atl1_set_settings(struct net_device *netdev, struct ethtool_cmd *ecmd
 	}
 	atl1_write_phy_reg(hw, MII_BMCR, phy_data);
 exit_sset:
-	if (ret_val) {
+	if (ret_val)
 		hw->media_type = old_media_type;
-	}
+	
 	if (netif_running(adapter->netdev)) {
-		printk(KERN_DEBUG "%s: ethtool starting link adapter\n", 
+		printk(KERN_DEBUG "%s: ethtool starting adapter\n", 
 			atl1_driver_name);
 		atl1_up(adapter);
 	} else if (!ret_val) {
-		printk(KERN_DEBUG "%s: ethtool resetting link adapter\n", 
+		printk(KERN_DEBUG "%s: ethtool resetting adapter\n", 
 			atl1_driver_name);
 		atl1_reset(adapter);
 	}
@@ -260,11 +255,13 @@ static void atl1_get_drvinfo(struct net_device *netdev,
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 
-	strncpy(drvinfo->driver, atl1_driver_name, 32);
-	strncpy(drvinfo->version, atl1_driver_version, 32);
-	strncpy(drvinfo->fw_version, "N/A", 32);
-	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
-	drvinfo->eedump_len = 48;
+	strncpy(drvinfo->driver, atl1_driver_name, sizeof(drvinfo->driver));
+	strncpy(drvinfo->version, atl1_driver_version, 
+		sizeof(drvinfo->version));
+	strncpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
+	strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 
+		sizeof(drvinfo->bus_info));
+	drvinfo->eedump_len = ATL1_EEDUMP_LEN;
 }
 
 static void atl1_get_wol(struct net_device *netdev,
@@ -361,7 +358,8 @@ static u32 atl1_get_rx_csum(struct net_device *netdev)
 	return 1;	
 }
 
-static void atl1_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
+static void atl1_get_strings(struct net_device *netdev, u32 stringset, 
+				u8 *data)
 {
 	u8 *p = data;
 	int i;
diff --git a/drivers/net/atl1/atl1_hw.c b/drivers/net/atl1/atl1_hw.c
index 4062abd..a5e92e7 100644
--- a/drivers/net/atl1/atl1_hw.c
+++ b/drivers/net/atl1/atl1_hw.c
@@ -1,4 +1,4 @@
-/**
+/*
  * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
  * Copyright(c) 2006 Chris Snook <csnook@redhat.com>
  * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
@@ -19,7 +19,7 @@
  * You should have received a copy of the GNU General Public License along with
  * this program; if not, write to the Free Software Foundation, Inc., 59
  * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
- **/
+ */
 
 #include <linux/types.h>
 #include <linux/pci.h>
@@ -28,36 +28,34 @@
 #include <linux/etherdevice.h>
 #include <linux/crc32.h>
 #include <asm/byteorder.h>
-#include "atl1.h"
 
+#include "atl1.h"
 
-extern char atl1_driver_name[];
-
-/**
+/*
  * Reset the transmit and receive units; mask and clear all interrupts.
  * hw - Struct containing variables accessed by shared code
  * return : ATL1_SUCCESS  or  idle status (if error)
- **/
-s32 atl1_reset_hw(struct atl1_hw * hw)
+ */
+s32 atl1_reset_hw(struct atl1_hw *hw)
 {
 	u32 icr;
 	int i;
 
-	/** 
+	/* 
 	 * Clear Interrupt mask to stop board from generating
 	 * interrupts & Clear any pending interrupt events 
-	 **/
-	/**
+	 */
+	/*
 	 * iowrite32(0, hw->hw_addr + REG_IMR);
 	 * iowrite32(0xffffffff, hw->hw_addr + REG_ISR);
-	 **/
+	 */
 
-	/**
+	/*
 	 * Issue Soft Reset to the MAC.  This will reset the chip's
 	 * transmit, receive, DMA.  It will not effect
 	 * the current PCI configuration.  The global reset bit is self-
 	 * clearing, and should clear within a microsecond.
-	 **/
+	 */
 	iowrite32(MASTER_CTRL_SOFT_RST, hw->hw_addr + REG_MASTER_CTRL);
 	ioread32(hw->hw_addr + REG_MASTER_CTRL);
 
@@ -83,11 +81,11 @@ s32 atl1_reset_hw(struct atl1_hw * hw)
 	return ATL1_SUCCESS;
 }
 
-/** function about EEPROM
+/* function about EEPROM
  *
  * check_eeprom_exist
  * return 0 if eeprom exist
- **/
+ */
 static int atl1_check_eeprom_exist(struct atl1_hw *hw)
 {
 	u32 value;
@@ -101,7 +99,7 @@ static int atl1_check_eeprom_exist(struct atl1_hw *hw)
 	return ((value & 0xFF00) == 0x6C00) ? 0 : 1;
 }
 
-static bool atl1_read_eeprom(struct atl1_hw *hw, u32 offset, u32 * p_value)
+static bool atl1_read_eeprom(struct atl1_hw *hw, u32 offset, u32 *p_value)
 {
 	int i;
 	u32 control;
@@ -127,12 +125,12 @@ static bool atl1_read_eeprom(struct atl1_hw *hw, u32 offset, u32 * p_value)
 	return false;		/* timeout */
 }
 
-/**
+/*
  * Reads the value from a PHY register
  * hw - Struct containing variables accessed by shared code
  * reg_addr - address of the PHY register to read
- **/
-s32 atl1_read_phy_reg(struct atl1_hw * hw, u16 reg_addr, u16 * phy_data)
+ */
+s32 atl1_read_phy_reg(struct atl1_hw *hw, u16 reg_addr, u16 *phy_data)
 {
 	u32 val;
 	int i;
@@ -146,9 +144,8 @@ s32 atl1_read_phy_reg(struct atl1_hw * hw, u16 reg_addr, u16 * phy_data)
 	for (i = 0; i < MDIO_WAIT_TIMES; i++) {
 		udelay(2);
 		val = ioread32(hw->hw_addr + REG_MDIO_CTRL);
-		if (!(val & (MDIO_START | MDIO_BUSY))) {
+		if (!(val & (MDIO_START | MDIO_BUSY)))
 			break;
-		}
 	}
 	if (!(val & (MDIO_START | MDIO_BUSY))) {
 		*phy_data = (u16) val;
@@ -163,7 +160,7 @@ s32 atl1_read_phy_reg(struct atl1_hw * hw, u16 reg_addr, u16 * phy_data)
 #define CUSTOM_SPI_CS_HOLD	2
 #define CUSTOM_SPI_CS_HI	3
 
-static bool atl1_spi_read(struct atl1_hw *hw, u32 addr, u32 * buf)
+static bool atl1_spi_read(struct atl1_hw *hw, u32 addr, u32 *buf)
 {
 	int i;
 	u32 value;
@@ -205,16 +202,16 @@ static bool atl1_spi_read(struct atl1_hw *hw, u32 addr, u32 * buf)
 	return true;
 }
 
-/**
+/*
  * get_permanent_address
  * return 0 if get valid mac address, 
- **/
+ */
 int atl1_get_permanent_address(struct atl1_hw *hw)
 {
 	u32 addr[2];
 	u32 i, control;
 	u16 reg;
-	u8 eth_addr[NODE_ADDRESS_SIZE];
+	u8 eth_addr[ETH_ALEN];
 	bool key_valid;
 
 	if (is_valid_ether_addr(hw->perm_mac_addr))
@@ -233,32 +230,29 @@ int atl1_get_permanent_address(struct atl1_hw *hw)
 				if (key_valid) {
 					if (reg == REG_MAC_STA_ADDR)
 						addr[0] = control;
-					else if (reg == (REG_MAC_STA_ADDR + 4)) {
+					else if (reg == (REG_MAC_STA_ADDR + 4))
 						addr[1] = control;
-					}
 					key_valid = false;
 				} else if ((control & 0xff) == 0x5A) {
 					key_valid = true;
 					reg = (u16) (control >> 16);
-				} else {
+				} else
 					break;	/* assume data end while encount an invalid KEYWORD */
-				}
-			} else {
+			} else
 				break;	/* read error */
-			}
 			i += 4;
 		}
 
-/**
+/*
  * The following 2 lines are the Attansic originals.  Saving for posterity.
  *		*(u32 *) & eth_addr[2] = LONGSWAP(addr[0]);
  *		*(u16 *) & eth_addr[0] = SHORTSWAP(*(u16 *) & addr[1]);
- **/
+ */
 		*(u32 *) & eth_addr[2] = swab32(addr[0]);
 		*(u16 *) & eth_addr[0] = swab16(*(u16 *) & addr[1]);
 
 		if (is_valid_ether_addr(eth_addr)) {
-			memcpy(hw->perm_mac_addr, eth_addr, NODE_ADDRESS_SIZE);
+			memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
 			return 0;
 		}
 		return 1;
@@ -274,53 +268,50 @@ int atl1_get_permanent_address(struct atl1_hw *hw)
 			if (key_valid) {
 				if (reg == REG_MAC_STA_ADDR)
 					addr[0] = control;
-				else if (reg == (REG_MAC_STA_ADDR + 4)) {
+				else if (reg == (REG_MAC_STA_ADDR + 4))
 					addr[1] = control;
-				}
 				key_valid = false;
 			} else if ((control & 0xff) == 0x5A) {
 				key_valid = true;
 				reg = (u16) (control >> 16);
-			} else {
+			} else
 				break;	/* data end */
-			}
-		} else {
+		} else
 			break;	/* read error */
-		}
 		i += 4;
 	}
 
-/**
+/*
  * The following 2 lines are the Attansic originals.  Saving for posterity.
  *	*(u32 *) & eth_addr[2] = LONGSWAP(addr[0]);
  *	*(u16 *) & eth_addr[0] = SHORTSWAP(*(u16 *) & addr[1]);
- **/
+ */
 	*(u32 *) & eth_addr[2] = swab32(addr[0]);
 	*(u16 *) & eth_addr[0] = swab16(*(u16 *) & addr[1]);
 	if (is_valid_ether_addr(eth_addr)) {
-		memcpy(hw->perm_mac_addr, eth_addr, NODE_ADDRESS_SIZE);
+		memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
 		return 0;
 	}
 	return 1;
 }
 
-/**
+/*
  * Reads the adapter's MAC address from the EEPROM 
  * hw - Struct containing variables accessed by shared code
- **/
-s32 atl1_read_mac_addr(struct atl1_hw * hw)
+ */
+s32 atl1_read_mac_addr(struct atl1_hw *hw)
 {
 	u16 i;
 
 	if (atl1_get_permanent_address(hw))
 		random_ether_addr(hw->perm_mac_addr);
 
-	for (i = 0; i < NODE_ADDRESS_SIZE; i++)
+	for (i = 0; i < ETH_ALEN; i++)
 		hw->mac_addr[i] = hw->perm_mac_addr[i];
 	return ATL1_SUCCESS;
 }
 
-/**
+/*
  * Hashes an address to determine its location in the multicast table
  * hw - Struct containing variables accessed by shared code
  * mc_addr - the multicast address to hash
@@ -331,8 +322,8 @@ s32 atl1_read_mac_addr(struct atl1_hw * hw)
  *      hash calcu processing :
  *          1. calcu 32bit CRC for multicast address
  *          2. reverse crc with MSB to LSB
- **/
-u32 atl1_hash_mc_addr(struct atl1_hw * hw, u8 * mc_addr)
+ */
+u32 atl1_hash_mc_addr(struct atl1_hw *hw, u8 *mc_addr)
 {
 	u32 crc32, value = 0;
 	int i;
@@ -345,17 +336,17 @@ u32 atl1_hash_mc_addr(struct atl1_hw * hw, u8 * mc_addr)
 	return value;
 }
 
-/**
+/*
  * Sets the bit in the multicast table corresponding to the hash value.
  * hw - Struct containing variables accessed by shared code
  * hash_value - Multicast address hash value
- **/
+ */
 void atl1_hash_set(struct atl1_hw *hw, u32 hash_value)
 {
 	u32 hash_bit, hash_reg;
 	u32 mta;
 
-	/**
+	/*
 	 * The HASH Table  is a register array of 2 32-bit registers.
 	 * It is treated like an array of 64 bits.  We want to set
 	 * bit BitArray[hash_value]. So we figure out what register
@@ -363,7 +354,7 @@ void atl1_hash_set(struct atl1_hw *hw, u32 hash_value)
 	 * back the new value.  The register is determined by the
 	 * upper 7 bits of the hash value and the bit within that
 	 * register are determined by the lower 5 bits of the value.
-	 **/
+	 */
 	hash_reg = (hash_value >> 31) & 0x1;
 	hash_bit = (hash_value >> 26) & 0x1F;
 	mta = ioread32((hw + REG_RX_HASH_TABLE) + (hash_reg << 2));
@@ -371,12 +362,12 @@ void atl1_hash_set(struct atl1_hw *hw, u32 hash_value)
 	iowrite32(mta, (hw->hw_addr + REG_RX_HASH_TABLE) + (hash_reg << 2));
 }
 
-/**
+/*
  * Writes a value to a PHY register
  * hw - Struct containing variables accessed by shared code
  * reg_addr - address of the PHY register to write
  * data - data to write to the PHY
- **/
+ */
 s32 atl1_write_phy_reg(struct atl1_hw *hw, u32 reg_addr, u16 phy_data)
 {
 	int i;
@@ -402,12 +393,12 @@ s32 atl1_write_phy_reg(struct atl1_hw *hw, u32 reg_addr, u16 phy_data)
 	return ATL1_ERR_PHY;
 }
 
-/**
+/*
  * Make L001's PHY out of Power Saving State (bug)
  * hw - Struct containing variables accessed by shared code
  * when power on, L001's PHY always on Power saving State
  * (Gigabit Link forbidden)
- **/
+ */
 static s32 atl1_phy_leave_power_saving(struct atl1_hw *hw)
 {
 	s32 ret;
@@ -417,10 +408,10 @@ static s32 atl1_phy_leave_power_saving(struct atl1_hw *hw)
 	return atl1_write_phy_reg(hw, 30, 0);
 }
 
-/**
+/*
  *TODO: do something or get rid of this
- **/
-s32 atl1_phy_enter_power_saving(struct atl1_hw * hw)
+ */
+s32 atl1_phy_enter_power_saving(struct atl1_hw *hw)
 {
 /*    s32 ret_val;
  *    u16 phy_data;
@@ -434,21 +425,21 @@ s32 atl1_phy_enter_power_saving(struct atl1_hw * hw)
 	return ATL1_SUCCESS;
 }
 
-/**
+/*
  * Resets the PHY and make all config validate
  * hw - Struct containing variables accessed by shared code
  *
  * Sets bit 15 and 12 of the MII Control regiser (for F001 bug)
- **/
+ */
 static s32 atl1_phy_reset(struct atl1_hw *hw)
 {
 	s32 ret_val;
 	u16 phy_data;
 
 	if (hw->media_type == MEDIA_TYPE_AUTO_SENSOR ||
-	    hw->media_type == MEDIA_TYPE_1000M_FULL) {
+	    hw->media_type == MEDIA_TYPE_1000M_FULL)
 		phy_data = MII_CR_RESET | MII_CR_AUTO_NEG_EN;
-	} else {
+	else {
 		switch (hw->media_type) {
 		case MEDIA_TYPE_100M_FULL:
 			phy_data =
@@ -472,9 +463,7 @@ static s32 atl1_phy_reset(struct atl1_hw *hw)
 	if (ret_val) {
 		u32 val;
 		int i;
-		/**************************************
-		 * pcie serdes link may be down !
-		 **************************************/
+		/* pcie serdes link may be down! */
 		printk(KERN_DEBUG "%s: autoneg caused pcie phy link down\n", 
 			atl1_driver_name);
 
@@ -495,11 +484,11 @@ static s32 atl1_phy_reset(struct atl1_hw *hw)
 	return ATL1_SUCCESS;
 }
 
-/**
+/*
  * Configures PHY autoneg and flow control advertisement settings
  * hw - Struct containing variables accessed by shared code
- **/
-s32 atl1_phy_setup_autoneg_adv(struct atl1_hw * hw)
+ */
+s32 atl1_phy_setup_autoneg_adv(struct atl1_hw *hw)
 {
 	s32 ret_val;
 	s16 mii_autoneg_adv_reg;
@@ -511,18 +500,18 @@ s32 atl1_phy_setup_autoneg_adv(struct atl1_hw * hw)
 	/* Read the MII 1000Base-T Control Register (Address 9). */
 	mii_1000t_ctrl_reg = MII_AT001_CR_1000T_DEFAULT_CAP_MASK;
 
-	/**
+	/*
 	 * First we clear all the 10/100 mb speed bits in the Auto-Neg
 	 * Advertisement Register (Address 4) and the 1000 mb speed bits in
 	 * the  1000Base-T Control Register (Address 9).
-	 **/
+	 */
 	mii_autoneg_adv_reg &= ~MII_AR_SPEED_MASK;
 	mii_1000t_ctrl_reg &= ~MII_AT001_CR_1000T_SPEED_MASK;
 
-	/**
+	/*
 	 * Need to parse media_type  and set up
 	 * the appropriate PHY registers.
-	 **/
+	 */
 	switch (hw->media_type) {
 	case MEDIA_TYPE_AUTO_SENSOR:
 		mii_autoneg_adv_reg |= (MII_AR_10T_HD_CAPS |
@@ -570,22 +559,22 @@ s32 atl1_phy_setup_autoneg_adv(struct atl1_hw * hw)
 	return ATL1_SUCCESS;
 }
 
-/**
+/*
  * Configures link settings.
  * hw - Struct containing variables accessed by shared code
  * Assumes the hardware has previously been reset and the
  * transmitter and receiver are not enabled.
- **/
+ */
 static s32 atl1_setup_link(struct atl1_hw *hw)
 {
 	s32 ret_val;
 
-	/**
+	/*
 	 * Options:
 	 *  PHY will advertise value(s) parsed from
 	 *  autoneg_advertised and fc
 	 *  no matter what autoneg is , We will not wait link result.
-	 **/
+	 */
 	ret_val = atl1_phy_setup_autoneg_adv(hw);
 	if (ret_val) {
 		printk(KERN_DEBUG "%s: error setting up autonegotiation\n", 
@@ -595,7 +584,8 @@ static s32 atl1_setup_link(struct atl1_hw *hw)
 	/* SW.Reset , En-Auto-Neg if needed */
 	ret_val = atl1_phy_reset(hw);
 	if (ret_val) {
-		printk(KERN_DEBUG "%s: error resetting the phy\n", atl1_driver_name);
+		printk(KERN_DEBUG "%s: error resetting the phy\n", 
+			atl1_driver_name);
 		return ret_val;
 	}
 	hw->phy_configured = true;
@@ -633,14 +623,14 @@ static void atl1_init_flash_opcode(struct atl1_hw *hw)
 		hw->hw_addr + REG_SPI_FLASH_OP_READ);
 }
 
-/**
+/*
  * Performs basic configuration of the adapter.
  * hw - Struct containing variables accessed by shared code
  * Assumes that the controller has previously been reset and is in a
  * post-reset uninitialized state. Initializes multicast table, 
  * and  Calls routines to setup link
  * Leaves the transmit and receive units disabled and uninitialized.
- **/
+ */
 s32 atl1_init_hw(struct atl1_hw *hw)
 {
 	u32 ret_val = 0;
@@ -667,13 +657,13 @@ s32 atl1_init_hw(struct atl1_hw *hw)
 	return ret_val;
 }
 
-/**
+/*
  * Detects the current speed and duplex settings of the hardware.
  * hw - Struct containing variables accessed by shared code
  * speed - Speed of the connection
  * duplex - Duplex setting of the connection
- **/
-s32 atl1_get_speed_and_duplex(struct atl1_hw * hw, u16 * speed, u16 * duplex)
+ */
+s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed, u16 *duplex)
 {
 	s32 ret_val;
 	u16 phy_data;
@@ -713,11 +703,11 @@ s32 atl1_get_speed_and_duplex(struct atl1_hw * hw, u16 * speed, u16 * duplex)
 void atl1_set_mac_addr(struct atl1_hw *hw)
 {
 	u32 value;
-	/**
+	/*
 	 * 00-0B-6A-F6-00-DC
 	 * 0:  6AF600DC   1: 000B
 	 * low dword
-	 **/
+	 */
 	value = (((u32) hw->mac_addr[2]) << 24) |
 	    (((u32) hw->mac_addr[3]) << 16) |
 	    (((u32) hw->mac_addr[4]) << 8) | (((u32) hw->mac_addr[5]));
diff --git a/drivers/net/atl1/atl1_hw.h b/drivers/net/atl1/atl1_hw.h
index 0450b77..41f3ca7 100644
--- a/drivers/net/atl1/atl1_hw.h
+++ b/drivers/net/atl1/atl1_hw.h
@@ -1,4 +1,4 @@
-/**
+/*
  * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
  * Copyright(c) 2006 Chris Snook <csnook@redhat.com>
  * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
@@ -23,25 +23,28 @@
  * There are a lot of defines in here that are unused and/or have cryptic 
  * names.  Please leave them alone, as they're the closest thing we have 
  * to a spec from Attansic at present. *ahem* -- CHS
- **/
+ */
 
 #ifndef _ATL1_HW_H_
 #define _ATL1_HW_H_
 
+#include <linux/types.h>
+#include <linux/mii.h>
+
 struct atl1_adapter;
 struct atl1_hw;
 
 /* function prototypes needed by multiple files */
 s32 atl1_phy_setup_autoneg_adv(struct atl1_hw *hw);
 s32 atl1_write_phy_reg(struct atl1_hw *hw, u32 reg_addr, u16 phy_data);
-s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 * speed, u16 * duplex);
+s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed, u16 *duplex);
 s32 atl1_read_mac_addr(struct atl1_hw *hw);
 s32 atl1_init_hw(struct atl1_hw *hw);
-s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 * speed, u16 * duplex);
+s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed, u16 *duplex);
 s32 atl1_set_speed_and_duplex(struct atl1_hw *hw, u16 speed, u16 duplex);
-u32 atl1_hash_mc_addr(struct atl1_hw *hw, u8 * mc_addr);
+u32 atl1_hash_mc_addr(struct atl1_hw *hw, u8 *mc_addr);
 void atl1_hash_set(struct atl1_hw *hw, u32 hash_value);
-s32 atl1_read_phy_reg(struct atl1_hw *hw, u16 reg_addr, u16 * phy_data);
+s32 atl1_read_phy_reg(struct atl1_hw *hw, u16 reg_addr, u16 *phy_data);
 void atl1_set_mac_addr(struct atl1_hw *hw);
 s32 atl1_phy_enter_power_saving(struct atl1_hw *hw);
 s32 atl1_reset_hw(struct atl1_hw *hw);
@@ -506,29 +509,11 @@ void atl1_check_options(struct atl1_adapter *adapter);
 
 /*  MII definition */
 /* PHY Common Register */
-#define MII_BMCR					0x00
-#define MII_BMSR					0x01
-#define MII_PHYSID1					0x02
-#define MII_PHYSID2					0x03
-#define MII_ADVERTISE					0x04
-#define MII_LPA						0x05
-#define MII_EXPANSION					0x06
 #define MII_AT001_CR					0x09
 #define MII_AT001_SR					0x0A
 #define MII_AT001_ESR					0x0F
 #define MII_AT001_PSCR					0x10
 #define MII_AT001_PSSR					0x11
-#define MII_DCOUNTER					0x12
-#define MII_FCSCOUNTER					0x13
-#define MII_NWAYTEST					0x14
-#define MII_RERRCOUNTER					0x15
-#define MII_SREVISION					0x16
-#define MII_RESV1					0x17
-#define MII_LBRERROR					0x18
-#define MII_PHYADDR					0x19
-#define MII_RESV2					0x1a
-#define MII_TPISTATUS					0x1b
-#define MII_NCONFIG					0x1c
 
 /* PHY Control Register */
 #define MII_CR_SPEED_SELECT_MSB				0x0040	/* bits 6,13: 10=1000, 01=100, 00=10 */
@@ -707,7 +692,8 @@ void atl1_check_options(struct atl1_adapter *adapter);
 
 /* For checksumming , the sum of all words in the EEPROM should equal 0xBABA */
 #define EEPROM_SUM		0xBABA
-#define NODE_ADDRESS_SIZE	6
+
+#define ATL1_EEDUMP_LEN		48
 
 /* Statistics counters collected by the MAC */
 struct stats_msg_block {
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 1045325..0afa9c1 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -1,4 +1,4 @@
-/**
+/*
  * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
  * Copyright(c) 2006 Chris Snook <csnook@redhat.com>
  * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
@@ -48,7 +48,7 @@
  * promiscuous mode
  * interrupt coalescing
  * SMP torture testing
- **/
+ */
 
 #include <linux/types.h>
 #include <linux/netdevice.h>
@@ -74,6 +74,7 @@
 #include <linux/tcp.h>
 #include <linux/compiler.h>
 #include <linux/delay.h>
+#include <linux/mii.h>
 #include <net/checksum.h>
 
 #include <asm/atomic.h>
@@ -82,7 +83,7 @@
 #include "atl1.h"
 
 #define RUN_REALTIME 0
-#define DRIVER_VERSION "2.0.5"
+#define DRIVER_VERSION "2.0.6"
 
 char atl1_driver_name[] = "atl1";
 static const char atl1_driver_string[] = "Attansic L1 Ethernet Network Driver";
@@ -97,9 +98,9 @@ MODULE_VERSION(DRIVER_VERSION);
 
 extern struct ethtool_ops atl1_ethtool_ops;
 
-/**
+/*
  * atl1_pci_tbl - PCI Device ID Table
- **/
+ */
 static const struct pci_device_id atl1_pci_tbl[] = {
 	{PCI_DEVICE(0x1969, 0x1048)},
 	/* required last entry */
@@ -108,14 +109,14 @@ static const struct pci_device_id atl1_pci_tbl[] = {
 
 MODULE_DEVICE_TABLE(pci, atl1_pci_tbl);
 
-/**
+/*
  * atl1_sw_init - Initialize general software structures (struct atl1_adapter)
  * @adapter: board private structure to initialize
  *
  * atl1_sw_init initializes the Adapter private data structure.
  * Fields are initialized based on PCI device information and
  * OS network device settings (MTU size).
- **/
+ */
 static int __devinit atl1_sw_init(struct atl1_adapter *adapter)
 {
 	struct atl1_hw *hw = &adapter->hw;
@@ -124,7 +125,6 @@ static int __devinit atl1_sw_init(struct atl1_adapter *adapter)
 
 	/* PCI config space info */
 	pci_read_config_byte(pdev, PCI_REVISION_ID, &hw->revision_id);
-	pci_read_config_word(pdev, PCI_COMMAND, &hw->pci_cmd_word);
 
 	hw->max_frame_size = netdev->mtu + ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
 	hw->min_frame_size = MINIMUM_ETHERNET_FRAME_SIZE;
@@ -172,13 +172,13 @@ static int __devinit atl1_sw_init(struct atl1_adapter *adapter)
 	return 0;
 }
 
-/**
+/*
  * atl1_setup_mem_resources - allocate Tx / RX descriptor resources 
  * @adapter: board private structure
  *
  * Return 0 on success, negative on failure
- **/
-s32 atl1_setup_ring_resources(struct atl1_adapter * adapter)
+ */
+s32 atl1_setup_ring_resources(struct atl1_adapter *adapter)
 {
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
 	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
@@ -216,21 +216,6 @@ s32 atl1_setup_ring_resources(struct atl1_adapter * adapter)
 		goto err_nomem;
 	}
 
-	if (adapter->pci_using_64) {	
-		/* test whether HIDWORD dma buffer is not cross boundary */
-		if (unlikely(((ring_header->dma & 0xffffffff00000000ULL) >> 32)
-		    != (((ring_header->dma + size) & 0xffffffff00000000ULL) >>
-			32))) {
-			pci_free_consistent(pdev, ring_header->size,
-					    ring_header->desc,
-					    ring_header->dma);
-			printk(KERN_DEBUG 
-				"%s: memory allocated across 32bit boundary\n", 
-				atl1_driver_name);
-			goto err_nomem;
-		}
-	}
-
 	memset(ring_header->desc, 0, ring_header->size);
 
 	/* init TPD ring */
@@ -279,15 +264,14 @@ s32 atl1_setup_ring_resources(struct atl1_adapter * adapter)
 	return ATL1_SUCCESS;
 
 err_nomem:
-	if (tpd_ring->buffer_info)
-		kfree(tpd_ring->buffer_info);
+	kfree(tpd_ring->buffer_info);
 	return -ENOMEM;
 }
 
-/**
+/*
  * atl1_irq_enable - Enable default interrupt generation settings
  * @adapter: board private structure
- **/
+ */
 static void atl1_irq_enable(struct atl1_adapter *adapter)
 {
 	if (likely(!atomic_dec_and_test(&adapter->irq_sem)))
@@ -297,9 +281,11 @@ static void atl1_irq_enable(struct atl1_adapter *adapter)
 static void atl1_clear_phy_int(struct atl1_adapter *adapter)
 {
 	u16 phy_data;
-	spin_lock(&adapter->lock);
+	unsigned long flags;
+
+	spin_lock_irqsave(&adapter->lock, flags);
 	atl1_read_phy_reg(&adapter->hw, 19, &phy_data);
-	spin_unlock(&adapter->lock);
+	spin_unlock_irqrestore(&adapter->lock, flags);
 }
 
 static void atl1_inc_smb(struct atl1_adapter *adapter)
@@ -381,7 +367,7 @@ static void atl1_inc_smb(struct atl1_adapter *adapter)
 }
 
 static void atl1_rx_checksum(struct atl1_adapter *adapter,
-				  	struct rx_return_desc * rrd, 
+				  	struct rx_return_desc *rrd, 
 					struct sk_buff *skb)
 {
 	skb->ip_summed = CHECKSUM_NONE;
@@ -418,10 +404,10 @@ static void atl1_rx_checksum(struct atl1_adapter *adapter,
 	return;
 }
 
-/**
+/*
  * atl1_alloc_rx_buffers - Replace used receive buffers
  * @adapter: address of board private structure
- **/
+ */
 static u16 atl1_alloc_rx_buffers(struct atl1_adapter *adapter)
 {
 	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
@@ -455,11 +441,11 @@ static u16 atl1_alloc_rx_buffers(struct atl1_adapter *adapter)
 			break;
 		}
 
-		/**
+		/*
 		 * Make buffer alignment 2 beyond a 16 byte boundary
 		 * this will result in a 16 byte aligned IP header after
 		 * the 14 byte MAC header is removed 
-		 **/
+		 */
 		skb_reserve(skb, NET_IP_ALIGN);
 		skb->dev = netdev;
 
@@ -486,12 +472,12 @@ next:
 	}
 
 	if (num_alloc) {
-		/**
+		/*
 		 * Force memory writes to complete before letting h/w
 		 * know there are new descriptors to fetch.  (Only
 		 * applicable for weak-ordered memory model archs,
 		 * such as IA-64).
-		 **/
+		 */
 		wmb();
 		atomic_set(&rfd_ring->next_to_use, (int)rfd_next_to_use);
 	}
@@ -714,12 +700,12 @@ static void atl1_check_for_link(struct atl1_adapter *adapter)
 	schedule_work(&adapter->link_chg_task);
 }
 
-/**
+/*
  * atl1_intr - Interrupt Handler
  * @irq: interrupt number
  * @data: pointer to a network interface device structure
  * @pt_regs: CPU registers structure
- **/
+ */
 static irqreturn_t atl1_intr(int irq, void *data)
 {
 	/*struct atl1_adapter *adapter = ((struct net_device *)data)->priv;*/
@@ -738,9 +724,9 @@ static irqreturn_t atl1_intr(int irq, void *data)
 		/* clear CMB interrupt status at once */
 		adapter->cmb.cmb->int_stats = 0;
 
-		if (status & ISR_GPHY) {	/* clear phy status */
+		if (status & ISR_GPHY)	/* clear phy status */
 			atl1_clear_phy_int(adapter);
-		}
+
 		/* clear ISR status, and Enable CMB DMA/Disable Interrupt */
 		iowrite32(status | ISR_DIS_INT, adapter->hw.hw_addr + REG_ISR);
 
@@ -785,11 +771,10 @@ static irqreturn_t atl1_intr(int irq, void *data)
 				ISR_HOST_RRD_OV | ISR_CMB_RX))) {
 			if (status &
 			    (ISR_RXF_OV | ISR_RFD_UNRUN | ISR_RRD_OV |
-			     ISR_HOST_RFD_UNRUN | ISR_HOST_RRD_OV)) {
+			     ISR_HOST_RFD_UNRUN | ISR_HOST_RRD_OV))
 				printk(KERN_INFO
 					"%s: rx exception: status = 0x%x\n",
  					atl1_driver_name, status);
-			}
 			atl1_intr_rx(adapter);
 		}
 
@@ -803,7 +788,7 @@ static irqreturn_t atl1_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
-/**
+/*
  * atl1_set_multi - Multicast and Promiscuous mode set
  * @netdev: network interface device structure
  *
@@ -811,7 +796,7 @@ static irqreturn_t atl1_intr(int irq, void *data)
  * list or the network interface flags are updated.  This routine is
  * responsible for configuring the hardware for proper multicast,
  * promiscuous mode, and all-multi behavior.
- **/
+ */
 static void atl1_set_multi(struct net_device *netdev)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
@@ -822,14 +807,13 @@ static void atl1_set_multi(struct net_device *netdev)
 
 	/* Check for Promiscuous and All Multicast modes */
 	rctl = ioread32(hw->hw_addr + REG_MAC_CTRL);
-	if (netdev->flags & IFF_PROMISC) {
+	if (netdev->flags & IFF_PROMISC)
 		rctl |= MAC_CTRL_PROMIS_EN;
-	} else if (netdev->flags & IFF_ALLMULTI) {
+	else if (netdev->flags & IFF_ALLMULTI) {
 		rctl |= MAC_CTRL_MC_ALL_EN;
 		rctl &= ~MAC_CTRL_PROMIS_EN;
-	} else {
+	} else
 		rctl &= ~(MAC_CTRL_PROMIS_EN | MAC_CTRL_MC_ALL_EN);
-	}
 
 	iowrite32(rctl, hw->hw_addr + REG_MAC_CTRL);
 
@@ -1045,12 +1029,12 @@ static void set_flow_ctrl_new(struct atl1_hw *hw)
 	iowrite32(value, hw->hw_addr + REG_RXQ_RRD_PAUSE_THRESH);
 }
 
-/**
+/*
  * atl1_configure - Configure Transmit&Receive Unit after Reset
  * @adapter: board private structure
  *
  * Configure the Tx /Rx unit of the MAC after a reset.
- **/
+ */
 static u32 atl1_configure(struct atl1_adapter *adapter)
 {
 	struct atl1_hw *hw = &adapter->hw;
@@ -1206,25 +1190,26 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
 	iowrite32(value, hw->hw_addr + REG_CSMB_CTRL);
 
 	value = ioread32(adapter->hw.hw_addr + REG_ISR);
-	if (unlikely((value & ISR_PHY_LINKDOWN) != 0)) {
+	if (unlikely((value & ISR_PHY_LINKDOWN) != 0))
 		value = 1;	/* config failed */
-	} else {
+	else
 		value = 0;
-	}
+
 	/* clear all interrupt status */
 	iowrite32(0x3fffffff, adapter->hw.hw_addr + REG_ISR);
 	iowrite32(0, adapter->hw.hw_addr + REG_ISR);
 	return value;
 }
 
-/**
+/*
  * atl1_irq_disable - Mask off interrupt generation on the NIC
  * @adapter: board private structure
- **/
+ */
 void atl1_irq_disable(struct atl1_adapter *adapter)
 {
 	atomic_inc(&adapter->irq_sem);
 	iowrite32(0, adapter->hw.hw_addr + REG_IMR);
+	ioread32(adapter->hw.hw_addr + REG_IMR);
 	synchronize_irq(adapter->pdev->irq);
 }
 
@@ -1255,14 +1240,14 @@ static void atl1_vlan_rx_register(struct net_device *netdev,
 	spin_unlock_irqrestore(&adapter->lock, flags);
 }
 
-/** FIXME: justify or remove -- CHS */
+/* FIXME: justify or remove -- CHS */
 static void atl1_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
 {
 	/* We don't do Vlan filtering */
 	return;
 }
 
-/** FIXME: this looks wrong too -- CHS */
+/* FIXME: this looks wrong too -- CHS */
 static void atl1_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
@@ -1301,7 +1286,7 @@ static u16 tpd_avail(struct atl1_tpd_ring *tpd_ring)
 }
 
 static int atl1_tso(struct atl1_adapter *adapter, struct sk_buff *skb,
-			 struct tso_param * tso)
+			 struct tso_param *tso)
 {
 	/* We enter this function holding a spinlock. */
 	u8 ipofst;
@@ -1341,7 +1326,7 @@ static int atl1_tso(struct atl1_adapter *adapter, struct sk_buff *skb,
 }
 
 static int atl1_tx_csum(struct atl1_adapter *adapter, struct sk_buff *skb,
-			struct csum_param * csum)
+			struct csum_param *csum)
 {
 	u8 css, cso;
 
@@ -1470,7 +1455,7 @@ static void atl1_tx_map(struct atl1_adapter *adapter,
 }
 
 static void atl1_tx_queue(struct atl1_adapter *adapter, int count,
-			       union tpd_descr * descr)
+			       union tpd_descr *descr)
 {
 	/* We enter this function holding a spinlock. */
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
@@ -1503,12 +1488,12 @@ static void atl1_tx_queue(struct atl1_adapter *adapter, int count,
 		if (++tpd_next_to_use == tpd_ring->count)
 			tpd_next_to_use = 0;
 	}
-	/**
+	/*
 	 * Force memory writes to complete before letting h/w
 	 * know there are new descriptors to fetch.  (Only
 	 * applicable for weak-ordered memory model archs,
 	 * such as IA-64).
-	 **/
+	 */
 	wmb();
 
 	atomic_set(&tpd_ring->next_to_use, (int)tpd_next_to_use);
@@ -1648,23 +1633,23 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	return NETDEV_TX_OK;
 }
 
-/**
+/*
  * atl1_get_stats - Get System Network Statistics
  * @netdev: network interface device structure
  *
  * Returns the address of the device statistics structure.
  * The statistics are actually updated from the timer callback.
- **/
+ */
 static struct net_device_stats *atl1_get_stats(struct net_device *netdev)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 	return &adapter->net_stats;
 }
 
-/**
+/*
  * atl1_clean_rx_ring - Free RFD Buffers
  * @adapter: board private structure
- **/
+ */
 static void atl1_clean_rx_ring(struct atl1_adapter *adapter)
 {
 	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
@@ -1703,10 +1688,10 @@ static void atl1_clean_rx_ring(struct atl1_adapter *adapter)
 	atomic_set(&rrd_ring->next_to_clean, 0);
 }
 
-/**
+/*
  * atl1_clean_tx_ring - Free Tx Buffers
  * @adapter: board private structure
- **/
+ */
 static void atl1_clean_tx_ring(struct atl1_adapter *adapter)
 {
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
@@ -1743,12 +1728,12 @@ static void atl1_clean_tx_ring(struct atl1_adapter *adapter)
 	atomic_set(&tpd_ring->next_to_clean, 0);
 }
 
-/**
+/*
  * atl1_free_ring_resources - Free Tx / RX descriptor Resources
  * @adapter: board private structure
  *
  * Free all transmit software resources
- **/
+ */
 void atl1_free_ring_resources(struct atl1_adapter *adapter)
 {
 	struct pci_dev *pdev = adapter->pdev;
@@ -1796,7 +1781,8 @@ s32 atl1_up(struct atl1_adapter *adapter)
 
 	err = pci_enable_msi(adapter->pdev);
 	if (err) {
-		dev_info(&adapter->pdev->dev, "Unable to enable MSI: %d\n", err);
+		dev_info(&adapter->pdev->dev,
+			"Unable to enable MSI: %d\n", err);
 		irq_flags |= IRQF_SHARED;
 	}
 	
@@ -1845,13 +1831,13 @@ void atl1_down(struct atl1_adapter *adapter)
 	atl1_clean_rx_ring(adapter);
 }
 
-/**
+/*
  * atl1_change_mtu - Change the Maximum Transfer Unit
  * @netdev: network interface device structure
  * @new_mtu: new value for maximum frame size
  *
  * Returns 0 on success, negative on failure
- **/
+ */
 static int atl1_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
@@ -1860,7 +1846,8 @@ static int atl1_change_mtu(struct net_device *netdev, int new_mtu)
 
 	if ((max_frame < MINIMUM_ETHERNET_FRAME_SIZE) ||
 	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		printk(KERN_WARNING "%s: invalid MTU setting\n", atl1_driver_name);
+		printk(KERN_WARNING "%s: invalid MTU setting\n", 
+			atl1_driver_name);
 		return -EINVAL;
 	}
 
@@ -1878,13 +1865,13 @@ static int atl1_change_mtu(struct net_device *netdev, int new_mtu)
 	return 0;
 }
 
-/**
+/*
  * atl1_set_mac - Change the Ethernet Address of the NIC
  * @netdev: network interface device structure
  * @p: pointer to an address structure
  *
  * Returns 0 on success, negative on failure
- **/
+ */
 static int atl1_set_mac(struct net_device *netdev, void *p)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
@@ -1903,10 +1890,10 @@ static int atl1_set_mac(struct net_device *netdev, void *p)
 	return 0;
 }
 
-/**
+/*
  * atl1_watchdog - Timer Call-back
  * @data: pointer to netdev cast into an unsigned long
- **/
+ */
 static void atl1_watchdog(unsigned long data)
 {
 	struct atl1_adapter *adapter = (struct atl1_adapter *)data;
@@ -1932,12 +1919,12 @@ static void mdio_write(struct net_device *netdev, int phy_id, int reg_num, int v
 	atl1_write_phy_reg(&adapter->hw, reg_num, val);
 }
  
-/**
+/*
  * atl1_mii_ioctl -
  * @netdev:
  * @ifreq:
  * @cmd:
- **/
+ */
 static int atl1_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
@@ -1954,12 +1941,12 @@ static int atl1_mii_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	return retval;
 }
 
-/**
+/*
  * atl1_ioctl -
  * @netdev:
  * @ifreq:
  * @cmd:
- **/
+ */
 static int atl1_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
 	switch (cmd) {
@@ -1972,10 +1959,10 @@ static int atl1_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	}
 }
 
-/**
+/*
  * atl1_tx_timeout - Respond to a Tx Hang
  * @netdev: network interface device structure
- **/
+ */
 static void atl1_tx_timeout(struct net_device *netdev)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
@@ -1983,10 +1970,10 @@ static void atl1_tx_timeout(struct net_device *netdev)
 	schedule_work(&adapter->tx_timeout_task);
 }
 
-/**
+/*
  * atl1_phy_config - Timer Call-back
  * @data: pointer to netdev cast into an unsigned long
- **/
+ */
 static void atl1_phy_config(unsigned long data)
 {
 	struct atl1_adapter *adapter = (struct atl1_adapter *)data;
@@ -2011,7 +1998,7 @@ int atl1_reset(struct atl1_adapter *adapter)
 	return atl1_init_hw(&adapter->hw);
 }
 
-/**
+/*
  * atl1_open - Called when a network interface is made active
  * @netdev: network interface device structure
  *
@@ -2022,7 +2009,7 @@ int atl1_reset(struct atl1_adapter *adapter)
  * for transmit and receive operations are allocated, the interrupt
  * handler is registered with the OS, the watchdog timer is started,
  * and the stack is notified that the interface is ready.
- **/
+ */
 static int atl1_open(struct net_device *netdev)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
@@ -2044,7 +2031,7 @@ err_up:
 	return err;
 }
 
-/**
+/*
  * atl1_close - Disables a network interface
  * @netdev: network interface device structure
  *
@@ -2054,7 +2041,7 @@ err_up:
  * by the OS.  The hardware is still under the drivers control, but
  * needs to be disabled.  A global MAC reset is issued to stop the
  * hardware, and all transmit and receive resources are freed.
- **/
+ */
 static int atl1_close(struct net_device *netdev)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
@@ -2063,7 +2050,7 @@ static int atl1_close(struct net_device *netdev)
 	return 0;
 }
 
-/**
+/*
  * If TPD Buffer size equal to 0, PCIE DMAR_TO_INT
  * will assert. We do soft reset <0x1400=1> according 
  * with the SPEC. BUT, it seemes that PCIE or DMA 
@@ -2082,9 +2069,9 @@ static void atl1_tx_timeout_task(struct work_struct *work)
 	netif_device_attach(netdev);
 }
 
-/**
+/*
  * atl1_link_chg_task - deal with link change event Out of interrupt context
- **/
+ */
 static void atl1_link_chg_task(struct work_struct *work)
 {
 	struct atl1_adapter *adapter = 
@@ -2096,9 +2083,9 @@ static void atl1_link_chg_task(struct work_struct *work)
 	spin_unlock_irqrestore(&adapter->lock, flags);
 }
 
-/**
+/*
  * atl1_pcie_patch - Patch for PCIE module
- **/
+ */
 static void atl1_pcie_patch(struct atl1_adapter *adapter)
 {
 	u32 value;
@@ -2110,7 +2097,7 @@ static void atl1_pcie_patch(struct atl1_adapter *adapter)
 	iowrite32(value, adapter->hw.hw_addr + 0x1008);
 }
 
-/**
+/*
  * When ACPI resume on some VIA MotherBoard, the Interrupt Disable bit/0x400
  * on PCI Command register is disable.
  * The function enable this bit.
@@ -2126,7 +2113,7 @@ static void atl1_via_workaround(struct atl1_adapter *adapter)
 	iowrite32(value, adapter->hw.hw_addr + PCI_COMMAND);
 }
 
-/**
+/*
  * atl1_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in atl1_pci_tbl
@@ -2136,7 +2123,7 @@ static void atl1_via_workaround(struct atl1_adapter *adapter)
  * atl1_probe initializes an adapter identified by a pci_dev structure.
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
- **/
+ */
 static int __devinit atl1_probe(struct pci_dev *pdev,
 			      const struct pci_device_id *ent)
 {
@@ -2162,13 +2149,15 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 		pci_using_64 = false;
 	}
 	/* Mark all PCI regions associated with PCI device 
-	 * pdev as being reserved by owner atl1_driver_name */
+	 * pdev as being reserved by owner atl1_driver_name
+	 */
 	err = pci_request_regions(pdev, atl1_driver_name);
 	if (err)
 		goto err_request_regions;
 
 	/* Enables bus-mastering on the device and calls 
-	 * pcibios_set_master to do the needed arch specific settings */
+	 * pcibios_set_master to do the needed arch specific settings
+	 */
 	pci_set_master(pdev);
 
 	netdev = alloc_etherdev(sizeof(struct atl1_adapter));
@@ -2222,39 +2211,38 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 
 	/* setup the private structure */
 	err = atl1_sw_init(adapter);
-	if (err) {
+	if (err)
 		goto err_common;
-	}
 
 	netdev->features = NETIF_F_HW_CSUM;
 	netdev->features |= NETIF_F_SG;
 	netdev->features |= (NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX);
 
-	/**
+	/*
 	 * FIXME - Until tso performance gets fixed, disable the feature. 
 	 * Enable it with ethtool -K if desired.
-	 **/
+	 */
 	/* netdev->features |= NETIF_F_TSO; */
 
-	if (pci_using_64) {
+	if (pci_using_64)
 		netdev->features |= NETIF_F_HIGHDMA;
-	}
+
 	netdev->features |= NETIF_F_LLTX;
 
-	/**
+	/*
 	 * patch for some L1 of old version,
 	 * the final version of L1 may not need these
 	 * patches 
-	 **/
+	 */
 	/* atl1_pcie_patch(adapter); */
 
 	/* really reset GPHY core */
 	iowrite16(0, adapter->hw.hw_addr + REG_GPHY_ENABLE);
 
-	/** 
+	/* 
 	 * reset the controller to
 	 * put the device in a known good starting state
-	 **/
+	 */
 	if (atl1_reset_hw(&adapter->hw)) {
 		err = -EIO;
 		goto err_common;
@@ -2299,9 +2287,8 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	INIT_WORK(&adapter->pcie_dma_to_rst_task, atl1_tx_timeout_task);
 
 	err = register_netdev(netdev);
-	if (err) {
+	if (err)
 		goto err_common;
-	}
 
 	cards_found++;
 	atl1_via_workaround(adapter);
@@ -2319,7 +2306,7 @@ err_request_regions:
 	return err;
 }
 
-/**
+/*
  * atl1_remove - Device Removal Routine
  * @pdev: PCI device information struct
  *
@@ -2327,7 +2314,7 @@ err_request_regions:
  * that it should release a PCI device.  The could be caused by a
  * Hot-Plug event, or because the driver is going to be removed from
  * memory.
- **/
+ */
 static void __devexit atl1_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
@@ -2455,23 +2442,23 @@ static struct pci_driver atl1_driver = {
 	.resume = atl1_resume
 };
 
-/**
+/*
  * atl1_exit_module - Driver Exit Cleanup Routine
  *
  * atl1_exit_module is called just before the driver is removed
  * from memory.
- **/
+ */
 static void __exit atl1_exit_module(void)
 {
 	pci_unregister_driver(&atl1_driver);
 }
 
-/**
+/*
  * atl1_init_module - Driver Registration Routine
  *
  * atl1_init_module is the first routine called when the driver is
  * loaded. All it does is register with the PCI subsystem.
- **/
+ */
 static int __init atl1_init_module(void)
 {
 	int ret;
diff --git a/drivers/net/atl1/atl1_param.c b/drivers/net/atl1/atl1_param.c
index caa2d83..d9aabfa 100644
--- a/drivers/net/atl1/atl1_param.c
+++ b/drivers/net/atl1/atl1_param.c
@@ -1,4 +1,4 @@
-/**
+/*
  * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
  * Copyright(c) 2006 Chris Snook <csnook@redhat.com>
  * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
@@ -19,19 +19,17 @@
  * You should have received a copy of the GNU General Public License along with
  * this program; if not, write to the Free Software Foundation, Inc., 59
  * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
- **/
+ */
 
 #include <linux/types.h>
 #include <linux/pci.h>
 #include <linux/moduleparam.h>
 #include "atl1.h"
 
-extern char atl1_driver_name[];
-
-/**
+/*
  * This is the only thing that needs to be changed to adjust the
  * maximum number of ports that the driver can manage.
- **/
+ */
 #define ATL1_MAX_NIC 4
 
 #define OPTION_UNSET    -1
@@ -40,19 +38,19 @@ extern char atl1_driver_name[];
 
 #define ATL1_PARAM_INIT { [0 ... ATL1_MAX_NIC] = OPTION_UNSET }
 
-/**
+/*
  * Interrupt Moderate Timer in units of 2 us
  *
  * Valid Range: 10-65535
  *
  * Default Value: 100 (200us)
- **/
+ */
 static int __devinitdata int_mod_timer[ATL1_MAX_NIC+1] = ATL1_PARAM_INIT;
 static int num_int_mod_timer = 0;
 module_param_array_named(int_mod_timer, int_mod_timer, int, &num_int_mod_timer, 0);
 MODULE_PARM_DESC(int_mod_timer, "Interrupt moderator timer");
 
-/**
+/*
  * flash_vendor
  *
  * Valid Range: 0-2
@@ -62,7 +60,7 @@ MODULE_PARM_DESC(int_mod_timer, "Interrupt moderator timer");
  * 2 - ST
  *
  * Default Value: 0
- **/
+ */
 static int __devinitdata flash_vendor[ATL1_MAX_NIC+1] = ATL1_PARAM_INIT;
 static int num_flash_vendor = 0;
 module_param_array_named(flash_vendor, flash_vendor, int, &num_flash_vendor, 0);
@@ -149,7 +147,7 @@ static int __devinit atl1_validate_option(int *value, struct atl1_option *opt)
 	return -1;
 }
 
-/**
+/*
  * atl1_check_options - Range Checking for Command Line Parameters
  * @adapter: board private structure
  *
@@ -157,7 +155,7 @@ static int __devinit atl1_validate_option(int *value, struct atl1_option *opt)
  * input.  If an invalid value is given, or if no user specified
  * value exists, a default value is used.  The final value is stored
  * in a variable in the adapter structure.
- **/
+ */
 void __devinit atl1_check_options(struct atl1_adapter *adapter)
 {
 	int bd = adapter->bd_number;
@@ -182,9 +180,8 @@ void __devinit atl1_check_options(struct atl1_adapter *adapter)
 			val = int_mod_timer[bd];
 			atl1_validate_option(&val, &opt);
 			adapter->imt = (u16) val;
-		} else {
+		} else
 			adapter->imt = (u16) (opt.def);
-		}
 	}
 
 	{			/* Flash Vendor */
@@ -203,8 +200,7 @@ void __devinit atl1_check_options(struct atl1_adapter *adapter)
 			val = flash_vendor[bd];
 			atl1_validate_option(&val, &opt);
 			adapter->hw.flash_vendor = (u8) val;
-		} else {
+		} else
 			adapter->hw.flash_vendor = (u8) (opt.def);
-		}
 	}
 }
