From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/34] net: sched: tcindex, fw, flow: use tcf_block_q helper to get struct Qdisc
Date: Thu, 12 Oct 2017 19:17:58 +0200
Message-ID: <20171012171823.1431-10-jiri@resnulli.us>
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
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35333 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752501AbdJLRSd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:33 -0400
Received: by mail-wm0-f66.google.com with SMTP id b189so4344755wmd.2
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:33 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Use helper to get q pointer per block.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/sched/cls_flow.c    | 7 +++++--
 net/sched/cls_fw.c      | 5 ++++-
 net/sched/cls_tcindex.c | 5 ++++-
 3 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 2a3a60e..f3be666 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -491,8 +491,11 @@ static int flow_change(struct net *net, struct sk_buff *in_skb,
 			perturb_period = nla_get_u32(tb[TCA_FLOW_PERTURB]) * HZ;
 		}
 
-		if (TC_H_MAJ(baseclass) == 0)
-			baseclass = TC_H_MAKE(tp->q->handle, baseclass);
+		if (TC_H_MAJ(baseclass) == 0) {
+			struct Qdisc *q = tcf_block_q(tp->chain->block);
+
+			baseclass = TC_H_MAKE(q->handle, baseclass);
+		}
 		if (TC_H_MIN(baseclass) == 0)
 			baseclass = TC_H_MAKE(baseclass, 1);
 
diff --git a/net/sched/cls_fw.c b/net/sched/cls_fw.c
index 941245a..aa1e1f3 100644
--- a/net/sched/cls_fw.c
+++ b/net/sched/cls_fw.c
@@ -28,6 +28,7 @@
 #include <net/netlink.h>
 #include <net/act_api.h>
 #include <net/pkt_cls.h>
+#include <net/sch_generic.h>
 
 #define HTSIZE 256
 
@@ -83,9 +84,11 @@ static int fw_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 			}
 		}
 	} else {
+		struct Qdisc *q = tcf_block_q(tp->chain->block);
+
 		/* Old method: classify the packet using its skb mark. */
 		if (id && (TC_H_MAJ(id) == 0 ||
-			   !(TC_H_MAJ(id ^ tp->q->handle)))) {
+			   !(TC_H_MAJ(id ^ q->handle)))) {
 			res->classid = id;
 			res->class = 0;
 			return 0;
diff --git a/net/sched/cls_tcindex.c b/net/sched/cls_tcindex.c
index 14a7e08..d732b54 100644
--- a/net/sched/cls_tcindex.c
+++ b/net/sched/cls_tcindex.c
@@ -13,6 +13,7 @@
 #include <net/act_api.h>
 #include <net/netlink.h>
 #include <net/pkt_cls.h>
+#include <net/sch_generic.h>
 
 /*
  * Passing parameters to the root seems to be done more awkwardly than really
@@ -90,9 +91,11 @@ static int tcindex_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 
 	f = tcindex_lookup(p, key);
 	if (!f) {
+		struct Qdisc *q = tcf_block_q(tp->chain->block);
+
 		if (!p->fall_through)
 			return -1;
-		res->classid = TC_H_MAKE(TC_H_MAJ(tp->q->handle), key);
+		res->classid = TC_H_MAKE(TC_H_MAJ(q->handle), key);
 		res->class = 0;
 		pr_debug("alg 0x%x\n", res->classid);
 		return 0;
-- 
2.9.5
