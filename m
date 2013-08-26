From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH] bridge: separate querier and query timer into IGMP/IPv4 and MLD/IPv6 ones
Date: Mon, 26 Aug 2013 12:01:06 +0200
Message-ID: <1377511266-14530-1-git-send-email-linus.luessing@web.de>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:59360 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756546Ab3HZKBY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Aug 2013 06:01:24 -0400
Received: from localhost ([95.211.10.3]) by smtp.web.de (mrweb102) with
 ESMTPSA (Nemesis) id 0LnS4I-1VhCYG2ya6-00harL for <netdev@vger.kernel.org>;
 Mon, 26 Aug 2013 12:01:21 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 net/bridge/br_mdb.c       |   14 +-
 net/bridge/br_multicast.c |  338 +++++++++++++++++++++++++++++++++++--=
--------
 net/bridge/br_private.h   |   47 +++++--
 5 files changed, 313 insertions(+), 90 deletions(-)

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
index 0daae3e..6053b96 100644
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
+		if (timer_pending(&br->ip4_multicast_querier_timer))
+			return -EBUSY;
+
 		ip.u.ip4 =3D entry->addr.u.ip4;
 #if IS_ENABLED(CONFIG_IPV6)
-	else
+	} else {
+		if (timer_pending(&br->ip6_multicast_querier_timer))
+			return -EBUSY;
+
 		ip.u.ip6 =3D entry->addr.u.ip6;
 #endif
+	}
=20
 	spin_lock_bh(&br->multicast_lock);
 	mdb =3D mlock_dereference(br->mdb, br);
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 08e576a..e1c01f4 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -33,7 +33,10 @@
=20
 #include "br_private.h"
=20
-static void br_multicast_start_querier(struct net_bridge *br);
+static void br_ip4_multicast_start_querier(struct net_bridge *br);
+#if IS_ENABLED(CONFIG_IPV6)
+static void br_ip6_multicast_start_querier(struct net_bridge *br);
+#endif
 unsigned int br_mdb_rehash_seq;
=20
 static inline int br_ip_equal(const struct br_ip *a, const struct br_i=
p *b)
@@ -755,7 +758,22 @@ static void br_multicast_local_router_expired(unsi=
gned long data)
 {
 }
=20
-static void br_multicast_querier_expired(unsigned long data)
+static void br_ip4_multicast_querier_expired(unsigned long data)
+{
+	struct net_bridge *br =3D (void *)data;
+
+	spin_lock(&br->multicast_lock);
+	if (!netif_running(br->dev) || br->multicast_disabled)
+		goto out;
+
+	br_ip4_multicast_start_querier(br);
+
+out:
+	spin_unlock(&br->multicast_lock);
+}
+
+#if IS_ENABLED(CONFIG_IPV6)
+static void br_ip6_multicast_querier_expired(unsigned long data)
 {
 	struct net_bridge *br =3D (void *)data;
=20
@@ -763,11 +781,12 @@ static void br_multicast_querier_expired(unsigned=
 long data)
 	if (!netif_running(br->dev) || br->multicast_disabled)
 		goto out;
=20
-	br_multicast_start_querier(br);
+	br_ip6_multicast_start_querier(br);
=20
 out:
 	spin_unlock(&br->multicast_lock);
 }
