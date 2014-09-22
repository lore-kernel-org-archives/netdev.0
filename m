From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/3] ipv4: rename ip_options_echo to __ip_options_echo()
Date: Mon, 22 Sep 2014 16:50:42 -0700
Message-ID: <1411429844-11099-2-git-send-email-edumazet@google.com>
References: <1411429844-11099-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f202.google.com ([209.85.213.202]:42431 "EHLO
	mail-ig0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752727AbaIVXuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 19:50:54 -0400
Received: by mail-ig0-f202.google.com with SMTP id h15so644568igd.3
        for <netdev@vger.kernel.org>; Mon, 22 Sep 2014 16:50:54 -0700 (PDT)
In-Reply-To: <1411429844-11099-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_options_echo() assumes struct ip_options is provided in &IPCB(skb)->opt
Lets break this assumption, but provide a helper to not change all call points.

ip_send_unicast_reply() gets a new struct ip_options pointer.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip.h      | 15 ++++++++++++---
 net/ipv4/ip_options.c |  6 ++----
 net/ipv4/ip_output.c  |  8 +++++---
 net/ipv4/tcp_ipv4.c   | 10 ++++++----
 4 files changed, 25 insertions(+), 14 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 14bfc8e1bcf9..c90e3357d589 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -180,8 +180,10 @@ static inline __u8 ip_reply_arg_flowi_flags(const struct ip_reply_arg *arg)
 	return (arg->flags & IP_REPLY_ARG_NOSRCCHECK) ? FLOWI_FLAG_ANYSRC : 0;
 }
 
-void ip_send_unicast_reply(struct net *net, struct sk_buff *skb, __be32 daddr,
-			   __be32 saddr, const struct ip_reply_arg *arg,
+void ip_send_unicast_reply(struct net *net, struct sk_buff *skb,
+			   const struct ip_options *sopt,
+			   __be32 daddr, __be32 saddr,
+			   const struct ip_reply_arg *arg,
 			   unsigned int len);
 
 #define IP_INC_STATS(net, field)	SNMP_INC_STATS64((net)->mib.ip_statistics, field)
@@ -511,7 +513,14 @@ int ip_forward(struct sk_buff *skb);
  
 void ip_options_build(struct sk_buff *skb, struct ip_options *opt,
 		      __be32 daddr, struct rtable *rt, int is_frag);
-int ip_options_echo(struct ip_options *dopt, struct sk_buff *skb);
+
+int __ip_options_echo(struct ip_options *dopt, struct sk_buff *skb,
+		      const struct ip_options *sopt);
+static inline int ip_options_echo(struct ip_options *dopt, struct sk_buff *skb)
+{
+	return __ip_options_echo(dopt, skb, &IPCB(skb)->opt);
+}
+
 void ip_options_fragment(struct sk_buff *skb);
 int ip_options_compile(struct net *net, struct ip_options *opt,
 		       struct sk_buff *skb);
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index ad382499bace..5b3d91be2db0 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -87,17 +87,15 @@ void ip_options_build(struct sk_buff *skb, struct ip_options *opt,
  * NOTE: dopt cannot point to skb.
  */
 
-int ip_options_echo(struct ip_options *dopt, struct sk_buff *skb)
+int __ip_options_echo(struct ip_options *dopt, struct sk_buff *skb,
+		      const struct ip_options *sopt)
 {
-	const struct ip_options *sopt;
 	unsigned char *sptr, *dptr;
 	int soffset, doffset;
 	int	optlen;
 
 	memset(dopt, 0, sizeof(struct ip_options));
 
-	sopt = &(IPCB(skb)->opt);
-
 	if (sopt->optlen == 0)
 		return 0;
 
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 215af2b155cb..c8fa62476461 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1522,8 +1522,10 @@ static DEFINE_PER_CPU(struct inet_sock, unicast_sock) = {
 	.uc_ttl		= -1,
 };
 
-void ip_send_unicast_reply(struct net *net, struct sk_buff *skb, __be32 daddr,
-			   __be32 saddr, const struct ip_reply_arg *arg,
+void ip_send_unicast_reply(struct net *net, struct sk_buff *skb,
+			   const struct ip_options *sopt,
+			   __be32 daddr, __be32 saddr,
+			   const struct ip_reply_arg *arg,
 			   unsigned int len)
 {
 	struct ip_options_data replyopts;
@@ -1534,7 +1536,7 @@ void ip_send_unicast_reply(struct net *net, struct sk_buff *skb, __be32 daddr,
 	struct sock *sk;
 	struct inet_sock *inet;
 
-	if (ip_options_echo(&replyopts.opt.opt, skb))
+	if (__ip_options_echo(&replyopts.opt.opt, skb, sopt))
 		return;
 
 	ipc.addr = daddr;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3b2e49cb2b61..28ab90382c01 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -681,8 +681,9 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 
 	net = dev_net(skb_dst(skb)->dev);
 	arg.tos = ip_hdr(skb)->tos;
-	ip_send_unicast_reply(net, skb, ip_hdr(skb)->saddr,
-			      ip_hdr(skb)->daddr, &arg, arg.iov[0].iov_len);
+	ip_send_unicast_reply(net, skb, &TCP_SKB_CB(skb)->header.h4.opt,
+			      ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
+			      &arg, arg.iov[0].iov_len);
 
 	TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
 	TCP_INC_STATS_BH(net, TCP_MIB_OUTRSTS);
@@ -764,8 +765,9 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 	if (oif)
 		arg.bound_dev_if = oif;
 	arg.tos = tos;
-	ip_send_unicast_reply(net, skb, ip_hdr(skb)->saddr,
-			      ip_hdr(skb)->daddr, &arg, arg.iov[0].iov_len);
+	ip_send_unicast_reply(net, skb, &TCP_SKB_CB(skb)->header.h4.opt,
+			      ip_hdr(skb)->saddr, ip_hdr(skb)->daddr,
+			      &arg, arg.iov[0].iov_len);
 
 	TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
 }
-- 
2.1.0.rc2.206.gedb03e5
