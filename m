From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 2/7] tipc: move message
	validation function to msg.c
Date: Fri, 13 Mar 2015 10:27:35 -0400
Message-ID: <1426256860-31208-3-git-send-email-jon.maloy@ericsson.com>
References: <1426256860-31208-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1426256860-31208-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The function link_buf_validate() is in reality re-entrant and context
independent, and will in later commits be called from several locations.
Therefore, we move it to msg.c, make it outline and rename the it to
tipc_msg_validate().

We also make some cosmetic changes to the function.

Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 58 +--------------------------------------------------------
 net/tipc/msg.c  | 42 ++++++++++++++++++++++++++++++++++++++++-
 net/tipc/msg.h  |  5 +++--
 3 files changed, 45 insertions(+), 60 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 98609fd..944c8c6 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1048,61 +1048,6 @@ static void link_retrieve_defq(struct tipc_link *link,
 }
 
 /**
- * link_recv_buf_validate - validate basic format of received message
- *
- * This routine ensures a TIPC message has an acceptable header, and at least
- * as much data as the header indicates it should.  The routine also ensures
- * that the entire message header is stored in the main fragment of the message
- * buffer, to simplify future access to message header fields.
- *
- * Note: Having extra info present in the message header or data areas is OK.
- * TIPC will ignore the excess, under the assumption that it is optional info
- * introduced by a later release of the protocol.
- */
-static int link_recv_buf_validate(struct sk_buff *buf)
-{
-	static u32 min_data_hdr_size[8] = {
-		SHORT_H_SIZE, MCAST_H_SIZE, NAMED_H_SIZE, BASIC_H_SIZE,
-		MAX_H_SIZE, MAX_H_SIZE, MAX_H_SIZE, MAX_H_SIZE
-		};
-
-	struct tipc_msg *msg;
-	u32 tipc_hdr[2];
-	u32 size;
-	u32 hdr_size;
-	u32 min_hdr_size;
-
-	/* If this packet comes from the defer queue, the skb has already
-	 * been validated
-	 */
-	if (unlikely(TIPC_SKB_CB(buf)->deferred))
-		return 1;
-
-	if (unlikely(buf->len < MIN_H_SIZE))
-		return 0;
-
-	msg = skb_header_pointer(buf, 0, sizeof(tipc_hdr), tipc_hdr);
-	if (msg == NULL)
-		return 0;
-
-	if (unlikely(msg_version(msg) != TIPC_VERSION))
-		return 0;
-
-	size = msg_size(msg);
-	hdr_size = msg_hdr_sz(msg);
-	min_hdr_size = msg_isdata(msg) ?
-		min_data_hdr_size[msg_type(msg)] : INT_H_SIZE;
-
-	if (unlikely((hdr_size < min_hdr_size) ||
-		     (size < hdr_size) ||
-		     (buf->len < size) ||
-		     (size - hdr_size > TIPC_MAX_USER_MSG_SIZE)))
-		return 0;
-
-	return pskb_may_pull(buf, hdr_size);
-}
-
-/**
  * tipc_rcv - process TIPC packets/messages arriving from off-node
  * @net: the applicable net namespace
  * @skb: TIPC packet
@@ -1127,7 +1072,7 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 
 	while ((skb = __skb_dequeue(&head))) {
 		/* Ensure message is well-formed */
-		if (unlikely(!link_recv_buf_validate(skb)))
+		if (unlikely(!tipc_msg_validate(skb)))
 			goto discard;
 
 		/* Ensure message data is a single contiguous unit */
@@ -1398,7 +1343,6 @@ static void link_handle_out_of_seq_msg(struct tipc_link *l_ptr,
 
 	if (tipc_link_defer_pkt(&l_ptr->deferred_queue, buf)) {
 		l_ptr->stats.deferred_recv++;
-		TIPC_SKB_CB(buf)->deferred = true;
 		if ((skb_queue_len(&l_ptr->deferred_queue) % 16) == 1)
 			tipc_link_proto_xmit(l_ptr, STATE_MSG, 0, 0, 0, 0, 0);
 	} else {
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index b6eb90c..1364ceb 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/msg.c: TIPC message header routines
  *
- * Copyright (c) 2000-2006, 2014, Ericsson AB
+ * Copyright (c) 2000-2006, 2014-2015, Ericsson AB
  * Copyright (c) 2005, 2010-2011, Wind River Systems
  * All rights reserved.
  *
@@ -181,6 +181,46 @@ err:
 	return 0;
 }
 
+/* tipc_msg_validate - validate basic format of received message
+ *
+ * This routine ensures a TIPC message has an acceptable header, and at least
+ * as much data as the header indicates it should.  The routine also ensures
+ * that the entire message header is stored in the main fragment of the message
+ * buffer, to simplify future access to message header fields.
+ *
+ * Note: Having extra info present in the message header or data areas is OK.
+ * TIPC will ignore the excess, under the assumption that it is optional info
+ * introduced by a later release of the protocol.
+ */
+bool tipc_msg_validate(struct sk_buff *skb)
+{
+	struct tipc_msg *msg;
+	int hdr[2];
+	int msz, hsz, min_hsz, mtype;
+	u8 min_hdr_sz[4] = {
+		SHORT_H_SIZE, MCAST_H_SIZE, NAMED_H_SIZE, BASIC_H_SIZE
+	};
+
+	msg = skb_header_pointer(skb, 0, sizeof(hdr), hdr);
+	if (unlikely(!msg))
+		return false;
+	if (unlikely(TIPC_SKB_CB(skb)->validated))
+		return true;
+	if (unlikely(msg_version(msg) != TIPC_VERSION))
+		return false;
+
+	msz = msg_size(msg);
+	hsz = msg_hdr_sz(msg);
+	mtype = msg_type(msg);
+	min_hsz = msg_isdata(msg) ? min_hdr_sz[mtype] : INT_H_SIZE;
+
+	if (unlikely((hsz < min_hsz) || (msz < hsz) || (skb->len < msz)))
+		return false;
+	if (unlikely((msz - hsz) > TIPC_MAX_USER_MSG_SIZE))
+		return false;
+	TIPC_SKB_CB(skb)->validated = true;
+	return pskb_may_pull(skb, hsz);
+}
 
 /**
  * tipc_msg_build - create buffer chain containing specified header and data
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 7cece64..62306b8 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -1,7 +1,7 @@
 /*
  * net/tipc/msg.h: Include file for TIPC message header routines
  *
- * Copyright (c) 2000-2007, 2014, Ericsson AB
+ * Copyright (c) 2000-2007, 2014-2015 Ericsson AB
  * Copyright (c) 2005-2008, 2010-2011, Wind River Systems
  * All rights reserved.
  *
@@ -92,7 +92,7 @@ struct plist;
 struct tipc_skb_cb {
 	void *handle;
 	struct sk_buff *tail;
-	bool deferred;
+	bool validated;
 	bool wakeup_pending;
 	bool bundling;
 	u16 chain_sz;
@@ -758,6 +758,7 @@ static inline u32 msg_tot_origport(struct tipc_msg *m)
 }
 
 struct sk_buff *tipc_buf_acquire(u32 size);
+bool tipc_msg_validate(struct sk_buff *skb);
 bool tipc_msg_reverse(u32 own_addr, struct sk_buff *buf, u32 *dnode,
 		      int err);
 void tipc_msg_init(u32 own_addr, struct tipc_msg *m, u32 user, u32 type,
-- 
1.9.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
