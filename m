From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 7/7] 2.6.6-rc3-mm1 - r8169 link handling rework (2/2)
Date: Sat, 1 May 2004 02:31:29 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040501023129.G500@electric-eye.fr.zoreil.com>
References: <20040501022308.A32762@electric-eye.fr.zoreil.com> <20040501022439.A500@electric-eye.fr.zoreil.com> <20040501022552.B500@electric-eye.fr.zoreil.com> <20040501022654.C500@electric-eye.fr.zoreil.com> <20040501022808.D500@electric-eye.fr.zoreil.com> <20040501022907.E500@electric-eye.fr.zoreil.com> <20040501023045.F500@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@myrealbox.com>, Jon D Mason <jonmason@us.ibm.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040501023045.F500@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Sat, May 01, 2004 at 02:30:45AM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Use rtl8169_set_speed() for link setup in rtl8169_init_one():
- the code whic handles the option checking is isolated;
- display (once) a notice message about the deprecated interface;
- rtl8169_open() enables the phy timer if the link is not up;
- rtl8169_set_speed() checks that the netdevice is actually ready
  in order to activate the timer.


diff -puN drivers/net/r8169.c~r8169-link-10 drivers/net/r8169.c
--- linux-2.6.6-rc3/drivers/net/r8169.c~r8169-link-10	2004-05-01 01:46:42.000000000 +0200
+++ linux-2.6.6-rc3-fr/drivers/net/r8169.c	2004-05-01 01:46:42.000000000 +0200
@@ -7,7 +7,7 @@
  Feb  4 2002	- created initially by ShuChen <shuchen@realtek.com.tw>.
  May 20 2002	- Add link status force-mode and TBI mode support.
 =========================================================================
-  1. The media can be forced in 5 modes.
+  1. [DEPRECATED: use ethtool instead] The media can be forced in 5 modes.
 	 Command: 'insmod r8169 media = SET_MEDIA'
 	 Ex:	  'insmod r8169 media = 0x04' will force PHY to operate in 100Mpbs Half-duplex.
 	
@@ -432,6 +432,37 @@ static void rtl8169_check_link_status(st
 	spin_unlock_irqrestore(&tp->lock, flags);
 }
 
