From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 3/3] rxrpc: Use MSG_WAITALL to tell sendmsg() to
 temporarily ignore signals
Date: Wed, 18 Oct 2017 12:56:10 +0100
Message-ID: <150832777060.7695.10910539582653058752.stgit@warthog.procyon.org.uk>
References: <150832775000.7695.7720685597577836060.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <150832775000.7695.7720685597577836060.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make AF_RXRPC accept MSG_WAITALL as a flag to sendmsg() to tell it to
ignore signals whilst loading up the message queue, provided progress is
being made in emptying the queue at the other side.

Progress is defined as the base of the transmit window having being
advanced within 2 RTT periods.  If the period is exceeded with no progress,
sendmsg() will return anyway, indicating how much data has been copied, if
any.

Once the supplied buffer is entirely decanted, the sendmsg() will return.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Documentation/networking/rxrpc.txt |   12 ++++
 fs/afs/rxrpc.c                     |   31 +++++++++-
 net/rxrpc/sendmsg.c                |  107 +++++++++++++++++++++++++++---------
 3 files changed, 119 insertions(+), 31 deletions(-)

diff --git a/Documentation/networking/rxrpc.txt b/Documentation/networking/rxrpc.txt
index 1fb5c553aedd..b5407163d53b 100644
--- a/Documentation/networking/rxrpc.txt
+++ b/Documentation/networking/rxrpc.txt
@@ -280,6 +280,18 @@ Interaction with the user of the RxRPC socket:
      nominated by a socket option.
 
 
+Notes on sendmsg:
+
+ (*) MSG_WAITALL can be set to tell sendmsg to ignore signals if the peer is
+     making progress at accepting packets within a reasonable time such that we
+     manage to queue up all the data for transmission.  This requires the
+     client to accept at least one packet per 2*RTT time period.
+
+     If this isn't set, sendmsg() will return immediately, either returning
+     EINTR/ERESTARTSYS if nothing was consumed or returning the amount of data
+     consumed.
+
+
 Notes on recvmsg:
 
  (*) If there's a sequence of data messages belonging to a particular call on
diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 172a4f9747ac..bb1e2caa1720 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -407,7 +407,7 @@ int afs_make_call(struct in_addr *addr, struct afs_call *call, gfp_t gfp,
 		      call->request_size);
 	msg.msg_control		= NULL;
 	msg.msg_controllen	= 0;
