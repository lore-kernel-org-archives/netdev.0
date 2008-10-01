From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [net-next PATCH 07/16] Make Netfilter's ip_route_me_harder()	non-local
 address compatible
Date: Wed, 01 Oct 2008 16:24:31 +0200
Message-ID: <20081001142431.4893.46493.stgit@este>
References: <20081001142431.4893.48078.stgit@este>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-reply-to: <20081001142431.4893.48078.stgit@este>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Netfilter's ip_route_me_harder() tries to re-route packets either generated or
re-routed by Netfilter. This patch changes ip_route_me_harder() to handle
packets from non-locally-bound sockets with IP_TRANSPARENT set as local and to
set the appropriate flowi flags when re-doing the routing lookup.

Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---

 include/net/ip.h                |    9 +++++++++
 net/ipv4/inet_connection_sock.c |    1 +
 net/ipv4/ip_output.c            |    4 +++-
 net/ipv4/netfilter.c            |    3 +++
 net/ipv4/syncookies.c           |    2 ++
 5 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 250e6ef..d678ea3 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -29,6 +29,7 @@
 
 #include <net/inet_sock.h>
 #include <net/snmp.h>
+#include <net/flow.h>
 
 struct sock;
 
@@ -140,12 +141,20 @@ static inline void ip_tr_mc_map(__be32 addr, char *buf)
 
 struct ip_reply_arg {
 	struct kvec iov[1];   
+	int	    flags;
 	__wsum 	    csum;
 	int	    csumoffset; /* u16 offset of csum in iov[0].iov_base */
 				/* -1 if not needed */ 
 	int	    bound_dev_if;
 }; 
 
+#define IP_REPLY_ARG_NOSRCCHECK 1
+
+static inline __u8 ip_reply_arg_flowi_flags(const struct ip_reply_arg *arg)
+{
+	return (arg->flags & IP_REPLY_ARG_NOSRCCHECK) ? FLOWI_FLAG_ANYSRC : 0;
+}
+
 void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *arg,
 		   unsigned int len); 
 
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 0c1ae68..432c570 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -335,6 +335,7 @@ struct dst_entry* inet_csk_route_req(struct sock *sk,
 					.saddr = ireq->loc_addr,
 					.tos = RT_CONN_FLAGS(sk) } },
 			    .proto = sk->sk_protocol,
+			    .flags = inet_sk_flowi_flags(sk),
 			    .uli_u = { .ports =
 				       { .sport = inet_sk(sk)->sport,
 					 .dport = ireq->rmt_port } } };
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index d533a89..d2a8f8b 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -340,6 +340,7 @@ int ip_queue_xmit(struct sk_buff *skb, int ipfragok)
 							.saddr = inet->saddr,
 							.tos = RT_CONN_FLAGS(sk) } },
 					    .proto = sk->sk_protocol,
+					    .flags = inet_sk_flowi_flags(sk),
 					    .uli_u = { .ports =
 						       { .sport = inet->sport,
 							 .dport = inet->dport } } };
@@ -1371,7 +1372,8 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, struct ip_reply_arg *ar
 				    .uli_u = { .ports =
 					       { .sport = tcp_hdr(skb)->dest,
 						 .dport = tcp_hdr(skb)->source } },
-				    .proto = sk->sk_protocol };
+				    .proto = sk->sk_protocol,
+				    .flags = ip_reply_arg_flowi_flags(arg) };
 		security_skb_classify_flow(skb, &fl);
 		if (ip_route_output_key(sock_net(sk), &rt, &fl))
 			return;
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index f8edacd..01671ad 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -20,6 +20,8 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 	unsigned int type;
 
 	type = inet_addr_type(&init_net, iph->saddr);
+	if (skb->sk && inet_sk(skb->sk)->transparent)
+		type = RTN_LOCAL;
 	if (addr_type == RTN_UNSPEC)
 		addr_type = type;
 
@@ -33,6 +35,7 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 		fl.nl_u.ip4_u.tos = RT_TOS(iph->tos);
 		fl.oif = skb->sk ? skb->sk->sk_bound_dev_if : 0;
 		fl.mark = skb->mark;
+		fl.flags = skb->sk ? inet_sk_flowi_flags(skb->sk) : 0;
 		if (ip_route_output_key(&init_net, &rt, &fl) != 0)
 			return -1;
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 9d38005..929302b 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -16,6 +16,7 @@
 #include <linux/cryptohash.h>
 #include <linux/kernel.h>
 #include <net/tcp.h>
+#include <net/route.h>
 
 /* Timestamps: lowest 9 bits store TCP options */
 #define TSBITS 9
@@ -337,6 +338,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 						.saddr = ireq->loc_addr,
 						.tos = RT_CONN_FLAGS(sk) } },
 				    .proto = IPPROTO_TCP,
+				    .flags = inet_sk_flowi_flags(sk),
 				    .uli_u = { .ports =
 					       { .sport = th->dest,
 						 .dport = th->source } } };


