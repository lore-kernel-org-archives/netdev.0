From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 04/10] sky2: jumbo packet changes
Date: Fri, 12 Feb 2010 08:58:01 -0800
Message-ID: <20100212165937.795430053@vyatta.com>
References: <20100212165757.767062851@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49493 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757372Ab0BLRIA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Feb 2010 12:08:00 -0500
Content-Disposition: inline; filename=sky2-ec-nojumbo.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change how FIFO is programmed in jumbo mode (to match vendor driver).
Mostly cosmetic, the only register change is that the bits 22,23
are not programemd used.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/sky2.c |   97 +++++++++++++++++++++++------------------------------
 drivers/net/sky2.h |    8 ++--
 2 files changed, 47 insertions(+), 58 deletions(-)

--- a/drivers/net/sky2.h	2010-02-11 15:32:59.821544922 -0800
+++ b/drivers/net/sky2.h	2010-02-11 15:33:34.491857721 -0800
@@ -1895,14 +1895,14 @@ enum {
 
 /*	TX_GMF_CTRL_T	32 bit	Tx GMAC FIFO Control/Test */
 enum {
-	TX_STFW_DIS	= 1<<31,/* Disable Store & Forward (Yukon-EC Ultra) */
-	TX_STFW_ENA	= 1<<30,/* Enable  Store & Forward (Yukon-EC Ultra) */
+	TX_STFW_DIS	= 1<<31,/* Disable Store & Forward */
+	TX_STFW_ENA	= 1<<30,/* Enable  Store & Forward */
 
 	TX_VLAN_TAG_ON	= 1<<25,/* enable  VLAN tagging */
 	TX_VLAN_TAG_OFF	= 1<<24,/* disable VLAN tagging */
 
-	TX_JUMBO_ENA	= 1<<23,/* PCI Jumbo Mode enable (Yukon-EC Ultra) */
-	TX_JUMBO_DIS	= 1<<22,/* PCI Jumbo Mode enable (Yukon-EC Ultra) */
+	TX_PCI_JUM_ENA  = 1<<23,/* PCI Jumbo Mode enable */
+	TX_PCI_JUM_DIS  = 1<<22,/* PCI Jumbo Mode enable */
 
 	GMF_WSP_TST_ON	= 1<<18,/* Write Shadow Pointer Test On */
 	GMF_WSP_TST_OFF	= 1<<17,/* Write Shadow Pointer Test Off */
--- a/drivers/net/sky2.c	2010-02-11 15:32:59.831545305 -0800
+++ b/drivers/net/sky2.c	2010-02-11 15:33:34.491857721 -0800
@@ -798,29 +798,15 @@ static void sky2_set_tx_stfwd(struct sky
 	      hw->chip_rev != CHIP_REV_YU_EX_A0) ||
 	     hw->chip_id >= CHIP_ID_YUKON_FE_P) {
 		/* Yukon-Extreme B0 and further Extreme devices */
-		/* enable Store & Forward mode for TX */
+		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_STFW_ENA);
+	} else if (dev->mtu > ETH_DATA_LEN) {
+		/* set Tx GMAC FIFO Almost Empty Threshold */
+		sky2_write32(hw, SK_REG(port, TX_GMF_AE_THR),
+			     (ECU_JUMBO_WM << 16) | ECU_AE_THR);
 
-		if (dev->mtu <= ETH_DATA_LEN)
-			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
-				     TX_JUMBO_DIS | TX_STFW_ENA);
-
-		else
-			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
-				     TX_JUMBO_ENA| TX_STFW_ENA);
-	} else {
-		if (dev->mtu <= ETH_DATA_LEN)
-			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_STFW_ENA);
-		else {
-			/* set Tx GMAC FIFO Almost Empty Threshold */
-			sky2_write32(hw, SK_REG(port, TX_GMF_AE_THR),
-				     (ECU_JUMBO_WM << 16) | ECU_AE_THR);
-
-			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_STFW_DIS);
-
-			/* Can't do offload because of lack of store/forward */
-			dev->features &= ~(NETIF_F_TSO | NETIF_F_SG | NETIF_F_ALL_CSUM);
-		}
-	}
+		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_STFW_DIS);
+	} else
+		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_STFW_ENA);
 }
 
 static void sky2_mac_init(struct sky2_hw *hw, unsigned port)
@@ -2206,14 +2192,20 @@ static int sky2_change_mtu(struct net_de
 	u16 ctl, mode;
 	u32 imask;
 
+	/* MTU size outside the spec */
 	if (new_mtu < ETH_ZLEN || new_mtu > ETH_JUMBO_MTU)
 		return -EINVAL;
 
+	/* MTU > 1500 on yukon FE and FE+ not allowed */
 	if (new_mtu > ETH_DATA_LEN &&
 	    (hw->chip_id == CHIP_ID_YUKON_FE ||
 	     hw->chip_id == CHIP_ID_YUKON_FE_P))
 		return -EINVAL;
 
+	/* TSO, etc on Yukon Ultra and MTU > 1500 not supported */
+	if (new_mtu > ETH_DATA_LEN && hw->chip_id == CHIP_ID_YUKON_EC_U)
+		dev->features &= ~(NETIF_F_TSO|NETIF_F_SG|NETIF_F_ALL_CSUM);
+
 	if (!netif_running(dev)) {
 		dev->mtu = new_mtu;
 		return 0;

-- 

