From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [PATCHv6 2/3] Interface group: core (netlink) part
Date: Tue, 20 Nov 2007 14:14:26 +0100
Message-ID: <11955644702451-git-send-email-panther@balabit.hu>
References: <11955644701165-git-send-email-panther@balabit.hu>
 <1195564470928-git-send-email-panther@balabit.hu>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Laszlo Attila Toth <panther@balabit.hu>
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1195564470928-git-send-email-panther@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Interface groups let handle different interfaces together.
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
index 1e6af4f..b1bdcb2 100644
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
index 20cb67e..a710813 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -614,6 +614,7 @@ static inline size_t if_nlmsg_size(const struct net_device *dev)
 	       + nla_total_size(4) /* IFLA_MTU */
 	       + nla_total_size(4) /* IFLA_LINK */
 	       + nla_total_size(4) /* IFLA_MASTER */
+	       + nla_total_size(4) /* IFLA_IFGROUP */
 	       + nla_total_size(1) /* IFLA_OPERSTATE */
 	       + nla_total_size(1) /* IFLA_LINKMODE */
 	       + rtnl_link_get_size(dev); /* IFLA_LINKINFO */
@@ -651,6 +652,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (dev->master)
 		NLA_PUT_U32(skb, IFLA_MASTER, dev->master->ifindex);
 
+	if (dev->ifgroup)
+		NLA_PUT_U32(skb, IFLA_IFGROUP, dev->ifgroup);
+
 	if (dev->qdisc_sleeping)
 		NLA_PUT_STRING(skb, IFLA_QDISC, dev->qdisc_sleeping->ops->id);
 
@@ -890,6 +894,13 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		}
 	}
 
+	if (tb[IFLA_IFGROUP]) {
+		if (dev->ifgroup != nla_get_u32(tb[IFLA_IFGROUP])) {
+			dev->ifgroup = nla_get_u32(tb[IFLA_IFGROUP]);
+			modified = 1;
+		}
+	}
+
 	err = 0;
 
 errout:
-- 
1.5.2.5

