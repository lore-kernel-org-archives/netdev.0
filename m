From: frank.blaschka@de.ibm.com
Subject: [patch 5/5] qeth: fix usage of netdev_ops
Date: Fri, 09 Jan 2009 14:44:00 +0100
Message-ID: <20090109134443.557577000@de.ibm.com>
References: <20090109134355.784732000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:34180 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753442AbZAINoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 08:44:46 -0500
Content-Disposition: inline; filename=qeth_fix_devops.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Have separate netdev_ops for OSA and HiperSocket/TR. 

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c |    2 +-
 drivers/s390/net/qeth_l3_main.c |   24 ++++++++++++++++++++----
 2 files changed, 21 insertions(+), 5 deletions(-)

Index: git_linus/drivers/s390/net/qeth_l2_main.c
===================================================================
--- git_linus.orig/drivers/s390/net/qeth_l2_main.c
+++ git_linus/drivers/s390/net/qeth_l2_main.c
@@ -916,7 +916,7 @@ static struct ethtool_ops qeth_l2_osn_op
 	.get_drvinfo = qeth_core_get_drvinfo,
 };
 
-static struct net_device_ops qeth_l2_netdev_ops = {
+static const struct net_device_ops qeth_l2_netdev_ops = {
 	.ndo_open		= qeth_l2_open,
 	.ndo_stop		= qeth_l2_stop,
 	.ndo_get_stats		= qeth_get_stats,
Index: git_linus/drivers/s390/net/qeth_l3_main.c
===================================================================
--- git_linus.orig/drivers/s390/net/qeth_l3_main.c
+++ git_linus/drivers/s390/net/qeth_l3_main.c
@@ -2894,7 +2894,7 @@ qeth_l3_neigh_setup(struct net_device *d
 	return 0;
 }
 
-static struct net_device_ops qeth_l3_netdev_ops = {
+static const struct net_device_ops qeth_l3_netdev_ops = {
 	.ndo_open		= qeth_l3_open,
 	.ndo_stop		= qeth_l3_stop,
 	.ndo_get_stats		= qeth_get_stats,
@@ -2909,6 +2909,22 @@ static struct net_device_ops qeth_l3_net
 	.ndo_tx_timeout	   	= qeth_tx_timeout,
 };
 
+static const struct net_device_ops qeth_l3_osa_netdev_ops = {
+	.ndo_open		= qeth_l3_open,
+	.ndo_stop		= qeth_l3_stop,
+	.ndo_get_stats		= qeth_get_stats,
+	.ndo_start_xmit		= qeth_l3_hard_start_xmit,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_multicast_list = qeth_l3_set_multicast_list,
+	.ndo_do_ioctl	   	= qeth_l3_do_ioctl,
+	.ndo_change_mtu	   	= qeth_change_mtu,
+	.ndo_vlan_rx_register	= qeth_l3_vlan_rx_register,
+	.ndo_vlan_rx_add_vid	= qeth_l3_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid   = qeth_l3_vlan_rx_kill_vid,
+	.ndo_tx_timeout	   	= qeth_tx_timeout,
+	.ndo_neigh_setup	= qeth_l3_neigh_setup,
+};
+
 static int qeth_l3_setup_netdev(struct qeth_card *card)
 {
 	if (card->info.type == QETH_CARD_TYPE_OSAE) {
@@ -2919,12 +2935,12 @@ static int qeth_l3_setup_netdev(struct q
 #endif
 			if (!card->dev)
 				return -ENODEV;
+			card->dev->netdev_ops = &qeth_l3_netdev_ops;
 		} else {
 			card->dev = alloc_etherdev(0);
 			if (!card->dev)
 				return -ENODEV;
-			qeth_l3_netdev_ops.ndo_neigh_setup =
-				qeth_l3_neigh_setup;
+			card->dev->netdev_ops = &qeth_l3_osa_netdev_ops;
 
 			/*IPv6 address autoconfiguration stuff*/
 			qeth_l3_get_unique_id(card);
@@ -2937,6 +2953,7 @@ static int qeth_l3_setup_netdev(struct q
 		if (!card->dev)
 			return -ENODEV;
 		card->dev->flags |= IFF_NOARP;
+		card->dev->netdev_ops = &qeth_l3_netdev_ops;
 		qeth_l3_iqd_read_initial_mac(card);
 	} else
 		return -ENODEV;
@@ -2944,7 +2961,6 @@ static int qeth_l3_setup_netdev(struct q
 	card->dev->ml_priv = card;
 	card->dev->watchdog_timeo = QETH_TX_TIMEOUT;
 	card->dev->mtu = card->info.initial_mtu;
-	card->dev->netdev_ops = &qeth_l3_netdev_ops;
 	SET_ETHTOOL_OPS(card->dev, &qeth_l3_ethtool_ops);
 	card->dev->features |=	NETIF_F_HW_VLAN_TX |
 				NETIF_F_HW_VLAN_RX |

-- 
