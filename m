From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 2/2] netdev: Use default implementation of
 ethtool_ops::get_link where possible
Date: Thu, 09 Dec 2010 22:10:25 +0000
Message-ID: <1291932625.2647.34.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:25788 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756636Ab0LIWK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 17:10:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Various drivers are using implementations of ethtool_ops::get_link
that are equivalent to the default ethtool_op_get_link().  Change
them to use that instead.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
I've tested the e1000e and sfc changes but not the others.

Ben.

 drivers/net/e1000e/ethtool.c |   16 +---------------
 drivers/net/ibmveth.c        |    7 +------
 drivers/net/igbvf/ethtool.c  |    7 +------
 drivers/net/iseries_veth.c   |    7 +------
 drivers/net/mv643xx_eth.c    |    7 +------
 drivers/net/pxa168_eth.c     |    7 +------
 drivers/net/sfc/ethtool.c    |    9 +--------
 drivers/net/sunlance.c       |   10 +---------
 8 files changed, 8 insertions(+), 62 deletions(-)

diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 8984d16..3612900 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -194,20 +194,6 @@ static int e1000_get_settings(struct net_device *netdev,
 	return 0;
 }
 
-static u32 e1000_get_link(struct net_device *netdev)
-{
-	struct e1000_adapter *adapter = netdev_priv(netdev);
-	struct e1000_hw *hw = &adapter->hw;
-
-	/*
-	 * Avoid touching hardware registers when possible, otherwise
-	 * link negotiation can get messed up when user-level scripts
-	 * are rapidly polling the driver to see if link is up.
-	 */
-	return netif_running(netdev) ? netif_carrier_ok(netdev) :
-	    !!(er32(STATUS) & E1000_STATUS_LU);
-}
-
 static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
 {
 	struct e1000_mac_info *mac = &adapter->hw.mac;
@@ -2024,7 +2010,7 @@ static const struct ethtool_ops e1000_ethtool_ops = {
 	.get_msglevel		= e1000_get_msglevel,
 	.set_msglevel		= e1000_set_msglevel,
 	.nway_reset		= e1000_nway_reset,
-	.get_link		= e1000_get_link,
+	.get_link		= ethtool_op_get_link,
 	.get_eeprom_len		= e1000_get_eeprom_len,
 	.get_eeprom		= e1000_get_eeprom,
 	.set_eeprom		= e1000_set_eeprom,
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index c454b45..5522d45 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -729,11 +729,6 @@ static void netdev_get_drvinfo(struct net_device *dev,
 		sizeof(info->version) - 1);
 }
 
-static u32 netdev_get_link(struct net_device *dev)
-{
-	return 1;
-}
-
 static void ibmveth_set_rx_csum_flags(struct net_device *dev, u32 data)
 {
 	struct ibmveth_adapter *adapter = netdev_priv(dev);
@@ -918,7 +913,7 @@ static void ibmveth_get_ethtool_stats(struct net_device *dev,
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_drvinfo		= netdev_get_drvinfo,
 	.get_settings		= netdev_get_settings,
-	.get_link		= netdev_get_link,
+	.get_link		= ethtool_op_get_link,
 	.set_tx_csum		= ibmveth_set_tx_csum,
 	.get_rx_csum		= ibmveth_get_rx_csum,
 	.set_rx_csum		= ibmveth_set_rx_csum,
diff --git a/drivers/net/igbvf/ethtool.c b/drivers/net/igbvf/ethtool.c
index abb3606..ed6e3d9 100644
--- a/drivers/net/igbvf/ethtool.c
+++ b/drivers/net/igbvf/ethtool.c
@@ -110,11 +110,6 @@ static int igbvf_get_settings(struct net_device *netdev,
 	return 0;
 }
 
-static u32 igbvf_get_link(struct net_device *netdev)
-{
-	return netif_carrier_ok(netdev);
-}
-
 static int igbvf_set_settings(struct net_device *netdev,
                               struct ethtool_cmd *ecmd)
 {
@@ -515,7 +510,7 @@ static const struct ethtool_ops igbvf_ethtool_ops = {
 	.get_msglevel		= igbvf_get_msglevel,
 	.set_msglevel		= igbvf_set_msglevel,
 	.nway_reset		= igbvf_nway_reset,
-	.get_link		= igbvf_get_link,
+	.get_link		= ethtool_op_get_link,
 	.get_eeprom_len		= igbvf_get_eeprom_len,
 	.get_eeprom		= igbvf_get_eeprom,
 	.set_eeprom		= igbvf_set_eeprom,
diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
index 38e15be..63ac531 100644
--- a/drivers/net/iseries_veth.c
+++ b/drivers/net/iseries_veth.c
@@ -1009,15 +1009,10 @@ static int veth_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 	return 0;
 }
 
-static u32 veth_get_link(struct net_device *dev)
-{
-	return 1;
-}
-
 static const struct ethtool_ops ops = {
 	.get_drvinfo = veth_get_drvinfo,
 	.get_settings = veth_get_settings,
-	.get_link = veth_get_link,
+	.get_link = ethtool_op_get_link,
 };
 
 static const struct net_device_ops veth_netdev_ops = {
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index dd2b6a7..ce31e74 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1514,11 +1514,6 @@ static int mv643xx_eth_nway_reset(struct net_device *dev)
 	return genphy_restart_aneg(mp->phy);
 }
 
-static u32 mv643xx_eth_get_link(struct net_device *dev)
-{
-	return !!netif_carrier_ok(dev);
-}
-
 static int
 mv643xx_eth_get_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
 {
@@ -1658,7 +1653,7 @@ static const struct ethtool_ops mv643xx_eth_ethtool_ops = {
 	.set_settings		= mv643xx_eth_set_settings,
 	.get_drvinfo		= mv643xx_eth_get_drvinfo,
 	.nway_reset		= mv643xx_eth_nway_reset,
-	.get_link		= mv643xx_eth_get_link,
+	.get_link		= ethtool_op_get_link,
 	.get_coalesce		= mv643xx_eth_get_coalesce,
 	.set_coalesce		= mv643xx_eth_set_coalesce,
 	.get_ringparam		= mv643xx_eth_get_ringparam,
diff --git a/drivers/net/pxa168_eth.c b/drivers/net/pxa168_eth.c
index 18c0297..04ed27d 100644
--- a/drivers/net/pxa168_eth.c
+++ b/drivers/net/pxa168_eth.c
@@ -1450,16 +1450,11 @@ static void pxa168_get_drvinfo(struct net_device *dev,
 	strncpy(info->bus_info, "N/A", 32);
 }
 
-static u32 pxa168_get_link(struct net_device *dev)
-{
-	return !!netif_carrier_ok(dev);
-}
-
 static const struct ethtool_ops pxa168_ethtool_ops = {
 	.get_settings = pxa168_get_settings,
 	.set_settings = pxa168_set_settings,
 	.get_drvinfo = pxa168_get_drvinfo,
-	.get_link = pxa168_get_link,
+	.get_link = ethtool_op_get_link,
 };
 
 static const struct net_device_ops pxa168_eth_netdev_ops = {
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index aae756b..e1489f9 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -620,13 +620,6 @@ static int efx_ethtool_nway_reset(struct net_device *net_dev)
 	return mdio45_nway_restart(&efx->mdio);
 }
 
-static u32 efx_ethtool_get_link(struct net_device *net_dev)
-{
-	struct efx_nic *efx = netdev_priv(net_dev);
-
-	return efx->link_state.up;
-}
-
 static int efx_ethtool_get_coalesce(struct net_device *net_dev,
 				    struct ethtool_coalesce *coalesce)
 {
@@ -1058,7 +1051,7 @@ const struct ethtool_ops efx_ethtool_ops = {
 	.get_msglevel		= efx_ethtool_get_msglevel,
 	.set_msglevel		= efx_ethtool_set_msglevel,
 	.nway_reset		= efx_ethtool_nway_reset,
-	.get_link		= efx_ethtool_get_link,
+	.get_link		= ethtool_op_get_link,
 	.get_coalesce		= efx_ethtool_get_coalesce,
 	.set_coalesce		= efx_ethtool_set_coalesce,
 	.get_ringparam		= efx_ethtool_get_ringparam,
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index 2cf84e5..767e1e2 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -1295,17 +1295,9 @@ static void sparc_lance_get_drvinfo(struct net_device *dev, struct ethtool_drvin
 	strcpy(info->version, "2.02");
 }
 
-static u32 sparc_lance_get_link(struct net_device *dev)
-{
-	/* We really do not keep track of this, but this
-	 * is better than not reporting anything at all.
-	 */
-	return 1;
-}
-
 static const struct ethtool_ops sparc_lance_ethtool_ops = {
 	.get_drvinfo		= sparc_lance_get_drvinfo,
-	.get_link		= sparc_lance_get_link,
+	.get_link		= ethtool_op_get_link,
 };
 
 static const struct net_device_ops sparc_lance_ops = {
-- 
1.7.3.2


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

