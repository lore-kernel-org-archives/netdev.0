From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 1/4] netfilter: use skb_to_full_sk in ip_route_me_harder
Date: Fri,  3 Mar 2017 20:22:22 +0100
Message-ID: <1488568945-4177-2-git-send-email-pablo@netfilter.org>
References: <1488568945-4177-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39556 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752057AbdCCTW6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Mar 2017 14:22:58 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 9062E1C500B
        for <netdev@vger.kernel.org>; Fri,  3 Mar 2017 20:22:36 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 803ECDA816
        for <netdev@vger.kernel.org>; Fri,  3 Mar 2017 20:22:36 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 7865DDA811
        for <netdev@vger.kernel.org>; Fri,  3 Mar 2017 20:22:33 +0100 (CET)
In-Reply-To: <1488568945-4177-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

inet_sk(skb->sk) is illegal in case skb is attached to request socket.

Fixes: ca6fb0651883 ("tcp: attach SYNACK messages to request sockets instead of listener")
Reported by: Daniel J Blueman <daniel@quora.org>
Signed-off-by: Florian Westphal <fw@strlen.de>
Tested-by: Daniel J Blueman <daniel@quora.org>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv4/netfilter.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index b3cc1335adbc..c0cc6aa8cfaa 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -23,7 +23,8 @@ int ip_route_me_harder(struct net *net, struct sk_buff *skb, unsigned int addr_t
 	struct rtable *rt;
 	struct flowi4 fl4 = {};
 	__be32 saddr = iph->saddr;
-	__u8 flags = skb->sk ? inet_sk_flowi_flags(skb->sk) : 0;
+	const struct sock *sk = skb_to_full_sk(skb);
+	__u8 flags = sk ? inet_sk_flowi_flags(sk) : 0;
 	struct net_device *dev = skb_dst(skb)->dev;
 	unsigned int hh_len;
 
@@ -40,7 +41,7 @@ int ip_route_me_harder(struct net *net, struct sk_buff *skb, unsigned int addr_t
 	fl4.daddr = iph->daddr;
 	fl4.saddr = saddr;
 	fl4.flowi4_tos = RT_TOS(iph->tos);
-	fl4.flowi4_oif = skb->sk ? skb->sk->sk_bound_dev_if : 0;
+	fl4.flowi4_oif = sk ? sk->sk_bound_dev_if : 0;
 	if (!fl4.flowi4_oif)
 		fl4.flowi4_oif = l3mdev_master_ifindex(dev);
 	fl4.flowi4_mark = skb->mark;
@@ -61,7 +62,7 @@ int ip_route_me_harder(struct net *net, struct sk_buff *skb, unsigned int addr_t
 	    xfrm_decode_session(skb, flowi4_to_flowi(&fl4), AF_INET) == 0) {
 		struct dst_entry *dst = skb_dst(skb);
 		skb_dst_set(skb, NULL);
-		dst = xfrm_lookup(net, dst, flowi4_to_flowi(&fl4), skb->sk, 0);
+		dst = xfrm_lookup(net, dst, flowi4_to_flowi(&fl4), sk, 0);
 		if (IS_ERR(dst))
 			return PTR_ERR(dst);
 		skb_dst_set(skb, dst);
-- 
2.1.4
