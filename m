From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net 6/9] sch_fq_codel: avoid double free on init failure
Date: Wed, 30 Aug 2017 12:49:02 +0300
Message-ID: <1504086545-7777-7-git-send-email-nikolay@cumulusnetworks.com>
References: <1504086545-7777-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: edumazet@google.com, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, roopa@cumulusnetworks.com,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f171.google.com ([209.85.128.171]:37499 "EHLO
        mail-wr0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751316AbdH3Jt3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 05:49:29 -0400
Received: by mail-wr0-f171.google.com with SMTP id k9so4663539wre.4
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 02:49:28 -0700 (PDT)
In-Reply-To: <1504086545-7777-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is very unlikely to happen but the backlogs memory allocation
could fail and will free q->flows, but then ->destroy() will free
q->flows too. For correctness remove the first free and let ->destroy
clean up.

Fixes: 87b60cfacf9f ("net_sched: fix error recovery at qdisc creation")
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/sched/sch_fq_codel.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index 337f2d6d81e4..2c0c05f2cc34 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -491,10 +491,8 @@ static int fq_codel_init(struct Qdisc *sch, struct nlattr *opt)
 		if (!q->flows)
 			return -ENOMEM;
 		q->backlogs = kvzalloc(q->flows_cnt * sizeof(u32), GFP_KERNEL);
-		if (!q->backlogs) {
-			kvfree(q->flows);
+		if (!q->backlogs)
 			return -ENOMEM;
-		}
 		for (i = 0; i < q->flows_cnt; i++) {
 			struct fq_codel_flow *flow = q->flows + i;
 
-- 
2.1.4
