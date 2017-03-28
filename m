From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 1/8] devlink: Support for pipeline debug (dpipe)
Date: Tue, 28 Mar 2017 17:24:10 +0200
Message-ID: <1490714657-6116-2-git-send-email-jiri@resnulli.us>
References: <1490714657-6116-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, jhs@mojatatu.com, ivecera@redhat.com,
        roopa@cumulusnetworks.com, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, john.fastabend@gmail.com,
        andrew@lunn.ch, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36708 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751640AbdC1PYn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Mar 2017 11:24:43 -0400
Received: by mail-wm0-f67.google.com with SMTP id x124so309775wmf.3
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 08:24:41 -0700 (PDT)
In-Reply-To: <1490714657-6116-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

The pipeline debug is used to export the pipeline abstractions for the
main objects - tables, headers and entries. The only support for set is
for changing the counter parameter on specific table.

The basic structures:

Header - can represent a real protocol header information or internal
         metadata. Generic protocol headers like IPv4 can be shared
         between drivers. Each driver can add local headers.

Field - part of a header. Can represent protocol field or specific ASIC
        metadata field. Hardware special metadata fields can be mapped
        to different resources, for example switch ASIC ports can have
        internal number which from the systems point of view is mapped
        to netdeivce ifindex.

Match - represent specific match rule. Can describe match on specific
        field or header. The header index should be specified as well
        in order to support several header instances of the same type
        (tunneling).

Action - represents specific action rule. Actions can describe operations
         on specific field values for example like set, increment, etc.
         And header operation like add and delete.

Value - represents value which can be associated with specific match or
        action.

Table - represents a hardware block which can be described with match/
        action behavior. The match/action can be done on the packets
        data or on the internal metadata that it gathered along the
        packets traversal throw the pipeline which is vendor specific
        and should be exported in order to provide understanding of
        ASICs behavior.

Entry - represents single record in a specific table. The entry is
        identified by specific combination of values for match/action.

Prior to accessing the tables/entries the drivers provide the header/
field data base which is used by driver to user-space. The data base
is split between the shared headers and unique headers.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/devlink.h        | 259 ++++++++++++++
 include/uapi/linux/devlink.h |  67 +++-
 net/core/devlink.c           | 836 +++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 1161 insertions(+), 1 deletion(-)

diff --git a/include/net/devlink.h b/include/net/devlink.h
index d29e5fc..24de13f 100644
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
@@ -49,6 +51,178 @@ struct devlink_sb_pool_info {
 	enum devlink_sb_threshold_type threshold_type;
 };
 
