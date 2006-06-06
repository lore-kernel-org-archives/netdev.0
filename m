From: Luca De Cicco <ldecicco@gmail.com>
Subject: [PATCH]TCP Westwood+
Date: Tue, 6 Jun 2006 18:41:52 +0200
Message-ID: <20060606184152.6d97a193@localhost>
References: <20060524182006.32fd1fcd@localhost>
	<20060605093240.5d68e117@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=MP_qijnLoZt5FIKtdjrxRWth5N
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Saverio Mascolo <saverio.mascolo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:46050 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1750853AbWFFQm4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jun 2006 12:42:56 -0400
Received: by nf-out-0910.google.com with SMTP id m18so1745300nfc
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2006 09:42:55 -0700 (PDT)
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060605093240.5d68e117@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--MP_qijnLoZt5FIKtdjrxRWth5N
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Dear all,
   As requested you find attached patches (they should be orghogonal) to
tcp_westwood.c. Changes are listed below:

* westwood_comments.diff: Updated comments pointing to essential papers
about TCP Westwood

* westwood_bugfix.diff: Fixes a subtle bug that caused the first sample
to be wrong

* westwood_faster_filter.diff: The bandwidth estimate filter is now
initialized with the first bandwidth sample in order to have better
performances in the case of small file transfers.

* westwood_rtt_min_reset.diff: RTT_min is updated each time a timeout
event occurs (in order to cope with hard handovers in wireless
scenarios such as UMTS). A new inline function, update_rtt_min has been
added.

Signed-off-by: Luca De Cicco <ldecicco@gmail.com>

Best Regards,
Luca De Cicco
Politecnico di Bari
--MP_qijnLoZt5FIKtdjrxRWth5N
Content-Type: text/x-patch; name=westwood_bugfix.diff
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename=westwood_bugfix.diff

Index: ipv4/tcp_westwood.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- ipv4.orig/tcp_westwood.c	2006-06-06 18:08:03.000000000 +0200
+++ ipv4/tcp_westwood.c	2006-06-06 18:09:44.000000000 +0200
@@ -22,6 +22,7 @@
 	u32    accounted;
 	u32    rtt;
 	u32    rtt_min;          /* minimum observed RTT */
+	u16    first_ack;        /* flag which infers that this is the first ack =
*/
 };
=20
=20
@@ -52,6 +53,7 @@
 	w->rtt_min =3D w->rtt =3D TCP_WESTWOOD_INIT_RTT;
 	w->rtt_win_sx =3D tcp_time_stamp;
 	w->snd_una =3D tcp_sk(sk)->snd_una;
+	w->first_ack =3D 1;
 }
