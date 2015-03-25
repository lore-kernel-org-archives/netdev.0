From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 2/3] tipc: clean up handling of
	link congestion
Date: Wed, 25 Mar 2015 12:07:25 -0400
Message-ID: <1427299646-31680-3-git-send-email-jon.maloy@ericsson.com>
References: <1427299646-31680-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1427299646-31680-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

After the recent changes in message importance handling it becomes
possible to simplify handling of messages and sockets when we
encounter link congestion.

We merge the function tipc_link_cong() into link_schedule_user(),
and simplify the code of the latter. The code should now be
easier to follow, especially regarding return codes and handling
of the message that caused the situation.

In case the scheduling function is unable to pre-allocate a wakeup
message buffer, it now returns -ENOBUFS, which is a more correct
code than the previously used -EHOSTUNREACH.

Reviewed-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c | 104 ++++++++++++++++++++++++++------------------------------
 net/tipc/msg.h  |  28 ++++++---------
 2 files changed, 60 insertions(+), 72 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index b9325a1..58e2460 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -367,28 +367,43 @@ void tipc_link_delete_list(struct net *net, unsigned int bearer_id,
 }
 
 /**
- * link_schedule_user - schedule user for wakeup after congestion
+ * link_schedule_user - schedule a message sender for wakeup after congestion
  * @link: congested link
- * @oport: sending port
- * @chain_sz: size of buffer chain that was attempted sent
- * @imp: importance of message attempted sent
+ * @list: message that was attempted sent
  * Create pseudo msg to send back to user when congestion abates
+ * Only consumes message if there is an error
  */
-static bool link_schedule_user(struct tipc_link *link, u32 oport,
-			       uint chain_sz, uint imp)
+static int link_schedule_user(struct tipc_link *link, struct sk_buff_head *list)
 {
-	struct sk_buff *buf;
+	struct tipc_msg *msg = buf_msg(skb_peek(list));
+	int imp = msg_importance(msg);
+	u32 oport = msg_origport(msg);
+	u32 addr = link_own_addr(link);
+	struct sk_buff *skb;
 
-	buf = tipc_msg_create(SOCK_WAKEUP, 0, INT_H_SIZE, 0,
-			      link_own_addr(link), link_own_addr(link),
-			      oport, 0, 0);
-	if (!buf)
-		return false;
-	TIPC_SKB_CB(buf)->chain_sz = chain_sz;
-	TIPC_SKB_CB(buf)->chain_imp = imp;
-	skb_queue_tail(&link->wakeupq, buf);
+	/* This really cannot happen...  */
+	if (unlikely(imp > TIPC_CRITICAL_IMPORTANCE)) {
+		pr_warn("%s<%s>, send queue full", link_rst_msg, link->name);
+		tipc_link_reset(link);
+		goto err;
+	}
+	/* Non-blocking sender: */
+	if (TIPC_SKB_CB(skb_peek(list))->wakeup_pending)
+		return -ELINKCONG;
+
+	/* Create and schedule wakeup pseudo message */
+	skb = tipc_msg_create(SOCK_WAKEUP, 0, INT_H_SIZE, 0,
+			      addr, addr, oport, 0, 0);
+	if (!skb)
+		goto err;
+	TIPC_SKB_CB(skb)->chain_sz = skb_queue_len(list);
+	TIPC_SKB_CB(skb)->chain_imp = imp;
+	skb_queue_tail(&link->wakeupq, skb);
 	link->stats.link_congs++;
-	return true;
+	return -ELINKCONG;
+err:
+	__skb_queue_purge(list);
+	return -ENOBUFS;
 }
 
 /**
@@ -708,48 +723,15 @@ static void link_state_event(struct tipc_link *l_ptr, unsigned int event)
 	}
 }
 
-/* tipc_link_cong: determine return value and how to treat the
- * sent buffer during link congestion.
- * - For plain, errorless user data messages we keep the buffer and
- *   return -ELINKONG.
- * - For all other messages we discard the buffer and return -EHOSTUNREACH
- * - For TIPC internal messages we also reset the link
- */
-static int tipc_link_cong(struct tipc_link *link, struct sk_buff_head *list)
-{
-	struct sk_buff *skb = skb_peek(list);
-	struct tipc_msg *msg = buf_msg(skb);
-	int imp = msg_importance(msg);
-	u32 oport = msg_tot_origport(msg);
-
-	if (unlikely(imp > TIPC_CRITICAL_IMPORTANCE)) {
-		pr_warn("%s<%s>, send queue full", link_rst_msg, link->name);
-		tipc_link_reset(link);
-		goto drop;
-	}
-	if (unlikely(msg_errcode(msg)))
-		goto drop;
-	if (unlikely(msg_reroute_cnt(msg)))
-		goto drop;
-	if (TIPC_SKB_CB(skb)->wakeup_pending)
-		return -ELINKCONG;
-	if (link_schedule_user(link, oport, skb_queue_len(list), imp))
-		return -ELINKCONG;
-drop:
-	__skb_queue_purge(list);
-	return -EHOSTUNREACH;
-}
-
 /**
  * __tipc_link_xmit(): same as tipc_link_xmit, but destlink is known & locked
  * @link: link to use
  * @list: chain of buffers containing message
  *
- * Consumes the buffer chain, except when returning -ELINKCONG
- * Returns 0 if success, otherwise errno: -ELINKCONG, -EMSGSIZE (plain socket
- * user data messages) or -EHOSTUNREACH (all other messages/senders)
- * Only the socket functions tipc_send_stream() and tipc_send_packet() need
- * to act on the return value, since they may need to do more send attempts.
+ * Consumes the buffer chain, except when returning -ELINKCONG,
+ * since the caller then may want to make more send attempts.
+ * Returns 0 if success, or errno: -ELINKCONG, -EMSGSIZE or -ENOBUFS
+ * Messages at TIPC_SYSTEM_IMPORTANCE are always accepted
  */
 int __tipc_link_xmit(struct net *net, struct tipc_link *link,
 		     struct sk_buff_head *list)
