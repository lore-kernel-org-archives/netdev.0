From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: [PATCH iproute2 2/4] devlink: Add support for special format protocol headers
Date: Thu,  7 Sep 2017 17:26:41 +0300
Message-ID: <1504794403-45690-3-git-send-email-arkadis@mellanox.com>
References: <1504794403-45690-1-git-send-email-arkadis@mellanox.com>
Cc: davem@davemloft.net, stephen@networkplumber.org, jiri@resnulli.us,
        mlxsw@mellanox.com, andrew@lunn.ch,
        Arkadi Sharshevsky <arkadis@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40330 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754273AbdIGOYH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 10:24:07 -0400
In-Reply-To: <1504794403-45690-1-git-send-email-arkadis@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of global header (protocol header), the header:field ids are used
to perform lookup for special format printer. In case no printer existence
fallback to plain value printing.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 devlink/devlink.c | 119 ++++++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 94 insertions(+), 25 deletions(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index 36a2b36..b87de38 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -3372,9 +3372,89 @@ static int cmd_dpipe_table_set(struct dl *dl)
 	return _mnlg_socket_sndrcv(dl->nlg, nlh, NULL, NULL);
 }
 
-static int dpipe_entry_value_show(struct dpipe_ctx *ctx,
-				  struct nlattr **nla_match_value)
+enum dpipe_value_type {
+	DPIPE_VALUE_TYPE_VALUE,
+	DPIPE_VALUE_TYPE_MASK,
+};
+
+static const char *
+dpipe_value_type_e2s(enum dpipe_value_type type)
+{
+	switch (type) {
+	case DPIPE_VALUE_TYPE_VALUE:
+		return "value";
+	case DPIPE_VALUE_TYPE_MASK:
+		return "value_mask";
+	default:
+		return "<unknown>";
+	}
+}
+
+struct dpipe_field_printer {
+	unsigned int field_id;
+	void (*printer)(struct dpipe_ctx *, enum dpipe_value_type, void *);
+};
+
+struct dpipe_header_printer {
+	struct dpipe_field_printer *printers;
+	unsigned int printers_count;
+	unsigned int header_id;
+};
+
+static struct dpipe_header_printer *dpipe_header_printers[] = {};
+
+static int dpipe_print_prot_header(struct dpipe_ctx *ctx,
+				   struct dpipe_op_info *info,
+				   enum dpipe_value_type type,
+				   void *value)
 {
+	unsigned int header_printers_count = ARRAY_SIZE(dpipe_header_printers);
+	struct dpipe_header_printer *header_printer;
+	struct dpipe_field_printer *field_printer;
+	unsigned int field_printers_count;
+	int j;
+	int i;
+
+	for (i = 0; i < header_printers_count; i++) {
+		header_printer = dpipe_header_printers[i];
+		if (header_printer->header_id != info->header_id)
+			continue;
+		field_printers_count = header_printer->printers_count;
+		for (j = 0; j < field_printers_count; j++) {
+			field_printer = &header_printer->printers[j];
+			if (field_printer->field_id != info->field_id)
+				continue;
+			field_printer->printer(ctx, type, value);
+			return 0;
+		}
+	}
+
+	return -EINVAL;
+}
+
+static void __pr_out_entry_value(struct dpipe_ctx *ctx,
+				 void *value,
+				 unsigned int value_len,
+				 struct dpipe_op_info *info,
+				 enum dpipe_value_type type)
+{
+	if (info->header_global &&
+	    !dpipe_print_prot_header(ctx, info, type, value))
+		return;
+
+	if (value_len == sizeof(uint32_t)) {
+		uint32_t *value_32 = value;
+
+		pr_out_uint(ctx->dl, dpipe_value_type_e2s(type), *value_32);
+	}
+}
+
+static void pr_out_dpipe_entry_value(struct dpipe_ctx *ctx,
+				     struct nlattr **nla_match_value,
+				     struct dpipe_op_info *info)
+{
+	void *value, *value_mask;
+	uint32_t value_mapping;
 	uint16_t value_len;
 	bool mask, mapping;
 
@@ -3382,27 +3462,20 @@ static int dpipe_entry_value_show(struct dpipe_ctx *ctx,
 	mapping = !!nla_match_value[DEVLINK_ATTR_DPIPE_VALUE_MAPPING];
 
 	value_len = mnl_attr_get_payload_len(nla_match_value[DEVLINK_ATTR_DPIPE_VALUE]);
-	if (value_len == sizeof(uint32_t)) {
-		uint32_t value, value_mask, value_mapping;
-
-		if (mapping) {
-			value_mapping = mnl_attr_get_u32(nla_match_value[DEVLINK_ATTR_DPIPE_VALUE_MAPPING]);
-			pr_out_uint(ctx->dl, "mapping_value", value_mapping);
-		}
-
-		if (mask) {
-			value_mask = mnl_attr_get_u32(nla_match_value[DEVLINK_ATTR_DPIPE_VALUE_MASK]);
-			pr_out_uint(ctx->dl, "mask_value", value_mask);
-		}
+	value = mnl_attr_get_payload(nla_match_value[DEVLINK_ATTR_DPIPE_VALUE]);
 
-		value = mnl_attr_get_u32(nla_match_value[DEVLINK_ATTR_DPIPE_VALUE]);
-		pr_out_uint(ctx->dl, "value", value);
+	if (mapping) {
+		value_mapping = mnl_attr_get_u32(nla_match_value[DEVLINK_ATTR_DPIPE_VALUE_MAPPING]);
+		pr_out_uint(ctx->dl, "mapping_value", value_mapping);
+	}
 
-	} else {
-		return -EINVAL;
+	if (mask) {
+		value_mask = mnl_attr_get_payload(nla_match_value[DEVLINK_ATTR_DPIPE_VALUE]);
+		__pr_out_entry_value(ctx, value_mask, value_len, info,
+				     DPIPE_VALUE_TYPE_MASK);
 	}
 
-	return 0;
+	__pr_out_entry_value(ctx, value, value_len, info, DPIPE_VALUE_TYPE_VALUE);
 }
 
 static int dpipe_entry_match_value_show(struct dpipe_ctx *ctx,
@@ -3426,13 +3499,11 @@ static int dpipe_entry_match_value_show(struct dpipe_ctx *ctx,
 			      nla_match_value[DEVLINK_ATTR_DPIPE_MATCH]))
 		goto err_match_parse;
 	pr_out_dpipe_match(&match, ctx);
-	if (dpipe_entry_value_show(ctx, nla_match_value))
-		goto err_value_show;
+	pr_out_dpipe_entry_value(ctx, nla_match_value, &match.info);
 	pr_out_entry_end(ctx->dl);
 
 	return 0;
 
-err_value_show:
 err_match_parse:
 	pr_out_entry_end(ctx->dl);
 	return -EINVAL;
@@ -3459,13 +3530,11 @@ static int dpipe_entry_action_value_show(struct dpipe_ctx *ctx,
 			       nla_action_value[DEVLINK_ATTR_DPIPE_ACTION]))
 		goto err_action_parse;
 	pr_out_dpipe_action(&action, ctx);
-	if (dpipe_entry_value_show(ctx, nla_action_value))
-		goto err_value_show;
+	pr_out_dpipe_entry_value(ctx, nla_action_value, &action.info);
 	pr_out_entry_end(ctx->dl);
 
 	return 0;
 
-err_value_show:
 err_action_parse:
 	pr_out_entry_end(ctx->dl);
 	return -EINVAL;
-- 
2.4.11
