From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 21/21] net: sched: drop all special handling of tx_queue_len == 0
Date: Tue, 18 Aug 2015 10:30:49 +0200
Message-ID: <1439886649-24166-22-git-send-email-phil@nwl.cc>
References: <1439886649-24166-1-git-send-email-phil@nwl.cc>
 <1439886649-24166-2-git-send-email-phil@nwl.cc>
 <1439886649-24166-3-git-send-email-phil@nwl.cc>
 <1439886649-24166-4-git-send-email-phil@nwl.cc>
 <1439886649-24166-5-git-send-email-phil@nwl.cc>
 <1439886649-24166-6-git-send-email-phil@nwl.cc>
 <1439886649-24166-7-git-send-email-phil@nwl.cc>
 <1439886649-24166-8-git-send-email-phil@nwl.cc>
 <1439886649-24166-9-git-send-email-phil@nwl.cc>
 <1439886649-24166-10-git-send-email-phil@nwl.cc>
 <1439886649-24166-11-git-send-email-phil@nwl.cc>
 <1439886649-24166-12-git-send-email-phil@nwl.cc>
 <1439886649-24166-13-git-send-email-phil@nwl.cc>
 <1439886649-24166-14-git-send-email-phil@nwl.cc>
 <1439886649-24166-15-git-send-email-phil@nwl.cc>
 <1439886649-24166-16-git-send-email-phil@nwl.cc>
 <1439886649-24166-17-git-send-email-phil@nwl.cc>
 <1439886649-24166-18-git-send-email-phil@nwl.cc>
 <1439886649-24166-19-git-send-email-phil@nwl.cc>
 <1439886649-24166-20-git-send-email-phil@nwl.cc>
 <1439886649-24166-21-git-send-email-phil@nwl.cc>
Cc: brouer@redhat.com, davem@davemloft.net,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:48564 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752136AbbHRIa5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 04:30:57 -0400
In-Reply-To: <1439886649-24166-21-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Those were all workarounds for the formerly double meaning of
tx_queue_len, which broke scheduling algorithms if untreated.

Now that all in-tree drivers have been converted away from setting
tx_queue_len = 0, it should be safe to drop these workarounds for
categorically broken setups.

Signed-off-by: Phil Sutter <phil@nwl.cc>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
---
 net/sched/sch_fifo.c | 2 +-
 net/sched/sch_gred.c | 8 +++-----
 net/sched/sch_htb.c  | 6 ++----
 net/sched/sch_plug.c | 8 ++------
 net/sched/sch_sfb.c  | 2 +-
 5 files changed, 9 insertions(+), 17 deletions(-)

diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 2e2398c..2177eac 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -54,7 +54,7 @@ static int fifo_init(struct Qdisc *sch, struct nlattr *opt)
 	bool is_bfifo = sch->ops == &bfifo_qdisc_ops;
 
 	if (opt == NULL) {
-		u32 limit = qdisc_dev(sch)->tx_queue_len ? : 1;
+		u32 limit = qdisc_dev(sch)->tx_queue_len;
 
 		if (is_bfifo)
 			limit *= psched_mtu(qdisc_dev(sch));
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index abb9f2f..8010510 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -512,11 +512,9 @@ static int gred_init(struct Qdisc *sch, struct nlattr *opt)
 
 	if (tb[TCA_GRED_LIMIT])
 		sch->limit = nla_get_u32(tb[TCA_GRED_LIMIT]);
-	else {
-		u32 qlen = qdisc_dev(sch)->tx_queue_len ? : 1;
-
-		sch->limit = qlen * psched_mtu(qdisc_dev(sch));
-	}
+	else
+		sch->limit = qdisc_dev(sch)->tx_queue_len
+		             * psched_mtu(qdisc_dev(sch));
 
 	return gred_change_table_def(sch, tb[TCA_GRED_DPS]);
 }
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index f1acb0f..cf4b0f8 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1048,11 +1048,9 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 
 	if (tb[TCA_HTB_DIRECT_QLEN])
 		q->direct_qlen = nla_get_u32(tb[TCA_HTB_DIRECT_QLEN]);
-	else {
+	else
 		q->direct_qlen = qdisc_dev(sch)->tx_queue_len;
-		if (q->direct_qlen < 2)	/* some devices have zero tx_queue_len */
-			q->direct_qlen = 2;
-	}
+
 	if ((q->rate2quantum = gopt->rate2quantum) < 1)
 		q->rate2quantum = 1;
 	q->defcls = gopt->defcls;
diff --git a/net/sched/sch_plug.c b/net/sched/sch_plug.c
index ade9445..5abfe44 100644
--- a/net/sched/sch_plug.c
+++ b/net/sched/sch_plug.c
@@ -130,12 +130,8 @@ static int plug_init(struct Qdisc *sch, struct nlattr *opt)
 	q->unplug_indefinite = false;
 
 	if (opt == NULL) {
-		/* We will set a default limit of 100 pkts (~150kB)
-		 * in case tx_queue_len is not available. The
-		 * default value is completely arbitrary.
-		 */
-		u32 pkt_limit = qdisc_dev(sch)->tx_queue_len ? : 100;
-		q->limit = pkt_limit * psched_mtu(qdisc_dev(sch));
+		q->limit = qdisc_dev(sch)->tx_queue_len
+		           * psched_mtu(qdisc_dev(sch));
 	} else {
 		struct tc_plug_qopt *ctl = nla_data(opt);
 
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index 4b81519..dcdff5c 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -502,7 +502,7 @@ static int sfb_change(struct Qdisc *sch, struct nlattr *opt)
 
 	limit = ctl->limit;
 	if (limit == 0)
-		limit = max_t(u32, qdisc_dev(sch)->tx_queue_len, 1);
+		limit = qdisc_dev(sch)->tx_queue_len;
 
 	child = fifo_create_dflt(sch, &pfifo_qdisc_ops, limit);
 	if (IS_ERR(child))
-- 
2.1.2
