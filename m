From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH 4/4 net-next] tcp: undo on DSACK during recovery
Date: Wed, 29 May 2013 17:20:14 -0700
Message-ID: <1369873214-29502-4-git-send-email-ycheng@google.com>
References: <1369873214-29502-1-git-send-email-ycheng@google.com>
Cc: aterzis@google.com, netdev@vger.kernel.org,
	Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net, ncardwell@google.com, edumazet@google.com,
	nanditad@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f201.google.com ([209.85.213.201]:62800 "EHLO
	mail-ye0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593Ab3E3At2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 20:49:28 -0400
Received: by mail-ye0-f201.google.com with SMTP id q9so671864yen.4
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 17:49:27 -0700 (PDT)
In-Reply-To: <1369873214-29502-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the receiver supports DSACK, sender can detect false recoveries and
revert cwnd reductions triggered by either severe network reordering or
concurrent reordering and loss event.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
---
 net/ipv4/tcp_input.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index c35b227..907311c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2315,7 +2315,7 @@ static bool tcp_try_undo_recovery(struct sock *sk)
 }
 
 /* Try to undo cwnd reduction, because D-SACKs acked all retransmitted data */
-static void tcp_try_undo_dsack(struct sock *sk)
+static bool tcp_try_undo_dsack(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -2323,7 +2323,9 @@ static void tcp_try_undo_dsack(struct sock *sk)
 		DBGUNDO(sk, "D-SACK");
 		tcp_undo_cwnd_reduction(sk, false);
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPDSACKUNDO);
+		return true;
 	}
+	return false;
 }
 
 /* We can clear retrans_stamp when there are no retransmissions in the
@@ -2751,6 +2753,10 @@ static void tcp_fastretrans_alert(struct sock *sk, const int acked,
 			do_lost = tcp_is_reno(tp) ||
 				  tcp_fackets_out(tp) > tp->reordering;
 		}
+		if (tcp_try_undo_dsack(sk)) {
+			tcp_try_keep_open(sk);
+			return;
+		}
 		break;
 	case TCP_CA_Loss:
 		tcp_process_loss(sk, flag, is_dupack);
-- 
1.8.2.1
