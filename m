From: Hantzis Fotis <xantzis@ceid.upatras.gr>
Subject: Re: PATCH tcp_init_wl / tcp_update_wl argument cleanup
Date: Mon, 02 Mar 2009 19:57:23 +0200
Message-ID: <49AC1E03.2000900@ceid.upatras.gr>
References: <49AA657B.5030904@gmail.com> <20090302.031401.177327405.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poseidon.ceid.upatras.gr ([150.140.141.169]:37529 "EHLO
	poseidon.ceid.upatras.gr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751577AbZCBSX3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 13:23:29 -0500
In-Reply-To: <20090302.031401.177327405.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "ithilgore.ryu.L@gmail.com" <ithilgore.ryu.l@gmail.com>
> Date: Sun, 01 Mar 2009 12:37:47 +0200
>
>   
>> The above functions from include/net/tcp.h have been defined with an
>> argument that they never use. The argument is 'u32 ack' which is never
>> used inside the function body, and thus it can be removed. The rest of
>> the patch involves the necessary changes to the function callers of the
>> above two functions.
>>     
>
> Please read linux/Documentation/SubmittingPatches
>
> In particular, your submission:
>
> 1) Lacked a proper "Signed-off-by" line and please do fix
>    the proper name assosciated with your email address if
>    you don't mind.
>
> 2) Did not root your patch properly.
>
> Thanks.
>   

Sorry for not complying with the guidelines on the previous submission.
I am resending the patch properly this time:

Signed-off-by: Hantzis Fotis <xantzis@ceid.upatras.gr>
---
diff -uprN -X linux-2.6.28-vanilla/Documentation/dontdiff linux-2.6.28-vanilla/include/net/tcp.h linux-2.6.28-devel/include/net/tcp.h
--- linux-2.6.28-vanilla/include/net/tcp.h	2009-03-02 18:50:45.000000000 +0200
+++ linux-2.6.28-devel/include/net/tcp.h	2009-03-02 19:11:19.000000000 +0200
@@ -829,12 +829,12 @@ static inline void tcp_push_pending_fram
 	__tcp_push_pending_frames(sk, tcp_current_mss(sk, 1), tp->nonagle);
 }
 
-static inline void tcp_init_wl(struct tcp_sock *tp, u32 ack, u32 seq)
+static inline void tcp_init_wl(struct tcp_sock *tp, u32 seq)
 {
 	tp->snd_wl1 = seq;
 }
 
-static inline void tcp_update_wl(struct tcp_sock *tp, u32 ack, u32 seq)
+static inline void tcp_update_wl(struct tcp_sock *tp, u32 seq)
 {
 	tp->snd_wl1 = seq;
 }
diff -uprN -X linux-2.6.28-vanilla/Documentation/dontdiff linux-2.6.28-vanilla/net/ipv4/tcp_input.c linux-2.6.28-devel/net/ipv4/tcp_input.c
--- linux-2.6.28-vanilla/net/ipv4/tcp_input.c	2009-03-02 18:52:36.000000000 +0200
+++ linux-2.6.28-devel/net/ipv4/tcp_input.c	2009-03-02 19:11:29.000000000 +0200
@@ -3072,7 +3072,7 @@ static int tcp_ack_update_window(struct 
 
 	if (tcp_may_update_window(tp, ack, ack_seq, nwin)) {
 		flag |= FLAG_WIN_UPDATE;
-		tcp_update_wl(tp, ack, ack_seq);
+		tcp_update_wl(tp, ack_seq);
 
 		if (tp->snd_wnd != nwin) {
 			tp->snd_wnd = nwin;
@@ -3277,7 +3277,7 @@ static int tcp_ack(struct sock *sk, stru
 		 * No more checks are required.
 		 * Note, we use the fact that SND.UNA>=SND.WL2.
 		 */
-		tcp_update_wl(tp, ack, ack_seq);
+		tcp_update_wl(tp, ack_seq);
 		tp->snd_una = ack;
 		flag |= FLAG_WIN_UPDATE;
 
@@ -5085,7 +5085,7 @@ static int tcp_rcv_synsent_state_process
 		 * never scaled.
 		 */
 		tp->snd_wnd = ntohs(th->window);
-		tcp_init_wl(tp, TCP_SKB_CB(skb)->ack_seq, TCP_SKB_CB(skb)->seq);
+		tcp_init_wl(tp, TCP_SKB_CB(skb)->seq);
 
 		if (!tp->rx_opt.wscale_ok) {
 			tp->rx_opt.snd_wscale = tp->rx_opt.rcv_wscale = 0;
@@ -5346,8 +5346,7 @@ int tcp_rcv_state_process(struct sock *s
 				tp->snd_una = TCP_SKB_CB(skb)->ack_seq;
 				tp->snd_wnd = ntohs(th->window) <<
 					      tp->rx_opt.snd_wscale;
-				tcp_init_wl(tp, TCP_SKB_CB(skb)->ack_seq,
-					    TCP_SKB_CB(skb)->seq);
+				tcp_init_wl(tp, TCP_SKB_CB(skb)->seq);
 
 				/* tcp_ack considers this ACK as duplicate
 				 * and does not calculate rtt.
diff -uprN -X linux-2.6.28-vanilla/Documentation/dontdiff linux-2.6.28-vanilla/net/ipv4/tcp_minisocks.c linux-2.6.28-devel/net/ipv4/tcp_minisocks.c
--- linux-2.6.28-vanilla/net/ipv4/tcp_minisocks.c	2009-03-02 18:52:36.000000000 +0200
+++ linux-2.6.28-devel/net/ipv4/tcp_minisocks.c	2009-03-02 19:11:29.000000000 +0200
@@ -399,7 +399,7 @@ struct sock *tcp_create_openreq_child(st
 
 		tcp_prequeue_init(newtp);
 
-		tcp_init_wl(newtp, treq->snt_isn, treq->rcv_isn);
+		tcp_init_wl(newtp, treq->rcv_isn);
 
 		newtp->srtt = 0;
 		newtp->mdev = TCP_TIMEOUT_INIT;
diff -uprN -X linux-2.6.28-vanilla/Documentation/dontdiff linux-2.6.28-vanilla/net/ipv4/tcp_output.c linux-2.6.28-devel/net/ipv4/tcp_output.c
--- linux-2.6.28-vanilla/net/ipv4/tcp_output.c	2009-03-02 18:52:36.000000000 +0200
+++ linux-2.6.28-devel/net/ipv4/tcp_output.c	2009-03-02 19:11:29.000000000 +0200
@@ -2373,7 +2373,7 @@ static void tcp_connect_init(struct sock
 	sk->sk_err = 0;
 	sock_reset_flag(sk, SOCK_DONE);
 	tp->snd_wnd = 0;
-	tcp_init_wl(tp, tp->write_seq, 0);
+	tcp_init_wl(tp, 0);
 	tp->snd_una = tp->write_seq;
 	tp->snd_sml = tp->write_seq;
 	tp->snd_up = tp->write_seq;



