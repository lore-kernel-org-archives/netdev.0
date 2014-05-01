From: John Fastabend <john.fastabend@gmail.com>
Subject: [net PATCH v2] net: sched: lock imbalance in hhf qdisc
Date: Thu, 01 May 2014 09:23:06 -0700
Message-ID: <20140501162300.17183.83124.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, vtlam@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f41.google.com ([209.85.219.41]:41343 "EHLO
	mail-oa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbaEAQXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 12:23:20 -0400
Received: by mail-oa0-f41.google.com with SMTP id m1so1299792oag.0
        for <netdev@vger.kernel.org>; Thu, 01 May 2014 09:23:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hhf_change() takes the sch_tree_lock and releases it but misses the
error cases. Fix the missed case here.

To reproduce try a command like this,

# tc qdisc change dev p3p2 root hhf quantum 40960 non_hh_weight 300000

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/sch_hhf.c |   11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index edee03d..6e957c3 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -553,11 +553,6 @@ static int hhf_change(struct Qdisc *sch, struct nlattr *opt)
 	if (err < 0)
 		return err;
 
-	sch_tree_lock(sch);
-
-	if (tb[TCA_HHF_BACKLOG_LIMIT])
-		sch->limit = nla_get_u32(tb[TCA_HHF_BACKLOG_LIMIT]);
-
 	if (tb[TCA_HHF_QUANTUM])
 		new_quantum = nla_get_u32(tb[TCA_HHF_QUANTUM]);
 
@@ -567,6 +562,12 @@ static int hhf_change(struct Qdisc *sch, struct nlattr *opt)
 	non_hh_quantum = (u64)new_quantum * new_hhf_non_hh_weight;
 	if (non_hh_quantum > INT_MAX)
 		return -EINVAL;
+
+	sch_tree_lock(sch);
+
+	if (tb[TCA_HHF_BACKLOG_LIMIT])
+		sch->limit = nla_get_u32(tb[TCA_HHF_BACKLOG_LIMIT]);
+
 	q->quantum = new_quantum;
 	q->hhf_non_hh_weight = new_hhf_non_hh_weight;
 
