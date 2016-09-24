From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 4/8] rxrpc: Reinitialise the call ACK and timer
 state for client reply phase
Date: Sun, 25 Sep 2016 00:25:24 +0100
Message-ID: <147475952422.15231.8672647973718593549.stgit@warthog.procyon.org.uk>
References: <147475949656.15231.3434038490632820605.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147475949656.15231.3434038490632820605.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Clear the ACK reason, ACK timer and resend timer when entering the client
reply phase when the first DATA packet is received.  New ACKs will be
proposed once the data is queued.

The resend timer is no longer relevant and we need to cancel ACKs scheduled
to probe for a lost reply.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    1 +
 net/rxrpc/input.c       |    9 +++++++++
 net/rxrpc/misc.c        |    1 +
 3 files changed, 11 insertions(+)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index e3bf9c0e3ad1..cdd35e2b40ba 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -682,6 +682,7 @@ extern const char rxrpc_rtt_rx_traces[rxrpc_rtt_rx__nr_trace][5];
 
 enum rxrpc_timer_trace {
 	rxrpc_timer_begin,
+	rxrpc_timer_init_for_reply,
 	rxrpc_timer_expired,
 	rxrpc_timer_set_for_ack,
 	rxrpc_timer_set_for_resend,
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 757c16f033a0..bda11eb2ab2a 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -149,6 +149,15 @@ static bool rxrpc_receiving_reply(struct rxrpc_call *call)
 {
 	rxrpc_seq_t top = READ_ONCE(call->tx_top);
 
+	if (call->ackr_reason) {
+		spin_lock_bh(&call->lock);
+		call->ackr_reason = 0;
+		call->resend_at = call->expire_at;
+		call->ack_at = call->expire_at;
+		spin_unlock_bh(&call->lock);
+		rxrpc_set_timer(call, rxrpc_timer_init_for_reply);
+	}
+
 	if (!test_bit(RXRPC_CALL_TX_LAST, &call->flags))
 		rxrpc_rotate_tx_window(call, top);
 	if (!test_bit(RXRPC_CALL_TX_LAST, &call->flags)) {
diff --git a/net/rxrpc/misc.c b/net/rxrpc/misc.c
index a473fd7dabaa..901c012a2700 100644
--- a/net/rxrpc/misc.c
+++ b/net/rxrpc/misc.c
@@ -191,6 +191,7 @@ const char rxrpc_rtt_rx_traces[rxrpc_rtt_rx__nr_trace][5] = {
 const char rxrpc_timer_traces[rxrpc_timer__nr_trace][8] = {
 	[rxrpc_timer_begin]			= "Begin ",
 	[rxrpc_timer_expired]			= "*EXPR*",
+	[rxrpc_timer_init_for_reply]		= "IniRpl",
 	[rxrpc_timer_set_for_ack]		= "SetAck",
 	[rxrpc_timer_set_for_send]		= "SetTx ",
 	[rxrpc_timer_set_for_resend]		= "SetRTx",
