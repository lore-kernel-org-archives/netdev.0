From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net iproute2] devlink: Add e-switch support
Date: Sun, 28 Aug 2016 16:35:21 +0300
Message-ID: <1472391321-28129-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
        Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35285 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752567AbcH1NgD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 09:36:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement kernel devlink e-switch interface. Currently we allow
to get and set the device e-switch mode.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Roi Dayan <roid@mellanox.com>
---

Hi Stephen,

The patch is rebased over the net-next branch of iproute2 which has the 
4.8 UAPI headers devlink update, but is targeted to 4.8 (net) as the 
relevant functionality was merged in 4.8-rc1

Roi && Or.

 devlink/devlink.c      | 122 +++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/devlink-dev.8 |  34 ++++++++++++++
 2 files changed, 156 insertions(+)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index 84fa51e..d69fc6b 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -26,6 +26,9 @@
 #include "mnlg.h"
 #include "json_writer.h"
 
+#define ESWITCH_MODE_LEGACY "legacy"
+#define ESWITCH_MODE_SWITCHDEV "switchdev"
+
 #define pr_err(args...) fprintf(stderr, ##args)
 #define pr_out(args...) fprintf(stdout, ##args)
 #define pr_out_sp(num, args...)					\
@@ -128,6 +131,7 @@ static void ifname_map_free(struct ifname_map *ifname_map)
 #define DL_OPT_SB_THTYPE	BIT(8)
 #define DL_OPT_SB_TH		BIT(9)
 #define DL_OPT_SB_TC		BIT(10)
+#define DL_OPT_ESWITCH_MODE	BIT(11)
 
 struct dl_opts {
 	uint32_t present; /* flags of present items */
@@ -143,6 +147,7 @@ struct dl_opts {
 	enum devlink_sb_threshold_type sb_pool_thtype;
 	uint32_t sb_threshold;
 	uint16_t sb_tc_index;
+	enum devlink_eswitch_mode eswitch_mode;
 };
 
 struct dl {
@@ -297,6 +302,9 @@ static int attr_cb(const struct nlattr *attr, void *data)
 	if (type == DEVLINK_ATTR_SB_OCC_MAX &&
 	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
 		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_ESWITCH_MODE &&
+	    mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
+		return MNL_CB_ERROR;
 	tb[type] = attr;
 	return MNL_CB_OK;
 }
@@ -661,6 +669,19 @@ static int threshold_type_get(const char *typestr,
 	return 0;
 }
 
+static int eswitch_mode_get(const char *typestr, enum devlink_eswitch_mode *p_mode)
+{
+	if (strcmp(typestr, ESWITCH_MODE_LEGACY) == 0) {
+		*p_mode = DEVLINK_ESWITCH_MODE_LEGACY;
+	} else if (strcmp(typestr, ESWITCH_MODE_SWITCHDEV) == 0) {
+		*p_mode = DEVLINK_ESWITCH_MODE_SWITCHDEV;
+	} else {
+		pr_err("Unknown eswitch mode \"%s\"\n", typestr);
+		return -EINVAL;
+	}
+	return 0;
+}
+
 static int dl_argv_parse(struct dl *dl, uint32_t o_required,
 			 uint32_t o_optional)
 {
@@ -770,6 +791,17 @@ static int dl_argv_parse(struct dl *dl, uint32_t o_required,
 			if (err)
 				return err;
 			o_found |= DL_OPT_SB_TC;
+		} else if (dl_argv_match(dl, "mode") &&
+			   (o_all & DL_OPT_ESWITCH_MODE)) {
+			const char *typestr;
+			dl_arg_inc(dl);
+			err = dl_argv_str(dl, &typestr);
+			if (err)
+				return err;
+			err = eswitch_mode_get(typestr, &opts->eswitch_mode);
+			if (err)
+				return err;
+			o_found |= DL_OPT_ESWITCH_MODE;
 		} else {
 			pr_err("Unknown option \"%s\"\n", dl_argv(dl));
 			return -EINVAL;
@@ -823,6 +855,12 @@ static int dl_argv_parse(struct dl *dl, uint32_t o_required,
 		pr_err("TC index option expected.\n");
 		return -EINVAL;
 	}
+
+	if ((o_required & DL_OPT_ESWITCH_MODE) && !(o_found & DL_OPT_ESWITCH_MODE)) {
+		pr_err("E-Switch mode option expected.\n");
+		return -EINVAL;
+	}
+
 	return 0;
 }
 
@@ -866,6 +904,9 @@ static void dl_opts_put(struct nlmsghdr *nlh, struct dl *dl)
 	if (opts->present & DL_OPT_SB_TC)
 		mnl_attr_put_u16(nlh, DEVLINK_ATTR_SB_TC_INDEX,
 				 opts->sb_tc_index);
+	if (opts->present & DL_OPT_ESWITCH_MODE)
+		mnl_attr_put_u16(nlh, DEVLINK_ATTR_ESWITCH_MODE,
+				 opts->eswitch_mode);
 }
 
 static int dl_argv_parse_put(struct nlmsghdr *nlh, struct dl *dl,
@@ -1149,6 +1190,84 @@ static void pr_out_section_end(struct dl *dl)
 	}
 }
 
+static const char *eswitch_mode_name(uint32_t mode)
+{
+	switch (mode) {
+	case DEVLINK_ESWITCH_MODE_LEGACY: return ESWITCH_MODE_LEGACY;
+	case DEVLINK_ESWITCH_MODE_SWITCHDEV: return ESWITCH_MODE_SWITCHDEV;
+	default: return "<unknown mode>";
+	}
+}
+
+static void pr_out_eswitch(struct dl *dl, struct nlattr **tb)
+{
+	__pr_out_handle_start(dl, tb, true, false);
+
+	if (tb[DEVLINK_ATTR_ESWITCH_MODE])
+		pr_out_str(dl, "mode",
+			   eswitch_mode_name(mnl_attr_get_u16(tb[DEVLINK_ATTR_ESWITCH_MODE])));
+	pr_out_handle_end(dl);
+}
+
+static int cmd_dev_eswitch_show_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct dl *dl = data;
+	struct nlattr *tb[DEVLINK_ATTR_MAX + 1] = {};
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+
+	mnl_attr_parse(nlh, sizeof(*genl), attr_cb, tb);
+	if (!tb[DEVLINK_ATTR_BUS_NAME] || !tb[DEVLINK_ATTR_DEV_NAME])
+		return MNL_CB_ERROR;
+	pr_out_eswitch(dl, tb);
+	return MNL_CB_OK;
+}
+
+static int cmd_dev_eswitch_show(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	int err;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_ESWITCH_MODE_GET,
+			       NLM_F_REQUEST | NLM_F_ACK);
+
+	err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLE, 0);
+	if (err)
+		return err;
+
+	pr_out_section_start(dl, "dev");
+	err = _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_dev_eswitch_show_cb, dl);
+	pr_out_section_end(dl);
+	return err;
+}
+
+static int cmd_dev_eswitch_set(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	int err;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_ESWITCH_MODE_SET,
+			       NLM_F_REQUEST | NLM_F_ACK);
+
+	err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLE | DL_OPT_ESWITCH_MODE, 0);
+	if (err)
+		return err;
+
+	return _mnlg_socket_sndrcv(dl->nlg, nlh, NULL, NULL);
+}
+
+static int cmd_dev_eswitch(struct dl *dl)
+{
+	if (dl_argv_match(dl, "set")) {
+		dl_arg_inc(dl);
+		return cmd_dev_eswitch_set(dl);
+	} else if (dl_argv_match(dl, "show")) {
+		dl_arg_inc(dl);
+		return cmd_dev_eswitch_show(dl);
+	}
+	pr_err("Command \"%s\" not found\n", dl_argv(dl));
+	return -ENOENT;
+}
+
 static int cmd_dev_show_cb(const struct nlmsghdr *nlh, void *data)
 {
 	struct dl *dl = data;
@@ -1194,6 +1313,9 @@ static int cmd_dev(struct dl *dl)
 		   dl_argv_match(dl, "list") || dl_no_arg(dl)) {
 		dl_arg_inc(dl);
 		return cmd_dev_show(dl);
+	} else if (dl_argv_match(dl, "eswitch")) {
+		dl_arg_inc(dl);
+		return cmd_dev_eswitch(dl);
 	}
 	pr_err("Command \"%s\" not found\n", dl_argv(dl));
 	return -ENOENT;
