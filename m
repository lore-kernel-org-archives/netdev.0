From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH] tcp: avoid cwnd moderation in undo
Date: Fri, 11 Mar 2011 17:40:51 -0800
Message-ID: <1299894051-13820-1-git-send-email-ycheng@google.com>
Cc: Nandita Dukkipati <nanditad@google.com>, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: David Miller <davem@davemloft.net>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:30185 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752851Ab1CLBlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 20:41:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the current undo logic, cwnd is moderated after it was restored
to the value prior entering fast-recovery. It was moderated first
in tcp_try_undo_recovery then again in tcp_complete_cwr.

Since the undo indicates recovery was false, these moderations
are not necessary. If the undo is triggered when most of the
outstanding data have been acknowledged, the (restored) cwnd is
falsely pulled down to a small value.

This patch removes these cwnd moderations if cwnd is undone during
the fast-recovery.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 08ea735..1bd0f38 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2659,7 +2659,7 @@ static void DBGUNDO(struct sock *sk, const char *msg)
 #define DBGUNDO(x...) do { } while (0)
 #endif
 
-static void tcp_undo_cwr(struct sock *sk, const int undo)
+static void tcp_undo_cwr(struct sock *sk, const int undo_ssthresh)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -2671,14 +2671,13 @@ static void tcp_undo_cwr(struct sock *sk, const int undo)
 		else
 			tp->snd_cwnd = max(tp->snd_cwnd, tp->snd_ssthresh << 1);
 
-		if (undo && tp->prior_ssthresh > tp->snd_ssthresh) {
+		if (undo_ssthresh && tp->prior_ssthresh > tp->snd_ssthresh) {
 			tp->snd_ssthresh = tp->prior_ssthresh;
 			TCP_ECN_withdraw_cwr(tp);
 		}
 	} else {
 		tp->snd_cwnd = max(tp->snd_cwnd, tp->snd_ssthresh);
 	}
-	tcp_moderate_cwnd(tp);
 	tp->snd_cwnd_stamp = tcp_time_stamp;
 }
 
@@ -2822,8 +2821,11 @@ static int tcp_try_undo_loss(struct sock *sk)
 static inline void tcp_complete_cwr(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	tp->snd_cwnd = min(tp->snd_cwnd, tp->snd_ssthresh);
-	tp->snd_cwnd_stamp = tcp_time_stamp;
+	/* Do not moderate cwnd if it's already undone in cwr or recovery */
+	if (tp->undo_marker && tp->snd_cwnd > tp->snd_ssthresh) {
+		tp->snd_cwnd = tp->snd_ssthresh;
+		tp->snd_cwnd_stamp = tcp_time_stamp;
+	}
 	tcp_ca_event(sk, CA_EVENT_COMPLETE_CWR);
 }
 
-- 
1.7.3.1

