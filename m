From: David Howells <dhowells@redhat.com>
Subject: [PATCH net] rxrpc: Wake up the transmitter if Rx window size
 increases on the peer
Date: Fri, 10 Mar 2017 07:48:49 +0000
Message-ID: <148913212914.28383.13034499448460205789.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The RxRPC ACK packet may contain an extension that includes the peer's
current Rx window size for this call.  We adjust the local Tx window size
to match.  However, the transmitter can stall if the receive window is
reduced to 0 by the peer and then reopened.

This is because the normal way that the transmitter is re-energised is by
dropping something out of our Tx queue and thus making space.  When a
single gap is made, the transmitter is woken up.  However, because there's
nothing in the Tx queue at this point, this doesn't happen.

To fix this, perform a wake_up() any time we see the peer's Rx window size
increasing.

The observable symptom is that calls start failing on ETIMEDOUT and the
following:

	kAFS: SERVER DEAD state=-62

appears in dmesg.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/input.c |   15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index d74921c4969b..18b2ad8be8e2 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -652,6 +652,7 @@ static void rxrpc_input_ackinfo(struct rxrpc_call *call, struct sk_buff *skb,
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	struct rxrpc_peer *peer;
 	unsigned int mtu;
+	bool wake = false;
 	u32 rwind = ntohl(ackinfo->rwind);
 
 	_proto("Rx ACK %%%u Info { rx=%u max=%u rwin=%u jm=%u }",
@@ -659,9 +660,14 @@ static void rxrpc_input_ackinfo(struct rxrpc_call *call, struct sk_buff *skb,
 	       ntohl(ackinfo->rxMTU), ntohl(ackinfo->maxMTU),
 	       rwind, ntohl(ackinfo->jumbo_max));
 
-	if (rwind > RXRPC_RXTX_BUFF_SIZE - 1)
-		rwind = RXRPC_RXTX_BUFF_SIZE - 1;
-	call->tx_winsize = rwind;
+	if (call->tx_winsize != rwind) {
+		if (rwind > RXRPC_RXTX_BUFF_SIZE - 1)
+			rwind = RXRPC_RXTX_BUFF_SIZE - 1;
+		if (rwind > call->tx_winsize)
+			wake = true;
+		call->tx_winsize = rwind;
+	}
+
 	if (call->cong_ssthresh > rwind)
 		call->cong_ssthresh = rwind;
 
@@ -675,6 +681,9 @@ static void rxrpc_input_ackinfo(struct rxrpc_call *call, struct sk_buff *skb,
 		spin_unlock_bh(&peer->lock);
 		_net("Net MTU %u (maxdata %u)", peer->mtu, peer->maxdata);
 	}
+
+	if (wake)
+		wake_up(&call->waitq);
 }
 
 /*
