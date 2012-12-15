From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 2/2] bridge: add flags to distinguish permanent mdb entires
Date: Sat, 15 Dec 2012 16:09:51 +0800
Message-ID: <1355558992-32285-2-git-send-email-amwang@redhat.com>
References: <1355558992-32285-1-git-send-email-amwang@redhat.com>
Cc: bridge@lists.linux-foundation.org, Cong Wang <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60330 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753645Ab2LOIjT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Dec 2012 03:39:19 -0500
In-Reply-To: <1355558992-32285-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a flag to each mdb entry, so that we can distinguish
permanent entries with temporary entries.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/uapi/linux/if_bridge.h |    3 +++
 net/bridge/br_mdb.c            |    9 ++++++---
 net/bridge/br_multicast.c      |    8 +++++---
 net/bridge/br_private.h        |    4 +++-
 4 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/include/uapi/linux/if_bridge.h b/include/uapi/linux/if_bridge.h
index afbb18a..5db2975 100644
--- a/include/uapi/linux/if_bridge.h
+++ b/include/uapi/linux/if_bridge.h
@@ -163,6 +163,9 @@ struct br_port_msg {
 
 struct br_mdb_entry {
 	__u32 ifindex;
+#define MDB_TEMPORARY 0
+#define MDB_PERMANENT 1
+	__u8 state;
 	struct {
 		union {
 			__be32	ip4;
diff --git a/net/bridge/br_mdb.c b/net/bridge/br_mdb.c
index 6f0a2ee..9cf5d2b 100644
--- a/net/bridge/br_mdb.c
+++ b/net/bridge/br_mdb.c
@@ -83,6 +83,7 @@ static int br_mdb_fill_info(struct sk_buff *skb, struct netlink_callback *cb,
 				if (port) {
 					struct br_mdb_entry e;
 					e.ifindex = port->dev->ifindex;
+					e.state = p->state;
 					e.addr.u.ip4 = p->addr.u.ip4;
 #if IS_ENABLED(CONFIG_IPV6)
 					e.addr.u.ip6 = p->addr.u.ip6;
@@ -253,6 +254,8 @@ static bool is_valid_mdb_entry(struct br_mdb_entry *entry)
 #endif
 	} else
 		return false;
+	if (entry->state != MDB_PERMANENT && entry->state != MDB_TEMPORARY)
+		return false;
 
 	return true;
 }
@@ -310,7 +313,7 @@ static int br_mdb_parse(struct sk_buff *skb, struct nlmsghdr *nlh,
 }
 
 static int br_mdb_add_group(struct net_bridge *br, struct net_bridge_port *port,
-			    struct br_ip *group)
+			    struct br_ip *group, unsigned char state)
 {
 	struct net_bridge_mdb_entry *mp;
 	struct net_bridge_port_group *p;
@@ -336,7 +339,7 @@ static int br_mdb_add_group(struct net_bridge *br, struct net_bridge_port *port,
 			break;
 	}
 
-	p = br_multicast_new_port_group(port, group, *pp);
+	p = br_multicast_new_port_group(port, group, *pp, state);
 	if (unlikely(!p))
 		return -ENOMEM;
 	rcu_assign_pointer(*pp, p);
@@ -373,7 +376,7 @@ static int __br_mdb_add(struct net *net, struct net_bridge *br,
 #endif
 
 	spin_lock_bh(&br->multicast_lock);
-	ret = br_mdb_add_group(br, p, &ip);
+	ret = br_mdb_add_group(br, p, &ip, entry->state);
 	spin_unlock_bh(&br->multicast_lock);
 	return ret;
 }
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 2561af9..dce9def 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -279,7 +279,7 @@ static void br_multicast_port_group_expired(unsigned long data)
 
 	spin_lock(&br->multicast_lock);
 	if (!netif_running(br->dev) || timer_pending(&pg->timer) ||
-	    hlist_unhashed(&pg->mglist))
+	    hlist_unhashed(&pg->mglist) || pg->state & MDB_PERMANENT)
 		goto out;
 
 	br_multicast_del_pg(br, pg);
@@ -622,7 +622,8 @@ out:
 struct net_bridge_port_group *br_multicast_new_port_group(
 			struct net_bridge_port *port,
 			struct br_ip *group,
-			struct net_bridge_port_group __rcu *next)
+			struct net_bridge_port_group __rcu *next,
+			unsigned char state)
 {
 	struct net_bridge_port_group *p;
 
@@ -632,6 +633,7 @@ struct net_bridge_port_group *br_multicast_new_port_group(
 
 	p->addr = *group;
 	p->port = port;
+	p->state = state;
 	rcu_assign_pointer(p->next, next);
 	hlist_add_head(&p->mglist, &port->mglist);
 	setup_timer(&p->timer, br_multicast_port_group_expired,
@@ -674,7 +676,7 @@ static int br_multicast_add_group(struct net_bridge *br,
 			break;
 	}
 
-	p = br_multicast_new_port_group(port, group, *pp);
+	p = br_multicast_new_port_group(port, group, *pp, MDB_TEMPORARY);
 	if (unlikely(!p))
 		goto err;
 	rcu_assign_pointer(*pp, p);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index f21a739..49b85af4 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -83,6 +83,7 @@ struct net_bridge_port_group {
 	struct rcu_head			rcu;
 	struct timer_list		timer;
 	struct br_ip			addr;
+	unsigned char			state;
 };
 
 struct net_bridge_mdb_entry
@@ -443,7 +444,8 @@ extern void br_multicast_free_pg(struct rcu_head *head);
 extern struct net_bridge_port_group *br_multicast_new_port_group(
 				struct net_bridge_port *port,
 				struct br_ip *group,
-				struct net_bridge_port_group *next);
+				struct net_bridge_port_group *next,
+				unsigned char state);
 extern void br_mdb_init(void);
 extern void br_mdb_notify(struct net_device *dev, struct net_bridge_port *port,
 			  struct br_ip *group, int type);
-- 
1.7.7.6
