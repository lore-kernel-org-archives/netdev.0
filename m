From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 07/13 net-next-2.6] [TIPC]: Optimize message initialization routine
Date: Fri, 30 May 2008 14:20:42 -0400
Message-ID: <1212171648-27122-8-git-send-email-allan.stephens@windriver.com>
References: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50531 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752664AbYE3SXJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 14:23:09 -0400
In-Reply-To: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch eliminates the rarely-used "error code" argument
when initializing a TIPC message header, since the default
value of zero is the desired result in most cases; the few
exceptional cases now set the error code explicitly.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/bcast.c      |    2 +-
 net/tipc/cluster.c    |    2 +-
 net/tipc/discover.c   |    3 +--
 net/tipc/link.c       |   12 ++++++------
 net/tipc/msg.h        |    3 +--
 net/tipc/name_distr.c |    3 +--
 net/tipc/port.c       |    9 +++++----
 7 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index e788017..0052c07 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -276,7 +276,7 @@ static void bclink_send_nack(struct node *n_ptr)
 	if (buf) {
 		msg = buf_msg(buf);
 		msg_init(msg, BCAST_PROTOCOL, STATE_MSG,
-			 TIPC_OK, INT_H_SIZE, n_ptr->addr);
+			 INT_H_SIZE, n_ptr->addr);
 		msg_set_mc_netid(msg, tipc_net_id);
 		msg_set_bcast_ack(msg, mod(n_ptr->bclink.last_in));
 		msg_set_bcgap_after(msg, n_ptr->bclink.gap_after);
diff --git a/net/tipc/cluster.c b/net/tipc/cluster.c
index 4bb3404..bc1db47 100644
--- a/net/tipc/cluster.c
+++ b/net/tipc/cluster.c
@@ -238,7 +238,7 @@ static struct sk_buff *tipc_cltr_prepare_routing_msg(u32 data_size, u32 dest)
 	if (buf) {
 		msg = buf_msg(buf);
 		memset((char *)msg, 0, size);
-		msg_init(msg, ROUTE_DISTRIBUTOR, 0, TIPC_OK, INT_H_SIZE, dest);
+		msg_init(msg, ROUTE_DISTRIBUTOR, 0, INT_H_SIZE, dest);
 	}
 	return buf;
 }
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index ada213a..64c2028 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -120,8 +120,7 @@ static struct sk_buff *tipc_disc_init_msg(u32 type,
 
 	if (buf) {
 		msg = buf_msg(buf);
-		msg_init(msg, LINK_CONFIG, type, TIPC_OK, DSC_H_SIZE,
-			 dest_domain);
+		msg_init(msg, LINK_CONFIG, type, DSC_H_SIZE, dest_domain);
 		msg_set_non_seq(msg);
 		msg_set_req_links(msg, req_links);
 		msg_set_dest_domain(msg, dest_domain);
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 022cb2f..9784a8e 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -468,7 +468,7 @@ struct link *tipc_link_create(struct bearer *b_ptr, const u32 peer,
 
 	l_ptr->pmsg = (struct tipc_msg *)&l_ptr->proto_msg;
 	msg = l_ptr->pmsg;
-	msg_init(msg, LINK_PROTOCOL, RESET_MSG, TIPC_OK, INT_H_SIZE, l_ptr->addr);
+	msg_init(msg, LINK_PROTOCOL, RESET_MSG, INT_H_SIZE, l_ptr->addr);
 	msg_set_size(msg, sizeof(l_ptr->proto_msg));
 	msg_set_session(msg, (tipc_random & 0xffff));
 	msg_set_bearer_id(msg, b_ptr->identity);
@@ -1128,7 +1128,7 @@ int tipc_link_send_buf(struct link *l_ptr, struct sk_buff *buf)
 
 			if (bundler) {
 				msg_init(&bundler_hdr, MSG_BUNDLER, OPEN_MSG,
-					 TIPC_OK, INT_H_SIZE, l_ptr->addr);
+					 INT_H_SIZE, l_ptr->addr);
 				skb_copy_to_linear_data(bundler, &bundler_hdr,
 							INT_H_SIZE);
 				skb_trim(bundler, INT_H_SIZE);
@@ -1392,7 +1392,7 @@ again:
 
 	msg_dbg(hdr, ">FRAGMENTING>");
 	msg_init(&fragm_hdr, MSG_FRAGMENTER, FIRST_FRAGMENT,
-		 TIPC_OK, INT_H_SIZE, msg_destnode(hdr));
+		 INT_H_SIZE, msg_destnode(hdr));
 	msg_set_link_selector(&fragm_hdr, sender->publ.ref);
 	msg_set_size(&fragm_hdr, max_pkt);
 	msg_set_fragm_no(&fragm_hdr, 1);
@@ -2426,7 +2426,7 @@ void tipc_link_changeover(struct link *l_ptr)
 	}
 
 	msg_init(&tunnel_hdr, CHANGEOVER_PROTOCOL,
-		 ORIGINAL_MSG, TIPC_OK, INT_H_SIZE, l_ptr->addr);
+		 ORIGINAL_MSG, INT_H_SIZE, l_ptr->addr);
 	msg_set_bearer_id(&tunnel_hdr, l_ptr->peer_bearer_id);
 	msg_set_msgcnt(&tunnel_hdr, msgcount);
 	dbg("Link changeover requires %u tunnel messages\n", msgcount);
