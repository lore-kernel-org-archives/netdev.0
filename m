From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/2] [TCP]: Add two new spurious RTO responses to FRTO
Date: Tue, 27 Feb 2007 17:50:06 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0702271738340.19465@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-2012005826-1172590876=:19465"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53422 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810AbXB0PuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Feb 2007 10:50:08 -0500
Content-ID: <Pine.LNX.4.64.0702271744480.19465@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-2012005826-1172590876=:19465
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0702271742371.19465@kivilampi-30.cs.helsinki.fi>

New sysctl tcp_frto_response is added to select amongst these
responses:
	- Rate halving based; reuses CA_CWR state (default)
	- Very conservative; used to be the only one available (=1)
	- Undo cwr; undoes ssthresh and cwnd reductions (=2)

The response with rate halving requires a new parameter to
tcp_enter_cwr because FRTO has already reduced ssthresh and
doing a second reduction there has to be prevented. In addition,
to keep things nice on 80 cols screen, a local variable was
added.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 include/linux/sysctl.h     |    1 +
 include/net/tcp.h          |    3 ++-
 net/ipv4/sysctl_net_ipv4.c |    8 ++++++++
 net/ipv4/tcp_input.c       |   30 ++++++++++++++++++++++++++----
 net/ipv4/tcp_output.c      |    2 +-
 5 files changed, 38 insertions(+), 6 deletions(-)

diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index a2dce72..80f11e0 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -439,6 +439,7 @@ enum
 	NET_TCP_AVAIL_CONG_CONTROL=122,
 	NET_TCP_ALLOWED_CONG_CONTROL=123,
 	NET_TCP_MAX_SSTHRESH=124,
+	NET_TCP_FRTO_RESPONSE=125,
 };
 
 enum {
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 6d09f50..f0c9e34 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -220,6 +220,7 @@ extern int sysctl_tcp_app_win;
 extern int sysctl_tcp_adv_win_scale;
 extern int sysctl_tcp_tw_reuse;
 extern int sysctl_tcp_frto;
+extern int sysctl_tcp_frto_response;
 extern int sysctl_tcp_low_latency;
 extern int sysctl_tcp_dma_copybreak;
 extern int sysctl_tcp_nometrics_save;
@@ -738,7 +739,7 @@ static inline void tcp_sync_left_out(str
 	tp->left_out = tp->sacked_out + tp->lost_out;
 }
 
-extern void tcp_enter_cwr(struct sock *sk);
+extern void tcp_enter_cwr(struct sock *sk, const int set_ssthresh);
 extern __u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_entry *dst);
 
 /* Slow start with delack produces 3 packets of burst, so that
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index d68effe..6817d64 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -647,6 +647,14 @@ #endif
 		.proc_handler	= &proc_dointvec
 	},
 	{
+		.ctl_name	= NET_TCP_FRTO_RESPONSE,
+		.procname	= "tcp_frto_response",
+		.data		= &sysctl_tcp_frto_response,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec
+	},
+	{
 		.ctl_name	= NET_TCP_LOW_LATENCY,
 		.procname	= "tcp_low_latency",
 		.data		= &sysctl_tcp_low_latency,
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f6ba07f..d6e1776 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -86,6 +86,7 @@ int sysctl_tcp_stdurg __read_mostly;
 int sysctl_tcp_rfc1337 __read_mostly;
 int sysctl_tcp_max_orphans __read_mostly = NR_FILE;
 int sysctl_tcp_frto __read_mostly;
+int sysctl_tcp_frto_response __read_mostly;
 int sysctl_tcp_nometrics_save __read_mostly;
 
 int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
@@ -762,15 +763,17 @@ __u32 tcp_init_cwnd(struct tcp_sock *tp,
 }
 
 /* Set slow start threshold and cwnd not falling to slow start */
-void tcp_enter_cwr(struct sock *sk)
+void tcp_enter_cwr(struct sock *sk, const int set_ssthresh)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
+	const struct inet_connection_sock *icsk = inet_csk(sk);
 
 	tp->prior_ssthresh = 0;
 	tp->bytes_acked = 0;
 	if (inet_csk(sk)->icsk_ca_state < TCP_CA_CWR) {
 		tp->undo_marker = 0;
-		tp->snd_ssthresh = inet_csk(sk)->icsk_ca_ops->ssthresh(sk);
+		if (set_ssthresh)
+			tp->snd_ssthresh = icsk->icsk_ca_ops->ssthresh(sk);
 		tp->snd_cwnd = min(tp->snd_cwnd,
 				   tcp_packets_in_flight(tp) + 1U);
 		tp->snd_cwnd_cnt = 0;
@@ -2003,7 +2006,7 @@ static void tcp_try_to_open(struct sock 
 		tp->retrans_stamp = 0;
 
 	if (flag&FLAG_ECE)
-		tcp_enter_cwr(sk);
+		tcp_enter_cwr(sk, 1);
 
 	if (inet_csk(sk)->icsk_ca_state != TCP_CA_CWR) {
 		int state = TCP_CA_Open;
@@ -2579,6 +2582,21 @@ static void tcp_conservative_spur_to_res
 	tcp_moderate_cwnd(tp);
 }
 
+/* A conservative spurious RTO response algorithm: reduce cwnd using
+ * rate halving and continue in congestion avoidance.
+ */
+static void tcp_ratehalving_spur_to_response(struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+	tcp_enter_cwr(sk, 0);
+	tp->high_seq = tp->frto_highmark; 	/* Smoother w/o this? - ij */
+}
+
+static void tcp_undo_spur_to_response(struct sock *sk)
+{
+	tcp_undo_cwr(sk, 1);
+}
+
 /* F-RTO spurious RTO detection algorithm (RFC4138)
  *
  * F-RTO affects during two new ACKs following RTO (well, almost, see inline
@@ -2661,7 +2679,11 @@ static int tcp_process_frto(struct sock 
 		tp->frto_counter = 2;
 		return 1;
 	} else /* frto_counter == 2 */ {
-		tcp_conservative_spur_to_response(tp);
+		switch (sysctl_tcp_frto_response) {
+		case 2: tcp_undo_spur_to_response(sk); break;
+		case 1: tcp_conservative_spur_to_response(tp); break;
+		default: tcp_ratehalving_spur_to_response(sk); break;
+		}
 		tp->frto_counter = 0;
 	}
 	return 0;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index dc15113..c9c912a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -545,7 +545,7 @@ #endif
 	if (likely(err <= 0))
 		return err;
 
-	tcp_enter_cwr(sk);
+	tcp_enter_cwr(sk, 1);
 
 	return net_xmit_eval(err);
 
-- 
1.4.2
---696243703-2012005826-1172590876=:19465--
