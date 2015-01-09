From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 13/16] tipc: make tipc node address support net namespace
Date: Fri, 9 Jan 2015 15:27:10 +0800
Message-ID: <1420788433-17960-14-git-send-email-ying.xue@windriver.com>
References: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jon.maloy@ericsson.com>, <Tero.Aho@coriant.com>,
	<Paul.Gortmaker@windriver.com>, <erik.hugne@ericsson.com>,
	<richard.alpe@ericsson.com>, <netdev@vger.kernel.org>,
	<tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:60331 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755972AbbAIH2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 02:28:19 -0500
In-Reply-To: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If net namespace is supported in tipc, each namespace will be treated
as a separate tipc node. Therefore, every namespace must own its
private tipc node address. This means the "tipc_own_addr" global
variable of node address must be moved to tipc_net structure to
satisfy the requirement. It's turned out that users also can assign
node address for every namespace.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Tested-by: Tero Aho <Tero.Aho@coriant.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/addr.c       |   43 +++++++++++++++++++++++++
 net/tipc/addr.h       |   44 ++++---------------------
 net/tipc/bcast.c      |    6 ++--
 net/tipc/bearer.c     |   13 ++++----
 net/tipc/config.c     |    9 +++---
 net/tipc/core.c       |    4 +--
 net/tipc/core.h       |    5 +--
 net/tipc/discover.c   |    8 ++---
 net/tipc/link.c       |   56 +++++++++++++++++++-------------
 net/tipc/msg.c        |   40 ++++++++++++-----------
 net/tipc/msg.h        |   21 ++++++------
 net/tipc/name_distr.c |   21 ++++++------
 net/tipc/name_distr.h |    2 +-
 net/tipc/name_table.c |   39 ++++++++++++----------
 net/tipc/net.c        |   20 ++++++------
 net/tipc/node.c       |   23 +++++++------
 net/tipc/socket.c     |   86 +++++++++++++++++++++++++++++--------------------
 17 files changed, 246 insertions(+), 194 deletions(-)

diff --git a/net/tipc/addr.c b/net/tipc/addr.c
index 9e6eeb4..48fd3b5 100644
--- a/net/tipc/addr.c
+++ b/net/tipc/addr.c
@@ -36,6 +36,49 @@
 
 #include <linux/kernel.h>
 #include "addr.h"
+#include "core.h"
+
+/**
+ * in_own_cluster - test for cluster inclusion; <0.0.0> always matches
+ */
+int in_own_cluster(struct net *net, u32 addr)
+{
+	return in_own_cluster_exact(net, addr) || !addr;
+}
+
+int in_own_cluster_exact(struct net *net, u32 addr)
+{
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+
+	return !((addr ^ tn->own_addr) >> 12);
+}
+
+/**
+ * in_own_node - test for node inclusion; <0.0.0> always matches
+ */
+int in_own_node(struct net *net, u32 addr)
+{
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+
+	return (addr == tn->own_addr) || !addr;
+}
+
+/**
+ * addr_domain - convert 2-bit scope value to equivalent message lookup domain
+ *
+ * Needed when address of a named message must be looked up a second time
+ * after a network hop.
+ */
+u32 addr_domain(struct net *net, u32 sc)
+{
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+
+	if (likely(sc == TIPC_NODE_SCOPE))
+		return tn->own_addr;
+	if (sc == TIPC_CLUSTER_SCOPE)
+		return tipc_cluster_mask(tn->own_addr);
+	return tipc_zone_mask(tn->own_addr);
+}
 
 /**
  * tipc_addr_domain_valid - validates a network domain address
diff --git a/net/tipc/addr.h b/net/tipc/addr.h
index 4e364c4..c700c2d 100644
--- a/net/tipc/addr.h
+++ b/net/tipc/addr.h
@@ -39,12 +39,12 @@
 
 #include <linux/types.h>
 #include <linux/tipc.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
 
 #define TIPC_ZONE_MASK		0xff000000u
 #define TIPC_CLUSTER_MASK	0xfffff000u
 
-extern u32 tipc_own_addr __read_mostly;
-
 static inline u32 tipc_zone_mask(u32 addr)
 {
 	return addr & TIPC_ZONE_MASK;
@@ -55,42 +55,10 @@ static inline u32 tipc_cluster_mask(u32 addr)
 	return addr & TIPC_CLUSTER_MASK;
 }
 
-static inline int in_own_cluster_exact(u32 addr)
-{
-	return !((addr ^ tipc_own_addr) >> 12);
-}
-
-/**
- * in_own_node - test for node inclusion; <0.0.0> always matches
- */
-static inline int in_own_node(u32 addr)
-{
-	return (addr == tipc_own_addr) || !addr;
-}
-
-/**
- * in_own_cluster - test for cluster inclusion; <0.0.0> always matches
- */
-static inline int in_own_cluster(u32 addr)
-{
-	return in_own_cluster_exact(addr) || !addr;
-}
-
-/**
- * addr_domain - convert 2-bit scope value to equivalent message lookup domain
- *
- * Needed when address of a named message must be looked up a second time
- * after a network hop.
- */
-static inline u32 addr_domain(u32 sc)
-{
-	if (likely(sc == TIPC_NODE_SCOPE))
-		return tipc_own_addr;
-	if (sc == TIPC_CLUSTER_SCOPE)
-		return tipc_cluster_mask(tipc_own_addr);
-	return tipc_zone_mask(tipc_own_addr);
-}
-
+int in_own_cluster(struct net *net, u32 addr);
+int in_own_cluster_exact(struct net *net, u32 addr);
+int in_own_node(struct net *net, u32 addr);
+u32 addr_domain(struct net *net, u32 sc);
 int tipc_addr_domain_valid(u32);
 int tipc_addr_node_valid(u32 addr);
 int tipc_in_scope(u32 domain, u32 addr);
diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index bc58097..53f8bf0 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -317,7 +317,7 @@ void tipc_bclink_update_link_state(struct net *net, struct tipc_node *n_ptr,
 		struct sk_buff *skb = skb_peek(&n_ptr->bclink.deferred_queue);
 		u32 to = skb ? buf_seqno(skb) - 1 : n_ptr->bclink.last_sent;
 
-		tipc_msg_init(msg, BCAST_PROTOCOL, STATE_MSG,
+		tipc_msg_init(net, msg, BCAST_PROTOCOL, STATE_MSG,
 			      INT_H_SIZE, n_ptr->addr);
 		msg_set_non_seq(msg, 1);
 		msg_set_mc_netid(msg, tn->net_id);
@@ -428,7 +428,7 @@ static void bclink_accept_pkt(struct tipc_node *node, u32 seqno)
 	 * Unicast an ACK periodically, ensuring that
 	 * all nodes in the cluster don't ACK at the same time
 	 */
-	if (((seqno - tipc_own_addr) % TIPC_MIN_LINK_WIN) == 0) {
+	if (((seqno - tn->own_addr) % TIPC_MIN_LINK_WIN) == 0) {
 		tipc_link_proto_xmit(node->active_links[node->addr & 1],
 				     STATE_MSG, 0, 0, 0, 0, 0);
 		tn->bcl->stats.sent_acks++;
@@ -466,7 +466,7 @@ void tipc_bclink_rcv(struct net *net, struct sk_buff *buf)
 	if (unlikely(msg_user(msg) == BCAST_PROTOCOL)) {
 		if (msg_type(msg) != STATE_MSG)
 			goto unlock;
-		if (msg_destnode(msg) == tipc_own_addr) {
+		if (msg_destnode(msg) == tn->own_addr) {
 			tipc_bclink_acknowledge(node, msg_bcast_ack(msg));
 			tipc_node_unlock(node);
 			tipc_bclink_lock(net);
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 9a0d6ed..33dc348 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -278,7 +278,7 @@ int tipc_enable_bearer(struct net *net, const char *name, u32 disc_domain,
 	u32 i;
 	int res = -EINVAL;
 
-	if (!tipc_own_addr) {
+	if (!tn->own_addr) {
 		pr_warn("Bearer <%s> rejected, not supported in standalone mode\n",
 			name);
 		return -ENOPROTOOPT;
@@ -288,11 +288,11 @@ int tipc_enable_bearer(struct net *net, const char *name, u32 disc_domain,
 		return -EINVAL;
 	}
 	if (tipc_addr_domain_valid(disc_domain) &&
-	    (disc_domain != tipc_own_addr)) {
-		if (tipc_in_scope(disc_domain, tipc_own_addr)) {
-			disc_domain = tipc_own_addr & TIPC_CLUSTER_MASK;
+	    (disc_domain != tn->own_addr)) {
+		if (tipc_in_scope(disc_domain, tn->own_addr)) {
+			disc_domain = tn->own_addr & TIPC_CLUSTER_MASK;
 			res = 0;   /* accept any node in own cluster */
-		} else if (in_own_cluster_exact(disc_domain))
+		} else if (in_own_cluster_exact(net, disc_domain))
 			res = 0;   /* accept specified node in own cluster */
 	}
 	if (res) {
@@ -817,6 +817,7 @@ int tipc_nl_bearer_disable(struct sk_buff *skb, struct genl_info *info)
 int tipc_nl_bearer_enable(struct sk_buff *skb, struct genl_info *info)
 {
 	struct net *net = genl_info_net(info);
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	int err;
 	char *bearer;
 	struct nlattr *attrs[TIPC_NLA_BEARER_MAX + 1];
@@ -824,7 +825,7 @@ int tipc_nl_bearer_enable(struct sk_buff *skb, struct genl_info *info)
 	u32 prio;
 
 	prio = TIPC_MEDIA_LINK_PRI;
-	domain = tipc_own_addr & TIPC_CLUSTER_MASK;
+	domain = tn->own_addr & TIPC_CLUSTER_MASK;
 
 	if (!info->attrs[TIPC_NLA_BEARER])
 		return -EINVAL;
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 974723a..6873360 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -163,18 +163,19 @@ static struct sk_buff *cfg_disable_bearer(struct net *net)
 
 static struct sk_buff *cfg_set_own_addr(struct net *net)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	u32 addr;
 
 	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_NET_ADDR))
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
 
 	addr = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (addr == tipc_own_addr)
+	if (addr == tn->own_addr)
 		return tipc_cfg_reply_none();
 	if (!tipc_addr_node_valid(addr))
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (node address)");
-	if (tipc_own_addr)
+	if (tn->own_addr)
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 						   " (cannot change node address once assigned)");
 	if (!tipc_net_start(net, addr))
@@ -196,7 +197,7 @@ static struct sk_buff *cfg_set_netid(struct net *net)
 	if (value < 1 || value > 9999)
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (network id must be 1-9999)");
-	if (tipc_own_addr)
+	if (tn->own_addr)
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 			" (cannot change network id once TIPC has joined a network)");
 	tn->net_id = value;
@@ -218,7 +219,7 @@ struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 	rep_headroom = reply_headroom;
 
 	/* Check command authorization */
-	if (likely(in_own_node(orig_node))) {
+	if (likely(in_own_node(net, orig_node))) {
 		/* command is permitted */
 	} else {
 		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
diff --git a/net/tipc/core.c b/net/tipc/core.c
index 63cde81..7c09670 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -48,7 +48,6 @@
 int tipc_random __read_mostly;
 
 /* configurable TIPC parameters */
-u32 tipc_own_addr __read_mostly;
 int tipc_net_id __read_mostly;
 int sysctl_tipc_rmem[3] __read_mostly;	/* min/default/max */
 
@@ -58,6 +57,7 @@ static int __net_init tipc_init_net(struct net *net)
 	int err;
 
 	tn->net_id = 4711;
+	tn->own_addr = 0;
 	INIT_LIST_HEAD(&tn->node_list);
 	spin_lock_init(&tn->node_list_lock);
 
@@ -96,8 +96,6 @@ static int __init tipc_init(void)
 
 	pr_info("Activated (version " TIPC_MOD_VER ")\n");
 
-	tipc_own_addr = 0;
-
 	sysctl_tipc_rmem[0] = TIPC_CONN_OVERLOAD_LIMIT >> 4 <<
 			      TIPC_LOW_IMPORTANCE;
 	sysctl_tipc_rmem[1] = TIPC_CONN_OVERLOAD_LIMIT >> 4 <<
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 8939929..afabf39 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -72,10 +72,6 @@
 
 int tipc_snprintf(char *buf, int len, const char *fmt, ...);
 
-/*
- * Global configuration variables
- */
-extern u32 tipc_own_addr __read_mostly;
 extern int tipc_net_id __read_mostly;
 extern int sysctl_tipc_rmem[3] __read_mostly;
 extern int sysctl_tipc_named_timeout __read_mostly;
@@ -86,6 +82,7 @@ extern int sysctl_tipc_named_timeout __read_mostly;
 extern int tipc_random __read_mostly;
 
 struct tipc_net {
+	u32 own_addr;
 	int net_id;
 
 	/* Node table and node list */
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index f93dd3d..786411d 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -86,7 +86,7 @@ static void tipc_disc_init_msg(struct net *net, struct sk_buff *buf, u32 type,
 	u32 dest_domain = b_ptr->domain;
 
 	msg = buf_msg(buf);
-	tipc_msg_init(msg, LINK_CONFIG, type, INT_H_SIZE, dest_domain);
+	tipc_msg_init(net, msg, LINK_CONFIG, type, INT_H_SIZE, dest_domain);
 	msg_set_non_seq(msg, 1);
 	msg_set_node_sig(msg, tipc_random);
 	msg_set_dest_domain(msg, dest_domain);
@@ -153,12 +153,12 @@ void tipc_disc_rcv(struct net *net, struct sk_buff *buf,
 	if (!tipc_addr_node_valid(onode))
 		return;
 
-	if (in_own_node(onode)) {
+	if (in_own_node(net, onode)) {
 		if (memcmp(&maddr, &bearer->addr, sizeof(maddr)))
-			disc_dupl_alert(bearer, tipc_own_addr, &maddr);
+			disc_dupl_alert(bearer, tn->own_addr, &maddr);
 		return;
 	}
-	if (!tipc_in_scope(ddom, tipc_own_addr))
+	if (!tipc_in_scope(ddom, tn->own_addr))
 		return;
 	if (!tipc_in_scope(bearer->domain, onode))
 		return;
diff --git a/net/tipc/link.c b/net/tipc/link.c
index a84d5c6..9972567 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -241,6 +241,7 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 				   struct tipc_bearer *b_ptr,
 				   const struct tipc_media_addr *media_addr)
 {
+	struct tipc_net *tn = net_generic(n_ptr->net, tipc_net_id);
 	struct tipc_link *l_ptr;
 	struct tipc_msg *msg;
 	char *if_name;
@@ -270,8 +271,8 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 	l_ptr->addr = peer;
 	if_name = strchr(b_ptr->name, ':') + 1;
 	sprintf(l_ptr->name, "%u.%u.%u:%s-%u.%u.%u:unknown",
-		tipc_zone(tipc_own_addr), tipc_cluster(tipc_own_addr),
-		tipc_node(tipc_own_addr),
+		tipc_zone(tn->own_addr), tipc_cluster(tn->own_addr),
+		tipc_node(tn->own_addr),
 		if_name,
 		tipc_zone(peer), tipc_cluster(peer), tipc_node(peer));
 		/* note: peer i/f name is updated by reset/activate message */
@@ -285,7 +286,8 @@ struct tipc_link *tipc_link_create(struct tipc_node *n_ptr,
 
 	l_ptr->pmsg = (struct tipc_msg *)&l_ptr->proto_msg;
 	msg = l_ptr->pmsg;
-	tipc_msg_init(msg, LINK_PROTOCOL, RESET_MSG, INT_H_SIZE, l_ptr->addr);
+	tipc_msg_init(n_ptr->net, msg, LINK_PROTOCOL, RESET_MSG, INT_H_SIZE,
+		      l_ptr->addr);
 	msg_set_size(msg, sizeof(l_ptr->proto_msg));
 	msg_set_session(msg, (tipc_random & 0xffff));
 	msg_set_bearer_id(msg, b_ptr->identity);
@@ -358,10 +360,12 @@ void tipc_link_delete_list(struct net *net, unsigned int bearer_id,
 static bool link_schedule_user(struct tipc_link *link, u32 oport,
 			       uint chain_sz, uint imp)
 {
+	struct net *net = link->owner->net;
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct sk_buff *buf;
 
-	buf = tipc_msg_create(SOCK_WAKEUP, 0, INT_H_SIZE, 0, tipc_own_addr,
-			      tipc_own_addr, oport, 0, 0);
+	buf = tipc_msg_create(net, SOCK_WAKEUP, 0, INT_H_SIZE, 0, tn->own_addr,
+			      tn->own_addr, oport, 0, 0);
 	if (!buf)
 		return false;
 	TIPC_SKB_CB(buf)->chain_sz = chain_sz;
@@ -753,7 +757,7 @@ int __tipc_link_xmit(struct net *net, struct tipc_link *link,
 		} else if (tipc_msg_bundle(outqueue, skb, mtu)) {
 			link->stats.sent_bundled++;
 			continue;
-		} else if (tipc_msg_make_bundle(outqueue, skb, mtu,
+		} else if (tipc_msg_make_bundle(net, outqueue, skb, mtu,
 						link->addr)) {
 			link->stats.sent_bundled++;
 			link->stats.sent_bundles++;
@@ -822,7 +826,7 @@ int tipc_link_xmit(struct net *net, struct sk_buff_head *list, u32 dnode,
 	if (link)
 		return rc;
 
-	if (likely(in_own_node(dnode))) {
+	if (likely(in_own_node(net, dnode))) {
 		/* As a node local message chain never contains more than one
 		 * buffer, we just need to dequeue one SKB buffer from the
 		 * head list.
@@ -852,7 +856,8 @@ static void tipc_link_sync_xmit(struct tipc_link *link)
 		return;
 
 	msg = buf_msg(skb);
-	tipc_msg_init(msg, BCAST_PROTOCOL, STATE_MSG, INT_H_SIZE, link->addr);
+	tipc_msg_init(link->owner->net, msg, BCAST_PROTOCOL, STATE_MSG,
+		      INT_H_SIZE, link->addr);
 	msg_set_last_bcast(msg, link->owner->bclink.acked);
 	__tipc_link_xmit_skb(link, skb);
 }
@@ -1092,6 +1097,7 @@ static int link_recv_buf_validate(struct sk_buff *buf)
  */
 void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct sk_buff_head head;
 	struct tipc_node *n_ptr;
 	struct tipc_link *l_ptr;
@@ -1125,7 +1131,7 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 
 		/* Discard unicast link messages destined for another node */
 		if (unlikely(!msg_short(msg) &&
-			     (msg_destnode(msg) != tipc_own_addr)))
+			     (msg_destnode(msg) != tn->own_addr)))
 			goto discard;
 
 		/* Locate neighboring node that sent message */
@@ -1483,6 +1489,7 @@ void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int probe_msg,
 static void tipc_link_proto_rcv(struct net *net, struct tipc_link *l_ptr,
 				struct sk_buff *buf)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	u32 rec_gap = 0;
 	u32 max_pkt_info;
 	u32 max_pkt_ack;
@@ -1494,7 +1501,7 @@ static void tipc_link_proto_rcv(struct net *net, struct tipc_link *l_ptr,
 		goto exit;
 
 	if (l_ptr->net_plane != msg_net_plane(msg))
-		if (tipc_own_addr > msg_prevnode(msg))
+		if (tn->own_addr > msg_prevnode(msg))
 			l_ptr->net_plane = msg_net_plane(msg);
 
 	switch (msg_type(msg)) {
@@ -1662,8 +1669,8 @@ void tipc_link_failover_send_queue(struct tipc_link *l_ptr)
 	if (!tunnel)
 		return;
 
-	tipc_msg_init(&tunnel_hdr, CHANGEOVER_PROTOCOL,
-		 ORIGINAL_MSG, INT_H_SIZE, l_ptr->addr);
+	tipc_msg_init(l_ptr->owner->net, &tunnel_hdr, CHANGEOVER_PROTOCOL,
+		      ORIGINAL_MSG, INT_H_SIZE, l_ptr->addr);
 	msg_set_bearer_id(&tunnel_hdr, l_ptr->peer_bearer_id);
 	msg_set_msgcnt(&tunnel_hdr, msgcount);
 
@@ -1720,8 +1727,8 @@ void tipc_link_dup_queue_xmit(struct tipc_link *l_ptr,
 	struct sk_buff *skb;
 	struct tipc_msg tunnel_hdr;
 
-	tipc_msg_init(&tunnel_hdr, CHANGEOVER_PROTOCOL,
-		 DUPLICATE_MSG, INT_H_SIZE, l_ptr->addr);
+	tipc_msg_init(l_ptr->owner->net, &tunnel_hdr, CHANGEOVER_PROTOCOL,
+		      DUPLICATE_MSG, INT_H_SIZE, l_ptr->addr);
 	msg_set_msgcnt(&tunnel_hdr, skb_queue_len(&l_ptr->outqueue));
 	msg_set_bearer_id(&tunnel_hdr, l_ptr->peer_bearer_id);
 	skb_queue_walk(&l_ptr->outqueue, skb) {
@@ -2506,12 +2513,14 @@ msg_full:
 }
 
 /* Caller should hold appropriate locks to protect the link */
-static int __tipc_nl_add_link(struct tipc_nl_msg *msg, struct tipc_link *link)
+static int __tipc_nl_add_link(struct net *net, struct tipc_nl_msg *msg,
+			      struct tipc_link *link)
 {
 	int err;
 	void *hdr;
 	struct nlattr *attrs;
 	struct nlattr *prop;
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 
 	hdr = genlmsg_put(msg->skb, msg->portid, msg->seq, &tipc_genl_v2_family,
 			  NLM_F_MULTI, TIPC_NL_LINK_GET);
@@ -2525,7 +2534,7 @@ static int __tipc_nl_add_link(struct tipc_nl_msg *msg, struct tipc_link *link)
 	if (nla_put_string(msg->skb, TIPC_NLA_LINK_NAME, link->name))
 		goto attr_msg_full;
 	if (nla_put_u32(msg->skb, TIPC_NLA_LINK_DEST,
-			tipc_cluster_mask(tipc_own_addr)))
+			tipc_cluster_mask(tn->own_addr)))
 		goto attr_msg_full;
 	if (nla_put_u32(msg->skb, TIPC_NLA_LINK_MTU, link->max_pkt))
 		goto attr_msg_full;
@@ -2575,9 +2584,8 @@ msg_full:
 }
 
 /* Caller should hold node lock  */
-static int __tipc_nl_add_node_links(struct tipc_nl_msg *msg,
-				    struct tipc_node *node,
-				    u32 *prev_link)
+static int __tipc_nl_add_node_links(struct net *net, struct tipc_nl_msg *msg,
+				    struct tipc_node *node, u32 *prev_link)
 {
 	u32 i;
 	int err;
@@ -2588,7 +2596,7 @@ static int __tipc_nl_add_node_links(struct tipc_nl_msg *msg,
 		if (!node->links[i])
 			continue;
 
-		err = __tipc_nl_add_link(msg, node->links[i]);
+		err = __tipc_nl_add_link(net, msg, node->links[i]);
 		if (err)
 			return err;
 	}
@@ -2633,7 +2641,8 @@ int tipc_nl_link_dump(struct sk_buff *skb, struct netlink_callback *cb)
 		list_for_each_entry_continue_rcu(node, &tn->node_list,
 						 list) {
 			tipc_node_lock(node);
-			err = __tipc_nl_add_node_links(&msg, node, &prev_link);
+			err = __tipc_nl_add_node_links(net, &msg, node,
+						       &prev_link);
 			tipc_node_unlock(node);
 			if (err)
 				goto out;
@@ -2647,7 +2656,8 @@ int tipc_nl_link_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 		list_for_each_entry_rcu(node, &tn->node_list, list) {
 			tipc_node_lock(node);
-			err = __tipc_nl_add_node_links(&msg, node, &prev_link);
+			err = __tipc_nl_add_node_links(net, &msg, node,
+						       &prev_link);
 			tipc_node_unlock(node);
 			if (err)
 				goto out;
@@ -2700,7 +2710,7 @@ int tipc_nl_link_get(struct sk_buff *skb, struct genl_info *info)
 		goto err_out;
 	}
 
-	err = __tipc_nl_add_link(&msg, link);
+	err = __tipc_nl_add_link(net, &msg, link);
 	if (err)
 		goto err_out;
 
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 642fb13..18aba9e 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -70,25 +70,27 @@ struct sk_buff *tipc_buf_acquire(u32 size)
 	return skb;
 }
 
-void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type, u32 hsize,
-		   u32 destnode)
+void tipc_msg_init(struct net *net, struct tipc_msg *m, u32 user, u32 type,
+		   u32 hsize, u32 destnode)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+
 	memset(m, 0, hsize);
 	msg_set_version(m);
 	msg_set_user(m, user);
 	msg_set_hdr_sz(m, hsize);
 	msg_set_size(m, hsize);
-	msg_set_prevnode(m, tipc_own_addr);
+	msg_set_prevnode(m, tn->own_addr);
 	msg_set_type(m, type);
 	if (hsize > SHORT_H_SIZE) {
-		msg_set_orignode(m, tipc_own_addr);
+		msg_set_orignode(m, tn->own_addr);
 		msg_set_destnode(m, destnode);
 	}
 }
 
-struct sk_buff *tipc_msg_create(uint user, uint type, uint hdr_sz,
-				uint data_sz, u32 dnode, u32 onode,
-				u32 dport, u32 oport, int errcode)
+struct sk_buff *tipc_msg_create(struct net *net, uint user, uint type,
+				uint hdr_sz, uint data_sz, u32 dnode,
+				u32 onode, u32 dport, u32 oport, int errcode)
 {
 	struct tipc_msg *msg;
 	struct sk_buff *buf;
@@ -98,7 +100,7 @@ struct sk_buff *tipc_msg_create(uint user, uint type, uint hdr_sz,
 		return NULL;
 
 	msg = buf_msg(buf);
-	tipc_msg_init(msg, user, type, hdr_sz, dnode);
+	tipc_msg_init(net, msg, user, type, hdr_sz, dnode);
 	msg_set_size(msg, hdr_sz + data_sz);
 	msg_set_prevnode(msg, onode);
 	msg_set_origport(msg, oport);
@@ -194,8 +196,8 @@ err:
  *
  * Returns message data size or errno: -ENOMEM, -EFAULT
  */
-int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m, int offset,
-		   int dsz, int pktmax, struct sk_buff_head *list)
+int tipc_msg_build(struct net *net, struct tipc_msg *mhdr, struct msghdr *m,
+		   int offset, int dsz, int pktmax, struct sk_buff_head *list)
 {
 	int mhsz = msg_hdr_sz(mhdr);
 	int msz = mhsz + dsz;
@@ -227,8 +229,8 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m, int offset,
 	}
 
 	/* Prepare reusable fragment header */
-	tipc_msg_init(&pkthdr, MSG_FRAGMENTER, FIRST_FRAGMENT,
-		      INT_H_SIZE, msg_destnode(mhdr));
+	tipc_msg_init(net, &pkthdr, MSG_FRAGMENTER, FIRST_FRAGMENT, INT_H_SIZE,
+		      msg_destnode(mhdr));
 	msg_set_size(&pkthdr, pktmax);
 	msg_set_fragm_no(&pkthdr, pktno);
 
@@ -339,8 +341,8 @@ bool tipc_msg_bundle(struct sk_buff_head *list, struct sk_buff *skb, u32 mtu)
  * Replaces buffer if successful
  * Returns true if success, otherwise false
  */
-bool tipc_msg_make_bundle(struct sk_buff_head *list, struct sk_buff *skb,
-			  u32 mtu, u32 dnode)
+bool tipc_msg_make_bundle(struct net *net, struct sk_buff_head *list,
+			  struct sk_buff *skb, u32 mtu, u32 dnode)
 {
 	struct sk_buff *bskb;
 	struct tipc_msg *bmsg;
@@ -363,7 +365,7 @@ bool tipc_msg_make_bundle(struct sk_buff_head *list, struct sk_buff *skb,
 
 	skb_trim(bskb, INT_H_SIZE);
 	bmsg = buf_msg(bskb);
-	tipc_msg_init(bmsg, MSG_BUNDLER, 0, INT_H_SIZE, dnode);
+	tipc_msg_init(net, bmsg, MSG_BUNDLER, 0, INT_H_SIZE, dnode);
 	msg_set_seqno(bmsg, msg_seqno(msg));
 	msg_set_ack(bmsg, msg_ack(msg));
 	msg_set_bcast_ack(bmsg, msg_bcast_ack(msg));
@@ -380,8 +382,10 @@ bool tipc_msg_make_bundle(struct sk_buff_head *list, struct sk_buff *skb,
  * Consumes buffer if failure
  * Returns true if success, otherwise false
  */
-bool tipc_msg_reverse(struct sk_buff *buf, u32 *dnode, int err)
+bool tipc_msg_reverse(struct net *net, struct sk_buff *buf, u32 *dnode,
+		      int err)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_msg *msg = buf_msg(buf);
 	uint imp = msg_importance(msg);
 	struct tipc_msg ohdr;
@@ -401,7 +405,7 @@ bool tipc_msg_reverse(struct sk_buff *buf, u32 *dnode, int err)
 	msg_set_errcode(msg, err);
 	msg_set_origport(msg, msg_destport(&ohdr));
 	msg_set_destport(msg, msg_origport(&ohdr));
-	msg_set_prevnode(msg, tipc_own_addr);
+	msg_set_prevnode(msg, tn->own_addr);
 	if (!msg_short(msg)) {
 		msg_set_orignode(msg, msg_destnode(&ohdr));
 		msg_set_destnode(msg, msg_orignode(&ohdr));
@@ -440,7 +444,7 @@ int tipc_msg_eval(struct net *net, struct sk_buff *buf, u32 *dnode)
 	if (msg_reroute_cnt(msg) > 0)
 		return -TIPC_ERR_NO_NAME;
 
-	*dnode = addr_domain(msg_lookup_scope(msg));
+	*dnode = addr_domain(net, msg_lookup_scope(msg));
 	dport = tipc_nametbl_translate(net, msg_nametype(msg),
 				       msg_nameinst(msg),
 				       dnode);
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 69f37e6..526ef34 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -748,19 +748,20 @@ static inline u32 msg_tot_origport(struct tipc_msg *m)
 }
 
 struct sk_buff *tipc_buf_acquire(u32 size);
-bool tipc_msg_reverse(struct sk_buff *buf, u32 *dnode, int err);
+bool tipc_msg_reverse(struct net *net, struct sk_buff *buf, u32 *dnode,
+		      int err);
 int tipc_msg_eval(struct net *net, struct sk_buff *buf, u32 *dnode);
-void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type, u32 hsize,
-		   u32 destnode);
-struct sk_buff *tipc_msg_create(uint user, uint type, uint hdr_sz,
-				uint data_sz, u32 dnode, u32 onode,
-				u32 dport, u32 oport, int errcode);
+void tipc_msg_init(struct net *net, struct tipc_msg *m, u32 user, u32 type,
+		   u32 hsize, u32 destnode);
+struct sk_buff *tipc_msg_create(struct net *net, uint user, uint type,
+				uint hdr_sz, uint data_sz, u32 dnode,
+				u32 onode, u32 dport, u32 oport, int errcode);
 int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf);
 bool tipc_msg_bundle(struct sk_buff_head *list, struct sk_buff *skb, u32 mtu);
-bool tipc_msg_make_bundle(struct sk_buff_head *list, struct sk_buff *skb,
-			  u32 mtu, u32 dnode);
-int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m, int offset,
-		   int dsz, int mtu, struct sk_buff_head *list);
+bool tipc_msg_make_bundle(struct net *net, struct sk_buff_head *list,
+			  struct sk_buff *skb, u32 mtu, u32 dnode);
+int tipc_msg_build(struct net *net, struct tipc_msg *mhdr, struct msghdr *m,
+		   int offset, int dsz, int mtu, struct sk_buff_head *list);
 struct sk_buff *tipc_msg_reassemble(struct sk_buff_head *list);
 
 #endif
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index ba42132..7f31cd4 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -68,14 +68,16 @@ static void publ_to_item(struct distr_item *i, struct publication *p)
 /**
  * named_prepare_buf - allocate & initialize a publication message
  */
-static struct sk_buff *named_prepare_buf(u32 type, u32 size, u32 dest)
+static struct sk_buff *named_prepare_buf(struct net *net, u32 type, u32 size,
+					 u32 dest)
 {
 	struct sk_buff *buf = tipc_buf_acquire(INT_H_SIZE + size);
 	struct tipc_msg *msg;
 
 	if (buf != NULL) {
 		msg = buf_msg(buf);
-		tipc_msg_init(msg, NAME_DISTRIBUTOR, type, INT_H_SIZE, dest);
+		tipc_msg_init(net, msg, NAME_DISTRIBUTOR, type, INT_H_SIZE,
+			      dest);
 		msg_set_size(msg, INT_H_SIZE + size);
 	}
 	return buf;
@@ -91,7 +93,7 @@ void named_cluster_distribute(struct net *net, struct sk_buff *skb)
 	rcu_read_lock();
 	list_for_each_entry_rcu(node, &tn->node_list, list) {
 		dnode = node->addr;
-		if (in_own_node(dnode))
+		if (in_own_node(net, dnode))
 			continue;
 		if (!tipc_node_active_links(node))
 			continue;
@@ -121,7 +123,7 @@ struct sk_buff *tipc_named_publish(struct net *net, struct publication *publ)
 	if (publ->scope == TIPC_NODE_SCOPE)
 		return NULL;
 
-	buf = named_prepare_buf(PUBLICATION, ITEM_SIZE, 0);
+	buf = named_prepare_buf(net, PUBLICATION, ITEM_SIZE, 0);
 	if (!buf) {
 		pr_warn("Publication distribution failure\n");
 		return NULL;
@@ -135,7 +137,7 @@ struct sk_buff *tipc_named_publish(struct net *net, struct publication *publ)
 /**
  * tipc_named_withdraw - tell other nodes about a withdrawn publication by this node
  */
-struct sk_buff *tipc_named_withdraw(struct publication *publ)
+struct sk_buff *tipc_named_withdraw(struct net *net, struct publication *publ)
 {
 	struct sk_buff *buf;
 	struct distr_item *item;
@@ -145,7 +147,7 @@ struct sk_buff *tipc_named_withdraw(struct publication *publ)
 	if (publ->scope == TIPC_NODE_SCOPE)
 		return NULL;
 
-	buf = named_prepare_buf(WITHDRAWAL, ITEM_SIZE, 0);
+	buf = named_prepare_buf(net, WITHDRAWAL, ITEM_SIZE, 0);
 	if (!buf) {
 		pr_warn("Withdrawal distribution failure\n");
 		return NULL;
@@ -175,7 +177,8 @@ static void named_distribute(struct net *net, struct sk_buff_head *list,
 	list_for_each_entry(publ, pls, local_list) {
 		/* Prepare next buffer: */
 		if (!skb) {
-			skb = named_prepare_buf(PUBLICATION, msg_rem, dnode);
+			skb = named_prepare_buf(net, PUBLICATION, msg_rem,
+						dnode);
 			if (!skb) {
 				pr_warn("Bulk publication failure\n");
 				return;
@@ -227,7 +230,7 @@ static void tipc_publ_subscribe(struct net *net, struct publication *publ,
 {
 	struct tipc_node *node;
 
-	if (in_own_node(addr))
+	if (in_own_node(net, addr))
 		return;
 
 	node = tipc_node_find(net, addr);
@@ -416,7 +419,7 @@ void tipc_named_reinit(struct net *net)
 	for (scope = TIPC_ZONE_SCOPE; scope <= TIPC_NODE_SCOPE; scope++)
 		list_for_each_entry_rcu(publ, &tn->nametbl->publ_list[scope],
 					local_list)
-			publ->node = tipc_own_addr;
+			publ->node = tn->own_addr;
 
 	spin_unlock_bh(&tn->nametbl_lock);
 }
diff --git a/net/tipc/name_distr.h b/net/tipc/name_distr.h
index 1ed2d7e..5ec10b5 100644
--- a/net/tipc/name_distr.h
+++ b/net/tipc/name_distr.h
@@ -68,7 +68,7 @@ struct distr_item {
 };
 
 struct sk_buff *tipc_named_publish(struct net *net, struct publication *publ);
-struct sk_buff *tipc_named_withdraw(struct publication *publ);
+struct sk_buff *tipc_named_withdraw(struct net *net, struct publication *publ);
 void named_cluster_distribute(struct net *net, struct sk_buff *buf);
 void tipc_named_node_up(struct net *net, u32 dnode);
 void tipc_named_rcv(struct net *net, struct sk_buff *buf);
diff --git a/net/tipc/name_table.c b/net/tipc/name_table.c
index 57e39c1..ce09b86 100644
--- a/net/tipc/name_table.c
+++ b/net/tipc/name_table.c
@@ -227,9 +227,11 @@ static u32 nameseq_locate_subseq(struct name_seq *nseq, u32 instance)
 /**
  * tipc_nameseq_insert_publ
  */
-static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
-						    u32 type, u32 lower, u32 upper,
-						    u32 scope, u32 node, u32 port, u32 key)
+static struct publication *tipc_nameseq_insert_publ(struct net *net,
+						    struct name_seq *nseq,
+						    u32 type, u32 lower,
+						    u32 upper, u32 scope,
+						    u32 node, u32 port, u32 key)
 {
 	struct tipc_subscription *s;
 	struct tipc_subscription *st;
@@ -314,12 +316,12 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
 	list_add(&publ->zone_list, &info->zone_list);
 	info->zone_list_size++;
 
-	if (in_own_cluster(node)) {
+	if (in_own_cluster(net, node)) {
 		list_add(&publ->cluster_list, &info->cluster_list);
 		info->cluster_list_size++;
 	}
 
-	if (in_own_node(node)) {
+	if (in_own_node(net, node)) {
 		list_add(&publ->node_list, &info->node_list);
 		info->node_list_size++;
 	}
@@ -348,8 +350,10 @@ static struct publication *tipc_nameseq_insert_publ(struct name_seq *nseq,
  * A failed withdraw request simply returns a failure indication and lets the
  * caller issue any error or warning messages associated with such a problem.
  */
-static struct publication *tipc_nameseq_remove_publ(struct name_seq *nseq, u32 inst,
-						    u32 node, u32 ref, u32 key)
+static struct publication *tipc_nameseq_remove_publ(struct net *net,
+						    struct name_seq *nseq,
+						    u32 inst, u32 node,
+						    u32 ref, u32 key)
 {
 	struct publication *publ;
 	struct sub_seq *sseq = nameseq_find_subseq(nseq, inst);
@@ -377,13 +381,13 @@ found:
 	info->zone_list_size--;
 
 	/* Remove publication from cluster scope list, if present */
-	if (in_own_cluster(node)) {
+	if (in_own_cluster(net, node)) {
 		list_del(&publ->cluster_list);
 		info->cluster_list_size--;
 	}
 
 	/* Remove publication from node scope list, if present */
-	if (in_own_node(node)) {
+	if (in_own_node(net, node)) {
 		list_del(&publ->node_list);
 		info->node_list_size--;
 	}
@@ -483,7 +487,7 @@ struct publication *tipc_nametbl_insert_publ(struct net *net, u32 type,
 		return NULL;
 
 	spin_lock_bh(&seq->lock);
-	publ = tipc_nameseq_insert_publ(seq, type, lower, upper,
+	publ = tipc_nameseq_insert_publ(net, seq, type, lower, upper,
 					scope, node, port, key);
 	spin_unlock_bh(&seq->lock);
 	return publ;
@@ -500,7 +504,7 @@ struct publication *tipc_nametbl_remove_publ(struct net *net, u32 type,
 		return NULL;
 
 	spin_lock_bh(&seq->lock);
-	publ = tipc_nameseq_remove_publ(seq, lower, node, ref, key);
+	publ = tipc_nameseq_remove_publ(net, seq, lower, node, ref, key);
 	if (!seq->first_free && list_empty(&seq->subscriptions)) {
 		hlist_del_init_rcu(&seq->ns_list);
 		kfree(seq->sseqs);
@@ -528,6 +532,7 @@ struct publication *tipc_nametbl_remove_publ(struct net *net, u32 type,
 u32 tipc_nametbl_translate(struct net *net, u32 type, u32 instance,
 			   u32 *destnode)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct sub_seq *sseq;
 	struct name_info *info;
 	struct publication *publ;
@@ -535,7 +540,7 @@ u32 tipc_nametbl_translate(struct net *net, u32 type, u32 instance,
 	u32 ref = 0;
 	u32 node = 0;
 
-	if (!tipc_in_scope(*destnode, tipc_own_addr))
+	if (!tipc_in_scope(*destnode, tn->own_addr))
 		return 0;
 
 	rcu_read_lock();
@@ -572,13 +577,13 @@ u32 tipc_nametbl_translate(struct net *net, u32 type, u32 instance,
 	}
 
 	/* Round-Robin Algorithm */
-	else if (*destnode == tipc_own_addr) {
+	else if (*destnode == tn->own_addr) {
 		if (list_empty(&info->node_list))
 			goto no_match;
 		publ = list_first_entry(&info->node_list, struct publication,
 					node_list);
 		list_move_tail(&publ->node_list, &info->node_list);
-	} else if (in_own_cluster_exact(*destnode)) {
+	} else if (in_own_cluster_exact(net, *destnode)) {
 		if (list_empty(&info->cluster_list))
 			goto no_match;
 		publ = list_first_entry(&info->cluster_list, struct publication,
@@ -670,7 +675,7 @@ struct publication *tipc_nametbl_publish(struct net *net, u32 type, u32 lower,
 	}
 
 	publ = tipc_nametbl_insert_publ(net, type, lower, upper, scope,
-					tipc_own_addr, port_ref, key);
+					tn->own_addr, port_ref, key);
 	if (likely(publ)) {
 		tn->nametbl->local_publ_count++;
 		buf = tipc_named_publish(net, publ);
@@ -695,11 +700,11 @@ int tipc_nametbl_withdraw(struct net *net, u32 type, u32 lower, u32 ref,
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 
 	spin_lock_bh(&tn->nametbl_lock);
-	publ = tipc_nametbl_remove_publ(net, type, lower, tipc_own_addr,
+	publ = tipc_nametbl_remove_publ(net, type, lower, tn->own_addr,
 					ref, key);
 	if (likely(publ)) {
 		tn->nametbl->local_publ_count--;
-		skb = tipc_named_withdraw(publ);
+		skb = tipc_named_withdraw(net, publ);
 		/* Any pending external events? */
 		tipc_named_process_backlog(net);
 		list_del_init(&publ->pport_list);
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 04445d21..263267e 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -115,30 +115,32 @@ int tipc_net_start(struct net *net, u32 addr)
 	char addr_string[16];
 	int res;
 
-	tipc_own_addr = addr;
+	tn->own_addr = addr;
 	tipc_named_reinit(net);
 	tipc_sk_reinit(net);
 	res = tipc_bclink_init(net);
 	if (res)
 		return res;
 
-	tipc_nametbl_publish(net, TIPC_CFG_SRV, tipc_own_addr, tipc_own_addr,
-			     TIPC_ZONE_SCOPE, 0, tipc_own_addr);
+	tipc_nametbl_publish(net, TIPC_CFG_SRV, tn->own_addr, tn->own_addr,
+			     TIPC_ZONE_SCOPE, 0, tn->own_addr);
 
 	pr_info("Started in network mode\n");
 	pr_info("Own node address %s, network identity %u\n",
-		tipc_addr_string_fill(addr_string, tipc_own_addr),
+		tipc_addr_string_fill(addr_string, tn->own_addr),
 		tn->net_id);
 	return 0;
 }
 
 void tipc_net_stop(struct net *net)
 {
-	if (!tipc_own_addr)
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+
+	if (!tn->own_addr)
 		return;
 
-	tipc_nametbl_withdraw(net, TIPC_CFG_SRV, tipc_own_addr, 0,
-			      tipc_own_addr);
+	tipc_nametbl_withdraw(net, TIPC_CFG_SRV, tn->own_addr, 0,
+			      tn->own_addr);
 	rtnl_lock();
 	tipc_bearer_stop(net);
 	tipc_bclink_stop(net);
@@ -224,7 +226,7 @@ int tipc_nl_net_set(struct sk_buff *skb, struct genl_info *info)
 		u32 val;
 
 		/* Can't change net id once TIPC has joined a network */
-		if (tipc_own_addr)
+		if (tn->own_addr)
 			return -EPERM;
 
 		val = nla_get_u32(attrs[TIPC_NLA_NET_ID]);
@@ -238,7 +240,7 @@ int tipc_nl_net_set(struct sk_buff *skb, struct genl_info *info)
 		u32 addr;
 
 		/* Can't change net addr once TIPC has joined a network */
-		if (tipc_own_addr)
+		if (tn->own_addr)
 			return -EPERM;
 
 		addr = nla_get_u32(attrs[TIPC_NLA_NET_ADDR]);
diff --git a/net/tipc/node.c b/net/tipc/node.c
index 3db5012..b1eb092 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -75,7 +75,7 @@ struct tipc_node *tipc_node_find(struct net *net, u32 addr)
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_node *node;
 
-	if (unlikely(!in_own_cluster_exact(addr)))
+	if (unlikely(!in_own_cluster_exact(net, addr)))
 		return NULL;
 
 	rcu_read_lock();
@@ -155,7 +155,7 @@ int tipc_node_add_conn(struct net *net, u32 dnode, u32 port, u32 peer_port)
 	struct tipc_node *node;
 	struct tipc_sock_conn *conn;
 
-	if (in_own_node(dnode))
+	if (in_own_node(net, dnode))
 		return 0;
 
 	node = tipc_node_find(net, dnode);
@@ -181,7 +181,7 @@ void tipc_node_remove_conn(struct net *net, u32 dnode, u32 port)
 	struct tipc_node *node;
 	struct tipc_sock_conn *conn, *safe;
 
-	if (in_own_node(dnode))
+	if (in_own_node(net, dnode))
 		return;
 
 	node = tipc_node_find(net, dnode);
@@ -200,14 +200,16 @@ void tipc_node_remove_conn(struct net *net, u32 dnode, u32 port)
 
 void tipc_node_abort_sock_conns(struct net *net, struct list_head *conns)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_sock_conn *conn, *safe;
 	struct sk_buff *buf;
 
 	list_for_each_entry_safe(conn, safe, conns, list) {
-		buf = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE, TIPC_CONN_MSG,
-				      SHORT_H_SIZE, 0, tipc_own_addr,
-				      conn->peer_node, conn->port,
-				      conn->peer_port, TIPC_ERR_NO_NODE);
+		buf = tipc_msg_create(net, TIPC_CRITICAL_IMPORTANCE,
+				      TIPC_CONN_MSG, SHORT_H_SIZE, 0,
+				      tn->own_addr, conn->peer_node,
+				      conn->port, conn->peer_port,
+				      TIPC_ERR_NO_NODE);
 		if (likely(buf))
 			tipc_sk_rcv(net, buf);
 		list_del(&conn->list);
@@ -287,6 +289,7 @@ static void node_select_active_links(struct tipc_node *n_ptr)
  */
 void tipc_node_link_down(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 {
+	struct tipc_net *tn = net_generic(n_ptr->net, tipc_net_id);
 	struct tipc_link **active;
 
 	n_ptr->working_links--;
@@ -321,7 +324,7 @@ void tipc_node_link_down(struct tipc_node *n_ptr, struct tipc_link *l_ptr)
 	}
 
 	/* Loopback link went down? No fragmentation needed from now on. */
-	if (n_ptr->addr == tipc_own_addr) {
+	if (n_ptr->addr == tn->own_addr) {
 		n_ptr->act_mtus[0] = MAX_MSG_SIZE;
 		n_ptr->act_mtus[1] = MAX_MSG_SIZE;
 	}
@@ -483,7 +486,7 @@ struct sk_buff *tipc_node_get_links(struct net *net, const void *req_tlv_area,
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
 						   " (network address)");
 
-	if (!tipc_own_addr)
+	if (!tn->own_addr)
 		return tipc_cfg_reply_none();
 
 	spin_lock_bh(&tn->node_list_lock);
@@ -501,7 +504,7 @@ struct sk_buff *tipc_node_get_links(struct net *net, const void *req_tlv_area,
 		return NULL;
 
 	/* Add TLV for broadcast link */
-	link_info.dest = htonl(tipc_cluster_mask(tipc_own_addr));
+	link_info.dest = htonl(tipc_cluster_mask(tn->own_addr));
 	link_info.up = htonl(1);
 	strlcpy(link_info.str, tipc_bclink_name, TIPC_MAX_LINK_NAME);
 	tipc_cfg_append_tlv(buf, TIPC_TLV_LINK_INFO, &link_info, sizeof(link_info));
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 4670e1e..9b8470e 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -251,10 +251,11 @@ static void tsk_rej_rx_queue(struct sock *sk)
 {
 	struct sk_buff *skb;
 	u32 dnode;
+	struct net *net = sock_net(sk);
 
 	while ((skb = __skb_dequeue(&sk->sk_receive_queue))) {
-		if (tipc_msg_reverse(skb, &dnode, TIPC_ERR_NO_PORT))
-			tipc_link_xmit_skb(sock_net(sk), skb, dnode, 0);
+		if (tipc_msg_reverse(net, skb, &dnode, TIPC_ERR_NO_PORT))
+			tipc_link_xmit_skb(net, skb, dnode, 0);
 	}
 }
 
@@ -265,6 +266,7 @@ static void tsk_rej_rx_queue(struct sock *sk)
  */
 static bool tsk_peer_msg(struct tipc_sock *tsk, struct tipc_msg *msg)
 {
+	struct tipc_net *tn = net_generic(sock_net(&tsk->sk), tipc_net_id);
 	u32 peer_port = tsk_peer_port(tsk);
 	u32 orig_node;
 	u32 peer_node;
@@ -281,10 +283,10 @@ static bool tsk_peer_msg(struct tipc_sock *tsk, struct tipc_msg *msg)
 	if (likely(orig_node == peer_node))
 		return true;
 
-	if (!orig_node && (peer_node == tipc_own_addr))
+	if (!orig_node && (peer_node == tn->own_addr))
 		return true;
 
-	if (!peer_node && (orig_node == tipc_own_addr))
+	if (!peer_node && (orig_node == tn->own_addr))
 		return true;
 
 	return false;
@@ -346,7 +348,7 @@ static int tipc_sk_create(struct net *net, struct socket *sock,
 	tsk->max_pkt = MAX_PKT_DEFAULT;
 	INIT_LIST_HEAD(&tsk->publications);
 	msg = &tsk->phdr;
-	tipc_msg_init(msg, TIPC_LOW_IMPORTANCE, TIPC_NAMED_MSG,
+	tipc_msg_init(net, msg, TIPC_LOW_IMPORTANCE, TIPC_NAMED_MSG,
 		      NAMED_H_SIZE, 0);
 
 	/* Finish initializing socket data structures */
@@ -471,6 +473,7 @@ static int tipc_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 	struct net *net = sock_net(sk);
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_sock *tsk;
 	struct sk_buff *skb;
 	u32 dnode, probing_state;
@@ -503,7 +506,8 @@ static int tipc_release(struct socket *sock)
 				tsk->connected = 0;
 				tipc_node_remove_conn(net, dnode, tsk->portid);
 			}
-			if (tipc_msg_reverse(skb, &dnode, TIPC_ERR_NO_PORT))
+			if (tipc_msg_reverse(net, skb, &dnode,
+					     TIPC_ERR_NO_PORT))
 				tipc_link_xmit_skb(net, skb, dnode, 0);
 		}
 	}
@@ -514,9 +518,9 @@ static int tipc_release(struct socket *sock)
 		sock_put(sk);
 	tipc_sk_remove(tsk);
 	if (tsk->connected) {
-		skb = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE, TIPC_CONN_MSG,
-				      SHORT_H_SIZE, 0, dnode, tipc_own_addr,
-				      tsk_peer_port(tsk),
+		skb = tipc_msg_create(net, TIPC_CRITICAL_IMPORTANCE,
+				      TIPC_CONN_MSG, SHORT_H_SIZE, 0, dnode,
+				      tn->own_addr, tsk_peer_port(tsk),
 				      tsk->portid, TIPC_ERR_NO_PORT);
 		if (skb)
 			tipc_link_xmit_skb(net, skb, dnode, tsk->portid);
@@ -614,6 +618,7 @@ static int tipc_getname(struct socket *sock, struct sockaddr *uaddr,
 {
 	struct sockaddr_tipc *addr = (struct sockaddr_tipc *)uaddr;
 	struct tipc_sock *tsk = tipc_sk(sock->sk);
+	struct tipc_net *tn = net_generic(sock_net(sock->sk), tipc_net_id);
 
 	memset(addr, 0, sizeof(*addr));
 	if (peer) {
@@ -624,7 +629,7 @@ static int tipc_getname(struct socket *sock, struct sockaddr *uaddr,
 		addr->addr.id.node = tsk_peer_node(tsk);
 	} else {
 		addr->addr.id.ref = tsk->portid;
-		addr->addr.id.node = tipc_own_addr;
+		addr->addr.id.node = tn->own_addr;
 	}
 
 	*uaddr_len = sizeof(*addr);
@@ -741,7 +746,7 @@ static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
 new_mtu:
 	mtu = tipc_bclink_get_mtu();
 	__skb_queue_head_init(&head);
-	rc = tipc_msg_build(mhdr, msg, 0, dsz, mtu, &head);
+	rc = tipc_msg_build(net, mhdr, msg, 0, dsz, mtu, &head);
 	if (unlikely(rc < 0))
 		return rc;
 
@@ -774,7 +779,7 @@ void tipc_sk_mcast_rcv(struct net *net, struct sk_buff *buf)
 	uint i, last, dst = 0;
 	u32 scope = TIPC_CLUSTER_SCOPE;
 
-	if (in_own_node(msg_orignode(msg)))
+	if (in_own_node(net, msg_orignode(msg)))
 		scope = TIPC_NODE_SCOPE;
 
 	/* Create destination port list: */
@@ -826,7 +831,7 @@ static int tipc_sk_proto_rcv(struct tipc_sock *tsk, u32 *dnode,
 		if (conn_cong)
 			tsk->sk.sk_write_space(&tsk->sk);
 	} else if (msg_type(msg) == CONN_PROBE) {
-		if (!tipc_msg_reverse(buf, dnode, TIPC_OK))
+		if (!tipc_msg_reverse(sock_net(&tsk->sk), buf, dnode, TIPC_OK))
 			return TIPC_OK;
 		msg_set_type(msg, CONN_PROBE_REPLY);
 		return TIPC_FWD_MSG;
@@ -959,7 +964,7 @@ static int tipc_sendmsg(struct kiocb *iocb, struct socket *sock,
 new_mtu:
 	mtu = tipc_node_get_mtu(net, dnode, tsk->portid);
 	__skb_queue_head_init(&head);
-	rc = tipc_msg_build(mhdr, m, 0, dsz, mtu, &head);
+	rc = tipc_msg_build(net, mhdr, m, 0, dsz, mtu, &head);
 	if (rc < 0)
 		goto exit;
 
@@ -1074,7 +1079,7 @@ next:
 	mtu = tsk->max_pkt;
 	send = min_t(uint, dsz - sent, TIPC_MAX_USER_MSG_SIZE);
 	__skb_queue_head_init(&head);
-	rc = tipc_msg_build(mhdr, m, sent, send, mtu, &head);
+	rc = tipc_msg_build(net, mhdr, m, sent, send, mtu, &head);
 	if (unlikely(rc < 0))
 		goto exit;
 	do {
@@ -1246,6 +1251,7 @@ static int tipc_sk_anc_data_recv(struct msghdr *m, struct tipc_msg *msg,
 static void tipc_sk_send_ack(struct tipc_sock *tsk, uint ack)
 {
 	struct net *net = sock_net(&tsk->sk);
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct sk_buff *skb = NULL;
 	struct tipc_msg *msg;
 	u32 peer_port = tsk_peer_port(tsk);
@@ -1253,8 +1259,9 @@ static void tipc_sk_send_ack(struct tipc_sock *tsk, uint ack)
 
 	if (!tsk->connected)
 		return;
-	skb = tipc_msg_create(CONN_MANAGER, CONN_ACK, INT_H_SIZE, 0, dnode,
-			      tipc_own_addr, peer_port, tsk->portid, TIPC_OK);
+	skb = tipc_msg_create(net, CONN_MANAGER, CONN_ACK, INT_H_SIZE, 0,
+			      dnode, tn->own_addr, peer_port, tsk->portid,
+			      TIPC_OK);
 	if (!skb)
 		return;
 	msg = buf_msg(skb);
@@ -1726,6 +1733,7 @@ static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 	int rc;
 	u32 onode;
 	struct tipc_sock *tsk = tipc_sk(sk);
+	struct net *net = sock_net(sk);
 	uint truesize = skb->truesize;
 
 	rc = filter_rcv(sk, skb);
@@ -1736,10 +1744,10 @@ static int tipc_backlog_rcv(struct sock *sk, struct sk_buff *skb)
 		return 0;
 	}
 
-	if ((rc < 0) && !tipc_msg_reverse(skb, &onode, -rc))
+	if ((rc < 0) && !tipc_msg_reverse(net, skb, &onode, -rc))
 		return 0;
 
-	tipc_link_xmit_skb(sock_net(sk), skb, onode, 0);
+	tipc_link_xmit_skb(net, skb, onode, 0);
 
 	return 0;
 }
@@ -1784,7 +1792,7 @@ int tipc_sk_rcv(struct net *net, struct sk_buff *skb)
 	if (likely(!rc))
 		return 0;
 exit:
-	if ((rc < 0) && !tipc_msg_reverse(skb, &dnode, -rc))
+	if ((rc < 0) && !tipc_msg_reverse(net, skb, &dnode, -rc))
 		return -EHOSTUNREACH;
 
 	tipc_link_xmit_skb(net, skb, dnode, 0);
@@ -2045,6 +2053,7 @@ static int tipc_shutdown(struct socket *sock, int how)
 {
 	struct sock *sk = sock->sk;
 	struct net *net = sock_net(sk);
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_sock *tsk = tipc_sk(sk);
 	struct sk_buff *skb;
 	u32 dnode;
@@ -2067,15 +2076,16 @@ restart:
 				kfree_skb(skb);
 				goto restart;
 			}
-			if (tipc_msg_reverse(skb, &dnode, TIPC_CONN_SHUTDOWN))
+			if (tipc_msg_reverse(net, skb, &dnode,
+					     TIPC_CONN_SHUTDOWN))
 				tipc_link_xmit_skb(net, skb, dnode,
 						   tsk->portid);
 			tipc_node_remove_conn(net, dnode, tsk->portid);
 		} else {
 			dnode = tsk_peer_node(tsk);
-			skb = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE,
+			skb = tipc_msg_create(net, TIPC_CRITICAL_IMPORTANCE,
 					      TIPC_CONN_MSG, SHORT_H_SIZE,
-					      0, dnode, tipc_own_addr,
+					      0, dnode, tn->own_addr,
 					      tsk_peer_port(tsk),
 					      tsk->portid, TIPC_CONN_SHUTDOWN);
 			tipc_link_xmit_skb(net, skb, dnode, tsk->portid);
@@ -2107,6 +2117,8 @@ static void tipc_sk_timeout(unsigned long data)
 {
 	struct tipc_sock *tsk = (struct tipc_sock *)data;
 	struct sock *sk = &tsk->sk;
+	struct net *net = sock_net(sk);
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct sk_buff *skb = NULL;
 	u32 peer_port, peer_node;
 
@@ -2120,13 +2132,13 @@ static void tipc_sk_timeout(unsigned long data)
 
 	if (tsk->probing_state == TIPC_CONN_PROBING) {
 		/* Previous probe not answered -> self abort */
-		skb = tipc_msg_create(TIPC_CRITICAL_IMPORTANCE, TIPC_CONN_MSG,
-				      SHORT_H_SIZE, 0, tipc_own_addr,
-				      peer_node, tsk->portid, peer_port,
-				      TIPC_ERR_NO_PORT);
+		skb = tipc_msg_create(net, TIPC_CRITICAL_IMPORTANCE,
+				      TIPC_CONN_MSG, SHORT_H_SIZE, 0,
+				      tn->own_addr, peer_node, tsk->portid,
+				      peer_port, TIPC_ERR_NO_PORT);
 	} else {
-		skb = tipc_msg_create(CONN_MANAGER, CONN_PROBE, INT_H_SIZE,
-				      0, peer_node, tipc_own_addr,
+		skb = tipc_msg_create(net, CONN_MANAGER, CONN_PROBE, INT_H_SIZE,
+				      0, peer_node, tn->own_addr,
 				      peer_port, tsk->portid, TIPC_OK);
 		tsk->probing_state = TIPC_CONN_PROBING;
 		if (!mod_timer(&tsk->timer, jiffies + tsk->probing_intv))
@@ -2198,14 +2210,16 @@ static int tipc_sk_withdraw(struct tipc_sock *tsk, uint scope,
 static int tipc_sk_show(struct tipc_sock *tsk, char *buf,
 			int len, int full_id)
 {
+	struct net *net = sock_net(&tsk->sk);
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct publication *publ;
 	int ret;
 
 	if (full_id)
 		ret = tipc_snprintf(buf, len, "<%u.%u.%u:%u>:",
-				    tipc_zone(tipc_own_addr),
-				    tipc_cluster(tipc_own_addr),
-				    tipc_node(tipc_own_addr), tsk->portid);
+				    tipc_zone(tn->own_addr),
+				    tipc_cluster(tn->own_addr),
+				    tipc_node(tn->own_addr), tsk->portid);
 	else
 		ret = tipc_snprintf(buf, len, "%-10u:", tsk->portid);
 
@@ -2296,8 +2310,8 @@ void tipc_sk_reinit(struct net *net)
 		rht_for_each_entry_rcu(tsk, pos, tbl, i, node) {
 			spin_lock_bh(&tsk->sk.sk_lock.slock);
 			msg = &tsk->phdr;
-			msg_set_prevnode(msg, tipc_own_addr);
-			msg_set_orignode(msg, tipc_own_addr);
+			msg_set_prevnode(msg, tn->own_addr);
+			msg_set_orignode(msg, tn->own_addr);
 			spin_unlock_bh(&tsk->sk.sk_lock.slock);
 		}
 	}
@@ -2691,6 +2705,8 @@ static int __tipc_nl_add_sk(struct sk_buff *skb, struct netlink_callback *cb,
 	int err;
 	void *hdr;
 	struct nlattr *attrs;
+	struct net *net = sock_net(skb->sk);
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 
 	hdr = genlmsg_put(skb, NETLINK_CB(cb->skb).portid, cb->nlh->nlmsg_seq,
 			  &tipc_genl_v2_family, NLM_F_MULTI, TIPC_NL_SOCK_GET);
@@ -2702,7 +2718,7 @@ static int __tipc_nl_add_sk(struct sk_buff *skb, struct netlink_callback *cb,
 		goto genlmsg_cancel;
 	if (nla_put_u32(skb, TIPC_NLA_SOCK_REF, tsk->portid))
 		goto attr_msg_cancel;
-	if (nla_put_u32(skb, TIPC_NLA_SOCK_ADDR, tipc_own_addr))
+	if (nla_put_u32(skb, TIPC_NLA_SOCK_ADDR, tn->own_addr))
 		goto attr_msg_cancel;
 
 	if (tsk->connected) {
-- 
1.7.9.5
