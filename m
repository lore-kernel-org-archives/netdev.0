From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/3] bridge: mdb: Separate br_mdb_entry->state from net_bridge_port_group->state
Date: Wed,  3 Feb 2016 09:57:05 +0100
Message-ID: <1454489826-1858-3-git-send-email-jiri@resnulli.us>
References: <1454489826-1858-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:32886 "EHLO
	mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755550AbcBCI5L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 03:57:11 -0500
Received: by mail-wm0-f43.google.com with SMTP id l66so152938687wml.0
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 00:57:10 -0800 (PST)
In-Reply-To: <1454489826-1858-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Change net_bridge_port_group 'state' member to 'flags' and define new set
of flags internal to the kernel.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/bridge/br_mdb.c       | 16 ++++++++++++----
 net/bridge/br_multicast.c | 16 ++++++++--------
 net/bridge/br_private.h   |  9 ++++++---
 3 files changed, 26 insertions(+), 15 deletions(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 30e105f..5312570 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -41,6 +41,14 @@ fail:
 	return -EMSGSIZE;
 }
 
+static void __mdb_entry_fill_flags(struct br_mdb_entry *e, unsigned char flags)
+{
+	e->state = flags & MDB_PG_FLAGS_PERMANENT;
+	e->flags = 0;
+	if (flags & MDB_PG_FLAGS_OFFLOAD)
+		e->flags |= MDB_FLAGS_OFFLOAD;
+}
+
 static int br_mdb_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
 			    struct net_device *dev)
 {
@@ -85,8 +93,8 @@ static int br_mdb_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
 					struct br_mdb_entry e;
 					memset(&e, 0, sizeof(e));
 					e.ifindex = port->dev->ifindex;
-					e.state = p->state;
 					e.vid = p->addr.vid;
+					__mdb_entry_fill_flags(&e, p->flags);
 					if (p->addr.proto == htons(ETH_P_IP))
 						e.addr.u.ip4 = p->addr.u.ip4;
 #if IS_ENABLED(CONFIG_IPV6)
@@ -254,7 +262,7 @@ errout:
 }
 
 void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
-		   struct br_ip *group, int type, u8 state)
+		   struct br_ip *group, int type, u8 flags)
 {
 	struct br_mdb_entry entry;
 
@@ -265,8 +273,8 @@ void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
 #if IS_ENABLED(CONFIG_IPV6)
 	entry.addr.u.ip6 = group->u.ip6;
 #endif
-	entry.state = state;
 	entry.vid = group->vid;
+	__mdb_entry_fill_flags(&entry, flags);
 	__br_mdb_notify(dev, &entry, type);
 }
 
@@ -568,7 +576,7 @@ static int __br_mdb_del(struct net_bridge *br, struct br_mdb_entry *entry)
 		if (p->port->state == BR_STATE_DISABLED)
 			goto unlock;
 
-		entry->state = p->state;
+		__mdb_entry_fill_flags(entry, p->flags);
 		rcu_assign_pointer(*pp, p->next);
 		hlist_del_init(&p->mglist);
 		del_timer(&p->timer);
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 03661d9..d156491 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -284,7 +284,7 @@ static void br_multicast_del_pg(struct net_bridge *br,
 		hlist_del_init(&p->mglist);
 		del_timer(&p->timer);
 		br_mdb_notify(br->dev, p->port, &pg->addr, RTM_DELMDB,
-			      p->state);
+			      p->flags);
 		call_rcu_bh(&p->rcu, br_multicast_free_pg);
 
 		if (!mp->ports && !mp->mglist &&
@@ -304,7 +304,7 @@ static void br_multicast_port_group_expired(unsigned long data)
 
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev) || timer_pending(&pg->timer) ||
-	    hlist_unhashed(&pg->mglist) || pg->state & MDB_PERMANENT)
+	    hlist_unhashed(&pg->mglist) || pg->flags & MDB_PG_FLAGS_PERMANENT)
 		goto out;
 
 	br_multicast_del_pg(br, pg);
@@ -649,7 +649,7 @@ struct net_bridge_port_group *br_multicast_new_port_group(
 			struct net_bridge_port *port,
 			struct br_ip *group,
 			struct net_bridge_port_group __rcu *next,
-			unsigned char state)
+			unsigned char flags)
 {
 	struct net_bridge_port_group *p;
 
@@ -659,7 +659,7 @@ struct net_bridge_port_group *br_multicast_new_port_group(
 
 	p->addr = *group;
 	p->port = port;
-	p->state = state;
+	p->flags = flags;
 	rcu_assign_pointer(p->next, next);
 	hlist_add_head(&p->mglist, &port->mglist);
 	setup_timer(&p->timer, br_multicast_port_group_expired,
@@ -702,11 +702,11 @@ static int br_multicast_add_group(struct net_bridge *br,
 			break;
 	}
 
-	p = br_multicast_new_port_group(port, group, *pp, MDB_TEMPORARY);
+	p = br_multicast_new_port_group(port, group, *pp, 0);
 	if (unlikely(!p))
 		goto err;
 	rcu_assign_pointer(*pp, p);
-	br_mdb_notify(br->dev, port, group, RTM_NEWMDB, MDB_TEMPORARY);
+	br_mdb_notify(br->dev, port, group, RTM_NEWMDB, 0);
 
 found:
 	mod_timer(&p->timer, now + br->multicast_membership_interval);
@@ -975,7 +975,7 @@ void br_multicast_disable_port(struct net_bridge_port *port)
 
 	spin_lock(&br->multicast_lock);
 	hlist_for_each_entry_safe(pg, n, &port->mglist, mglist)
-		if (pg->state == MDB_TEMPORARY)
+		if (!(pg->flags & MDB_PG_FLAGS_PERMANENT))
 			br_multicast_del_pg(br, pg);
 
 	if (!hlist_unhashed(&port->rlist)) {
@@ -1454,7 +1454,7 @@ br_multicast_leave_group(struct net_bridge *br,
 			del_timer(&p->timer);
 			call_rcu_bh(&p->rcu, br_multicast_free_pg);
 			br_mdb_notify(br->dev, port, group, RTM_DELMDB,
-				      p->state);
+				      p->flags);
 
 			if (!mp->ports && !mp->mglist &&
 			    netif_running(br->dev))
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 216018c..67f4dce 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -150,6 +150,9 @@ struct net_bridge_fdb_entry
 	struct rcu_head			rcu;
 };
 
+#define MDB_PG_FLAGS_PERMANENT	BIT(0)
+#define MDB_PG_FLAGS_OFFLOAD	BIT(1)
+
 struct net_bridge_port_group {
 	struct net_bridge_port		*port;
 	struct net_bridge_port_group __rcu *next;
@@ -157,7 +160,7 @@ struct net_bridge_port_group {
 	struct rcu_head			rcu;
 	struct timer_list		timer;
 	struct br_ip			addr;
-	unsigned char			state;
+	unsigned char			flags;
 };
 
 struct net_bridge_mdb_entry
@@ -554,11 +557,11 @@ void br_multicast_free_pg(struct rcu_head *head);
 struct net_bridge_port_group *
 br_multicast_new_port_group(struct net_bridge_port *port, struct br_ip *group,
 			    struct net_bridge_port_group __rcu *next,
-			    unsigned char state);
+			    unsigned char flags);
 void br_mdb_init(void);
 void br_mdb_uninit(void);
 void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
-		   struct br_ip *group, int type, u8 state);
+		   struct br_ip *group, int type, u8 flags);
 void br_rtr_notify(struct net_device *dev, struct net_bridge_port *port,
 		   int type);
 
-- 
1.9.3
