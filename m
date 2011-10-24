From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: |PATCH net-next] tg3: add tx_dropped counter
Date: Mon, 24 Oct 2011 19:53:03 +0200
Message-ID: <1319478783.3064.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:49178 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754834Ab1JXRxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2011 13:53:08 -0400
Received: by wwe6 with SMTP id 6so9330257wwe.1
        for <netdev@vger.kernel.org>; Mon, 24 Oct 2011 10:53:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a frame cant be transmitted, it is silently discarded.

Add a counter to report these errors to user.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
Note : merge errors expected because of pending tg3 patch in net tree, I
can respin if needed.

 drivers/net/ethernet/broadcom/tg3.c |   23 +++++++++++------------
 drivers/net/ethernet/broadcom/tg3.h |    1 +
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index b89027c..3447585 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -6671,10 +6671,8 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		u32 tcp_opt_len, hdr_len;
 
 		if (skb_header_cloned(skb) &&
-		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
-			dev_kfree_skb(skb);
-			goto out_unlock;
-		}
+		    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+			goto drop;
 
 		iph = ip_hdr(skb);
 		tcp_opt_len = tcp_optlen(skb);
@@ -6746,10 +6744,9 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	len = skb_headlen(skb);
 
 	mapping = pci_map_single(tp->pdev, skb->data, len, PCI_DMA_TODEVICE);
-	if (pci_dma_mapping_error(tp->pdev, mapping)) {
-		dev_kfree_skb(skb);
-		goto out_unlock;
-	}
+	if (pci_dma_mapping_error(tp->pdev, mapping))
+		goto drop;
+
 
 	tnapi->tx_buffers[entry].skb = skb;
 	dma_unmap_addr_set(&tnapi->tx_buffers[entry], mapping, mapping);
@@ -6805,7 +6802,7 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		budget = tg3_tx_avail(tnapi);
 		if (tigon3_dma_hwbug_workaround(tnapi, skb, &entry, &budget,
 						base_flags, mss, vlan))
-			goto out_unlock;
+			goto drop_nofree;
 	}
 
 	skb_tx_timestamp(skb);
@@ -6827,15 +6824,16 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			netif_tx_wake_queue(txq);
 	}
 
-out_unlock:
 	mmiowb();
-
 	return NETDEV_TX_OK;
 
 dma_error:
 	tg3_tx_skb_unmap(tnapi, tnapi->tx_prod, i);
-	dev_kfree_skb(skb);
 	tnapi->tx_buffers[tnapi->tx_prod].skb = NULL;
+drop:
+	dev_kfree_skb(skb);
+drop_nofree:
+	tp->tx_dropped++;
 	return NETDEV_TX_OK;
 }
 
@@ -10009,6 +10007,7 @@ static struct rtnl_link_stats64 *tg3_get_stats64(struct net_device *dev,
 		get_stat64(&hw_stats->rx_discards);
 
 	stats->rx_dropped = tp->rx_dropped;
+	stats->tx_dropped = tp->tx_dropped;
 
 	return stats;
 }
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index d2976f3..f32f288 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2990,6 +2990,7 @@ struct tg3 {
 
 	/* begin "everything else" cacheline(s) section */
 	unsigned long			rx_dropped;
+	unsigned long			tx_dropped;
 	struct rtnl_link_stats64	net_stats_prev;
 	struct tg3_ethtool_stats	estats;
 	struct tg3_ethtool_stats	estats_prev;
