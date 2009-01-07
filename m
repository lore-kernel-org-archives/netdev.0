From: frank.blaschka@de.ibm.com
Subject: [patch 2/2] qeth: convert to net_device_ops
Date: Wed, 07 Jan 2009 13:15:52 +0100
Message-ID: <20090107121700.139748000@de.ibm.com>
References: <20090107121550.878339000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:47171 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874AbZAGMRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 07:17:03 -0500
Content-Disposition: inline; filename=qeth-devops.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

qeth_l2, qeth_l3 convert to net_device_ops.
qeth_l3 remove vlan neigh_setup hack since it does not work any longer
with the new net_device_ops.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c |   27 ++++++++++++--------
 drivers/s390/net/qeth_l3_main.c |   53 +++++++++++++---------------------------
 2 files changed, 34 insertions(+), 46 deletions(-)

Index: git_linus/drivers/s390/net/qeth_l2_main.c
===================================================================
--- git_linus.orig/drivers/s390/net/qeth_l2_main.c
+++ git_linus/drivers/s390/net/qeth_l2_main.c
@@ -916,6 +916,21 @@ static struct ethtool_ops qeth_l2_osn_op
 	.get_drvinfo = qeth_core_get_drvinfo,
 };
 
+static struct net_device_ops qeth_l2_netdev_ops = {
+	.ndo_open		= qeth_l2_open,
+	.ndo_stop		= qeth_l2_stop,
+	.ndo_get_stats		= qeth_get_stats,
+	.ndo_start_xmit		= qeth_l2_hard_start_xmit,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_multicast_list = qeth_l2_set_multicast_list,
+	.ndo_do_ioctl	   	= qeth_l2_do_ioctl,
+	.ndo_set_mac_address    = qeth_l2_set_mac_address,
+	.ndo_change_mtu	   	= qeth_change_mtu,
+	.ndo_vlan_rx_add_vid	= qeth_l2_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid   = qeth_l2_vlan_rx_kill_vid,
+	.ndo_tx_timeout	   	= qeth_tx_timeout,
+};
+
 static int qeth_l2_setup_netdev(struct qeth_card *card)
 {
 	switch (card->info.type) {
@@ -937,19 +952,9 @@ static int qeth_l2_setup_netdev(struct q
 		return -ENODEV;
 
 	card->dev->ml_priv = card;
-	card->dev->tx_timeout = &qeth_tx_timeout;
 	card->dev->watchdog_timeo = QETH_TX_TIMEOUT;
-	card->dev->open = qeth_l2_open;
-	card->dev->stop = qeth_l2_stop;
-	card->dev->hard_start_xmit = qeth_l2_hard_start_xmit;
-	card->dev->do_ioctl = qeth_l2_do_ioctl;
-	card->dev->get_stats = qeth_get_stats;
-	card->dev->change_mtu = qeth_change_mtu;
-	card->dev->set_multicast_list = qeth_l2_set_multicast_list;
-	card->dev->vlan_rx_kill_vid = qeth_l2_vlan_rx_kill_vid;
-	card->dev->vlan_rx_add_vid = qeth_l2_vlan_rx_add_vid;
-	card->dev->set_mac_address = qeth_l2_set_mac_address;
 	card->dev->mtu = card->info.initial_mtu;
+	card->dev->netdev_ops = &qeth_l2_netdev_ops;
 	if (card->info.type != QETH_CARD_TYPE_OSN)
 		SET_ETHTOOL_OPS(card->dev, &qeth_l2_ethtool_ops);
 	else
Index: git_linus/drivers/s390/net/qeth_l3_main.c
===================================================================
--- git_linus.orig/drivers/s390/net/qeth_l3_main.c
+++ git_linus/drivers/s390/net/qeth_l3_main.c
@@ -1829,28 +1829,6 @@ static void qeth_l3_vlan_rx_register(str
 
 static void qeth_l3_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 {
-	struct net_device *vlandev;
-	struct qeth_card *card = dev->ml_priv;
-	struct in_device *in_dev;
-
-	if (card->info.type == QETH_CARD_TYPE_IQD)
-		return;
-
-	vlandev = vlan_group_get_device(card->vlangrp, vid);
-	vlandev->neigh_setup = qeth_l3_neigh_setup;
-
-	in_dev = in_dev_get(vlandev);
-#ifdef CONFIG_SYSCTL
-	neigh_sysctl_unregister(in_dev->arp_parms);
-#endif
-	neigh_parms_release(&arp_tbl, in_dev->arp_parms);
-
-	in_dev->arp_parms = neigh_parms_alloc(vlandev, &arp_tbl);
-#ifdef CONFIG_SYSCTL
-	neigh_sysctl_register(vlandev, in_dev->arp_parms, NET_IPV4,
-			      NET_IPV4_NEIGH, "ipv4", NULL, NULL);
-#endif
-	in_dev_put(in_dev);
 	return;
 }
 
@@ -2916,6 +2894,21 @@ qeth_l3_neigh_setup(struct net_device *d
 	return 0;
 }
 
+static struct net_device_ops qeth_l3_netdev_ops = {
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
+};
+
 static int qeth_l3_setup_netdev(struct qeth_card *card)
 {
 	if (card->info.type == QETH_CARD_TYPE_OSAE) {
@@ -2930,7 +2923,8 @@ static int qeth_l3_setup_netdev(struct q
 			card->dev = alloc_etherdev(0);
 			if (!card->dev)
 				return -ENODEV;
-			card->dev->neigh_setup = qeth_l3_neigh_setup;
+			qeth_l3_netdev_ops.ndo_neigh_setup =
+				qeth_l3_neigh_setup;
 
 			/*IPv6 address autoconfiguration stuff*/
 			qeth_l3_get_unique_id(card);
@@ -2947,21 +2941,10 @@ static int qeth_l3_setup_netdev(struct q
 	} else
 		return -ENODEV;
 
-	card->dev->hard_start_xmit = qeth_l3_hard_start_xmit;
 	card->dev->ml_priv = card;
-	card->dev->tx_timeout = &qeth_tx_timeout;
 	card->dev->watchdog_timeo = QETH_TX_TIMEOUT;
-	card->dev->open = qeth_l3_open;
-	card->dev->stop = qeth_l3_stop;
-	card->dev->do_ioctl = qeth_l3_do_ioctl;
-	card->dev->get_stats = qeth_get_stats;
-	card->dev->change_mtu = qeth_change_mtu;
-	card->dev->set_multicast_list = qeth_l3_set_multicast_list;
-	card->dev->vlan_rx_register = qeth_l3_vlan_rx_register;
-	card->dev->vlan_rx_add_vid = qeth_l3_vlan_rx_add_vid;
-	card->dev->vlan_rx_kill_vid = qeth_l3_vlan_rx_kill_vid;
 	card->dev->mtu = card->info.initial_mtu;
-	card->dev->set_mac_address = NULL;
+	card->dev->netdev_ops = &qeth_l3_netdev_ops;
 	SET_ETHTOOL_OPS(card->dev, &qeth_l3_ethtool_ops);
 	card->dev->features |=	NETIF_F_HW_VLAN_TX |
 				NETIF_F_HW_VLAN_RX |

-- 
