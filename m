From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 4/9] tipc: split up function
	tipc_msg_eval()
Date: Thu,  5 Feb 2015 08:36:39 -0500
Message-ID: <1423143404-23322-5-git-send-email-jon.maloy@ericsson.com>
References: <1423143404-23322-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1423143404-23322-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The function tipc_msg_eval() is in reality doing two related, but
different tasks. First it tries to find a new destination for named
messages, in case there was no first lookup, or if the first lookup
failed. Second, it does what its name suggests, evaluating the validity
of the message and its destination, and returning an appropriate error
code depending on the result.

This is confusing, and in this commit we choose to break it up into two
functions. A new function, tipc_msg_lookup_dest(), first attempts to find
a new destination, if the message is of the right type. If this lookup
fails, or if the message should not be subject to a second lookup, the
already existing tipc_msg_reverse() is called. This function performs
prepares the message for rejection, if applicable.

Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/msg.c    | 42 +++++++++++++++++++++---------------------
 net/tipc/msg.h    |  9 +++++----
 net/tipc/socket.c | 40 ++++++++++++++++++++++------------------
 3 files changed, 48 insertions(+), 43 deletions(-)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 940d741..697223a 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -411,43 +411,43 @@ bool tipc_msg_reverse(u32 own_addr,  struct sk_buff *buf, u32 *dnode,
 	return true;
 exit:
 	kfree_skb(buf);
+	*dnode = 0;
 	return false;
 }
 
 /**
- * tipc_msg_eval: determine fate of message that found no destination
- * @buf: the buffer containing the message.
- * @dnode: return value: next-hop node, if message to be forwarded
- * @err: error code to use, if message to be rejected
- *
+ * tipc_msg_lookup_dest(): try to find new destination for named message
+ * @skb: the buffer containing the message.
+ * @dnode: return value: next-hop node, if destination found
+ * @err: return value: error code to use, if message to be rejected
  * Does not consume buffer
- * Returns 0 (TIPC_OK) if message ok and we can try again, -TIPC error
- * code if message to be rejected
+ * Returns true if a destination is found, false otherwise
  */
-int tipc_msg_eval(struct net *net, struct sk_buff *buf, u32 *dnode)
+bool tipc_msg_lookup_dest(struct net *net, struct sk_buff *skb,
+			  u32 *dnode, int *err)
 {
-	struct tipc_msg *msg = buf_msg(buf);
+	struct tipc_msg *msg = buf_msg(skb);
 	u32 dport;
 
-	if (msg_type(msg) != TIPC_NAMED_MSG)
-		return -TIPC_ERR_NO_PORT;
-	if (skb_linearize(buf))
-		return -TIPC_ERR_NO_NAME;
-	if (msg_data_sz(msg) > MAX_FORWARD_SIZE)
-		return -TIPC_ERR_NO_NAME;
+	if (!msg_isdata(msg))
+		return false;
+	if (!msg_named(msg))
+		return false;
+	*err = -TIPC_ERR_NO_NAME;
+	if (skb_linearize(skb))
+		return false;
 	if (msg_reroute_cnt(msg) > 0)
-		return -TIPC_ERR_NO_NAME;
-
+		return false;
 	*dnode = addr_domain(net, msg_lookup_scope(msg));
 	dport = tipc_nametbl_translate(net, msg_nametype(msg),
-				       msg_nameinst(msg),
-				       dnode);
+				       msg_nameinst(msg), dnode);
 	if (!dport)
-		return -TIPC_ERR_NO_NAME;
+		return false;
 	msg_incr_reroute_cnt(msg);
 	msg_set_destnode(msg, *dnode);
 	msg_set_destport(msg, dport);
