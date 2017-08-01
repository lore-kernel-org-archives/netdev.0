From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net] tcp: avoid setting cwnd to invalid ssthresh after cwnd reduction states
Date: Tue,  1 Aug 2017 13:22:32 -0700
Message-ID: <20170801202232.162176-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33516 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752025AbdHAUWm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 16:22:42 -0400
Received: by mail-pf0-f176.google.com with SMTP id d67so12147105pfc.0
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 13:22:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the sender switches the congestion control during ECN-triggered
cwnd-reduction state (CA_CWR), upon exiting recovery cwnd is set to
the ssthresh value calculated by the previous congestion control. If
the previous congestion control is BBR that always keep ssthresh
to TCP_INIFINITE_SSTHRESH, cwnd ends up being infinite. The safe
step is to avoid assigning invalid ssthresh value when recovery ends.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_input.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2920e0cb09f8..dad026fcfd09 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2520,8 +2520,8 @@ static inline void tcp_end_cwnd_reduction(struct sock *sk)
 		return;
 
 	/* Reset cwnd to ssthresh in CWR or Recovery (unless it's undone) */
-	if (inet_csk(sk)->icsk_ca_state == TCP_CA_CWR ||
-	    (tp->undo_marker && tp->snd_ssthresh < TCP_INFINITE_SSTHRESH)) {
+	if (tp->snd_ssthresh < TCP_INFINITE_SSTHRESH &&
+	    (inet_csk(sk)->icsk_ca_state == TCP_CA_CWR || tp->undo_marker)) {
 		tp->snd_cwnd = tp->snd_ssthresh;
 		tp->snd_cwnd_stamp = tcp_jiffies32;
 	}
-- 
2.14.0.rc1.383.gd1ce394fe2-goog
