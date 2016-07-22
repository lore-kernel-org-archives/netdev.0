From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 2/2] devlink: add option to generate JSON output
Date: Fri, 22 Jul 2016 18:34:30 +0200
Message-ID: <1469205270-6180-2-git-send-email-jiri@resnulli.us>
References: <1469205270-6180-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34925 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750AbcGVQeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 12:34:36 -0400
Received: by mail-wm0-f68.google.com with SMTP id i5so6843486wmg.2
        for <netdev@vger.kernel.org>; Fri, 22 Jul 2016 09:34:35 -0700 (PDT)
In-Reply-To: <1469205270-6180-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

For parsing by another app it is convenient to produce output in JSON
format.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 devlink/devlink.c | 455 +++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 362 insertions(+), 93 deletions(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index f73ba95..84fa51e 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -24,6 +24,7 @@
 #include "SNAPSHOT.h"
 #include "list.h"
 #include "mnlg.h"
+#include "json_writer.h"
 
 #define pr_err(args...) fprintf(stderr, ##args)
 #define pr_out(args...) fprintf(stdout, ##args)
@@ -151,6 +152,15 @@ struct dl {
 	char **argv;
 	bool no_nice_names;
 	struct dl_opts opts;
+	json_writer_t *jw;
+	bool json_output;
+	bool pretty_output;
+	struct {
+		bool present;
+		char *bus_name;
+		char *dev_name;
+		uint32_t port_index;
+	} arr_last;
 };
 
 static int dl_argc(struct dl *dl)
@@ -912,52 +922,161 @@ static void cmd_dev_help(void)
 	pr_err("Usage: devlink dev show [ DEV ]\n");
 }
 
-static void __pr_out_handle(const char *bus_name, const char *dev_name)
+static bool cmp_arr_last_handle(struct dl *dl, const char *bus_name,
+				const char *dev_name)
 {
-	pr_out("%s/%s", bus_name, dev_name);
+	if (!dl->arr_last.present)
+		return false;
+	return strcmp(dl->arr_last.bus_name, bus_name) == 0 &&
+	       strcmp(dl->arr_last.dev_name, dev_name) == 0;
 }
 
-static void pr_out_handle(struct nlattr **tb)
+static void arr_last_handle_set(struct dl *dl, const char *bus_name,
+				const char *dev_name)
 {
-	__pr_out_handle(mnl_attr_get_str(tb[DEVLINK_ATTR_BUS_NAME]),
-			mnl_attr_get_str(tb[DEVLINK_ATTR_DEV_NAME]));
+	dl->arr_last.present = true;
+	free(dl->arr_last.dev_name);
+	free(dl->arr_last.bus_name);
+	dl->arr_last.bus_name = strdup(bus_name);
+	dl->arr_last.dev_name = strdup(dev_name);
 }
 
-static void __pr_out_port_handle(const char *bus_name, const char *dev_name,
-				 uint32_t port_index)
+static bool should_arr_last_handle_start(struct dl *dl, const char *bus_name,
+					 const char *dev_name)
 {
-	__pr_out_handle(bus_name, dev_name);
-	pr_out("/%d", port_index);
+	return !cmp_arr_last_handle(dl, bus_name, dev_name);
 }
 
-static void pr_out_port_handle(struct nlattr **tb)
+static bool should_arr_last_handle_end(struct dl *dl, const char *bus_name,
+				       const char *dev_name)
 {
-	__pr_out_port_handle(mnl_attr_get_str(tb[DEVLINK_ATTR_BUS_NAME]),
-			     mnl_attr_get_str(tb[DEVLINK_ATTR_DEV_NAME]),
-			     mnl_attr_get_u32(tb[DEVLINK_ATTR_PORT_INDEX]));
+	return dl->arr_last.present &&
+	       !cmp_arr_last_handle(dl, bus_name, dev_name);
 }
 
