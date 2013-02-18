From: Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v5] netpoll: fix some sparse warnings in various places
Date: Mon, 18 Feb 2013 11:22:29 +0800
Message-ID: <1361157749-9367-1-git-send-email-amwang@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:65395 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755212Ab3BRDWv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Feb 2013 22:22:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

This fixes sparse warnings like the one below:

drivers/net/team/team.c:953:25: warning: incorrect type in return expression (different address spaces)
drivers/net/team/team.c:953:25:    expected struct netpoll_info *
drivers/net/team/team.c:953:25:    got struct netpoll_info [noderef] <asn:4>*npinfo

and make these functions return bool as suggested by Jiri.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: Vlad Yasevich <vyasevic@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 94c1534..2263bf2 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1300,9 +1300,9 @@ static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni, g
 	return err;
 }
 
-static struct netpoll_info *bond_netpoll_info(struct bonding *bond)
+static bool bond_netpoll_info(struct bonding *bond)
 {
-	return bond->dev->npinfo;
+	return rcu_access_pointer(bond->dev->npinfo) != NULL;
 }
 
 #else
@@ -1862,8 +1862,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	bond_set_carrier(bond);
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	slave_dev->npinfo = bond_netpoll_info(bond);
-	if (slave_dev->npinfo) {
+	rcu_assign_pointer(slave_dev->npinfo, bond->dev->npinfo);
+	if (bond_netpoll_info(bond)) {
 		if (slave_enable_netpoll(new_slave)) {
 			read_unlock(&bond->lock);
 			pr_info("Error, %s: master_dev is using netpoll, "
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 05c5efe..26abee3 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -948,9 +948,9 @@ static void team_port_disable_netpoll(struct team_port *port)
 	kfree(np);
 }
 
-static struct netpoll_info *team_netpoll_info(struct team *team)
+static bool team_netpoll_info(struct team *team)
 {
-	return team->dev->npinfo;
+	return rcu_access_pointer(team->dev->npinfo) != NULL;
 }
 
 #else
@@ -962,9 +962,9 @@ static int team_port_enable_netpoll(struct team *team, struct team_port *port,
 static void team_port_disable_netpoll(struct team_port *port)
 {
 }
-static struct netpoll_info *team_netpoll_info(struct team *team)
+static bool team_netpoll_info(struct team *team)
 {
-	return NULL;
+	return false;
 }
 #endif
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 6d314c4..f69cdda 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -328,9 +328,9 @@ extern void br_dev_delete(struct net_device *dev, struct list_head *list);
 extern netdev_tx_t br_dev_xmit(struct sk_buff *skb,
 			       struct net_device *dev);
 #ifdef CONFIG_NET_POLL_CONTROLLER
-static inline struct netpoll_info *br_netpoll_info(struct net_bridge *br)
+static inline bool br_netpoll_info(struct net_bridge *br)
 {
-	return br->dev->npinfo;
+	return rcu_access_pointer(br->dev->npinfo) != NULL;
 }
 
 static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
@@ -345,9 +345,9 @@ static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
 extern int br_netpoll_enable(struct net_bridge_port *p, gfp_t gfp);
 extern void br_netpoll_disable(struct net_bridge_port *p);
 #else
-static inline struct netpoll_info *br_netpoll_info(struct net_bridge *br)
+static inline bool br_netpoll_info(struct net_bridge *br)
 {
-	return NULL;
+	return false;
 }
 
 static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
