From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 08/17] tipc: convert legacy nl name table dump to nl compat
Date: Mon, 9 Feb 2015 09:50:10 +0100
Message-ID: <1423471819-23112-9-git-send-email-richard.alpe@ericsson.com>
References: <1423471819-23112-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Richard Alpe <richard.alpe@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:44309 "EHLO
	sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933151AbbBIIyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 03:54:38 -0500
In-Reply-To: <1423471819-23112-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>

Add functionality for printing a dump header and convert
TIPC_CMD_SHOW_NAME_TABLE to compat dumpit.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/config.c         |   4 -
 net/tipc/name_table.c     | 184 ----------------------------------------------
 net/tipc/name_table.h     |   2 -
 net/tipc/netlink_compat.c | 101 +++++++++++++++++++++++++
 4 files changed, 101 insertions(+), 190 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index 11c16d1..7b053fc 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -209,10 +209,6 @@ struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 		rep_tlv_buf = tipc_node_get_nodes(net, req_tlv_area,
 						  req_tlv_space);
 		break;
-	case TIPC_CMD_SHOW_NAME_TABLE:
-		rep_tlv_buf = tipc_nametbl_get(net, req_tlv_area,
-					       req_tlv_space);
-		break;
 	case TIPC_CMD_GET_MEDIA_NAMES:
 		rep_tlv_buf = tipc_media_get_names();
 		break;
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 2251912..c8eaa2a 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -773,190 +773,6 @@ void tipc_nametbl_unsubscribe(struct tipc_subscription *s)
 	spin_unlock_bh(&tn->nametbl_lock);
 }
 
-/**
- * subseq_list - print specified sub-sequence contents into the given buffer
- */
-static int subseq_list(struct sub_seq *sseq, char *buf, int len, u32 depth,
-		       u32 index)
-{
-	char portIdStr[27];
-	const char *scope_str[] = {"", " zone", " cluster", " node"};
-	struct publication *publ;
-	struct name_info *info;
-	int ret;
-
-	ret = tipc_snprintf(buf, len, "%-10u %-10u ", sseq->lower, sseq->upper);
-
-	if (depth == 2) {
-		ret += tipc_snprintf(buf - ret, len + ret, "\n");
-		return ret;
-	}
-
-	info = sseq->info;
-
-	list_for_each_entry(publ, &info->zone_list, zone_list) {
-		sprintf(portIdStr, "<%u.%u.%u:%u>",
-			 tipc_zone(publ->node), tipc_cluster(publ->node),
-			 tipc_node(publ->node), publ->ref);
-		ret += tipc_snprintf(buf + ret, len - ret, "%-26s ", portIdStr);
-		if (depth > 3) {
-			ret += tipc_snprintf(buf + ret, len - ret, "%-10u %s",
-					     publ->key, scope_str[publ->scope]);
-		}
-		if (!list_is_last(&publ->zone_list, &info->zone_list))
-			ret += tipc_snprintf(buf + ret, len - ret,
-					     "\n%33s", " ");
-	}
-
-	ret += tipc_snprintf(buf + ret, len - ret, "\n");
-	return ret;
-}
-
-/**
- * nameseq_list - print specified name sequence contents into the given buffer
- */
-static int nameseq_list(struct name_seq *seq, char *buf, int len, u32 depth,
-			u32 type, u32 lowbound, u32 upbound, u32 index)
-{
-	struct sub_seq *sseq;
-	char typearea[11];
-	int ret = 0;
-
-	if (seq->first_free == 0)
-		return 0;
-
-	sprintf(typearea, "%-10u", seq->type);
-
-	if (depth == 1) {
-		ret += tipc_snprintf(buf, len, "%s\n", typearea);
-		return ret;
-	}
-
-	for (sseq = seq->sseqs; sseq != &seq->sseqs[seq->first_free]; sseq++) {
-		if ((lowbound <= sseq->upper) && (upbound >= sseq->lower)) {
-			ret += tipc_snprintf(buf + ret, len - ret, "%s ",
-					    typearea);
-			spin_lock_bh(&seq->lock);
-			ret += subseq_list(sseq, buf + ret, len - ret,
-					  depth, index);
-			spin_unlock_bh(&seq->lock);
-			sprintf(typearea, "%10s", " ");
-		}
-	}
-	return ret;
-}
-
-/**
- * nametbl_header - print name table header into the given buffer
- */
-static int nametbl_header(char *buf, int len, u32 depth)
-{
-	const char *header[] = {
-		"Type       ",
-		"Lower      Upper      ",
-		"Port Identity              ",
-		"Publication Scope"
-	};
-
-	int i;
-	int ret = 0;
-
-	if (depth > 4)
-		depth = 4;
-	for (i = 0; i < depth; i++)
-		ret += tipc_snprintf(buf + ret, len - ret, header[i]);
-	ret += tipc_snprintf(buf + ret, len - ret, "\n");
-	return ret;
-}
-
-/**
- * nametbl_list - print specified name table contents into the given buffer
- */
-static int nametbl_list(struct net *net, char *buf, int len, u32 depth_info,
-			u32 type, u32 lowbound, u32 upbound)
-{
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
-	struct hlist_head *seq_head;
-	struct name_seq *seq;
-	int all_types;
-	int ret = 0;
-	u32 depth;
-	u32 i;
-
-	all_types = (depth_info & TIPC_NTQ_ALLTYPES);
-	depth = (depth_info & ~TIPC_NTQ_ALLTYPES);
-
-	if (depth == 0)
-		return 0;
-
-	if (all_types) {
-		/* display all entries in name table to specified depth */
-		ret += nametbl_header(buf, len, depth);
-		lowbound = 0;
-		upbound = ~0;
-		for (i = 0; i < TIPC_NAMETBL_SIZE; i++) {
-			seq_head = &tn->nametbl->seq_hlist[i];
-			hlist_for_each_entry_rcu(seq, seq_head, ns_list) {
-				ret += nameseq_list(seq, buf + ret, len - ret,
-						   depth, seq->type,
-						   lowbound, upbound, i);
-			}
-		}
-	} else {
-		/* display only the sequence that matches the specified type */
-		if (upbound < lowbound) {
-			ret += tipc_snprintf(buf + ret, len - ret,
-					"invalid name sequence specified\n");
-			return ret;
-		}
-		ret += nametbl_header(buf + ret, len - ret, depth);
-		i = hash(type);
-		seq_head = &tn->nametbl->seq_hlist[i];
-		hlist_for_each_entry_rcu(seq, seq_head, ns_list) {
-			if (seq->type == type) {
-				ret += nameseq_list(seq, buf + ret, len - ret,
-						   depth, type,
-						   lowbound, upbound, i);
-				break;
-			}
-		}
-	}
-	return ret;
-}
-
-struct sk_buff *tipc_nametbl_get(struct net *net, const void *req_tlv_area,
-				 int req_tlv_space)
-{
-	struct sk_buff *buf;
-	struct tipc_name_table_query *argv;
-	struct tlv_desc *rep_tlv;
-	char *pb;
-	int pb_len;
-	int str_len;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_NAME_TBL_QUERY))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	buf = tipc_cfg_reply_alloc(TLV_SPACE(ULTRA_STRING_MAX_LEN));
-	if (!buf)
-		return NULL;
-
-	rep_tlv = (struct tlv_desc *)buf->data;
-	pb = TLV_DATA(rep_tlv);
-	pb_len = ULTRA_STRING_MAX_LEN;
-	argv = (struct tipc_name_table_query *)TLV_DATA(req_tlv_area);
-	rcu_read_lock();
-	str_len = nametbl_list(net, pb, pb_len, ntohl(argv->depth),
-			       ntohl(argv->type),
-			       ntohl(argv->lowbound), ntohl(argv->upbound));
-	rcu_read_unlock();
-	str_len += 1;	/* for "\0" */
-	skb_put(buf, TLV_SPACE(str_len));
-	TLV_SET(rep_tlv, TIPC_TLV_ULTRA_STRING, NULL, str_len);
-
-	return buf;
-}
-
 int tipc_nametbl_init(struct net *net)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
