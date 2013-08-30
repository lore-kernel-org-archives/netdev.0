From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCHv2] bridge: separate querier and query timer into IGMP/IPv4 and MLD/IPv6 ones
Date: Fri, 30 Aug 2013 17:28:17 +0200
Message-ID: <1377876497-6185-1-git-send-email-linus.luessing@web.de>
References: <20130828.200831.289304393401193657.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Cong Wang <amwang@redhat.com>,
	Adam Baker <linux@baker-net.org.uk>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
To: bridge@lists.linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130828.200831.289304393401193657.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently we would still potentially suffer multicast packet loss if th=
ere
is just either an IGMP or an MLD querier: For the former case, we would
possibly drop IPv6 multicast packets, for the latter IPv4 ones. This is
because we are currently assuming that if either an IGMP or MLD querier
is present that the other one is present, too.

This patch makes the behaviour and fix added in
"bridge: disable snooping if there is no querier" (b00589af3b04)
to also work if there is either just an IGMP or an MLD querier on the
link: It refines the deactivation of the snooping to be protocol
specific by using separate timers for the snooped IGMP and MLD queries
as well as separate timers for our internal IGMP and MLD queriers.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 net/bridge/br_device.c    |    2 +-
 net/bridge/br_input.c     |    2 +-
 net/bridge/br_mdb.c       |   14 ++-
 net/bridge/br_multicast.c |  258 ++++++++++++++++++++++++++++++++-----=
--------
 net/bridge/br_private.h   |   57 ++++++++--
 5 files changed, 240 insertions(+), 93 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 69363bd..89659d4 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -71,7 +71,7 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct n=
et_device *dev)
=20
 		mdst =3D br_mdb_get(br, skb, vid);
 		if ((mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) &&
-		    br_multicast_querier_exists(br))
+		    br_multicast_querier_exists(br, eth_hdr(skb)))
 			br_multicast_deliver(mdst, skb);
 		else
 			br_flood_deliver(br, skb, false);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 8c561c0..a2fd37e 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -102,7 +102,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
 	} else if (is_multicast_ether_addr(dest)) {
 		mdst =3D br_mdb_get(br, skb, vid);
 		if ((mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) &&
-		    br_multicast_querier_exists(br)) {
+		    br_multicast_querier_exists(br, eth_hdr(skb))) {
 			if ((mdst && mdst->mglist) ||
 			    br_multicast_is_router(br))
 				skb2 =3D skb;
diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 0daae3e..6319c43 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -414,16 +414,20 @@ static int __br_mdb_del(struct net_bridge *br, st=
ruct br_mdb_entry *entry)
 	if (!netif_running(br->dev) || br->multicast_disabled)
 		return -EINVAL;
=20
-	if (timer_pending(&br->multicast_querier_timer))
-		return -EBUSY;
-
 	ip.proto =3D entry->addr.proto;
-	if (ip.proto =3D=3D htons(ETH_P_IP))
+	if (ip.proto =3D=3D htons(ETH_P_IP)) {
+		if (timer_pending(&br->ip4_querier.timer))
+			return -EBUSY;
+
 		ip.u.ip4 =3D entry->addr.u.ip4;
 #if IS_ENABLED(CONFIG_IPV6)
-	else
+	} else {
+		if (timer_pending(&br->ip6_querier.timer))
+			return -EBUSY;
+
 		ip.u.ip6 =3D entry->addr.u.ip6;
 #endif
+	}
=20
 	spin_lock_bh(&br->multicast_lock);
 	mdb =3D mlock_dereference(br->mdb, br);
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 08e576a..9d1d0e6 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -33,7 +33,8 @@
=20
 #include "br_private.h"
=20
-static void br_multicast_start_querier(struct net_bridge *br);
+static void br_multicast_start_querier(struct net_bridge *br,
+				       struct bridge_mcast_query *query);
 unsigned int br_mdb_rehash_seq;
=20
 static inline int br_ip_equal(const struct br_ip *a, const struct br_i=
p *b)
@@ -755,20 +756,35 @@ static void br_multicast_local_router_expired(uns=
igned long data)
 {
 }
=20
-static void br_multicast_querier_expired(unsigned long data)
+static void br_multicast_querier_expired(struct net_bridge *br,
+					 struct bridge_mcast_query *query)
 {
-	struct net_bridge *br =3D (void *)data;
-
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev) || br->multicast_disabled)
 		goto out;
=20
-	br_multicast_start_querier(br);
+	br_multicast_start_querier(br, query);
=20
 out:
 	spin_unlock(&br->multicast_lock);
 }
