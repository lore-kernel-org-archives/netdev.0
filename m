From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 04/15] rtnetlink: remove usage of dev->master
Date: Tue, 14 Aug 2012 17:05:37 +0200
Message-ID: <1344956748-2099-5-git-send-email-jiri@resnulli.us>
References: <1344956748-2099-1-git-send-email-jiri@resnulli.us>
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
Received: from mail-ey0-f174.google.com ([209.85.215.174]:55986 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756527Ab2HNPGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 11:06:08 -0400
Received: by eaac11 with SMTP id c11so194980eaa.19
        for <netdev@vger.kernel.org>; Tue, 14 Aug 2012 08:06:07 -0700 (PDT)
In-Reply-To: <1344956748-2099-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/rtnetlink.c |   44 ++++++++++++++++++++++++--------------------
 1 file changed, 24 insertions(+), 20 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 34d975b..4d41682 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -879,6 +879,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	const struct rtnl_link_stats64 *stats;
 	struct nlattr *attr, *af_spec;
 	struct rtnl_af_ops *af_ops;
+	struct net_device *upper_dev = netdev_master_upper_dev_get(dev);
 
 	ASSERT_RTNL();
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ifm), flags);
@@ -907,8 +908,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 #endif
 	    (dev->ifindex != dev->iflink &&
 	     nla_put_u32(skb, IFLA_LINK, dev->iflink)) ||
-	    (dev->master &&
-	     nla_put_u32(skb, IFLA_MASTER, dev->master->ifindex)) ||
+	    (upper_dev &&
+	     nla_put_u32(skb, IFLA_MASTER, upper_dev->ifindex)) ||
 	    (dev->qdisc &&
 	     nla_put_string(skb, IFLA_QDISC, dev->qdisc->ops->id)) ||
 	    (dev->ifalias &&
@@ -1270,16 +1271,16 @@ static int do_setvfinfo(struct net_device *dev, struct nlattr *attr)
 
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
@@ -1288,12 +1289,12 @@ static int do_set_master(struct net_device *dev, int ifindex)
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
@@ -2050,7 +2051,6 @@ errout:
 static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 {
 	struct net *net = sock_net(skb->sk);
-	struct net_device *master = NULL;
 	struct ndmsg *ndm;
 	struct nlattr *tb[NDA_MAX+1];
 	struct net_device *dev;
@@ -2089,9 +2089,10 @@ static int rtnl_fdb_add(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	/* Support fdb on master device the net/bridge default case */
 	if ((!ndm->ndm_flags || ndm->ndm_flags & NTF_MASTER) &&
 	    (dev->priv_flags & IFF_BRIDGE_PORT)) {
-		master = dev->master;
-		err = master->netdev_ops->ndo_fdb_add(ndm, dev, addr,
-						      nlh->nlmsg_flags);
+		struct net_device *br_dev = netdev_master_upper_dev_get(dev);
+		const struct net_device_ops *ops = br_dev->netdev_ops;
+
+		err = ops->ndo_fdb_add(ndm, dev, addr, nlh->nlmsg_flags);
 		if (err)
 			goto out;
 		else
@@ -2148,10 +2149,11 @@ static int rtnl_fdb_del(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
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
@@ -2234,9 +2236,11 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
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
-- 
1.7.10.4
