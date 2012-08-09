From: Cong Wang <amwang@redhat.com>
Subject: [PATCH 01/14] netpoll: use GFP_ATOMIC in slave_enable_netpoll() and __netpoll_setup()
Date: Thu,  9 Aug 2012 23:00:13 +0800
Message-ID: <1344524426-11588-2-git-send-email-amwang@redhat.com>
References: <1344524426-11588-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12203 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030517Ab2HIPAn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2012 11:00:43 -0400
In-Reply-To: <1344524426-11588-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

slave_enable_netpoll() and __netpoll_setup() may be called
with read_lock() held, so should use GFP_ATOMIC to allocate
memory. Eric suggested to pass gfp flags to __netpoll_setup().

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 drivers/net/bonding/bond_main.c |    6 +++---
 drivers/net/team/team.c         |   16 +++++++++-------
 include/linux/netdevice.h       |    3 ++-
 include/linux/netpoll.h         |    2 +-
 net/8021q/vlan_dev.c            |    7 ++++---
 net/bridge/br_device.c          |   12 ++++++------
 net/bridge/br_if.c              |    2 +-
 net/bridge/br_private.h         |    4 ++--
 net/core/netpoll.c              |    8 ++++----
 9 files changed, 32 insertions(+), 28 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6fae5f3..8697136 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1235,12 +1235,12 @@ static inline int slave_enable_netpoll(struct slave *slave)
 	struct netpoll *np;
 	int err = 0;
 
-	np = kzalloc(sizeof(*np), GFP_KERNEL);
+	np = kzalloc(sizeof(*np), GFP_ATOMIC);
 	err = -ENOMEM;
 	if (!np)
 		goto out;
 
-	err = __netpoll_setup(np, slave->dev);
+	err = __netpoll_setup(np, slave->dev, GFP_ATOMIC);
 	if (err) {
 		kfree(np);
 		goto out;
@@ -1292,7 +1292,7 @@ static void bond_netpoll_cleanup(struct net_device *bond_dev)
 	read_unlock(&bond->lock);
 }
 
