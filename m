From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH 2/2] tcp: fix undo after RTO for CUBIC
Date: Wed, 18 Jan 2012 22:47:59 -0500
Message-ID: <1326944879-22780-2-git-send-email-ncardwell@google.com>
References: <1326944879-22780-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, ilpo.jarvinen@helsinki.fi,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Jerry Chu <hkchu@google.com>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f202.google.com ([209.85.161.202]:34176 "EHLO
	mail-gx0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755582Ab2ASDsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 22:48:11 -0500
Received: by ggnv2 with SMTP id v2so399040ggn.1
        for <netdev@vger.kernel.org>; Wed, 18 Jan 2012 19:48:11 -0800 (PST)
In-Reply-To: <1326944879-22780-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes CUBIC so that cwnd reductions made during RTOs can be
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
 net/ipv4/tcp_cubic.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index f376b05..a9077f4 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -107,7 +107,6 @@ static inline void bictcp_reset(struct bictcp *ca)
 {
 	ca->cnt = 0;
 	ca->last_max_cwnd = 0;
-	ca->loss_cwnd = 0;
 	ca->last_cwnd = 0;
 	ca->last_time = 0;
 	ca->bic_origin_point = 0;
@@ -142,7 +141,10 @@ static inline void bictcp_hystart_reset(struct sock *sk)
 
 static void bictcp_init(struct sock *sk)
 {
-	bictcp_reset(inet_csk_ca(sk));
+	struct bictcp *ca = inet_csk_ca(sk);
+
+	bictcp_reset(ca);
+	ca->loss_cwnd = 0;
 
 	if (hystart)
 		bictcp_hystart_reset(sk);
@@ -275,7 +277,7 @@ static inline void bictcp_update(struct bictcp *ca, u32 cwnd)
 	 * The initial growth of cubic function may be too conservative
 	 * when the available bandwidth is still unknown.
 	 */
-	if (ca->loss_cwnd == 0 && ca->cnt > 20)
+	if (ca->last_max_cwnd == 0 && ca->cnt > 20)
 		ca->cnt = 20;	/* increase cwnd 5% per RTT */
 
 	/* TCP Friendly */
@@ -342,7 +344,7 @@ static u32 bictcp_undo_cwnd(struct sock *sk)
 {
 	struct bictcp *ca = inet_csk_ca(sk);
 
-	return max(tcp_sk(sk)->snd_cwnd, ca->last_max_cwnd);
+	return max(tcp_sk(sk)->snd_cwnd, ca->loss_cwnd);
 }
 
 static void bictcp_state(struct sock *sk, u8 new_state)
-- 
1.7.7.3
