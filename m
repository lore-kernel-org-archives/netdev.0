From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.6-mm4 2/4] r8169: ethtool .get_{settings/link}
Date: Thu, 20 May 2004 14:38:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040520143841.B30304@electric-eye.fr.zoreil.com>
References: <20040520143500.A28948@electric-eye.fr.zoreil.com> <20040520143735.A30304@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20040520143735.A30304@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Thu, May 20, 2004 at 02:37:35PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


- ethtool get_settings() for r8169 (Andy Lutomirski <luto@myrealbox.com>);
- rtl8169_ethtool_ops.get_drvinfo() is set as well;
- added some bits to handle the TBI status.

The locking does not need to be specially clever.


diff -puN drivers/net/r8169.c~r8169-ethtool-get_settings drivers/net/r8169.c
--- linux-2.6.6-mm4/drivers/net/r8169.c~r8169-ethtool-get_settings	2004-05-20 13:04:53.000000000 +0200
+++ linux-2.6.6-mm4-fr/drivers/net/r8169.c	2004-05-20 13:15:59.000000000 +0200
@@ -344,7 +344,11 @@ struct rtl8169_private {
 	unsigned long phy_link_down_cnt;
 	u16 cp_cmd;
 	u16 intr_mask;
+	int phy_auto_nego_reg;
+	int phy_1000_ctrl_reg;
+
 	int (*set_speed)(struct net_device *, u8 autoneg, u16 speed, u8 duplex);
+	void (*get_settings)(struct net_device *, struct ethtool_cmd *);
 };
 
 MODULE_AUTHOR("Realtek");
@@ -475,6 +479,9 @@ static int rtl8169_set_speed_xmii(struct
 			auto_nego &= ~(PHY_Cap_10_Full | PHY_Cap_100_Full);
 	}
 
+	tp->phy_auto_nego_reg = auto_nego;
+	tp->phy_1000_ctrl_reg = giga_ctrl;
+
 	mdio_write(ioaddr, PHY_AUTO_NEGO_REG, auto_nego);
 	mdio_write(ioaddr, PHY_1000_CTRL_REG, giga_ctrl);
 	mdio_write(ioaddr, PHY_CTRL_REG, PHY_Enable_Auto_Nego |
@@ -503,8 +510,84 @@ static int rtl8169_set_settings(struct n
 	return ret;
 }
 
+static void rtl8169_gset_tbi(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void *ioaddr = tp->mmio_addr;
+	u32 status;
+
+	cmd->supported =
+		SUPPORTED_1000baseT_Full | SUPPORTED_Autoneg | SUPPORTED_FIBRE;
+	cmd->port = PORT_FIBRE;
+	cmd->transceiver = XCVR_INTERNAL;
+
+	status = RTL_R32(TBICSR);
+	cmd->advertising = (status & TBINwEnable) ?  ADVERTISED_Autoneg : 0;
+	cmd->autoneg = !!(status & TBINwEnable);
+
+	cmd->speed = SPEED_1000;
+	cmd->duplex = DUPLEX_FULL; /* Always set */
+}
+
+static void rtl8169_gset_xmii(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	void *ioaddr = tp->mmio_addr;
+	u8 status;
+
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
+
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
+	status = RTL_R8(PHYstatus);
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
+}
+
+static int rtl8169_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	unsigned long flags;
+
+	spin_lock_irqsave(&tp->lock, flags);
+
+	tp->get_settings(dev, cmd);
+
+	spin_unlock_irqrestore(&tp->lock, flags);
+	return 0;
+}
+
+
 static struct ethtool_ops rtl8169_ethtool_ops = {
 	.get_drvinfo		= rtl8169_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
+	.get_settings		= rtl8169_get_settings,
 	.set_settings		= rtl8169_set_settings,
 };
 
@@ -930,8 +1013,12 @@ rtl8169_init_one(struct pci_dev *pdev, c
 
 	if (RTL_R8(PHYstatus) & TBI_Enable) {
 		tp->set_speed = rtl8169_set_speed_tbi;
+		tp->get_settings = rtl8169_gset_tbi;
+
+		tp->phy_1000_ctrl_reg = PHY_Cap_1000_Full; /* Implied by TBI */
 	} else {
 		tp->set_speed = rtl8169_set_speed_xmii;
+		tp->get_settings = rtl8169_gset_xmii;
 	}
 
 	// Get MAC address.  FIXME: read EEPROM

_
