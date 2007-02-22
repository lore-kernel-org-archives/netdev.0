From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH, take 2] TCP : keep copied_seq, rcv_wup and rcv_next together
Date: Thu, 22 Feb 2007 12:11:50 +0100
Message-ID: <200702221211.50289.dada1@cosmosbay.com>
References: <1171583205.29021.44.camel@localhost> <20070222.012649.119274047.davem@davemloft.net> <200702221122.02806.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_2pX3FZJBYl7TF73"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:40771 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933025AbXBVLMD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Feb 2007 06:12:03 -0500
In-Reply-To: <200702221122.02806.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_2pX3FZJBYl7TF73
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David

I noticed in oprofile study a cache miss in tcp_rcv_established() to read=20
copied_seq.


ffffffff80400a80 <tcp_rcv_established>: /* tcp_rcv_established total: 40342=
93 =C2=A0
2.0400 */

=C2=A055493 =C2=A00.0281 :ffffffff80400bc9: =C2=A0 mov =C2=A0 =C2=A00x4c8(%=
r12),%eax copied_seq
543103 =C2=A00.2746 :ffffffff80400bd1: =C2=A0 cmp =C2=A0 =C2=A00x3e0(%r12),=
%eax =C2=A0 rcv_nxt =C2=A0 =C2=A0

if (tp->copied_seq =3D=3D tp->rcv_nxt &&
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0len - tcp_header_len <=3D t=
p->ucopy.len) {


In this function, the cache line 0x4c0 -> 0x500 is used only for this=20
reading 'copied_seq' field.

rcv_wup and copied_seq should be next to rcv_nxt field, to lower number of=
=20
active cache lines in hot paths. (tcp_rcv_established(), tcp_poll(), ...)

As you suggested, I changed tcp_create_openreq_child() so that these fields=
=20
are changed together, to avoid adding a new store buffer stall.

Patch is 64bit friendly (no new hole because of alignment constraints)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--Boundary-00=_2pX3FZJBYl7TF73
Content-Type: text/plain;
  charset="utf-8";
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
--- linux/net/ipv4/tcp_minisocks.c	2007-02-22 12:41:26.000000000 +0100
+++ linux-ed/net/ipv4/tcp_minisocks.c	2007-02-22 12:49:49.000000000 +0100
@@ -387,8 +387,8 @@ struct sock *tcp_create_openreq_child(st
 		/* Now setup tcp_sock */
 		newtp = tcp_sk(newsk);
 		newtp->pred_flags = 0;
-		newtp->rcv_nxt = treq->rcv_isn + 1;
-		newtp->snd_nxt = newtp->snd_una = newtp->snd_sml = treq->snt_isn + 1;
+		newtp->rcv_wup = newtp->copied_seq = newtp->rcv_nxt = treq->rcv_isn + 1;
+		newtp->snd_sml = newtp->snd_una = newtp->snd_nxt = treq->snt_isn + 1;
 
 		tcp_prequeue_init(newtp);
 
@@ -422,10 +422,8 @@ struct sock *tcp_create_openreq_child(st
 		tcp_set_ca_state(newsk, TCP_CA_Open);
 		tcp_init_xmit_timers(newsk);
 		skb_queue_head_init(&newtp->out_of_order_queue);
-		newtp->rcv_wup = treq->rcv_isn + 1;
 		newtp->write_seq = treq->snt_isn + 1;
 		newtp->pushed_seq = newtp->write_seq;
-		newtp->copied_seq = treq->rcv_isn + 1;
 
 		newtp->rx_opt.saw_tstamp = 0;
 

--Boundary-00=_2pX3FZJBYl7TF73--
