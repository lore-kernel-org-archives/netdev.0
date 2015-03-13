From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v2 4/7] tipc: extract bundled
	buffers by cloning instead of copying
Date: Fri, 13 Mar 2015 16:08:08 -0400
Message-ID: <1426277291-2427-5-git-send-email-jon.maloy@ericsson.com>
References: <1426277291-2427-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1426277291-2427-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

When we currently extract a bundled buffer from a message bundle in
the function tipc_msg_extract(), we allocate a new buffer and explicitly
copy the linear data area.

This is unnecessary, since we can just clone the buffer and do
skb_pull() on the clone to move the data pointer to the correct
position.

This is what we do in this commit.

Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 45 ++++++++++++---------------------------------
 net/tipc/msg.c  | 30 ++++++++++++++++--------------
 2 files changed, 28 insertions(+), 47 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 8c6639d..56c39b1 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1,7 +1,7 @@
 /*
  * net/tipc/link.c: TIPC link code
  *
- * Copyright (c) 1996-2007, 2012-2014, Ericsson AB
+ * Copyright (c) 1996-2007, 2012-2015, Ericsson AB
  * Copyright (c) 2004-2007, 2010-2013, Wind River Systems
  * All rights reserved.
  *
@@ -1117,7 +1117,7 @@ void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 		ackd = msg_ack(msg);
 
 		/* Release acked messages */
-		if (n_ptr->bclink.recv_permitted)
+		if (likely(n_ptr->bclink.recv_permitted))
 			tipc_bclink_acknowledge(n_ptr, msg_bcast_ack(msg));
 
 		released = 0;
@@ -1712,45 +1712,24 @@ void tipc_link_dup_queue_xmit(struct tipc_link *l_ptr,
 	}
 }
 
-/**
- * buf_extract - extracts embedded TIPC message from another message
- * @skb: encapsulating message buffer
- * @from_pos: offset to extract from
- *
- * Returns a new message buffer containing an embedded message.  The
- * encapsulating buffer is left unchanged.
- */
-static struct sk_buff *buf_extract(struct sk_buff *skb, u32 from_pos)
-{
-	struct tipc_msg *msg = (struct tipc_msg *)(skb->data + from_pos);
-	u32 size = msg_size(msg);
-	struct sk_buff *eb;
-
-	eb = tipc_buf_acquire(size);
-	if (eb)
-		skb_copy_to_linear_data(eb, msg, size);
-	return eb;
-}
-
 /* tipc_link_dup_rcv(): Receive a tunnelled DUPLICATE_MSG packet.
  * Owner node is locked.
  */
-static void tipc_link_dup_rcv(struct tipc_link *l_ptr,
-			      struct sk_buff *t_buf)
+static void tipc_link_dup_rcv(struct tipc_link *link,
+			      struct sk_buff *skb)
 {
-	struct sk_buff *buf;
+	struct sk_buff *iskb;
+	int pos = 0;
 
-	if (!tipc_link_is_up(l_ptr))
+	if (!tipc_link_is_up(link))
 		return;
 
-	buf = buf_extract(t_buf, INT_H_SIZE);
-	if (buf == NULL) {
+	if (!tipc_msg_extract(skb, &iskb, &pos)) {
 		pr_warn("%sfailed to extract inner dup pkt\n", link_co_err);
 		return;
 	}
-
-	/* Add buffer to deferred queue, if applicable: */
-	link_handle_out_of_seq_msg(l_ptr, buf);
+	/* Append buffer to deferred queue, if applicable: */
+	link_handle_out_of_seq_msg(link, iskb);
 }
 
 /*  tipc_link_failover_rcv(): Receive a tunnelled ORIGINAL_MSG packet
@@ -1762,6 +1741,7 @@ static struct sk_buff *tipc_link_failover_rcv(struct tipc_link *l_ptr,
 	struct tipc_msg *t_msg = buf_msg(t_buf);
 	struct sk_buff *buf = NULL;
 	struct tipc_msg *msg;
+	int pos = 0;
 
 	if (tipc_link_is_up(l_ptr))
 		tipc_link_reset(l_ptr);
@@ -1773,8 +1753,7 @@ static struct sk_buff *tipc_link_failover_rcv(struct tipc_link *l_ptr,
 	/* Should there be an inner packet? */
 	if (l_ptr->exp_msg_count) {
 		l_ptr->exp_msg_count--;
-		buf = buf_extract(t_buf, INT_H_SIZE);
-		if (buf == NULL) {
+		if (!tipc_msg_extract(t_buf, &buf, &pos)) {
 			pr_warn("%sno inner failover pkt\n", link_co_err);
 			goto exit;
 		}
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index ff8c64c..333d2ae 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -372,38 +372,40 @@ bool tipc_msg_bundle(struct sk_buff_head *list, struct sk_buff *skb, u32 mtu)
 
 /**
  *  tipc_msg_extract(): extract bundled inner packet from buffer
- *  @skb: linear outer buffer, to be extracted from.
+ *  @skb: buffer to be extracted from.
  *  @iskb: extracted inner buffer, to be returned
- *  @pos: position of msg to be extracted. Returns with pointer of next msg
+ *  @pos: position in outer message of msg to be extracted.
+ *        Returns position of next msg
  *  Consumes outer buffer when last packet extracted
  *  Returns true when when there is an extracted buffer, otherwise false
  */
 bool tipc_msg_extract(struct sk_buff *skb, struct sk_buff **iskb, int *pos)
 {
 	struct tipc_msg *msg;
-	int imsz;
-	struct tipc_msg *imsg;
+	int imsz, offset;
 
+	*iskb = NULL;
 	if (unlikely(skb_linearize(skb)))
-		return false;
+		goto none;
+
 	msg = buf_msg(skb);
-	imsg = (struct tipc_msg *)(msg_data(msg) + *pos);
-	/* Is there space left for shortest possible message? */
-	if (*pos > (msg_data_sz(msg) - SHORT_H_SIZE))
+	offset = msg_hdr_sz(msg) + *pos;
+	if (unlikely(offset > (msg_size(msg) - MIN_H_SIZE)))
 		goto none;
-	imsz = msg_size(imsg);
 
-	/* Is there space left for current message ? */
-	if ((*pos + imsz) > msg_data_sz(msg))
+	*iskb = skb_clone(skb, GFP_ATOMIC);
+	if (unlikely(!*iskb))
 		goto none;
-	*iskb = tipc_buf_acquire(imsz);
-	if (!*iskb)
+	skb_pull(*iskb, offset);
+	imsz = msg_size(buf_msg(*iskb));
+	skb_trim(*iskb, imsz);
+	if (unlikely(!tipc_msg_validate(*iskb)))
 		goto none;
-	skb_copy_to_linear_data(*iskb, imsg, imsz);
 	*pos += align(imsz);
 	return true;
 none:
 	kfree_skb(skb);
+	kfree_skb(*iskb);
 	*iskb = NULL;
 	return false;
 }
-- 
1.9.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
