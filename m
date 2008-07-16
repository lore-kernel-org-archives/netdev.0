From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 6/20] inet: prepare struct net for TCP MIB accounting
Date: Wed, 16 Jul 2008 12:16:08 +0400
Message-ID: <487DAE48.1020100@openvz.org>
References: <487DABB6.5080905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:36893 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755603AbYGPIQP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 04:16:15 -0400
In-Reply-To: <487DABB6.5080905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the same as the first patch in the set, but preparing
the net for TCP_XXX_STATS - save the struct net on the stack
where required and possible.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 net/ipv4/tcp_ipv4.c |   10 +++++++---
 net/ipv6/tcp_ipv6.c |    3 ++-
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 7797d52..db3bf9b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -544,6 +544,7 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 #ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key *key;
 #endif
+	struct net *net;
 
 	/* Never send a reset in response to a reset. */
 	if (th->rst)
@@ -594,7 +595,8 @@ static void tcp_v4_send_reset(struct sock *sk, struct sk_buff *skb)
 				      sizeof(struct tcphdr), IPPROTO_TCP, 0);
 	arg.csumoffset = offsetof(struct tcphdr, check) / 2;
 
-	ip_send_reply(dev_net(skb->dst->dev)->ipv4.tcp_sock, skb,
+	net = dev_net(skb->dst->dev);
+	ip_send_reply(net->ipv4.tcp_sock, skb,
 		      &arg, arg.iov[0].iov_len);
 
 	TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
@@ -619,6 +621,7 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 			];
 	} rep;
 	struct ip_reply_arg arg;
+	struct net *net = dev_net(skb->dev);
 
 	memset(&rep.th, 0, sizeof(struct tcphdr));
 	memset(&arg, 0, sizeof(arg));
@@ -668,7 +671,7 @@ static void tcp_v4_send_ack(struct sk_buff *skb, u32 seq, u32 ack,
 	if (oif)
 		arg.bound_dev_if = oif;
 
-	ip_send_reply(dev_net(skb->dev)->ipv4.tcp_sock, skb,
+	ip_send_reply(net->ipv4.tcp_sock, skb,
 		      &arg, arg.iov[0].iov_len);
 
 	TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
@@ -1505,6 +1508,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	struct tcphdr *th;
 	struct sock *sk;
 	int ret;
+	struct net *net = dev_net(skb->dev);
 
 	if (skb->pkt_type != PACKET_HOST)
 		goto discard_it;
@@ -1539,7 +1543,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
 	TCP_SKB_CB(skb)->flags	 = iph->tos;
 	TCP_SKB_CB(skb)->sacked	 = 0;
 
-	sk = __inet_lookup(dev_net(skb->dev), &tcp_hashinfo, iph->saddr,
+	sk = __inet_lookup(net, &tcp_hashinfo, iph->saddr,
 			th->source, iph->daddr, th->dest, inet_iif(skb));
 	if (!sk)
 		goto no_tcp_socket;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 30dbab7..fc5f716 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1617,6 +1617,7 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	struct tcphdr *th;
 	struct sock *sk;
 	int ret;
+	struct net *net = dev_net(skb->dev);
 
 	if (skb->pkt_type != PACKET_HOST)
 		goto discard_it;
@@ -1648,7 +1649,7 @@ static int tcp_v6_rcv(struct sk_buff *skb)
 	TCP_SKB_CB(skb)->flags = ipv6_get_dsfield(ipv6_hdr(skb));
 	TCP_SKB_CB(skb)->sacked = 0;
 
-	sk = __inet6_lookup(dev_net(skb->dev), &tcp_hashinfo,
+	sk = __inet6_lookup(net, &tcp_hashinfo,
 			&ipv6_hdr(skb)->saddr, th->source,
 			&ipv6_hdr(skb)->daddr, ntohs(th->dest),
 			inet6_iif(skb));
-- 
1.5.5.1

