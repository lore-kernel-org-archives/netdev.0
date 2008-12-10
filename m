From: Balazs Scheidler <bazsi@balabit.hu>
Subject: Re: [RFC][PATCH] [TPROXY] kick out TIME_WAIT sockets in case a new
 connection comes in with the same tuple
Date: Wed, 10 Dec 2008 11:15:30 +0100
Message-ID: <1228904130.7542.57.camel@bzorp.balabit>
References: <1228812695.7631.16.camel@bzorp.balabit>
	 <20081209.221838.206534714.davem@davemloft.net>
	 <1228899142.7542.31.camel@bzorp.balabit>
	 <20081210.005728.41175879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tproxy@lists.balabit.hu, hidden@sch.bme.hu,
	panther@balabit.hu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from support.balabit.hu ([195.70.41.86]:57438 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754323AbYLJKPk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2008 05:15:40 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 7B48A39D157
	for <netdev@vger.kernel.org>; Wed, 10 Dec 2008 11:15:36 +0100 (CET)
In-Reply-To: <20081210.005728.41175879.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-12-10 at 00:57 -0800, David Miller wrote:
> From: Balazs Scheidler <bazsi@balabit.hu>
> Date: Wed, 10 Dec 2008 09:52:22 +0100
> 
> > I understand. Here are the alternatives I considered:
> >  1) the patch above, by extending the socket structures
> >  2) expand skb, of course I felt this is worse than the patch I posted
> >  3) call inet_twsk_deschedule() from the prerouting hook
> > 
> > The 3rd one does not require any expansion of the related structures,
> > however it'd mean that the TCP state is not only looked up, but also
> > changed from the TPROXY target. I felt this ugly, but the ugliness would
> > be constrained to the tproxy code. Shall I post a patch implementing
> > option #3 above?
> 
> It would be interesting to see what it looks like, so if you
> don't mind then yes please toss that together so we can have
> a look.
> 

Updated patch below. The SYN validation could still be improved to match
the one in tcp_timewait_state_process(), the current one is very
simplistic, but the approach is already visible.

[TPROXY] kick out TIME_WAIT sockets in case a new connection comes in with the same tuple

Without tproxy redirections an incoming SYN kicks out conflicting
TIME_WAIT sockets, in order to handle clients that reuse ports
within the TIME_WAIT period.

The same mechanism didn't work in case TProxy is involved in finding
the proper socket, as the time_wait processing code looked up the
listening socket assuming that the listener addr/port matches those
of the established connection.

This is not the case with TProxy as the listener addr/port is possibly
changed with the tproxy rule.

An earlier version of this patch used expanded inet_sock and
inet_timewait_sock structs in order to store the original listener
address. This time, the TIME_WAIT socket is removed from the hashes right in
the TPROXY target so by the time the packet reaches the TCP stack, the
TIME_WAIT socket will not be there.

This patch is currently only a draft, I'm still thinking about
changing the prototype of nf_tproxy_get_sock_v4(), so please
do NOT apply.
---

 include/net/inet_timewait_sock.h       |    2 +-
 include/net/netfilter/nf_tproxy_core.h |    6 +++++-
 net/netfilter/nf_tproxy_core.c         |   29 +++++++++++++++++++++--------
 net/netfilter/xt_TPROXY.c              |   29 ++++++++++++++++++++++++-----
 net/netfilter/xt_socket.c              |    2 +-
 5 files changed, 52 insertions(+), 16 deletions(-)


diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index 4b8ece2..2f579f4 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -130,7 +130,7 @@ struct inet_timewait_sock {
 	/* And these are ours. */
 	__u8			tw_ipv6only:1,
 				tw_transparent:1;
-	/* 15 bits hole, try to pack */
+	/* 14 bits hole, try to pack */
 	__u16			tw_ipv6_offset;
 	unsigned long		tw_ttd;
 	struct inet_bind_bucket	*tw_tb;
diff --git a/include/net/netfilter/nf_tproxy_core.h b/include/net/netfilter/nf_tproxy_core.h
index 208b46f..b3a8942 100644
--- a/include/net/netfilter/nf_tproxy_core.h
+++ b/include/net/netfilter/nf_tproxy_core.h
@@ -8,12 +8,16 @@
 #include <net/inet_sock.h>
 #include <net/tcp.h>
 
+#define NFT_LOOKUP_ANY         0
+#define NFT_LOOKUP_LISTENER    1
+#define NFT_LOOKUP_ESTABLISHED 2
+
 /* look up and get a reference to a matching socket */
 extern struct sock *
 nf_tproxy_get_sock_v4(struct net *net, const u8 protocol,
 		      const __be32 saddr, const __be32 daddr,
 		      const __be16 sport, const __be16 dport,
-		      const struct net_device *in, bool listening);
+		      const struct net_device *in, int lookup_type);
 
 static inline void
 nf_tproxy_put_sock(struct sock *sk)
