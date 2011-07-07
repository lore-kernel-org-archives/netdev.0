From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 1/5] sky2: force receive checksum when using RSS on
 some hardware (v2)
Date: Thu, 7 Jul 2011 16:40:00 -0700
Message-ID: <20110707164000.6f3f58f4@nehalam.ftrdhcpuser.net>
References: <20110707155056.939223264@vyatta.com>
	<20110707155212.000920741@vyatta.com>
	<CAHXqBF+Ha9XaMDB0x1XBD633mj2b6Jxmg9U_JSokrov90gPA-g@mail.gmail.com>
	<20110707101322.784409eb@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-2?B?TWljaGGzIE1pcm9zs2F3?= <mirqus@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45468 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751356Ab1GGXkC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2011 19:40:02 -0400
In-Reply-To: <20110707101322.784409eb@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found when reviewing the vendor driver. Apparently some chip versions
require receive checksumming to be enabled in order for RSS to work.

Also, if fix_features has to change some settings; put in message
in log in similar manner to netdev_fix_features.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
v2 - enforce the requirement in fix_features rather than set features

--- a/drivers/net/sky2.c	2011-07-07 13:56:03.575420273 -0700
+++ b/drivers/net/sky2.c	2011-07-07 14:03:17.775403938 -0700
@@ -2996,7 +2996,8 @@ static int __devinit sky2_init(struct sk
 		hw->flags = SKY2_HW_GIGABIT
 			| SKY2_HW_NEWER_PHY
 			| SKY2_HW_NEW_LE
-			| SKY2_HW_ADV_POWER_CTL;
+			| SKY2_HW_ADV_POWER_CTL
+			| SKY2_HW_RSS_CHKSUM;
 
 		/* New transmit checksum */
 		if (hw->chip_rev != CHIP_REV_YU_EX_B0)
@@ -3024,7 +3025,7 @@ static int __devinit sky2_init(struct sk
 
 		/* The workaround for status conflicts VLAN tag detection. */
 		if (hw->chip_rev == CHIP_REV_YU_FE2_A0)
-			hw->flags |= SKY2_HW_VLAN_BROKEN;
+			hw->flags |= SKY2_HW_VLAN_BROKEN | SKY2_HW_RSS_CHKSUM;
 		break;
 
 	case CHIP_ID_YUKON_SUPR:
@@ -3033,6 +3034,9 @@ static int __devinit sky2_init(struct sk
 			| SKY2_HW_NEW_LE
 			| SKY2_HW_AUTO_TX_SUM
 			| SKY2_HW_ADV_POWER_CTL;
+
+		if (hw->chip_rev == CHIP_REV_YU_SU_A0)
+			hw->flags |= SKY2_HW_RSS_CHKSUM;
 		break;
 
 	case CHIP_ID_YUKON_UL_2:
@@ -4176,8 +4180,18 @@ static u32 sky2_fix_features(struct net_
 	/* In order to do Jumbo packets on these chips, need to turn off the
 	 * transmit store/forward. Therefore checksum offload won't work.
 	 */
-	if (dev->mtu > ETH_DATA_LEN && hw->chip_id == CHIP_ID_YUKON_EC_U)
+	if (dev->mtu > ETH_DATA_LEN && hw->chip_id == CHIP_ID_YUKON_EC_U) {
+		netdev_warn(dev, "checksum offload not possible with jumbo frames\n");
 		features &= ~(NETIF_F_TSO|NETIF_F_SG|NETIF_F_ALL_CSUM);
+	}
+
+	/* Some hardware requires receive checksum for RSS to work. */
+	if ( (features & NETIF_F_RXHASH) &&
+	     !(features & NETIF_F_RXCSUM) &&
+	     (sky2->hw->flags & SKY2_HW_RSS_CHKSUM)) {
+		netdev_warn(dev, "receive hashing forces receive checksum\n");
+		features |= NETIF_F_RXCSUM;
+	}
 
 	return features;
 }
--- a/drivers/net/sky2.h	2011-07-07 13:56:03.563420272 -0700
+++ b/drivers/net/sky2.h	2011-07-07 13:56:07.719420117 -0700
@@ -2281,6 +2281,7 @@ struct sky2_hw {
 #define SKY2_HW_ADV_POWER_CTL	0x00000080	/* additional PHY power regs */
 #define SKY2_HW_RSS_BROKEN	0x00000100
 #define SKY2_HW_VLAN_BROKEN     0x00000200
+#define SKY2_HW_RSS_CHKSUM	0x00000400	/* RSS requires chksum */
 
 	u8	     	     chip_id;
 	u8		     chip_rev;

