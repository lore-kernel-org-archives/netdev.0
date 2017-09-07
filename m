From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH iproute2 1/4] devlink: Make match/action parsing more flexible
Date: Thu,  7 Sep 2017 17:26:40 +0300
Message-ID: <1504794403-45690-2-git-send-email-arkadis@mellanox.com>
References: <1504794403-45690-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, stephen@networkplumber.org, jiri@resnulli.us,
        mlxsw@mellanox.com, andrew@lunn.ch,
        Arkadi Sharshevsky <arkadis@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40332 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1755300AbdIGOYH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 10:24:07 -0400
In-Reply-To: <1504794403-45690-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch decouples the match/action parsing from printing. This is
done as a preparation for adding the ability to print global header
values, for example print IPv4 address, which require special formatting.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 devlink/devlink.c | 127 ++++++++++++++++++++++++++++++++++--------------------
 1 file changed, 80 insertions(+), 47 deletions(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index 8f11f86..36a2b36 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -3077,27 +3077,42 @@ static const char
 	}
 }
 
-static void pr_out_dpipe_action(struct dpipe_ctx *ctx,
-				uint32_t header_id, uint32_t field_id,
-				uint32_t action_type, bool global)
+struct dpipe_op_info {
+	uint32_t header_id;
+	uint32_t field_id;
+	bool header_global;
+};
+
+struct dpipe_action {
+	struct dpipe_op_info info;
+	uint32_t type;
+};
+
+static void pr_out_dpipe_action(struct dpipe_action *action,
+				struct dpipe_ctx *ctx)
 {
+	struct dpipe_op_info *op_info = &action->info;
 	const char *mapping;
 
-	pr_out_str(ctx->dl, "type", dpipe_action_type_e2s(action_type));
-	pr_out_str(ctx->dl, "header", dpipe_header_id2s(ctx, header_id,
-							global));
-	pr_out_str(ctx->dl, "field", dpipe_field_id2s(ctx, header_id, field_id,
-						      global));
-	mapping = dpipe_mapping_get(ctx, header_id, field_id, global);
+	pr_out_str(ctx->dl, "type",
+		   dpipe_action_type_e2s(action->type));
+	pr_out_str(ctx->dl, "header",
+		   dpipe_header_id2s(ctx, op_info->header_id,
+				     op_info->header_global));
+	pr_out_str(ctx->dl, "field",
+		   dpipe_field_id2s(ctx, op_info->header_id,
+				    op_info->field_id,
+				    op_info->header_global));
+	mapping = dpipe_mapping_get(ctx, op_info->header_id,
+				    op_info->field_id,
+				    op_info->header_global);
 	if (mapping)
 		pr_out_str(ctx->dl, "mapping", mapping);
 }
 
-static int dpipe_action_show(struct dpipe_ctx *ctx, struct nlattr *nl)
+static int dpipe_action_parse(struct dpipe_action *action, struct nlattr *nl)
 {
 	struct nlattr *nla_action[DEVLINK_ATTR_MAX + 1] = {};
-	uint32_t header_id, field_id, action_type;
-	bool global;
 	int err;
 
 	err = mnl_attr_parse_nested(nl, attr_cb, nla_action);
@@ -3111,12 +3126,11 @@ static int dpipe_action_show(struct dpipe_ctx *ctx, struct nlattr *nl)
 		return -EINVAL;
 	}
 
-	header_id = mnl_attr_get_u32(nla_action[DEVLINK_ATTR_DPIPE_HEADER_ID]);
-	field_id = mnl_attr_get_u32(nla_action[DEVLINK_ATTR_DPIPE_FIELD_ID]);
-	action_type = mnl_attr_get_u32(nla_action[DEVLINK_ATTR_DPIPE_ACTION_TYPE]);
-	global = !!mnl_attr_get_u8(nla_action[DEVLINK_ATTR_DPIPE_HEADER_GLOBAL]);
+	action->type = mnl_attr_get_u32(nla_action[DEVLINK_ATTR_DPIPE_ACTION_TYPE]);
+	action->info.header_id = mnl_attr_get_u32(nla_action[DEVLINK_ATTR_DPIPE_HEADER_ID]);
+	action->info.field_id = mnl_attr_get_u32(nla_action[DEVLINK_ATTR_DPIPE_FIELD_ID]);
+	action->info.header_global = !!mnl_attr_get_u8(nla_action[DEVLINK_ATTR_DPIPE_HEADER_GLOBAL]);
 
