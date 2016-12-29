From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net] net: ipv4: dst for local input routes should use l3mdev if relevant
Date: Thu, 29 Dec 2016 15:29:03 -0800
Message-ID: <1483054143-11050-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:34930 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751220AbcL2X3L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 18:29:11 -0500
Received: by mail-pg0-f43.google.com with SMTP id i5so106070326pgh.2
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2016 15:29:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv4 output routes already use l3mdev device instead of loopback for dst's
if it is applicable. Change local input routes to do the same.

This fixes icmp responses for unreachable UDP ports which are directed
to the wrong table after commit 9d1a6c4ea43e4 because local_input
routes use the loopback device. Moving from ingress device to loopback
loses the L3 domain causing responses based on the dst to get to lost.

Fixes: 9d1a6c4ea43e4 ("net: icmp_route_lookup should use rt dev to
		       determine L3 domain")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv4/route.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index a82a11747b3f..0fcac8e7a2b2 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1914,7 +1914,8 @@ out:	return err;
 		}
 	}
 
-	rth = rt_dst_alloc(net->loopback_dev, flags | RTCF_LOCAL, res.type,
+	rth = rt_dst_alloc(l3mdev_master_dev_rcu(dev) ? : net->loopback_dev,
+			   flags | RTCF_LOCAL, res.type,
 			   IN_DEV_CONF_GET(in_dev, NOPOLICY), false, do_cache);
 	if (!rth)
 		goto e_nobufs;
-- 
2.1.4
