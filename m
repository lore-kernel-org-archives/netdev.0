From: =?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>
Subject: [PATCHv3] bridge: disable snooping if there is no querier
Date: Thu,  1 Aug 2013 01:06:20 +0200
Message-ID: <1375311980-25575-1-git-send-email-linus.luessing@web.de>
References: <20130730.161035.1646022729333223847.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Adam Baker <linux@baker-net.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	=?UTF-8?q?Linus=20L=C3=BCssing?= <linus.luessing@web.de>,
	"David S. Miller" <davem@davemloft.net>, Cong Wang <amwang@redhat.com>
To: bridge@lists.linux-foundation.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20130730.161035.1646022729333223847.davem@davemloft.net>
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

If there is no querier on a link then we won't get periodic reports and
therefore won't be able to learn about multicast listeners behind ports,
potentially leading to lost multicast packets, especially for multicast
listeners that joined before the creation of the bridge.

These lost multicast packets can appear since c5c23260594
("bridge: Add multicast_querier toggle and disable queries by default")
in particular.

With this patch we are flooding multicast packets if our querier is
disabled and if we didn't detect any other querier.

A grace period of the Maximum Response Delay of the querier is added to
give multicast responses enough time to arrive and to be learned from
before disabling the flooding behaviour again.

Signed-off-by: Linus L=C3=BCssing <linus.luessing@web.de>
---
v3: changed type of multicast_querier_delay_time from
    atomic64_t to unsigned long
v2: added missing, empty br_multicast_querier_exists() to avoid
    build failures if CONFIG_BRIDGE_IGMP_SNOOPING is not set

 net/bridge/br_device.c    |    3 ++-
 net/bridge/br_input.c     |    3 ++-
 net/bridge/br_multicast.c |   39 ++++++++++++++++++++++++++++++---------
 net/bridge/br_private.h   |   12 ++++++++++++
 4 files changed, 46 insertions(+), 11 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 2ef6678..69363bd 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -70,7 +70,8 @@ netdev_tx_t br_dev_xmit(struct sk_buff *skb, struct net=
_device *dev)
 		}
=20
 		mdst =3D br_mdb_get(br, skb, vid);
