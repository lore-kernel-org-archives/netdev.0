From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net_sched: htb: do not acquire qdisc lock in dump
 operations
Date: Wed, 05 Mar 2014 10:14:34 -0800
Message-ID: <1394043274.27473.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:56497 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850AbaCESOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 13:14:40 -0500
Received: by mail-pa0-f42.google.com with SMTP id fb1so1453824pad.1
        for <netdev@vger.kernel.org>; Wed, 05 Mar 2014 10:14:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

htb_dump() and htb_dump_class() do not strictly need to acquire
qdisc lock to fetch qdisc and/or class parameters.

We hold RTNL and no changes can occur.

This reduces by 50% qdisc lock pressure while doing tc qdisc|class dump
operations.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
Google-Bug-Id: 13305844

 net/sched/sch_htb.c |   20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index 722e137df244..9f949abcacef 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1062,12 +1062,13 @@ static int htb_init(struct Qdisc *sch, struct nlattr *opt)
 
 static int htb_dump(struct Qdisc *sch, struct sk_buff *skb)
 {
-	spinlock_t *root_lock = qdisc_root_sleeping_lock(sch);
 	struct htb_sched *q = qdisc_priv(sch);
 	struct nlattr *nest;
 	struct tc_htb_glob gopt;
 
-	spin_lock_bh(root_lock);
+	/* Its safe to not acquire qdisc lock. As we hold RTNL,
+	 * no change can happen on the qdisc parameters.
+	 */
 
 	gopt.direct_pkts = q->direct_pkts;
 	gopt.version = HTB_VER;
@@ -1081,13 +1082,10 @@ static int htb_dump(struct Qdisc *sch, struct sk_buff *skb)
 	if (nla_put(skb, TCA_HTB_INIT, sizeof(gopt), &gopt) ||
 	    nla_put_u32(skb, TCA_HTB_DIRECT_QLEN, q->direct_qlen))
 		goto nla_put_failure;
-	nla_nest_end(skb, nest);
 
-	spin_unlock_bh(root_lock);
-	return skb->len;
+	return nla_nest_end(skb, nest);
 
 nla_put_failure:
-	spin_unlock_bh(root_lock);
 	nla_nest_cancel(skb, nest);
 	return -1;
 }
@@ -1096,11 +1094,12 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 			  struct sk_buff *skb, struct tcmsg *tcm)
 {
 	struct htb_class *cl = (struct htb_class *)arg;
-	spinlock_t *root_lock = qdisc_root_sleeping_lock(sch);
 	struct nlattr *nest;
 	struct tc_htb_opt opt;
 
-	spin_lock_bh(root_lock);
+	/* Its safe to not acquire qdisc lock. As we hold RTNL,
+	 * no change can happen on the class parameters.
+	 */
 	tcm->tcm_parent = cl->parent ? cl->parent->common.classid : TC_H_ROOT;
 	tcm->tcm_handle = cl->common.classid;
 	if (!cl->level && cl->un.leaf.q)
@@ -1128,12 +1127,9 @@ static int htb_dump_class(struct Qdisc *sch, unsigned long arg,
 	    nla_put_u64(skb, TCA_HTB_CEIL64, cl->ceil.rate_bytes_ps))
 		goto nla_put_failure;
 
-	nla_nest_end(skb, nest);
-	spin_unlock_bh(root_lock);
-	return skb->len;
+	return nla_nest_end(skb, nest);
 
 nla_put_failure:
-	spin_unlock_bh(root_lock);
 	nla_nest_cancel(skb, nest);
 	return -1;
 }
