From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH net-next 1/4] bridge: rename struct
	bridge_mcast_query/querier
Date: Wed, 21 May 2014 10:58:59 +0200
Message-ID: <1400662742-31999-2-git-send-email-linus.luessing@web.de>
References: <1400662742-31999-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: b.a.t.m.a.n@lists.open-mesh.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1400662742-31999-1-git-send-email-linus.luessing@web.de>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

The current naming of these two structs is very random, in that
reversing their naming would not make any semantical difference.

This patch tries to make the naming less confusing by giving them a more
specific, distinguishable naming.

This is also useful for the upcoming patches reintroducing the
"struct bridge_mcast_querier" but for storing information about the
selected querier (no matter if our own or a foreign querier).

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 net/bridge/br_mdb.c       |    4 +-
 net/bridge/br_multicast.c |  169 +++++++++++++++++++++++----------------=
------
 net/bridge/br_private.h   |   22 +++---
 3 files changed, 100 insertions(+), 95 deletions(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index b7b1914..5df0526 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -418,13 +418,13 @@ static int __br_mdb_del(struct net_bridge *br, stru=
ct br_mdb_entry *entry)
=20
 	ip.proto =3D entry->addr.proto;
 	if (ip.proto =3D=3D htons(ETH_P_IP)) {
-		if (timer_pending(&br->ip4_querier.timer))
+		if (timer_pending(&br->ip4_other_query.timer))
 			return -EBUSY;
=20
 		ip.u.ip4 =3D entry->addr.u.ip4;
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
-		if (timer_pending(&br->ip6_querier.timer))
+		if (timer_pending(&br->ip6_other_query.timer))
 			return -EBUSY;
=20
 		ip.u.ip6 =3D entry->addr.u.ip6;
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 7b757b5..6bc9cef 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -35,7 +35,7 @@
 #include "br_private.h"
=20
 static void br_multicast_start_querier(struct net_bridge *br,
-				       struct bridge_mcast_query *query);
+				       struct bridge_mcast_own_query *query);
 unsigned int br_mdb_rehash_seq;
=20
 static inline int br_ip_equal(const struct br_ip *a, const struct br_ip =
*b)
@@ -761,7 +761,7 @@ static void br_multicast_local_router_expired(unsigne=
d long data)
 }
=20
 static void br_multicast_querier_expired(struct net_bridge *br,
-					 struct bridge_mcast_query *query)
+					 struct bridge_mcast_own_query *query)
 {
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev) || br->multicast_disabled)
@@ -777,7 +777,7 @@ static void br_ip4_multicast_querier_expired(unsigned=
 long data)
 {
 	struct net_bridge *br =3D (void *)data;
=20
-	br_multicast_querier_expired(br, &br->ip4_query);
+	br_multicast_querier_expired(br, &br->ip4_own_query);
 }
=20
 #if IS_ENABLED(CONFIG_IPV6)
@@ -785,7 +785,7 @@ static void br_ip6_multicast_querier_expired(unsigned=
 long data)
 {
 	struct net_bridge *br =3D (void *)data;
=20
-	br_multicast_querier_expired(br, &br->ip6_query);
+	br_multicast_querier_expired(br, &br->ip6_own_query);
 }
 #endif
