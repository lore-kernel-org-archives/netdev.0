From: Andrew Yourtchenko <ayourtch@gmail.com>
Subject: [PATCH 1/2] ipv6: save route expiry in RTA_EXPIRES if RTF_EXPIRES set
Date: Tue, 16 Aug 2016 15:59:02 +0200
Message-ID: <1471355943-21288-2-git-send-email-ayourtch@gmail.com>
References: <1471355943-21288-1-git-send-email-ayourtch@gmail.com>
Cc: Andrew Yourtchenko <ayourtch@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36256 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753430AbcHPN70 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 09:59:26 -0400
Received: by mail-wm0-f65.google.com with SMTP id i138so16542772wmf.3
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2016 06:59:23 -0700 (PDT)
In-Reply-To: <1471355943-21288-1-git-send-email-ayourtch@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This allows "ip -6 route save" to save the expiry for the routes
that have it, such that it can be correctly restored later by
"ip -6 route restore".

If a route has RTF_EXPIRES set, generate RTA_EXPIRES value which
will be used to restore the flag and expiry value by already
existing code in rtm_to_fib6_config.

The expiry was already being saved as part of RTA_CACHEINFO
in rtnl_put_cacheinfo(), but adding code to generate RTF_EXPIRES upon save
looked more appropriate than redundant cherrypicking from
RTA_CACHEINFO upon restore.

Signed-off-by: Andrew Yourtchenko <ayourtch@gmail.com>
---
 net/ipv6/route.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 4981755..dc37017 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -3244,6 +3244,14 @@ static int rt6_fill_node(struct net *net,
 	if (rtnl_put_cacheinfo(skb, &rt->dst, 0, expires, rt->dst.error) < 0)
 		goto nla_put_failure;
 
+	/* Can't rely on expires == 0. It is zero if no expires flag,
+	 * or if the timing is precisely at expiry. So, recheck the flag.
+	 */
+	if (rt->rt6i_flags & RTF_EXPIRES)
+		if (nla_put_u32(skb, RTA_EXPIRES,
+                                 expires > 0 ? expires / HZ : 0))
+			goto nla_put_failure;
+
 	if (nla_put_u8(skb, RTA_PREF, IPV6_EXTRACT_PREF(rt->rt6i_flags)))
 		goto nla_put_failure;
 
-- 
2.7.4
