From: leitao@linux.vnet.ibm.com
Subject: [PATCH] ehea: Fixing LRO configuration
Date: Wed,  8 Dec 2010 16:31:02 -0200
Message-ID: <1291833062-27446-1-git-send-email-leitao@linux.vnet.ibm.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Breno Leitao <leitao@linux.vnet.ibm.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:51507 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756103Ab0LHSbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 13:31:16 -0500
Received: from mailhub3.br.ibm.com (mailhub3.br.ibm.com [9.18.232.110])
	by e24smtp02.br.ibm.com (8.14.4/8.13.1) with ESMTP id oB8IlTnj028593
	for <netdev@vger.kernel.org>; Wed, 8 Dec 2010 16:47:29 -0200
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB8IcMwP2613460
	for <netdev@vger.kernel.org>; Wed, 8 Dec 2010 16:38:23 -0200
Received: from d24av04.br.ibm.com (loopback [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB8IVB3u004182
	for <netdev@vger.kernel.org>; Wed, 8 Dec 2010 16:31:11 -0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to set LRO on ehea, the user must set a module parameter, which
is not the standard way to do so. This patch adds a way to set LRO using
the ethtool tool.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>

diff --git a/drivers/net/ehea/ehea_ethtool.c b/drivers/net/ehea/ehea_ethtool.c
index 75b099c..1f37ee6 100644
--- a/drivers/net/ehea/ehea_ethtool.c
+++ b/drivers/net/ehea/ehea_ethtool.c
@@ -261,6 +261,13 @@ static void ehea_get_ethtool_stats(struct net_device *dev,
 
 }
 
+static int ehea_set_flags(struct net_device *dev, u32 data)
+{
+	return ethtool_op_set_flags(dev, data, ETH_FLAG_LRO
+					| ETH_FLAG_TXVLAN
+					| ETH_FLAG_RXVLAN);
+}
+
 const struct ethtool_ops ehea_ethtool_ops = {
 	.get_settings = ehea_get_settings,
 	.get_drvinfo = ehea_get_drvinfo,
@@ -273,6 +280,8 @@ const struct ethtool_ops ehea_ethtool_ops = {
 	.get_ethtool_stats = ehea_get_ethtool_stats,
 	.get_rx_csum = ehea_get_rx_csum,
 	.set_settings = ehea_set_settings,
+	.get_flags = ethtool_op_get_flags,
+	.set_flags = ehea_set_flags,
 	.nway_reset = ehea_nway_reset,		/* Restart autonegotiation */
 };
 
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index a84c389..c7132e8 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -675,7 +675,7 @@ static void ehea_proc_skb(struct ehea_port_res *pr, struct ehea_cqe *cqe,
 	int vlan_extracted = ((cqe->status & EHEA_CQE_VLAN_TAG_XTRACT) &&
 			      pr->port->vgrp);
 
-	if (use_lro) {
+	if (skb->dev->features && NETIF_F_LRO) {
 		if (vlan_extracted)
 			lro_vlan_hwaccel_receive_skb(&pr->lro_mgr, skb,
 						     pr->port->vgrp,
@@ -777,7 +777,7 @@ static int ehea_proc_rwqes(struct net_device *dev,
 		}
 		cqe = ehea_poll_rq1(qp, &wqe_index);
 	}
-	if (use_lro)
+	if (dev->features && NETIF_F_LRO)
 		lro_flush_all(&pr->lro_mgr);
 
 	pr->rx_packets += processed;
@@ -3265,6 +3265,9 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER
 		      | NETIF_F_LLTX;
 	dev->watchdog_timeo = EHEA_WATCH_DOG_TIMEOUT;
+
+	if (use_lro)
+		dev->features |= NETIF_F_LRO;
 
 	INIT_WORK(&port->reset_task, ehea_reset_port);
 
-- 
1.7.3.2

