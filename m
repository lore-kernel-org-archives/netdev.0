From: Francesco Fusco <ffusco@redhat.com>
Subject: [PATCH net-next 2/2] ipv4: processing ancillary IP_TOS or IP_TTL
Date: Wed, 14 Aug 2013 17:48:39 +0200
Message-ID: <d54a214ad9301352128f2b3300c0eaf91cc6e12e.1376494032.git.ffusco@redhat.com>
References: <cover.1376494030.git.ffusco@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34639 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759669Ab3HNPsp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Aug 2013 11:48:45 -0400
In-Reply-To: <cover.1376494030.git.ffusco@redhat.com>
In-Reply-To: <cover.1376494030.git.ffusco@redhat.com>
References: <cover.1376494030.git.ffusco@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If IP_TOS or IP_TTL are specified as ancillary data, then sendmsg() sends out
packets with the specified TTL or TOS overriding the socket values specified
with the traditional setsockopt().

If there is a per-packet specified tos, the skb->priority is set accordingly.
The ipv4_is_multicast() function is used to fill in the right TTL value in case
of multicast destinations.

Signed-off-by: Francesco Fusco <ffusco@redhat.com>
---
 include/net/inet_sock.h |  3 +++
 net/ipv4/icmp.c         | 11 ++++++-----
 net/ipv4/ip_output.c    | 17 ++++++++++++++---
 net/ipv4/raw.c          |  3 +++
 net/ipv4/udp.c          |  3 +++
 5 files changed, 29 insertions(+), 8 deletions(-)

diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index b21a7f0..5e22c9e 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -101,6 +101,9 @@ struct inet_cork {
 	struct ip_options	*opt;
 	unsigned int		fragsize;
 	int			length; /* Total length of all frames */
+	__s16			ttl;
+	__s16			tos;
+	__u32			priority;
 	struct dst_entry	*dst;
 	u8			tx_flags;
 };
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 5f7d11a..28bccce 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -348,9 +348,11 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 
 	icmp_param->data.icmph.checksum = 0;
 
-	inet->tos = ip_hdr(skb)->tos;
 	daddr = ipc.addr = ip_hdr(skb)->saddr;
 	saddr = fib_compute_spec_dst(skb);
+	ipc.tos = ip_hdr(skb)->tos;
+	ipc.ttl = ipv4_is_multicast(daddr) ? inet->mc_ttl : inet->uc_ttl;
+	ipc.priority = sk->sk_priority;
 	ipc.opt = NULL;
 	ipc.tx_flags = 0;
 	if (icmp_param->replyopts.opt.opt.optlen) {
@@ -487,7 +489,6 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	struct ipcm_cookie ipc;
 	struct flowi4 fl4;
 	__be32 saddr;
-	u8  tos;
 	struct net *net;
 	struct sock *sk;
 
@@ -586,7 +587,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 		rcu_read_unlock();
 	}
 
-	tos = icmp_pointers[type].error ? ((iph->tos & IPTOS_TOS_MASK) |
+	ipc.tos = icmp_pointers[type].error ? ((iph->tos & IPTOS_TOS_MASK) |
 					   IPTOS_PREC_INTERNETCONTROL) :
 					  iph->tos;
 
@@ -604,12 +605,12 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	icmp_param->data.icmph.checksum	 = 0;
 	icmp_param->skb	  = skb_in;
 	icmp_param->offset = skb_network_offset(skb_in);
-	inet_sk(sk)->tos = tos;
+	ipc.ttl = -1;
 	ipc.addr = iph->saddr;
 	ipc.opt = &icmp_param->replyopts.opt;
 	ipc.tx_flags = 0;
 
-	rt = icmp_route_lookup(net, &fl4, skb_in, iph, saddr, tos,
+	rt = icmp_route_lookup(net, &fl4, skb_in, iph, saddr, ipc.tos,
 			       type, code, icmp_param);
 	if (IS_ERR(rt))
 		goto out_unlock;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 4bcabf3..bf46730 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1068,6 +1068,9 @@ static int ip_setup_cork(struct sock *sk, struct inet_cork *cork,
 			 rt->dst.dev->mtu : dst_mtu(&rt->dst);
 	cork->dst = &rt->dst;
 	cork->length = 0;
+	cork->ttl = ipc->ttl;
+	cork->tos = ipc->tos;
+	cork->priority = ipc->priority;
 	cork->tx_flags = ipc->tx_flags;
 
 	return 0;
@@ -1319,7 +1322,9 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 	if (cork->flags & IPCORK_OPT)
 		opt = cork->opt;
 
-	if (rt->rt_type == RTN_MULTICAST)
+	if (cork->ttl != -1)
+		ttl = cork->ttl;
+	else if (rt->rt_type == RTN_MULTICAST)
 		ttl = inet->mc_ttl;
 	else
 		ttl = ip_select_ttl(inet, &rt->dst);
@@ -1327,7 +1332,7 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 	iph = (struct iphdr *)skb->data;
 	iph->version = 4;
 	iph->ihl = 5;
-	iph->tos = inet->tos;
+	iph->tos = (cork->tos != inet->tos) ? cork->tos : inet->tos;
 	iph->frag_off = df;
 	iph->ttl = ttl;
 	iph->protocol = sk->sk_protocol;
@@ -1339,7 +1344,8 @@ struct sk_buff *__ip_make_skb(struct sock *sk,
 		ip_options_build(skb, opt, cork->addr, rt, 0);
 	}
 
-	skb->priority = sk->sk_priority;
+	skb->priority = (cork->tos != inet->tos) ? 
+		cork->priority : sk->sk_priority;
 	skb->mark = sk->sk_mark;
 	/*
 	 * Steal rt from cork.dst to avoid a pair of atomic_inc/atomic_dec
@@ -1511,6 +1517,11 @@ void ip_send_unicast_reply(struct net *net, struct sk_buff *skb, __be32 daddr,
 	inet = &get_cpu_var(unicast_sock);
 
 	inet->tos = arg->tos;
+
+	ipc.tos = ip_hdr(skb)->tos;
+	ipc.ttl = inet->uc_ttl;
+	ipc.priority = skb->priority;
+
 	sk = &inet->sk;
 	sk->sk_priority = skb->priority;
 	sk->sk_protocol = ip_hdr(skb)->protocol;
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index dd44e0a..68a9423 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -518,6 +518,9 @@ static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	ipc.opt = NULL;
 	ipc.tx_flags = 0;
 	ipc.oif = sk->sk_bound_dev_if;
+	ipc.ttl = ipv4_is_multicast(daddr) ? inet->mc_ttl : inet->uc_ttl;
+	ipc.tos = inet->tos;
+	ipc.priority = sk->sk_priority;
 
 	if (msg->msg_controllen) {
 		err = ip_cmsg_send(sock_net(sk), msg, &ipc);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 9e88af0..2d72ce8 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -904,6 +904,9 @@ int udp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	}
 	ipc.addr = inet->inet_saddr;
 
+	ipc.ttl = ipv4_is_multicast(daddr) ? inet->mc_ttl : inet->uc_ttl;
+	ipc.tos = inet->tos;
+	ipc.priority = sk->sk_priority;
 	ipc.oif = sk->sk_bound_dev_if;
 
 	sock_tx_timestamp(sk, &ipc.tx_flags);
-- 
1.8.3.1
