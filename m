From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next v2] net_sched: increase drop count when packets are dropped
Date: Mon, 26 May 2014 10:22:12 +0800
Message-ID: <1401070932-12440-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <vtlam@google.com>,
	<nanditad@google.com>, <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:11203 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751027AbaEZCWw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 May 2014 22:22:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we change limit in qdisc, if there're too many packets in the queue,
some packets will be dropped but the drop count is not increased.

E.g.:
 One terminal run the following command:
 # tc qdisc add dev eth4 root handle 1: htb default 1
 # tc class add dev eth4 parent 1:0 classid 1:1 htb rate 800mbit ceil 800mbit
 # tc qdisc add dev eth4 parent 1:1 handle 11: fq
 Then use iperf to send packets
 
 Another run the following scripts:
 #!/bin/sh
 int=1
 while(( $int<=5 ))
 do
 tc qdisc replace dev eth4 parent 1:1 handle 11: fq limit 10
 tc qdisc replace dev eth4 parent 1:1 handle 11: fq limit 100000
 done

 Then show the qdisc :
 # tc -s -d qdisc show dev eth4
qdisc htb 1: root refcnt 2 r2q 10 default 1 direct_packets_stat 0 ver 3.17 direct_qlen 1000
 Sent 1770938310 bytes 1175683 pkt (_dropped_ 447, overlimits 12423 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc fq 11: parent 1:1 limit 100000p flow_limit 100p buckets 1024 quantum 3028 initial_quantum 15140 
 Sent 1770970104 bytes 1175704 pkt (_dropped_ 426, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  4 flows (3 inactive, 0 throttled)
  0 gc, 0 highprio, 6748 throttled, 162 flows_plimit

The drop count of parent and leaf is not equal, becasue it only increase
the drop count of parent(htb) but not leaf(fq) in fq_change().

With this patch, they will be equal :
 # tc -s -d qdisc show dev eth4
qdisc htb 1: root refcnt 2 r2q 10 default 1 direct_packets_stat 0 ver 3.17 direct_qlen 1000
 Sent 977241352 bytes 648678 pkt (_dropped_ 512, overlimits 14209 requeues 0) 
 backlog 0b 0p requeues 0 
qdisc fq 11: parent 1:1 limit 100000p flow_limit 100p buckets 1024 quantum 3028 initial_quantum 15140 
 Sent 977274660 bytes 648700 pkt (_dropped_ 512, overlimits 0 requeues 0) 
 backlog 0b 0p requeues 0 
  5 flows (2 inactive, 0 throttled)
  0 gc, 0 highprio, 7550 throttled, 58 flows_plimit

So replace kfree_skb() with qdisc_drop() which will increase the
drop count. hhf and fq_codel have the same problem, fix them too.
Besides, fq_codel and hhf have a member drop_overlimit which means
drop count because of overlimit, increase it too.

Cc: Eric Dumazet <edumazet@google.com>
Cc: Terry Lam <vtlam@google.com>
Cc: Nandita Dukkipati <nanditad@google.com>
Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>

---
Change note:

Modify the changelog and add the description of test.
---
 net/sched/sch_fq.c       | 2 +-
 net/sched/sch_fq_codel.c | 3 ++-
 net/sched/sch_hhf.c      | 3 ++-
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_fq.c b/net/sched/sch_fq.c
index ba648e189f2e..1e350406aa53 100644
--- a/net/sched/sch_fq.c
+++ b/net/sched/sch_fq.c
@@ -756,7 +756,7 @@ static int fq_change(struct Qdisc *sch, struct nlattr *opt)
 
 		if (!skb)
 			break;
-		kfree_skb(skb);
+		qdisc_drop(skb, sch);
 		drop_count++;
 	}
 	qdisc_tree_decrease_qlen(sch, drop_count);
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 0bf432c782c1..bcfe4594470f 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -344,7 +344,8 @@ static int fq_codel_change(struct Qdisc *sch, struct nlattr *opt)
 	while (sch->q.qlen > sch->limit) {
 		struct sk_buff *skb = fq_codel_dequeue(sch);
 
-		kfree_skb(skb);
+		qdisc_drop(skb, sch);
+		q->drop_overlimit++;
 		q->cstats.drop_count++;
 	}
 	qdisc_tree_decrease_qlen(sch, q->cstats.drop_count);
diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index 6aab8619bbb0..71542d2cecac 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -593,7 +593,8 @@ static int hhf_change(struct Qdisc *sch, struct nlattr *opt)
 	while (sch->q.qlen > sch->limit) {
 		struct sk_buff *skb = hhf_dequeue(sch);
 
-		kfree_skb(skb);
+		qdisc_drop(skb, sch);
+		q->drop_overlimit++;
 	}
 	qdisc_tree_decrease_qlen(sch, qlen - sch->q.qlen);
 
-- 
1.8.0
