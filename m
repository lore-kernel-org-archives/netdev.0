From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] pkt_sched: fq: remove useless TIME_WAIT check
Date: Wed, 28 Jan 2015 06:06:36 -0800
Message-ID: <1422453996.29618.64.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:49425 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933900AbbA2Dzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 22:55:42 -0500
Received: by mail-ie0-f179.google.com with SMTP id x19so28721696ier.10
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 19:55:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TIME_WAIT sockets are not owning any skb.

ip_send_unicast_reply() and tcp_v6_send_response() both use
regular sockets.

We can safely remove a test in sch_fq and save one cache line miss,
as sk_state is far away from sk_pacing_rate.

Tested at Google for about one year.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_fq.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index 9b05924cc386ecc2cdb9816be27e439637fb37b3..2a50f5c62070a81ae37d871aac2626555128fd38 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -1,7 +1,7 @@
 /*
  * net/sched/sch_fq.c Fair Queue Packet Scheduler (per flow pacing)
  *
- *  Copyright (C) 2013 Eric Dumazet <edumazet@google.com>
+ *  Copyright (C) 2013-2015 Eric Dumazet <edumazet@google.com>
  *
  *	This program is free software; you can redistribute it and/or
  *	modify it under the terms of the GNU General Public License
@@ -471,7 +471,7 @@ begin:
 		goto out;
 
 	rate = q->flow_max_rate;
-	if (skb->sk && skb->sk->sk_state != TCP_TIME_WAIT)
+	if (skb->sk)
 		rate = min(skb->sk->sk_pacing_rate, rate);
 
 	if (rate != ~0U) {
