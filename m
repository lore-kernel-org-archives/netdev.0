From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH v3 5/9] net: sh-eth: Remove SH_ETH_HAS_TSU and use tsu of sh_eth_cpu_data instead
Date: Tue,  7 May 2013 14:17:51 +0900
Message-ID: <1367903875-32606-5-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
References: <1367903875-32606-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: yoshihiro.shimoda.uh@renesas.com,
	sergei.shtylyov@cogentembedded.com,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:49208 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015Ab3EGFSV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 01:18:21 -0400
Received: by mail-da0-f45.google.com with SMTP id w3so116518dad.32
        for <netdev@vger.kernel.org>; Mon, 06 May 2013 22:18:20 -0700 (PDT)
In-Reply-To: <1367903875-32606-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
V3:
  no change.
V2:
  no change.
 drivers/net/ethernet/renesas/sh_eth.c |   22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 944b2df..667c908 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -431,7 +431,6 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 };
 #elif defined(CONFIG_CPU_SUBTYPE_SH7757)
 #define SH_ETH_HAS_BOTH_MODULES	1
-#define SH_ETH_HAS_TSU	1
 static int sh_eth_check_reset(struct net_device *ndev);
 
 static void sh_eth_set_rate(struct net_device *ndev)
@@ -593,7 +592,6 @@ static struct sh_eth_cpu_data *sh_eth_get_cpu_data(struct sh_eth_private *mdp)
 }
 
 #elif defined(CONFIG_CPU_SUBTYPE_SH7734) || defined(CONFIG_CPU_SUBTYPE_SH7763)
-#define SH_ETH_HAS_TSU	1
 static int sh_eth_check_reset(struct net_device *ndev);
 static void sh_eth_reset_hw_crc(struct net_device *ndev);
 
@@ -696,7 +694,6 @@ static void sh_eth_reset_hw_crc(struct net_device *ndev)
 }
 
 #elif defined(CONFIG_ARCH_R8A7740)
-#define SH_ETH_HAS_TSU	1
 static int sh_eth_check_reset(struct net_device *ndev);
 
 static void sh_eth_chip_reset(struct net_device *ndev)
@@ -794,7 +791,6 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 };
 #elif defined(CONFIG_CPU_SUBTYPE_SH7710) || defined(CONFIG_CPU_SUBTYPE_SH7712)
 #define SH_ETH_RESET_DEFAULT	1
-#define SH_ETH_HAS_TSU	1
 static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 	.tsu		= 1,
@@ -2109,7 +2105,6 @@ static int sh_eth_do_ioctl(struct net_device *ndev, struct ifreq *rq,
 	return phy_mii_ioctl(phydev, rq, cmd);
 }
 
-#if defined(SH_ETH_HAS_TSU)
 /* For TSU_POSTn. Please refer to the manual about this (strange) bitfields */
 static void *sh_eth_tsu_get_post_reg_offset(struct sh_eth_private *mdp,
 					    int entry)
@@ -2452,7 +2447,6 @@ static int sh_eth_vlan_rx_kill_vid(struct net_device *ndev,
 
 	return 0;
 }
-#endif /* SH_ETH_HAS_TSU */
 
 /* SuperH's TSU register init function */
 static void sh_eth_tsu_init(struct sh_eth_private *mdp)
@@ -2591,16 +2585,11 @@ static const u16 *sh_eth_get_register_offset(int register_type)
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
@@ -2681,6 +2670,15 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
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
