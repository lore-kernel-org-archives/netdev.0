From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.6-mm4 1/4] r8169: ethtool .set_settings
Date: Thu, 20 May 2004 14:37:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040520143735.A30304@electric-eye.fr.zoreil.com>
References: <20040520143500.A28948@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040520143500.A28948@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Thu, May 20, 2004 at 02:35:00PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


ethtool set_settings support (Andy Lutomirski <luto@myrealbox.com>).
The initial code has been modified so that the settings of parameters
for TBI and normal mode do not step on each others shoes.


diff -puN drivers/net/r8169.c~r8169-ethtool-set_settings drivers/net/r8169.c
--- linux-2.6.6-mm4/drivers/net/r8169.c~r8169-ethtool-set_settings	2004-05-20 00:19:52.000000000 +0200
+++ linux-2.6.6-mm4-fr/drivers/net/r8169.c	2004-05-20 13:03:25.000000000 +0200
@@ -242,6 +242,14 @@ enum RTL8169_register_content {
 	TxInterFrameGapShift = 24,
 	TxDMAShift = 8,	/* DMA burst value (0-7) is shift this many bits */
 
+	/* TBICSR p.28 */
+	TBIReset	= 0x80000000,
+	TBILoopback	= 0x40000000,
+	TBINwEnable	= 0x20000000,
+	TBINwRestart	= 0x10000000,
+	TBILinkOk	= 0x02000000,
+	TBINwComplete	= 0x01000000,
+
 	/* CPlusCmd p.31 */
 	RxVlan		= (1 << 6),
 	RxChkSum	= (1 << 5),
@@ -336,6 +344,7 @@ struct rtl8169_private {
 	unsigned long phy_link_down_cnt;
 	u16 cp_cmd;
 	u16 intr_mask;
+	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duplex);
 };
 
 MODULE_AUTHOR("Realtek");
@@ -413,8 +422,90 @@ static void rtl8169_get_drvinfo(struct n
 	strcpy(info->bus_info, pci_name(tp->pci_dev));
 }
 
+static int rtl8169_set_speed_tbi(struct net_device *dev,
+				 u8 autoneg, u16 speed, u8 duplex)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void *ioaddr = tp->mmio_addr;
+	int ret = 0;
+	u32 reg;
+
+	reg = RTL_R32(TBICSR);
+	if ((autoneg == AUTONEG_DISABLE) && (speed == SPEED_1000) &&
+	    (duplex == DUPLEX_FULL)) {
+		RTL_W32(TBICSR, reg & ~(TBINwEnable | TBINwRestart));
+	} else if (autoneg == AUTONEG_ENABLE)
+		RTL_W32(TBICSR, reg | TBINwEnable | TBINwRestart);
+	else {
+		printk(KERN_WARNING PFX
+		       "%s: incorrect speed setting refused in TBI mode\n",
+		       dev->name);
+		ret = -EOPNOTSUPP;
+	}
+
+	return ret;
+}
+
+static int rtl8169_set_speed_xmii(struct net_device *dev,
+				  u8 autoneg, u16 speed, u8 duplex)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void *ioaddr = tp->mmio_addr;
+	int auto_nego, giga_ctrl;
+
+	auto_nego = mdio_read(ioaddr, PHY_AUTO_NEGO_REG);
+	auto_nego &= ~(PHY_Cap_10_Half | PHY_Cap_10_Full |
+		       PHY_Cap_100_Half | PHY_Cap_100_Full);
+	giga_ctrl = mdio_read(ioaddr, PHY_1000_CTRL_REG);
+	giga_ctrl &= ~(PHY_Cap_1000_Full | PHY_Cap_Null);
+
+	if (autoneg == AUTONEG_ENABLE) {
+		auto_nego |= (PHY_Cap_10_Half | PHY_Cap_10_Full |
+			      PHY_Cap_100_Half | PHY_Cap_100_Full);
+		giga_ctrl |= PHY_Cap_1000_Full;
+	} else {
+		if (speed == SPEED_10)
+			auto_nego |= PHY_Cap_10_Half | PHY_Cap_10_Full;
+		else if (speed == SPEED_100)
+			auto_nego |= PHY_Cap_100_Half | PHY_Cap_100_Full;
+		else if (speed == SPEED_1000)
+			giga_ctrl |= PHY_Cap_1000_Full;
+
+		if (duplex == DUPLEX_HALF)
+			auto_nego &= ~(PHY_Cap_10_Full | PHY_Cap_100_Full);
+	}
+
+	mdio_write(ioaddr, PHY_AUTO_NEGO_REG, auto_nego);
+	mdio_write(ioaddr, PHY_1000_CTRL_REG, giga_ctrl);
+	mdio_write(ioaddr, PHY_CTRL_REG, PHY_Enable_Auto_Nego |
+					 PHY_Restart_Auto_Nego);
+	return 0;
+}
+
+static int rtl8169_set_speed(struct net_device *dev,
+			     u8 autoneg, u16 speed, u8 duplex)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+
+	return tp->set_speed(dev, autoneg, speed, duplex);
+}
+
+static int rtl8169_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&tp->lock, flags);
+	ret = rtl8169_set_speed(dev, cmd->autoneg, cmd->speed, cmd->duplex);
+	spin_unlock_irqrestore(&tp->lock, flags);
+	
+	return ret;
+}
+
 static struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_drvinfo		= rtl8169_get_drvinfo,
+	.set_settings		= rtl8169_set_settings,
 };
 
 static void rtl8169_write_gmii_reg_bit(void *ioaddr, int reg, int bitnum,
@@ -837,6 +928,12 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	assert(dev != NULL);
 	assert(tp != NULL);
 
+	if (RTL_R8(PHYstatus) & TBI_Enable) {
+		tp->set_speed = rtl8169_set_speed_tbi;
+	} else {
+		tp->set_speed = rtl8169_set_speed_xmii;
+	}
+
 	// Get MAC address.  FIXME: read EEPROM
 	for (i = 0; i < MAC_ADDR_LEN; i++)
 		dev->dev_addr[i] = RTL_R8(MAC0 + i);

_
