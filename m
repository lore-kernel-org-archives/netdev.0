From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 4/7] 2.6.6-rc3-mm1 - r8169 ethtool .set_settings
Date: Sat, 1 May 2004 02:28:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040501022808.D500@electric-eye.fr.zoreil.com>
References: <20040501022308.A32762@electric-eye.fr.zoreil.com> <20040501022439.A500@electric-eye.fr.zoreil.com> <20040501022552.B500@electric-eye.fr.zoreil.com> <20040501022654.C500@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@myrealbox.com>, Jon D Mason <jonmason@us.ibm.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040501022654.C500@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Sat, May 01, 2004 at 02:26:54AM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


ethtool set_settings support (Andy Lutomirski <luto@myrealbox.com>).


diff -puN drivers/net/r8169.c~r8169-ethtool-set_settings drivers/net/r8169.c
--- linux-2.6.6-rc3/drivers/net/r8169.c~r8169-ethtool-set_settings	2004-05-01 01:46:36.000000000 +0200
+++ linux-2.6.6-rc3-fr/drivers/net/r8169.c	2004-05-01 01:46:36.000000000 +0200
@@ -413,8 +413,68 @@ static void rtl8169_get_drvinfo(struct n
 	strcpy(info->bus_info, pci_name(tp->pci_dev));
 }
 
+static void rtl8169_set_speed(struct net_device *dev,
+			      u8 autoneg, u16 speed, u8 duplex)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void *ioaddr = tp->mmio_addr;
+	int auto_nego, giga_ctrl;
+	u8 status;
+
+	status = RTL_R8(PHYstatus);
+	if ((status & TBI_Enable) && (autoneg == AUTONEG_DISABLE)) {
+		autoneg = AUTONEG_ENABLE;
+		printk(KERN_WARNING PFX
+		       "%s: ignoring request to force speed in TBI mode\n",
+		       dev->name);
+	}
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
+	if (!(status & TBI_Enable)) {
+		mdio_write(ioaddr, PHY_AUTO_NEGO_REG, auto_nego);
+		mdio_write(ioaddr, PHY_1000_CTRL_REG, giga_ctrl);
+	}
+
+	mdio_write(ioaddr, PHY_CTRL_REG,
+		   PHY_Enable_Auto_Nego | PHY_Restart_Auto_Nego);
+}
+
+static int rtl8169_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	unsigned long flags;
+
+	spin_lock_irqsave(&tp->lock, flags);
+	rtl8169_set_speed(dev, cmd->autoneg, cmd->speed, cmd->duplex);
+	spin_unlock_irqrestore(&tp->lock, flags);
+	
+	return 0;
+}
+
 static struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_drvinfo		= rtl8169_get_drvinfo,
+	.set_settings		= rtl8169_set_settings,
 };
 
 static void rtl8169_write_gmii_reg_bit(void *ioaddr, int reg, int bitnum,

_