-	pr_out_dpipe_action(ctx, header_id, field_id, action_type, global);
 	return 0;
 }
 
@@ -3124,16 +3138,18 @@ static int dpipe_table_actions_show(struct dpipe_ctx *ctx,
 				    struct nlattr *nla_actions)
 {
 	struct nlattr *nla_action;
+	struct dpipe_action action;
 
 	mnl_attr_for_each_nested(nla_action, nla_actions) {
 		pr_out_entry_start(ctx->dl);
-		if (dpipe_action_show(ctx, nla_action))
-			goto err_action_show;
+		if (dpipe_action_parse(&action, nla_action))
+			goto err_action_parse;
+		pr_out_dpipe_action(&action, ctx);
 		pr_out_entry_end(ctx->dl);
 	}
 	return 0;
 
-err_action_show:
+err_action_parse:
 	pr_out_entry_end(ctx->dl);
 	return -EINVAL;
 }
@@ -3149,28 +3165,38 @@ dpipe_match_type_e2s(enum devlink_dpipe_match_type match_type)
 	}
 }
 
-static void pr_out_dpipe_match(struct dpipe_ctx *ctx,
-			       uint32_t header_id, uint32_t field_id,
-			       uint32_t match_type, bool global)
+struct dpipe_match {
+	struct dpipe_op_info info;
+	uint32_t type;
+};
+
+static void pr_out_dpipe_match(struct dpipe_match *match,
+			       struct dpipe_ctx *ctx)
 {
+	struct dpipe_op_info *op_info = &match->info;
 	const char *mapping;
 
-	pr_out_str(ctx->dl, "type", dpipe_match_type_e2s(match_type));
-	pr_out_str(ctx->dl, "header", dpipe_header_id2s(ctx, header_id,
-							global));
-	pr_out_str(ctx->dl, "field", dpipe_field_id2s(ctx, header_id, field_id,
-						      global));
-	mapping = dpipe_mapping_get(ctx, header_id, field_id, global);
+	pr_out_str(ctx->dl, "type",
+		   dpipe_match_type_e2s(match->type));
+	pr_out_str(ctx->dl, "header",
+		   dpipe_header_id2s(ctx, op_info->header_id,
+				     op_info->header_global));
+	pr_out_str(ctx->dl, "field",
+		   dpipe_field_id2s(ctx, op_info->header_id,
+				    op_info->field_id,
+				    op_info->header_global));
+	mapping = dpipe_mapping_get(ctx, op_info->header_id,
+				    op_info->field_id,
+				    op_info->header_global);
 	if (mapping)
 		pr_out_str(ctx->dl, "mapping", mapping);
-
 }
 
-static int dpipe_match_show(struct dpipe_ctx *ctx, struct nlattr *nl)
+static int dpipe_match_parse(struct dpipe_match *match,
+			     struct nlattr *nl)
+
 {
 	struct nlattr *nla_match[DEVLINK_ATTR_MAX + 1] = {};
-	uint32_t header_id, field_id, match_type;
-	bool global;
 	int err;
 
 	err = mnl_attr_parse_nested(nl, attr_cb, nla_match);
@@ -3184,12 +3210,11 @@ static int dpipe_match_show(struct dpipe_ctx *ctx, struct nlattr *nl)
 		return -EINVAL;
 	}
 
