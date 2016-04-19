From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv3 net-next] net: use jiffies_to_msecs to replace EXPIRES_IN_MS in inet/sctp_diag
Date: Tue, 19 Apr 2016 15:10:01 +0800
Message-ID: <87a0e83132ce64a3fe2266a5323fa6577a2e5c96.1461049801.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net, eric.dumazet@gmail.com, jsitnick@redhat.com
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34773 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051AbcDSHKG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 03:10:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EXPIRES_IN_MS macro comes from net/ipv4/inet_diag.c and dates
back to before jiffies_to_msecs() has been introduced.

Now we can remove it and use jiffies_to_msecs().

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/ipv4/inet_diag.c | 12 ++++++------
 net/sctp/sctp_diag.c |  6 ++----
 2 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 70212bd..ad7956f 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -197,27 +197,27 @@ int inet_sk_diag_fill(struct sock *sk, struct inet_connection_sock *icsk,
 		goto out;
 	}
 
-#define EXPIRES_IN_MS(tmo)  DIV_ROUND_UP((tmo - jiffies) * 1000, HZ)
-
 	if (icsk->icsk_pending == ICSK_TIME_RETRANS ||
 	    icsk->icsk_pending == ICSK_TIME_EARLY_RETRANS ||
 	    icsk->icsk_pending == ICSK_TIME_LOSS_PROBE) {
 		r->idiag_timer = 1;
 		r->idiag_retrans = icsk->icsk_retransmits;
-		r->idiag_expires = EXPIRES_IN_MS(icsk->icsk_timeout);
+		r->idiag_expires =
+			jiffies_to_msecs(icsk->icsk_timeout - jiffies);
 	} else if (icsk->icsk_pending == ICSK_TIME_PROBE0) {
 		r->idiag_timer = 4;
 		r->idiag_retrans = icsk->icsk_probes_out;
-		r->idiag_expires = EXPIRES_IN_MS(icsk->icsk_timeout);
+		r->idiag_expires =
+			jiffies_to_msecs(icsk->icsk_timeout - jiffies);
 	} else if (timer_pending(&sk->sk_timer)) {
 		r->idiag_timer = 2;
 		r->idiag_retrans = icsk->icsk_probes_out;
-		r->idiag_expires = EXPIRES_IN_MS(sk->sk_timer.expires);
+		r->idiag_expires =
+			jiffies_to_msecs(sk->sk_timer.expires - jiffies);
 	} else {
 		r->idiag_timer = 0;
 		r->idiag_expires = 0;
 	}
-#undef EXPIRES_IN_MS
 
 	if ((ext & (1 << (INET_DIAG_INFO - 1))) && handler->idiag_info_size) {
 		attr = nla_reserve(skb, INET_DIAG_INFO,
diff --git a/net/sctp/sctp_diag.c b/net/sctp/sctp_diag.c
index 98ecd16..bb2d8d9 100644
--- a/net/sctp/sctp_diag.c
+++ b/net/sctp/sctp_diag.c
@@ -48,10 +48,8 @@ static void inet_diag_msg_sctpasoc_fill(struct inet_diag_msg *r,
 	r->idiag_state = asoc->state;
 	r->idiag_timer = SCTP_EVENT_TIMEOUT_T3_RTX;
 	r->idiag_retrans = asoc->rtx_data_chunks;
-#define EXPIRES_IN_MS(tmo)  DIV_ROUND_UP((tmo - jiffies) * 1000, HZ)
-	r->idiag_expires =
-		EXPIRES_IN_MS(asoc->timeouts[SCTP_EVENT_TIMEOUT_T3_RTX]);
-#undef EXPIRES_IN_MS
+	r->idiag_expires = jiffies_to_msecs(
+		asoc->timeouts[SCTP_EVENT_TIMEOUT_T3_RTX] - jiffies);
 }
 
 static int inet_diag_msg_sctpladdrs_fill(struct sk_buff *skb,
-- 
2.1.0
