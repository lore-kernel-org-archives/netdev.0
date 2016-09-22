From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 8/9] rxrpc: Reduce the number of PING ACKs sent
Date: Thu, 22 Sep 2016 01:40:04 +0100
Message-ID: <147450480416.14691.2181748630440433933.stgit@warthog.procyon.org.uk>
References: <147450474784.14691.229861132515739820.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147450474784.14691.229861132515739820.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We don't want to send a PING ACK for every new incoming call as that just
adds to the network traffic.  Instead, we send a PING ACK to the first
three that we receive and then once per second thereafter.

This could probably be made adjustable in future.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/input.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

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
