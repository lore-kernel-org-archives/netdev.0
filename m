From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2 resent net-next 1/4] net: generic fdb support for drivers without ndo_fdb_<op>
Date: Wed,  6 Mar 2013 20:39:42 -0500
Message-ID: <1362620385-14553-2-git-send-email-vyasevic@redhat.com>
References: <1362620385-14553-1-git-send-email-vyasevic@redhat.com>
Cc: or.gerlitz@gmail.com, Vlad Yasevich <vyasevic@redhat.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58994 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755479Ab3CGBjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 20:39:52 -0500
In-Reply-To: <1362620385-14553-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the driver does not support the ndo_op use the generic
handler for it. This should work in the majority of cases.
Eventually the fdb_dflt_add call gets translated into a
__dev_set_rx_mode() call which should handle hardware
support for filtering via the IFF_UNICAST_FLT flag.

Namely IFF_UNICAST_FLT indicates if the hardware can do
unicast address filtering. If no support is available
the device is put into promisc mode.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/rtnetlink.h |    9 +++++
 net/core/rtnetlink.c      |   81 +++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 84 insertions(+), 6 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 489dd7bb..f28544b 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -69,6 +69,15 @@ extern int ndo_dflt_fdb_dump(struct sk_buff *skb,
 			     struct netlink_callback *cb,
 			     struct net_device *dev,
 			     int idx);
+extern int ndo_dflt_fdb_add(struct ndmsg *ndm,
+			    struct nlattr *tb[],
+			    struct net_device *dev,
+			    const unsigned char *addr,
+			     u16 flags);
+extern int ndo_dflt_fdb_del(struct ndmsg *ndm,
+			    struct nlattr *tb[],
+			    struct net_device *dev,
+			    const unsigned char *addr);
 
 extern int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				   struct net_device *dev, u16 mode);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index b376410..f95b6fb 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2048,6 +2048,38 @@ errout:
 	rtnl_set_sk_err(net, RTNLGRP_NEIGH, err);
 }
 
+/**
+ * ndo_dflt_fdb_add - default netdevice operation to add an FDB entry
+ */
+int ndo_dflt_fdb_add(struct ndmsg *ndm,
+		     struct nlattr *tb[],
+		     struct net_device *dev,
+		     const unsigned char *addr,
+		     u16 flags)
+{
+	int err = -EINVAL;
+
+	/* If aging addresses are supported device will need to
+	 * implement its own handler for this.
+	 */
+	if (ndm->ndm_state && !(ndm->ndm_state & NUD_PERMANENT)) {
+		pr_info("%s: FDB only supports static addresses\n", dev->name);
+		return err;
+	}
+
+	if (is_unicast_ether_addr(addr) || is_link_local_ether_addr(addr))
+		err = dev_uc_add_excl(dev, addr);
+	else if (is_multicast_ether_addr(addr))
+		err = dev_mc_add_excl(dev, addr);
+
+	/* Only return duplicate errors if NLM_F_EXCL is set */
+	if (err == -EEXIST && !(flags & NLM_F_EXCL))
+		err = 0;
+
+	return err;
+}
+EXPORT_SYMBOL(ndo_dflt_fdb_add);
+
 static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
@@ -2100,10 +2132,13 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	}
 
 	/* Embedded bridge, macvlan, and any other device support */
-	if ((ndm->ndm_flags & NTF_SELF) && dev->netdev_ops->ndo_fdb_add) {
-		err = dev->netdev_ops->ndo_fdb_add(ndm, tb,
-						   dev, addr,
-						   nlh->nlmsg_flags);
+	if ((ndm->ndm_flags & NTF_SELF)) {
+		if (dev->netdev_ops->ndo_fdb_add)
+			err = dev->netdev_ops->ndo_fdb_add(ndm, tb, dev, addr,
+							   nlh->nlmsg_flags);
+		else
+			err = ndo_dflt_fdb_add(ndm, tb, dev, addr,
+					       nlh->nlmsg_flags);
 
 		if (!err) {
 			rtnl_fdb_notify(dev, addr, RTM_NEWNEIGH);
@@ -2114,6 +2149,35 @@ out:
 	return err;
 }
 
+/**
+ * ndo_dflt_fdb_del - default netdevice operation to delete an FDB entry
+ */
+int ndo_dflt_fdb_del(struct ndmsg *ndm,
+		     struct nlattr *tb[],
+		     struct net_device *dev,
+		     const unsigned char *addr)
+{
+	int err = -EOPNOTSUPP;
+
+	/* If aging addresses are supported device will need to
+	 * implement its own handler for this.
+	 */
+	if (ndm->ndm_state & NUD_PERMANENT) {
+		pr_info("%s: FDB only supports static addresses\n", dev->name);
+		return -EINVAL;
+	}
+
+	if (is_unicast_ether_addr(addr) || is_link_local_ether_addr(addr))
+		err = dev_uc_del(dev, addr);
+	else if (is_multicast_ether_addr(addr))
+		err = dev_mc_del(dev, addr);
+	else
+		err = -EINVAL;
+
+	return err;
+}
+EXPORT_SYMBOL(ndo_dflt_fdb_del);
+
 static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
@@ -2171,8 +2235,11 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	}
 
 	/* Embedded bridge, macvlan, and any other device support */
-	if ((ndm->ndm_flags & NTF_SELF) && dev->netdev_ops->ndo_fdb_del) {
-		err = dev->netdev_ops->ndo_fdb_del(ndm, tb, dev, addr);
+	if (ndm->ndm_flags & NTF_SELF) {
+		if (dev->netdev_ops->ndo_fdb_del)
+			err = dev->netdev_ops->ndo_fdb_del(ndm, tb, dev, addr);
+		else
+			err = ndo_dflt_fdb_del(ndm, tb, dev, addr);
 
 		if (!err) {
 			rtnl_fdb_notify(dev, addr, RTM_DELNEIGH);
@@ -2257,6 +2324,8 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 		if (dev->netdev_ops->ndo_fdb_dump)
 			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev, idx);
+		else
+			ndo_dflt_fdb_dump(skb, cb, dev, idx);
 	}
 	rcu_read_unlock();
 
-- 
1.7.7.6