-static void __pr_out_port_handle_nice(struct dl *dl, const char *bus_name,
-				      const char *dev_name, uint32_t port_index)
+static void __pr_out_handle_start(struct dl *dl, struct nlattr **tb,
+				  bool content, bool array)
 {
-	char *ifname;
-	int err;
+	const char *bus_name = mnl_attr_get_str(tb[DEVLINK_ATTR_BUS_NAME]);
+	const char *dev_name = mnl_attr_get_str(tb[DEVLINK_ATTR_DEV_NAME]);
+	char buf[32];
 
-	if (dl->no_nice_names)
-		goto no_nice_names;
+	sprintf(buf, "%s/%s", bus_name, dev_name);
 
-	err = ifname_map_rev_lookup(dl, bus_name, dev_name,
-				    port_index, &ifname);
-	if (err)
-		goto no_nice_names;
-	pr_out("%s", ifname);
-	return;
+	if (dl->json_output) {
+		if (array) {
+			if (should_arr_last_handle_end(dl, bus_name, dev_name))
+				jsonw_end_array(dl->jw);
+			if (should_arr_last_handle_start(dl, bus_name,
+							 dev_name)) {
+				jsonw_name(dl->jw, buf);
+				jsonw_start_array(dl->jw);
+				jsonw_start_object(dl->jw);
+				arr_last_handle_set(dl, bus_name, dev_name);
+			} else {
+				jsonw_start_object(dl->jw);
+			}
+		} else {
+			jsonw_name(dl->jw, buf);
+			jsonw_start_object(dl->jw);
+		}
+	} else {
+		pr_out("%s%s", buf, content ? ":" : "");
+	}
+}
 
-no_nice_names:
-	__pr_out_port_handle(bus_name, dev_name, port_index);
+static void pr_out_handle_start_arr(struct dl *dl, struct nlattr **tb)
+{
+	__pr_out_handle_start(dl, tb, true, true);
 }
 
