From: Richard Dawe <rich@phekda.gotadsl.co.uk>
Subject: [PATCH] r8169: support restricting speed+duplex in autonegotiation
Date: Fri, 27 May 2005 23:36:39 +0100
Message-ID: <4297A0F7.5070209@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060003000203050201030506"
Cc: Linux netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060003000203050201030506
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hello.

Attached is a patch for drivers/net/r8169.c against Linux 2.6.11 that 
allows adjustment of the speed and duplex advertised via 
autonegotiation. Example usage:

   ethtool -s eth0 autoneg on speed 10 duplex half

Also attached is a test script which tries various combinations of 
autoneg, speed and duplex. There is also a log of the test run attache.d 
While the test ran I had an ssh session running "while true; do sleep 1; 
date; done". The ssh session did not drop. Note that I don't have GigE, 
so that part of the test was bogus.

I also tried various speed tests, to check that the speed and duplex 
were actually changed. They were.

Bye, Rich

r8169: Allow adjustment of speed and duplex advertised via autonegotiation

Signed-off-by: Richard Dawe <rich@phekda.gotadsl.co.uk>

--------------060003000203050201030506
Content-Type: text/plain;
 name="r8169-ethtool-autoneg.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="r8169-ethtool-autoneg.diff"

--- r8169.c.orig	2005-05-27 21:12:21.000000000 +0100
+++ r8169.c	2005-05-27 22:14:59.000000000 +0100
@@ -407,7 +407,9 @@ struct rtl8169_private {
 #ifdef CONFIG_R8169_VLAN
 	struct vlan_group *vlgrp;
 #endif
-	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duplex);
+	int (*set_speed)(struct net_device *,
+			 u8 autoneg, u16 speed, u8 duplex,
+			 u32 advertising);
 	void (*get_settings)(struct net_device *, struct ethtool_cmd *);
 	void (*phy_reset_enable)(void __iomem *);
 	unsigned int (*phy_reset_pending)(void __iomem *);
@@ -549,7 +551,9 @@ static void rtl8169_check_link_status(st
 	spin_unlock_irqrestore(&tp->lock, flags);
 }
 
