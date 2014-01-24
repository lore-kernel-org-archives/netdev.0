From: Sergey Popovich <popovich_sergei@mail.ru>
Subject: [PATCH 4/4 v3] ipv4: mark nexthop as dead when it's subnet becomes unreachable
Date: Fri, 24 Jan 2014 12:25:17 +0200
Message-ID: <1521507.ObZglEaf1D@tuxracer>
References: <cover.1390304505.git.popovich_sergei@mail.ru> <alpine.LFD.2.11.1401232221010.1667@ja.home.ssi.bg> <2039386.VZO3kUlZdW@tuxracer>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp40.i.mail.ru ([94.100.177.100]:51490 "EHLO smtp40.i.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752018AbaAXKZW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jan 2014 05:25:22 -0500
Received: from [2a01:6d80:103:13::c3ea:4404] (port=57159 helo=tuxracer.localnet)
	by smtp40.i.mail.ru with esmtpa (envelope-from <popovich_sergei@mail.ru>)
	id 1W6dwt-00086L-Kj
	for netdev@vger.kernel.org; Fri, 24 Jan 2014 14:25:20 +0400
In-Reply-To: <2039386.VZO3kUlZdW@tuxracer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Removing ip address and it's subnet route using fib_del_ifaddr() does
not purge routes with nexthop in such subnet.

This could be easily reproduced with the following config:

  ip link add dev dummy1 type dummy
  ip link set up dev dummy1
  ip -4 addr add 10.0.10.1/24 dev dummy1
  ip -4 addr add 10.0.20.1/24 dev dummy1

  ip -4 route add 172.16.0.0/12 proto static via 10.0.10.5
  ip -4 route show exact 172.16.0.0/12
  172.16.0.0/12 via 10.0.10.5 dev dummy1  proto static

  ip -4 addr del 10.0.10.1/24 dev dummy1

  ip -4 route show exact 172.16.0.0/12
  172.16.0.0/12 via 10.0.10.5 dev dummy1  proto static

Add interface address (ifa) parameter to fib_sync_down_dev()
and use it to match nexthop against it's subnet.

Use fib_sync_down_dev() in fib_del_ifaddr() among with fib_sync_down_addr()
to mark as dead routes with nexthop in ifa.

  v3. Fix NH marking as dead when NH gateway subnet is still on
      interface (e.g. 10.0.10.1/24 and 10.0.30.1/16 and NH is 10.0.10.5).
      Thanks to Julian Anastasov.

  v2. Fix NH marking as dead when NH created with onlink option.

Signed-off-by: Sergey Popovich <popovich_sergei@mail.ru>
---
 include/net/ip_fib.h     |  3 ++-
 net/ipv4/fib_frontend.c  |  5 +++--
 net/ipv4/fib_semantics.c | 29 +++++++++++++++++++++++++++--
 3 files changed, 32 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 9922093..0405fc9 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -287,8 +287,9 @@ static inline int fib_num_tclassid_users(struct net *net)
 #endif
 
 /* Exported by fib_semantics.c */
+struct in_ifaddr;
 int ip_fib_check_default(__be32 gw, struct net_device *dev);
-int fib_sync_down_dev(struct net_device *dev, int force);
+int fib_sync_down_dev(struct net_device *dev, struct in_ifaddr *ifa, int force);
 int fib_sync_down_addr(struct net *net, __be32 local);
 int fib_sync_up(struct net_device *dev);
 void fib_select_multipath(struct fib_result *res);
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
index 9d43468..fbebba5 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1112,7 +1112,29 @@ int fib_sync_down_addr(struct net *net, __be32 local)
 	return ret;
 }
 
-int fib_sync_down_dev(struct net_device *dev, int force)
+static inline bool fib_sync_down_gw(struct fib_nh *nh,
+				    struct in_ifaddr *ifr)
+{
+	if (!ifr)
+		return true;
+
+	if (nh->nh_flags & RTNH_F_ONLINK)
+		return false;
+
+	if (!inet_ifa_match(nh->nh_gw, ifr))
+		return false;
+
+	for_ifa(ifr->ifa_dev) {
+		if (unlikely(ifa == ifr))
+			continue;
+		if (inet_ifa_match(nh->nh_gw, ifa))
+			return false;
+	} endfor_ifa(ifr->ifa_dev);
+
+	return true;
+}
+
+int fib_sync_down_dev(struct net_device *dev, struct in_ifaddr *ifa, int force)
 {
 	int ret = 0;
 	int scope = RT_SCOPE_NOWHERE;
@@ -1124,6 +1146,8 @@ int fib_sync_down_dev(struct net_device *dev, int force)
 	if (force)
 		scope = -1;
 
+	BUG_ON(ifa && ifa->ifa_dev->dev != dev);
+
 	hlist_for_each_entry(nh, head, nh_hash) {
 		struct fib_info *fi = nh->nh_parent;
 		int dead;
@@ -1137,7 +1161,8 @@ int fib_sync_down_dev(struct net_device *dev, int force)
 			if (nexthop_nh->nh_flags & RTNH_F_DEAD)
 				dead++;
 			else if (nexthop_nh->nh_dev == dev &&
-				 nexthop_nh->nh_scope != scope) {
+				 nexthop_nh->nh_scope != scope &&
+				 fib_sync_down_gw(nexthop_nh, ifa)) {
 				nexthop_nh->nh_flags |= RTNH_F_DEAD;
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 				spin_lock_bh(&fib_multipath_lock);
-- 
1.8.3.4