+#endif
=20
 static void __br_multicast_send_query(struct net_bridge *br,
 				      struct net_bridge_port *port,
@@ -788,15 +807,15 @@ static void __br_multicast_send_query(struct net_=
bridge *br,
 		netif_rx(skb);
 }
=20
-static void br_multicast_send_query(struct net_bridge *br,
-				    struct net_bridge_port *port, u32 sent)
+static void br_ip4_multicast_send_query(struct net_bridge *br,
+					struct net_bridge_port *port, u32 sent)
 {
 	unsigned long time;
 	struct br_ip br_group;
=20
 	if (!netif_running(br->dev) || br->multicast_disabled ||
 	    !br->multicast_querier ||
-	    timer_pending(&br->multicast_querier_timer))
+	    timer_pending(&br->ip4_multicast_querier_timer))
 		return;
=20
 	memset(&br_group.u, 0, sizeof(br_group.u));
@@ -804,20 +823,41 @@ static void br_multicast_send_query(struct net_br=
idge *br,
 	br_group.proto =3D htons(ETH_P_IP);
 	__br_multicast_send_query(br, port, &br_group);
=20
+	time =3D jiffies;
+	time +=3D sent < br->multicast_startup_query_count ?
+		br->multicast_startup_query_interval :
+		br->multicast_query_interval;
+	mod_timer(port ? &port->ip4_multicast_query_timer :
+			 &br->ip4_multicast_query_timer, time);
+}
+
 #if IS_ENABLED(CONFIG_IPV6)
+static void br_ip6_multicast_send_query(struct net_bridge *br,
+					struct net_bridge_port *port, u32 sent)
+{
+	unsigned long time;
+	struct br_ip br_group;
+
+	if (!netif_running(br->dev) || br->multicast_disabled ||
+	    !br->multicast_querier ||
+	    timer_pending(&br->ip6_multicast_querier_timer))
+		return;
+
+	memset(&br_group.u, 0, sizeof(br_group.u));
+
 	br_group.proto =3D htons(ETH_P_IPV6);
 	__br_multicast_send_query(br, port, &br_group);
-#endif
=20
 	time =3D jiffies;
 	time +=3D sent < br->multicast_startup_query_count ?
 		br->multicast_startup_query_interval :
 		br->multicast_query_interval;
-	mod_timer(port ? &port->multicast_query_timer :
-			 &br->multicast_query_timer, time);
+	mod_timer(port ? &port->ip6_multicast_query_timer :
+			 &br->ip6_multicast_query_timer, time);
 }
+#endif
=20
-static void br_multicast_port_query_expired(unsigned long data)
+static void br_ip4_multicast_port_query_expired(unsigned long data)
 {
 	struct net_bridge_port *port =3D (void *)data;
 	struct net_bridge *br =3D port->br;
@@ -827,25 +867,52 @@ static void br_multicast_port_query_expired(unsig=
ned long data)
 	    port->state =3D=3D BR_STATE_BLOCKING)
 		goto out;
=20
-	if (port->multicast_startup_queries_sent <
+	if (port->ip4_multicast_startup_queries_sent <
 	    br->multicast_startup_query_count)
-		port->multicast_startup_queries_sent++;
+		port->ip4_multicast_startup_queries_sent++;
=20
-	br_multicast_send_query(port->br, port,
-				port->multicast_startup_queries_sent);
+	br_ip4_multicast_send_query(port->br, port,
+				    port->ip4_multicast_startup_queries_sent);
=20
 out:
 	spin_unlock(&br->multicast_lock);
 }
=20
+#if IS_ENABLED(CONFIG_IPV6)
+static void br_ip6_multicast_port_query_expired(unsigned long data)
+{
+	struct net_bridge_port *port =3D (void *)data;
+	struct net_bridge *br =3D port->br;
+
+	spin_lock(&br->multicast_lock);
+	if (port->state =3D=3D BR_STATE_DISABLED ||
+	    port->state =3D=3D BR_STATE_BLOCKING)
+		goto out;
+
+	if (port->ip6_multicast_startup_queries_sent <
+	    br->multicast_startup_query_count)
+		port->ip6_multicast_startup_queries_sent++;
+
+	br_ip6_multicast_send_query(port->br, port,
+				    port->ip6_multicast_startup_queries_sent);
+
+out:
+	spin_unlock(&br->multicast_lock);
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
+	setup_timer(&port->ip4_multicast_query_timer,
+		    br_ip4_multicast_port_query_expired, (unsigned long)port);
+#if IS_ENABLED(CONFIG_IPV6)
+	setup_timer(&port->ip6_multicast_query_timer,
+		    br_ip6_multicast_port_query_expired, (unsigned long)port);
+#endif
 }
=20
 void br_multicast_del_port(struct net_bridge_port *port)
@@ -853,14 +920,25 @@ void br_multicast_del_port(struct net_bridge_port=
 *port)
 	del_timer_sync(&port->multicast_router_timer);
 }
