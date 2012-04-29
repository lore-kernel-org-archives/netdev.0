From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netem: fix possible skb leak
Date: Sun, 29 Apr 2012 21:08:22 +0200
Message-ID: <1335726502.3897.8.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:46078 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753564Ab2D2TI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2012 15:08:28 -0400
Received: by wgbdr13 with SMTP id dr13so2407975wgb.1
        for <netdev@vger.kernel.org>; Sun, 29 Apr 2012 12:08:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

skb_checksum_help(skb) can return an error, we must free skb in this
case. qdisc_drop(skb, sch) can also be feeded with a NULL skb (if
skb_unshare() failed), so lets use this generic helper.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Stephen Hemminger <shemminger@osdl.org>
---
 net/sched/sch_netem.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 5da548f..ebd2296 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -408,10 +408,8 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (q->corrupt && q->corrupt >= get_crandom(&q->corrupt_cor)) {
 		if (!(skb = skb_unshare(skb, GFP_ATOMIC)) ||
 		    (skb->ip_summed == CHECKSUM_PARTIAL &&
-		     skb_checksum_help(skb))) {
-			sch->qstats.drops++;
-			return NET_XMIT_DROP;
-		}
+		     skb_checksum_help(skb)))
+			return qdisc_drop(skb, sch);
 
 		skb->data[net_random() % skb_headlen(skb)] ^= 1<<(net_random() % 8);
 	}
