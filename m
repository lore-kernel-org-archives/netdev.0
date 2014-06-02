From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCHv3 net-next 4/4] bridge: memorize and export selected IGMP/MLD querier port
Date: Mon,  2 Jun 2014 20:07:46 +0200
Message-ID: <1401732466-3027-4-git-send-email-linus.luessing@web.de>
References: <1401732466-3027-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401732466-3027-1-git-send-email-linus.luessing@web.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding bridge support to the batman-adv multicast optimization requires
batman-adv knowing about the existence of bridged-in IGMP/MLD queriers
to be able to reliably serve any multicast listener behind this same
bridge.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 include/linux/if_bridge.h |    1 +
 net/bridge/br_multicast.c |   72 +++++++++++++++++++++++++++++++++++++=
++++----
 net/bridge/br_private.h   |    1 +
 3 files changed, 68 insertions(+), 6 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index 44d6eb0..fd22789 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -38,5 +38,6 @@ typedef int br_should_route_hook_t(struct sk_buff *sk=
b);
 extern br_should_route_hook_t __rcu *br_should_route_hook;
 int br_multicast_list_adjacent(struct net_device *dev,
 			       struct list_head *br_ip_list);
+bool br_multicast_has_querier_adjacent(struct net_device *dev, int pro=
to);
=20
 #endif
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 772476b..cd3cf39 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1081,6 +1081,7 @@ static int br_ip6_multicast_mld2_report(struct ne=
t_bridge *br,
 #endif
=20
 static bool br_ip4_multicast_select_querier(struct net_bridge *br,
+					    struct net_bridge_port *port,
 					    __be32 saddr)
 {
 	if (!timer_pending(&br->ip4_own_query.timer) &&
@@ -1098,11 +1099,15 @@ static bool br_ip4_multicast_select_querier(str=
uct net_bridge *br,
 update:
 	br->ip4_querier.addr.u.ip4 =3D saddr;
=20
+	/* update protected by general multicast_lock by caller */
+	rcu_assign_pointer(br->ip4_querier.port, port);
+
 	return true;
 }
=20
 #if IS_ENABLED(CONFIG_IPV6)
 static bool br_ip6_multicast_select_querier(struct net_bridge *br,
+					    struct net_bridge_port *port,
 					    struct in6_addr *saddr)
 {
 	if (!timer_pending(&br->ip6_own_query.timer) &&
@@ -1117,19 +1122,23 @@ static bool br_ip6_multicast_select_querier(str=
uct net_bridge *br,
 update:
 	br->ip6_querier.addr.u.ip6 =3D *saddr;
=20
+	/* update protected by general multicast_lock by caller */
+	rcu_assign_pointer(br->ip6_querier.port, port);
+
 	return true;
 }
 #endif
=20
 static bool br_multicast_select_querier(struct net_bridge *br,
+					struct net_bridge_port *port,
 					struct br_ip *saddr)
 {
 	switch (saddr->proto) {
 	case htons(ETH_P_IP):
-		return br_ip4_multicast_select_querier(br, saddr->u.ip4);
+		return br_ip4_multicast_select_querier(br, port, saddr->u.ip4);
 #if IS_ENABLED(CONFIG_IPV6)
 	case htons(ETH_P_IPV6):
-		return br_ip6_multicast_select_querier(br, &saddr->u.ip6);
+		return br_ip6_multicast_select_querier(br, port, &saddr->u.ip6);
 #endif
 	}
=20
@@ -1201,7 +1210,7 @@ static void br_multicast_query_received(struct ne=
t_bridge *br,
 					struct br_ip *saddr,
 					unsigned long max_delay)
 {
-	if (!br_multicast_select_querier(br, saddr))
+	if (!br_multicast_select_querier(br, port, saddr))
 		return;
=20
 	br_multicast_update_query_timer(br, query, max_delay);
@@ -1804,12 +1813,14 @@ int br_multicast_rcv(struct net_bridge *br, str=
uct net_bridge_port *port,
 }
=20
 static void br_multicast_query_expired(struct net_bridge *br,
-				       struct bridge_mcast_own_query *query)
+				       struct bridge_mcast_own_query *query,
+				       struct bridge_mcast_querier *querier)
 {
 	spin_lock(&br->multicast_lock);
 	if (query->startup_sent < br->multicast_startup_query_count)
 		query->startup_sent++;
=20
+	rcu_assign_pointer(querier, NULL);
 	br_multicast_send_query(br, NULL, query);
 	spin_unlock(&br->multicast_lock);
 }
@@ -1818,7 +1829,7 @@ static void br_ip4_multicast_query_expired(unsign=
ed long data)
 {
 	struct net_bridge *br =3D (void *)data;
=20
-	br_multicast_query_expired(br, &br->ip4_own_query);
+	br_multicast_query_expired(br, &br->ip4_own_query, &br->ip4_querier);
 }
=20
 #if IS_ENABLED(CONFIG_IPV6)
@@ -1826,7 +1837,7 @@ static void br_ip6_multicast_query_expired(unsign=
ed long data)
 {
 	struct net_bridge *br =3D (void *)data;
=20
-	br_multicast_query_expired(br, &br->ip6_own_query);
+	br_multicast_query_expired(br, &br->ip6_own_query, &br->ip6_querier);
 }
 #endif
=20
@@ -1849,8 +1860,10 @@ void br_multicast_init(struct net_bridge *br)
 	br->multicast_membership_interval =3D 260 * HZ;
=20
 	br->ip4_other_query.delay_time =3D 0;
+	br->ip4_querier.port =3D NULL;
 #if IS_ENABLED(CONFIG_IPV6)
 	br->ip6_other_query.delay_time =3D 0;
+	br->ip6_querier.port =3D NULL;
 #endif
=20
 	spin_lock_init(&br->multicast_lock);
@@ -2199,3 +2212,50 @@ unlock:
 	return count;
 }
 EXPORT_SYMBOL_GPL(br_multicast_list_adjacent);
+
+/**
+ * br_multicast_has_querier_adjacent - Checks for a querier behind a b=
ridge port
+ * @dev: The bridge port adjacent to which to check for a querier
+ * @proto: The protocol family to check for: IGMP -> ETH_P_IP, MLD -> =
ETH_P_IPV6
+ *
+ * Checks whether the given interface has a bridge on top and if so re=
turns
+ * true if a selected querier is behind one of the other ports of this
+ * bridge. Otherwise returns false.
+ */
+bool br_multicast_has_querier_adjacent(struct net_device *dev, int pro=
to)
+{
+	struct net_bridge *br;
+	struct net_bridge_port *port;
+	bool ret =3D false;
+
+	rcu_read_lock();
+	if (!br_port_exists(dev))
+		goto unlock;
+
+	port =3D br_port_get_rcu(dev);
+	if (!port || !port->br)
+		goto unlock;
+
+	br =3D port->br;
+
+	switch (proto) {
+	case ETH_P_IP:
+		if (!timer_pending(&br->ip4_other_query.timer) ||
+		    rcu_dereference(br->ip4_querier.port) =3D=3D port)
+			goto unlock;
+		break;
+	case ETH_P_IPV6:
+		if (!timer_pending(&br->ip6_other_query.timer) ||
+		    rcu_dereference(br->ip6_querier.port) =3D=3D port)
+			goto unlock;
+		break;
+	default:
+		goto unlock;
+	}
+
+	ret =3D true;
+unlock:
+	rcu_read_unlock();
+	return ret;
+}
+EXPORT_SYMBOL_GPL(br_multicast_has_querier_adjacent);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index d7b0e04..c5e4585 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -70,6 +70,7 @@ struct bridge_mcast_other_query {
 /* selected querier */
 struct bridge_mcast_querier {
 	struct br_ip addr;
+	struct net_bridge_port __rcu	*port;
 };
 #endif
=20
--=20
1.7.10.4
