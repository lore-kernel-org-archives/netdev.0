From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 4/7] tipc: disallow packet
	duplicates in link deferred queue
Date: Thu, 15 Oct 2015 14:52:43 -0400
Message-ID: <1444935166-12745-5-git-send-email-jon.maloy@ericsson.com>
References: <1444935166-12745-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1444935166-12745-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

After the previous commits, we are guaranteed that no packets
of type LINK_PROTOCOL or with illegal sequence numbers will be
attempted added to the link deferred queue. This makes it possible to
make some simplifications to the sorting algorithm in the function
tipc_skb_queue_sorted().

We also alter the function so that it will drop packets if one with
the same seqeunce number is already present in the queue. This is
necessary because we have identified weird packet sequences, involving
duplicate packets, where a legitimate in-sequence packet may advance to
the head of the queue without being detected and de-queued.

Finally, we make this function outline, since it will now be called only
in exceptional cases.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/link.c |  2 +-
 net/tipc/msg.c  | 31 +++++++++++++++++++++++++++++++
 net/tipc/msg.h  | 34 ++--------------------------------
 3 files changed, 34 insertions(+), 33 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 2b549f6..e7c6086 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1114,7 +1114,7 @@ int tipc_link_rcv(struct tipc_link *l, struct sk_buff *skb,
 
 		/* Defer delivery if sequence gap */
 		if (unlikely(seqno != rcv_nxt)) {
-			__tipc_skb_queue_sorted(defq, skb);
+			__tipc_skb_queue_sorted(defq, seqno, skb);
 			tipc_link_build_nack_msg(l, xmitq);
 			break;
 		}
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index c5ac436..454f5ec 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -590,3 +590,34 @@ error:
 	kfree_skb(head);
 	return NULL;
 }
+
+/* tipc_skb_queue_sorted(); sort pkt into list according to sequence number
+ * @list: list to be appended to
+ * @seqno: sequence number of buffer to add
+ * @skb: buffer to add
+ */
+void __tipc_skb_queue_sorted(struct sk_buff_head *list, u16 seqno,
+			     struct sk_buff *skb)
+{
+	struct sk_buff *_skb, *tmp;
+
+	if (skb_queue_empty(list) || less(seqno, buf_seqno(skb_peek(list)))) {
+		__skb_queue_head(list, skb);
+		return;
+	}
+
+	if (more(seqno, buf_seqno(skb_peek_tail(list)))) {
+		__skb_queue_tail(list, skb);
+		return;
+	}
+
+	skb_queue_walk_safe(list, _skb, tmp) {
+		if (more(seqno, buf_seqno(_skb)))
+			continue;
+		if (seqno == buf_seqno(_skb))
+			break;
+		__skb_queue_before(list, _skb, skb);
+		return;
+	}
+	kfree_skb(skb);
+}
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 5351a3f..9f0ef54 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -790,6 +790,8 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
 		   int offset, int dsz, int mtu, struct sk_buff_head *list);
 bool tipc_msg_lookup_dest(struct net *net, struct sk_buff *skb, int *err);
 struct sk_buff *tipc_msg_reassemble(struct sk_buff_head *list);
+void __tipc_skb_queue_sorted(struct sk_buff_head *list, u16 seqno,
+			     struct sk_buff *skb);
 
 static inline u16 buf_seqno(struct sk_buff *skb)
 {
@@ -862,38 +864,6 @@ static inline struct sk_buff *tipc_skb_dequeue(struct sk_buff_head *list,
 	return skb;
 }
 
-/* tipc_skb_queue_sorted(); sort pkt into list according to sequence number
- * @list: list to be appended to
- * @skb: buffer to add
- * Returns true if queue should treated further, otherwise false
- */
-static inline bool __tipc_skb_queue_sorted(struct sk_buff_head *list,
-					   struct sk_buff *skb)
-{
-	struct sk_buff *_skb, *tmp;
-	struct tipc_msg *hdr = buf_msg(skb);
-	u16 seqno = msg_seqno(hdr);
-
-	if (skb_queue_empty(list) || (msg_user(hdr) == LINK_PROTOCOL)) {
-		__skb_queue_head(list, skb);
-		return true;
-	}
-	if (likely(less(seqno, buf_seqno(skb_peek(list))))) {
-		__skb_queue_head(list, skb);
-		return true;
-	}
-	if (!more(seqno, buf_seqno(skb_peek_tail(list)))) {
-		skb_queue_walk_safe(list, _skb, tmp) {
-			if (likely(less(seqno, buf_seqno(_skb)))) {
-				__skb_queue_before(list, _skb, skb);
-				return true;
-			}
-		}
-	}
-	__skb_queue_tail(list, skb);
-	return false;
-}
-
 /* tipc_skb_queue_splice_tail - append an skb list to lock protected list
  * @list: the new list to append. Not lock protected
  * @head: target list. Lock protected.
-- 
1.9.1


------------------------------------------------------------------------------
