From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: TCP's initial cwnd setting correct?...
Date: Mon, 6 Aug 2007 15:37:15 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0708061508070.8788@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1476037953-1186403835=:8788"
Cc: David Miller <davem@davemloft.net>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43728 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932143AbXHFMhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2007 08:37:19 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1476037953-1186403835=:8788
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

I'm I missing something or why it seems to me that whenever rtt stuff is 
reset, also tcp_init_cwnd is not called to do RFC3390-like initial 
window setting (remains then in 2 which is set by tcp_v4_init_sock)...
Is this done on purpose or what?

...Another thing that makes me wonder, is the tp->mss_cache > 1460 check 
as based on rfc3390 (and also it's precursor rfc2414) with up to 2190 
bytes MSS TCP can use 3 as initial cwnd...

...Compile tested patch below in case these are valid concerns... ...Goto 
logic could be cleaner (somebody has any suggestion for better way to 
structure it?)

-- 
 i.


[PATCH] [TCP]: Use IW also when RTT vars get reset & update to match RFC

Previously when RTT got reset, initial window was not being set.

Initial window defined RFC3390 (and it's precursor 2414) allows
using initial window of three as long as MSS < 2190 bytes.

Also update RFC2414 references as it's obsoleted by RFC3390.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c  |   32 +++++++++++++++++---------------
 net/ipv4/tcp_output.c |    2 +-
 2 files changed, 18 insertions(+), 16 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index eb96864..89794ec 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -805,13 +805,13 @@ void tcp_update_metrics(struct sock *sk)
 	}
 }
 
-/* Numbers are taken from RFC2414.  */
+/* Numbers are taken from RFC3390.  */
 __u32 tcp_init_cwnd(struct tcp_sock *tp, struct dst_entry *dst)
 {
 	__u32 cwnd = (dst ? dst_metric(dst, RTAX_INITCWND) : 0);
 
 	if (!cwnd) {
-		if (tp->mss_cache > 1460)
+		if (tp->mss_cache >= 2190)
 			cwnd = 2;
 		else
 			cwnd = (tp->mss_cache > 1095) ? 3 : 4;
@@ -897,22 +897,24 @@ static void tcp_init_metrics(struct sock *sk)
 	}
 	tcp_set_rto(sk);
 	tcp_bound_rto(sk);
-	if (inet_csk(sk)->icsk_rto < TCP_TIMEOUT_INIT && !tp->rx_opt.saw_tstamp)
-		goto reset;
-	tp->snd_cwnd = tcp_init_cwnd(tp, dst);
-	tp->snd_cwnd_stamp = tcp_time_stamp;
-	return;
+
+	if (inet_csk(sk)->icsk_rto < TCP_TIMEOUT_INIT && !tp->rx_opt.saw_tstamp) {
 
 reset:
-	/* Play conservative. If timestamps are not
-	 * supported, TCP will fail to recalculate correct
-	 * rtt, if initial rto is too small. FORGET ALL AND RESET!
-	 */
-	if (!tp->rx_opt.saw_tstamp && tp->srtt) {
-		tp->srtt = 0;
-		tp->mdev = tp->mdev_max = tp->rttvar = TCP_TIMEOUT_INIT;
-		inet_csk(sk)->icsk_rto = TCP_TIMEOUT_INIT;
+		/* Play conservative. If timestamps are not
+		 * supported, TCP will fail to recalculate correct
+		 * rtt, if initial rto is too small. FORGET ALL AND RESET!
+		 */
+		if (!tp->rx_opt.saw_tstamp && tp->srtt) {
+			tp->srtt = 0;
+			tp->mdev = tp->mdev_max = tp->rttvar = TCP_TIMEOUT_INIT;
+			inet_csk(sk)->icsk_rto = TCP_TIMEOUT_INIT;
+		}
 	}
+
+	tp->snd_cwnd = tcp_init_cwnd(tp, dst);
+	tp->snd_cwnd_stamp = tcp_time_stamp;
+	return;
 }
 
 static void tcp_update_reordering(struct sock *sk, const int metric,
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 3abe22e..4f9be23 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -209,7 +209,7 @@ void tcp_select_initial_window(int __space, __u32 mss,
 	}
 
 	/* Set initial window to value enough for senders,
-	 * following RFC2414. Senders, not following this RFC,
+	 * following RFC3390. Senders, not following this RFC,
 	 * will be satisfied with 2.
 	 */
 	if (mss > (1<<*rcv_wscale)) {
-- 
1.5.0.6

---696243703-1476037953-1186403835=:8788--
