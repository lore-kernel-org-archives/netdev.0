From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 3/3] [TCP]: NAGLE_PUSH seems to be a wrong way around
Date: Wed, 5 Dec 2007 13:18:14 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712051242310.18529@kivilampi-30.cs.helsinki.fi>
References: <11967869303567-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11967869303709-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1196786930388-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20071205.022634.114614917.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-1446559195-1196851691=:18529"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57643 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941AbXLELSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 06:18:16 -0500
In-Reply-To: <20071205.022634.114614917.davem@davemloft.net>
Content-ID: <Pine.LNX.4.64.0712051303370.18529@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1446559195-1196851691=:18529
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0712051303371.18529@kivilampi-30.cs.helsinki.fi>

On Wed, 5 Dec 2007, David Miller wrote:

> From: "Ilpo_Järvinen" <ilpo.jarvinen@helsinki.fi>
> Date: Tue,  4 Dec 2007 18:48:50 +0200
> 
> > The comment in tcp_nagle_test suggests that. This bug is very
> > very old, even 2.4.0 seems to have it.
> > 
> > Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
> 
> Wow, I can't believed I missed this during the TSO output
> path rewrite.
> 
> I will have to double check the history, because I stated
> at these conditionals many times during that work and I
> wonder if I inverted a "!" somewhere along the line.

...No need, I mostly digged this up already because I was bit unsure 
how it should be, your conversions didn't invert anything significant,
at least before 2.4.0 :-).  ...Unless you first fixed it and then
broke it again (in your private working tree)... :-/

...If I understood the very old history correctly, this bug was introduced 
in 2.4.0-test12 which inverted !tail incorrectly to nonagle==1.

You can check include/net/tcp.h diffs from this commit:
http://www.linux-mips.org/git?p=linux.git;a=commitdiff;h=c9c06167e7933d93a6e396174c68abf242294abb

...Though it's very large one. So I included only the relevant portion 
here below.


-- 
 i.

c9c06167e7933d93a6e396174c68abf242294abb
diff --git a/include/net/tcp.h b/include/net/tcp.h
index dd8e74c..ccdff5a 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -328,9 +328,13 @@ static __inline__ int tcp_sk_listen_hashfn(struct sock *sk)
 				  */
 
 #define TCP_DELACK_MAX	(HZ/5)	/* maximal time to delay before sending an ACK */
-#define TCP_DELACK_MIN	(2)	/* minimal time to delay before sending an ACK,
-				 * 2 scheduler ticks, not depending on HZ. */
-#define TCP_ATO_MIN	2
+#if HZ >= 100
+#define TCP_DELACK_MIN	(HZ/25)	/* minimal time to delay before sending an ACK */
+#define TCP_ATO_MIN	(HZ/25)
+#else
+#define TCP_DELACK_MIN	4
+#define TCP_ATO_MIN	4
+#endif
 #define TCP_RTO_MAX	(120*HZ)
 #define TCP_RTO_MIN	(HZ/5)
 #define TCP_TIMEOUT_INIT (3*HZ)	/* RFC 1122 initial RTO value	*/
@@ -688,6 +692,10 @@ static __inline__ void tcp_delack_init(struct tcp_opt *tp)
 	memset(&tp->ack, 0, sizeof(tp->ack));
 }
 
