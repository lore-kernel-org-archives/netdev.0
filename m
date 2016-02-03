From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/3] bridge: mdb: Passing the port-group pointer to br_mdb module
Date: Wed,  3 Feb 2016 09:57:06 +0100
Message-ID: <1454489826-1858-4-git-send-email-jiri@resnulli.us>
References: <1454489826-1858-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org, nikolay@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:38869 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755800AbcBCI5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 03:57:12 -0500
Received: by mail-wm0-f45.google.com with SMTP id p63so59426553wmp.1
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 00:57:11 -0800 (PST)
In-Reply-To: <1454489826-1858-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Passing the port-group to br_mdb in order to allow direct access to the
structure. br_mdb will later use the structure to reflect HW reflection
status via "state" variable.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/bridge/br_mdb.c       | 51 +++++++++++++++++++++++++++--------------------
 net/bridge/br_multicast.c |  8 +++-----
 net/bridge/br_private.h   |  4 ++--
 3 files changed, 34 insertions(+), 29 deletions(-)

diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 5312570..ac089286 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -217,7 +217,7 @@ static inline size_t rtnl_mdb_nlmsg_size(void)
 }
 
 static void __br_mdb_notify(struct net_device *dev, struct br_mdb_entry *entry,
-			    int type)
+			    int type, struct net_bridge_port_group *pg)
 {
 	struct switchdev_obj_port_mdb mdb = {
 		.obj = {
@@ -240,10 +240,13 @@ static void __br_mdb_notify(struct net_device *dev, struct br_mdb_entry *entry,
 #endif
 
 	mdb.obj.orig_dev = port_dev;
-	if (port_dev && type == RTM_NEWMDB)
-		switchdev_port_obj_add(port_dev, &mdb.obj);
-	else if (port_dev && type == RTM_DELMDB)
+	if (port_dev && type == RTM_NEWMDB) {
+		err = switchdev_port_obj_add(port_dev, &mdb.obj);
+		if (!err && pg)
+			pg->flags |= MDB_PG_FLAGS_OFFLOAD;
+	} else if (port_dev && type == RTM_DELMDB) {
 		switchdev_port_obj_del(port_dev, &mdb.obj);
+	}
 
 	skb = nlmsg_new(rtnl_mdb_nlmsg_size(), GFP_ATOMIC);
 	if (!skb)
@@ -261,21 +264,21 @@ errout:
 	rtnl_set_sk_err(net, RTNLGRP_MDB, err);
 }
 
-void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
-		   struct br_ip *group, int type, u8 flags)
+void br_mdb_notify(struct net_device *dev, struct net_bridge_port_group *pg,
+		   int type)
 {
 	struct br_mdb_entry entry;
 
 	memset(&entry, 0, sizeof(entry));
-	entry.ifindex = port->dev->ifindex;
-	entry.addr.proto = group->proto;
-	entry.addr.u.ip4 = group->u.ip4;
+	entry.ifindex = pg->port->dev->ifindex;
+	entry.addr.proto = pg->addr.proto;
+	entry.addr.u.ip4 = pg->addr.u.ip4;
 #if IS_ENABLED(CONFIG_IPV6)
-	entry.addr.u.ip6 = group->u.ip6;
+	entry.addr.u.ip6 = pg->addr.u.ip6;
 #endif
-	entry.vid = group->vid;
-	__mdb_entry_fill_flags(&entry, flags);
-	__br_mdb_notify(dev, &entry, type);
+	entry.vid = pg->addr.vid;
+	__mdb_entry_fill_flags(&entry, pg->flags);
+	__br_mdb_notify(dev, &entry, type, pg);
 }
 
 static int nlmsg_populate_rtr_fill(struct sk_buff *skb,
@@ -420,7 +423,8 @@ static int br_mdb_parse(struct sk_buff *skb, struct nlmsghdr *nlh,
 }
 
 static int br_mdb_add_group(struct net_bridge *br, struct net_bridge_port *port,
-			    struct br_ip *group, unsigned char state)
+			    struct br_ip *group, unsigned char state,
+			    struct net_bridge_port_group **pg)
 {
 	struct net_bridge_mdb_entry *mp;
 	struct net_bridge_port_group *p;
@@ -451,6 +455,7 @@ static int br_mdb_add_group(struct net_bridge *br, struct net_bridge_port *port,
 	if (unlikely(!p))
 		return -ENOMEM;
 	rcu_assign_pointer(*pp, p);
+	*pg = p;
 	if (state == MDB_TEMPORARY)
 		mod_timer(&p->timer, now + br->multicast_membership_interval);
 
@@ -458,7 +463,8 @@ static int br_mdb_add_group(struct net_bridge *br, struct net_bridge_port *port,
 }
 
 static int __br_mdb_add(struct net *net, struct net_bridge *br,
-			struct br_mdb_entry *entry)
+			struct br_mdb_entry *entry,
+			struct net_bridge_port_group **pg)
 {
 	struct br_ip ip;
 	struct net_device *dev;
@@ -487,7 +493,7 @@ static int __br_mdb_add(struct net *net, struct net_bridge *br,
 #endif
 
 	spin_lock_bh(&br->multicast_lock);
-	ret = br_mdb_add_group(br, p, &ip, entry->state);
+	ret = br_mdb_add_group(br, p, &ip, entry->state, pg);
 	spin_unlock_bh(&br->multicast_lock);
 	return ret;
 }
@@ -495,6 +501,7 @@ static int __br_mdb_add(struct net *net, struct net_bridge *br,
 static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
+	struct net_bridge_port_group *pg;
 	struct net_bridge_vlan_group *vg;
 	struct net_device *dev, *pdev;
 	struct br_mdb_entry *entry;
@@ -524,15 +531,15 @@ static int br_mdb_add(struct sk_buff *skb, struct nlmsghdr *nlh)
 	if (br_vlan_enabled(br) && vg && entry->vid == 0) {
 		list_for_each_entry(v, &vg->vlan_list, vlist) {
 			entry->vid = v->vid;
-			err = __br_mdb_add(net, br, entry);
+			err = __br_mdb_add(net, br, entry, &pg);
 			if (err)
 				break;
-			__br_mdb_notify(dev, entry, RTM_NEWMDB);
+			__br_mdb_notify(dev, entry, RTM_NEWMDB, pg);
 		}
 	} else {
-		err = __br_mdb_add(net, br, entry);
+		err = __br_mdb_add(net, br, entry, &pg);
 		if (!err)
-			__br_mdb_notify(dev, entry, RTM_NEWMDB);
+			__br_mdb_notify(dev, entry, RTM_NEWMDB, pg);
 	}
 
 	return err;
@@ -628,12 +635,12 @@ static int br_mdb_del(struct sk_buff *skb, struct nlmsghdr *nlh)
 			entry->vid = v->vid;
 			err = __br_mdb_del(br, entry);
 			if (!err)
-				__br_mdb_notify(dev, entry, RTM_DELMDB);
+				__br_mdb_notify(dev, entry, RTM_DELMDB, NULL);
 		}
 	} else {
 		err = __br_mdb_del(br, entry);
 		if (!err)
-			__br_mdb_notify(dev, entry, RTM_DELMDB);
+			__br_mdb_notify(dev, entry, RTM_DELMDB, NULL);
 	}
 
 	return err;
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index d156491..8b6e424 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -283,8 +283,7 @@ static void br_multicast_del_pg(struct net_bridge *br,
 		rcu_assign_pointer(*pp, p->next);
 		hlist_del_init(&p->mglist);
 		del_timer(&p->timer);
-		br_mdb_notify(br->dev, p->port, &pg->addr, RTM_DELMDB,
-			      p->flags);
+		br_mdb_notify(br->dev, p, RTM_DELMDB);
 		call_rcu_bh(&p->rcu, br_multicast_free_pg);
 
 		if (!mp->ports && !mp->mglist &&
@@ -706,7 +705,7 @@ static int br_multicast_add_group(struct net_bridge *br,
 	if (unlikely(!p))
 		goto err;
 	rcu_assign_pointer(*pp, p);
-	br_mdb_notify(br->dev, port, group, RTM_NEWMDB, 0);
+	br_mdb_notify(br->dev, p, RTM_NEWMDB);
 
 found:
 	mod_timer(&p->timer, now + br->multicast_membership_interval);
@@ -1453,8 +1452,7 @@ br_multicast_leave_group(struct net_bridge *br,
 			hlist_del_init(&p->mglist);
 			del_timer(&p->timer);
 			call_rcu_bh(&p->rcu, br_multicast_free_pg);
-			br_mdb_notify(br->dev, port, group, RTM_DELMDB,
-				      p->flags);
+			br_mdb_notify(br->dev, p, RTM_DELMDB);
 
 			if (!mp->ports && !mp->mglist &&
 			    netif_running(br->dev))
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 67f4dce..302ab0a 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -560,8 +560,8 @@ br_multicast_new_port_group(struct net_bridge_port *port, struct br_ip *group,
 			    unsigned char flags);
 void br_mdb_init(void);
 void br_mdb_uninit(void);
-void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
-		   struct br_ip *group, int type, u8 flags);
+void br_mdb_notify(struct net_device *dev, struct net_bridge_port_group *pg,
+		   int type);
 void br_rtr_notify(struct net_device *dev, struct net_bridge_port *port,
 		   int type);
 
-- 
1.9.3