+/**
+ * struct devlink_dpipe_field - dpipe field object
+ * @name: field name
+ * @id: index inside the headers field array
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
+ * @id: index, global/local detrmined by global bit
+ * @fields: fields
+ * @fields_count: number of fields
+ * @global: indicates if header is shared like most protocol header
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
+ * struct devlink_dpipe_match - represents match operation
+ * @type: type of match
+ * @header_index: header index (packets can have several headers of same
+ *		  type like in case of tunnels)
+ * @header: header
+ * @fieled_id: field index
+ */
+struct devlink_dpipe_match {
+	enum devlink_dpipe_match_type type;
+	unsigned int header_index;
+	struct devlink_dpipe_header *header;
+	unsigned int field_id;
+};
+
+/**
+ * struct devlink_dpipe_action - represents action operation
+ * @type: type of action
+ * @header_index: header index (packets can have several headers of same
+ *		  type like in case of tunnels)
+ * @header: header
+ * @fieled_id: field index
+ */
+struct devlink_dpipe_action {
+	enum devlink_dpipe_action_type type;
+	unsigned int header_index;
+	struct devlink_dpipe_header *header;
+	unsigned int field_id;
+};
+
+/**
+ * struct devlink_dpipe_value - represents value of match/action
+ * @action: action
+ * @match: match
+ * @mapping_value: in case the field has some mapping this value
+ *                 specified the mapping value
+ * @mapping_valid: specify if mapping value is valid
+ * @value_size: value size
+ * @value: value
+ * @mask: bit mask
+ */
+struct devlink_dpipe_value {
+	union {
+		struct devlink_dpipe_action *action;
+		struct devlink_dpipe_match *match;
+	};
+	unsigned int mapping_value;
+	bool mapping_valid;
+	unsigned int value_size;
+	void *value;
+	void *mask;
+};
+
+/**
+ * struct devlink_dpipe_entry - table entry object
+ * @index: index of the entry in the table
+ * @match_values: match values
+ * @matche_values_count: count of matches tuples
+ * @action_values: actions values
+ * @action_values_count: count of actions values
+ * @counter: value of counter
+ * @counter_valid: Specify if value is valid from hardware
+ */
+struct devlink_dpipe_entry {
+	u64 index;
+	struct devlink_dpipe_value *match_values;
+	unsigned int match_values_count;
+	struct devlink_dpipe_value *action_values;
+	unsigned int action_values_count;
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
+	u64 size;
+	bool counters_enabled;
+	bool counter_control_extern;
+	struct devlink_dpipe_table_ops *table_ops;
+	struct rcu_head rcu;
+};
+
+/**
+ * struct devlink_dpipe_table_ops - dpipe_table ops
+ * @actions_dump - dumps all tables actions
+ * @matches_dump - dumps all tables matches
+ * @entries_dump - dumps all active entries in the table
+ * @counters_set_update - when changing the counter status hardware sync
+ *			  maybe needed to allocate/free counter related
+ *			  resources
+ */
+struct devlink_dpipe_table_ops {
+	int (*actions_dump)(void *priv, struct sk_buff *skb);
+	int (*matches_dump)(void *priv, struct sk_buff *skb);
+	int (*entries_dump)(void *priv, bool counters_enabled,
+			    struct devlink_dpipe_dump_ctx *dump_ctx);
+	int (*counters_set_update)(void *priv, bool enable);
+};
+
+/**
+ * struct devlink_dpipe_headers - dpipe headers
+ * @headers - header array can be shared (global bit) or driver specific
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
@@ -132,6 +306,26 @@ int devlink_sb_register(struct devlink *devlink, unsigned int sb_index,
 			u16 egress_pools_count, u16 ingress_tc_count,
 			u16 egress_tc_count);
 void devlink_sb_unregister(struct devlink *devlink, unsigned int sb_index);
+int devlink_dpipe_table_register(struct devlink *devlink,
+				 const char *table_name,
+				 struct devlink_dpipe_table_ops *table_ops,
+				 void *priv, u64 size,
+				 bool counter_control_extern);
+void devlink_dpipe_table_unregister(struct devlink *devlink,
+				    const char *table_name);
+int devlink_dpipe_headers_register(struct devlink *devlink,
+				   struct devlink_dpipe_headers *dpipe_headers);
+void devlink_dpipe_headers_unregister(struct devlink *devlink);
+bool devlink_dpipe_table_counter_enabled(struct devlink *devlink,
+					 const char *table_name);
+int devlink_dpipe_entry_ctx_prepare(struct devlink_dpipe_dump_ctx *dump_ctx);
+int devlink_dpipe_entry_ctx_append(struct devlink_dpipe_dump_ctx *dump_ctx,
+				   struct devlink_dpipe_entry *entry);
+int devlink_dpipe_entry_ctx_close(struct devlink_dpipe_dump_ctx *dump_ctx);
+int devlink_dpipe_action_put(struct sk_buff *skb,
+			     struct devlink_dpipe_action *action);
+int devlink_dpipe_match_put(struct sk_buff *skb,
+			    struct devlink_dpipe_match *match);
 
 #else
 
@@ -200,6 +394,71 @@ static inline void devlink_sb_unregister(struct devlink *devlink,
 {
 }
 
+static inline int
+devlink_dpipe_table_register(struct devlink *devlink,
+			     const char *table_name,
+			     struct devlink_dpipe_table_ops *table_ops,
+			     void *priv, u64 size,
+			     bool counter_control_extern)
+{
+	return 0;
+}
+
+static inline void devlink_dpipe_table_unregister(struct devlink *devlink,
+						  const char *table_name)
+{
+}
+
+static inline int devlink_dpipe_headers_register(struct devlink *devlink,
+						 struct devlink_dpipe_headers *
+						 dpipe_headers)
+{
+	return 0;
+}
+
+static inline void devlink_dpipe_headers_unregister(struct devlink *devlink)
+{
+}
+
+static inline bool devlink_dpipe_table_counter_enabled(struct devlink *devlink,
+						       const char *table_name)
+{
+	return false;
+}
+
+static inline int
+devlink_dpipe_entry_ctx_prepare(struct devlink_dpipe_dump_ctx *dump_ctx)
+{
+	return 0;
+}
+
+static inline int
+devlink_dpipe_entry_ctx_append(struct devlink_dpipe_dump_ctx *dump_ctx,
+			       struct devlink_dpipe_entry *entry)
+{
+	return 0;
+}
+
+static inline int
+devlink_dpipe_entry_ctx_close(struct devlink_dpipe_dump_ctx *dump_ctx)
+{
+	return 0;
+}
+
+static inline int
+devlink_dpipe_action_put(struct sk_buff *skb,
+			 struct devlink_dpipe_action *action)
+{
+	return 0;
+}
+
+static inline int
+devlink_dpipe_match_put(struct sk_buff *skb,
+			struct devlink_dpipe_match *match)
+{
+	return 0;
+}
+
 #endif
 
 #endif /* _NET_DEVLINK_H_ */
