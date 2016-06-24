From: Daniel Danzberger <daniel@dd-wrt.com>
Subject: [PATCH net] Bridge: Fix ipv6 mc snooping if bridge has no
	ipv6 address
Date: Fri, 24 Jun 2016 12:35:18 +0200
Message-ID: <1466764518-11358-1-git-send-email-daniel@dd-wrt.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: davem@davemloft.net
To: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
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

The bridge is falsly dropping ipv6 mulitcast packets if there is:
 1. No ipv6 address assigned on the brigde.
 2. No external mld querier present.
 3. The internal querier enabled.

When the bridge fails to build mld queries, because it has no
ipv6 address, it slilently returns, but keeps the local querier enabled.
This specific case causes confusing packet loss.

Ipv6 multicast snooping can only work if:
 a) An external querier is present
 OR
 b) The bridge has an ipv6 address an is capable of sending own queries

Otherwise it has to forward/flood the ipv6 multicast traffic,
because snooping cannot work.

This patch fixes the issue by adding a flag to the bridge struct that
indicates that there is currently no ipv6 address assinged to the bridge
and returns a false state for the local querier in
__br_multicast_querier_exists().

Special thanks to Linus L=C3=BCssing.

Signed-off-by: Daniel Danzberger <daniel@dd-wrt.com>
---
 net/bridge/br_multicast.c |  4 ++++
 net/bridge/br_private.h   | 23 +++++++++++++++++++----
 2 files changed, 23 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 6852f3c..4384414 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -464,8 +464,11 @@ static struct sk_buff *br_ip6_multicast_alloc_query(=
struct net_bridge *br,
 	if (ipv6_dev_get_saddr(dev_net(br->dev), br->dev, &ip6h->daddr, 0,
 			       &ip6h->saddr)) {
 		kfree_skb(skb);
+		br->has_ipv6_addr =3D 0;
 		return NULL;
 	}
+
+	br->has_ipv6_addr =3D 1;
 	ipv6_eth_mc_map(&ip6h->daddr, eth->h_dest);
=20
 	hopopt =3D (u8 *)(ip6h + 1);
@@ -1745,6 +1748,7 @@ void br_multicast_init(struct net_bridge *br)
 	br->ip6_other_query.delay_time =3D 0;
 	br->ip6_querier.port =3D NULL;
 #endif
+	br->has_ipv6_addr =3D 1;
=20
 	spin_lock_init(&br->multicast_lock);
 	setup_timer(&br->multicast_router_timer,
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index c7fb5d7..52edecf 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -314,6 +314,7 @@ struct net_bridge
 	u8				multicast_disabled:1;
 	u8				multicast_querier:1;
 	u8				multicast_query_use_ifaddr:1;
+	u8				has_ipv6_addr:1;
=20
 	u32				hash_elasticity;
 	u32				hash_max;
@@ -588,10 +589,22 @@ static inline bool br_multicast_is_router(struct ne=
t_bridge *br)
=20
 static inline bool
 __br_multicast_querier_exists(struct net_bridge *br,
-			      struct bridge_mcast_other_query *querier)
+				struct bridge_mcast_other_query *querier,
+				const bool is_ipv6)
 {
+	bool own_querier_enabled;
+
+	if (br->multicast_querier) {
+		if (is_ipv6 && !br->has_ipv6_addr)
+			own_querier_enabled =3D false;
+		else
+			own_querier_enabled =3D true;
+	} else {
+		own_querier_enabled =3D false;
+	}
+
 	return time_is_before_jiffies(querier->delay_time) &&
-	       (br->multicast_querier || timer_pending(&querier->timer));
+	       (own_querier_enabled || timer_pending(&querier->timer));
 }
=20
 static inline bool br_multicast_querier_exists(struct net_bridge *br,
@@ -599,10 +612,12 @@ static inline bool br_multicast_querier_exists(stru=
ct net_bridge *br,
 {
 	switch (eth->h_proto) {
 	case (htons(ETH_P_IP)):
-		return __br_multicast_querier_exists(br, &br->ip4_other_query);
+		return __br_multicast_querier_exists(br,
+			&br->ip4_other_query, false);
 #if IS_ENABLED(CONFIG_IPV6)
 	case (htons(ETH_P_IPV6)):
-		return __br_multicast_querier_exists(br, &br->ip6_other_query);
+		return __br_multicast_querier_exists(br,
+			&br->ip6_other_query, true);
 #endif
 	default:
 		return false;
--=20
2.1.4
