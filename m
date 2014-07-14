From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v9 4/4] net: rtnetlink - make create_link take name_assign_type
Date: Mon, 14 Jul 2014 16:37:25 +0200
Message-ID: <1405348645-1995-4-git-send-email-teg@jklm.no>
References: <1405348645-1995-1-git-send-email-teg@jklm.no>
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	Tom Gundersen <teg@jklm.no>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405348645-1995-1-git-send-email-teg@jklm.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This passes down NET_NAME_USER (or NET_NAME_ENUM) to alloc_netdev(),
for any device created over rtnetlink.

v9: restore reverse-christmas-tree order of local variables

Signed-off-by: Tom Gundersen <teg@jklm.no>
---
 drivers/net/veth.c      | 11 ++++++++---
 include/net/rtnetlink.h |  1 +
 net/core/rtnetlink.c    | 12 ++++++++----
 3 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index b4a10bc..157c567 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -317,6 +317,7 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 	struct veth_priv *priv;
 	char ifname[IFNAMSIZ];
 	struct nlattr *peer_tb[IFLA_MAX + 1], **tbp;
+	unsigned char name_assign_type;
 	struct ifinfomsg *ifmp;
 	struct net *net;
 
@@ -344,16 +345,20 @@ static int veth_newlink(struct net *src_net, struct net_device *dev,
 		tbp = tb;
 	}
 
-	if (tbp[IFLA_IFNAME])
+	if (tbp[IFLA_IFNAME]) {
 		nla_strlcpy(ifname, tbp[IFLA_IFNAME], IFNAMSIZ);
-	else
+		name_assign_type = NET_NAME_USER;
+	} else {
 		snprintf(ifname, IFNAMSIZ, DRV_NAME "%%d");
+		name_assign_type = NET_NAME_ENUM;
+	}
 
 	net = rtnl_link_get_net(src_net, tbp);
 	if (IS_ERR(net))
 		return PTR_ERR(net);
 
-	peer = rtnl_create_link(net, ifname, &veth_link_ops, tbp);
+	peer = rtnl_create_link(net, ifname, name_assign_type,
+				&veth_link_ops, tbp);
 	if (IS_ERR(peer)) {
 		put_net(net);
 		return PTR_ERR(peer);
diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index 72240e5..e21b9f9 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -136,6 +136,7 @@ void rtnl_af_unregister(struct rtnl_af_ops *ops);
 
 struct net *rtnl_link_get_net(struct net *src_net, struct nlattr *tb[]);
 struct net_device *rtnl_create_link(struct net *net, char *ifname,
+				    unsigned char name_assign_type,
 				    const struct rtnl_link_ops *ops,
 				    struct nlattr *tb[]);
 int rtnl_configure_link(struct net_device *dev, const struct ifinfomsg *ifm);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 899de40..09456ff 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1805,7 +1805,8 @@ int rtnl_configure_link(struct net_device *dev, const struct ifinfomsg *ifm)
 EXPORT_SYMBOL(rtnl_configure_link);
 
 struct net_device *rtnl_create_link(struct net *net,
-	char *ifname, const struct rtnl_link_ops *ops, struct nlattr *tb[])
+	char *ifname, unsigned char name_assign_type,
+	const struct rtnl_link_ops *ops, struct nlattr *tb[])
 {
 	int err;
 	struct net_device *dev;
@@ -1823,7 +1824,7 @@ struct net_device *rtnl_create_link(struct net *net,
 		num_rx_queues = ops->get_num_rx_queues();
 
 	err = -ENOMEM;
-	dev = alloc_netdev_mqs(ops->priv_size, ifname, NET_NAME_UNKNOWN,
+	dev = alloc_netdev_mqs(ops->priv_size, ifname, name_assign_type,
 			       ops->setup, num_tx_queues, num_rx_queues);
 	if (!dev)
 		goto err;
@@ -1889,6 +1890,7 @@ static int rtnl_newlink(struct sk_buff *skb, struct nlmsghdr *nlh)
 	char ifname[IFNAMSIZ];
 	struct nlattr *tb[IFLA_MAX+1];
 	struct nlattr *linkinfo[IFLA_INFO_MAX+1];
+	unsigned char name_assign_type = NET_NAME_USER;
 	int err;
 
 #ifdef CONFIG_MODULES
@@ -2038,14 +2040,16 @@ replay:
 			return -EOPNOTSUPP;
 		}
 
-		if (!ifname[0])
+		if (!ifname[0]) {
 			snprintf(ifname, IFNAMSIZ, "%s%%d", ops->kind);
+			name_assign_type = NET_NAME_ENUM;
+		}
 
 		dest_net = rtnl_link_get_net(net, tb);
 		if (IS_ERR(dest_net))
 			return PTR_ERR(dest_net);
 
-		dev = rtnl_create_link(dest_net, ifname, ops, tb);
+		dev = rtnl_create_link(dest_net, ifname, name_assign_type, ops, tb);
 		if (IS_ERR(dev)) {
 			err = PTR_ERR(dev);
 			goto out;
-- 
1.9.3