diff --git a/man/man8/devlink-dev.8 b/man/man8/devlink-dev.8
index 62bcead..9ce3193 100644
--- a/man/man8/devlink-dev.8
+++ b/man/man8/devlink-dev.8
@@ -25,6 +25,17 @@ devlink-dev \- devlink device configuration
 .ti -8
 .B devlink dev help
 
+.ti -8
+.BR "devlink dev eswitch set"
+.IR DEV
+.RI "[ "
+.BR mode " { " legacy " | " switchdev " } "
+.RI "]"
+
+.ti -8
+.BR "devlink dev eswitch show"
+.IR DEV
+
 .SH "DESCRIPTION"
 .SS devlink dev show - display devlink device attributes
 
@@ -38,6 +49,19 @@ Format is:
 .in +2
 BUS_NAME/BUS_ADDRESS
 
+.SS devlink dev eswitch show - display devlink device eswitch attributes
+.SS devlink dev eswitch set  - sets devlink device eswitch attributes
+
+.TP
+.BR mode " { " legacy " | " switchdev " } "
+set eswitch mode
+
+.I legacy
+- Legacy SRIOV
+
+.I switchdev
+- SRIOV switchdev offloads
+
 .SH "EXAMPLES"
 .PP
 devlink dev show
@@ -48,6 +72,16 @@ Shows the state of all devlink devices on the system.
 devlink dev show pci/0000:01:00.0
 .RS 4
 Shows the state of specified devlink device.
+.RE
+.PP
+devlink dev eswitch show pci/0000:01:00.0
+.RS 4
+Shows the eswitch mode of specified devlink device.
+.RE
+.PP
+devlink dev eswitch set pci/0000:01:00.0 mode switchdev
+.RS 4
+Sets the eswitch mode of specified devlink device to switchdev.
 
 .SH SEE ALSO
 .BR devlink (8),
-- 
2.3.7
