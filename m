From: Jiri Pirko <jiri@resnulli.us>
Subject: [iproute2 net-next repost 2/2] devlink: implement shared buffer occupancy control
Date: Sat, 14 May 2016 15:21:02 +0200
Message-ID: <1463232062-3708-2-git-send-email-jiri@resnulli.us>
References: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
 <1463232062-3708-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34716 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752119AbcENNVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 09:21:08 -0400
Received: by mail-wm0-f65.google.com with SMTP id n129so8866148wmn.1
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 06:21:07 -0700 (PDT)
In-Reply-To: <1463232062-3708-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Use kernel shared buffer occupancy control commands to make snapshot and
clear occupancy watermarks. Also, allow to show occupancy values in a
nice way.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 devlink/devlink.c | 378 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 378 insertions(+)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index ca3f586..ffefa86 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -27,6 +27,12 @@
 
 #define pr_err(args...) fprintf(stderr, ##args)
 #define pr_out(args...) fprintf(stdout, ##args)
+#define pr_out_sp(num, args...)					\
+	do {							\
+		int ret = fprintf(stdout, ##args);		\
+		if (ret < num)					\
+			fprintf(stdout, "%*s", num - ret, "");	\
+	} while (0)
 
 static int _mnlg_socket_recv_run(struct mnlg_socket *nlg,
 				 mnl_cb_t data_cb, void *data)
@@ -275,6 +281,12 @@ static int attr_cb(const struct nlattr *attr, void *data)
 	if (type == DEVLINK_ATTR_SB_TC_INDEX &&
 	    mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
 		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_SB_OCC_CUR &&
+	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_SB_OCC_MAX &&
+	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
+		return MNL_CB_ERROR;
 	tb[type] = attr;
 	return MNL_CB_OK;
 }
@@ -858,6 +870,42 @@ static int dl_argv_parse_put(struct nlmsghdr *nlh, struct dl *dl,
 	return 0;
 }
 
+static bool dl_dump_filter(struct dl *dl, struct nlattr **tb)
+{
+	struct dl_opts *opts = &dl->opts;
+	struct nlattr *attr_bus_name = tb[DEVLINK_ATTR_BUS_NAME];
+	struct nlattr *attr_dev_name = tb[DEVLINK_ATTR_DEV_NAME];
+	struct nlattr *attr_port_index = tb[DEVLINK_ATTR_PORT_INDEX];
+	struct nlattr *attr_sb_index = tb[DEVLINK_ATTR_SB_INDEX];
+
+	if (opts->present & DL_OPT_HANDLE &&
+	    attr_bus_name && attr_dev_name) {
+		const char *bus_name = mnl_attr_get_str(attr_bus_name);
+		const char *dev_name = mnl_attr_get_str(attr_dev_name);
+
+		if (strcmp(bus_name, opts->bus_name) != 0 ||
+		    strcmp(dev_name, opts->dev_name) != 0)
+			return false;
+	}
+	if (opts->present & DL_OPT_HANDLEP &&
+	    attr_bus_name && attr_dev_name && attr_port_index) {
+		const char *bus_name = mnl_attr_get_str(attr_bus_name);
+		const char *dev_name = mnl_attr_get_str(attr_dev_name);
+		uint32_t port_index = mnl_attr_get_u32(attr_port_index);
+
+		if (strcmp(bus_name, opts->bus_name) != 0 ||
+		    strcmp(dev_name, opts->dev_name) != 0 ||
+		    port_index != opts->port_index)
+			return false;
+	}
+	if (opts->present & DL_OPT_SB && attr_sb_index) {
+		uint32_t sb_index = mnl_attr_get_u32(attr_sb_index);
+
+		if (sb_index != opts->sb_index)
+			return false;
+	}
+	return true;
+}
 
 static void cmd_dev_help(void)
 {
@@ -1139,6 +1187,9 @@ static void cmd_sb_help(void)
 	pr_out("       devlink sb tc bind set DEV/PORT_INDEX [ sb SB_INDEX ] tc TC_INDEX\n");
 	pr_out("                              type { ingress | egress } pool POOL_INDEX\n");
 	pr_out("                              th THRESHOLD\n");
+	pr_out("       devlink sb occupancy show { DEV | DEV/PORT_INDEX } [ sb SB_INDEX ]\n");
+	pr_out("       devlink sb occupancy snapshot DEV [ sb SB_INDEX ]\n");
+	pr_out("       devlink sb occupancy clearmax DEV [ sb SB_INDEX ]\n");
 }
 
 static void pr_out_sb(struct nlattr **tb)
@@ -1475,6 +1526,330 @@ static int cmd_sb_tc(struct dl *dl)
 	return -ENOENT;
 }
 
