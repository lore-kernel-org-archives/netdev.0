From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 2/9] hsr: use genl_register_family_with_ops()
Date: Thu, 14 Nov 2013 17:14:40 +0100
Message-ID: <1384445687-30948-3-git-send-email-johannes@sipsolutions.net>
References: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>
 <1384445687-30948-1-git-send-email-johannes@sipsolutions.net>
Cc: linux-wimax@intel.com, Balbir Singh <bsingharora@gmail.com>,
	netfilter-devel@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1384445687-30948-1-git-send-email-johannes@sipsolutions.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes.berg@intel.com>

This simplifies the code since there's no longer a
need to have error handling in the registration.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/hsr/hsr_netlink.c | 46 +++++++++++++++++-----------------------------
 1 file changed, 17 insertions(+), 29 deletions(-)

diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index 4e66bf6..8f52a9f 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -306,15 +306,6 @@ fail:
 	return res;
 }
 
-static struct genl_ops hsr_ops_get_node_status = {
-	.cmd = HSR_C_GET_NODE_STATUS,
-	.flags = 0,
-	.policy = hsr_genl_policy,
-	.doit = hsr_get_node_status,
-	.dumpit = NULL,
-};
-
-
 /* Get a list of MacAddressA of all nodes known to this node (other than self).
  */
 static int hsr_get_node_list(struct sk_buff *skb_in, struct genl_info *info)
@@ -398,12 +389,21 @@ fail:
 }
 
 
-static struct genl_ops hsr_ops_get_node_list = {
-	.cmd = HSR_C_GET_NODE_LIST,
-	.flags = 0,
-	.policy = hsr_genl_policy,
-	.doit = hsr_get_node_list,
-	.dumpit = NULL,
+static struct genl_ops hsr_ops[] = {
+	{
+		.cmd = HSR_C_GET_NODE_STATUS,
+		.flags = 0,
+		.policy = hsr_genl_policy,
+		.doit = hsr_get_node_status,
+		.dumpit = NULL,
+	},
+	{
+		.cmd = HSR_C_GET_NODE_LIST,
+		.flags = 0,
+		.policy = hsr_genl_policy,
+		.doit = hsr_get_node_list,
+		.dumpit = NULL,
+	},
 };
 
 int __init hsr_netlink_init(void)
@@ -414,18 +414,11 @@ int __init hsr_netlink_init(void)
 	if (rc)
 		goto fail_rtnl_link_register;
 
-	rc = genl_register_family(&hsr_genl_family);
+	rc = genl_register_family_with_ops(&hsr_genl_family, hsr_ops,
+					   ARRAY_SIZE(hsr_ops));
 	if (rc)
 		goto fail_genl_register_family;
 
-	rc = genl_register_ops(&hsr_genl_family, &hsr_ops_get_node_status);
-	if (rc)
-		goto fail_genl_register_ops;
-
-	rc = genl_register_ops(&hsr_genl_family, &hsr_ops_get_node_list);
-	if (rc)
-		goto fail_genl_register_ops_node_list;
-
 	rc = genl_register_mc_group(&hsr_genl_family, &hsr_network_genl_mcgrp);
 	if (rc)
 		goto fail_genl_register_mc_group;
@@ -433,10 +426,6 @@ int __init hsr_netlink_init(void)
 	return 0;
 
 fail_genl_register_mc_group:
-	genl_unregister_ops(&hsr_genl_family, &hsr_ops_get_node_list);
-fail_genl_register_ops_node_list:
-	genl_unregister_ops(&hsr_genl_family, &hsr_ops_get_node_status);
-fail_genl_register_ops:
 	genl_unregister_family(&hsr_genl_family);
 fail_genl_register_family:
 	rtnl_link_unregister(&hsr_link_ops);
@@ -448,7 +437,6 @@ fail_rtnl_link_register:
 void __exit hsr_netlink_exit(void)
 {
 	genl_unregister_mc_group(&hsr_genl_family, &hsr_network_genl_mcgrp);
-	genl_unregister_ops(&hsr_genl_family, &hsr_ops_get_node_status);
 	genl_unregister_family(&hsr_genl_family);
 
 	rtnl_link_unregister(&hsr_link_ops);
-- 
1.8.4.rc3

