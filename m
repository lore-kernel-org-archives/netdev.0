From: Roi Dayan <roid@mellanox.com>
Subject: [PATCH iproute2] devlink: Add option to set and show eswitch encapsulation support
Date: Sun, 21 May 2017 08:37:27 +0300
Message-ID: <1495345047-55019-1-git-send-email-roid@mellanox.com>
Cc: netdev@vger.kernel.org, Paul Blakey <paulb@mellanox.com>,
        Shahar Klein <shahark@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>, Roi Dayan <roid@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39330 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750822AbdEUFhq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 01:37:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an e-switch global knob to enable HW support for applying
encapsulation/decapsulation to VF traffic as part of SRIOV e-switch offloading.

The actual encap/decap is carried out (along with the matching and other
actions) per offloaded e-switch rules, e.g as done when offloading the TC tunnel
key action.

Possible values are enable/disable.

Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Jiri Pirko <jiri@mellanox.com>
---
 devlink/devlink.c      | 48 +++++++++++++++++++++++++++++++++++++++++++++++-
 man/man8/devlink-dev.8 | 13 +++++++++++++
 2 files changed, 60 insertions(+), 1 deletion(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index e22ee0a..f9bc16c 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -176,6 +176,7 @@ static void ifname_map_free(struct ifname_map *ifname_map)
 #define DL_OPT_ESWITCH_INLINE_MODE	BIT(12)
 #define DL_OPT_DPIPE_TABLE_NAME	BIT(13)
 #define DL_OPT_DPIPE_TABLE_COUNTERS	BIT(14)
+#define DL_OPT_ESWITCH_ENCAP_MODE	BIT(15)
 
 struct dl_opts {
 	uint32_t present; /* flags of present items */
@@ -195,6 +196,7 @@ struct dl_opts {
 	enum devlink_eswitch_inline_mode eswitch_inline_mode;
 	const char *dpipe_table_name;
 	bool dpipe_counters_enable;
+	bool eswitch_encap_mode;
 };
 
 struct dl {
@@ -299,6 +301,7 @@ static const enum mnl_attr_data_type devlink_policy[DEVLINK_ATTR_MAX + 1] = {
 	[DEVLINK_ATTR_SB_OCC_MAX] = MNL_TYPE_U32,
 	[DEVLINK_ATTR_ESWITCH_MODE] = MNL_TYPE_U16,
 	[DEVLINK_ATTR_ESWITCH_INLINE_MODE] = MNL_TYPE_U8,
+	[DEVLINK_ATTR_ESWITCH_ENCAP_MODE] = MNL_TYPE_U8,
 	[DEVLINK_ATTR_DPIPE_TABLES] = MNL_TYPE_NESTED,
 	[DEVLINK_ATTR_DPIPE_TABLE] = MNL_TYPE_NESTED,
 	[DEVLINK_ATTR_DPIPE_TABLE_NAME] = MNL_TYPE_STRING,
@@ -754,6 +757,19 @@ static int dpipe_counters_enable_get(const char *typestr,
 	return 0;
 }
 
+static int eswitch_encap_mode_get(const char *typestr, bool *p_mode)
+{
+	if (strcmp(typestr, "enable") == 0) {
+		*p_mode = true;
+	} else if (strcmp(typestr, "disable") == 0) {
+		*p_mode = false;
+	} else {
+		pr_err("Unknown eswitch encap mode \"%s\"\n", typestr);
+		return -EINVAL;
+	}
+	return 0;
+}
+
 static int dl_argv_parse(struct dl *dl, uint32_t o_required,
 			 uint32_t o_optional)
 {
@@ -908,7 +924,19 @@ static int dl_argv_parse(struct dl *dl, uint32_t o_required,
 			if (err)
 				return err;
 			o_found |= DL_OPT_DPIPE_TABLE_COUNTERS;
+		} else if (dl_argv_match(dl, "encap") &&
+			   (o_all & DL_OPT_ESWITCH_ENCAP_MODE)) {
+			const char *typestr;
 
+			dl_arg_inc(dl);
+			err = dl_argv_str(dl, &typestr);
+			if (err)
+				return err;
+			err = eswitch_encap_mode_get(typestr,
+						     &opts->eswitch_encap_mode);
+			if (err)
+				return err;
+			o_found |= DL_OPT_ESWITCH_ENCAP_MODE;
 		} else {
 			pr_err("Unknown option \"%s\"\n", dl_argv(dl));
 			return -EINVAL;
@@ -986,6 +1014,13 @@ static int dl_argv_parse(struct dl *dl, uint32_t o_required,
 		pr_err("Dpipe table counter state expected\n");
 		return -EINVAL;
 	}
+
+	if ((o_required & DL_OPT_ESWITCH_ENCAP_MODE) &&
+	    !(o_found & DL_OPT_ESWITCH_ENCAP_MODE)) {
+		pr_err("E-Switch encapsulation option expected.\n");
+		return -EINVAL;
+	}
+
 	return 0;
 }
 
@@ -1041,6 +1076,9 @@ static void dl_opts_put(struct nlmsghdr *nlh, struct dl *dl)
 	if (opts->present & DL_OPT_DPIPE_TABLE_COUNTERS)
 		mnl_attr_put_u8(nlh, DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED,
 				opts->dpipe_counters_enable);
+	if (opts->present & DL_OPT_ESWITCH_ENCAP_MODE)
+		mnl_attr_put_u8(nlh, DEVLINK_ATTR_ESWITCH_ENCAP_MODE,
+				opts->eswitch_encap_mode);
 }
 
 static int dl_argv_parse_put(struct nlmsghdr *nlh, struct dl *dl,
@@ -1097,6 +1135,7 @@ static void cmd_dev_help(void)
 	pr_err("Usage: devlink dev show [ DEV ]\n");
 	pr_err("       devlink dev eswitch set DEV [ mode { legacy | switchdev } ]\n");
 	pr_err("                               [ inline-mode { none | link | network | transport } ]\n");
+	pr_err("                               [ encap { disable | enable } ]\n");
 	pr_err("       devlink dev eswitch show DEV\n");
 }
 
@@ -1421,6 +1460,12 @@ static void pr_out_eswitch(struct dl *dl, struct nlattr **tb)
 			   eswitch_inline_mode_name(mnl_attr_get_u8(
 				   tb[DEVLINK_ATTR_ESWITCH_INLINE_MODE])));
 
+	if (tb[DEVLINK_ATTR_ESWITCH_ENCAP_MODE]) {
+		bool encap_mode = !!mnl_attr_get_u8(tb[DEVLINK_ATTR_ESWITCH_ENCAP_MODE]);
+
+		pr_out_str(dl, "encap", encap_mode ? "enable" : "disable");
+	}
+
 	pr_out_handle_end(dl);
 }
 
@@ -1465,7 +1510,8 @@ static int cmd_dev_eswitch_set(struct dl *dl)
 
 	err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLE,
 				DL_OPT_ESWITCH_MODE |
-				DL_OPT_ESWITCH_INLINE_MODE);
+				DL_OPT_ESWITCH_INLINE_MODE |
+				DL_OPT_ESWITCH_ENCAP_MODE);
 
 	if (err)
 		return err;
diff --git a/man/man8/devlink-dev.8 b/man/man8/devlink-dev.8
index 6bfe66f..b074d57 100644
--- a/man/man8/devlink-dev.8
+++ b/man/man8/devlink-dev.8
@@ -34,6 +34,9 @@ devlink-dev \- devlink device configuration
 .RI "[ "
 .BR inline-mode " { " none " | " link " | " network " | " transport " } "
 .RI "]"
+.RI "[ "
+.BR encap " { " disable " | " enable " } "
+.RI "]"
 
 .ti -8
 .BR "devlink dev eswitch show"
@@ -81,6 +84,16 @@ Some HWs need the VF driver to put part of the packet headers on the TX descript
 .I transport
 - L4 mode
 
+.TP
+.BR encap " { " disable " | " enable " } "
+Set eswitch encapsulation support
+
+.I disable
+- Disable encapsulation support
+
+.I enable
+- Enable encapsulation support
+
 .SH "EXAMPLES"
 .PP
 devlink dev show
-- 
2.7.4
