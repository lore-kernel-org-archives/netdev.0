From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCH net-next 2/4] bridge: adhere to querier election
	mechanism specified by RFCs
Date: Wed, 21 May 2014 10:59:00 +0200
Message-ID: <1400662742-31999-3-git-send-email-linus.luessing@web.de>
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

MLDv1 (RFC2710 section 6), MLDv2 (RFC3810 section 7.6.2), IGMPv2
(RFC2236 section 3) and IGMPv3 (RFC3376 section 6.6.2) specify that the
querier with lowest source address shall become the selected
querier.

So far the bridge stopped its querier as soon as it heard another
querier regardless of its source address. This results in the "wrong"
querier potentially becoming the active querier or a potential,
unnecessary querying delay.

With this patch the bridge memorizes the source address of the currently
selected querier and ignores queries from queriers with a higher source
address than the currently selected one. This slight optimization is
supposed to make it more RFC compliant (but is rather uncritical and
therefore probably not necessary to be queued for stable kernels).

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
 net/bridge/br_multicast.c |  101 +++++++++++++++++++++++++++++++++++++++=
------
 net/bridge/br_private.h   |    7 ++++
 2 files changed, 95 insertions(+), 13 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 6bc9cef..05c6593 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -789,6 +789,18 @@ static void br_ip6_multicast_querier_expired(unsigne=
d long data)
 }
 #endif
=20
+static void br_multicast_select_own_querier(struct net_bridge *br,
+					    struct br_ip *ip,
+					    struct sk_buff *skb)
+{
+	if (ip->proto =3D=3D htons(ETH_P_IP))
+		br->ip4_querier.addr.u.ip4 =3D ip_hdr(skb)->saddr;
+#if IS_ENABLED(CONFIG_IPV6)
+	else
+		br->ip6_querier.addr.u.ip6 =3D ipv6_hdr(skb)->saddr;
+#endif
+}
+
 static void __br_multicast_send_query(struct net_bridge *br,
 				      struct net_bridge_port *port,
 				      struct br_ip *ip)
@@ -804,8 +816,10 @@ static void __br_multicast_send_query(struct net_bri=
dge *br,
 		skb->dev =3D port->dev;
 		NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
 			dev_queue_xmit);
-	} else
+	} else {
+		br_multicast_select_own_querier(br, ip, skb);
 		netif_rx(skb);
+	}
 }
