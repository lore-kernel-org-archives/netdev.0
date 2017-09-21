From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 3/7] rtnetlink: add helper to dump qdisc name
Date: Thu, 21 Sep 2017 18:58:58 +0200
Message-ID: <20170921165902.10746-4-fw@strlen.de>
References: <20170921165902.10746-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:39112 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751738AbdIUQ6z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 12:58:55 -0400
In-Reply-To: <20170921165902.10746-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can use rcu here to make this safe even if we would not hold rtnl,
qdisc_destroy uses call_rcu to delay free of the qdisc for one grace period.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/core/rtnetlink.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index c801212ee40e..ad3f27da37a8 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1332,6 +1332,19 @@ static int nla_put_iflink(struct sk_buff *skb, const struct net_device *dev)
 	return nla_put_u32(skb, IFLA_LINK, ifindex);
 }
 
+static int nla_put_qdisc(struct sk_buff *skb, struct net_device *dev)
+{
+	struct Qdisc *q;
+	int ret = 0;
+
+	rcu_read_lock();
+	q = READ_ONCE(dev->qdisc);
+	if (q)
+		ret = nla_put_string(skb, IFLA_QDISC, q->ops->id);
+	rcu_read_unlock();
+	return ret;
+}
+
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
 			    unsigned int flags, u32 ext_filter_mask,
@@ -1372,8 +1385,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	    nla_put_iflink(skb, dev) ||
 	    put_master_ifindex(skb, dev) ||
 	    nla_put_u8(skb, IFLA_CARRIER, netif_carrier_ok(dev)) ||
-	    (dev->qdisc &&
-	     nla_put_string(skb, IFLA_QDISC, dev->qdisc->ops->id)) ||
+	    nla_put_qdisc(skb, dev) ||
 	    (dev->ifalias &&
 	     nla_put_string(skb, IFLA_IFALIAS, dev->ifalias)) ||
 	    nla_put_u32(skb, IFLA_CARRIER_CHANGES,
-- 
2.13.5
