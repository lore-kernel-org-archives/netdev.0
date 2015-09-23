From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 1/9] net: Remove martian_source_keep_err goto label
Date: Wed, 23 Sep 2015 08:15:14 -0700
Message-ID: <1443021322-48621-2-git-send-email-dsa@cumulusnetworks.com>
References: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35722 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752195AbbIWPPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 11:15:36 -0400
Received: by pacfv12 with SMTP id fv12so43765032pac.2
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 08:15:36 -0700 (PDT)
In-Reply-To: <1443021322-48621-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

err is initialized to -EINVAL when it is declared. It is not reset until
fib_lookup which is well after the 3 users of the martian_source jump. So
resetting err to -EINVAL at martian_source label is not needed.

Removing that line obviates the need for the martian_source_keep_err label
so delete it.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 80f7c5b7b832..ef36dfed24da 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1760,7 +1760,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		err = fib_validate_source(skb, saddr, daddr, tos,
 					  0, dev, in_dev, &itag);
 		if (err < 0)
-			goto martian_source_keep_err;
+			goto martian_source;
 		goto local_input;
 	}
 
@@ -1782,7 +1782,7 @@ out:	return err;
 		err = fib_validate_source(skb, saddr, 0, tos, 0, dev,
 					  in_dev, &itag);
 		if (err < 0)
-			goto martian_source_keep_err;
+			goto martian_source;
 	}
 	flags |= RTCF_BROADCAST;
 	res.type = RTN_BROADCAST;
@@ -1858,8 +1858,6 @@ out:	return err;
 	goto out;
 
 martian_source:
-	err = -EINVAL;
-martian_source_keep_err:
 	ip_handle_martian_source(dev, in_dev, skb, daddr, saddr);
 	goto out;
 }
-- 
1.9.1
