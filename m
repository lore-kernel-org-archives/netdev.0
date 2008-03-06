From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCHv8 1/2] Interface group: core and netlink part
Date: Thu,  6 Mar 2008 15:03:58 +0100
Message-ID: <1204812239968-git-send-email-panther@balabit.hu>
References: <12048121721361-git-send-email-panther@balabit.hu>
Cc: netdev@vger.kernel.org, Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:49496 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934500AbYCFOEB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2008 09:04:01 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 1C835C1317
	for <netdev@vger.kernel.org>; Thu,  6 Mar 2008 15:04:00 +0100 (CET)
In-Reply-To: <12048121721361-git-send-email-panther@balabit.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Interface groups let handle different interfaces together.
Modified net device structure and netlink interface.

Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
---
 include/linux/if_link.h   |    2 ++
 include/linux/netdevice.h |    3 +++
 net/core/rtnetlink.c      |    9 +++++++++
 3 files changed, 14 insertions(+), 0 deletions(-)

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
index a2f0032..e50d439 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -546,6 +546,9 @@ struct net_device
 	/* Hardware header description */
 	const struct header_ops *header_ops;
 
+	/* interface group this interface belongs to */
+	unsigned int		ifgroup;
+
 	/*
 	 * This marks the end of the "visible" part of the structure. All
 	 * fields hereafter are internal to the system, and may change at
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2bd9c5f..5fbbdc4 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -577,6 +577,7 @@ static inline size_t if_nlmsg_size(const struct net_device *dev)
 	       + nla_total_size(4) /* IFLA_MTU */
 	       + nla_total_size(4) /* IFLA_LINK */
 	       + nla_total_size(4) /* IFLA_MASTER */
+	       + nla_total_size(4) /* IFLA_IFGROUP */
 	       + nla_total_size(1) /* IFLA_OPERSTATE */
 	       + nla_total_size(1) /* IFLA_LINKMODE */
 	       + rtnl_link_get_size(dev); /* IFLA_LINKINFO */
@@ -614,6 +615,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (dev->master)
 		NLA_PUT_U32(skb, IFLA_MASTER, dev->master->ifindex);
 
+	if (dev->ifgroup)
+		NLA_PUT_U32(skb, IFLA_IFGROUP, dev->ifgroup);
+
 	if (dev->qdisc_sleeping)
 		NLA_PUT_STRING(skb, IFLA_QDISC, dev->qdisc_sleeping->ops->id);
 
@@ -863,6 +867,11 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		write_unlock_bh(&dev_base_lock);
 	}
 
+	if (tb[IFLA_IFGROUP]) {
+		dev->ifgroup = nla_get_u32(tb[IFLA_IFGROUP]);
+	}
+
+
 	err = 0;
 
 errout:
-- 
1.5.2.5