=20
+static void br_ip4_multicast_querier_expired(unsigned long data)
+{
+	struct net_bridge *br =3D (void *)data;
+
+	br_multicast_querier_expired(br, &br->ip4_query);
+}
+
+#if IS_ENABLED(CONFIG_IPV6)
+static void br_ip6_multicast_querier_expired(unsigned long data)
+{
+	struct net_bridge *br =3D (void *)data;
+
+	br_multicast_querier_expired(br, &br->ip6_query);
+}
+#endif
+
 static void __br_multicast_send_query(struct net_bridge *br,
 				      struct net_bridge_port *port,
 				      struct br_ip *ip)
@@ -789,37 +805,45 @@ static void __br_multicast_send_query(struct net_=
bridge *br,
 }
=20
 static void br_multicast_send_query(struct net_bridge *br,
-				    struct net_bridge_port *port, u32 sent)
+				    struct net_bridge_port *port,
+				    struct bridge_mcast_query *query)
 {
 	unsigned long time;
 	struct br_ip br_group;
+	struct bridge_mcast_querier *querier =3D NULL;
=20
 	if (!netif_running(br->dev) || br->multicast_disabled ||
-	    !br->multicast_querier ||
-	    timer_pending(&br->multicast_querier_timer))
+	    !br->multicast_querier)
 		return;
=20
 	memset(&br_group.u, 0, sizeof(br_group.u));
=20
-	br_group.proto =3D htons(ETH_P_IP);
-	__br_multicast_send_query(br, port, &br_group);
-
+	if (port ? (query =3D=3D &port->ip4_query) :
+		   (query =3D=3D &br->ip4_query)) {
+		querier =3D &br->ip4_querier;
+		br_group.proto =3D htons(ETH_P_IP);
 #if IS_ENABLED(CONFIG_IPV6)
-	br_group.proto =3D htons(ETH_P_IPV6);
-	__br_multicast_send_query(br, port, &br_group);
+	} else {
+		querier =3D &br->ip6_querier;
+		br_group.proto =3D htons(ETH_P_IPV6);
 #endif
+	}
+
+	if (!querier || timer_pending(&querier->timer))
+		return;
+
+	__br_multicast_send_query(br, port, &br_group);
=20
 	time =3D jiffies;
-	time +=3D sent < br->multicast_startup_query_count ?
+	time +=3D query->startup_sent < br->multicast_startup_query_count ?
 		br->multicast_startup_query_interval :
 		br->multicast_query_interval;
-	mod_timer(port ? &port->multicast_query_timer :
-			 &br->multicast_query_timer, time);
+	mod_timer(&query->timer, time);
 }
=20
-static void br_multicast_port_query_expired(unsigned long data)
+static void br_multicast_port_query_expired(struct net_bridge_port *po=
rt,
+					    struct bridge_mcast_query *query)
 {
-	struct net_bridge_port *port =3D (void *)data;
 	struct net_bridge *br =3D port->br;
=20
 	spin_lock(&br->multicast_lock);
@@ -827,25 +851,43 @@ static void br_multicast_port_query_expired(unsig=
ned long data)
 	    port->state =3D=3D BR_STATE_BLOCKING)
 		goto out;
=20
-	if (port->multicast_startup_queries_sent <
-	    br->multicast_startup_query_count)
-		port->multicast_startup_queries_sent++;
+	if (query->startup_sent < br->multicast_startup_query_count)
+		query->startup_sent++;
=20
-	br_multicast_send_query(port->br, port,
-				port->multicast_startup_queries_sent);
+	br_multicast_send_query(port->br, port, query);
=20
 out:
 	spin_unlock(&br->multicast_lock);
 }
