From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next v1 04/17] tipc: convert legacy nl link stat to nl compat
Date: Mon, 9 Feb 2015 09:50:06 +0100
Message-ID: <1423471819-23112-5-git-send-email-richard.alpe@ericsson.com>
References: <1423471819-23112-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Richard Alpe <richard.alpe@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:48594 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933113AbbBIIyi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 03:54:38 -0500
In-Reply-To: <1423471819-23112-1-git-send-email-richard.alpe@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>

Add functionality for safely appending string data to a TLV without
keeping write count in the caller.

Convert TIPC_CMD_SHOW_LINK_STATS to compat dumpit.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 include/uapi/linux/tipc_config.h |  10 ++
 net/tipc/bcast.c                 |  43 --------
 net/tipc/bcast.h                 |   1 -
 net/tipc/config.c                |   4 -
 net/tipc/link.c                  | 141 ---------------------------
 net/tipc/link.h                  |   3 -
 net/tipc/netlink_compat.c        | 205 +++++++++++++++++++++++++++++++++++++++
 7 files changed, 215 insertions(+), 192 deletions(-)

diff --git a/include/uapi/linux/tipc_config.h b/include/uapi/linux/tipc_config.h
index f922656..087b0ef 100644
--- a/include/uapi/linux/tipc_config.h
+++ b/include/uapi/linux/tipc_config.h
@@ -277,11 +277,21 @@ static inline int TLV_GET_LEN(struct tlv_desc *tlv)
 	return ntohs(tlv->tlv_len);
 }
 
+static inline void TLV_SET_LEN(struct tlv_desc *tlv, __u16 len)
+{
+	tlv->tlv_len = htons(len);
+}
+
 static inline int TLV_CHECK_TYPE(struct tlv_desc *tlv,  __u16 type)
 {
 	return (ntohs(tlv->tlv_type) == type);
 }
 
+static inline void TLV_SET_TYPE(struct tlv_desc *tlv, __u16 type)
+{
+	tlv->tlv_type = htons(type);
+}
+
 static inline int TLV_SET(void *tlv, __u16 type, void *data, __u16 len)
 {
 	struct tlv_desc *tlv_ptr;
diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index e96fd6a..3e41704 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -860,49 +860,6 @@ msg_full:
 	return -EMSGSIZE;
 }
 
