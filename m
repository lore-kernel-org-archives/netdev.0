From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2 1/6] net: mpls: rt_nhn_alive and nh_flags should be accessed using READ_ONCE
Date: Thu, 30 Mar 2017 09:18:19 -0700
Message-ID: <1490890704-8075-2-git-send-email-dsa@cumulusnetworks.com>
References: <1490890704-8075-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
        ebiederm@xmission.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:35102 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933848AbdC3QSc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 12:18:32 -0400
Received: by mail-pg0-f45.google.com with SMTP id 81so44442236pgh.2
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 09:18:31 -0700 (PDT)
In-Reply-To: <1490890704-8075-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The number of alive nexthops for a route (rt->rt_nhn_alive) and the
flags for a next hop (nh->nh_flags) are modified by netdev event
handlers. The event handlers run with rtnl_lock held so updates are
always done with the lock held. The packet path accesses the fields
under the rcu lock. Since those fields can change at any moment in
the packet path, both fields should be accessed using READ_ONCE. Updates
to both fields should use WRITE_ONCE.

Update mpls_select_multipath (packet path) and mpls_ifdown and mpls_ifup
(event handlers) accordingly.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2
- new patch in v2 of set

 net/mpls/af_mpls.c  | 36 +++++++++++++++++++++++++-----------
 net/mpls/internal.h |  8 ++++++++
 2 files changed, 33 insertions(+), 11 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 06ffafde70da..6bdd2f95b576 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -189,10 +189,15 @@ static u32 mpls_multipath_hash(struct mpls_route *rt, struct sk_buff *skb)
 	return hash;
 }
 
+/* number of alive nexthops (rt->rt_nhn_alive) and the flags for
+ * a next hop (nh->nh_flags) are modified by netdev event handlers.
+ * Since those fields can change at any moment, use READ_ONCE to
+ * access both.
+ */
 static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
 					     struct sk_buff *skb)
 {
-	int alive = ACCESS_ONCE(rt->rt_nhn_alive);
+	unsigned int alive;
 	u32 hash = 0;
 	int nh_index = 0;
 	int n = 0;
@@ -203,7 +208,8 @@ static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
 	if (rt->rt_nhn == 1)
 		goto out;
 
-	if (alive <= 0)
+	alive = READ_ONCE(rt->rt_nhn_alive);
+	if (alive == 0)
 		return NULL;
 
 	hash = mpls_multipath_hash(rt, skb);
@@ -211,7 +217,9 @@ static struct mpls_nh *mpls_select_multipath(struct mpls_route *rt,
 	if (alive == rt->rt_nhn)
 		goto out;
 	for_nexthops(rt) {
-		if (nh->nh_flags & (RTNH_F_DEAD | RTNH_F_LINKDOWN))
+		unsigned int nh_flags = READ_ONCE(nh->nh_flags);
+
+		if (nh_flags & (RTNH_F_DEAD | RTNH_F_LINKDOWN))
 			continue;
 		if (n == nh_index)
 			return nh;
@@ -1302,7 +1310,6 @@ static void mpls_ifdown(struct net_device *dev, int event)
 {
 	struct mpls_route __rcu **platform_label;
 	struct net *net = dev_net(dev);
-	unsigned int nh_flags = RTNH_F_DEAD | RTNH_F_LINKDOWN;
 	unsigned int alive, deleted;
 	unsigned index;
 
@@ -1316,22 +1323,27 @@ static void mpls_ifdown(struct net_device *dev, int event)
 		alive = 0;
 		deleted = 0;
 		change_nexthops(rt) {
+			unsigned int nh_flags = nh->nh_flags;
+
 			if (rtnl_dereference(nh->nh_dev) != dev)
 				goto next;
 
 			switch (event) {
 			case NETDEV_DOWN:
 			case NETDEV_UNREGISTER:
-				nh->nh_flags |= RTNH_F_DEAD;
+				nh_flags |= RTNH_F_DEAD;
 				/* fall through */
 			case NETDEV_CHANGE:
-				nh->nh_flags |= RTNH_F_LINKDOWN;
+				nh_flags |= RTNH_F_LINKDOWN;
 				break;
 			}
 			if (event == NETDEV_UNREGISTER)
 				RCU_INIT_POINTER(nh->nh_dev, NULL);
+
+			if (nh->nh_flags != nh_flags)
+				WRITE_ONCE(nh->nh_flags, nh_flags);
 next:
-			if (!(nh->nh_flags & nh_flags))
+			if (!(nh_flags & (RTNH_F_DEAD | RTNH_F_LINKDOWN)))
 				alive++;
 			if (!rtnl_dereference(nh->nh_dev))
 				deleted++;
@@ -1345,7 +1357,7 @@ static void mpls_ifdown(struct net_device *dev, int event)
 	}
 }
 
-static void mpls_ifup(struct net_device *dev, unsigned int nh_flags)
+static void mpls_ifup(struct net_device *dev, unsigned int flags)
 {
 	struct mpls_route __rcu **platform_label;
 	struct net *net = dev_net(dev);
@@ -1361,20 +1373,22 @@ static void mpls_ifup(struct net_device *dev, unsigned int nh_flags)
 
 		alive = 0;
 		change_nexthops(rt) {
+			unsigned int nh_flags = nh->nh_flags;
 			struct net_device *nh_dev =
 				rtnl_dereference(nh->nh_dev);
 
-			if (!(nh->nh_flags & nh_flags)) {
+			if (!(nh_flags & flags)) {
 				alive++;
 				continue;
 			}
 			if (nh_dev != dev)
 				continue;
 			alive++;
-			nh->nh_flags &= ~nh_flags;
+			nh_flags &= ~flags;
+			WRITE_ONCE(nh->nh_flags, flags);
 		} endfor_nexthops(rt);
 
-		ACCESS_ONCE(rt->rt_nhn_alive) = alive;
+		WRITE_ONCE(rt->rt_nhn_alive, alive);
 	}
 }
 
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index 62928d8fabd1..91419fe63464 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -83,6 +83,10 @@ enum mpls_payload_type {
 
 struct mpls_nh { /* next hop label forwarding entry */
 	struct net_device __rcu *nh_dev;
+
+	/* nh_flags is accessed under RCU in the packet path; it is
+	 * modified handling netdev events with rtnl lock held
+	 */
 	unsigned int		nh_flags;
 	u32			nh_label[MAX_NEW_LABELS];
 	u8			nh_labels;
@@ -124,6 +128,10 @@ struct mpls_route { /* next hop label forwarding entry */
 	u8			rt_max_alen;
 	u8			rt_ttl_propagate;
 	unsigned int		rt_nhn;
+
+	/* rt_nhn_alive is accessed under RCU in the packet path; it
+	 * is modified handling netdev events with rtnl lock held
+	 */
 	unsigned int		rt_nhn_alive;
 	struct mpls_nh		rt_nh[0];
 };
-- 
2.1.4
