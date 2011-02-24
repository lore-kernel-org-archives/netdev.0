From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 16/17] tipc: Remove unused message header field for requested number of links
Date: Wed, 23 Feb 2011 20:26:44 -0500
Message-ID: <1298510805-20630-17-git-send-email-paul.gortmaker@windriver.com>
References: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com, netdev@vger.kernel.org,
	Allan Stephens <Allan.Stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34542 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932119Ab1BXB1S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 20:27:18 -0500
In-Reply-To: <1298510805-20630-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Eliminates support for the "number of requested links" field in a neighbor
discovery message. This field was never used and has been removed from
the TIPC 2.0 protocol specification.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c   |    2 +-
 net/tipc/discover.c |   11 +++--------
 net/tipc/discover.h |    3 +--
 net/tipc/msg.c      |    1 -
 net/tipc/msg.h      |   10 ----------
 5 files changed, 5 insertions(+), 22 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 9e2ff0e..f2839b0 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -566,7 +566,7 @@ restart:
 	INIT_LIST_HEAD(&b_ptr->links);
 	if (m_ptr->bcast) {
 		b_ptr->link_req = tipc_disc_init_link_req(b_ptr, &m_ptr->bcast_addr,
-							  bcast_scope, 2);
+							  bcast_scope);
 	}
 	spin_lock_init(&b_ptr->lock);
 	write_unlock_bh(&tipc_net_lock);
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 59a86fc..09ce231 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -67,13 +67,11 @@ struct link_req {
 /**
  * tipc_disc_init_msg - initialize a link setup message
  * @type: message type (request or response)
- * @req_links: number of links associated with message
  * @dest_domain: network domain of node(s) which should respond to message
  * @b_ptr: ptr to bearer issuing message
  */
 
 static struct sk_buff *tipc_disc_init_msg(u32 type,
-					  u32 req_links,
 					  u32 dest_domain,
 					  struct tipc_bearer *b_ptr)
 {
@@ -84,7 +82,6 @@ static struct sk_buff *tipc_disc_init_msg(u32 type,
 		msg = buf_msg(buf);
 		tipc_msg_init(msg, LINK_CONFIG, type, DSC_H_SIZE, dest_domain);
 		msg_set_non_seq(msg, 1);
-		msg_set_req_links(msg, req_links);
 		msg_set_dest_domain(msg, dest_domain);
 		msg_set_bc_netid(msg, tipc_net_id);
 		msg_set_media_addr(msg, &b_ptr->addr);
@@ -191,7 +188,7 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 		spin_unlock_bh(&n_ptr->lock);
 		if ((type == DSC_RESP_MSG) || link_fully_up)
 			return;
-		rbuf = tipc_disc_init_msg(DSC_RESP_MSG, 1, orig, b_ptr);
+		rbuf = tipc_disc_init_msg(DSC_RESP_MSG, orig, b_ptr);
 		if (rbuf != NULL) {
 			b_ptr->media->send_msg(rbuf, b_ptr, &media_addr);
 			buf_discard(rbuf);
@@ -274,15 +271,13 @@ static void disc_timeout(struct link_req *req)
  * @b_ptr: ptr to bearer issuing requests
  * @dest: destination address for request messages
  * @dest_domain: network domain of node(s) which should respond to message
- * @req_links: max number of desired links
  *
  * Returns pointer to link request structure, or NULL if unable to create.
  */
 
 struct link_req *tipc_disc_init_link_req(struct tipc_bearer *b_ptr,
 					 const struct tipc_media_addr *dest,
-					 u32 dest_domain,
-					 u32 req_links)
+					 u32 dest_domain)
 {
 	struct link_req *req;
 
@@ -290,7 +285,7 @@ struct link_req *tipc_disc_init_link_req(struct tipc_bearer *b_ptr,
 	if (!req)
 		return NULL;
 
-	req->buf = tipc_disc_init_msg(DSC_REQ_MSG, req_links, dest_domain, b_ptr);
+	req->buf = tipc_disc_init_msg(DSC_REQ_MSG, dest_domain, b_ptr);
 	if (!req->buf) {
 		kfree(req);
 		return NULL;
diff --git a/net/tipc/discover.h b/net/tipc/discover.h
index 4046d77..e48a167 100644
--- a/net/tipc/discover.h
+++ b/net/tipc/discover.h
@@ -41,8 +41,7 @@ struct link_req;
 
 struct link_req *tipc_disc_init_link_req(struct tipc_bearer *b_ptr,
 					 const struct tipc_media_addr *dest,
-					 u32 dest_domain,
-					 u32 req_links);
+					 u32 dest_domain);
 void tipc_disc_update_link_req(struct link_req *req);
 void tipc_disc_stop_link_req(struct link_req *req);
 
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index e56b9b8..0787e12 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -390,7 +390,6 @@ void tipc_msg_dbg(struct print_buf *buf, struct tipc_msg *msg, const char *str)
 	if (msg_user(msg) ==  LINK_CONFIG) {
 		u32 *raw = (u32 *)msg;
 		struct tipc_media_addr *orig = (struct tipc_media_addr *)&raw[5];
-		tipc_printf(buf, ":REQL(%u):", msg_req_links(msg));
 		tipc_printf(buf, ":DDOM(%x):", msg_dest_domain(msg));
 		tipc_printf(buf, ":NETID(%u):", msg_bc_netid(msg));
 		tipc_media_addr_printf(buf, orig);
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index b1438c7..9d643a1 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -567,16 +567,6 @@ static inline void msg_set_seq_gap(struct tipc_msg *m, u32 n)
 	msg_set_bits(m, 1, 16, 0x1fff, n);
 }
 
-static inline u32 msg_req_links(struct tipc_msg *m)
-{
-	return msg_bits(m, 1, 16, 0xfff);
-}
-
-static inline void msg_set_req_links(struct tipc_msg *m, u32 n)
-{
-	msg_set_bits(m, 1, 16, 0xfff, n);
-}
-
 
 /*
  * Word 2
-- 
1.7.3.3

