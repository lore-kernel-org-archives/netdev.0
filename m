From: Roi Dayan <roid@mellanox.com>
Subject: [PATCH iproute2 2/2] devlink: Add option to set and show eswitch inline mode
Date: Sun, 27 Nov 2016 13:21:03 +0200
Message-ID: <1480245663-814-3-git-send-email-roid@mellanox.com>
References: <1480245663-814-1-git-send-email-roid@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35861 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753820AbcK0LVW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 06:21:22 -0500
In-Reply-To: <1480245663-814-1-git-send-email-roid@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is needed for some HWs to do proper macthing and steering.
Possible values are none, link, network, transport.

Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 devlink/devlink.c       |   82 ++++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/devlink.h |    8 ++++
 man/man8/devlink-dev.8  |   19 +++++++++++
 3 files changed, 108 insertions(+), 1 deletions(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index 673234f..23db9e7 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -28,6 +28,10 @@
 
 #define ESWITCH_MODE_LEGACY "legacy"
 #define ESWITCH_MODE_SWITCHDEV "switchdev"
+#define ESWITCH_INLINE_MODE_NONE "none"
+#define ESWITCH_INLINE_MODE_LINK "link"
+#define ESWITCH_INLINE_MODE_NETWORK "network"
+#define ESWITCH_INLINE_MODE_TRANSPORT "transport"
 
 #define pr_err(args...) fprintf(stderr, ##args)
 #define pr_out(args...) fprintf(stdout, ##args)
@@ -132,6 +136,7 @@ static void ifname_map_free(struct ifname_map *ifname_map)
 #define DL_OPT_SB_TH		BIT(9)
 #define DL_OPT_SB_TC		BIT(10)
 #define DL_OPT_ESWITCH_MODE	BIT(11)
+#define DL_OPT_ESWITCH_INLINE_MODE	BIT(12)
 
 struct dl_opts {
 	uint32_t present; /* flags of present items */
@@ -148,6 +153,7 @@ struct dl_opts {
 	uint32_t sb_threshold;
 	uint16_t sb_tc_index;
 	enum devlink_eswitch_mode eswitch_mode;
+	enum devlink_eswitch_inline_mode eswitch_inline_mode;
 };
 
 struct dl {
@@ -305,6 +311,9 @@ static int attr_cb(const struct nlattr *attr, void *data)
 	if (type == DEVLINK_ATTR_ESWITCH_MODE &&
 	    mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
 		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_ESWITCH_INLINE_MODE &&
+	    mnl_attr_validate(attr, MNL_TYPE_U8) < 0)
+		return MNL_CB_ERROR;
 	tb[type] = attr;
 	return MNL_CB_OK;
 }
@@ -682,6 +691,24 @@ static int eswitch_mode_get(const char *typestr,
 	return 0;
 }
 
+static int eswitch_inline_mode_get(const char *typestr,
+				   enum devlink_eswitch_inline_mode *p_mode)
+{
+	if (strcmp(typestr, ESWITCH_INLINE_MODE_NONE) == 0) {
+		*p_mode = DEVLINK_ESWITCH_INLINE_MODE_NONE;
+	} else if (strcmp(typestr, ESWITCH_INLINE_MODE_LINK) == 0) {
+		*p_mode = DEVLINK_ESWITCH_INLINE_MODE_LINK;
+	} else if (strcmp(typestr, ESWITCH_INLINE_MODE_NETWORK) == 0) {
+		*p_mode = DEVLINK_ESWITCH_INLINE_MODE_NETWORK;
+	} else if (strcmp(typestr, ESWITCH_INLINE_MODE_TRANSPORT) == 0) {
+		*p_mode = DEVLINK_ESWITCH_INLINE_MODE_TRANSPORT;
+	} else {
+		pr_err("Unknown eswitch inline mode \"%s\"\n", typestr);
+		return -EINVAL;
+	}
+	return 0;
+}
+
 static int dl_argv_parse(struct dl *dl, uint32_t o_required,
 			 uint32_t o_optional)
 {
@@ -803,6 +830,19 @@ static int dl_argv_parse(struct dl *dl, uint32_t o_required,
 			if (err)
 				return err;
 			o_found |= DL_OPT_ESWITCH_MODE;
+		} else if (dl_argv_match(dl, "inline-mode") &&
+			   (o_all & DL_OPT_ESWITCH_INLINE_MODE)) {
+			const char *typestr;
+
+			dl_arg_inc(dl);
+			err = dl_argv_str(dl, &typestr);
+			if (err)
+				return err;
+			err = eswitch_inline_mode_get(
+				typestr, &opts->eswitch_inline_mode);
+			if (err)
+				return err;
+			o_found |= DL_OPT_ESWITCH_INLINE_MODE;
 		} else {
 			pr_err("Unknown option \"%s\"\n", dl_argv(dl));
 			return -EINVAL;
@@ -863,6 +903,12 @@ static int dl_argv_parse(struct dl *dl, uint32_t o_required,
 		return -EINVAL;
 	}
 
+	if ((o_required & DL_OPT_ESWITCH_INLINE_MODE) &&
+	    !(o_found & DL_OPT_ESWITCH_INLINE_MODE)) {
+		pr_err("E-Switch inline-mode option expected.\n");
+		return -EINVAL;
+	}
+
 	return 0;
 }
 
@@ -909,6 +955,9 @@ static void dl_opts_put(struct nlmsghdr *nlh, struct dl *dl)
 	if (opts->present & DL_OPT_ESWITCH_MODE)
 		mnl_attr_put_u16(nlh, DEVLINK_ATTR_ESWITCH_MODE,
 				 opts->eswitch_mode);
+	if (opts->present & DL_OPT_ESWITCH_INLINE_MODE)
+		mnl_attr_put_u8(nlh, DEVLINK_ATTR_ESWITCH_INLINE_MODE,
+				opts->eswitch_inline_mode);
 }
 
 static int dl_argv_parse_put(struct nlmsghdr *nlh, struct dl *dl,
@@ -964,6 +1013,7 @@ static void cmd_dev_help(void)
 {
 	pr_err("Usage: devlink dev show [ DEV ]\n");
 	pr_err("       devlink dev eswitch set DEV [ mode { legacy | switchdev } ]\n");
+	pr_err("                               [ inline-mode { none | link | network | transport } ]\n");
 	pr_err("       devlink dev eswitch show DEV\n");
 }
 
@@ -1203,6 +1253,22 @@ static const char *eswitch_mode_name(uint32_t mode)
 	}
 }
 
+static const char *eswitch_inline_mode_name(uint32_t mode)
+{
+	switch (mode) {
+	case DEVLINK_ESWITCH_INLINE_MODE_NONE:
+		return ESWITCH_INLINE_MODE_NONE;
+	case DEVLINK_ESWITCH_INLINE_MODE_LINK:
+		return ESWITCH_INLINE_MODE_LINK;
+	case DEVLINK_ESWITCH_INLINE_MODE_NETWORK:
+		return ESWITCH_INLINE_MODE_NETWORK;
+	case DEVLINK_ESWITCH_INLINE_MODE_TRANSPORT:
+		return ESWITCH_INLINE_MODE_TRANSPORT;
+	default:
+		return "<unknown mode>";
+	}
+}
+
 static void pr_out_eswitch(struct dl *dl, struct nlattr **tb)
 {
 	__pr_out_handle_start(dl, tb, true, false);
@@ -1210,6 +1276,12 @@ static void pr_out_eswitch(struct dl *dl, struct nlattr **tb)
 	if (tb[DEVLINK_ATTR_ESWITCH_MODE])
 		pr_out_str(dl, "mode",
 			   eswitch_mode_name(mnl_attr_get_u16(tb[DEVLINK_ATTR_ESWITCH_MODE])));
+
+	if (tb[DEVLINK_ATTR_ESWITCH_INLINE_MODE])
+		pr_out_str(dl, "inline-mode",
+			   eswitch_inline_mode_name(mnl_attr_get_u8(
+				   tb[DEVLINK_ATTR_ESWITCH_INLINE_MODE])));
+
 	pr_out_handle_end(dl);
 }
 
@@ -1252,10 +1324,18 @@ static int cmd_dev_eswitch_set(struct dl *dl)
 	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_ESWITCH_MODE_SET,
 			       NLM_F_REQUEST | NLM_F_ACK);
 
