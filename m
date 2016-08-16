From: Jiri Kosina <jikos@kernel.org>
Subject: [PATCH 2/2] net: sched: avoid duplicates in qdisc dump
Date: Tue, 16 Aug 2016 23:53:46 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1608162350330.22028@cbobk.fhfr.pm>
References: <alpine.LNX.2.00.1608162339050.22028@cbobk.fhfr.pm>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Simon Horman <simon.horman@netronome.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Phil Sutter <phil@nwl.cc>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	David Ahern <dsa@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1608162339050.22028@cbobk.fhfr.pm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Kosina <jkosina@suse.cz>

tc_dump_qdisc() performs dumping of the per-device qdiscs in two phases; 
first, the "standard" dev->qdisc is being dumped. Second, if there is/are 
ingress queue(s), they are being dumped as well.

After conversion of netdevice's qdisc linked-list into hashtable, these 
two sets are not in two disjunctive sets/lists any more, but are both 
"reachable" directly from netdevice's hashtable. As a consequence, the 
"full-depth" dump of the ingress qdiscs results in immediately hitting the 
netdevice hashtable again, and duplicating the dump that has already been 
performed for dev->qdisc. 
What in fact needs to be dumped in case of ingress queue is "just" the 
top-level ingress qdisc, as everything else has been dumped already.

Fix this by extending tc_dump_qdisc_root() in a way that it can be instructed
whether it should (while performing the "full" per-netdev qdisc dump) perform
the whole recursion, or just dump "additional" top-level (ingress) qdiscs
without performing any kind of recursion.

This fixes duplicate dumps such as

	qdisc mq 0: root
	qdisc pfifo_fast 0: parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
	qdisc pfifo_fast 0: parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
	qdisc pfifo_fast 0: parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
	qdisc pfifo_fast 0: parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
	qdisc clsact ffff: parent ffff:fff1
	qdisc pfifo_fast 0: parent :4 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
	qdisc pfifo_fast 0: parent :3 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
	qdisc pfifo_fast 0: parent :2 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
	qdisc pfifo_fast 0: parent :1 bands 3 priomap  1 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1

Fixes: 59cc1f61f ("net: sched: convert qdisc linked list to hashtable")
Reported-by: Daniel Borkmann <daniel@iogearbox.net>
Tested-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Jiri Kosina <jkosina@suse.cz>
---
 net/sched/sch_api.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 2b75d68..749811f 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1440,7 +1440,7 @@ err_out:
 
 static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
 			      struct netlink_callback *cb,
-			      int *q_idx_p, int s_q_idx)
+			      int *q_idx_p, int s_q_idx, bool recur)
 {
 	int ret = 0, q_idx = *q_idx_p;
 	struct Qdisc *q;
@@ -1460,7 +1460,13 @@ static int tc_dump_qdisc_root(struct Qdisc *root, struct sk_buff *skb,
 		q_idx++;
 	}
 
-	if (!qdisc_dev(root))
+	/* If dumping singletons, there is no qdisc_dev(root) and the singleton
+	 * itself has already been dumped.
+	 *
+	 * If we've already dumped the top-level (ingress) qdisc above and the global
+	 * qdisc hashtable, we don't want to hit it again
+	 */
+	if (!qdisc_dev(root) || !recur)
 		goto out;
 
 	hash_for_each(qdisc_dev(root)->qdisc_hash, b, q, hash) {
@@ -1504,13 +1510,13 @@ static int tc_dump_qdisc(struct sk_buff *skb, struct netlink_callback *cb)
 			s_q_idx = 0;
 		q_idx = 0;
 
-		if (tc_dump_qdisc_root(dev->qdisc, skb, cb, &q_idx, s_q_idx) < 0)
+		if (tc_dump_qdisc_root(dev->qdisc, skb, cb, &q_idx, s_q_idx, true) < 0)
 			goto done;
 
 		dev_queue = dev_ingress_queue(dev);
 		if (dev_queue &&
 		    tc_dump_qdisc_root(dev_queue->qdisc_sleeping, skb, cb,
-				       &q_idx, s_q_idx) < 0)
+				       &q_idx, s_q_idx, false) < 0)
 			goto done;
 
 cont:
-- 
1.9.2
