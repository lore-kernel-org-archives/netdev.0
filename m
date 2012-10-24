From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH v2 1/3] net: create generic bridge ops
Date: Wed, 24 Oct 2012 11:12:57 -0700
Message-ID: <20121024181257.14378.41548.stgit@jf-dev1-dcblab>
References: <20121024181033.14378.33097.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, chrisw@redhat.com, krkumar2@in.ibm.com,
	samudrala@us.ibm.com, peter.p.waskiewicz.jr@intel.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, gregory.v.rose@intel.com,
	eilong@broadcom.com
To: shemminger@vyatta.com, buytenh@wantstofly.org, davem@davemloft.net,
	vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24824 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934943Ab2JXSaP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2012 14:30:15 -0400
In-Reply-To: <20121024181033.14378.33097.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PF_BRIDGE:RTM_{GET|SET}LINK nlmsg family and type are
currently embedded in the ./net/bridge module. This prohibits
them from being used by other bridging devices. One example
of this being hardware that has embedded bridging components.

In order to use these nlmsg types more generically this patch
adds two net_device_ops hooks. One to set link bridge attributes
and another to dump the current bride attributes.

	ndo_bridge_setlink()
	ndo_bridge_getlink()

CC: Lennert Buytenhek <buytenh@wantstofly.org>
CC: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/linux/netdevice.h |   10 ++++++
 net/bridge/br_device.c    |    2 +
 net/bridge/br_netlink.c   |   73 +++++++----------------------------------
 net/bridge/br_private.h   |    3 ++
 net/core/rtnetlink.c      |   80 +++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 108 insertions(+), 60 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f8eda02..7bf867c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -887,6 +887,10 @@ struct netdev_fcoe_hbainfo {
  *		       struct net_device *dev, int idx)
  *	Used to add FDB entries to dump requests. Implementers should add
  *	entries to skb and update idx with the number of entries.
+ *
+ * int (*ndo_bridge_setlink)(struct net_device *dev, struct nlmsghdr *nlh)
+ * int (*ndo_bridge_getlink)(struct sk_buff *skb, u32 pid, u32 seq,
+ *			     struct net_device *dev)
  */
 struct net_device_ops {
 	int			(*ndo_init)(struct net_device *dev);
@@ -998,6 +1002,12 @@ struct net_device_ops {
 						struct netlink_callback *cb,
 						struct net_device *dev,
 						int idx);
+
+	int			(*ndo_bridge_setlink)(struct net_device *dev,
+						      struct nlmsghdr *nlh);
+	int			(*ndo_bridge_getlink)(struct sk_buff *skb,
+						      u32 pid, u32 seq,
+						      struct net_device *dev);
 };
 
 /*
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 070e8a6..63b5b08 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -313,6 +313,8 @@ static const struct net_device_ops br_netdev_ops = {
 	.ndo_fdb_add		 = br_fdb_add,
 	.ndo_fdb_del		 = br_fdb_delete,
 	.ndo_fdb_dump		 = br_fdb_dump,
+	.ndo_bridge_getlink	 = br_getlink,
+	.ndo_bridge_setlink	 = br_setlink,
 };
 
 static void br_dev_free(struct net_device *dev)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 093f527..743511b 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -111,54 +111,33 @@ errout:
 /*
  * Dump information about all ports, in response to GETLINK
  */
-static int br_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
+int br_getlink(struct sk_buff *skb, u32 pid, u32 seq,
+	       struct net_device *dev)
 {
-	struct net *net = sock_net(skb->sk);
-	struct net_device *dev;
-	int idx;
-
-	idx = 0;
-	rcu_read_lock();
-	for_each_netdev_rcu(net, dev) {
-		struct net_bridge_port *port = br_port_get_rcu(dev);
-
-		/* not a bridge port */
-		if (!port || idx < cb->args[0])
-			goto skip;
-
-		if (br_fill_ifinfo(skb, port,
-				   NETLINK_CB(cb->skb).portid,
-				   cb->nlh->nlmsg_seq, RTM_NEWLINK,
-				   NLM_F_MULTI) < 0)
-			break;
-skip:
-		++idx;
-	}
-	rcu_read_unlock();
-	cb->args[0] = idx;
+	int err = 0;
+	struct net_bridge_port *port = br_port_get_rcu(dev);
+
+	/* not a bridge port */
+	if (!port)
+		goto out;
 
-	return skb->len;
+	err = br_fill_ifinfo(skb, port, pid, seq, RTM_NEWLINK, NLM_F_MULTI);
+out:
+	return err;
 }
 
 /*
  * Change state of port (ie from forwarding to blocking etc)
  * Used by spanning tree in user space.
  */
