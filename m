From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 3/9] rxrpc: Add per-peer RTT tracker
Date: Thu, 22 Sep 2016 01:39:29 +0100
Message-ID: <147450476978.14691.9512799255128693593.stgit@warthog.procyon.org.uk>
References: <147450474784.14691.229861132515739820.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57472 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932892AbcIVAjb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 20:39:31 -0400
In-Reply-To: <147450474784.14691.229861132515739820.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a function to track the average RTT for a peer.  Sources of RTT data
will be added in subsequent patches.

The RTT data will be useful in the future for determining resend timeouts
and for handling the slow-start part of the Rx protocol.

Also add a pair of tracepoints, one to log transmissions to elicit a
response for RTT purposes and one to log responses that contribute RTT
data.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   61 ++++++++++++++++++++++++++++++++++++++++++
 net/rxrpc/ar-internal.h      |   25 ++++++++++++++---
 net/rxrpc/misc.c             |    8 ++++++
 net/rxrpc/peer_event.c       |   39 +++++++++++++++++++++++++++
 4 files changed, 129 insertions(+), 4 deletions(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index 75a5d8bf50e1..e8f2afbbe0bf 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -353,6 +353,67 @@ TRACE_EVENT(rxrpc_recvmsg,
 		      __entry->ret)
 	    );
 
+TRACE_EVENT(rxrpc_rtt_tx,
+	    TP_PROTO(struct rxrpc_call *call, enum rxrpc_rtt_tx_trace why,
+		     rxrpc_serial_t send_serial),
+
+	    TP_ARGS(call, why, send_serial),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,	call		)
+		    __field(enum rxrpc_rtt_tx_trace,	why		)
+		    __field(rxrpc_serial_t,		send_serial	)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->call = call;
+		    __entry->why = why;
+		    __entry->send_serial = send_serial;
+			   ),
+
+	    TP_printk("c=%p %s sr=%08x",
+		      __entry->call,
+		      rxrpc_rtt_tx_traces[__entry->why],
+		      __entry->send_serial)
+	    );
+
+TRACE_EVENT(rxrpc_rtt_rx,
+	    TP_PROTO(struct rxrpc_call *call, enum rxrpc_rtt_rx_trace why,
+		     rxrpc_serial_t send_serial, rxrpc_serial_t resp_serial,
+		     s64 rtt, u8 nr, s64 avg),
+
+	    TP_ARGS(call, why, send_serial, resp_serial, rtt, nr, avg),
+
+	    TP_STRUCT__entry(
+		    __field(struct rxrpc_call *,	call		)
+		    __field(enum rxrpc_rtt_rx_trace,	why		)
+		    __field(u8,				nr		)
+		    __field(rxrpc_serial_t,		send_serial	)
+		    __field(rxrpc_serial_t,		resp_serial	)
+		    __field(s64,			rtt		)
+		    __field(u64,			avg		)
+			     ),
+
+	    TP_fast_assign(
+		    __entry->call = call;
+		    __entry->why = why;
+		    __entry->send_serial = send_serial;
+		    __entry->resp_serial = resp_serial;
+		    __entry->rtt = rtt;
+		    __entry->nr = nr;
+		    __entry->avg = avg;
+			   ),
+
+	    TP_printk("c=%p %s sr=%08x rr=%08x rtt=%lld nr=%u avg=%lld",
+		      __entry->call,
+		      rxrpc_rtt_rx_traces[__entry->why],
+		      __entry->send_serial,
+		      __entry->resp_serial,
+		      __entry->rtt,
+		      __entry->nr,
+		      __entry->avg)
+	    );
+
 #endif /* _TRACE_RXRPC_H */
 
 /* This part must be outside protection */
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index dcf54e3fb478..79c671e552c3 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -258,10 +258,11 @@ struct rxrpc_peer {
 
 	/* calculated RTT cache */
 #define RXRPC_RTT_CACHE_SIZE 32
-	suseconds_t		rtt;		/* current RTT estimate (in uS) */
-	unsigned int		rtt_point;	/* next entry at which to insert */
-	unsigned int		rtt_usage;	/* amount of cache actually used */
-	suseconds_t		rtt_cache[RXRPC_RTT_CACHE_SIZE]; /* calculated RTT cache */
+	u64			rtt;		/* Current RTT estimate (in nS) */
+	u64			rtt_sum;	/* Sum of cache contents */
+	u64			rtt_cache[RXRPC_RTT_CACHE_SIZE]; /* Determined RTT cache */
+	u8			rtt_cursor;	/* next entry at which to insert */
+	u8			rtt_usage;	/* amount of cache actually used */
 };
 
 /*
@@ -657,6 +658,20 @@ enum rxrpc_recvmsg_trace {
 
 extern const char rxrpc_recvmsg_traces[rxrpc_recvmsg__nr_trace][5];
 
+enum rxrpc_rtt_tx_trace {
+	rxrpc_rtt_tx_ping,
+	rxrpc_rtt_tx__nr_trace
+};
+
+extern const char rxrpc_rtt_tx_traces[rxrpc_rtt_tx__nr_trace][5];
+
+enum rxrpc_rtt_rx_trace {
+	rxrpc_rtt_rx_ping_response,
+	rxrpc_rtt_rx__nr_trace
+};
+
+extern const char rxrpc_rtt_rx_traces[rxrpc_rtt_rx__nr_trace][5];
+
 extern const char *const rxrpc_pkts[];
 extern const char *rxrpc_acks(u8 reason);
 
@@ -955,6 +970,8 @@ void rxrpc_reject_packets(struct rxrpc_local *);
  */
 void rxrpc_error_report(struct sock *);
 void rxrpc_peer_error_distributor(struct work_struct *);
