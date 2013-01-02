From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next V5 04/15] rtnetlink: remove usage of dev->master
Date: Wed,  2 Jan 2013 13:28:25 +0100
Message-ID: <1357129716-2450-5-git-send-email-jiri@resnulli.us>
References: <1357129716-2450-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, faisal.latif@intel.com,
	roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	fubar@us.ibm.com, andy@greyhouse.net, divy@chelsio.com,
	jitendra.kalsaria@qlogic.com, sony.chacko@qlogic.com,
	linux-driver@qlogic.com, kaber@trash.net, ursula.braun@de.ibm.com,
	blaschka@linux.vnet.ibm.com, linux390@de.ibm.com,
	shemminger@vyatta.com, bhutchings@solarflare.com,
	therbert@google.com, xiyou.wangcong@gmail.com, joe@perches.com,
	gregory.v.rose@intel.com, john.r.fastabend@intel.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org, bridge@lists.linux-foundation.org,
	fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:44557 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752760Ab3ABM26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2013 07:28:58 -0500
Received: by mail-ea0-f174.google.com with SMTP id e13so5692533eaa.5
        for <netdev@vger.kernel.org>; Wed, 02 Jan 2013 04:28:56 -0800 (PST)
In-Reply-To: <1357129716-2450-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/rtnetlink.c | 69 ++++++++++++++++++++++++++++------------------------
 1 file changed, 37 insertions(+), 32 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2ef7a56..ae612f4 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -880,6 +880,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	const struct rtnl_link_stats64 *stats;
 	struct nlattr *attr, *af_spec;
 	struct rtnl_af_ops *af_ops;
+	struct net_device *upper_dev = netdev_master_upper_dev_get(dev);
 
 	ASSERT_RTNL();
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ifm), flags);
@@ -908,8 +909,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 #endif
 	    (dev->ifindex != dev->iflink &&
 	     nla_put_u32(skb, IFLA_LINK, dev->iflink)) ||
-	    (dev->master &&
-	     nla_put_u32(skb, IFLA_MASTER, dev->master->ifindex)) ||
+	    (upper_dev &&
+	     nla_put_u32(skb, IFLA_MASTER, upper_dev->ifindex)) ||
 	    nla_put_u8(skb, IFLA_CARRIER, netif_carrier_ok(dev)) ||
 	    (dev->qdisc &&
 	     nla_put_string(skb, IFLA_QDISC, dev->qdisc->ops->id)) ||
