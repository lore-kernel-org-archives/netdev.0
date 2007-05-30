From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] spidernet: checksum and ethtool
Date: Tue, 29 May 2007 17:24:36 -0700
Message-ID: <20070529172436.3cd60dcf@freepuppy>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:46647 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750796AbXE3Afu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2007 20:35:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It doesn't look like spidernet hardware can really checksum all protocols,
the code looks like it does IPV4 only.  If so, it should use NETIF_F_IP_CSUM
instead of NETIF_F_HW_CSUM.

The driver doesn't need it's own get/set for ethtool tx csum, and it
should use the standard ethtool_op_get_link.

NOT TESTED (no CELL hardware).

---
 drivers/net/spider_net.c         |    4 ++--
 drivers/net/spider_net_ethtool.c |   21 +++------------------
 2 files changed, 5 insertions(+), 20 deletions(-)

--- a/drivers/net/spider_net.c	2007-05-29 16:44:35.000000000 -0700
+++ b/drivers/net/spider_net.c	2007-05-29 17:19:52.000000000 -0700
@@ -718,7 +718,7 @@ spider_net_prepare_tx_descr(struct spide
 			SPIDER_NET_DESCR_CARDOWNED | SPIDER_NET_DMAC_NOCS;
 	spin_unlock_irqrestore(&chain->lock, flags);
 
-	if (skb->protocol == htons(ETH_P_IP) && skb->ip_summed == CHECKSUM_PARTIAL)
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		switch (ip_hdr(skb)->protocol) {
 		case IPPROTO_TCP:
 			hwdescr->dmac_cmd_status |= SPIDER_NET_DMAC_TCP;
@@ -2225,7 +2225,7 @@ spider_net_setup_netdev(struct spider_ne
 
 	spider_net_setup_netdev_ops(netdev);
 
-	netdev->features = NETIF_F_HW_CSUM | NETIF_F_LLTX;
+	netdev->features = NETIF_F_IP_CSUM | NETIF_F_LLTX;
 	/* some time: NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
 	 *		NETIF_F_HW_VLAN_FILTER */
 
--- a/drivers/net/spider_net_ethtool.c	2007-05-29 17:19:52.000000000 -0700
+++ b/drivers/net/spider_net_ethtool.c	2007-05-29 17:24:08.000000000 -0700
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