=20
+static void br_ip4_multicast_port_query_expired(unsigned long data)
+{
+	struct net_bridge_port *port =3D (void *)data;
+
+	br_multicast_port_query_expired(port, &port->ip4_query);
+}
+
+#if IS_ENABLED(CONFIG_IPV6)
+static void br_ip6_multicast_port_query_expired(unsigned long data)
+{
+	struct net_bridge_port *port =3D (void *)data;
+
+	br_multicast_port_query_expired(port, &port->ip6_query);
+}
+#endif
+
 void br_multicast_add_port(struct net_bridge_port *port)
 {
 	port->multicast_router =3D 1;
=20
 	setup_timer(&port->multicast_router_timer, br_multicast_router_expire=
d,
 		    (unsigned long)port);
-	setup_timer(&port->multicast_query_timer,
-		    br_multicast_port_query_expired, (unsigned long)port);
+	setup_timer(&port->ip4_query.timer, br_ip4_multicast_port_query_expir=
ed,
+		    (unsigned long)port);
+#if IS_ENABLED(CONFIG_IPV6)
+	setup_timer(&port->ip6_query.timer, br_ip6_multicast_port_query_expir=
ed,
+		    (unsigned long)port);
+#endif
 }
=20
 void br_multicast_del_port(struct net_bridge_port *port)
@@ -853,13 +895,13 @@ void br_multicast_del_port(struct net_bridge_port=
 *port)
 	del_timer_sync(&port->multicast_router_timer);
 }
=20
-static void __br_multicast_enable_port(struct net_bridge_port *port)
+static void br_multicast_enable(struct bridge_mcast_query *query)
 {
-	port->multicast_startup_queries_sent =3D 0;
+	query->startup_sent =3D 0;
=20
-	if (try_to_del_timer_sync(&port->multicast_query_timer) >=3D 0 ||
-	    del_timer(&port->multicast_query_timer))
-		mod_timer(&port->multicast_query_timer, jiffies);
+	if (try_to_del_timer_sync(&query->timer) >=3D 0 ||
+	    del_timer(&query->timer))
+		mod_timer(&query->timer, jiffies);
 }
=20
 void br_multicast_enable_port(struct net_bridge_port *port)
@@ -870,7 +912,10 @@ void br_multicast_enable_port(struct net_bridge_po=
rt *port)
 	if (br->multicast_disabled || !netif_running(br->dev))
 		goto out;
=20
-	__br_multicast_enable_port(port);
+	br_multicast_enable(&port->ip4_query);
+#if IS_ENABLED(CONFIG_IPV6)
+	br_multicast_enable(&port->ip6_query);
+#endif
=20
 out:
 	spin_unlock(&br->multicast_lock);
@@ -889,7 +934,10 @@ void br_multicast_disable_port(struct net_bridge_p=
ort *port)
 	if (!hlist_unhashed(&port->rlist))
 		hlist_del_init_rcu(&port->rlist);
 	del_timer(&port->multicast_router_timer);
-	del_timer(&port->multicast_query_timer);
+	del_timer(&port->ip4_query.timer);
+#if IS_ENABLED(CONFIG_IPV6)
+	del_timer(&port->ip6_query.timer);
+#endif
 	spin_unlock(&br->multicast_lock);
 }
=20
@@ -1014,14 +1062,15 @@ static int br_ip6_multicast_mld2_report(struct =
net_bridge *br,
 }
 #endif
=20
-static void br_multicast_update_querier_timer(struct net_bridge *br,
-					      unsigned long max_delay)
+static void
+br_multicast_update_querier_timer(struct net_bridge *br,
+				  struct bridge_mcast_querier *querier,
+				  unsigned long max_delay)
 {
-	if (!timer_pending(&br->multicast_querier_timer))
-		br->multicast_querier_delay_time =3D jiffies + max_delay;
+	if (!timer_pending(&querier->timer))
+		querier->delay_time =3D jiffies + max_delay;
=20
-	mod_timer(&br->multicast_querier_timer,
-		  jiffies + br->multicast_querier_interval);
+	mod_timer(&querier->timer, jiffies + br->multicast_querier_interval);
 }
