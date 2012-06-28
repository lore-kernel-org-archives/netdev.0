From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Show that ip_send_reply() is purely unicast routine.
Date: Thu, 28 Jun 2012 03:22:21 -0700 (PDT)
Message-ID: <20120628.032221.670647985041908413.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51489 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932865Ab2F1KWX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 06:22:23 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 12DD95847CC
	for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 03:22:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Rename it to ip_send_unicast_reply() and add explicit 'saddr'
argument.

This removed one of the few users of rt->rt_spec_dst.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/ip.h     |    5 +++--
 net/ipv4/ip_output.c |    9 +++++----
 net/ipv4/tcp_ipv4.c  |    8 ++++----
 3 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 50841bd..ec5cfde 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -158,8 +158,9 @@ static inline __u8 ip_reply_arg_flowi_flags(const struct ip_reply_arg *arg)
 	return (arg->flags & IP_REPLY_ARG_NOSRCCHECK) ? FLOWI_FLAG_ANYSRC : 0;
 }
 
-void ip_send_reply(struct sock *sk, struct sk_buff *skb, __be32 daddr,
-		   const struct ip_reply_arg *arg, unsigned int len);
+void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb, __be32 daddr,
+			   __be32 saddr, const struct ip_reply_arg *arg,
+			   unsigned int len);
 
 struct ipv4_config {
 	int	log_martians;
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 0f3185a..2630900 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1459,13 +1459,14 @@ static int ip_reply_glue_bits(void *dptr, char *to, int offset,
 
 /*
  *	Generic function to send a packet as reply to another packet.
- *	Used to send TCP resets so far. ICMP should use this function too.
+ *	Used to send TCP resets so far.
  *
  *	Should run single threaded per socket because it uses the sock
  *     	structure to pass arguments.
  */
-void ip_send_reply(struct sock *sk, struct sk_buff *skb, __be32 daddr,
-		   const struct ip_reply_arg *arg, unsigned int len)
+void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb, __be32 daddr,
+			   __be32 saddr, const struct ip_reply_arg *arg,
+			   unsigned int len)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ip_options_data replyopts;
@@ -1491,7 +1492,7 @@ void ip_send_reply(struct sock *sk, struct sk_buff *skb, __be32 daddr,
 			   RT_TOS(arg->tos),
 			   RT_SCOPE_UNIVERSE, sk->sk_protocol,
 			   ip_reply_arg_flowi_flags(arg),
-			   daddr, rt->rt_spec_dst,
+			   daddr, saddr,
 			   tcp_hdr(skb)->source, tcp_hdr(skb)->dest);
 	security_skb_classify_flow(skb, flowi4_to_flowi(&fl4));
 	rt = ip_route_output_key(sock_net(sk), &fl4);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b4ae1c1..64568fa 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -698,8 +698,8 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 
 	net = dev_net(skb_dst(skb)->dev);
 	arg.tos = ip_hdr(skb)->tos;
-	ip_send_reply(net->ipv4.tcp_sock, skb, ip_hdr(skb)->saddr,
-		      &arg, arg.iov[0].iov_len);
+	ip_send_unicast_reply(net->ipv4.tcp_sock, skb, ip_hdr(skb)->saddr,
+			      ip_hdr(skb)->daddr, &arg, arg.iov[0].iov_len);
 
 	TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
 	TCP_INC_STATS_BH(net, TCP_MIB_OUTRSTS);
@@ -781,8 +781,8 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 	if (oif)
 		arg.bound_dev_if = oif;
 	arg.tos = tos;
-	ip_send_reply(net->ipv4.tcp_sock, skb, ip_hdr(skb)->saddr,
-		      &arg, arg.iov[0].iov_len);
+	ip_send_unicast_reply(net->ipv4.tcp_sock, skb, ip_hdr(skb)->saddr,
+			      ip_hdr(skb)->daddr, &arg, arg.iov[0].iov_len);
 
 	TCP_INC_STATS_BH(net, TCP_MIB_OUTSEGS);
 }
-- 
1.7.10.2
