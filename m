From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fix wraparound issue in tcp_lp
Date: Mon, 01 May 2017 15:29:48 -0700
Message-ID: <1493677788.31837.25.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34000 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750811AbdEAW3v (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 18:29:51 -0400
Received: by mail-pg0-f66.google.com with SMTP id t7so17952119pgt.1
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 15:29:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Be careful when comparing tcp_time_stamp to some u32 quantity,
otherwise result can be surprising.

Fixes: 7c106d7e782b ("[TCP]: TCP Low Priority congestion control")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_lp.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
index 046fd3910873306d74207615d6997e1c847ea361..d6fb6c067af4641f232b94e7c590c212648e8173 100644
--- a/net/ipv4/tcp_lp.c
+++ b/net/ipv4/tcp_lp.c
@@ -264,13 +264,15 @@ static void tcp_lp_pkts_acked(struct sock *sk, const struct ack_sample *sample)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct lp *lp = inet_csk_ca(sk);
+	u32 delta;
 
 	if (sample->rtt_us > 0)
 		tcp_lp_rtt_sample(sk, sample->rtt_us);
 
 	/* calc inference */
-	if (tcp_time_stamp > tp->rx_opt.rcv_tsecr)
-		lp->inference = 3 * (tcp_time_stamp - tp->rx_opt.rcv_tsecr);
+	delta = tcp_time_stamp - tp->rx_opt.rcv_tsecr;
+	if ((s32)delta > 0)
+		lp->inference = 3 * delta;
 
 	/* test if within inference */
 	if (lp->last_drop && (tcp_time_stamp - lp->last_drop < lp->inference))