diff --git a/include/uapi/linux/devlink.h b/include/uapi/linux/devlink.h
index 0f1f3a1..b47bee2 100644
--- a/include/uapi/linux/devlink.h
+++ b/include/uapi/linux/devlink.h
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
 #endif /* _UAPI_LINUX_DEVLINK_H_ */
diff --git a/net/core/devlink.c b/net/core/devlink.c
index e9c1e6a..24b7660 100644
--- a/net/core/devlink.c
+++ b/net/core/devlink.c
@@ -1493,8 +1493,686 @@ static int devlink_nl_cmd_eswitch_set_doit(struct sk_buff *skb,
 		if (err)
 			return err;
 	}
+	return 0;
+}
+
+int devlink_dpipe_match_put(struct sk_buff *skb,
+			    struct devlink_dpipe_match *match)
+{
+	struct devlink_dpipe_header *header = match->header;
+	struct devlink_dpipe_field *field = &header->fields[match->field_id];
+	struct nlattr *match_attr;
+
+	match_attr = nla_nest_start(skb, DEVLINK_ATTR_DPIPE_MATCH);
+	if (!match_attr)
+		return -EMSGSIZE;
+
+	if (nla_put_u32(skb, DEVLINK_ATTR_DPIPE_MATCH_TYPE, match->type) ||
+	    nla_put_u32(skb, DEVLINK_ATTR_DPIPE_HEADER_INDEX, match->header_index) ||
+	    nla_put_u32(skb, DEVLINK_ATTR_DPIPE_HEADER_ID, header->id) ||
+	    nla_put_u32(skb, DEVLINK_ATTR_DPIPE_FIELD_ID, field->id) ||
+	    nla_put_u8(skb, DEVLINK_ATTR_DPIPE_HEADER_GLOBAL, header->global))
+		goto nla_put_failure;
+
+	nla_nest_end(skb, match_attr);
+	return 0;
+
+nla_put_failure:
+	nla_nest_cancel(skb, match_attr);
+	return -EMSGSIZE;
+}
+EXPORT_SYMBOL_GPL(devlink_dpipe_match_put);
+
+static int devlink_dpipe_matches_put(struct devlink_dpipe_table *table,
+				     struct sk_buff *skb)
+{
+	struct nlattr *matches_attr;
+
+	matches_attr = nla_nest_start(skb, DEVLINK_ATTR_DPIPE_TABLE_MATCHES);
+	if (!matches_attr)
+		return -EMSGSIZE;
+
+	if (table->table_ops->matches_dump(table->priv, skb))
+		goto nla_put_failure;
+
+	nla_nest_end(skb, matches_attr);
+	return 0;
+
+nla_put_failure:
+	nla_nest_cancel(skb, matches_attr);
+	return -EMSGSIZE;
+}
+
+int devlink_dpipe_action_put(struct sk_buff *skb,
+			     struct devlink_dpipe_action *action)
+{
+	struct devlink_dpipe_header *header = action->header;
+	struct devlink_dpipe_field *field = &header->fields[action->field_id];
+	struct nlattr *action_attr;
+
+	action_attr = nla_nest_start(skb, DEVLINK_ATTR_DPIPE_ACTION);
+	if (!action_attr)
+		return -EMSGSIZE;
+
+	if (nla_put_u32(skb, DEVLINK_ATTR_DPIPE_ACTION_TYPE, action->type) ||
+	    nla_put_u32(skb, DEVLINK_ATTR_DPIPE_HEADER_INDEX, action->header_index) ||
+	    nla_put_u32(skb, DEVLINK_ATTR_DPIPE_HEADER_ID, header->id) ||
+	    nla_put_u32(skb, DEVLINK_ATTR_DPIPE_FIELD_ID, field->id) ||
+	    nla_put_u8(skb, DEVLINK_ATTR_DPIPE_HEADER_GLOBAL, header->global))
+		goto nla_put_failure;
+
+	nla_nest_end(skb, action_attr);
+	return 0;
+
+nla_put_failure:
+	nla_nest_cancel(skb, action_attr);
+	return -EMSGSIZE;
+}
+EXPORT_SYMBOL_GPL(devlink_dpipe_action_put);
+
+static int devlink_dpipe_actions_put(struct devlink_dpipe_table *table,
+				     struct sk_buff *skb)
+{
+	struct nlattr *actions_attr;
+
+	actions_attr = nla_nest_start(skb, DEVLINK_ATTR_DPIPE_TABLE_ACTIONS);
+	if (!actions_attr)
+		return -EMSGSIZE;
+
+	if (table->table_ops->actions_dump(table->priv, skb))
+		goto nla_put_failure;
+
+	nla_nest_end(skb, actions_attr);
+	return 0;
+
+nla_put_failure:
+	nla_nest_cancel(skb, actions_attr);
+	return -EMSGSIZE;
+}
+
+static int devlink_dpipe_table_put(struct sk_buff *skb,
+				   struct devlink_dpipe_table *table)
+{
+	struct nlattr *table_attr;
+
+	table_attr = nla_nest_start(skb, DEVLINK_ATTR_DPIPE_TABLE);
+	if (!table_attr)
+		return -EMSGSIZE;
+
+	if (nla_put_string(skb, DEVLINK_ATTR_DPIPE_TABLE_NAME, table->name) ||
+	    nla_put_u64_64bit(skb, DEVLINK_ATTR_DPIPE_TABLE_SIZE, table->size,
+			      DEVLINK_ATTR_PAD))
+		goto nla_put_failure;
+	if (nla_put_u8(skb, DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED,
+		       table->counters_enabled))
+		goto nla_put_failure;
+
+	if (devlink_dpipe_matches_put(table, skb))
+		goto nla_put_failure;
+
+	if (devlink_dpipe_actions_put(table, skb))
+		goto nla_put_failure;
+
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
+				     struct list_head *dpipe_tables,
+				     const char *table_name)
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
+
+	if (devlink_nl_put_handle(skb, devlink))
+		goto nla_put_failure;
+	tables_attr = nla_nest_start(skb, DEVLINK_ATTR_DPIPE_TABLES);
+	if (!tables_attr)
+		goto nla_put_failure;
+
+	i = 0;
+	incomplete = false;
+	list_for_each_entry_from(table, dpipe_tables, list) {
+		if (!table_name) {
+			err = devlink_dpipe_table_put(skb, table);
+			if (err) {
+				if (!i)
+					goto err_table_put;
+				incomplete = true;
+				break;
+			}
+		} else {
+			if (!strcmp(table->name, table_name)) {
+				err = devlink_dpipe_table_put(skb, table);
+				if (err)
+					break;
+			}
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
+static int devlink_nl_cmd_dpipe_table_get(struct sk_buff *skb,
+					  struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	const char *table_name =  NULL;
+
+	if (info->attrs[DEVLINK_ATTR_DPIPE_TABLE_NAME])
+		table_name = nla_data(info->attrs[DEVLINK_ATTR_DPIPE_TABLE_NAME]);
+
+	return devlink_dpipe_tables_fill(info, DEVLINK_CMD_DPIPE_TABLE_GET, 0,
+					 &devlink->dpipe_table_list,
+					 table_name);
+}
+
+static int devlink_dpipe_value_put(struct sk_buff *skb,
+				   struct devlink_dpipe_value *value)
+{
+	if (nla_put(skb, DEVLINK_ATTR_DPIPE_VALUE,
+		    value->value_size, value->value))
+		return -EMSGSIZE;
+	if (value->mask)
+		if (nla_put(skb, DEVLINK_ATTR_DPIPE_VALUE_MASK,
+			    value->value_size, value->mask))
+			return -EMSGSIZE;
+	if (value->mapping_valid)
+		if (nla_put_u32(skb, DEVLINK_ATTR_DPIPE_VALUE_MAPPING,
+				value->mapping_value))
+			return -EMSGSIZE;
+	return 0;
+}
+
+static int devlink_dpipe_action_value_put(struct sk_buff *skb,
+					  struct devlink_dpipe_value *value)
+{
+	if (!value->action)
+		return -EINVAL;
+	if (devlink_dpipe_action_put(skb, value->action))
+		return -EMSGSIZE;
+	if (devlink_dpipe_value_put(skb, value))
+		return -EMSGSIZE;
+	return 0;
+}
+
+static int devlink_dpipe_action_values_put(struct sk_buff *skb,
+					   struct devlink_dpipe_value *values,
+					   unsigned int values_count)
+{
+	struct nlattr *action_attr;
+	int i;
+	int err;
+
+	for (i = 0; i < values_count; i++) {
+		action_attr = nla_nest_start(skb,
+					     DEVLINK_ATTR_DPIPE_ACTION_VALUE);
+		if (!action_attr)
+			return -EMSGSIZE;
+		err = devlink_dpipe_action_value_put(skb, &values[i]);
+		if (err)
+			goto err_action_value_put;
+		nla_nest_end(skb, action_attr);
+	}
+	return 0;
+
+err_action_value_put:
+	nla_nest_cancel(skb, action_attr);
+	return err;
+}
+
+static int devlink_dpipe_match_value_put(struct sk_buff *skb,
+					 struct devlink_dpipe_value *value)
+{
+	if (!value->match)
+		return -EINVAL;
+	if (devlink_dpipe_match_put(skb, value->match))
+		return -EMSGSIZE;
+	if (devlink_dpipe_value_put(skb, value))
+		return -EMSGSIZE;
+	return 0;
+}
+
+static int devlink_dpipe_match_values_put(struct sk_buff *skb,
+					  struct devlink_dpipe_value *values,
+					  unsigned int values_count)
+{
+	struct nlattr *match_attr;
+	int i;
+	int err;
+
+	for (i = 0; i < values_count; i++) {
+		match_attr = nla_nest_start(skb,
+					    DEVLINK_ATTR_DPIPE_MATCH_VALUE);
+		if (!match_attr)
+			return -EMSGSIZE;
+		err = devlink_dpipe_match_value_put(skb, &values[i]);
+		if (err)
+			goto err_match_value_put;
+		nla_nest_end(skb, match_attr);
+	}
+	return 0;
+
+err_match_value_put:
+	nla_nest_cancel(skb, match_attr);
+	return err;
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
+	if (nla_put_u64_64bit(skb, DEVLINK_ATTR_DPIPE_ENTRY_INDEX, entry->index,
+			      DEVLINK_ATTR_PAD))
+		goto nla_put_failure;
+	if (entry->counter_valid)
+		if (nla_put_u64_64bit(skb, DEVLINK_ATTR_DPIPE_ENTRY_COUNTER,
+				      entry->counter, DEVLINK_ATTR_PAD))
+			goto nla_put_failure;
+
+	matches_attr = nla_nest_start(skb,
+				      DEVLINK_ATTR_DPIPE_ENTRY_MATCH_VALUES);
+	if (!matches_attr)
+		goto nla_put_failure;
+
+	err = devlink_dpipe_match_values_put(skb, entry->match_values,
+					     entry->match_values_count);
+	if (err) {
+		nla_nest_cancel(skb, matches_attr);
+		goto err_match_values_put;
+	}
+	nla_nest_end(skb, matches_attr);
+
+	actions_attr = nla_nest_start(skb,
+				      DEVLINK_ATTR_DPIPE_ENTRY_ACTION_VALUES);
+	if (!actions_attr)
+		goto nla_put_failure;
+
+	err = devlink_dpipe_action_values_put(skb, entry->action_values,
+					      entry->action_values_count);
+	if (err) {
+		nla_nest_cancel(skb, actions_attr);
+		goto err_action_values_put;
+	}
+	nla_nest_end(skb, actions_attr);
 
+	nla_nest_end(skb, entry_attr);
 	return 0;
+
+nla_put_failure:
+	err = -EMSGSIZE;
+err_match_values_put:
+err_action_values_put:
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
+int devlink_dpipe_entry_ctx_prepare(struct devlink_dpipe_dump_ctx *dump_ctx)
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
+EXPORT_SYMBOL_GPL(devlink_dpipe_entry_ctx_prepare);
+
+int devlink_dpipe_entry_ctx_append(struct devlink_dpipe_dump_ctx *dump_ctx,
+				   struct devlink_dpipe_entry *entry)
+{
+	return devlink_dpipe_entry_put(dump_ctx->skb, entry);
+}
+EXPORT_SYMBOL_GPL(devlink_dpipe_entry_ctx_append);
+
+int devlink_dpipe_entry_ctx_close(struct devlink_dpipe_dump_ctx *dump_ctx)
+{
+	nla_nest_end(dump_ctx->skb, dump_ctx->nest);
+	genlmsg_end(dump_ctx->skb, dump_ctx->hdr);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(devlink_dpipe_entry_ctx_close);
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
+		    nla_put_u32(skb, DEVLINK_ATTR_DPIPE_FIELD_BITWIDTH, field->bitwidth) ||
+		    nla_put_u32(skb, DEVLINK_ATTR_DPIPE_FIELD_MAPPING_TYPE, field->mapping_type))
+			goto nla_put_failure;
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
+	    nla_put_u32(skb, DEVLINK_ATTR_DPIPE_HEADER_ID, header->id) ||
+	    nla_put_u8(skb, DEVLINK_ATTR_DPIPE_HEADER_GLOBAL, header->global))
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
+	if (!devlink->dpipe_headers)
+		return -EOPNOTSUPP;
+	return devlink_dpipe_headers_fill(info, DEVLINK_CMD_DPIPE_HEADERS_GET,
+					  0, devlink->dpipe_headers);
+}
+
+static int devlink_dpipe_table_counters_set(struct devlink *devlink,
+					    const char *table_name,
+					    bool enable)
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
+	if (table->table_ops->counters_set_update)
+		table->table_ops->counters_set_update(table->priv, enable);
+	return 0;
+}
+
+static int devlink_nl_cmd_dpipe_table_counters_set(struct sk_buff *skb,
+						   struct genl_info *info)
+{
+	struct devlink *devlink = info->user_ptr[0];
+	const char *table_name;
+	bool counters_enable;
+
+	if (!info->attrs[DEVLINK_ATTR_DPIPE_TABLE_NAME] ||
+	    !info->attrs[DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED])
+		return -EINVAL;
+
+	table_name = nla_data(info->attrs[DEVLINK_ATTR_DPIPE_TABLE_NAME]);
+	counters_enable = !!nla_get_u8(info->attrs[DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED]);
+
+	return devlink_dpipe_table_counters_set(devlink, table_name,
+						counters_enable);
 }
 
 static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
