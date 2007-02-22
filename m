From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] TCP : keep copied_seq, rcv_wup and rcv_next together
Date: Thu, 22 Feb 2007 11:22:02 +0100
Message-ID: <200702221122.02806.dada1@cosmosbay.com>
References: <1171583205.29021.44.camel@localhost> <20070222.012649.119274047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_K7W3F6zUH1iYAwX"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:40119 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750712AbXBVKWO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 05:22:14 -0500
In-Reply-To: <20070222.012649.119274047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_K7W3F6zUH1iYAwX
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi David

I noticed in oprofile study a cache miss in tcp_rcv_established() to read 
copied_seq.


ffffffff80400a80 <tcp_rcv_established>: /* tcp_rcv_established total: 4034293  
2.0400 */

 55493  0.0281 :ffffffff80400bc9:   mov    0x4c8(%r12),%eax copied_seq
543103  0.2746 :ffffffff80400bd1:   cmp    0x3e0(%r12),%eax   rcv_nxt    

if (tp->copied_seq == tp->rcv_nxt &&
	len - tcp_header_len <= tp->ucopy.len) {


In this function, the cache line 0x4c0 -> 0x500 is used only for this 
reading 'copied_seq' field.

rcv_wup and copied_seq should be next to rcv_nxt field, to lower number of 
active cache lines in hot paths. (tcp_rcv_established(), tcp_poll(), ...)

Patch is 64bit friendly (no new hole because of alignment constraints)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--Boundary-00=_K7W3F6zUH1iYAwX
Content-Type: text/plain;
  charset="iso-8859-1";
  name="tcp_sock_reorder1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="tcp_sock_reorder1.patch"

--- linux/include/linux/tcp.h	2007-02-22 11:53:22.000000000 +0100
+++ linux-ed/include/linux/tcp.h	2007-02-22 12:03:19.000000000 +0100
@@ -242,6 +242,8 @@ struct tcp_sock {
  *	See RFC793 and RFC1122. The RFC writes these in capitals.
  */
  	u32	rcv_nxt;	/* What we want to receive next 	*/
+	u32	copied_seq;	/* Head of yet unread data		*/
+	u32	rcv_wup;	/* rcv_nxt on last window update sent	*/
  	u32	snd_nxt;	/* Next sequence we send		*/
 
  	u32	snd_una;	/* First byte we want an ack for	*/
@@ -307,10 +309,8 @@ struct tcp_sock {
 	struct sk_buff_head	out_of_order_queue; /* Out of order segments go here */
 
  	u32	rcv_wnd;	/* Current receiver window		*/
-	u32	rcv_wup;	/* rcv_nxt on last window update sent	*/
 	u32	write_seq;	/* Tail(+1) of data held in tcp send buffer */
 	u32	pushed_seq;	/* Last pushed seq, required to talk to windows */
-	u32	copied_seq;	/* Head of yet unread data		*/
 
 /*	SACKs data	*/
 	struct tcp_sack_block duplicate_sack[1]; /* D-SACK block */

--Boundary-00=_K7W3F6zUH1iYAwX--
