From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net_sched: sch_sfq: add backlog info in
 sfq_dump_class_stats()
Date: Wed, 15 Dec 2010 19:18:36 +0100
Message-ID: <1292437116.3427.386.camel@edumazet-laptop>
References: <1292421783.3427.232.camel@edumazet-laptop>
	 <4D08E6C2.804@trash.net>  <1292430424.3427.350.camel@edumazet-laptop>
	 <1292431256.3427.358.camel@edumazet-laptop>  <4D08F025.5030603@trash.net>
	 <1292432120.3427.366.camel@edumazet-laptop>  <4D08F4F4.3050501@trash.net>
	 <1292432980.3427.369.camel@edumazet-laptop>  <4D08F91C.4070000@trash.net>
	 <1292434227.3427.377.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:54798 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753326Ab0LOSSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 13:18:41 -0500
Received: by wwi17 with SMTP id 17so5644910wwi.1
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 10:18:40 -0800 (PST)
In-Reply-To: <1292434227.3427.377.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently return for each active SFQ slot the number of packets in
queue. We can also give number of bytes accounted for these packets.

tc -s class show dev ifb0

Before patch :

class sfq 11:3d9 parent 11: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 0b 3p requeues 0 
 allot 1266 

After patch :

class sfq 11:3e4 parent 11: 
 (dropped 0, overlimits 0 requeues 0) 
 backlog 4380b 3p requeues 0 
 allot 1212 


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/sched/sch_sfq.c |    7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 3cf478d..cb331de 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -548,8 +548,13 @@ static int sfq_dump_class_stats(struct Qdisc *sch, unsigned long cl,
 {
 	struct sfq_sched_data *q = qdisc_priv(sch);
 	sfq_index idx = q->ht[cl-1];
-	struct gnet_stats_queue qs = { .qlen = q->qs[idx].qlen };
+	struct sk_buff_head *list = &q->qs[idx];
+	struct gnet_stats_queue qs = { .qlen = list->qlen };
 	struct tc_sfq_xstats xstats = { .allot = q->allot[idx] };
+	struct sk_buff *skb;
+
+	skb_queue_walk(list, skb)
+		qs.backlog += qdisc_pkt_len(skb);
 
 	if (gnet_stats_copy_queue(d, &qs) < 0)
 		return -1;