=20
 /*
@@ -184,6 +186,15 @@
 {
 	struct tcp_sock *tp =3D tcp_sk(sk);
 	struct westwood *w =3D inet_csk_ca(sk);
+=09
+	/* Initialise w->snd_una with the first acked sequence number in oder
+	 * to fix mismatch between tp->snd_una and w->snd_una for the first
+	 * bandwidth sample
+	 */
+        if(w->first_ack && (event =3D=3D CA_EVENT_FAST_ACK||event =3D=3D C=
A_EVENT_SLOW_ACK)) {
+		w->snd_una =3D tp->snd_una;
+		w->first_ack =3D 0;
+	}
=20
 	switch(event) {
 	case CA_EVENT_FAST_ACK:

--MP_qijnLoZt5FIKtdjrxRWth5N
Content-Type: text/x-patch; name=westwood_comments.diff
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename=westwood_comments.diff

Index: ipv4/tcp_westwood.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- ipv4.orig/tcp_westwood.c	2006-06-06 17:56:13.000000000 +0200
+++ ipv4/tcp_westwood.c	2006-06-06 17:57:13.000000000 +0200
@@ -1,9 +1,29 @@
 /*
- * TCP Westwood+
+ * TCP Westwood+: end-to-end bandwidth estimation for TCP
  *
- *	Angelo Dell'Aera:	TCP Westwood+ support
+ *      Angelo Dell'Aera: author of the first version of TCP Westwood+ in =
Linux 2.4
+ *      Luca De Cicco: current support of Westwood+ and author of the last=
 patch
+ *                     with: updated RTT_min and initial bandwidth estimate
+ *
+ * Support at http://c3lab.poliba.it/index.php/Westwood
+ * Main references in literature:
+ *
+ * - Mascolo S, Casetti, M. Gerla et al.
+ *   "TCP Westwood: bandwidth estimation for TCP" Proc. ACM Mobicom 2001
+ *
+ * - A. Grieco, s. Mascolo
+ *   "Performance evaluation of New Reno, Vegas, Westwood+ TCP" ACM Comput=
er
+ *     Comm. Review, 2004
+ *
+ * - A. Dell'Aera, L. Grieco, S. Mascolo.
+ *   "Linux 2.4 Implementation of Westwood+ TCP with Rate-Halving :
+ *    A Performance Evaluation Over the Internet" (ICC 2004), Paris, June =
2004
+ *
+ * Westwood+ employs end-to-end bandwdidth measurement to set cwnd and
+ * ssthresh after packet loss. The probing phase is as the original Reno.
  */
=20
+
 #include <linux/config.h>
 #include <linux/mm.h>
 #include <linux/module.h>

--MP_qijnLoZt5FIKtdjrxRWth5N
Content-Type: text/x-patch; name=westwood_faster_filter.diff
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename=westwood_faster_filter.diff

Index: ipv4/tcp_westwood.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- ipv4.orig/tcp_westwood.c	2006-06-06 18:14:50.000000000 +0200
+++ ipv4/tcp_westwood.c	2006-06-06 18:16:49.000000000 +0200
@@ -65,8 +65,17 @@
=20
 static inline void westwood_filter(struct westwood *w, u32 delta)
 {
-	w->bw_ns_est =3D westwood_do_filter(w->bw_ns_est, w->bk / delta);
-	w->bw_est =3D westwood_do_filter(w->bw_est, w->bw_ns_est);
+	/*
+	 * If the filter is empty fill it with the first sample of bandwidth
+	 */
+	if (w->bw_ns_est=3D=3D0 && w->bw_est=3D=3D0)
+	{
+		w->bw_ns_est =3D w->bk / delta;
+		w->bw_est =3D w->bw_ns_est ;
+	} else {
+		w->bw_ns_est =3D westwood_do_filter(w->bw_ns_est, w->bk / delta);
+		w->bw_est =3D westwood_do_filter(w->bw_est, w->bw_ns_est);
+	}
 }
=20
 /*

--MP_qijnLoZt5FIKtdjrxRWth5N
Content-Type: text/x-patch; name=westwood_rtt_min_reset.diff
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment; filename=westwood_rtt_min_reset.diff

Index: ipv4/tcp_westwood.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
--- ipv4.orig/tcp_westwood.c	2006-06-06 18:10:22.000000000 +0200
+++ ipv4/tcp_westwood.c	2006-06-06 18:13:07.000000000 +0200
@@ -15,6 +15,7 @@
 struct westwood {
 	u32    bw_ns_est;        /* first bandwidth estimation..not too smoothed =
8) */
 	u32    bw_est;           /* bandwidth estimate */
+	u16    reset_rtt_min;    /* Please reset RTT min to RTT sample*/
 	u32    rtt_win_sx;       /* here starts a new evaluation... */
 	u32    bk;
 	u32    snd_una;          /* used for evaluating the number of acked bytes=
 */
@@ -50,6 +51,7 @@
         w->bw_est =3D 0;
         w->accounted =3D 0;
         w->cumul_ack =3D 0;
+	w->reset_rtt_min =3D 1;
 	w->rtt_min =3D w->rtt =3D TCP_WESTWOOD_INIT_RTT;
 	w->rtt_win_sx =3D tcp_time_stamp;
 	w->snd_una =3D tcp_sk(sk)->snd_una;
@@ -110,6 +112,19 @@
 	}
 }
=20
+static inline void update_rtt_min(struct sock *sk)
+{
+	struct westwood *w =3D inet_csk_ca(sk);
+=09
+	if (w->reset_rtt_min) {
+		w->rtt_min =3D w->rtt;
+		w->reset_rtt_min =3D 0;=09
+	} else {
+		w->rtt_min =3D min(w->rtt, w->rtt_min);
+	}
+}
+
+
 /*
  * @westwood_fast_bw
  * It is called when we are in fast path. In particular it is called when
@@ -125,7 +140,7 @@
=20
 	w->bk +=3D tp->snd_una - w->snd_una;
 	w->snd_una =3D tp->snd_una;
-	w->rtt_min =3D min(w->rtt, w->rtt_min);
+	update_rtt_min(sk);
 }
=20
 /*
@@ -207,12 +222,14 @@
=20
 	case CA_EVENT_FRTO:
 		tp->snd_ssthresh =3D westwood_bw_rttmin(sk);
+		/* Please update RTT_min when next ack arrives */
+                w->reset_rtt_min =3D 1;
 		break;
=20
 	case CA_EVENT_SLOW_ACK:
 		westwood_update_window(sk);
 		w->bk +=3D westwood_acked_count(sk);
-		w->rtt_min =3D min(w->rtt, w->rtt_min);
+		update_rtt_min(sk);
 		break;
=20
 	default:

--MP_qijnLoZt5FIKtdjrxRWth5N--
