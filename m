From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: mpls: Fix nexthop alive tracking on down events
Date: Mon, 13 Mar 2017 16:49:10 -0700
Message-ID: <1489448950-13340-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:34009 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751330AbdCMXtR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 19:49:17 -0400
Received: by mail-pg0-f48.google.com with SMTP id 77so72718412pgc.1
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 16:49:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alive tracking of nexthops can account for a link twice if the carrier
goes down followed by an admin down of the same link rendering multipath
routes useless. This is similar to 79099aab38c8 for UNREGISTER events and
DOWN events.

Fix by tracking number of alive nexthops in mpls_ifdown similar to the
logic in mpls_ifup. Checking the flags per nexthop once after all events
have been processed is simpler than trying to maintian a running count
through all event combinations.

Also, WRITE_ONCE is used instead of ACCESS_ONCE to set rt_nhn_alive
per a comment from checkpatch:
    WARNING: Prefer WRITE_ONCE(<FOO>, <BAR>) over ACCESS_ONCE(<FOO>) = <BAR>

Fixes: c89359a42e2a4 ("mpls: support for dead routes")
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/mpls/af_mpls.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 33211f9a2656..6414079aa729 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -1269,6 +1269,8 @@ static void mpls_ifdown(struct net_device *dev, int event)
 {
 	struct mpls_route __rcu **platform_label;
 	struct net *net = dev_net(dev);
+	unsigned int nh_flags = RTNH_F_DEAD | RTNH_F_LINKDOWN;
+	unsigned int alive;
 	unsigned index;
 
 	platform_label = rtnl_dereference(net->mpls.platform_label);
@@ -1278,9 +1280,11 @@ static void mpls_ifdown(struct net_device *dev, int event)
 		if (!rt)
 			continue;
 
+		alive = 0;
 		change_nexthops(rt) {
 			if (rtnl_dereference(nh->nh_dev) != dev)
-				continue;
+				goto next;
+
 			switch (event) {
 			case NETDEV_DOWN:
 			case NETDEV_UNREGISTER:
@@ -1288,13 +1292,16 @@ static void mpls_ifdown(struct net_device *dev, int event)
 				/* fall through */
 			case NETDEV_CHANGE:
 				nh->nh_flags |= RTNH_F_LINKDOWN;
-				if (event != NETDEV_UNREGISTER)
-					ACCESS_ONCE(rt->rt_nhn_alive) = rt->rt_nhn_alive - 1;
 				break;
 			}
 			if (event == NETDEV_UNREGISTER)
 				RCU_INIT_POINTER(nh->nh_dev, NULL);
+next:
+			if (!(nh->nh_flags & nh_flags))
+				alive++;
 		} endfor_nexthops(rt);
+
+		WRITE_ONCE(rt->rt_nhn_alive, alive);
 	}
 }
 
-- 
2.1.4