+static void rtl8169_link_option(int idx, u8 *autoneg, u16 *speed, u8 *duplex)
+{
+	struct {
+		u16 speed;
+		u8 duplex;
+		u8 autoneg;
+		u8 media;
+	} link_settings[] = {
+		{ SPEED_10,	DUPLEX_HALF, AUTONEG_DISABLE,	_10_Half },
+		{ SPEED_10,	DUPLEX_FULL, AUTONEG_DISABLE,	_10_Full },
+		{ SPEED_100,	DUPLEX_HALF, AUTONEG_DISABLE,	_100_Half },
+		{ SPEED_100,	DUPLEX_FULL, AUTONEG_DISABLE,	_100_Full },
+		{ SPEED_1000,	DUPLEX_FULL, AUTONEG_DISABLE,	_1000_Full },
+		{ SPEED_1000,	DUPLEX_FULL, AUTONEG_ENABLE,	0xff }
+	}, *p;
+	unsigned char option;
+	
+	option = ((idx < MAX_UNITS) && (idx >= 0)) ? media[idx] : 0xff;
+
+	if ((option != 0xff) && !idx)
+		printk(KERN_WARNING PFX "media option is deprecated.\n");
+
+	for (p = link_settings; p->media != 0xff; p++) {
+		if (p->media == option)
+			break;
+	}
+	*autoneg = p->autoneg;
+	*speed = p->speed;
+	*duplex = p->duplex;
+}
+
 static void rtl8169_get_drvinfo(struct net_device *dev,
 				struct ethtool_drvinfo *info)
 {
@@ -491,7 +522,7 @@ static void rtl8169_set_speed(struct net
 	mdio_write(ioaddr, PHY_CTRL_REG,
 		   PHY_Enable_Auto_Nego | PHY_Restart_Auto_Nego);
 
-	if (giga_ctrl & PHY_Cap_1000_Full)
+	if (netif_running(dev) && (giga_ctrl & PHY_Cap_1000_Full))
 		mod_timer(&tp->timer, jiffies + RTL8169_PHY_TIMEOUT);
 }
 
@@ -957,8 +988,9 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	void *ioaddr = NULL;
 	static int board_idx = -1;
 	static int printed_version = 0;
+	u8 autoneg, duplex;
+	u16 speed;
 	int i, rc;
-	int option = -1, Cap10_100 = 0, Cap1000 = 0;
 
 	assert(pdev != NULL);
 	assert(ent != NULL);
@@ -1045,91 +1077,11 @@ rtl8169_init_one(struct pci_dev *pdev, c
 		mdio_write(ioaddr, 0x0b, 0x0000); //w 0x0b 15 0 0
 	}
 
-	// if TBI is not endbled
-	if (!(RTL_R8(PHYstatus) & TBI_Enable)) {
-		int val = mdio_read(ioaddr, PHY_AUTO_NEGO_REG);
-
-		option = (board_idx >= MAX_UNITS) ? 0 : media[board_idx];
-		// Force RTL8169 in 10/100/1000 Full/Half mode.
-		if (option > 0) {
-			printk(KERN_INFO "%s: Force-mode Enabled.\n",
-			       dev->name);
-			Cap10_100 = 0, Cap1000 = 0;
-			switch (option) {
-			case _10_Half:
-				Cap10_100 = PHY_Cap_10_Half_Or_Less;
-				Cap1000 = PHY_Cap_Null;
-				break;
-			case _10_Full:
-				Cap10_100 = PHY_Cap_10_Full_Or_Less;
-				Cap1000 = PHY_Cap_Null;
-				break;
-			case _100_Half:
-				Cap10_100 = PHY_Cap_100_Half_Or_Less;
-				Cap1000 = PHY_Cap_Null;
-				break;
-			case _100_Full:
-				Cap10_100 = PHY_Cap_100_Full_Or_Less;
-				Cap1000 = PHY_Cap_Null;
-				break;
-			case _1000_Full:
-				Cap10_100 = PHY_Cap_100_Full_Or_Less;
-				Cap1000 = PHY_Cap_1000_Full;
-				break;
-			default:
-				break;
-			}
-			// leave PHY_AUTO_NEGO_REG bit4:0 unchanged
-			mdio_write(ioaddr, PHY_AUTO_NEGO_REG,
-				   Cap10_100 | (val & 0x1F));
-			mdio_write(ioaddr, PHY_1000_CTRL_REG, Cap1000);
-		} else {
-			printk(KERN_INFO "%s: Auto-negotiation Enabled.\n",
-			       dev->name);
-
-			// enable 10/100 Full/Half Mode
-			// leave PHY_AUTO_NEGO_REG bit4:0 unchanged
-			mdio_write(ioaddr, PHY_AUTO_NEGO_REG,
-				   PHY_Cap_100_Full_Or_Less | (val & 0x1f));
-
-			// enable 1000 Full Mode
-			mdio_write(ioaddr, PHY_1000_CTRL_REG,
-				   PHY_Cap_1000_Full);
-
-		}
-
-		// Enable auto-negotiation and restart auto-nigotiation
-		mdio_write(ioaddr, PHY_CTRL_REG,
-			   PHY_Enable_Auto_Nego | PHY_Restart_Auto_Nego);
-		udelay(100);
+	rtl8169_link_option(board_idx, &autoneg, &speed, &duplex);
 
-		// wait for auto-negotiation process
-		for (i = 10000; i > 0; i--) {
-			//check if auto-negotiation complete
-			if (mdio_read(ioaddr, PHY_STAT_REG) &
-			    PHY_Auto_Neco_Comp) {
-				udelay(100);
-				option = RTL_R8(PHYstatus);
-				if (option & _1000bpsF) {
-					printk(KERN_INFO
-					       "%s: 1000Mbps Full-duplex operation.\n",
-					       dev->name);
-				} else {
-					printk(KERN_INFO
-					       "%s: %sMbps %s-duplex operation.\n",
-					       dev->name,
-					       (option & _100bps) ? "100" :
-					       "10",
-					       (option & FullDup) ? "Full" :
-					       "Half");
-				}
-				break;
-			} else {
-				udelay(100);
-			}
-		}	// end for-loop to wait for auto-negotiation process
-
-	} else {
+	rtl8169_set_speed(dev, autoneg, speed, duplex);
+	
+	if (RTL_R8(PHYstatus) & TBI_Enable) {
 		udelay(100);
 		printk(KERN_INFO
 		       "%s: 1000Mbps Full-duplex operation, TBI Link %s!\n",
@@ -1236,6 +1188,8 @@ rtl8169_open(struct net_device *dev)
 	rtl8169_hw_start(dev);
 
 	rtl8169_request_timer(dev);
+
+	rtl8169_check_link_status(dev, tp, tp->mmio_addr);
 out:
 	return retval;
 

_