-static void pr_out_port_handle_nice(struct dl *dl, struct nlattr **tb)
+static void pr_out_handle_end(struct dl *dl)
+{
+	if (dl->json_output)
+		jsonw_end_object(dl->jw);
+	else
+		pr_out("\n");
+}
+
+static void pr_out_handle(struct dl *dl, struct nlattr **tb)
+{
+	__pr_out_handle_start(dl, tb, false, false);
+	pr_out_handle_end(dl);
+}
+
+static bool cmp_arr_last_port_handle(struct dl *dl, const char *bus_name,
+				     const char *dev_name, uint32_t port_index)
+{
+	return cmp_arr_last_handle(dl, bus_name, dev_name) &&
+	       dl->arr_last.port_index == port_index;
+}
+
+static void arr_last_port_handle_set(struct dl *dl, const char *bus_name,
+				     const char *dev_name, uint32_t port_index)
+{
+	arr_last_handle_set(dl, bus_name, dev_name);
+	dl->arr_last.port_index = port_index;
+}
+
+static bool should_arr_last_port_handle_start(struct dl *dl,
+					      const char *bus_name,
+					      const char *dev_name,
+					      uint32_t port_index)
+{
+	return !cmp_arr_last_port_handle(dl, bus_name, dev_name, port_index);
+}
+
+static bool should_arr_last_port_handle_end(struct dl *dl,
+					    const char *bus_name,
+					    const char *dev_name,
+					    uint32_t port_index)
+{
+	return dl->arr_last.present &&
+	       !cmp_arr_last_port_handle(dl, bus_name, dev_name, port_index);
+}
+
+static void __pr_out_port_handle_start(struct dl *dl, const char *bus_name,
+				       const char *dev_name,
+				       uint32_t port_index, bool try_nice,
+				       bool array)
+{
+	static char buf[32];
+	char *ifname = NULL;
+
+	if (dl->no_nice_names || !try_nice ||
+	    ifname_map_rev_lookup(dl, bus_name, dev_name,
+				  port_index, &ifname) != 0)
+		sprintf(buf, "%s/%s/%d", bus_name, dev_name, port_index);
+	else
+		sprintf(buf, "%s", ifname);
+
+	if (dl->json_output) {
+		if (array) {
+			if (should_arr_last_port_handle_end(dl, bus_name,
+							    dev_name,
+							    port_index))
+				jsonw_end_array(dl->jw);
+			if (should_arr_last_port_handle_start(dl, bus_name,
+							      dev_name,
+							      port_index)) {
+				jsonw_name(dl->jw, buf);
+				jsonw_start_array(dl->jw);
+				jsonw_start_object(dl->jw);
+				arr_last_port_handle_set(dl, bus_name, dev_name,
+							 port_index);
+			} else {
+				jsonw_start_object(dl->jw);
+			}
+		} else {
+			jsonw_name(dl->jw, buf);
+			jsonw_start_object(dl->jw);
+		}
+	} else {
+		pr_out("%s:", buf);
+	}
+}
+
+static void pr_out_port_handle_start(struct dl *dl, struct nlattr **tb, bool try_nice)
 {
 	const char *bus_name;
 	const char *dev_name;
@@ -966,25 +1085,80 @@ static void pr_out_port_handle_nice(struct dl *dl, struct nlattr **tb)
 	bus_name = mnl_attr_get_str(tb[DEVLINK_ATTR_BUS_NAME]);
 	dev_name = mnl_attr_get_str(tb[DEVLINK_ATTR_DEV_NAME]);
 	port_index = mnl_attr_get_u32(tb[DEVLINK_ATTR_PORT_INDEX]);
+	__pr_out_port_handle_start(dl, bus_name, dev_name, port_index, try_nice, false);
+}
+
+static void pr_out_port_handle_start_arr(struct dl *dl, struct nlattr **tb, bool try_nice)
+{
+	const char *bus_name;
+	const char *dev_name;
+	uint32_t port_index;
 
-	__pr_out_port_handle_nice(dl, bus_name, dev_name, port_index);
+	bus_name = mnl_attr_get_str(tb[DEVLINK_ATTR_BUS_NAME]);
+	dev_name = mnl_attr_get_str(tb[DEVLINK_ATTR_DEV_NAME]);
+	port_index = mnl_attr_get_u32(tb[DEVLINK_ATTR_PORT_INDEX]);
+	__pr_out_port_handle_start(dl, bus_name, dev_name, port_index, try_nice, true);
 }
 
-static void pr_out_dev(struct nlattr **tb)
+static void pr_out_port_handle_end(struct dl *dl)
 {
-	pr_out_handle(tb);
-	pr_out("\n");
+	if (dl->json_output)
+		jsonw_end_object(dl->jw);
+	else
+		pr_out("\n");
+}
+
+
+static void pr_out_str(struct dl *dl, const char *name, const char *val)
+{
+	if (dl->json_output)
+		jsonw_string_field(dl->jw, name, val);
+	else
+		pr_out(" %s %s", name, val);
+}
+
+static void pr_out_uint(struct dl *dl, const char *name, unsigned int val)
+{
+	if (dl->json_output)
+		jsonw_uint_field(dl->jw, name, val);
+	else
+		pr_out(" %s %u", name, val);
+}
+
+static void pr_out_dev(struct dl *dl, struct nlattr **tb)
+{
+	pr_out_handle(dl, tb);
+}
+
+static void pr_out_section_start(struct dl *dl, const char *name)
+{
+	if (dl->json_output) {
+		jsonw_start_object(dl->jw);
+		jsonw_name(dl->jw, name);
+		jsonw_start_object(dl->jw);
+	}
+}
+
+static void pr_out_section_end(struct dl *dl)
+{
+	if (dl->json_output) {
+		if (dl->arr_last.present)
+			jsonw_end_array(dl->jw);
+		jsonw_end_object(dl->jw);
+		jsonw_end_object(dl->jw);
+	}
 }
 
 static int cmd_dev_show_cb(const struct nlmsghdr *nlh, void *data)
 {
+	struct dl *dl = data;
 	struct nlattr *tb[DEVLINK_ATTR_MAX + 1] = {};
 	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
 
 	mnl_attr_parse(nlh, sizeof(*genl), attr_cb, tb);
 	if (!tb[DEVLINK_ATTR_BUS_NAME] || !tb[DEVLINK_ATTR_DEV_NAME])
 		return MNL_CB_ERROR;
-	pr_out_dev(tb);
+	pr_out_dev(dl, tb);
 	return MNL_CB_OK;
 }
 
