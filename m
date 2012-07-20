From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/6] rtnl: allow to specify number of rx and tx queues on device creation
Date: Fri, 20 Jul 2012 14:28:48 +0200
Message-ID: <1342787331-1866-4-git-send-email-jiri@resnulli.us>
References: <1342787331-1866-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, shemminger@vyatta.com,
	fubar@us.ibm.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:34608 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753202Ab2GTM3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 08:29:06 -0400
Received: by weyx8 with SMTP id x8so2559855wey.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 05:29:04 -0700 (PDT)
In-Reply-To: <1342787331-1866-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces IFLA_NUM_TX_QUEUES and IFLA_NUM_RX_QUEUES by
which userspace can set number of rx and/or tx queues to be allocated
for newly created netdevice.
This overrides ops->get_num_[tr]x_queues()

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/linux/if_link.h |    2 ++
 net/core/rtnetlink.c    |   15 +++++++++++++--
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index f715750..ac173bd 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -140,6 +140,8 @@ enum {
 	IFLA_EXT_MASK,		/* Extended info mask, VFs, etc */
 	IFLA_PROMISCUITY,	/* Promiscuity count: > 0 means acts PROMISC */
 #define IFLA_PROMISCUITY IFLA_PROMISCUITY
+	IFLA_NUM_TX_QUEUES,
+	IFLA_NUM_RX_QUEUES,
 	__IFLA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index db5a8ad..5bb1ebc 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -771,6 +771,8 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(4) /* IFLA_LINK */
 	       + nla_total_size(4) /* IFLA_MASTER */
 	       + nla_total_size(4) /* IFLA_PROMISCUITY */
+	       + nla_total_size(4) /* IFLA_NUM_TX_QUEUES */
+	       + nla_total_size(4) /* IFLA_NUM_RX_QUEUES */
 	       + nla_total_size(1) /* IFLA_OPERSTATE */
 	       + nla_total_size(1) /* IFLA_LINKMODE */
 	       + nla_total_size(ext_filter_mask
@@ -889,6 +891,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	    nla_put_u32(skb, IFLA_MTU, dev->mtu) ||
 	    nla_put_u32(skb, IFLA_GROUP, dev->group) ||
 	    nla_put_u32(skb, IFLA_PROMISCUITY, dev->promiscuity) ||
+	    nla_put_u32(skb, IFLA_NUM_TX_QUEUES, dev->num_tx_queues) ||
+	    nla_put_u32(skb, IFLA_NUM_RX_QUEUES, dev->num_rx_queues) ||
 	    (dev->ifindex != dev->iflink &&
 	     nla_put_u32(skb, IFLA_LINK, dev->iflink)) ||
 	    (dev->master &&
@@ -1106,6 +1110,8 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_AF_SPEC]		= { .type = NLA_NESTED },
 	[IFLA_EXT_MASK]		= { .type = NLA_U32 },
 	[IFLA_PROMISCUITY]	= { .type = NLA_U32 },
+	[IFLA_NUM_TX_QUEUES]	= { .type = NLA_U32 },
+	[IFLA_NUM_RX_QUEUES]	= { .type = NLA_U32 },
 };
 EXPORT_SYMBOL(ifla_policy);
 
@@ -1627,9 +1633,14 @@ struct net_device *rtnl_create_link(struct net *src_net, struct net *net,
 	unsigned int num_tx_queues = 1;
 	unsigned int num_rx_queues = 1;
 
-	if (ops->get_num_tx_queues)
+	if (tb[IFLA_NUM_TX_QUEUES])
+		num_tx_queues = nla_get_u32(tb[IFLA_NUM_TX_QUEUES]);
+	else if (ops->get_num_tx_queues)
 		num_tx_queues = ops->get_num_tx_queues();
-	if (ops->get_num_rx_queues)
+
+	if (tb[IFLA_NUM_RX_QUEUES])
+		num_rx_queues = nla_get_u32(tb[IFLA_NUM_RX_QUEUES]);
+	else if (ops->get_num_rx_queues)
 		num_rx_queues = ops->get_num_rx_queues();
 
 	err = -ENOMEM;
-- 
1.7.10.4
