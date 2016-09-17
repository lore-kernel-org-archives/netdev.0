From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 02/14] rxrpc: Move the check of rx_pkt_offset from
 rxrpc_locate_data() to caller
Date: Sun, 18 Sep 2016 00:17:58 +0100
Message-ID: <147415427878.17897.14191866969662813684.stgit@warthog.procyon.org.uk>
References: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49850 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933017AbcIQXSA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 17 Sep 2016 19:18:00 -0400
In-Reply-To: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the check of rx_pkt_offset from rxrpc_locate_data() to the caller,
rxrpc_recvmsg_data(), so that it's more clear what's going on there.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/recvmsg.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/rxrpc/recvmsg.c b/net/rxrpc/recvmsg.c
index a284205b8ecf..0d085f5cf1bf 100644
--- a/net/rxrpc/recvmsg.c
+++ b/net/rxrpc/recvmsg.c
@@ -240,9 +240,6 @@ static int rxrpc_locate_data(struct rxrpc_call *call, struct sk_buff *skb,
 	int ret;
 	u8 annotation = *_annotation;
 
-	if (offset > 0)
-		return 0;
-
 	/* Locate the subpacket */
 	offset = sp->offset;
 	len = skb->len - sp->offset;
@@ -303,8 +300,10 @@ static int rxrpc_recvmsg_data(struct socket *sock, struct rxrpc_call *call,
 		if (msg)
 			sock_recv_timestamp(msg, sock->sk, skb);
 
-		ret = rxrpc_locate_data(call, skb, &call->rxtx_annotations[ix],
-					&rx_pkt_offset, &rx_pkt_len);
+		if (rx_pkt_offset == 0)
+			ret = rxrpc_locate_data(call, skb,
+						&call->rxtx_annotations[ix],
+						&rx_pkt_offset, &rx_pkt_len);
 		_debug("recvmsg %x DATA #%u { %d, %d }",
 		       sp->hdr.callNumber, seq, rx_pkt_offset, rx_pkt_len);
 
