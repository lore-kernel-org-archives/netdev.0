From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 06/11] devlink: split dl_argv_parse_put to parse and put parts
Date: Fri, 15 Apr 2016 09:51:48 +0200
Message-ID: <1460706713-5942-7-git-send-email-jiri@resnulli.us>
References: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	idosch@mellanox.com, eladr@mellanox.com, yotamg@mellanox.com,
	ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:34839 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752402AbcDOHwE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 03:52:04 -0400
Received: by mail-wm0-f42.google.com with SMTP id a140so19474073wma.0
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 00:52:03 -0700 (PDT)
In-Reply-To: <1460706713-5942-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

It is handy to have parsed cmdline data stored so they can be used for
dumps filtering. So split original dl_argv_parse_put into parse and put
parts.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 devlink/devlink.c | 105 +++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 69 insertions(+), 36 deletions(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index 5e08666..0c2132f 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -109,12 +109,28 @@ static void ifname_map_free(struct ifname_map *ifname_map)
 	free(ifname_map);
 }
 
+#define BIT(nr)                 (1UL << (nr))
+#define DL_OPT_HANDLE		BIT(0)
+#define DL_OPT_HANDLEP		BIT(1)
+#define DL_OPT_PORT_TYPE	BIT(2)
+#define DL_OPT_PORT_COUNT	BIT(3)
+
+struct dl_opts {
+	uint32_t present; /* flags of present items */
+	char *bus_name;
+	char *dev_name;
+	uint32_t port_index;
+	enum devlink_port_type port_type;
+	uint32_t port_count;
+};
+
 struct dl {
 	struct mnlg_socket *nlg;
 	struct list_head ifname_map_list;
 	int argc;
 	char **argv;
 	bool no_nice_names;
+	struct dl_opts opts;
 };
 
 static int dl_argc(struct dl *dl)
@@ -347,11 +363,9 @@ static int strtouint32_t(const char *str, uint32_t *p_val)
 	return 0;
 }
 
-static int dl_argv_put_handle(struct nlmsghdr *nlh, struct dl *dl)
+static int dl_argv_handle(struct dl *dl, char **p_bus_name, char **p_dev_name)
 {
 	char *str = dl_argv_next(dl);
-	char *bus_name = bus_name;
-	char *dev_name = dev_name;
 
 	if (!str) {
 		pr_err("Devlink identification (\"bus_name/dev_name\") expected\n");
@@ -363,19 +377,15 @@ static int dl_argv_put_handle(struct nlmsghdr *nlh, struct dl *dl)
 		return -EINVAL;
 	}
 
-	strslashrsplit(str, &bus_name, &dev_name);
-	mnl_attr_put_strz(nlh, DEVLINK_ATTR_BUS_NAME, bus_name);
-	mnl_attr_put_strz(nlh, DEVLINK_ATTR_DEV_NAME, dev_name);
+	strslashrsplit(str, p_bus_name, p_dev_name);
 	return 0;
 }
 
-static int dl_argv_put_handle_port(struct nlmsghdr *nlh, struct dl *dl)
+static int dl_argv_handle_port(struct dl *dl, char **p_bus_name,
+			       char **p_dev_name, uint32_t *p_port_index)
 {
 	char *str = dl_argv_next(dl);
 	unsigned int slash_count;
-	char *bus_name = bus_name;
-	char *dev_name = dev_name;
-	uint32_t port_index = port_index;
 	int err;
 
 	if (!str) {
@@ -394,24 +404,21 @@ static int dl_argv_put_handle_port(struct nlmsghdr *nlh, struct dl *dl)
 		char *portstr = portstr;
 
 		err = strslashrsplit(str, &handlestr, &portstr);
-		err = strtouint32_t(portstr, &port_index);
+		err = strtouint32_t(portstr, p_port_index);
 		if (err) {
 			pr_err("Port index \"%s\" is not a number or not within range\n",
 			       portstr);
 			return err;
 		}
-		strslashrsplit(handlestr, &bus_name, &dev_name);
+		strslashrsplit(handlestr, p_bus_name, p_dev_name);
 	} else if (slash_count == 0) {
-		err = ifname_map_lookup(dl, str, &bus_name, &dev_name,
-					&port_index);
+		err = ifname_map_lookup(dl, str, p_bus_name, p_dev_name,
+					p_port_index);
 		if (err) {
 			pr_err("Netdevice \"%s\" not found\n", str);
 			return err;
 		}
 	}
-	mnl_attr_put_strz(nlh, DEVLINK_ATTR_BUS_NAME, bus_name);
-	mnl_attr_put_strz(nlh, DEVLINK_ATTR_DEV_NAME, dev_name);
-	mnl_attr_put_u32(nlh, DEVLINK_ATTR_PORT_INDEX, port_index);
 	return 0;
 }
 
@@ -460,55 +467,46 @@ static int port_type_get(const char *typestr, enum devlink_port_type *p_type)
 	return 0;
 }
 
