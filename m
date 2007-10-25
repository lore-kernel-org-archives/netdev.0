From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [IFGROUPv4 2/3] Interface group: core (netlink) part
Date: Thu, 25 Oct 2007 17:03:08 +0200
Message-ID: <11933245921874-git-send-email-panther@balabit.hu>
References: <11933245923082-git-send-email-panther@balabit.hu>
 <11933245922165-git-send-email-panther@balabit.hu>
Cc: Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:51748 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758424AbXJYPDU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2007 11:03:20 -0400
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id EFCF1C1309
	for <netdev@vger.kernel.org>; Thu, 25 Oct 2007 17:03:18 +0200 (CEST)
In-Reply-To: <11933245922165-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Interface groups let handle different interfaces together
especially in netfilter modules.
Modified net device structure and netlink interface.

Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
---
 include/linux/if_link.h   |    2 ++
 include/linux/netdevice.h |    2 ++
 net/core/rtnetlink.c      |   11 +++++++++++
 3 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 84c3492..722b25c 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -79,6 +79,8 @@ enum
 	IFLA_LINKINFO,
 #define IFLA_LINKINFO IFLA_LINKINFO
 	IFLA_NET_NS_PID,
+	IFLA_IFGROUP,
+#define IFLA_IFGROUP IFLA_IFGROUP
 	__IFLA_MAX
 };
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c4de536..87aa550 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -519,6 +519,8 @@ struct net_device
 	/* Interface index. Unique device identifier	*/
 	int			ifindex;
 	int			iflink;
+	/* interface group this interface belongs to */
+	u_int32_t		ifgroup;
 
 
 	struct net_device_stats* (*get_stats)(struct net_device *dev);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index ecf4dc5..f13883d 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -611,6 +611,7 @@ static inline size_t if_nlmsg_size(const struct net_device *dev)
 	       + nla_total_size(4) /* IFLA_MTU */
 	       + nla_total_size(4) /* IFLA_LINK */
 	       + nla_total_size(4) /* IFLA_MASTER */
+	       + nla_total_size(4) /* IFLA_IFGROUP */
 	       + nla_total_size(1) /* IFLA_OPERSTATE */
 	       + nla_total_size(1) /* IFLA_LINKMODE */
 	       + rtnl_link_get_size(dev); /* IFLA_LINKINFO */
@@ -648,6 +649,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (dev->master)
 		NLA_PUT_U32(skb, IFLA_MASTER, dev->master->ifindex);
 
+	if (dev->ifgroup)
+		NLA_PUT_U32(skb, IFLA_IFGROUP, dev->ifgroup);
+
 	if (dev->qdisc_sleeping)
 		NLA_PUT_STRING(skb, IFLA_QDISC, dev->qdisc_sleeping->ops->id);
 
@@ -891,6 +895,13 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		}
 	}
 
+	if (tb[IFLA_IFGROUP]) {
+		write_lock_bh(&dev_base_lock);
+		dev->ifgroup = nla_get_u32(tb[IFLA_IFGROUP]);
+		write_unlock_bh(&dev_base_lock);
+		modified = 1;
+	}
+
 	err = 0;
 
 errout:
-- 
1.5.2.5

