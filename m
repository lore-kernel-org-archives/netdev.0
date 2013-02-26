From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH] core: Add ioctls to control device unicast hw addresses
Date: Tue, 26 Feb 2013 14:44:22 -0500
Message-ID: <1361907862-13009-1-git-send-email-vyasevic@redhat.com>
References: <20130226.124322.28904104699526114.davem@davemloft.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43249 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759602Ab3BZToZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Feb 2013 14:44:25 -0500
In-Reply-To: <20130226.124322.28904104699526114.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> No new ioctls please, extend the netlink interfaces as necessary
> instead.
>
> Thanks.

So, something like below patch (compiled only) would be better in your opinion?
The one concern I have is that there is no way to probe for the availabilty
of this functionality, since netlink will just ignore unknown types and appear
to succeed.  With an ioctl it is clear if the support is present.

-- >8 --


[RFC PATCH] rtnetlink: Add support for adding/removing additional hw addresses.

Add an ability to add and remove HW addresses to the device
unicast and multicast address lists.  Right now, we only have
an ioctl() to manage the multicast addresses and there is no
way the manage the unicast list.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/uapi/linux/if_link.h   |    3 +
 include/uapi/linux/rtnetlink.h |    1 +
 net/core/rtnetlink.c           |   84 +++++++++++++++++++++++++++++++++++++++-
 3 files changed, 87 insertions(+), 1 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index c4edfe1..7933a1c 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -143,6 +143,9 @@ enum {
 	IFLA_NUM_TX_QUEUES,
 	IFLA_NUM_RX_QUEUES,
 	IFLA_CARRIER,
+	IFLA_HW_ADDR_ADD,
+	IFLA_HW_ADDR_DEL,
+	IFLA_HW_ADDR_LIST,
 	__IFLA_MAX
 };
 
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 7a2144e..4d6f1c9 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -631,6 +631,7 @@ struct tcamsg {
 /* New extended info filters for IFLA_EXT_MASK */
 #define RTEXT_FILTER_VF		(1 << 0)
 #define RTEXT_FILTER_BRVLAN	(1 << 1)
+#define RTEXT_FILTER_MACLIST	(1 << 2)
 
 /* End of information exported to user level */
 
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d8aa20f..4df2ff1 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -763,6 +763,20 @@ static size_t rtnl_port_size(const struct net_device *dev)
 		return port_self_size;
 }
 
+static size_t rtnl_maclist_size(const struct net_device *dev,
+				u32 ext_filter_mask)
+{
+	size_t size = 0;
+
+	if (ext_filter_mask & RTEXT_FILTER_MACLIST) {
+		size = nla_total_size(sizeof(struct nlattr)) +
+			nla_total_size(ETH_ALEN) *
+			(netdev_uc_count(dev) + netdev_mc_count(dev));
+	}
+
+	return size;
+}
+
 static noinline size_t if_nlmsg_size(const struct net_device *dev,
 				     u32 ext_filter_mask)
 {
@@ -790,6 +804,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 			        & RTEXT_FILTER_VF ? 4 : 0) /* IFLA_NUM_VF */
 	       + rtnl_vfinfo_size(dev, ext_filter_mask) /* IFLA_VFINFO_LIST */
 	       + rtnl_port_size(dev) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
+	       + rtnl_maclist_size(dev, ext_filter_mask) /* IFLA_MAC_LIST */
 	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
 	       + rtnl_link_get_af_size(dev); /* IFLA_AF_SPEC */
 }
@@ -870,6 +885,39 @@ static int rtnl_port_fill(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
+static int rtnl_hwaddr_fill(struct sk_buff *skb, struct net_device *dev,
+			    u32 ext_filter_mask)
+{
+	struct netdev_hw_addr *ha;
+	struct nlattr *hw_list;
+
+	if (!(ext_filter_mask & RTEXT_FILTER_MACLIST))
+		return 0;
+
+	if ((netdev_uc_count(dev) + netdev_mc_count(dev)) == 0)
+		return 0;
+
+	hw_list = nla_nest_start(skb, IFLA_HW_ADDR_LIST);
+	if (!hw_list)
+		return -EMSGSIZE;
+
+	/* Unicasts first */
+	netdev_for_each_uc_addr(ha, dev) {
+		if (nla_put(skb, IFLA_ADDRESS, ETH_ALEN, ha->addr))
+			goto nla_put_fail;
+	}
+
+	/* Now multicasts */
+	netdev_for_each_mc_addr(ha, dev) {
+		if (nla_put(skb, IFLA_ADDRESS, ETH_ALEN, ha->addr))
+			goto nla_put_fail;
+	}
+
+nla_put_fail:
+	nla_nest_cancel(skb, hw_list);
+	return -EMSGSIZE;
+}
+
 static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			    int type, u32 pid, u32 seq, u32 change,
 			    unsigned int flags, u32 ext_filter_mask)
@@ -1044,6 +1092,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 		}
 	}
 
+	if (rtnl_hwaddr_fill(skb, dev, ext_filter_mask))
+		goto nla_put_failure;
+
 	nla_nest_end(skb, af_spec);
 
 	return nlmsg_end(skb, nlh);
@@ -1128,6 +1179,8 @@ const struct nla_policy ifla_policy[IFLA_MAX+1] = {
 	[IFLA_PROMISCUITY]	= { .type = NLA_U32 },
 	[IFLA_NUM_TX_QUEUES]	= { .type = NLA_U32 },
 	[IFLA_NUM_RX_QUEUES]	= { .type = NLA_U32 },
+	[IFLA_HW_ADDR_ADD]	= { .type = NLA_BINARY, .len = ETH_ALEN },
+	[IFLA_HW_ADDR_DEL]	= { .type = NLA_BINARY, .len = ETH_ALEN },
 };
 EXPORT_SYMBOL(ifla_policy);
 
@@ -1527,7 +1580,36 @@ static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
 			modified = 1;
 		}
 	}
-	err = 0;
+
+	if (tb[IFLA_HW_ADDR_ADD]) {
+		const unsigned char *addr;
+
+		addr = nla_data(tb[IFLA_HW_ADDR_ADD]);
+
+		if (is_unicast_ether_addr(addr))
+			err = dev_uc_add_excl(dev, addr);
+		else if (is_multicast_ether_addr(addr))
+			err = dev_mc_add_excl(dev, addr);
+
+		if (err)
+			goto errout;
+		modified = 1;
+	}
+
+	if (tb[IFLA_HW_ADDR_DEL]) {
+		const unsigned char *addr;
+
+		addr = nla_data(tb[IFLA_HW_ADDR_DEL]);
+
+		if (is_unicast_ether_addr(addr))
+			err = dev_uc_del(dev, addr);
+		else if (is_multicast_ether_addr(addr))
+			err = dev_mc_del(dev, addr);
+
+		if (err)
+			goto errout;
+		modified = 1;
+	}
 
 errout:
 	if (err < 0 && modified)
-- 
1.7.7.6
