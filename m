From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 8/9] net: Remove local_input label
Date: Wed, 23 Sep 2015 08:15:21 -0700
Message-ID: <1443021322-48621-9-git-send-email-dsa@cumulusnetworks.com>
References: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36771 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755598AbbIWPPs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 11:15:48 -0400
Received: by pacgz1 with SMTP id gz1so8983547pac.3
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 08:15:47 -0700 (PDT)
In-Reply-To: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move calls to ip_route_local_input to jump sites and remove
local_input label.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index c23bb0965966..340246414545 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1835,9 +1835,11 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 					  0, dev, in_dev, &itag);
 		if (err < 0) {
 			ip_handle_martian_source(dev, in_dev, skb, daddr, saddr);
-			goto out;
+		} else {
+			err = ip_route_local_input(skb, &res, net, in_dev,
+						   flags, itag, err);
 		}
-		goto local_input;
+		goto out;
 	}
 
 	if (!IN_DEV_FORWARD(in_dev)) {
@@ -1870,7 +1872,6 @@ out:	return err;
 	res.type = RTN_BROADCAST;
 	RT_CACHE_STAT_INC(in_brd);
 
-local_input:
 	err = ip_route_local_input(skb, &res, net, in_dev,
 				   flags, itag, err);
 	goto out;
@@ -1880,7 +1881,10 @@ out:	return err;
 	res.type = RTN_UNREACHABLE;
 	res.fi = NULL;
 	res.table = NULL;
-	goto local_input;
+
+	err = ip_route_local_input(skb, &res, net, in_dev,
+				   flags, itag, err);
+	goto out;
 }
 
 int ip_route_input_noref(struct sk_buff *skb, __be32 daddr, __be32 saddr,
-- 
1.9.1
