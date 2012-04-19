From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 4/6] tcp: Repair socket queues
Date: Thu, 19 Apr 2012 17:41:01 +0400
Message-ID: <4F9015ED.7020607@parallels.com>
References: <4F901572.4040009@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:31344 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752808Ab2DSNlI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Apr 2012 09:41:08 -0400
In-Reply-To: <4F901572.4040009@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reading queues under repair mode is done with recvmsg call.
The queue-under-repair set by TCP_REPAIR_QUEUE option is used
to determine which queue should be read. Thus both send and
receive queue can be read with this.

Caller must pass the MSG_PEEK flag.

Writing to queues is done with sendmsg call and yet again --
the repair-queue option can be used to push data into the
receive queue.

When putting an skb into receive queue a zero tcp header is
appented to its head to address the tcp_hdr(skb)->syn and
the ->fin checks by the (after repair) tcp_recvmsg. These
flags flags are both set to zero and that's why.

The fin cannot be met in the queue while reading the source
socket, since the repair only works for closed/established
sockets and queueing fin packet always changes its state.

The syn in the queue denotes that the respective skb's seq
is "off-by-one" as compared to the actual payload lenght. Thus,
at the rcv queue refill we can just drop this flag and set the
skb's sequences to precice values.

When the repair mode is turned off, the write queue seqs are
updated so that the whole queue is considered to be 'already sent,
waiting for ACKs' (write_seq = snd_nxt <= snd_una). From the
protocol POV the send queue looks like it was sent, but the data
between the write_seq and snd_nxt is lost in the network.

This helps to avoid another sockoption for setting the snd_nxt
sequence. Leaving the whole queue in a 'not yet sent' state (as
it will be after sendmsg-s) will not allow to receive any acks
from the peer since the ack_seq will be after the snd_nxt. Thus
even the ack for the window probe will be dropped and the
connection will be 'locked' with the zero peer window.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
---
 net/ipv4/tcp.c        |   89 +++++++++++++++++++++++++++++++++++++++++++++++--
 net/ipv4/tcp_output.c |    1 +
 2 files changed, 87 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index e38d6f2..47e2f49 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -912,6 +912,39 @@ static inline int select_size(const struct sock *sk, bool sg)
 	return tmp;
 }
 
+static int tcp_send_rcvq(struct sock *sk, struct msghdr *msg, size_t size)
+{
+	struct sk_buff *skb;
+	struct tcp_skb_cb *cb;
+	struct tcphdr *th;
+
+	skb = alloc_skb(size + sizeof(*th), sk->sk_allocation);
+	if (!skb)
+		goto err;
+
+	th = (struct tcphdr *)skb_put(skb, sizeof(*th));
+	skb_reset_transport_header(skb);
+	memset(th, 0, sizeof(*th));
+
+	if (memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size))
+		goto err_free;
+
+	cb = TCP_SKB_CB(skb);
+
+	TCP_SKB_CB(skb)->seq = tcp_sk(sk)->rcv_nxt;
+	TCP_SKB_CB(skb)->end_seq = TCP_SKB_CB(skb)->seq + size;
+	TCP_SKB_CB(skb)->ack_seq = tcp_sk(sk)->snd_una - 1;
+
+	tcp_queue_rcv(sk, skb, sizeof(*th));
+
+	return size;
+
+err_free:
+	kfree_skb(skb);
+err:
+	return -ENOMEM;
+}
+
 int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		size_t size)
 {
@@ -933,6 +966,19 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		if ((err = sk_stream_wait_connect(sk, &timeo)) != 0)
 			goto out_err;
 
+	if (unlikely(tp->repair)) {
+		if (tp->repair_queue == TCP_RECV_QUEUE) {
+			copied = tcp_send_rcvq(sk, msg, size);
+			goto out;
+		}
+
+		err = -EINVAL;
+		if (tp->repair_queue == TCP_NO_QUEUE)
+			goto out_err;
+
+		/* 'common' sending to sendq */
+	}
+
 	/* This should be in poll */
 	clear_bit(SOCK_ASYNC_NOSPACE, &sk->sk_socket->flags);
 
@@ -1089,7 +1135,7 @@ new_segment:
 			if ((seglen -= copy) == 0 && iovlen == 0)
 				goto out;
 
-			if (skb->len < max || (flags & MSG_OOB))
+			if (skb->len < max || (flags & MSG_OOB) || unlikely(tp->repair))
 				continue;
 
 			if (forced_push(tp)) {
@@ -1102,7 +1148,7 @@ new_segment:
 wait_for_sndbuf:
 			set_bit(SOCK_NOSPACE, &sk->sk_socket->flags);
 wait_for_memory:
-			if (copied)
+			if (copied && likely(!tp->repair))
 				tcp_push(sk, flags & ~MSG_MORE, mss_now, TCP_NAGLE_PUSH);
 
 			if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
@@ -1113,7 +1159,7 @@ wait_for_memory:
 	}
 
 out:
-	if (copied)
+	if (copied && likely(!tp->repair))
 		tcp_push(sk, flags, mss_now, tp->nonagle);
 	release_sock(sk);
 	return copied;
@@ -1187,6 +1233,24 @@ static int tcp_recv_urg(struct sock *sk, struct msghdr *msg, int len, int flags)
 	return -EAGAIN;
 }
 
+static int tcp_peek_sndq(struct sock *sk, struct msghdr *msg, int len)
+{
+	struct sk_buff *skb;
+	int copied = 0, err = 0;
+
+	/* XXX -- need to support SO_PEEK_OFF */
+
+	skb_queue_walk(&sk->sk_write_queue, skb) {
+		err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, skb->len);
+		if (err)
+			break;
+
+		copied += skb->len;
+	}
+
+	return err ?: copied;
+}
+
 /* Clean up the receive buffer for full frames taken by the user,
  * then send an ACK if necessary.  COPIED is the number of bytes
  * tcp_recvmsg has given to the user so far, it speeds up the
@@ -1432,6 +1496,21 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (flags & MSG_OOB)
 		goto recv_urg;
 
+	if (unlikely(tp->repair)) {
+		err = -EPERM;
+		if (!(flags & MSG_PEEK))
+			goto out;
+
+		if (tp->repair_queue == TCP_SEND_QUEUE)
+			goto recv_sndq;
+
+		err = -EINVAL;
+		if (tp->repair_queue == TCP_NO_QUEUE)
+			goto out;
+
+		/* 'common' recv queue MSG_PEEK-ing */
+	}
+
 	seq = &tp->copied_seq;
 	if (flags & MSG_PEEK) {
 		peek_seq = tp->copied_seq;
@@ -1783,6 +1862,10 @@ out:
 recv_urg:
 	err = tcp_recv_urg(sk, msg, len, flags);
 	goto out;
+
+recv_sndq:
+	err = tcp_peek_sndq(sk, msg, len);
+	goto out;
 }
 EXPORT_SYMBOL(tcp_recvmsg);
 
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index fa442a6..57a834c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2796,6 +2796,7 @@ void tcp_send_window_probe(struct sock *sk)
 {
 	if (sk->sk_state == TCP_ESTABLISHED) {
 		tcp_sk(sk)->snd_wl1 = tcp_sk(sk)->rcv_nxt - 1;
+		tcp_sk(sk)->snd_nxt = tcp_sk(sk)->write_seq;
 		tcp_xmit_probe_skb(sk, 0);
 	}
 }
-- 
1.5.5.6
