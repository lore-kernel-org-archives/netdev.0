From: Stephen Hemminger <shemminger@osdl.org>
Subject: TCP Westwood+ patches
Date: Tue, 6 Jun 2006 11:53:06 -0700
Message-ID: <20060606115306.15b52b38@dxpl.pdx.osdl.net>
References: <20060524182006.32fd1fcd@localhost>
	<20060605093240.5d68e117@dxpl.pdx.osdl.net>
	<20060606184152.6d97a193@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Saverio Mascolo <saverio.mascolo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:59291 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750960AbWFFSxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2006 14:53:02 -0400
To: Luca De Cicco <ldecicco@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060606184152.6d97a193@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I cleaned these up and put them in a git tree. Luco if you want to be the
maintainer of this, then the correct way is to send a patch to the MAINTAINER
file.
-------

The following changes since commit bd6673d239e7041bc3f81f8d6d0242b7bf6dd62f:
  Andreas Schwab:
        [CONNECTOR]: Fix warning in cn_queue.c

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/tcp-2.6.18.git#tcp

Luca De Cicco:
      TCP Westwood: comment fixes
      TCP Westwood: bandwidth filter startup
      TCP Westwood: reset RTT min after FRTO

Stephen Hemminger:
      TCP Westwood: fix first sample

 net/ipv4/tcp_westwood.c |   62 ++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 55 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
index 62a96b7..4247da1 100644
--- a/net/ipv4/tcp_westwood.c
+++ b/net/ipv4/tcp_westwood.c
@@ -1,7 +1,24 @@
 /*
- * TCP Westwood+
+ * TCP Westwood+: end-to-end bandwidth estimation for TCP
  *
- *	Angelo Dell'Aera:	TCP Westwood+ support
+ *      Angelo Dell'Aera: author of the first version of TCP Westwood+ in Linux 2.4
+ *
+ * Support at http://c3lab.poliba.it/index.php/Westwood
+ * Main references in literature:
+ *
+ * - Mascolo S, Casetti, M. Gerla et al.
+ *   "TCP Westwood: bandwidth estimation for TCP" Proc. ACM Mobicom 2001
+ *
+ * - A. Grieco, s. Mascolo
+ *   "Performance evaluation of New Reno, Vegas, Westwood+ TCP" ACM Computer
+ *     Comm. Review, 2004
+ *
+ * - A. Dell'Aera, L. Grieco, S. Mascolo.
+ *   "Linux 2.4 Implementation of Westwood+ TCP with Rate-Halving :
+ *    A Performance Evaluation Over the Internet" (ICC 2004), Paris, June 2004
+ *
+ * Westwood+ employs end-to-end bandwidth measurement to set cwnd and
+ * ssthresh after packet loss. The probing phase is as the original Reno.
  */
 
 #include <linux/config.h>
@@ -23,6 +40,7 @@ struct westwood {
 	u32    rtt;
 	u32    rtt_min;          /* minimum observed RTT */
 	u8     first_ack;        /* flag which infers that this is the first ack */
+	u8     reset_rtt_min;    /* Reset RTT min to next RTT sample*/
 };
 
 
@@ -50,6 +68,7 @@ static void tcp_westwood_init(struct soc
         w->bw_est = 0;
         w->accounted = 0;
         w->cumul_ack = 0;
+	w->reset_rtt_min = 1;
 	w->rtt_min = w->rtt = TCP_WESTWOOD_INIT_RTT;
 	w->rtt_win_sx = tcp_time_stamp;
 	w->snd_una = tcp_sk(sk)->snd_una;
@@ -65,10 +84,16 @@ static inline u32 westwood_do_filter(u32
 	return (((7 * a) + b) >> 3);
 }
 
-static inline void westwood_filter(struct westwood *w, u32 delta)
+static void westwood_filter(struct westwood *w, u32 delta)
 {
-	w->bw_ns_est = westwood_do_filter(w->bw_ns_est, w->bk / delta);
-	w->bw_est = westwood_do_filter(w->bw_est, w->bw_ns_est);
+	/* If the filter is empty fill it with the first sample of bandwidth  */
+	if (w->bw_ns_est == 0 && w->bw_est == 0) {
+		w->bw_ns_est = w->bk / delta;
+		w->bw_est = w->bw_ns_est;
+	} else {
+		w->bw_ns_est = westwood_do_filter(w->bw_ns_est, w->bk / delta);
+		w->bw_est = westwood_do_filter(w->bw_est, w->bw_ns_est);
+	}
 }
 
 /*
@@ -93,7 +118,7 @@ static void westwood_update_window(struc
 	struct westwood *w = inet_csk_ca(sk);
 	s32 delta = tcp_time_stamp - w->rtt_win_sx;
 
-	/* Initialise w->snd_una with the first acked sequence number in order
+	/* Initialize w->snd_una with the first acked sequence number in order
 	 * to fix mismatch between tp->snd_una and w->snd_una for the first
 	 * bandwidth sample
 	 */
@@ -119,6 +144,16 @@ static void westwood_update_window(struc
 	}
 }
 
+static inline void update_rtt_min(struct westwood *w)
+{
+	if (w->reset_rtt_min) {
+		w->rtt_min = w->rtt;
+		w->reset_rtt_min = 0;	
+	} else
+		w->rtt_min = min(w->rtt, w->rtt_min);
+}
+
+
 /*
  * @westwood_fast_bw
  * It is called when we are in fast path. In particular it is called when
@@ -134,7 +169,7 @@ static inline void westwood_fast_bw(stru
 
 	w->bk += tp->snd_una - w->snd_una;
 	w->snd_una = tp->snd_una;
-	w->rtt_min = min(w->rtt, w->rtt_min);
+	update_rtt_min(w);
 }
 
 /*
@@ -191,7 +226,7 @@ static void tcp_westwood_event(struct so
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct westwood *w = inet_csk_ca(sk);
-	
+
 	switch(event) {
 	case CA_EVENT_FAST_ACK:
 		westwood_fast_bw(sk);
@@ -203,12 +238,14 @@ static void tcp_westwood_event(struct so
 
 	case CA_EVENT_FRTO:
 		tp->snd_ssthresh = tcp_westwood_bw_rttmin(sk);
+ 		/* Update RTT_min when next ack arrives */
+		w->reset_rtt_min = 1;
 		break;
 
 	case CA_EVENT_SLOW_ACK:
 		westwood_update_window(sk);
 		w->bk += westwood_acked_count(sk);
-		w->rtt_min = min(w->rtt, w->rtt_min);
+		update_rtt_min(w);
 		break;
 
 	default:
