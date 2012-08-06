From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: [PATCH net] net_sched: act: Delete estimator in error path.
Date: Tue, 7 Aug 2012 00:45:48 +0900
Message-ID: <20120807004548.6f9e7b6d1e566d7eead73497@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:64576 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756276Ab2HFPpx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 11:45:53 -0400
Received: by ggnl2 with SMTP id l2so2613961ggn.19
        for <netdev@vger.kernel.org>; Mon, 06 Aug 2012 08:45:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some action modules free struct tcf_common in their error path
while estimator is still active. This results in est_timer()
dereference freed memory.
Add gen_kill_estimator() in ipt, pedit and simple action.

Signed-off-by: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
---
 net/sched/act_ipt.c    |    7 ++++++-
 net/sched/act_pedit.c  |    5 ++++-
 net/sched/act_simple.c |    5 ++++-
 3 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/net/sched/act_ipt.c b/net/sched/act_ipt.c
index 60e281a..58fb3c7 100644
--- a/net/sched/act_ipt.c
+++ b/net/sched/act_ipt.c
@@ -185,7 +185,12 @@ err3:
 err2:
 	kfree(tname);
 err1:
-	kfree(pc);
+	if (ret == ACT_P_CREATED) {
+		if (est)
+			gen_kill_estimator(&pc->tcfc_bstats,
+					   &pc->tcfc_rate_est);
+		kfree_rcu(pc, tcfc_rcu);
+	}
 	return err;
 }
 
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 26aa2f6..45c53ab 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -74,7 +74,10 @@ static int tcf_pedit_init(struct nlattr *nla, struct nlattr *est,
 		p = to_pedit(pc);
 		keys = kmalloc(ksize, GFP_KERNEL);
 		if (keys == NULL) {
-			kfree(pc);
+			if (est)
+				gen_kill_estimator(&pc->tcfc_bstats,
+						   &pc->tcfc_rate_est);
+			kfree_rcu(pc, tcfc_rcu);
 			return -ENOMEM;
 		}
 		ret = ACT_P_CREATED;
diff --git a/net/sched/act_simple.c b/net/sched/act_simple.c
index 3922f2a..3714f60 100644
--- a/net/sched/act_simple.c
+++ b/net/sched/act_simple.c
@@ -131,7 +131,10 @@ static int tcf_simp_init(struct nlattr *nla, struct nlattr *est,
 		d = to_defact(pc);
 		ret = alloc_defdata(d, defdata);
 		if (ret < 0) {
-			kfree(pc);
+			if (est)
+				gen_kill_estimator(&pc->tcfc_bstats,
+						   &pc->tcfc_rate_est);
+			kfree_rcu(pc, tcfc_rcu);
 			return ret;
 		}
 		d->tcf_action = parm->action;
-- 
1.7.8.6
