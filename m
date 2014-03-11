From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH] net: reflect the fwmark for replies with no socket
Date: Tue, 11 Mar 2014 20:15:41 +0900
Message-ID: <1394536541-25702-1-git-send-email-lorenzo@google.com>
Cc: David Miller <davem@davemloft.net>,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:39632 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753233AbaCKLP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 07:15:56 -0400
Received: by mail-pd0-f180.google.com with SMTP id v10so8437049pde.11
        for <netdev@vger.kernel.org>; Tue, 11 Mar 2014 04:15:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel-originated IP packets that have no user socket associated
with them (e.g., ICMP errors and echo replies, TCP RSTs, etc.)
are emitted with a mark of zero. Instead, make them have the
same mark as the packet they are replying to.

This is consistent with TOS, which is also reflected from the
incoming packet, and it allows the administrator to use
mark-based routing, firewalling, etc. for these replies by
marking the original packets inbound.

Also fix the IPv6 code to reflect the tclass in replies like the
IPv4 code does.

Change-Id: Ifd8dd75016e60dc982e7860f720d45c27dcaf04c
Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 net/ipv4/icmp.c      | 10 ++++++++--
 net/ipv4/ip_output.c |  2 +-
 net/ipv6/tcp_ipv6.c  |  7 +++++--
 3 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 0134663..3b101a4 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -349,6 +349,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	icmp_param->data.icmph.checksum = 0;
 
 	inet->tos = ip_hdr(skb)->tos;
+	sk->sk_mark = skb->mark;
 	daddr = ipc.addr = ip_hdr(skb)->saddr;
 	saddr = fib_compute_spec_dst(skb);
 	ipc.opt = NULL;
@@ -364,6 +365,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	memset(&fl4, 0, sizeof(fl4));
 	fl4.daddr = daddr;
 	fl4.saddr = saddr;
+	fl4.flowi4_mark = skb->mark;
 	fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
 	fl4.flowi4_proto = IPPROTO_ICMP;
 	security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
@@ -382,7 +384,7 @@ static struct rtable *icmp_route_lookup(struct net *net,
 					struct flowi4 *fl4,
 					struct sk_buff *skb_in,
 					const struct iphdr *iph,
-					__be32 saddr, u8 tos,
+					__be32 saddr, u8 tos, u32 mark,
 					int type, int code,
 					struct icmp_bxm *param)
 {
@@ -394,6 +396,7 @@ static struct rtable *icmp_route_lookup(struct net *net,
 	fl4->daddr = (param->replyopts.opt.opt.srr ?
 		      param->replyopts.opt.opt.faddr : iph->saddr);
 	fl4->saddr = saddr;
+	fl4->flowi4_mark = mark;
 	fl4->flowi4_tos = RT_TOS(tos);
 	fl4->flowi4_proto = IPPROTO_ICMP;
 	fl4->fl4_icmp_type = type;
@@ -491,6 +494,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	struct flowi4 fl4;
 	__be32 saddr;
 	u8  tos;
+	u32 mark;
 	struct net *net;
 	struct sock *sk;
 
@@ -592,6 +596,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	tos = icmp_pointers[type].error ? ((iph->tos & IPTOS_TOS_MASK) |
 					   IPTOS_PREC_INTERNETCONTROL) :
 					  iph->tos;
+	mark = skb_in->mark;
 
 	if (ip_options_echo(&icmp_param->replyopts.opt.opt, skb_in))
 		goto out_unlock;
@@ -608,13 +613,14 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	icmp_param->skb	  = skb_in;
 	icmp_param->offset = skb_network_offset(skb_in);
 	inet_sk(sk)->tos = tos;
+	sk->sk_mark = mark;
 	ipc.addr = iph->saddr;
 	ipc.opt = &icmp_param->replyopts.opt;
 	ipc.tx_flags = 0;
 	ipc.ttl = 0;
 	ipc.tos = -1;
 
-	rt = icmp_route_lookup(net, &fl4, skb_in, iph, saddr, tos,
+	rt = icmp_route_lookup(net, &fl4, skb_in, iph, saddr, tos, mark,
 			       type, code, icmp_param);
 	if (IS_ERR(rt))
 		goto out_unlock;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 1a0755f..a6039b1 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1501,7 +1501,7 @@ void ip_send_unicast_reply(struct net *net, struct sk_buff *skb, __be32 daddr,
 			daddr = replyopts.opt.opt.faddr;
 	}
 
-	flowi4_init_output(&fl4, arg->bound_dev_if, 0,
+	flowi4_init_output(&fl4, arg->bound_dev_if, skb->mark,
 			   RT_TOS(arg->tos),
 			   RT_SCOPE_UNIVERSE, ip_hdr(skb)->protocol,
 			   ip_reply_arg_flowi_flags(arg),
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3277680..b4f0388 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -802,6 +802,7 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 	fl6.flowi6_proto = IPPROTO_TCP;
 	if (ipv6_addr_type(&fl6.daddr) & IPV6_ADDR_LINKLOCAL)
 		fl6.flowi6_oif = inet6_iif(skb);
+	fl6.flowi6_mark = skb->mark;
 	fl6.fl6_dport = t1->dest;
 	fl6.fl6_sport = t1->source;
 	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
@@ -828,6 +829,7 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 	const struct tcphdr *th = tcp_hdr(skb);
 	u32 seq = 0, ack_seq = 0;
 	struct tcp_md5sig_key *key = NULL;
+	u8 tclass;
 #ifdef CONFIG_TCP_MD5SIG
 	const __u8 *hash_location = NULL;
 	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
@@ -878,7 +880,8 @@ static void tcp_v6_send_reset(struct sock *sk, struct sk_buff *skb)
 		ack_seq = ntohl(th->seq) + th->syn + th->fin + skb->len -
 			  (th->doff << 2);
 
-	tcp_v6_send_response(skb, seq, ack_seq, 0, 0, 0, key, 1, 0, 0);
+	tclass = ipv6_get_dsfield(ipv6_hdr(skb));
+	tcp_v6_send_response(skb, seq, ack_seq, 0, 0, 0, key, 1, tclass, 0);
 
 #ifdef CONFIG_TCP_MD5SIG
 release_sk1:
@@ -918,7 +921,7 @@ static void tcp_v6_reqsk_send_ack(struct sock *sk, struct sk_buff *skb,
 	tcp_v6_send_ack(skb, tcp_rsk(req)->snt_isn + 1, tcp_rsk(req)->rcv_isn + 1,
 			req->rcv_wnd, tcp_time_stamp, req->ts_recent,
 			tcp_v6_md5_do_lookup(sk, &ipv6_hdr(skb)->daddr),
-			0, 0);
+			ipv6_get_dsfield(ipv6_hdr(skb)), 0);
 }
 
 
-- 
1.9.0.279.gdc9e3eb