@@ -768,7 +750,7 @@ int __tipc_link_xmit(struct net *net, struct tipc_link *link,
 
 	/* Match backlog limit against msg importance: */
 	if (unlikely(link->backlog[imp].len >= link->backlog[imp].limit))
-		return tipc_link_cong(link, list);
+		return link_schedule_user(link, list);
 
 	if (unlikely(msg_size(msg) > mtu)) {
 		__skb_queue_purge(list);
@@ -820,13 +802,25 @@ static int __tipc_link_xmit_skb(struct tipc_link *link, struct sk_buff *skb)
 	return __tipc_link_xmit(link->owner->net, link, &head);
 }
 
+/* tipc_link_xmit_skb(): send single buffer to destination
+ * Buffers sent via this functon are generally TIPC_SYSTEM_IMPORTANCE
+ * messages, which will not be rejected
+ * The only exception is datagram messages rerouted after secondary
+ * lookup, which are rare and safe to dispose of anyway.
+ * TODO: Return real return value, and let callers use
+ * tipc_wait_for_sendpkt() where applicable
+ */
 int tipc_link_xmit_skb(struct net *net, struct sk_buff *skb, u32 dnode,
 		       u32 selector)
 {
 	struct sk_buff_head head;
+	int rc;
 
 	skb2list(skb, &head);
-	return tipc_link_xmit(net, &head, dnode, selector);
+	rc = tipc_link_xmit(net, &head, dnode, selector);
+	if (rc == -ELINKCONG)
+		kfree_skb(skb);
+	return 0;
 }
 
 /**
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index bd3969a..6445db0 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -240,6 +240,15 @@ static inline void msg_set_size(struct tipc_msg *m, u32 sz)
 	m->hdr[0] = htonl((msg_word(m, 0) & ~0x1ffff) | sz);
 }
 
+static inline unchar *msg_data(struct tipc_msg *m)
+{
+	return ((unchar *)m) + msg_hdr_sz(m);
+}
+
+static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
+{
+	return (struct tipc_msg *)msg_data(m);
+}
 
 /*
  * Word 1
@@ -372,6 +381,8 @@ static inline void msg_set_prevnode(struct tipc_msg *m, u32 a)
 
 static inline u32 msg_origport(struct tipc_msg *m)
 {
+	if (msg_user(m) == MSG_FRAGMENTER)
+		m = msg_get_wrapped(m);
 	return msg_word(m, 4);
 }
 
@@ -467,16 +478,6 @@ static inline void msg_set_nameupper(struct tipc_msg *m, u32 n)
 	msg_set_word(m, 10, n);
 }
 
-static inline unchar *msg_data(struct tipc_msg *m)
-{
-	return ((unchar *)m) + msg_hdr_sz(m);
-}
-
-static inline struct tipc_msg *msg_get_wrapped(struct tipc_msg *m)
-{
-	return (struct tipc_msg *)msg_data(m);
-}
-
 /*
  * Constants and routines used to read and write TIPC internal message headers
  */
@@ -753,13 +754,6 @@ static inline void msg_set_link_tolerance(struct tipc_msg *m, u32 n)
 	msg_set_bits(m, 9, 0, 0xffff, n);
 }
 
-static inline u32 msg_tot_origport(struct tipc_msg *m)
-{
-	if ((msg_user(m) == MSG_FRAGMENTER) && (msg_type(m) == FIRST_FRAGMENT))
-		return msg_origport(msg_get_wrapped(m));
-	return msg_origport(m);
-}
-
 struct sk_buff *tipc_buf_acquire(u32 size);
 bool tipc_msg_validate(struct sk_buff *skb);
 bool tipc_msg_reverse(u32 own_addr, struct sk_buff *buf, u32 *dnode,
-- 
1.9.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
