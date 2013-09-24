From: Francesco Fusco <ffusco@redhat.com>
Subject: [PATCH net-next v3 2/2] ipv4: processing ancillary IP_TOS or IP_TTL
Date: Tue, 24 Sep 2013 15:43:09 +0200
Message-ID: <9dfd771ed7c38d3a3564d93d7e5f0f256eb7df88.1379944642.git.ffusco@redhat.com>
References: <cover.1379944641.git.ffusco@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1617 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753947Ab3IXNnP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 09:43:15 -0400
In-Reply-To: <cover.1379944641.git.ffusco@redhat.com>
In-Reply-To: <cover.1379944641.git.ffusco@redhat.com>
References: <cover.1379944641.git.ffusco@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If IP_TOS or IP_TTL are specified as ancillary data, then sendmsg() sends out
packets with the specified TTL or TOS overriding the socket values specified
with the traditional setsockopt().

The struct inet_cork stores the values of TOS, TTL and priority that are
passed through the struct ipcm_cookie. If there are user-specified TOS
(tos != -1) or TTL (ttl != 0) in the struct ipcm_cookie, these values are
used to override the per-socket values. In case of TOS also the priority
is changed accordingly.

Two helper functions get_rttos and get_rtconn_flags are defined to take
into account the presence of a user specified TOS value when computing
RT_TOS and RT_CONN_FLAGS.

Signed-off-by: Francesco Fusco <ffusco@redhat.com>
---
 v1->v2
  - reworked the entire patch
  - modified the ttl field in the struct inet_cork from __s16 to __u8:
    0 means that the TTL is not specified
  - the tos field in the struct inet_cork is still __s16: 
    -1 means tha the tos is not set
  - modified the priority field in the struct inet_cork from __u32 to 
    char.
  - introduced the get_rttos and get_rtconn_flags functions
 v2->v3
  - no code changes, rebase to net-next

 include/net/inet_sock.h |  3 +++
 include/net/ip.h        | 11 +++++++++++
 include/net/route.h     |  1 +
 net/ipv4/icmp.c         |  5 +++++
 net/ipv4/ip_output.c    | 13 ++++++++++---
 net/ipv4/ping.c         |  4 +++-
 net/ipv4/raw.c          |  4 +++-
 net/ipv4/udp.c          |  4 +++-
 8 files changed, 39 insertions(+), 6 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index 636d203..f314177 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -103,6 +103,9 @@ struct inet_cork {
 	int			length; /* Total length of all frames */
 	struct dst_entry	*dst;
 	u8			tx_flags;
+	__u8			ttl;
+	__s16			tos;
+	char			priority;
 };
 
 struct inet_cork_full {
diff --git a/include/net/ip.h b/include/net/ip.h
index 0135f38..77b4f9b 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -28,6 +28,7 @@
 #include <linux/skbuff.h>
 
 #include <net/inet_sock.h>
+#include <net/route.h>
 #include <net/snmp.h>
 #include <net/flow.h>
 
@@ -140,6 +141,16 @@ static inline struct sk_buff *ip_finish_skb(struct sock *sk, struct flowi4 *fl4)
 	return __ip_make_skb(sk, fl4, &sk->sk_write_queue, &inet_sk(sk)->cork.base);
 }
 
+static inline __u8 get_rttos(struct ipcm_cookie* ipc, struct inet_sock *inet)
+{
+	return (ipc->tos != -1) ? RT_TOS(ipc->tos) : RT_TOS(inet->tos);
+}
+
+static inline __u8 get_rtconn_flags(struct ipcm_cookie* ipc, struct sock* sk)
+{
+	return (ipc->tos != -1) ? RT_CONN_FLAGS_TOS(sk, ipc->tos) : RT_CONN_FLAGS(sk);
+}
+
 /* datagram.c */
 int ip4_datagram_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len);
 
diff --git a/include/net/route.h b/include/net/route.h
index 6f572ca..0ad8e01 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -39,6 +39,7 @@
 #define RTO_ONLINK	0x01
 
 #define RT_CONN_FLAGS(sk)   (RT_TOS(inet_sk(sk)->tos) | sock_flag(sk, SOCK_LOCALROUTE))
+#define RT_CONN_FLAGS_TOS(sk,tos)   (RT_TOS(tos) | sock_flag(sk, SOCK_LOCALROUTE))
 
 struct fib_nh;
 struct fib_info;
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 5f7d11a..5c0e8bc 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -353,6 +353,9 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	saddr = fib_compute_spec_dst(skb);
 	ipc.opt = NULL;
 	ipc.tx_flags = 0;
