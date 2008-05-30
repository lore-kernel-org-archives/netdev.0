From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 13/13 net-next-2.6] [TIPC]: Message rejection rework preparatory changes
Date: Fri, 30 May 2008 14:20:48 -0400
Message-ID: <1212171648-27122-14-git-send-email-allan.stephens@windriver.com>
References: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50578 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751868AbYE3SXP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 14:23:15 -0400
In-Reply-To: <1212171648-27122-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch defines a few new message header manipulation routines,
and generalizes the usefulness of another, in preparation for upcoming
rework of TIPC's message rejection code.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/bcast.c    |    2 +-
 net/tipc/discover.c |    2 +-
 net/tipc/msg.h      |   31 +++++++++++++++++++++++++++++--
 3 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 0052c07..a5883b1 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -571,7 +571,7 @@ static int tipc_bcbearer_send(struct sk_buff *buf,
 		assert(tipc_cltr_bcast_nodes.count != 0);
 		bcbuf_set_acks(buf, tipc_cltr_bcast_nodes.count);
 		msg = buf_msg(buf);
-		msg_set_non_seq(msg);
+		msg_set_non_seq(msg, 1);
 		msg_set_mc_netid(msg, tipc_net_id);
 	}
 
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 64c2028..1657f0e 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -121,7 +121,7 @@ static struct sk_buff *tipc_disc_init_msg(u32 type,
 	if (buf) {
 		msg = buf_msg(buf);
 		msg_init(msg, LINK_CONFIG, type, DSC_H_SIZE, dest_domain);
-		msg_set_non_seq(msg);
+		msg_set_non_seq(msg, 1);
 		msg_set_req_links(msg, req_links);
 		msg_set_dest_domain(msg, dest_domain);
 		msg_set_bc_netid(msg, tipc_net_id);
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index b23619f..7ee6ae2 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -75,6 +75,14 @@ static inline void msg_set_bits(struct tipc_msg *m, u32 w,
 	m->hdr[w] |= htonl(val);
 }
 
+static inline void msg_swap_words(struct tipc_msg *msg, u32 a, u32 b)
+{
+	u32 temp = msg->hdr[a];
+
+	msg->hdr[a] = msg->hdr[b];
+	msg->hdr[b] = temp;
+}
+
 /*
  * Word 0
  */
@@ -119,9 +127,9 @@ static inline int msg_non_seq(struct tipc_msg *m)
 	return msg_bits(m, 0, 20, 1);
 }
 
-static inline void msg_set_non_seq(struct tipc_msg *m)
+static inline void msg_set_non_seq(struct tipc_msg *m, u32 n)
 {
-	msg_set_bits(m, 0, 20, 1, 1);
+	msg_set_bits(m, 0, 20, 1, n);
 }
 
 static inline int msg_dest_droppable(struct tipc_msg *m)
@@ -224,6 +232,25 @@ static inline void msg_set_seqno(struct tipc_msg *m, u32 n)
 	msg_set_bits(m, 2, 0, 0xffff, n);
 }
 
+/*
+ * TIPC may utilize the "link ack #" and "link seq #" fields of a short
+ * message header to hold the destination node for the message, since the
+ * normal "dest node" field isn't present.  This cache is only referenced
+ * when required, so populating the cache of a longer message header is
+ * harmless (as long as the header has the two link sequence fields present).
+ *
+ * Note: Host byte order is OK here, since the info never goes off-card.
+ */
+
+static inline u32 msg_destnode_cache(struct tipc_msg *m)
+{
+	return m->hdr[2];
+}
+
+static inline void msg_set_destnode_cache(struct tipc_msg *m, u32 dnode)
+{
+	m->hdr[2] = dnode;
+}
 
 /*
  * Words 3-10
-- 
1.5.3.2

