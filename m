From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 6/6] netfilter: Fix potential use after free in ip6_route_me_harder()
Date: Fri,  9 May 2014 12:56:07 +0200
Message-ID: <1399632967-4423-7-git-send-email-pablo@netfilter.org>
References: <1399632967-4423-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40276 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755884AbaEIK4U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 May 2014 06:56:20 -0400
In-Reply-To: <1399632967-4423-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergey Popovich <popovich_sergei@mail.ru>

Dst is released one line before we access it again with dst->error.

Fixes: 58e35d147128 netfilter: ipv6: propagate routing errors from
ip6_route_me_harder()

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 95f3f1d..d38e6a8 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -30,13 +30,15 @@ int ip6_route_me_harder(struct sk_buff *skb)
 		.daddr = iph->daddr,
 		.saddr = iph->saddr,
 	};
+	int err;
 
 	dst = ip6_route_output(net, skb->sk, &fl6);
-	if (dst->error) {
+	err = dst->error;
+	if (err) {
 		IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
 		LIMIT_NETDEBUG(KERN_DEBUG "ip6_route_me_harder: No more route.\n");
 		dst_release(dst);
-		return dst->error;
+		return err;
 	}
 
 	/* Drop old route. */
-- 
1.7.10.4