@@ -1273,16 +1274,16 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
 
 static int do_set_master(struct net_device *dev, int ifindex)
 {
-	struct net_device *master_dev;
+	struct net_device *upper_dev = netdev_master_upper_dev_get(dev);
 	const struct net_device_ops *ops;
 	int err;
 
-	if (dev->master) {
-		if (dev->master->ifindex == ifindex)
+	if (upper_dev) {
+		if (upper_dev->ifindex == ifindex)
 			return 0;
-		ops = dev->master->netdev_ops;
+		ops = upper_dev->netdev_ops;
 		if (ops->ndo_del_slave) {
-			err = ops->ndo_del_slave(dev->master, dev);
+			err = ops->ndo_del_slave(upper_dev, dev);
 			if (err)
 				return err;
 		} else {
@@ -1291,12 +1292,12 @@ static int do_set_master(struct net_device *dev, int ifindex)
 	}
 
 	if (ifindex) {
-		master_dev = __dev_get_by_index(dev_net(dev), ifindex);
-		if (!master_dev)
+		upper_dev = __dev_get_by_index(dev_net(dev), ifindex);
+		if (!upper_dev)
 			return -EINVAL;
-		ops = master_dev->netdev_ops;
+		ops = upper_dev->netdev_ops;
 		if (ops->ndo_add_slave) {
-			err = ops->ndo_add_slave(master_dev, dev);
+			err = ops->ndo_add_slave(upper_dev, dev);
 			if (err)
 				return err;
 		} else {
@@ -2064,7 +2065,6 @@ errout:
 static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
-	struct net_device *master = NULL;
 	struct ndmsg *ndm;
 	struct nlattr *tb[NDA_MAX+1];
 	struct net_device *dev;
@@ -2106,10 +2106,10 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	/* Support fdb on master device the net/bridge default case */
 	if ((!ndm->ndm_flags || ndm->ndm_flags & NTF_MASTER) &&
 	    (dev->priv_flags & IFF_BRIDGE_PORT)) {
-		master = dev->master;
-		err = master->netdev_ops->ndo_fdb_add(ndm, tb,
-						      dev, addr,
-						      nlh->nlmsg_flags);
+		struct net_device *br_dev = netdev_master_upper_dev_get(dev);
+		const struct net_device_ops *ops = br_dev->netdev_ops;
+
+		err = ops->ndo_fdb_add(ndm, tb, dev, addr, nlh->nlmsg_flags);
 		if (err)
 			goto out;
 		else
@@ -2170,10 +2170,11 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	/* Support fdb on master device the net/bridge default case */
 	if ((!ndm->ndm_flags || ndm->ndm_flags & NTF_MASTER) &&
 	    (dev->priv_flags & IFF_BRIDGE_PORT)) {
-		struct net_device *master = dev->master;
+		struct net_device *br_dev = netdev_master_upper_dev_get(dev);
+		const struct net_device_ops *ops = br_dev->netdev_ops;
 
-		if (master->netdev_ops->ndo_fdb_del)
-			err = master->netdev_ops->ndo_fdb_del(ndm, dev, addr);
+		if (ops->ndo_fdb_del)
+			err = ops->ndo_fdb_del(ndm, dev, addr);
 
 		if (err)
 			goto out;
@@ -2257,9 +2258,11 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	rcu_read_lock();
 	for_each_netdev_rcu(net, dev) {
 		if (dev->priv_flags & IFF_BRIDGE_PORT) {
-			struct net_device *master = dev->master;
-			const struct net_device_ops *ops = master->netdev_ops;
+			struct net_device *br_dev;
+			const struct net_device_ops *ops;
 
+			br_dev = netdev_master_upper_dev_get(dev);
+			ops = br_dev->netdev_ops;
 			if (ops->ndo_fdb_dump)
 				idx = ops->ndo_fdb_dump(skb, cb, dev, idx);
 		}
@@ -2280,6 +2283,7 @@ int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	struct ifinfomsg *ifm;
 	struct nlattr *br_afspec;
 	u8 operstate = netif_running(dev) ? dev->operstate : IF_OPER_DOWN;
+	struct net_device *br_dev = netdev_master_upper_dev_get(dev);
 
 	nlh = nlmsg_put(skb, pid, seq, RTM_NEWLINK, sizeof(*ifm), NLM_F_MULTI);
 	if (nlh == NULL)
@@ -2297,8 +2301,8 @@ int ndo_dflt_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 	if (nla_put_string(skb, IFLA_IFNAME, dev->name) ||
 	    nla_put_u32(skb, IFLA_MTU, dev->mtu) ||
 	    nla_put_u8(skb, IFLA_OPERSTATE, operstate) ||
-	    (dev->master &&
-	     nla_put_u32(skb, IFLA_MASTER, dev->master->ifindex)) ||
+	    (br_dev &&
+	     nla_put_u32(skb, IFLA_MASTER, br_dev->ifindex)) ||
 	    (dev->addr_len &&
 	     nla_put(skb, IFLA_ADDRESS, dev->addr_len, dev->dev_addr)) ||
 	    (dev->ifindex != dev->iflink &&
@@ -2334,11 +2338,11 @@ static int rtnl_bridge_getlink(struct sk_buff *skb, struct netlink_callback *cb)
 	rcu_read_lock();
 	for_each_netdev_rcu(net, dev) {
 		const struct net_device_ops *ops = dev->netdev_ops;
-		struct net_device *master = dev->master;
+		struct net_device *br_dev = netdev_master_upper_dev_get(dev);
 
-		if (master && master->netdev_ops->ndo_bridge_getlink) {
+		if (br_dev && br_dev->netdev_ops->ndo_bridge_getlink) {
 			if (idx >= cb->args[0] &&
-			    master->netdev_ops->ndo_bridge_getlink(
+			    br_dev->netdev_ops->ndo_bridge_getlink(
 				    skb, portid, seq, dev) < 0)
 				break;
 			idx++;
@@ -2375,7 +2379,7 @@ static inline size_t bridge_nlmsg_size(void)
 static int rtnl_bridge_notify(struct net_device *dev, u16 flags)
 {
 	struct net *net = dev_net(dev);
-	struct net_device *master = dev->master;
+	struct net_device *br_dev = netdev_master_upper_dev_get(dev);
 	struct sk_buff *skb;
 	int err = -EOPNOTSUPP;
 
@@ -2386,8 +2390,8 @@ static int rtnl_bridge_notify(struct net_device *dev, u16 flags)
 	}
 
 	if ((!flags || (flags & BRIDGE_FLAGS_MASTER)) &&
-	    master && master->netdev_ops->ndo_bridge_getlink) {
-		err = master->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev);
+	    br_dev && br_dev->netdev_ops->ndo_bridge_getlink) {
+		err = br_dev->netdev_ops->ndo_bridge_getlink(skb, 0, 0, dev);
 		if (err < 0)
 			goto errout;
 	}
@@ -2446,13 +2450,14 @@ static int rtnl_bridge_setlink(struct sk_buff *skb, struct nlmsghdr *nlh,
 	oflags = flags;
 
 	if (!flags || (flags & BRIDGE_FLAGS_MASTER)) {
-		if (!dev->master ||
-		    !dev->master->netdev_ops->ndo_bridge_setlink) {
+		struct net_device *br_dev = netdev_master_upper_dev_get(dev);
+
+		if (!br_dev || !br_dev->netdev_ops->ndo_bridge_setlink) {
 			err = -EOPNOTSUPP;
 			goto out;
 		}
 
-		err = dev->master->netdev_ops->ndo_bridge_setlink(dev, nlh);
+		err = br_dev->netdev_ops->ndo_bridge_setlink(dev, nlh);
 		if (err)
 			goto out;
 
-- 
1.8.0
