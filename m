From: David Gibson <david@gibson.dropbear.id.au>
Subject: [PATCH 2/2] rtnetlink: Only supply IFLA_VF_PORTS information when RTEXT_FILTER_VF is set
Date: Wed, 23 Apr 2014 17:21:05 +1000
Message-ID: <1398237665-26980-3-git-send-email-david@gibson.dropbear.id.au>
References: <1398237665-26980-1-git-send-email-david@gibson.dropbear.id.au>
Cc: ssujith@cisco.com, neepatel@cisco.com, benve@cisco.com,
	davem@davemloft.net, ben@decadent.org.uk,
	govindarajulu90@gmail.com, gregory.v.rose@intel.com,
	David Gibson <david@gibson.dropbear.id.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:51402 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756804AbaDWHVJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 03:21:09 -0400
In-Reply-To: <1398237665-26980-1-git-send-email-david@gibson.dropbear.id.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 115c9b81928360d769a76c632bae62d15206a94a (rtnetlink: Fix problem with
buffer allocation), RTM_NEWLINK messages only contain the IFLA_VFINFO_LIST
attribute if they were solicited by a GETLINK message containing an
IFLA_EXT_MASK attribute with the RTEXT_FILTER_VF flag.

That was done because some user programs broke when they received more data
than expected - because IFLA_VFINFO_LIST contains information for each VF
it can become large if there are many VFs.

However, the IFLA_VF_PORTS attribute, supplied for devices which implement
ndo_get_vf_port (currently the 'enic' driver only), has the same problem.
It supplies per-VF information and can therefore become large, but it is
not currently conditional on the IFLA_EXT_MASK value.

Worse, it interacts badly with the existing EXT_MASK handling.  When
IFLA_EXT_MASK is not supplied, the buffer for netlink replies is fixed at
NLMSG_GOODSIZE.  If the information for IFLA_VF_PORTS exceeds this, then
rtnl_fill_ifinfo() returns -EMSGSIZE on the first message in a packet.
netlink_dump() will misinterpret this as having finished the listing and
omit data for this interface and all subsequent ones.  That can cause
getifaddrs(3) to enter an infinite loop.

This patch addresses the problem by only supplying IFLA_VF_PORTS when
IFLA_EXT_MASK is supplied with the RTEXT_FILTER_VF flag set.

Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
---
 net/core/rtnetlink.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 5331db2..32a1287 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -774,7 +774,8 @@ static inline int rtnl_vfinfo_size(const struct net_device *dev,
 		return 0;
 }
 
-static size_t rtnl_port_size(const struct net_device *dev)
+static size_t rtnl_port_size(const struct net_device *dev,
+			     u32 ext_filter_mask)
 {
 	size_t port_size = nla_total_size(4)		/* PORT_VF */
 		+ nla_total_size(PORT_PROFILE_MAX)	/* PORT_PROFILE */
@@ -790,7 +791,8 @@ static size_t rtnl_port_size(const struct net_device *dev)
 	size_t port_self_size = nla_total_size(sizeof(struct nlattr))
 		+ port_size;
 
-	if (!dev->netdev_ops->ndo_get_vf_port || !dev->dev.parent)
+	if (!dev->netdev_ops->ndo_get_vf_port || !dev->dev.parent
+	    || !(ext_filter_mask & RTEXT_FILTER_VF))
 		return 0;
 	if (dev_num_vf(dev->dev.parent))
 		return port_self_size + vf_ports_size +
@@ -826,7 +828,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + nla_total_size(ext_filter_mask
 			        & RTEXT_FILTER_VF ? 4 : 0) /* IFLA_NUM_VF */
 	       + rtnl_vfinfo_size(dev, ext_filter_mask) /* IFLA_VFINFO_LIST */
-	       + rtnl_port_size(dev) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
+	       + rtnl_port_size(dev, ext_filter_mask) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
 	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
 	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
 	       + nla_total_size(MAX_PHYS_PORT_ID_LEN); /* IFLA_PHYS_PORT_ID */
@@ -888,11 +890,13 @@ static int rtnl_port_self_fill(struct sk_buff *skb, struct net_device *dev)
 	return 0;
 }
 
-static int rtnl_port_fill(struct sk_buff *skb, struct net_device *dev)
+static int rtnl_port_fill(struct sk_buff *skb, struct net_device *dev,
+			  u32 ext_filter_mask)
 {
 	int err;
 
-	if (!dev->netdev_ops->ndo_get_vf_port || !dev->dev.parent)
+	if (!dev->netdev_ops->ndo_get_vf_port || !dev->dev.parent
+	    || !(ext_filter_mask & RTEXT_FILTER_VF))
 		return 0;
 
 	err = rtnl_port_self_fill(skb, dev);
@@ -1079,7 +1083,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 		nla_nest_end(skb, vfinfo);
 	}
 
-	if (rtnl_port_fill(skb, dev))
+	if (rtnl_port_fill(skb, dev, ext_filter_mask))
 		goto nla_put_failure;
 
 	if (dev->rtnl_link_ops || rtnl_have_link_slave_info(dev)) {
-- 
1.9.0
