From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 1/8] devlink: Support for pipeline debug (dpipe)
Date: Thu, 16 Feb 2017 16:22:37 +0100
Message-ID: <1487258564-3775-2-git-send-email-jiri@resnulli.us>
References: <1487258564-3775-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, jhs@mojatatu.com, ivecera@redhat.com,
        roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@gmail.com,
        andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33091 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932385AbdBPPWs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2017 10:22:48 -0500
Received: by mail-wm0-f65.google.com with SMTP id v77so3650405wmv.0
        for <netdev@vger.kernel.org>; Thu, 16 Feb 2017 07:22:47 -0800 (PST)
In-Reply-To: <1487258564-3775-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

The pipeline debug is used to export the pipeline abstractions
for the main objects - tables, headers and entries. The only support for
set is for changing the counter parameter on specific table.

The basic structures:

Header - can represent a real protocol header information or internal
         metadata. Generic protocol headers like IPv4 can be shared
         between drivers. Each driver can add local headers.

Field - part of a header. Can represent protocol field or specific
        ASIC metadata field. Hardware special metadata fields can
        be mapped to different resources, for example switch ASIC
       	ports can have internal number which from the systems
        point of view is mapped to netdeivce ifindex.

Hfield - Specific combination of header:field. This object is used
         to represent the table behavior in terms of match/action.

Hfield_val - Represents value of specific Hfield.

Table - represents a hardware block which can be described with
        match/action behavior. The match/action can be done on the
        packets data or on the internal metadata that it gathered
        along the packets traversal throw the pipeline which is vendor
        specific and should be exported in order to provide
        understanding of ASICs behavior.

Entry - represents single record in a specific table. The entry is
        identified by specific combination of Hfield_vals for match
        /action.

Prior to accessing the tables/entries the drivers provide the header/
field data base which is used by driver to user-space. The data base
is split between the shared headers and unique headers.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/devlink.h        | 224 ++++++++++++-
 include/uapi/linux/devlink.h |  50 ++-
 net/core/devlink.c           | 747 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 1019 insertions(+), 2 deletions(-)