=20
 /*
@@ -1074,12 +1123,13 @@ timer:
=20
 static void br_multicast_query_received(struct net_bridge *br,
 					struct net_bridge_port *port,
+					struct bridge_mcast_querier *querier,
 					int saddr,
 					unsigned long max_delay)
 {
 	if (saddr)
-		br_multicast_update_querier_timer(br, max_delay);
-	else if (timer_pending(&br->multicast_querier_timer))
+		br_multicast_update_querier_timer(br, querier, max_delay);
+	else if (timer_pending(&querier->timer))
 		return;
=20
 	br_multicast_mark_router(br, port);
@@ -1129,7 +1179,8 @@ static int br_ip4_multicast_query(struct net_brid=
ge *br,
 			    IGMPV3_MRC(ih3->code) * (HZ / IGMP_TIMER_SCALE) : 1;
 	}
=20
-	br_multicast_query_received(br, port, !!iph->saddr, max_delay);
+	br_multicast_query_received(br, port, &br->ip4_querier, !!iph->saddr,
+				    max_delay);
=20
 	if (!group)
 		goto out;
@@ -1206,8 +1257,8 @@ static int br_ip6_multicast_query(struct net_brid=
ge *br,
 		max_delay =3D mld2q->mld2q_mrc ? MLDV2_MRC(ntohs(mld2q->mld2q_mrc)) =
: 1;
 	}
=20
-	br_multicast_query_received(br, port, !ipv6_addr_any(&ip6h->saddr),
-				    max_delay);
+	br_multicast_query_received(br, port, &br->ip6_querier,
+				    !ipv6_addr_any(&ip6h->saddr), max_delay);
=20
 	if (!group)
 		goto out;
@@ -1244,7 +1295,9 @@ out:
=20
 static void br_multicast_leave_group(struct net_bridge *br,
 				     struct net_bridge_port *port,
-				     struct br_ip *group)
+				     struct br_ip *group,
+				     struct bridge_mcast_querier *querier,
+				     struct bridge_mcast_query *query)
 {
 	struct net_bridge_mdb_htable *mdb;
 	struct net_bridge_mdb_entry *mp;
@@ -1255,7 +1308,7 @@ static void br_multicast_leave_group(struct net_b=
ridge *br,
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev) ||
 	    (port && port->state =3D=3D BR_STATE_DISABLED) ||
-	    timer_pending(&br->multicast_querier_timer))
+	    timer_pending(&querier->timer))
 		goto out;
=20
 	mdb =3D mlock_dereference(br->mdb, br);
@@ -1263,14 +1316,13 @@ static void br_multicast_leave_group(struct net=
_bridge *br,
 	if (!mp)
 		goto out;
=20
-	if (br->multicast_querier &&
-	    !timer_pending(&br->multicast_querier_timer)) {
+	if (br->multicast_querier) {
 		__br_multicast_send_query(br, port, &mp->addr);
=20
 		time =3D jiffies + br->multicast_last_member_count *
 				 br->multicast_last_member_interval;
-		mod_timer(port ? &port->multicast_query_timer :
-				 &br->multicast_query_timer, time);
+
+		mod_timer(&query->timer, time);
=20
 		for (p =3D mlock_dereference(mp->ports, br);
 		     p !=3D NULL;
@@ -1323,7 +1375,6 @@ static void br_multicast_leave_group(struct net_b=
ridge *br,
 			mod_timer(&mp->timer, time);
 		}
 	}
-
 out:
 	spin_unlock(&br->multicast_lock);
 }
@@ -1334,6 +1385,8 @@ static void br_ip4_multicast_leave_group(struct n=
et_bridge *br,
 					 __u16 vid)
 {
 	struct br_ip br_group;
+	struct bridge_mcast_query *query =3D port ? &port->ip4_query :
+						  &br->ip4_query;
=20
 	if (ipv4_is_local_multicast(group))
 		return;
@@ -1342,7 +1395,7 @@ static void br_ip4_multicast_leave_group(struct n=
et_bridge *br,
 	br_group.proto =3D htons(ETH_P_IP);
 	br_group.vid =3D vid;
=20
-	br_multicast_leave_group(br, port, &br_group);
+	br_multicast_leave_group(br, port, &br_group, &br->ip4_querier, query=
);
 }
=20
 #if IS_ENABLED(CONFIG_IPV6)
@@ -1352,6 +1405,9 @@ static void br_ip6_multicast_leave_group(struct n=
et_bridge *br,
 					 __u16 vid)
 {
 	struct br_ip br_group;
+	struct bridge_mcast_query *query =3D port ? &port->ip6_query :
+						  &br->ip6_query;
+
=20
 	if (!ipv6_is_transient_multicast(group))
 		return;
@@ -1360,7 +1416,7 @@ static void br_ip6_multicast_leave_group(struct n=
et_bridge *br,
 	br_group.proto =3D htons(ETH_P_IPV6);
 	br_group.vid =3D vid;
=20
-	br_multicast_leave_group(br, port, &br_group);
+	br_multicast_leave_group(br, port, &br_group, &br->ip6_querier, query=
);
 }
 #endif
=20
@@ -1622,19 +1678,32 @@ int br_multicast_rcv(struct net_bridge *br, str=
uct net_bridge_port *port,
 	return 0;
 }
=20
-static void br_multicast_query_expired(unsigned long data)
+static void br_multicast_query_expired(struct net_bridge *br,
+				       struct bridge_mcast_query *query)
+{
+	spin_lock(&br->multicast_lock);
+	if (query->startup_sent < br->multicast_startup_query_count)
+		query->startup_sent++;
+
+	br_multicast_send_query(br, NULL, query);
+	spin_unlock(&br->multicast_lock);
+}
+
+static void br_ip4_multicast_query_expired(unsigned long data)
 {
 	struct net_bridge *br =3D (void *)data;
=20
-	spin_lock(&br->multicast_lock);
-	if (br->multicast_startup_queries_sent <
-	    br->multicast_startup_query_count)
-		br->multicast_startup_queries_sent++;
+	br_multicast_query_expired(br, &br->ip4_query);
+}
=20
-	br_multicast_send_query(br, NULL, br->multicast_startup_queries_sent)=
;
+#if IS_ENABLED(CONFIG_IPV6)
+static void br_ip6_multicast_query_expired(unsigned long data)
+{
+	struct net_bridge *br =3D (void *)data;
=20
-	spin_unlock(&br->multicast_lock);
+	br_multicast_query_expired(br, &br->ip6_query);
 }
+#endif
=20
 void br_multicast_init(struct net_bridge *br)
 {
@@ -1654,25 +1723,43 @@ void br_multicast_init(struct net_bridge *br)
 	br->multicast_querier_interval =3D 255 * HZ;
 	br->multicast_membership_interval =3D 260 * HZ;
=20
-	br->multicast_querier_delay_time =3D 0;
+	br->ip4_querier.delay_time =3D 0;
+#if IS_ENABLED(CONFIG_IPV6)
+	br->ip6_querier.delay_time =3D 0;
+#endif
=20
 	spin_lock_init(&br->multicast_lock);
 	setup_timer(&br->multicast_router_timer,
 		    br_multicast_local_router_expired, 0);
-	setup_timer(&br->multicast_querier_timer,
-		    br_multicast_querier_expired, (unsigned long)br);
-	setup_timer(&br->multicast_query_timer, br_multicast_query_expired,
+	setup_timer(&br->ip4_querier.timer, br_ip4_multicast_querier_expired,
+		    (unsigned long)br);
+	setup_timer(&br->ip4_query.timer, br_ip4_multicast_query_expired,
 		    (unsigned long)br);
+#if IS_ENABLED(CONFIG_IPV6)
+	setup_timer(&br->ip6_querier.timer, br_ip6_multicast_querier_expired,
+		    (unsigned long)br);
+	setup_timer(&br->ip6_query.timer, br_ip6_multicast_query_expired,
+		    (unsigned long)br);
+#endif
 }
=20
-void br_multicast_open(struct net_bridge *br)
+static void __br_multicast_open(struct net_bridge *br,
+				struct bridge_mcast_query *query)
 {
-	br->multicast_startup_queries_sent =3D 0;
+	query->startup_sent =3D 0;
=20
 	if (br->multicast_disabled)
 		return;
=20
-	mod_timer(&br->multicast_query_timer, jiffies);
+	mod_timer(&query->timer, jiffies);
+}
+
+void br_multicast_open(struct net_bridge *br)
+{
+	__br_multicast_open(br, &br->ip4_query);
+#if IS_ENABLED(CONFIG_IPV6)
+	__br_multicast_open(br, &br->ip6_query);
+#endif
 }
=20
 void br_multicast_stop(struct net_bridge *br)
@@ -1684,8 +1771,12 @@ void br_multicast_stop(struct net_bridge *br)
 	int i;
=20
 	del_timer_sync(&br->multicast_router_timer);
-	del_timer_sync(&br->multicast_querier_timer);
-	del_timer_sync(&br->multicast_query_timer);
+	del_timer_sync(&br->ip4_querier.timer);
+	del_timer_sync(&br->ip4_query.timer);
+#if IS_ENABLED(CONFIG_IPV6)
+	del_timer_sync(&br->ip6_querier.timer);
+	del_timer_sync(&br->ip6_query.timer);
+#endif
=20
 	spin_lock_bh(&br->multicast_lock);
 	mdb =3D mlock_dereference(br->mdb, br);
@@ -1788,18 +1879,24 @@ unlock:
 	return err;
 }
=20
-static void br_multicast_start_querier(struct net_bridge *br)
+static void br_multicast_start_querier(struct net_bridge *br,
+				       struct bridge_mcast_query *query)
 {
 	struct net_bridge_port *port;
=20
-	br_multicast_open(br);
+	__br_multicast_open(br, query);
=20
 	list_for_each_entry(port, &br->port_list, list) {
 		if (port->state =3D=3D BR_STATE_DISABLED ||
 		    port->state =3D=3D BR_STATE_BLOCKING)
 			continue;
=20
-		__br_multicast_enable_port(port);
+		if (query =3D=3D &br->ip4_query)
+			br_multicast_enable(&port->ip4_query);
+#if IS_ENABLED(CONFIG_IPV6)
+		else
+			br_multicast_enable(&port->ip6_query);
+#endif
 	}
 }
=20
@@ -1834,7 +1931,10 @@ rollback:
 			goto rollback;
 	}
=20
-	br_multicast_start_querier(br);
+	br_multicast_start_querier(br, &br->ip4_query);
+#if IS_ENABLED(CONFIG_IPV6)
+	br_multicast_start_querier(br, &br->ip6_query);
+#endif
=20
 unlock:
 	spin_unlock_bh(&br->multicast_lock);
@@ -1857,10 +1957,18 @@ int br_multicast_set_querier(struct net_bridge =
*br, unsigned long val)
 		goto unlock;
=20
 	max_delay =3D br->multicast_query_response_interval;
-	if (!timer_pending(&br->multicast_querier_timer))
-		br->multicast_querier_delay_time =3D jiffies + max_delay;
=20
-	br_multicast_start_querier(br);
+	if (!timer_pending(&br->ip4_querier.timer))
+		br->ip4_querier.delay_time =3D jiffies + max_delay;
+
+	br_multicast_start_querier(br, &br->ip4_query);
+
+#if IS_ENABLED(CONFIG_IPV6)
+	if (!timer_pending(&br->ip6_querier.timer))
+		br->ip6_querier.delay_time =3D jiffies + max_delay;
+
+	br_multicast_start_querier(br, &br->ip6_query);
+#endif
=20
 unlock:
 	spin_unlock_bh(&br->multicast_lock);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 2f7da41..263ba90 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -66,6 +66,20 @@ struct br_ip
 	__u16		vid;
 };
=20
+#ifdef CONFIG_BRIDGE_IGMP_SNOOPING
+/* our own querier */
+struct bridge_mcast_query {
+	struct timer_list	timer;
+	u32			startup_sent;
+};
+
+/* other querier */
+struct bridge_mcast_querier {
+	struct timer_list		timer;
+	unsigned long			delay_time;
+};
+#endif
+
 struct net_port_vlans {
 	u16				port_idx;
 	u16				pvid;
@@ -162,10 +176,12 @@ struct net_bridge_port
 #define BR_FLOOD		0x00000040
=20
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
-	u32				multicast_startup_queries_sent;
+	struct bridge_mcast_query	ip4_query;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct bridge_mcast_query	ip6_query;
+#endif /* IS_ENABLED(CONFIG_IPV6) */
 	unsigned char			multicast_router;
 	struct timer_list		multicast_router_timer;
-	struct timer_list		multicast_query_timer;
 	struct hlist_head		mglist;
 	struct hlist_node		rlist;
 #endif
@@ -258,7 +274,6 @@ struct net_bridge
 	u32				hash_max;
=20
 	u32				multicast_last_member_count;
-	u32				multicast_startup_queries_sent;
 	u32				multicast_startup_query_count;
=20
 	unsigned long			multicast_last_member_interval;
@@ -267,15 +282,18 @@ struct net_bridge
 	unsigned long			multicast_query_interval;
 	unsigned long			multicast_query_response_interval;
 	unsigned long			multicast_startup_query_interval;
-	unsigned long			multicast_querier_delay_time;
=20
 	spinlock_t			multicast_lock;
 	struct net_bridge_mdb_htable __rcu *mdb;
 	struct hlist_head		router_list;
=20
 	struct timer_list		multicast_router_timer;
-	struct timer_list		multicast_querier_timer;
-	struct timer_list		multicast_query_timer;
+	struct bridge_mcast_querier	ip4_querier;
+	struct bridge_mcast_query	ip4_query;
+#if IS_ENABLED(CONFIG_IPV6)
+	struct bridge_mcast_querier	ip6_querier;
+	struct bridge_mcast_query	ip6_query;
+#endif /* IS_ENABLED(CONFIG_IPV6) */
 #endif
=20
 	struct timer_list		hello_timer;
@@ -503,11 +521,27 @@ static inline bool br_multicast_is_router(struct =
net_bridge *br)
 		timer_pending(&br->multicast_router_timer));
 }
