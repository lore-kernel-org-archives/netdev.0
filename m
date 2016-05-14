From: Jiri Pirko <jiri@resnulli.us>
Subject: [iproute2 net-next repost 1/2] devlink: implement shared buffer support
Date: Sat, 14 May 2016 15:21:01 +0200
Message-ID: <1463232062-3708-1-git-send-email-jiri@resnulli.us>
References: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36568 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091AbcENNVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2016 09:21:06 -0400
Received: by mail-wm0-f65.google.com with SMTP id w143so8845014wmw.3
        for <netdev@vger.kernel.org>; Sat, 14 May 2016 06:21:05 -0700 (PDT)
In-Reply-To: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Implement kernel devlink shared buffer interface. Introduce new object
"sb" and allow to browse the shared buffer parameters and also change
configuration.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 devlink/devlink.c | 653 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 652 insertions(+), 1 deletion(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index 89a3083..ca3f586 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -114,6 +114,13 @@ static void ifname_map_free(struct ifname_map *ifname_map)
 #define DL_OPT_HANDLEP		BIT(1)
 #define DL_OPT_PORT_TYPE	BIT(2)
 #define DL_OPT_PORT_COUNT	BIT(3)
+#define DL_OPT_SB		BIT(4)
+#define DL_OPT_SB_POOL		BIT(5)
+#define DL_OPT_SB_SIZE		BIT(6)
+#define DL_OPT_SB_TYPE		BIT(7)
+#define DL_OPT_SB_THTYPE	BIT(8)
+#define DL_OPT_SB_TH		BIT(9)
+#define DL_OPT_SB_TC		BIT(10)
 
 struct dl_opts {
 	uint32_t present; /* flags of present items */
@@ -122,6 +129,13 @@ struct dl_opts {
 	uint32_t port_index;
 	enum devlink_port_type port_type;
 	uint32_t port_count;
+	uint32_t sb_index;
+	uint16_t sb_pool_index;
+	uint32_t sb_pool_size;
+	enum devlink_sb_pool_type sb_pool_type;
+	enum devlink_sb_threshold_type sb_pool_thtype;
+	uint32_t sb_threshold;
+	uint16_t sb_tc_index;
 };
 
 struct dl {
@@ -225,6 +239,42 @@ static int attr_cb(const struct nlattr *attr, void *data)
 	if (type == DEVLINK_ATTR_PORT_IBDEV_NAME &&
 	    mnl_attr_validate(attr, MNL_TYPE_NUL_STRING) < 0)
 		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_SB_INDEX &&
+	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_SB_SIZE &&
+	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_SB_INGRESS_POOL_COUNT &&
+	    mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_SB_EGRESS_POOL_COUNT &&
+	    mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_SB_INGRESS_TC_COUNT &&
+	    mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_SB_EGRESS_TC_COUNT &&
+	    mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_SB_POOL_INDEX &&
+	    mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_SB_POOL_TYPE &&
+	    mnl_attr_validate(attr, MNL_TYPE_U8) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_SB_POOL_SIZE &&
+	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_SB_POOL_THRESHOLD_TYPE &&
+	    mnl_attr_validate(attr, MNL_TYPE_U8) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_SB_THRESHOLD &&
+	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_SB_TC_INDEX &&
+	    mnl_attr_validate(attr, MNL_TYPE_U16) < 0)
+		return MNL_CB_ERROR;
 	tb[type] = attr;
 	return MNL_CB_OK;
 }
@@ -307,6 +357,23 @@ static int ifname_map_lookup(struct dl *dl, const char *ifname,
 	return -ENOENT;
 }
 
+static int ifname_map_rev_lookup(struct dl *dl, const char *bus_name,
+				 const char *dev_name, uint32_t port_index,
+				 char **p_ifname)
+{
+	struct ifname_map *ifname_map;
+
+	list_for_each_entry(ifname_map, &dl->ifname_map_list, list) {
+		if (strcmp(bus_name, ifname_map->bus_name) == 0 &&
+		    strcmp(dev_name, ifname_map->dev_name) == 0 &&
+		    port_index == ifname_map->port_index) {
+			*p_ifname = ifname_map->ifname;
+			return 0;
+		}
+	}
+	return -ENOENT;
+}
+
 static unsigned int strslashcount(char *str)
 {
 	unsigned int count = 0;
@@ -346,6 +413,20 @@ static int strtouint32_t(const char *str, uint32_t *p_val)
 	return 0;
 }
 
+static int strtouint16_t(const char *str, uint16_t *p_val)
+{
+	char *endptr;
+	unsigned long int val;
+
+	val = strtoul(str, &endptr, 10);
+	if (endptr == str || *endptr != '\0')
+		return -EINVAL;
+	if (val > USHRT_MAX)
+		return -ERANGE;
+	*p_val = val;
+	return 0;
+}
+
 static int __dl_argv_handle(char *str, char **p_bus_name, char **p_dev_name)
 {
 	strslashrsplit(str, p_bus_name, p_dev_name);
@@ -486,6 +567,24 @@ static int dl_argv_uint32_t(struct dl *dl, uint32_t *p_val)
 	return 0;
 }
 
+static int dl_argv_uint16_t(struct dl *dl, uint16_t *p_val)
+{
+	char *str = dl_argv_next(dl);
+	int err;
+
+	if (!str) {
+		pr_err("Unsigned number argument expected\n");
+		return -EINVAL;
+	}
+
+	err = strtouint16_t(str, p_val);
+	if (err) {
+		pr_err("\"%s\" is not a number or not within range\n", str);
+		return err;
+	}
+	return 0;
+}
+
 static int dl_argv_str(struct dl *dl, const char **p_str)
 {
 	const char *str = dl_argv_next(dl);
@@ -513,6 +612,33 @@ static int port_type_get(const char *typestr, enum devlink_port_type *p_type)
 	return 0;
 }
 
+static int pool_type_get(const char *typestr, enum devlink_sb_pool_type *p_type)
+{
+	if (strcmp(typestr, "ingress") == 0) {
+		*p_type = DEVLINK_SB_POOL_TYPE_INGRESS;
+	} else if (strcmp(typestr, "egress") == 0) {
+		*p_type = DEVLINK_SB_POOL_TYPE_EGRESS;
+	} else {
+		pr_err("Unknown pool type \"%s\"\n", typestr);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static int threshold_type_get(const char *typestr,
+			      enum devlink_sb_threshold_type *p_type)
+{
+	if (strcmp(typestr, "static") == 0) {
+		*p_type = DEVLINK_SB_THRESHOLD_TYPE_STATIC;
+	} else if (strcmp(typestr, "dynamic") == 0) {
+		*p_type = DEVLINK_SB_THRESHOLD_TYPE_DYNAMIC;
+	} else {
+		pr_err("Unknown threshold type \"%s\"\n", typestr);
+		return -EINVAL;
+	}
+	return 0;
+}
+
 static int dl_argv_parse(struct dl *dl, uint32_t o_required,
 			 uint32_t o_optional)
 {
@@ -562,6 +688,66 @@ static int dl_argv_parse(struct dl *dl, uint32_t o_required,
 			if (err)
 				return err;
 			o_found |= DL_OPT_PORT_COUNT;
+		} else if (dl_argv_match(dl, "sb") &&
+			   (o_all & DL_OPT_SB)) {
+			dl_arg_inc(dl);
+			err = dl_argv_uint32_t(dl, &opts->sb_index);
+			if (err)
+				return err;
+			o_found |= DL_OPT_SB;
+		} else if (dl_argv_match(dl, "pool") &&
+			   (o_all & DL_OPT_SB_POOL)) {
+			dl_arg_inc(dl);
+			err = dl_argv_uint16_t(dl, &opts->sb_pool_index);
+			if (err)
+				return err;
+			o_found |= DL_OPT_SB_POOL;
+		} else if (dl_argv_match(dl, "size") &&
+			   (o_all & DL_OPT_SB_SIZE)) {
+			dl_arg_inc(dl);
+			err = dl_argv_uint32_t(dl, &opts->sb_pool_size);
+			if (err)
+				return err;
+			o_found |= DL_OPT_SB_SIZE;
+		} else if (dl_argv_match(dl, "type") &&
+			   (o_all & DL_OPT_SB_TYPE)) {
+			const char *typestr;
+
+			dl_arg_inc(dl);
+			err = dl_argv_str(dl, &typestr);
+			if (err)
+				return err;
+			err = pool_type_get(typestr, &opts->sb_pool_type);
+			if (err)
+				return err;
+			o_found |= DL_OPT_SB_TYPE;
+		} else if (dl_argv_match(dl, "thtype") &&
+			   (o_all & DL_OPT_SB_THTYPE)) {
+			const char *typestr;
+
+			dl_arg_inc(dl);
+			err = dl_argv_str(dl, &typestr);
+			if (err)
+				return err;
+			err = threshold_type_get(typestr,
+						 &opts->sb_pool_thtype);
+			if (err)
+				return err;
+			o_found |= DL_OPT_SB_THTYPE;
+		} else if (dl_argv_match(dl, "th") &&
+			   (o_all & DL_OPT_SB_TH)) {
+			dl_arg_inc(dl);
+			err = dl_argv_uint32_t(dl, &opts->sb_threshold);
+			if (err)
+				return err;
+			o_found |= DL_OPT_SB_TH;
+		} else if (dl_argv_match(dl, "tc") &&
+			   (o_all & DL_OPT_SB_TC)) {
+			dl_arg_inc(dl);
+			err = dl_argv_uint16_t(dl, &opts->sb_tc_index);
+			if (err)
+				return err;
+			o_found |= DL_OPT_SB_TC;
 		} else {
 			pr_err("Unknown option \"%s\"\n", dl_argv(dl));
 			return -EINVAL;
@@ -570,6 +756,11 @@ static int dl_argv_parse(struct dl *dl, uint32_t o_required,
 
 	opts->present = o_found;
 
+	if ((o_optional & DL_OPT_SB) && !(o_found & DL_OPT_SB)) {
+		opts->sb_index = 0;
+		opts->present |= DL_OPT_SB;
+	}
+
 	if ((o_required & DL_OPT_PORT_TYPE) && !(o_found & DL_OPT_PORT_TYPE)) {
 		pr_err("Port type option expected.\n");
 		return -EINVAL;
@@ -581,6 +772,35 @@ static int dl_argv_parse(struct dl *dl, uint32_t o_required,
 		return -EINVAL;
 	}
 
+	if ((o_required & DL_OPT_SB_POOL) && !(o_found & DL_OPT_SB_POOL)) {
+		pr_err("Pool index option expected.\n");
+		return -EINVAL;
+	}
+
+	if ((o_required & DL_OPT_SB_SIZE) && !(o_found & DL_OPT_SB_SIZE)) {
+		pr_err("Pool size option expected.\n");
+		return -EINVAL;
+	}
+
+	if ((o_required & DL_OPT_SB_TYPE) && !(o_found & DL_OPT_SB_TYPE)) {
+		pr_err("Pool type option expected.\n");
+		return -EINVAL;
+	}
+
+	if ((o_required & DL_OPT_SB_THTYPE) && !(o_found & DL_OPT_SB_THTYPE)) {
+		pr_err("Pool threshold type option expected.\n");
+		return -EINVAL;
+	}
+
+	if ((o_required & DL_OPT_SB_TH) && !(o_found & DL_OPT_SB_TH)) {
+		pr_err("Threshold option expected.\n");
+		return -EINVAL;
+	}
+
+	if ((o_required & DL_OPT_SB_TC) && !(o_found & DL_OPT_SB_TC)) {
+		pr_err("TC index option expected.\n");
+		return -EINVAL;
+	}
 	return 0;
 }
 
@@ -603,6 +823,27 @@ static void dl_opts_put(struct nlmsghdr *nlh, struct dl *dl)
 	if (opts->present & DL_OPT_PORT_COUNT)
 		mnl_attr_put_u32(nlh, DEVLINK_ATTR_PORT_SPLIT_COUNT,
 				 opts->port_count);
+	if (opts->present & DL_OPT_SB)
+		mnl_attr_put_u32(nlh, DEVLINK_ATTR_SB_INDEX,
+				 opts->sb_index);
+	if (opts->present & DL_OPT_SB_POOL)
+		mnl_attr_put_u16(nlh, DEVLINK_ATTR_SB_POOL_INDEX,
+				 opts->sb_pool_index);
+	if (opts->present & DL_OPT_SB_SIZE)
+		mnl_attr_put_u32(nlh, DEVLINK_ATTR_SB_POOL_SIZE,
+				 opts->sb_pool_size);
+	if (opts->present & DL_OPT_SB_TYPE)
+		mnl_attr_put_u8(nlh, DEVLINK_ATTR_SB_POOL_TYPE,
+				opts->sb_pool_type);
+	if (opts->present & DL_OPT_SB_THTYPE)
+		mnl_attr_put_u8(nlh, DEVLINK_ATTR_SB_POOL_THRESHOLD_TYPE,
+				opts->sb_pool_thtype);
+	if (opts->present & DL_OPT_SB_TH)
+		mnl_attr_put_u32(nlh, DEVLINK_ATTR_SB_THRESHOLD,
+				 opts->sb_threshold);
+	if (opts->present & DL_OPT_SB_TC)
+		mnl_attr_put_u16(nlh, DEVLINK_ATTR_SB_TC_INDEX,
+				 opts->sb_tc_index);
 }
 
 static int dl_argv_parse_put(struct nlmsghdr *nlh, struct dl *dl,
@@ -648,6 +889,39 @@ static void pr_out_port_handle(struct nlattr **tb)
 			     mnl_attr_get_u32(tb[DEVLINK_ATTR_PORT_INDEX]));
 }
 
+static void __pr_out_port_handle_nice(struct dl *dl, const char *bus_name,
+				      const char *dev_name, uint32_t port_index)
+{
+	char *ifname;
+	int err;
+
+	if (dl->no_nice_names)
+		goto no_nice_names;
+
+	err = ifname_map_rev_lookup(dl, bus_name, dev_name,
+				    port_index, &ifname);
+	if (err)
+		goto no_nice_names;
+	pr_out("%s", ifname);
+	return;
+
+no_nice_names:
+	__pr_out_port_handle(bus_name, dev_name, port_index);
+}
+
+static void pr_out_port_handle_nice(struct dl *dl, struct nlattr **tb)
+{
+	const char *bus_name;
+	const char *dev_name;
+	uint32_t port_index;
+
+	bus_name = mnl_attr_get_str(tb[DEVLINK_ATTR_BUS_NAME]);
+	dev_name = mnl_attr_get_str(tb[DEVLINK_ATTR_DEV_NAME]);
+	port_index = mnl_attr_get_u32(tb[DEVLINK_ATTR_PORT_INDEX]);
+
+	__pr_out_port_handle_nice(dl, bus_name, dev_name, port_index);
+}
+
 static void pr_out_dev(struct nlattr **tb)
 {
 	pr_out_handle(tb);
@@ -850,6 +1124,380 @@ static int cmd_port(struct dl *dl)
 	return -ENOENT;
 }
 
+static void cmd_sb_help(void)
+{
+	pr_out("Usage: devlink sb show [ DEV [ sb SB_INDEX ] ]\n");
+	pr_out("       devlink sb pool show [ DEV [ sb SB_INDEX ] pool POOL_INDEX ]\n");
+	pr_out("       devlink sb pool set DEV [ sb SB_INDEX ] pool POOL_INDEX\n");
+	pr_out("                           size POOL_SIZE thtype { static | dynamic }\n");
+	pr_out("       devlink sb port pool show [ DEV/PORT_INDEX [ sb SB_INDEX ]\n");
+	pr_out("                                   pool POOL_INDEX ]\n");
+	pr_out("       devlink sb port pool set DEV/PORT_INDEX [ sb SB_INDEX ]\n");
+	pr_out("                                pool POOL_INDEX th THRESHOLD\n");
+	pr_out("       devlink sb tc bind show [ DEV/PORT_INDEX [ sb SB_INDEX ] tc TC_INDEX\n");
+	pr_out("                                 type { ingress | egress } ]\n");
+	pr_out("       devlink sb tc bind set DEV/PORT_INDEX [ sb SB_INDEX ] tc TC_INDEX\n");
+	pr_out("                              type { ingress | egress } pool POOL_INDEX\n");
+	pr_out("                              th THRESHOLD\n");
+}
+
+static void pr_out_sb(struct nlattr **tb)
+{
+	pr_out_handle(tb);
+	pr_out(": sb %u size %u ing_pools %u eg_pools %u ing_tcs %u eg_tcs %u\n",
+	       mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_INDEX]),
+	       mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_SIZE]),
+	       mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_INGRESS_POOL_COUNT]),
+	       mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_EGRESS_POOL_COUNT]),
+	       mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_INGRESS_TC_COUNT]),
+	       mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_EGRESS_TC_COUNT]));
+}
+
+static int cmd_sb_show_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct nlattr *tb[DEVLINK_ATTR_MAX + 1] = {};
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+
+	mnl_attr_parse(nlh, sizeof(*genl), attr_cb, tb);
+	if (!tb[DEVLINK_ATTR_BUS_NAME] || !tb[DEVLINK_ATTR_DEV_NAME] ||
+	    !tb[DEVLINK_ATTR_SB_INDEX] || !tb[DEVLINK_ATTR_SB_SIZE] ||
+	    !tb[DEVLINK_ATTR_SB_INGRESS_POOL_COUNT] ||
+	    !tb[DEVLINK_ATTR_SB_EGRESS_POOL_COUNT] ||
+	    !tb[DEVLINK_ATTR_SB_INGRESS_TC_COUNT] ||
+	    !tb[DEVLINK_ATTR_SB_EGRESS_TC_COUNT])
+		return MNL_CB_ERROR;
+	pr_out_sb(tb);
+	return MNL_CB_OK;
+}
+
+static int cmd_sb_show(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	uint16_t flags = NLM_F_REQUEST | NLM_F_ACK;
+	int err;
+
+	if (dl_argc(dl) == 0)
+		flags |= NLM_F_DUMP;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_SB_GET, flags);
+
+	if (dl_argc(dl) > 0) {
+		err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLE, DL_OPT_SB);
+		if (err)
+			return err;
+	}
+
+	return _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_sb_show_cb, NULL);
+}
+
+static const char *pool_type_name(uint8_t type)
+{
+	switch (type) {
+	case DEVLINK_SB_POOL_TYPE_INGRESS: return "ingress";
+	case DEVLINK_SB_POOL_TYPE_EGRESS: return "egress";
+	default: return "<unknown type>";
+	}
+}
+
+static const char *threshold_type_name(uint8_t type)
+{
+	switch (type) {
+	case DEVLINK_SB_THRESHOLD_TYPE_STATIC: return "static";
+	case DEVLINK_SB_THRESHOLD_TYPE_DYNAMIC: return "dynamic";
+	default: return "<unknown type>";
+	}
+}
+
+static void pr_out_sb_pool(struct nlattr **tb)
+{
+	pr_out_handle(tb);
+	pr_out(": sb %u pool %u type %s size %u thtype %s\n",
+	       mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_INDEX]),
+	       mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_POOL_INDEX]),
+	       pool_type_name(mnl_attr_get_u8(tb[DEVLINK_ATTR_SB_POOL_TYPE])),
+	       mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_POOL_SIZE]),
+	       threshold_type_name(mnl_attr_get_u8(tb[DEVLINK_ATTR_SB_POOL_THRESHOLD_TYPE])));
+}
+
+static int cmd_sb_pool_show_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct nlattr *tb[DEVLINK_ATTR_MAX + 1] = {};
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+
+	mnl_attr_parse(nlh, sizeof(*genl), attr_cb, tb);
+	if (!tb[DEVLINK_ATTR_BUS_NAME] || !tb[DEVLINK_ATTR_DEV_NAME] ||
+	    !tb[DEVLINK_ATTR_SB_INDEX] || !tb[DEVLINK_ATTR_SB_POOL_INDEX] ||
+	    !tb[DEVLINK_ATTR_SB_POOL_TYPE] || !tb[DEVLINK_ATTR_SB_POOL_SIZE] ||
+	    !tb[DEVLINK_ATTR_SB_POOL_THRESHOLD_TYPE])
+		return MNL_CB_ERROR;
+	pr_out_sb_pool(tb);
+	return MNL_CB_OK;
+}
+
+static int cmd_sb_pool_show(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	uint16_t flags = NLM_F_REQUEST | NLM_F_ACK;
+	int err;
+
+	if (dl_argc(dl) == 0)
+		flags |= NLM_F_DUMP;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_SB_POOL_GET, flags);
+
+	if (dl_argc(dl) > 0) {
+		err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLE | DL_OPT_SB_POOL,
+					DL_OPT_SB);
+		if (err)
+			return err;
+	}
+
+	return _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_sb_pool_show_cb, NULL);
+}
+
+static int cmd_sb_pool_set(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	int err;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_SB_POOL_SET,
+			       NLM_F_REQUEST | NLM_F_ACK);
+
+	err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLE | DL_OPT_SB_POOL |
+				DL_OPT_SB_SIZE | DL_OPT_SB_THTYPE, DL_OPT_SB);
+	if (err)
+		return err;
+
+	return _mnlg_socket_sndrcv(dl->nlg, nlh, NULL, NULL);
+}
+
+static int cmd_sb_pool(struct dl *dl)
+{
+	if (dl_argv_match(dl, "help")) {
+		cmd_sb_help();
+		return 0;
+	} else if (dl_argv_match(dl, "show") ||
+		   dl_argv_match(dl, "list") || dl_no_arg(dl)) {
+		dl_arg_inc(dl);
+		return cmd_sb_pool_show(dl);
+	} else if (dl_argv_match(dl, "set")) {
+		dl_arg_inc(dl);
+		return cmd_sb_pool_set(dl);
+	}
+	pr_err("Command \"%s\" not found\n", dl_argv(dl));
+	return -ENOENT;
+}
+
+static void pr_out_sb_port_pool(struct dl *dl, struct nlattr **tb)
+{
+	pr_out_port_handle_nice(dl, tb);
+	pr_out(": sb %u pool %u threshold %u\n",
+	       mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_INDEX]),
+	       mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_POOL_INDEX]),
+	       mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_THRESHOLD]));
+}
+
+static int cmd_sb_port_pool_show_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct dl *dl = data;
+	struct nlattr *tb[DEVLINK_ATTR_MAX + 1] = {};
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+
+	mnl_attr_parse(nlh, sizeof(*genl), attr_cb, tb);
+	if (!tb[DEVLINK_ATTR_BUS_NAME] || !tb[DEVLINK_ATTR_DEV_NAME] ||
+	    !tb[DEVLINK_ATTR_PORT_INDEX] || !tb[DEVLINK_ATTR_SB_INDEX] ||
+	    !tb[DEVLINK_ATTR_SB_POOL_INDEX] || !tb[DEVLINK_ATTR_SB_THRESHOLD])
+		return MNL_CB_ERROR;
+	pr_out_sb_port_pool(dl, tb);
+	return MNL_CB_OK;
+}
+
+static int cmd_sb_port_pool_show(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	uint16_t flags = NLM_F_REQUEST | NLM_F_ACK;
+	int err;
+
+	if (dl_argc(dl) == 0)
+		flags |= NLM_F_DUMP;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_SB_PORT_POOL_GET, flags);
+
+	if (dl_argc(dl) > 0) {
+		err = dl_argv_parse_put(nlh, dl,
+					DL_OPT_HANDLEP | DL_OPT_SB_POOL,
+					DL_OPT_SB);
+		if (err)
+			return err;
+	}
+
+	return _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_sb_port_pool_show_cb, dl);
+}
+
+static int cmd_sb_port_pool_set(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	int err;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_SB_PORT_POOL_SET,
+			       NLM_F_REQUEST | NLM_F_ACK);
+
+	err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLEP | DL_OPT_SB_POOL |
+				DL_OPT_SB_TH, DL_OPT_SB);
+	if (err)
+		return err;
+
+	return _mnlg_socket_sndrcv(dl->nlg, nlh, NULL, NULL);
+}
+
+static int cmd_sb_port_pool(struct dl *dl)
+{
+	if (dl_argv_match(dl, "help")) {
+		cmd_sb_help();
+		return 0;
+	} else if (dl_argv_match(dl, "show") ||
+		   dl_argv_match(dl, "list") || dl_no_arg(dl)) {
+		dl_arg_inc(dl);
+		return cmd_sb_port_pool_show(dl);
+	} else if (dl_argv_match(dl, "set")) {
+		dl_arg_inc(dl);
+		return cmd_sb_port_pool_set(dl);
+	}
+	pr_err("Command \"%s\" not found\n", dl_argv(dl));
+	return -ENOENT;
+}
+
+static int cmd_sb_port(struct dl *dl)
+{
+	if (dl_argv_match(dl, "help") || dl_no_arg(dl)) {
+		cmd_sb_help();
+		return 0;
+	} else if (dl_argv_match(dl, "pool")) {
+		dl_arg_inc(dl);
+		return cmd_sb_port_pool(dl);
+	}
+	pr_err("Command \"%s\" not found\n", dl_argv(dl));
+	return -ENOENT;
+}
+
+static void pr_out_sb_tc_bind(struct dl *dl, struct nlattr **tb)
+{
+	pr_out_port_handle_nice(dl, tb);
+	pr_out(": sb %u tc %u type %s pool %u threshold %u\n",
+	       mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_INDEX]),
+	       mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_TC_INDEX]),
+	       pool_type_name(mnl_attr_get_u8(tb[DEVLINK_ATTR_SB_POOL_TYPE])),
+	       mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_POOL_INDEX]),
+	       mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_THRESHOLD]));
+}
+
+static int cmd_sb_tc_bind_show_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct dl *dl = data;
+	struct nlattr *tb[DEVLINK_ATTR_MAX + 1] = {};
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+
+	mnl_attr_parse(nlh, sizeof(*genl), attr_cb, tb);
+	if (!tb[DEVLINK_ATTR_BUS_NAME] || !tb[DEVLINK_ATTR_DEV_NAME] ||
+	    !tb[DEVLINK_ATTR_PORT_INDEX] || !tb[DEVLINK_ATTR_SB_INDEX] ||
+	    !tb[DEVLINK_ATTR_SB_TC_INDEX] || !tb[DEVLINK_ATTR_SB_POOL_TYPE] ||
+	    !tb[DEVLINK_ATTR_SB_POOL_INDEX] || !tb[DEVLINK_ATTR_SB_THRESHOLD])
+		return MNL_CB_ERROR;
+	pr_out_sb_tc_bind(dl, tb);
+	return MNL_CB_OK;
+}
+
+static int cmd_sb_tc_bind_show(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	uint16_t flags = NLM_F_REQUEST | NLM_F_ACK;
+	int err;
+
+	if (dl_argc(dl) == 0)
+		flags |= NLM_F_DUMP;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_SB_TC_POOL_BIND_GET, flags);
+
+	if (dl_argc(dl) > 0) {
+		err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLEP | DL_OPT_SB_TC |
+					DL_OPT_SB_TYPE, DL_OPT_SB);
+		if (err)
+			return err;
+	}
+
+	return _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_sb_tc_bind_show_cb, dl);
+}
+
+static int cmd_sb_tc_bind_set(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	int err;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_SB_TC_POOL_BIND_SET,
+			       NLM_F_REQUEST | NLM_F_ACK);
+
+	err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLEP | DL_OPT_SB_TC |
+				DL_OPT_SB_TYPE | DL_OPT_SB_POOL | DL_OPT_SB_TH,
+				DL_OPT_SB);
+	if (err)
+		return err;
+
+	return _mnlg_socket_sndrcv(dl->nlg, nlh, NULL, NULL);
+}
+
+static int cmd_sb_tc_bind(struct dl *dl)
+{
+	if (dl_argv_match(dl, "help")) {
+		cmd_sb_help();
+		return 0;
+	} else if (dl_argv_match(dl, "show") ||
+		   dl_argv_match(dl, "list") || dl_no_arg(dl)) {
+		dl_arg_inc(dl);
+		return cmd_sb_tc_bind_show(dl);
+	} else if (dl_argv_match(dl, "set")) {
+		dl_arg_inc(dl);
+		return cmd_sb_tc_bind_set(dl);
+	}
+	pr_err("Command \"%s\" not found\n", dl_argv(dl));
+	return -ENOENT;
+}
+
+static int cmd_sb_tc(struct dl *dl)
+{
+	if (dl_argv_match(dl, "help") || dl_no_arg(dl)) {
+		cmd_sb_help();
+		return 0;
+	} else if (dl_argv_match(dl, "bind")) {
+		dl_arg_inc(dl);
+		return cmd_sb_tc_bind(dl);
+	}
+	pr_err("Command \"%s\" not found\n", dl_argv(dl));
+	return -ENOENT;
+}
+
+static int cmd_sb(struct dl *dl)
+{
+	if (dl_argv_match(dl, "help")) {
+		cmd_sb_help();
+		return 0;
+	} else if (dl_argv_match(dl, "show") ||
+		   dl_argv_match(dl, "list") || dl_no_arg(dl)) {
+		dl_arg_inc(dl);
+		return cmd_sb_show(dl);
+	} else if (dl_argv_match(dl, "pool")) {
+		dl_arg_inc(dl);
+		return cmd_sb_pool(dl);
+	} else if (dl_argv_match(dl, "port")) {
+		dl_arg_inc(dl);
+		return cmd_sb_port(dl);
+	} else if (dl_argv_match(dl, "tc")) {
+		dl_arg_inc(dl);
+		return cmd_sb_tc(dl);
+	}
+	pr_err("Command \"%s\" not found\n", dl_argv(dl));
+	return -ENOENT;
+}
+
 static const char *cmd_name(uint8_t cmd)
 {
 	switch (cmd) {
@@ -985,7 +1633,7 @@ static int cmd_mon(struct dl *dl)
 static void help(void)
 {
 	pr_out("Usage: devlink [ OPTIONS ] OBJECT { COMMAND | help }\n"
-	       "where  OBJECT := { dev | port | monitor }\n"
+	       "where  OBJECT := { dev | port | sb | monitor }\n"
 	       "       OPTIONS := { -V[ersion] | -n[no-nice-names] }\n");
 }
 
@@ -1000,6 +1648,9 @@ static int dl_cmd(struct dl *dl)
 	} else if (dl_argv_match(dl, "port")) {
 		dl_arg_inc(dl);
 		return cmd_port(dl);
+	} else if (dl_argv_match(dl, "sb")) {
+		dl_arg_inc(dl);
+		return cmd_sb(dl);
 	} else if (dl_argv_match(dl, "monitor")) {
 		dl_arg_inc(dl);
 		return cmd_mon(dl);
-- 
2.5.5
