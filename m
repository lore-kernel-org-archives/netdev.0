From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 9/9] net: Remove no_route label
Date: Wed, 23 Sep 2015 08:15:22 -0700
Message-ID: <1443021322-48621-10-git-send-email-dsa@cumulusnetworks.com>
References: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34297 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755619AbbIWPPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 11:15:48 -0400
Received: by padhy16 with SMTP id hy16so43250506pad.1
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 08:15:48 -0700 (PDT)
In-Reply-To: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move no_route code into helper. Add call to helper at jump sites and
remove goto label.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 36 +++++++++++++++++++++++-------------
 1 file changed, 23 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 340246414545..2709ee6e292e 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1737,6 +1737,22 @@ static int ip_route_local_input(struct sk_buff *skb,
 	return err;
 }
 
+static int ip_input_no_route(struct sk_buff *skb,
+			     struct fib_result *res,
+			     struct net *net,
+			     struct in_device *in_dev,
+			     unsigned int flags,
+			     u32 itag, int err)
+{
+	RT_CACHE_STAT_INC(in_no_route);
+
+	res->type = RTN_UNREACHABLE;
+	res->fi = NULL;
+	res->table = NULL;
+
+	return ip_route_local_input(skb, res, net, in_dev, flags, itag, err);
+}
+
 /*
  *	NOTE. We drop all the packets that has local source
  *	addresses, because every properly looped back packet
@@ -1824,7 +1840,10 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (err != 0) {
 		if (!IN_DEV_FORWARD(in_dev))
 			err = -EHOSTUNREACH;
-		goto no_route;
+
+		err = ip_input_no_route(skb, &res, net, in_dev,
+					flags, itag, err);
+		goto out;
 	}
 
 	if (res.type == RTN_BROADCAST)
@@ -1843,8 +1862,9 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	}
 
 	if (!IN_DEV_FORWARD(in_dev)) {
-		err = -EHOSTUNREACH;
-		goto no_route;
+		err = ip_input_no_route(skb, &res, net, in_dev,
+					flags, itag, -EHOSTUNREACH);
+		goto out;
 	}
 	if (res.type != RTN_UNICAST) {
 		err = -EINVAL;
@@ -1875,16 +1895,6 @@ out:	return err;
 	err = ip_route_local_input(skb, &res, net, in_dev,
 				   flags, itag, err);
 	goto out;
-
-no_route:
-	RT_CACHE_STAT_INC(in_no_route);
-	res.type = RTN_UNREACHABLE;
-	res.fi = NULL;
-	res.table = NULL;
-
-	err = ip_route_local_input(skb, &res, net, in_dev,
-				   flags, itag, err);
-	goto out;
 }
 
 int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
-- 
1.9.1
