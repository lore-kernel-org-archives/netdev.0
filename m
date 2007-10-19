From: Laszlo Attila Toth <panther@balabit.hu>
Subject: [IFGROUPv3 2/3] Interface group: core (netlink) part
Date: Fri, 19 Oct 2007 18:30:00 +0200
Message-ID: <11928114034113-git-send-email-panther@balabit.hu>
References: <11928114032187-git-send-email-panther@balabit.hu>
 <119281140331-git-send-email-panther@balabit.hu>
Cc: Laszlo Attila Toth <panther@balabit.hu>
To: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <119281140331-git-send-email-panther@balabit.hu>
Message-Id: <b304cea2e4e1659e9e7e58c0303b21a8e03b6688.1192810837.git.panther@balabit.hu>
In-Reply-To: <80da3aa904080a33dd4645a8390c96133268a512.1192810837.git.panther@balabit.hu>
References: <80da3aa904080a33dd4645a8390c96133268a512.1192810837.git.panther@balabit.hu>
In-Reply-To: <20071019-181844-1192810724.panther@balabit.hu>
References: <20071019-181844-1192810724.panther@balabit.hu>From: Laszlo Attila Toth <panther@balabit.hu>
Sender: netfilter-devel-owner@vger.kernel.org
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
index 422084d..d9f1726 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -78,6 +78,8 @@ enum
 	IFLA_LINKMODE,
 	IFLA_LINKINFO,
 #define IFLA_LINKINFO IFLA_LINKINFO
+	IFLA_IFGROUP,
+#define IFLA_IFGROUP IFLA_IFGROUP
 	__IFLA_MAX
 };
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e679b27..c489a20 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -365,6 +365,8 @@ struct net_device
 	/* Interface index. Unique device identifier	*/
 	int			ifindex;
 	int			iflink;
+	/* interface group this interface belongs to */
+	u_int32_t		ifgroup;
 
 
 	struct net_device_stats* (*get_stats)(struct net_device *dev);
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 53af13f..de38c03 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -608,6 +608,7 @@ static inline size_t if_nlmsg_size(const struct net_device *dev)
 	       + nla_total_size(4) /* IFLA_MTU */
 	       + nla_total_size(4) /* IFLA_LINK */
 	       + nla_total_size(4) /* IFLA_MASTER */
+	       + nla_total_size(4) /* IFLA_IFGROUP */
 	       + nla_total_size(1) /* IFLA_OPERSTATE */
 	       + nla_total_size(1) /* IFLA_LINKMODE */
 	       + rtnl_link_get_size(dev); /* IFLA_LINKINFO */
@@ -646,6 +647,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 	if (dev->master)
 		NLA_PUT_U32(skb, IFLA_MASTER, dev->master->ifindex);
 
+	if (dev->ifgroup)
+		NLA_PUT_U32(skb, IFLA_IFGROUP, dev->ifgroup);
+
 	if (dev->qdisc_sleeping)
 		NLA_PUT_STRING(skb, IFLA_QDISC, dev->qdisc_sleeping->ops->id);
 
@@ -861,6 +865,13 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 		modified = 1;
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

