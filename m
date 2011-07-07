From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next 2/5] sky2: use correct Inter Packet Gap at 10/100mbit
Date: Thu, 07 Jul 2011 08:50:58 -0700
Message-ID: <20110707155212.086061402@vyatta.com>
References: <20110707155056.939223264@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:56594 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752736Ab1GGQnn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jul 2011 12:43:43 -0400
Content-Disposition: inline; filename=sky2-100mbit-ipg.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is another fix picked out of the vendor driver. The IPG value
in the serial mode register is supposed to be programmed differently
at lower speeds.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2011-07-07 08:36:37.372004595 -0700
+++ b/drivers/net/sky2.c	2011-07-07 08:36:42.420004801 -0700
@@ -714,6 +714,20 @@ static void sky2_phy_power_down(struct s
 	sky2_write8(hw, B2_TST_CTRL1, TST_CFG_WRITE_OFF);
 }
 
+/* configure IPG according to used link speed */
+static void sky2_set_ipg(struct sky2_port *sky2)
+{
+	u16 reg;
+
+	reg = gma_read16(sky2->hw, sky2->port, GM_SERIAL_MODE);
+	reg &= ~GM_SMOD_IPG_MSK;
+	if (sky2->speed > SPEED_100)
+		reg |= IPG_DATA_VAL(IPG_DATA_DEF_1000);
+	else
+		reg |= IPG_DATA_VAL(IPG_DATA_DEF_10_100);
+	gma_write16(sky2->hw, sky2->port, GM_SERIAL_MODE, reg);
+}
+
 /* Enable Rx/Tx */
 static void sky2_enable_rx_tx(struct sky2_port *sky2)
 {
@@ -882,7 +896,7 @@ static void sky2_mac_init(struct sky2_hw
 
 	/* serial mode register */
 	reg = DATA_BLIND_VAL(DATA_BLIND_DEF) |
-		GM_SMOD_VLAN_ENA | IPG_DATA_VAL(IPG_DATA_DEF);
+		GM_SMOD_VLAN_ENA | IPG_DATA_VAL(IPG_DATA_DEF_1000);
 
 	if (hw->dev[port]->mtu > ETH_DATA_LEN)
 		reg |= GM_SMOD_JUMBO_ENA;
@@ -2053,6 +2067,8 @@ static void sky2_link_up(struct sky2_por
 		[FC_BOTH]	= "both",
 	};
 
+	sky2_set_ipg(sky2);
+
 	sky2_enable_rx_tx(sky2);
 
 	gm_phy_write(hw, port, PHY_MARV_INT_MASK, PHY_M_DEF_MSK);
@@ -2290,8 +2306,11 @@ static int sky2_change_mtu(struct net_de
 	dev->mtu = new_mtu;
 	netdev_update_features(dev);
 
-	mode = DATA_BLIND_VAL(DATA_BLIND_DEF) |
-		GM_SMOD_VLAN_ENA | IPG_DATA_VAL(IPG_DATA_DEF);
+	mode = DATA_BLIND_VAL(DATA_BLIND_DEF) |	GM_SMOD_VLAN_ENA;
+	if (sky2->speed > SPEED_100)
+		mode |= IPG_DATA_VAL(IPG_DATA_DEF_1000);
+	else
+		mode |= IPG_DATA_VAL(IPG_DATA_DEF_10_100);
 
 	if (dev->mtu > ETH_DATA_LEN)
 		mode |= GM_SMOD_JUMBO_ENA;
--- a/drivers/net/sky2.h	2011-07-07 08:36:37.372004595 -0700
+++ b/drivers/net/sky2.h	2011-07-07 08:36:42.420004801 -0700
@@ -1807,10 +1807,11 @@ enum {
 };
 
 #define DATA_BLIND_VAL(x)	(((x)<<11) & GM_SMOD_DATABL_MSK)
-#define DATA_BLIND_DEF		0x04
-
 #define IPG_DATA_VAL(x)		(x & GM_SMOD_IPG_MSK)
-#define IPG_DATA_DEF		0x1e
+
+#define DATA_BLIND_DEF		0x04
+#define IPG_DATA_DEF_1000	0x1e
+#define IPG_DATA_DEF_10_100	0x18
 
 /*	GM_SMI_CTRL			16 bit r/w	SMI Control Register */
 enum {


