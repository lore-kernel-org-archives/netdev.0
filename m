From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 7/15] spidernet: checksum and ethtool
Date: Mon, 11 Jun 2007 13:35:23 -0500
Message-ID: <20070611183522.GG13741@austin.ibm.com>
References: <20070607191707.GA7904@austin.ibm.com> <1181265151.6026.1.camel@concordia.ozlabs.ibm.com> <20070608170608.GI7904@austin.ibm.com> <20070608172020.GA31089@havoc.gtf.org> <20070611181429.GA4397@austin.ibm.com> <20070611181702.GA13741@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Ellerman <michael@ellerman.id.au>, netdev@vger.kernel.org,
	cbe-oss-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:50448 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371AbXFKSf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 14:35:26 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BIZPUs001425
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 14:35:25 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BIZO3o251660
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 12:35:25 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BIZNXe005205
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 12:35:23 -0600
Content-Disposition: inline
In-Reply-To: <20070611181702.GA13741@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Stephen Hemminger <shemminger@linux-foundation.org>

It doesn't look like spidernet hardware can really checksum all protocols,
the code looks like it does IPV4 only.  If so, it should use NETIF_F_IP_CSUM
instead of NETIF_F_HW_CSUM.

The driver doesn't need it's own get/set for ethtool tx csum, and it
should use the standard ethtool_op_get_link.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

-----

 drivers/net/spider_net.c         |    4 ++--
 drivers/net/spider_net_ethtool.c |   21 +++------------------
 2 files changed, 5 insertions(+), 20 deletions(-)

Index: linux-2.6.22-rc1/drivers/net/spider_net.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net.c	2007-06-08 17:28:55.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net.c	2007-06-08 17:28:58.000000000 -0500
@@ -718,7 +718,7 @@ spider_net_prepare_tx_descr(struct spide
 			SPIDER_NET_DESCR_CARDOWNED | SPIDER_NET_DMAC_NOCS;
 	spin_unlock_irqrestore(&chain->lock, flags);
 
-	if (skb->protocol == htons(ETH_P_IP) && skb->ip_summed == CHECKSUM_PARTIAL)
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		switch (ip_hdr(skb)->protocol) {
 		case IPPROTO_TCP:
 			hwdescr->dmac_cmd_status |= SPIDER_NET_DMAC_TCP;
@@ -2300,7 +2300,7 @@ spider_net_setup_netdev(struct spider_ne
 
 	spider_net_setup_netdev_ops(netdev);
 
-	netdev->features = NETIF_F_HW_CSUM | NETIF_F_LLTX;
+	netdev->features = NETIF_F_IP_CSUM | NETIF_F_LLTX;
 	/* some time: NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
 	 *		NETIF_F_HW_VLAN_FILTER */
 
Index: linux-2.6.22-rc1/drivers/net/spider_net_ethtool.c
===================================================================
--- linux-2.6.22-rc1.orig/drivers/net/spider_net_ethtool.c	2007-06-08 17:27:01.000000000 -0500
+++ linux-2.6.22-rc1/drivers/net/spider_net_ethtool.c	2007-06-08 17:28:58.000000000 -0500
@@ -134,22 +134,6 @@ spider_net_ethtool_set_rx_csum(struct ne
 	return 0;
 }
 
-static uint32_t
-spider_net_ethtool_get_tx_csum(struct net_device *netdev)
-{
-        return (netdev->features & NETIF_F_HW_CSUM) != 0;
-}
-
-static int
-spider_net_ethtool_set_tx_csum(struct net_device *netdev, uint32_t data)
-{
-        if (data)
-                netdev->features |= NETIF_F_HW_CSUM;
-        else
-                netdev->features &= ~NETIF_F_HW_CSUM;
-
-        return 0;
-}
 
 static void
 spider_net_ethtool_get_ringparam(struct net_device *netdev,
@@ -200,11 +184,12 @@ const struct ethtool_ops spider_net_etht
 	.get_wol		= spider_net_ethtool_get_wol,
 	.get_msglevel		= spider_net_ethtool_get_msglevel,
 	.set_msglevel		= spider_net_ethtool_set_msglevel,
+	.get_link		= ethtool_op_get_link,
 	.nway_reset		= spider_net_ethtool_nway_reset,
 	.get_rx_csum		= spider_net_ethtool_get_rx_csum,
 	.set_rx_csum		= spider_net_ethtool_set_rx_csum,
-	.get_tx_csum		= spider_net_ethtool_get_tx_csum,
-	.set_tx_csum		= spider_net_ethtool_set_tx_csum,
+	.get_tx_csum		= ethtool_op_get_tx_csum,
+	.set_tx_csum		= ethtool_op_set_tx_csum,
 	.get_ringparam          = spider_net_ethtool_get_ringparam,
 	.get_strings		= spider_net_get_strings,
 	.get_stats_count	= spider_net_get_stats_count,
