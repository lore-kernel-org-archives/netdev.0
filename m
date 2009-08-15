From: Balazs Scheidler <bazsi@balabit.hu>
Subject: [PATCH 01/13] TProxy: kick out TIME_WAIT sockets in case a new
 connection comes in with the same tuple
Date: Sat, 15 Aug 2009 10:00:21 +0200
Message-ID: <1253548005.12519.1.camel@bzorp.balabit>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
To: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Without tproxy redirections an incoming SYN kicks out conflicting
TIME_WAIT sockets, in order to handle clients that reuse ports
within the TIME_WAIT period.

The same mechanism didn't work in case TProxy is involved in finding
the proper socket, as the time_wait processing code looked up the
listening socket assuming that the listener addr/port matches those
of the established connection.

This is not the case with TProxy as the listener addr/port is possibly
changed with the tproxy rule.

Signed-off-by: Balazs Scheidler <bazsi@balabit.hu>
---
 include/net/netfilter/nf_tproxy_core.h |    6 ++++-
 net/netfilter/nf_tproxy_core.c         |   29 +++++++++++++++++++-------
 net/netfilter/xt_TPROXY.c              |   35 ++++++++++++++++++++++++++++---
 net/netfilter/xt_socket.c              |    2 +-
 4 files changed, 58 insertions(+), 14 deletions(-)

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
index 5490fc3..8589e5e 100644
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
index 1340c2f..5592b72 100644
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
@@ -37,10 +37,37 @@ tproxy_tg(struct sk_buff *skb, const struct xt_target_param *par)
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
+	/* udp has no TCP_TIME_WAIT state, so we never enter here */
+	if (sk && sk->sk_state == TCP_TIME_WAIT &&
+	    hp->syn && !hp->rst && !hp->ack && !hp->fin) {
+		struct sock *sk2;
+
+		/* Hm.. we got a SYN to a TIME_WAIT socket, let's see if
+		 * there's a listener on the redirected port
+		 */
+		sk2 = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
+					   iph->saddr, tgi->laddr ? tgi->laddr : iph->daddr,
+					   hp->source, tgi->lport ? tgi->lport : hp->dest,
+					   par->in, NFT_LOOKUP_LISTENER);
+		if (sk2) {
+
+			/* yeah, there's one, let's kill the TIME_WAIT
+			 * socket and redirect to the listener
+			 */
+			inet_twsk_deschedule(inet_twsk(sk), &tcp_death_row);
+			inet_twsk_put(inet_twsk(sk));
+			sk = sk2;
+		}
+	} else if (!sk) {
+		sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), iph->protocol,
+					   iph->saddr, tgi->laddr ? tgi->laddr : iph->daddr,
+					   hp->source, tgi->lport ? tgi->lport : hp->dest,
+					   par->in, NFT_LOOKUP_LISTENER);
+	}
 	/* NOTE: assign_sock consumes our sk reference */
 	if (sk && nf_tproxy_assign_sock(skb, sk)) {
 		/* This should be in a separate target, but we don't do multiple
diff --git a/net/netfilter/xt_socket.c b/net/netfilter/xt_socket.c
index ebf00ad..12a7140 100644
--- a/net/netfilter/xt_socket.c
+++ b/net/netfilter/xt_socket.c
@@ -142,7 +142,7 @@ socket_match(const struct sk_buff *skb, const struct xt_match_param *par,
 #endif
 
 	sk = nf_tproxy_get_sock_v4(dev_net(skb->dev), protocol,
-				   saddr, daddr, sport, dport, par->in, false);
+				   saddr, daddr, sport, dport, par->in, NFT_LOOKUP_ANY);
 	if (sk != NULL) {
 		bool wildcard;
 		bool transparent = true;
-- 
1.6.0.4

