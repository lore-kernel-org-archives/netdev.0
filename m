From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 1/6] netpoll: Remove gfp parameter from __netpoll_setup
Date: Mon, 17 Mar 2014 23:24:28 -0700
Message-ID: <87d2hkgh2b.fsf_-_@xmission.com>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
	<20140317.154916.2276987764507311378.davem@davemloft.net>
	<87iorcgh5d.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:47778 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751534AbaCRGYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 02:24:35 -0400
In-Reply-To: <87iorcgh5d.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Mon, 17 Mar 2014 23:22:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The gfp parameter was added in:
commit 47be03a28cc6c80e3aa2b3e8ed6d960ff0c5c0af
Author: Amerigo Wang <amwang@redhat.com>
Date:   Fri Aug 10 01:24:37 2012 +0000

    netpoll: use GFP_ATOMIC in slave_enable_netpoll() and __netpoll_setup()

    slave_enable_netpoll() and __netpoll_setup() may be called
    with read_lock() held, so should use GFP_ATOMIC to allocate
    memory. Eric suggested to pass gfp flags to __netpoll_setup().

    Cc: Eric Dumazet <eric.dumazet@gmail.com>
    Cc: "David S. Miller" <davem@davemloft.net>
    Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: Cong Wang <amwang@redhat.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

The reason for the gfp parameter was removed in:
commit c4cdef9b7183159c23c7302aaf270d64c549f557
Author: dingtianhong <dingtianhong@huawei.com>
Date:   Tue Jul 23 15:25:27 2013 +0800

    bonding: don't call slave_xxx_netpoll under spinlocks

    The slave_xxx_netpoll will call synchronize_rcu_bh(),
    so the function may schedule and sleep, it should't be
    called under spinlocks.

    bond_netpoll_setup() and bond_netpoll_cleanup() are always
    protected by rtnl lock, it is no need to take the read lock,
    as the slave list couldn't be changed outside rtnl lock.

    Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
    Cc: Jay Vosburgh <fubar@us.ibm.com>
    Cc: Andy Gospodarek <andy@greyhouse.net>
    Signed-off-by: David S. Miller <davem@davemloft.net>

Nothing else that calls __netpoll_setup or ndo_netpoll_setup
requires a gfp paramter, so remove the gfp parameter from both
of these functions making the code clearer.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/bonding/bond_main.c |    6 +++---
 drivers/net/team/team.c         |   16 +++++++---------
 include/linux/netdevice.h       |    3 +--
 include/linux/netpoll.h         |    2 +-
 net/8021q/vlan_dev.c            |    7 +++----
 net/bridge/br_device.c          |   15 +++++++--------
 net/bridge/br_if.c              |    2 +-
 net/bridge/br_private.h         |    4 ++--
 net/core/netpoll.c              |    8 ++++----
 9 files changed, 29 insertions(+), 34 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e717db301d46..76581971cf5f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -922,12 +922,12 @@ static inline int slave_enable_netpoll(struct slave *slave)
 	struct netpoll *np;
 	int err = 0;
 
-	np = kzalloc(sizeof(*np), GFP_ATOMIC);
+	np = kzalloc(sizeof(*np), GFP_KERNEL);
 	err = -ENOMEM;
 	if (!np)
 		goto out;
 
-	err = __netpoll_setup(np, slave->dev, GFP_ATOMIC);
+	err = __netpoll_setup(np, slave->dev);
 	if (err) {
 		kfree(np);
 		goto out;
@@ -962,7 +962,7 @@ static void bond_netpoll_cleanup(struct net_device *bond_dev)
 			slave_disable_netpoll(slave);
 }
 
