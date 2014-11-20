From: <richard.alpe@ericsson.com>
Subject: [PATCH v3 net-next 06/14] tipc: add link get/dump
	to new netlink api
Date: Thu, 20 Nov 2014 10:29:12 +0100
Message-ID: <1416475760-18914-7-git-send-email-richard.alpe@ericsson.com>
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

Add TIPC_NL_LINK_GET command to the new tipc netlink API.

This command supports dumping all information about all links
(including the broadcast link) or getting all information about a
specific link (not the broadcast link).

The information about a link includes name, transmission info,
properties and link statistics.

As the tipc broadcast link is special we unfortunately have to treat
it specially. It is a deliberate decision not to abstract the
broadcast link on this (API) level.

Netlink logical layout of link response message:
    -> port
        -> name
        -> MTU
        -> RX
        -> TX
        -> up flag
        -> active flag
        -> properties
           -> priority
           -> tolerance
           -> window
        -> statistics
            -> rx_info
            -> rx_fragments
            -> rx_fragmented
            -> rx_bundles
            -> rx_bundled
            -> tx_info
            -> tx_fragments
            -> tx_fragmented
            -> tx_bundles
            -> tx_bundled
            -> msg_prof_tot
            -> msg_len_cnt
            -> msg_len_tot
            -> msg_len_p0
            -> msg_len_p1
            -> msg_len_p2
            -> msg_len_p3
            -> msg_len_p4
            -> msg_len_p5
            -> msg_len_p6
            -> rx_states
            -> rx_probes
            -> rx_nacks
            -> rx_deferred
            -> tx_states
            -> tx_probes
            -> tx_nacks
            -> tx_acks
            -> retransmitted
            -> duplicates
            -> link_congs
            -> max_queue
            -> avg_queue

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 include/uapi/linux/tipc_netlink.h |   62 ++++++++
 net/tipc/bcast.c                  |  111 ++++++++++++++
 net/tipc/bcast.h                  |    4 +
 net/tipc/link.c                   |  287 +++++++++++++++++++++++++++++++++++++
 net/tipc/link.h                   |    2 +
 net/tipc/netlink.c                |   10 +-
 6 files changed, 475 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/tipc_netlink.h b/include/uapi/linux/tipc_netlink.h
