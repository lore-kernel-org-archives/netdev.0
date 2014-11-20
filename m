From: <richard.alpe@ericsson.com>
Subject: [PATCH v3 net-next 14/14] tipc: add name table
	dump to new netlink api
Date: Thu, 20 Nov 2014 10:29:20 +0100
Message-ID: <1416475760-18914-15-git-send-email-richard.alpe@ericsson.com>
References: <1416475760-18914-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1416475760-18914-1-git-send-email-richard.alpe@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Richard Alpe <richard.alpe@ericsson.com>

Add TIPC_NL_NAME_TABLE_GET command to the new tipc netlink API.

This command supports dumping the name table of all nodes.

Netlink logical layout of name table response message:
-> name table
    -> publication
        -> type
        -> lower
        -> upper
        -> scope
        -> node
        -> ref
        -> key

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 include/uapi/linux/tipc_netlink.h |   11 +++
 net/tipc/name_table.c             |  190 ++++++++++++++++++++++++++++++++++++-
 net/tipc/name_table.h             |    4 +-
 net/tipc/netlink.c                |    9 +-
 4 files changed, 211 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/tipc_netlink.h b/include/uapi/linux/tipc_netlink.h
index fb980e2..8d72382 100644
--- a/include/uapi/linux/tipc_netlink.h
+++ b/include/uapi/linux/tipc_netlink.h
@@ -55,6 +55,7 @@ enum {
 	TIPC_NL_NODE_GET,
 	TIPC_NL_NET_GET,
 	TIPC_NL_NET_SET,
+	TIPC_NL_NAME_TABLE_GET,
 
 	__TIPC_NL_CMD_MAX,
 	TIPC_NL_CMD_MAX = __TIPC_NL_CMD_MAX - 1
@@ -70,6 +71,7 @@ enum {
 	TIPC_NLA_MEDIA,			/* nest */
 	TIPC_NLA_NODE,			/* nest */
 	TIPC_NLA_NET,			/* nest */
+	TIPC_NLA_NAME_TABLE,		/* nest */
 
 	__TIPC_NLA_MAX,
 	TIPC_NLA_MAX = __TIPC_NLA_MAX - 1
@@ -146,6 +148,15 @@ enum {
 	TIPC_NLA_NET_MAX = __TIPC_NLA_NET_MAX - 1
 };
 
+/* Name table info */
+enum {
+	TIPC_NLA_NAME_TABLE_UNSPEC,
+	TIPC_NLA_NAME_TABLE_PUBL,	/* nest */
+
+	__TIPC_NLA_NAME_TABLE_MAX,
+	TIPC_NLA_NAME_TABLE_MAX = __TIPC_NLA_NAME_TABLE_MAX - 1
+};
+
 /* Publication info */
 enum {
 	TIPC_NLA_PUBL_UNSPEC,
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 3a6a0a7..30ca8e0 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/name_table.c: TIPC name table code
  *
- * Copyright (c) 2000-2006, Ericsson AB
+ * Copyright (c) 2000-2006, 2014, Ericsson AB
  * Copyright (c) 2004-2008, 2010-2011, Wind River Systems
  * All rights reserved.
  *
@@ -42,6 +42,12 @@
 
 #define TIPC_NAMETBL_SIZE 1024		/* must be a power of 2 */
 
+static const struct nla_policy
+tipc_nl_name_table_policy[TIPC_NLA_NAME_TABLE_MAX + 1] = {
+	[TIPC_NLA_NAME_TABLE_UNSPEC]	= { .type = NLA_UNSPEC },
+	[TIPC_NLA_NAME_TABLE_PUBL]	= { .type = NLA_NESTED }
+};
+
 /**
  * struct name_info - name sequence publication info
  * @node_list: circular list of publications made by own node
@@ -995,3 +1001,185 @@ void tipc_nametbl_stop(void)
 	table.types = NULL;
 	write_unlock_bh(&tipc_nametbl_lock);
 }
+
+int __tipc_nl_add_nametable_publ(struct tipc_nl_msg *msg, struct name_seq *seq,
+				 struct sub_seq *sseq, u32 *last_publ)
+{
+	void *hdr;
+	struct nlattr *attrs;
+	struct nlattr *publ;
+	struct publication *p;
+
+	if (*last_publ) {
+		list_for_each_entry(p, &sseq->info->zone_list, zone_list)
+			if (p->key == *last_publ)
+				break;
+		if (p->key != *last_publ)
+			return -EPIPE;
+	} else {
+		p = list_first_entry(&sseq->info->zone_list, struct publication,
+				     zone_list);
+	}
+
+	list_for_each_entry_from(p, &sseq->info->zone_list, zone_list) {
+		*last_publ = p->key;
+
+		hdr = genlmsg_put(msg->skb, msg->portid, msg->seq,
+				  &tipc_genl_v2_family, NLM_F_MULTI,
+				  TIPC_NL_NAME_TABLE_GET);
+		if (!hdr)
+			return -EMSGSIZE;
+
+		attrs = nla_nest_start(msg->skb, TIPC_NLA_NAME_TABLE);
+		if (!attrs)
+			goto msg_full;
+
+		publ = nla_nest_start(msg->skb, TIPC_NLA_NAME_TABLE_PUBL);
+		if (!publ)
+			goto attr_msg_full;
+
+		if (nla_put_u32(msg->skb, TIPC_NLA_PUBL_TYPE, seq->type))
+			goto publ_msg_full;
+		if (nla_put_u32(msg->skb, TIPC_NLA_PUBL_LOWER, sseq->lower))
+			goto publ_msg_full;
+		if (nla_put_u32(msg->skb, TIPC_NLA_PUBL_UPPER, sseq->upper))
+			goto publ_msg_full;
+		if (nla_put_u32(msg->skb, TIPC_NLA_PUBL_SCOPE, p->scope))
+			goto publ_msg_full;
+		if (nla_put_u32(msg->skb, TIPC_NLA_PUBL_NODE, p->node))
+			goto publ_msg_full;
+		if (nla_put_u32(msg->skb, TIPC_NLA_PUBL_REF, p->ref))
+			goto publ_msg_full;
+		if (nla_put_u32(msg->skb, TIPC_NLA_PUBL_KEY, p->key))
+			goto publ_msg_full;
+
+		nla_nest_end(msg->skb, publ);
+		nla_nest_end(msg->skb, attrs);
+		genlmsg_end(msg->skb, hdr);
+	}
+	*last_publ = 0;
+
+	return 0;
+
+publ_msg_full:
+	nla_nest_cancel(msg->skb, publ);
+attr_msg_full:
+	nla_nest_cancel(msg->skb, attrs);
+msg_full:
+	genlmsg_cancel(msg->skb, hdr);
+
+	return -EMSGSIZE;
+}
+
+int __tipc_nl_subseq_list(struct tipc_nl_msg *msg, struct name_seq *seq,
+			  u32 *last_lower, u32 *last_publ)
+{
+	struct sub_seq *sseq;
+	struct sub_seq *sseq_start;
+	int err;
+
+	if (*last_lower) {
+		sseq_start = nameseq_find_subseq(seq, *last_lower);
+		if (!sseq_start)
+			return -EPIPE;
+	} else {
+		sseq_start = seq->sseqs;
+	}
+
+	for (sseq = sseq_start; sseq != &seq->sseqs[seq->first_free]; sseq++) {
+		err = __tipc_nl_add_nametable_publ(msg, seq, sseq, last_publ);
+		if (err) {
+			*last_lower = sseq->lower;
+			return err;
+		}
+	}
+	*last_lower = 0;
+
+	return 0;
+}
+
+int __tipc_nl_seq_list(struct tipc_nl_msg *msg, u32 *last_type, u32 *last_lower,
+		       u32 *last_publ)
+{
+	struct hlist_head *seq_head;
+	struct name_seq *seq;
+	int err;
+	int i;
+
+	if (*last_type)
+		i = hash(*last_type);
+	else
+		i = 0;
+
+	for (; i < TIPC_NAMETBL_SIZE; i++) {
+		seq_head = &table.types[i];
+
+		if (*last_type) {
+			seq = nametbl_find_seq(*last_type);
+			if (!seq)
+				return -EPIPE;
+		} else {
+			seq = hlist_entry_safe((seq_head)->first,
+					       struct name_seq, ns_list);
+			if (!seq)
+				continue;
+		}
+
+		hlist_for_each_entry_from(seq, ns_list) {
+			spin_lock_bh(&seq->lock);
+
+			err = __tipc_nl_subseq_list(msg, seq, last_lower,
+						    last_publ);
+
+			if (err) {
+				*last_type = seq->type;
+				spin_unlock_bh(&seq->lock);
+				return err;
+			}
+			spin_unlock_bh(&seq->lock);
+		}
+		*last_type = 0;
+	}
+	return 0;
+}
+
+int tipc_nl_name_table_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	int err;
+	int done = cb->args[3];
+	u32 last_type = cb->args[0];
+	u32 last_lower = cb->args[1];
+	u32 last_publ = cb->args[2];
+	struct tipc_nl_msg msg;
+
+	if (done)
+		return 0;
+
+	msg.skb = skb;
+	msg.portid = NETLINK_CB(cb->skb).portid;
+	msg.seq = cb->nlh->nlmsg_seq;
+
+	read_lock_bh(&tipc_nametbl_lock);
+
+	err = __tipc_nl_seq_list(&msg, &last_type, &last_lower, &last_publ);
+	if (!err) {
+		done = 1;
+	} else if (err != -EMSGSIZE) {
+		/* We never set seq or call nl_dump_check_consistent() this
+		 * means that setting prev_seq here will cause the consistence
+		 * check to fail in the netlink callback handler. Resulting in
+		 * the NLMSG_DONE message having the NLM_F_DUMP_INTR flag set if
+		 * we got an error.
+		 */
+		cb->prev_seq = 1;
+	}
+
+	read_unlock_bh(&tipc_nametbl_lock);
+
+	cb->args[0] = last_type;
+	cb->args[1] = last_lower;
+	cb->args[2] = last_publ;
+	cb->args[3] = done;
+
+	return skb->len;
+}
diff --git a/net/tipc/name_table.h b/net/tipc/name_table.h
index f02f48b..b38ebec 100644
--- a/net/tipc/name_table.h
+++ b/net/tipc/name_table.h
@@ -1,7 +1,7 @@
 /*
  * net/tipc/name_table.h: Include file for TIPC name table code
  *
- * Copyright (c) 2000-2006, Ericsson AB
+ * Copyright (c) 2000-2006, 2014, Ericsson AB
  * Copyright (c) 2004-2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
@@ -84,6 +84,8 @@ struct publication {
 
 extern rwlock_t tipc_nametbl_lock;
 
+int tipc_nl_name_table_dump(struct sk_buff *skb, struct netlink_callback *cb);
+
 struct sk_buff *tipc_nametbl_get(const void *req_tlv_area, int req_tlv_space);
 u32 tipc_nametbl_translate(u32 type, u32 instance, u32 *node);
 int tipc_nametbl_mc_translate(u32 type, u32 lower, u32 upper, u32 limit,
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index cb37d30..b891e39 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -37,6 +37,7 @@
 #include "core.h"
 #include "config.h"
 #include "socket.h"
+#include "name_table.h"
 #include "bearer.h"
 #include "link.h"
 #include "node.h"
@@ -81,7 +82,8 @@ static const struct nla_policy tipc_nl_policy[TIPC_NLA_MAX + 1] = {
 	[TIPC_NLA_LINK]		= { .type = NLA_NESTED, },
 	[TIPC_NLA_MEDIA]	= { .type = NLA_NESTED, },
 	[TIPC_NLA_NODE]		= { .type = NLA_NESTED, },
-	[TIPC_NLA_NET]		= { .type = NLA_NESTED, }
+	[TIPC_NLA_NET]		= { .type = NLA_NESTED, },
+	[TIPC_NLA_NAME_TABLE]	= { .type = NLA_NESTED, }
 };
 
 /* Legacy ASCII API */
@@ -185,6 +187,11 @@ static const struct genl_ops tipc_genl_v2_ops[] = {
 		.cmd	= TIPC_NL_NET_SET,
 		.doit	= tipc_nl_net_set,
 		.policy = tipc_nl_policy,
+	},
+	{
+		.cmd	= TIPC_NL_NAME_TABLE_GET,
+		.dumpit	= tipc_nl_name_table_dump,
+		.policy = tipc_nl_policy,
 	}
 };
 
-- 
1.7.10.4


------------------------------------------------------------------------------
Download BIRT iHub F-Type - The Free Enterprise-Grade BIRT Server
from Actuate! Instantly Supercharge Your Business Reports and Dashboards
with Interactivity, Sharing, Native Excel Exports, App Integration & more
Get technology previously reserved for billion-dollar corporations, FREE
http://pubads.g.doubleclick.net/gampad/clk?id=157005751&iu=/4140/ostg.clktrk
