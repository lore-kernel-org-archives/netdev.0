From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH 1/2] tcp: fix undo after RTO for BIC
Date: Wed, 18 Jan 2012 22:47:58 -0500
Message-ID: <1326944879-22780-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Jerry Chu <hkchu@google.com>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f74.google.com ([74.125.83.74]:65443 "EHLO
	mail-ee0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757252Ab2ASDsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 22:48:12 -0500
Received: by eekb15 with SMTP id b15so143868eek.1
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 19:48:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes BIC so that cwnd reductions made during RTOs can be
undone (just as they already can be undone when using the default/Reno
behavior).

When undoing cwnd reductions, BIC-derived congestion control modules
were restoring the cwnd from last_max_cwnd. There were two problems
with using last_max_cwnd to restore a cwnd during undo:

(a) last_max_cwnd was set to 0 on state transitions into TCP_CA_Loss
(by calling the module's reset() functions), so cwnd reductions from
RTOs could not be undone.

(b) when fast_covergence is enabled (which it is by default)
last_max_cwnd does not actually hold the value of snd_cwnd before the
loss; instead, it holds a scaled-down version of snd_cwnd.

This patch makes the following changes:

(1) upon undo, revert snd_cwnd to ca->loss_cwnd, which is already, as
the existing comment notes, the "congestion window at last loss"

(2) stop forgetting ca->loss_cwnd on TCP_CA_Loss events

(3) use ca->last_max_cwnd to check if we're in slow start

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_bic.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_bic.c b/net/ipv4/tcp_bic.c
index 6187eb4..f45e1c2 100644
--- a/net/ipv4/tcp_bic.c
+++ b/net/ipv4/tcp_bic.c
@@ -63,7 +63,6 @@ static inline void bictcp_reset(struct bictcp *ca)
 {
 	ca->cnt = 0;
 	ca->last_max_cwnd = 0;
-	ca->loss_cwnd = 0;
 	ca->last_cwnd = 0;
 	ca->last_time = 0;
 	ca->epoch_start = 0;
@@ -72,7 +71,11 @@ static inline void bictcp_reset(struct bictcp *ca)
 
 static void bictcp_init(struct sock *sk)
 {
-	bictcp_reset(inet_csk_ca(sk));
+	struct bictcp *ca = inet_csk_ca(sk);
+
+	bictcp_reset(ca);
+	ca->loss_cwnd = 0;
+
 	if (initial_ssthresh)
 		tcp_sk(sk)->snd_ssthresh = initial_ssthresh;
 }
@@ -127,7 +130,7 @@ static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
 	}
 
 	/* if in slow start or link utilization is very low */
-	if (ca->loss_cwnd == 0) {
+	if (ca->last_max_cwnd == 0) {
 		if (ca->cnt > 20) /* increase cwnd 5% per RTT */
 			ca->cnt = 20;
 	}
@@ -185,7 +188,7 @@ static u32 bictcp_undo_cwnd(struct sock *sk)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	const struct bictcp *ca = inet_csk_ca(sk);
-	return max(tp->snd_cwnd, ca->last_max_cwnd);
+	return max(tp->snd_cwnd, ca->loss_cwnd);
 }
 
 static void bictcp_state(struct sock *sk, u8 new_state)
-- 
1.7.7.3