-static void rtl8169_link_option(int idx, u8 *autoneg, u16 *speed, u8 *duplex)
+static void rtl8169_link_option(int idx,
+				u8 *autoneg, u16 *speed, u8 *duplex,
+				u32 *advertising)
 {
 	struct {
 		u16 speed;
@@ -579,6 +583,23 @@ static void rtl8169_link_option(int idx,
 	*autoneg = p->autoneg;
 	*speed = p->speed;
 	*duplex = p->duplex;
+
+	if (p->media == _10_Half)
+		*advertising = ADVERTISED_10baseT_Half;
+	if (p->media == _10_Full)
+		*advertising = ADVERTISED_10baseT_Full;
+	if (p->media == _100_Half)
+		*advertising = ADVERTISED_100baseT_Half;
+	if (p->media == _100_Full)
+		*advertising = ADVERTISED_100baseT_Full;
+	if (p->media == _1000_Full)
+		*advertising = ADVERTISED_1000baseT_Full;
+	if (p->media == 0xff)
+		*advertising = ADVERTISED_10baseT_Half |
+			       ADVERTISED_10baseT_Full |
+			       ADVERTISED_100baseT_Half |
+			       ADVERTISED_100baseT_Full |
+			       ADVERTISED_1000baseT_Full;
 }
 
 static void rtl8169_get_drvinfo(struct net_device *dev,
@@ -597,7 +618,8 @@ static int rtl8169_get_regs_len(struct n
 }
 
 static int rtl8169_set_speed_tbi(struct net_device *dev,
-				 u8 autoneg, u16 speed, u8 duplex)
+				 u8 autoneg, u16 speed, u8 duplex,
+				 u32 advertising)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -608,7 +630,8 @@ static int rtl8169_set_speed_tbi(struct 
 	if ((autoneg == AUTONEG_DISABLE) && (speed == SPEED_1000) &&
 	    (duplex == DUPLEX_FULL)) {
 		RTL_W32(TBICSR, reg & ~(TBINwEnable | TBINwRestart));
-	} else if (autoneg == AUTONEG_ENABLE)
+	} else if ((autoneg == AUTONEG_ENABLE) &&
+		   (advertising & ADVERTISED_1000baseT_Full))
 		RTL_W32(TBICSR, reg | TBINwEnable | TBINwRestart);
 	else {
 		printk(KERN_WARNING PFX
@@ -621,11 +644,13 @@ static int rtl8169_set_speed_tbi(struct 
 }
 
 static int rtl8169_set_speed_xmii(struct net_device *dev,
-				  u8 autoneg, u16 speed, u8 duplex)
+				  u8 autoneg, u16 speed, u8 duplex,
+				  u32 advertising)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
 	int auto_nego, giga_ctrl;
+	int ret = 0;
 
 	auto_nego = mdio_read(ioaddr, PHY_AUTO_NEGO_REG);
 	auto_nego &= ~(PHY_Cap_10_Half | PHY_Cap_10_Full |
@@ -634,9 +659,16 @@ static int rtl8169_set_speed_xmii(struct
 	giga_ctrl &= ~(PHY_Cap_1000_Full | PHY_Cap_Null);
 
 	if (autoneg == AUTONEG_ENABLE) {
-		auto_nego |= (PHY_Cap_10_Half | PHY_Cap_10_Full |
-			      PHY_Cap_100_Half | PHY_Cap_100_Full);
-		giga_ctrl |= PHY_Cap_1000_Full;
+		if (advertising & ADVERTISED_10baseT_Half)
+			auto_nego |= PHY_Cap_10_Half;
+		if (advertising & ADVERTISED_10baseT_Full)
+			auto_nego |= PHY_Cap_10_Full;
+		if (advertising & ADVERTISED_100baseT_Half)
+			auto_nego |= PHY_Cap_100_Half;
+		if (advertising & ADVERTISED_100baseT_Full)
+			auto_nego |= PHY_Cap_100_Full;
+		if (advertising & ADVERTISED_1000baseT_Full)
+			giga_ctrl |= PHY_Cap_1000_Full;
 	} else {
 		if (speed == SPEED_10)
 			auto_nego |= PHY_Cap_10_Half | PHY_Cap_10_Full;
@@ -649,23 +681,28 @@ static int rtl8169_set_speed_xmii(struct
 			auto_nego &= ~(PHY_Cap_10_Full | PHY_Cap_100_Full);
 	}
 
-	tp->phy_auto_nego_reg = auto_nego;
-	tp->phy_1000_ctrl_reg = giga_ctrl;
+	if (ret == 0)
+	{
+		tp->phy_auto_nego_reg = auto_nego;
+		tp->phy_1000_ctrl_reg = giga_ctrl;
+
+		mdio_write(ioaddr, PHY_AUTO_NEGO_REG, auto_nego);
+		mdio_write(ioaddr, PHY_1000_CTRL_REG, giga_ctrl);
+		mdio_write(ioaddr, PHY_CTRL_REG, PHY_Enable_Auto_Nego |
+			                         PHY_Restart_Auto_Nego);
+	}
 
-	mdio_write(ioaddr, PHY_AUTO_NEGO_REG, auto_nego);
-	mdio_write(ioaddr, PHY_1000_CTRL_REG, giga_ctrl);
-	mdio_write(ioaddr, PHY_CTRL_REG, PHY_Enable_Auto_Nego |
-					 PHY_Restart_Auto_Nego);
-	return 0;
+	return ret;
 }
 
 static int rtl8169_set_speed(struct net_device *dev,
-			     u8 autoneg, u16 speed, u8 duplex)
+			     u8 autoneg, u16 speed, u8 duplex,
+			     u32 advertising)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	int ret;
 
-	ret = tp->set_speed(dev, autoneg, speed, duplex);
+	ret = tp->set_speed(dev, autoneg, speed, duplex, advertising);
 
 	if (netif_running(dev) && (tp->phy_1000_ctrl_reg & PHY_Cap_1000_Full))
 		mod_timer(&tp->timer, jiffies + RTL8169_PHY_TIMEOUT);
@@ -680,7 +717,9 @@ static int rtl8169_set_settings(struct n
 	int ret;
 
 	spin_lock_irqsave(&tp->lock, flags);
-	ret = rtl8169_set_speed(dev, cmd->autoneg, cmd->speed, cmd->duplex);
+	ret = rtl8169_set_speed(dev,
+				cmd->autoneg, cmd->speed, cmd->duplex,
+				cmd->advertising);
 	spin_unlock_irqrestore(&tp->lock, flags);
 	
 	return ret;
@@ -1311,6 +1350,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	static int printed_version = 0;
 	u8 autoneg, duplex;
 	u16 speed;
+	u32 advertising;
 	int i, rc;
 
 	assert(pdev != NULL);
@@ -1423,9 +1463,9 @@ rtl8169_init_one(struct pci_dev *pdev, c
 		mdio_write(ioaddr, 0x0b, 0x0000); //w 0x0b 15 0 0
 	}
 
-	rtl8169_link_option(board_idx, &autoneg, &speed, &duplex);
+	rtl8169_link_option(board_idx, &autoneg, &speed, &duplex, &advertising);
 
-	rtl8169_set_speed(dev, autoneg, speed, duplex);
+	rtl8169_set_speed(dev, autoneg, speed, duplex, advertising);
 	
 	if (RTL_R8(PHYstatus) & TBI_Enable)
 		printk(KERN_INFO PFX "%s: TBI auto-negotiating\n", dev->name);

--------------060003000203050201030506
Content-Type: application/x-sh;
 name="test.sh"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="test.sh"

for i in on off; do
	ethtool -s eth0 autoneg $i speed 10 duplex half
	sleep 10
	ethtool eth0
	sleep 10
	ethtool -s eth0 autoneg $i speed 10 duplex full
	sleep 10
	ethtool eth0
	sleep 10
	ethtool -s eth0 autoneg $i speed 100 duplex half
	sleep 10
	ethtool eth0
	sleep 10
	ethtool -s eth0 autoneg $i speed 100 duplex full
	sleep 10
	ethtool eth0
	sleep 10
	ethtool -s eth0 autoneg $i speed 1000 duplex full
	sleep 10
	ethtool eth0
	sleep 10
	ethtool -s eth0 autoneg on
	sleep 10
	ethtool eth0
	sleep 10
done

--------------060003000203050201030506
Content-Type: text/plain;
 name="test.log"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="test.log"

+ for i in on off
+ ethtool -s eth0 autoneg on speed 10 duplex half
+ sleep 10
+ ethtool eth0
Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 
	Advertised auto-negotiation: Yes
	Speed: 10Mb/s
	Duplex: Half
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Link detected: yes
+ sleep 10
+ ethtool -s eth0 autoneg on speed 10 duplex full
+ sleep 10
+ ethtool eth0
Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Full 
	Advertised auto-negotiation: Yes
	Speed: 10Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Link detected: yes
+ sleep 10
+ ethtool -s eth0 autoneg on speed 100 duplex half
+ sleep 10
+ ethtool eth0
Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  100baseT/Half 
	Advertised auto-negotiation: Yes
	Speed: 100Mb/s
	Duplex: Half
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Link detected: yes
+ sleep 10
+ ethtool -s eth0 autoneg on speed 100 duplex full
+ sleep 10
+ ethtool eth0
Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  100baseT/Full 
	Advertised auto-negotiation: Yes
	Speed: 100Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Link detected: yes
+ sleep 10
+ ethtool -s eth0 autoneg on speed 1000 duplex full
+ sleep 10
+ ethtool eth0
Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  1000baseT/Full 
	Advertised auto-negotiation: Yes
	Speed: 100Mb/s
	Duplex: Half
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Link detected: no
+ sleep 10
+ ethtool -s eth0 autoneg on
+ sleep 10
+ ethtool eth0
Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Advertised auto-negotiation: Yes
	Speed: 100Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Link detected: yes
+ sleep 10
+ for i in on off
+ ethtool -s eth0 autoneg off speed 10 duplex half
+ sleep 10
+ ethtool eth0
Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 
	Advertised auto-negotiation: Yes
	Speed: 10Mb/s
	Duplex: Half
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Link detected: yes
+ sleep 10
+ ethtool -s eth0 autoneg off speed 10 duplex full
+ sleep 10
+ ethtool eth0
Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full 
	Advertised auto-negotiation: Yes
	Speed: 10Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Link detected: yes
+ sleep 10
+ ethtool -s eth0 autoneg off speed 100 duplex half
+ sleep 10
+ ethtool eth0
Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  100baseT/Half 
	Advertised auto-negotiation: Yes
	Speed: 100Mb/s
	Duplex: Half
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Link detected: yes
+ sleep 10
+ ethtool -s eth0 autoneg off speed 100 duplex full
+ sleep 10
+ ethtool eth0
Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  100baseT/Half 100baseT/Full 
	Advertised auto-negotiation: Yes
	Speed: 100Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Link detected: yes
+ sleep 10
+ ethtool -s eth0 autoneg off speed 1000 duplex full
+ sleep 10
+ ethtool eth0
Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  1000baseT/Full 
	Advertised auto-negotiation: Yes
	Speed: 100Mb/s
	Duplex: Half
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Link detected: no
+ sleep 10
+ ethtool -s eth0 autoneg on
+ sleep 10
+ ethtool eth0
Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Advertised auto-negotiation: Yes
	Speed: 100Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Link detected: yes
+ sleep 10

--------------060003000203050201030506--
