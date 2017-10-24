From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next] ipv6: update use count on dst_check()
Date: Tue, 24 Oct 2017 12:42:57 +0200
Message-ID: <f9c3808ba0aa553eaaa47c1507ba417366f015de.1508841703.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Wei Wang <weiwan@google.com>, Martin KaFai Lau <kafai@fb.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15003 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932267AbdJXKof (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Oct 2017 06:44:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the dst 'lastuse' field is not updated in a reliable way
for dst entries only accessed via socket cache.

This may fool the ipv6 dst gc, especially since we really age out unused
entries, either via the commit 1859bac04fb6 ("ipv6: remove from fib tree
aged out RTF_CACHE dst") or via the commit 1e2ea8ad37be ("ipv6: set
dst.obsolete when a cached route has expired").

Updating such field is now very cheap, thanks to commit 0da4af00b2ed
("ipv6: only update __use and lastusetime once per jiffy at most"),
so we can address the issue updating 'lastuse' in ip6_dst_check(),
if successful.

Fixes: 1859bac04fb6 ("ipv6: remove from fib tree aged out RTF_CACHE dst")
Fixes: 1e2ea8ad37be ("ipv6: set dst.obsolete when a cached route has expired")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv6/route.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 87a15cbd0e8b..8f8c7fb83b9b 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1952,6 +1952,7 @@ static struct dst_entry *rt6_check(struct rt6_info *rt, u32 cookie)
 	if (rt6_check_expired(rt))
 		return NULL;
 
+	dst_use_noref(&rt->dst, jiffies);
 	return &rt->dst;
 }
 
-- 
2.13.6
