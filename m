From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 1/5] sky2: force receive checksum when using RSS on some hardware
Date: Thu, 07 Jul 2011 08:50:57 -0700
Message-ID: <20110707155212.000920741@vyatta.com>
References: <20110707155056.939223264@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:56593 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753455Ab1GGQno (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2011 12:43:44 -0400
Content-Disposition: inline; filename=sky2-rxhash-rxcsum.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found when reviewing the vendor driver. Apparently some chip versions
require receive checksumming to be enabled in order for RSS to work.
Rather than silently enabling checksumming which is what the vendor
driver does, return an error to the user instead.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2011-07-07 08:36:10.748003369 -0700
+++ b/drivers/net/sky2.c	2011-07-07 08:36:37.372004595 -0700
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
@@ -4187,6 +4191,11 @@ static int sky2_set_features(struct net_
 	struct sky2_port *sky2 = netdev_priv(dev);
 	u32 changed = dev->features ^ features;
 
+	/* Some hardware requires receive checksum for RSS to work. */
+	if ( (features & (NETIF_F_RXHASH|NETIF_F_RXCSUM)) == NETIF_F_RXHASH &&
+	     (sky2->hw->flags & SKY2_HW_RSS_CHKSUM))
+		return -EINVAL;
+
 	if (changed & NETIF_F_RXCSUM) {
 		u32 on = features & NETIF_F_RXCSUM;
 		sky2_write32(sky2->hw, Q_ADDR(rxqaddr[sky2->port], Q_CSR),
--- a/drivers/net/sky2.h	2011-07-06 21:57:43.155687362 -0700
+++ b/drivers/net/sky2.h	2011-07-07 08:36:37.372004595 -0700
@@ -2281,6 +2281,7 @@ struct sky2_hw {
 #define SKY2_HW_ADV_POWER_CTL	0x00000080	/* additional PHY power regs */
 #define SKY2_HW_RSS_BROKEN	0x00000100
 #define SKY2_HW_VLAN_BROKEN     0x00000200
+#define SKY2_HW_RSS_CHKSUM	0x00000400	/* RSS requires chksum */
 
 	u8	     	     chip_id;
 	u8		     chip_rev;


