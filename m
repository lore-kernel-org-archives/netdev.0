From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: use ACCESS_ONCE() in tcp_update_pacing_rate()
Date: Wed, 09 Oct 2013 17:14:52 -0700
Message-ID: <1381364092.4971.57.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:54792 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756966Ab3JJAOy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Oct 2013 20:14:54 -0400
Received: by mail-pa0-f52.google.com with SMTP id kl14so1855648pab.11
        for <netdev@vger.kernel.org>; Wed, 09 Oct 2013 17:14:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

sk_pacing_rate is read by sch_fq packet scheduler at any time,
with no synchronization, so make sure we update it in a
sensible way. ACCESS_ONCE() is how we instruct compiler
to not do stupid things, like using the memory location
as a temporary variable.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 47b8ab7..b441fe6 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -755,7 +755,12 @@ static void tcp_update_pacing_rate(struct sock *sk)
 	if (tp->srtt > 8 + 2)
 		do_div(rate, tp->srtt);
 
-	sk->sk_pacing_rate = min_t(u64, rate, sk->sk_max_pacing_rate);
+	/* ACCESS_ONCE() is needed because sch_fq fetches sk_pacing_rate
+	 * without any lock. We want to make sure compiler wont store
+	 * intermediate values in this location.
+	 */
+	ACCESS_ONCE(sk->sk_pacing_rate) = min_t(u64, rate,
+						sk->sk_max_pacing_rate);
 }
 
 /* Calculate rto without backoff.  This is the second half of Van Jacobson's
