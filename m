From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 1/2] tcp: don't extend RTO on failed loss probe attempts
Date: Fri, 17 Jul 2015 14:22:51 -0700
Message-ID: <1437168172-24201-2-git-send-email-ycheng@google.com>
References: <1437168172-24201-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:33881 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707AbbGQVXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 17:23:14 -0400
Received: by pdbbh15 with SMTP id bh15so21913724pdb.1
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 14:23:13 -0700 (PDT)
In-Reply-To: <1437168172-24201-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If TLP was unable to send a probe, it extended the RTO to
now + icsk_rto. But extending the RTO makes little sense
if no TLP probe went out. With this commit, instead of
extending the RTO we re-arm it relative to the transmit time
of the write queue head.

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_output.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7105784..deb944b 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2275,13 +2275,12 @@ void tcp_send_loss_probe(struct sock *sk)
 		tp->tlp_high_seq = tp->snd_nxt;
 
 rearm_timer:
-	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
-				  inet_csk(sk)->icsk_rto,
-				  TCP_RTO_MAX);
-
-	if (likely(!err))
-		NET_INC_STATS_BH(sock_net(sk),
-				 LINUX_MIB_TCPLOSSPROBES);
+	if (likely(!err)) {
+		/* Reset s.t. tcp_rearm_rto will restart timer from now */
+		inet_csk(sk)->icsk_pending = 0;
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPLOSSPROBES);
+	}
+	tcp_rearm_rto(sk);
 }
 
 /* Push out any pending frames which were held back due to
-- 
2.4.3.573.g4eafbef
