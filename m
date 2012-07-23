From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2] ipv4: Prepare for change of rt->rt_iif encoding.
Date: Mon, 23 Jul 2012 14:07:34 -0700 (PDT)
Message-ID: <20120723.140734.801766368525762769.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754663Ab2GWVHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 17:07:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Use inet_iif() consistently, and for TCP record the input interface of
cached RX dst in inet sock.

rt->rt_iif is going to be encoded differently, so that we can
legitimately cache input routes in the FIB info more aggressively.

When the input interface is "use SKB device index" the rt->rt_iif will
be set to zero.

This forces us to move the TCP RX dst cache installation into the ipv4
specific code, and as well it should since doing the route caching for
ipv6 is pointless at the moment since it is not inspected in the ipv6
input paths yet.

Also, remove the unlikely on dst->obsolete, all ipv4 dsts have
obsolete set to a non-zero value to force invocation of the check
callback.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/inet_sock.h |    1 +
 net/dccp/ipv4.c         |    2 +-
 net/ipv4/icmp.c         |    2 +-
 net/ipv4/ip_sockglue.c  |    5 ++---
 net/ipv4/route.c        |    2 +-
 net/ipv4/tcp_input.c    |   12 ------------
 net/ipv4/tcp_ipv4.c     |   24 ++++++++++++++++++------
 net/sched/cls_route.c   |    2 +-
 net/sched/em_meta.c     |    2 +-
 net/sctp/protocol.c     |    2 +-
 10 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 924d7b9..613cfa4 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -172,6 +172,7 @@ struct inet_sock {
 	int			uc_index;
 	int			mc_index;
 	__be32			mc_addr;
+	int			rx_dst_ifindex;
 	struct ip_mc_socklist __rcu	*mc_list;
 	struct inet_cork_full	cork;
 };
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 25428d0..176ecdb 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -481,7 +481,7 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 	struct rtable *rt;
 	const struct iphdr *iph = ip_hdr(skb);
 	struct flowi4 fl4 = {
-		.flowi4_oif = skb_rtable(skb)->rt_iif,
+		.flowi4_oif = inet_iif(skb),
 		.daddr = iph->saddr,
 		.saddr = iph->daddr,
 		.flowi4_tos = RT_CONN_FLAGS(sk),
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index f2a06be..f2eccd5 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -571,7 +571,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 		rcu_read_lock();
 		if (rt_is_input_route(rt) &&
 		    net->ipv4.sysctl_icmp_errors_use_inbound_ifaddr)
-			dev = dev_get_by_index_rcu(net, rt->rt_iif);
+			dev = dev_get_by_index_rcu(net, inet_iif(skb_in));
 
 		if (dev)
 			saddr = inet_select_addr(dev, 0, RT_SCOPE_LINK);
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index de29f46..5eea4a8 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1027,10 +1027,9 @@ e_inval:
 void ipv4_pktinfo_prepare(struct sk_buff *skb)
 {
 	struct in_pktinfo *pktinfo = PKTINFO_SKB_CB(skb);
-	const struct rtable *rt = skb_rtable(skb);
 
-	if (rt) {
-		pktinfo->ipi_ifindex = rt->rt_iif;
+	if (skb_rtable(skb)) {
+		pktinfo->ipi_ifindex = inet_iif(skb);
 		pktinfo->ipi_spec_dst.s_addr = fib_compute_spec_dst(skb);
 	} else {
 		pktinfo->ipi_ifindex = 0;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 34017be..f6be781 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -848,7 +848,7 @@ void ip_rt_send_redirect(struct sk_buff *skb)
 		if (log_martians &&
 		    peer->rate_tokens == ip_rt_redirect_number)
 			net_warn_ratelimited("host %pI4/if%d ignores redirects for %pI4 to %pI4\n",
-					     &ip_hdr(skb)->saddr, rt->rt_iif,
+					     &ip_hdr(skb)->saddr, inet_iif(skb),
 					     &ip_hdr(skb)->daddr, &rt->rt_gateway);
 #endif
 	}
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 21d7f8f..3e07a64 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5391,18 +5391,6 @@ int tcp_rcv_established(struct sock *sk, struct sk_buff *skb,
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
-	if (sk->sk_rx_dst) {
-		struct dst_entry *dst = sk->sk_rx_dst;
-		if (unlikely(dst->obsolete)) {
-			if (dst->ops->check(dst, 0) == NULL) {
-				dst_release(dst);
-				sk->sk_rx_dst = NULL;
-			}
-		}
-	}
-	if (unlikely(sk->sk_rx_dst == NULL))
-		sk->sk_rx_dst = dst_clone(skb_dst(skb));
-
 	/*
 	 *	Header prediction.
 	 *	The code loosely follows the one in the famous
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index bc5432e..3e30548 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1618,6 +1618,20 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 
 	if (sk->sk_state == TCP_ESTABLISHED) { /* Fast path */
 		sock_rps_save_rxhash(sk, skb);
+		if (sk->sk_rx_dst) {
+			struct dst_entry *dst = sk->sk_rx_dst;
+			if (dst->ops->check(dst, 0) == NULL) {
+				dst_release(dst);
+				sk->sk_rx_dst = NULL;
+			}
+		}
+		if (unlikely(sk->sk_rx_dst == NULL)) {
+			struct inet_sock *icsk = inet_sk(sk);
+			struct rtable *rt = skb_rtable(skb);
+
+			sk->sk_rx_dst = dst_clone(&rt->dst);
+			icsk->rx_dst_ifindex = inet_iif(skb);
+		}
 		if (tcp_rcv_established(sk, skb, tcp_hdr(skb), skb->len)) {
 			rsk = sk;
 			goto reset;
@@ -1700,14 +1714,12 @@ void tcp_v4_early_demux(struct sk_buff *skb)
 		skb->destructor = sock_edemux;
 		if (sk->sk_state != TCP_TIME_WAIT) {
 			struct dst_entry *dst = sk->sk_rx_dst;
+			struct inet_sock *icsk = inet_sk(sk);
 			if (dst)
 				dst = dst_check(dst, 0);
-			if (dst) {
-				struct rtable *rt = (struct rtable *) dst;
-
-				if (rt->rt_iif == dev->ifindex)
-					skb_dst_set_noref(skb, dst);
-			}
+			if (dst &&
+			    icsk->rx_dst_ifindex == dev->ifindex)
+				skb_dst_set_noref(skb, dst);
 		}
 	}
 }
diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
index 36fec42..44f405c 100644
--- a/net/sched/cls_route.c
+++ b/net/sched/cls_route.c
@@ -143,7 +143,7 @@ static int route4_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 	if (head == NULL)
 		goto old_method;
 
-	iif = ((struct rtable *)dst)->rt_iif;
+	iif = inet_iif(skb);
 
 	h = route4_fastmap_hash(id, iif);
 	if (id == head->fastmap[h].id &&
diff --git a/net/sched/em_meta.c b/net/sched/em_meta.c
index 4790c69..4ab6e33 100644
--- a/net/sched/em_meta.c
+++ b/net/sched/em_meta.c
@@ -264,7 +264,7 @@ META_COLLECTOR(int_rtiif)
 	if (unlikely(skb_rtable(skb) == NULL))
 		*err = -1;
 	else
-		dst->value = skb_rtable(skb)->rt_iif;
+		dst->value = inet_iif(skb);
 }
 
 /**************************************************************************
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index 9c90811..1f89c4e 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -568,7 +568,7 @@ static void sctp_v4_get_saddr(struct sctp_sock *sk,
 /* What interface did this skb arrive on? */
 static int sctp_v4_skb_iif(const struct sk_buff *skb)
 {
-	return skb_rtable(skb)->rt_iif;
+	return inet_iif(skb);
 }
 
 /* Was this packet marked by Explicit Congestion Notification? */
-- 
1.7.10.4
