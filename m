From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH v3] net: add a sysctl to reflect the fwmark on replies
Date: Tue,  8 Apr 2014 08:58:51 +0900
Message-ID: <1396915131-20353-1-git-send-email-lorenzo@google.com>
Cc: davem@davemloft.net, ja@ssi.bg, hannes@stressinduktion.org,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:41425 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755944AbaDGX7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Apr 2014 19:59:05 -0400
Received: by mail-pa0-f53.google.com with SMTP id ld10so172493pab.40
        for <netdev@vger.kernel.org>; Mon, 07 Apr 2014 16:59:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kernel-originated IP packets that have no user socket associated
with them (e.g., ICMP errors and echo replies, TCP RSTs, etc.)
are emitted with a mark of zero. Add a sysctl to make them have
the same mark as the packet they are replying to.

This allows an administrator that wishes to do so to use
mark-based routing, firewalling, etc. for these replies by
marking the original packets inbound.

Tested using user-mode linux:
 - ICMP/ICMPv6 echo replies and errors.
 - TCP RST packets (IPv4 and IPv6).

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 include/net/ip.h           |  3 +++
 include/net/ipv6.h         |  3 +++
 include/net/netns/ipv4.h   |  2 ++
 include/net/netns/ipv6.h   |  1 +
 net/ipv4/icmp.c            | 11 +++++++++--
 net/ipv4/ip_output.c       |  3 ++-
 net/ipv4/sysctl_net_ipv4.c |  7 +++++++
 net/ipv6/icmp.c            |  6 ++++++
 net/ipv6/sysctl_net_ipv6.c |  7 +++++++
 net/ipv6/tcp_ipv6.c        |  1 +
 10 files changed, 41 insertions(+), 3 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 25064c2..c886b09 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -238,6 +238,9 @@ void ipfrag_init(void);
 
 void ip_static_sysctl_init(void);
 