diff --git a/net/tipc/name_table.h b/net/tipc/name_table.h
index 0304ddc..1524a73 100644
--- a/net/tipc/name_table.h
+++ b/net/tipc/name_table.h
@@ -97,8 +97,6 @@ struct name_table {
 
 int tipc_nl_name_table_dump(struct sk_buff *skb, struct netlink_callback *cb);
 
-struct sk_buff *tipc_nametbl_get(struct net *net, const void *req_tlv_area,
-				 int req_tlv_space);
 u32 tipc_nametbl_translate(struct net *net, u32 type, u32 instance, u32 *node);
 int tipc_nametbl_mc_translate(struct net *net, u32 type, u32 lower, u32 upper,
 			      u32 limit, struct tipc_plist *dports);
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index 0246123..40c24ea 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -35,6 +35,7 @@
 #include "config.h"
 #include "bearer.h"
 #include "link.h"
+#include "name_table.h"
 #include <net/genetlink.h>
 #include <linux/tipc_config.h>
 
@@ -58,6 +59,7 @@ struct tipc_nl_compat_msg {
 };
 
 struct tipc_nl_compat_cmd_dump {
+	int (*header)(struct tipc_nl_compat_msg *);
 	int (*dumpit)(struct sk_buff *, struct netlink_callback *);
 	int (*format)(struct tipc_nl_compat_msg *msg, struct nlattr **attrs);
 };
@@ -246,6 +248,9 @@ static int tipc_nl_compat_dumpit(struct tipc_nl_compat_cmd_dump *cmd,
 	if (msg->rep_type)
 		tipc_tlv_init(msg->rep, msg->rep_type);
 
+	if (cmd->header)
+		(*cmd->header)(msg);
+
 	arg = nlmsg_new(0, GFP_KERNEL);
 	if (!arg) {
 		kfree_skb(msg->rep);
@@ -626,6 +631,93 @@ static int tipc_nl_compat_link_reset_stats(struct sk_buff *skb,
 	return 0;
 }
 
+static int tipc_nl_compat_name_table_dump_header(struct tipc_nl_compat_msg *msg)
+{
+	int i;
+	u32 depth;
+	struct tipc_name_table_query *ntq;
+	static const char * const header[] = {
+		"Type       ",
+		"Lower      Upper      ",
+		"Port Identity              ",
+		"Publication Scope"
+	};
+
+	ntq = (struct tipc_name_table_query *)TLV_DATA(msg->req);
+
+	depth = ntohl(ntq->depth);
+
+	if (depth > 4)
+		depth = 4;
+	for (i = 0; i < depth; i++)
+		tipc_tlv_sprintf(msg->rep, header[i]);
+	tipc_tlv_sprintf(msg->rep, "\n");
+
+	return 0;
+}
+
+static int tipc_nl_compat_name_table_dump(struct tipc_nl_compat_msg *msg,
+					  struct nlattr **attrs)
+{
+	char port_str[27];
+	struct tipc_name_table_query *ntq;
+	struct nlattr *nt[TIPC_NLA_NAME_TABLE_MAX + 1];
+	struct nlattr *publ[TIPC_NLA_PUBL_MAX + 1];
+	u32 node, depth, type, lowbound, upbound;
+	static const char * const scope_str[] = {"", " zone", " cluster",
+						 " node"};
+
+	nla_parse_nested(nt, TIPC_NLA_NAME_TABLE_MAX,
+			 attrs[TIPC_NLA_NAME_TABLE], NULL);
+
+	nla_parse_nested(publ, TIPC_NLA_PUBL_MAX, nt[TIPC_NLA_NAME_TABLE_PUBL],
+			 NULL);
+
+	ntq = (struct tipc_name_table_query *)TLV_DATA(msg->req);
+
+	depth = ntohl(ntq->depth);
+	type = ntohl(ntq->type);
+	lowbound = ntohl(ntq->lowbound);
+	upbound = ntohl(ntq->upbound);
+
+	if (!(depth & TIPC_NTQ_ALLTYPES) &&
+	    (type != nla_get_u32(publ[TIPC_NLA_PUBL_TYPE])))
+		return 0;
+	if (lowbound && (lowbound > nla_get_u32(publ[TIPC_NLA_PUBL_UPPER])))
+		return 0;
+	if (upbound && (upbound < nla_get_u32(publ[TIPC_NLA_PUBL_LOWER])))
+		return 0;
+
+	tipc_tlv_sprintf(msg->rep, "%-10u ",
+			 nla_get_u32(publ[TIPC_NLA_PUBL_TYPE]));
+
+	if (depth == 1)
+		goto out;
+
+	tipc_tlv_sprintf(msg->rep, "%-10u %-10u ",
+			 nla_get_u32(publ[TIPC_NLA_PUBL_LOWER]),
+			 nla_get_u32(publ[TIPC_NLA_PUBL_UPPER]));
+
+	if (depth == 2)
+		goto out;
+
+	node = nla_get_u32(publ[TIPC_NLA_PUBL_NODE]);
+	sprintf(port_str, "<%u.%u.%u:%u>", tipc_zone(node), tipc_cluster(node),
+		tipc_node(node), nla_get_u32(publ[TIPC_NLA_PUBL_REF]));
+	tipc_tlv_sprintf(msg->rep, "%-26s ", port_str);
+
+	if (depth == 3)
+		goto out;
+
+	tipc_tlv_sprintf(msg->rep, "%-10u %s",
+			 nla_get_u32(publ[TIPC_NLA_PUBL_REF]),
+			 scope_str[nla_get_u32(publ[TIPC_NLA_PUBL_SCOPE])]);
+out:
+	tipc_tlv_sprintf(msg->rep, "\n");
+
+	return 0;
+}
+
 static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 {
 	struct tipc_nl_compat_cmd_dump dump;
@@ -675,6 +767,14 @@ static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 		doit.doit = tipc_nl_link_reset_stats;
 		doit.transcode = tipc_nl_compat_link_reset_stats;
 		return tipc_nl_compat_doit(&doit, msg);
+	case TIPC_CMD_SHOW_NAME_TABLE:
+		msg->req_type = TIPC_TLV_NAME_TBL_QUERY;
+		msg->rep_size = ULTRA_STRING_MAX_LEN;
+		msg->rep_type = TIPC_TLV_ULTRA_STRING;
+		dump.header = tipc_nl_compat_name_table_dump_header;
+		dump.dumpit = tipc_nl_name_table_dump;
+		dump.format = tipc_nl_compat_name_table_dump;
+		return tipc_nl_compat_dumpit(&dump, msg);
 	}
 
 	return -EOPNOTSUPP;
@@ -780,6 +880,7 @@ static int tipc_nl_compat_tmp_wrap(struct sk_buff *skb, struct genl_info *info)
 	case TIPC_CMD_SET_LINK_PRI:
 	case TIPC_CMD_SET_LINK_WINDOW:
 	case TIPC_CMD_RESET_LINK_STATS:
+	case TIPC_CMD_SHOW_NAME_TABLE:
 		return tipc_nl_compat_recv(skb, info);
 	}
 
-- 
2.1.4
