From: roy.qing.li@gmail.com
Subject: [PATCH 1/3] ipv6: ip6_route_output() never returns NULL.
Date: Wed, 22 Feb 2012 16:10:49 +0800
Message-ID: <1329898251-5357-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:36193 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788Ab2BVILc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2012 03:11:32 -0500
Received: by eaah12 with SMTP id h12so2996352eaa.19
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2012 00:11:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: RongQing.Li <roy.qing.li@gmail.com> 

ip6_route_output() never returns NULL, so it is wrong to
check if the return value is NULL.

Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
---
 net/ipv6/ip6mr.c |    4 +++-
 net/ipv6/ndisc.c |    5 +++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index c7e95c8..5aa3981 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1926,8 +1926,10 @@ static int ip6mr_forward2(struct net *net, struct mr6_table *mrt,
 	};
 
 	dst = ip6_route_output(net, NULL, &fl6);
-	if (!dst)
+	if (dst->error) {
+		dst_release(dst);
 		goto out_free;
+	}
 
 	skb_dst_drop(skb);
 	skb_dst_set(skb, dst);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 8d81701..3dcdb81 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1550,9 +1550,10 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 			 &saddr_buf, &ipv6_hdr(skb)->saddr, dev->ifindex);
 
 	dst = ip6_route_output(net, NULL, &fl6);
-	if (dst == NULL)
+	if (dst->error) {
+		dst_release(dst);
 		return;
-
+	}
 	dst = xfrm_lookup(net, dst, flowi6_to_flowi(&fl6), NULL, 0);
 	if (IS_ERR(dst))
 		return;
-- 
1.7.1