=20
-static void __br_multicast_enable_port(struct net_bridge_port *port)
+static void __br_ip4_multicast_enable_port(struct net_bridge_port *por=
t)
+{
+	port->ip4_multicast_startup_queries_sent =3D 0;
+
+	if (try_to_del_timer_sync(&port->ip4_multicast_query_timer) >=3D 0 ||
+	    del_timer(&port->ip4_multicast_query_timer))
+		mod_timer(&port->ip4_multicast_query_timer, jiffies);
+}
+
+#if IS_ENABLED(CONFIG_IPV6)
+static void __br_ip6_multicast_enable_port(struct net_bridge_port *por=
t)
 {
-	port->multicast_startup_queries_sent =3D 0;
+	port->ip6_multicast_startup_queries_sent =3D 0;
=20
-	if (try_to_del_timer_sync(&port->multicast_query_timer) >=3D 0 ||
-	    del_timer(&port->multicast_query_timer))
-		mod_timer(&port->multicast_query_timer, jiffies);
+	if (try_to_del_timer_sync(&port->ip6_multicast_query_timer) >=3D 0 ||
+	    del_timer(&port->ip6_multicast_query_timer))
+		mod_timer(&port->ip6_multicast_query_timer, jiffies);
 }
+#endif
=20
 void br_multicast_enable_port(struct net_bridge_port *port)
 {
@@ -870,7 +948,10 @@ void br_multicast_enable_port(struct net_bridge_po=
rt *port)
 	if (br->multicast_disabled || !netif_running(br->dev))
 		goto out;
=20
-	__br_multicast_enable_port(port);
+	__br_ip4_multicast_enable_port(port);
+#if IS_ENABLED(CONFIG_IPV6)
+	__br_ip6_multicast_enable_port(port);
+#endif
=20
 out:
 	spin_unlock(&br->multicast_lock);
@@ -889,7 +970,8 @@ void br_multicast_disable_port(struct net_bridge_po=
rt *port)
 	if (!hlist_unhashed(&port->rlist))
 		hlist_del_init_rcu(&port->rlist);
 	del_timer(&port->multicast_router_timer);
-	del_timer(&port->multicast_query_timer);
+	del_timer(&port->ip4_multicast_query_timer);
+	del_timer(&port->ip6_multicast_query_timer);
 	spin_unlock(&br->multicast_lock);
 }
=20
@@ -1014,16 +1096,28 @@ static int br_ip6_multicast_mld2_report(struct =
net_bridge *br,
 }
 #endif
