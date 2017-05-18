From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: fix tcp_rearm_rto()
Date: Thu, 18 May 2017 09:15:58 -0700
Message-ID: <1495124158.6465.30.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170516210014.31176-1-edumazet@google.com>
         <20170516210014.31176-16-edumazet@google.com>
         <1495110825.6465.22.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Wei Wang <weiwan@google.com>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33045 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932318AbdERQQB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 12:16:01 -0400
Received: by mail-pg0-f68.google.com with SMTP id s62so6516749pgc.0
        for <netdev@vger.kernel.org>; Thu, 18 May 2017 09:16:01 -0700 (PDT)
In-Reply-To: <1495110825.6465.22.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

skbs in (re)transmit queue no longer have a copy of jiffies
at the time of the transmit : skb->skb_mstamp is now in usec unit,
with no correlation to tcp_jiffies32.

We have to convert rto from jiffies to usec, compute a time difference
in usec, then convert the delta to HZ units.

Fixes: 9a568de4818d ("tcp: switch TCP TS option (RFC 7323) to 1ms clock")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9a5a9e8eda899666501cca06b37948ab64ae79b2..6db6b47e2bbc09aae2627a109e5a1ee9a3f4fe4e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3002,14 +3002,14 @@ void tcp_rearm_rto(struct sock *sk)
 		if (icsk->icsk_pending == ICSK_TIME_REO_TIMEOUT ||
 		    icsk->icsk_pending == ICSK_TIME_LOSS_PROBE) {
 			struct sk_buff *skb = tcp_write_queue_head(sk);
-			const u32 rto_time_stamp =
-				tcp_skb_timestamp(skb) + rto;
-			s32 delta = (s32)(rto_time_stamp - tcp_jiffies32);
-			/* delta may not be positive if the socket is locked
+			u64 rto_time_stamp = skb->skb_mstamp +
+					     jiffies_to_usecs(rto);
+			s64 delta_us = rto_time_stamp - tp->tcp_mstamp;
+			/* delta_us may not be positive if the socket is locked
 			 * when the retrans timer fires and is rescheduled.
 			 */
-			if (delta > 0)
-				rto = delta;
+			if (delta_us > 0)
+				rto = usecs_to_jiffies(delta_us);
 		}
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS, rto,
 					  TCP_RTO_MAX);
