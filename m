From: "ithilgore.ryu.L@gmail.com" <ithilgore.ryu.l@gmail.com>
Subject: PATCH tcp_init_wl / tcp_update_wl argument cleanup
Date: Sun, 01 Mar 2009 12:37:47 +0200
Message-ID: <49AA657B.5030904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f178.google.com ([209.85.218.178]:64977 "EHLO
	mail-bw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752358AbZCAKlH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 05:41:07 -0500
Received: by bwz26 with SMTP id 26so1571944bwz.37
        for <netdev@vger.kernel.org>; Sun, 01 Mar 2009 02:41:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The above functions from include/net/tcp.h have been defined with an
argument that they never use. The argument is 'u32 ack' which is never
used inside the function body, and thus it can be removed. The rest of
the patch involves the necessary changes to the function callers of the
above two functions.



--- /net/ipv4/orig.tcp_minisocks.c	2009-02-21 21:26:07.000000000 +0200
+++ /net/ipv4/tcp_minisocks.c	2009-02-21 21:26:22.000000000 +0200
@@ -399,7 +399,7 @@

 		tcp_prequeue_init(newtp);

-		tcp_init_wl(newtp, treq->snt_isn, treq->rcv_isn);
+		tcp_init_wl(newtp, treq->rcv_isn);

 		newtp->srtt = 0;
 		newtp->mdev = TCP_TIMEOUT_INIT;
--- /net/ipv4/orig.tcp_input.c	2009-02-21 21:26:36.000000000 +0200
+++ /net/ipv4/tcp_input.c	2009-02-21 21:27:41.000000000 +0200
@@ -3072,7 +3072,7 @@

 	if (tcp_may_update_window(tp, ack, ack_seq, nwin)) {
 		flag |= FLAG_WIN_UPDATE;
-		tcp_update_wl(tp, ack, ack_seq);
+		tcp_update_wl(tp, ack_seq);

 		if (tp->snd_wnd != nwin) {
 			tp->snd_wnd = nwin;
@@ -3277,7 +3277,7 @@
 		 * No more checks are required.
 		 * Note, we use the fact that SND.UNA>=SND.WL2.
 		 */
-		tcp_update_wl(tp, ack, ack_seq);
+		tcp_update_wl(tp, ack_seq);
 		tp->snd_una = ack;
 		flag |= FLAG_WIN_UPDATE;

@@ -5085,7 +5085,7 @@
 		 * never scaled.
 		 */
 		tp->snd_wnd = ntohs(th->window);
-		tcp_init_wl(tp, TCP_SKB_CB(skb)->ack_seq, TCP_SKB_CB(skb)->seq);
+		tcp_init_wl(tp, TCP_SKB_CB(skb)->seq);

 		if (!tp->rx_opt.wscale_ok) {
 			tp->rx_opt.snd_wscale = tp->rx_opt.rcv_wscale = 0;
@@ -5346,8 +5346,7 @@
 				tp->snd_una = TCP_SKB_CB(skb)->ack_seq;
 				tp->snd_wnd = ntohs(th->window) <<
 					      tp->rx_opt.snd_wscale;
-				tcp_init_wl(tp, TCP_SKB_CB(skb)->ack_seq,
-					    TCP_SKB_CB(skb)->seq);
+				tcp_init_wl(tp, TCP_SKB_CB(skb)->seq);

 				/* tcp_ack considers this ACK as duplicate
 				 * and does not calculate rtt.
--- net/ipv4/orig.tcp_output.c	2009-02-21 21:28:11.000000000 +0200
+++ net/ipv4/tcp_output.c	2009-02-21 21:28:34.000000000 +0200
@@ -2373,7 +2373,7 @@
 	sk->sk_err = 0;
 	sock_reset_flag(sk, SOCK_DONE);
 	tp->snd_wnd = 0;
-	tcp_init_wl(tp, tp->write_seq, 0);
+	tcp_init_wl(tp, 0);
 	tp->snd_una = tp->write_seq;
 	tp->snd_sml = tp->write_seq;
 	tp->snd_up = tp->write_seq;
--- include/net/orig.tcp.h	2009-02-21 21:23:21.000000000 +0200
+++ include/net/tcp.h	2009-02-21 21:23:49.000000000 +0200
@@ -829,12 +829,12 @@
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


--
ithilgore
