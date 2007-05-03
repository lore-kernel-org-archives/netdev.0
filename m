From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] [TCP] Highspeed: Limited slow-start is nowadays in tcp_slow_start
Date: Thu, 3 May 2007 15:34:25 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0705031531170.3607@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1409140367-1178195665=:3607"
Cc: David Miller <davem@davemloft.net>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33941 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031225AbXECMe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 08:34:27 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1409140367-1178195665=:3607
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

Reuse limited slow-start (RFC3742) included into tcp_cong instead
of having another implementation in High Speed TCP.

Compile tested only.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_highspeed.c |   24 +++---------------------
 1 files changed, 3 insertions(+), 21 deletions(-)

diff --git a/net/ipv4/tcp_highspeed.c b/net/ipv4/tcp_highspeed.c
index a291097..43d624e 100644
--- a/net/ipv4/tcp_highspeed.c
+++ b/net/ipv4/tcp_highspeed.c
@@ -97,10 +97,6 @@ struct hstcp {
 	u32	ai;
 };
 
-static int max_ssthresh = 100;
-module_param(max_ssthresh, int, 0644);
-MODULE_PARM_DESC(max_ssthresh, "limited slow start threshold (RFC3742)");
-
 static void hstcp_init(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -122,23 +118,9 @@ static void hstcp_cong_avoid(struct sock
 	if (!tcp_is_cwnd_limited(sk, in_flight))
 		return;
 
-	if (tp->snd_cwnd <= tp->snd_ssthresh) {
-		/* RFC3742: limited slow start
-		 * the window is increased by 1/K MSS for each arriving ACK,
-		 * for K = int(cwnd/(0.5 max_ssthresh))
-		 */
-		if (max_ssthresh > 0 && tp->snd_cwnd > max_ssthresh) {
-			u32 k = max(tp->snd_cwnd / (max_ssthresh >> 1), 1U);
-			if (++tp->snd_cwnd_cnt >= k) {
-				if (tp->snd_cwnd < tp->snd_cwnd_clamp)
-					tp->snd_cwnd++;
-				tp->snd_cwnd_cnt = 0;
-			}
-		} else {
-			if (tp->snd_cwnd < tp->snd_cwnd_clamp)
-				tp->snd_cwnd++;
-		}
-	} else {
+	if (tp->snd_cwnd <= tp->snd_ssthresh)
+		tcp_slow_start(tp);
+	else {
 		/* Update AIMD parameters.
 		 *
 		 * We want to guarantee that:
-- 
1.4.2

---696243703-1409140367-1178195665=:3607--
