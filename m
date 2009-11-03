From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] net: Support specifying the network namespace upon device creation.
Date: Tue, 03 Nov 2009 01:03:02 -0800
Message-ID: <m1eioggeux.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:37970 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754731AbZKCJDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 04:03:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There is no good reason to not support userspace specifying the
network namespace during device creation, and it makes it easier
to create a network device and pass it to a child network namespace
with a well known name.

We have to be careful to ensure that the target network namespace
for the new device exists through the life of the call.  To keep
that logic clear I have factored out the network namespace grabbing
logic into rtnl_link_get_net.

In addtion we need to continue to pass the source network namespace
to the rtnl_link_ops.newlink method so that we can find the base
device source network namespace.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/can/dev.c    |    2 +-
 drivers/net/macvlan.c    |    4 ++--
 drivers/net/veth.c       |   15 ++++++++++++---
 include/net/rtnetlink.h  |    8 +++++---
 net/8021q/vlan_netlink.c |    4 ++--
 net/core/rtnetlink.c     |   38 +++++++++++++++++++++++++++-----------
 net/ipv4/ip_gre.c        |    2 +-
 7 files changed, 50 insertions(+), 23 deletions(-)

diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
index c3db111..5fe34d6 100644
--- a/drivers/net/can/dev.c
+++ b/drivers/net/can/dev.c
@@ -674,7 +674,7 @@ nla_put_failure:
 	return -EMSGSIZE;
 }
 
