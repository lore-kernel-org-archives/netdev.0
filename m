From: Ronen Arad <ronen.arad@intel.com>
Subject: [PATCH net-next v2] netlink: Rightsize IFLA_AF_SPEC size calculation
Date: Wed, 14 Oct 2015 08:51:28 -0700
Message-ID: <1444837888-32656-1-git-send-email-ronen.arad@intel.com>
References: <1444802314-28830-1-git-send-email-ronen.arad@intel.com>
Cc: Ronen Arad <ronen.arad@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:2191 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753652AbbJNPvu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 11:51:50 -0400
In-Reply-To: <1444802314-28830-1-git-send-email-ronen.arad@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a v2 of a 4-parts patch with same subject.
Giving up on backward compatibility allows for much simplified single patch.

if_nlmsg_size() overestimates the minimum allocation size of netlink
dump request (when called from rtnl_calcit()) or the size of the
message (when called from rtnl_getlink()). This is because
ext_filter_mask is not supported by rtnl_link_get_af_size() and
rtnl_link_get_size().

The over-estimation is significant when at least one netdev has many
VLANs configured (8 bytes for each configured VLAN).

This patch-set "rightsizes" the protocol specific attribute size
calculation by propagating ext_filter_mask to rtnl_link_get_af_size()
and adding this a argument to get_link_af_size op in rtnl_af_ops.

Bridge module already used filtering aware sizing for notifications.
br_get_link_af_size_filtered() is consistent with the modified
get_link_af_size op so it replaces br_get_link_af_size() in br_af_ops.
br_get_link_af_size() becomes unused and thus removed.
---
 include/net/rtnetlink.h |  3 ++-
 net/bridge/br_netlink.c | 21 +--------------------
 net/core/rtnetlink.c    |  8 ++++----
 net/ipv4/devinet.c      |  4 ++--
 net/ipv6/addrconf.c     |  3 ++-
 5 files changed, 11 insertions(+), 28 deletions(-)

diff --git a/include/net/rtnetlink.h b/include/net/rtnetlink.h
index aff6ceb..2f87c1b 100644
--- a/include/net/rtnetlink.h
+++ b/include/net/rtnetlink.h
@@ -124,7 +124,8 @@ struct rtnl_af_ops {
 	int			(*fill_link_af)(struct sk_buff *skb,
 						const struct net_device *dev,
 						u32 ext_filter_mask);
-	size_t			(*get_link_af_size)(const struct net_device *dev);
+	size_t			(*get_link_af_size)(const struct net_device *dev,
+						    u32 ext_filter_mask);

 	int			(*validate_link_af)(const struct net_device *dev,
 						    const struct nlattr *attr);
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 94b4de8..40197ff 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -1214,29 +1214,10 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	return 0;
 }

-static size_t br_get_link_af_size(const struct net_device *dev)
-{
-	struct net_bridge_port *p;
-	struct net_bridge *br;
-	int num_vlans = 0;
-
-	if (br_port_exists(dev)) {
-		p = br_port_get_rtnl(dev);
-		num_vlans = br_get_num_vlan_infos(nbp_vlan_group(p),
-						  RTEXT_FILTER_BRVLAN);
-	} else if (dev->priv_flags & IFF_EBRIDGE) {
-		br = netdev_priv(dev);
-		num_vlans = br_get_num_vlan_infos(br_vlan_group(br),
-						  RTEXT_FILTER_BRVLAN);
-	}
-
-	/* Each VLAN is returned in bridge_vlan_info along with flags */
-	return num_vlans * nla_total_size(sizeof(struct bridge_vlan_info));
-}

 static struct rtnl_af_ops br_af_ops __read_mostly = {
 	.family			= AF_BRIDGE,
-	.get_link_af_size	= br_get_link_af_size,
+	.get_link_af_size	= br_get_link_af_size_filtered,
 };

 struct rtnl_link_ops br_link_ops __read_mostly = {
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2477595..581aec4 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -497,7 +497,8 @@ void rtnl_af_unregister(struct rtnl_af_ops *ops)
 }
 EXPORT_SYMBOL_GPL(rtnl_af_unregister);

-static size_t rtnl_link_get_af_size(const struct net_device *dev)
+static size_t rtnl_link_get_af_size(const struct net_device *dev,
+				    u32 ext_filter_mask)
 {
 	struct rtnl_af_ops *af_ops;
 	size_t size;
@@ -509,7 +510,7 @@ static size_t rtnl_link_get_af_size(const struct net_device *dev)
 		if (af_ops->get_link_af_size) {
 			/* AF_* + nested data */
 			size += nla_total_size(sizeof(struct nlattr)) +
-				af_ops->get_link_af_size(dev);
+				af_ops->get_link_af_size(dev, ext_filter_mask);
 		}
 	}

@@ -900,7 +901,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + rtnl_vfinfo_size(dev, ext_filter_mask) /* IFLA_VFINFO_LIST */
 	       + rtnl_port_size(dev, ext_filter_mask) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
 	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
-	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
+		+ rtnl_link_get_af_size(dev, ext_filter_mask) /* IFLA_AF_SPEC */
 	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_PORT_ID */
 	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_SWITCH_ID */
 	       + nla_total_size(1); /* IFLA_PROTO_DOWN */
@@ -3443,4 +3444,3 @@ void __init rtnetlink_init(void)
 	rtnl_register(PF_BRIDGE, RTM_DELLINK, rtnl_bridge_dellink, NULL, NULL);
 	rtnl_register(PF_BRIDGE, RTM_SETLINK, rtnl_bridge_setlink, NULL, NULL);
 }
-
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 7350084..cebd9d3 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1644,7 +1644,8 @@ errout:
 		rtnl_set_sk_err(net, RTNLGRP_IPV4_IFADDR, err);
 }

-static size_t inet_get_link_af_size(const struct net_device *dev)
+static size_t inet_get_link_af_size(const struct net_device *dev,
+				    u32 ext_filter_mask)
 {
 	struct in_device *in_dev = rcu_dereference_rtnl(dev->ip_ptr);

@@ -2398,4 +2399,3 @@ void __init devinet_init(void)
 	rtnl_register(PF_INET, RTM_GETNETCONF, inet_netconf_get_devconf,
 		      inet_netconf_dump_devconf, NULL);
 }
-
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index f0326aa..0645fd1 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4786,7 +4786,8 @@ nla_put_failure:
 	return -EMSGSIZE;
 }

-static size_t inet6_get_link_af_size(const struct net_device *dev)
+static size_t inet6_get_link_af_size(const struct net_device *dev,
+				     u32 ext_filter_mask)
 {
 	if (!__in6_dev_get(dev))
 		return 0;
--
2.1.0
