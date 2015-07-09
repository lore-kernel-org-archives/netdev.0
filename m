From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next] bridge: mdb: fill state in br_mdb_notify
Date: Thu,  9 Jul 2015 03:11:10 -0700
Message-ID: <1436436670-28859-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	bridge@lists.linux-foundation.org, davem@davemloft.net
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

Fill also the port group state when sending notifications.

Signed-off-by: Satish Ashok <sashok@cumulusnetworks.com>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
Note: I know that I didn't need to move the notification before the
      call_rcu_bh call since we're running with bh-disabled but I did
      it for consistency.

 net/bridge/br_mdb.c       | 5 +++--
 net/bridge/br_multicast.c | 5 +++--
 net/bridge/br_private.h   | 2 +-
 3 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index e29ad70b3000..1fb7d076f15c 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -230,7 +230,7 @@ errout:
 }
 
 void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
-		   struct br_ip *group, int type)
+		   struct br_ip *group, int type, u8 state)
 {
 	struct br_mdb_entry entry;
 
@@ -241,6 +241,7 @@ void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
 #if IS_ENABLED(CONFIG_IPV6)
 	entry.addr.u.ip6 = group->u.ip6;
 #endif
+	entry.state = state;
 	__br_mdb_notify(dev, &entry, type);
 }
 
@@ -348,7 +349,7 @@ static int br_mdb_add_group(struct net_bridge *br, struct net_bridge_port *port,
 		return -ENOMEM;
 	rcu_assign_pointer(*pp, p);
 
-	br_mdb_notify(br->dev, port, group, RTM_NEWMDB);
+	br_mdb_notify(br->dev, port, group, RTM_NEWMDB, state);
 	return 0;
 }
 
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 742a6c27d7a2..5a44cd9473f2 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -694,7 +694,7 @@ static int br_multicast_add_group(struct net_bridge *br,
 	if (unlikely(!p))
 		goto err;
 	rcu_assign_pointer(*pp, p);
-	br_mdb_notify(br->dev, port, group, RTM_NEWMDB);
+	br_mdb_notify(br->dev, port, group, RTM_NEWMDB, MDB_TEMPORARY);
 
 found:
 	mod_timer(&p->timer, now + br->multicast_membership_interval);
@@ -1439,8 +1439,9 @@ br_multicast_leave_group(struct net_bridge *br,
 			rcu_assign_pointer(*pp, p->next);
 			hlist_del_init(&p->mglist);
 			del_timer(&p->timer);
+			br_mdb_notify(br->dev, port, group, RTM_DELMDB,
+				      p->state);
 			call_rcu_bh(&p->rcu, br_multicast_free_pg);
-			br_mdb_notify(br->dev, port, group, RTM_DELMDB);
 
 			if (!mp->ports && !mp->mglist &&
 			    netif_running(br->dev))
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 8b21146b24a0..c73fd785654d 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -488,7 +488,7 @@ br_multicast_new_port_group(struct net_bridge_port *port, struct br_ip *group,
 void br_mdb_init(void);
 void br_mdb_uninit(void);
 void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
-		   struct br_ip *group, int type);
+		   struct br_ip *group, int type, u8 state);
 
 #define mlock_dereference(X, br) \
 	rcu_dereference_protected(X, lockdep_is_held(&br->multicast_lock))
-- 
1.9.1