@@ -1005,7 +1179,10 @@ static int cmd_dev_show(struct dl *dl)
 			return err;
 	}
 
-	return _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_dev_show_cb, NULL);
+	pr_out_section_start(dl, "dev");
+	err = _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_dev_show_cb, dl);
+	pr_out_section_end(dl);
+	return err;
 }
 
 static int cmd_dev(struct dl *dl)
@@ -1041,38 +1218,39 @@ static const char *port_type_name(uint32_t type)
 	}
 }
 
-static void pr_out_port(struct nlattr **tb)
+static void pr_out_port(struct dl *dl, struct nlattr **tb)
 {
 	struct nlattr *pt_attr = tb[DEVLINK_ATTR_PORT_TYPE];
 	struct nlattr *dpt_attr = tb[DEVLINK_ATTR_PORT_DESIRED_TYPE];
 
-	pr_out_port_handle(tb);
-	pr_out(":");
+	pr_out_port_handle_start(dl, tb, false);
 	if (pt_attr) {
 		uint16_t port_type = mnl_attr_get_u16(pt_attr);
 
-		pr_out(" type %s", port_type_name(port_type));
+		pr_out_str(dl, "type", port_type_name(port_type));
 		if (dpt_attr) {
 			uint16_t des_port_type = mnl_attr_get_u16(dpt_attr);
 
 			if (port_type != des_port_type)
-				pr_out("(%s)", port_type_name(des_port_type));
+				pr_out_str(dl, "des_type",
+					   port_type_name(des_port_type));
 		}
 	}
 	if (tb[DEVLINK_ATTR_PORT_NETDEV_NAME])
-		pr_out(" netdev %s",
-		       mnl_attr_get_str(tb[DEVLINK_ATTR_PORT_NETDEV_NAME]));
+		pr_out_str(dl, "netdev",
+			   mnl_attr_get_str(tb[DEVLINK_ATTR_PORT_NETDEV_NAME]));
 	if (tb[DEVLINK_ATTR_PORT_IBDEV_NAME])
-		pr_out(" ibdev %s",
-		       mnl_attr_get_str(tb[DEVLINK_ATTR_PORT_IBDEV_NAME]));
+		pr_out_str(dl, "ibdev",
+			   mnl_attr_get_str(tb[DEVLINK_ATTR_PORT_IBDEV_NAME]));
 	if (tb[DEVLINK_ATTR_PORT_SPLIT_GROUP])
-		pr_out(" split_group %u",
-		       mnl_attr_get_u32(tb[DEVLINK_ATTR_PORT_SPLIT_GROUP]));
-	pr_out("\n");
+		pr_out_uint(dl, "split_group",
+			    mnl_attr_get_u32(tb[DEVLINK_ATTR_PORT_SPLIT_GROUP]));
+	pr_out_port_handle_end(dl);
 }
 
 static int cmd_port_show_cb(const struct nlmsghdr *nlh, void *data)
 {
+	struct dl *dl = data;
 	struct nlattr *tb[DEVLINK_ATTR_MAX + 1] = {};
 	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
 
@@ -1080,7 +1258,7 @@ static int cmd_port_show_cb(const struct nlmsghdr *nlh, void *data)
 	if (!tb[DEVLINK_ATTR_BUS_NAME] || !tb[DEVLINK_ATTR_DEV_NAME] ||
 	    !tb[DEVLINK_ATTR_PORT_INDEX])
 		return MNL_CB_ERROR;
-	pr_out_port(tb);
+	pr_out_port(dl, tb);
 	return MNL_CB_OK;
 }
 
