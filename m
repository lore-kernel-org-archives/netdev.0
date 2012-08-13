From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH] ipv4: Cache local output routes
Date: Mon, 13 Aug 2012 14:09:59 +0800
Message-ID: <50289A37.6000209@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Shi, Alex" <alex.shi@intel.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:42619 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751219Ab2HMGKB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2012 02:10:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit caacf05e5ad1abf causes big drop of UDP loop back performance.
The cause of the regression is that we do not cache the local output
routes. Each time we send a datagram from unconnected UDP socket,
the kernel allocates a dst_entry and adds it to the rt_uncached_list.
It creates lock contention on the rt_uncached_lock.

Reported-by: Alex Shi <alex.shi@intel.com>
Signed-off-by: Yan, Zheng <zheng.z.yan@intel.com>
---
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e4ba974..fd9ecb5 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2028,7 +2028,6 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 		}
 		dev_out = net->loopback_dev;
 		fl4->flowi4_oif = dev_out->ifindex;
-		res.fi = NULL;
 		flags |= RTCF_LOCAL;
 		goto make_route;
 	}