-	match_type = mnl_attr_get_u32(nla_match[DEVLINK_ATTR_DPIPE_MATCH_TYPE]);
-	header_id = mnl_attr_get_u32(nla_match[DEVLINK_ATTR_DPIPE_HEADER_ID]);
-	field_id = mnl_attr_get_u32(nla_match[DEVLINK_ATTR_DPIPE_FIELD_ID]);
-	global = !!mnl_attr_get_u8(nla_match[DEVLINK_ATTR_DPIPE_HEADER_GLOBAL]);
+	match->type = mnl_attr_get_u32(nla_match[DEVLINK_ATTR_DPIPE_MATCH_TYPE]);
+	match->info.header_id = mnl_attr_get_u32(nla_match[DEVLINK_ATTR_DPIPE_HEADER_ID]);
+	match->info.field_id = mnl_attr_get_u32(nla_match[DEVLINK_ATTR_DPIPE_FIELD_ID]);
+	match->info.header_global = !!mnl_attr_get_u8(nla_match[DEVLINK_ATTR_DPIPE_HEADER_GLOBAL]);
 
-	pr_out_dpipe_match(ctx, header_id, field_id, match_type, global);
 	return 0;
 }
 
@@ -3197,16 +3222,18 @@ static int dpipe_table_matches_show(struct dpipe_ctx *ctx,
 				    struct nlattr *nla_matches)
 {
 	struct nlattr *nla_match;
+	struct dpipe_match match;
 
 	mnl_attr_for_each_nested(nla_match, nla_matches) {
 		pr_out_entry_start(ctx->dl);
-		if (dpipe_match_show(ctx, nla_match))
-			goto err_match_show;
+		if (dpipe_match_parse(&match, nla_match))
+			goto err_match_parse;
+		pr_out_dpipe_match(&match, ctx);
 		pr_out_entry_end(ctx->dl);
 	}
 	return 0;
 
-err_match_show:
+err_match_parse:
 	pr_out_entry_end(ctx->dl);
 	return -EINVAL;
 }
@@ -3382,6 +3409,7 @@ static int dpipe_entry_match_value_show(struct dpipe_ctx *ctx,
 					struct nlattr *nl)
 {
 	struct nlattr *nla_match_value[DEVLINK_ATTR_MAX + 1] = {};
+	struct dpipe_match match;
 	int err;
 
 	err = mnl_attr_parse_nested(nl, attr_cb, nla_match_value);
@@ -3394,16 +3422,18 @@ static int dpipe_entry_match_value_show(struct dpipe_ctx *ctx,
 	}
 
 	pr_out_entry_start(ctx->dl);
-	if (dpipe_match_show(ctx, nla_match_value[DEVLINK_ATTR_DPIPE_MATCH]))
-		goto err_match_show;
+	if (dpipe_match_parse(&match,
+			      nla_match_value[DEVLINK_ATTR_DPIPE_MATCH]))
+		goto err_match_parse;
+	pr_out_dpipe_match(&match, ctx);
 	if (dpipe_entry_value_show(ctx, nla_match_value))
 		goto err_value_show;
 	pr_out_entry_end(ctx->dl);
 
 	return 0;
 
-err_match_show:
 err_value_show:
+err_match_parse:
 	pr_out_entry_end(ctx->dl);
 	return -EINVAL;
 }
@@ -3412,6 +3442,7 @@ static int dpipe_entry_action_value_show(struct dpipe_ctx *ctx,
 					 struct nlattr *nl)
 {
 	struct nlattr *nla_action_value[DEVLINK_ATTR_MAX + 1] = {};
+	struct dpipe_action action;
 	int err;
 
 	err = mnl_attr_parse_nested(nl, attr_cb, nla_action_value);
@@ -3424,16 +3455,18 @@ static int dpipe_entry_action_value_show(struct dpipe_ctx *ctx,
 	}
 
 	pr_out_entry_start(ctx->dl);
-	if (dpipe_action_show(ctx, nla_action_value[DEVLINK_ATTR_DPIPE_ACTION]))
-		goto err_action_show;
+	if (dpipe_action_parse(&action,
+			       nla_action_value[DEVLINK_ATTR_DPIPE_ACTION]))
+		goto err_action_parse;
+	pr_out_dpipe_action(&action, ctx);
 	if (dpipe_entry_value_show(ctx, nla_action_value))
 		goto err_value_show;
 	pr_out_entry_end(ctx->dl);
 
 	return 0;
 
-err_action_show:
 err_value_show:
+err_action_parse:
 	pr_out_entry_end(ctx->dl);
 	return -EINVAL;
 }
-- 
2.4.11