@@ -1101,7 +1279,10 @@ static int cmd_port_show(struct dl *dl)
 			return err;
 	}
 
-	return _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_port_show_cb, NULL);
+	pr_out_section_start(dl, "port");
+	err = _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_port_show_cb, dl);
+	pr_out_section_end(dl);
+	return err;
 }
 
 static int cmd_port_set(struct dl *dl)
@@ -1192,20 +1373,27 @@ static void cmd_sb_help(void)
 	pr_err("       devlink sb occupancy clearmax DEV [ sb SB_INDEX ]\n");
 }
 
-static void pr_out_sb(struct nlattr **tb)
+static void pr_out_sb(struct dl *dl, struct nlattr **tb)
 {
-	pr_out_handle(tb);
-	pr_out(": sb %u size %u ing_pools %u eg_pools %u ing_tcs %u eg_tcs %u\n",
-	       mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_INDEX]),
-	       mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_SIZE]),
-	       mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_INGRESS_POOL_COUNT]),
-	       mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_EGRESS_POOL_COUNT]),
-	       mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_INGRESS_TC_COUNT]),
-	       mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_EGRESS_TC_COUNT]));
+	pr_out_handle_start_arr(dl, tb);
+	pr_out_uint(dl, "sb",
+		    mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_INDEX]));
+	pr_out_uint(dl, "size",
+		    mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_SIZE]));
+	pr_out_uint(dl, "ing_pools",
+		    mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_INGRESS_POOL_COUNT]));
+	pr_out_uint(dl, "eg_pools",
+		    mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_EGRESS_POOL_COUNT]));
+	pr_out_uint(dl, "ing_tcs",
+		    mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_INGRESS_TC_COUNT]));
+	pr_out_uint(dl, "eg_tcs",
+		    mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_EGRESS_TC_COUNT]));
+	pr_out_handle_end(dl);
 }
 
 static int cmd_sb_show_cb(const struct nlmsghdr *nlh, void *data)
 {
+	struct dl *dl = data;
 	struct nlattr *tb[DEVLINK_ATTR_MAX + 1] = {};
 	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
 
@@ -1217,7 +1405,7 @@ static int cmd_sb_show_cb(const struct nlmsghdr *nlh, void *data)
 	    !tb[DEVLINK_ATTR_SB_INGRESS_TC_COUNT] ||
 	    !tb[DEVLINK_ATTR_SB_EGRESS_TC_COUNT])
 		return MNL_CB_ERROR;
-	pr_out_sb(tb);
+	pr_out_sb(dl, tb);
 	return MNL_CB_OK;
 }
 
@@ -1238,7 +1426,10 @@ static int cmd_sb_show(struct dl *dl)
 			return err;
 	}
 
-	return _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_sb_show_cb, NULL);
+	pr_out_section_start(dl, "sb");
+	err = _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_sb_show_cb, dl);
+	pr_out_section_end(dl);
+	return err;
 }
 
 static const char *pool_type_name(uint8_t type)
@@ -1259,19 +1450,25 @@ static const char *threshold_type_name(uint8_t type)
 	}
 }
 