index 7e51ff6..1034fb4 100644
--- a/include/uapi/linux/tipc_netlink.h
+++ b/include/uapi/linux/tipc_netlink.h
@@ -47,6 +47,7 @@ enum {
 	TIPC_NL_BEARER_SET,
 	TIPC_NL_SOCK_GET,
 	TIPC_NL_PUBL_GET,
+	TIPC_NL_LINK_GET,
 
 	__TIPC_NL_CMD_MAX,
 	TIPC_NL_CMD_MAX = __TIPC_NL_CMD_MAX - 1
@@ -58,6 +59,7 @@ enum {
 	TIPC_NLA_BEARER,		/* nest */
 	TIPC_NLA_SOCK,			/* nest */
 	TIPC_NLA_PUBL,			/* nest */
+	TIPC_NLA_LINK,			/* nest */
 
 	__TIPC_NLA_MAX,
 	TIPC_NLA_MAX = __TIPC_NLA_MAX - 1
@@ -86,6 +88,24 @@ enum {
 	TIPC_NLA_SOCK_MAX = __TIPC_NLA_SOCK_MAX - 1
 };
 
+/* Link info */
+enum {
+	TIPC_NLA_LINK_UNSPEC,
+	TIPC_NLA_LINK_NAME,		/* string */
+	TIPC_NLA_LINK_DEST,		/* u32 */
+	TIPC_NLA_LINK_MTU,		/* u32 */
+	TIPC_NLA_LINK_BROADCAST,	/* flag */
+	TIPC_NLA_LINK_UP,		/* flag */
+	TIPC_NLA_LINK_ACTIVE,		/* flag */
+	TIPC_NLA_LINK_PROP,		/* nest */
+	TIPC_NLA_LINK_STATS,		/* nest */
+	TIPC_NLA_LINK_RX,		/* u32 */
+	TIPC_NLA_LINK_TX,		/* u32 */
+
+	__TIPC_NLA_LINK_MAX,
+	TIPC_NLA_LINK_MAX = __TIPC_NLA_LINK_MAX - 1
+};
+
 /* Publication info */
 enum {
 	TIPC_NLA_PUBL_UNSPEC,
@@ -128,4 +148,46 @@ enum {
 	TIPC_NLA_PROP_MAX = __TIPC_NLA_PROP_MAX - 1
 };
 
+/* Nest, statistics info */
+enum {
+	TIPC_NLA_STATS_UNSPEC,
+
+	TIPC_NLA_STATS_RX_INFO,		/* u32 */
+	TIPC_NLA_STATS_RX_FRAGMENTS,	/* u32 */
+	TIPC_NLA_STATS_RX_FRAGMENTED,	/* u32 */
+	TIPC_NLA_STATS_RX_BUNDLES,	/* u32 */
+	TIPC_NLA_STATS_RX_BUNDLED,	/* u32 */
+	TIPC_NLA_STATS_TX_INFO,		/* u32 */
+	TIPC_NLA_STATS_TX_FRAGMENTS,	/* u32 */
+	TIPC_NLA_STATS_TX_FRAGMENTED,	/* u32 */
+	TIPC_NLA_STATS_TX_BUNDLES,	/* u32 */
+	TIPC_NLA_STATS_TX_BUNDLED,	/* u32 */
+	TIPC_NLA_STATS_MSG_PROF_TOT,	/* u32 */
+	TIPC_NLA_STATS_MSG_LEN_CNT,	/* u32 */
+	TIPC_NLA_STATS_MSG_LEN_TOT,	/* u32 */
+	TIPC_NLA_STATS_MSG_LEN_P0,	/* u32 */
+	TIPC_NLA_STATS_MSG_LEN_P1,	/* u32 */
+	TIPC_NLA_STATS_MSG_LEN_P2,	/* u32 */
+	TIPC_NLA_STATS_MSG_LEN_P3,	/* u32 */
+	TIPC_NLA_STATS_MSG_LEN_P4,	/* u32 */
+	TIPC_NLA_STATS_MSG_LEN_P5,	/* u32 */
+	TIPC_NLA_STATS_MSG_LEN_P6,	/* u32 */
+	TIPC_NLA_STATS_RX_STATES,	/* u32 */
+	TIPC_NLA_STATS_RX_PROBES,	/* u32 */
+	TIPC_NLA_STATS_RX_NACKS,	/* u32 */
+	TIPC_NLA_STATS_RX_DEFERRED,	/* u32 */
+	TIPC_NLA_STATS_TX_STATES,	/* u32 */
+	TIPC_NLA_STATS_TX_PROBES,	/* u32 */
+	TIPC_NLA_STATS_TX_NACKS,	/* u32 */
+	TIPC_NLA_STATS_TX_ACKS,		/* u32 */
+	TIPC_NLA_STATS_RETRANSMITTED,	/* u32 */
+	TIPC_NLA_STATS_DUPLICATES,	/* u32 */
+	TIPC_NLA_STATS_LINK_CONGS,	/* u32 */
+	TIPC_NLA_STATS_MAX_QUEUE,	/* u32 */
+	TIPC_NLA_STATS_AVG_QUEUE,	/* u32 */
+
+	__TIPC_NLA_STATS_MAX,
+	TIPC_NLA_STATS_MAX = __TIPC_NLA_STATS_MAX - 1
+};
+
 #endif
diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index b8670bf..dcf3589 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -767,6 +767,117 @@ void tipc_bcbearer_sort(struct tipc_node_map *nm_ptr, u32 node, bool action)
 	tipc_bclink_unlock();
 }
 
+int __tipc_nl_add_bc_link_stat(struct sk_buff *skb, struct tipc_stats *stats)
+{
+	int i;
+	struct nlattr *nest;
+
+	struct nla_map {
+		__u32 key;
+		__u32 val;
+	};
+
+	struct nla_map map[] = {
+		{TIPC_NLA_STATS_RX_INFO, stats->recv_info},
+		{TIPC_NLA_STATS_RX_FRAGMENTS, stats->recv_fragments},
+		{TIPC_NLA_STATS_RX_FRAGMENTED, stats->recv_fragmented},
+		{TIPC_NLA_STATS_RX_BUNDLES, stats->recv_bundles},
+		{TIPC_NLA_STATS_RX_BUNDLED, stats->recv_bundled},
+		{TIPC_NLA_STATS_TX_INFO, stats->sent_info},
+		{TIPC_NLA_STATS_TX_FRAGMENTS, stats->sent_fragments},
+		{TIPC_NLA_STATS_TX_FRAGMENTED, stats->sent_fragmented},
+		{TIPC_NLA_STATS_TX_BUNDLES, stats->sent_bundles},
+		{TIPC_NLA_STATS_TX_BUNDLED, stats->sent_bundled},
+		{TIPC_NLA_STATS_RX_NACKS, stats->recv_nacks},
+		{TIPC_NLA_STATS_RX_DEFERRED, stats->deferred_recv},
+		{TIPC_NLA_STATS_TX_NACKS, stats->sent_nacks},
+		{TIPC_NLA_STATS_TX_ACKS, stats->sent_acks},
+		{TIPC_NLA_STATS_RETRANSMITTED, stats->retransmitted},
+		{TIPC_NLA_STATS_DUPLICATES, stats->duplicates},
+		{TIPC_NLA_STATS_LINK_CONGS, stats->link_congs},
+		{TIPC_NLA_STATS_MAX_QUEUE, stats->max_queue_sz},
+		{TIPC_NLA_STATS_AVG_QUEUE, stats->queue_sz_counts ?
+			(stats->accu_queue_sz / stats->queue_sz_counts) : 0}
+	};
+
+	nest = nla_nest_start(skb, TIPC_NLA_LINK_STATS);
+	if (!nest)
+		return -EMSGSIZE;
+
+	for (i = 0; i <  ARRAY_SIZE(map); i++)
+		if (nla_put_u32(skb, map[i].key, map[i].val))
+			goto msg_full;
+
+	nla_nest_end(skb, nest);
+
+	return 0;
+msg_full:
+	nla_nest_cancel(skb, nest);
+
+	return -EMSGSIZE;
+}
+
+int tipc_nl_add_bc_link(struct tipc_nl_msg *msg)
+{
+	int err;
+	void *hdr;
+	struct nlattr *attrs;
+	struct nlattr *prop;
+
+	if (!bcl)
+		return 0;
+
+	tipc_bclink_lock();
+
+	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_v2_family,
+			  NLM_F_MULTI, TIPC_NL_LINK_GET);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	attrs = nla_nest_start(msg->skb, TIPC_NLA_LINK);
+	if (!attrs)
+		goto msg_full;
+
+	/* The broadcast link is always up */
+	if (nla_put_flag(msg->skb, TIPC_NLA_LINK_UP))
+		goto attr_msg_full;
+
+	if (nla_put_flag(msg->skb, TIPC_NLA_LINK_BROADCAST))
+		goto attr_msg_full;
+	if (nla_put_string(msg->skb, TIPC_NLA_LINK_NAME, bcl->name))
+		goto attr_msg_full;
+	if (nla_put_u32(msg->skb, TIPC_NLA_LINK_RX, bcl->next_in_no))
+		goto attr_msg_full;
+	if (nla_put_u32(msg->skb, TIPC_NLA_LINK_TX, bcl->next_out_no))
+		goto attr_msg_full;
+
+	prop = nla_nest_start(msg->skb, TIPC_NLA_LINK_PROP);
+	if (!prop)
+		goto attr_msg_full;
+	if (nla_put_u32(msg->skb, TIPC_NLA_PROP_WIN, bcl->queue_limit[0]))
+		goto prop_msg_full;
+	nla_nest_end(msg->skb, prop);
+
+	err = __tipc_nl_add_bc_link_stat(msg->skb, &bcl->stats);
+	if (err)
+		goto attr_msg_full;
+
+	tipc_bclink_unlock();
+	nla_nest_end(msg->skb, attrs);
+	genlmsg_end(msg->skb, hdr);
+
+	return 0;
+
+prop_msg_full:
+	nla_nest_cancel(msg->skb, prop);
+attr_msg_full:
+	nla_nest_cancel(msg->skb, attrs);
+msg_full:
+	tipc_bclink_unlock();
+	genlmsg_cancel(msg->skb, hdr);
+
+	return -EMSGSIZE;
+}
 
 int tipc_bclink_stats(char *buf, const u32 buf_size)
 {
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index e7b0f85..443de08 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -37,6 +37,8 @@
 #ifndef _TIPC_BCAST_H
 #define _TIPC_BCAST_H
 
+#include "netlink.h"
+
 #define MAX_NODES 4096
 #define WSIZE 32
 #define TIPC_BCLINK_RESET 1
@@ -100,4 +102,6 @@ void tipc_bcbearer_sort(struct tipc_node_map *nm_ptr, u32 node, bool action);
 uint  tipc_bclink_get_mtu(void);
 int tipc_bclink_xmit(struct sk_buff *buf);
 void tipc_bclink_wakeup_users(void);
+int tipc_nl_add_bc_link(struct tipc_nl_msg *msg);
+
 #endif
diff --git a/net/tipc/link.c b/net/tipc/link.c
index e7f3650..bdc4b5e 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -36,6 +36,7 @@
 
 #include "core.h"
 #include "link.h"
+#include "bcast.h"
 #include "socket.h"
 #include "name_distr.h"
 #include "discover.h"
@@ -51,6 +52,22 @@ static const char *link_co_err = "Link changeover error, ";
 static const char *link_rst_msg = "Resetting link ";
 static const char *link_unk_evt = "Unknown link event ";
 
+static const struct nla_policy tipc_nl_link_policy[TIPC_NLA_LINK_MAX + 1] = {
+	[TIPC_NLA_LINK_UNSPEC]		= { .type = NLA_UNSPEC },
+	[TIPC_NLA_LINK_NAME] = {
+		.type = NLA_STRING,
+		.len = TIPC_MAX_LINK_NAME
+	},
+	[TIPC_NLA_LINK_MTU]		= { .type = NLA_U32 },
+	[TIPC_NLA_LINK_BROADCAST]	= { .type = NLA_FLAG },
+	[TIPC_NLA_LINK_UP]		= { .type = NLA_FLAG },
+	[TIPC_NLA_LINK_ACTIVE]		= { .type = NLA_FLAG },
+	[TIPC_NLA_LINK_PROP]		= { .type = NLA_NESTED },
+	[TIPC_NLA_LINK_STATS]		= { .type = NLA_NESTED },
+	[TIPC_NLA_LINK_RX]		= { .type = NLA_U32 },
+	[TIPC_NLA_LINK_TX]		= { .type = NLA_U32 }
+};
+
 /* Properties valid for media, bearar and link */
 static const struct nla_policy tipc_nl_prop_policy[TIPC_NLA_PROP_MAX + 1] = {
 	[TIPC_NLA_PROP_UNSPEC]		= { .type = NLA_UNSPEC },
@@ -2423,3 +2440,273 @@ int tipc_nl_parse_link_prop(struct nlattr *prop, struct nlattr *props[])
 
 	return 0;
 }
+
+int __tipc_nl_add_stats(struct sk_buff *skb, struct tipc_stats *s)
+{
+	int i;
+	struct nlattr *stats;
+
+	struct nla_map {
+		u32 key;
+		u32 val;
+	};
+
+	struct nla_map map[] = {
+		{TIPC_NLA_STATS_RX_INFO, s->recv_info},
+		{TIPC_NLA_STATS_RX_FRAGMENTS, s->recv_fragments},
+		{TIPC_NLA_STATS_RX_FRAGMENTED, s->recv_fragmented},
+		{TIPC_NLA_STATS_RX_BUNDLES, s->recv_bundles},
+		{TIPC_NLA_STATS_RX_BUNDLED, s->recv_bundled},
+		{TIPC_NLA_STATS_TX_INFO, s->sent_info},
+		{TIPC_NLA_STATS_TX_FRAGMENTS, s->sent_fragments},
+		{TIPC_NLA_STATS_TX_FRAGMENTED, s->sent_fragmented},
+		{TIPC_NLA_STATS_TX_BUNDLES, s->sent_bundles},
+		{TIPC_NLA_STATS_TX_BUNDLED, s->sent_bundled},
+		{TIPC_NLA_STATS_MSG_PROF_TOT, (s->msg_length_counts) ?
+			s->msg_length_counts : 1},
+		{TIPC_NLA_STATS_MSG_LEN_CNT, s->msg_length_counts},
+		{TIPC_NLA_STATS_MSG_LEN_TOT, s->msg_lengths_total},
+		{TIPC_NLA_STATS_MSG_LEN_P0, s->msg_length_profile[0]},
+		{TIPC_NLA_STATS_MSG_LEN_P1, s->msg_length_profile[1]},
+		{TIPC_NLA_STATS_MSG_LEN_P2, s->msg_length_profile[2]},
+		{TIPC_NLA_STATS_MSG_LEN_P3, s->msg_length_profile[3]},
+		{TIPC_NLA_STATS_MSG_LEN_P4, s->msg_length_profile[4]},
+		{TIPC_NLA_STATS_MSG_LEN_P5, s->msg_length_profile[5]},
+		{TIPC_NLA_STATS_MSG_LEN_P6, s->msg_length_profile[6]},
+		{TIPC_NLA_STATS_RX_STATES, s->recv_states},
+		{TIPC_NLA_STATS_RX_PROBES, s->recv_probes},
+		{TIPC_NLA_STATS_RX_NACKS, s->recv_nacks},
+		{TIPC_NLA_STATS_RX_DEFERRED, s->deferred_recv},
+		{TIPC_NLA_STATS_TX_STATES, s->sent_states},
+		{TIPC_NLA_STATS_TX_PROBES, s->sent_probes},
+		{TIPC_NLA_STATS_TX_NACKS, s->sent_nacks},
+		{TIPC_NLA_STATS_TX_ACKS, s->sent_acks},
+		{TIPC_NLA_STATS_RETRANSMITTED, s->retransmitted},
+		{TIPC_NLA_STATS_DUPLICATES, s->duplicates},
+		{TIPC_NLA_STATS_LINK_CONGS, s->link_congs},
+		{TIPC_NLA_STATS_MAX_QUEUE, s->max_queue_sz},
+		{TIPC_NLA_STATS_AVG_QUEUE, s->queue_sz_counts ?
+			(s->accu_queue_sz / s->queue_sz_counts) : 0}
+	};
+
+	stats = nla_nest_start(skb, TIPC_NLA_LINK_STATS);
+	if (!stats)
+		return -EMSGSIZE;
+
+	for (i = 0; i <  ARRAY_SIZE(map); i++)
+		if (nla_put_u32(skb, map[i].key, map[i].val))
+			goto msg_full;
+
+	nla_nest_end(skb, stats);
+
+	return 0;
+msg_full:
+	nla_nest_cancel(skb, stats);
+
+	return -EMSGSIZE;
+}
+
+/* Caller should hold appropriate locks to protect the link */
+int __tipc_nl_add_link(struct tipc_nl_msg *msg, struct tipc_link *link)
+{
+	int err;
+	void *hdr;
+	struct nlattr *attrs;
+	struct nlattr *prop;
+
+	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_v2_family,
+			  NLM_F_MULTI, TIPC_NL_LINK_GET);
+	if (!hdr)
+		return -EMSGSIZE;
+
+	attrs = nla_nest_start(msg->skb, TIPC_NLA_LINK);
+	if (!attrs)
+		goto msg_full;
+
+	if (nla_put_string(msg->skb, TIPC_NLA_LINK_NAME, link->name))
+		goto attr_msg_full;
+	if (nla_put_u32(msg->skb, TIPC_NLA_LINK_DEST,
+			tipc_cluster_mask(tipc_own_addr)))
+		goto attr_msg_full;
+	if (nla_put_u32(msg->skb, TIPC_NLA_LINK_MTU, link->max_pkt))
+		goto attr_msg_full;
+	if (nla_put_u32(msg->skb, TIPC_NLA_LINK_RX, link->next_in_no))
+		goto attr_msg_full;
+	if (nla_put_u32(msg->skb, TIPC_NLA_LINK_TX, link->next_out_no))
+		goto attr_msg_full;
+
+	if (tipc_link_is_up(link))
+		if (nla_put_flag(msg->skb, TIPC_NLA_LINK_UP))
+			goto attr_msg_full;
+	if (tipc_link_is_active(link))
+		if (nla_put_flag(msg->skb, TIPC_NLA_LINK_ACTIVE))
+			goto attr_msg_full;
+
+	prop = nla_nest_start(msg->skb, TIPC_NLA_LINK_PROP);
+	if (!prop)
+		goto attr_msg_full;
+	if (nla_put_u32(msg->skb, TIPC_NLA_PROP_PRIO, link->priority))
+		goto prop_msg_full;
+	if (nla_put_u32(msg->skb, TIPC_NLA_PROP_TOL, link->tolerance))
+		goto prop_msg_full;
+	if (nla_put_u32(msg->skb, TIPC_NLA_PROP_WIN,
+			link->queue_limit[TIPC_LOW_IMPORTANCE]))
+		goto prop_msg_full;
+	if (nla_put_u32(msg->skb, TIPC_NLA_PROP_PRIO, link->priority))
+		goto prop_msg_full;
+	nla_nest_end(msg->skb, prop);
+
+	err = __tipc_nl_add_stats(msg->skb, &link->stats);
+	if (err)
+		goto attr_msg_full;
+
+	nla_nest_end(msg->skb, attrs);
+	genlmsg_end(msg->skb, hdr);
+
+	return 0;
+
+prop_msg_full:
+	nla_nest_cancel(msg->skb, prop);
+attr_msg_full:
+	nla_nest_cancel(msg->skb, attrs);
+msg_full:
+	genlmsg_cancel(msg->skb, hdr);
+
+	return -EMSGSIZE;
+}
+
+/* Caller should hold node lock  */
+int __tipc_nl_add_node_links(struct tipc_nl_msg *msg, struct tipc_node *node,
+			     u32 *prev_link)
+{
+	u32 i;
+	int err;
+
+	for (i = *prev_link; i < MAX_BEARERS; i++) {
+		*prev_link = i;
+
+		if (!node->links[i])
+			continue;
+
+		err = __tipc_nl_add_link(msg, node->links[i]);
+		if (err)
+			return err;
+	}
+	*prev_link = 0;
+
+	return 0;
+}
+
+int tipc_nl_link_dump(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	struct tipc_node *node;
+	struct tipc_nl_msg msg;
+	u32 prev_node = cb->args[0];
+	u32 prev_link = cb->args[1];
+	int done = cb->args[2];
+	int err;
+
+	if (done)
+		return 0;
+
+	msg.skb = skb;
+	msg.portid = NETLINK_CB(cb->skb).portid;
+	msg.seq = cb->nlh->nlmsg_seq;
+
+	rcu_read_lock();
+
+	if (prev_node) {
+		node = tipc_node_find(prev_node);
+		if (!node) {
+			/* We never set seq or call nl_dump_check_consistent()
+			 * this means that setting prev_seq here will cause the
+			 * consistence check to fail in the netlink callback
+			 * handler. Resulting in the last NLMSG_DONE message
+			 * having the NLM_F_DUMP_INTR flag set.
+			 */
+			cb->prev_seq = 1;
+			goto out;
+		}
+
+		list_for_each_entry_continue_rcu(node, &tipc_node_list, list) {
+			tipc_node_lock(node);
+			err = __tipc_nl_add_node_links(&msg, node, &prev_link);
+			tipc_node_unlock(node);
+			if (err)
+				goto out;
+
+			prev_node = node->addr;
+		}
+	} else {
+		err = tipc_nl_add_bc_link(&msg);
+		if (err)
+			goto out;
+
+		list_for_each_entry_rcu(node, &tipc_node_list, list) {
+			tipc_node_lock(node);
+			err = __tipc_nl_add_node_links(&msg, node, &prev_link);
+			tipc_node_unlock(node);
+			if (err)
+				goto out;
+
+			prev_node = node->addr;
+		}
+	}
+	done = 1;
+out:
+	rcu_read_unlock();
+
+	cb->args[0] = prev_node;
+	cb->args[1] = prev_link;
+	cb->args[2] = done;
+
+	return skb->len;
+}
+
+int tipc_nl_link_get(struct sk_buff *skb, struct genl_info *info)
+{
+	struct sk_buff *ans_skb;
+	struct tipc_nl_msg msg;
+	struct tipc_link *link;
+	struct tipc_node *node;
+	char *name;
+	int bearer_id;
+	int err;
+
+	if (!info->attrs[TIPC_NLA_LINK_NAME])
+		return -EINVAL;
+
+	name = nla_data(info->attrs[TIPC_NLA_LINK_NAME]);
+	node = tipc_link_find_owner(name, &bearer_id);
+	if (!node)
+		return -EINVAL;
+
+	ans_skb = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!ans_skb)
+		return -ENOMEM;
+
+	msg.skb = ans_skb;
+	msg.portid = info->snd_portid;
+	msg.seq = info->snd_seq;
+
+	tipc_node_lock(node);
+	link = node->links[bearer_id];
+	if (!link) {
+		err = -EINVAL;
+		goto err_out;
+	}
+
+	err = __tipc_nl_add_link(&msg, link);
+	if (err)
+		goto err_out;
+
+	tipc_node_unlock(node);
+
+	return genlmsg_reply(ans_skb, info);
+
+err_out:
+	tipc_node_unlock(node);
+	nlmsg_free(ans_skb);
+
+	return err;
+}
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 4338294..8e3542a 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -240,6 +240,8 @@ void tipc_link_set_queue_limits(struct tipc_link *l_ptr, u32 window);
 void tipc_link_retransmit(struct tipc_link *l_ptr,
 			  struct sk_buff *start, u32 retransmits);
 
