From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 06/10] rxrpc: Use skb->len not skb->data_len
Date: Tue, 13 Sep 2016 23:21:37 +0100
Message-ID: <147380529744.23135.5120326198401433704.stgit@warthog.procyon.org.uk>
References: <147380525614.23135.7539695651371953351.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56494 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932669AbcIMWVj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 18:21:39 -0400
In-Reply-To: <147380525614.23135.7539695651371953351.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb->len should be used rather than skb->data_len when referring to the
amount of data in a packet.  This will only cause a malfunction in the
following cases:

 (1) We receive a jumbo packet (validation and splitting both are wrong).

 (2) We see if there's extra ACK info in an ACK packet (we think it's not
     there and just ignore it).

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/input.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/rxrpc/input.c b/net/rxrpc/input.c
index a707d5952164..5958ef8ba2a0 100644
--- a/net/rxrpc/input.c
+++ b/net/rxrpc/input.c
@@ -127,7 +127,7 @@ static bool rxrpc_validate_jumbo(struct sk_buff *skb)
 {
 	struct rxrpc_skb_priv *sp = rxrpc_skb(skb);
 	unsigned int offset = sp->offset;
-	unsigned int len = skb->data_len;
+	unsigned int len = skb->len;
 	int nr_jumbo = 1;
 	u8 flags = sp->hdr.flags;
 
@@ -196,7 +196,7 @@ static void rxrpc_input_data(struct rxrpc_call *call, struct sk_buff *skb,
 	u8 ack = 0, flags, annotation = 0;
 
 	_enter("{%u,%u},{%u,%u}",
-	       call->rx_hard_ack, call->rx_top, skb->data_len, seq);
+	       call->rx_hard_ack, call->rx_top, skb->len, seq);
 
 	_proto("Rx DATA %%%u { #%u f=%02x }",
 	       sp->hdr.serial, seq, sp->hdr.flags);
@@ -233,7 +233,7 @@ static void rxrpc_input_data(struct rxrpc_call *call, struct sk_buff *skb,
 next_subpacket:
 	queued = false;
 	ix = seq & RXRPC_RXTX_BUFF_MASK;
-	len = skb->data_len;
+	len = skb->len;
 	if (flags & RXRPC_JUMBO_PACKET)
 		len = RXRPC_JUMBO_DATALEN;
 
@@ -444,7 +444,7 @@ static void rxrpc_input_ack(struct rxrpc_call *call, struct sk_buff *skb,
 	}
 
 	offset = sp->offset + nr_acks + 3;
-	if (skb->data_len >= offset + sizeof(buf.info)) {
+	if (skb->len >= offset + sizeof(buf.info)) {
 		if (skb_copy_bits(skb, offset, &buf.info, sizeof(buf.info)) < 0)
 			return rxrpc_proto_abort("XAI", call, 0);
 		rxrpc_input_ackinfo(call, skb, &buf.info);