+static inline void tcp_clear_options(struct tcp_opt *tp)
+{
+ 	tp->tstamp_ok = tp->sack_ok = tp->wscale_ok = tp->snd_wscale = 0;
+}
 
 enum tcp_tw_status
 {
@@ -734,7 +742,8 @@ extern int			tcp_recvmsg(struct sock *sk,
 extern int			tcp_listen_start(struct sock *sk);
 
 extern void			tcp_parse_options(struct sk_buff *skb,
-						  struct tcp_opt *tp);
+						  struct tcp_opt *tp,
+						  int estab);
 
 /*
  *	TCP v4 functions exported for the inet6 API
@@ -997,6 +1006,9 @@ struct tcp_skb_cb {
 #define TCPCB_EVER_RETRANS	0x80	/* Ever retransmitted frame	*/
 #define TCPCB_RETRANS		(TCPCB_SACKED_RETRANS|TCPCB_EVER_RETRANS)
 
+#define TCPCB_URG		0x20	/* Urgent pointer advenced here	*/
+
+#define TCPCB_AT_TAIL		(TCPCB_URG)
 
 	__u16		urg_ptr;	/* Valid w/URG flags is set.	*/
 	__u32		ack_seq;	/* Sequence number ACK'd	*/
@@ -1134,18 +1146,19 @@ static __inline__ void tcp_minshall_update(struct tcp_opt *tp, int mss, struct s
 
 /* Return 0, if packet can be sent now without violation Nagle's rules:
    1. It is full sized.
-   2. Or it contains FIN or URG.
+   2. Or it contains FIN.
    3. Or TCP_NODELAY was set.
    4. Or TCP_CORK is not set, and all sent packets are ACKed.
       With Minshall's modification: all sent small packets are ACKed.
  */
 
-static __inline__ int tcp_nagle_check(struct tcp_opt *tp, struct sk_buff *skb, unsigned mss_now)
+static __inline__ int
+tcp_nagle_check(struct tcp_opt *tp, struct sk_buff *skb, unsigned mss_now, int nonagle)
 {
 	return (skb->len < mss_now &&
-		!(TCP_SKB_CB(skb)->flags & (TCPCB_FLAG_URG|TCPCB_FLAG_FIN)) &&
-		(tp->nonagle == 2 ||
-		 (!tp->nonagle &&
+		!(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN) &&
+		(nonagle == 2 ||
+		 (!nonagle &&
 		  tp->packets_out &&
 		  tcp_minshall_check(tp))));
 }
@@ -1154,7 +1167,7 @@ static __inline__ int tcp_nagle_check(struct tcp_opt *tp, struct sk_buff *skb, u
  * should be put on the wire right now.
  */
 static __inline__ int tcp_snd_test(struct tcp_opt *tp, struct sk_buff *skb,
-				   unsigned cur_mss, int tail)
+				   unsigned cur_mss, int nonagle)
 {
 	/*	RFC 1122 - section 4.2.3.4
 	 *
@@ -1180,8 +1193,8 @@ static __inline__ int tcp_snd_test(struct tcp_opt *tp, struct sk_buff *skb,
 	/* Don't be strict about the congestion window for the
 	 * final FIN frame.  -DaveM
 	 */
-	return ((!tail || !tcp_nagle_check(tp, skb, cur_mss) ||
-		 skb_tailroom(skb) < 32) &&
+	return ((nonagle==1 || tp->urg_mode
+		 || !tcp_nagle_check(tp, skb, cur_mss, nonagle)) &&
 		((tcp_packets_in_flight(tp) < tp->snd_cwnd) ||
 		 (TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN)) &&
 		!after(TCP_SKB_CB(skb)->end_seq, tp->snd_una + tp->snd_wnd));
@@ -1204,12 +1217,15 @@ static __inline__ int tcp_skb_is_last(struct sock *sk, struct sk_buff *skb)
  */
 static __inline__ void __tcp_push_pending_frames(struct sock *sk,
 						 struct tcp_opt *tp,
-						 unsigned cur_mss)
+						 unsigned cur_mss,
+						 int nonagle)
 {
 	struct sk_buff *skb = tp->send_head;
 
 	if (skb) {
-		if (!tcp_snd_test(tp, skb, cur_mss, tcp_skb_is_last(sk, skb)) ||
+		if (!tcp_skb_is_last(sk, skb))
+			nonagle = 1;
+		if (!tcp_snd_test(tp, skb, cur_mss, nonagle) ||
 		    tcp_write_xmit(sk))
 			tcp_check_probe_timer(sk, tp);
 	}
@@ -1219,7 +1235,7 @@ static __inline__ void __tcp_push_pending_frames(struct sock *sk,
 static __inline__ void tcp_push_pending_frames(struct sock *sk,
 					       struct tcp_opt *tp)
 {
-	__tcp_push_pending_frames(sk, tp, tcp_current_mss(sk));
+	__tcp_push_pending_frames(sk, tp, tcp_current_mss(sk), tp->nonagle);
 }
 
 static __inline__ int tcp_may_send_now(struct sock *sk, struct tcp_opt *tp)
@@ -1227,7 +1243,8 @@ static __inline__ int tcp_may_send_now(struct sock *sk, struct tcp_opt *tp)
 	struct sk_buff *skb = tp->send_head;
 
 	return (skb &&
-		tcp_snd_test(tp, skb, tcp_current_mss(sk), tcp_skb_is_last(sk, skb)));
+		tcp_snd_test(tp, skb, tcp_current_mss(sk),
+			     tcp_skb_is_last(sk, skb) ? 1 : tp->nonagle));
 }
 
 static __inline__ void tcp_init_wl(struct tcp_opt *tp, u32 ack, u32 seq)
---696243703-1446559195-1196851691=:18529--