-int tipc_bclink_stats(struct net *net, char *buf, const u32 buf_size)
-{
-	int ret;
-	struct tipc_stats *s;
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
-	struct tipc_link *bcl = tn->bcl;
-
-	if (!bcl)
-		return 0;
-
-	tipc_bclink_lock(net);
-
-	s = &bcl->stats;
-
-	ret = tipc_snprintf(buf, buf_size, "Link <%s>\n"
-			    "  Window:%u packets\n",
-			    bcl->name, bcl->queue_limit[0]);
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  RX packets:%u fragments:%u/%u bundles:%u/%u\n",
-			     s->recv_info, s->recv_fragments,
-			     s->recv_fragmented, s->recv_bundles,
-			     s->recv_bundled);
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  TX packets:%u fragments:%u/%u bundles:%u/%u\n",
-			     s->sent_info, s->sent_fragments,
-			     s->sent_fragmented, s->sent_bundles,
-			     s->sent_bundled);
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  RX naks:%u defs:%u dups:%u\n",
-			     s->recv_nacks, s->deferred_recv, s->duplicates);
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  TX naks:%u acks:%u dups:%u\n",
-			     s->sent_nacks, s->sent_acks, s->retransmitted);
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  Congestion link:%u  Send queue max:%u avg:%u\n",
-			     s->link_congs, s->max_queue_sz,
-			     s->queue_sz_counts ?
-			     (s->accu_queue_sz / s->queue_sz_counts) : 0);
-
-	tipc_bclink_unlock(net);
-	return ret;
-}
-
 int tipc_bclink_reset_stats(struct net *net)
 {
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index a910c0b..43f397f 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -127,7 +127,6 @@ u32  tipc_bclink_get_last_sent(struct net *net);
 u32  tipc_bclink_acks_missing(struct tipc_node *n_ptr);
 void tipc_bclink_update_link_state(struct tipc_node *node,
 				   u32 last_sent);
-int  tipc_bclink_stats(struct net *net, char *stats_buf, const u32 buf_size);
 int  tipc_bclink_reset_stats(struct net *net);
 int  tipc_bclink_set_queue_limits(struct net *net, u32 limit);
 void tipc_bcbearer_sort(struct net *net, struct tipc_node_map *nm_ptr,
diff --git a/net/tipc/config.c b/net/tipc/config.c
index f8cd5e1..67b76ee 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -213,10 +213,6 @@ struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 		rep_tlv_buf = tipc_node_get_links(net, req_tlv_area,
 						  req_tlv_space);
 		break;
-	case TIPC_CMD_SHOW_LINK_STATS:
-		rep_tlv_buf = tipc_link_cmd_show_stats(net, req_tlv_area,
-						       req_tlv_space);
-		break;
 	case TIPC_CMD_RESET_LINK_STATS:
 		rep_tlv_buf = tipc_link_cmd_reset_stats(net, req_tlv_area,
 							req_tlv_space);
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 466f28f..2622fb9 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2146,147 +2146,6 @@ struct sk_buff *tipc_link_cmd_reset_stats(struct net *net,
 	return tipc_cfg_reply_none();
 }
 
-/**
- * percent - convert count to a percentage of total (rounding up or down)
- */
-static u32 percent(u32 count, u32 total)
-{
-	return (count * 100 + (total / 2)) / total;
-}
-
-/**
- * tipc_link_stats - print link statistics
- * @net: the applicable net namespace
- * @name: link name
- * @buf: print buffer area
- * @buf_size: size of print buffer area
- *
- * Returns length of print buffer data string (or 0 if error)
- */
-static int tipc_link_stats(struct net *net, const char *name, char *buf,
-			   const u32 buf_size)
-{
-	struct tipc_link *l;
-	struct tipc_stats *s;
-	struct tipc_node *node;
-	char *status;
-	u32 profile_total = 0;
-	unsigned int bearer_id;
-	int ret;
-
-	if (!strcmp(name, tipc_bclink_name))
-		return tipc_bclink_stats(net, buf, buf_size);
-
-	node = tipc_link_find_owner(net, name, &bearer_id);
-	if (!node)
-		return 0;
-
-	tipc_node_lock(node);
-
-	l = node->links[bearer_id];
-	if (!l) {
-		tipc_node_unlock(node);
-		return 0;
-	}
-
-	s = &l->stats;
-
-	if (tipc_link_is_active(l))
-		status = "ACTIVE";
-	else if (tipc_link_is_up(l))
-		status = "STANDBY";
-	else
-		status = "DEFUNCT";
-
-	ret = tipc_snprintf(buf, buf_size, "Link <%s>\n"
-			    "  %s  MTU:%u  Priority:%u  Tolerance:%u ms"
-			    "  Window:%u packets\n",
-			    l->name, status, l->max_pkt, l->priority,
-			    l->tolerance, l->queue_limit[0]);
-
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  RX packets:%u fragments:%u/%u bundles:%u/%u\n",
-			     l->next_in_no - s->recv_info, s->recv_fragments,
-			     s->recv_fragmented, s->recv_bundles,
-			     s->recv_bundled);
-
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  TX packets:%u fragments:%u/%u bundles:%u/%u\n",
-			     l->next_out_no - s->sent_info, s->sent_fragments,
-			     s->sent_fragmented, s->sent_bundles,
-			     s->sent_bundled);
-
-	profile_total = s->msg_length_counts;
-	if (!profile_total)
-		profile_total = 1;
-
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  TX profile sample:%u packets  average:%u octets\n"
-			     "  0-64:%u%% -256:%u%% -1024:%u%% -4096:%u%% "
-			     "-16384:%u%% -32768:%u%% -66000:%u%%\n",
-			     s->msg_length_counts,
-			     s->msg_lengths_total / profile_total,
-			     percent(s->msg_length_profile[0], profile_total),
-			     percent(s->msg_length_profile[1], profile_total),
-			     percent(s->msg_length_profile[2], profile_total),
-			     percent(s->msg_length_profile[3], profile_total),
-			     percent(s->msg_length_profile[4], profile_total),
-			     percent(s->msg_length_profile[5], profile_total),
-			     percent(s->msg_length_profile[6], profile_total));
-
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  RX states:%u probes:%u naks:%u defs:%u"
-			     " dups:%u\n", s->recv_states, s->recv_probes,
-			     s->recv_nacks, s->deferred_recv, s->duplicates);
-
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  TX states:%u probes:%u naks:%u acks:%u"
-			     " dups:%u\n", s->sent_states, s->sent_probes,
-			     s->sent_nacks, s->sent_acks, s->retransmitted);
-
-	ret += tipc_snprintf(buf + ret, buf_size - ret,
-			     "  Congestion link:%u  Send queue"
-			     " max:%u avg:%u\n", s->link_congs,
-			     s->max_queue_sz, s->queue_sz_counts ?
-			     (s->accu_queue_sz / s->queue_sz_counts) : 0);
-
-	tipc_node_unlock(node);
-	return ret;
-}
-
-struct sk_buff *tipc_link_cmd_show_stats(struct net *net,
-					 const void *req_tlv_area,
-					 int req_tlv_space)
-{
-	struct sk_buff *buf;
-	struct tlv_desc *rep_tlv;
-	int str_len;
-	int pb_len;
-	char *pb;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_LINK_NAME))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	buf = tipc_cfg_reply_alloc(TLV_SPACE(ULTRA_STRING_MAX_LEN));
-	if (!buf)
-		return NULL;
-
-	rep_tlv = (struct tlv_desc *)buf->data;
-	pb = TLV_DATA(rep_tlv);
-	pb_len = ULTRA_STRING_MAX_LEN;
-	str_len = tipc_link_stats(net, (char *)TLV_DATA(req_tlv_area),
-				  pb, pb_len);
-	if (!str_len) {
-		kfree_skb(buf);
-		return tipc_cfg_reply_error_string("link not found");
-	}
-	str_len += 1;	/* for "\0" */
-	skb_put(buf, TLV_SPACE(str_len));
-	TLV_SET(rep_tlv, TIPC_TLV_ULTRA_STRING, NULL, str_len);
-
-	return buf;
-}
-
 static void link_print(struct tipc_link *l_ptr, const char *str)
 {
 	struct tipc_net *tn = net_generic(l_ptr->owner->net, tipc_net_id);
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 34d3f55..8c8340c 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -217,9 +217,6 @@ int tipc_link_is_active(struct tipc_link *l_ptr);
 void tipc_link_purge_queues(struct tipc_link *l_ptr);
 struct sk_buff *tipc_link_cmd_config(struct net *net, const void *req_tlv_area,
 				     int req_tlv_space, u16 cmd);
-struct sk_buff *tipc_link_cmd_show_stats(struct net *net,
-					 const void *req_tlv_area,
-					 int req_tlv_space);
 struct sk_buff *tipc_link_cmd_reset_stats(struct net *net,
 					  const void *req_tlv_area,
 					  int req_tlv_space);
diff --git a/net/tipc/netlink_compat.c b/net/tipc/netlink_compat.c
index 12b0f44..899bd94 100644
--- a/net/tipc/netlink_compat.c
+++ b/net/tipc/netlink_compat.c
@@ -34,6 +34,7 @@
 #include "core.h"
 #include "config.h"
 #include "bearer.h"
+#include "link.h"
 #include <net/genetlink.h>
 #include <linux/tipc_config.h>
 
@@ -48,6 +49,7 @@
 
 struct tipc_nl_compat_msg {
 	u16 cmd;
+	int rep_type;
 	int rep_size;
 	int req_type;
 	struct sk_buff *rep;
@@ -95,6 +97,40 @@ static int tipc_add_tlv(struct sk_buff *skb, u16 type, void *data, u16 len)
 	return 0;
 }
 
+static void tipc_tlv_init(struct sk_buff *skb, u16 type)
+{
+	struct tlv_desc *tlv = (struct tlv_desc *)skb->data;
+
+	TLV_SET_LEN(tlv, 0);
+	TLV_SET_TYPE(tlv, type);
+	skb_put(skb, sizeof(struct tlv_desc));
+}
+
+static int tipc_tlv_sprintf(struct sk_buff *skb, const char *fmt, ...)
+{
+	int n;
+	u16 len;
+	u32 rem;
+	char *buf;
+	struct tlv_desc *tlv;
+	va_list args;
+
+	rem = tipc_skb_tailroom(skb);
+
+	tlv = (struct tlv_desc *)skb->data;
+	len = TLV_GET_LEN(tlv);
+	buf = TLV_DATA(tlv) + len;
+
+	va_start(args, fmt);
+	n = vscnprintf(buf, rem, fmt, args);
+	va_end(args);
+
+	TLV_SET_LEN(tlv, n + len);
+	skb_put(skb, n);
+
+	return n;
+}
+
 static struct sk_buff *tipc_tlv_alloc(int size)
 {
 	int hdr_len;
@@ -200,10 +236,16 @@ static int tipc_nl_compat_dumpit(struct tipc_nl_compat_cmd_dump *cmd,
 	int err;
 	struct sk_buff *arg;
 
+	if (msg->req_type && !TLV_CHECK_TYPE(msg->req, msg->req_type))
+		return -EINVAL;
+
 	msg->rep = tipc_tlv_alloc(msg->rep_size);
 	if (!msg->rep)
 		return -ENOMEM;
 
+	if (msg->rep_type)
+		tipc_tlv_init(msg->rep, msg->rep_type);
+
 	arg = nlmsg_new(0, GFP_KERNEL);
 	if (!arg) {
 		kfree_skb(msg->rep);
@@ -356,6 +398,161 @@ static int tipc_nl_compat_bearer_disable(struct sk_buff *skb,
 	return 0;
 }
 
+static inline u32 perc(u32 count, u32 total)
+{
+	return (count * 100 + (total / 2)) / total;
+}
+
+static void __fill_bc_link_stat(struct tipc_nl_compat_msg *msg,
+				struct nlattr *prop[], struct nlattr *stats[])
+{
+	tipc_tlv_sprintf(msg->rep, "  Window:%u packets\n",
+			 nla_get_u32(prop[TIPC_NLA_PROP_WIN]));
+
+	tipc_tlv_sprintf(msg->rep,
+			 "  RX packets:%u fragments:%u/%u bundles:%u/%u\n",
+			 nla_get_u32(stats[TIPC_NLA_STATS_RX_INFO]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_RX_FRAGMENTS]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_RX_FRAGMENTED]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_RX_BUNDLES]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_RX_BUNDLED]));
+
+	tipc_tlv_sprintf(msg->rep,
+			 "  TX packets:%u fragments:%u/%u bundles:%u/%u\n",
+			 nla_get_u32(stats[TIPC_NLA_STATS_TX_INFO]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_TX_FRAGMENTS]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_TX_FRAGMENTED]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_TX_BUNDLES]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_TX_BUNDLED]));
+
+	tipc_tlv_sprintf(msg->rep, "  RX naks:%u defs:%u dups:%u\n",
+			 nla_get_u32(stats[TIPC_NLA_STATS_RX_NACKS]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_RX_DEFERRED]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_DUPLICATES]));
+
+	tipc_tlv_sprintf(msg->rep, "  TX naks:%u acks:%u dups:%u\n",
+			 nla_get_u32(stats[TIPC_NLA_STATS_TX_NACKS]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_TX_ACKS]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_RETRANSMITTED]));
+
+	tipc_tlv_sprintf(msg->rep,
+			 "  Congestion link:%u  Send queue max:%u avg:%u",
+			 nla_get_u32(stats[TIPC_NLA_STATS_LINK_CONGS]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_MAX_QUEUE]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_AVG_QUEUE]));
+}
+
+static int tipc_nl_compat_link_stat_dump(struct tipc_nl_compat_msg *msg,
+					 struct nlattr **attrs)
+{
+	char *name;
+	struct nlattr *link[TIPC_NLA_LINK_MAX + 1];
+	struct nlattr *prop[TIPC_NLA_PROP_MAX + 1];
+	struct nlattr *stats[TIPC_NLA_STATS_MAX + 1];
+
+	nla_parse_nested(link, TIPC_NLA_LINK_MAX, attrs[TIPC_NLA_LINK], NULL);
+
+	nla_parse_nested(prop, TIPC_NLA_PROP_MAX, link[TIPC_NLA_LINK_PROP],
+			 NULL);
+
+	nla_parse_nested(stats, TIPC_NLA_STATS_MAX, link[TIPC_NLA_LINK_STATS],
+			 NULL);
+
+	name = (char *)TLV_DATA(msg->req);
+	if (strcmp(name, nla_data(link[TIPC_NLA_LINK_NAME])) != 0)
+		return 0;
+
+	tipc_tlv_sprintf(msg->rep, "\nLink <%s>\n",
+			 nla_data(link[TIPC_NLA_LINK_NAME]));
+
+	if (link[TIPC_NLA_LINK_BROADCAST]) {
+		__fill_bc_link_stat(msg, prop, stats);
+		return 0;
+	}
+
+	if (link[TIPC_NLA_LINK_ACTIVE])
+		tipc_tlv_sprintf(msg->rep, "  ACTIVE");
+	else if (link[TIPC_NLA_LINK_UP])
+		tipc_tlv_sprintf(msg->rep, "  STANDBY");
+	else
+		tipc_tlv_sprintf(msg->rep, "  DEFUNCT");
+
+	tipc_tlv_sprintf(msg->rep, "  MTU:%u  Priority:%u",
+			 nla_get_u32(link[TIPC_NLA_LINK_MTU]),
+			 nla_get_u32(prop[TIPC_NLA_PROP_PRIO]));
+
+	tipc_tlv_sprintf(msg->rep, "  Tolerance:%u ms  Window:%u packets\n",
+			 nla_get_u32(prop[TIPC_NLA_PROP_TOL]),
+			 nla_get_u32(prop[TIPC_NLA_PROP_WIN]));
+
+	tipc_tlv_sprintf(msg->rep,
+			 "  RX packets:%u fragments:%u/%u bundles:%u/%u\n",
+			 nla_get_u32(link[TIPC_NLA_LINK_RX]) -
+			 nla_get_u32(stats[TIPC_NLA_STATS_RX_INFO]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_RX_FRAGMENTS]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_RX_FRAGMENTED]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_RX_BUNDLES]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_RX_BUNDLED]));
+
+	tipc_tlv_sprintf(msg->rep,
+			 "  TX packets:%u fragments:%u/%u bundles:%u/%u\n",
+			 nla_get_u32(link[TIPC_NLA_LINK_TX]) -
+			 nla_get_u32(stats[TIPC_NLA_STATS_TX_INFO]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_TX_FRAGMENTS]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_TX_FRAGMENTED]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_TX_BUNDLES]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_TX_BUNDLED]));
+
+	tipc_tlv_sprintf(msg->rep,
+			 "  TX profile sample:%u packets  average:%u octets\n",
+			 nla_get_u32(stats[TIPC_NLA_STATS_MSG_LEN_CNT]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_MSG_LEN_TOT]) /
+			 nla_get_u32(stats[TIPC_NLA_STATS_MSG_PROF_TOT]));
+
+	tipc_tlv_sprintf(msg->rep,
+			 "  0-64:%u%% -256:%u%% -1024:%u%% -4096:%u%% ",
+			 perc(nla_get_u32(stats[TIPC_NLA_STATS_MSG_LEN_P0]),
+			      nla_get_u32(stats[TIPC_NLA_STATS_MSG_PROF_TOT])),
+			 perc(nla_get_u32(stats[TIPC_NLA_STATS_MSG_LEN_P1]),
+			      nla_get_u32(stats[TIPC_NLA_STATS_MSG_PROF_TOT])),
+			 perc(nla_get_u32(stats[TIPC_NLA_STATS_MSG_LEN_P2]),
+			      nla_get_u32(stats[TIPC_NLA_STATS_MSG_PROF_TOT])),
+			 perc(nla_get_u32(stats[TIPC_NLA_STATS_MSG_LEN_P3]),
+			      nla_get_u32(stats[TIPC_NLA_STATS_MSG_PROF_TOT])));
+
+	tipc_tlv_sprintf(msg->rep, "-16384:%u%% -32768:%u%% -66000:%u%%\n",
+			 perc(nla_get_u32(stats[TIPC_NLA_STATS_MSG_LEN_P4]),
+			      nla_get_u32(stats[TIPC_NLA_STATS_MSG_PROF_TOT])),
+			 perc(nla_get_u32(stats[TIPC_NLA_STATS_MSG_LEN_P5]),
+			      nla_get_u32(stats[TIPC_NLA_STATS_MSG_PROF_TOT])),
+			 perc(nla_get_u32(stats[TIPC_NLA_STATS_MSG_LEN_P6]),
+			      nla_get_u32(stats[TIPC_NLA_STATS_MSG_PROF_TOT])));
+
+	tipc_tlv_sprintf(msg->rep,
+			 "  RX states:%u probes:%u naks:%u defs:%u dups:%u\n",
+			 nla_get_u32(stats[TIPC_NLA_STATS_RX_STATES]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_RX_PROBES]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_RX_NACKS]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_RX_DEFERRED]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_DUPLICATES]));
+
+	tipc_tlv_sprintf(msg->rep,
+			 "  TX states:%u probes:%u naks:%u acks:%u dups:%u\n",
+			 nla_get_u32(stats[TIPC_NLA_STATS_TX_STATES]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_TX_PROBES]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_TX_NACKS]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_TX_ACKS]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_RETRANSMITTED]));
+
+	tipc_tlv_sprintf(msg->rep,
+			 "  Congestion link:%u  Send queue max:%u avg:%u",
+			 nla_get_u32(stats[TIPC_NLA_STATS_LINK_CONGS]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_MAX_QUEUE]),
+			 nla_get_u32(stats[TIPC_NLA_STATS_AVG_QUEUE]));
+
+	return 0;
+}
+
 static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 {
 	struct tipc_nl_compat_cmd_dump dump;
@@ -380,6 +577,13 @@ static int tipc_nl_compat_handle(struct tipc_nl_compat_msg *msg)
 		doit.doit = tipc_nl_bearer_disable;
 		doit.transcode = tipc_nl_compat_bearer_disable;
 		return tipc_nl_compat_doit(&doit, msg);
+	case TIPC_CMD_SHOW_LINK_STATS:
+		msg->req_type = TIPC_TLV_LINK_NAME;
+		msg->rep_size = ULTRA_STRING_MAX_LEN;
+		msg->rep_type = TIPC_TLV_ULTRA_STRING;
+		dump.dumpit = tipc_nl_link_dump;
+		dump.format = tipc_nl_compat_link_stat_dump;
+		return tipc_nl_compat_dumpit(&dump, msg);
 	}
 
 	return -EOPNOTSUPP;
@@ -479,6 +683,7 @@ static int tipc_nl_compat_tmp_wrap(struct sk_buff *skb, struct genl_info *info)
 	case TIPC_CMD_GET_BEARER_NAMES:
 	case TIPC_CMD_ENABLE_BEARER:
 	case TIPC_CMD_DISABLE_BEARER:
+	case TIPC_CMD_SHOW_LINK_STATS:
 		return tipc_nl_compat_recv(skb, info);
 	}
 
-- 
2.1.4