-static void pr_out_sb_pool(struct nlattr **tb)
+static void pr_out_sb_pool(struct dl *dl, struct nlattr **tb)
 {
-	pr_out_handle(tb);
-	pr_out(": sb %u pool %u type %s size %u thtype %s\n",
-	       mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_INDEX]),
-	       mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_POOL_INDEX]),
-	       pool_type_name(mnl_attr_get_u8(tb[DEVLINK_ATTR_SB_POOL_TYPE])),
-	       mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_POOL_SIZE]),
-	       threshold_type_name(mnl_attr_get_u8(tb[DEVLINK_ATTR_SB_POOL_THRESHOLD_TYPE])));
+	pr_out_handle_start_arr(dl, tb);
+	pr_out_uint(dl, "sb",
+		    mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_INDEX]));
+	pr_out_uint(dl, "pool",
+		    mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_POOL_INDEX]));
+	pr_out_str(dl, "type",
+		   pool_type_name(mnl_attr_get_u8(tb[DEVLINK_ATTR_SB_POOL_TYPE])));
+	pr_out_uint(dl, "size",
+		    mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_POOL_SIZE]));
+	pr_out_str(dl, "thtype",
+		   threshold_type_name(mnl_attr_get_u8(tb[DEVLINK_ATTR_SB_POOL_THRESHOLD_TYPE])));
+	pr_out_handle_end(dl);
 }
 
 static int cmd_sb_pool_show_cb(const struct nlmsghdr *nlh, void *data)
 {
+	struct dl *dl = data;
 	struct nlattr *tb[DEVLINK_ATTR_MAX + 1] = {};
 	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
 
@@ -1281,7 +1478,7 @@ static int cmd_sb_pool_show_cb(const struct nlmsghdr *nlh, void *data)
 	    !tb[DEVLINK_ATTR_SB_POOL_TYPE] || !tb[DEVLINK_ATTR_SB_POOL_SIZE] ||
 	    !tb[DEVLINK_ATTR_SB_POOL_THRESHOLD_TYPE])
 		return MNL_CB_ERROR;
-	pr_out_sb_pool(tb);
+	pr_out_sb_pool(dl, tb);
 	return MNL_CB_OK;
 }
 
@@ -1303,7 +1500,10 @@ static int cmd_sb_pool_show(struct dl *dl)
 			return err;
 	}
 
-	return _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_sb_pool_show_cb, NULL);
+	pr_out_section_start(dl, "pool");
+	err = _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_sb_pool_show_cb, dl);
+	pr_out_section_end(dl);
+	return err;
 }
 
 static int cmd_sb_pool_set(struct dl *dl)
@@ -1341,11 +1541,14 @@ static int cmd_sb_pool(struct dl *dl)
 
 static void pr_out_sb_port_pool(struct dl *dl, struct nlattr **tb)
 {
-	pr_out_port_handle_nice(dl, tb);
-	pr_out(": sb %u pool %u threshold %u\n",
-	       mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_INDEX]),
-	       mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_POOL_INDEX]),
-	       mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_THRESHOLD]));
+	pr_out_port_handle_start_arr(dl, tb, true);
+	pr_out_uint(dl, "sb",
+		    mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_INDEX]));
+	pr_out_uint(dl, "pool",
+		    mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_POOL_INDEX]));
+	pr_out_uint(dl, "threshold",
+		    mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_THRESHOLD]));
+	pr_out_port_handle_end(dl);
 }
 
 static int cmd_sb_port_pool_show_cb(const struct nlmsghdr *nlh, void *data)
@@ -1382,7 +1585,10 @@ static int cmd_sb_port_pool_show(struct dl *dl)
 			return err;
 	}
 
-	return _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_sb_port_pool_show_cb, dl);
+	pr_out_section_start(dl, "port_pool");
+	err = _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_sb_port_pool_show_cb, dl);
+	pr_out_section_end(dl);
+	return 0;
 }
 
 static int cmd_sb_port_pool_set(struct dl *dl)
