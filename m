From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH] tcp: fix infinite cwnd in tcp_complete_cwr()
Date: Sat, 28 Apr 2012 12:04:54 -0700
Message-ID: <1335639894-18569-1-git-send-email-ycheng@google.com>
Cc: ncardwell@google.com, nanditad@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:38073 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751336Ab2D1TFF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 15:05:05 -0400
Received: by qabg24 with SMTP id g24so167783qab.1
        for <netdev@vger.kernel.org>; Sat, 28 Apr 2012 12:05:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the cwnd reduction is done, ssthresh may be infinite
if TCP enters CWR via ECN or F-RTO. If cwnd is not undone, i.e.,
undo_marker is set, tcp_complete_cwr() falsely set cwnd to the
infinite ssthresh value. The correct operation is to keep cwnd
intact because it has been updated in ECN or F-RTO.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c93b0cb..ac417de 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2868,11 +2868,13 @@ static inline void tcp_complete_cwr(struct sock *sk)
 
 	/* Do not moderate cwnd if it's already undone in cwr or recovery. */
 	if (tp->undo_marker) {
-		if (inet_csk(sk)->icsk_ca_state == TCP_CA_CWR)
+		if (inet_csk(sk)->icsk_ca_state == TCP_CA_CWR) {
 			tp->snd_cwnd = min(tp->snd_cwnd, tp->snd_ssthresh);
-		else /* PRR */
+		} else if (tp->snd_ssthresh < TCP_INFINITE_SSTHRESH) {
+			/* PRR algorithm. */
 			tp->snd_cwnd = tp->snd_ssthresh;
-		tp->snd_cwnd_stamp = tcp_time_stamp;
+			tp->snd_cwnd_stamp = tcp_time_stamp;
+		}
 	}
 	tcp_ca_event(sk, CA_EVENT_COMPLETE_CWR);
 }
-- 
1.7.7.3
