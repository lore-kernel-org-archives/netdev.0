From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] e1000: ethtool cleanups
Date: Wed, 5 Jan 2005 15:22:13 -0800
Message-ID: <20050105152213.6bb7b5dd@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeb Cramer <cramerj@intel.com>, john.ronciak@intel.com,
        ganesh.venkatesan@intel.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

E1000 ethtool fixes:
	* can use ethtool_ops_get_tx_csum
	* use ADVERTISED_xxx fields when setting advertised fields
	  (works now because fields are the same in ethtool.h)
	* don't hardcode constant for advertised field

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
--- a/drivers/net/e1000/e1000_ethtool.c	2005-01-05 13:54:27 -08:00
+++ b/drivers/net/e1000/e1000_ethtool.c	2005-01-05 13:54:27 -08:00
@@ -140,9 +140,9 @@
 				     SUPPORTED_FIBRE |
 				     SUPPORTED_Autoneg);
 
-		ecmd->advertising = (SUPPORTED_1000baseT_Full |
-				     SUPPORTED_FIBRE |
-				     SUPPORTED_Autoneg);
+		ecmd->advertising = (ADVERTISED_1000baseT_Full |
+				     ADVERTISED_FIBRE |
+				     ADVERTISED_Autoneg);
 
 		ecmd->port = PORT_FIBRE;
 
@@ -183,8 +183,19 @@
 
 	if(ecmd->autoneg == AUTONEG_ENABLE) {
 		hw->autoneg = 1;
-		hw->autoneg_advertised = 0x002F;
-		ecmd->advertising = 0x002F;
+		if (hw->media_type == e1000_media_type_fiber)
+			hw->autoneg_advertised = ADVERTISED_100baseT_Full |
+				     ADVERTISED_FIBRE |
+				     ADVERTISED_Autoneg;
+		else 
+			hw->autoneg_advertised = ADVERTISED_10baseT_Half |
+						  ADVERTISED_10baseT_Full |
+						  ADVERTISED_100baseT_Half |
+						  ADVERTISED_100baseT_Full |
+						  ADVERTISED_1000baseT_Full|
+						  ADVERTISED_Autoneg |
+						  ADVERTISED_TP;
+		ecmd->advertising = hw->autoneg_advertised;
 	} else
 		if(e1000_set_spd_dplx(adapter, ecmd->speed + ecmd->duplex))
 			return -EINVAL;
@@ -276,12 +287,6 @@
 	return 0;
 }
 	
-static uint32_t
-e1000_get_tx_csum(struct net_device *netdev)
-{
-	return (netdev->features & NETIF_F_HW_CSUM) != 0;
-}
-
 static int
 e1000_set_tx_csum(struct net_device *netdev, uint32_t data)
 {
@@ -293,12 +298,7 @@
 		return 0;
 	}
 
-	if (data)
-		netdev->features |= NETIF_F_HW_CSUM;
-	else
-		netdev->features &= ~NETIF_F_HW_CSUM;
-
-	return 0;
+	return ethtool_op_set_tx_csum(netdev, data);
 }
 
 #ifdef NETIF_F_TSO
@@ -1638,7 +1638,7 @@
 	.set_pauseparam		= e1000_set_pauseparam,
 	.get_rx_csum		= e1000_get_rx_csum,
 	.set_rx_csum		= e1000_set_rx_csum,
-	.get_tx_csum		= e1000_get_tx_csum,
+	.get_tx_csum		= ethtool_op_get_tx_csum,
 	.set_tx_csum		= e1000_set_tx_csum,
 	.get_sg			= ethtool_op_get_sg,
 	.set_sg			= ethtool_op_set_sg,
