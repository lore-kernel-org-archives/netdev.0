From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 3/9] ieee802154: use genl_register_family_with_ops()
Date: Thu, 14 Nov 2013 17:14:41 +0100
Message-ID: <1384445687-30948-4-git-send-email-johannes@sipsolutions.net>
References: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>
 <1384445687-30948-1-git-send-email-johannes@sipsolutions.net>
Cc: linux-wimax@intel.com, Balbir Singh <bsingharora@gmail.com>,
	netfilter-devel@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:49284 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754848Ab3KNQOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 11:14:54 -0500
In-Reply-To: <1384445687-30948-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

This simplifies the code since there's no longer a need to
have error handling in the registration.

Unfortunately it means more extern function declarations are
needed, but the overall goal would seem to justify this.

While at it, also fix the registration error path - if the
family registration failed then it shouldn't be unregistered.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/ieee802154/ieee802154.h | 19 ++++++++++++--
 net/ieee802154/netlink.c    | 28 +++++++++++++++------
 net/ieee802154/nl-mac.c     | 61 +++++++--------------------------------------
 net/ieee802154/nl-phy.c     | 37 +++------------------------
 4 files changed, 51 insertions(+), 94 deletions(-)

diff --git a/net/ieee802154/ieee802154.h b/net/ieee802154/ieee802154.h
index aadec42..14d5dab 100644
--- a/net/ieee802154/ieee802154.h
+++ b/net/ieee802154/ieee802154.h
@@ -47,7 +47,22 @@ struct sk_buff *ieee802154_nl_new_reply(struct genl_info *info,
 int ieee802154_nl_reply(struct sk_buff *msg, struct genl_info *info);
 
 extern struct genl_family nl802154_family;
-int nl802154_mac_register(void);
-int nl802154_phy_register(void);
+
+/* genetlink ops/groups */
+int ieee802154_list_phy(struct sk_buff *skb, struct genl_info *info);
+int ieee802154_dump_phy(struct sk_buff *skb, struct netlink_callback *cb);
+int ieee802154_add_iface(struct sk_buff *skb, struct genl_info *info);
+int ieee802154_del_iface(struct sk_buff *skb, struct genl_info *info);
+
+extern struct genl_multicast_group ieee802154_coord_mcgrp;
+extern struct genl_multicast_group ieee802154_beacon_mcgrp;
+
+int ieee802154_associate_req(struct sk_buff *skb, struct genl_info *info);
+int ieee802154_associate_resp(struct sk_buff *skb, struct genl_info *info);
+int ieee802154_disassociate_req(struct sk_buff *skb, struct genl_info *info);
+int ieee802154_scan_req(struct sk_buff *skb, struct genl_info *info);
+int ieee802154_start_req(struct sk_buff *skb, struct genl_info *info);
+int ieee802154_list_iface(struct sk_buff *skb, struct genl_info *info);
+int ieee802154_dump_iface(struct sk_buff *skb, struct netlink_callback *cb);
 
 #endif
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 7e49bbc..eb9faef 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -109,24 +109,39 @@ out:
 	return -ENOBUFS;
 }
 