+#define IP4_REPLY_MARK(net, mark) \
+	((net)->ipv4.sysctl_fwmark_reflect ? (mark) : 0)
+
 static inline bool ip_is_fragment(const struct iphdr *iph)
 {
 	return (iph->frag_off & htons(IP_MF | IP_OFFSET)) != 0;
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 4f541f1..b80290c 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -113,6 +113,9 @@ struct frag_hdr {
 #define	IP6_MF		0x0001
 #define	IP6_OFFSET	0xFFF8
 
+#define IP6_REPLY_MARK(net, mark) \
+	((net)->ipv6.sysctl.fwmark_reflect ? (mark) : 0)
+
 #include <net/sock.h>
 
 /* sysctls */
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index 80f500a..8e1a9c0 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -72,6 +72,8 @@ struct netns_ipv4 {
 	int sysctl_ip_no_pmtu_disc;
 	int sysctl_ip_fwd_use_pmtu;
 
+	int sysctl_fwmark_reflect;
+
 	kgid_t sysctl_ping_group_range[2];
 
 	atomic_t dev_addr_genid;
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 21edaf1..19d3446 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -30,6 +30,7 @@ struct netns_sysctl_ipv6 {
 	int flowlabel_consistency;
 	int icmpv6_time;
 	int anycast_src_echo_reply;
+	int fwmark_reflect;
 };
 
 struct netns_ipv6 {
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 0134663..31f45f8 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -337,6 +337,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	struct sock *sk;
 	struct inet_sock *inet;
 	__be32 daddr, saddr;
+	u32 mark = IP4_REPLY_MARK(net, skb->mark);
 
 	if (ip_options_echo(&icmp_param->replyopts.opt.opt, skb))
 		return;
@@ -349,6 +350,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	icmp_param->data.icmph.checksum = 0;
 
 	inet->tos = ip_hdr(skb)->tos;
+	sk->sk_mark = mark;
 	daddr = ipc.addr = ip_hdr(skb)->saddr;
 	saddr = fib_compute_spec_dst(skb);
 	ipc.opt = NULL;
@@ -364,6 +366,7 @@ static void icmp_reply(struct icmp_bxm *icmp_param, struct sk_buff *skb)
 	memset(&fl4, 0, sizeof(fl4));
 	fl4.daddr = daddr;
 	fl4.saddr = saddr;
+	fl4.flowi4_mark = mark;
 	fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
 	fl4.flowi4_proto = IPPROTO_ICMP;
 	security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
@@ -382,7 +385,7 @@ static struct rtable *icmp_route_lookup(struct net *net,
 					struct flowi4 *fl4,
 					struct sk_buff *skb_in,
 					const struct iphdr *iph,
-					__be32 saddr, u8 tos,
+					__be32 saddr, u8 tos, u32 mark,
 					int type, int code,
 					struct icmp_bxm *param)
 {
@@ -394,6 +397,7 @@ static struct rtable *icmp_route_lookup(struct net *net,
 	fl4->daddr = (param->replyopts.opt.opt.srr ?
 		      param->replyopts.opt.opt.faddr : iph->saddr);
 	fl4->saddr = saddr;
+	fl4->flowi4_mark = mark;
 	fl4->flowi4_tos = RT_TOS(tos);
 	fl4->flowi4_proto = IPPROTO_ICMP;
 	fl4->fl4_icmp_type = type;
@@ -491,6 +495,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	struct flowi4 fl4;
 	__be32 saddr;
 	u8  tos;
+	u32 mark;
 	struct net *net;
 	struct sock *sk;
 
@@ -592,6 +597,7 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
 	tos = icmp_pointers[type].error ? ((iph->tos & IPTOS_TOS_MASK) |
 					   IPTOS_PREC_INTERNETCONTROL) :
 					  iph->tos;
+	mark = IP4_REPLY_MARK(net, skb_in->mark);
 
 	if (ip_options_echo(&icmp_param->replyopts.opt.opt, skb_in))
 		goto out_unlock;
@@ -608,13 +614,14 @@ void icmp_send(struct sk_buff *skb_in, int type, int code, __be32 info)
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
index 1a0755f..8461dba 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1501,7 +1501,8 @@ void ip_send_unicast_reply(struct net *net, struct sk_buff *skb, __be32 daddr,
 			daddr = replyopts.opt.opt.faddr;
 	}
 
-	flowi4_init_output(&fl4, arg->bound_dev_if, 0,
+	flowi4_init_output(&fl4, arg->bound_dev_if,
+			   IP4_REPLY_MARK(net, skb->mark),
 			   RT_TOS(arg->tos),
 			   RT_SCOPE_UNIVERSE, ip_hdr(skb)->protocol,
 			   ip_reply_arg_flowi_flags(arg),
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 44eba05..e40a738 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -838,6 +838,13 @@ static struct ctl_table ipv4_net_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec,
 	},
+	{
+		.procname	= "fwmark_reflect",
+		.data		= &init_net.ipv4.sysctl_fwmark_reflect,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
 	{ }
 };
 
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 7b32652..1dd2128 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -400,6 +400,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	int len;
 	int hlimit;
 	int err = 0;
+	u32 mark = IP6_REPLY_MARK(net, skb->mark);
 
 	if ((u8 *)hdr < skb->head ||
 	    (skb_network_header(skb) + sizeof(*hdr)) > skb_tail_pointer(skb))
@@ -466,6 +467,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	fl6.daddr = hdr->saddr;
 	if (saddr)
 		fl6.saddr = *saddr;
+	fl6.flowi6_mark = mark;
 	fl6.flowi6_oif = iif;
 	fl6.fl6_icmp_type = type;
 	fl6.fl6_icmp_code = code;
@@ -474,6 +476,7 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	sk = icmpv6_xmit_lock(net);
 	if (sk == NULL)
 		return;
+	sk->sk_mark = mark;
 	np = inet6_sk(sk);
 
 	if (!icmpv6_xrlim_allow(sk, type, &fl6))
@@ -556,6 +559,7 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 	int err = 0;
 	int hlimit;
 	u8 tclass;
+	u32 mark = IP6_REPLY_MARK(net, skb->mark);
 
 	saddr = &ipv6_hdr(skb)->daddr;
 
@@ -574,11 +578,13 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 		fl6.saddr = *saddr;
 	fl6.flowi6_oif = skb->dev->ifindex;
 	fl6.fl6_icmp_type = ICMPV6_ECHO_REPLY;
+	fl6.flowi6_mark = mark;
 	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
 
 	sk = icmpv6_xmit_lock(net);
 	if (sk == NULL)
 		return;
+	sk->sk_mark = mark;
 	np = inet6_sk(sk);
 
 	if (!fl6.flowi6_oif && ipv6_addr_is_multicast(&fl6.daddr))
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 7f405a1..058f3ec 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -38,6 +38,13 @@ static struct ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "fwmark_reflect",
+		.data		= &init_net.ipv6.sysctl.fwmark_reflect,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 5ca56ce..c2021ef 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -802,6 +802,7 @@ static void tcp_v6_send_response(struct sk_buff *skb, u32 seq, u32 ack, u32 win,
 		fl6.flowi6_oif = inet6_iif(skb);
 	else
 		fl6.flowi6_oif = oif;
+	fl6.flowi6_mark = IP6_REPLY_MARK(net, skb->mark);
 	fl6.fl6_dport = t1->dest;
 	fl6.fl6_sport = t1->source;
 	security_skb_classify_flow(skb, flowi6_to_flowi(&fl6));
-- 
1.9.1.423.g4596e3a
