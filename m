From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 4/7] tipc: start using the new
	multicast functions
Date: Mon, 14 Jul 2014 23:54:23 -0400
Message-ID: <1405396466-4594-5-git-send-email-jon.maloy@ericsson.com>
References: <1405396466-4594-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, erik.hugne@ericsson.com,
	netdev@vger.kernel.org, Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1405396466-4594-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In this commit, we convert the socket multicast send function to
directly call the new multicast/broadcast function (tipc_bclink_xmit2())
introduced in the previous commit. We do this instead of letting the
call go via the now obsolete tipc_port_mcast_xmit(), hence saving
a call level and some code complexity.

We also remove the initial destination lookup at the message sending
side, and replace that with an unconditional lookup at the receiving
side, including on the sending node itself. This makes the destination
lookup and message transfer more uniform than before.

Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/bcast.c  |    7 ++---
 net/tipc/socket.c |   90 +++++++++++++++++++++++++++++++----------------------
 2 files changed, 56 insertions(+), 41 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 80f5a51..d1d39fa 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -491,7 +491,7 @@ void tipc_bclink_rcv(struct sk_buff *buf)
 	struct tipc_node *node;
 	u32 next_in;
 	u32 seqno;
-	int deferred;
+	int deferred = 0;
 
 	/* Screen out unwanted broadcast messages */
 
@@ -542,7 +542,7 @@ receive:
 			tipc_bclink_unlock();
 			tipc_node_unlock(node);
 			if (likely(msg_mcast(msg)))
-				tipc_port_mcast_rcv(buf, NULL);
+				tipc_sk_mcast_rcv(buf);
 			else
 				kfree_skb(buf);
 		} else if (msg_user(msg) == MSG_BUNDLER) {
@@ -620,8 +620,7 @@ receive:
 		node->bclink.deferred_size += deferred;
 		bclink_update_last_sent(node, seqno);
 		buf = NULL;
-	} else
-		deferred = 0;
+	}
 
 	tipc_bclink_lock();
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index d16550f..ae3d716 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -53,6 +53,7 @@ static void tipc_data_ready(struct sock *sk);
 static void tipc_write_space(struct sock *sk);
 static int tipc_release(struct socket *sock);
 static int tipc_accept(struct socket *sock, struct socket *new_sock, int flags);
+static int tipc_wait_for_sndmsg(struct socket *sock, long *timeo_p);
 
 static const struct proto_ops packet_ops;
 static const struct proto_ops stream_ops;
@@ -534,6 +535,58 @@ static unsigned int tipc_poll(struct file *file, struct socket *sock,
 	return mask;
 }
 
+/**
+ * tipc_sendmcast - send multicast message
+ * @sock: socket structure
+ * @seq: destination address
+ * @iov: message data to send
+ * @dsz: total length of message data
+ * @timeo: timeout to wait for wakeup
+ *
+ * Called from function tipc_sendmsg(), which has done all sanity checks
+ * Returns the number of bytes sent on success, or errno
+ */
+static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
+			  struct iovec *iov, size_t dsz, long timeo)
+{
+	struct sock *sk = sock->sk;
+	struct tipc_msg *mhdr = &tipc_sk(sk)->port.phdr;
+	struct sk_buff *buf;
+	uint mtu;
+	int rc;
+
+	msg_set_type(mhdr, TIPC_MCAST_MSG);
+	msg_set_lookup_scope(mhdr, TIPC_CLUSTER_SCOPE);
+	msg_set_destport(mhdr, 0);
+	msg_set_destnode(mhdr, 0);
+	msg_set_nametype(mhdr, seq->type);
+	msg_set_namelower(mhdr, seq->lower);
+	msg_set_nameupper(mhdr, seq->upper);
+	msg_set_hdr_sz(mhdr, MCAST_H_SIZE);
+
+new_mtu:
+	mtu = tipc_bclink_get_mtu();
+	rc = tipc_msg_build2(mhdr, iov, 0, dsz, mtu, &buf);
+	if (unlikely(rc < 0))
+		return rc;
+
+	do {
+		rc = tipc_bclink_xmit(buf);
+		if (likely(rc >= 0)) {
+			rc = dsz;
+			break;
+		}
+		if (rc == -EMSGSIZE)
+			goto new_mtu;
+		if (rc != -ELINKCONG)
+			break;
+		rc = tipc_wait_for_sndmsg(sock, &timeo);
+		if (rc)
+			kfree_skb_list(buf);
+	} while (!rc);
+	return rc;
+}
+
 /* tipc_sk_mcast_rcv - Deliver multicast message to all destination sockets
  */
 void tipc_sk_mcast_rcv(struct sk_buff *buf)
@@ -670,43 +723,6 @@ static int tipc_wait_for_sndmsg(struct socket *sock, long *timeo_p)
 }
 
 /**
- * tipc_sendmcast - send multicast message
- * @sock: socket structure
- * @seq: destination address
- * @iov: message data to send
- * @dsz: total length of message data
- * @timeo: timeout to wait for wakeup
- *
- * Called from function tipc_sendmsg(), which has done all sanity checks
- * Returns the number of bytes sent on success, or errno
- */
-static int tipc_sendmcast(struct  socket *sock, struct tipc_name_seq *seq,
-			  struct iovec *iov, size_t dsz, long timeo)
-{
-	struct sock *sk = sock->sk;
-	struct tipc_sock *tsk = tipc_sk(sk);
-	int rc;
-
-	do {
-		if (sock->state != SS_READY) {
-			rc = -EOPNOTSUPP;
-			break;
-		}
-		rc = tipc_port_mcast_xmit(&tsk->port, seq, iov, dsz);
-		if (likely(rc >= 0)) {
-			if (sock->state != SS_READY)
-				sock->state = SS_CONNECTING;
-			break;
-		}
-		if (rc != -ELINKCONG)
-			break;
-		rc = tipc_wait_for_sndmsg(sock, &timeo);
-	} while (!rc);
-
-	return rc;
-}
-
-/**
  * tipc_sendmsg - send message in connectionless manner
  * @iocb: if NULL, indicates that socket lock is already held
  * @sock: socket structure
-- 
1.7.9.5


------------------------------------------------------------------------------
Want fast and easy access to all the code in your enterprise? Index and
search up to 200,000 lines of code with a free copy of Black Duck
Code Sight - the same software that powers the world's largest code
search on Ohloh, the Black Duck Open Hub! Try it now.
http://p.sf.net/sfu/bds