+static struct genl_ops ieee8021154_ops[] = {
+	/* see nl-phy.c */
+	IEEE802154_DUMP(IEEE802154_LIST_PHY, ieee802154_list_phy,
+			ieee802154_dump_phy),
+	IEEE802154_OP(IEEE802154_ADD_IFACE, ieee802154_add_iface),
+	IEEE802154_OP(IEEE802154_DEL_IFACE, ieee802154_del_iface),
+	/* see nl-mac.c */
+	IEEE802154_OP(IEEE802154_ASSOCIATE_REQ, ieee802154_associate_req),
+	IEEE802154_OP(IEEE802154_ASSOCIATE_RESP, ieee802154_associate_resp),
+	IEEE802154_OP(IEEE802154_DISASSOCIATE_REQ, ieee802154_disassociate_req),
+	IEEE802154_OP(IEEE802154_SCAN_REQ, ieee802154_scan_req),
+	IEEE802154_OP(IEEE802154_START_REQ, ieee802154_start_req),
+	IEEE802154_DUMP(IEEE802154_LIST_IFACE, ieee802154_list_iface,
+			ieee802154_dump_iface),
+};
+
 int __init ieee802154_nl_init(void)
 {
 	int rc;
 
-	rc = genl_register_family(&nl802154_family);
+	rc = genl_register_family_with_ops(&nl802154_family, ieee8021154_ops,
+					   ARRAY_SIZE(ieee8021154_ops));
 	if (rc)
-		goto fail;
+		return rc;
 
-	rc = nl802154_mac_register();
+	rc = genl_register_mc_group(&nl802154_family, &ieee802154_coord_mcgrp);
 	if (rc)
 		goto fail;
 
-	rc = nl802154_phy_register();
+	rc = genl_register_mc_group(&nl802154_family, &ieee802154_beacon_mcgrp);
 	if (rc)
 		goto fail;
-
 	return 0;
-
 fail:
 	genl_unregister_family(&nl802154_family);
 	return rc;
@@ -136,4 +151,3 @@ void __exit ieee802154_nl_exit(void)
 {
 	genl_unregister_family(&nl802154_family);
 }
-
diff --git a/net/ieee802154/nl-mac.c b/net/ieee802154/nl-mac.c
index b0bdd8c..28d4930 100644
--- a/net/ieee802154/nl-mac.c
+++ b/net/ieee802154/nl-mac.c
@@ -39,11 +39,11 @@
 
 #include "ieee802154.h"
 
-static struct genl_multicast_group ieee802154_coord_mcgrp = {
+struct genl_multicast_group ieee802154_coord_mcgrp = {
 	.name		= IEEE802154_MCAST_COORD_NAME,
 };
 
-static struct genl_multicast_group ieee802154_beacon_mcgrp = {
+struct genl_multicast_group ieee802154_beacon_mcgrp = {
 	.name		= IEEE802154_MCAST_BEACON_NAME,
 };
 
@@ -309,8 +309,7 @@ static struct net_device *ieee802154_nl_get_dev(struct genl_info *info)
 	return dev;
 }
 
-static int ieee802154_associate_req(struct sk_buff *skb,
-		struct genl_info *info)
+int ieee802154_associate_req(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net_device *dev;
 	struct ieee802154_addr addr;
@@ -357,8 +356,7 @@ out:
 	return ret;
 }
 
-static int ieee802154_associate_resp(struct sk_buff *skb,
-		struct genl_info *info)
+int ieee802154_associate_resp(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net_device *dev;
 	struct ieee802154_addr addr;
@@ -390,8 +388,7 @@ out:
 	return ret;
 }
 
-static int ieee802154_disassociate_req(struct sk_buff *skb,
-		struct genl_info *info)
+int ieee802154_disassociate_req(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net_device *dev;
 	struct ieee802154_addr addr;
@@ -433,7 +430,7 @@ out:
  * PAN_coordinator, battery_life_extension = 0,
  * coord_realignment = 0, security_enable = 0
 */
-static int ieee802154_start_req(struct sk_buff *skb, struct genl_info *info)
+int ieee802154_start_req(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net_device *dev;
 	struct ieee802154_addr addr;
@@ -492,7 +489,7 @@ out:
 	return ret;
 }
 
-static int ieee802154_scan_req(struct sk_buff *skb, struct genl_info *info)
+int ieee802154_scan_req(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net_device *dev;
 	int ret = -EOPNOTSUPP;
@@ -530,8 +527,7 @@ out:
 	return ret;
 }
 
-static int ieee802154_list_iface(struct sk_buff *skb,
-	struct genl_info *info)
+int ieee802154_list_iface(struct sk_buff *skb, struct genl_info *info)
 {
 	/* Request for interface name, index, type, IEEE address,
 	   PAN Id, short address */
@@ -565,8 +561,7 @@ out_dev:
 
 }
 
-static int ieee802154_dump_iface(struct sk_buff *skb,
-	struct netlink_callback *cb)
+int ieee802154_dump_iface(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct net *net = sock_net(skb->sk);
 	struct net_device *dev;
@@ -590,41 +585,3 @@ cont:
 
 	return skb->len;
 }
-
-static struct genl_ops ieee802154_coordinator_ops[] = {
-	IEEE802154_OP(IEEE802154_ASSOCIATE_REQ, ieee802154_associate_req),
-	IEEE802154_OP(IEEE802154_ASSOCIATE_RESP, ieee802154_associate_resp),
-	IEEE802154_OP(IEEE802154_DISASSOCIATE_REQ, ieee802154_disassociate_req),
-	IEEE802154_OP(IEEE802154_SCAN_REQ, ieee802154_scan_req),
-	IEEE802154_OP(IEEE802154_START_REQ, ieee802154_start_req),
-	IEEE802154_DUMP(IEEE802154_LIST_IFACE, ieee802154_list_iface,
-							ieee802154_dump_iface),
-};
-
-/*
- * No need to unregister as family unregistration will do it.
- */
-int nl802154_mac_register(void)
-{
-	int i;
-	int rc;
-
-	rc = genl_register_mc_group(&nl802154_family,
-			&ieee802154_coord_mcgrp);
-	if (rc)
-		return rc;
-
-	rc = genl_register_mc_group(&nl802154_family,
-			&ieee802154_beacon_mcgrp);
-	if (rc)
-		return rc;
-
-	for (i = 0; i < ARRAY_SIZE(ieee802154_coordinator_ops); i++) {
-		rc = genl_register_ops(&nl802154_family,
-				&ieee802154_coordinator_ops[i]);
-		if (rc)
-			return rc;
-	}
-
-	return 0;
-}
diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index 22b1a70..d08c7a4 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -77,8 +77,7 @@ out:
 	return -EMSGSIZE;
 }
 
-static int ieee802154_list_phy(struct sk_buff *skb,
-	struct genl_info *info)
+int ieee802154_list_phy(struct sk_buff *skb, struct genl_info *info)
 {
 	/* Request for interface name, index, type, IEEE address,
 	   PAN Id, short address */
@@ -151,8 +150,7 @@ static int ieee802154_dump_phy_iter(struct wpan_phy *phy, void *_data)
 	return 0;
 }
 
-static int ieee802154_dump_phy(struct sk_buff *skb,
-	struct netlink_callback *cb)
+int ieee802154_dump_phy(struct sk_buff *skb, struct netlink_callback *cb)
 {
 	struct dump_phy_data data = {
 		.cb = cb,
@@ -170,8 +168,7 @@ static int ieee802154_dump_phy(struct sk_buff *skb,
 	return skb->len;
 }
 
-static int ieee802154_add_iface(struct sk_buff *skb,
-		struct genl_info *info)
+int ieee802154_add_iface(struct sk_buff *skb, struct genl_info *info)
 {
 	struct sk_buff *msg;
 	struct wpan_phy *phy;
@@ -273,8 +270,7 @@ out_dev:
 	return rc;
 }
 
-static int ieee802154_del_iface(struct sk_buff *skb,
-		struct genl_info *info)
+int ieee802154_del_iface(struct sk_buff *skb, struct genl_info *info)
 {
 	struct sk_buff *msg;
 	struct wpan_phy *phy;
@@ -356,28 +352,3 @@ out_dev:
 
 	return rc;
 }
-
-static struct genl_ops ieee802154_phy_ops[] = {
-	IEEE802154_DUMP(IEEE802154_LIST_PHY, ieee802154_list_phy,
-							ieee802154_dump_phy),
-	IEEE802154_OP(IEEE802154_ADD_IFACE, ieee802154_add_iface),
-	IEEE802154_OP(IEEE802154_DEL_IFACE, ieee802154_del_iface),
-};
-
-/*
- * No need to unregister as family unregistration will do it.
- */
-int nl802154_phy_register(void)
-{
-	int i;
-	int rc;
-
-	for (i = 0; i < ARRAY_SIZE(ieee802154_phy_ops); i++) {
-		rc = genl_register_ops(&nl802154_family,
-				&ieee802154_phy_ops[i]);
-		if (rc)
-			return rc;
-	}
-
-	return 0;
-}
-- 
1.8.4.rc3
