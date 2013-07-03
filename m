From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] netem: fix possible NULL deref in netem_dequeue()
Date: Wed, 03 Jul 2013 14:04:14 -0700
Message-ID: <1372885454.4979.73.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Dan Carpenter <dan.carpenter@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:43131 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933054Ab3GCVEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 17:04:16 -0400
Received: by mail-pd0-f171.google.com with SMTP id y14so447455pdi.2
        for <netdev@vger.kernel.org>; Wed, 03 Jul 2013 14:04:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit aec0a40a6f7884 ("netem: use rb tree to implement the time queue")
added a regression if a child qdisc is attached to netem, as we perform
a NULL dereference.

Fix this by adding a temporary variable to cache
netem_skb_cb(skb)->time_to_send.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/sched/sch_netem.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index ed0082c..ca4a5d5 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -554,10 +554,13 @@ deliver:
 	}
 	p = rb_first(&q->t_root);
 	if (p) {
+		psched_time_t time_to_send;
+
 		skb = netem_rb_to_skb(p);
 
 		/* if more time remaining? */
-		if (netem_skb_cb(skb)->time_to_send <= psched_get_time()) {
+		time_to_send = netem_skb_cb(skb)->time_to_send;
+		if (time_to_send <= psched_get_time()) {
 			rb_erase(p, &q->t_root);
 
 			sch->q.qlen--;
@@ -593,8 +596,7 @@ deliver:
 			if (skb)
 				goto deliver;
 		}
-		qdisc_watchdog_schedule(&q->watchdog,
-					netem_skb_cb(skb)->time_to_send);
+		qdisc_watchdog_schedule(&q->watchdog, time_to_send);
 	}
 
 	if (q->qdisc) {
