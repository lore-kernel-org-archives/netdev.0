From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Wed, 6 Jan 2010 13:10:44 -0800
Message-ID: <20100106131044.25b4e500@nehalam>
References: <20100105230746.GA6612@del.dom.local>
	<4B43F72C.9090004@majjas.com>
	<20100106072208.GA6711@ff.dom.local>
	<4B44E952.5000804@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48078 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932401Ab0AFVMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 16:12:05 -0500
In-Reply-To: <4B44E952.5000804@majjas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 06 Jan 2010 14:49:38 -0500
Michael Breuer <mbreuer@majjas.com> wrote:

> This patch at first behaved similarly to the previous one - seemed to be 
> running a bit better... until the adapter went down :(
> 
> This is the syslog output at the time the network failed:
> Jan  6 14:11:01 mail kernel: sky2 0000:06:00.0: error interrupt 
> status=0x40000008
> Jan  6 14:11:01 mail kernel: sky2 software interrupt status 0x40000008

Could you go back to baseline sky2 driver.  The display code might be buggy.
These bits indicate an error in the MAC. The interrupt source enabled
is Transmit FIFO underrun.

Looking at how vendor driver handles this.
It looks like the Yukon EC_U chip doesn't really do Jumbo frames correctly.
Maybe not enough internal buffering to ensure that the whole packet
is in the chip.  Of course, none of this is in the chip manual.

Does this help
--------------
--- a/drivers/net/sky2.c	2010-01-06 12:48:43.012318966 -0800
+++ b/drivers/net/sky2.c	2010-01-06 13:05:31.273987255 -0800
@@ -792,33 +792,21 @@ static void sky2_set_tx_stfwd(struct sky
 {
 	struct net_device *dev = hw->dev[port];
 
-	if ( (hw->chip_id == CHIP_ID_YUKON_EX &&
-	      hw->chip_rev != CHIP_REV_YU_EX_A0) ||
-	     hw->chip_id >= CHIP_ID_YUKON_FE_P) {
-		/* Yukon-Extreme B0 and further Extreme devices */
-		/* enable Store & Forward mode for TX */
-
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
+       if ( (hw->chip_id == CHIP_ID_YUKON_EX && hw->chip_rev != CHIP_REV_YU_EX_A0) ||
+	    hw->chip_id >= CHIP_ID_YUKON_FE_P) {
+	       /* Yukon-Extreme B0 and further Extreme devices */
+	       /* enable Store & Forward mode for TX */
+	       sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_STFW_ENA);
+       } else if (dev->mtu > ETH_DATA_LEN) {
+	       /* set Tx GMAC FIFO Almost Empty Threshold */
+	       sky2_write32(hw, SK_REG(port, TX_GMF_AE_THR),
+			    (ECU_JUMBO_WM << 16) | ECU_AE_THR);
+	       /* disable Store & Forward mode for TX */
+	       sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_STFW_DIS);
+       } else {
+	       /* enable Store & Forward mode for TX */
+	       sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_STFW_ENA);
+       }
 }
 
 static void sky2_mac_init(struct sky2_hw *hw, unsigned port)
@@ -2185,11 +2173,16 @@ static int sky2_change_mtu(struct net_de
 	if (new_mtu < ETH_ZLEN || new_mtu > ETH_JUMBO_MTU)
 		return -EINVAL;
 
+	/* MTU > 1500 on yukon FE and FE+ not allowed */
 	if (new_mtu > ETH_DATA_LEN &&
 	    (hw->chip_id == CHIP_ID_YUKON_FE ||
 	     hw->chip_id == CHIP_ID_YUKON_FE_P))
 		return -EINVAL;
 
+	/* TSO on Yukon Ultra and MTU > 1500 not supported */
+	if (new_mtu > ETH_DATA_LEN && hw->chip_id == CHIP_ID_YUKON_EC_U)
+		dev->features &= ~NETIF_F_TSO;
+
 	if (!netif_running(dev)) {
 		dev->mtu = new_mtu;
 		return 0;
@@ -2233,6 +2226,15 @@ static int sky2_change_mtu(struct net_de
 	if (err)
 		dev_close(dev);
 	else {
+		/* WA for dev. #4.209 */
+		if (hw->chip_id == CHIP_ID_YUKON_EC_U &&
+		    hw->chip_rev == CHIP_REV_YU_EC_U_A1) {
+			/* enable/disable Store & Forward mode for TX */
+			sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+				     sky2->speed != SPEED_1000
+				     ? TX_STFW_ENA : TX_STFW_DIS);
+		}
+
 		gma_write16(hw, port, GM_GP_CTRL, ctl);
 
 		netif_wake_queue(dev);
--- a/drivers/net/sky2.h	2010-01-06 12:48:48.632247424 -0800
+++ b/drivers/net/sky2.h	2010-01-06 12:59:57.322078964 -0800
@@ -1901,8 +1901,8 @@ enum {
 	TX_VLAN_TAG_ON	= 1<<25,/* enable  VLAN tagging */
 	TX_VLAN_TAG_OFF	= 1<<24,/* disable VLAN tagging */
 
-	TX_JUMBO_ENA	= 1<<23,/* PCI Jumbo Mode enable (Yukon-EC Ultra) */
-	TX_JUMBO_DIS	= 1<<22,/* PCI Jumbo Mode enable (Yukon-EC Ultra) */
+	TX_PCI_JUM_ENA	= 1<<23,/* Enable  PCI Jumbo Mode (Yukon-EC Ultra) */
+	TX_PCI_JUM_DIS	= 1<<22,/* Disable PCI Jumbo Mode (Yukon-EC Ultra) */
 
 	GMF_WSP_TST_ON	= 1<<18,/* Write Shadow Pointer Test On */
 	GMF_WSP_TST_OFF	= 1<<17,/* Write Shadow Pointer Test Off */