@@ -1433,13 +1639,18 @@ static int cmd_sb_port(struct dl *dl)
 
 static void pr_out_sb_tc_bind(struct dl *dl, struct nlattr **tb)
 {
-	pr_out_port_handle_nice(dl, tb);
-	pr_out(": sb %u tc %u type %s pool %u threshold %u\n",
-	       mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_INDEX]),
-	       mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_TC_INDEX]),
-	       pool_type_name(mnl_attr_get_u8(tb[DEVLINK_ATTR_SB_POOL_TYPE])),
-	       mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_POOL_INDEX]),
+	pr_out_port_handle_start_arr(dl, tb, true);
+	pr_out_uint(dl, "sb",
+	       mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_INDEX]));
+	pr_out_uint(dl, "tc",
+	       mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_TC_INDEX]));
+	pr_out_str(dl, "type",
+	       pool_type_name(mnl_attr_get_u8(tb[DEVLINK_ATTR_SB_POOL_TYPE])));
+	pr_out_uint(dl, "pool",
+	       mnl_attr_get_u16(tb[DEVLINK_ATTR_SB_POOL_INDEX]));
+	pr_out_uint(dl, "threshold",
 	       mnl_attr_get_u32(tb[DEVLINK_ATTR_SB_THRESHOLD]));
+	pr_out_port_handle_end(dl);
 }
 
 static int cmd_sb_tc_bind_show_cb(const struct nlmsghdr *nlh, void *data)
@@ -1476,7 +1687,10 @@ static int cmd_sb_tc_bind_show(struct dl *dl)
 			return err;
 	}
 
-	return _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_sb_tc_bind_show_cb, dl);
+	pr_out_section_start(dl, "tc_bind");
+	err = _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_sb_tc_bind_show_cb, dl);
+	pr_out_section_end(dl);
+	return err;
 }
 
 static int cmd_sb_tc_bind_set(struct dl *dl)
@@ -1649,11 +1863,44 @@ static void pr_out_occ_show_item_list(const char *label, struct list_head *list,
 		pr_out("\n");
 }
 
-static void pr_out_occ_show_port(struct occ_port *occ_port)
+static void pr_out_json_occ_show_item_list(struct dl *dl, const char *label,
+					   struct list_head *list,
+					   bool bound_pool)
+{
+	struct occ_item *occ_item;
+	char buf[32];
+
+	jsonw_name(dl->jw, label);
+	jsonw_start_object(dl->jw);
+	list_for_each_entry(occ_item, list, list) {
+		sprintf(buf, "%u", occ_item->index);
+		jsonw_name(dl->jw, buf);
+		jsonw_start_object(dl->jw);
+		if (bound_pool)
+			jsonw_uint_field(dl->jw, "bound_pool",
+					 occ_item->bound_pool_index);
+		jsonw_uint_field(dl->jw, "current", occ_item->cur);
+		jsonw_uint_field(dl->jw, "max", occ_item->max);
+		jsonw_end_object(dl->jw);
+	}
+	jsonw_end_object(dl->jw);
+}
+
+static void pr_out_occ_show_port(struct dl *dl, struct occ_port *occ_port)
 {
-	pr_out_occ_show_item_list("pool", &occ_port->pool_list, false);
-	pr_out_occ_show_item_list("itc", &occ_port->ing_tc_list, true);
-	pr_out_occ_show_item_list("etc", &occ_port->eg_tc_list, true);
+	if (dl->json_output) {
+		pr_out_json_occ_show_item_list(dl, "pool",
+					       &occ_port->pool_list, false);
+		pr_out_json_occ_show_item_list(dl, "itc",
+					       &occ_port->ing_tc_list, true);
+		pr_out_json_occ_show_item_list(dl, "etc",
+					       &occ_port->eg_tc_list, true);
+	} else {
+		pr_out("\n");
+		pr_out_occ_show_item_list("pool", &occ_port->pool_list, false);
+		pr_out_occ_show_item_list("itc", &occ_port->ing_tc_list, true);
+		pr_out_occ_show_item_list("etc", &occ_port->eg_tc_list, true);
+	}
 }
 
 static void pr_out_occ_show(struct occ_show *occ_show)
