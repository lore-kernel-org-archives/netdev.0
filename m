From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 08/11] rxrpc: Add a tracepoint to follow what
 recvmsg does
Date: Sun, 18 Sep 2016 00:22:25 +0100
Message-ID: <147415454588.18436.997800436433958676.stgit@warthog.procyon.org.uk>
References: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147415448967.18436.14900942726390485534.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a tracepoint to follow what recvmsg does within AF_RXRPC.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   34 ++++++++++++++++++++++++++++++++++
 net/rxrpc/ar-internal.h      |   17 +++++++++++++++++
 net/rxrpc/misc.c             |   14 ++++++++++++++
 net/rxrpc/recvmsg.c          |   34 ++++++++++++++++++++++++++--------
 4 files changed, 91 insertions(+), 8 deletions(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index 7dd5f0188681..58732202e9f0 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -323,6 +323,40 @@ TRACE_EVENT(rxrpc_receive,
 		      __entry->top)
 	    );
 
+TRACE_EVENT(rxrpc_recvmsg,
+	    TP_PROTO(struct rxrpc_call *call, enum rxrpc_recvmsg_trace why,
+		     rxrpc_seq_t seq, unsigned int offset, unsigned int len,
+		     int ret),
+
+	    TP_ARGS(call, why, seq, offset, len, ret),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,	call		)
+		    __field(enum rxrpc_recvmsg_trace,	why		)
+		    __field(rxrpc_seq_t,		seq		)
+		    __field(unsigned int,		offset		)
+		    __field(unsigned int,		len		)
+		    __field(int,			ret		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->call = call;
+		    __entry->why = why;
+		    __entry->seq = seq;
+		    __entry->offset = offset;
+		    __entry->len = len;
+		    __entry->ret = ret;
+			   ),
+
+	    TP_printk("c=%p %s q=%08x o=%u l=%u ret=%d",
+		      __entry->call,
+		      rxrpc_recvmsg_traces[__entry->why],
+		      __entry->seq,
+		      __entry->offset,
+		      __entry->len,
+		      __entry->ret)
+	    );
+
 #endif /* _TRACE_RXRPC_H */
 
 /* This part must be outside protection */
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index e5d2f2fb8e41..a17341d2df3d 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -617,6 +617,23 @@ enum rxrpc_receive_trace {
 
 extern const char rxrpc_receive_traces[rxrpc_receive__nr_trace][4];
 
+enum rxrpc_recvmsg_trace {
+	rxrpc_recvmsg_enter,
+	rxrpc_recvmsg_wait,
+	rxrpc_recvmsg_dequeue,
+	rxrpc_recvmsg_hole,
+	rxrpc_recvmsg_next,
+	rxrpc_recvmsg_cont,
+	rxrpc_recvmsg_full,
+	rxrpc_recvmsg_data_return,
+	rxrpc_recvmsg_terminal,
+	rxrpc_recvmsg_to_be_accepted,
+	rxrpc_recvmsg_return,
+	rxrpc_recvmsg__nr_trace
+};
+
+extern const char rxrpc_recvmsg_traces[rxrpc_recvmsg__nr_trace][5];
+
 extern const char *const rxrpc_pkts[];
 extern const char *rxrpc_acks(u8 reason);
 
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index db5f1d54fc90..c7065d893d1e 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -150,3 +150,17 @@ const char rxrpc_receive_traces[rxrpc_receive__nr_trace][4] = {
 	[rxrpc_receive_rotate]		= "ROT",
 	[rxrpc_receive_end]		= "END",
 };
+
+const char rxrpc_recvmsg_traces[rxrpc_recvmsg__nr_trace][5] = {
+	[rxrpc_recvmsg_enter]		= "ENTR",
+	[rxrpc_recvmsg_wait]		= "WAIT",
+	[rxrpc_recvmsg_dequeue]		= "DEQU",
+	[rxrpc_recvmsg_hole]		= "HOLE",
+	[rxrpc_recvmsg_next]		= "NEXT",
+	[rxrpc_recvmsg_cont]		= "CONT",
+	[rxrpc_recvmsg_full]		= "FULL",
+	[rxrpc_recvmsg_data_return]	= "DATA",
+	[rxrpc_recvmsg_terminal]	= "TERM",
+	[rxrpc_recvmsg_to_be_accepted]	= "TBAC",
+	[rxrpc_recvmsg_return]		= "RETN",
+};
diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index 22d51087c580..b62a08151895 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -94,6 +94,8 @@ static int rxrpc_recvmsg_term(struct rxrpc_call *call, struct msghdr *msg)
 		break;
 	}
 
+	trace_rxrpc_recvmsg(call, rxrpc_recvmsg_terminal, call->rx_hard_ack,
+			    call->rx_pkt_offset, call->rx_pkt_len, ret);
 	return ret;
 }
 
@@ -124,6 +126,7 @@ static int rxrpc_recvmsg_new_call(struct rxrpc_sock *rx,
 		write_unlock(&rx->call_lock);
 	}
 
