From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net] tcp_yeah: don't set ssthresh below 2
Date: Mon, 11 Jan 2016 13:42:43 -0500
Message-ID: <1452537763-28163-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f49.google.com ([209.85.192.49]:33187 "EHLO
	mail-qg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933143AbcAKSmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 13:42:45 -0500
Received: by mail-qg0-f49.google.com with SMTP id b35so280001523qge.0
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 10:42:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For tcp_yeah, use an ssthresh floor of 2, the same floor used by Reno
and CUBIC, per RFC 5681 (equation 4).

tcp_yeah_ssthresh() was sometimes returning a 0 or negative ssthresh
value if the intended reduction is as big or bigger than the current
cwnd. Congestion control modules should never return a zero or
negative ssthresh. A zero ssthresh generally results in a zero cwnd,
causing the connection to stall. A negative ssthresh value will be
interpreted as a u32 and will set a target cwnd for PRR near 4
billion.

Oleksandr Natalenko reported that a system using tcp_yeah with ECN
could see a warning about a prior_cwnd of 0 in
tcp_cwnd_reduction(). Testing verified that this was due to
tcp_yeah_ssthresh() misbehaving in this way.

Reported-by: Oleksandr Natalenko <oleksandr@natalenko.name>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_yeah.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp_yeah.c
index 17d3566..3e6a472 100644
--- a/net/ipv4/tcp_yeah.c
+++ b/net/ipv4/tcp_yeah.c
@@ -219,7 +219,7 @@ static u32 tcp_yeah_ssthresh(struct sock *sk)
 	yeah->fast_count = 0;
 	yeah->reno_count = max(yeah->reno_count>>1, 2U);
 
-	return tp->snd_cwnd - reduction;
+	return max_t(int, tp->snd_cwnd - reduction, 2);
 }
 
 static struct tcp_congestion_ops tcp_yeah __read_mostly = {
-- 
2.6.0.rc2.230.g3dd15c0
