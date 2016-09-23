From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 13/15] rxrpc: Add a tracepoint to log injected Rx
 packet loss
Date: Fri, 23 Sep 2016 16:16:47 +0100
Message-ID: <147464380737.5090.16548220325966783358.stgit@warthog.procyon.org.uk>
References: <147464371753.5090.1634919599283321856.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147464371753.5090.1634919599283321856.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add a tracepoint to log received packets that get discarded due to Rx
packet loss.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |   21 +++++++++++++++++++++
 net/rxrpc/input.c            |   11 +++++------
 2 files changed, 26 insertions(+), 6 deletions(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index 6001bf93dc79..9413b17ba04b 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -484,6 +484,27 @@ TRACE_EVENT(rxrpc_timer,
 		      __entry->timer - __entry->now)
 	    );
 
+TRACE_EVENT(rxrpc_rx_lose,
+	    TP_PROTO(struct rxrpc_skb_priv *sp),
+
+	    TP_ARGS(sp),
+
+	    TP_STRUCT__entry(
+		    __field_struct(struct rxrpc_host_header,	hdr		)
+			     ),
+
+	    TP_fast_assign(
+		    memcpy(&__entry->hdr, &sp->hdr, sizeof(__entry->hdr));
+			   ),
+
+	    TP_printk("%08x:%08x:%08x:%04x %08x %08x %02x %02x %s *LOSE*",
+		      __entry->hdr.epoch, __entry->hdr.cid,
+		      __entry->hdr.callNumber, __entry->hdr.serviceId,
+		      __entry->hdr.serial, __entry->hdr.seq,
+		      __entry->hdr.type, __entry->hdr.flags,
+		      __entry->hdr.type <= 15 ? rxrpc_pkts[__entry->hdr.type] : "?UNK")
+	    );
+
 #endif /* _TRACE_RXRPC_H */
 
 /* This part must be outside protection */
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index fb3e2f6afa3b..19b1e189f5dc 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -837,20 +837,19 @@ void rxrpc_data_ready(struct sock *udp_sk)
 	skb_orphan(skb);
 	sp = rxrpc_skb(skb);
 
+	/* dig out the RxRPC connection details */
+	if (rxrpc_extract_header(sp, skb) < 0)
+		goto bad_message;
+
 	if (IS_ENABLED(CONFIG_AF_RXRPC_INJECT_LOSS)) {
 		static int lose;
 		if ((lose++ & 7) == 7) {
+			trace_rxrpc_rx_lose(sp);
 			rxrpc_lose_skb(skb, rxrpc_skb_rx_lost);
 			return;
 		}
 	}
 
-	_net("Rx UDP packet from %08x:%04hu",
-	     ntohl(ip_hdr(skb)->saddr), ntohs(udp_hdr(skb)->source));
-
-	/* dig out the RxRPC connection details */
-	if (rxrpc_extract_header(sp, skb) < 0)
-		goto bad_message;
 	trace_rxrpc_rx_packet(sp);
 
 	_net("Rx RxRPC %s ep=%x call=%x:%x",
