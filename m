From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 07/10] rxrpc: Allow tx_winsize to grow in response
 to an ACK
Date: Tue, 13 Sep 2016 23:21:44 +0100
Message-ID: <147380530434.23135.10090736308604988088.stgit@warthog.procyon.org.uk>
References: <147380525614.23135.7539695651371953351.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147380525614.23135.7539695651371953351.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow tx_winsize to grow when the ACK info packet shows a larger receive
window at the other end rather than only permitting it to shrink.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/input.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 5958ef8ba2a0..8e529afcd6c1 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -333,14 +333,16 @@ static void rxrpc_input_ackinfo(struct rxrpc_call *call, struct sk_buff *skb,
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	struct rxrpc_peer *peer;
 	unsigned int mtu;
+	u32 rwind = ntohl(ackinfo->rwind);
 
 	_proto("Rx ACK %%%u Info { rx=%u max=%u rwin=%u jm=%u }",
 	       sp->hdr.serial,
 	       ntohl(ackinfo->rxMTU), ntohl(ackinfo->maxMTU),
-	       ntohl(ackinfo->rwind), ntohl(ackinfo->jumbo_max));
+	       rwind, ntohl(ackinfo->jumbo_max));
 
-	if (call->tx_winsize > ntohl(ackinfo->rwind))
-		call->tx_winsize = ntohl(ackinfo->rwind);
+	if (rwind > RXRPC_RXTX_BUFF_SIZE - 1)
+		rwind = RXRPC_RXTX_BUFF_SIZE - 1;
+	call->tx_winsize = rwind;
 
 	mtu = min(ntohl(ackinfo->rxMTU), ntohl(ackinfo->maxMTU));
 
