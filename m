From: Daniele Lacamera <root@danielinux.net>
Subject: [PATCH] *icsk_ca_priv: Reduce inet_connection_sock size?
Date: Sun, 31 Aug 2008 20:26:50 +0200
Message-ID: <48BAE26A.4060002@danielinux.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090906010101080509090704"
Cc: angelo.tornese@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from danielinux.vm.bytemark.co.uk ([80.68.95.85]:4123 "EHLO
	mail.danielinux.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752318AbYHaS0p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2008 14:26:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090906010101080509090704
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This simple patch (2.6.26) replaces the icsk_ca_priv big array with a
void pointer, reducing the default inet_connection_sock size by 60Bytes.

Each "congestion controlled" socket must allocate and free its own priv
structure if needed, from the connection init and release callbacks
inside each module.

Wouldn't this reduce memory usage for sockets that don't use ca?


Thanks

-- 
Daniele


--------------090906010101080509090704
Content-Type: text/x-diff;
 name="reduce_icsk_ca_priv_size.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="reduce_icsk_ca_priv_size.diff"

diff -ruN a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
--- a/include/net/inet_connection_sock.h	2008-07-13 23:51:29.000000000 +0200
+++ b/include/net/inet_connection_sock.h	2008-08-31 18:30:36.000000000 +0200
@@ -123,7 +123,7 @@
 		/* Information on the current probe. */
 		int		  probe_size;
 	} icsk_mtup;
-	u32			  icsk_ca_priv[16];
+	void 			  *icsk_ca_priv;
 #define ICSK_CA_PRIV_SIZE	(16 * sizeof(u32))
 };
 
diff -ruN a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2008-07-13 23:51:29.000000000 +0200
+++ b/include/net/tcp.h	2008-08-31 18:30:07.000000000 +0200
@@ -673,6 +673,9 @@
 	struct module 	*owner;
 };
 
+extern void *tcp_register_ca_priv(struct sock *sk, u32 size);
+extern void tcp_release_ca_priv(struct sock *sk);
+
 extern int tcp_register_congestion_control(struct tcp_congestion_ops *type);
 extern void tcp_unregister_congestion_control(struct tcp_congestion_ops *type);
 
diff -ruN a/net/ipv4/tcp_bic.c b/net/ipv4/tcp_bic.c
--- a/net/ipv4/tcp_bic.c	2008-07-13 23:51:29.000000000 +0200
+++ b/net/ipv4/tcp_bic.c	2008-08-31 18:57:52.000000000 +0200
@@ -70,8 +70,14 @@
 	ca->delayed_ack = 2 << ACK_RATIO_SHIFT;
 }
 
