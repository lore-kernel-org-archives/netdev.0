From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2/net-next] devlink: Add support for pipeline debug (dpipe)
Date: Sat, 25 Mar 2017 08:37:46 +0100
Message-ID: <1490427466-2157-1-git-send-email-jiri@resnulli.us>
References: <1490427342-2061-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, jhs@mojatatu.com, ivecera@redhat.com,
        roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@gmail.com,
        andrew@lunn.ch, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33317 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751308AbdCYHhu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 03:37:50 -0400
Received: by mail-wr0-f194.google.com with SMTP id 20so1398832wrx.0
        for <netdev@vger.kernel.org>; Sat, 25 Mar 2017 00:37:48 -0700 (PDT)
In-Reply-To: <1490427342-2061-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Add support for pipeline debug (dpipe). The headers are used both the
gain visibillity into the headers supported by the hardware, and to
build the headers/field database which is used by other commands.

Examples:

First we can see the headers supported by the hardware:

$devlink dpipe header show pci/0000:03:00.0

pci/0000:03:00.0:
  name mlxsw_meta
  field:
    name erif_port bitwidth 32 mapping_type ifindex
    name l3_forward bitwidth 1
    name l2_drop bitwidth 1

Note that mapping_type is presented only if relevant. Also the header/
field id's are reported by the kernel they are not shown by default.
They can be observed by using the -v option. Also the headers scope
(global/local) is specified.

$devlink -v dpipe header show pci/0000:03:00.0

pci/0000:03:00.0:
  name mlxsw_meta id 0 global false
  field:
    name erif_port id 0 bitwidth 32 mapping_type ifindex
    name l3_forward id 1 bitwidth 1
    name l2_drop id 2 bitwidth 1

Second we can examine the tables supported by the hardware. In order
to dump all the tables no table name should be provided:
$devlink dpipe table show pci/0000:03:00.0

In order to examine specific table its name have to be specified:
$devlink dpipe table show pci/0000:03:00.0 name erif

pci/0000:03:00.0:
  name mlxsw_erif size 800 counters_enabled true
  match:
    type field_exact header mlxsw_meta field erif_port mapping ifindex
  action:
    type field_modify header mlxsw_meta field l3_forward
    type field_modify header mlxsw_meta field l2_drop

To enable/disable counters on the table:
$devlink dpipe table set pci/0000:03:00.0 name erif counters enable
$devlink dpipe table set pci/0000:03:00.0 name erif counters disable

In order to see the current entries in the hardware for specific table:
$devlink dpipe table dump pci/0000:03:00.0 name erif

pci/0000:03:00.0:
  index 0 counter 0
  match_value:
    type field_exact header mlxsw_meta field erif_port mapping ifindex mapping_value 383 value 0
  action_value:
    type field_modify header mlxsw_meta field l3_forward value 1

  index 1 counter 0
  match_value:
    type field_exact header mlxsw_meta field erif_port mapping ifindex mapping_value 381 value 1
  action_value:
    type field_modify header mlxsw_meta field l3_forward value 1

