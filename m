From: David Ahern <dsahern@gmail.com>
Subject: [RFC PATCH 18/29] net: vrf: Plumbing for vrf context on a socket
Date: Wed,  4 Feb 2015 18:34:19 -0700
Message-ID: <1423100070-31848-19-git-send-email-dsahern@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Cc: ebiederm@xmission.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:47946 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966747AbbBEBgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 20:36:09 -0500
Received: by mail-ie0-f181.google.com with SMTP id rd18so6677850iec.12
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 17:36:08 -0800 (PST)
In-Reply-To: <1423100070-31848-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sockets inherit the vrf context of the task opening it. The context can
be read/changed via a socket option (IP_VRF_CONTEXT).

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 include/uapi/linux/in.h         |  1 +
 net/core/sock.c                 |  2 ++
 net/ipv4/inet_connection_sock.c |  5 +++--
 net/ipv4/inet_hashtables.c      |  1 +
 net/ipv4/inet_timewait_sock.c   |  1 +
 net/ipv4/ip_output.c            |  1 +
 net/ipv4/ip_sockglue.c          | 14 ++++++++++++++
 net/ipv4/tcp_minisocks.c        |  1 +
 8 files changed, 24 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/in.h b/include/uapi/linux/in.h
index 589ced069e8a..77ac6fce6493 100644
--- a/include/uapi/linux/in.h
+++ b/include/uapi/linux/in.h
@@ -145,6 +145,7 @@ struct in_addr {
 #define MCAST_MSFILTER			48
 #define IP_MULTICAST_ALL		49
 #define IP_UNICAST_IF			50
+#define IP_VRF_CONTEXT			51
 
 #define MCAST_EXCLUDE	0
 #define MCAST_INCLUDE	1
diff --git a/net/core/sock.c b/net/core/sock.c
index 93c8b20c91e4..8a4ef8540e50 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1392,6 +1392,8 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		sk->sk_prot = sk->sk_prot_creator = prot;
 		sock_lock_init(sk);
 		sock_net_set(sk, get_net(net));
+		/* by default socket takes on vrf of task */
+		sk->sk_vrf = current->vrf;
 		atomic_set(&sk->sk_wmem_alloc, 1);
 
 		sock_update_classid(sk);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index b3580594d08a..3b8df03c69db 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -404,7 +404,7 @@ struct dst_entry *inet_csk_route_req(struct sock *sk,
 	const struct inet_request_sock *ireq = inet_rsk(req);
 	struct ip_options_rcu *opt = inet_rsk(req)->opt;
 	struct net *net = sock_net(sk);
-	struct net_ctx ctx = { .net = net };
+	struct net_ctx ctx = { .net = net, .vrf = ireq->ir_vrf };
 	int flags = inet_sk_flowi_flags(sk);
 
 	flowi4_init_output(fl4, sk->sk_bound_dev_if, ireq->ir_mark,
@@ -437,7 +437,7 @@ struct dst_entry *inet_csk_route_child_sock(struct sock *sk,
 	struct inet_sock *newinet = inet_sk(newsk);
 	struct ip_options_rcu *opt;
 	struct net *net = sock_net(sk);
-	struct net_ctx ctx = { .net = net };
+	struct net_ctx ctx = { .net = net, .vrf = ireq->ir_vrf };
 	struct flowi4 *fl4;
 	struct rtable *rt;
 
@@ -681,6 +681,7 @@ struct sock *inet_csk_clone_lock(const struct sock *sk,
 		newsk->sk_write_space = sk_stream_write_space;
 
 		newsk->sk_mark = inet_rsk(req)->ir_mark;
+		newsk->sk_vrf  = inet_rsk(req)->ir_vrf;
 
 		newicsk->icsk_retransmits = 0;
 		newicsk->icsk_backoff	  = 0;
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 8b3d94ca634c..71c31c81aea1 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -62,6 +62,7 @@ struct inet_bind_bucket *inet_bind_bucket_create(struct kmem_cache *cachep,
 
 	if (tb != NULL) {
 		write_pnet(&tb->ib_net_ctx.net, hold_net(ctx->net));
+		tb->ib_net_ctx.vrf = ctx->vrf;
 		tb->port      = snum;
 		tb->fastreuse = 0;
 		tb->fastreuseport = 0;
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 6d592f8555fb..faec08993a46 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -196,6 +196,7 @@ struct inet_timewait_sock *inet_twsk_alloc(const struct sock *sk, const int stat
 		tw->tw_transparent  = inet->transparent;
 		tw->tw_prot	    = sk->sk_prot_creator;
 		twsk_net_set(tw, hold_net(sock_net(sk)));
+		tw->tw_vrf	    = sk->sk_vrf;
 		/*
 		 * Because we use RCU lookups, we should not set tw_refcnt
 		 * to a non null value before everything is setup for this
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 855e003e43d8..126d6edea34e 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1574,6 +1574,7 @@ void ip_send_unicast_reply(struct net_ctx *ctx, struct sk_buff *skb,
 	sk->sk_protocol = ip_hdr(skb)->protocol;
 	sk->sk_bound_dev_if = arg->bound_dev_if;
 	sock_net_set(sk, ctx->net);
+	sk->sk_vrf = ctx->vrf;
 	__skb_queue_head_init(&sk->sk_write_queue);
 	sk->sk_sndbuf = sysctl_wmem_default;
 	err = ip_append_data(sk, &fl4, ip_reply_glue_bits, arg->iov->iov_base,
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 8ab03f0431f5..eeb51e935379 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -555,6 +555,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	case IP_MULTICAST_LOOP:
 	case IP_RECVORIGDSTADDR:
 	case IP_CHECKSUM:
+	case IP_VRF_CONTEXT:
 		if (optlen >= sizeof(int)) {
 			if (get_user(val, (int __user *) optval))
 				return -EFAULT;
@@ -1104,6 +1105,16 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		inet->min_ttl = val;
 		break;
 
+	case IP_VRF_CONTEXT:
+		/* VRF context can only be set on unconnected sockets */
+		if (inet->inet_sport || inet->inet_dport) {
+			err = -EINVAL;
+			break;
+		}
+		sk->sk_vrf = val;
+		err = 0;
+		break;
+
 	default:
 		err = -ENOPROTOOPT;
 		break;
@@ -1411,6 +1422,9 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 	case IP_MINTTL:
 		val = inet->min_ttl;
 		break;
+	case IP_VRF_CONTEXT:
+		val = sk->sk_vrf;
+		break;
 	default:
 		release_sock(sk);
 		return -ENOPROTOOPT;
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index bc9216dc9de1..f5b869799b14 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -283,6 +283,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 
 		tw->tw_transparent	= inet->transparent;
 		tw->tw_rcv_wscale	= tp->rx_opt.rcv_wscale;
+		tw->tw_vrf		= sk->sk_vrf;
 		tcptw->tw_rcv_nxt	= tp->rcv_nxt;
 		tcptw->tw_snd_nxt	= tp->snd_nxt;
 		tcptw->tw_rcv_wnd	= tcp_receive_window(tp);
-- 
1.9.3 (Apple Git-50)
