From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next 3/4] tcp: TCP Fast Open Server - note timestamps and retransmits for SYNACK RTT
Date: Sat, 22 Sep 2012 10:18:56 -0400
Message-ID: <1348323537-30310-3-git-send-email-ncardwell@google.com>
References: <1348323537-30310-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Jerry Chu <hkchu@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f202.google.com ([209.85.213.202]:43799 "EHLO
	mail-yx0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752117Ab2IVOTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 10:19:31 -0400
Received: by yenr11 with SMTP id r11so179988yen.1
        for <netdev@vger.kernel.org>; Sat, 22 Sep 2012 07:19:31 -0700 (PDT)
In-Reply-To: <1348323537-30310-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously, when using TCP Fast Open a server would return from
tcp_check_req() before updating snt_synack based on TCP timestamp echo
replies and whether or not we've retransmitted the SYNACK. The result
was that (a) for TFO connections using timestamps we used an incorrect
baseline SYNACK send time (tcp_time_stamp of SYNACK send instead of
rcv_tsecr), and (b) for TFO connections that do not have TCP
timestamps but retransmit the SYNACK we took a SYNACK RTT sample when
we should not take a sample.

This fix merely moves the snt_synack update logic a bit earlier in the
function, so that connections using TCP Fast Open will properly do
these updates when the ACK for the SYNACK arrives.

Moving this snt_synack update logic means that with TCP_DEFER_ACCEPT
enabled we do a few instructions of wasted work on each bare ACK, but
that seems OK.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_minisocks.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 5792577..27536ba 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -692,6 +692,12 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	if (!(flg & TCP_FLAG_ACK))
 		return NULL;
 
+	/* Got ACK for our SYNACK, so update baseline for SYNACK RTT sample. */
+	if (tmp_opt.saw_tstamp && tmp_opt.rcv_tsecr)
+		tcp_rsk(req)->snt_synack = tmp_opt.rcv_tsecr;
+	else if (req->retrans) /* don't take RTT sample if retrans && ~TS */
+		tcp_rsk(req)->snt_synack = 0;
+
 	/* For Fast Open no more processing is needed (sk is the
 	 * child socket).
 	 */
@@ -705,10 +711,6 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPDEFERACCEPTDROP);
 		return NULL;
 	}
-	if (tmp_opt.saw_tstamp && tmp_opt.rcv_tsecr)
-		tcp_rsk(req)->snt_synack = tmp_opt.rcv_tsecr;
-	else if (req->retrans) /* don't take RTT sample if retrans && ~TS */
-		tcp_rsk(req)->snt_synack = 0;
 
 	/* OK, ACK is valid, create big socket and
 	 * feed this segment to it. It will repeat all
-- 
1.7.7.3
