From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/34] net: sched: use tcf_block_q helper to get q pointer for sch_tree_lock
Date: Thu, 12 Oct 2017 19:17:59 +0200
Message-ID: <20171012171823.1431-11-jiri@resnulli.us>
References: <20171012171823.1431-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, edumazet@google.com, dsahern@gmail.com,
        alexander.h.duyck@intel.com, john.fastabend@gmail.com,
        willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:51962 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753416AbdJLRSf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:35 -0400
Received: by mail-wm0-f65.google.com with SMTP id f4so15295606wme.0
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:34 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
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
index 0b2ba3b..a4926c9 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -361,9 +361,6 @@ static inline void sch_tree_unlock(const struct Qdisc *q)
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
