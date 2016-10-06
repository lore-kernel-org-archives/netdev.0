From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 07/13] rxrpc: Partially handle OpenAFS's improper
 termination of calls
Date: Thu, 06 Oct 2016 11:04:45 +0100
Message-ID: <147574828564.30350.1649444077912544776.stgit@warthog.procyon.org.uk>
References: <147574823645.30350.16131031458272035074.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147574823645.30350.16131031458272035074.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

OpenAFS doesn't always correctly terminate client calls that it makes -
this includes calls the OpenAFS servers make to the cache manager service.
It should end the client call with either:

 (1) An ACK that has firstPacket set to one greater than the seq number of
     the reply DATA packet with the LAST_PACKET flag set (thereby
     hard-ACK'ing all packets).  nAcks should be 0 and acks[] should be
     empty (ie. no soft-ACKs).

 (2) An ACKALL packet.

OpenAFS, though, may send an ACK packet with firstPacket set to the last
seq number or less and soft-ACKs listed for all packets up to and including
the last DATA packet.

The transmitter, however, is obliged to keep the call live and the
soft-ACK'd DATA packets around until they're hard-ACK'd as the receiver is
permitted to drop any merely soft-ACK'd packet and request retransmission
by sending an ACK packet with a NACK in it.

Further, OpenAFS will also terminate a client call by beginning the next
client call on the same connection channel.  This implicitly completes the
previous call.

This patch handles implicit ACK of a call on a channel by the reception of
the first packet of the next call on that channel.

If another call doesn't come along to implicitly ACK a call, then we have
to time the call out.  There are some bugs there that will be addressed in
subsequent patches.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/input.c |   37 +++++++++++++++++++++++++++++++++++++
 1 file changed, 37 insertions(+)

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index a6da83f036d6..44fb8d893c7d 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -939,6 +939,33 @@ static void rxrpc_input_call_packet(struct rxrpc_call *call,
 }
 
 /*
+ * Handle a new call on a channel implicitly completing the preceding call on
+ * that channel.
+ *
+ * TODO: If callNumber > call_id + 1, renegotiate security.
+ */
+static void rxrpc_input_implicit_end_call(struct rxrpc_connection *conn,
+					  struct rxrpc_call *call)
+{
+	switch (call->state) {
+	case RXRPC_CALL_SERVER_AWAIT_ACK:
+		rxrpc_call_completed(call);
+		break;
+	case RXRPC_CALL_COMPLETE:
+		break;
+	default:
+		if (rxrpc_abort_call("IMP", call, 0, RX_CALL_DEAD, ESHUTDOWN)) {
+			set_bit(RXRPC_CALL_EV_ABORT, &call->events);
+			rxrpc_queue_call(call);
+		}
+		break;
+	}
+
+	__rxrpc_disconnect_call(conn, call);
+	rxrpc_notify_socket(call);
+}
+
+/*
  * post connection-level events to the connection
  * - this includes challenges, responses, some aborts and call terminal packet
  *   retransmission.
@@ -1146,6 +1173,16 @@ void rxrpc_data_ready(struct sock *udp_sk)
 		}
 
 		call = rcu_dereference(chan->call);
+
+		if (sp->hdr.callNumber > chan->call_id) {
+			if (!(sp->hdr.flags & RXRPC_CLIENT_INITIATED)) {
+				rcu_read_unlock();
+				goto reject_packet;
+			}
+			if (call)
+				rxrpc_input_implicit_end_call(conn, call);
+			call = NULL;
+		}
 	} else {
 		skew = 0;
 		call = NULL;