-static int can_newlink(struct net_device *dev,
+static int can_newlink(struct net *src_net, struct net_device *dev,
 		       struct nlattr *tb[], struct nlattr *data[])
 {
 	return -EOPNOTSUPP;
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 20b7707..d7dba3f 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -504,7 +504,7 @@ static int macvlan_get_tx_queues(struct net *net,
 	return 0;
 }
 
-static int macvlan_newlink(struct net_device *dev,
+static int macvlan_newlink(struct net *src_net, struct net_device *dev,
 			   struct nlattr *tb[], struct nlattr *data[])
 {
 	struct macvlan_dev *vlan = netdev_priv(dev);
@@ -515,7 +515,7 @@ static int macvlan_newlink(struct net_device *dev,
 	if (!tb[IFLA_LINK])
 		return -EINVAL;
 
-	lowerdev = __dev_get_by_index(dev_net(dev), nla_get_u32(tb[IFLA_LINK]));
+	lowerdev = __dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
 	if (lowerdev == NULL)
 		return -ENODEV;
 
diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 9bed694..2d657f2 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -340,7 +340,7 @@ static int veth_validate(struct nlattr *tb[], struct nlattr *data[])
 
 static struct rtnl_link_ops veth_link_ops;
 
-static int veth_newlink(struct net_device *dev,
+static int veth_newlink(struct net *src_net, struct net_device *dev,
 			 struct nlattr *tb[], struct nlattr *data[])
 {
 	int err;
@@ -348,6 +348,7 @@ static int veth_newlink(struct net_device *dev,
 	struct veth_priv *priv;
 	char ifname[IFNAMSIZ];
 	struct nlattr *peer_tb[IFLA_MAX + 1], **tbp;
+	struct net *net;
 
 	/*
 	 * create and register peer first
@@ -380,14 +381,22 @@ static int veth_newlink(struct net_device *dev,
 	else
 		snprintf(ifname, IFNAMSIZ, DRV_NAME "%%d");
 
-	peer = rtnl_create_link(dev_net(dev), ifname, &veth_link_ops, tbp);
-	if (IS_ERR(peer))
+	net = rtnl_link_get_net(src_net, tbp);
+	if (IS_ERR(net))
+		return PTR_ERR(net);
+
+	peer = rtnl_create_link(src_net, net, ifname, &veth_link_ops, tbp);
+	if (IS_ERR(peer)) {
+		put_net(net);
 		return PTR_ERR(peer);
+	}
 
 	if (tbp[IFLA_ADDRESS] == NULL)
 		random_ether_addr(peer->dev_addr);
 
 	err = register_netdevice(peer);
+	put_net(net);
+	net = NULL;
 	if (err < 0)
 		goto err_register_peer;
 
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index cd5af1f..48d3efc 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -55,7 +55,8 @@ struct rtnl_link_ops {
 	int			(*validate)(struct nlattr *tb[],
 					    struct nlattr *data[]);
 
-	int			(*newlink)(struct net_device *dev,
+	int			(*newlink)(struct net *src_net,
+					   struct net_device *dev,
 					   struct nlattr *tb[],
 					   struct nlattr *data[]);
 	int			(*changelink)(struct net_device *dev,
@@ -83,8 +84,9 @@ extern void	rtnl_kill_links(struct net *net, struct rtnl_link_ops *ops);
 extern int	rtnl_link_register(struct rtnl_link_ops *ops);
 extern void	rtnl_link_unregister(struct rtnl_link_ops *ops);
 
-extern struct net_device *rtnl_create_link(struct net *net, char *ifname,
-		const struct rtnl_link_ops *ops, struct nlattr *tb[]);
+extern struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[]);
+extern struct net_device *rtnl_create_link(struct net *src_net, struct net *net,
+	char *ifname, const struct rtnl_link_ops *ops, struct nlattr *tb[]);
 extern const struct nla_policy ifla_policy[IFLA_MAX+1];
 
 #define MODULE_ALIAS_RTNL_LINK(kind) MODULE_ALIAS("rtnl-link-" kind)
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index a915048..3c9cf6a 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -119,7 +119,7 @@ static int vlan_get_tx_queues(struct net *net,
 	return 0;
 }
 
-static int vlan_newlink(struct net_device *dev,
+static int vlan_newlink(struct net *src_net, struct net_device *dev,
 			struct nlattr *tb[], struct nlattr *data[])
 {
 	struct vlan_dev_info *vlan = vlan_dev_info(dev);
@@ -131,7 +131,7 @@ static int vlan_newlink(struct net_device *dev,
 
 	if (!tb[IFLA_LINK])
 		return -EINVAL;
-	real_dev = __dev_get_by_index(dev_net(dev), nla_get_u32(tb[IFLA_LINK]));
+	real_dev = __dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
 	if (!real_dev)
 		return -ENODEV;
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 391a62c..ad52ebc 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -734,6 +734,19 @@ static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
 	[IFLA_INFO_DATA]	= { .type = NLA_NESTED },
 };
 
+struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[])
+{
+	struct net *net;
+	/* Examine the link attributes and figure out which
+	 * network namespace we are talking about.
+	 */
+	if (tb[IFLA_NET_NS_PID])
+		net = get_net_ns_by_pid(nla_get_u32(tb[IFLA_NET_NS_PID]));
+	else
+		net = get_net(src_net);
+	return net;
+}
+
 static int validate_linkmsg(struct net_device *dev, struct nlattr *tb[])
 {
 	if (dev) {
@@ -757,8 +770,7 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 	int err;
 
 	if (tb[IFLA_NET_NS_PID]) {
-		struct net *net;
-		net = get_net_ns_by_pid(nla_get_u32(tb[IFLA_NET_NS_PID]));
+		struct net *net = rtnl_link_get_net(dev_net(dev), tb);
 		if (IS_ERR(net)) {
 			err = PTR_ERR(net);
 			goto errout;
@@ -976,8 +988,8 @@ static int rtnl_dellink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	return 0;
 }
 
-struct net_device *rtnl_create_link(struct net *net, char *ifname,
-		const struct rtnl_link_ops *ops, struct nlattr *tb[])
+struct net_device *rtnl_create_link(struct net *src_net, struct net *net,
+	char *ifname, const struct rtnl_link_ops *ops, struct nlattr *tb[])
 {
 	int err;
 	struct net_device *dev;
@@ -985,7 +997,7 @@ struct net_device *rtnl_create_link(struct net *net, char *ifname,
 	unsigned int real_num_queues = 1;
 
 	if (ops->get_tx_queues) {
-		err = ops->get_tx_queues(net, tb, &num_queues, &real_num_queues);
+		err = ops->get_tx_queues(src_net, tb, &num_queues, &real_num_queues);
 		if (err)
 			goto err;
 	}
@@ -994,16 +1006,16 @@ struct net_device *rtnl_create_link(struct net *net, char *ifname,
 	if (!dev)
 		goto err;
 
+	dev_net_set(dev, net);
+	dev->rtnl_link_ops = ops;
 	dev->real_num_tx_queues = real_num_queues;
+
 	if (strchr(dev->name, '%')) {
 		err = dev_alloc_name(dev, dev->name);
 		if (err < 0)
 			goto err_free;
 	}
 
-	dev_net_set(dev, net);
-	dev->rtnl_link_ops = ops;
-
 	if (tb[IFLA_MTU])
 		dev->mtu = nla_get_u32(tb[IFLA_MTU]);
 	if (tb[IFLA_ADDRESS])
@@ -1080,6 +1092,7 @@ replay:
 
 	if (1) {
 		struct nlattr *attr[ops ? ops->maxtype + 1 : 0], **data = NULL;
+		struct net *dest_net;
 
 		if (ops) {
 			if (ops->maxtype && linkinfo[IFLA_INFO_DATA]) {
@@ -1144,17 +1157,19 @@ replay:
 		if (!ifname[0])
 			snprintf(ifname, IFNAMSIZ, "%s%%d", ops->kind);
 
-		dev = rtnl_create_link(net, ifname, ops, tb);
+		dest_net = rtnl_link_get_net(net, tb);
+		dev = rtnl_create_link(net, dest_net, ifname, ops, tb);
 
 		if (IS_ERR(dev))
 			err = PTR_ERR(dev);
 		else if (ops->newlink)
-			err = ops->newlink(dev, tb, data);
+			err = ops->newlink(net, dev, tb, data);
 		else
 			err = register_netdevice(dev);
-
 		if (err < 0 && !IS_ERR(dev))
 			free_netdev(dev);
+
+		put_net(dest_net);
 		return err;
 	}
 }
@@ -1425,5 +1440,6 @@ EXPORT_SYMBOL(rtnl_is_locked);
 EXPORT_SYMBOL(rtnl_unicast);
 EXPORT_SYMBOL(rtnl_notify);
 EXPORT_SYMBOL(rtnl_set_sk_err);
+EXPORT_SYMBOL(rtnl_link_get_net);
 EXPORT_SYMBOL(rtnl_create_link);
 EXPORT_SYMBOL(ifla_policy);
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index a77807d..c69129c 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1483,7 +1483,7 @@ static void ipgre_tap_setup(struct net_device *dev)
 	dev->features		|= NETIF_F_NETNS_LOCAL;
 }
 
-static int ipgre_newlink(struct net_device *dev, struct nlattr *tb[],
+static int ipgre_newlink(struct net *src_net, struct net_device *dev, struct nlattr *tb[],
 			 struct nlattr *data[])
 {
 	struct ip_tunnel *nt;
-- 
1.6.3.1.54.g99dd.dirty

