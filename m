From: Lance Richardson <lrichard@redhat.com>
Subject: [PATCH net v3] ipv4: allow local fragmentation in ip_finish_output_gso()
Date: Wed,  2 Nov 2016 16:36:17 -0400
Message-ID: <1478118977-19608-1-git-send-email-lrichard@redhat.com>
To: netdev@vger.kernel.org, fw@strlen.de, jtluka@redhat.com,
        hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44650 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756031AbcKBUgU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Nov 2016 16:36:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some configurations (e.g. geneve interface with default
MTU of 1500 over an ethernet interface with 1500 MTU) result
in the transmission of packets that exceed the configured MTU.
While this should be considered to be a "bad" configuration,
it is still allowed and should not result in the sending
of packets that exceed the configured MTU.

Fix by dropping the assumption in ip_finish_output_gso() that
locally originated gso packets will never need fragmentation.
Basic testing using iperf (observing CPU usage and bandwidth)
have shown no measurable performance impact for traffic not
requiring fragmentation.

Fixes: c7ba65d7b649 ("net: ip: push gso skb forwarding handling down the stack")
Reported-by: Jan Tluka <jtluka@redhat.com>
Signed-off-by: Lance Richardson <lrichard@redhat.com>
---
 v2: IPSKB_FRAG_SEGS is no longer useful, remove it.
 v3: Eliminate unused variable warning.
 include/net/ip.h          |  3 +--
 net/ipv4/ip_forward.c     |  2 +-
 net/ipv4/ip_output.c      |  6 ++----
 net/ipv4/ip_tunnel_core.c | 11 -----------
 net/ipv4/ipmr.c           |  2 +-
 5 files changed, 5 insertions(+), 19 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 5413883..d3a1078 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -47,8 +47,7 @@ struct inet_skb_parm {
 #define IPSKB_REROUTED		BIT(4)
 #define IPSKB_DOREDIRECT	BIT(5)
 #define IPSKB_FRAG_PMTU		BIT(6)
-#define IPSKB_FRAG_SEGS		BIT(7)
-#define IPSKB_L3SLAVE		BIT(8)
+#define IPSKB_L3SLAVE		BIT(7)
 
 	u16			frag_max_size;
 };
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 8b4ffd2..9f0a7b9 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -117,7 +117,7 @@ int ip_forward(struct sk_buff *skb)
 	if (opt->is_strictroute && rt->rt_uses_gateway)
 		goto sr_failed;
 
-	IPCB(skb)->flags |= IPSKB_FORWARDED | IPSKB_FRAG_SEGS;
+	IPCB(skb)->flags |= IPSKB_FORWARDED;
 	mtu = ip_dst_mtu_maybe_forward(&rt->dst, true);
 	if (ip_exceeds_mtu(skb, mtu)) {
 		IP_INC_STATS(net, IPSTATS_MIB_FRAGFAILS);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 03e7f73..4971401 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -239,11 +239,9 @@ static int ip_finish_output_gso(struct net *net, struct sock *sk,
 	struct sk_buff *segs;
 	int ret = 0;
 
-	/* common case: fragmentation of segments is not allowed,
-	 * or seglen is <= mtu
+	/* common case: seglen is <= mtu
 	 */
-	if (((IPCB(skb)->flags & IPSKB_FRAG_SEGS) == 0) ||
-	      skb_gso_validate_mtu(skb, mtu))
+	if (skb_gso_validate_mtu(skb, mtu))
 		return ip_finish_output2(net, sk, skb);
 
 	/* Slowpath -  GSO segment length is exceeding the dst MTU.
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 777bc18..fed3d29 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -63,7 +63,6 @@ void iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 	int pkt_len = skb->len - skb_inner_network_offset(skb);
 	struct net *net = dev_net(rt->dst.dev);
 	struct net_device *dev = skb->dev;
-	int skb_iif = skb->skb_iif;
 	struct iphdr *iph;
 	int err;
 
@@ -73,16 +72,6 @@ void iptunnel_xmit(struct sock *sk, struct rtable *rt, struct sk_buff *skb,
 	skb_dst_set(skb, &rt->dst);
 	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 
-	if (skb_iif && !(df & htons(IP_DF))) {
-		/* Arrived from an ingress interface, got encapsulated, with
-		 * fragmentation of encapulating frames allowed.
-		 * If skb is gso, the resulting encapsulated network segments
-		 * may exceed dst mtu.
-		 * Allow IP Fragmentation of segments.
-		 */
-		IPCB(skb)->flags |= IPSKB_FRAG_SEGS;
-	}
-
 	/* Push down and install the IP header. */
 	skb_push(skb, sizeof(struct iphdr));
 	skb_reset_network_header(skb);
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 5f006e1..27089f5 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1749,7 +1749,7 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 		vif->dev->stats.tx_bytes += skb->len;
 	}
 
-	IPCB(skb)->flags |= IPSKB_FORWARDED | IPSKB_FRAG_SEGS;
+	IPCB(skb)->flags |= IPSKB_FORWARDED;
 
 	/* RFC1584 teaches, that DVMRP/PIM router must deliver packets locally
 	 * not only before forwarding, but after forwarding on all output
-- 
2.5.5
