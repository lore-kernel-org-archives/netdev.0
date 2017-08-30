From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net 8/9] sch_sfq: fix null pointer dereference on init failure
Date: Wed, 30 Aug 2017 12:49:04 +0300
Message-ID: <1504086545-7777-9-git-send-email-nikolay@cumulusnetworks.com>
References: <1504086545-7777-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: edumazet@google.com, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, roopa@cumulusnetworks.com,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:38198 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751933AbdH3Jtc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 05:49:32 -0400
Received: by mail-wr0-f181.google.com with SMTP id 40so16418504wrv.5
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 02:49:31 -0700 (PDT)
In-Reply-To: <1504086545-7777-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently only a memory allocation failure can lead to this, so let's
initialize the timer first.

Fixes: 6529eaba33f0 ("net: sched: introduce tcf block infractructure")
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/sched/sch_sfq.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 82469ef9655e..fc69fc5956e9 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -716,13 +716,13 @@ static int sfq_init(struct Qdisc *sch, struct nlattr *opt)
 	int i;
 	int err;
 
+	setup_deferrable_timer(&q->perturb_timer, sfq_perturbation,
+			       (unsigned long)sch);
+
 	err = tcf_block_get(&q->block, &q->filter_list);
 	if (err)
 		return err;
 
-	setup_deferrable_timer(&q->perturb_timer, sfq_perturbation,
-			       (unsigned long)sch);
-
 	for (i = 0; i < SFQ_MAX_DEPTH + 1; i++) {
 		q->dep[i].next = i + SFQ_MAX_FLOWS;
 		q->dep[i].prev = i + SFQ_MAX_FLOWS;
-- 
2.1.4
