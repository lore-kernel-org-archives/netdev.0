From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6] ipv6: Don't drop cache route entry unless timer actually expired.
Date: Mon, 29 Mar 2010 02:15:45 +0900
Message-ID: <201003281715.o2SHFjai004362@94.43.138.210.xn.2iij.net>
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	guenter.roeck@ericsson.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:42504 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754569Ab0C1RP7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Mar 2010 13:15:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is ipv6 variant of the commit 5e016cbf6.. ("ipv4: Don't drop
redirected route cache entry unless PTMU actually expired")
by Guenter Roeck <guenter.roeck@ericsson.com>.

Remove cache route entry in ipv6_negative_advice() only if
the timer is expired.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/route.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 7fcb0e5..0d7713c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -890,12 +890,17 @@ static struct dst_entry *ip6_negative_advice(struct dst_entry *dst)
 	struct rt6_info *rt = (struct rt6_info *) dst;
 
 	if (rt) {
-		if (rt->rt6i_flags & RTF_CACHE)
-			ip6_del_rt(rt);
-		else
+		if (rt->rt6i_flags & RTF_CACHE) {
+			if (rt6_check_expired(rt)) {
+				ip6_del_rt(rt);
+				dst = NULL;
+			}
+		} else {
 			dst_release(dst);
+			dst = NULL;
+		}
 	}
-	return NULL;
+	return dst;
 }
 
 static void ip6_link_failure(struct sk_buff *skb)
-- 
1.5.6.5