+	ipc.ttl = 0;
+	ipc.tos = -1;
+
 	if (icmp_param->replyopts.opt.opt.optlen) {
 		ipc.opt = &icmp_param->replyopts.opt;
 		if (ipc.opt->opt.srr)
@@ -608,6 +611,8 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	ipc.addr = iph->saddr;
 	ipc.opt = &icmp_param->replyopts.opt;
 	ipc.tx_flags = 0;
+	ipc.ttl = 0;
+	ipc.tos = -1;
 
 	rt = icmp_route_lookup(net, &fl4, skb_in, iph, saddr, tos,
 			       type, code, icmp_param);
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index a04d872..7d8357b 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1060,6 +1060,9 @@ static int ip_setup_cork(struct sock *sk, struct inet_cork *cork,
 			 rt->dst.dev->mtu : dst_mtu(&rt->dst);
 	cork->dst = &rt->dst;
 	cork->length = 0;
+	cork->ttl = ipc->ttl;
+	cork->tos = ipc->tos;
+	cork->priority = ipc->priority;
 	cork->tx_flags = ipc->tx_flags;
 
 	return 0;
@@ -1311,7 +1314,9 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 	if (cork->flags & IPCORK_OPT)
 		opt = cork->opt;
 
-	if (rt->rt_type == RTN_MULTICAST)
+	if (cork->ttl != 0)
+		ttl = cork->ttl;
+	else if (rt->rt_type == RTN_MULTICAST)
 		ttl = inet->mc_ttl;
 	else
 		ttl = ip_select_ttl(inet, &rt->dst);
@@ -1319,7 +1324,7 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 	iph = ip_hdr(skb);
 	iph->version = 4;
 	iph->ihl = 5;
-	iph->tos = inet->tos;
+	iph->tos = (cork->tos != -1) ? cork->tos : inet->tos;
 	iph->frag_off = df;
 	iph->ttl = ttl;
 	iph->protocol = sk->sk_protocol;
@@ -1331,7 +1336,7 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 		ip_options_build(skb, opt, cork->addr, rt, 0);
 	}
 
-	skb->priority = sk->sk_priority;
+	skb->priority = (cork->tos != -1) ? cork->priority: sk->sk_priority;
 	skb->mark = sk->sk_mark;
 	/*
 	 * Steal rt from cork.dst to avoid a pair of atomic_inc/atomic_dec
@@ -1481,6 +1486,8 @@ void ip_send_unicast_reply(struct net *net, struct sk_buff *skb, __be32 daddr,
 	ipc.addr = daddr;
 	ipc.opt = NULL;
 	ipc.tx_flags = 0;
+	ipc.ttl = 0;
+	ipc.tos = -1;
 
 	if (replyopts.opt.opt.optlen) {
 		ipc.opt = &replyopts.opt;
diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index d7d9882..706d108e 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -713,6 +713,8 @@ int ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	ipc.opt = NULL;
 	ipc.oif = sk->sk_bound_dev_if;
 	ipc.tx_flags = 0;
+	ipc.ttl = 0;
+	ipc.tos = -1;
 
 	sock_tx_timestamp(sk, &ipc.tx_flags);
 
@@ -744,7 +746,7 @@ int ping_v4_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			return -EINVAL;
 		faddr = ipc.opt->opt.faddr;
 	}
-	tos = RT_TOS(inet->tos);
+	tos = get_rttos(&ipc, inet);
 	if (sock_flag(sk, SOCK_LOCALROUTE) ||
 	    (msg->msg_flags & MSG_DONTROUTE) ||
 	    (ipc.opt && ipc.opt->opt.is_strictroute)) {
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index bfec521..a3fe534 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -517,6 +517,8 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	ipc.addr = inet->inet_saddr;
 	ipc.opt = NULL;
 	ipc.tx_flags = 0;
+	ipc.ttl = 0;
+	ipc.tos = -1;
 	ipc.oif = sk->sk_bound_dev_if;
 
 	if (msg->msg_controllen) {
@@ -556,7 +558,7 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			daddr = ipc.opt->opt.faddr;
 		}
 	}
-	tos = RT_CONN_FLAGS(sk);
+	tos = get_rtconn_flags(&ipc, sk);
 	if (msg->msg_flags & MSG_DONTROUTE)
 		tos |= RTO_ONLINK;
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 74d2c95..22462d94 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -855,6 +855,8 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	ipc.opt = NULL;
 	ipc.tx_flags = 0;
+	ipc.ttl = 0;
+	ipc.tos = -1;
 
 	getfrag = is_udplite ? udplite_getfrag : ip_generic_getfrag;
 
@@ -938,7 +940,7 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		faddr = ipc.opt->opt.faddr;
 		connected = 0;
 	}
-	tos = RT_TOS(inet->tos);
+	tos = get_rttos(&ipc, inet);
 	if (sock_flag(sk, SOCK_LOCALROUTE) ||
 	    (msg->msg_flags & MSG_DONTROUTE) ||
 	    (ipc.opt && ipc.opt->opt.is_strictroute)) {
-- 
1.8.3.1