-static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni)
+static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni, gfp_t gfp)
 {
 	struct bonding *bond = netdev_priv(dev);
 	struct slave *slave;
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index ba10c46..bbb8524 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -913,16 +913,17 @@ static void team_port_leave(struct team *team, struct team_port *port)
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-static int team_port_enable_netpoll(struct team *team, struct team_port *port)
+static int team_port_enable_netpoll(struct team *team, struct team_port *port,
+				    gfp_t gfp)
 {
 	struct netpoll *np;
 	int err;
 
-	np = kzalloc(sizeof(*np), GFP_KERNEL);
+	np = kzalloc(sizeof(*np), gfp);
 	if (!np)
 		return -ENOMEM;
 
-	err = __netpoll_setup(np, port->dev);
+	err = __netpoll_setup(np, port->dev, gfp);
 	if (err) {
 		kfree(np);
 		return err;
@@ -951,7 +952,8 @@ static struct netpoll_info *team_netpoll_info(struct team *team)
 }
 
 #else
-static int team_port_enable_netpoll(struct team *team, struct team_port *port)
+static int team_port_enable_netpoll(struct team *team, struct team_port *port,
+				    gfp_t gfp)
 {
 	return 0;
 }
@@ -1032,7 +1034,7 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 	}
 
 	if (team_netpoll_info(team)) {
-		err = team_port_enable_netpoll(team, port);
+		err = team_port_enable_netpoll(team, port, GFP_KERNEL);
 		if (err) {
 			netdev_err(dev, "Failed to enable netpoll on device %s\n",
 				   portname);
@@ -1627,7 +1629,7 @@ static void team_netpoll_cleanup(struct net_device *dev)
 }
 
 static int team_netpoll_setup(struct net_device *dev,
-			      struct netpoll_info *npifo)
+			      struct netpoll_info *npifo, gfp_t gfp)
 {
 	struct team *team = netdev_priv(dev);
 	struct team_port *port;
@@ -1635,7 +1637,7 @@ static int team_netpoll_setup(struct net_device *dev,
 
 	mutex_lock(&team->lock);
 	list_for_each_entry(port, &team->port_list, list) {
-		err = team_port_enable_netpoll(team, port);
+		err = team_port_enable_netpoll(team, port, gfp);
 		if (err) {
 			__team_netpoll_cleanup(team);
 			break;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a9db4f3..3560d68 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -953,7 +953,8 @@ struct net_device_ops {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	void                    (*ndo_poll_controller)(struct net_device *dev);
 	int			(*ndo_netpoll_setup)(struct net_device *dev,
-						     struct netpoll_info *info);
+						     struct netpoll_info *info,
+						     gfp_t gfp);
 	void			(*ndo_netpoll_cleanup)(struct net_device *dev);
 #endif
 	int			(*ndo_set_vf_mac)(struct net_device *dev,
diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 28f5389..bf2d51e 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -43,7 +43,7 @@ struct netpoll_info {
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
 void netpoll_print_options(struct netpoll *np);
 int netpoll_parse_options(struct netpoll *np, char *opt);
-int __netpoll_setup(struct netpoll *np, struct net_device *ndev);
+int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp);
 int netpoll_setup(struct netpoll *np);
 int netpoll_trap(void);
 void netpoll_set_trap(int trap);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 73a2a83..ee4ae09 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -669,19 +669,20 @@ static void vlan_dev_poll_controller(struct net_device *dev)
 	return;
 }
 
-static int vlan_dev_netpoll_setup(struct net_device *dev, struct netpoll_info *npinfo)
+static int vlan_dev_netpoll_setup(struct net_device *dev, struct netpoll_info *npinfo,
+				  gfp_t gfp)
 {
 	struct vlan_dev_priv *info = vlan_dev_priv(dev);
 	struct net_device *real_dev = info->real_dev;
 	struct netpoll *netpoll;
 	int err = 0;
 
-	netpoll = kzalloc(sizeof(*netpoll), GFP_KERNEL);
+	netpoll = kzalloc(sizeof(*netpoll), gfp);
 	err = -ENOMEM;
 	if (!netpoll)
 		goto out;
 
-	err = __netpoll_setup(netpoll, real_dev);
+	err = __netpoll_setup(netpoll, real_dev, gfp);
 	if (err) {
 		kfree(netpoll);
 		goto out;
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 3334845..ed0e0f9 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -213,7 +213,8 @@ static void br_netpoll_cleanup(struct net_device *dev)
 	}
 }
 
-static int br_netpoll_setup(struct net_device *dev, struct netpoll_info *ni)
+static int br_netpoll_setup(struct net_device *dev, struct netpoll_info *ni,
+			    gfp_t gfp)
 {
 	struct net_bridge *br = netdev_priv(dev);
 	struct net_bridge_port *p, *n;
@@ -222,8 +223,7 @@ static int br_netpoll_setup(struct net_device *dev, struct netpoll_info *ni)
 	list_for_each_entry_safe(p, n, &br->port_list, list) {
 		if (!p->dev)
 			continue;
-
-		err = br_netpoll_enable(p);
+		err = br_netpoll_enable(p, gfp);
 		if (err)
 			goto fail;
 	}
@@ -236,17 +236,17 @@ fail:
 	goto out;
 }
 
-int br_netpoll_enable(struct net_bridge_port *p)
+int br_netpoll_enable(struct net_bridge_port *p, gfp_t gfp)
 {
 	struct netpoll *np;
 	int err = 0;
 
-	np = kzalloc(sizeof(*p->np), GFP_KERNEL);
+	np = kzalloc(sizeof(*p->np), gfp);
 	err = -ENOMEM;
 	if (!np)
 		goto out;
 
-	err = __netpoll_setup(np, p->dev);
+	err = __netpoll_setup(np, p->dev, gfp);
 	if (err) {
 		kfree(np);
 		goto out;
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index e1144e1..171fd6b 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -361,7 +361,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (err)
 		goto err2;
 
-	if (br_netpoll_info(br) && ((err = br_netpoll_enable(p))))
+	if (br_netpoll_info(br) && ((err = br_netpoll_enable(p, GFP_KERNEL))))
 		goto err3;
 
 	err = netdev_set_master(dev, br->dev);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index a768b24..f507d2a 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -316,7 +316,7 @@ static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
 		netpoll_send_skb(np, skb);
 }
 
-extern int br_netpoll_enable(struct net_bridge_port *p);
+extern int br_netpoll_enable(struct net_bridge_port *p, gfp_t gfp);
 extern void br_netpoll_disable(struct net_bridge_port *p);
 #else
 static inline struct netpoll_info *br_netpoll_info(struct net_bridge *br)
@@ -329,7 +329,7 @@ static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
 {
 }
 
-static inline int br_netpoll_enable(struct net_bridge_port *p)
+static inline int br_netpoll_enable(struct net_bridge_port *p, gfp_t gfp)
 {
 	return 0;
 }
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index b4c90e4..37cc854 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -715,7 +715,7 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 }
 EXPORT_SYMBOL(netpoll_parse_options);
 
-int __netpoll_setup(struct netpoll *np, struct net_device *ndev)
+int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 {
 	struct netpoll_info *npinfo;
 	const struct net_device_ops *ops;
@@ -734,7 +734,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev)
 	}
 
 	if (!ndev->npinfo) {
-		npinfo = kmalloc(sizeof(*npinfo), GFP_KERNEL);
+		npinfo = kmalloc(sizeof(*npinfo), gfp);
 		if (!npinfo) {
 			err = -ENOMEM;
 			goto out;
@@ -752,7 +752,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev)
 
 		ops = np->dev->netdev_ops;
 		if (ops->ndo_netpoll_setup) {
-			err = ops->ndo_netpoll_setup(ndev, npinfo);
+			err = ops->ndo_netpoll_setup(ndev, npinfo, gfp);
 			if (err)
 				goto free_npinfo;
 		}
@@ -857,7 +857,7 @@ int netpoll_setup(struct netpoll *np)
 	refill_skbs();
 
 	rtnl_lock();
-	err = __netpoll_setup(np, ndev);
+	err = __netpoll_setup(np, ndev, GFP_KERNEL);
 	rtnl_unlock();
 
 	if (err)
-- 
1.7.7.6
