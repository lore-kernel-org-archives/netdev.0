From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next v4 1/4] rtnetlink: add helper to put master and link ifindexes
Date: Tue, 26 Sep 2017 13:58:40 +0200
Message-ID: <20170926115843.12013-2-fw@strlen.de>
References: <20170926115843.12013-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:58788 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S936361AbdIZL63 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 07:58:29 -0400
In-Reply-To: <20170926115843.12013-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtnl_fill_ifinfo currently requires caller to hold the rtnl mutex.
Unfortunately the function is quite large which makes it harder to see
which spots require the lock, which spots assume it and which ones could
do without.

Add helpers to factor out the ifindex dumping, one can use rcu to avoid
rtnl dependency.

Reviewed-by: David Ahern <dsahern@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 No changes in v4.

 net/core/rtnetlink.c | 32 +++++++++++++++++++++++++++-----
 1 file changed, 27 insertions(+), 5 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a78fd61da0ec..c801212ee40e 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1307,6 +1307,31 @@ static u32 rtnl_get_event(unsigned long event)
 	return rtnl_event_type;
 }
 
+static int put_master_ifindex(struct sk_buff *skb, struct net_device *dev)
+{
+	const struct net_device *upper_dev;
+	int ret = 0;
+
+	rcu_read_lock();
+
+	upper_dev = netdev_master_upper_dev_get_rcu(dev);
+	if (upper_dev)
+		ret = nla_put_u32(skb, IFLA_MASTER, upper_dev->ifindex);
+
+	rcu_read_unlock();
+	return ret;
+}
+
+static int nla_put_iflink(struct sk_buff *skb, const struct net_device *dev)
+{
+	int ifindex = dev_get_iflink(dev);
+
+	if (dev->ifindex == ifindex)
+		return 0;
+
+	return nla_put_u32(skb, IFLA_LINK, ifindex);
+}
+
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
 			    unsigned int flags, u32 ext_filter_mask,
@@ -1316,7 +1341,6 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	struct nlmsghdr *nlh;
 	struct nlattr *af_spec;
 	struct rtnl_af_ops *af_ops;
-	struct net_device *upper_dev = netdev_master_upper_dev_get(dev);
 
 	ASSERT_RTNL();
 	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ifm), flags);
@@ -1345,10 +1369,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 #ifdef CONFIG_RPS
 	    nla_put_u32(skb, IFLA_NUM_RX_QUEUES, dev->num_rx_queues) ||
 #endif
-	    (dev->ifindex != dev_get_iflink(dev) &&
-	     nla_put_u32(skb, IFLA_LINK, dev_get_iflink(dev))) ||
-	    (upper_dev &&
-	     nla_put_u32(skb, IFLA_MASTER, upper_dev->ifindex)) ||
+	    nla_put_iflink(skb, dev) ||
+	    put_master_ifindex(skb, dev) ||
 	    nla_put_u8(skb, IFLA_CARRIER, netif_carrier_ok(dev)) ||
 	    (dev->qdisc &&
 	     nla_put_string(skb, IFLA_QDISC, dev->qdisc->ops->id)) ||
-- 
2.13.5
