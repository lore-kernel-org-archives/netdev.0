From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 13/13] rxrpc: Don't request an ACK on the last DATA
 packet of a call's Tx phase
Date: Thu, 06 Oct 2016 11:05:27 +0100
Message-ID: <147574832716.30350.16807641319615333129.stgit@warthog.procyon.org.uk>
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

Don't request an ACK on the last DATA packet of a call's Tx phase as for a
client there will be a reply packet or some sort of ACK to shift phase.  If
the ACK is requested, OpenAFS sends a REQUESTED-ACK ACK with soft-ACKs in
it and doesn't follow up with a hard-ACK.

If we don't set the flag, OpenAFS will send a DELAY ACK that hard-ACKs the
reply data, thereby allowing the call to terminate cleanly.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/output.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/rxrpc/output.c b/net/rxrpc/output.c
index a12cea0cbc05..5dab1ff3a6c2 100644
--- a/net/rxrpc/output.c
+++ b/net/rxrpc/output.c
@@ -307,11 +307,12 @@ int rxrpc_send_data_packet(struct rxrpc_call *call, struct sk_buff *skb,
 	/* If our RTT cache needs working on, request an ACK.  Also request
 	 * ACKs if a DATA packet appears to have been lost.
 	 */
-	if (retrans ||
-	    call->cong_mode == RXRPC_CALL_SLOW_START ||
-	    (call->peer->rtt_usage < 3 && sp->hdr.seq & 1) ||
-	    ktime_before(ktime_add_ms(call->peer->rtt_last_req, 1000),
-			 ktime_get_real()))
+	if (!(sp->hdr.flags & RXRPC_LAST_PACKET) &&
+	    (retrans ||
+	     call->cong_mode == RXRPC_CALL_SLOW_START ||
+	     (call->peer->rtt_usage < 3 && sp->hdr.seq & 1) ||
+	     ktime_before(ktime_add_ms(call->peer->rtt_last_req, 1000),
+			  ktime_get_real())))
 		whdr.flags |= RXRPC_REQUEST_ACK;
 
 	if (IS_ENABLED(CONFIG_AF_RXRPC_INJECT_LOSS)) {
