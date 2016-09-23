From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 07/15] rxrpc: Fix accidental cancellation of
 scheduled resend by ACK parser
Date: Fri, 23 Sep 2016 16:16:05 +0100
Message-ID: <147464376586.5090.14901936645927156006.stgit@warthog.procyon.org.uk>
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

When rxrpc_input_soft_acks() is parsing the soft-ACKs from an ACK packet,
it updates the Tx packet annotations in the annotation buffer.  If a
soft-ACK is an ACK, then we overwrite unack'd, nak'd or to-be-retransmitted
states and that is fine; but if the soft-ACK is an NACK, we overwrite the
to-be-retransmitted with a nak - which isn't.

Instead, we need to let any scheduled retransmission stand if the packet
was NAK'd.

Note that we don't reissue a resend if the annotation is in the
to-be-retransmitted state because someone else must've scheduled the
resend already.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/input.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index 06027b6d9c19..d3d69ab1f0a1 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -479,6 +479,8 @@ static void rxrpc_input_soft_acks(struct rxrpc_call *call, u8 *acks,
 		case RXRPC_ACK_TYPE_NACK:
 			if (anno_type == RXRPC_TX_ANNO_NAK)
 				continue;
+			if (anno_type == RXRPC_TX_ANNO_RETRANS)
+				continue;
 			call->rxtx_annotations[ix] =
 				RXRPC_TX_ANNO_NAK | annotation;
 			resend = true;
