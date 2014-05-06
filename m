From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: [PATCH 1/3] netfilter: Fix potential use after free in ip6_route_me_harder()
Date: Tue,  6 May 2014 18:17:19 +0300
Message-ID: <1399389441-20095-1-git-send-email-popovich_sergei@mail.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback2.mail.ru ([94.100.176.87]:60948 "EHLO
	fallback6.mail.ru" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756798AbaEFPXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 11:23:32 -0400
Received: from smtp46.i.mail.ru (smtp46.i.mail.ru [94.100.177.106])
	by fallback6.mail.ru (mPOP.Fallback_MX) with ESMTP id EB848384AB76
	for <netdev@vger.kernel.org>; Tue,  6 May 2014 19:17:48 +0400 (MSK)
Received: from [195.234.68.4] (port=52741 helo=tuxracer.skif.com.ua)
	by smtp46.i.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1Whh7X-0007OK-7d
	for netdev@vger.kernel.org; Tue, 06 May 2014 19:17:27 +0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dst is released one line before we access it again with dst->error.

Fixes: 58e35d147128 netfilter: ipv6: propagate routing errors from
ip6_route_me_harder()

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>
---
 net/ipv6/netfilter.c | 6 ++++--
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
1.8.3.4
