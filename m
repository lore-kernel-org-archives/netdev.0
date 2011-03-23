From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: avoid cwnd moderation in undo
Date: Tue, 22 Mar 2011 19:37:40 -0700 (PDT)
Message-ID: <20110322.193740.179920597.davem@davemloft.net>
References: <201103141106.19679.carsten@wolffcarsten.de>
	<1300136223-855-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, nanditad@google.com,
	netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46257
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752412Ab1CWChC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 22:37:02 -0400
In-Reply-To: <1300136223-855-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Mon, 14 Mar 2011 13:57:03 -0700

> In the current undo logic, cwnd is moderated after it was restored
> to the value prior entering fast-recovery. It was moderated first
> in tcp_try_undo_recovery then again in tcp_complete_cwr.
> 
> Since the undo indicates recovery was false, these moderations
> are not necessary. If the undo is triggered when most of the
> outstanding data have been acknowledged, the (restored) cwnd is
> falsely pulled down to a small value.
> 
> This patch removes these cwnd moderations if cwnd is undone
>   a) during fast-recovery
> 	b) by receiving DSACKs past fast-recovery
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied, thank you.

I followed it up with this tidy up:

--------------------
tcp: Make undo_ssthresh arg to tcp_undo_cwr() a bool.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/tcp_input.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e72af7e..bef9f04 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2659,7 +2659,7 @@ static void DBGUNDO(struct sock *sk, const char *msg)
 #define DBGUNDO(x...) do { } while (0)
 #endif
 
-static void tcp_undo_cwr(struct sock *sk, const int undo_ssthresh)
+static void tcp_undo_cwr(struct sock *sk, const bool undo_ssthresh)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -2698,7 +2698,7 @@ static int tcp_try_undo_recovery(struct sock *sk)
 		 * or our original transmission succeeded.
 		 */
 		DBGUNDO(sk, inet_csk(sk)->icsk_ca_state == TCP_CA_Loss ? "loss" : "retrans");
-		tcp_undo_cwr(sk, 1);
+		tcp_undo_cwr(sk, true);
 		if (inet_csk(sk)->icsk_ca_state == TCP_CA_Loss)
 			mib_idx = LINUX_MIB_TCPLOSSUNDO;
 		else
@@ -2725,7 +2725,7 @@ static void tcp_try_undo_dsack(struct sock *sk)
 
 	if (tp->undo_marker && !tp->undo_retrans) {
 		DBGUNDO(sk, "D-SACK");
-		tcp_undo_cwr(sk, 1);
+		tcp_undo_cwr(sk, true);
 		tp->undo_marker = 0;
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPDSACKUNDO);
 	}
@@ -2778,7 +2778,7 @@ static int tcp_try_undo_partial(struct sock *sk, int acked)
 		tcp_update_reordering(sk, tcp_fackets_out(tp) + acked, 1);
 
 		DBGUNDO(sk, "Hoe");
-		tcp_undo_cwr(sk, 0);
+		tcp_undo_cwr(sk, false);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPPARTIALUNDO);
 
 		/* So... Do not make Hoe's retransmit yet.
@@ -2807,7 +2807,7 @@ static int tcp_try_undo_loss(struct sock *sk)
 
 		DBGUNDO(sk, "partial loss");
 		tp->lost_out = 0;
-		tcp_undo_cwr(sk, 1);
+		tcp_undo_cwr(sk, true);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPLOSSUNDO);
 		inet_csk(sk)->icsk_retransmits = 0;
 		tp->undo_marker = 0;
@@ -3496,7 +3496,7 @@ static void tcp_undo_spur_to_response(struct sock *sk, int flag)
 	if (flag & FLAG_ECE)
 		tcp_ratehalving_spur_to_response(sk);
 	else
-		tcp_undo_cwr(sk, 1);
+		tcp_undo_cwr(sk, true);
 }
 
 /* F-RTO spurious RTO detection algorithm (RFC4138)
-- 
1.7.4.1