-#define BIT(nr)                 (1UL << (nr))
-#define DL_OPT_HANDLE		BIT(0)
-#define DL_OPT_HANDLEP		BIT(1)
-#define DL_OPT_PORT_TYPE	BIT(2)
-#define DL_OPT_PORT_COUNT	BIT(3)
-
-static int dl_argv_parse_put(struct nlmsghdr *nlh, struct dl *dl,
-			     uint32_t o_required, uint32_t o_optional)
+static int dl_argv_parse(struct dl *dl, uint32_t o_required,
+			 uint32_t o_optional)
 {
+	struct dl_opts *opts = &dl->opts;
 	uint32_t o_all = o_required | o_optional;
 	uint32_t o_found = 0;
 	int err;
 
 	if (o_required & DL_OPT_HANDLE) {
-		err = dl_argv_put_handle(nlh, dl);
+		err = dl_argv_handle(dl, &opts->bus_name, &opts->dev_name);
 		if (err)
 			return err;
+		o_found |= DL_OPT_HANDLE;
 	} else if (o_required & DL_OPT_HANDLEP) {
-		err = dl_argv_put_handle_port(nlh, dl);
+		err = dl_argv_handle_port(dl, &opts->bus_name, &opts->dev_name,
+					  &opts->port_index);
 		if (err)
 			return err;
+		o_found |= DL_OPT_HANDLEP;
 	}
 
 	while (dl_argc(dl)) {
 		if (dl_argv_match(dl, "type") &&
 		    (o_all & DL_OPT_PORT_TYPE)) {
-			enum devlink_port_type port_type;
 			const char *typestr;
 
 			dl_arg_inc(dl);
 			err = dl_argv_str(dl, &typestr);
 			if (err)
 				return err;
-			err = port_type_get(typestr, &port_type);
+			err = port_type_get(typestr, &opts->port_type);
 			if (err)
 				return err;
-			mnl_attr_put_u16(nlh, DEVLINK_ATTR_PORT_TYPE,
-					 port_type);
 			o_found |= DL_OPT_PORT_TYPE;
 		} else if (dl_argv_match(dl, "count") &&
 			   (o_all & DL_OPT_PORT_COUNT)) {
-			uint32_t count;
-
 			dl_arg_inc(dl);
-			err = dl_argv_uint32_t(dl, &count);
+			err = dl_argv_uint32_t(dl, &opts->port_count);
 			if (err)
 				return err;
-			mnl_attr_put_u32(nlh, DEVLINK_ATTR_PORT_SPLIT_COUNT,
-					 count);
 			o_found |= DL_OPT_PORT_COUNT;
 		} else {
 			pr_err("Unknown option \"%s\"\n", dl_argv(dl));
@@ -516,6 +514,8 @@ static int dl_argv_parse_put(struct nlmsghdr *nlh, struct dl *dl,
 		}
 	}
 
+	opts->present = o_found;
+
 	if ((o_required & DL_OPT_PORT_TYPE) && !(o_found & DL_OPT_PORT_TYPE)) {
 		pr_err("Port type option expected.\n");
 		return -EINVAL;
@@ -530,6 +530,39 @@ static int dl_argv_parse_put(struct nlmsghdr *nlh, struct dl *dl,
 	return 0;
 }
 
+static void dl_opts_put(struct nlmsghdr *nlh, struct dl *dl)
+{
+	struct dl_opts *opts = &dl->opts;
+
+	if (opts->present & DL_OPT_HANDLE) {
+		mnl_attr_put_strz(nlh, DEVLINK_ATTR_BUS_NAME, opts->bus_name);
+		mnl_attr_put_strz(nlh, DEVLINK_ATTR_DEV_NAME, opts->dev_name);
+	} else if (opts->present & DL_OPT_HANDLEP) {
+		mnl_attr_put_strz(nlh, DEVLINK_ATTR_BUS_NAME, opts->bus_name);
+		mnl_attr_put_strz(nlh, DEVLINK_ATTR_DEV_NAME, opts->dev_name);
+		mnl_attr_put_u32(nlh, DEVLINK_ATTR_PORT_INDEX,
+				 opts->port_index);
+	}
+	if (opts->present & DL_OPT_PORT_TYPE)
+		mnl_attr_put_u16(nlh, DEVLINK_ATTR_PORT_TYPE,
+				 opts->port_type);
+	if (opts->present & DL_OPT_PORT_COUNT)
+		mnl_attr_put_u32(nlh, DEVLINK_ATTR_PORT_SPLIT_COUNT,
+				 opts->port_count);
+}
+
+static int dl_argv_parse_put(struct nlmsghdr *nlh, struct dl *dl,
+			     uint32_t o_required, uint32_t o_optional)
+{
+	int err;
+
+	err = dl_argv_parse(dl, o_required, o_optional);
+	if (err)
+		return err;
+	dl_opts_put(nlh, dl);
+	return 0;
+}
+
 static void cmd_dev_help(void)
 {
 	pr_out("Usage: devlink dev show [ DEV ]\n");
-- 
2.5.5
