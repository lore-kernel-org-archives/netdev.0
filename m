From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net 2/2] tcp: fix reordering SNMP under-counting
Date: Tue,  4 Apr 2017 14:15:40 -0700
Message-ID: <20170404211540.47887-2-ycheng@google.com>
References: <20170404211540.47887-1-ycheng@google.com>
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        soheil@google.com, Yuchung Cheng <ycheng@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:34326 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752859AbdDDVQH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 17:16:07 -0400
Received: by mail-pf0-f169.google.com with SMTP id 197so12730315pfv.1
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 14:16:07 -0700 (PDT)
In-Reply-To: <20170404211540.47887-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently the reordering SNMP counters only increase if a connection
sees a higher degree then it has previously seen. It ignores if the
reordering degree is not greater than the default system threshold.
This significantly under-counts the number of reordering events
and falsely convey that reordering is rare on the network.

This patch properly and faithfully records the number of reordering
events detected by the TCP stack, just like the comment says "this
exciting event is worth to be remembered". Note that even so TCP
still under-estimate the actual reordering events because TCP
requires TS options or certain packet sequences to detect reordering
(i.e. ACKing never-retransmitted sequence in recovery or disordered
 state).

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/ipv4/tcp_input.c | 27 ++++++++++++++-------------
 1 file changed, 14 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a75c48f62e27..5bfe17fc8064 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -874,22 +874,11 @@ static void tcp_update_reordering(struct sock *sk, const int metric,
 				  const int ts)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
-	if (metric > tp->reordering) {
-		int mib_idx;
+	int mib_idx;
 
+	if (metric > tp->reordering) {
 		tp->reordering = min(sysctl_tcp_max_reordering, metric);
 
-		/* This exciting event is worth to be remembered. 8) */
-		if (ts)
-			mib_idx = LINUX_MIB_TCPTSREORDER;
-		else if (tcp_is_reno(tp))
-			mib_idx = LINUX_MIB_TCPRENOREORDER;
-		else if (tcp_is_fack(tp))
-			mib_idx = LINUX_MIB_TCPFACKREORDER;
-		else
-			mib_idx = LINUX_MIB_TCPSACKREORDER;
-
-		NET_INC_STATS(sock_net(sk), mib_idx);
 #if FASTRETRANS_DEBUG > 1
 		pr_debug("Disorder%d %d %u f%u s%u rr%d\n",
 			 tp->rx_opt.sack_ok, inet_csk(sk)->icsk_ca_state,
@@ -902,6 +891,18 @@ static void tcp_update_reordering(struct sock *sk, const int metric,
 	}
 
 	tp->rack.reord = 1;
+
+	/* This exciting event is worth to be remembered. 8) */
+	if (ts)
+		mib_idx = LINUX_MIB_TCPTSREORDER;
+	else if (tcp_is_reno(tp))
+		mib_idx = LINUX_MIB_TCPRENOREORDER;
+	else if (tcp_is_fack(tp))
+		mib_idx = LINUX_MIB_TCPFACKREORDER;
+	else
+		mib_idx = LINUX_MIB_TCPSACKREORDER;
+
+	NET_INC_STATS(sock_net(sk), mib_idx);
 }
 
 /* This must be called before lost_out is incremented */
-- 
2.12.2.715.g7642488e1d-goog
