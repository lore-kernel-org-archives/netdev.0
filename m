From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 01/15] rxrpc: Preset timestamp on Tx sk_buffs
Date: Fri, 23 Sep 2016 16:15:24 +0100
Message-ID: <147464372471.5090.15595625502675969668.stgit@warthog.procyon.org.uk>
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

Set the timestamp on sk_buffs holding packets to be transmitted before
queueing them because the moment the packet is on the queue it can be seen
by the retransmission algorithm - which may see a completely random
timestamp.

If the retransmission algorithm sees such a timestamp, it may retransmit
the packet and, in future, tell the congestion management algorithm that
the retransmit timer expired.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/sendmsg.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/rxrpc/sendmsg.c b/net/rxrpc/sendmsg.c
index ca7c3be60ad2..ca3811bfbd17 100644
--- a/net/rxrpc/sendmsg.c
+++ b/net/rxrpc/sendmsg.c
@@ -99,6 +99,11 @@ static void rxrpc_queue_packet(struct rxrpc_call *call, struct sk_buff *skb,
 
 	ASSERTCMP(seq, ==, call->tx_top + 1);
 
+	/* We have to set the timestamp before queueing as the retransmit
+	 * algorithm can see the packet as soon as we queue it.
+	 */
+	skb->tstamp = ktime_get_real();
+
 	ix = seq & RXRPC_RXTX_BUFF_MASK;
 	rxrpc_get_skb(skb, rxrpc_skb_tx_got);
 	call->rxtx_annotations[ix] = RXRPC_TX_ANNO_UNACK;
