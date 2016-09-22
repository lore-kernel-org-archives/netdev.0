From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 9/9] rxrpc: Reduce the number of PING ACKs sent
 [ver #2]
Date: Thu, 22 Sep 2016 09:23:03 +0100
Message-ID: <147453258298.14579.5896246590975864224.stgit@warthog.procyon.org.uk>
References: <147453251987.14579.17230566511204847506.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147453251987.14579.17230566511204847506.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We don't want to send a PING ACK for every new incoming call as that just
adds to the network traffic.  Instead, we send a PING ACK to the first
three that we receive and then once per second thereafter.

This could probably be made adjustable in future.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_event.c |    2 +-
 net/rxrpc/input.c      |    7 +++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index adb2ec61e21f..6e2ea8f4ae75 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -142,7 +142,7 @@ static void rxrpc_resend(struct rxrpc_call *call)
 	struct rxrpc_skb_priv *sp;
 	struct sk_buff *skb;
 	rxrpc_seq_t cursor, seq, top;
-	ktime_t now = ktime_get_real(), max_age, oldest, resend_at;
+	ktime_t now = ktime_get_real(), max_age, oldest,  resend_at;
 	int ix;
 	u8 annotation, anno_type;
 
diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index c121949de3c8..cbb5d53f09d7 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -44,9 +44,12 @@ static void rxrpc_send_ping(struct rxrpc_call *call, struct sk_buff *skb,
 			    int skew)
 {
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
+	ktime_t now = skb->tstamp;
 
-	rxrpc_propose_ACK(call, RXRPC_ACK_PING, skew, sp->hdr.serial,
-			  true, true);
+	if (call->peer->rtt_usage < 3 ||
+	    ktime_before(ktime_add_ms(call->peer->rtt_last_req, 1000), now))
+		rxrpc_propose_ACK(call, RXRPC_ACK_PING, skew, sp->hdr.serial,
+				  true, true);
 }
 
 /*
