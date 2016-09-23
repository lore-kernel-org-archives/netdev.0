From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 15/15] rxrpc: Add a tracepoint to log which packets
 will be retransmitted
Date: Fri, 23 Sep 2016 16:17:01 +0100
Message-ID: <147464382130.5090.16209373468795924203.stgit@warthog.procyon.org.uk>
References: <147464371753.5090.1634919599283321856.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39740 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1161258AbcIWPRD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 11:17:03 -0400
In-Reply-To: <147464371753.5090.1634919599283321856.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a tracepoint to log in rxrpc_resend() which packets will be
retransmitted.  Note that if a positive ACK comes in whilst we have dropped
the lock to retransmit another packet, the actual retransmission may not
happen, though some of the effects will (such as altering the congestion
management).

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   27 +++++++++++++++++++++++++++
 net/rxrpc/call_event.c       |    2 ++
 2 files changed, 29 insertions(+)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index d67a8c6b085a..56475497043d 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -543,6 +543,33 @@ TRACE_EVENT(rxrpc_propose_ack,
 		      rxrpc_propose_ack_outcomes[__entry->outcome])
 	    );
 
+TRACE_EVENT(rxrpc_retransmit,
+	    TP_PROTO(struct rxrpc_call *call, rxrpc_seq_t seq, u8 annotation,
+		     s64 expiry),
+
+	    TP_ARGS(call, seq, annotation, expiry),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,	call		)
+		    __field(rxrpc_seq_t,		seq		)
+		    __field(u8,				annotation	)
+		    __field(s64,			expiry		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->call = call;
+		    __entry->seq = seq;
+		    __entry->annotation = annotation;
+		    __entry->expiry = expiry;
+			   ),
+
+	    TP_printk("c=%p q=%x a=%02x xp=%lld",
+		      __entry->call,
+		      __entry->seq,
+		      __entry->annotation,
+		      __entry->expiry)
+	    );
+
 #endif /* _TRACE_RXRPC_H */
 
 /* This part must be outside protection */
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index fd5b11339ffb..a78a92fe5d77 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -196,6 +196,8 @@ static void rxrpc_resend(struct rxrpc_call *call)
 
 		/* Okay, we need to retransmit a packet. */
 		call->rxtx_annotations[ix] = RXRPC_TX_ANNO_RETRANS | annotation;
+		trace_rxrpc_retransmit(call, seq, annotation | anno_type,
+				       ktime_to_ns(ktime_sub(skb->tstamp, max_age)));
 	}
 
 	resend_at = ktime_sub(ktime_add_ms(oldest, rxrpc_resend_timeout), now);
