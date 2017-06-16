From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH net-next 03/21] net: use loopback dev when generating blackhole route
Date: Fri, 16 Jun 2017 10:47:26 -0700
Message-ID: <20170616174744.139688-4-tracywwnj@gmail.com>
References: <20170616174744.139688-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34458 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752231AbdFPRsW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 13:48:22 -0400
Received: by mail-pg0-f67.google.com with SMTP id j186so7270584pge.1
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 10:48:22 -0700 (PDT)
In-Reply-To: <20170616174744.139688-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

Existing ipv4/6_blackhole_route() code generates a blackhole route
with dst->dev pointing to the passed in dst->dev.
It is not necessary to hold reference to the passed in dst->dev
because the packets going through this route are dropped anyway.
A loopback interface is good enough so that we don't need to worry about
releasing this dst->dev when this dev is going down.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv4/route.c | 2 +-
 net/ipv6/route.c | 9 +++++----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 9b38cf18144e..0a843ef2b709 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2504,7 +2504,7 @@ struct dst_entry *ipv4_blackhole_route(struct net *net, struct dst_entry *dst_or
 		new->input = dst_discard;
 		new->output = dst_discard_out;
 
-		new->dev = ort->dst.dev;
+		new->dev = net->loopback_dev;
 		if (new->dev)
 			dev_hold(new->dev);
 
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 18fe6e2b88d5..bc1bc91bb969 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1245,9 +1245,12 @@ EXPORT_SYMBOL_GPL(ip6_route_output_flags);
 struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_orig)
 {
 	struct rt6_info *rt, *ort = (struct rt6_info *) dst_orig;
+	struct net_device *loopback_dev = net->loopback_dev;
 	struct dst_entry *new = NULL;
 
-	rt = dst_alloc(&ip6_dst_blackhole_ops, ort->dst.dev, 1, DST_OBSOLETE_NONE, 0);
+
+	rt = dst_alloc(&ip6_dst_blackhole_ops, loopback_dev, 1,
+		       DST_OBSOLETE_NONE, 0);
 	if (rt) {
 		rt6_info_init(rt);
 
@@ -1257,10 +1260,8 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 		new->output = dst_discard_out;
 
 		dst_copy_metrics(new, &ort->dst);
-		rt->rt6i_idev = ort->rt6i_idev;
-		if (rt->rt6i_idev)
-			in6_dev_hold(rt->rt6i_idev);
 
+		rt->rt6i_idev = in6_dev_get(loopback_dev);
 		rt->rt6i_gateway = ort->rt6i_gateway;
 		rt->rt6i_flags = ort->rt6i_flags & ~RTF_PCPU;
 		rt->rt6i_metric = 0;
-- 
2.13.1.518.g3df882009-goog
