From: roy.qing.li@gmail.com
Subject: [PATCH net-next] ipv6: recursive check rt->dst.from when call rt6_check_expired
Date: Fri, 14 Sep 2012 13:54:57 +0800
Message-ID: <1347602097-18034-1-git-send-email-roy.qing.li@gmail.com>
To: gaofeng@cn.fujitsu.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:32817 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166Ab2INFzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 01:55:08 -0400
Received: by pbbrr13 with SMTP id rr13so5107831pbb.19
        for <netdev@vger.kernel.org>; Thu, 13 Sep 2012 22:55:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

If dst cache dst_a copies from dst_b, and dst_b copies from dst_c, check
if dst_a is expired or not, we should not end with dst_a->dst.from, dst_b,
we should check dst_c.

CC: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/route.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 83dafa5..0607ee3 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -369,15 +369,11 @@ static void ip6_dst_ifdown(struct dst_entry *dst, struct net_device *dev,
 
 static bool rt6_check_expired(const struct rt6_info *rt)
 {
-	struct rt6_info *ort = NULL;
-
 	if (rt->rt6i_flags & RTF_EXPIRES) {
 		if (time_after(jiffies, rt->dst.expires))
 			return true;
 	} else if (rt->dst.from) {
-		ort = (struct rt6_info *) rt->dst.from;
-		return (ort->rt6i_flags & RTF_EXPIRES) &&
-			time_after(jiffies, ort->dst.expires);
+		return rt6_check_expired((struct rt6_info *) rt->dst.from);
 	}
 	return false;
 }
-- 
1.7.4.1
