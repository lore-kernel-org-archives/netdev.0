From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 9/9] net: Remove no_route label
Date: Tue, 22 Sep 2015 15:55:23 -0700
Message-ID: <1442962523-3974-10-git-send-email-dsa@cumulusnetworks.com>
References: <1442962523-3974-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35555 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933261AbbIVWzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 18:55:40 -0400
Received: by pacfv12 with SMTP id fv12so21982572pac.2
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 15:55:40 -0700 (PDT)
In-Reply-To: <1442962523-3974-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move no_route code into helper. Add call to helper at jump sites and
remove goto label.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 40 ++++++++++++++++++++++++++--------------
 1 file changed, 26 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 454c38bd23a8..e486a3fb3081 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1738,6 +1738,23 @@ static int ip_route_local_input(struct sk_buff *skb,
 	return err;
 }
 
+static int ip_input_no_route(struct sk_buff *skb,
+			     struct fib_result *res,
+			     struct net_device *loopback_dev,
+			     unsigned int flags,
+			     u32 itag, int err,
+			     bool nopolicy)
+{
+	RT_CACHE_STAT_INC(in_no_route);
+
+	res->type = RTN_UNREACHABLE;
+	res->fi = NULL;
+	res->table = NULL;
+
+	return ip_route_local_input(skb, res, loopback_dev,
+				    flags, itag, err, nopolicy);
+}
+
 /*
  *	NOTE. We drop all the packets that has local source
  *	addresses, because every properly looped back packet
@@ -1825,7 +1842,11 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (err != 0) {
 		if (!IN_DEV_FORWARD(in_dev))
 			err = -EHOSTUNREACH;
-		goto no_route;
+
+		err = ip_input_no_route(skb, &res, net->loopback_dev,
+					flags, itag, err,
+					IN_DEV_CONF_GET(in_dev, NOPOLICY));
+		goto out;
 	}
 
 	if (res.type == RTN_BROADCAST)
@@ -1846,8 +1867,10 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	}
 
 	if (!IN_DEV_FORWARD(in_dev)) {
-		err = -EHOSTUNREACH;
-		goto no_route;
+		err = ip_input_no_route(skb, &res, net->loopback_dev,
+					flags, itag, -EHOSTUNREACH,
+					IN_DEV_CONF_GET(in_dev, NOPOLICY));
+		goto out;
 	}
 	if (res.type != RTN_UNICAST) {
 		err = -EINVAL;
@@ -1879,17 +1902,6 @@ out:	return err;
 				   flags, itag, err,
 				   IN_DEV_CONF_GET(in_dev, NOPOLICY));
 	goto out;
-
-no_route:
-	RT_CACHE_STAT_INC(in_no_route);
-	res.type = RTN_UNREACHABLE;
-	res.fi = NULL;
-	res.table = NULL;
-
-	err = ip_route_local_input(skb, &res, net->loopback_dev,
-				   flags, itag, err,
-				   IN_DEV_CONF_GET(in_dev, NOPOLICY));
-	goto out;
 }
 
 int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
-- 
1.9.1
