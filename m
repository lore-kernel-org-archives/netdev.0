From: Yang Yingliang <yangyingliang@huawei.com>
Subject: [PATCH net-next] sch_htb: add HTB_LEAF_LIMIT attribute
Date: Fri, 6 Dec 2013 17:32:04 +0800
Message-ID: <1386322324-87976-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <eric.dumazet@gmail.com>, <jhs@mojatatu.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:40614 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753442Ab3LFJcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Dec 2013 04:32:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HTB uses an internal pfifo queue, which limit is inherited from
device tx_queue_len. But virtual device's tx_queue_len is 0, so
the limit will be initialized to 1.

Introduce TCA_HTB_LEAF_LIMIT attribute to allow finer control.

Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
---
 include/uapi/linux/pkt_sched.h |  1 +
 net/sched/sch_htb.c            | 16 ++++++++++++++--
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index 307f293..071d592 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -361,6 +361,7 @@ enum {
 	TCA_HTB_DIRECT_QLEN,
 	TCA_HTB_RATE64,
 	TCA_HTB_CEIL64,
+	TCA_HTB_LEAF_LIMIT,
 	__TCA_HTB_MAX,
 };
 
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 0e1e38b..424f54f 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -999,6 +999,7 @@ static const struct nla_policy htb_policy[TCA_HTB_MAX + 1] = {
 	[TCA_HTB_DIRECT_QLEN] = { .type = NLA_U32 },
 	[TCA_HTB_RATE64] = { .type = NLA_U64 },
 	[TCA_HTB_CEIL64] = { .type = NLA_U64 },
+	[TCA_HTB_LEAF_LIMIT] = { .type = NLA_U32 },
 };
 
 static void htb_work_func(struct work_struct *work)
@@ -1122,6 +1123,8 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 	if ((cl->ceil.rate_bytes_ps >= (1ULL << 32)) &&
 	    nla_put_u64(skb, TCA_HTB_CEIL64, cl->ceil.rate_bytes_ps))
 		goto nla_put_failure;
+	if (nla_put_u32(skb, TCA_HTB_LEAF_LIMIT, cl->un.leaf.q->limit))
+		goto nla_put_failure;
 
 	nla_nest_end(skb, nest);
 	spin_unlock_bh(root_lock);
@@ -1341,6 +1344,7 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 	struct nlattr *tb[TCA_HTB_MAX + 1];
 	struct tc_htb_opt *hopt;
 	u64 rate64, ceil64;
+	u32 limit = 0;
 
 	/* extract all subattrs from opt attr */
 	if (!opt)
@@ -1372,6 +1376,11 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 			qdisc_put_rtab(ctab);
 	}
 
+	if (tb[TCA_HTB_LEAF_LIMIT])
+		limit = nla_get_u32(tb[TCA_HTB_LEAF_LIMIT]);
+	else
+		limit = qdisc_dev(sch)->tx_queue_len ? : 1;
+
 	if (!cl) {		/* new class */
 		struct Qdisc *new_q;
 		int prio;
@@ -1427,8 +1436,11 @@ static int htb_change_class(struct Qdisc *sch, u32 classid,
 		 * so that can't be used inside of sch_tree_lock
 		 * -- thanks to Karlis Peisenieks
 		 */
-		new_q = qdisc_create_dflt(sch->dev_queue,
-					  &pfifo_qdisc_ops, classid);
+		new_q = fifo_create_dflt(sch, &pfifo_qdisc_ops, limit);
+		if (IS_ERR(new_q))
+			new_q = NULL;
+		else
+			new_q->parent = classid;
 		sch_tree_lock(sch);
 		if (parent && !parent->level) {
 			unsigned int qlen = parent->un.leaf.q->q.qlen;
-- 
1.8.0
