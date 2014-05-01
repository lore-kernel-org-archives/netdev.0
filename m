From: John Fastabend <john.fastabend@gmail.com>
Subject: [net PATCH] net: sched: lock imbalance in hhf qdisc
Date: Thu, 01 May 2014 08:15:44 -0700
Message-ID: <20140501151542.3649.8824.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: edumazet@google.com, vtlam@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:47371 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754100AbaEAPQD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 11:16:03 -0400
Received: by mail-oa0-f43.google.com with SMTP id eb12so3743641oac.2
        for <netdev@vger.kernel.org>; Thu, 01 May 2014 08:16:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hhf_change() takes the sch_tree_lock and releases it but misses the error
cases. Fix the missed case here.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/sch_hhf.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index edee03d..1803f89 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -565,8 +565,10 @@ static int hhf_change(struct Qdisc *sch, struct nlattr *opt)
 		new_hhf_non_hh_weight = nla_get_u32(tb[TCA_HHF_NON_HH_WEIGHT]);
 
 	non_hh_quantum = (u64)new_quantum * new_hhf_non_hh_weight;
-	if (non_hh_quantum > INT_MAX)
+	if (non_hh_quantum > INT_MAX) {
+		sch_tree_unlock(sch);
 		return -EINVAL;
+	}
 	q->quantum = new_quantum;
 	q->hhf_non_hh_weight = new_hhf_non_hh_weight;
 