+void rxrpc_peer_add_rtt(struct rxrpc_call *, enum rxrpc_rtt_rx_trace,
+			rxrpc_serial_t, rxrpc_serial_t, ktime_t, ktime_t);
 
 /*
  * peer_object.c
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index 026e1f2e83ff..6321c23f9a6e 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -182,3 +182,11 @@ const char rxrpc_recvmsg_traces[rxrpc_recvmsg__nr_trace][5] = {
 	[rxrpc_recvmsg_to_be_accepted]	= "TBAC",
 	[rxrpc_recvmsg_return]		= "RETN",
 };
+
+const char rxrpc_rtt_tx_traces[rxrpc_rtt_tx__nr_trace][5] = {
+	[rxrpc_rtt_tx_ping]		= "PING",
+};
+
+const char rxrpc_rtt_rx_traces[rxrpc_rtt_rx__nr_trace][5] = {
+	[rxrpc_rtt_rx_ping_response]	= "PONG",
+};
diff --git a/net/rxrpc/peer_event.c b/net/rxrpc/peer_event.c
index 18276e7cb9e0..1e0818b37507 100644
--- a/net/rxrpc/peer_event.c
+++ b/net/rxrpc/peer_event.c
@@ -305,3 +305,42 @@ void rxrpc_peer_error_distributor(struct work_struct *work)
 	rxrpc_put_peer(peer);
 	_leave("");
 }
+
+/*
+ * Add RTT information to cache.  This is called in softirq mode and has
+ * exclusive access to the peer RTT data.
+ */
+void rxrpc_peer_add_rtt(struct rxrpc_call *call, enum rxrpc_rtt_rx_trace why,
+			rxrpc_serial_t send_serial, rxrpc_serial_t resp_serial,
+			ktime_t send_time, ktime_t resp_time)
+{
+	struct rxrpc_peer *peer = call->peer;
+	s64 rtt;
+	u64 sum = peer->rtt_sum, avg;
+	u8 cursor = peer->rtt_cursor, usage = peer->rtt_usage;
+
+	rtt = ktime_to_ns(ktime_sub(resp_time, send_time));
+	if (rtt < 0)
+		return;
+
+	/* Replace the oldest datum in the RTT buffer */
+	sum -= peer->rtt_cache[cursor];
+	sum += rtt;
+	peer->rtt_cache[cursor] = rtt;
+	peer->rtt_cursor = (cursor + 1) & (RXRPC_RTT_CACHE_SIZE - 1);
+	peer->rtt_sum = sum;
+	if (usage < RXRPC_RTT_CACHE_SIZE) {
+		usage++;
+		peer->rtt_usage = usage;
+	}
+
+	/* Now recalculate the average */
+	if (usage == RXRPC_RTT_CACHE_SIZE)
+		avg = sum / RXRPC_RTT_CACHE_SIZE;
+	else
+		avg = sum / usage;
+
+	peer->rtt = avg;
+	trace_rxrpc_rtt_rx(call, why, send_serial, resp_serial, rtt,
+			   usage, avg);
+}
