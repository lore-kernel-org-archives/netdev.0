From: ganesh.venkatesan@intel.com
Subject: [PATCH 8/12 2.5] e1000 - Shutdown PHY while bringing the interface
 down (if WoL is off)
Date: Thu, 29 Jul 2004 08:32:34 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407290811240.21929-100000@westville2.jf.intel.com>
Reply-To: ganesh.venkatesan@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.5/drivers/net/e1000/e1000_main.c linux-2.5/drivers/net/e1000.new/e1000_main.c
--- linux-2.5/drivers/net/e1000/e1000_main.c	2004-07-28 21:50:08.672461176 -0700
+++ linux-2.5/drivers/net/e1000.new/e1000_main.c	2004-07-28 21:50:09.523331824 -0700
@@ -256,6 +256,14 @@ e1000_up(struct e1000_adapter *adapter)
 
 	/* hardware has been reset, we need to reload some things */
 
+	/* Reset the PHY if it was previously powered down */
+	if(adapter->hw.media_type == e1000_media_type_copper) {
+		uint16_t mii_reg;
+		e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &mii_reg);
+		if(mii_reg & MII_CR_POWER_DOWN)
+			e1000_phy_reset(&adapter->hw);
+	}
+
 	e1000_set_multi(netdev);
 
 	e1000_restore_vlan(adapter);
@@ -294,6 +302,15 @@ e1000_down(struct e1000_adapter *adapter
 	e1000_reset(adapter);
 	e1000_clean_tx_ring(adapter);
 	e1000_clean_rx_ring(adapter);
+
+	/* If WoL is not enabled
+	 * Power down the PHY so no link is implied when interface is down */
+	if(!adapter->wol && adapter->hw.media_type == e1000_media_type_copper) {
+		uint16_t mii_reg;
+		e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &mii_reg);
+		mii_reg |= MII_CR_POWER_DOWN;
+		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, mii_reg);
+	}
 }
 
 void
@@ -2543,6 +2521,8 @@ e1000_mii_ioctl(struct net_device *netde
 			switch (data->reg_num) {
 			case PHY_CTRL:
 				if(data->val_in & MII_CR_AUTO_NEG_EN) {
+				if(mii_reg & MII_CR_POWER_DOWN)
+					break;
 					adapter->hw.autoneg = 1;
 					adapter->hw.autoneg_advertised = 0x2F;
 				} else {
@@ -2572,6 +2591,18 @@ e1000_mii_ioctl(struct net_device *netde
 					return -EIO;
 				break;
 			}
+		} else {
+			switch (data->reg_num) {
+			case PHY_CTRL:
+				if(mii_reg & MII_CR_POWER_DOWN)
+					break;
+				if(netif_running(adapter->netdev)) {
+					e1000_down(adapter);
+					e1000_up(adapter);
+				} else
+					e1000_reset(adapter);
+				break;
+			}
 		}
 		break;
 	default:
