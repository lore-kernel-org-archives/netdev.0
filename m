From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: [PATCH] net_sched: reset pointers to tcf blocks in classful qdiscs'
 destructors
Date: Tue, 15 Aug 2017 16:35:21 +0300
Message-ID: <150280412126.717517.16274927544808177918.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@mellanox.com>, Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forwardcorp1j.cmail.yandex.net ([5.255.227.106]:33918 "EHLO
        forwardcorp1j.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750997AbdHONf1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 09:35:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Traffic filters could keep direct pointers to classes in classful qdisc,
thus qdisc destruction first removes all filters before freeing classes.
Class destruction methods also tries to free attached filters but now
this isn't safe because tcf_block_put() unlike to tcf_destroy_chain()
cannot be called second time.

This patch set class->block to NULL after first tcf_block_put() and
turn second call into no-op.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Fixes: 6529eaba33f0 ("net: sched: introduce tcf block infractructure")
---
 net/sched/sch_atm.c  |    4 +++-
 net/sched/sch_cbq.c  |    4 +++-
 net/sched/sch_hfsc.c |    4 +++-
 net/sched/sch_htb.c  |    4 +++-
 4 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 572fe2584e48..c403c87aff7a 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -572,8 +572,10 @@ static void atm_tc_destroy(struct Qdisc *sch)
 	struct atm_flow_data *flow, *tmp;
 
 	pr_debug("atm_tc_destroy(sch %p,[qdisc %p])\n", sch, p);
-	list_for_each_entry(flow, &p->flows, list)
+	list_for_each_entry(flow, &p->flows, list) {
 		tcf_block_put(flow->block);
+		flow->block = NULL;
+	}
 
 	list_for_each_entry_safe(flow, tmp, &p->flows, list) {
 		if (flow->ref > 1)
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 481036f6b54e..780db43300b1 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -1431,8 +1431,10 @@ static void cbq_destroy(struct Qdisc *sch)
 	 * be bound to classes which have been destroyed already. --TGR '04
 	 */
 	for (h = 0; h < q->clhash.hashsize; h++) {
-		hlist_for_each_entry(cl, &q->clhash.hash[h], common.hnode)
+		hlist_for_each_entry(cl, &q->clhash.hash[h], common.hnode) {
 			tcf_block_put(cl->block);
+			cl->block = NULL;
+		}
 	}
 	for (h = 0; h < q->clhash.hashsize; h++) {
 		hlist_for_each_entry_safe(cl, next, &q->clhash.hash[h],
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index 3ad02bbe6903..fd15200f8627 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1530,8 +1530,10 @@ hfsc_destroy_qdisc(struct Qdisc *sch)
 	unsigned int i;
 
 	for (i = 0; i < q->clhash.hashsize; i++) {
-		hlist_for_each_entry(cl, &q->clhash.hash[i], cl_common.hnode)
+		hlist_for_each_entry(cl, &q->clhash.hash[i], cl_common.hnode) {
 			tcf_block_put(cl->block);
+			cl->block = NULL;
+		}
 	}
 	for (i = 0; i < q->clhash.hashsize; i++) {
 		hlist_for_each_entry_safe(cl, next, &q->clhash.hash[i],
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 203286ab4427..5d65ec5207e9 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1258,8 +1258,10 @@ static void htb_destroy(struct Qdisc *sch)
 	tcf_block_put(q->block);
 
 	for (i = 0; i < q->clhash.hashsize; i++) {
-		hlist_for_each_entry(cl, &q->clhash.hash[i], common.hnode)
+		hlist_for_each_entry(cl, &q->clhash.hash[i], common.hnode) {
 			tcf_block_put(cl->block);
+			cl->block = NULL;
+		}
 	}
 	for (i = 0; i < q->clhash.hashsize; i++) {
 		hlist_for_each_entry_safe(cl, next, &q->clhash.hash[i],
