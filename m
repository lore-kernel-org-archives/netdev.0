From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/4] rtnl: expose carrier value with possibility to set it
Date: Wed, 19 Dec 2012 10:35:55 +0100
Message-ID: <1355909756-2389-4-git-send-email-jiri@resnulli.us>
References: <1355909756-2389-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, mirqus@gmail.com, shemminger@vyatta.com,
	greearb@candelatech.com, fbl@redhat.com, john.r.fastabend@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f51.google.com ([74.125.83.51]:33631 "EHLO
	mail-ee0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753891Ab2LSJgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 04:36:11 -0500
Received: by mail-ee0-f51.google.com with SMTP id d4so858800eek.24
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2012 01:36:10 -0800 (PST)
In-Reply-To: <1355909756-2389-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 Documentation/networking/operstates.txt |  4 ++++
 include/uapi/linux/if_link.h            |  1 +
 net/core/rtnetlink.c                    | 10 ++++++++++
 3 files changed, 15 insertions(+)

diff --git a/Documentation/networking/operstates.txt b/Documentation/networking/operstates.txt
index 1a77a3c..9769457 100644
--- a/Documentation/networking/operstates.txt
+++ b/Documentation/networking/operstates.txt
@@ -88,6 +88,10 @@ set this flag. On netif_carrier_off(), the scheduler stops sending
 packets. The name 'carrier' and the inversion are historical, think of
 it as lower layer.
 
+Note that for certain kind of soft-devices, which are not managing any
+real hardware, there is possible to set this bit from userpsace.
+One should use TVL IFLA_CARRIER to do so.
+
 netif_carrier_ok() can be used to query that bit.
 
 __LINK_STATE_DORMANT, maps to IFF_DORMANT:
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
