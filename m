From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 06/12] ip_tunnel: push generic protocol handling to ip_tunnel module.
Date: Thu, 13 Jun 2013 11:24:44 -0700
Message-ID: <1371147884-9323-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog130.obsmtp.com ([74.125.149.143]:56100 "HELO
	na3sys009aog130.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758966Ab3FMSYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 14:24:50 -0400
Received: by mail-pd0-f180.google.com with SMTP id 10so11569223pdi.39
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 11:24:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Process skb tunnel header before sending packet to protocol handler.
this allows code sharing between gre and ovs gre modules.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/net/ip_tunnels.h  |    1 +
 net/ipv4/gre.c            |    3 ++-
 net/ipv4/ip_tunnel.c      |   30 ++++++------------------------
 net/ipv4/ip_tunnel_core.c |   33 +++++++++++++++++++++++++++++++++
 net/ipv4/ipip.c           |    6 +++++-
 net/ipv6/sit.c            |    7 ++++++-
 6 files changed, 53 insertions(+), 27 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 788fa5d..048a97f 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -155,6 +155,7 @@ static inline void tunnel_ip_select_ident(struct sk_buff *skb,
 				  (skb_shinfo(skb)->gso_segs ?: 1) - 1);
 }
 
+int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto);
 int iptunnel_xmit(struct net *net, struct rtable *rt,
 		  struct sk_buff *skb,
 		  __be32 src, __be32 dst, __u8 proto,
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index 5ecc9c4..ba4803e 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -201,7 +201,8 @@ static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 				return -EINVAL;
 		}
 	}
-	return 0;
+
+	return iptunnel_pull_header(skb, hdr_len, tpi->proto);
 }
 
 static int gre_cisco_rcv(struct sk_buff *skb)
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index b7b8d15..c41faf8 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -408,13 +408,6 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 	const struct iphdr *iph = ip_hdr(skb);
 	int err;
 
-	secpath_reset(skb);
-
-	skb->protocol = tpi->proto;
-
-	skb->mac_header = skb->network_header;
-	__pskb_pull(skb, tunnel->hlen);
-	skb_postpull_rcsum(skb, skb_transport_header(skb), tunnel->hlen);
 #ifdef CONFIG_NET_IPGRE_BROADCAST
 	if (ipv4_is_multicast(iph->daddr)) {
 		/* Looped back packet, drop it! */
@@ -442,23 +435,6 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 		tunnel->i_seqno = ntohl(tpi->seq) + 1;
 	}
 
-	/* Warning: All skb pointers will be invalidated! */
-	if (tunnel->dev->type == ARPHRD_ETHER) {
-		if (!pskb_may_pull(skb, ETH_HLEN)) {
-			tunnel->dev->stats.rx_length_errors++;
-			tunnel->dev->stats.rx_errors++;
-			goto drop;
-		}
-
-		iph = ip_hdr(skb);
-		skb->protocol = eth_type_trans(skb, tunnel->dev);
-		skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
-	}
-
-	skb->pkt_type = PACKET_HOST;
-	__skb_tunnel_rx(skb, tunnel->dev);
-
-	skb_reset_network_header(skb);
 	err = IP_ECN_decapsulate(iph, skb);
 	if (unlikely(err)) {
 		if (log_ecn_error)
@@ -477,6 +453,12 @@ int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
 	tstats->rx_bytes += skb->len;
 	u64_stats_update_end(&tstats->syncp);
 
+	if (tunnel->dev->type == ARPHRD_ETHER) {
+		skb->protocol = eth_type_trans(skb, tunnel->dev);
+		skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
+	} else {
+		skb->dev = tunnel->dev;
+	}
 	gro_cells_receive(&tunnel->gro_cells, skb);
 	return 0;
 
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 927687e..6007518 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -86,3 +86,36 @@ int iptunnel_xmit(struct net *net, struct rtable *rt,
 	return pkt_len;
 }
 EXPORT_SYMBOL_GPL(iptunnel_xmit);
+
+int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto)
+{
+	if (unlikely(!pskb_may_pull(skb, hdr_len)))
+		return -ENOMEM;
+
+	skb_pull_rcsum(skb, hdr_len);
+
+	if (inner_proto == htons(ETH_P_TEB)) {
+		struct ethhdr *eh = (struct ethhdr *)skb->data;
+
+		if (unlikely(!pskb_may_pull(skb, ETH_HLEN)))
+			return -ENOMEM;
+
+		if (likely(ntohs(eh->h_proto) >= ETH_P_802_3_MIN))
+			skb->protocol = eh->h_proto;
+		else
+			skb->protocol = htons(ETH_P_802_2);
+
+	} else {
+		skb->protocol = inner_proto;
+	}
+
+	nf_reset(skb);
+	secpath_reset(skb);
+	skb->rxhash = 0;
+	skb_dst_drop(skb);
+	skb->vlan_tci = 0;
+	skb_set_queue_mapping(skb, 0);
+	skb->pkt_type = PACKET_HOST;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(iptunnel_pull_header);
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 9df7ecd..e6905fb 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -188,8 +188,12 @@ static int ipip_rcv(struct sk_buff *skb)
 	struct net *net = dev_net(skb->dev);
 	struct ip_tunnel_net *itn = net_generic(net, ipip_net_id);
 	struct ip_tunnel *tunnel;
-	const struct iphdr *iph = ip_hdr(skb);
+	const struct iphdr *iph;
 
+	if (iptunnel_pull_header(skb, 0, tpi.proto))
+		goto drop;
+
+	iph = ip_hdr(skb);
 	tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex, TUNNEL_NO_KEY,
 			iph->saddr, iph->daddr, 0);
 	if (tunnel) {
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 76bb8de..6cee844 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -640,9 +640,14 @@ static const struct tnl_ptk_info tpi = {
 
 static int ipip_rcv(struct sk_buff *skb)
 {
-	const struct iphdr *iph = ip_hdr(skb);
+	const struct iphdr *iph;
 	struct ip_tunnel *tunnel;
 
+	if (iptunnel_pull_header(skb, 0, tpi.proto))
+		goto drop;
+
+	iph = ip_hdr(skb);
+
 	tunnel = ipip6_tunnel_lookup(dev_net(skb->dev), skb->dev,
 				     iph->saddr, iph->daddr);
 	if (tunnel != NULL) {
-- 
1.7.1
