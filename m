From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] netem: fix a use after free
Date: Mon, 20 Jun 2016 15:00:43 -0700
Message-ID: <1466460043.6850.21.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1466459980.6850.20.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	WANG Cong <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33356 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020AbcFTW6N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 18:58:13 -0400
Received: by mail-pa0-f67.google.com with SMTP id ts6so11789158pac.0
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 15:57:15 -0700 (PDT)
In-Reply-To: <1466459980.6850.20.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

If the packet was dropped by lower qdisc, then we must not
access it later.

Save qdisc_pkt_len(skb) in a temp variable.

Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: WANG Cong <xiyou.wangcong@gmail.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
---
 net/sched/sch_netem.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 205bed00dd34..178f1630a036 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -650,14 +650,14 @@ deliver:
 #endif
 
 			if (q->qdisc) {
+				unsigned int pkt_len = qdisc_pkt_len(skb);
 				int err = qdisc_enqueue(skb, q->qdisc);
 
-				if (unlikely(err != NET_XMIT_SUCCESS)) {
-					if (net_xmit_drop_count(err)) {
-						qdisc_qstats_drop(sch);
-						qdisc_tree_reduce_backlog(sch, 1,
-									  qdisc_pkt_len(skb));
-					}
+				if (err != NET_XMIT_SUCCESS &&
+				    net_xmit_drop_count(err)) {
+					qdisc_qstats_drop(sch);
+					qdisc_tree_reduce_backlog(sch, 1,
+								  pkt_len);
 				}
 				goto tfifo_dequeue;
 			}