+int tipc_nl_link_dump(struct sk_buff *skb, struct netlink_callback *cb);
+int tipc_nl_link_get(struct sk_buff *skb, struct genl_info *info);
 int tipc_nl_parse_link_prop(struct nlattr *prop, struct nlattr *props[]);
 
 /*
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index 9bc64aa..ea168b8 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -38,6 +38,7 @@
 #include "config.h"
 #include "socket.h"
 #include "bearer.h"
+#include "link.h"
 #include <net/genetlink.h>
 
 static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
@@ -74,7 +75,8 @@ static const struct nla_policy tipc_nl_policy[TIPC_NLA_MAX + 1] = {
 	[TIPC_NLA_UNSPEC]	= { .type = NLA_UNSPEC, },
 	[TIPC_NLA_BEARER]	= { .type = NLA_NESTED, },
 	[TIPC_NLA_SOCK]		= { .type = NLA_NESTED, },
-	[TIPC_NLA_PUBL]		= { .type = NLA_NESTED, }
+	[TIPC_NLA_PUBL]		= { .type = NLA_NESTED, },
+	[TIPC_NLA_LINK]		= { .type = NLA_NESTED, },
 };
 
 /* Legacy ASCII API */
@@ -136,6 +138,12 @@ static const struct genl_ops tipc_genl_v2_ops[] = {
 		.cmd	= TIPC_NL_PUBL_GET,
 		.dumpit	= tipc_nl_publ_dump,
 		.policy = tipc_nl_policy,
+	},
+	{
+		.cmd	= TIPC_NL_LINK_GET,
+		.doit   = tipc_nl_link_get,
+		.dumpit	= tipc_nl_link_dump,
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
