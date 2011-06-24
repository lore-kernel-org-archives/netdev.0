From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 16/20] tipc: Cleanup of message header size terminology
Date: Fri, 24 Jun 2011 18:07:23 -0400
Message-ID: <1308953247-25266-17-git-send-email-paul.gortmaker@windriver.com>
References: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34413 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757383Ab1FXWHx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 18:07:53 -0400
In-Reply-To: <1308953247-25266-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Performs cosmetic cleanup of the symbolic names used to specify TIPC
payload message header sizes. The revised names now more accurately
reflect the payload messages in which they can appear. In addition,
several places where these payload message symbol names were being used
to create non-payload messages have been updated to use the proper
internal message symbolic name.

No functional changes are introduced by this rework.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c       |    4 ++--
 net/tipc/msg.h        |   10 +++++-----
 net/tipc/name_distr.c |    6 +++---
 net/tipc/port.c       |   20 ++++++++++----------
 4 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 5bfe000..f89570c 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1572,7 +1572,7 @@ static struct sk_buff *link_insert_deferred_queue(struct link *l_ptr,
 static int link_recv_buf_validate(struct sk_buff *buf)
 {
 	static u32 min_data_hdr_size[8] = {
-		SHORT_H_SIZE, MCAST_H_SIZE, LONG_H_SIZE, DIR_MSG_H_SIZE,
+		SHORT_H_SIZE, MCAST_H_SIZE, NAMED_H_SIZE, BASIC_H_SIZE,
 		MAX_H_SIZE, MAX_H_SIZE, MAX_H_SIZE, MAX_H_SIZE
 		};
 
@@ -2553,7 +2553,7 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 		u32 msg_sz = msg_size(imsg);
 		u32 fragm_sz = msg_data_sz(fragm);
 		u32 exp_fragm_cnt = msg_sz/fragm_sz + !!(msg_sz % fragm_sz);
-		u32 max =  TIPC_MAX_USER_MSG_SIZE + LONG_H_SIZE;
+		u32 max =  TIPC_MAX_USER_MSG_SIZE + NAMED_H_SIZE;
 		if (msg_type(imsg) == TIPC_MCAST_MSG)
 			max = TIPC_MAX_USER_MSG_SIZE + MCAST_H_SIZE;
 		if (msg_size(imsg) > max) {
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index a58975c..d93178f 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -68,10 +68,10 @@
  * Message header sizes
  */
 
-#define SHORT_H_SIZE              24	/* Connected, in-cluster messages */
-#define DIR_MSG_H_SIZE            32	/* Directly addressed messages */
-#define LONG_H_SIZE               40	/* Named messages */
-#define MCAST_H_SIZE              44	/* Multicast messages */
+#define SHORT_H_SIZE              24	/* In-cluster basic payload message */
+#define BASIC_H_SIZE              32	/* Basic payload message */
+#define NAMED_H_SIZE              40	/* Named payload message */
+#define MCAST_H_SIZE              44	/* Multicast payload message */
 #define INT_H_SIZE                40	/* Internal messages */
 #define MIN_H_SIZE                24	/* Smallest legal TIPC header size */
 #define MAX_H_SIZE                60	/* Largest possible TIPC header size */
@@ -357,7 +357,7 @@ static inline void msg_set_mc_netid(struct tipc_msg *m, u32 p)
 
 static inline int msg_short(struct tipc_msg *m)
 {
-	return msg_hdr_sz(m) == 24;
+	return msg_hdr_sz(m) == SHORT_H_SIZE;
 }
 
 static inline u32 msg_orignode(struct tipc_msg *m)
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index 80025a1..cd356e5 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -94,13 +94,13 @@ static void publ_to_item(struct distr_item *i, struct publication *p)
 
 static struct sk_buff *named_prepare_buf(u32 type, u32 size, u32 dest)
 {
-	struct sk_buff *buf = tipc_buf_acquire(LONG_H_SIZE + size);
+	struct sk_buff *buf = tipc_buf_acquire(INT_H_SIZE + size);
 	struct tipc_msg *msg;
 
 	if (buf != NULL) {
 		msg = buf_msg(buf);
-		tipc_msg_init(msg, NAME_DISTRIBUTOR, type, LONG_H_SIZE, dest);
-		msg_set_size(msg, LONG_H_SIZE + size);
+		tipc_msg_init(msg, NAME_DISTRIBUTOR, type, INT_H_SIZE, dest);
+		msg_set_size(msg, INT_H_SIZE + size);
 	}
 	return buf;
 }
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 5311817..70e9de5 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -222,7 +222,7 @@ struct tipc_port *tipc_createport_raw(void *usr_handle,
 	p_ptr->max_pkt = MAX_PKT_DEFAULT;
 	p_ptr->ref = ref;
 	msg = &p_ptr->phdr;
-	tipc_msg_init(msg, importance, TIPC_NAMED_MSG, LONG_H_SIZE, 0);
+	tipc_msg_init(msg, importance, TIPC_NAMED_MSG, NAMED_H_SIZE, 0);
 	msg_set_origport(msg, ref);
 	INIT_LIST_HEAD(&p_ptr->wait_list);
 	INIT_LIST_HEAD(&p_ptr->subscription.nodesub_list);
@@ -339,10 +339,10 @@ static struct sk_buff *port_build_proto_msg(u32 destport, u32 destnode,
 	struct sk_buff *buf;
 	struct tipc_msg *msg;
 
-	buf = tipc_buf_acquire(LONG_H_SIZE);
+	buf = tipc_buf_acquire(INT_H_SIZE);
 	if (buf) {
 		msg = buf_msg(buf);
-		tipc_msg_init(msg, usr, type, LONG_H_SIZE, destnode);
+		tipc_msg_init(msg, usr, type, INT_H_SIZE, destnode);
 		msg_set_errcode(msg, err);
 		msg_set_destport(msg, destport);
 		msg_set_origport(msg, origport);
@@ -1247,7 +1247,7 @@ int tipc_send2name(u32 ref, struct tipc_name const *name, unsigned int domain,
 	msg_set_type(msg, TIPC_NAMED_MSG);
 	msg_set_orignode(msg, tipc_own_addr);
 	msg_set_origport(msg, ref);
-	msg_set_hdr_sz(msg, LONG_H_SIZE);
+	msg_set_hdr_sz(msg, NAMED_H_SIZE);
 	msg_set_nametype(msg, name->type);
 	msg_set_nameinst(msg, name->instance);
 	msg_set_lookup_scope(msg, tipc_addr_scope(domain));
@@ -1300,7 +1300,7 @@ int tipc_send2port(u32 ref, struct tipc_portid const *dest,
 	msg_set_origport(msg, ref);
 	msg_set_destnode(msg, dest->node);
 	msg_set_destport(msg, dest->ref);
-	msg_set_hdr_sz(msg, DIR_MSG_H_SIZE);
+	msg_set_hdr_sz(msg, BASIC_H_SIZE);
 
 	if (dest->node == tipc_own_addr)
 		res =  tipc_port_recv_sections(p_ptr, num_sect, msg_sect,
@@ -1340,13 +1340,13 @@ int tipc_send_buf2port(u32 ref, struct tipc_portid const *dest,
 	msg_set_origport(msg, ref);
 	msg_set_destnode(msg, dest->node);
 	msg_set_destport(msg, dest->ref);
-	msg_set_hdr_sz(msg, DIR_MSG_H_SIZE);
-	msg_set_size(msg, DIR_MSG_H_SIZE + dsz);
-	if (skb_cow(buf, DIR_MSG_H_SIZE))
+	msg_set_hdr_sz(msg, BASIC_H_SIZE);
+	msg_set_size(msg, BASIC_H_SIZE + dsz);
+	if (skb_cow(buf, BASIC_H_SIZE))
 		return -ENOMEM;
 
-	skb_push(buf, DIR_MSG_H_SIZE);
-	skb_copy_to_linear_data(buf, msg, DIR_MSG_H_SIZE);
+	skb_push(buf, BASIC_H_SIZE);
+	skb_copy_to_linear_data(buf, msg, BASIC_H_SIZE);
 
 	if (dest->node == tipc_own_addr)
 		res = tipc_port_recv_msg(buf);
-- 
1.7.4.4