=20
-static inline bool br_multicast_querier_exists(struct net_bridge *br)
+static inline bool
+__br_multicast_querier_exists(struct net_bridge *br,
+			      struct bridge_mcast_querier *querier)
+{
+	return time_is_before_jiffies(querier->delay_time) &&
+	       (br->multicast_querier || timer_pending(&querier->timer));
+}
+
+static inline bool br_multicast_querier_exists(struct net_bridge *br,
+					       struct ethhdr *eth)
 {
-	return time_is_before_jiffies(br->multicast_querier_delay_time) &&
-	       (br->multicast_querier ||
-		timer_pending(&br->multicast_querier_timer));
+	switch (eth->h_proto) {
+	case (htons(ETH_P_IP)):
+		return __br_multicast_querier_exists(br, &br->ip4_querier);
+#if IS_ENABLED(CONFIG_IPV6)
+	case (htons(ETH_P_IPV6)):
+		return __br_multicast_querier_exists(br, &br->ip6_querier);
+#endif
+	default:
+		return false;
+	}
 }
 #else
 static inline int br_multicast_rcv(struct net_bridge *br,
@@ -565,7 +599,8 @@ static inline bool br_multicast_is_router(struct ne=
t_bridge *br)
 {
 	return 0;
 }
-static inline bool br_multicast_querier_exists(struct net_bridge *br)
+static inline bool br_multicast_querier_exists(struct net_bridge *br,
+					       struct ethhdr *eth)
 {
 	return false;
 }
--=20
1.7.10.4
