From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH v2] tcp: fix infinite cwnd in tcp_complete_cwr()
Date: Mon, 30 Apr 2012 09:00:18 -0700
Message-ID: <1335801618-31498-1-git-send-email-ycheng@google.com>
Cc: nanditad@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ilpo.jarvinen@helsinki.fi,
	ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f74.google.com ([209.85.215.74]:47136 "EHLO
	mail-lpp01m010-f74.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753044Ab2D3QA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 12:00:28 -0400
Received: by laai8 with SMTP id i8so159332laa.1
        for <netdev@vger.kernel.org>; Mon, 30 Apr 2012 09:00:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the cwnd reduction is done, ssthresh may be infinite
if TCP enters CWR via ECN or F-RTO. If cwnd is not undone, i.e.,
undo_marker is set, tcp_complete_cwr() falsely set cwnd to the
infinite ssthresh value. The correct operation is to keep cwnd
intact because it has been updated in ECN or F-RTO.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
ChangeLog since v1:
 - Add snd_cwnd_stamp timestamping in CWR mode

 net/ipv4/tcp_input.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c93b0cb..e0a9b89 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2868,11 +2868,14 @@ static inline void tcp_complete_cwr(struct sock *sk)
 
 	/* Do not moderate cwnd if it's already undone in cwr or recovery. */
 	if (tp->undo_marker) {
-		if (inet_csk(sk)->icsk_ca_state == TCP_CA_CWR)
+		if (inet_csk(sk)->icsk_ca_state == TCP_CA_CWR) {
 			tp->snd_cwnd = min(tp->snd_cwnd, tp->snd_ssthresh);
-		else /* PRR */
+			tp->snd_cwnd_stamp = tcp_time_stamp;
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
