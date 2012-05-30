From: John Fastabend <john.r.fastabend@intel.com>
Subject: [RFC PATCH v1 1/3] net: create generic bridge ops
Date: Tue, 29 May 2012 20:07:00 -0700
Message-ID: <20120530030700.7443.81546.stgit@jf-dev1-dcblab>
References: <20120530030531.7443.72024.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, gregory.v.rose@intel.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, jeffrey.t.kirsher@intel.com,
	eric.w.multanen@intel.com
To: krkumar2@in.ibm.com, hadi@cyberus.ca, shemminger@vyatta.com,
	mst@redhat.com, buytenh@wantstofly.org, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6104 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932261Ab2E3DVL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2012 23:21:11 -0400
In-Reply-To: <20120530030531.7443.72024.stgit@jf-dev1-dcblab>
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

This avoids adding many ndo_ops to the net_device but does
require drivers do more nlmsg handling.

CC: Lennert Buytenhek <buytenh@wantstofly.org>
CC: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 include/linux/netdevice.h |   10 ++++++
 net/bridge/br_device.c    |    2 +
 net/bridge/br_netlink.c   |   73 ++++++++----------------------------------
 net/bridge/br_private.h   |    3 ++
 net/core/rtnetlink.c      |   78 +++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 106 insertions(+), 60 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e7fd468..a307d77 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -916,6 +916,10 @@ struct netdev_fcoe_hbainfo {
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
@@ -1025,6 +1029,12 @@ struct net_device_ops {
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
index 929e48aed..e942180 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -320,6 +320,8 @@ static const struct net_device_ops br_netdev_ops = {
 	.ndo_fdb_add		 = br_fdb_add,
 	.ndo_fdb_del		 = br_fdb_delete,
 	.ndo_fdb_dump		 = br_fdb_dump,
+	.ndo_bridge_getlink	 = br_getlink,
+	.ndo_bridge_setlink	 = br_setlink,
 };
 
 static void br_dev_free(struct net_device *dev)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 2080485..f207234 100644
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
-				   NETLINK_CB(cb->skb).pid,
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
@@ -218,29 +193,7 @@ static struct rtnl_link_ops br_link_ops __read_mostly = {
 
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
index 1a8ad4f..659907c 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -552,6 +552,9 @@ extern int (*br_fdb_test_addr_hook)(struct net_device *dev, unsigned char *addr)
 extern int br_netlink_init(void);
 extern void br_netlink_fini(void);
 extern void br_ifinfo_notify(int event, struct net_bridge_port *port);
+extern int br_setlink(struct net_device *dev, struct nlmsghdr *nlmsg);
+extern int br_getlink(struct sk_buff *skb, u32 pid, u32 seq,
+		      struct net_device *dev);
 
 #ifdef CONFIG_SYSFS
 /* br_sysfs_if.c */
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 21318d1..de6c371 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2239,6 +2239,81 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	return skb->len;
 }
 
+static int rtnl_bridge_getlink(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	struct net_device *dev;
+	int idx = 0;
+	u32 pid = NETLINK_CB(cb->skb).pid;
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
+			int err = bops->ndo_bridge_getlink(skb, pid, seq, dev);
+
+			if (err < 0)
+				break;
+			else
+				idx++;
+		}
+
+		if (ops->ndo_bridge_getlink) {
+			int err = ops->ndo_bridge_getlink(skb, pid, seq, dev);
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
@@ -2415,5 +2490,8 @@ void __init rtnetlink_init(void)
 	rtnl_register(PF_BRIDGE, RTM_NEWNEIGH, rtnl_fdb_add, NULL, NULL);
 	rtnl_register(PF_BRIDGE, RTM_DELNEIGH, rtnl_fdb_del, NULL, NULL);
 	rtnl_register(PF_BRIDGE, RTM_GETNEIGH, NULL, rtnl_fdb_dump, NULL);
+
+	rtnl_register(PF_BRIDGE, RTM_GETLINK, NULL, rtnl_bridge_getlink, NULL);
+	rtnl_register(PF_BRIDGE, RTM_SETLINK, rtnl_bridge_setlink, NULL, NULL);
 }
 
