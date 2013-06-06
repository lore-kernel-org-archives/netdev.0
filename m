From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v5 4/8] sh_eth: remove SH_ETH_HAS_TSU
Date: Thu, 6 Jun 2013 23:48:09 +0400
Message-ID: <201306062348.09927.sergei.shtylyov@cogentembedded.com>
References: <201306062339.21353.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:60422 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754333Ab3FFTsF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jun 2013 15:48:05 -0400
Received: by mail-la0-f41.google.com with SMTP id fn20so2980265lab.14
        for <netdev@vger.kernel.org>; Thu, 06 Jun 2013 12:48:03 -0700 (PDT)
In-Reply-To: <201306062339.21353.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

Remove SH_ETH_HAS_TSU #define's and #ifdef's. Set three 'struct net_device_ops'
methods that depend on the presence of TSU basing on the 'tsu' field of 'struct
sh_eth_cpu_data'.

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
[Sergei: made two method assignments one-liners, added the changelog, reworded
the subject, changing the prefix.]
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Changes in version 4:
- made two method assignments one-liners;
- refreshed the patch;
- added the changelog;
- reworded the subject, changing the prefix.

 drivers/net/ethernet/renesas/sh_eth.c |   20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -431,7 +431,6 @@ static struct sh_eth_cpu_data sh_eth_my_
 };
 #elif defined(CONFIG_CPU_SUBTYPE_SH7757)
 #define SH_ETH_HAS_BOTH_MODULES	1
-#define SH_ETH_HAS_TSU	1
 static int sh_eth_check_reset(struct net_device *ndev);
 
 static void sh_eth_set_rate(struct net_device *ndev)
@@ -592,7 +591,6 @@ static struct sh_eth_cpu_data *sh_eth_ge
 }
 
 #elif defined(CONFIG_CPU_SUBTYPE_SH7734) || defined(CONFIG_CPU_SUBTYPE_SH7763)
-#define SH_ETH_HAS_TSU	1
 static int sh_eth_check_reset(struct net_device *ndev);
 static void sh_eth_reset_hw_crc(struct net_device *ndev);
 
@@ -693,7 +691,6 @@ static void sh_eth_reset_hw_crc(struct n
 }
 
 #elif defined(CONFIG_ARCH_R8A7740)
-#define SH_ETH_HAS_TSU	1
 static int sh_eth_check_reset(struct net_device *ndev);
 
 static void sh_eth_chip_reset(struct net_device *ndev)
@@ -791,7 +788,6 @@ static struct sh_eth_cpu_data sh_eth_my_
 };
 #elif defined(CONFIG_CPU_SUBTYPE_SH7710) || defined(CONFIG_CPU_SUBTYPE_SH7712)
 #define SH_ETH_RESET_DEFAULT	1
-#define SH_ETH_HAS_TSU	1
 static struct sh_eth_cpu_data sh_eth_my_cpu_data = {
 	.eesipr_value	= DMAC_M_RFRMER | DMAC_M_ECI | 0x003fffff,
 	.tsu		= 1,
@@ -2105,7 +2101,6 @@ static int sh_eth_do_ioctl(struct net_de
 	return phy_mii_ioctl(phydev, rq, cmd);
 }
 
-#if defined(SH_ETH_HAS_TSU)
 /* For TSU_POSTn. Please refer to the manual about this (strange) bitfields */
 static void *sh_eth_tsu_get_post_reg_offset(struct sh_eth_private *mdp,
 					    int entry)
@@ -2448,7 +2443,6 @@ static int sh_eth_vlan_rx_kill_vid(struc
 
 	return 0;
 }
-#endif /* SH_ETH_HAS_TSU */
 
 /* SuperH's TSU register init function */
 static void sh_eth_tsu_init(struct sh_eth_private *mdp)
@@ -2587,16 +2581,11 @@ static const u16 *sh_eth_get_register_of
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
@@ -2677,6 +2666,13 @@ static int sh_eth_drv_probe(struct platf
 	sh_eth_set_default_cpu_data(mdp->cd);
 
 	/* set function */
+	if (mdp->cd->tsu) {
+		sh_eth_netdev_ops.ndo_set_rx_mode = sh_eth_set_multicast_list;
+		sh_eth_netdev_ops.ndo_vlan_rx_add_vid = sh_eth_vlan_rx_add_vid;
+		sh_eth_netdev_ops.ndo_vlan_rx_kill_vid =
+			sh_eth_vlan_rx_kill_vid;
+	}
+
 	ndev->netdev_ops = &sh_eth_netdev_ops;
 	SET_ETHTOOL_OPS(ndev, &sh_eth_ethtool_ops);
 	ndev->watchdog_timeo = TX_TIMEOUT;
