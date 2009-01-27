From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH] Fix tcp splice length
Date: Mon, 26 Jan 2009 21:12:21 -0800
Message-ID: <200901270512.n0R5CLXB019113@darkside.asicdesigners.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:25243 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751170AbZA0FMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 00:12:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 6c242233648471868b44ea091d461f2db6a93f10
Author: Dimitris Michailidis <dm@chelsio.com>
Date:   Mon Jan 26 20:46:56 2009 -0800

    Fix length tcp_splice_data_recv passes to skb_splice_bits.
    
    tcp_splice_data_recv has two lengths to consider: the len parameter it
    gets from tcp_read_sock, which specifies the amount of data in the skb,
    and rd_desc->count, which is the amount of data the splice caller still
    wants.  Currently it passes just the latter to skb_splice_bits, which then
    splices min(rd_desc->count, skb->len - offset) bytes.
    
    Most of the time this is fine, except when the skb contains urgent data.
    In that case len goes only up to the urgent byte and is less than
    skb->len - offset.  By ignoring len tcp_splice_data_recv may a) splice
    data tcp_read_sock told it not to, b) return to tcp_read_sock a value > len.
    
    Now, tcp_read_sock doesn't handle used > len and leaves the socket in a
    bad state (both sk_receive_queue and copied_seq are bad at that point)
    resulting in duplicated data and corruption.
    
    Fix by passing min(rd_desc->count, len) to skb_splice_bits.
    
    Signed-off-by: Dimitris Michailidis <dm@chelsio.com>

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0cd71b8..76b148b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -524,7 +524,8 @@ static int tcp_splice_data_recv(read_descriptor_t *rd_desc, struct sk_buff *skb,
 	struct tcp_splice_state *tss = rd_desc->arg.data;
 	int ret;
 
-	ret = skb_splice_bits(skb, offset, tss->pipe, rd_desc->count, tss->flags);
+	ret = skb_splice_bits(skb, offset, tss->pipe, min(rd_desc->count, len),
+			      tss->flags);
 	if (ret > 0)
 		rd_desc->count -= ret;
 	return ret;
