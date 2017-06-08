From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: [PATCH] geneve: add missing rx stats accounting
Date: Thu,  8 Jun 2017 11:39:49 -0700
Message-ID: <1496947189-19773-1-git-send-email-girish.moodalbail@oracle.com>
Cc: davem@davemloft.net, pshelar@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:33317 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751505AbdFHSxK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 14:53:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are few places on the receive path where packet drops and packet
errors were not accounted for. This patch fixes that issue.

Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
---
 drivers/net/geneve.c | 36 ++++++++++++++++++++++++------------
 1 file changed, 24 insertions(+), 12 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 6ebb0f5..34a4d45 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -212,6 +212,7 @@ static void geneve_rx(struct geneve_dev *geneve, struct geneve_sock *gs,
 	struct genevehdr *gnvh = geneve_hdr(skb);
 	struct metadata_dst *tun_dst = NULL;
 	struct pcpu_sw_netstats *stats;
+	unsigned int len;
 	int err = 0;
 	void *oiph;
 
@@ -225,8 +226,10 @@ static void geneve_rx(struct geneve_dev *geneve, struct geneve_sock *gs,
 		tun_dst = udp_tun_rx_dst(skb, geneve_get_sk_family(gs), flags,
 					 vni_to_tunnel_id(gnvh->vni),
 					 gnvh->opt_len * 4);
-		if (!tun_dst)
+		if (!tun_dst) {
+			++geneve->dev->stats.rx_dropped;
 			goto drop;
+		}
 		/* Update tunnel dst according to Geneve options. */
 		ip_tunnel_info_opts_set(&tun_dst->u.tun_info,
 					gnvh->options, gnvh->opt_len * 4);
@@ -234,8 +237,11 @@ static void geneve_rx(struct geneve_dev *geneve, struct geneve_sock *gs,
 		/* Drop packets w/ critical options,
 		 * since we don't support any...
 		 */
-		if (gnvh->critical)
+		if (gnvh->critical) {
+			++geneve->dev->stats.rx_frame_errors;
+			++geneve->dev->stats.rx_errors;
 			goto drop;
+		}
 	}
 
 	skb_reset_mac_header(skb);
@@ -246,8 +252,10 @@ static void geneve_rx(struct geneve_dev *geneve, struct geneve_sock *gs,
 		skb_dst_set(skb, &tun_dst->dst);
 
 	/* Ignore packet loops (and multicast echo) */
-	if (ether_addr_equal(eth_hdr(skb)->h_source, geneve->dev->dev_addr))
+	if (ether_addr_equal(eth_hdr(skb)->h_source, geneve->dev->dev_addr)) {
+		++geneve->dev->stats.rx_errors;
 		goto drop;
+	}
 
 	oiph = skb_network_header(skb);
 	skb_reset_network_header(skb);
@@ -279,13 +287,15 @@ static void geneve_rx(struct geneve_dev *geneve, struct geneve_sock *gs,
 		}
 	}
 
-	stats = this_cpu_ptr(geneve->dev->tstats);
-	u64_stats_update_begin(&stats->syncp);
-	stats->rx_packets++;
-	stats->rx_bytes += skb->len;
-	u64_stats_update_end(&stats->syncp);
-
-	gro_cells_receive(&geneve->gro_cells, skb);
+	len = skb->len;
+	err = gro_cells_receive(&geneve->gro_cells, skb);
+	if (likely(err == NET_RX_SUCCESS)) {
+		stats = this_cpu_ptr(geneve->dev->tstats);
+		u64_stats_update_begin(&stats->syncp);
+		stats->rx_packets++;
+		stats->rx_bytes += len;
+		u64_stats_update_end(&stats->syncp);
+	}
 	return;
 drop:
 	/* Consume bad packet */
@@ -334,7 +344,7 @@ static int geneve_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	struct geneve_sock *gs;
 	int opts_len;
 
-	/* Need Geneve and inner Ethernet header to be present */
+	/* Need UDP and Geneve header to be present */
 	if (unlikely(!pskb_may_pull(skb, GENEVE_BASE_HLEN)))
 		goto drop;
 
@@ -357,8 +367,10 @@ static int geneve_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	opts_len = geneveh->opt_len * 4;
 	if (iptunnel_pull_header(skb, GENEVE_BASE_HLEN + opts_len,
 				 htons(ETH_P_TEB),
-				 !net_eq(geneve->net, dev_net(geneve->dev))))
+				 !net_eq(geneve->net, dev_net(geneve->dev)))) {
+		++geneve->dev->stats.rx_dropped;
 		goto drop;
+	}
 
 	geneve_rx(geneve, gs, skb);
 	return 0;
-- 
1.8.3.1
