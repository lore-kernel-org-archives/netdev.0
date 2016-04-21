From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 3/3] bridge: mdb: Marking port-group as offloaded
Date: Thu, 21 Apr 2016 12:52:45 +0200
Message-ID: <1461235965-3930-4-git-send-email-jiri@resnulli.us>
References: <1461235965-3930-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35512 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828AbcDUKwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 06:52:53 -0400
Received: by mail-wm0-f47.google.com with SMTP id e201so82110916wme.0
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 03:52:51 -0700 (PDT)
In-Reply-To: <1461235965-3930-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

There is a race-condition when updating the mdb offload flag without using
the mulicast_lock. This reverts commit 9e8430f8d60d98 ("bridge: mdb:
Passing the port-group pointer to br_mdb module").

This patch marks offloaded MDB entry as "offload" by changing the port-
group flags and marks it as MDB_PG_FLAGS_OFFLOAD.

When switchdev PORT_MDB succeeded and adds a multicast group, a completion
callback is been invoked "br_mdb_complete". The completion function
locks the multicast_lock and finds the right net_bridge_port_group and
marks it as offloaded.

Fixes: 9e8430f8d60d98 ("bridge: mdb: Passing the port-group pointer to br_mdb module")
Reported-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Acked-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_mdb.c       | 91 +++++++++++++++++++++++++++++++++--------------
 net/bridge/br_multicast.c |  8 +++--
 net/bridge/br_private.h   |  4 +--
 3 files changed, 71 insertions(+), 32 deletions(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index b258120..7dbc80d 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -256,9 +256,45 @@ static inline size_t rtnl_mdb_nlmsg_size(void)
 		+ nla_total_size(sizeof(struct br_mdb_entry));
 }
 
-static void __br_mdb_notify(struct net_device *dev, struct br_mdb_entry *entry,
-			    int type, struct net_bridge_port_group *pg)
+struct br_mdb_complete_info {
+	struct net_bridge_port *port;
+	struct br_ip ip;
+};
+
+static void br_mdb_complete(struct net_device *dev, int err, void *priv)
 {
+	struct br_mdb_complete_info *data = priv;
+	struct net_bridge_port_group __rcu **pp;
+	struct net_bridge_port_group *p;
+	struct net_bridge_mdb_htable *mdb;
+	struct net_bridge_mdb_entry *mp;
+	struct net_bridge_port *port = data->port;
+	struct net_bridge *br = port->br;
+
+	if (err)
+		goto err;
+
+	spin_lock_bh(&br->multicast_lock);
+	mdb = mlock_dereference(br->mdb, br);
+	mp = br_mdb_ip_get(mdb, &data->ip);
+	if (!mp)
+		goto out;
+	for (pp = &mp->ports; (p = mlock_dereference(*pp, br)) != NULL;
+	     pp = &p->next) {
+		if (p->port != port)
+			continue;
+		p->flags |= MDB_PG_FLAGS_OFFLOAD;
+	}
+out:
+	spin_unlock_bh(&br->multicast_lock);
+err:
+	kfree(priv);
+}
+
+static void __br_mdb_notify(struct net_device *dev, struct net_bridge_port *p,
+			    struct br_mdb_entry *entry, int type)
+{
+	struct br_mdb_complete_info *complete_info;
 	struct switchdev_obj_port_mdb mdb = {
 		.obj = {
 			.id = SWITCHDEV_OBJ_ID_PORT_MDB,
@@ -281,9 +317,14 @@ static void __br_mdb_notify(struct net_device *dev, struct br_mdb_entry *entry,
 
 	mdb.obj.orig_dev = port_dev;
 	if (port_dev && type == RTM_NEWMDB) {
-		err = switchdev_port_obj_add(port_dev, &mdb.obj);
-		if (!err && pg)
-			pg->flags |= MDB_PG_FLAGS_OFFLOAD;
+		complete_info = kmalloc(sizeof(*complete_info), GFP_ATOMIC);
+		if (complete_info) {
+			complete_info->port = p;
+			__mdb_entry_to_br_ip(entry, &complete_info->ip);
+			mdb.obj.complete_priv = complete_info;
+			mdb.obj.complete = br_mdb_complete;
+			switchdev_port_obj_add(port_dev, &mdb.obj);
+		}
 	} else if (port_dev && type == RTM_DELMDB) {
 		switchdev_port_obj_del(port_dev, &mdb.obj);
 	}
@@ -304,21 +345,21 @@ errout:
 	rtnl_set_sk_err(net, RTNLGRP_MDB, err);
 }
 
-void br_mdb_notify(struct net_device *dev, struct net_bridge_port_group *pg,
-		   int type)
+void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
+		   struct br_ip *group, int type, u8 flags)
 {
 	struct br_mdb_entry entry;
 
 	memset(&entry, 0, sizeof(entry));
-	entry.ifindex = pg->port->dev->ifindex;
-	entry.addr.proto = pg->addr.proto;
-	entry.addr.u.ip4 = pg->addr.u.ip4;
+	entry.ifindex = port->dev->ifindex;
+	entry.addr.proto = group->proto;
+	entry.addr.u.ip4 = group->u.ip4;
 #if IS_ENABLED(CONFIG_IPV6)
-	entry.addr.u.ip6 = pg->addr.u.ip6;
+	entry.addr.u.ip6 = group->u.ip6;
 #endif
-	entry.vid = pg->addr.vid;
-	__mdb_entry_fill_flags(&entry, pg->flags);
-	__br_mdb_notify(dev, &entry, type, pg);
+	entry.vid = group->vid;
+	__mdb_entry_fill_flags(&entry, flags);
+	__br_mdb_notify(dev, port, &entry, type);
 }
 
 static int nlmsg_populate_rtr_fill(struct sk_buff *skb,
@@ -463,8 +504,7 @@ static int br_mdb_parse(struct sk_buff *skb, struct nlmsghdr *nlh,
 }
 
 static int br_mdb_add_group(struct net_bridge *br, struct net_bridge_port *port,
-			    struct br_ip *group, unsigned char state,
-			    struct net_bridge_port_group **pg)
+			    struct br_ip *group, unsigned char state)
 {
 	struct net_bridge_mdb_entry *mp;
 	struct net_bridge_port_group *p;
@@ -495,7 +535,6 @@ static int br_mdb_add_group(struct net_bridge *br, struct net_bridge_port *port,
 	if (unlikely(!p))
 		return -ENOMEM;
 	rcu_assign_pointer(*pp, p);
-	*pg = p;
 	if (state == MDB_TEMPORARY)
 		mod_timer(&p->timer, now + br->multicast_membership_interval);
 
@@ -503,8 +542,7 @@ static int br_mdb_add_group(struct net_bridge *br, struct net_bridge_port *port,
 }
 
 static int __br_mdb_add(struct net *net, struct net_bridge *br,
-			struct br_mdb_entry *entry,
-			struct net_bridge_port_group **pg)
+			struct br_mdb_entry *entry)
 {
 	struct br_ip ip;
 	struct net_device *dev;
@@ -525,7 +563,7 @@ static int __br_mdb_add(struct net *net, struct net_bridge *br,
 	__mdb_entry_to_br_ip(entry, &ip);
 
 	spin_lock_bh(&br->multicast_lock);
-	ret = br_mdb_add_group(br, p, &ip, entry->state, pg);
+	ret = br_mdb_add_group(br, p, &ip, entry->state);
 	spin_unlock_bh(&br->multicast_lock);
 	return ret;
 }
@@ -533,7 +571,6 @@ static int __br_mdb_add(struct net *net, struct net_bridge *br,
 static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
-	struct net_bridge_port_group *pg;
 	struct net_bridge_vlan_group *vg;
 	struct net_device *dev, *pdev;
 	struct br_mdb_entry *entry;
@@ -563,15 +600,15 @@ static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (br_vlan_enabled(br) && vg && entry->vid == 0) {
 		list_for_each_entry(v, &vg->vlan_list, vlist) {
 			entry->vid = v->vid;
-			err = __br_mdb_add(net, br, entry, &pg);
+			err = __br_mdb_add(net, br, entry);
 			if (err)
 				break;
-			__br_mdb_notify(dev, entry, RTM_NEWMDB, pg);
+			__br_mdb_notify(dev, p, entry, RTM_NEWMDB);
 		}
 	} else {
-		err = __br_mdb_add(net, br, entry, &pg);
+		err = __br_mdb_add(net, br, entry);
 		if (!err)
-			__br_mdb_notify(dev, entry, RTM_NEWMDB, pg);
+			__br_mdb_notify(dev, p, entry, RTM_NEWMDB);
 	}
 
 	return err;
@@ -659,12 +696,12 @@ static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
 			entry->vid = v->vid;
 			err = __br_mdb_del(br, entry);
 			if (!err)
-				__br_mdb_notify(dev, entry, RTM_DELMDB, NULL);
+				__br_mdb_notify(dev, p, entry, RTM_DELMDB);
 		}
 	} else {
 		err = __br_mdb_del(br, entry);
 		if (!err)
-			__br_mdb_notify(dev, entry, RTM_DELMDB, NULL);
+			__br_mdb_notify(dev, p, entry, RTM_DELMDB);
 	}
 
 	return err;
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index a4c15df..191ea66 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -283,7 +283,8 @@ static void br_multicast_del_pg(struct net_bridge *br,
 		rcu_assign_pointer(*pp, p->next);
 		hlist_del_init(&p->mglist);
 		del_timer(&p->timer);
-		br_mdb_notify(br->dev, p, RTM_DELMDB);
+		br_mdb_notify(br->dev, p->port, &pg->addr, RTM_DELMDB,
+			      p->flags);
 		call_rcu_bh(&p->rcu, br_multicast_free_pg);
 
 		if (!mp->ports && !mp->mglist &&
@@ -705,7 +706,7 @@ static int br_multicast_add_group(struct net_bridge *br,
 	if (unlikely(!p))
 		goto err;
 	rcu_assign_pointer(*pp, p);
-	br_mdb_notify(br->dev, p, RTM_NEWMDB);
+	br_mdb_notify(br->dev, port, group, RTM_NEWMDB, 0);
 
 found:
 	mod_timer(&p->timer, now + br->multicast_membership_interval);
@@ -1461,7 +1462,8 @@ br_multicast_leave_group(struct net_bridge *br,
 			hlist_del_init(&p->mglist);
 			del_timer(&p->timer);
 			call_rcu_bh(&p->rcu, br_multicast_free_pg);
-			br_mdb_notify(br->dev, p, RTM_DELMDB);
+			br_mdb_notify(br->dev, port, group, RTM_DELMDB,
+				      p->flags);
 
 			if (!mp->ports && !mp->mglist &&
 			    netif_running(br->dev))
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 1b5d145..d9da857 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -560,8 +560,8 @@ br_multicast_new_port_group(struct net_bridge_port *port, struct br_ip *group,
 			    unsigned char flags);
 void br_mdb_init(void);
 void br_mdb_uninit(void);
-void br_mdb_notify(struct net_device *dev, struct net_bridge_port_group *pg,
-		   int type);
+void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
+		   struct br_ip *group, int type, u8 flags);
 void br_rtr_notify(struct net_device *dev, struct net_bridge_port *port,
 		   int type);
 
-- 
2.5.5
