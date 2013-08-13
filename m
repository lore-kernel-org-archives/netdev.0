From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next v2 1/4] dev: move skb_scrub_packet() after eth_type_trans()
Date: Tue, 13 Aug 2013 17:51:09 +0200
Message-ID: <1376409072-6414-2-git-send-email-nicolas.dichtel@6wind.com>
References: <20130704.145621.2060744817757546493.davem@davemloft.net>
 <1376409072-6414-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com, bcrl@kvack.org,
	ravi.mlists@gmail.com, bhutchings@solarflare.com,
	eric.dumazet@gmail.com, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:35960 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758352Ab3HMPvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 11:51:38 -0400
In-Reply-To: <1376409072-6414-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_scrub_packet() was called before eth_type_trans() to let eth_type_trans()
set pkt_type.

In fact, we should force pkt_type to PACKET_HOST, so move the call after
eth_type_trans().

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/dev.c       | 6 +++---
 net/ipv4/ip_tunnel.c | 7 ++++---
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 58eb802584b9..1ed2b66a10a6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1691,13 +1691,13 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
-	skb_scrub_packet(skb);
 	skb->protocol = eth_type_trans(skb, dev);
 
 	/* eth_type_trans() can set pkt_type.
-	 * clear pkt_type _after_ calling eth_type_trans()
+	 * call skb_scrub_packet() after it to clear pkt_type _after_ calling
+	 * eth_type_trans().
 	 */
-	skb->pkt_type = PACKET_HOST;
+	skb_scrub_packet(skb);
 
 	return netif_rx(skb);
 }
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 9fdf8a6d95f3..fbc1094964bf 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -454,15 +454,16 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 	tstats->rx_bytes += skb->len;
 	u64_stats_update_end(&tstats->syncp);
 
-	if (tunnel->net != dev_net(tunnel->dev))
-		skb_scrub_packet(skb);
-
 	if (tunnel->dev->type == ARPHRD_ETHER) {
 		skb->protocol = eth_type_trans(skb, tunnel->dev);
 		skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
 	} else {
 		skb->dev = tunnel->dev;
 	}
+
+	if (tunnel->net != dev_net(tunnel->dev))
+		skb_scrub_packet(skb);
+
 	gro_cells_receive(&tunnel->gro_cells, skb);
 	return 0;
 
-- 
1.8.2.1