-	return TIPC_OK;
+	*err = TIPC_OK;
+	return true;
 }
 
 /* tipc_msg_reassemble() - clone a buffer chain of fragments and
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index f7ea954..6070299 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -750,18 +750,19 @@ static inline u32 msg_tot_origport(struct tipc_msg *m)
 struct sk_buff *tipc_buf_acquire(u32 size);
 bool tipc_msg_reverse(u32 own_addr, struct sk_buff *buf, u32 *dnode,
 		      int err);
-int tipc_msg_eval(struct net *net, struct sk_buff *buf, u32 *dnode);
 void tipc_msg_init(u32 own_addr, struct tipc_msg *m, u32 user, u32 type,
 		   u32 hsize, u32 destnode);
-struct sk_buff *tipc_msg_create(uint user, uint type,
-				uint hdr_sz, uint data_sz, u32 dnode,
-				u32 onode, u32 dport, u32 oport, int errcode);
+struct sk_buff *tipc_msg_create(uint user, uint type, uint hdr_sz,
+				uint data_sz, u32 dnode, u32 onode,
+				u32 dport, u32 oport, int errcode);
 int tipc_buf_append(struct sk_buff **headbuf, struct sk_buff **buf);
 bool tipc_msg_bundle(struct sk_buff_head *list, struct sk_buff *skb, u32 mtu);
 bool tipc_msg_make_bundle(struct sk_buff_head *list,
 			  struct sk_buff *skb, u32 mtu, u32 dnode);
 int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m,
 		   int offset, int dsz, int mtu, struct sk_buff_head *list);
+bool tipc_msg_lookup_dest(struct net *net, struct sk_buff *skb, u32 *dnode,
+			  int *err);
 struct sk_buff *tipc_msg_reassemble(struct sk_buff_head *list);
 
 #endif
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 1d98bfc..e14b2ae 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1739,7 +1739,7 @@ static int filter_rcv(struct sock *sk, struct sk_buff **skb)
  * @sk: socket
  * @skb: message
  *
- * Caller must hold socket lock, but not port lock.
+ * Caller must hold socket lock
  *
  * Returns 0
  */
@@ -1805,27 +1805,31 @@ int tipc_sk_rcv(struct net *net, struct sk_buff *skb)
 	struct tipc_net *tn;
 	struct sock *sk;
 	u32 dport = msg_destport(buf_msg(skb));
-	int err;
+	int err = -TIPC_ERR_NO_PORT;
 	u32 dnode;
 
-	/* Validate destination and message */
+	/* Find destination */
 	tsk = tipc_sk_lookup(net, dport);
-	if (unlikely(!tsk)) {
-		err = tipc_msg_eval(net, skb, &dnode);
-		goto exit;
-	}
-	sk = &tsk->sk;
-
-	spin_lock_bh(&sk->sk_lock.slock);
-	err = tipc_sk_enqueue_skb(sk, &skb);
-	spin_unlock_bh(&sk->sk_lock.slock);
-	sock_put(sk);
-exit:
-	if (unlikely(skb)) {
-		tn = net_generic(net, tipc_net_id);
-		if (!err || tipc_msg_reverse(tn->own_addr, skb, &dnode, -err))
-			tipc_link_xmit_skb(net, skb, dnode, 0);
+	if (likely(tsk)) {
+		sk = &tsk->sk;
+		spin_lock_bh(&sk->sk_lock.slock);
+		err = tipc_sk_enqueue_skb(sk, &skb);
+		spin_unlock_bh(&sk->sk_lock.slock);
+		sock_put(sk);
 	}
+	if (likely(!skb))
+		return 0;
+	if (tipc_msg_lookup_dest(net, skb, &dnode, &err))
+		goto xmit;
+	if (!err) {
+		dnode = msg_destnode(buf_msg(skb));
+		goto xmit;
+	}
+	tn = net_generic(net, tipc_net_id);
+	if (!tipc_msg_reverse(tn->own_addr, skb, &dnode, -err))
+		return -EHOSTUNREACH;
+xmit:
+	tipc_link_xmit_skb(net, skb, dnode, dport);
 	return err ? -EHOSTUNREACH : 0;
 }
 
-- 
1.9.1


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