-		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb))
+		if ((mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) &&
+		    br_multicast_querier_exists(br))
 			br_multicast_deliver(mdst, skb);
 		else
 			br_flood_deliver(br, skb, false);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 1b8b8b8..8c561c0 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -101,7 +101,8 @@ int br_handle_frame_finish(struct sk_buff *skb)
 		unicast =3D false;
 	} else if (is_multicast_ether_addr(dest)) {
 		mdst =3D br_mdb_get(br, skb, vid);
-		if (mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) {
+		if ((mdst || BR_INPUT_SKB_CB_MROUTERS_ONLY(skb)) &&
+		    br_multicast_querier_exists(br)) {
 			if ((mdst && mdst->mglist) ||
 			    br_multicast_is_router(br))
 				skb2 =3D skb;
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 4b99c9a..61c5e81 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1014,6 +1014,16 @@ static int br_ip6_multicast_mld2_report(struct net=
_bridge *br,
 }
 #endif
=20
+static void br_multicast_update_querier_timer(struct net_bridge *br,
+					      unsigned long max_delay)
+{
+	if (!timer_pending(&br->multicast_querier_timer))
+		br->multicast_querier_delay_time =3D jiffies + max_delay;
+
+	mod_timer(&br->multicast_querier_timer,
+		  jiffies + br->multicast_querier_interval);
+}
+
 /*
  * Add port to router_list
  *  list is maintained ordered by pointer value
@@ -1064,11 +1074,11 @@ timer:
=20
 static void br_multicast_query_received(struct net_bridge *br,
 					struct net_bridge_port *port,
-					int saddr)
+					int saddr,
+					unsigned long max_delay)
 {
 	if (saddr)
-		mod_timer(&br->multicast_querier_timer,
-			  jiffies + br->multicast_querier_interval);
+		br_multicast_update_querier_timer(br, max_delay);
 	else if (timer_pending(&br->multicast_querier_timer))
 		return;
=20
@@ -1096,8 +1106,6 @@ static int br_ip4_multicast_query(struct net_bridge=
 *br,
 	    (port && port->state =3D=3D BR_STATE_DISABLED))
 		goto out;
=20
-	br_multicast_query_received(br, port, !!iph->saddr);
-
 	group =3D ih->group;
=20
 	if (skb->len =3D=3D sizeof(*ih)) {
@@ -1121,6 +1129,8 @@ static int br_ip4_multicast_query(struct net_bridge=
 *br,
 			    IGMPV3_MRC(ih3->code) * (HZ / IGMP_TIMER_SCALE) : 1;
 	}
=20
+	br_multicast_query_received(br, port, !!iph->saddr, max_delay);
+
 	if (!group)
 		goto out;
=20
@@ -1176,8 +1186,6 @@ static int br_ip6_multicast_query(struct net_bridge=
 *br,
 	    (port && port->state =3D=3D BR_STATE_DISABLED))
 		goto out;
=20
-	br_multicast_query_received(br, port, !ipv6_addr_any(&ip6h->saddr));
-
 	if (skb->len =3D=3D sizeof(*mld)) {
 		if (!pskb_may_pull(skb, sizeof(*mld))) {
 			err =3D -EINVAL;
@@ -1198,6 +1206,9 @@ static int br_ip6_multicast_query(struct net_bridge=
 *br,
 		max_delay =3D mld2q->mld2q_mrc ? MLDV2_MRC(ntohs(mld2q->mld2q_mrc)) : =
1;
 	}
=20
+	br_multicast_query_received(br, port, !ipv6_addr_any(&ip6h->saddr),
+				    max_delay);
+
 	if (!group)
 		goto out;
=20
@@ -1643,6 +1654,8 @@ void br_multicast_init(struct net_bridge *br)
 	br->multicast_querier_interval =3D 255 * HZ;
 	br->multicast_membership_interval =3D 260 * HZ;
=20
+	br->multicast_querier_delay_time =3D 0;
+
 	spin_lock_init(&br->multicast_lock);
 	setup_timer(&br->multicast_router_timer,
 		    br_multicast_local_router_expired, 0);
@@ -1831,6 +1844,8 @@ unlock:
=20
 int br_multicast_set_querier(struct net_bridge *br, unsigned long val)
 {
+	unsigned long max_delay;
+
 	val =3D !!val;
=20
 	spin_lock_bh(&br->multicast_lock);
@@ -1838,8 +1853,14 @@ int br_multicast_set_querier(struct net_bridge *br=
, unsigned long val)
 		goto unlock;
=20
 	br->multicast_querier =3D val;
-	if (val)
-		br_multicast_start_querier(br);
+	if (!val)
+		goto unlock;
+
+	max_delay =3D br->multicast_query_response_interval;
+	if (!timer_pending(&br->multicast_querier_timer))
+		br->multicast_querier_delay_time =3D jiffies + max_delay;
+
+	br_multicast_start_querier(br);
=20
 unlock:
 	spin_unlock_bh(&br->multicast_lock);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 3be89b3..2f7da41 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -267,6 +267,7 @@ struct net_bridge
 	unsigned long			multicast_query_interval;
 	unsigned long			multicast_query_response_interval;
 	unsigned long			multicast_startup_query_interval;
+	unsigned long			multicast_querier_delay_time;
=20
 	spinlock_t			multicast_lock;
 	struct net_bridge_mdb_htable __rcu *mdb;
@@ -501,6 +502,13 @@ static inline bool br_multicast_is_router(struct net=
_bridge *br)
 	       (br->multicast_router =3D=3D 1 &&
 		timer_pending(&br->multicast_router_timer));
 }
+
+static inline bool br_multicast_querier_exists(struct net_bridge *br)
+{
+	return time_is_before_jiffies(br->multicast_querier_delay_time) &&
+	       (br->multicast_querier ||
+		timer_pending(&br->multicast_querier_timer));
+}
 #else
 static inline int br_multicast_rcv(struct net_bridge *br,
 				   struct net_bridge_port *port,
@@ -557,6 +565,10 @@ static inline bool br_multicast_is_router(struct net=
_bridge *br)
 {
 	return 0;
 }
+static inline bool br_multicast_querier_exists(struct net_bridge *br)
+{
+	return false;
+}
 static inline void br_mdb_init(void)
 {
 }
--=20
1.7.10.4
