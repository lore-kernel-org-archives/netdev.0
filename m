From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 8/9] net: Remove local_input label
Date: Tue, 22 Sep 2015 15:55:22 -0700
Message-ID: <1442962523-3974-9-git-send-email-dsa@cumulusnetworks.com>
References: <1442962523-3974-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36840 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935077AbbIVWzj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 18:55:39 -0400
Received: by pacbt3 with SMTP id bt3so3400079pac.3
        for <netdev@vger.kernel.org>; Tue, 22 Sep 2015 15:55:39 -0700 (PDT)
In-Reply-To: <1442962523-3974-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move calls to ip_route_local_input to jump sites and remove
local_input label.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index efc8e58c1964..454c38bd23a8 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1836,9 +1836,13 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 					  0, dev, in_dev, &itag);
 		if (err < 0) {
 			ip_handle_martian_source(dev, in_dev, skb, daddr, saddr);
-			goto out;
+		} else {
+			err = ip_route_local_input(skb, &res,
+						   net->loopback_dev,
+						   flags, itag, err,
+						   IN_DEV_CONF_GET(in_dev, NOPOLICY));
 		}
-		goto local_input;
+		goto out;
 	}
 
 	if (!IN_DEV_FORWARD(in_dev)) {
@@ -1871,7 +1875,6 @@ out:	return err;
 	res.type = RTN_BROADCAST;
 	RT_CACHE_STAT_INC(in_brd);
 
-local_input:
 	err = ip_route_local_input(skb, &res, net->loopback_dev,
 				   flags, itag, err,
 				   IN_DEV_CONF_GET(in_dev, NOPOLICY));
@@ -1882,7 +1885,11 @@ out:	return err;
 	res.type = RTN_UNREACHABLE;
 	res.fi = NULL;
 	res.table = NULL;
-	goto local_input;
+
+	err = ip_route_local_input(skb, &res, net->loopback_dev,
+				   flags, itag, err,
+				   IN_DEV_CONF_GET(in_dev, NOPOLICY));
+	goto out;
 }
 
 int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
-- 
1.9.1