@@ -2481,7 +2481,7 @@ void tipc_link_send_duplicate(struct link *l_ptr, struct link *tunnel)
 	struct tipc_msg tunnel_hdr;
 
 	msg_init(&tunnel_hdr, CHANGEOVER_PROTOCOL,
-		 DUPLICATE_MSG, TIPC_OK, INT_H_SIZE, l_ptr->addr);
+		 DUPLICATE_MSG, INT_H_SIZE, l_ptr->addr);
 	msg_set_msgcnt(&tunnel_hdr, l_ptr->out_queue_size);
 	msg_set_bearer_id(&tunnel_hdr, l_ptr->peer_bearer_id);
 	iter = l_ptr->first_out;
@@ -2687,7 +2687,7 @@ int tipc_link_send_long_buf(struct link *l_ptr, struct sk_buff *buf)
 	/* Prepare reusable fragment header: */
 
 	msg_init(&fragm_hdr, MSG_FRAGMENTER, FIRST_FRAGMENT,
-		 TIPC_OK, INT_H_SIZE, destaddr);
+		 INT_H_SIZE, destaddr);
 	msg_set_link_selector(&fragm_hdr, msg_link_selector(inmsg));
 	msg_set_long_msgno(&fragm_hdr, mod(l_ptr->long_msg_seq_no++));
 	msg_set_fragm_no(&fragm_hdr, fragm_no);
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index ad487e8..3418ffa 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -696,7 +696,7 @@ static inline u32 msg_tot_importance(struct tipc_msg *m)
 
 
 static inline void msg_init(struct tipc_msg *m, u32 user, u32 type,
-			    u32 err, u32 hsize, u32 destnode)
+			    u32 hsize, u32 destnode)
 {
 	memset(m, 0, hsize);
 	msg_set_version(m);
@@ -705,7 +705,6 @@ static inline void msg_init(struct tipc_msg *m, u32 user, u32 type,
 	msg_set_size(m, hsize);
 	msg_set_prevnode(m, tipc_own_addr);
 	msg_set_type(m, type);
-	msg_set_errcode(m, err);
 	if (!msg_short(m)) {
 		msg_set_orignode(m, tipc_own_addr);
 		msg_set_destnode(m, destnode);
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index aecba5c..10a6989 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -103,8 +103,7 @@ static struct sk_buff *named_prepare_buf(u32 type, u32 size, u32 dest)
 
 	if (buf != NULL) {
 		msg = buf_msg(buf);
-		msg_init(msg, NAME_DISTRIBUTOR, type, TIPC_OK,
-			 LONG_H_SIZE, dest);
+		msg_init(msg, NAME_DISTRIBUTOR, type, LONG_H_SIZE, dest);
 		msg_set_size(msg, LONG_H_SIZE + size);
 	}
 	return buf;
diff --git a/net/tipc/port.c b/net/tipc/port.c
index 4dfef9e..e3e9c12 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -244,8 +244,7 @@ u32 tipc_createport_raw(void *usr_handle,
 	p_ptr->publ.max_pkt = MAX_PKT_DEFAULT;
 	p_ptr->publ.ref = ref;
 	msg = &p_ptr->publ.phdr;
-	msg_init(msg, TIPC_LOW_IMPORTANCE, TIPC_NAMED_MSG, TIPC_OK, LONG_H_SIZE,
-		 0);
+	msg_init(msg, TIPC_LOW_IMPORTANCE, TIPC_NAMED_MSG, LONG_H_SIZE, 0);
 	msg_set_orignode(msg, tipc_own_addr);
 	msg_set_prevnode(msg, tipc_own_addr);
 	msg_set_origport(msg, ref);
@@ -404,7 +403,8 @@ static struct sk_buff *port_build_proto_msg(u32 destport, u32 destnode,
 	buf = buf_acquire(LONG_H_SIZE);
 	if (buf) {
 		msg = buf_msg(buf);
-		msg_init(msg, usr, type, err, LONG_H_SIZE, destnode);
+		msg_init(msg, usr, type, LONG_H_SIZE, destnode);
+		msg_set_errcode(msg, err);
 		msg_set_destport(msg, destport);
 		msg_set_origport(msg, origport);
 		msg_set_destnode(msg, destnode);
@@ -448,7 +448,8 @@ int tipc_reject_msg(struct sk_buff *buf, u32 err)
 		return data_sz;
 	}
 	rmsg = buf_msg(rbuf);
-	msg_init(rmsg, imp, msg_type(msg), err, hdr_sz, msg_orignode(msg));
+	msg_init(rmsg, imp, msg_type(msg), hdr_sz, msg_orignode(msg));
+	msg_set_errcode(rmsg, err);
 	msg_set_destport(rmsg, msg_origport(msg));
 	msg_set_prevnode(rmsg, tipc_own_addr);
 	msg_set_origport(rmsg, msg_destport(msg));
-- 
1.5.3.2

