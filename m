From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/4] rtnl: expose carrier value with possibility to set it
Date: Wed, 12 Dec 2012 11:58:06 +0100
Message-ID: <1355309887-1081-4-git-send-email-jiri@resnulli.us>
References: <1355309887-1081-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com, shemminger@vyatta.com,
	greearb@candelatech.com, fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49070 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753546Ab2LLK6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 05:58:23 -0500
Received: by mail-ee0-f46.google.com with SMTP id e53so325458eek.19
        for <netdev@vger.kernel.org>; Wed, 12 Dec 2012 02:58:22 -0800 (PST)
In-Reply-To: <1355309887-1081-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/uapi/linux/if_link.h |  1 +
 net/core/rtnetlink.c         | 10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 60f3b6b..c4edfe1 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -142,6 +142,7 @@ enum {
 #define IFLA_PROMISCUITY IFLA_PROMISCUITY
 	IFLA_NUM_TX_QUEUES,
 	IFLA_NUM_RX_QUEUES,
+	IFLA_CARRIER,
 	__IFLA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 1868625..2ef7a56 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -780,6 +780,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(4) /* IFLA_MTU */
 	       + nla_total_size(4) /* IFLA_LINK */
 	       + nla_total_size(4) /* IFLA_MASTER */
+	       + nla_total_size(1) /* IFLA_CARRIER */
 	       + nla_total_size(4) /* IFLA_PROMISCUITY */
 	       + nla_total_size(4) /* IFLA_NUM_TX_QUEUES */
 	       + nla_total_size(4) /* IFLA_NUM_RX_QUEUES */
@@ -909,6 +910,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	     nla_put_u32(skb, IFLA_LINK, dev->iflink)) ||
 	    (dev->master &&
 	     nla_put_u32(skb, IFLA_MASTER, dev->master->ifindex)) ||
+	    nla_put_u8(skb, IFLA_CARRIER, netif_carrier_ok(dev)) ||
 	    (dev->qdisc &&
 	     nla_put_string(skb, IFLA_QDISC, dev->qdisc->ops->id)) ||
 	    (dev->ifalias &&
@@ -1108,6 +1110,7 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_MTU]		= { .type = NLA_U32 },
 	[IFLA_LINK]		= { .type = NLA_U32 },
 	[IFLA_MASTER]		= { .type = NLA_U32 },
+	[IFLA_CARRIER]		= { .type = NLA_U8 },
 	[IFLA_TXQLEN]		= { .type = NLA_U32 },
 	[IFLA_WEIGHT]		= { .type = NLA_U32 },
 	[IFLA_OPERSTATE]	= { .type = NLA_U8 },
@@ -1438,6 +1441,13 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		modified = 1;
 	}
 
+	if (tb[IFLA_CARRIER]) {
+		err = dev_change_carrier(dev, nla_get_u8(tb[IFLA_CARRIER]));
+		if (err)
+			goto errout;
+		modified = 1;
+	}
+
 	if (tb[IFLA_TXQLEN])
 		dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);
 
-- 
1.8.0