+	trace_rxrpc_recvmsg(call, rxrpc_recvmsg_to_be_accepted, 1, 0, 0, ret);
 	return ret;
 }
 
@@ -310,8 +313,11 @@ static int rxrpc_recvmsg_data(struct socket *sock, struct rxrpc_call *call,
 	for (seq = hard_ack + 1; before_eq(seq, top); seq++) {
 		ix = seq & RXRPC_RXTX_BUFF_MASK;
 		skb = call->rxtx_buffer[ix];
-		if (!skb)
+		if (!skb) {
+			trace_rxrpc_recvmsg(call, rxrpc_recvmsg_hole, seq,
+					    rx_pkt_offset, rx_pkt_len, 0);
 			break;
+		}
 		smp_rmb();
 		rxrpc_see_skb(skb);
 		sp = rxrpc_skb(skb);
@@ -327,10 +333,15 @@ static int rxrpc_recvmsg_data(struct socket *sock, struct rxrpc_call *call,
 			ret2 = rxrpc_locate_data(call, skb,
 						 &call->rxtx_annotations[ix],
 						 &rx_pkt_offset, &rx_pkt_len);
+			trace_rxrpc_recvmsg(call, rxrpc_recvmsg_next, seq,
+					    rx_pkt_offset, rx_pkt_len, ret2);
 			if (ret2 < 0) {
 				ret = ret2;
 				goto out;
 			}
+		} else {
+			trace_rxrpc_recvmsg(call, rxrpc_recvmsg_cont, seq,
+					    rx_pkt_offset, rx_pkt_len, 0);
 		}
 		_debug("recvmsg %x DATA #%u { %d, %d }",
 		       sp->hdr.callNumber, seq, rx_pkt_offset, rx_pkt_len);
@@ -357,6 +368,8 @@ static int rxrpc_recvmsg_data(struct socket *sock, struct rxrpc_call *call,
 		}
 
 		if (rx_pkt_len > 0) {
+			trace_rxrpc_recvmsg(call, rxrpc_recvmsg_full, seq,
+					    rx_pkt_offset, rx_pkt_len, 0);
 			_debug("buffer full");
 			ASSERTCMP(*_offset, ==, len);
 			ret = 0;
@@ -383,6 +396,8 @@ out:
 		call->rx_pkt_len = rx_pkt_len;
 	}
 done:
+	trace_rxrpc_recvmsg(call, rxrpc_recvmsg_data_return, seq,
+			    rx_pkt_offset, rx_pkt_len, ret);
 	_leave(" = %d [%u/%u]", ret, seq, top);
 	return ret;
 }
@@ -404,7 +419,7 @@ int rxrpc_recvmsg(struct socket *sock, struct msghdr *msg, size_t len,
 
 	DEFINE_WAIT(wait);
 
-	_enter(",,,%zu,%d", len, flags);
+	trace_rxrpc_recvmsg(NULL, rxrpc_recvmsg_enter, 0, 0, 0, 0);
 
 	if (flags & (MSG_OOB | MSG_TRUNC))
 		return -EOPNOTSUPP;
@@ -424,8 +439,10 @@ try_again:
 
 	if (list_empty(&rx->recvmsg_q)) {
 		ret = -EWOULDBLOCK;
-		if (timeo == 0)
+		if (timeo == 0) {
+			call = NULL;
 			goto error_no_call;
+		}
 
 		release_sock(&rx->sk);
 
@@ -439,6 +456,8 @@ try_again:
 		if (list_empty(&rx->recvmsg_q)) {
 			if (signal_pending(current))
 				goto wait_interrupted;
+			trace_rxrpc_recvmsg(NULL, rxrpc_recvmsg_wait,
+					    0, 0, 0, 0);
 			timeo = schedule_timeout(timeo);
 		}
 		finish_wait(sk_sleep(&rx->sk), &wait);
@@ -457,7 +476,7 @@ try_again:
 		rxrpc_get_call(call, rxrpc_call_got);
 	write_unlock_bh(&rx->recvmsg_lock);
 
-	_debug("recvmsg call %p", call);
+	trace_rxrpc_recvmsg(call, rxrpc_recvmsg_dequeue, 0, 0, 0, 0);
 
 	if (test_bit(RXRPC_CALL_RELEASED, &call->flags))
 		BUG();
@@ -527,16 +546,15 @@ error:
 	rxrpc_put_call(call, rxrpc_call_put);
 error_no_call:
 	release_sock(&rx->sk);
-	_leave(" = %d", ret);
+	trace_rxrpc_recvmsg(call, rxrpc_recvmsg_return, 0, 0, 0, ret);
 	return ret;
 
 wait_interrupted:
 	ret = sock_intr_errno(timeo);
 wait_error:
 	finish_wait(sk_sleep(&rx->sk), &wait);
-	release_sock(&rx->sk);
-	_leave(" = %d [wait]", ret);
-	return ret;
+	call = NULL;
+	goto error_no_call;
 }
 
 /**
