From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 6/9] net: Remove martian_source goto
Date: Wed, 23 Sep 2015 08:15:19 -0700
Message-ID: <1443021322-48621-7-git-send-email-dsa@cumulusnetworks.com>
References: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:35825 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754104AbbIWPPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 11:15:43 -0400
Received: by pacfv12 with SMTP id fv12so43767617pac.2
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 08:15:43 -0700 (PDT)
In-Reply-To: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move call to ip_handle_martian_source to various jump sites. The
function only increments a counter and possibly does additional
logging if CONFIG_IP_ROUTE_VERBOSE is enabled.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 38 ++++++++++++++++++++------------------
 1 file changed, 20 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 8e0fb1e4de72..0fdcb0539795 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1776,20 +1776,20 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		fl4.flowi4_tun_key.tun_id = 0;
 	skb_dst_drop(skb);
 
-	if (ipv4_is_multicast(saddr) || ipv4_is_lbcast(saddr))
-		goto martian_source;
+	/* Accept zero addresses only to limited broadcast;
+	 * I even do not know to fix it or not. Waiting for complains :-)
+	 */
+	if (ipv4_is_multicast(saddr) || ipv4_is_lbcast(saddr) ||
+	    ipv4_is_zeronet(saddr)) {
+		ip_handle_martian_source(dev, in_dev, skb, daddr, saddr);
+		goto out;
+	}
 
 	res.fi = NULL;
 	res.table = NULL;
 	if (ipv4_is_lbcast(daddr) || (saddr == 0 && daddr == 0))
 		goto brd_input;
 
-	/* Accept zero addresses only to limited broadcast;
-	 * I even do not know to fix it or not. Waiting for complains :-)
-	 */
-	if (ipv4_is_zeronet(saddr))
-		goto martian_source;
-
 	if (ipv4_is_zeronet(daddr))
 		goto martian_destination;
 
@@ -1800,8 +1800,10 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		if (!IN_DEV_NET_ROUTE_LOCALNET(in_dev, net))
 			goto martian_destination;
 	} else if (ipv4_is_loopback(saddr)) {
-		if (!IN_DEV_NET_ROUTE_LOCALNET(in_dev, net))
-			goto martian_source;
+		if (!IN_DEV_NET_ROUTE_LOCALNET(in_dev, net)) {
+			ip_handle_martian_source(dev, in_dev, skb, daddr, saddr);
+			goto out;
+		}
 	}
 
 	/*
@@ -1827,8 +1829,10 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	if (res.type == RTN_LOCAL) {
 		err = fib_validate_source(skb, saddr, daddr, tos,
 					  0, dev, in_dev, &itag);
-		if (err < 0)
-			goto martian_source;
+		if (err < 0) {
+			ip_handle_martian_source(dev, in_dev, skb, daddr, saddr);
+			goto out;
+		}
 		goto local_input;
 	}
 
@@ -1850,8 +1854,10 @@ out:	return err;
 	if (!ipv4_is_zeronet(saddr)) {
 		err = fib_validate_source(skb, saddr, 0, tos, 0, dev,
 					  in_dev, &itag);
-		if (err < 0)
-			goto martian_source;
+		if (err < 0) {
+			ip_handle_martian_source(dev, in_dev, skb, daddr, saddr);
+			goto out;
+		}
 	}
 	flags |= RTCF_BROADCAST;
 	res.type = RTN_BROADCAST;
@@ -1873,10 +1879,6 @@ out:	return err;
 	err = -EINVAL;
 	ip_handle_martian_dest(dev, in_dev, daddr, saddr);
 	goto out;
-
-martian_source:
-	ip_handle_martian_source(dev, in_dev, skb, daddr, saddr);
-	goto out;
 }
 
 int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
-- 
1.9.1