diff --git a/include/net/devlink.h b/include/net/devlink.h
index d29e5fc..d480669 100644
--- a/include/net/devlink.h
+++ b/include/net/devlink.h
@@ -25,6 +25,8 @@ struct devlink {
 	struct list_head list;
 	struct list_head port_list;
 	struct list_head sb_list;
+	struct list_head dpipe_table_list;
+	struct devlink_dpipe_headers *dpipe_headers;
 	const struct devlink_ops *ops;
 	struct device *dev;
 	possible_net_t _net;
@@ -49,6 +51,157 @@ struct devlink_sb_pool_info {
 	enum devlink_sb_threshold_type threshold_type;
 };
 
+/**
+ * struct devlink_dpipe_field - dpipe field object
+ * @name: field name
+ * @id: id inside header fields array
+ * @bitwidth: bitwidth
+ * @mapping_type: mapping type
+ */
+struct devlink_dpipe_field {
+	const char *name;
+	unsigned int id;
+	unsigned int bitwidth;
+	enum devlink_dpipe_field_mapping_type mapping_type;
+};
+
+/**
+ * struct devlink_dpipe_header - dpipe header object
+ * @name: header name
+ * @id: id, global/local detrmined by global bit
+ * @fields: fields
+ * @fields_count: number of fields
+ * @global: indicates of header is shared like most protocol header
+ *	    or driver specific
+ */
+struct devlink_dpipe_header {
+	const char *name;
+	unsigned int id;
+	struct devlink_dpipe_field *fields;
+	unsigned int fields_count;
+	bool global;
+};
+
+/**
+ * struct devlink_dpipe_hfield - represents header:field tuple
+ * @header: header
+ * @filed_id: field index
+ */
+struct devlink_dpipe_hfield {
+	struct devlink_dpipe_header *header;
+	unsigned int field_id;
+};
+
+/**
+ * struct devlink_dpipe_hfield_val - represents a value of specific
+ *				     tuple
+ * @hfield: the tuple the value is relevant for
+ * @mapping_value: in case the field has some mapping this value
+ *                 specified the mapping value
+ * @value_size: value size
+ * @value: the value
+ * @mask: bit mask
+ */
+struct devlink_dpipe_hfield_val {
+	struct devlink_dpipe_hfield *hfield;
+	unsigned int mapping_value;
+	unsigned int value_size;
+	void *value;
+	void *mask;
+};
+
+/**
+ * struct devlink_dpipe_entry - table entry object
+ * @index: index of the entry in the table
+ * @matches: tuple match values
+ * @matches_count: count of matches tuples
+ * @actions: tuple actions values
+ * @actions_count: count of actions values
+ * @counter: value of counter
+ * @counter_valid: Specify if value is valid from hardware
+ */
+struct devlink_dpipe_entry {
+	unsigned int index;
+	struct devlink_dpipe_hfield_val *matches;
+	unsigned int matches_count;
+	struct devlink_dpipe_hfield_val *actions;
+	unsigned int actions_count;
+	u64 counter;
+	bool counter_valid;
+};
+
+/**
+ * struct devlink_dpipe_dump_ctx - context provided to driver in order
+ *				   to dump
+ * @info: info
+ * @cmd: devlink command
+ * @skb: skb
+ * @nest: top attribute
+ * @hdr: hdr
+ */
+struct devlink_dpipe_dump_ctx {
+	struct genl_info *info;
+	enum devlink_command cmd;
+	struct sk_buff *skb;
+	struct nlattr *nest;
+	void *hdr;
+};
+
+struct devlink_dpipe_table_ops;
+
+/**
+ * struct devlink_dpipe_table - table object
+ * @priv: private
+ * @name: table name
+ * @size: maximum number of entries
+ * @matches: header:field match tuples
+ * @matches_count: count of match tuples
+ * @actions: header:field action tuples
+ * @actions_count: count of action tuples
+ * @counters_enabled: indicates if counters are active
+ * @counter_control_extern: indicates if counter control is in dpipe or
+ *			    external tool
+ * @table_ops: table operations
+ * @rcu: rcu
+ */
+struct devlink_dpipe_table {
+	void *priv;
+	struct list_head list;
+	const char *name;
+	int size;
+	struct devlink_dpipe_hfield *matches;
+	unsigned int matches_count;
+	struct devlink_dpipe_hfield *actions;
+	unsigned int actions_count;
+	bool counters_enabled;
+	bool counter_control_extern;
+	struct devlink_dpipe_table_ops *table_ops;
+	struct rcu_head rcu;
+};
+
+/**
+ * struct devlink_dpipe_table_ops - dpipe_table ops
+ * @entries_dump - dumps all active entries in the table
+ * @counter_set_update - when changing the counter status hardware sync
+ *			 maybe needed to allocate/free counter related
+ *			 resources
+ */
+struct devlink_dpipe_table_ops {
+	int (*entries_dump)(void *priv, bool counters_enabled,
+			    struct devlink_dpipe_dump_ctx *dump_ctx);
+	int (*counter_set_update)(void *priv, bool enable);
+};
+
+/**
+ * struct devlink_dpipe_headers - dpipe headers
+ * @headers - header array can be shared(global bit) or local
+ * @headers_count - count of headers
+ */
+struct devlink_dpipe_headers {
+	struct devlink_dpipe_header **headers;
+	unsigned int headers_count;
+};
+
 struct devlink_ops {
 	int (*port_type_set)(struct devlink_port *devlink_port,
 			     enum devlink_port_type port_type);
@@ -132,7 +285,26 @@ int devlink_sb_register(struct devlink *devlink, unsigned int sb_index,
 			u16 egress_pools_count, u16 ingress_tc_count,
 			u16 egress_tc_count);
 void devlink_sb_unregister(struct devlink *devlink, unsigned int sb_index);
-
+int devlink_dpipe_table_register(struct devlink *devlink,
+				 const char *table_name,
+				 struct devlink_dpipe_table_ops *table_ops,
+				 void *priv,
+				 struct devlink_dpipe_hfield *matches,
+				 unsigned int matches_count,
+				 struct devlink_dpipe_hfield *actions,
+				 unsigned int actions_count,
+				 bool counter_control_extern);
+void devlink_dpipe_table_unregister(struct devlink *devlink,
+				    const char *table_name);
+int devlink_dpipe_headers_register(struct devlink *devlink,
+				   struct devlink_dpipe_headers *dpipe_headers);
+void devlink_dpipe_headers_unregister(struct devlink *devlink);
+bool devlink_dpipe_table_counter_enabled(struct devlink *devlink,
+					 const char *table_name);
+int devlink_dpipe_entry_prepare_ctx(struct devlink_dpipe_dump_ctx *dump_ctx);
+int devlink_dpipe_entry_append_ctx(struct devlink_dpipe_dump_ctx *dump_ctx,
+				   struct devlink_dpipe_entry *entry);
+int devlink_dpipe_entry_close_ctx(struct devlink_dpipe_dump_ctx *dump_ctx);
 #else
 
 static inline struct devlink *devlink_alloc(const struct devlink_ops *ops,
@@ -200,6 +372,56 @@ static inline void devlink_sb_unregister(struct devlink *devlink,
 {
 }
 
+int devlink_dpipe_table_register(struct devlink *devlink,
+				 const char *table_name,
+				 struct devlink_dpipe_table_ops *table_ops,
+				 void *priv,
+				 struct devlink_dpipe_hfield *matches,
+				 unsigned int matches_count,
+				 struct devlink_dpipe_hfield *actions,
+				 unsigned int actions_count,
+				 bool counter_control_extern)
+{
+	return 0;
+}
+
+void devlink_dpipe_table_unregister(struct devlink *devlink,
+				    const char *table_name);
+{
+}
+
+int devlink_dpipe_headers_register(struct devlink *devlink,
+				   struct devlink_dpipe_headers *dpipe_headers);
+{
+	return 0;
+}
+
+void devlink_dpipe_headers_unregister(struct devlink *devlink)
+{
+}
+
+bool devlink_dpipe_table_counter_enabled(struct devlink *devlink,
+					 const char *table_name)
+{
+	return false;
+}
+
+int devlink_dpipe_entry_prepare_ctx(struct devlink_dpipe_dump_ctx *dump_ctx)
+{
+	return 0;
+}
+
+int devlink_dpipe_entry_append_ctx(struct devlink_dpipe_dump_ctx *dump_ctx,
+				   struct devlink_dpipe_entry *entry)
+{
+	return 0;
+}
+
+int devlink_dpipe_entry_close_ctx(struct devlink_dpipe_dump_ctx *dump_ctx)
+{
+	return 0;
+}
+
 #endif
 
 #endif /* _NET_DEVLINK_H_ */
diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 0f1f3a1..bbab55d 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
@@ -65,8 +65,12 @@ enum devlink_command {
 #define DEVLINK_CMD_ESWITCH_MODE_SET /* obsolete, never use this! */ \
 	DEVLINK_CMD_ESWITCH_SET
 
-	/* add new commands above here */
+	DEVLINK_CMD_DPIPE_TABLES_GET,
+	DEVLINK_CMD_DPIPE_ENTRIES_GET,
+	DEVLINK_CMD_DPIPE_HEADERS_GET,
+	DEVLINK_CMD_DPIPE_TABLE_COUNTER_SET,
 
+	/* add new commands above here */
 	__DEVLINK_CMD_MAX,
 	DEVLINK_CMD_MAX = __DEVLINK_CMD_MAX - 1
 };
@@ -148,10 +152,54 @@ enum devlink_attr {
 	DEVLINK_ATTR_ESWITCH_MODE,		/* u16 */
 	DEVLINK_ATTR_ESWITCH_INLINE_MODE,	/* u8 */
 
+	DEVLINK_ATTR_DPIPE_TABLES,		/* nested */
+	DEVLINK_ATTR_DPIPE_TABLE,		/* nested */
+	DEVLINK_ATTR_DPIPE_TABLE_NAME,		/* string */
+	DEVLINK_ATTR_DPIPE_TABLE_SIZE,		/* u32 */
+	DEVLINK_ATTR_DPIPE_TABLE_MATCHES,	/* nested */
+	DEVLINK_ATTR_DPIPE_TABLE_ACTIONS,	/* nested */
+	DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED,	/* flag */
+
+	DEVLINK_ATTR_DPIPE_HFIELD,		/* nested */
+	DEVLINK_ATTR_DPIPE_HFIELD_VALUE,
+	DEVLINK_ATTR_DPIPE_HFIELD_MASK,
+	DEVLINK_ATTR_DPIPE_HFIELD_MAPPING,	/* u32 */
+
+	DEVLINK_ATTR_DPIPE_ENTRIES,		/* nested */
+	DEVLINK_ATTR_DPIPE_ENTRY,		/* nested */
+	DEVLINK_ATTR_DPIPE_ENTRY_INDEX,		/* u32 */
+	DEVLINK_ATTR_DPIPE_ENTRY_MATCHES,	/* nested */
+	DEVLINK_ATTR_DPIPE_ENTRY_ACTIONS,	/* nested */
+	DEVLINK_ATTR_DPIPE_ENTRY_COUNTER,	/* u64 */
+	DEVLINK_ATTR_DPIPE_ENTRY_COUNTER_VALID,	/* u32 */
+
+	DEVLINK_ATTR_DPIPE_HEADERS,		/* nested */
+	DEVLINK_ATTR_DPIPE_HEADER,		/* nested */
+	DEVLINK_ATTR_DPIPE_HEADER_NAME,		/* string */
+	DEVLINK_ATTR_DPIPE_HEADER_ID,		/* u32 */
+	DEVLINK_ATTR_DPIPE_HEADER_FIELDS,	/* string */
+	DEVLINK_ATTR_DPIPE_HEADER_GLOBAL,	/* flag */
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
 #endif /* _UAPI_LINUX_DEVLINK_H_ */
diff --git a/net/core/devlink.c b/net/core/devlink.c
index e9c1e6a..286d7d2 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -1493,8 +1493,588 @@ static int devlink_nl_cmd_eswitch_set_doit(struct sk_buff *skb,
 		if (err)
 			return err;
 	}
+	return 0;
+}
+
+static int devlink_dpipe_hfield_put(struct sk_buff *skb,
+				    struct devlink_dpipe_hfield *hfield)
+{
+	struct devlink_dpipe_header *header = hfield->header;
+	struct devlink_dpipe_field *field = &header->fields[hfield->field_id];
+
+	if (nla_put_u32(skb, DEVLINK_ATTR_DPIPE_HEADER_ID, header->id) ||
+	    nla_put_u32(skb, DEVLINK_ATTR_DPIPE_FIELD_ID, field->id))
+		return -EMSGSIZE;
+
+	if (header->global)
+		if (nla_put_flag(skb, DEVLINK_ATTR_DPIPE_HEADER_GLOBAL))
+			return -EMSGSIZE;
+	return 0;
+}
+
+static int devlink_dpipe_hfield_val_put(struct sk_buff *skb,
+					struct devlink_dpipe_hfield_val *val)
+{
+	struct devlink_dpipe_header *header;
+	struct devlink_dpipe_field *field;
+
+	if (!val->hfield)
+		return -EINVAL;
+	if (devlink_dpipe_hfield_put(skb, val->hfield))
+		return -EMSGSIZE;
+	if (nla_put(skb, DEVLINK_ATTR_DPIPE_HFIELD_VALUE,
+		    val->value_size, val->value))
+		return -EMSGSIZE;
+	if (val->mask)
+		if (nla_put(skb, DEVLINK_ATTR_DPIPE_HFIELD_MASK,
+			    val->value_size, val->mask))
+			return -EMSGSIZE;
+
+	header = val->hfield->header;
+	field = &header->fields[val->hfield->field_id];
+	if (field->mapping_type)
+		if (nla_put_u32(skb, DEVLINK_ATTR_DPIPE_HFIELD_MAPPING,
+				val->mapping_value))
+			return -EMSGSIZE;
+	return 0;
+}
+
+static int devlink_dpipe_hfield_vals_put(struct sk_buff *skb,
+					 struct devlink_dpipe_hfield_val *vals,
+					 unsigned int vals_count)
+{
+	struct nlattr *hfield_attr;
+	int i;
+	int err;
+
+	for (i = 0; i < vals_count; i++) {
+		hfield_attr = nla_nest_start(skb, DEVLINK_ATTR_DPIPE_HFIELD);
+		if (!hfield_attr)
+			return -EMSGSIZE;
+		err = devlink_dpipe_hfield_val_put(skb, &vals[i]);
+		if (err)
+			goto err_hfield_val_put;
+		nla_nest_end(skb, hfield_attr);
+	}
+	return 0;
+
+err_hfield_val_put:
+	nla_nest_cancel(skb, hfield_attr);
+	return err;
+}
+
+static int devlink_dpipe_hfields_put(struct sk_buff *skb,
+				     struct devlink_dpipe_hfield *hfields,
+				     unsigned int hfields_count)
+{
+	struct nlattr *hfield_attr;
+	int i;
+
+	for (i = 0; i < hfields_count; i++) {
+		hfield_attr = nla_nest_start(skb, DEVLINK_ATTR_DPIPE_HFIELD);
+		if (!hfield_attr)
+			return -EMSGSIZE;
+		if (devlink_dpipe_hfield_put(skb, &hfields[i]))
+			goto nla_put_failure;
+		nla_nest_end(skb, hfield_attr);
+	}
+	return 0;
+
+nla_put_failure:
+	nla_nest_cancel(skb, hfield_attr);
+	return -EMSGSIZE;
+}
+
+static int devlink_dpipe_table_put(struct sk_buff *skb,
+				   struct devlink_dpipe_table *table)
+{
+	struct nlattr *matches_attr, *actions_attr, *table_attr;
+
+	table_attr = nla_nest_start(skb, DEVLINK_ATTR_DPIPE_TABLE);
+	if (!table_attr)
+		return -EMSGSIZE;
+
+	if (nla_put_string(skb, DEVLINK_ATTR_DPIPE_TABLE_NAME, table->name) ||
+	    nla_put_u32(skb, DEVLINK_ATTR_DPIPE_TABLE_SIZE, table->size))
+		goto nla_put_failure;
+	if (table->counters_enabled)
+		if (nla_put_flag(skb,
+				 DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED))
+			goto nla_put_failure;
+
+	matches_attr = nla_nest_start(skb, DEVLINK_ATTR_DPIPE_TABLE_MATCHES);
+	if (!matches_attr)
+		goto nla_put_failure;
+
+	if (devlink_dpipe_hfields_put(skb, table->matches,
+				      table->matches_count)) {
+		nla_nest_cancel(skb, matches_attr);
+		goto nla_put_failure;
+	}
+
+	actions_attr = nla_nest_start(skb, DEVLINK_ATTR_DPIPE_TABLE_ACTIONS);
+	if (!actions_attr)
+		goto nla_put_failure;
+
+	if (devlink_dpipe_hfields_put(skb, table->actions,
+				      table->actions_count)) {
+		nla_nest_cancel(skb, actions_attr);
+		goto nla_put_failure;
+	}
+
+	nla_nest_end(skb, actions_attr);
+	nla_nest_end(skb, table_attr);
+	return 0;
+
+nla_put_failure:
+	nla_nest_cancel(skb, table_attr);
+	return -EMSGSIZE;
+}
+
+static int devlink_dpipe_send_and_alloc_skb(struct sk_buff **pskb,
+					    struct genl_info *info)
+{
+	int err;
+
+	if (*pskb) {
+		err = genlmsg_reply(*pskb, info);
+		if (err)
+			return err;
+	}
+	*pskb = genlmsg_new(GENLMSG_DEFAULT_SIZE, GFP_KERNEL);
+	if (!*pskb)
+		return -ENOMEM;
+	return 0;
+}
+
+static int devlink_dpipe_tables_fill(struct genl_info *info,
+				     enum devlink_command cmd, int flags,
+				     struct list_head *dpipe_tables)
+
+{
+	struct devlink *devlink = info->user_ptr[0];
+	struct devlink_dpipe_table *table;
+	struct nlattr *tables_attr;
+	struct sk_buff *skb = NULL;
+	struct nlmsghdr *nlh;
+	bool incomplete;
+	void *hdr;
+	int i;
+	int err;
+
+	table = list_first_entry(dpipe_tables,
+				 struct devlink_dpipe_table, list);
+start_again:
+	err = devlink_dpipe_send_and_alloc_skb(&skb, info);
+	if (err)
+		return err;
+
+	hdr = genlmsg_put(skb, info->snd_portid, info->snd_seq,
+			  &devlink_nl_family, NLM_F_MULTI, cmd);
+	if (!hdr)
+		return -EMSGSIZE;
 
+	if (devlink_nl_put_handle(skb, devlink))
+		goto nla_put_failure;
+	tables_attr = nla_nest_start(skb, DEVLINK_ATTR_DPIPE_TABLES);
+	if (!tables_attr)
+		goto nla_put_failure;
+
+	i = 0;
+	incomplete = false;
+	list_for_each_entry_from(table, dpipe_tables, list) {
+		err = devlink_dpipe_table_put(skb, table);
+		if (err) {
+			if (!i)
+				goto err_table_put;
+			incomplete = true;
+			break;
+		}
+		i++;
+	}
+
+	nla_nest_end(skb, tables_attr);
+	genlmsg_end(skb, hdr);
+	if (incomplete)
+		goto start_again;
+
+send_done:
+	nlh = nlmsg_put(skb, info->snd_portid, info->snd_seq,
+			NLMSG_DONE, 0, flags | NLM_F_MULTI);
+	if (!nlh) {
+		err = devlink_dpipe_send_and_alloc_skb(&skb, info);
+		if (err)
+			goto err_skb_send_alloc;
+		goto send_done;
+	}
+
+	return genlmsg_reply(skb, info);
+
+nla_put_failure:
+	err = -EMSGSIZE;
+err_table_put:
+err_skb_send_alloc:
+	genlmsg_cancel(skb, hdr);
+	nlmsg_free(skb);
+	return err;
+}
+
+static int devlink_nl_cmd_dpipe_tables_get(struct sk_buff *skb,
+					   struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+
+	return devlink_dpipe_tables_fill(info, DEVLINK_CMD_DPIPE_TABLES_GET, 0,
+					 &devlink->dpipe_table_list);
+}
+
+static int devlink_dpipe_entry_put(struct sk_buff *skb,
+				   struct devlink_dpipe_entry *entry)
+{
+	struct nlattr *entry_attr, *matches_attr, *actions_attr;
+	int err;
+
+	entry_attr = nla_nest_start(skb, DEVLINK_ATTR_DPIPE_ENTRY);
+	if (!entry_attr)
+		return  -EMSGSIZE;
+
+	if (nla_put_u32(skb, DEVLINK_ATTR_DPIPE_ENTRY_INDEX, entry->index))
+		goto nla_put_failure;
+	if (entry->counter_valid)
+		if (nla_put_u64_64bit(skb, DEVLINK_ATTR_DPIPE_ENTRY_COUNTER,
+				      entry->counter, DEVLINK_ATTR_PAD))
+			goto nla_put_failure;
+
+	matches_attr = nla_nest_start(skb, DEVLINK_ATTR_DPIPE_ENTRY_MATCHES);
+	if (!matches_attr)
+		goto nla_put_failure;
+
+	err = devlink_dpipe_hfield_vals_put(skb, entry->matches,
+					    entry->matches_count);
+	if (err) {
+		nla_nest_cancel(skb, matches_attr);
+		goto err_hfield_vals_put;
+	}
+	nla_nest_end(skb, matches_attr);
+
+	actions_attr = nla_nest_start(skb, DEVLINK_ATTR_DPIPE_ENTRY_ACTIONS);
+	if (!actions_attr)
+		goto nla_put_failure;
+
+	err = devlink_dpipe_hfield_vals_put(skb, entry->actions,
+					    entry->actions_count);
+	if (err) {
+		nla_nest_cancel(skb, actions_attr);
+		goto err_hfield_vals_put;
+	}
+	nla_nest_end(skb, actions_attr);
+
+	nla_nest_end(skb, entry_attr);
 	return 0;
+
+nla_put_failure:
+	err = -EMSGSIZE;
+err_hfield_vals_put:
+	nla_nest_cancel(skb, entry_attr);
+	return err;
+}
+
+static struct devlink_dpipe_table *
+devlink_dpipe_table_find(struct list_head *dpipe_tables,
+			 const char *table_name)
+{
+	struct devlink_dpipe_table *table;
+
+	list_for_each_entry_rcu(table, dpipe_tables, list) {
+		if (!strcmp(table->name, table_name))
+			return table;
+	}
+	return NULL;
+}
+
+int devlink_dpipe_entry_prepare_ctx(struct devlink_dpipe_dump_ctx *dump_ctx)
+{
+	struct devlink *devlink;
+	int err;
+
+	err = devlink_dpipe_send_and_alloc_skb(&dump_ctx->skb,
+					       dump_ctx->info);
+	if (err)
+		return err;
+
+	dump_ctx->hdr = genlmsg_put(dump_ctx->skb,
+				    dump_ctx->info->snd_portid,
+				    dump_ctx->info->snd_seq,
+				    &devlink_nl_family, NLM_F_MULTI,
+				    dump_ctx->cmd);
+	if (!dump_ctx->hdr)
+		goto nla_put_failure;
+
+	devlink = dump_ctx->info->user_ptr[0];
+	if (devlink_nl_put_handle(dump_ctx->skb, devlink))
+		goto nla_put_failure;
+	dump_ctx->nest = nla_nest_start(dump_ctx->skb,
+					DEVLINK_ATTR_DPIPE_ENTRIES);
+	if (!dump_ctx->nest)
+		goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	genlmsg_cancel(dump_ctx->skb, dump_ctx->hdr);
+	nlmsg_free(dump_ctx->skb);
+	return -EMSGSIZE;
+}
+
+int devlink_dpipe_entry_append_ctx(struct devlink_dpipe_dump_ctx *dump_ctx,
+				   struct devlink_dpipe_entry *entry)
+{
+	return devlink_dpipe_entry_put(dump_ctx->skb, entry);
+}
+
+int devlink_dpipe_entry_close_ctx(struct devlink_dpipe_dump_ctx *dump_ctx)
+{
+	nla_nest_end(dump_ctx->skb, dump_ctx->nest);
+	genlmsg_end(dump_ctx->skb, dump_ctx->hdr);
+	return 0;
+}
+
+static int devlink_dpipe_entries_fill(struct genl_info *info,
+				      enum devlink_command cmd, int flags,
+				      struct devlink_dpipe_table *table)
+{
+	struct devlink_dpipe_dump_ctx dump_ctx;
+	struct nlmsghdr *nlh;
+	int err;
+
+	dump_ctx.skb = NULL;
+	dump_ctx.cmd = cmd;
+	dump_ctx.info = info;
+
+	err = table->table_ops->entries_dump(table->priv,
+					     table->counters_enabled,
+					     &dump_ctx);
+	if (err)
+		goto err_entries_dump;
+
+send_done:
+	nlh = nlmsg_put(dump_ctx.skb, info->snd_portid, info->snd_seq,
+			NLMSG_DONE, 0, flags | NLM_F_MULTI);
+	if (!nlh) {
+		err = devlink_dpipe_send_and_alloc_skb(&dump_ctx.skb, info);
+		if (err)
+			goto err_skb_send_alloc;
+		goto send_done;
+	}
+	return genlmsg_reply(dump_ctx.skb, info);
+
+err_entries_dump:
+err_skb_send_alloc:
+	genlmsg_cancel(dump_ctx.skb, dump_ctx.hdr);
+	nlmsg_free(dump_ctx.skb);
+	return err;
+}
+
+static int devlink_nl_cmd_dpipe_entries_get(struct sk_buff *skb,
+					    struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	struct devlink_dpipe_table *table;
+	const char *table_name;
+
+	if (!info->attrs[DEVLINK_ATTR_DPIPE_TABLE_NAME])
+		return -EINVAL;
+
+	table_name = nla_data(info->attrs[DEVLINK_ATTR_DPIPE_TABLE_NAME]);
+	table = devlink_dpipe_table_find(&devlink->dpipe_table_list,
+					 table_name);
+	if (!table)
+		return -EINVAL;
+
+	if (!table->table_ops->entries_dump)
+		return -EINVAL;
+
+	return devlink_dpipe_entries_fill(info, DEVLINK_CMD_DPIPE_ENTRIES_GET,
+					  0, table);
+}
+
+static int devlink_dpipe_fields_put(struct sk_buff *skb,
+				    const struct devlink_dpipe_header *header)
+{
+	struct devlink_dpipe_field *field;
+	struct nlattr *field_attr;
+	int i;
+
+	for (i = 0; i < header->fields_count; i++) {
+		field = &header->fields[i];
+		field_attr = nla_nest_start(skb, DEVLINK_ATTR_DPIPE_FIELD);
+		if (!field_attr)
+			return -EMSGSIZE;
+		if (nla_put_string(skb, DEVLINK_ATTR_DPIPE_FIELD_NAME, field->name) ||
+		    nla_put_u32(skb, DEVLINK_ATTR_DPIPE_FIELD_ID, field->id) ||
+		    nla_put_u32(skb, DEVLINK_ATTR_DPIPE_FIELD_BITWIDTH, field->bitwidth))
+			goto nla_put_failure;
+		if (field->mapping_type)
+			if (nla_put_u32(skb,
+					DEVLINK_ATTR_DPIPE_FIELD_MAPPING_TYPE,
+					field->mapping_type))
+				goto nla_put_failure;
+		nla_nest_end(skb, field_attr);
+	}
+	return 0;
+
+nla_put_failure:
+	nla_nest_cancel(skb, field_attr);
+	return -EMSGSIZE;
+}
+
+static int devlink_dpipe_header_put(struct sk_buff *skb,
+				    struct devlink_dpipe_header *header)
+{
+	struct nlattr *fields_attr, *header_attr;
+	int err;
+
+	header_attr = nla_nest_start(skb, DEVLINK_ATTR_DPIPE_HEADER);
+	if (!header)
+		return -EMSGSIZE;
+
+	if (nla_put_string(skb, DEVLINK_ATTR_DPIPE_HEADER_NAME, header->name) ||
+	    nla_put_u32(skb, DEVLINK_ATTR_DPIPE_HEADER_ID, header->id))
+		goto nla_put_failure;
+
+	fields_attr = nla_nest_start(skb, DEVLINK_ATTR_DPIPE_HEADER_FIELDS);
+	if (!fields_attr)
+		goto nla_put_failure;
+
+	err = devlink_dpipe_fields_put(skb, header);
+	if (err) {
+		nla_nest_cancel(skb, fields_attr);
+		goto nla_put_failure;
+	}
+	nla_nest_end(skb, fields_attr);
+	nla_nest_end(skb, header_attr);
+	return 0;
+
+nla_put_failure:
+	err = -EMSGSIZE;
+	nla_nest_cancel(skb, header_attr);
+	return err;
+}
+
+static int devlink_dpipe_headers_fill(struct genl_info *info,
+				      enum devlink_command cmd, int flags,
+				      struct devlink_dpipe_headers *
+				      dpipe_headers)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	struct nlattr *headers_attr;
+	struct sk_buff *skb = NULL;
+	struct nlmsghdr *nlh;
+	void *hdr;
+	int i, j;
+	int err;
+
+	i = 0;
+start_again:
+	err = devlink_dpipe_send_and_alloc_skb(&skb, info);
+	if (err)
+		return err;
+
+	hdr = genlmsg_put(skb, info->snd_portid, info->snd_seq,
+			  &devlink_nl_family, NLM_F_MULTI, cmd);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	if (devlink_nl_put_handle(skb, devlink))
+		goto nla_put_failure;
+	headers_attr = nla_nest_start(skb, DEVLINK_ATTR_DPIPE_HEADERS);
+	if (!headers_attr)
+		goto nla_put_failure;
+
+	j = 0;
+	for (; i < dpipe_headers->headers_count; i++) {
+		err = devlink_dpipe_header_put(skb, dpipe_headers->headers[i]);
+		if (err) {
+			if (!j)
+				goto err_table_put;
+			break;
+		}
+		j++;
+	}
+	nla_nest_end(skb, headers_attr);
+	genlmsg_end(skb, hdr);
+	if (i != dpipe_headers->headers_count)
+		goto start_again;
+
+send_done:
+	nlh = nlmsg_put(skb, info->snd_portid, info->snd_seq,
+			NLMSG_DONE, 0, flags | NLM_F_MULTI);
+	if (!nlh) {
+		err = devlink_dpipe_send_and_alloc_skb(&skb, info);
+		if (err)
+			goto err_skb_send_alloc;
+		goto send_done;
+	}
+	return genlmsg_reply(skb, info);
+
+nla_put_failure:
+	err = -EMSGSIZE;
+err_table_put:
+err_skb_send_alloc:
+	genlmsg_cancel(skb, hdr);
+	nlmsg_free(skb);
+	return err;
+}
+
+static int devlink_nl_cmd_dpipe_headers_get(struct sk_buff *skb,
+					    struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+
+	return devlink_dpipe_headers_fill(info, DEVLINK_CMD_DPIPE_HEADERS_GET,
+					  0, devlink->dpipe_headers);
+}
+
+static int devlink_dpipe_table_counter_set(struct devlink *devlink,
+					   const char *table_name,
+					   bool enable)
+{
+	struct devlink_dpipe_table *table;
+
+	table = devlink_dpipe_table_find(&devlink->dpipe_table_list,
+					 table_name);
+	if (!table)
+		return -EINVAL;
+
+	if (table->counter_control_extern)
+		return -EOPNOTSUPP;
+
+	if (!(table->counters_enabled ^ enable))
+		return 0;
+
+	table->counters_enabled = enable;
+	if (table->table_ops->counter_set_update)
+		table->table_ops->counter_set_update(table->priv, enable);
+	return 0;
+}
+
+static int devlink_nl_cmd_dpipe_table_counter_set(struct sk_buff *skb,
+						  struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	const char *table_name;
+	int counter_enable;
+
+	if (!info->attrs[DEVLINK_ATTR_DPIPE_TABLE_NAME])
+		return -EINVAL;
+	table_name = nla_data(info->attrs[DEVLINK_ATTR_DPIPE_TABLE_NAME]);
+
+	if (!info->attrs[DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED])
+		counter_enable = false;
+	else
+		counter_enable = true;
+
+	return devlink_dpipe_table_counter_set(devlink, table_name,
+					       counter_enable);
 }
 
 static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
@@ -1512,6 +2092,8 @@ static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
 	[DEVLINK_ATTR_SB_TC_INDEX] = { .type = NLA_U16 },
 	[DEVLINK_ATTR_ESWITCH_MODE] = { .type = NLA_U16 },
 	[DEVLINK_ATTR_ESWITCH_INLINE_MODE] = { .type = NLA_U8 },
+	[DEVLINK_ATTR_DPIPE_TABLE_NAME] = { .type = NLA_NUL_STRING },
+	[DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED] = { .type =  NLA_U32 },
 };
 
 static const struct genl_ops devlink_nl_ops[] = {
@@ -1644,6 +2226,34 @@ static const struct genl_ops devlink_nl_ops[] = {
 		.flags = GENL_ADMIN_PERM,
 		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
 	},
+	{
+		.cmd = DEVLINK_CMD_DPIPE_TABLES_GET,
+		.doit = devlink_nl_cmd_dpipe_tables_get,
+		.policy = devlink_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
+	},
+	{
+		.cmd = DEVLINK_CMD_DPIPE_ENTRIES_GET,
+		.doit = devlink_nl_cmd_dpipe_entries_get,
+		.policy = devlink_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
+	},
+	{
+		.cmd = DEVLINK_CMD_DPIPE_HEADERS_GET,
+		.doit = devlink_nl_cmd_dpipe_headers_get,
+		.policy = devlink_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
+	},
+	{
+		.cmd = DEVLINK_CMD_DPIPE_TABLE_COUNTER_SET,
+		.doit = devlink_nl_cmd_dpipe_table_counter_set,
+		.policy = devlink_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
+	},
 };
 
 static struct genl_family devlink_nl_family __ro_after_init = {
@@ -1680,6 +2290,7 @@ struct devlink *devlink_alloc(const struct devlink_ops *ops, size_t priv_size)
 	devlink_net_set(devlink, &init_net);
 	INIT_LIST_HEAD(&devlink->port_list);
 	INIT_LIST_HEAD(&devlink->sb_list);
+	INIT_LIST_HEAD_RCU(&devlink->dpipe_table_list);
 	return devlink;
 }
 EXPORT_SYMBOL_GPL(devlink_alloc);
@@ -1880,6 +2491,142 @@ void devlink_sb_unregister(struct devlink *devlink, unsigned int sb_index)
 }
 EXPORT_SYMBOL_GPL(devlink_sb_unregister);
 
+/**
+ *	devlink_dpipe_headers_register - register dpipe headers
+ *
+ *	@devlink: devlink
+ *	@dpipe_headers: dpipe header array
+ *
+ *	Register the headers supported by hardware.
+ */
+int devlink_dpipe_headers_register(struct devlink *devlink,
+				   struct devlink_dpipe_headers *dpipe_headers)
+{
+	mutex_lock(&devlink_mutex);
+	devlink->dpipe_headers = dpipe_headers;
+	mutex_unlock(&devlink_mutex);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(devlink_dpipe_headers_register);
+
+/**
+ *	devlink_dpipe_headers_unregister - unregister dpipe headers
+ *
+ *	@devlink: devlink
+ *
+ *	Unregister the headers supported by hardware.
+ */
+void devlink_dpipe_headers_unregister(struct devlink *devlink)
+{
+	mutex_lock(&devlink_mutex);
+	devlink->dpipe_headers = NULL;
+	mutex_unlock(&devlink_mutex);
+}
+EXPORT_SYMBOL_GPL(devlink_dpipe_headers_unregister);
+
+/**
+ *	devlink_dpipe_table_counter_enabled - check if counter allocation
+ *					      required
+ *	@devlink: devlink
+ *	@table_name: tables name
+ *
+ *	Used by driver to check if counter allocation is required.
+ *	After counter allocation is turned on the table entries
+ *	are updated to include counter statistics.
+ *
+ *	After that point on the driver must respect the counter
+ *	state so that each entry added to the table is added
+ *	with a counter.
+ */
+bool devlink_dpipe_table_counter_enabled(struct devlink *devlink,
+					 const char *table_name)
+{
+	struct devlink_dpipe_table *table;
+	bool enabled;
+
+	rcu_read_lock();
+	table = devlink_dpipe_table_find(&devlink->dpipe_table_list,
+					 table_name);
+	enabled = false;
+	if (table)
+		enabled = table->counters_enabled;
+	rcu_read_unlock();
+	return enabled;
+}
+EXPORT_SYMBOL_GPL(devlink_dpipe_table_counter_enabled);
+
+/**
+ *	devlink_dpipe_table_register - register dpipe table
+ *
+ *	@devlink: devlink
+ *	@table_name: table name
+ *	@table_ops: table ops
+ *	@priv: priv
+ *	@matches: match tuples
+ *	@matches_count: count of matches count
+ *	@actions: action tuples
+ *	@actions_count: count of action tuples
+ *	@counter_control_extern: external control for counters
+ */
+int devlink_dpipe_table_register(struct devlink *devlink,
+				 const char *table_name,
+				 struct devlink_dpipe_table_ops *table_ops,
+				 void *priv,
+				 struct devlink_dpipe_hfield *matches,
+				 unsigned int matches_count,
+				 struct devlink_dpipe_hfield *actions,
+				 unsigned int actions_count,
+				 bool counter_control_extern)
+{
+	struct devlink_dpipe_table *table;
+
+	if (devlink_dpipe_table_find(&devlink->dpipe_table_list, table_name))
+		return -EEXIST;
+
+	table = kzalloc(sizeof(*table), GFP_KERNEL);
+	if (!table)
+		return -ENOMEM;
+
+	table->name = table_name;
+	table->table_ops = table_ops;
+	table->priv = priv;
+	table->matches = matches;
+	table->matches_count = matches_count;
+	table->actions = actions;
+	table->actions_count = actions_count;
+	table->counter_control_extern = counter_control_extern;
+	mutex_lock(&devlink_mutex);
+	list_add_tail_rcu(&table->list, &devlink->dpipe_table_list);
+	mutex_unlock(&devlink_mutex);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(devlink_dpipe_table_register);
+
+/**
+ *	devlink_dpipe_table_unregister - unregister dpipe table
+ *
+ *	@devlink: devlink
+ *	@table_name: table name
+ */
+void devlink_dpipe_table_unregister(struct devlink *devlink,
+				    const char *table_name)
+{
+	struct devlink_dpipe_table *table;
+
+	mutex_lock(&devlink_mutex);
+	table = devlink_dpipe_table_find(&devlink->dpipe_table_list,
+					 table_name);
+	if (!table)
+		goto unlock;
+	list_del_rcu(&table->list);
+	mutex_unlock(&devlink_mutex);
+	kfree_rcu(table, rcu);
+	return;
+unlock:
+	mutex_unlock(&devlink_mutex);
+}
+EXPORT_SYMBOL_GPL(devlink_dpipe_table_unregister);
+
 static int __init devlink_module_init(void)
 {
 	return genl_register_family(&devlink_nl_family);
-- 
2.7.4