@@ -1663,10 +1910,10 @@ static void pr_out_occ_show(struct occ_show *occ_show)
 	struct occ_port *occ_port;
 
 	list_for_each_entry(occ_port, &occ_show->port_list, list) {
-		__pr_out_port_handle_nice(dl, opts->bus_name, opts->dev_name,
-					  occ_port->port_index);
-		pr_out(":\n");
-		pr_out_occ_show_port(occ_port);
+		__pr_out_port_handle_start(dl, opts->bus_name, opts->dev_name,
+					   occ_port->port_index, true, false);
+		pr_out_occ_show_port(dl, occ_port);
+		pr_out_port_handle_end(dl);
 	}
 }
 
@@ -1793,7 +2040,9 @@ static int cmd_sb_occ_show(struct dl *dl)
 	if (err)
 		goto out;
 
+	pr_out_section_start(dl, "occupancy");
 	pr_out_occ_show(occ_show);
+	pr_out_section_end(dl);
 
 out:
 	occ_show_free(occ_show);
@@ -1949,7 +2198,7 @@ static int cmd_mon_show_cb(const struct nlmsghdr *nlh, void *data)
 		if (!tb[DEVLINK_ATTR_BUS_NAME] || !tb[DEVLINK_ATTR_DEV_NAME])
 			return MNL_CB_ERROR;
 		pr_out_mon_header(genl->cmd);
-		pr_out_dev(tb);
+		pr_out_dev(dl, tb);
 		break;
 	case DEVLINK_CMD_PORT_GET: /* fall through */
 	case DEVLINK_CMD_PORT_SET: /* fall through */
@@ -1960,7 +2209,7 @@ static int cmd_mon_show_cb(const struct nlmsghdr *nlh, void *data)
 		    !tb[DEVLINK_ATTR_PORT_INDEX])
 			return MNL_CB_ERROR;
 		pr_out_mon_header(genl->cmd);
-		pr_out_port(tb);
+		pr_out_port(dl, tb);
 		break;
 	}
 	return MNL_CB_OK;
@@ -2055,8 +2304,18 @@ static int dl_init(struct dl *dl, int argc, char **argv)
 		pr_err("Failed to create index map\n");
 		goto err_ifname_map_create;
 	}
+	if (dl->json_output) {
+		dl->jw = jsonw_new(stdout);
+		if (!dl->jw) {
+			pr_err("Failed to create JSON writer\n");
+			goto err_json_new;
+		}
+		jsonw_pretty(dl->jw, dl->pretty_output);
+	}
 	return 0;
 
+err_json_new:
+	ifname_map_fini(dl);
 err_ifname_map_create:
 	mnlg_socket_close(dl->nlg);
 	return err;
@@ -2064,6 +2323,8 @@ err_ifname_map_create:
 
 static void dl_fini(struct dl *dl)
 {
+	if (dl->json_output)
+		jsonw_destroy(&dl->jw);
 	ifname_map_fini(dl);
 	mnlg_socket_close(dl->nlg);
 }
@@ -2088,6 +2349,8 @@ int main(int argc, char **argv)
 	static const struct option long_options[] = {
 		{ "Version",		no_argument,		NULL, 'V' },
 		{ "no-nice-names",	no_argument,		NULL, 'n' },
+		{ "json",		no_argument,		NULL, 'j' },
+		{ "pretty",		no_argument,		NULL, 'p' },
 		{ NULL, 0, NULL, 0 }
 	};
 	struct dl *dl;
@@ -2101,7 +2364,7 @@ int main(int argc, char **argv)
 		return EXIT_FAILURE;
 	}
 
-	while ((opt = getopt_long(argc, argv, "Vn",
+	while ((opt = getopt_long(argc, argv, "Vnjp",
 				  long_options, NULL)) >= 0) {
 
 		switch (opt) {
@@ -2111,6 +2374,12 @@ int main(int argc, char **argv)
 		case 'n':
 			dl->no_nice_names = true;
 			break;
+		case 'j':
+			dl->json_output = true;
+			break;
+		case 'p':
+			dl->pretty_output = true;
+			break;
 		default:
 			pr_err("Unknown option.\n");
 			help();
-- 
2.5.5
