From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 2/2] net: mpls: Delete route when all nexthops have been deleted
Date: Fri, 24 Mar 2017 15:21:57 -0700
Message-ID: <1490394117-19268-3-git-send-email-dsa@cumulusnetworks.com>
References: <1490394117-19268-1-git-send-email-dsa@cumulusnetworks.com>
Cc: rshearma@brocade.com, roopa@cumulusnetworks.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:32798 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934956AbdCXWWF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 18:22:05 -0400
Received: by mail-pf0-f180.google.com with SMTP id o190so1410656pfo.0
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 15:22:05 -0700 (PDT)
In-Reply-To: <1490394117-19268-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When all devices for all nexthops in a route have been deleted, the
route is effectively dead, so remove it.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 3861f8dfa9c1..74755920c689 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -1299,7 +1299,7 @@ static void mpls_ifdown(struct net_device *dev, int event)
 	struct mpls_route __rcu **platform_label;
 	struct net *net = dev_net(dev);
 	unsigned int nh_flags = RTNH_F_DEAD | RTNH_F_LINKDOWN;
-	unsigned int alive;
+	unsigned int alive, deleted;
 	unsigned index;
 
 	platform_label = rtnl_dereference(net->mpls.platform_label);
@@ -1310,6 +1310,7 @@ static void mpls_ifdown(struct net_device *dev, int event)
 			continue;
 
 		alive = 0;
+		deleted = 0;
 		change_nexthops(rt) {
 			if (rtnl_dereference(nh->nh_dev) != dev)
 				goto next;
@@ -1328,9 +1329,15 @@ static void mpls_ifdown(struct net_device *dev, int event)
 next:
 			if (!(nh->nh_flags & nh_flags))
 				alive++;
+			if (!rtnl_dereference(nh->nh_dev))
+				deleted++;
 		} endfor_nexthops(rt);
 
 		WRITE_ONCE(rt->rt_nhn_alive, alive);
+
+		/* if there are no more nexthops, delete the route */
+		if (event == NETDEV_UNREGISTER && deleted == rt->rt_nhn)
+			mpls_route_update(net, index, NULL, NULL);
 	}
 }
 
-- 
2.1.4