In the above example the table contains two entries which does match
on erif port and forwards the packet or drop it (currently only the
forward count is implemented). The counter values are provided for
example. In case the counting is not enabled on the table the counters
will not be available.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 devlink/devlink.c       | 1413 +++++++++++++++++++++++++++++++++++++++++++----
 include/linux/devlink.h |   67 ++-
 2 files changed, 1382 insertions(+), 98 deletions(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index e90226e..3d525ea 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -34,7 +34,15 @@
 #define ESWITCH_INLINE_MODE_TRANSPORT "transport"
 
 #define pr_err(args...) fprintf(stderr, ##args)
-#define pr_out(args...) fprintf(stdout, ##args)
+#define pr_out(args...)						\
+	do {							\
+		if (g_indent_newline) {				\
+			fprintf(stdout, "%s", g_indent_str);	\
+			g_indent_newline = false;		\
+		}						\
+		fprintf(stdout, ##args);			\
+	} while (0)
+
 #define pr_out_sp(num, args...)					\
 	do {							\
 		int ret = fprintf(stdout, ##args);		\
@@ -42,6 +50,35 @@
 			fprintf(stdout, "%*s", num - ret, "");	\
 	} while (0)
 
+static int g_indent_level;
+static bool g_indent_newline;
+#define INDENT_STR_STEP 2
+#define INDENT_STR_MAXLEN 32
+static char g_indent_str[INDENT_STR_MAXLEN + 1] = "";
+
+static void __pr_out_indent_inc(void)
+{
+	if (g_indent_level + INDENT_STR_STEP > INDENT_STR_MAXLEN)
+		return;
+	g_indent_level += INDENT_STR_STEP;
+	memset(g_indent_str, ' ', sizeof(g_indent_str));
+	g_indent_str[g_indent_level] = '\0';
+}
+
+static void __pr_out_indent_dec(void)
+{
+	if (g_indent_level - INDENT_STR_STEP < 0)
+		return;
+	g_indent_level -= INDENT_STR_STEP;
+	g_indent_str[g_indent_level] = '\0';
+}
+
+static void __pr_out_newline(void)
+{
+	pr_out("\n");
+	g_indent_newline = true;
+}
+
 static int _mnlg_socket_recv_run(struct mnlg_socket *nlg,
 				 mnl_cb_t data_cb, void *data)
 {
@@ -137,6 +174,8 @@ static void ifname_map_free(struct ifname_map *ifname_map)
 #define DL_OPT_SB_TC		BIT(10)
 #define DL_OPT_ESWITCH_MODE	BIT(11)
 #define DL_OPT_ESWITCH_INLINE_MODE	BIT(12)
+#define DL_OPT_DPIPE_TABLE_NAME	BIT(13)
+#define DL_OPT_DPIPE_TABLE_COUNTERS	BIT(14)
 
 struct dl_opts {
 	uint32_t present; /* flags of present items */
@@ -154,6 +193,8 @@ struct dl_opts {
 	uint16_t sb_tc_index;
 	enum devlink_eswitch_mode eswitch_mode;
 	enum devlink_eswitch_inline_mode eswitch_inline_mode;
+	const char *dpipe_table_name;
+	bool dpipe_counters_enable;
 };
 
 struct dl {
@@ -166,6 +207,7 @@ struct dl {
 	json_writer_t *jw;
 	bool json_output;
 	bool pretty_output;
+	bool verbose;
 	struct {
 		bool present;
 		char *bus_name;
@@ -314,6 +356,102 @@ static int attr_cb(const struct nlattr *attr, void *data)
 	if (type == DEVLINK_ATTR_ESWITCH_INLINE_MODE &&
 	    mnl_attr_validate(attr, MNL_TYPE_U8) < 0)
 		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_TABLES &&
+	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_TABLE &&
+	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_TABLE_NAME &&
+	    mnl_attr_validate(attr, MNL_TYPE_STRING) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_TABLE_SIZE &&
+	    mnl_attr_validate(attr, MNL_TYPE_U64) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_TABLE_MATCHES &&
+	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_TABLE_ACTIONS &&
+	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED &&
+	    mnl_attr_validate(attr, MNL_TYPE_U8) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_ENTRIES &&
+	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_ENTRY &&
+	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_ENTRY_INDEX &&
+	    mnl_attr_validate(attr, MNL_TYPE_U64) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_ENTRY_MATCH_VALUES &&
+	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_ENTRY_ACTION_VALUES &&
+	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_ENTRY_COUNTER &&
+	    mnl_attr_validate(attr, MNL_TYPE_U64) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_MATCH &&
+	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_MATCH_VALUE &&
+	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_MATCH_TYPE &&
+	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_ACTION &&
+	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_ACTION_VALUE &&
+	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_ACTION_TYPE &&
+	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_VALUE_MAPPING &&
+	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_HEADERS &&
+	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_HEADER &&
+	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_HEADER_NAME &&
+	    mnl_attr_validate(attr, MNL_TYPE_STRING) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_HEADER_ID &&
+	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_HEADER_FIELDS &&
+	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_HEADER_GLOBAL &&
+	    mnl_attr_validate(attr, MNL_TYPE_U8) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_HEADER_INDEX &&
+	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_FIELD &&
+	    mnl_attr_validate(attr, MNL_TYPE_NESTED) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_FIELD_NAME &&
+	    mnl_attr_validate(attr, MNL_TYPE_STRING) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_FIELD_ID &&
+	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_FIELD_BITWIDTH &&
+	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
+		return MNL_CB_ERROR;
+	if (type == DEVLINK_ATTR_DPIPE_FIELD_MAPPING_TYPE &&
+	    mnl_attr_validate(attr, MNL_TYPE_U32) < 0)
+		return MNL_CB_ERROR;
 	tb[type] = attr;
 	return MNL_CB_OK;
 }
@@ -709,6 +847,20 @@ static int eswitch_inline_mode_get(const char *typestr,
 	return 0;
 }
 
+static int dpipe_counters_enable_get(const char *typestr,
+				     bool *counters_enable)
+{
+	if (strcmp(typestr, "enable") == 0) {
+		*counters_enable = 1;
+	} else if (strcmp(typestr, "disable") == 0) {
+		*counters_enable = 0;
+	} else {
+		pr_err("Unknown counter_state \"%s\"\n", typestr);
+		return -EINVAL;
+	}
+	return 0;
+}
+
 static int dl_argv_parse(struct dl *dl, uint32_t o_required,
 			 uint32_t o_optional)
 {
@@ -843,6 +995,27 @@ static int dl_argv_parse(struct dl *dl, uint32_t o_required,
 			if (err)
 				return err;
 			o_found |= DL_OPT_ESWITCH_INLINE_MODE;
+		} else if (dl_argv_match(dl, "name") &&
+			   (o_all & DL_OPT_DPIPE_TABLE_NAME)) {
+			dl_arg_inc(dl);
+			err = dl_argv_str(dl, &opts->dpipe_table_name);
+			if (err)
+				return err;
+			o_found |= DL_OPT_DPIPE_TABLE_NAME;
+		} else if (dl_argv_match(dl, "counters") &&
+			   (o_all & DL_OPT_DPIPE_TABLE_COUNTERS)) {
+			const char *typestr;
+
+			dl_arg_inc(dl);
+			err = dl_argv_str(dl, &typestr);
+			if (err)
+				return err;
+			err = dpipe_counters_enable_get(typestr,
+							&opts->dpipe_counters_enable);
+			if (err)
+				return err;
+			o_found |= DL_OPT_DPIPE_TABLE_COUNTERS;
+
 		} else {
 			pr_err("Unknown option \"%s\"\n", dl_argv(dl));
 			return -EINVAL;
@@ -909,6 +1082,17 @@ static int dl_argv_parse(struct dl *dl, uint32_t o_required,
 		return -EINVAL;
 	}
 
+	if ((o_required & DL_OPT_DPIPE_TABLE_NAME) &&
+	    !(o_found & DL_OPT_DPIPE_TABLE_NAME)) {
+		pr_err("Dpipe table name expected\n");
+		return -EINVAL;
+	}
+
+	if ((o_required & DL_OPT_DPIPE_TABLE_COUNTERS) &&
+	    !(o_found & DL_OPT_DPIPE_TABLE_COUNTERS)) {
+		pr_err("Dpipe table counter state expected\n");
+		return -EINVAL;
+	}
 	return 0;
 }
 
@@ -958,6 +1142,12 @@ static void dl_opts_put(struct nlmsghdr *nlh, struct dl *dl)
 	if (opts->present & DL_OPT_ESWITCH_INLINE_MODE)
 		mnl_attr_put_u8(nlh, DEVLINK_ATTR_ESWITCH_INLINE_MODE,
 				opts->eswitch_inline_mode);
+	if (opts->present & DL_OPT_DPIPE_TABLE_NAME)
+		mnl_attr_put_strz(nlh, DEVLINK_ATTR_DPIPE_TABLE_NAME,
+				  opts->dpipe_table_name);
+	if (opts->present & DL_OPT_DPIPE_TABLE_COUNTERS)
+		mnl_attr_put_u8(nlh, DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED,
+				opts->dpipe_counters_enable);
 }
 
 static int dl_argv_parse_put(struct nlmsghdr *nlh, struct dl *dl,
@@ -1076,7 +1266,19 @@ static void __pr_out_handle_start(struct dl *dl, struct nlattr **tb,
 			jsonw_start_object(dl->jw);
 		}
 	} else {
-		pr_out("%s%s", buf, content ? ":" : "");
+		if (array) {
+			if (should_arr_last_handle_end(dl, bus_name, dev_name))
+				__pr_out_indent_dec();
+			if (should_arr_last_handle_start(dl, bus_name,
+							 dev_name)) {
+				pr_out("%s%s", buf, content ? ":" : "");
+				__pr_out_newline();
+				__pr_out_indent_inc();
+				arr_last_handle_set(dl, bus_name, dev_name);
+			}
+		} else {
+			pr_out("%s%s", buf, content ? ":" : "");
+		}
 	}
 }
 
@@ -1090,7 +1292,7 @@ static void pr_out_handle_end(struct dl *dl)
 	if (dl->json_output)
 		jsonw_end_object(dl->jw);
 	else
-		pr_out("\n");
+		__pr_out_newline();
 }
 
 static void pr_out_handle(struct dl *dl, struct nlattr **tb)
@@ -1206,18 +1408,26 @@ static void pr_out_port_handle_end(struct dl *dl)
 
 static void pr_out_str(struct dl *dl, const char *name, const char *val)
 {
-	if (dl->json_output)
+	if (dl->json_output) {
 		jsonw_string_field(dl->jw, name, val);
-	else
-		pr_out(" %s %s", name, val);
+	} else {
+		if (g_indent_newline)
+			pr_out("%s %s", name, val);
+		else
+			pr_out(" %s %s", name, val);
+	}
 }
 
 static void pr_out_uint(struct dl *dl, const char *name, unsigned int val)
 {
-	if (dl->json_output)
+	if (dl->json_output) {
 		jsonw_uint_field(dl->jw, name, val);
-	else
-		pr_out(" %s %u", name, val);
+	} else {
+		if (g_indent_newline)
+			pr_out("%s %u", name, val);
+		else
+			pr_out(" %s %u", name, val);
+	}
 }
 
 static void pr_out_dev(struct dl *dl, struct nlattr **tb)
@@ -1244,6 +1454,42 @@ static void pr_out_section_end(struct dl *dl)
 	}
 }
 
+static void pr_out_array_start(struct dl *dl, const char *name)
+{
+	if (dl->json_output) {
+		jsonw_name(dl->jw, name);
+		jsonw_start_array(dl->jw);
+	} else {
+		if (!g_indent_newline)
+			__pr_out_newline();
+		pr_out("%s:", name);
+		__pr_out_newline();
+		__pr_out_indent_inc();
+	}
+}
+
+static void pr_out_array_end(struct dl *dl)
+{
+	if (dl->json_output)
+		jsonw_end_array(dl->jw);
+	else
+		__pr_out_indent_dec();
+}
+
+static void pr_out_entry_start(struct dl *dl)
+{
+	if (dl->json_output)
+		jsonw_start_object(dl->jw);
+}
+
+static void pr_out_entry_end(struct dl *dl)
+{
+	if (dl->json_output)
+		jsonw_end_object(dl->jw);
+	else
+		__pr_out_newline();
+}
+
 static const char *eswitch_mode_name(uint32_t mode)
 {
 	switch (mode) {
@@ -2466,130 +2712,1103 @@ static int cmd_mon(struct dl *dl)
 	return -ENOENT;
 }
 
-static void help(void)
+struct dpipe_field {
+	char *name;
+	unsigned int id;
+	unsigned int bitwidth;
+	enum devlink_dpipe_field_mapping_type mapping_type;
+};
+
+struct dpipe_header {
+	struct list_head list;
+	char *name;
+	unsigned int id;
+	struct dpipe_field *fields;
+	unsigned int fields_count;
+};
+
+struct dpipe_ctx {
+	struct dl *dl;
+	int err;
+	struct list_head global_headers;
+	struct list_head local_headers;
+	bool print_headers;
+};
+
+static struct dpipe_header *dpipe_header_alloc(unsigned int fields_count)
 {
-	pr_err("Usage: devlink [ OPTIONS ] OBJECT { COMMAND | help }\n"
-	       "where  OBJECT := { dev | port | sb | monitor }\n"
-	       "       OPTIONS := { -V[ersion] | -n[no-nice-names] | -j[json] | -p[pretty] }\n");
+	struct dpipe_header *header;
+
+	header = calloc(1, sizeof(struct dpipe_header));
+	if (!header)
+		return NULL;
+	header->fields = calloc(fields_count, sizeof(struct dpipe_field));
+	if (!header->fields)
+		goto err_fields_alloc;
+	header->fields_count = fields_count;
+	return header;
+
+err_fields_alloc:
+	free(header);
+	return NULL;
 }
 
-static int dl_cmd(struct dl *dl)
+static void dpipe_header_free(struct dpipe_header *header)
 {
-	if (dl_argv_match(dl, "help") || dl_no_arg(dl)) {
-		help();
-		return 0;
-	} else if (dl_argv_match(dl, "dev")) {
-		dl_arg_inc(dl);
-		return cmd_dev(dl);
-	} else if (dl_argv_match(dl, "port")) {
-		dl_arg_inc(dl);
-		return cmd_port(dl);
-	} else if (dl_argv_match(dl, "sb")) {
-		dl_arg_inc(dl);
-		return cmd_sb(dl);
-	} else if (dl_argv_match(dl, "monitor")) {
-		dl_arg_inc(dl);
-		return cmd_mon(dl);
+	free(header->fields);
+	free(header);
+}
+
+static void dpipe_header_clear(struct dpipe_header *header)
+{
+	struct dpipe_field *field;
+	int i;
+
+	for (i = 0; i < header->fields_count; i++) {
+		field = &header->fields[i];
+		free(field->name);
 	}
-	pr_err("Object \"%s\" not found\n", dl_argv(dl));
-	return -ENOENT;
+	free(header->name);
 }
 
-static int dl_init(struct dl *dl, int argc, char **argv)
+static void dpipe_header_add(struct dpipe_ctx *ctx,
+			     struct dpipe_header *header, bool global)
 {
-	int err;
+	if (global)
+		list_add(&header->list, &ctx->global_headers);
+	else
+		list_add(&header->list, &ctx->local_headers);
+}
 
-	dl->argc = argc;
-	dl->argv = argv;
+static void dpipe_header_del(struct dpipe_header *header)
+{
+	list_del(&header->list);
+}
 
-	dl->nlg = mnlg_socket_open(DEVLINK_GENL_NAME, DEVLINK_GENL_VERSION);
-	if (!dl->nlg) {
-		pr_err("Failed to connect to devlink Netlink\n");
-		return -errno;
-	}
+static struct dpipe_ctx *dpipe_ctx_alloc(struct dl *dl)
+{
+	struct dpipe_ctx *ctx;
 
-	err = ifname_map_init(dl);
-	if (err) {
-		pr_err("Failed to create index map\n");
-		goto err_ifname_map_create;
+	ctx = calloc(1, sizeof(struct dpipe_ctx));
+	if (!ctx)
+		return NULL;
+	ctx->dl = dl;
+	INIT_LIST_HEAD(&ctx->global_headers);
+	INIT_LIST_HEAD(&ctx->local_headers);
+	return ctx;
+}
+
+static void dpipe_ctx_free(struct dpipe_ctx *ctx)
+{
+	free(ctx);
+}
+
+static void dpipe_ctx_clear(struct dpipe_ctx *ctx)
+{
+	struct dpipe_header *header, *tmp;
+
+	list_for_each_entry_safe(header, tmp, &ctx->global_headers,
+				 list) {
+		dpipe_header_del(header);
+		dpipe_header_clear(header);
+		dpipe_header_free(header);
 	}
-	if (dl->json_output) {
-		dl->jw = jsonw_new(stdout);
-		if (!dl->jw) {
-			pr_err("Failed to create JSON writer\n");
-			goto err_json_new;
-		}
-		jsonw_pretty(dl->jw, dl->pretty_output);
+	list_for_each_entry_safe(header, tmp, &ctx->local_headers,
+				 list) {
+		dpipe_header_del(header);
+		dpipe_header_clear(header);
+		dpipe_header_free(header);
 	}
-	return 0;
-
-err_json_new:
-	ifname_map_fini(dl);
-err_ifname_map_create:
-	mnlg_socket_close(dl->nlg);
-	return err;
 }
 
-static void dl_fini(struct dl *dl)
+static const char *dpipe_header_id2s(struct dpipe_ctx *ctx,
+				     uint32_t header_id, bool global)
 {
-	if (dl->json_output)
-		jsonw_destroy(&dl->jw);
-	ifname_map_fini(dl);
-	mnlg_socket_close(dl->nlg);
+	struct list_head *header_list;
+	struct dpipe_header *header;
+
+	if (global)
+		header_list = &ctx->global_headers;
+	else
+		header_list = &ctx->local_headers;
+	list_for_each_entry(header, header_list, list) {
+		if (header->id != header_id)
+			continue;
+		return header->name;
+	}
+	return NULL;
 }
 
-static struct dl *dl_alloc(void)
+static const char *dpipe_field_id2s(struct dpipe_ctx *ctx,
+				    uint32_t header_id,
+				    uint32_t field_id, bool global)
 {
-	struct dl *dl;
+	struct list_head *header_list;
+	struct dpipe_header *header;
 
-	dl = calloc(1, sizeof(*dl));
-	if (!dl)
+	if (global)
+		header_list = &ctx->global_headers;
+	else
+		header_list = &ctx->local_headers;
+	list_for_each_entry(header, header_list, list) {
+		if (header->id != header_id)
+			continue;
+		return header->fields[field_id].name;
+	}
+	return NULL;
+}
+
+static const char *
+dpipe_field_mapping_e2s(enum devlink_dpipe_field_mapping_type mapping_type)
+{
+	switch (mapping_type) {
+	case DEVLINK_DPIPE_FIELD_MAPPING_TYPE_NONE:
 		return NULL;
-	return dl;
+	case DEVLINK_DPIPE_FIELD_MAPPING_TYPE_IFINDEX:
+		return "ifindex";
+	default:
+		return "<unknown>";
+	}
 }
 
-static void dl_free(struct dl *dl)
+static const char *
+dpipe_mapping_get(struct dpipe_ctx *ctx, uint32_t header_id,
+		  uint32_t field_id, bool global)
 {
-	free(dl);
+	enum devlink_dpipe_field_mapping_type mapping_type;
+	struct list_head *header_list;
+	struct dpipe_header *header;
+
+	if (global)
+		header_list = &ctx->global_headers;
+	else
+		header_list = &ctx->local_headers;
+	list_for_each_entry(header, header_list, list) {
+		if (header->id != header_id)
+			continue;
+		mapping_type = header->fields[field_id].mapping_type;
+		return dpipe_field_mapping_e2s(mapping_type);
+	}
+	return NULL;
 }
 
-int main(int argc, char **argv)
+static void pr_out_dpipe_fields(struct dpipe_ctx *ctx,
+				struct dpipe_field *fields,
+				unsigned int field_count)
 {
-	static const struct option long_options[] = {
-		{ "Version",		no_argument,		NULL, 'V' },
-		{ "no-nice-names",	no_argument,		NULL, 'n' },
-		{ "json",		no_argument,		NULL, 'j' },
-		{ "pretty",		no_argument,		NULL, 'p' },
-		{ NULL, 0, NULL, 0 }
-	};
-	struct dl *dl;
-	int opt;
-	int err;
-	int ret;
+	struct dpipe_field *field;
+	int i;
 
-	dl = dl_alloc();
-	if (!dl) {
-		pr_err("Failed to allocate memory for devlink\n");
-		return EXIT_FAILURE;
+	for (i = 0; i < field_count; i++) {
+		field = &fields[i];
+		pr_out_entry_start(ctx->dl);
+		pr_out_str(ctx->dl, "name", field->name);
+		if (ctx->dl->verbose)
+			pr_out_uint(ctx->dl, "id", field->id);
+		pr_out_uint(ctx->dl, "bitwidth", field->bitwidth);
+		if (field->mapping_type)
+			pr_out_str(ctx->dl, "mapping_type",
+				   dpipe_field_mapping_e2s(field->mapping_type));
+		pr_out_entry_end(ctx->dl);
 	}
+}
 
-	while ((opt = getopt_long(argc, argv, "Vnjp",
-				  long_options, NULL)) >= 0) {
+static void
+pr_out_dpipe_header(struct dpipe_ctx *ctx, struct nlattr **tb,
+		    struct dpipe_header *header, bool global)
+{
+	pr_out_handle_start_arr(ctx->dl, tb);
+	pr_out_str(ctx->dl, "name", header->name);
+	if (ctx->dl->verbose) {
+		pr_out_uint(ctx->dl, "id", header->id);
+		pr_out_str(ctx->dl, "global",
+			   global ? "true" : "false");
+	}
+	pr_out_array_start(ctx->dl, "field");
+	pr_out_dpipe_fields(ctx, header->fields,
+			    header->fields_count);
+	pr_out_array_end(ctx->dl);
+	pr_out_handle_end(ctx->dl);
+}
 
-		switch (opt) {
-		case 'V':
-			printf("devlink utility, iproute2-ss%s\n", SNAPSHOT);
-			ret = EXIT_SUCCESS;
-			goto dl_free;
-		case 'n':
-			dl->no_nice_names = true;
-			break;
-		case 'j':
+static void pr_out_dpipe_headers(struct dpipe_ctx *ctx,
+				 struct nlattr **tb)
+{
+	struct dpipe_header *header;
+
+	list_for_each_entry(header, &ctx->local_headers, list)
+		pr_out_dpipe_header(ctx, tb, header, false);
+
+	list_for_each_entry(header, &ctx->global_headers, list)
+		pr_out_dpipe_header(ctx, tb, header, true);
+}
+
+static int dpipe_header_field_get(struct nlattr *nl, struct dpipe_field *field)
+{
+	struct nlattr *nla_field[DEVLINK_ATTR_MAX + 1] = {};
+	const char *name;
+	int err;
+
+	err = mnl_attr_parse_nested(nl, attr_cb, nla_field);
+	if (err != MNL_CB_OK)
+		return -EINVAL;
+	if (!nla_field[DEVLINK_ATTR_DPIPE_FIELD_ID] ||
+	    !nla_field[DEVLINK_ATTR_DPIPE_FIELD_NAME] ||
+	    !nla_field[DEVLINK_ATTR_DPIPE_FIELD_BITWIDTH] ||
+	    !nla_field[DEVLINK_ATTR_DPIPE_FIELD_MAPPING_TYPE])
+		return -EINVAL;
+
+	name = mnl_attr_get_str(nla_field[DEVLINK_ATTR_DPIPE_FIELD_NAME]);
+	field->id = mnl_attr_get_u32(nla_field[DEVLINK_ATTR_DPIPE_FIELD_ID]);
+	field->bitwidth = mnl_attr_get_u32(nla_field[DEVLINK_ATTR_DPIPE_FIELD_BITWIDTH]);
+	field->name = strdup(name);
+	if (!field->name)
+		return -ENOMEM;
+	field->mapping_type = mnl_attr_get_u32(nla_field[DEVLINK_ATTR_DPIPE_FIELD_MAPPING_TYPE]);
+	return 0;
+}
+
+static int dpipe_header_fields_get(struct nlattr *nla_fields,
+				   struct dpipe_field *fields)
+{
+	struct nlattr *nla_field;
+	int count = 0;
+	int err;
+
+	mnl_attr_for_each_nested(nla_field, nla_fields) {
+		err = dpipe_header_field_get(nla_field, &fields[count]);
+		if (err)
+			return err;
+		count++;
+	}
+	return 0;
+}
+
+static unsigned int dpipe_header_field_count_get(struct nlattr *nla_fields)
+{
+	struct nlattr *nla_field;
+	unsigned int count = 0;
+
+	mnl_attr_for_each_nested(nla_field, nla_fields)
+		count++;
+	return count;
+}
+
+static int dpipe_header_get(struct dpipe_ctx *ctx, struct nlattr *nl)
+{
+	struct nlattr *nla_header[DEVLINK_ATTR_MAX + 1] = {};
+	struct dpipe_header *header;
+	unsigned int fields_count;
+	const char *header_name;
+	bool global;
+	int err;
+
+	err = mnl_attr_parse_nested(nl, attr_cb, nla_header);
+	if (err != MNL_CB_OK)
+		return -EINVAL;
+
+	if (!nla_header[DEVLINK_ATTR_DPIPE_HEADER_NAME] ||
+	    !nla_header[DEVLINK_ATTR_DPIPE_HEADER_ID] ||
+	    !nla_header[DEVLINK_ATTR_DPIPE_HEADER_FIELDS])
+		return -EINVAL;
+
+	fields_count = dpipe_header_field_count_get(nla_header[DEVLINK_ATTR_DPIPE_HEADER_FIELDS]);
+	header = dpipe_header_alloc(fields_count);
+	if (!header)
+		return -ENOMEM;
+
+	header_name = mnl_attr_get_str(nla_header[DEVLINK_ATTR_DPIPE_HEADER_NAME]);
+	header->name = strdup(header_name);
+	header->id = mnl_attr_get_u32(nla_header[DEVLINK_ATTR_DPIPE_HEADER_ID]);
+	header->fields_count = fields_count;
+	global = !!mnl_attr_get_u8(nla_header[DEVLINK_ATTR_DPIPE_HEADER_GLOBAL]);
+
+	err = dpipe_header_fields_get(nla_header[DEVLINK_ATTR_DPIPE_HEADER_FIELDS],
+				      header->fields);
+	if (err)
+		goto err_field_get;
+	dpipe_header_add(ctx, header, global);
+	return 0;
+
+err_field_get:
+	dpipe_header_free(header);
+	return err;
+}
+
+static int dpipe_headers_get(struct dpipe_ctx *ctx, struct nlattr **tb)
+{
+	struct nlattr *nla_headers = tb[DEVLINK_ATTR_DPIPE_HEADERS];
+	struct nlattr *nla_header;
+	int err;
+
+	mnl_attr_for_each_nested(nla_header, nla_headers) {
+		err = dpipe_header_get(ctx, nla_header);
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
+static int cmd_dpipe_header_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct dpipe_ctx *ctx = data;
+	struct nlattr *tb[DEVLINK_ATTR_MAX + 1] = {};
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+	int err;
+
+	mnl_attr_parse(nlh, sizeof(*genl), attr_cb, tb);
+	if (!tb[DEVLINK_ATTR_BUS_NAME] || !tb[DEVLINK_ATTR_DEV_NAME] ||
+	    !tb[DEVLINK_ATTR_DPIPE_HEADERS])
+		return MNL_CB_ERROR;
+	err = dpipe_headers_get(ctx, tb);
+	if (err) {
+		ctx->err = err;
+		return MNL_CB_ERROR;
+	}
+
+	if (ctx->print_headers)
+		pr_out_dpipe_headers(ctx, tb);
+	return MNL_CB_OK;
+}
+
+static int cmd_dpipe_headers_show(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	struct dpipe_ctx *ctx;
+	uint16_t flags = NLM_F_REQUEST | NLM_F_ACK;
+	int err;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_DPIPE_HEADERS_GET, flags);
+
+	err = dl_argv_parse_put(nlh, dl, DL_OPT_HANDLE, 0);
+	if (err)
+		return err;
+
+	ctx = dpipe_ctx_alloc(dl);
+	if (!ctx)
+		return -ENOMEM;
+
+	ctx->print_headers = true;
+
+	pr_out_section_start(dl, "header");
+	err = _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_dpipe_header_cb, ctx);
+	if (err)
+		pr_err("error get headers %s\n", strerror(ctx->err));
+	pr_out_section_end(dl);
+
+	dpipe_ctx_clear(ctx);
+	dpipe_ctx_free(ctx);
+	return err;
+}
+
+static void cmd_dpipe_header_help(void)
+{
+	pr_err("Usage: devlink dpipe headers show DEV\n");
+}
+
+static int cmd_dpipe_header(struct dl *dl)
+{
+	if (dl_argv_match(dl, "help") || dl_no_arg(dl)) {
+		cmd_dpipe_header_help();
+		return 0;
+	} else if (dl_argv_match(dl, "show")) {
+		dl_arg_inc(dl);
+		return cmd_dpipe_headers_show(dl);
+	}
+	pr_err("Command \"%s\" not found\n", dl_argv(dl));
+	return -ENOENT;
+}
+
+static const char
+*dpipe_action_type_e2s(enum devlink_dpipe_action_type action_type)
+{
+	switch (action_type) {
+	case DEVLINK_DPIPE_ACTION_TYPE_FIELD_MODIFY:
+		return "field_modify";
+	default:
+		return "<unknown>";
+	}
+}
+
+static void pr_out_dpipe_action(struct dpipe_ctx *ctx,
+				uint32_t header_id, uint32_t field_id,
+				uint32_t action_type, bool global)
+{
+	const char *mapping;
+
+	pr_out_str(ctx->dl, "type", dpipe_action_type_e2s(action_type));
+	pr_out_str(ctx->dl, "header", dpipe_header_id2s(ctx, header_id,
+							global));
+	pr_out_str(ctx->dl, "field", dpipe_field_id2s(ctx, header_id, field_id,
+						      global));
+	mapping = dpipe_mapping_get(ctx, header_id, field_id, global);
+	if (mapping)
+		pr_out_str(ctx->dl, "mapping", mapping);
+}
+
+static int dpipe_action_show(struct dpipe_ctx *ctx, struct nlattr *nl)
+{
+	struct nlattr *nla_action[DEVLINK_ATTR_MAX + 1] = {};
+	uint32_t header_id, field_id, action_type;
+	bool global;
+	int err;
+
+	err = mnl_attr_parse_nested(nl, attr_cb, nla_action);
+	if (err != MNL_CB_OK)
+		return -EINVAL;
+
+	if (!nla_action[DEVLINK_ATTR_DPIPE_ACTION_TYPE] ||
+	    !nla_action[DEVLINK_ATTR_DPIPE_HEADER_INDEX] ||
+	    !nla_action[DEVLINK_ATTR_DPIPE_HEADER_ID] ||
+	    !nla_action[DEVLINK_ATTR_DPIPE_FIELD_ID]) {
+		return -EINVAL;
+	}
+
+	header_id = mnl_attr_get_u32(nla_action[DEVLINK_ATTR_DPIPE_HEADER_ID]);
+	field_id = mnl_attr_get_u32(nla_action[DEVLINK_ATTR_DPIPE_FIELD_ID]);
+	action_type = mnl_attr_get_u32(nla_action[DEVLINK_ATTR_DPIPE_ACTION_TYPE]);
+	global = !!mnl_attr_get_u8(nla_action[DEVLINK_ATTR_DPIPE_HEADER_GLOBAL]);
+
+	pr_out_dpipe_action(ctx, header_id, field_id, action_type, global);
+	return 0;
+}
+
+static int dpipe_table_actions_show(struct dpipe_ctx *ctx,
+				    struct nlattr *nla_actions)
+{
+	struct nlattr *nla_action;
+
+	mnl_attr_for_each_nested(nla_action, nla_actions) {
+		pr_out_entry_start(ctx->dl);
+		if (dpipe_action_show(ctx, nla_action))
+			goto err_action_show;
+		pr_out_entry_end(ctx->dl);
+	}
+	return 0;
+
+err_action_show:
+	pr_out_entry_end(ctx->dl);
+	return -EINVAL;
+}
+
+static const char *
+dpipe_match_type_e2s(enum devlink_dpipe_match_type match_type)
+{
+	switch (match_type) {
+	case DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT:
+		return "field_exact";
+	default:
+		return "<unknown>";
+	}
+}
+
+static void pr_out_dpipe_match(struct dpipe_ctx *ctx,
+			       uint32_t header_id, uint32_t field_id,
+			       uint32_t match_type, bool global)
+{
+	const char *mapping;
+
+	pr_out_str(ctx->dl, "type", dpipe_match_type_e2s(match_type));
+	pr_out_str(ctx->dl, "header", dpipe_header_id2s(ctx, header_id,
+							global));
+	pr_out_str(ctx->dl, "field", dpipe_field_id2s(ctx, header_id, field_id,
+						      global));
+	mapping = dpipe_mapping_get(ctx, header_id, field_id, global);
+	if (mapping)
+		pr_out_str(ctx->dl, "mapping", mapping);
+
+}
+
+static int dpipe_match_show(struct dpipe_ctx *ctx, struct nlattr *nl)
+{
+	struct nlattr *nla_match[DEVLINK_ATTR_MAX + 1] = {};
+	uint32_t header_id, field_id, match_type;
+	bool global;
+	int err;
+
+	err = mnl_attr_parse_nested(nl, attr_cb, nla_match);
+	if (err != MNL_CB_OK)
+		return -EINVAL;
+
+	if (!nla_match[DEVLINK_ATTR_DPIPE_MATCH_TYPE] ||
+	    !nla_match[DEVLINK_ATTR_DPIPE_HEADER_INDEX] ||
+	    !nla_match[DEVLINK_ATTR_DPIPE_HEADER_ID] ||
+	    !nla_match[DEVLINK_ATTR_DPIPE_FIELD_ID]) {
+		return -EINVAL;
+	}
+
+	match_type = mnl_attr_get_u32(nla_match[DEVLINK_ATTR_DPIPE_MATCH_TYPE]);
+	header_id = mnl_attr_get_u32(nla_match[DEVLINK_ATTR_DPIPE_HEADER_ID]);
+	field_id = mnl_attr_get_u32(nla_match[DEVLINK_ATTR_DPIPE_FIELD_ID]);
+	global = !!mnl_attr_get_u8(nla_match[DEVLINK_ATTR_DPIPE_HEADER_GLOBAL]);
+
+	pr_out_dpipe_match(ctx, header_id, field_id, match_type, global);
+	return 0;
+}
+
+static int dpipe_table_matches_show(struct dpipe_ctx *ctx,
+				    struct nlattr *nla_matches)
+{
+	struct nlattr *nla_match;
+
+	mnl_attr_for_each_nested(nla_match, nla_matches) {
+		pr_out_entry_start(ctx->dl);
+		if (dpipe_match_show(ctx, nla_match))
+			goto err_match_show;
+		pr_out_entry_end(ctx->dl);
+	}
+	return 0;
+
+err_match_show:
+	pr_out_entry_end(ctx->dl);
+	return -EINVAL;
+}
+
+static int dpipe_table_show(struct dpipe_ctx *ctx, struct nlattr *nl)
+{
+	struct nlattr *nla_table[DEVLINK_ATTR_MAX + 1] = {};
+	bool counters_enabled;
+	const char *name;
+	uint32_t size;
+	int err;
+
+	err = mnl_attr_parse_nested(nl, attr_cb, nla_table);
+	if (err != MNL_CB_OK)
+		return -EINVAL;
+
+	if (!nla_table[DEVLINK_ATTR_DPIPE_TABLE_NAME] ||
+	    !nla_table[DEVLINK_ATTR_DPIPE_TABLE_SIZE] ||
+	    !nla_table[DEVLINK_ATTR_DPIPE_TABLE_ACTIONS] ||
+	    !nla_table[DEVLINK_ATTR_DPIPE_TABLE_MATCHES] ||
+	    !nla_table[DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED]) {
+		return -EINVAL;
+	}
+
+	name = mnl_attr_get_str(nla_table[DEVLINK_ATTR_DPIPE_TABLE_NAME]);
+	size = mnl_attr_get_u32(nla_table[DEVLINK_ATTR_DPIPE_TABLE_SIZE]);
+	counters_enabled = !!mnl_attr_get_u8(nla_table[DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED]);
+
+	pr_out_str(ctx->dl, "name", name);
+	pr_out_uint(ctx->dl, "size", size);
+	pr_out_str(ctx->dl, "counters_enabled",
+		   counters_enabled ? "true" : "false");
+
+	pr_out_array_start(ctx->dl, "match");
+	if (dpipe_table_matches_show(ctx, nla_table[DEVLINK_ATTR_DPIPE_TABLE_MATCHES]))
+		goto err_matches_show;
+	pr_out_array_end(ctx->dl);
+
+	pr_out_array_start(ctx->dl, "action");
+	if (dpipe_table_actions_show(ctx, nla_table[DEVLINK_ATTR_DPIPE_TABLE_ACTIONS]))
+		goto err_actions_show;
+	pr_out_array_end(ctx->dl);
+
+	return 0;
+
+err_actions_show:
+err_matches_show:
+	pr_out_array_end(ctx->dl);
+	return -EINVAL;
+}
+
+static int dpipe_tables_show(struct dpipe_ctx *ctx, struct nlattr **tb)
+{
+	struct nlattr *nla_tables = tb[DEVLINK_ATTR_DPIPE_TABLES];
+	struct nlattr *nla_table;
+
+	mnl_attr_for_each_nested(nla_table, nla_tables) {
+		pr_out_handle_start_arr(ctx->dl, tb);
+		if (dpipe_table_show(ctx, nla_table))
+			goto err_table_show;
+		pr_out_handle_end(ctx->dl);
+	}
+	return 0;
+
+err_table_show:
+	pr_out_handle_end(ctx->dl);
+	return -EINVAL;
+}
+
+static int cmd_dpipe_table_show_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct dpipe_ctx *ctx = data;
+	struct nlattr *tb[DEVLINK_ATTR_MAX + 1] = {};
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+
+	mnl_attr_parse(nlh, sizeof(*genl), attr_cb, tb);
+	if (!tb[DEVLINK_ATTR_BUS_NAME] || !tb[DEVLINK_ATTR_DEV_NAME] ||
+	    !tb[DEVLINK_ATTR_DPIPE_TABLES])
+		return MNL_CB_ERROR;
+
+	if (dpipe_tables_show(ctx, tb))
+		return MNL_CB_ERROR;
+	return MNL_CB_OK;
+}
+
+static int cmd_dpipe_table_show(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	struct dpipe_ctx *ctx;
+	uint16_t flags = NLM_F_REQUEST;
+	int err;
+
+	ctx = dpipe_ctx_alloc(dl);
+	if (!ctx)
+		return -ENOMEM;
+
+	err = dl_argv_parse(dl, DL_OPT_HANDLE, DL_OPT_DPIPE_TABLE_NAME);
+	if (err)
+		goto out;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_DPIPE_HEADERS_GET, flags);
+	dl_opts_put(nlh, dl);
+	err = _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_dpipe_header_cb, ctx);
+	if (err) {
+		pr_err("error get headers %s\n", strerror(ctx->err));
+		goto out;
+	}
+
+	flags = NLM_F_REQUEST | NLM_F_ACK;
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_DPIPE_TABLE_GET, flags);
+	dl_opts_put(nlh, dl);
+
+	pr_out_section_start(dl, "table");
+	_mnlg_socket_sndrcv(dl->nlg, nlh, cmd_dpipe_table_show_cb, ctx);
+	pr_out_section_end(dl);
+out:
+	dpipe_ctx_clear(ctx);
+	dpipe_ctx_free(ctx);
+	return err;
+}
+
+static int cmd_dpipe_table_set(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	int err;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_DPIPE_TABLE_COUNTERS_SET,
+			       NLM_F_REQUEST | NLM_F_ACK);
+
+	err = dl_argv_parse_put(nlh, dl,
+				DL_OPT_HANDLE | DL_OPT_DPIPE_TABLE_NAME |
+				DL_OPT_DPIPE_TABLE_COUNTERS, 0);
+	if (err)
+		return err;
+
+	return _mnlg_socket_sndrcv(dl->nlg, nlh, NULL, NULL);
+}
+
+static int dpipe_entry_value_show(struct dpipe_ctx *ctx,
+				  struct nlattr **nla_match_value)
+{
+	uint16_t value_len;
+	bool mask, mapping;
+
+	mask = !!nla_match_value[DEVLINK_ATTR_DPIPE_VALUE_MASK];
+	mapping = !!nla_match_value[DEVLINK_ATTR_DPIPE_VALUE_MAPPING];
+
+	value_len = mnl_attr_get_payload_len(nla_match_value[DEVLINK_ATTR_DPIPE_VALUE]);
+	if (value_len == sizeof(uint32_t)) {
+		uint32_t value, value_mask, value_mapping;
+
+		if (mapping) {
+			value_mapping = mnl_attr_get_u32(nla_match_value[DEVLINK_ATTR_DPIPE_VALUE_MAPPING]);
+			pr_out_uint(ctx->dl, "mapping_value", value_mapping);
+		}
+
+		if (mask) {
+			value_mask = mnl_attr_get_u32(nla_match_value[DEVLINK_ATTR_DPIPE_VALUE_MASK]);
+			pr_out_uint(ctx->dl, "mask_value", value_mask);
+		}
+
+		value = mnl_attr_get_u32(nla_match_value[DEVLINK_ATTR_DPIPE_VALUE]);
+		pr_out_uint(ctx->dl, "value", value);
+
+	} else {
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int dpipe_entry_match_value_show(struct dpipe_ctx *ctx,
+					struct nlattr *nl)
+{
+	struct nlattr *nla_match_value[DEVLINK_ATTR_MAX + 1] = {};
+	int err;
+
+	err = mnl_attr_parse_nested(nl, attr_cb, nla_match_value);
+	if (err != MNL_CB_OK)
+		return -EINVAL;
+
+	if (!nla_match_value[DEVLINK_ATTR_DPIPE_MATCH] ||
+	    !nla_match_value[DEVLINK_ATTR_DPIPE_VALUE]) {
+		return -EINVAL;
+	}
+
+	pr_out_entry_start(ctx->dl);
+	if (dpipe_match_show(ctx, nla_match_value[DEVLINK_ATTR_DPIPE_MATCH]))
+		goto err_match_show;
+	if (dpipe_entry_value_show(ctx, nla_match_value))
+		goto err_value_show;
+	pr_out_entry_end(ctx->dl);
+
+	return 0;
+
+err_match_show:
+err_value_show:
+	pr_out_entry_end(ctx->dl);
+	return -EINVAL;
+}
+
+static int dpipe_entry_action_value_show(struct dpipe_ctx *ctx,
+					 struct nlattr *nl)
+{
+	struct nlattr *nla_action_value[DEVLINK_ATTR_MAX + 1] = {};
+	int err;
+
+	err = mnl_attr_parse_nested(nl, attr_cb, nla_action_value);
+	if (err != MNL_CB_OK)
+		return -EINVAL;
+
+	if (!nla_action_value[DEVLINK_ATTR_DPIPE_ACTION] ||
+	    !nla_action_value[DEVLINK_ATTR_DPIPE_VALUE]) {
+		return -EINVAL;
+	}
+
+	pr_out_entry_start(ctx->dl);
+	if (dpipe_action_show(ctx, nla_action_value[DEVLINK_ATTR_DPIPE_ACTION]))
+		goto err_action_show;
+	if (dpipe_entry_value_show(ctx, nla_action_value))
+		goto err_value_show;
+	pr_out_entry_end(ctx->dl);
+
+	return 0;
+
+err_action_show:
+err_value_show:
+	pr_out_entry_end(ctx->dl);
+	return -EINVAL;
+}
+
+static int
+dpipe_tables_action_values_show(struct dpipe_ctx *ctx,
+				struct nlattr *nla_action_values)
+{
+	struct nlattr *nla_action_value;
+
+	mnl_attr_for_each_nested(nla_action_value, nla_action_values) {
+		if (dpipe_entry_action_value_show(ctx, nla_action_value))
+			return -EINVAL;
+	}
+	return 0;
+}
+
+static int
+dpipe_tables_match_values_show(struct dpipe_ctx *ctx,
+			       struct nlattr *nla_match_values)
+{
+	struct nlattr *nla_match_value;
+
+	mnl_attr_for_each_nested(nla_match_value, nla_match_values) {
+		if (dpipe_entry_match_value_show(ctx, nla_match_value))
+			return -EINVAL;
+	}
+	return 0;
+}
+
+static int dpipe_entry_show(struct dpipe_ctx *ctx, struct nlattr *nl)
+{
+	struct nlattr *nla_entry[DEVLINK_ATTR_MAX + 1] = {};
+	uint32_t entry_index;
+	uint64_t counter;
+	int err;
+
+	err = mnl_attr_parse_nested(nl, attr_cb, nla_entry);
+	if (err != MNL_CB_OK)
+		return -EINVAL;
+
+	if (!nla_entry[DEVLINK_ATTR_DPIPE_ENTRY_INDEX] ||
+	    !nla_entry[DEVLINK_ATTR_DPIPE_ENTRY_MATCH_VALUES] ||
+	    !nla_entry[DEVLINK_ATTR_DPIPE_ENTRY_ACTION_VALUES]) {
+		return -EINVAL;
+	}
+
+	entry_index = mnl_attr_get_u32(nla_entry[DEVLINK_ATTR_DPIPE_ENTRY_INDEX]);
+	pr_out_uint(ctx->dl, "index", entry_index);
+
+	if (nla_entry[DEVLINK_ATTR_DPIPE_ENTRY_COUNTER]) {
+		counter = mnl_attr_get_u64(nla_entry[DEVLINK_ATTR_DPIPE_ENTRY_COUNTER]);
+		pr_out_uint(ctx->dl, "counter", counter);
+	}
+
+	pr_out_array_start(ctx->dl, "match_value");
+	if (dpipe_tables_match_values_show(ctx,
+					   nla_entry[DEVLINK_ATTR_DPIPE_ENTRY_MATCH_VALUES]))
+		goto err_match_values_show;
+	pr_out_array_end(ctx->dl);
+
+	pr_out_array_start(ctx->dl, "action_value");
+	if (dpipe_tables_action_values_show(ctx,
+					    nla_entry[DEVLINK_ATTR_DPIPE_ENTRY_ACTION_VALUES]))
+		goto err_action_values_show;
+	pr_out_array_end(ctx->dl);
+	return 0;
+
+err_action_values_show:
+err_match_values_show:
+	pr_out_array_end(ctx->dl);
+	return -EINVAL;
+}
+
+static int dpipe_table_entries_show(struct dpipe_ctx *ctx, struct nlattr **tb)
+{
+	struct nlattr *nla_entries = tb[DEVLINK_ATTR_DPIPE_ENTRIES];
+	struct nlattr *nla_entry;
+
+	mnl_attr_for_each_nested(nla_entry, nla_entries) {
+		pr_out_handle_start_arr(ctx->dl, tb);
+		if (dpipe_entry_show(ctx, nla_entry))
+			goto err_entry_show;
+		pr_out_handle_end(ctx->dl);
+	}
+	return 0;
+
+err_entry_show:
+	pr_out_handle_end(ctx->dl);
+	return -EINVAL;
+}
+
+static int cmd_dpipe_table_entry_dump_cb(const struct nlmsghdr *nlh, void *data)
+{
+	struct dpipe_ctx *ctx = data;
+	struct nlattr *tb[DEVLINK_ATTR_MAX + 1] = {};
+	struct genlmsghdr *genl = mnl_nlmsg_get_payload(nlh);
+
+	mnl_attr_parse(nlh, sizeof(*genl), attr_cb, tb);
+	if (!tb[DEVLINK_ATTR_BUS_NAME] || !tb[DEVLINK_ATTR_DEV_NAME] ||
+	    !tb[DEVLINK_ATTR_DPIPE_ENTRIES])
+		return MNL_CB_ERROR;
+
+	if (dpipe_table_entries_show(ctx, tb))
+		return MNL_CB_ERROR;
+	return MNL_CB_OK;
+}
+
+static int cmd_dpipe_table_dump(struct dl *dl)
+{
+	struct nlmsghdr *nlh;
+	struct dpipe_ctx *ctx;
+	uint16_t flags = NLM_F_REQUEST;
+	int err;
+
+	ctx = dpipe_ctx_alloc(dl);
+	if (!ctx)
+		return -ENOMEM;
+
+	err = dl_argv_parse(dl, DL_OPT_HANDLE | DL_OPT_DPIPE_TABLE_NAME, 0);
+	if (err)
+		goto out;
+
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_DPIPE_HEADERS_GET, flags);
+	dl_opts_put(nlh, dl);
+	err = _mnlg_socket_sndrcv(dl->nlg, nlh, cmd_dpipe_header_cb, ctx);
+	if (err) {
+		pr_err("error get headers %s\n", strerror(ctx->err));
+		goto out;
+	}
+
+	flags = NLM_F_REQUEST | NLM_F_ACK;
+	nlh = mnlg_msg_prepare(dl->nlg, DEVLINK_CMD_DPIPE_ENTRIES_GET, flags);
+	dl_opts_put(nlh, dl);
+
+	pr_out_section_start(dl, "table_entry");
+	_mnlg_socket_sndrcv(dl->nlg, nlh, cmd_dpipe_table_entry_dump_cb, ctx);
+	pr_out_section_end(dl);
+out:
+	dpipe_ctx_clear(ctx);
+	dpipe_ctx_free(ctx);
+	return err;
+}
+
+static void cmd_dpipe_table_help(void)
+{
+	pr_err("Usage: devlink dpipe table [ OBJECT-LIST ]\n"
+	       "where  OBJECT-LIST := { show | set | dump }\n");
+}
+
+static int cmd_dpipe_table(struct dl *dl)
+{
+	if (dl_argv_match(dl, "help") || dl_no_arg(dl)) {
+		cmd_dpipe_table_help();
+		return 0;
+	} else if (dl_argv_match(dl, "show")) {
+		dl_arg_inc(dl);
+		return cmd_dpipe_table_show(dl);
+	} else if (dl_argv_match(dl, "set")) {
+		dl_arg_inc(dl);
+		return cmd_dpipe_table_set(dl);
+	}  else if (dl_argv_match(dl, "dump")) {
+		dl_arg_inc(dl);
+		return cmd_dpipe_table_dump(dl);
+	}
+	pr_err("Command \"%s\" not found\n", dl_argv(dl));
+	return -ENOENT;
+}
+
+static void cmd_dpipe_help(void)
+{
+	pr_err("Usage: devlink dpipe [ OBJECT-LIST ]\n"
+	       "where  OBJECT-LIST := { header | table }\n");
+}
+
+static int cmd_dpipe(struct dl *dl)
+{
+	if (dl_argv_match(dl, "help") || dl_no_arg(dl)) {
+		cmd_dpipe_help();
+		return 0;
+	} else if (dl_argv_match(dl, "header")) {
+		dl_arg_inc(dl);
+		return cmd_dpipe_header(dl);
+	} else if (dl_argv_match(dl, "table")) {
+		dl_arg_inc(dl);
+		return cmd_dpipe_table(dl);
+	}
+	pr_err("Command \"%s\" not found\n", dl_argv(dl));
+	return -ENOENT;
+}
+
+static void help(void)
+{
+	pr_err("Usage: devlink [ OPTIONS ] OBJECT { COMMAND | help }\n"
+	       "where  OBJECT := { dev | port | sb | monitor | dpipe }\n"
+	       "       OPTIONS := { -V[ersion] | -n[no-nice-names] | -j[json] | -p[pretty] | -v[verbose] }\n");
+}
+
+static int dl_cmd(struct dl *dl)
+{
+	if (dl_argv_match(dl, "help") || dl_no_arg(dl)) {
+		help();
+		return 0;
+	} else if (dl_argv_match(dl, "dev")) {
+		dl_arg_inc(dl);
+		return cmd_dev(dl);
+	} else if (dl_argv_match(dl, "port")) {
+		dl_arg_inc(dl);
+		return cmd_port(dl);
+	} else if (dl_argv_match(dl, "sb")) {
+		dl_arg_inc(dl);
+		return cmd_sb(dl);
+	} else if (dl_argv_match(dl, "monitor")) {
+		dl_arg_inc(dl);
+		return cmd_mon(dl);
+	} else if (dl_argv_match(dl, "dpipe")) {
+		dl_arg_inc(dl);
+		return cmd_dpipe(dl);
+	}
+	pr_err("Object \"%s\" not found\n", dl_argv(dl));
+	return -ENOENT;
+}
+
+static int dl_init(struct dl *dl, int argc, char **argv)
+{
+	int err;
+
+	dl->argc = argc;
+	dl->argv = argv;
+
+	dl->nlg = mnlg_socket_open(DEVLINK_GENL_NAME, DEVLINK_GENL_VERSION);
+	if (!dl->nlg) {
+		pr_err("Failed to connect to devlink Netlink\n");
+		return -errno;
+	}
+
+	err = ifname_map_init(dl);
+	if (err) {
+		pr_err("Failed to create index map\n");
+		goto err_ifname_map_create;
+	}
+	if (dl->json_output) {
+		dl->jw = jsonw_new(stdout);
+		if (!dl->jw) {
+			pr_err("Failed to create JSON writer\n");
+			goto err_json_new;
+		}
+		jsonw_pretty(dl->jw, dl->pretty_output);
+	}
+	return 0;
+
+err_json_new:
+	ifname_map_fini(dl);
+err_ifname_map_create:
+	mnlg_socket_close(dl->nlg);
+	return err;
+}
+
+static void dl_fini(struct dl *dl)
+{
+	if (dl->json_output)
+		jsonw_destroy(&dl->jw);
+	ifname_map_fini(dl);
+	mnlg_socket_close(dl->nlg);
+}
+
+static struct dl *dl_alloc(void)
+{
+	struct dl *dl;
+
+	dl = calloc(1, sizeof(*dl));
+	if (!dl)
+		return NULL;
+	return dl;
+}
+
+static void dl_free(struct dl *dl)
+{
+	free(dl);
+}
+
+int main(int argc, char **argv)
+{
+	static const struct option long_options[] = {
+		{ "Version",		no_argument,		NULL, 'V' },
+		{ "no-nice-names",	no_argument,		NULL, 'n' },
+		{ "json",		no_argument,		NULL, 'j' },
+		{ "pretty",		no_argument,		NULL, 'p' },
+		{ "verbose",		no_argument,		NULL, 'v' },
+		{ NULL, 0, NULL, 0 }
+	};
+	struct dl *dl;
+	int opt;
+	int err;
+	int ret;
+
+	dl = dl_alloc();
+	if (!dl) {
+		pr_err("Failed to allocate memory for devlink\n");
+		return EXIT_FAILURE;
+	}
+
+	while ((opt = getopt_long(argc, argv, "Vnjpv",
+				  long_options, NULL)) >= 0) {
+
+		switch (opt) {
+		case 'V':
+			printf("devlink utility, iproute2-ss%s\n", SNAPSHOT);
+			ret = EXIT_SUCCESS;
+			goto dl_free;
+		case 'n':
+			dl->no_nice_names = true;
+			break;
+		case 'j':
 			dl->json_output = true;
 			break;
 		case 'p':
 			dl->pretty_output = true;
 			break;
+		case 'v':
+			dl->verbose = true;
+			break;
 		default:
 			pr_err("Unknown option.\n");
 			help();
diff --git a/include/linux/devlink.h b/include/linux/devlink.h
index 2ad3585..0c8af61 100644
--- a/include/linux/devlink.h
+++ b/include/linux/devlink.h
@@ -65,8 +65,12 @@ enum devlink_command {
 #define DEVLINK_CMD_ESWITCH_MODE_SET /* obsolete, never use this! */ \
 	DEVLINK_CMD_ESWITCH_SET
 
-	/* add new commands above here */
+	DEVLINK_CMD_DPIPE_TABLE_GET,
+	DEVLINK_CMD_DPIPE_ENTRIES_GET,
+	DEVLINK_CMD_DPIPE_HEADERS_GET,
+	DEVLINK_CMD_DPIPE_TABLE_COUNTERS_SET,
 
+	/* add new commands above here */
 	__DEVLINK_CMD_MAX,
 	DEVLINK_CMD_MAX = __DEVLINK_CMD_MAX - 1
 };
@@ -148,10 +152,71 @@ enum devlink_attr {
 	DEVLINK_ATTR_ESWITCH_MODE,		/* u16 */
 	DEVLINK_ATTR_ESWITCH_INLINE_MODE,	/* u8 */
 
+	DEVLINK_ATTR_DPIPE_TABLES,		/* nested */
+	DEVLINK_ATTR_DPIPE_TABLE,		/* nested */
+	DEVLINK_ATTR_DPIPE_TABLE_NAME,		/* string */
+	DEVLINK_ATTR_DPIPE_TABLE_SIZE,		/* u64 */
+	DEVLINK_ATTR_DPIPE_TABLE_MATCHES,	/* nested */
+	DEVLINK_ATTR_DPIPE_TABLE_ACTIONS,	/* nested */
+	DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED,	/* u8 */
+
+	DEVLINK_ATTR_DPIPE_ENTRIES,		/* nested */
+	DEVLINK_ATTR_DPIPE_ENTRY,		/* nested */
+	DEVLINK_ATTR_DPIPE_ENTRY_INDEX,		/* u64 */
+	DEVLINK_ATTR_DPIPE_ENTRY_MATCH_VALUES,	/* nested */
+	DEVLINK_ATTR_DPIPE_ENTRY_ACTION_VALUES,	/* nested */
+	DEVLINK_ATTR_DPIPE_ENTRY_COUNTER,	/* u64 */
+
+	DEVLINK_ATTR_DPIPE_MATCH,		/* nested */
+	DEVLINK_ATTR_DPIPE_MATCH_VALUE,		/* nested */
+	DEVLINK_ATTR_DPIPE_MATCH_TYPE,		/* u32 */
+
+	DEVLINK_ATTR_DPIPE_ACTION,		/* nested */
+	DEVLINK_ATTR_DPIPE_ACTION_VALUE,	/* nested */
+	DEVLINK_ATTR_DPIPE_ACTION_TYPE,		/* u32 */
+
+	DEVLINK_ATTR_DPIPE_VALUE,
+	DEVLINK_ATTR_DPIPE_VALUE_MASK,
+	DEVLINK_ATTR_DPIPE_VALUE_MAPPING,	/* u32 */
+
+	DEVLINK_ATTR_DPIPE_HEADERS,		/* nested */
+	DEVLINK_ATTR_DPIPE_HEADER,		/* nested */
+	DEVLINK_ATTR_DPIPE_HEADER_NAME,		/* string */
+	DEVLINK_ATTR_DPIPE_HEADER_ID,		/* u32 */
+	DEVLINK_ATTR_DPIPE_HEADER_FIELDS,	/* nested */
+	DEVLINK_ATTR_DPIPE_HEADER_GLOBAL,	/* u8 */
+	DEVLINK_ATTR_DPIPE_HEADER_INDEX,	/* u32 */
+
+	DEVLINK_ATTR_DPIPE_FIELD,		/* nested */
+	DEVLINK_ATTR_DPIPE_FIELD_NAME,		/* string */
+	DEVLINK_ATTR_DPIPE_FIELD_ID,		/* u32 */
+	DEVLINK_ATTR_DPIPE_FIELD_BITWIDTH,	/* u32 */
+	DEVLINK_ATTR_DPIPE_FIELD_MAPPING_TYPE,	/* u32 */
+
+	DEVLINK_ATTR_PAD,
+
 	/* add new attributes above here, update the policy in devlink.c */
 
 	__DEVLINK_ATTR_MAX,
 	DEVLINK_ATTR_MAX = __DEVLINK_ATTR_MAX - 1
 };
 
+/* Mapping between internal resource described by the field and system
+ * structure
+ */
+enum devlink_dpipe_field_mapping_type {
+	DEVLINK_DPIPE_FIELD_MAPPING_TYPE_NONE,
+	DEVLINK_DPIPE_FIELD_MAPPING_TYPE_IFINDEX,
+};
+
+/* Match type - specify the type of the match */
+enum devlink_dpipe_match_type {
+	DEVLINK_DPIPE_MATCH_TYPE_FIELD_EXACT,
+};
+
+/* Action type - specify the action type */
+enum devlink_dpipe_action_type {
+	DEVLINK_DPIPE_ACTION_TYPE_FIELD_MODIFY,
+};
+
 #endif /* _LINUX_DEVLINK_H_ */
-- 
2.7.4
