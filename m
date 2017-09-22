From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next v2 4/6] rtnetlink: add helper to dump ifalias
Date: Fri, 22 Sep 2017 08:10:06 +0200
Message-ID: <20170922061008.14723-5-fw@strlen.de>
References: <20170922061008.14723-1-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:41596 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751795AbdIVGKF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 02:10:05 -0400
In-Reply-To: <20170922061008.14723-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ifalias is currently protected by rtnl mutex, add assertion
as a reminder.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/core/rtnetlink.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index ad3f27da37a8..42ff582a010e 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1345,6 +1345,16 @@ static int nla_put_qdisc(struct sk_buff *skb, struct net_device *dev)
 	return ret;
 }
 
+static noinline int nla_put_ifalias(struct sk_buff *skb, struct net_device *dev)
+{
+	ASSERT_RTNL();
+
+	if (dev->ifalias)
+		return nla_put_string(skb, IFLA_IFALIAS, dev->ifalias);
+
+	return 0;
+}
+
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
 			    unsigned int flags, u32 ext_filter_mask,
@@ -1386,8 +1396,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	    put_master_ifindex(skb, dev) ||
 	    nla_put_u8(skb, IFLA_CARRIER, netif_carrier_ok(dev)) ||
 	    nla_put_qdisc(skb, dev) ||
-	    (dev->ifalias &&
-	     nla_put_string(skb, IFLA_IFALIAS, dev->ifalias)) ||
+	    nla_put_ifalias(skb, dev) ||
 	    nla_put_u32(skb, IFLA_CARRIER_CHANGES,
 			atomic_read(&dev->carrier_changes)) ||
 	    nla_put_u8(skb, IFLA_PROTO_DOWN, dev->proto_down))
-- 
2.13.5