diff --git a/net/netfilter/nf_tproxy_core.c b/net/netfilter/nf_tproxy_core.c
index cdc97f3..1858da0 100644
--- a/net/netfilter/nf_tproxy_core.c
+++ b/net/netfilter/nf_tproxy_core.c
@@ -22,21 +22,34 @@ struct sock *
 nf_tproxy_get_sock_v4(struct net *net, const u8 protocol,
 		      const __be32 saddr, const __be32 daddr,
 		      const __be16 sport, const __be16 dport,
-		      const struct net_device *in, bool listening_only)
+		      const struct net_device *in, int lookup_type)
 {
 	struct sock *sk;
 
 	/* look up socket */
 	switch (protocol) {
 	case IPPROTO_TCP:
-		if (listening_only)
-			sk = __inet_lookup_listener(net, &tcp_hashinfo,
-						    daddr, ntohs(dport),
-						    in->ifindex);
-		else
+		switch (lookup_type) {
+		case NFT_LOOKUP_ANY:
 			sk = __inet_lookup(net, &tcp_hashinfo,
 					   saddr, sport, daddr, dport,
 					   in->ifindex);
+			break;
+		case NFT_LOOKUP_LISTENER:
+			sk = inet_lookup_listener(net, &tcp_hashinfo,
+						    daddr, dport,
+						    in->ifindex);
+			break;
+		case NFT_LOOKUP_ESTABLISHED:
+			sk = inet_lookup_established(net, &tcp_hashinfo,
+						    saddr, sport, daddr, dport,
+						    in->ifindex);
+			break;
+		default:
+			WARN_ON(1);
+			sk = NULL;
+			break;
+		}
 		break;
 	case IPPROTO_UDP:
 		sk = udp4_lib_lookup(net, saddr, sport, daddr, dport,
@@ -47,8 +60,8 @@ nf_tproxy_get_sock_v4(struct net *net, const u8 protocol,
 		sk = NULL;
 	}
 
-	pr_debug("tproxy socket lookup: proto %u %08x:%u -> %08x:%u, listener only: %d, sock %p\n",
-		 protocol, ntohl(saddr), ntohs(sport), ntohl(daddr), ntohs(dport), listening_only, sk);
+	pr_debug("tproxy socket lookup: proto %u %08x:%u -> %08x:%u, lookup type: %d, sock %p\n",
+		 protocol, ntohl(saddr), ntohs(sport), ntohl(daddr), ntohs(dport), lookup_type, sk);
 
 	return sk;
 }
diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index 1340c2f..92a911e 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -29,7 +29,7 @@ tproxy_tg(struct sk_buff *skb, const struct xt_target_param *par)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	const struct xt_tproxy_target_info *tgi = par->targinfo;
-	struct udphdr _hdr, *hp;
+	struct tcphdr _hdr, *hp;
 	struct sock *sk;
 
 	hp = skb_header_pointer(skb, ip_hdrlen(skb), sizeof(_hdr), &_hdr);
@@ -37,10 +37,29 @@ tproxy_tg(struct sk_buff *skb, const struct xt_target_param *par)
 		return NF_DROP;
 
 	sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
-				   iph->saddr, tgi->laddr ? tgi->laddr : iph->daddr,
-				   hp->source, tgi->lport ? tgi->lport : hp->dest,
-				   par->in, true);
-
+				   iph->saddr, iph->daddr,
+				   hp->source, hp->dest,
+				   par->in, NFT_LOOKUP_ESTABLISHED);
+				   
+	if (sk->sk_state == TCP_TIME_WAIT && hp->syn && !hp->rst && !hp->ack && !hp->fin) {
+		struct sock *sk2;
+		 
+		sk2 = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
+					   iph->saddr, tgi->laddr ? tgi->laddr : iph->daddr,
+					   hp->source, tgi->lport ? tgi->lport : hp->dest,
+					   par->in, NFT_LOOKUP_LISTENER);
+		if (sk2) {
+			inet_twsk_deschedule(inet_twsk(sk), &tcp_death_row);
+			inet_twsk_put(inet_twsk(sk));
+			sk = sk2;
+		}
+	}
+	else if (!sk) {
+		sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
+					   iph->saddr, tgi->laddr ? tgi->laddr : iph->daddr,
+					   hp->source, tgi->lport ? tgi->lport : hp->dest,
+					   par->in, NFT_LOOKUP_LISTENER);
+	}
 	/* NOTE: assign_sock consumes our sk reference */
 	if (sk && nf_tproxy_assign_sock(skb, sk)) {
 		/* This should be in a separate target, but we don't do multiple
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index 1d521a5..ae8233d 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -142,7 +142,7 @@ socket_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 #endif
 
 	sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), protocol,
-				   saddr, daddr, sport, dport, par->in, false);
+				   saddr, daddr, sport, dport, par->in, NFT_LOOKUP_ANY);
 	if (sk != NULL) {
 		bool wildcard = (sk->sk_state != TCP_TIME_WAIT && inet_sk(sk)->rcv_saddr == 0);
 


-- 
Bazsi