+struct occ_item {
+	struct list_head list;
+	uint32_t index;
+	uint32_t cur;
+	uint32_t max;
+	uint32_t bound_pool_index;
+};
+
+struct occ_port {
+	struct list_head list;
+	char *bus_name;
+	char *dev_name;
+	uint32_t port_index;
+	uint32_t sb_index;
+	struct list_head pool_list;
+	struct list_head ing_tc_list;
+	struct list_head eg_tc_list;
+};
+
+struct occ_show {
+	struct dl *dl;
+	int err;
+	struct list_head port_list;
+};
+
+static struct occ_item *occ_item_alloc(void)
+{
+	return calloc(1, sizeof(struct occ_item));
+}
+
+static void occ_item_free(struct occ_item *occ_item)
+{
+	free(occ_item);
+}
+
+static struct occ_port *occ_port_alloc(uint32_t port_index)
+{
+	struct occ_port *occ_port;
+
+	occ_port = calloc(1, sizeof(*occ_port));
+	if (!occ_port)
+		return NULL;
+	occ_port->port_index = port_index;
+	INIT_LIST_HEAD(&occ_port->pool_list);
+	INIT_LIST_HEAD(&occ_port->ing_tc_list);
+	INIT_LIST_HEAD(&occ_port->eg_tc_list);
+	return occ_port;
+}
+
+static void occ_port_free(struct occ_port *occ_port)
+{
+	struct occ_item *occ_item, *tmp;
+
+	list_for_each_entry_safe(occ_item, tmp, &occ_port->pool_list, list)
+		occ_item_free(occ_item);
+	list_for_each_entry_safe(occ_item, tmp, &occ_port->ing_tc_list, list)
+		occ_item_free(occ_item);
+	list_for_each_entry_safe(occ_item, tmp, &occ_port->eg_tc_list, list)
+		occ_item_free(occ_item);
+}
+
+static struct occ_show *occ_show_alloc(struct dl *dl)
+{
+	struct occ_show *occ_show;
+
+	occ_show = calloc(1, sizeof(*occ_show));
+	if (!occ_show)
+		return NULL;
+	occ_show->dl = dl;
+	INIT_LIST_HEAD(&occ_show->port_list);
+	return occ_show;
+}
+
+static void occ_show_free(struct occ_show *occ_show)
+{
+	struct occ_port *occ_port, *tmp;
+
+	list_for_each_entry_safe(occ_port, tmp, &occ_show->port_list, list)
+		occ_port_free(occ_port);
+}
+
+static struct occ_port *occ_port_get(struct occ_show *occ_show,
+				     struct nlattr **tb)
+{
+	struct occ_port *occ_port;
+	uint32_t port_index;
+
+	port_index = mnl_attr_get_u32(tb[DEVLINK_ATTR_PORT_INDEX]);
+
+	list_for_each_entry_reverse(occ_port, &occ_show->port_list, list) {
+		if (occ_port->port_index == port_index)
+			return occ_port;
+	}
+	occ_port = occ_port_alloc(port_index);
+	if (!occ_port)
+		return NULL;
+	list_add_tail(&occ_port->list, &occ_show->port_list);
+	return occ_port;
+}
+
+static void pr_out_occ_show_item_list(const char *label, struct list_head *list,
+				      bool bound_pool)
+{
+	struct occ_item *occ_item;
+	int i = 1;
+
+	pr_out_sp(7, "  %s:", label);
+	list_for_each_entry(occ_item, list, list) {
+		if ((i - 1) % 4 == 0 && i != 1)
+			pr_out_sp(7, " ");
+		if (bound_pool)
+			pr_out_sp(7, "%2u(%u):", occ_item->index,
+				  occ_item->bound_pool_index);
+		else
+			pr_out_sp(7, "%2u:", occ_item->index);
+		pr_out_sp(15, "%7u/%u", occ_item->cur, occ_item->max);
+		if (i++ % 4 == 0)
+			pr_out("\n");
+	}
+	if ((i - 1) % 4 != 0)
+		pr_out("\n");
+}
+
+static void pr_out_occ_show_port(struct occ_port *occ_port)
+{
+	pr_out_occ_show_item_list("pool", &occ_port->pool_list, false);
+	pr_out_occ_show_item_list("itc", &occ_port->ing_tc_list, true);
+	pr_out_occ_show_item_list("etc", &occ_port->eg_tc_list, true);
+}
+
+static void pr_out_occ_show(struct occ_show *occ_show)
+{
+	struct dl *dl = occ_show->dl;
+	struct dl_opts *opts = &dl->opts;
+	struct occ_port *occ_port;
+
+	list_for_each_entry(occ_port, &occ_show->port_list, list) {
+		__pr_out_port_handle_nice(dl, opts->bus_name, opts->dev_name,
+					  occ_port->port_index);
+		pr_out(":\n");
+		pr_out_occ_show_port(occ_port);
+	}
+}
+
+static void cmd_sb_occ_port_pool_process(struct occ_show *occ_show,
+					 struct nlattr **tb)
+{
+	struct occ_port *occ_port;
+	struct occ_item *occ_item;
+
+	if (occ_show->err || !dl_dump_filter(occ_show->dl, tb))
+		return;
+
+	occ_port = occ_port_get(occ_show, tb);
+	if (!occ_port) {
+		occ_show->err = -ENOMEM;
+		return;
+	}
+
+	occ_item = occ_item_alloc();
+	if (!occ_item) {
+		occ_show->err = -ENOMEM;
+		return;
+	}
+	occ_item->index = mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_POOL_INDEX]);
+	occ_item->cur = mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_OCC_CUR]);
+	occ_item->max = mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_OCC_MAX]);
+	list_add_tail(&occ_item->list, &occ_port->pool_list);
+}
+
+static int cmd_sb_occ_port_pool_process_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct occ_show *occ_show = data;
+	struct nlattr *tb[DEVLINK_ATTR_MAX + 1] = {};
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+
+	mnl_attr_parse(nlh, sizeof(*genl), attr_cb, tb);
+	if (!tb[DEVLINK_ATTR_BUS_NAME] || !tb[DEVLINK_ATTR_DEV_NAME] ||
+	    !tb[DEVLINK_ATTR_PORT_INDEX] || !tb[DEVLINK_ATTR_SB_INDEX] ||
+	    !tb[DEVLINK_ATTR_SB_POOL_INDEX] ||
+	    !tb[DEVLINK_ATTR_SB_OCC_CUR] || !tb[DEVLINK_ATTR_SB_OCC_MAX])
+		return MNL_CB_ERROR;
+	cmd_sb_occ_port_pool_process(occ_show, tb);
+	return MNL_CB_OK;
+}
+
+static void cmd_sb_occ_tc_pool_process(struct occ_show *occ_show,
+				       struct nlattr **tb)
+{
+	struct occ_port *occ_port;
+	struct occ_item *occ_item;
+	uint8_t pool_type;
+
+	if (occ_show->err || !dl_dump_filter(occ_show->dl, tb))
+		return;
+
+	occ_port = occ_port_get(occ_show, tb);
+	if (!occ_port) {
+		occ_show->err = -ENOMEM;
+		return;
+	}
+
+	occ_item = occ_item_alloc();
+	if (!occ_item) {
+		occ_show->err = -ENOMEM;
+		return;
+	}
+	occ_item->index = mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_TC_INDEX]);
+	occ_item->cur = mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_OCC_CUR]);
+	occ_item->max = mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_OCC_MAX]);
+	occ_item->bound_pool_index =
+			mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_POOL_INDEX]);
+	pool_type = mnl_attr_get_u8(tb[DEVLINK_ATTR_SB_POOL_TYPE]);
+	if (pool_type == DEVLINK_SB_POOL_TYPE_INGRESS)
+		list_add_tail(&occ_item->list, &occ_port->ing_tc_list);
+	else if (pool_type == DEVLINK_SB_POOL_TYPE_EGRESS)
+		list_add_tail(&occ_item->list, &occ_port->eg_tc_list);
+	else
+		occ_item_free(occ_item);
+}
+
+static int cmd_sb_occ_tc_pool_process_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct occ_show *occ_show = data;
+	struct nlattr *tb[DEVLINK_ATTR_MAX + 1] = {};
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+
+	mnl_attr_parse(nlh, sizeof(*genl), attr_cb, tb);
+	if (!tb[DEVLINK_ATTR_BUS_NAME] || !tb[DEVLINK_ATTR_DEV_NAME] ||
+	    !tb[DEVLINK_ATTR_PORT_INDEX] || !tb[DEVLINK_ATTR_SB_INDEX] ||
+	    !tb[DEVLINK_ATTR_SB_TC_INDEX] || !tb[DEVLINK_ATTR_SB_POOL_TYPE] ||
+	    !tb[DEVLINK_ATTR_SB_POOL_INDEX] ||
+	    !tb[DEVLINK_ATTR_SB_OCC_CUR] || !tb[DEVLINK_ATTR_SB_OCC_MAX])
+		return MNL_CB_ERROR;
+	cmd_sb_occ_tc_pool_process(occ_show, tb);
+	return MNL_CB_OK;
+}
+
+static int cmd_sb_occ_show(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	struct occ_show *occ_show;
+	uint16_t flags = NLM_F_REQUEST | NLM_F_ACK | NLM_F_DUMP;
+	int err;
+
+	err = dl_argv_parse(dl, DL_OPT_HANDLE | DL_OPT_HANDLEP, DL_OPT_SB);
+	if (err)
+		return err;
+
+	occ_show = occ_show_alloc(dl);
+	if (!occ_show)
+		return -ENOMEM;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_SB_PORT_POOL_GET, flags);
+
+	err = _mnlg_socket_sndrcv(dl->nlg, nlh,
+				  cmd_sb_occ_port_pool_process_cb, occ_show);
+	if (err)
+		goto out;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_SB_TC_POOL_BIND_GET, flags);
+
+	err = _mnlg_socket_sndrcv(dl->nlg, nlh,
+				  cmd_sb_occ_tc_pool_process_cb, occ_show);
+	if (err)
+		goto out;
+
+	pr_out_occ_show(occ_show);
+
+out:
+	occ_show_free(occ_show);
+	return err;
+}
+
+static int cmd_sb_occ_snapshot(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	int err;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_SB_OCC_SNAPSHOT,
+			       NLM_F_REQUEST | NLM_F_ACK);
+
+	err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLE, DL_OPT_SB);
+	if (err)
+		return err;
+
+	return _mnlg_socket_sndrcv(dl->nlg, nlh, NULL, NULL);
+}
+
+static int cmd_sb_occ_clearmax(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	int err;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_SB_OCC_MAX_CLEAR,
+			       NLM_F_REQUEST | NLM_F_ACK);
+
+	err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLE, DL_OPT_SB);
+	if (err)
+		return err;
+
+	return _mnlg_socket_sndrcv(dl->nlg, nlh, NULL, NULL);
+}
+
+static int cmd_sb_occ(struct dl *dl)
+{
+	if (dl_argv_match(dl, "help") || dl_no_arg(dl)) {
+		cmd_sb_help();
+		return 0;
+	} else if (dl_argv_match(dl, "show") ||
+		   dl_argv_match(dl, "list")) {
+		dl_arg_inc(dl);
+		return cmd_sb_occ_show(dl);
+	} else if (dl_argv_match(dl, "snapshot")) {
+		dl_arg_inc(dl);
+		return cmd_sb_occ_snapshot(dl);
+	} else if (dl_argv_match(dl, "clearmax")) {
+		dl_arg_inc(dl);
+		return cmd_sb_occ_clearmax(dl);
+	}
+	pr_err("Command \"%s\" not found\n", dl_argv(dl));
+	return -ENOENT;
+}
+
 static int cmd_sb(struct dl *dl)
 {
 	if (dl_argv_match(dl, "help")) {
@@ -1493,6 +1868,9 @@ static int cmd_sb(struct dl *dl)
 	} else if (dl_argv_match(dl, "tc")) {
 		dl_arg_inc(dl);
 		return cmd_sb_tc(dl);
+	} else if (dl_argv_match(dl, "occupancy")) {
+		dl_arg_inc(dl);
+		return cmd_sb_occ(dl);
 	}
 	pr_err("Command \"%s\" not found\n", dl_argv(dl));
 	return -ENOENT;
-- 
2.5.5