=20
@@ -810,11 +810,11 @@ static void __br_multicast_send_query(struct net_br=
idge *br,
=20
 static void br_multicast_send_query(struct net_bridge *br,
 				    struct net_bridge_port *port,
-				    struct bridge_mcast_query *query)
+				    struct bridge_mcast_own_query *own_query)
 {
 	unsigned long time;
 	struct br_ip br_group;
-	struct bridge_mcast_querier *querier =3D NULL;
+	struct bridge_mcast_other_query *other_query =3D NULL;
=20
 	if (!netif_running(br->dev) || br->multicast_disabled ||
 	    !br->multicast_querier)
@@ -822,31 +822,32 @@ static void br_multicast_send_query(struct net_brid=
ge *br,
=20
 	memset(&br_group.u, 0, sizeof(br_group.u));
=20
-	if (port ? (query =3D=3D &port->ip4_query) :
-		   (query =3D=3D &br->ip4_query)) {
-		querier =3D &br->ip4_querier;
+	if (port ? (own_query =3D=3D &port->ip4_own_query) :
+		   (own_query =3D=3D &br->ip4_own_query)) {
+		other_query =3D &br->ip4_other_query;
 		br_group.proto =3D htons(ETH_P_IP);
 #if IS_ENABLED(CONFIG_IPV6)
 	} else {
-		querier =3D &br->ip6_querier;
+		other_query =3D &br->ip6_other_query;
 		br_group.proto =3D htons(ETH_P_IPV6);
 #endif
 	}
=20
-	if (!querier || timer_pending(&querier->timer))
+	if (!other_query || timer_pending(&other_query->timer))
 		return;
=20
 	__br_multicast_send_query(br, port, &br_group);
=20
 	time =3D jiffies;
-	time +=3D query->startup_sent < br->multicast_startup_query_count ?
+	time +=3D own_query->startup_sent < br->multicast_startup_query_count ?
 		br->multicast_startup_query_interval :
 		br->multicast_query_interval;
-	mod_timer(&query->timer, time);
+	mod_timer(&own_query->timer, time);
 }
=20
-static void br_multicast_port_query_expired(struct net_bridge_port *port=
,
-					    struct bridge_mcast_query *query)
+static void
+br_multicast_port_query_expired(struct net_bridge_port *port,
+				struct bridge_mcast_own_query *query)
 {
 	struct net_bridge *br =3D port->br;
=20
@@ -868,7 +869,7 @@ static void br_ip4_multicast_port_query_expired(unsig=
ned long data)
 {
 	struct net_bridge_port *port =3D (void *)data;
=20
-	br_multicast_port_query_expired(port, &port->ip4_query);
+	br_multicast_port_query_expired(port, &port->ip4_own_query);
 }
=20
 #if IS_ENABLED(CONFIG_IPV6)
@@ -876,7 +877,7 @@ static void br_ip6_multicast_port_query_expired(unsig=
ned long data)
 {
 	struct net_bridge_port *port =3D (void *)data;
=20
-	br_multicast_port_query_expired(port, &port->ip6_query);
+	br_multicast_port_query_expired(port, &port->ip6_own_query);
 }
 #endif
=20
@@ -886,11 +887,11 @@ void br_multicast_add_port(struct net_bridge_port *=
port)
=20
 	setup_timer(&port->multicast_router_timer, br_multicast_router_expired,
 		    (unsigned long)port);
-	setup_timer(&port->ip4_query.timer, br_ip4_multicast_port_query_expired=
,
-		    (unsigned long)port);
+	setup_timer(&port->ip4_own_query.timer,
+		    br_ip4_multicast_port_query_expired, (unsigned long)port);
 #if IS_ENABLED(CONFIG_IPV6)
-	setup_timer(&port->ip6_query.timer, br_ip6_multicast_port_query_expired=
,
-		    (unsigned long)port);
+	setup_timer(&port->ip6_own_query.timer,
+		    br_ip6_multicast_port_query_expired, (unsigned long)port);
 #endif
 }
=20
@@ -899,7 +900,7 @@ void br_multicast_del_port(struct net_bridge_port *po=
rt)
 	del_timer_sync(&port->multicast_router_timer);
 }
=20
-static void br_multicast_enable(struct bridge_mcast_query *query)
+static void br_multicast_enable(struct bridge_mcast_own_query *query)
 {
 	query->startup_sent =3D 0;
=20
@@ -916,9 +917,9 @@ void br_multicast_enable_port(struct net_bridge_port =
*port)
 	if (br->multicast_disabled || !netif_running(br->dev))
 		goto out;
=20
-	br_multicast_enable(&port->ip4_query);
+	br_multicast_enable(&port->ip4_own_query);
 #if IS_ENABLED(CONFIG_IPV6)
-	br_multicast_enable(&port->ip6_query);
+	br_multicast_enable(&port->ip6_own_query);
 #endif
=20
 out:
@@ -938,9 +939,9 @@ void br_multicast_disable_port(struct net_bridge_port=
 *port)
 	if (!hlist_unhashed(&port->rlist))
 		hlist_del_init_rcu(&port->rlist);
 	del_timer(&port->multicast_router_timer);
-	del_timer(&port->ip4_query.timer);
+	del_timer(&port->ip4_own_query.timer);
 #if IS_ENABLED(CONFIG_IPV6)
-	del_timer(&port->ip6_query.timer);
+	del_timer(&port->ip6_own_query.timer);
 #endif
 	spin_unlock(&br->multicast_lock);
 }
@@ -1065,14 +1066,14 @@ static int br_ip6_multicast_mld2_report(struct ne=
t_bridge *br,
 #endif
=20
 static void
-br_multicast_update_querier_timer(struct net_bridge *br,
-				  struct bridge_mcast_querier *querier,
-				  unsigned long max_delay)
+br_multicast_update_query_timer(struct net_bridge *br,
+				struct bridge_mcast_other_query *query,
+				unsigned long max_delay)
 {
-	if (!timer_pending(&querier->timer))
-		querier->delay_time =3D jiffies + max_delay;
+	if (!timer_pending(&query->timer))
+		query->delay_time =3D jiffies + max_delay;
=20
-	mod_timer(&querier->timer, jiffies + br->multicast_querier_interval);
+	mod_timer(&query->timer, jiffies + br->multicast_query_interval);
 }
=20
 /*
@@ -1125,14 +1126,14 @@ timer:
=20
 static void br_multicast_query_received(struct net_bridge *br,
 					struct net_bridge_port *port,
-					struct bridge_mcast_querier *querier,
+					struct bridge_mcast_other_query *query,
 					int saddr,
 					bool is_general_query,
 					unsigned long max_delay)
 {
 	if (saddr && is_general_query)
-		br_multicast_update_querier_timer(br, querier, max_delay);
-	else if (timer_pending(&querier->timer))
+		br_multicast_update_query_timer(br, query, max_delay);
+	else if (timer_pending(&query->timer))
 		return;
=20
 	br_multicast_mark_router(br, port);
@@ -1190,8 +1191,8 @@ static int br_ip4_multicast_query(struct net_bridge=
 *br,
 		goto out;
 	}
=20
-	br_multicast_query_received(br, port, &br->ip4_querier, !!iph->saddr,
-				    !group, max_delay);
+	br_multicast_query_received(br, port, &br->ip4_other_query,
+				    !!iph->saddr, !group, max_delay);
=20
 	if (!group)
 		goto out;
@@ -1282,7 +1283,7 @@ static int br_ip6_multicast_query(struct net_bridge=
 *br,
 		goto out;
 	}
=20
-	br_multicast_query_received(br, port, &br->ip6_querier,
+	br_multicast_query_received(br, port, &br->ip6_other_query,
 				    !ipv6_addr_any(&ip6h->saddr),
 				    is_general_query, max_delay);
=20
@@ -1315,11 +1316,12 @@ out:
 }
 #endif
=20
-static void br_multicast_leave_group(struct net_bridge *br,
-				     struct net_bridge_port *port,
-				     struct br_ip *group,
-				     struct bridge_mcast_querier *querier,
-				     struct bridge_mcast_query *query)
+static void
+br_multicast_leave_group(struct net_bridge *br,
+			 struct net_bridge_port *port,
+			 struct br_ip *group,
+			 struct bridge_mcast_other_query *other_query,
+			 struct bridge_mcast_own_query *own_query)
 {
 	struct net_bridge_mdb_htable *mdb;
 	struct net_bridge_mdb_entry *mp;
@@ -1330,7 +1332,7 @@ static void br_multicast_leave_group(struct net_bri=
dge *br,
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev) ||
 	    (port && port->state =3D=3D BR_STATE_DISABLED) ||
-	    timer_pending(&querier->timer))
+	    timer_pending(&other_query->timer))
 		goto out;
=20
 	mdb =3D mlock_dereference(br->mdb, br);
@@ -1344,7 +1346,7 @@ static void br_multicast_leave_group(struct net_bri=
dge *br,
 		time =3D jiffies + br->multicast_last_member_count *
 				 br->multicast_last_member_interval;
=20
-		mod_timer(&query->timer, time);
+		mod_timer(&own_query->timer, time);
=20
 		for (p =3D mlock_dereference(mp->ports, br);
 		     p !=3D NULL;
@@ -1425,17 +1427,19 @@ static void br_ip4_multicast_leave_group(struct n=
et_bridge *br,
 					 __u16 vid)
 {
 	struct br_ip br_group;
-	struct bridge_mcast_query *query =3D port ? &port->ip4_query :
-						  &br->ip4_query;
+	struct bridge_mcast_own_query *own_query;
=20
 	if (ipv4_is_local_multicast(group))
 		return;
=20
+	own_query =3D port ? &port->ip4_own_query : &br->ip4_own_query;
+
 	br_group.u.ip4 =3D group;
 	br_group.proto =3D htons(ETH_P_IP);
 	br_group.vid =3D vid;
=20
-	br_multicast_leave_group(br, port, &br_group, &br->ip4_querier, query);
+	br_multicast_leave_group(br, port, &br_group, &br->ip4_other_query,
+				 own_query);
 }
=20
 #if IS_ENABLED(CONFIG_IPV6)
@@ -1445,18 +1449,19 @@ static void br_ip6_multicast_leave_group(struct n=
et_bridge *br,
 					 __u16 vid)
 {
 	struct br_ip br_group;
-	struct bridge_mcast_query *query =3D port ? &port->ip6_query :
-						  &br->ip6_query;
-
+	struct bridge_mcast_own_query *own_query;
=20
 	if (ipv6_addr_is_ll_all_nodes(group))
 		return;
=20
+	own_query =3D port ? &port->ip6_own_query : &br->ip6_own_query;
+
 	br_group.u.ip6 =3D *group;
 	br_group.proto =3D htons(ETH_P_IPV6);
 	br_group.vid =3D vid;
=20
-	br_multicast_leave_group(br, port, &br_group, &br->ip6_querier, query);
+	br_multicast_leave_group(br, port, &br_group, &br->ip6_other_query,
+				 own_query);
 }
 #endif
=20
@@ -1723,7 +1728,7 @@ int br_multicast_rcv(struct net_bridge *br, struct =
net_bridge_port *port,
 }
=20
 static void br_multicast_query_expired(struct net_bridge *br,
-				       struct bridge_mcast_query *query)
+				       struct bridge_mcast_own_query *query)
 {
 	spin_lock(&br->multicast_lock);
 	if (query->startup_sent < br->multicast_startup_query_count)
@@ -1737,7 +1742,7 @@ static void br_ip4_multicast_query_expired(unsigned=
 long data)
 {
 	struct net_bridge *br =3D (void *)data;
=20
-	br_multicast_query_expired(br, &br->ip4_query);
+	br_multicast_query_expired(br, &br->ip4_own_query);
 }
=20
 #if IS_ENABLED(CONFIG_IPV6)
@@ -1745,7 +1750,7 @@ static void br_ip6_multicast_query_expired(unsigned=
 long data)
 {
 	struct net_bridge *br =3D (void *)data;
=20
-	br_multicast_query_expired(br, &br->ip6_query);
+	br_multicast_query_expired(br, &br->ip6_own_query);
 }
 #endif
=20
@@ -1767,28 +1772,28 @@ void br_multicast_init(struct net_bridge *br)
 	br->multicast_querier_interval =3D 255 * HZ;
 	br->multicast_membership_interval =3D 260 * HZ;
=20
-	br->ip4_querier.delay_time =3D 0;
+	br->ip4_other_query.delay_time =3D 0;
 #if IS_ENABLED(CONFIG_IPV6)
-	br->ip6_querier.delay_time =3D 0;
+	br->ip6_other_query.delay_time =3D 0;
 #endif
=20
 	spin_lock_init(&br->multicast_lock);
 	setup_timer(&br->multicast_router_timer,
 		    br_multicast_local_router_expired, 0);
-	setup_timer(&br->ip4_querier.timer, br_ip4_multicast_querier_expired,
-		    (unsigned long)br);
-	setup_timer(&br->ip4_query.timer, br_ip4_multicast_query_expired,
+	setup_timer(&br->ip4_other_query.timer,
+		    br_ip4_multicast_querier_expired, (unsigned long)br);
+	setup_timer(&br->ip4_own_query.timer, br_ip4_multicast_query_expired,
 		    (unsigned long)br);
 #if IS_ENABLED(CONFIG_IPV6)
-	setup_timer(&br->ip6_querier.timer, br_ip6_multicast_querier_expired,
-		    (unsigned long)br);
-	setup_timer(&br->ip6_query.timer, br_ip6_multicast_query_expired,
+	setup_timer(&br->ip6_other_query.timer,
+		    br_ip6_multicast_querier_expired, (unsigned long)br);
+	setup_timer(&br->ip6_own_query.timer, br_ip6_multicast_query_expired,
 		    (unsigned long)br);
 #endif
 }
=20
 static void __br_multicast_open(struct net_bridge *br,
-				struct bridge_mcast_query *query)
+				struct bridge_mcast_own_query *query)
 {
 	query->startup_sent =3D 0;
=20
@@ -1800,9 +1805,9 @@ static void __br_multicast_open(struct net_bridge *=
br,
=20
 void br_multicast_open(struct net_bridge *br)
 {
-	__br_multicast_open(br, &br->ip4_query);
+	__br_multicast_open(br, &br->ip4_own_query);
 #if IS_ENABLED(CONFIG_IPV6)
-	__br_multicast_open(br, &br->ip6_query);
+	__br_multicast_open(br, &br->ip6_own_query);
 #endif
 }
=20
@@ -1815,11 +1820,11 @@ void br_multicast_stop(struct net_bridge *br)
 	int i;
=20
 	del_timer_sync(&br->multicast_router_timer);
-	del_timer_sync(&br->ip4_querier.timer);
-	del_timer_sync(&br->ip4_query.timer);
+	del_timer_sync(&br->ip4_other_query.timer);
+	del_timer_sync(&br->ip4_own_query.timer);
 #if IS_ENABLED(CONFIG_IPV6)
-	del_timer_sync(&br->ip6_querier.timer);
-	del_timer_sync(&br->ip6_query.timer);
+	del_timer_sync(&br->ip6_other_query.timer);
+	del_timer_sync(&br->ip6_own_query.timer);
 #endif
=20
 	spin_lock_bh(&br->multicast_lock);
@@ -1923,7 +1928,7 @@ unlock:
 }
=20
 static void br_multicast_start_querier(struct net_bridge *br,
-				       struct bridge_mcast_query *query)
+				       struct bridge_mcast_own_query *query)
 {
 	struct net_bridge_port *port;
=20
@@ -1934,11 +1939,11 @@ static void br_multicast_start_querier(struct net=
_bridge *br,
 		    port->state =3D=3D BR_STATE_BLOCKING)
 			continue;
=20
-		if (query =3D=3D &br->ip4_query)
-			br_multicast_enable(&port->ip4_query);
+		if (query =3D=3D &br->ip4_own_query)
+			br_multicast_enable(&port->ip4_own_query);
 #if IS_ENABLED(CONFIG_IPV6)
 		else
-			br_multicast_enable(&port->ip6_query);
+			br_multicast_enable(&port->ip6_own_query);
 #endif
 	}
 }
@@ -1974,9 +1979,9 @@ rollback:
 			goto rollback;
 	}
=20
-	br_multicast_start_querier(br, &br->ip4_query);
+	br_multicast_start_querier(br, &br->ip4_own_query);
 #if IS_ENABLED(CONFIG_IPV6)
-	br_multicast_start_querier(br, &br->ip6_query);
+	br_multicast_start_querier(br, &br->ip6_own_query);
 #endif
=20
 unlock:
@@ -2001,16 +2006,16 @@ int br_multicast_set_querier(struct net_bridge *b=
r, unsigned long val)
=20
 	max_delay =3D br->multicast_query_response_interval;
=20
-	if (!timer_pending(&br->ip4_querier.timer))
-		br->ip4_querier.delay_time =3D jiffies + max_delay;
+	if (!timer_pending(&br->ip4_other_query.timer))
+		br->ip4_other_query.delay_time =3D jiffies + max_delay;
=20
-	br_multicast_start_querier(br, &br->ip4_query);
+	br_multicast_start_querier(br, &br->ip4_own_query);
=20
 #if IS_ENABLED(CONFIG_IPV6)
-	if (!timer_pending(&br->ip6_querier.timer))
-		br->ip6_querier.delay_time =3D jiffies + max_delay;
+	if (!timer_pending(&br->ip6_other_query.timer))
+		br->ip6_other_query.delay_time =3D jiffies + max_delay;
=20
-	br_multicast_start_querier(br, &br->ip6_query);
+	br_multicast_start_querier(br, &br->ip6_own_query);
 #endif
=20
 unlock:
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index af067711..f186ce8 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -68,13 +68,13 @@ struct br_ip
=20
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 /* our own querier */
-struct bridge_mcast_query {
+struct bridge_mcast_own_query {
 	struct timer_list	timer;
 	u32			startup_sent;
 };
=20
 /* other querier */
-struct bridge_mcast_querier {
+struct bridge_mcast_other_query {
 	struct timer_list		timer;
 	unsigned long			delay_time;
 };
@@ -178,9 +178,9 @@ struct net_bridge_port
 #define BR_PROMISC		0x00000080
=20
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
-	struct bridge_mcast_query	ip4_query;
+	struct bridge_mcast_own_query	ip4_own_query;
 #if IS_ENABLED(CONFIG_IPV6)
-	struct bridge_mcast_query	ip6_query;
+	struct bridge_mcast_own_query	ip6_own_query;
 #endif /* IS_ENABLED(CONFIG_IPV6) */
 	unsigned char			multicast_router;
 	struct timer_list		multicast_router_timer;
@@ -282,11 +282,11 @@ struct net_bridge
 	struct hlist_head		router_list;
=20
 	struct timer_list		multicast_router_timer;
-	struct bridge_mcast_querier	ip4_querier;
-	struct bridge_mcast_query	ip4_query;
+	struct bridge_mcast_other_query	ip4_other_query;
+	struct bridge_mcast_own_query	ip4_own_query;
 #if IS_ENABLED(CONFIG_IPV6)
-	struct bridge_mcast_querier	ip6_querier;
-	struct bridge_mcast_query	ip6_query;
+	struct bridge_mcast_other_query	ip6_other_query;
+	struct bridge_mcast_own_query	ip6_own_query;
 #endif /* IS_ENABLED(CONFIG_IPV6) */
 #endif
=20
@@ -495,7 +495,7 @@ static inline bool br_multicast_is_router(struct net_=
bridge *br)
=20
 static inline bool
 __br_multicast_querier_exists(struct net_bridge *br,
-			      struct bridge_mcast_querier *querier)
+			      struct bridge_mcast_other_query *querier)
 {
 	return time_is_before_jiffies(querier->delay_time) &&
 	       (br->multicast_querier || timer_pending(&querier->timer));
@@ -506,10 +506,10 @@ static inline bool br_multicast_querier_exists(stru=
ct net_bridge *br,
 {
 	switch (eth->h_proto) {
 	case (htons(ETH_P_IP)):
-		return __br_multicast_querier_exists(br, &br->ip4_querier);
+		return __br_multicast_querier_exists(br, &br->ip4_other_query);
 #if IS_ENABLED(CONFIG_IPV6)
 	case (htons(ETH_P_IPV6)):
-		return __br_multicast_querier_exists(br, &br->ip6_querier);
+		return __br_multicast_querier_exists(br, &br->ip6_other_query);
 #endif
 	default:
 		return false;
--=20
1.7.10.4
