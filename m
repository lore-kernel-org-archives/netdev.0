From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 7/9] net: Remove martian_destination label
Date: Wed, 23 Sep 2015 08:15:20 -0700
Message-ID: <1443021322-48621-8-git-send-email-dsa@cumulusnetworks.com>
References: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36739 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755602AbbIWPPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 11:15:46 -0400
Received: by pacgz1 with SMTP id gz1so8982763pac.3
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 08:15:45 -0700 (PDT)
In-Reply-To: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move call to ip_handle_martian_dest to various jump sites. The
function only increments a counter and possibly does additional
logging if CONFIG_IP_ROUTE_VERBOSE is enabled.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 0fdcb0539795..c23bb0965966 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1790,15 +1790,19 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (ipv4_is_lbcast(daddr) || (saddr == 0 && daddr == 0))
 		goto brd_input;
 
-	if (ipv4_is_zeronet(daddr))
-		goto martian_destination;
+	if (ipv4_is_zeronet(daddr)) {
+		ip_handle_martian_dest(dev, in_dev, daddr, saddr);
+		goto out;
+	}
 
 	/* Following code try to avoid calling IN_DEV_NET_ROUTE_LOCALNET(),
 	 * and call it once if daddr or/and saddr are loopback addresses
 	 */
 	if (ipv4_is_loopback(daddr)) {
-		if (!IN_DEV_NET_ROUTE_LOCALNET(in_dev, net))
-			goto martian_destination;
+		if (!IN_DEV_NET_ROUTE_LOCALNET(in_dev, net)) {
+			ip_handle_martian_dest(dev, in_dev, daddr, saddr);
+			goto out;
+		}
 	} else if (ipv4_is_loopback(saddr)) {
 		if (!IN_DEV_NET_ROUTE_LOCALNET(in_dev, net)) {
 			ip_handle_martian_source(dev, in_dev, skb, daddr, saddr);
@@ -1840,8 +1844,11 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		err = -EHOSTUNREACH;
 		goto no_route;
 	}
-	if (res.type != RTN_UNICAST)
-		goto martian_destination;
+	if (res.type != RTN_UNICAST) {
+		err = -EINVAL;
+		ip_handle_martian_dest(dev, in_dev, daddr, saddr);
+		goto out;
+	}
 
 	err = ip_mkroute_input(skb, &res, &fl4, in_dev, daddr, saddr, tos);
 out:	return err;
@@ -1874,11 +1881,6 @@ out:	return err;
 	res.fi = NULL;
 	res.table = NULL;
 	goto local_input;
-
-martian_destination:
-	err = -EINVAL;
-	ip_handle_martian_dest(dev, in_dev, daddr, saddr);
-	goto out;
 }
 
 int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
-- 
1.9.1
