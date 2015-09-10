From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net 2/2] tcp_cubic: better follow cubic curve after idle
 period
Date: Wed, 09 Sep 2015 21:55:07 -0700
Message-ID: <1441860907.4619.44.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1441808667.4619.21.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Jana Iyengar <jri@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Sangtae Ha <sangtae.ha@gmail.com>,
	Lawrence Brakmo <lawrence@brakmo.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34427 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752659AbbIJEzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 00:55:09 -0400
Received: by padhy16 with SMTP id hy16so31294422pad.1
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 21:55:09 -0700 (PDT)
In-Reply-To: <1441808667.4619.21.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Jana Iyengar found an interesting issue on CUBIC :

The epoch is only updated/reset initially and when experiencing losses.
The delta "t" of now - epoch_start can be arbitrary large after app idle
as well as the bic_target. Consequentially the slope (inverse of
ca->cnt) would be really large, and eventually ca->cnt would be
lower-bounded in the end to 2 to have delayed-ACK slow-start behavior.

This particularly shows up when slow_start_after_idle is disabled
as a dangerous cwnd inflation (1.5 x RTT) after few seconds of idle
time.

Jana initial fix was to reset epoch_start if app limited,
but Neal pointed out it would ask the CUBIC algorithm to recalculate the
curve so that we again start growing steeply upward from where cwnd is
now (as CUBIC does just after a loss). Ideally we'd want the cwnd growth
curve to be the same shape, just shifted later in time by the amount of
the idle period.

Reported-by: Jana Iyengar <jri@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Sangtae Ha <sangtae.ha@gmail.com>
Cc: Lawrence Brakmo <lawrence@brakmo.org>
---
 net/ipv4/tcp_cubic.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index 28011fb1f4a2..c6ded6b2a79f 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -151,6 +151,21 @@ static void bictcp_init(struct sock *sk)
 		tcp_sk(sk)->snd_ssthresh = initial_ssthresh;
 }
 
+static void bictcp_cwnd_event(struct sock *sk, enum tcp_ca_event event)
+{
+	if (event == CA_EVENT_TX_START) {
+		s32 delta = tcp_time_stamp - tcp_sk(sk)->lsndtime;
+		struct bictcp *ca = inet_csk_ca(sk);
+
+		/* We were application limited (idle) for a while.
+		 * Shift epoch_start to keep cwnd growth to cubic curve.
+		 */
+		if (ca->epoch_start && delta > 0)
+			ca->epoch_start += delta;
+		return;
+	}
+}
+
 /* calculate the cubic root of x using a table lookup followed by one
  * Newton-Raphson iteration.
  * Avg err ~= 0.195%
@@ -450,6 +465,7 @@ static struct tcp_congestion_ops cubictcp __read_mostly = {
 	.cong_avoid	= bictcp_cong_avoid,
 	.set_state	= bictcp_state,
 	.undo_cwnd	= bictcp_undo_cwnd,
+	.cwnd_event	= bictcp_cwnd_event,
 	.pkts_acked     = bictcp_acked,
 	.owner		= THIS_MODULE,
 	.name		= "cubic",
