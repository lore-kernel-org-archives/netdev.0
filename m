From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH 4/8] net: sh-eth: Remove SH_ETH_HAS_TSU and use tsu of sh_eth_cpu_data instead
Date: Thu, 18 Apr 2013 16:01:46 +0900
Message-ID: <1366268510-8121-4-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
References: <1366268510-8121-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: yoshihiro.shimoda.uh@renesas.com,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:64299 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566Ab3DRHCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 03:02:09 -0400
Received: by mail-pb0-f54.google.com with SMTP id xa7so4022pbc.13
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 00:02:09 -0700 (PDT)
In-Reply-To: <1366268510-8121-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
 drivers/net/ethernet/renesas/sh_eth.c |   22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 5c4e82c..7de0b0e 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -437,7 +437,6 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 };
 #elif defined(CONFIG_CPU_SUBTYPE_SH7757)
 #define SH_ETH_HAS_BOTH_MODULES	1
-#define SH_ETH_HAS_TSU	1
 static int sh_eth_check_reset(struct net_device *ndev);
 
 static void sh_eth_set_rate(struct net_device *ndev)
@@ -599,7 +598,6 @@ static struct sh_eth_cpu_data *sh_eth_get_cpu_data(struct sh_eth_private *mdp)
 }
 
 #elif defined(CONFIG_CPU_SUBTYPE_SH7734) || defined(CONFIG_CPU_SUBTYPE_SH7763)
-#define SH_ETH_HAS_TSU	1
 static int sh_eth_check_reset(struct net_device *ndev);
 static void sh_eth_reset_hw_crc(struct net_device *ndev);
 
@@ -702,7 +700,6 @@ static void sh_eth_reset_hw_crc(struct net_device *ndev)
 }
 
 #elif defined(CONFIG_ARCH_R8A7740)
-#define SH_ETH_HAS_TSU	1
 static int sh_eth_check_reset(struct net_device *ndev);
 
 static void sh_eth_chip_reset(struct net_device *ndev)
@@ -801,7 +798,6 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 };
 #elif defined(CONFIG_CPU_SUBTYPE_SH7710) || defined(CONFIG_CPU_SUBTYPE_SH7712)
 #define SH_ETH_RESET_DEFAULT	1
-#define SH_ETH_HAS_TSU	1
 static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.set_duplex = sh_eth_set_duplex,
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
@@ -2117,7 +2113,6 @@ static int sh_eth_do_ioctl(struct net_device *ndev, struct ifreq *rq,
 	return phy_mii_ioctl(phydev, rq, cmd);
 }
 
-#if defined(SH_ETH_HAS_TSU)
 /* For TSU_POSTn. Please refer to the manual about this (strange) bitfields */
 static void *sh_eth_tsu_get_post_reg_offset(struct sh_eth_private *mdp,
 					    int entry)
@@ -2458,7 +2453,6 @@ static int sh_eth_vlan_rx_kill_vid(struct net_device *ndev, u16 vid)
 
 	return 0;
 }
-#endif /* SH_ETH_HAS_TSU */
 
 /* SuperH's TSU register init function */
 static void sh_eth_tsu_init(struct sh_eth_private *mdp)
@@ -2597,16 +2591,11 @@ static const u16 *sh_eth_get_register_offset(int register_type)
 	return reg_offset;
 }
 
-static const struct net_device_ops sh_eth_netdev_ops = {
+static struct net_device_ops sh_eth_netdev_ops = {
 	.ndo_open		= sh_eth_open,
 	.ndo_stop		= sh_eth_close,
 	.ndo_start_xmit		= sh_eth_start_xmit,
 	.ndo_get_stats		= sh_eth_get_stats,
-#if defined(SH_ETH_HAS_TSU)
-	.ndo_set_rx_mode	= sh_eth_set_multicast_list,
-	.ndo_vlan_rx_add_vid	= sh_eth_vlan_rx_add_vid,
-	.ndo_vlan_rx_kill_vid	= sh_eth_vlan_rx_kill_vid,
-#endif
 	.ndo_tx_timeout		= sh_eth_tx_timeout,
 	.ndo_do_ioctl		= sh_eth_do_ioctl,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -2687,6 +2676,15 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 	sh_eth_set_default_cpu_data(mdp->cd);
 
 	/* set function */
+	if (mdp->cd->tsu) {
+		sh_eth_netdev_ops.ndo_set_rx_mode
+			= sh_eth_set_multicast_list;
+		sh_eth_netdev_ops.ndo_vlan_rx_add_vid
+			= sh_eth_vlan_rx_add_vid;
+		sh_eth_netdev_ops.ndo_vlan_rx_kill_vid
+			= sh_eth_vlan_rx_kill_vid;
+	}
+
 	ndev->netdev_ops = &sh_eth_netdev_ops;
 	SET_ETHTOOL_OPS(ndev, &sh_eth_ethtool_ops);
 	ndev->watchdog_timeo = TX_TIMEOUT;
-- 
1.7.10.4
