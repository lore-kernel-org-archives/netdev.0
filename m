From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC 4/7] wimax: use genl_register_family_with_ops()
Date: Thu, 14 Nov 2013 10:14:43 +0100
Message-ID: <1384420486-8713-5-git-send-email-johannes@sipsolutions.net>
References: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>
Cc: Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:47798 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437Ab3KNJOw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 04:14:52 -0500
In-Reply-To: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

This simplifies the code since there's no longer a need to
have error handling in the registration.

Unfortunately it means more extern function declarations are
needed, but the overall goal would seem to justify this.

Due to the removal of duplication in the netlink policies,
this reduces the size of wimax by almost 1k.

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 net/wimax/op-msg.c         | 25 ---------------
 net/wimax/op-reset.c       | 17 ----------
 net/wimax/op-rfkill.c      | 21 ------------
 net/wimax/op-state-get.c   | 17 ----------
 net/wimax/stack.c          | 79 +++++++++++++++++++++++-----------------------
 net/wimax/wimax-internal.h |  7 ++++
 6 files changed, 47 insertions(+), 119 deletions(-)

diff --git a/net/wimax/op-msg.c b/net/wimax/op-msg.c
index 0694d62..ff19cbe 100644
--- a/net/wimax/op-msg.c
+++ b/net/wimax/op-msg.c
@@ -321,17 +321,6 @@ int wimax_msg(struct wimax_dev *wimax_dev, const char *pipe_name,
 }
 EXPORT_SYMBOL_GPL(wimax_msg);
 
-
-static const struct nla_policy wimax_gnl_msg_policy[WIMAX_GNL_ATTR_MAX + 1] = {
-	[WIMAX_GNL_MSG_IFIDX] = {
-		.type = NLA_U32,
-	},
-	[WIMAX_GNL_MSG_DATA] = {
-		.type = NLA_UNSPEC,	/* libnl doesn't grok BINARY yet */
-	},
-};
-
-
 /*
  * Relays a message from user space to the driver
  *
@@ -340,7 +329,6 @@ static const struct nla_policy wimax_gnl_msg_policy[WIMAX_GNL_ATTR_MAX + 1] = {
  *
  * This call will block while handling/relaying the message.
  */
-static
 int wimax_gnl_doit_msg_from_user(struct sk_buff *skb, struct genl_info *info)
 {
 	int result, ifindex;
@@ -418,16 +406,3 @@ error_no_wimax_dev:
 	return result;
 }
 
-
-/*
- * Generic Netlink glue
- */
-
-struct genl_ops wimax_gnl_msg_from_user = {
-	.cmd = WIMAX_GNL_OP_MSG_FROM_USER,
-	.flags = GENL_ADMIN_PERM,
-	.policy = wimax_gnl_msg_policy,
-	.doit = wimax_gnl_doit_msg_from_user,
-	.dumpit = NULL,
-};
-
diff --git a/net/wimax/op-reset.c b/net/wimax/op-reset.c
index 7ceffe3..eb45807 100644
--- a/net/wimax/op-reset.c
+++ b/net/wimax/op-reset.c
@@ -92,13 +92,6 @@ int wimax_reset(struct wimax_dev *wimax_dev)
 EXPORT_SYMBOL(wimax_reset);
 
 
-static const struct nla_policy wimax_gnl_reset_policy[WIMAX_GNL_ATTR_MAX + 1] = {
-	[WIMAX_GNL_RESET_IFIDX] = {
-		.type = NLA_U32,
-	},
-};
-
-
 /*
  * Exporting to user space over generic netlink
  *
@@ -106,7 +99,6 @@ static const struct nla_policy wimax_gnl_reset_policy[WIMAX_GNL_ATTR_MAX + 1] =
  *
  * No attributes.
  */
-static
 int wimax_gnl_doit_reset(struct sk_buff *skb, struct genl_info *info)
 {
 	int result, ifindex;
@@ -130,12 +122,3 @@ error_no_wimax_dev:
 	d_fnend(3, NULL, "(skb %p info %p) = %d\n", skb, info, result);
 	return result;
 }
-
-
-struct genl_ops wimax_gnl_reset = {
-	.cmd = WIMAX_GNL_OP_RESET,
-	.flags = GENL_ADMIN_PERM,
-	.policy = wimax_gnl_reset_policy,
-	.doit = wimax_gnl_doit_reset,
-	.dumpit = NULL,
-};
diff --git a/net/wimax/op-rfkill.c b/net/wimax/op-rfkill.c
index 7ab60ba..403078d 100644
--- a/net/wimax/op-rfkill.c
+++ b/net/wimax/op-rfkill.c
@@ -411,17 +411,6 @@ void wimax_rfkill_rm(struct wimax_dev *wimax_dev)
  * just query).
  */
 