=20
-static void br_multicast_update_querier_timer(struct net_bridge *br,
-					      unsigned long max_delay)
+static void br_ip4_multicast_update_querier_timer(struct net_bridge *b=
r,
+						  unsigned long max_delay)
 {
-	if (!timer_pending(&br->multicast_querier_timer))
-		br->multicast_querier_delay_time =3D jiffies + max_delay;
+	if (!timer_pending(&br->ip4_multicast_querier_timer))
+		br->ip4_multicast_querier_delay_time =3D jiffies + max_delay;
=20
-	mod_timer(&br->multicast_querier_timer,
+	mod_timer(&br->ip4_multicast_querier_timer,
 		  jiffies + br->multicast_querier_interval);
 }
=20
+#if IS_ENABLED(CONFIG_IPV6)
+static void br_ip6_multicast_update_querier_timer(struct net_bridge *b=
r,
+						  unsigned long max_delay)
+{
+	if (!timer_pending(&br->ip6_multicast_querier_timer))
+		br->ip6_multicast_querier_delay_time =3D jiffies + max_delay;
+
+	mod_timer(&br->ip6_multicast_querier_timer,
+		  jiffies + br->multicast_querier_interval);
+}
+#endif
+
 /*
  * Add port to router_list
  *  list is maintained ordered by pointer value
@@ -1072,18 +1166,33 @@ timer:
 		  now + br->multicast_querier_interval);
 }
=20
-static void br_multicast_query_received(struct net_bridge *br,
-					struct net_bridge_port *port,
-					int saddr,
-					unsigned long max_delay)
+static void br_ip4_multicast_query_received(struct net_bridge *br,
+					    struct net_bridge_port *port,
+					    int saddr,
+					    unsigned long max_delay)
+{
+	if (saddr)
+		br_ip4_multicast_update_querier_timer(br, max_delay);
+	else if (timer_pending(&br->ip4_multicast_querier_timer))
+		return;
+
+	br_multicast_mark_router(br, port);
+}
+
+#if IS_ENABLED(CONFIG_IPV6)
+static void br_ip6_multicast_query_received(struct net_bridge *br,
+					    struct net_bridge_port *port,
+					    int saddr,
+					    unsigned long max_delay)
 {
 	if (saddr)
-		br_multicast_update_querier_timer(br, max_delay);
-	else if (timer_pending(&br->multicast_querier_timer))
+		br_ip6_multicast_update_querier_timer(br, max_delay);
+	else if (timer_pending(&br->ip6_multicast_querier_timer))
 		return;
=20
 	br_multicast_mark_router(br, port);
 }
+#endif
=20
 static int br_ip4_multicast_query(struct net_bridge *br,
 				  struct net_bridge_port *port,
@@ -1129,7 +1238,7 @@ static int br_ip4_multicast_query(struct net_brid=
ge *br,
 			    IGMPV3_MRC(ih3->code) * (HZ / IGMP_TIMER_SCALE) : 1;
 	}
=20
-	br_multicast_query_received(br, port, !!iph->saddr, max_delay);
+	br_ip4_multicast_query_received(br, port, !!iph->saddr, max_delay);
=20
 	if (!group)
 		goto out;
@@ -1206,8 +1315,8 @@ static int br_ip6_multicast_query(struct net_brid=
ge *br,
 		max_delay =3D mld2q->mld2q_mrc ? MLDV2_MRC(ntohs(mld2q->mld2q_mrc)) =
: 1;
 	}
=20
-	br_multicast_query_received(br, port, !ipv6_addr_any(&ip6h->saddr),
-				    max_delay);
+	br_ip6_multicast_query_received(br, port, !ipv6_addr_any(&ip6h->saddr=
),
+					max_delay);
=20
 	if (!group)
 		goto out;
@@ -1252,25 +1361,23 @@ static void br_multicast_leave_group(struct net=
_bridge *br,
 	unsigned long now;
 	unsigned long time;
=20
-	spin_lock(&br->multicast_lock);
-	if (!netif_running(br->dev) ||
-	    (port && port->state =3D=3D BR_STATE_DISABLED) ||
-	    timer_pending(&br->multicast_querier_timer))
-		goto out;
-
 	mdb =3D mlock_dereference(br->mdb, br);
 	mp =3D br_mdb_ip_get(mdb, group);
 	if (!mp)
-		goto out;
+		return;
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
+		if (group->proto =3D=3D htons(ETH_P_IP))
+			mod_timer(port ? &port->ip4_multicast_query_timer :
+				  &br->ip4_multicast_query_timer, time);
+		else
+			mod_timer(port ? &port->ip6_multicast_query_timer :
+				  &br->ip6_multicast_query_timer, time);
=20
 		for (p =3D mlock_dereference(mp->ports, br);
 		     p !=3D NULL;
@@ -1308,7 +1415,7 @@ static void br_multicast_leave_group(struct net_b=
ridge *br,
 			    netif_running(br->dev))
 				mod_timer(&mp->timer, jiffies);
 		}
-		goto out;
+		return;
 	}
=20
 	now =3D jiffies;
@@ -1323,9 +1430,6 @@ static void br_multicast_leave_group(struct net_b=
ridge *br,
 			mod_timer(&mp->timer, time);
 		}
 	}
-
-out:
-	spin_unlock(&br->multicast_lock);
 }
=20
 static void br_ip4_multicast_leave_group(struct net_bridge *br,
@@ -1342,7 +1446,15 @@ static void br_ip4_multicast_leave_group(struct =
net_bridge *br,
 	br_group.proto =3D htons(ETH_P_IP);
 	br_group.vid =3D vid;
=20
+	spin_lock(&br->multicast_lock);
+	if (!netif_running(br->dev) ||
+	    (port && port->state =3D=3D BR_STATE_DISABLED) ||
+	    timer_pending(&br->ip4_multicast_querier_timer))
+		goto out;
+
 	br_multicast_leave_group(br, port, &br_group);
+out:
+	spin_unlock(&br->multicast_lock);
 }
=20
 #if IS_ENABLED(CONFIG_IPV6)
@@ -1360,7 +1472,15 @@ static void br_ip6_multicast_leave_group(struct =
net_bridge *br,
 	br_group.proto =3D htons(ETH_P_IPV6);
 	br_group.vid =3D vid;
=20
+	spin_lock(&br->multicast_lock);
+	if (!netif_running(br->dev) ||
+	    (port && port->state =3D=3D BR_STATE_DISABLED) ||
+	    timer_pending(&br->ip6_multicast_querier_timer))
+		goto out;
+
 	br_multicast_leave_group(br, port, &br_group);
+out:
+	spin_unlock(&br->multicast_lock);
 }
 #endif
=20
@@ -1622,20 +1742,38 @@ int br_multicast_rcv(struct net_bridge *br, str=
uct net_bridge_port *port,
 	return 0;
 }
=20
-static void br_multicast_query_expired(unsigned long data)
+static void br_ip4_multicast_query_expired(unsigned long data)
 {
 	struct net_bridge *br =3D (void *)data;
=20
 	spin_lock(&br->multicast_lock);
-	if (br->multicast_startup_queries_sent <
+	if (br->ip4_multicast_startup_queries_sent <
 	    br->multicast_startup_query_count)
-		br->multicast_startup_queries_sent++;
+		br->ip4_multicast_startup_queries_sent++;
=20
-	br_multicast_send_query(br, NULL, br->multicast_startup_queries_sent)=
;
+	br_ip4_multicast_send_query(br, NULL,
+				    br->ip4_multicast_startup_queries_sent);
=20
 	spin_unlock(&br->multicast_lock);
 }
=20
+#if IS_ENABLED(CONFIG_IPV6)
+static void br_ip6_multicast_query_expired(unsigned long data)
+{
+	struct net_bridge *br =3D (void *)data;
+
+	spin_lock(&br->multicast_lock);
+	if (br->ip6_multicast_startup_queries_sent <
+	    br->multicast_startup_query_count)
+		br->ip6_multicast_startup_queries_sent++;
+
+	br_ip6_multicast_send_query(br, NULL,
+				    br->ip6_multicast_startup_queries_sent);
+
+	spin_unlock(&br->multicast_lock);
+}
+#endif
+
 void br_multicast_init(struct net_bridge *br)
 {
 	br->hash_elasticity =3D 4;
@@ -1654,25 +1792,52 @@ void br_multicast_init(struct net_bridge *br)
 	br->multicast_querier_interval =3D 255 * HZ;
 	br->multicast_membership_interval =3D 260 * HZ;
=20
-	br->multicast_querier_delay_time =3D 0;
+	br->ip4_multicast_querier_delay_time =3D 0;
+	br->ip6_multicast_querier_delay_time =3D 0;
=20
 	spin_lock_init(&br->multicast_lock);
 	setup_timer(&br->multicast_router_timer,
 		    br_multicast_local_router_expired, 0);
-	setup_timer(&br->multicast_querier_timer,
-		    br_multicast_querier_expired, (unsigned long)br);
-	setup_timer(&br->multicast_query_timer, br_multicast_query_expired,
-		    (unsigned long)br);
+	setup_timer(&br->ip4_multicast_querier_timer,
+		    br_ip4_multicast_querier_expired, (unsigned long)br);
+	setup_timer(&br->ip4_multicast_query_timer,
+		    br_ip4_multicast_query_expired, (unsigned long)br);
+#if IS_ENABLED(CONFIG_IPV6)
+	setup_timer(&br->ip6_multicast_querier_timer,
+		    br_ip6_multicast_querier_expired, (unsigned long)br);
+	setup_timer(&br->ip6_multicast_query_timer,
+		    br_ip6_multicast_query_expired, (unsigned long)br);
+#endif
 }
=20
-void br_multicast_open(struct net_bridge *br)
+static void br_ip4_multicast_open(struct net_bridge *br)
 {
-	br->multicast_startup_queries_sent =3D 0;
+	br->ip4_multicast_startup_queries_sent =3D 0;
=20
 	if (br->multicast_disabled)
 		return;
=20
-	mod_timer(&br->multicast_query_timer, jiffies);
+	mod_timer(&br->ip4_multicast_query_timer, jiffies);
+}
+
+#if IS_ENABLED(CONFIG_IPV6)
+static void br_ip6_multicast_open(struct net_bridge *br)
+{
+	br->ip6_multicast_startup_queries_sent =3D 0;
+
+	if (br->multicast_disabled)
+		return;
+
+	mod_timer(&br->ip6_multicast_query_timer, jiffies);
+}
+#endif
+
+void br_multicast_open(struct net_bridge *br)
+{
+	br_ip4_multicast_open(br);
+#if IS_ENABLED(CONFIG_IPV6)
+	br_ip6_multicast_open(br);
+#endif
 }
=20
 void br_multicast_stop(struct net_bridge *br)
@@ -1684,8 +1849,10 @@ void br_multicast_stop(struct net_bridge *br)
 	int i;
=20
 	del_timer_sync(&br->multicast_router_timer);
-	del_timer_sync(&br->multicast_querier_timer);
-	del_timer_sync(&br->multicast_query_timer);
+	del_timer_sync(&br->ip4_multicast_querier_timer);
+	del_timer_sync(&br->ip6_multicast_querier_timer);
+	del_timer_sync(&br->ip4_multicast_query_timer);
+	del_timer_sync(&br->ip6_multicast_query_timer);
=20
 	spin_lock_bh(&br->multicast_lock);
 	mdb =3D mlock_dereference(br->mdb, br);
@@ -1788,21 +1955,38 @@ unlock:
 	return err;
 }
=20
-static void br_multicast_start_querier(struct net_bridge *br)
+static void br_ip4_multicast_start_querier(struct net_bridge *br)
 {
 	struct net_bridge_port *port;
=20
-	br_multicast_open(br);
+	br_ip4_multicast_open(br);
=20
 	list_for_each_entry(port, &br->port_list, list) {
 		if (port->state =3D=3D BR_STATE_DISABLED ||
 		    port->state =3D=3D BR_STATE_BLOCKING)
 			continue;
=20
-		__br_multicast_enable_port(port);
+		__br_ip4_multicast_enable_port(port);
 	}
 }
=20
+#if IS_ENABLED(CONFIG_IPV6)
+static void br_ip6_multicast_start_querier(struct net_bridge *br)
+{
+	struct net_bridge_port *port;
+
+	br_ip6_multicast_open(br);
+
+	list_for_each_entry(port, &br->port_list, list) {
+		if (port->state =3D=3D BR_STATE_DISABLED ||
+		    port->state =3D=3D BR_STATE_BLOCKING)
+			continue;
+
+		__br_ip6_multicast_enable_port(port);
+	}
+}
+#endif
+
 int br_multicast_toggle(struct net_bridge *br, unsigned long val)
 {
 	int err =3D 0;
@@ -1834,7 +2018,10 @@ rollback:
 			goto rollback;
 	}
=20
-	br_multicast_start_querier(br);
+	br_ip4_multicast_start_querier(br);
+#if IS_ENABLED(CONFIG_IPV6)
+	br_ip6_multicast_start_querier(br);
+#endif
=20
 unlock:
 	spin_unlock_bh(&br->multicast_lock);
@@ -1857,10 +2044,15 @@ int br_multicast_set_querier(struct net_bridge =
*br, unsigned long val)
 		goto unlock;
=20
 	max_delay =3D br->multicast_query_response_interval;
-	if (!timer_pending(&br->multicast_querier_timer))
-		br->multicast_querier_delay_time =3D jiffies + max_delay;
+	if (!timer_pending(&br->ip4_multicast_querier_timer))
+		br->ip4_multicast_querier_delay_time =3D jiffies + max_delay;
+	if (!timer_pending(&br->ip6_multicast_querier_timer))
+		br->ip6_multicast_querier_delay_time =3D jiffies + max_delay;
=20
-	br_multicast_start_querier(br);
+	br_ip4_multicast_start_querier(br);
+#if IS_ENABLED(CONFIG_IPV6)
+	br_ip6_multicast_start_querier(br);
+#endif
=20
 unlock:
 	spin_unlock_bh(&br->multicast_lock);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 2f7da41..10b4231 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -162,10 +162,12 @@ struct net_bridge_port
 #define BR_FLOOD		0x00000040
=20
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
-	u32				multicast_startup_queries_sent;
+	u32				ip4_multicast_startup_queries_sent;
+	u32				ip6_multicast_startup_queries_sent;
 	unsigned char			multicast_router;
 	struct timer_list		multicast_router_timer;
-	struct timer_list		multicast_query_timer;
+	struct timer_list		ip4_multicast_query_timer;
+	struct timer_list		ip6_multicast_query_timer;
 	struct hlist_head		mglist;
 	struct hlist_node		rlist;
 #endif
@@ -258,7 +260,8 @@ struct net_bridge
 	u32				hash_max;
=20
 	u32				multicast_last_member_count;
-	u32				multicast_startup_queries_sent;
+	u32				ip4_multicast_startup_queries_sent;
+	u32				ip6_multicast_startup_queries_sent;
 	u32				multicast_startup_query_count;
=20
 	unsigned long			multicast_last_member_interval;
@@ -267,15 +270,18 @@ struct net_bridge
 	unsigned long			multicast_query_interval;
 	unsigned long			multicast_query_response_interval;
 	unsigned long			multicast_startup_query_interval;
-	unsigned long			multicast_querier_delay_time;
+	unsigned long			ip4_multicast_querier_delay_time;
+	unsigned long			ip6_multicast_querier_delay_time;
=20
 	spinlock_t			multicast_lock;
 	struct net_bridge_mdb_htable __rcu *mdb;
 	struct hlist_head		router_list;
=20
 	struct timer_list		multicast_router_timer;
-	struct timer_list		multicast_querier_timer;
-	struct timer_list		multicast_query_timer;
+	struct timer_list		ip4_multicast_querier_timer;
+	struct timer_list		ip6_multicast_querier_timer;
+	struct timer_list		ip4_multicast_query_timer;
+	struct timer_list		ip6_multicast_query_timer;
 #endif
=20
 	struct timer_list		hello_timer;
@@ -503,11 +509,31 @@ static inline bool br_multicast_is_router(struct =
net_bridge *br)
 		timer_pending(&br->multicast_router_timer));
 }
=20
-static inline bool br_multicast_querier_exists(struct net_bridge *br)
+static inline bool br_ip4_multicast_querier_exists(struct net_bridge *=
br)
 {
-	return time_is_before_jiffies(br->multicast_querier_delay_time) &&
+	return time_is_before_jiffies(br->ip4_multicast_querier_delay_time) &=
&
 	       (br->multicast_querier ||
-		timer_pending(&br->multicast_querier_timer));
+		timer_pending(&br->ip4_multicast_querier_timer));
+}
+
+static inline bool br_ip6_multicast_querier_exists(struct net_bridge *=
br)
+{
+	return time_is_before_jiffies(br->ip6_multicast_querier_delay_time) &=
&
+	       (br->multicast_querier ||
+		timer_pending(&br->ip6_multicast_querier_timer));
+}
+
+static inline bool br_multicast_querier_exists(struct net_bridge *br,
+					       struct ethhdr *eth)
+{
+	switch (eth->h_proto) {
+	case (htons(ETH_P_IP)):
+		return br_ip4_multicast_querier_exists(br);
+	case (htons(ETH_P_IPV6)):
+		return br_ip6_multicast_querier_exists(br);
+	default:
+		return false;
+	}
 }
 #else
 static inline int br_multicast_rcv(struct net_bridge *br,
@@ -565,7 +591,8 @@ static inline bool br_multicast_is_router(struct ne=
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
