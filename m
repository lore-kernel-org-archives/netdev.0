From: David Howells <dhowells@redhat.com>
Subject: [PATCH 7/8] af_rxrpc: Request an ACK for every alternate DATA
 packet [ver #2]
Date: Thu, 06 Mar 2014 12:47:04 +0000
Message-ID: <20140306124704.16645.84887.stgit@warthog.procyon.org.uk>
References: <20140306124614.16645.50744.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, tim@electronghost.co.uk,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140306124614.16645.50744.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set the RxRPC header flag to request an ACK packet for every odd-numbered DATA
packet unless it's the last one (which implicitly requests an ACK anyway).
This is similar to how librx appears to work.

If we don't do this, we'll send out a full window of packets and then just sit
there until the other side gets bored and sends an ACK to indicate that it's
been idle for a while and has received no new packets.

Requesting a lot of ACKs shouldn't be a problem as ACKs should be merged when
possible.

As AF_RXRPC currently works, it will schedule an ACK to be generated upon
receipt of a DATA packet with the ACK-request packet set - and in the time
taken to schedule this in a work queue, several other packets are likely to
arrive and then all get ACK'd together.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-output.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/ar-output.c b/net/rxrpc/ar-output.c
index 4814d882bcb4..0b4b9a79f5ab 100644
--- a/net/rxrpc/ar-output.c
+++ b/net/rxrpc/ar-output.c
@@ -669,6 +669,7 @@ static int rxrpc_send_data(struct kiocb *iocb,
 		/* add the packet to the send queue if it's now full */
 		if (sp->remain <= 0 || (segment == 0 && !more)) {
 			struct rxrpc_connection *conn = call->conn;
+			uint32_t seq;
 			size_t pad;
 
 			/* pad out if we're using security */
@@ -681,11 +682,12 @@ static int rxrpc_send_data(struct kiocb *iocb,
 					memset(skb_put(skb, pad), 0, pad);
 			}
 
+			seq = atomic_inc_return(&call->sequence);
+
 			sp->hdr.epoch = conn->epoch;
 			sp->hdr.cid = call->cid;
 			sp->hdr.callNumber = call->call_id;
-			sp->hdr.seq =
-				htonl(atomic_inc_return(&call->sequence));
+			sp->hdr.seq = htonl(seq);
 			sp->hdr.serial =
 				htonl(atomic_inc_return(&conn->serial));
 			sp->hdr.type = RXRPC_PACKET_TYPE_DATA;
@@ -700,6 +702,8 @@ static int rxrpc_send_data(struct kiocb *iocb,
 			else if (CIRC_SPACE(call->acks_head, call->acks_tail,
 					    call->acks_winsz) > 1)
 				sp->hdr.flags |= RXRPC_MORE_PACKETS;
+			if (more && seq & 1)
+				sp->hdr.flags |= RXRPC_REQUEST_ACK;
 
 			ret = rxrpc_secure_packet(
 				call, skb, skb->mark,
