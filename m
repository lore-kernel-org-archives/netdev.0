From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] fq_codel: fix NET_XMIT_CN behavior
Date: Sat, 04 Jun 2016 10:43:47 -0700
Message-ID: <1465062227.2968.7.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stas Nichiporovich <stasn77@gmail.com>,
	WANG Cong <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36216 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751026AbcFDRnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2016 13:43:50 -0400
Received: by mail-pf0-f193.google.com with SMTP id 62so14309774pfd.3
        for <netdev@vger.kernel.org>; Sat, 04 Jun 2016 10:43:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

My prior attempt to fix the backlogs of parents failed.

If we return NET_XMIT_CN, our parents wont increase their backlog,
so our qdisc_tree_reduce_backlog() should take this into account.

Fixes: 9d18562a2278 ("fq_codel: add batch ability to fq_codel_drop()")
Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
Reported-by: Stas Nichiporovich <stasn77@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: WANG Cong <xiyou.wangcong@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/sch_fq_codel.c |   18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 6883a8971562..c57ec480a2da 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -240,11 +240,19 @@ static int fq_codel_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	q->drop_overlimit += prev_qlen - sch->q.qlen;
 	if (memory_limited)
 		q->drop_overmemory += prev_qlen - sch->q.qlen;
-	/* As we dropped packet(s), better let upper stack know this */
-	qdisc_tree_reduce_backlog(sch, prev_qlen - sch->q.qlen,
-				  prev_backlog - sch->qstats.backlog);
-
-	return ret == idx ? NET_XMIT_CN : NET_XMIT_SUCCESS;
+	/* As we dropped packet(s), better let upper stack know this.
+	 * If we dropped a packet for this flow, return NET_XMIT_CN,
+	 * but in this case, our parents wont increase their backlogs.
+	 */
+	prev_qlen -= sch->q.qlen;
+	prev_backlog -= sch->qstats.backlog;
+	if (ret == idx) {
+		qdisc_tree_reduce_backlog(sch, prev_qlen - 1,
+					  prev_backlog - qdisc_pkt_len(skb));
+		return NET_XMIT_CN;
+	}
+	qdisc_tree_reduce_backlog(sch, prev_qlen, prev_backlog);
+	return NET_XMIT_SUCCESS;
 }
 
 /* This is the specific function called from codel_dequeue()
