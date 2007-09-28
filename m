From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Fri, 28 Sep 2007 00:21:19 -0400
Message-ID: <20070928042119.GA15161@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:50501 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753330AbXI1EVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2007 00:21:20 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


And an e1000 id patch.

Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/e1000/e1000_ethtool.c |    1 +
 drivers/net/e1000/e1000_hw.c      |    1 +
 drivers/net/e1000/e1000_hw.h      |    1 +
 drivers/net/e1000/e1000_main.c    |    2 +
 drivers/net/sky2.c                |   53 +++++++++++++++++++++++++++----------
 5 files changed, 44 insertions(+), 14 deletions(-)

Auke Kok (1):
      e1000: Add device IDs of blade version of the 82571 quad port

Stephen Hemminger (3):
      sky2: sky2 FE+ receive status workaround
      sky2: FE+ vlan workaround
      sky2: fix transmit state on resume

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 4c3785c..9ecc3ad 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -1726,6 +1726,7 @@ static int e1000_wol_exclusion(struct e1000_adapter *adapter, struct ethtool_wol
 	case E1000_DEV_ID_82571EB_QUAD_COPPER:
 	case E1000_DEV_ID_82571EB_QUAD_FIBER:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE:
+	case E1000_DEV_ID_82571PT_QUAD_COPPER:
 	case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3:
 		/* quad port adapters only support WoL on port A */
 		if (!adapter->quad_port_a) {
diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index ba120f7..8604adb 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -387,6 +387,7 @@ e1000_set_mac_type(struct e1000_hw *hw)
 	case E1000_DEV_ID_82571EB_SERDES_DUAL:
 	case E1000_DEV_ID_82571EB_SERDES_QUAD:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER:
+	case E1000_DEV_ID_82571PT_QUAD_COPPER:
 	case E1000_DEV_ID_82571EB_QUAD_FIBER:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE:
 		hw->mac_type = e1000_82571;
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index fe87146..07f0ea7 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -475,6 +475,7 @@ int32_t e1000_check_phy_reset_block(struct e1000_hw *hw);
 #define E1000_DEV_ID_82571EB_FIBER       0x105F
 #define E1000_DEV_ID_82571EB_SERDES      0x1060
 #define E1000_DEV_ID_82571EB_QUAD_COPPER 0x10A4
+#define E1000_DEV_ID_82571PT_QUAD_COPPER 0x10D5
 #define E1000_DEV_ID_82571EB_QUAD_FIBER  0x10A5
 #define E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE  0x10BC
 #define E1000_DEV_ID_82571EB_SERDES_DUAL 0x10D9
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 4a22595..e7c8951 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -108,6 +108,7 @@ static struct pci_device_id e1000_pci_tbl[] = {
 	INTEL_E1000_ETHERNET_DEVICE(0x10BC),
 	INTEL_E1000_ETHERNET_DEVICE(0x10C4),
 	INTEL_E1000_ETHERNET_DEVICE(0x10C5),
+	INTEL_E1000_ETHERNET_DEVICE(0x10D5),
 	INTEL_E1000_ETHERNET_DEVICE(0x10D9),
 	INTEL_E1000_ETHERNET_DEVICE(0x10DA),
 	/* required last entry */
@@ -1101,6 +1102,7 @@ e1000_probe(struct pci_dev *pdev,
 	case E1000_DEV_ID_82571EB_QUAD_COPPER:
 	case E1000_DEV_ID_82571EB_QUAD_FIBER:
 	case E1000_DEV_ID_82571EB_QUAD_COPPER_LOWPROFILE:
+	case E1000_DEV_ID_82571PT_QUAD_COPPER:
 		/* if quad port adapter, disable WoL on all but port A */
 		if (global_quad_port_a != 0)
 			adapter->eeprom_wol = 0;
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 0792031..162489b 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -910,6 +910,20 @@ static inline struct sky2_tx_le *get_tx_le(struct sky2_port *sky2)
 	return le;
 }
 
+static void tx_init(struct sky2_port *sky2)
+{
+	struct sky2_tx_le *le;
+
+	sky2->tx_prod = sky2->tx_cons = 0;
+	sky2->tx_tcpsum = 0;
+	sky2->tx_last_mss = 0;
+
+	le = get_tx_le(sky2);
+	le->addr = 0;
+	le->opcode = OP_ADDR64 | HW_OWNER;
+	sky2->tx_addr64 = 0;
+}
+
 static inline struct tx_ring_info *tx_le_re(struct sky2_port *sky2,
 					    struct sky2_tx_le *le)
 {
@@ -1320,7 +1334,8 @@ static int sky2_up(struct net_device *dev)
 				GFP_KERNEL);
 	if (!sky2->tx_ring)
 		goto err_out;
-	sky2->tx_prod = sky2->tx_cons = 0;
+
+	tx_init(sky2);
 
 	sky2->rx_le = pci_alloc_consistent(hw->pdev, RX_LE_BYTES,
 					   &sky2->rx_le_map);
@@ -2148,6 +2163,18 @@ static struct sk_buff *sky2_receive(struct net_device *dev,
 	sky2->rx_next = (sky2->rx_next + 1) % sky2->rx_pending;
 	prefetch(sky2->rx_ring + sky2->rx_next);
 
+	if (length < ETH_ZLEN || length > sky2->rx_data_size)
+		goto len_error;
+
+	/* This chip has hardware problems that generates bogus status.
+	 * So do only marginal checking and expect higher level protocols
+	 * to handle crap frames.
+	 */
+	if (sky2->hw->chip_id == CHIP_ID_YUKON_FE_P &&
+	    sky2->hw->chip_rev == CHIP_REV_YU_FE2_A0 &&
+	    length != count)
+		goto okay;
+
 	if (status & GMR_FS_ANY_ERR)
 		goto error;
 
@@ -2156,8 +2183,9 @@ static struct sk_buff *sky2_receive(struct net_device *dev,
 
 	/* if length reported by DMA does not match PHY, packet was truncated */
 	if (length != count)
-		goto len_mismatch;
+		goto len_error;
 
+okay:
 	if (length < copybreak)
 		skb = receive_copy(sky2, re, length);
 	else
@@ -2167,13 +2195,13 @@ resubmit:
 
 	return skb;
 
-len_mismatch:
+len_error:
 	/* Truncation of overlength packets
 	   causes PHY length to not match MAC length */
 	++sky2->net_stats.rx_length_errors;
 	if (netif_msg_rx_err(sky2) && net_ratelimit())
-		pr_info(PFX "%s: rx length mismatch: length %d status %#x\n",
-			dev->name, length, status);
+		pr_info(PFX "%s: rx length error: status %#x length %d\n",
+			dev->name, status, length);
 	goto resubmit;
 
 error:
@@ -3934,13 +3962,6 @@ static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 	sky2->hw = hw;
 	sky2->msg_enable = netif_msg_init(debug, default_msg);
 
-	/* This chip has hardware problems that generates
-	 * bogus PHY receive status so by default shut up the message.
-	 */
-	if (hw->chip_id == CHIP_ID_YUKON_FE_P &&
-	    hw->chip_rev == CHIP_REV_YU_FE2_A0)
-		sky2->msg_enable &= ~NETIF_MSG_RX_ERR;
-
 	/* Auto speed and flow control */
 	sky2->autoneg = AUTONEG_ENABLE;
 	sky2->flow_mode = FC_BOTH;
@@ -3964,8 +3985,12 @@ static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 		dev->features |= NETIF_F_HIGHDMA;
 
 #ifdef SKY2_VLAN_TAG_USED
-	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-	dev->vlan_rx_register = sky2_vlan_rx_register;
+	/* The workaround for FE+ status conflicts with VLAN tag detection. */
+	if (!(sky2->hw->chip_id == CHIP_ID_YUKON_FE_P &&
+	      sky2->hw->chip_rev == CHIP_REV_YU_FE2_A0)) {
+		dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+		dev->vlan_rx_register = sky2_vlan_rx_register;
+	}
 #endif
 
 	/* read the mac address */
