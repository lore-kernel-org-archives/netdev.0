From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 06/15] rxrpc: Need to start the resend timer on
 initial transmission
Date: Fri, 23 Sep 2016 16:15:58 +0100
Message-ID: <147464375879.5090.13289253812547192634.stgit@warthog.procyon.org.uk>
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

When a DATA packet has its initial transmission, we may need to start or
adjust the resend timer.  Without this we end up relying on being sent a
NACK to initiate the resend.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |    1 +
 net/rxrpc/call_event.c  |    2 +-
 net/rxrpc/sendmsg.c     |    9 +++++++++
 3 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 808ab750dc6b..9e3ba4dc9578 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -704,6 +704,7 @@ int rxrpc_reject_call(struct rxrpc_sock *);
 /*
  * call_event.c
  */
+void rxrpc_set_timer(struct rxrpc_call *);
 void rxrpc_propose_ACK(struct rxrpc_call *, u8, u16, u32, bool, bool);
 void rxrpc_process_call(struct work_struct *);
 
diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index a2909da5d581..3a7f90a2659c 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -24,7 +24,7 @@
 /*
  * Set the timer
  */
-static void rxrpc_set_timer(struct rxrpc_call *call)
+void rxrpc_set_timer(struct rxrpc_call *call)
 {
 	unsigned long t, now = jiffies;
 
diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index ca3811bfbd17..7cb34b2dfba9 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -146,6 +146,15 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 	if (ret < 0) {
 		_debug("need instant resend %d", ret);
 		rxrpc_instant_resend(call, ix);
+	} else {
+		unsigned long resend_at;
+
+		resend_at = jiffies + msecs_to_jiffies(rxrpc_resend_timeout);
+
+		if (time_before(resend_at, call->resend_at)) {
+			call->resend_at = resend_at;
+			rxrpc_set_timer(call);
+		}
 	}
 
 	rxrpc_free_skb(skb, rxrpc_skb_tx_freed);
