From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net-next] ipv6: introduce ip6tunnel_xmit() helper
Date: Sun, 10 Mar 2013 17:00:39 +0800
Message-ID: <1362906039-8236-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:59202 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488Ab3CJJBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Mar 2013 05:01:16 -0400
Received: by mail-pb0-f43.google.com with SMTP id md12so2692668pbc.2
        for <netdev@vger.kernel.org>; Sun, 10 Mar 2013 01:01:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

Similar to iptunnel_xmit(), group these operations into a
helper function.

This by the way fixes the missing u64_stats_update_begin()
and u64_stats_update_end() for 32 bit arch.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
 include/net/ip6_tunnel.h |   20 ++++++++++++++++++++
 net/ipv6/ip6_gre.c       |   17 +----------------
 net/ipv6/ip6_tunnel.c    |   15 +--------------
 3 files changed, 22 insertions(+), 30 deletions(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index e03047f..ebdef7f 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -68,4 +68,24 @@ __u16 ip6_tnl_parse_tlv_enc_lim(struct sk_buff *skb, __u8 *raw);
 __u32 ip6_tnl_get_cap(struct ip6_tnl *t, const struct in6_addr *laddr,
 			     const struct in6_addr *raddr);
 
+static inline void ip6tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct net_device_stats *stats = &dev->stats;
+	int pkt_len, err;
+
+	nf_reset(skb);
+	pkt_len = skb->len;
+	err = ip6_local_out(skb);
+
+	if (net_xmit_eval(err) == 0) {
+		struct pcpu_tstats *tstats = this_cpu_ptr(dev->tstats);
+		u64_stats_update_begin(&tstats->syncp);
+		tstats->tx_bytes += pkt_len;
+		tstats->tx_packets++;
+		u64_stats_update_end(&tstats->syncp);
+	} else {
+		stats->tx_errors++;
+		stats->tx_aborted_errors++;
+	}
+}
 #endif
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index e4efffe..6a6ba73 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -667,7 +667,6 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 	struct net_device_stats *stats = &tunnel->dev->stats;
 	int err = -1;
 	u8 proto;
-	int pkt_len;
 	struct sk_buff *new_skb;
 
 	if (dev->type == ARPHRD_ETHER)
@@ -801,23 +800,9 @@ static netdev_tx_t ip6gre_xmit2(struct sk_buff *skb,
 		}
 	}
 
-	nf_reset(skb);
-	pkt_len = skb->len;
-	err = ip6_local_out(skb);
-
-	if (net_xmit_eval(err) == 0) {
-		struct pcpu_tstats *tstats = this_cpu_ptr(tunnel->dev->tstats);
-
-		tstats->tx_bytes += pkt_len;
-		tstats->tx_packets++;
-	} else {
-		stats->tx_errors++;
-		stats->tx_aborted_errors++;
-	}
-
+	ip6tunnel_xmit(skb, dev);
 	if (ndst)
 		ip6_tnl_dst_store(tunnel, ndst);
-
 	return 0;
 tx_err_link_failure:
 	stats->tx_carrier_errors++;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index fff83cb..bef3fed 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -955,7 +955,6 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	unsigned int max_headroom = sizeof(struct ipv6hdr);
 	u8 proto;
 	int err = -1;
-	int pkt_len;
 
 	if (!fl6->flowi6_mark)
 		dst = ip6_tnl_dst_check(t);
@@ -1035,19 +1034,7 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	ipv6h->nexthdr = proto;
 	ipv6h->saddr = fl6->saddr;
 	ipv6h->daddr = fl6->daddr;
-	nf_reset(skb);
-	pkt_len = skb->len;
-	err = ip6_local_out(skb);
-
-	if (net_xmit_eval(err) == 0) {
-		struct pcpu_tstats *tstats = this_cpu_ptr(t->dev->tstats);
-
-		tstats->tx_bytes += pkt_len;
-		tstats->tx_packets++;
-	} else {
-		stats->tx_errors++;
-		stats->tx_aborted_errors++;
-	}
+	ip6tunnel_xmit(skb, dev);
 	if (ndst)
 		ip6_tnl_dst_store(t, ndst);
 	return 0;
