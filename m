From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [net-2.6.22] [TCP]: Fix linkage errors.
Date: Wed, 25 Apr 2007 00:17:43 +0900 (JST)
Message-ID: <20070425.001743.19811068.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:32835 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161796AbXDXPRs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2007 11:17:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Recent ktime_t changes had introduced linkage errors.

| WARNING: "__divdi3" [net/ipv4/tcp_veno.ko] undefined!
| WARNING: "__divdi3" [net/ipv4/tcp_vegas.ko] undefined!
| WARNING: "__divdi3" [net/ipv4/tcp_lp.ko] undefined!
| WARNING: "__divdi3" [net/ipv4/tcp_illinois.ko] undefined!

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

---
diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp_illinois.c
index 8e31659..0cec615 100644
--- a/net/ipv4/tcp_illinois.c
+++ b/net/ipv4/tcp_illinois.c
@@ -87,10 +87,12 @@ static void tcp_illinois_acked(struct sock *sk, u32 pkts_acked, ktime_t last)
 {
 	struct illinois *ca = inet_csk_ca(sk);
 	u32 rtt;
+	struct timeval tv;
 
 	ca->acked = pkts_acked;
 
-	rtt = ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC;
+	tv = ktime_to_timeval(net_timedelta(last));
+	rtt = tv.tv_sec * USEC_PER_SEC + tv.tv_usec;
 
 	/* ignore bogus values, this prevents wraparound in alpha math */
 	if (rtt > RTT_MAX)
diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
index b4e062a..0b990ea 100644
--- a/net/ipv4/tcp_lp.c
+++ b/net/ipv4/tcp_lp.c
@@ -265,8 +265,10 @@ static void tcp_lp_pkts_acked(struct sock *sk, u32 num_acked, ktime_t last)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct lp *lp = inet_csk_ca(sk);
+	struct timeval tv;
 
-	tcp_lp_rtt_sample(sk,  ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC);
+	tv = ktime_to_timeval(net_timedelta(last));
+	tcp_lp_rtt_sample(sk, tv.tv_sec * USEC_PER_SEC + tv.tv_usec);
 
 	/* calc inference */
 	if (tcp_time_stamp > tp->rx_opt.rcv_tsecr)
diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp_vegas.c
index 0f0ee7f..c13dc16 100644
--- a/net/ipv4/tcp_vegas.c
+++ b/net/ipv4/tcp_vegas.c
@@ -116,9 +116,11 @@ void tcp_vegas_pkts_acked(struct sock *sk, u32 cnt, ktime_t last)
 {
 	struct vegas *vegas = inet_csk_ca(sk);
 	u32 vrtt;
+	struct timeval tv;
 
 	/* Never allow zero rtt or baseRTT */
-	vrtt = (ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC) + 1;
+	tv = ktime_to_timeval(net_timedelta(last));
+	vrtt = tv.tv_sec * USEC_PER_SEC + tv.tv_usec;
 
 	/* Filter to find propagation delay: */
 	if (vrtt < vegas->baseRTT)
diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp_veno.c
index 0b50d06..a439c49 100644
--- a/net/ipv4/tcp_veno.c
+++ b/net/ipv4/tcp_veno.c
@@ -73,9 +73,11 @@ static void tcp_veno_pkts_acked(struct sock *sk, u32 cnt, ktime_t last)
 {
 	struct veno *veno = inet_csk_ca(sk);
 	u32 vrtt;
+	struct timeval tv;
 
 	/* Never allow zero rtt or baseRTT */
-	vrtt = (ktime_to_ns(net_timedelta(last)) / NSEC_PER_USEC) + 1;
+	tv = ktime_to_timeval(net_timedelta(last));
+	vrtt = tv.tv_sec * USEC_PER_SEC + tv.tv_usec;
 
 	/* Filter to find propagation delay: */
 	if (vrtt < veno->basertt)

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
