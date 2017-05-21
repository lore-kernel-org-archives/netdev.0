From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: fix tcp_probe_timer() for TCP_USER_TIMEOUT
Date: Sun, 21 May 2017 10:39:00 -0700
Message-ID: <1495388340.6465.50.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33491 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751233AbdEURjD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 13:39:03 -0400
Received: by mail-pf0-f195.google.com with SMTP id f27so14923626pfe.0
        for <netdev@vger.kernel.org>; Sun, 21 May 2017 10:39:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCP_USER_TIMEOUT is still converted to jiffies value in
icsk_user_timeout

So we need to make a conversion for the cases HZ != 1000 

Fixes: 9a568de4818d ("tcp: switch TCP TS option (RFC 7323) to 1ms clock")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_timer.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 27a667bce8060e6b2290fe636c27a79d0d593b48..c4a35ba7f8ed0dac573c864900b081b4847927d8 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -341,7 +341,8 @@ static void tcp_probe_timer(struct sock *sk)
 	if (!start_ts)
 		tcp_send_head(sk)->skb_mstamp = tp->tcp_mstamp;
 	else if (icsk->icsk_user_timeout &&
-		 (s32)(tcp_time_stamp(tp) - start_ts) > icsk->icsk_user_timeout)
+		 (s32)(tcp_time_stamp(tp) - start_ts) >
+		 jiffies_to_msecs(icsk->icsk_user_timeout))
 		goto abort;
 
 	max_probes = sock_net(sk)->ipv4.sysctl_tcp_retries2;
