From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next v2 3/5] rtnl: add link netns id to interface messages
Date: Tue, 23 Sep 2014 15:20:28 +0200
Message-ID: <1411478430-4989-4-git-send-email-nicolas.dichtel@6wind.com>
References: <1411478430-4989-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	stephen@networkplumber.org, akpm@linux-foundation.org,
	luto@amacapital.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:46015 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751742AbaIWNUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 09:20:52 -0400
In-Reply-To: <1411478430-4989-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new attribute (IFLA_LINK_NETNSID) which contains the 'link'
netns id when this netns is different from the netns where the interface
stands (for example for x-net interfaces like ip tunnels). When there is no id,
because user ns of link netns and interface netns is not the same, we put 0
into this attribute (id 0 is not valid) to indicate to userland that the link
netns is different from the interface netns. Hence, userland knows that some
information like IFLA_LINK are not interpretable.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/net/rtnetlink.h      |  2 ++
 include/uapi/linux/if_link.h |  1 +
 net/core/rtnetlink.c         | 22 ++++++++++++++++++++++
 3 files changed, 25 insertions(+)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index e21b9f9653c0..6c6d5393fc34 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -46,6 +46,7 @@ static inline int rtnl_msg_family(const struct nlmsghdr *nlh)
  *			    to create when creating a new device.
  *	@get_num_rx_queues: Function to determine number of receive queues
  *			    to create when creating a new device.
+ *	@get_link_net: Function to get the i/o netns of the device
  */
 struct rtnl_link_ops {
 	struct list_head	list;
@@ -93,6 +94,7 @@ struct rtnl_link_ops {
 	int			(*fill_slave_info)(struct sk_buff *skb,
 						   const struct net_device *dev,
 						   const struct net_device *slave_dev);
+	struct net		*(*get_link_net)(const struct net_device *dev);
 };
 
 int __rtnl_link_register(struct rtnl_link_ops *ops);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index c80f95f6ee78..21dd2bcb295f 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -145,6 +145,7 @@ enum {
 	IFLA_CARRIER,
 	IFLA_PHYS_PORT_ID,
 	IFLA_CARRIER_CHANGES,
+	IFLA_LINK_NETNSID,
 	__IFLA_MAX
 };
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index a6882686ca3a..99ed83c62685 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -862,6 +862,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(1) /* IFLA_OPERSTATE */
 	       + nla_total_size(1) /* IFLA_LINKMODE */
 	       + nla_total_size(4) /* IFLA_CARRIER_CHANGES */
+	       + nla_total_size(4) /* IFLA_LINK_NETNSID */
 	       + nla_total_size(ext_filter_mask
 			        & RTEXT_FILTER_VF ? 4 : 0) /* IFLA_NUM_VF */
 	       + rtnl_vfinfo_size(dev, ext_filter_mask) /* IFLA_VFINFO_LIST */
@@ -1134,6 +1135,27 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			goto nla_put_failure;
 	}
 
+	if (dev->rtnl_link_ops &&
+	    dev->rtnl_link_ops->get_link_net) {
+		struct net *link_net = dev->rtnl_link_ops->get_link_net(dev);
+
+		if (!net_eq(dev_net(dev), link_net)) {
+			int id = peernet2id(dev_net(dev), link_net);
+
+			/* If the link netns is not in the same user ns, put id
+			 * 0 in IFLA_LINK_NETNSID to indicate to userland that
+			 * the link netns is not the current netns, but that it
+			 * don't have access to it.
+			 */
+			if (id == -EPERM)
+				id = 0;
+
+			if (id >= 0 &&
+			    nla_put_u32(skb, IFLA_LINK_NETNSID, id))
+				goto nla_put_failure;
+		}
+	}
+
 	if (!(af_spec = nla_nest_start(skb, IFLA_AF_SPEC)))
 		goto nla_put_failure;
 
-- 
2.1.0