-	msg.msg_flags		= (call->send_pages ? MSG_MORE : 0);
+	msg.msg_flags		= MSG_WAITALL | (call->send_pages ? MSG_MORE : 0);
 
 	/* We have to change the state *before* sending the last packet as
 	 * rxrpc might give us the reply before it returns from sending the
@@ -538,15 +538,26 @@ static void afs_deliver_to_call(struct afs_call *call)
  */
 static int afs_wait_for_call_to_complete(struct afs_call *call)
 {
+	signed long rtt2, timeout;
 	int ret;
+	u64 rtt;
+	u32 life, last_life;
 
 	DECLARE_WAITQUEUE(myself, current);
 
 	_enter("");
 
+	rtt = rxrpc_kernel_get_rtt(afs_socket, call->rxcall);
+	rtt2 = nsecs_to_jiffies64(rtt) * 2;
+	if (rtt2 < 2)
+		rtt2 = 2;
+
+	timeout = rtt2;
+	last_life = rxrpc_kernel_check_life(afs_socket, call->rxcall);
+
 	add_wait_queue(&call->waitq, &myself);
 	for (;;) {
-		set_current_state(TASK_INTERRUPTIBLE);
+		set_current_state(TASK_UNINTERRUPTIBLE);
 
 		/* deliver any messages that are in the queue */
 		if (call->state < AFS_CALL_COMPLETE && call->need_attention) {
@@ -556,10 +567,20 @@ static int afs_wait_for_call_to_complete(struct afs_call *call)
 			continue;
 		}
 
-		if (call->state == AFS_CALL_COMPLETE ||
-		    signal_pending(current))
+		if (call->state == AFS_CALL_COMPLETE)
 			break;
-		schedule();
+
+		life = rxrpc_kernel_check_life(afs_socket, call->rxcall);
+		if (timeout == 0 &&
+		    life == last_life && signal_pending(current))
+				break;
+
+		if (life != last_life) {
+			timeout = rtt2;
+			last_life = life;
+		}
+
+		timeout = schedule_timeout(timeout);
 	}
 
 	remove_wait_queue(&call->waitq, &myself);
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index 9ea6f972767e..2d9edc656ca3 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -38,12 +38,86 @@ struct rxrpc_send_params {
 };
 
 /*
+ * Wait for space to appear in the Tx queue or a signal to occur.
+ */
+static int rxrpc_wait_for_tx_window_intr(struct rxrpc_sock *rx,
+					 struct rxrpc_call *call,
+					 long *timeo)
+{
+	for (;;) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		if (call->tx_top - call->tx_hard_ack <
+		    min_t(unsigned int, call->tx_winsize,
+			  call->cong_cwnd + call->cong_extra))
+			return 0;
+
+		if (call->state >= RXRPC_CALL_COMPLETE)
+			return call->error;
+
+		if (signal_pending(current))
+			return sock_intr_errno(*timeo);
+
+		trace_rxrpc_transmit(call, rxrpc_transmit_wait);
+		mutex_unlock(&call->user_mutex);
+		*timeo = schedule_timeout(*timeo);
+		if (mutex_lock_interruptible(&call->user_mutex) < 0)
+			return sock_intr_errno(*timeo);
+	}
+}
+
+/*
+ * Wait for space to appear in the Tx queue uninterruptibly, but with
+ * a timeout of 2*RTT if no progress was made and a signal occurred.
+ */
+static int rxrpc_wait_for_tx_window_nonintr(struct rxrpc_sock *rx,
+					    struct rxrpc_call *call)
+{
+	rxrpc_seq_t tx_start, tx_win;
+	signed long rtt2, timeout;
+	u64 rtt;
+
+	rtt = READ_ONCE(call->peer->rtt);
+	rtt2 = nsecs_to_jiffies64(rtt) * 2;
+	if (rtt2 < 1)
+		rtt2 = 1;
+
+	timeout = rtt2;
+	tx_start = READ_ONCE(call->tx_hard_ack);
+
+	for (;;) {
+		set_current_state(TASK_UNINTERRUPTIBLE);
+
+		tx_win = READ_ONCE(call->tx_hard_ack);
+		if (call->tx_top - tx_win <
+		    min_t(unsigned int, call->tx_winsize,
+			  call->cong_cwnd + call->cong_extra))
+			return 0;
+
+		if (call->state >= RXRPC_CALL_COMPLETE)
+			return call->error;
+
+		if (timeout == 0 &&
+		    tx_win == tx_start && signal_pending(current))
+			return -EINTR;
+
+		if (tx_win != tx_start) {
+			timeout = rtt2;
+			tx_start = tx_win;
+		}
+
+		trace_rxrpc_transmit(call, rxrpc_transmit_wait);
+		timeout = schedule_timeout(timeout);
+	}
+}
+
+/*
  * wait for space to appear in the transmit/ACK window
  * - caller holds the socket locked
  */
 static int rxrpc_wait_for_tx_window(struct rxrpc_sock *rx,
 				    struct rxrpc_call *call,
-				    long *timeo)
+				    long *timeo,
+				    bool waitall)
 {
 	DECLARE_WAITQUEUE(myself, current);
 	int ret;
@@ -53,30 +127,10 @@ static int rxrpc_wait_for_tx_window(struct rxrpc_sock *rx,
 
 	add_wait_queue(&call->waitq, &myself);
 
-	for (;;) {
-		set_current_state(TASK_INTERRUPTIBLE);
-		ret = 0;
-		if (call->tx_top - call->tx_hard_ack <
-		    min_t(unsigned int, call->tx_winsize,
-			  call->cong_cwnd + call->cong_extra))
-			break;
-		if (call->state >= RXRPC_CALL_COMPLETE) {
-			ret = call->error;
-			break;
-		}
-		if (signal_pending(current)) {
-			ret = sock_intr_errno(*timeo);
-			break;
-		}
-
-		trace_rxrpc_transmit(call, rxrpc_transmit_wait);
-		mutex_unlock(&call->user_mutex);
-		*timeo = schedule_timeout(*timeo);
-		if (mutex_lock_interruptible(&call->user_mutex) < 0) {
-			ret = sock_intr_errno(*timeo);
-			break;
-		}
-	}
+	if (waitall)
+		ret = rxrpc_wait_for_tx_window_nonintr(rx, call);
+	else
+		ret = rxrpc_wait_for_tx_window_intr(rx, call, timeo);
 
 	remove_wait_queue(&call->waitq, &myself);
 	set_current_state(TASK_RUNNING);
@@ -254,7 +308,8 @@ static int rxrpc_send_data(struct rxrpc_sock *rx,
 				if (msg->msg_flags & MSG_DONTWAIT)
 					goto maybe_error;
 				ret = rxrpc_wait_for_tx_window(rx, call,
-							       &timeo);
+							       &timeo,
+							       msg->msg_flags & MSG_WAITALL);
 				if (ret < 0)
 					goto maybe_error;
 			}
