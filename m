From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 5/7] 2.6.6-rc3-mm1 - r8169 ethtool .get_settings
Date: Sat, 1 May 2004 02:29:07 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040501022907.E500@electric-eye.fr.zoreil.com>
References: <20040501022308.A32762@electric-eye.fr.zoreil.com> <20040501022439.A500@electric-eye.fr.zoreil.com> <20040501022552.B500@electric-eye.fr.zoreil.com> <20040501022654.C500@electric-eye.fr.zoreil.com> <20040501022808.D500@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@myrealbox.com>, Jon D Mason <jonmason@us.ibm.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040501022808.D500@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Sat, May 01, 2004 at 02:28:08AM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


ethtool get_settings() for r8169 (Andy Lutomirski <luto@myrealbox.com>).

The locking does not need to be specially clever.


diff -puN drivers/net/r8169.c~r8169-ethtool-get_settings drivers/net/r8169.c
--- linux-2.6.6-rc3/drivers/net/r8169.c~r8169-ethtool-get_settings	2004-05-01 01:46:38.000000000 +0200
+++ linux-2.6.6-rc3-fr/drivers/net/r8169.c	2004-05-01 01:46:38.000000000 +0200
@@ -336,6 +336,8 @@ struct rtl8169_private {
 	unsigned long phy_link_down_cnt;
 	u16 cp_cmd;
 	u16 intr_mask;
+	int phy_auto_nego_reg;
+	int phy_1000_ctrl_reg;
 };
 
 MODULE_AUTHOR("Realtek");
@@ -451,6 +453,9 @@ static void rtl8169_set_speed(struct net
 			auto_nego &= ~(PHY_Cap_10_Full | PHY_Cap_100_Full);
 	}
 
+	tp->phy_auto_nego_reg = auto_nego;
+	tp->phy_1000_ctrl_reg = giga_ctrl;
+
 	if (!(status & TBI_Enable)) {
 		mdio_write(ioaddr, PHY_AUTO_NEGO_REG, auto_nego);
 		mdio_write(ioaddr, PHY_1000_CTRL_REG, giga_ctrl);
@@ -460,6 +465,56 @@ static void rtl8169_set_speed(struct net
 		   PHY_Enable_Auto_Nego | PHY_Restart_Auto_Nego);
 }
 
+static int rtl8169_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void *ioaddr = tp->mmio_addr;
+	unsigned long flags;
+	u8 status;
+
+	spin_lock_irqsave(&tp->lock, flags);
+
+	status = RTL_R8(PHYstatus);
+	cmd->supported = SUPPORTED_10baseT_Half |
+			 SUPPORTED_10baseT_Full |
+			 SUPPORTED_100baseT_Half |
+			 SUPPORTED_100baseT_Full |
+			 SUPPORTED_1000baseT_Full |
+			 SUPPORTED_Autoneg |
+		         SUPPORTED_TP;
+
+	cmd->autoneg = 1;
+	cmd->advertising = ADVERTISED_TP | ADVERTISED_Autoneg;
+	/*
+	 * FIXME: the driver should retrieve the values from the registers
+	 * of the rtl8169.
+	 */ 
+	if (tp->phy_auto_nego_reg & PHY_Cap_10_Half)
+		cmd->advertising |= ADVERTISED_10baseT_Half;
+	if (tp->phy_auto_nego_reg & PHY_Cap_10_Full)
+		cmd->advertising |= ADVERTISED_10baseT_Full;
+	if (tp->phy_auto_nego_reg & PHY_Cap_100_Half)
+		cmd->advertising |= ADVERTISED_100baseT_Half;
+	if (tp->phy_auto_nego_reg & PHY_Cap_100_Full)
+		cmd->advertising |= ADVERTISED_100baseT_Full;
+	if (tp->phy_1000_ctrl_reg & PHY_Cap_1000_Full)
+		cmd->advertising |= ADVERTISED_1000baseT_Full;
+
+	if (status & _1000bpsF)
+		cmd->speed = SPEED_1000;
+	else if (status & _100bps)
+		cmd->speed = SPEED_100;
+	else if (status & _10bps)
+		cmd->speed = SPEED_10;
+
+	cmd->duplex = ((status & _1000bpsF) || (status & FullDup)) ?
+		      DUPLEX_FULL : DUPLEX_HALF;
+
+	spin_unlock_irqrestore(&tp->lock, flags);
+
+	return 0;
+}
+
 static int rtl8169_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -474,6 +529,7 @@ static int rtl8169_set_settings(struct n
 
 static struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_drvinfo		= rtl8169_get_drvinfo,
+	.get_settings		= rtl8169_get_settings,
 	.set_settings		= rtl8169_set_settings,
 };
 

_
