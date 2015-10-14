From: Ronen Arad <ronen.arad@intel.com>
Subject: [PATCH net-next 3/4] rtnetlink: Prefer filtering-aware af sizing
Date: Tue, 13 Oct 2015 22:58:33 -0700
Message-ID: <1444802314-28830-4-git-send-email-ronen.arad@intel.com>
References: <1444802314-28830-1-git-send-email-ronen.arad@intel.com>
Cc: Ronen Arad <ronen.arad@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:30704 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752137AbbJNF73 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 01:59:29 -0400
In-Reply-To: <1444802314-28830-1-git-send-email-ronen.arad@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ext_filter_mask arg to rtnl_link_get_af_size().
rtnl_link_get_af_size() will prefer filtering-aware af sizing when
provided by an address family. It falls back to get_link_af_size for
other families.

Signed-off-by: Ronen Arad <ronen.arad@intel.com>
---
 net/core/rtnetlink.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 2477595..dd7cda7 100644
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
@@ -506,7 +507,12 @@ static size_t rtnl_link_get_af_size(const struct net_device *dev)
 	size = nla_total_size(sizeof(struct nlattr));
 
 	list_for_each_entry(af_ops, &rtnl_af_ops, list) {
-		if (af_ops->get_link_af_size) {
+		/* Prefer filtering-aware af sizing when available */
+		if (af_ops->get_link_af_size_filtered) {
+			/* AF_* + nested data */
+			size += nla_total_size(sizeof(struct nlattr)) +
+				af_ops->get_link_af_size_filtered(dev, ext_filter_mask);
+		} else if (af_ops->get_link_af_size) {
 			/* AF_* + nested data */
 			size += nla_total_size(sizeof(struct nlattr)) +
 				af_ops->get_link_af_size(dev);
@@ -900,7 +906,7 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
 	       + rtnl_vfinfo_size(dev, ext_filter_mask) /* IFLA_VFINFO_LIST */
 	       + rtnl_port_size(dev, ext_filter_mask) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
 	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
-	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
+	       + rtnl_link_get_af_size(dev, ext_filter_mask) /* IFLA_AF_SPEC */
 	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_PORT_ID */
 	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_SWITCH_ID */
 	       + nla_total_size(1); /* IFLA_PROTO_DOWN */
-- 
2.1.0
