From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net] bridge: mcast: give fast leave precedence over
	multicast router and querier
Date: Tue, 28 Jul 2015 03:28:27 -0700
Message-ID: <1438079308-25040-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: bridge@lists.linux-foundation.org, herbert@gondor.apana.org.au,
	davem@davemloft.net
To: netdev@vger.kernel.org
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

From: Satish Ashok <sashok@cumulusnetworks.com>

When fast leave is configured on a bridge port and an IGMP leave is
received for a group, the group is not deleted immediately if there is
a router detected or if multicast querier is configured.
Ideally the group should be deleted immediately when fast leave is
configured.

Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
---
 net/bridge/br_multicast.c | 50 ++++++++++++++++++++++++-----------------------
 1 file changed, 26 insertions(+), 24 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 79db489cdade..0b39dcc65b94 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1416,8 +1416,7 @@ br_multicast_leave_group(struct net_bridge *br,
 
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev) ||
-	    (port && port->state == BR_STATE_DISABLED) ||
-	    timer_pending(&other_query->timer))
+	    (port && port->state == BR_STATE_DISABLED))
 		goto out;
 
 	mdb = mlock_dereference(br->mdb, br);
@@ -1425,6 +1424,31 @@ br_multicast_leave_group(struct net_bridge *br,
 	if (!mp)
 		goto out;
 
+	if (port && (port->flags & BR_MULTICAST_FAST_LEAVE)) {
+		struct net_bridge_port_group __rcu **pp;
+
+		for (pp = &mp->ports;
+		     (p = mlock_dereference(*pp, br)) != NULL;
+		     pp = &p->next) {
+			if (p->port != port)
+				continue;
+
+			rcu_assign_pointer(*pp, p->next);
+			hlist_del_init(&p->mglist);
+			del_timer(&p->timer);
+			call_rcu_bh(&p->rcu, br_multicast_free_pg);
+			br_mdb_notify(br->dev, port, group, RTM_DELMDB);
+
+			if (!mp->ports && !mp->mglist &&
+			    netif_running(br->dev))
+				mod_timer(&mp->timer, jiffies);
+		}
+		goto out;
+	}
+
+	if (timer_pending(&other_query->timer))
+		goto out;
+
 	if (br->multicast_querier) {
 		__br_multicast_send_query(br, port, &mp->addr);
 
@@ -1450,28 +1474,6 @@ br_multicast_leave_group(struct net_bridge *br,
 		}
 	}
 
-	if (port && (port->flags & BR_MULTICAST_FAST_LEAVE)) {
-		struct net_bridge_port_group __rcu **pp;
-
-		for (pp = &mp->ports;
-		     (p = mlock_dereference(*pp, br)) != NULL;
-		     pp = &p->next) {
-			if (p->port != port)
-				continue;
-
-			rcu_assign_pointer(*pp, p->next);
-			hlist_del_init(&p->mglist);
-			del_timer(&p->timer);
-			call_rcu_bh(&p->rcu, br_multicast_free_pg);
-			br_mdb_notify(br->dev, port, group, RTM_DELMDB);
-
-			if (!mp->ports && !mp->mglist &&
-			    netif_running(br->dev))
-				mod_timer(&mp->timer, jiffies);
-		}
-		goto out;
-	}
-
 	now = jiffies;
 	time = now + br->multicast_last_member_count *
 		     br->multicast_last_member_interval;
-- 
2.4.3