-static const struct nla_policy wimax_gnl_rfkill_policy[WIMAX_GNL_ATTR_MAX + 1] = {
-	[WIMAX_GNL_RFKILL_IFIDX] = {
-		.type = NLA_U32,
-	},
-	[WIMAX_GNL_RFKILL_STATE] = {
-		.type = NLA_U32		/* enum wimax_rf_state */
-	},
-};
-
-
-static
 int wimax_gnl_doit_rfkill(struct sk_buff *skb, struct genl_info *info)
 {
 	int result, ifindex;
@@ -457,13 +446,3 @@ error_no_wimax_dev:
 	d_fnend(3, NULL, "(skb %p info %p) = %d\n", skb, info, result);
 	return result;
 }
-
-
-struct genl_ops wimax_gnl_rfkill = {
-	.cmd = WIMAX_GNL_OP_RFKILL,
-	.flags = GENL_ADMIN_PERM,
-	.policy = wimax_gnl_rfkill_policy,
-	.doit = wimax_gnl_doit_rfkill,
-	.dumpit = NULL,
-};
-
diff --git a/net/wimax/op-state-get.c b/net/wimax/op-state-get.c
index aff8776..995c08c 100644
--- a/net/wimax/op-state-get.c
+++ b/net/wimax/op-state-get.c
@@ -33,13 +33,6 @@
 #include "debug-levels.h"
 
 
-static const struct nla_policy wimax_gnl_state_get_policy[WIMAX_GNL_ATTR_MAX + 1] = {
-	[WIMAX_GNL_STGET_IFIDX] = {
-		.type = NLA_U32,
-	},
-};
-
-
 /*
  * Exporting to user space over generic netlink
  *
@@ -48,7 +41,6 @@ static const struct nla_policy wimax_gnl_state_get_policy[WIMAX_GNL_ATTR_MAX + 1
  *
  * No attributes.
  */
-static
 int wimax_gnl_doit_state_get(struct sk_buff *skb, struct genl_info *info)
 {
 	int result, ifindex;
@@ -72,12 +64,3 @@ error_no_wimax_dev:
 	d_fnend(3, NULL, "(skb %p info %p) = %d\n", skb, info, result);
 	return result;
 }
-
-
-struct genl_ops wimax_gnl_state_get = {
-	.cmd = WIMAX_GNL_OP_STATE_GET,
-	.flags = GENL_ADMIN_PERM,
-	.policy = wimax_gnl_state_get_policy,
-	.doit = wimax_gnl_doit_state_get,
-	.dumpit = NULL,
-};
diff --git a/net/wimax/stack.c b/net/wimax/stack.c
index a6470ac..4b7f15a 100644
--- a/net/wimax/stack.c
+++ b/net/wimax/stack.c
@@ -402,22 +402,44 @@ void wimax_dev_init(struct wimax_dev *wimax_dev)
 }
 EXPORT_SYMBOL_GPL(wimax_dev_init);
 
-/*
- * This extern is declared here because it's easier to keep track --
- * both declarations are a list of the same
- */
-extern struct genl_ops
-	wimax_gnl_msg_from_user,
-	wimax_gnl_reset,
-	wimax_gnl_rfkill,
-	wimax_gnl_state_get;
+static const struct nla_policy wimax_gnl_policy[WIMAX_GNL_ATTR_MAX + 1] = {
+	[WIMAX_GNL_RESET_IFIDX] = { .type = NLA_U32, },
+	[WIMAX_GNL_RFKILL_IFIDX] = { .type = NLA_U32, },
+	[WIMAX_GNL_RFKILL_STATE] = {
+		.type = NLA_U32		/* enum wimax_rf_state */
+	},
+	[WIMAX_GNL_STGET_IFIDX] = { .type = NLA_U32, },
+	[WIMAX_GNL_MSG_IFIDX] = { .type = NLA_U32, },
+	[WIMAX_GNL_MSG_DATA] = {
+		.type = NLA_UNSPEC,	/* libnl doesn't grok BINARY yet */
+	},
+};
 
