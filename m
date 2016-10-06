From: David Howells <dhowells@redhat.com>
Subject: [PATCH net 08/13] rxrpc: Queue the call on expiry
Date: Thu, 06 Oct 2016 11:04:52 +0100
Message-ID: <147574829250.30350.15555931926893261458.stgit@warthog.procyon.org.uk>
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

When a call expires, it must be queued for the background processor to deal
with otherwise a service call that is improperly terminated will just sit
there awaiting an ACK and won't expire.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_event.c |   10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index eeea9602cb89..e2a987fd31ce 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -35,8 +35,11 @@ void rxrpc_set_timer(struct rxrpc_call *call, enum rxrpc_timer_trace why,
 
 	if (call->state < RXRPC_CALL_COMPLETE) {
 		t = call->expire_at;
-		if (!ktime_after(t, now))
+		if (!ktime_after(t, now)) {
+			trace_rxrpc_timer(call, why, now, now_j);
+			queue = true;
 			goto out;
+		}
 
 		if (!ktime_after(call->resend_at, now)) {
 			call->resend_at = call->expire_at;
@@ -76,12 +79,11 @@ void rxrpc_set_timer(struct rxrpc_call *call, enum rxrpc_timer_trace why,
 			mod_timer(&call->timer, t_j);
 			trace_rxrpc_timer(call, why, now, now_j);
 		}
-
-		if (queue)
-			rxrpc_queue_call(call);
 	}
 
 out:
+	if (queue)
+		rxrpc_queue_call(call);
 	read_unlock_bh(&call->state_lock);
 }
 