@@ -1512,6 +2190,8 @@ static const struct nla_policy devlink_nl_policy[DEVLINK_ATTR_MAX + 1] = {
 	[DEVLINK_ATTR_SB_TC_INDEX] = { .type = NLA_U16 },
 	[DEVLINK_ATTR_ESWITCH_MODE] = { .type = NLA_U16 },
 	[DEVLINK_ATTR_ESWITCH_INLINE_MODE] = { .type = NLA_U8 },
+	[DEVLINK_ATTR_DPIPE_TABLE_NAME] = { .type = NLA_NUL_STRING },
+	[DEVLINK_ATTR_DPIPE_TABLE_COUNTERS_ENABLED] = { .type = NLA_U8 },
 };
 
 static const struct genl_ops devlink_nl_ops[] = {
@@ -1644,6 +2324,34 @@ static const struct genl_ops devlink_nl_ops[] = {
 		.flags = GENL_ADMIN_PERM,
 		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
 	},
+	{
+		.cmd = DEVLINK_CMD_DPIPE_TABLE_GET,
+		.doit = devlink_nl_cmd_dpipe_table_get,
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
+		.cmd = DEVLINK_CMD_DPIPE_TABLE_COUNTERS_SET,
+		.doit = devlink_nl_cmd_dpipe_table_counters_set,
+		.policy = devlink_nl_policy,
+		.flags = GENL_ADMIN_PERM,
+		.internal_flags = DEVLINK_NL_FLAG_NEED_DEVLINK,
+	},
 };
 
 static struct genl_family devlink_nl_family __ro_after_init = {
@@ -1680,6 +2388,7 @@ struct devlink *devlink_alloc(const struct devlink_ops *ops, size_t priv_size)
 	devlink_net_set(devlink, &init_net);
 	INIT_LIST_HEAD(&devlink->port_list);
 	INIT_LIST_HEAD(&devlink->sb_list);
+	INIT_LIST_HEAD_RCU(&devlink->dpipe_table_list);
 	return devlink;
 }
 EXPORT_SYMBOL_GPL(devlink_alloc);
@@ -1880,6 +2589,133 @@ void devlink_sb_unregister(struct devlink *devlink, unsigned int sb_index)
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
+ *	@size: size
+ *	@counter_control_extern: external control for counters
+ */
+int devlink_dpipe_table_register(struct devlink *devlink,
+				 const char *table_name,
+				 struct devlink_dpipe_table_ops *table_ops,
+				 void *priv, u64 size,
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
+	table->size = size;
+	table->counter_control_extern = counter_control_extern;
+
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
