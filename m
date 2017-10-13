From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 8/9] net: sched: use tcf_block_q helper to get q pointer for sch_tree_lock
Date: Fri, 13 Oct 2017 14:01:04 +0200
Message-ID: <20171013120105.23358-9-jiri@resnulli.us>
References: <20171013120105.23358-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:38360 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758083AbdJMMBP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 08:01:15 -0400
Received: by mail-wm0-f68.google.com with SMTP id q124so5579102wmb.5
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 05:01:15 -0700 (PDT)
In-Reply-To: <20171013120105.23358-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Use tcf_block_q helper to get q pointer to be used for direct call of
sch_tree_lock/unlock instead of tcf_tree_lock/unlock.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/sch_generic.h | 3 ---
 net/sched/sch_api.c       | 6 ++++--
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 9b2cb91..0aea9e2 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -359,9 +359,6 @@ static inline void sch_tree_unlock(const struct Qdisc *q)
 	spin_unlock_bh(qdisc_root_sleeping_lock(q));
 }
 
-#define tcf_tree_lock(tp)	sch_tree_lock((tp)->q)
-#define tcf_tree_unlock(tp)	sch_tree_unlock((tp)->q)
-
 extern struct Qdisc noop_qdisc;
 extern struct Qdisc_ops noop_qdisc_ops;
 extern struct Qdisc_ops pfifo_fast_ops;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index aa82116..a9ac912 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1661,9 +1661,11 @@ static int tcf_node_bind(struct tcf_proto *tp, void *n, struct tcf_walker *arg)
 	struct tcf_bind_args *a = (void *)arg;
 
 	if (tp->ops->bind_class) {
-		tcf_tree_lock(tp);
+		struct Qdisc *q = tcf_block_q(tp->chain->block);
+
+		sch_tree_lock(q);
 		tp->ops->bind_class(n, a->classid, a->cl);
-		tcf_tree_unlock(tp);
+		sch_tree_unlock(q);
 	}
 	return 0;
 }
-- 
2.9.5