-static
-struct genl_ops *wimax_gnl_ops[] = {
-	&wimax_gnl_msg_from_user,
-	&wimax_gnl_reset,
-	&wimax_gnl_rfkill,
-	&wimax_gnl_state_get,
+static struct genl_ops wimax_gnl_ops[] = {
+	{
+		.cmd = WIMAX_GNL_OP_MSG_FROM_USER,
+		.flags = GENL_ADMIN_PERM,
+		.policy = wimax_gnl_policy,
+		.doit = wimax_gnl_doit_msg_from_user,
+	},
+	{
+		.cmd = WIMAX_GNL_OP_RESET,
+		.flags = GENL_ADMIN_PERM,
+		.policy = wimax_gnl_policy,
+		.doit = wimax_gnl_doit_reset,
+	},
+	{
+		.cmd = WIMAX_GNL_OP_RFKILL,
+		.flags = GENL_ADMIN_PERM,
+		.policy = wimax_gnl_policy,
+		.doit = wimax_gnl_doit_rfkill,
+	},
+	{
+		.cmd = WIMAX_GNL_OP_STATE_GET,
+		.flags = GENL_ADMIN_PERM,
+		.policy = wimax_gnl_policy,
+		.doit = wimax_gnl_doit_state_get,
+	},
 };
 
 
@@ -567,7 +589,7 @@ struct genl_multicast_group wimax_gnl_mcg = {
 static
 int __init wimax_subsys_init(void)
 {
-	int result, cnt;
+	int result;
 
 	d_fnstart(4, NULL, "()\n");
 	d_parse_params(D_LEVEL, D_LEVEL_SIZE, wimax_debug_params,
@@ -575,26 +597,14 @@ int __init wimax_subsys_init(void)
 
 	snprintf(wimax_gnl_family.name, sizeof(wimax_gnl_family.name),
 		 "WiMAX");
-	result = genl_register_family(&wimax_gnl_family);
+	result = genl_register_family_with_ops(&wimax_gnl_family, wimax_gnl_ops,
+					       ARRAY_SIZE(wimax_gnl_ops));
 	if (unlikely(result < 0)) {
 		printk(KERN_ERR "cannot register generic netlink family: %d\n",
 		       result);
 		goto error_register_family;
 	}
 
-	for (cnt = 0; cnt < ARRAY_SIZE(wimax_gnl_ops); cnt++) {
-		result = genl_register_ops(&wimax_gnl_family,
-					   wimax_gnl_ops[cnt]);
-		d_printf(4, NULL, "registering generic netlink op code "
-			 "%u: %d\n", wimax_gnl_ops[cnt]->cmd, result);
-		if (unlikely(result < 0)) {
-			printk(KERN_ERR "cannot register generic netlink op "
-			       "code %u: %d\n",
-			       wimax_gnl_ops[cnt]->cmd, result);
-			goto error_register_ops;
-		}
-	}
-
 	result = genl_register_mc_group(&wimax_gnl_family, &wimax_gnl_mcg);
 	if (result < 0)
 		goto error_mc_group;
@@ -602,10 +612,6 @@ int __init wimax_subsys_init(void)
 	return 0;
 
 error_mc_group:
-error_register_ops:
-	for (cnt--; cnt >= 0; cnt--)
-		genl_unregister_ops(&wimax_gnl_family,
-				    wimax_gnl_ops[cnt]);
 	genl_unregister_family(&wimax_gnl_family);
 error_register_family:
 	d_fnend(4, NULL, "() = %d\n", result);
@@ -619,12 +625,7 @@ module_init(wimax_subsys_init);
 static
 void __exit wimax_subsys_exit(void)
 {
-	int cnt;
 	wimax_id_table_release();
-	genl_unregister_mc_group(&wimax_gnl_family, &wimax_gnl_mcg);
-	for (cnt = ARRAY_SIZE(wimax_gnl_ops) - 1; cnt >= 0; cnt--)
-		genl_unregister_ops(&wimax_gnl_family,
-				    wimax_gnl_ops[cnt]);
 	genl_unregister_family(&wimax_gnl_family);
 }
 module_exit(wimax_subsys_exit);
diff --git a/net/wimax/wimax-internal.h b/net/wimax/wimax-internal.h
index 5dcd9c0..8567d30 100644
--- a/net/wimax/wimax-internal.h
+++ b/net/wimax/wimax-internal.h
@@ -84,8 +84,15 @@ void wimax_id_table_release(void);
 int wimax_rfkill_add(struct wimax_dev *);
 void wimax_rfkill_rm(struct wimax_dev *);
 
+/* generic netlink */
 extern struct genl_family wimax_gnl_family;
 extern struct genl_multicast_group wimax_gnl_mcg;
 
+/* ops */
+int wimax_gnl_doit_msg_from_user(struct sk_buff *skb, struct genl_info *info);
+int wimax_gnl_doit_reset(struct sk_buff *skb, struct genl_info *info);
+int wimax_gnl_doit_rfkill(struct sk_buff *skb, struct genl_info *info);
+int wimax_gnl_doit_state_get(struct sk_buff *skb, struct genl_info *info);
+
 #endif /* #ifdef __KERNEL__ */
 #endif /* #ifndef __WIMAX_INTERNAL_H__ */
-- 
1.8.4.rc3