=20
 static void br_multicast_send_query(struct net_bridge *br,
@@ -1065,6 +1079,62 @@ static int br_ip6_multicast_mld2_report(struct net=
_bridge *br,
 }
 #endif
=20
+static bool br_ip4_multicast_select_querier(struct net_bridge *br,
+					    __be32 saddr)
+{
+	if (!timer_pending(&br->ip4_own_query.timer) &&
+	    !timer_pending(&br->ip4_other_query.timer))
+		goto update;
+
+	if (!br->ip4_querier.addr.u.ip4)
+		goto update;
+
+	if (saddr <=3D br->ip4_querier.addr.u.ip4)
+		goto update;
+
+	return false;
+
+update:
+	br->ip4_querier.addr.u.ip4 =3D saddr;
+
+	return true;
+}
+
+#if IS_ENABLED(CONFIG_IPV6)
+static bool br_ip6_multicast_select_querier(struct net_bridge *br,
+					    struct in6_addr *saddr)
+{
+	if (!timer_pending(&br->ip6_own_query.timer) &&
+	    !timer_pending(&br->ip6_other_query.timer))
+		goto update;
+
+	if (ipv6_addr_cmp(saddr, &br->ip6_querier.addr.u.ip6) <=3D 0)
+		goto update;
+
+	return false;
+
+update:
+	br->ip6_querier.addr.u.ip6 =3D *saddr;
+
+	return true;
+}
+#endif
+
+static bool br_multicast_select_querier(struct net_bridge *br,
+					struct br_ip *saddr)
+{
+	switch (saddr->proto) {
+	case htons(ETH_P_IP):
+		return br_ip4_multicast_select_querier(br, saddr->u.ip4);
+#if IS_ENABLED(CONFIG_IPV6)
+	case htons(ETH_P_IPV6):
+		return br_ip6_multicast_select_querier(br, &saddr->u.ip6);
+#endif
+	}
+
+	return false;
+}
+
 static void
 br_multicast_update_query_timer(struct net_bridge *br,
 				struct bridge_mcast_other_query *query,
@@ -1127,15 +1197,13 @@ timer:
 static void br_multicast_query_received(struct net_bridge *br,
 					struct net_bridge_port *port,
 					struct bridge_mcast_other_query *query,
-					int saddr,
-					bool is_general_query,
+					struct br_ip *saddr,
 					unsigned long max_delay)
 {
-	if (saddr && is_general_query)
-		br_multicast_update_query_timer(br, query, max_delay);
-	else if (timer_pending(&query->timer))
+	if (!br_multicast_select_querier(br, saddr))
 		return;
=20
+	br_multicast_update_query_timer(br, query, max_delay);
 	br_multicast_mark_router(br, port);
 }
=20
@@ -1150,6 +1218,7 @@ static int br_ip4_multicast_query(struct net_bridge=
 *br,
 	struct igmpv3_query *ih3;
 	struct net_bridge_port_group *p;
 	struct net_bridge_port_group __rcu **pp;
+	struct br_ip saddr;
 	unsigned long max_delay;
 	unsigned long now =3D jiffies;
 	__be32 group;
@@ -1191,11 +1260,14 @@ static int br_ip4_multicast_query(struct net_brid=
ge *br,
 		goto out;
 	}
=20
-	br_multicast_query_received(br, port, &br->ip4_other_query,
-				    !!iph->saddr, !group, max_delay);
+	if (!group) {
+		saddr.proto =3D ntohs(ETH_P_IP);
+		saddr.u.ip4 =3D iph->saddr;
=20
-	if (!group)
+		br_multicast_query_received(br, port, &br->ip4_other_query,
+					    &saddr, max_delay);
 		goto out;
+	}
=20
 	mp =3D br_mdb_ip4_get(mlock_dereference(br->mdb, br), group, vid);
 	if (!mp)
@@ -1235,6 +1307,7 @@ static int br_ip6_multicast_query(struct net_bridge=
 *br,
 	struct mld2_query *mld2q;
 	struct net_bridge_port_group *p;
 	struct net_bridge_port_group __rcu **pp;
+	struct br_ip saddr;
 	unsigned long max_delay;
 	unsigned long now =3D jiffies;
 	const struct in6_addr *group =3D NULL;
@@ -1283,12 +1356,14 @@ static int br_ip6_multicast_query(struct net_brid=
ge *br,
 		goto out;
 	}
=20
-	br_multicast_query_received(br, port, &br->ip6_other_query,
-				    !ipv6_addr_any(&ip6h->saddr),
-				    is_general_query, max_delay);
+	if (is_general_query) {
+		saddr.proto =3D ntohs(ETH_P_IPV6);
+		saddr.u.ip6 =3D ip6h->saddr;
=20
-	if (!group)
+		br_multicast_query_received(br, port, &br->ip6_other_query,
+					    &saddr, max_delay);
 		goto out;
+	}
=20
 	mp =3D br_mdb_ip6_get(mlock_dereference(br->mdb, br), group, vid);
 	if (!mp)
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index f186ce8..bc1803b 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -78,6 +78,11 @@ struct bridge_mcast_other_query {
 	struct timer_list		timer;
 	unsigned long			delay_time;
 };
+
+/* selected querier */
+struct bridge_mcast_querier {
+	struct br_ip addr;
+};
 #endif
=20
 struct net_port_vlans {
@@ -284,9 +289,11 @@ struct net_bridge
 	struct timer_list		multicast_router_timer;
 	struct bridge_mcast_other_query	ip4_other_query;
 	struct bridge_mcast_own_query	ip4_own_query;
+	struct bridge_mcast_querier	ip4_querier;
 #if IS_ENABLED(CONFIG_IPV6)
 	struct bridge_mcast_other_query	ip6_other_query;
 	struct bridge_mcast_own_query	ip6_own_query;
+	struct bridge_mcast_querier	ip6_querier;
 #endif /* IS_ENABLED(CONFIG_IPV6) */
 #endif
=20
--=20
1.7.10.4