-static int br_rtm_setlink(struct sk_buff *skb,  struct nlmsghdr *nlh, void *arg)
+int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
 {
-	struct net *net = sock_net(skb->sk);
 	struct ifinfomsg *ifm;
 	struct nlattr *protinfo;
-	struct net_device *dev;
 	struct net_bridge_port *p;
 	u8 new_state;
 
-	if (nlmsg_len(nlh) < sizeof(*ifm))
-		return -EINVAL;
-
 	ifm = nlmsg_data(nlh);
-	if (ifm->ifi_family != AF_BRIDGE)
-		return -EPFNOSUPPORT;
 
 	protinfo = nlmsg_find_attr(nlh, sizeof(*ifm), IFLA_PROTINFO);
 	if (!protinfo || nla_len(protinfo) < sizeof(u8))
@@ -168,10 +147,6 @@ static int br_rtm_setlink(struct sk_buff *skb,  struct nlmsghdr *nlh, void *arg)
 	if (new_state > BR_STATE_BLOCKING)
 		return -EINVAL;
 
-	dev = __dev_get_by_index(net, ifm->ifi_index);
-	if (!dev)
-		return -ENODEV;
-
 	p = br_port_get_rtnl(dev);
 	if (!p)
 		return -EINVAL;
@@ -218,29 +193,7 @@ struct rtnl_link_ops br_link_ops __read_mostly = {
 
 int __init br_netlink_init(void)
 {
-	int err;
-
-	err = rtnl_link_register(&br_link_ops);
-	if (err < 0)
-		goto err1;
-
-	err = __rtnl_register(PF_BRIDGE, RTM_GETLINK, NULL,
-			      br_dump_ifinfo, NULL);
-	if (err)
-		goto err2;
-	err = __rtnl_register(PF_BRIDGE, RTM_SETLINK,
-			      br_rtm_setlink, NULL, NULL);
-	if (err)
-		goto err3;
-
-	return 0;
-
-err3:
-	rtnl_unregister_all(PF_BRIDGE);
-err2:
-	rtnl_link_unregister(&br_link_ops);
-err1:
-	return err;
+	return rtnl_link_register(&br_link_ops);
 }
 
 void __exit br_netlink_fini(void)
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 9b278c4..fdcd5f6 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -553,6 +553,9 @@ extern struct rtnl_link_ops br_link_ops;
 extern int br_netlink_init(void);
 extern void br_netlink_fini(void);
 extern void br_ifinfo_notify(int event, struct net_bridge_port *port);
+extern int br_setlink(struct net_device *dev, struct nlmsghdr *nlmsg);
+extern int br_getlink(struct sk_buff *skb, u32 pid, u32 seq,
+		      struct net_device *dev);
 
 #ifdef CONFIG_SYSFS
 /* br_sysfs_if.c */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 64fe3cc..a068666 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2252,6 +2252,83 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
+static int rtnl_bridge_getlink(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	struct net_device *dev;
+	int idx = 0;
+	u32 portid = NETLINK_CB(cb->skb).portid;
+	u32 seq = cb->nlh->nlmsg_seq;
+
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev) {
+		const struct net_device_ops *ops = dev->netdev_ops;
+		struct net_device *master = dev->master;
+
+		if (idx < cb->args[0])
+			continue;
+
+		if (master && master->netdev_ops->ndo_bridge_getlink) {
+			const struct net_device_ops *bops = master->netdev_ops;
+			int err = bops->ndo_bridge_getlink(skb, portid,
+							   seq, dev);
+
+			if (err < 0)
+				break;
+			else
+				idx++;
+		}
+
+		if (ops->ndo_bridge_getlink) {
+			int err = ops->ndo_bridge_getlink(skb, portid,
+							  seq, dev);
+
+			if (err < 0)
+				break;
+			else
+				idx++;
+		}
+	}
+	rcu_read_unlock();
+	cb->args[0] = idx;
+
+	return skb->len;
+}
+
+static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh,
+			       void *arg)
+{
+	struct net *net = sock_net(skb->sk);
+	struct ifinfomsg *ifm;
+	struct net_device *dev;
+	int err = -EINVAL;
+
+	if (nlmsg_len(nlh) < sizeof(*ifm))
+		return -EINVAL;
+
+	ifm = nlmsg_data(nlh);
+	if (ifm->ifi_family != AF_BRIDGE)
+		return -EPFNOSUPPORT;
+
+	dev = __dev_get_by_index(net, ifm->ifi_index);
+	if (!dev) {
+		pr_info("PF_BRIDGE: RTM_SETLINK with unknown ifindex\n");
+		return -ENODEV;
+	}
+
+	if (dev->master && dev->master->netdev_ops->ndo_bridge_setlink) {
+		err = dev->master->netdev_ops->ndo_bridge_setlink(dev, nlh);
+		if (err)
+			goto out;
+	}
+
+	if (dev->netdev_ops->ndo_bridge_setlink)
+		err = dev->netdev_ops->ndo_bridge_setlink(dev, nlh);
+
+out:
+	return err;
+}
+
 /* Protected by RTNL sempahore.  */
 static struct rtattr **rta_buf;
 static int rtattr_max;
@@ -2433,5 +2510,8 @@ void __init rtnetlink_init(void)
 	rtnl_register(PF_BRIDGE, RTM_NEWNEIGH, rtnl_fdb_add, NULL, NULL);
 	rtnl_register(PF_BRIDGE, RTM_DELNEIGH, rtnl_fdb_del, NULL, NULL);
 	rtnl_register(PF_BRIDGE, RTM_GETNEIGH, NULL, rtnl_fdb_dump, NULL);
+
+	rtnl_register(PF_BRIDGE, RTM_GETLINK, NULL, rtnl_bridge_getlink, NULL);
+	rtnl_register(PF_BRIDGE, RTM_SETLINK, rtnl_bridge_setlink, NULL, NULL);
 }
 