+static void bictcp_release(struct sock *sk)
+{
+	tcp_release_ca_priv(sk);
+}
+
 static void bictcp_init(struct sock *sk)
 {
+	tcp_register_ca_priv(sk, sizeof(struct bictcp));
 	bictcp_reset(inet_csk_ca(sk));
 	if (initial_ssthresh)
 		tcp_sk(sk)->snd_ssthresh = initial_ssthresh;
@@ -220,6 +226,7 @@
 
 static struct tcp_congestion_ops bictcp = {
 	.init		= bictcp_init,
+	.release	= bictcp_release,
 	.ssthresh	= bictcp_recalc_ssthresh,
 	.cong_avoid	= bictcp_cong_avoid,
 	.set_state	= bictcp_state,
diff -ruN a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
--- a/net/ipv4/tcp_cong.c	2008-07-13 23:51:29.000000000 +0200
+++ b/net/ipv4/tcp_cong.c	2008-08-31 18:32:17.000000000 +0200
@@ -73,6 +73,27 @@
 }
 EXPORT_SYMBOL_GPL(tcp_unregister_congestion_control);
 
+void *tcp_register_ca_priv(struct sock *sk, u32 size)
+{
+	struct inet_connection_sock *icsk = inet_csk(sk);
+	if (size > ICSK_CA_PRIV_SIZE){
+		return NULL;	
+	}
+	icsk->icsk_ca_priv = kmalloc(size, GFP_KERNEL);
+	return icsk->icsk_ca_priv;
+}
+EXPORT_SYMBOL_GPL(tcp_register_ca_priv);
+
+void tcp_release_ca_priv(struct sock *sk)
+{
+	struct inet_connection_sock *icsk = inet_csk(sk);
+	if (icsk->icsk_ca_priv) {
+		kfree(icsk->icsk_ca_priv);
+		icsk->icsk_ca_priv = (void *)0;
+	}
+}
+EXPORT_SYMBOL_GPL(tcp_release_ca_priv);
+
 /* Assign choice of congestion control. */
 void tcp_init_congestion_control(struct sock *sk)
 {
diff -ruN a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
--- a/net/ipv4/tcp_cubic.c	2008-07-13 23:51:29.000000000 +0200
+++ b/net/ipv4/tcp_cubic.c	2008-08-31 18:58:15.000000000 +0200
@@ -78,8 +78,14 @@
 	ca->tcp_cwnd = 0;
 }
 
+static void bictcp_release(struct sock *sk)
+{
+	tcp_release_ca_priv(sk);
+}
+
 static void bictcp_init(struct sock *sk)
 {
+	tcp_register_ca_priv(sk, sizeof(struct bictcp));
 	bictcp_reset(inet_csk_ca(sk));
 	if (initial_ssthresh)
 		tcp_sk(sk)->snd_ssthresh = initial_ssthresh;
@@ -318,6 +324,7 @@
 
 static struct tcp_congestion_ops cubictcp = {
 	.init		= bictcp_init,
+	.release	= bictcp_release,
 	.ssthresh	= bictcp_recalc_ssthresh,
 	.cong_avoid	= bictcp_cong_avoid,
 	.set_state	= bictcp_state,
diff -ruN a/net/ipv4/tcp_highspeed.c b/net/ipv4/tcp_highspeed.c
--- a/net/ipv4/tcp_highspeed.c	2008-07-13 23:51:29.000000000 +0200
+++ b/net/ipv4/tcp_highspeed.c	2008-08-31 18:58:44.000000000 +0200
@@ -97,10 +97,15 @@
 	u32	ai;
 };
 
+static void hstcp_release(struct sock *sk)
+{
+	tcp_release_ca_priv(sk);
+}
+
 static void hstcp_init(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct hstcp *ca = inet_csk_ca(sk);
+	struct hstcp *ca = tcp_register_ca_priv(sk, sizeof(struct hstcp));
 
 	ca->ai = 0;
 
@@ -160,6 +165,7 @@
 
 static struct tcp_congestion_ops tcp_highspeed = {
 	.init		= hstcp_init,
+	.release	= hstcp_release,
 	.ssthresh	= hstcp_ssthresh,
 	.cong_avoid	= hstcp_cong_avoid,
 	.min_cwnd	= tcp_reno_min_cwnd,
diff -ruN a/net/ipv4/tcp_htcp.c b/net/ipv4/tcp_htcp.c
--- a/net/ipv4/tcp_htcp.c	2008-07-13 23:51:29.000000000 +0200
+++ b/net/ipv4/tcp_htcp.c	2008-08-31 18:49:25.000000000 +0200
@@ -251,10 +251,15 @@
 	}
 }
 
-static void htcp_init(struct sock *sk)
+static void htcp_release(struct sock *sk)
 {
-	struct htcp *ca = inet_csk_ca(sk);
+	tcp_release_ca_priv(sk);	
+}
 
+static void htcp_init(struct sock *sk)
+{
+	struct htcp *ca = tcp_register_ca_priv(sk, sizeof(struct htcp));
+	
 	memset(ca, 0, sizeof(struct htcp));
 	ca->alpha = ALPHA_BASE;
 	ca->beta = BETA_MIN;
@@ -281,6 +286,7 @@
 
 static struct tcp_congestion_ops htcp = {
 	.init		= htcp_init,
+	.release	= htcp_release,
 	.ssthresh	= htcp_recalc_ssthresh,
 	.cong_avoid	= htcp_cong_avoid,
 	.set_state	= htcp_state,
diff -ruN a/net/ipv4/tcp_hybla.c b/net/ipv4/tcp_hybla.c
--- a/net/ipv4/tcp_hybla.c	2008-07-13 23:51:29.000000000 +0200
+++ b/net/ipv4/tcp_hybla.c	2008-08-31 18:49:50.000000000 +0200
@@ -42,10 +42,15 @@
 	ca->rho2 = ca->rho2_7ls >>7;
 }
 
+static void hybla_release(struct sock *sk)
+{
+	tcp_release_ca_priv(sk);
+}
+
 static void hybla_init(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct hybla *ca = inet_csk_ca(sk);
+	struct hybla *ca = tcp_register_ca_priv(sk, sizeof(struct hybla));
 
 	ca->rho = 0;
 	ca->rho2 = 0;
@@ -160,6 +165,7 @@
 
 static struct tcp_congestion_ops tcp_hybla = {
 	.init		= hybla_init,
+	.release	= hybla_release,
 	.ssthresh	= tcp_reno_ssthresh,
 	.min_cwnd	= tcp_reno_min_cwnd,
 	.cong_avoid	= hybla_cong_avoid,
diff -ruN a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
--- a/net/ipv4/tcp_illinois.c	2008-07-13 23:51:29.000000000 +0200
+++ b/net/ipv4/tcp_illinois.c	2008-08-31 19:01:03.000000000 +0200
@@ -66,9 +66,14 @@
 	/* TODO: age max_rtt? */
 }
 
+static void tcp_illinois_release(struct sock *sk)
+{
+	tcp_release_ca_priv(sk);
+}
+
 static void tcp_illinois_init(struct sock *sk)
 {
-	struct illinois *ca = inet_csk_ca(sk);
+	struct illinois *ca = tcp_register_ca_priv(sk, sizeof(struct illinois));
 
 	ca->alpha = ALPHA_MAX;
 	ca->beta = BETA_BASE;
@@ -325,6 +330,7 @@
 static struct tcp_congestion_ops tcp_illinois = {
 	.flags		= TCP_CONG_RTT_STAMP,
 	.init		= tcp_illinois_init,
+	.release	= tcp_illinois_release,
 	.ssthresh	= tcp_illinois_ssthresh,
 	.min_cwnd	= tcp_reno_min_cwnd,
 	.cong_avoid	= tcp_illinois_cong_avoid,
diff -ruN a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
--- a/net/ipv4/tcp_lp.c	2008-07-13 23:51:29.000000000 +0200
+++ b/net/ipv4/tcp_lp.c	2008-08-31 18:50:29.000000000 +0200
@@ -86,6 +86,11 @@
 	u32 inference;
 };
 
+static void tcp_lp_release(struct sock *sk)
+{
+	tcp_release_ca_priv(sk);
+}
+
 /**
  * tcp_lp_init
  *
@@ -94,7 +99,7 @@
  */
 static void tcp_lp_init(struct sock *sk)
 {
-	struct lp *lp = inet_csk_ca(sk);
+	struct lp *lp = tcp_register_ca_priv(sk, sizeof(struct lp));
 
 	lp->flag = 0;
 	lp->sowd = 0;
@@ -316,6 +321,7 @@
 static struct tcp_congestion_ops tcp_lp = {
 	.flags = TCP_CONG_RTT_STAMP,
 	.init = tcp_lp_init,
+	.release = tcp_lp_release,
 	.ssthresh = tcp_reno_ssthresh,
 	.cong_avoid = tcp_lp_cong_avoid,
 	.min_cwnd = tcp_reno_min_cwnd,
diff -ruN a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
--- a/net/ipv4/tcp_vegas.c	2008-07-13 23:51:29.000000000 +0200
+++ b/net/ipv4/tcp_vegas.c	2008-08-31 18:59:59.000000000 +0200
@@ -95,9 +95,14 @@
 	vegas->doing_vegas_now = 0;
 }
 
+void tcp_vegas_release(struct sock *sk)
+{
+	tcp_release_ca_priv(sk);
+}
+
 void tcp_vegas_init(struct sock *sk)
 {
-	struct vegas *vegas = inet_csk_ca(sk);
+	struct vegas *vegas = tcp_register_ca_priv(sk, sizeof(struct vegas));
 
 	vegas->baseRTT = 0x7fffffff;
 	vegas_enable(sk);
@@ -358,6 +363,7 @@
 static struct tcp_congestion_ops tcp_vegas = {
 	.flags		= TCP_CONG_RTT_STAMP,
 	.init		= tcp_vegas_init,
+	.release	= tcp_vegas_release,	
 	.ssthresh	= tcp_reno_ssthresh,
 	.cong_avoid	= tcp_vegas_cong_avoid,
 	.min_cwnd	= tcp_reno_min_cwnd,
diff -ruN a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
--- a/net/ipv4/tcp_veno.c	2008-07-13 23:51:29.000000000 +0200
+++ b/net/ipv4/tcp_veno.c	2008-08-31 18:51:23.000000000 +0200
@@ -59,9 +59,14 @@
 	veno->doing_veno_now = 0;
 }
 
+static void tcp_veno_release(struct sock *sk)
+{
+	tcp_release_ca_priv(sk);
+}
+
 static void tcp_veno_init(struct sock *sk)
 {
-	struct veno *veno = inet_csk_ca(sk);
+	struct veno *veno = tcp_register_ca_priv(sk, sizeof(struct veno));
 
 	veno->basertt = 0x7fffffff;
 	veno->inc = 1;
@@ -210,6 +215,7 @@
 static struct tcp_congestion_ops tcp_veno = {
 	.flags		= TCP_CONG_RTT_STAMP,
 	.init		= tcp_veno_init,
+	.release	= tcp_veno_release,
 	.ssthresh	= tcp_veno_ssthresh,
 	.cong_avoid	= tcp_veno_cong_avoid,
 	.pkts_acked	= tcp_veno_pkts_acked,
diff -ruN a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp_westwood.c
--- a/net/ipv4/tcp_westwood.c	2008-07-13 23:51:29.000000000 +0200
+++ b/net/ipv4/tcp_westwood.c	2008-08-31 18:51:41.000000000 +0200
@@ -47,6 +47,11 @@
 #define TCP_WESTWOOD_RTT_MIN   (HZ/20)	/* 50ms */
 #define TCP_WESTWOOD_INIT_RTT  (20*HZ)	/* maybe too conservative?! */
 
+static void tcp_westwood_release(struct sock *sk)
+{
+	tcp_release_ca_priv(sk);
+}
+
 /*
  * @tcp_westwood_create
  * This function initializes fields used in TCP Westwood+,
@@ -60,7 +65,7 @@
  */
 static void tcp_westwood_init(struct sock *sk)
 {
-	struct westwood *w = inet_csk_ca(sk);
+	struct westwood *w = tcp_register_ca_priv(sk, sizeof(struct westwood));
 
 	w->bk = 0;
 	w->bw_ns_est = 0;
@@ -274,6 +279,7 @@
 
 static struct tcp_congestion_ops tcp_westwood = {
 	.init		= tcp_westwood_init,
+	.release	= tcp_westwood_release,
 	.ssthresh	= tcp_reno_ssthresh,
 	.cong_avoid	= tcp_reno_cong_avoid,
 	.min_cwnd	= tcp_westwood_bw_rttmin,
diff -ruN a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
--- a/net/ipv4/tcp_yeah.c	2008-07-13 23:51:29.000000000 +0200
+++ b/net/ipv4/tcp_yeah.c	2008-08-31 19:00:33.000000000 +0200
@@ -39,10 +39,15 @@
 	u32 pkts_acked;
 };
 
+static void tcp_yeah_release(struct sock *sk)
+{
+	tcp_release_ca_priv(sk);
+}
+
 static void tcp_yeah_init(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct yeah *yeah = inet_csk_ca(sk);
+	struct yeah *yeah = tcp_register_ca_priv(sk, sizeof(struct yeah));
 
 	tcp_vegas_init(sk);
 
@@ -235,6 +240,7 @@
 static struct tcp_congestion_ops tcp_yeah = {
 	.flags		= TCP_CONG_RTT_STAMP,
 	.init		= tcp_yeah_init,
+	.release	= tcp_yeah_release,
 	.ssthresh	= tcp_yeah_ssthresh,
 	.cong_avoid	= tcp_yeah_cong_avoid,
 	.min_cwnd	= tcp_reno_min_cwnd,


--------------090906010101080509090704--
