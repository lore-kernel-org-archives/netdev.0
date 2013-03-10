From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] tunnel: use iptunnel_xmit() again
Date: Sun, 10 Mar 2013 10:38:39 +0800
Message-ID: <1362883119-4099-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Pravin B Shelar <pshelar@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:34756 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751843Ab3CJCjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 21:39:06 -0500
Received: by mail-pb0-f46.google.com with SMTP id uo15so2552298pbc.19
        for <netdev@vger.kernel.org>; Sat, 09 Mar 2013 18:39:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

With recent patches from Pravin, most tunnels can't use iptunnel_xmit()
any more, due to ip_select_ident() and skb->ip_summed. But we can just
move these operations out of iptunnel_xmit(), so that tunnels can
use it again.

This by the way fixes a bug in vxlan (missing nf_reset()) for net-next.

Cc: Pravin B Shelar <pshelar@nicira.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index f057ec0..f3a135c 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -855,7 +855,6 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	__u16 src_port;
 	__be16 df = 0;
 	__u8 tos, ttl;
-	int err;
 	bool did_rsc = false;
 	const struct vxlan_fdb *f;
 
@@ -980,18 +979,7 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (handle_offloads(skb))
 		goto drop;
 
-	err = ip_local_out(skb);
-	if (likely(net_xmit_eval(err) == 0)) {
-		struct vxlan_stats *stats = this_cpu_ptr(vxlan->stats);
-
-		u64_stats_update_begin(&stats->syncp);
-		stats->tx_packets++;
-		stats->tx_bytes += pkt_len;
-		u64_stats_update_end(&stats->syncp);
-	} else {
-		dev->stats.tx_errors++;
-		dev->stats.tx_aborted_errors++;
-	}
+	iptunnel_xmit(skb, dev);
 	return NETDEV_TX_OK;
 
 drop:
diff --git a/include/net/ipip.h b/include/net/ipip.h
index fd19625..0c046e3 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -51,13 +51,10 @@ struct ip_tunnel_prl_entry {
 static inline void iptunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	int err;
-	struct iphdr *iph = ip_hdr(skb);
 	int pkt_len = skb->len - skb_transport_offset(skb);
 	struct pcpu_tstats *tstats = this_cpu_ptr(dev->tstats);
 
 	nf_reset(skb);
-	skb->ip_summed = CHECKSUM_NONE;
-	ip_select_ident(iph, skb_dst(skb), NULL);
 
 	err = ip_local_out(skb);
 	if (likely(net_xmit_eval(err) == 0)) {
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index d0ef0e6..a13a097 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -762,7 +762,6 @@ error:
 
 static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct pcpu_tstats *tstats = this_cpu_ptr(dev->tstats);
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	const struct iphdr  *old_iph;
 	const struct iphdr  *tiph;
@@ -778,7 +777,6 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	int    mtu;
 	u8     ttl;
 	int    err;
-	int    pkt_len;
 
 	skb = handle_offloads(tunnel, skb);
 	if (IS_ERR(skb)) {
@@ -1022,19 +1020,7 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 		}
 	}
 
-	nf_reset(skb);
-
-	pkt_len = skb->len - skb_transport_offset(skb);
-	err = ip_local_out(skb);
-	if (likely(net_xmit_eval(err) == 0)) {
-		u64_stats_update_begin(&tstats->syncp);
-		tstats->tx_bytes += pkt_len;
-		tstats->tx_packets++;
-		u64_stats_update_end(&tstats->syncp);
-	} else {
-		dev->stats.tx_errors++;
-		dev->stats.tx_aborted_errors++;
-	}
+	iptunnel_xmit(skb, dev);
 	return NETDEV_TX_OK;
 
 #if IS_ENABLED(CONFIG_IPV6)
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index b50435b..34e006f 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -478,8 +478,6 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	__be32 dst = tiph->daddr;
 	struct flowi4 fl4;
 	int    mtu;
-	int err;
-	int pkt_len;
 
 	if (skb->protocol != htons(ETH_P_IP))
 		goto tx_error;
@@ -600,21 +598,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	if ((iph->ttl = tiph->ttl) == 0)
 		iph->ttl	=	old_iph->ttl;
 
-	nf_reset(skb);
-
-	pkt_len = skb->len - skb_transport_offset(skb);
-	err = ip_local_out(skb);
-	if (likely(net_xmit_eval(err) == 0)) {
-		struct pcpu_tstats *tstats = this_cpu_ptr(dev->tstats);
-
-		u64_stats_update_begin(&tstats->syncp);
-		tstats->tx_bytes += pkt_len;
-		tstats->tx_packets++;
-		u64_stats_update_end(&tstats->syncp);
-	} else {
-		dev->stats.tx_errors++;
-		dev->stats.tx_aborted_errors++;
-	}
+	iptunnel_xmit(skb, dev);
 
 	return NETDEV_TX_OK;
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 02f96dc..898e671 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -899,6 +899,8 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	if ((iph->ttl = tiph->ttl) == 0)
 		iph->ttl	=	iph6->hop_limit;
 
+	skb->ip_summed = CHECKSUM_NONE;
+	ip_select_ident(iph, skb_dst(skb), NULL);
 	iptunnel_xmit(skb, dev);
 	return NETDEV_TX_OK;
 
