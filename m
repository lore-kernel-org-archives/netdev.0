From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net 4/9] sch_hfsc: fix null pointer deref and double free on init failure
Date: Wed, 30 Aug 2017 12:49:00 +0300
Message-ID: <1504086545-7777-5-git-send-email-nikolay@cumulusnetworks.com>
References: <1504086545-7777-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: edumazet@google.com, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, roopa@cumulusnetworks.com,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35869 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751298AbdH3Jt0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 05:49:26 -0400
Received: by mail-wm0-f49.google.com with SMTP id u126so6400169wmg.1
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 02:49:25 -0700 (PDT)
In-Reply-To: <1504086545-7777-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Depending on where ->init fails we can get a null pointer deref due to
uninitialized hires timer (watchdog) or a double free of the qdisc hash
because it is already freed by ->destroy().

Fixes: 8d5537387505 ("net/sched/hfsc: allocate tcf block for hfsc root class")
Fixes: 87b60cfacf9f ("net_sched: fix error recovery at qdisc creation")
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/sched/sch_hfsc.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index fd15200f8627..11ab8dace901 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1418,6 +1418,8 @@ hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 	struct tc_hfsc_qopt *qopt;
 	int err;
 
+	qdisc_watchdog_init(&q->watchdog, sch);
+
 	if (opt == NULL || nla_len(opt) < sizeof(*qopt))
 		return -EINVAL;
 	qopt = nla_data(opt);
@@ -1430,7 +1432,7 @@ hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 
 	err = tcf_block_get(&q->root.block, &q->root.filter_list);
 	if (err)
-		goto err_tcf;
+		return err;
 
 	q->root.cl_common.classid = sch->handle;
 	q->root.refcnt  = 1;
@@ -1448,13 +1450,7 @@ hfsc_init_qdisc(struct Qdisc *sch, struct nlattr *opt)
 	qdisc_class_hash_insert(&q->clhash, &q->root.cl_common);
 	qdisc_class_hash_grow(sch, &q->clhash);
 
-	qdisc_watchdog_init(&q->watchdog, sch);
-
 	return 0;
-
-err_tcf:
-	qdisc_class_hash_destroy(&q->clhash);
-	return err;
 }
 
 static int
-- 
2.1.4