-	err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLE | DL_OPT_ESWITCH_MODE, 0);
+	err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLE,
+				DL_OPT_ESWITCH_MODE |
+				DL_OPT_ESWITCH_INLINE_MODE);
+
 	if (err)
 		return err;
 
+	if (dl->opts.present == 1) {
+		pr_err("Need to set at least one option\n");
+		return -ENOENT;
+	}
+
 	return _mnlg_socket_sndrcv(dl->nlg, nlh, NULL, NULL);
 }
 
diff --git a/include/linux/devlink.h b/include/linux/devlink.h
index b7c1a06..7c14d77 100644
--- a/include/linux/devlink.h
+++ b/include/linux/devlink.h
@@ -102,6 +102,13 @@ enum devlink_eswitch_mode {
 	DEVLINK_ESWITCH_MODE_SWITCHDEV,
 };
 
+enum devlink_eswitch_inline_mode {
+	DEVLINK_ESWITCH_INLINE_MODE_NONE,
+	DEVLINK_ESWITCH_INLINE_MODE_LINK,
+	DEVLINK_ESWITCH_INLINE_MODE_NETWORK,
+	DEVLINK_ESWITCH_INLINE_MODE_TRANSPORT,
+};
+
 enum devlink_attr {
 	/* don't change the order or add anything between, this is ABI! */
 	DEVLINK_ATTR_UNSPEC,
@@ -133,6 +140,7 @@ enum devlink_attr {
 	DEVLINK_ATTR_SB_OCC_CUR,		/* u32 */
 	DEVLINK_ATTR_SB_OCC_MAX,		/* u32 */
 	DEVLINK_ATTR_ESWITCH_MODE,		/* u16 */
+	DEVLINK_ATTR_ESWITCH_INLINE_MODE,	/* u8 */
 
 	/* add new attributes above here, update the policy in devlink.c */
 
diff --git a/man/man8/devlink-dev.8 b/man/man8/devlink-dev.8
index 931e334..6bfe66f 100644
--- a/man/man8/devlink-dev.8
+++ b/man/man8/devlink-dev.8
@@ -31,6 +31,9 @@ devlink-dev \- devlink device configuration
 .RI "[ "
 .BR mode " { " legacy " | " switchdev " } "
 .RI "]"
+.RI "[ "
+.BR inline-mode " { " none " | " link " | " network " | " transport " } "
+.RI "]"
 
 .ti -8
 .BR "devlink dev eswitch show"
@@ -62,6 +65,22 @@ Set eswitch mode
 .I switchdev
 - SRIOV switchdev offloads
 
+.TP
+.BR inline-mode " { " none " | " link " | " network " | " transport " } "
+Some HWs need the VF driver to put part of the packet headers on the TX descriptor so the e-switch can do proper matching and steering.
+
+.I none
+- None
+
+.I link
+- L2 mode
+
+.I network
+- L3 mode
+
+.I transport
+- L4 mode
+
 .SH "EXAMPLES"
 .PP
 devlink dev show
-- 
1.7.1
