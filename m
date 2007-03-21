From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 0/5] [RFC] AF_RXRPC socket family implementation [try #3]
Date: Wed, 21 Mar 2007 21:32:09 +0000
Message-ID: <14308.1174512729@redhat.com>
References: <24260.1174500635@redhat.com>  <15256.1174429573@redhat.com> <20070320213657.15afe5fa@lxorguk.ukuu.org.uk> <20070320195856.12853.63473.stgit@warthog.cambridge.redhat.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org, dhowells@redhat.com
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:53647 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751795AbXCUVc6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 17:32:58 -0400
In-Reply-To: <24260.1174500635@redhat.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


David Howells <dhowells@redhat.com> wrote:

> > > - recvmsg not supporting MSG_TRUNC is rather weird and really ought to be
> > > fixed one day as its useful to find out the sizeof message pending when
> > > combined with MSG_PEEK
> > 
> > Hmmm...  I hadn't considered that.  I assumed MSG_TRUNC not to be useful as
> > arbitrarily chopping bits out of the request or reply would seem to be
> > pointless.
> 
> But why do I need to support MSG_TRUNC?  I currently have things arranged so
> that if you do a recvmsg() that doesn't pull everything out of a packet then
> the next time you do a recvmsg() you'll get the next part of the data in that
> packet.  MSG_EOR is flagged when recvmsg copies across the last byte of data
> of a particular phase.

Okay...  I've rewritten my recvmsg implementation for RxRPC.  The one I had
could pull messages belonging to a call off the socket in the wrong order if
two threads both tried to pull simultaneously.

Also:

 (1) If there's a sequence of data messages belonging to a particular call on
     the receive queue, then recvmsg() will keep eating them until it meets
     either a non-data message or a message belonging to a different call or
     until it fills the user buffer.  If it doesn't fill the user buffer, it
     will sleep unless it is non-blocking.

 (2) MSG_PEEK operates similarly, but will return immediately if it has put any
     data in the buffer rather than waiting for further packets to arrive.

 (3) If a packet is only partially consumed in filling a user buffer, then the
     shrunken packet will be left on the front of the queue for the next taker.

 (4) If there is more data to be had on a call (we haven't copied the last byte
     of the last data packet in that phase yet), then MSG_MORE will be flagged.

 (5) MSG_EOR will be flagged on the terminal message of a call.  No more
     messages from that call will be received, and the user ID may be reused.

Patch attached.

David

diff --git a/net/rxrpc/Makefile b/net/rxrpc/Makefile
index 3369534..f12cd28 100644
--- a/net/rxrpc/Makefile
+++ b/net/rxrpc/Makefile
@@ -17,6 +17,7 @@ af-rxrpc-objs := \
 	ar-local.o \
 	ar-output.o \
 	ar-peer.o \
+	ar-recvmsg.o \
 	ar-security.o \
 	ar-skbuff.o \
 	ar-transport.o
diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index b25d931..06963e6 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -385,217 +385,6 @@ out:
 }
 
 /*
- * receive a message from an RxRPC socket
- */
-static int rxrpc_recvmsg(struct kiocb *iocb, struct socket *sock,
-			 struct msghdr *msg, size_t len, int flags)
-{
-	struct rxrpc_skb_priv *sp;
-	struct rxrpc_call *call;
-	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
-	struct sk_buff *skb;
-	int copy, ret, ullen;
-	u32 abort_code;
-
-	_enter(",,,%zu,%d", len, flags);
-
-	if (flags & (MSG_OOB | MSG_TRUNC))
-		return -EOPNOTSUPP;
-
-try_again:
-	if (RB_EMPTY_ROOT(&rx->calls) &&
-	    rx->sk.sk_state != RXRPC_SERVER_LISTENING)
-		return -ENODATA;
-
-	/* receive the next message from the common Rx queue */
-	skb = skb_recv_datagram(&rx->sk, flags, flags & MSG_DONTWAIT, &ret);
-	if (!skb) {
-		_leave(" = %d", ret);
-		return ret;
-	}
-
-	sp = rxrpc_skb(skb);
-	call = sp->call;
-	ASSERT(call != NULL);
-
-	/* make sure we wait for the state to be updated in this call */
-	spin_lock_bh(&call->lock);
-	spin_unlock_bh(&call->lock);
-
-	if (test_bit(RXRPC_CALL_RELEASED, &call->flags)) {
-		_debug("packet from release call");
-		rxrpc_free_skb(skb);
-		goto try_again;
-	}
-
-	rxrpc_get_call(call);
-
-	/* copy the peer address. */
-	if (msg->msg_name && msg->msg_namelen > 0)
-		memcpy(&msg->msg_name, &call->conn->trans->peer->srx,
-		       sizeof(call->conn->trans->peer->srx));
-
-	/* set up the control messages */
-	ullen = msg->msg_flags & MSG_CMSG_COMPAT ? 4 : sizeof(unsigned long);
-
-	sock_recv_timestamp(msg, &rx->sk, skb);
-
-	if (skb->mark == RXRPC_SKB_MARK_NEW_CALL) {
-		_debug("RECV NEW CALL");
-		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_NEW_CALL, 0, &abort_code);
-		if (ret < 0)
-			goto error_requeue_packet;
-		goto done;
-	}
-
-	ret = put_cmsg(msg, SOL_RXRPC, RXRPC_USER_CALL_ID,
-		       ullen, &call->user_call_ID);
-	if (ret < 0)
-		goto error_requeue_packet;
-	ASSERT(test_bit(RXRPC_CALL_HAS_USERID, &call->flags));
-
-	switch (skb->mark) {
-	case RXRPC_SKB_MARK_DATA:
-		_debug("recvmsg DATA #%u { %d, %d }",
-		       ntohl(sp->hdr.seq), skb->len, sp->offset);
-
-		ASSERTCMP(ntohl(sp->hdr.seq), >=, call->rx_data_recv);
-		ASSERTCMP(ntohl(sp->hdr.seq), <=, call->rx_data_recv + 1);
-		call->rx_data_recv = ntohl(sp->hdr.seq);
-
-		ASSERTCMP(ntohl(sp->hdr.seq), >, call->rx_data_eaten);
-
-		copy = skb->len - sp->offset;
-		if (copy > len)
-			copy = len;
-
-		if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
-			ret = skb_copy_datagram_iovec(skb, sp->offset, msg->msg_iov,
-						      copy);
-		} else {
-			ret = skb_copy_and_csum_datagram_iovec(skb, sp->offset,
-							       msg->msg_iov);
-			if (ret == -EINVAL)
-				goto csum_copy_err;
-		}
-
-		if (ret < 0)
-			goto error_requeue_packet;
-
-		/* handle piecemeal consumption of data packets */
-		sp->offset += copy;
-		ret = copy;
-
-		if (sp->hdr.flags & RXRPC_LAST_PACKET)
-			msg->msg_flags |= MSG_EOR;
-
-		if (sp->offset < skb->len) {
-			if (!(flags & MSG_PEEK)) {
-				skb_queue_head(&rx->sk.sk_receive_queue, skb);
-				atomic_add(skb->truesize, &rx->sk.sk_rmem_alloc);
-			}
-		} else if (!(flags & MSG_PEEK)) {
-			if (call->conn->out_clientflag &&
-			    sp->hdr.flags & RXRPC_LAST_PACKET)
-				goto terminal_message;
-		}
-		break;
-
-	case RXRPC_SKB_MARK_FINAL_ACK:
-		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_ACK, 0, &abort_code);
-		if (ret < 0)
-			goto error_requeue_packet;
-		goto terminal_message;
-
-	case RXRPC_SKB_MARK_BUSY:
-		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_BUSY, 0, &abort_code);
-		if (ret < 0)
-			goto error_requeue_packet;
-		goto terminal_message;
-
-	case RXRPC_SKB_MARK_REMOTE_ABORT:
-		abort_code = call->abort_code;
-		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_ABORT,
-			       sizeof(abort_code), &abort_code);
-		if (ret < 0)
-			goto error_requeue_packet;
-		goto terminal_message;
-
-	case RXRPC_SKB_MARK_NET_ERROR:
-		_debug("RECV NET ERROR %d", sp->error);
-		abort_code = sp->error;
-		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_NET_ERROR, 4, &abort_code);
-		if (ret < 0)
-			goto error_requeue_packet;
-		goto terminal_message;
-
-	case RXRPC_SKB_MARK_LOCAL_ERROR:
-		_debug("RECV LOCAL ERROR %d", sp->error);
-		abort_code = sp->error;
-		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_LOCAL_ERROR, 4, &abort_code);
-		if (ret < 0)
-			goto error_requeue_packet;
-		goto terminal_message;
-
-	default:
-		BUG();
-		break;
-	}
-
-done:
-	if (!(flags & MSG_PEEK)) {
-		rxrpc_kill_skb(skb);
-		skb_free_datagram(&rx->sk, skb);
-	}
-	rxrpc_put_call(call);
-	_leave(" = %d", ret);
-  	return ret;
-
-terminal_message:
-	if (!(flags & MSG_PEEK)) {
-		_net("free terminal skb %p", skb);
-		rxrpc_kill_skb(skb);
-		skb_free_datagram(&rx->sk, skb);
-		_debug("RELEASE CALL %d", call->debug_id);
-
-		/* withdraw the user ID mapping so that it's not seen again in
-		 * association with that call */
-		if (test_bit(RXRPC_CALL_HAS_USERID, &call->flags)) {
-			write_lock_bh(&rx->call_lock);
-			rb_erase(&call->sock_node, &call->socket->calls);
-			clear_bit(RXRPC_CALL_HAS_USERID, &call->flags);
-			write_unlock_bh(&rx->call_lock);
-		}
-		read_lock_bh(&call->state_lock);
-		if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
-		    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
-			schedule_work(&call->processor);
-		read_unlock_bh(&call->state_lock);
-	}
-	rxrpc_put_call(call);
-	msg->msg_flags |= MSG_EOR;
-	_leave(" = %d", ret);
-  	return ret;
-
-error_requeue_packet:
-	if (!(flags & MSG_PEEK)) {
-		skb_queue_head(&rx->sk.sk_receive_queue, skb);
-		atomic_add(skb->truesize, &rx->sk.sk_rmem_alloc);
-	}
-	rxrpc_put_call(call);
-	_leave(" = %d", ret);
-  	return ret;
-
-csum_copy_err:
-	rxrpc_kill_skb(skb);
-	skb_kill_datagram(&rx->sk, skb, flags);
-	rxrpc_put_call(call);
-	if (flags & MSG_DONTWAIT)
-		return -EAGAIN;
-	goto try_again;
-}
-
-/*
  * set RxRPC socket options
  */
 static int rxrpc_setsockopt(struct socket *sock, int level, int optname,
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 00ebf1b..213a640 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -580,6 +580,12 @@ extern struct file_operations rxrpc_call_seq_fops;
 extern struct file_operations rxrpc_connection_seq_fops;
 
 /*
+ * ar-recvmsg.c
+ */
+extern int rxrpc_recvmsg(struct kiocb *, struct socket *, struct msghdr *,
+			 size_t, int);
+
+/*
  * ar-security.c
  */
 extern int rxrpc_register_security(struct rxrpc_security *);
diff --git a/net/rxrpc/ar-recvmsg.c b/net/rxrpc/ar-recvmsg.c
new file mode 100644
index 0000000..74e08cc
--- /dev/null
+++ b/net/rxrpc/ar-recvmsg.c
@@ -0,0 +1,362 @@
+/* RxRPC recvmsg() implementation
+ *
+ * Copyright (C) 2007 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/net.h>
+#include <linux/skbuff.h>
+#include <net/sock.h>
+#include <net/af_rxrpc.h>
+#include "ar-internal.h"
+
+/*
+ * removal a call's user ID from the socket tree to make the user ID available
+ * again and so that it won't be seen again in association with that call
+ */
+static void rxrpc_remove_user_ID(struct rxrpc_sock *rx, struct rxrpc_call *call)
+{
+	_debug("RELEASE CALL %d", call->debug_id);
+
+	if (test_bit(RXRPC_CALL_HAS_USERID, &call->flags)) {
+		write_lock_bh(&rx->call_lock);
+		rb_erase(&call->sock_node, &call->socket->calls);
+		clear_bit(RXRPC_CALL_HAS_USERID, &call->flags);
+		write_unlock_bh(&rx->call_lock);
+	}
+
+	read_lock_bh(&call->state_lock);
+	if (!test_bit(RXRPC_CALL_RELEASED, &call->flags) &&
+	    !test_and_set_bit(RXRPC_CALL_RELEASE, &call->events))
+		schedule_work(&call->processor);
+	read_unlock_bh(&call->state_lock);
+}
+
+/*
+ * receive a message from an RxRPC socket
+ */
+int rxrpc_recvmsg(struct kiocb *iocb, struct socket *sock,
+		  struct msghdr *msg, size_t len, int flags)
+{
+	struct rxrpc_skb_priv *sp;
+	struct rxrpc_call *call, *continue_call = NULL;
+	struct rxrpc_sock *rx = rxrpc_sk(sock->sk);
+	struct sk_buff *skb;
+	long timeo;
+	int copy, ret, ullen, offset, copied = 0;
+	u32 abort_code;
+
+	DEFINE_WAIT(wait);
+
+	_enter(",,,%zu,%d", len, flags);
+
+	if (flags & (MSG_OOB | MSG_TRUNC))
+		return -EOPNOTSUPP;
+
+	ullen = msg->msg_flags & MSG_CMSG_COMPAT ? 4 : sizeof(unsigned long);
+
+	timeo = sock_rcvtimeo(&rx->sk, flags & MSG_DONTWAIT);
+	msg->msg_flags |= MSG_MORE;
+
+	lock_sock(&rx->sk);
+
+	for (;;) {
+		/* return immediately if a client socket has no outstanding
+		 * calls */
+		if (RB_EMPTY_ROOT(&rx->calls) &&
+		    rx->sk.sk_state != RXRPC_SERVER_LISTENING) {
+			release_sock(&rx->sk);
+			return -ENODATA;
+		}
+
+		/* get the next message on the Rx queue */
+		skb = skb_peek(&rx->sk.sk_receive_queue);
+		if (!skb) {
+			/* wait for a message to turn up */
+			release_sock(&rx->sk);
+
+			if (msg->msg_flags & MSG_PEEK && copied) {
+				if (continue_call)
+					rxrpc_put_call(continue_call);
+				_leave(" = %d [peekwait]", copied);
+				return copied;
+			}
+
+			prepare_to_wait_exclusive(rx->sk.sk_sleep, &wait,
+						  TASK_INTERRUPTIBLE);
+			ret = sock_error(&rx->sk);
+			if (ret)
+				goto wait_error;
+
+			if (skb_queue_empty(&rx->sk.sk_receive_queue)) {
+				if (signal_pending(current))
+					goto wait_interrupted;
+				timeo = schedule_timeout(timeo);
+			}
+			finish_wait(rx->sk.sk_sleep, &wait);
+			lock_sock(&rx->sk);
+			continue;
+		}
+
+	peek_next_packet:
+		sp = rxrpc_skb(skb);
+		call = sp->call;
+		ASSERT(call != NULL);
+
+		_debug("next pkt %s", rxrpc_pkts[sp->hdr.type]);
+
+		/* make sure we wait for the state to be updated in this call */
+		spin_lock_bh(&call->lock);
+		spin_unlock_bh(&call->lock);
+
+		if (test_bit(RXRPC_CALL_RELEASED, &call->flags)) {
+			_debug("packet from released call");
+			if (skb_dequeue(&rx->sk.sk_receive_queue) != skb)
+				BUG();
+			rxrpc_free_skb(skb);
+			continue;
+		}
+
+		/* determine whether to continue last data receive */
+		if (continue_call) {
+			_debug("maybe cont");
+			if (call != continue_call ||
+			    skb->mark != RXRPC_SKB_MARK_DATA) {
+				release_sock(&rx->sk);
+				rxrpc_put_call(continue_call);
+				_leave(" = %d [noncont]", copied);
+				return copied;
+			}
+		}
+
+		rxrpc_get_call(call);
+
+		/* copy the peer address and timestamp */
+		if (!continue_call) {
+			if (msg->msg_name && msg->msg_namelen > 0)
+				memcpy(&msg->msg_name, &call->conn->trans->peer->srx,
+				       sizeof(call->conn->trans->peer->srx));
+			sock_recv_timestamp(msg, &rx->sk, skb);
+		}
+
+		/* receive the message */
+		if (skb->mark != RXRPC_SKB_MARK_DATA)
+			goto receive_non_data_message;
+
+		_debug("recvmsg DATA #%u { %d, %d }",
+		       ntohl(sp->hdr.seq), skb->len, sp->offset);
+
+		if (!continue_call) {
+			/* only set the control data once per recvmsg() */
+			ret = put_cmsg(msg, SOL_RXRPC, RXRPC_USER_CALL_ID,
+				       ullen, &call->user_call_ID);
+			if (ret < 0)
+				goto copy_error;
+			ASSERT(test_bit(RXRPC_CALL_HAS_USERID, &call->flags));
+		}
+
+		ASSERTCMP(ntohl(sp->hdr.seq), >=, call->rx_data_recv);
+		ASSERTCMP(ntohl(sp->hdr.seq), <=, call->rx_data_recv + 1);
+		call->rx_data_recv = ntohl(sp->hdr.seq);
+
+		ASSERTCMP(ntohl(sp->hdr.seq), >, call->rx_data_eaten);
+
+		offset = sp->offset;
+		copy = skb->len - offset;
+		if (copy > len - copied)
+			copy = len - copied;
+
+		if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
+			ret = skb_copy_datagram_iovec(skb, offset,
+						      msg->msg_iov, copy);
+		} else {
+			ret = skb_copy_and_csum_datagram_iovec(skb, offset,
+							       msg->msg_iov);
+			if (ret == -EINVAL)
+				goto csum_copy_error;
+		}
+
+		if (ret < 0)
+			goto copy_error;
+
+		/* handle piecemeal consumption of data packets */
+		_debug("copied %d+%d", copy, copied);
+
+		offset += copy;
+		copied += copy;
+
+		if (!(flags & MSG_PEEK))
+			sp->offset = offset;
+
+		if (sp->offset < skb->len) {
+			_debug("buffer full");
+			ASSERTCMP(copied, ==, len);
+			break;
+		}
+
+		/* we transferred the whole data packet */
+		if (sp->hdr.flags & RXRPC_LAST_PACKET) {
+			_debug("last");
+			if (call->conn->out_clientflag) {
+				 /* last byte of reply received */
+				ret = copied;
+				goto terminal_message;
+			}
+
+			/* last bit of request received */
+			if (!(flags & MSG_PEEK)) {
+				_debug("eat packet");
+				if (skb_dequeue(&rx->sk.sk_receive_queue) !=
+				    skb)
+					BUG();
+				rxrpc_free_skb(skb);
+			}
+			msg->msg_flags &= ~MSG_MORE;
+			break;
+		}
+
+		/* move on to the next data message */
+		_debug("next");
+		if (!continue_call)
+			continue_call = sp->call;
+		else
+			rxrpc_put_call(call);
+		call = NULL;
+
+		if (flags & MSG_PEEK) {
+			_debug("peek next");
+			skb = skb->next;
+			if (skb == (struct sk_buff *) &rx->sk.sk_receive_queue)
+				break;
+			goto peek_next_packet;
+		}
+
+		_debug("eat packet");
+		if (skb_dequeue(&rx->sk.sk_receive_queue) != skb)
+			BUG();
+		rxrpc_free_skb(skb);
+	}
+
+	/* end of non-terminal data packet reception for the moment */
+	_debug("end rcv data");
+out:
+	release_sock(&rx->sk);
+	if (call)
+		rxrpc_put_call(call);
+	if (continue_call)
+		rxrpc_put_call(continue_call);
+	_leave(" = %d [data]", copied);
+	return copied;
+
+	/* handle non-DATA messages such as aborts, incoming connections and
+	 * final ACKs */
+receive_non_data_message:
+	_debug("non-data");
+
+	if (skb->mark == RXRPC_SKB_MARK_NEW_CALL) {
+		_debug("RECV NEW CALL");
+		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_NEW_CALL, 0, &abort_code);
+		if (ret < 0)
+			goto copy_error;
+		if (!(flags & MSG_PEEK)) {
+			if (skb_dequeue(&rx->sk.sk_receive_queue) != skb)
+				BUG();
+			rxrpc_free_skb(skb);
+		}
+		goto out;
+	}
+
+	ret = put_cmsg(msg, SOL_RXRPC, RXRPC_USER_CALL_ID,
+		       ullen, &call->user_call_ID);
+	if (ret < 0)
+		goto copy_error;
+	ASSERT(test_bit(RXRPC_CALL_HAS_USERID, &call->flags));
+
+	switch (skb->mark) {
+	case RXRPC_SKB_MARK_DATA:
+		BUG();
+	case RXRPC_SKB_MARK_FINAL_ACK:
+		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_ACK, 0, &abort_code);
+		break;
+	case RXRPC_SKB_MARK_BUSY:
+		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_BUSY, 0, &abort_code);
+		break;
+	case RXRPC_SKB_MARK_REMOTE_ABORT:
+		abort_code = call->abort_code;
+		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_ABORT, 4, &abort_code);
+		break;
+	case RXRPC_SKB_MARK_NET_ERROR:
+		_debug("RECV NET ERROR %d", sp->error);
+		abort_code = sp->error;
+		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_NET_ERROR, 4, &abort_code);
+		break;
+	case RXRPC_SKB_MARK_LOCAL_ERROR:
+		_debug("RECV LOCAL ERROR %d", sp->error);
+		abort_code = sp->error;
+		ret = put_cmsg(msg, SOL_RXRPC, RXRPC_LOCAL_ERROR, 4,
+			       &abort_code);
+		break;
+	default:
+		BUG();
+		break;
+	}
+
+	if (ret < 0)
+		goto copy_error;
+
+terminal_message:
+	_debug("terminal");
+	msg->msg_flags &= ~MSG_MORE;
+	msg->msg_flags |= MSG_EOR;
+
+	if (!(flags & MSG_PEEK)) {
+		_net("free terminal skb %p", skb);
+		if (skb_dequeue(&rx->sk.sk_receive_queue) != skb)
+			BUG();
+		rxrpc_free_skb(skb);
+		rxrpc_remove_user_ID(rx, call);
+	}
+
+	release_sock(&rx->sk);
+	rxrpc_put_call(call);
+	if (continue_call)
+		rxrpc_put_call(continue_call);
+	_leave(" = %d", ret);
+	return ret;
+
+copy_error:
+	_debug("copy error");
+	release_sock(&rx->sk);
+	rxrpc_put_call(call);
+	if (continue_call)
+		rxrpc_put_call(continue_call);
+	_leave(" = %d", ret);
+	return ret;
+
+csum_copy_error:
+	_debug("csum error");
+	release_sock(&rx->sk);
+	if (continue_call)
+		rxrpc_put_call(continue_call);
+	rxrpc_kill_skb(skb);
+	skb_kill_datagram(&rx->sk, skb, flags);
+	rxrpc_put_call(call);
+	return -EAGAIN;
+
+wait_interrupted:
+	ret = sock_intr_errno(timeo);
+wait_error:
+	finish_wait(rx->sk.sk_sleep, &wait);
+	if (continue_call)
+		rxrpc_put_call(continue_call);
+	if (copied)
+		copied = ret;
+	_leave(" = %d [waitfail %d]", copied, ret);
+	return copied;
+
+}
