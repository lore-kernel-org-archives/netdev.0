From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: [PATCH 4/4] ipv4: mark nexthop as dead when it's subnet becomes unreachable
Date: Tue, 21 Jan 2014 13:48:51 +0200
Message-ID: <40044b636dbf7ae5bba5fe2873451e14438ec170.1390304505.git.popovich_sergei@mail.ru>
References: <cover.1390304505.git.popovich_sergei@mail.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback7.mail.ru ([94.100.176.135]:50988 "EHLO
	fallback7.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754099AbaAULtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 06:49:21 -0500
Received: from smtp11.mail.ru (smtp11.mail.ru [94.100.176.85])
	by fallback7.mail.ru (mPOP.Fallback_MX) with ESMTP id 99339F5DF777
	for <netdev@vger.kernel.org>; Tue, 21 Jan 2014 15:49:18 +0400 (MSK)
Received: from [2a01:6d80:103:13::c3ea:4404] (port=42200 helo=tuxracer.localdomain)
	by smtp11.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1W5ZpB-0006Kt-DN
	for netdev@vger.kernel.org; Tue, 21 Jan 2014 15:48:57 +0400
In-Reply-To: <cover.1390304505.git.popovich_sergei@mail.ru>
In-Reply-To: <cover.1390304505.git.popovich_sergei@mail.ru>
References: <cover.1390304505.git.popovich_sergei@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removing ip address and it's subnet route using fib_del_ifaddr() does
not purge routes with nexthop in such subnet.

This could be easily reproduced with the following config:

  # ip link add dev dummy1 type dummy
  # ip link set up dev dummy1
  # ip -4 addr add 10.0.10.1/24 dev dummy1
  # ip -4 addr add 10.0.20.1/24 dev dummy1

  # ip -4 route add 172.16.0.0/12 proto static via 10.0.10.5
  # ip -4 route show exact 172.16.0.0/12
  172.16.0.0/12 via 10.0.10.5 dev dummy1  proto static

  # ip -4 addr del 10.0.10.1/24 dev dummy1

  # ip -4 route show exact 172.16.0.0/12
  172.16.0.0/12 via 10.0.10.5 dev dummy1  proto static

Add interface address (ifa) parameter to fib_sync_down_dev()
and use it to match nexthop against it's subnet.

Use fib_sync_down_dev() in fib_del_ifaddr() among with fib_sync_down_addr()
to mark as dead routes with nexthop in ifa.

Also optimize loop a bit:
  move handling of force > 1 out of the change_nexthops() loop.

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>
---
 net/ipv4/fib_frontend.c  |  5 +++--
 net/ipv4/fib_semantics.c | 36 ++++++++++++++++++++----------------
 2 files changed, 23 insertions(+), 18 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index ae5f35f..fd3445e 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -907,7 +907,8 @@ void fib_del_ifaddr(struct in_ifaddr *ifa, struct in_ifaddr *iprim)
 			 * First of all, we scan fib_info list searching
 			 * for stray nexthop entries, then ignite fib_flush.
 			 */
-			if (fib_sync_down_addr(dev_net(dev), ifa->ifa_local))
+			if (fib_sync_down_addr(dev_net(dev), ifa->ifa_local) +
+			    fib_sync_down_dev(dev, ifa, 0))
 				fib_flush(dev_net(dev));
 		}
 	}
@@ -997,7 +998,7 @@ static void nl_fib_lookup_exit(struct net *net)
 
 static void fib_disable_ip(struct net_device *dev, int force)
 {
-	if (fib_sync_down_dev(dev, force))
+	if (fib_sync_down_dev(dev, NULL, force))
 		fib_flush(dev_net(dev));
 	rt_cache_flush(dev_net(dev));
 	arp_ifdown(dev);
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 9d43468..ca920df 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1112,7 +1112,7 @@ int fib_sync_down_addr(struct net *net, __be32 local)
 	return ret;
 }
 
-int fib_sync_down_dev(struct net_device *dev, int force)
+int fib_sync_down_dev(struct net_device *dev, struct in_ifaddr *ifa, int force)
 {
 	int ret = 0;
 	int scope = RT_SCOPE_NOWHERE;
@@ -1132,29 +1132,33 @@ int fib_sync_down_dev(struct net_device *dev, int force)
 		if (nh->nh_dev != dev || fi == prev_fi)
 			continue;
 		prev_fi = fi;
-		dead = 0;
-		change_nexthops(fi) {
-			if (nexthop_nh->nh_flags & RTNH_F_DEAD)
-				dead++;
-			else if (nexthop_nh->nh_dev == dev &&
-				 nexthop_nh->nh_scope != scope) {
-				nexthop_nh->nh_flags |= RTNH_F_DEAD;
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-				spin_lock_bh(&fib_multipath_lock);
-				fi->fib_power -= nexthop_nh->nh_power;
-				nexthop_nh->nh_power = 0;
-				spin_unlock_bh(&fib_multipath_lock);
+		if (force > 1)
+			goto fi_dead;
 #endif
+		dead = 0;
+		change_nexthops(fi) {
+			if (nexthop_nh->nh_flags & RTNH_F_DEAD) {
 				dead++;
+				continue;
 			}
+			if (nexthop_nh->nh_dev != dev ||
+			    nexthop_nh->nh_scope == scope ||
+			    (ifa && !inet_ifa_match(nexthop_nh->nh_gw, ifa)))
+				continue;
+			nexthop_nh->nh_flags |= RTNH_F_DEAD;
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
-			if (force > 1 && nexthop_nh->nh_dev == dev) {
-				dead = fi->fib_nhs;
-				break;
-			}
+			spin_lock_bh(&fib_multipath_lock);
+			fi->fib_power -= nexthop_nh->nh_power;
+			nexthop_nh->nh_power = 0;
+			spin_unlock_bh(&fib_multipath_lock);
 #endif
+			dead++;
 		} endfor_nexthops(fi)
 		if (dead == fi->fib_nhs) {
+#ifdef CONFIG_IP_ROUTE_MULTIPATH
+fi_dead:
+#endif
 			fi->fib_flags |= RTNH_F_DEAD;
 			ret++;
 		}
-- 
1.8.3.4
