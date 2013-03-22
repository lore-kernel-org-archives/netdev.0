From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] tcp: preserve ACK clocking in TSO
Date: Thu, 21 Mar 2013 20:36:09 -0700
Message-ID: <1363923369.4431.53.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Van Jacobson <vanj@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:55260 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753645Ab3CVDgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 23:36:12 -0400
Received: by mail-pd0-f172.google.com with SMTP id w10so1387287pde.17
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 20:36:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

A long standing problem with TSO is the fact that tcp_tso_should_defer()
rearms the deferred timer, while it should not.

Current code leads to following bad bursty behavior :

20:11:24.484333 IP A > B: . 297161:316921(19760) ack 1 win 119
20:11:24.484337 IP B > A: . ack 263721 win 1117
20:11:24.485086 IP B > A: . ack 265241 win 1117
20:11:24.485925 IP B > A: . ack 266761 win 1117
20:11:24.486759 IP B > A: . ack 268281 win 1117
20:11:24.487594 IP B > A: . ack 269801 win 1117
20:11:24.488430 IP B > A: . ack 271321 win 1117
20:11:24.489267 IP B > A: . ack 272841 win 1117
20:11:24.490104 IP B > A: . ack 274361 win 1117
20:11:24.490939 IP B > A: . ack 275881 win 1117
20:11:24.491775 IP B > A: . ack 277401 win 1117
20:11:24.491784 IP A > B: . 316921:332881(15960) ack 1 win 119
20:11:24.492620 IP B > A: . ack 278921 win 1117
20:11:24.493448 IP B > A: . ack 280441 win 1117
20:11:24.494286 IP B > A: . ack 281961 win 1117
20:11:24.495122 IP B > A: . ack 283481 win 1117
20:11:24.495958 IP B > A: . ack 285001 win 1117
20:11:24.496791 IP B > A: . ack 286521 win 1117
20:11:24.497628 IP B > A: . ack 288041 win 1117
20:11:24.498459 IP B > A: . ack 289561 win 1117
20:11:24.499296 IP B > A: . ack 291081 win 1117
20:11:24.500133 IP B > A: . ack 292601 win 1117
20:11:24.500970 IP B > A: . ack 294121 win 1117
20:11:24.501388 IP B > A: . ack 295641 win 1117
20:11:24.501398 IP A > B: . 332881:351881(19000) ack 1 win 119

While the expected behavior is more like :

20:19:49.259620 IP A > B: . 197601:202161(4560) ack 1 win 119
20:19:49.260446 IP B > A: . ack 154281 win 1212
20:19:49.261282 IP B > A: . ack 155801 win 1212
20:19:49.262125 IP B > A: . ack 157321 win 1212
20:19:49.262136 IP A > B: . 202161:206721(4560) ack 1 win 119
20:19:49.262958 IP B > A: . ack 158841 win 1212
20:19:49.263795 IP B > A: . ack 160361 win 1212
20:19:49.264628 IP B > A: . ack 161881 win 1212
20:19:49.264637 IP A > B: . 206721:211281(4560) ack 1 win 119
20:19:49.265465 IP B > A: . ack 163401 win 1212
20:19:49.265886 IP B > A: . ack 164921 win 1212
20:19:49.266722 IP B > A: . ack 166441 win 1212
20:19:49.266732 IP A > B: . 211281:215841(4560) ack 1 win 119
20:19:49.267559 IP B > A: . ack 167961 win 1212
20:19:49.268394 IP B > A: . ack 169481 win 1212
20:19:49.269232 IP B > A: . ack 171001 win 1212
20:19:49.269241 IP A > B: . 215841:221161(5320) ack 1 win 119

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Yuchung Cheng <ycheng@google.com>
Cc: Van Jacobson <vanj@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Nandita Dukkipati <nanditad@google.com>
---
 net/ipv4/tcp_output.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 817fbb3..5d0b438 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1809,8 +1809,11 @@ static bool tcp_tso_should_defer(struct sock *sk, struct sk_buff *skb)
 			goto send_now;
 	}
 
-	/* Ok, it looks like it is advisable to defer.  */
-	tp->tso_deferred = 1 | (jiffies << 1);
+	/* Ok, it looks like it is advisable to defer.
+	 * Do not rearm the timer if already set to not break TCP ACK clocking.
+	 */
+	if (!tp->tso_deferred)
+		tp->tso_deferred = 1 | (jiffies << 1);
 
 	return true;
 
