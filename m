From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] vlan: multiqueue vlan devices
Date: Wed, 02 Sep 2009 19:17:58 +0200
Message-ID: <4A9EA8C6.2000501@gmail.com>
References: <20090902081429.GB4878@ff.dom.local>	<4A9E2CC7.1010103@gmail.com>	<20090902.013002.181288977.davem@davemloft.net>	<4A9E6551.4030209@gmail.com>	<4A9E699B.7080400@gmail.com> <20090902092351.11649796@nehalam> <4A9E9D8A.50406@trash.net> <4A9EA250.2010209@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@vyatta.com>, jarkao2@gmail.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58477 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752886AbZIBRSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 13:18:03 -0400
In-Reply-To: <4A9EA250.2010209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan devices are currently not multi-queue capable.

We can do that with a new rtnl_link_ops method,
get_tx_queues(), called from rtnl_create_link()

This new method gets num_tx_queues/real_num_tx_queues
from real device.

register_vlan_device() is also handled.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/rtnetlink.h  |    2 ++
 net/8021q/vlan.c         |    5 +++--
 net/8021q/vlan_netlink.c |   20 ++++++++++++++++++++
 net/core/rtnetlink.c     |   10 +++++++++-
 4 files changed, 34 insertions(+), 3 deletions(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 3c1895e..0525a1d 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -70,6 +70,8 @@ struct rtnl_link_ops {
 	size_t			(*get_xstats_size)(const struct net_device *dev);
 	int			(*fill_xstats)(struct sk_buff *skb,
 					       const struct net_device *dev);
+	int			(*get_tx_queues)(struct net*, struct nlattr *tb[],
+						 int *tx_queues, int *real_tx_queues);
 };
 
 extern int	__rtnl_link_register(struct rtnl_link_ops *ops);
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index e814794..8836575 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -330,12 +330,13 @@ static int register_vlan_device(struct net_device *real_dev, u16 vlan_id)
 		snprintf(name, IFNAMSIZ, "vlan%.4i", vlan_id);
 	}
 
-	new_dev = alloc_netdev(sizeof(struct vlan_dev_info), name,
-			       vlan_setup);
+	new_dev = alloc_netdev_mq(sizeof(struct vlan_dev_info), name,
+				  vlan_setup, real_dev->num_tx_queues);
 
 	if (new_dev == NULL)
 		return -ENOBUFS;
 
+	new_dev->real_num_tx_queues = real_dev->real_num_tx_queues;
 	dev_net_set(new_dev, net);
 	/* need 4 bytes for extra VLAN header info,
 	 * hope the underlying device can handle it.
diff --git a/net/8021q/vlan_netlink.c b/net/8021q/vlan_netlink.c
index e9c91dc..8ce4122 100644
--- a/net/8021q/vlan_netlink.c
+++ b/net/8021q/vlan_netlink.c
@@ -100,6 +100,25 @@ static int vlan_changelink(struct net_device *dev,
 	return 0;
 }
 
+static int vlan_get_tx_queues(struct net *net, 
+			      struct nlattr *tb[],
+			      int *num_tx_queues,
+			      int *real_num_tx_queues)
+{
+	struct net_device *real_dev;
+
+	if (!tb[IFLA_LINK])
+		return -EINVAL;
+
+	real_dev = __dev_get_by_index(net, nla_get_u32(tb[IFLA_LINK]));
+	if (!real_dev)
+		return -ENODEV;
+
+	*num_tx_queues      = real_dev->num_tx_queues;
+	*real_num_tx_queues = real_dev->real_num_tx_queues;
+	return 0;
+}
+
 static int vlan_newlink(struct net_device *dev,
 			struct nlattr *tb[], struct nlattr *data[])
 {
@@ -216,6 +235,7 @@ struct rtnl_link_ops vlan_link_ops __read_mostly = {
 	.maxtype	= IFLA_VLAN_MAX,
 	.policy		= vlan_policy,
 	.priv_size	= sizeof(struct vlan_dev_info),
+	.get_tx_queues  = vlan_get_tx_queues,
 	.setup		= vlan_setup,
 	.validate	= vlan_validate,
 	.newlink	= vlan_newlink,
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index b44775f..5c1fe53 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -974,12 +974,20 @@ struct net_device *rtnl_create_link(struct net *net, char *ifname,
 {
 	int err;
 	struct net_device *dev;
+	int num_queues = 1;
+	int real_num_queues = 1;
 
+	if (ops->get_tx_queues) {
+		err = ops->get_tx_queues(net, tb, &num_queues, &real_num_queues);
+		if (err)
+			goto err;
+	}
 	err = -ENOMEM;
-	dev = alloc_netdev(ops->priv_size, ifname, ops->setup);
+	dev = alloc_netdev_mq(ops->priv_size, ifname, ops->setup, num_queues);
 	if (!dev)
 		goto err;
 
+	dev->real_num_tx_queues = real_num_queues;
 	if (strchr(dev->name, '%')) {
 		err = dev_alloc_name(dev, dev->name);
 		if (err < 0)
