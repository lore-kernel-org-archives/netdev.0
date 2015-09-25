From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 09/17] ip: constify ip_build_and_send_pkt() socket argument
Date: Fri, 25 Sep 2015 07:39:16 -0700
Message-ID: <1443191964-923-10-git-send-email-edumazet@google.com>
References: <1443191964-923-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36406 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932396AbbIYOkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:40:13 -0400
Received: by pablk4 with SMTP id lk4so10825606pab.3
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 07:40:12 -0700 (PDT)
In-Reply-To: <1443191964-923-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function is used to build and send SYNACK packets,
possibly on behalf of unlocked listener socket.

Make sure we did not miss a write by making this socket const.

We no longer can use ip_select_ident() and have to either
set iph->id to 0 or directly call __ip_select_ident()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ip.h     |  2 +-
 net/ipv4/ip_output.c | 14 ++++++++------
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 525dc0778926..91a6b2c88341 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -100,7 +100,7 @@ int igmp_mc_init(void);
  *	Functions provided by ip.c
  */
 
-int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
+int ip_build_and_send_pkt(struct sk_buff *skb, const struct sock *sk,
 			  __be32 saddr, __be32 daddr,
 			  struct ip_options_rcu *opt);
 int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 09a6b7bb7ea3..06d2c87ed505 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -137,7 +137,7 @@ static inline int ip_select_ttl(struct inet_sock *inet, struct dst_entry *dst)
  *		Add an ip header to a skbuff and send it out.
  *
  */
-int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
+int ip_build_and_send_pkt(struct sk_buff *skb, const struct sock *sk,
 			  __be32 saddr, __be32 daddr, struct ip_options_rcu *opt)
 {
 	struct inet_sock *inet = inet_sk(sk);
@@ -151,15 +151,17 @@ int ip_build_and_send_pkt(struct sk_buff *skb, struct sock *sk,
 	iph->version  = 4;
 	iph->ihl      = 5;
 	iph->tos      = inet->tos;
-	if (ip_dont_fragment(sk, &rt->dst))
-		iph->frag_off = htons(IP_DF);
-	else
-		iph->frag_off = 0;
 	iph->ttl      = ip_select_ttl(inet, &rt->dst);
 	iph->daddr    = (opt && opt->opt.srr ? opt->opt.faddr : daddr);
 	iph->saddr    = saddr;
 	iph->protocol = sk->sk_protocol;
-	ip_select_ident(sock_net(sk), skb, sk);
+	if (ip_dont_fragment(sk, &rt->dst)) {
+		iph->frag_off = htons(IP_DF);
+		iph->id = 0;
+	} else {
+		iph->frag_off = 0;
+		__ip_select_ident(sock_net(sk), iph, 1);
+	}
 
 	if (opt && opt->opt.optlen) {
 		iph->ihl += opt->opt.optlen>>2;
-- 
2.6.0.rc2.230.g3dd15c0