-static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni, gfp_t gfp)
+static int bond_netpoll_setup(struct net_device *dev, struct netpoll_info *ni)
 {
 	struct bonding *bond = netdev_priv(dev);
 	struct list_head *iter;
diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index 2b1a1d61072c..33008c1d1d67 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -1031,8 +1031,7 @@ static void team_port_leave(struct team *team, struct team_port *port)
 }
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-static int team_port_enable_netpoll(struct team *team, struct team_port *port,
-				    gfp_t gfp)
+static int team_port_enable_netpoll(struct team *team, struct team_port *port)
 {
 	struct netpoll *np;
 	int err;
@@ -1040,11 +1039,11 @@ static int team_port_enable_netpoll(struct team *team, struct team_port *port,
 	if (!team->dev->npinfo)
 		return 0;
 
-	np = kzalloc(sizeof(*np), gfp);
+	np = kzalloc(sizeof(*np), GFP_KERNEL);
 	if (!np)
 		return -ENOMEM;
 
-	err = __netpoll_setup(np, port->dev, gfp);
+	err = __netpoll_setup(np, port->dev);
 	if (err) {
 		kfree(np);
 		return err;
@@ -1067,8 +1066,7 @@ static void team_port_disable_netpoll(struct team_port *port)
 	kfree(np);
 }
 #else
-static int team_port_enable_netpoll(struct team *team, struct team_port *port,
-				    gfp_t gfp)
+static int team_port_enable_netpoll(struct team *team, struct team_port *port)
 {
 	return 0;
 }
@@ -1156,7 +1154,7 @@ static int team_port_add(struct team *team, struct net_device *port_dev)
 		goto err_vids_add;
 	}
 
-	err = team_port_enable_netpoll(team, port, GFP_KERNEL);
+	err = team_port_enable_netpoll(team, port);
 	if (err) {
 		netdev_err(dev, "Failed to enable netpoll on device %s\n",
 			   portname);
@@ -1850,7 +1848,7 @@ static void team_netpoll_cleanup(struct net_device *dev)
 }
 
 static int team_netpoll_setup(struct net_device *dev,
-			      struct netpoll_info *npifo, gfp_t gfp)
+			      struct netpoll_info *npifo)
 {
 	struct team *team = netdev_priv(dev);
 	struct team_port *port;
@@ -1858,7 +1856,7 @@ static int team_netpoll_setup(struct net_device *dev,
 
 	mutex_lock(&team->lock);
 	list_for_each_entry(port, &team->port_list, list) {
-		err = team_port_enable_netpoll(team, port, gfp);
+		err = team_port_enable_netpoll(team, port);
 		if (err) {
 			__team_netpoll_cleanup(team);
 			break;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4b6d12c7b803..77142a78c4d9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1037,8 +1037,7 @@ struct net_device_ops {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	void                    (*ndo_poll_controller)(struct net_device *dev);
 	int			(*ndo_netpoll_setup)(struct net_device *dev,
-						     struct netpoll_info *info,
-						     gfp_t gfp);
+						     struct netpoll_info *info);
 	void			(*ndo_netpoll_cleanup)(struct net_device *dev);
 #endif
 #ifdef CONFIG_NET_RX_BUSY_POLL
diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index 1b475a5a7239..893b9e66060e 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -57,7 +57,7 @@ static inline void netpoll_rx_enable(struct net_device *dev) { return; }
 void netpoll_send_udp(struct netpoll *np, const char *msg, int len);
 void netpoll_print_options(struct netpoll *np);
 int netpoll_parse_options(struct netpoll *np, char *opt);
-int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp);
+int __netpoll_setup(struct netpoll *np, struct net_device *ndev);
 int netpoll_setup(struct netpoll *np);
 void __netpoll_cleanup(struct netpoll *np);
 void __netpoll_free_async(struct netpoll *np);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 4f3e9073cb49..a78bebeca4d9 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -707,20 +707,19 @@ static void vlan_dev_poll_controller(struct net_device *dev)
 	return;
 }
 
-static int vlan_dev_netpoll_setup(struct net_device *dev, struct netpoll_info *npinfo,
-				  gfp_t gfp)
+static int vlan_dev_netpoll_setup(struct net_device *dev, struct netpoll_info *npinfo)
 {
 	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
 	struct net_device *real_dev = vlan->real_dev;
 	struct netpoll *netpoll;
 	int err = 0;
 
-	netpoll = kzalloc(sizeof(*netpoll), gfp);
+	netpoll = kzalloc(sizeof(*netpoll), GFP_KERNEL);
 	err = -ENOMEM;
 	if (!netpoll)
 		goto out;
 
-	err = __netpoll_setup(netpoll, real_dev, gfp);
+	err = __netpoll_setup(netpoll, real_dev);
 	if (err) {
 		kfree(netpoll);
 		goto out;
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index f2a08477e0f5..0dd01a05bd59 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -218,16 +218,16 @@ static void br_netpoll_cleanup(struct net_device *dev)
 		br_netpoll_disable(p);
 }
 
-static int __br_netpoll_enable(struct net_bridge_port *p, gfp_t gfp)
+static int __br_netpoll_enable(struct net_bridge_port *p)
 {
 	struct netpoll *np;
 	int err;
 
-	np = kzalloc(sizeof(*p->np), gfp);
+	np = kzalloc(sizeof(*p->np), GFP_KERNEL);
 	if (!np)
 		return -ENOMEM;
 
-	err = __netpoll_setup(np, p->dev, gfp);
+	err = __netpoll_setup(np, p->dev);
 	if (err) {
 		kfree(np);
 		return err;
@@ -237,16 +237,15 @@ static int __br_netpoll_enable(struct net_bridge_port *p, gfp_t gfp)
 	return err;
 }
 
-int br_netpoll_enable(struct net_bridge_port *p, gfp_t gfp)
+int br_netpoll_enable(struct net_bridge_port *p)
 {
 	if (!p->br->dev->npinfo)
 		return 0;
 
-	return __br_netpoll_enable(p, gfp);
+	return __br_netpoll_enable(p);
 }
 
-static int br_netpoll_setup(struct net_device *dev, struct netpoll_info *ni,
-			    gfp_t gfp)
+static int br_netpoll_setup(struct net_device *dev, struct netpoll_info *ni)
 {
 	struct net_bridge *br = netdev_priv(dev);
 	struct net_bridge_port *p;
@@ -255,7 +254,7 @@ static int br_netpoll_setup(struct net_device *dev, struct netpoll_info *ni,
 	list_for_each_entry(p, &br->port_list, list) {
 		if (!p->dev)
 			continue;
-		err = __br_netpoll_enable(p, gfp);
+		err = __br_netpoll_enable(p);
 		if (err)
 			goto fail;
 	}
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 54d207d3a31c..5262b8617eb9 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -366,7 +366,7 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (err)
 		goto err2;
 
-	err = br_netpoll_enable(p, GFP_KERNEL);
+	err = br_netpoll_enable(p);
 	if (err)
 		goto err3;
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index e1ca1dc916a4..06811d79f89f 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -349,7 +349,7 @@ static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
 		netpoll_send_skb(np, skb);
 }
 
-int br_netpoll_enable(struct net_bridge_port *p, gfp_t gfp);
+int br_netpoll_enable(struct net_bridge_port *p);
 void br_netpoll_disable(struct net_bridge_port *p);
 #else
 static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
@@ -357,7 +357,7 @@ static inline void br_netpoll_send_skb(const struct net_bridge_port *p,
 {
 }
 
-static inline int br_netpoll_enable(struct net_bridge_port *p, gfp_t gfp)
+static inline int br_netpoll_enable(struct net_bridge_port *p)
 {
 	return 0;
 }
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 7291dde93469..4bccc78c5b58 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -584,7 +584,7 @@ int netpoll_parse_options(struct netpoll *np, char *opt)
 }
 EXPORT_SYMBOL(netpoll_parse_options);
 
-int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
+int __netpoll_setup(struct netpoll *np, struct net_device *ndev)
 {
 	struct netpoll_info *npinfo;
 	const struct net_device_ops *ops;
@@ -603,7 +603,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 	}
 
 	if (!ndev->npinfo) {
-		npinfo = kmalloc(sizeof(*npinfo), gfp);
+		npinfo = kmalloc(sizeof(*npinfo), GFP_KERNEL);
 		if (!npinfo) {
 			err = -ENOMEM;
 			goto out;
@@ -617,7 +617,7 @@ int __netpoll_setup(struct netpoll *np, struct net_device *ndev, gfp_t gfp)
 
 		ops = np->dev->netdev_ops;
 		if (ops->ndo_netpoll_setup) {
-			err = ops->ndo_netpoll_setup(ndev, npinfo, gfp);
+			err = ops->ndo_netpoll_setup(ndev, npinfo);
 			if (err)
 				goto free_npinfo;
 		}
@@ -749,7 +749,7 @@ int netpoll_setup(struct netpoll *np)
 	/* fill up the skb queue */
 	refill_skbs();
 
-	err = __netpoll_setup(np, ndev, GFP_KERNEL);
+	err = __netpoll_setup(np, ndev);
 	if (err)
 		goto put;
 
-- 
1.7.5.4
