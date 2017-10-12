From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 14/34] net: sched: use extended variants of block get and put in ingress and clsact qdiscs
Date: Thu, 12 Oct 2017 19:18:03 +0200
Message-ID: <20171012171823.1431-15-jiri@resnulli.us>
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
Received: from mail-wm0-f66.google.com ([74.125.82.66]:49214 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753254AbdJLRSi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:38 -0400
Received: by mail-wm0-f66.google.com with SMTP id b189so14956674wmd.4
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:38 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Use previously introduced extended variants of block get and put
functions. This allows to specify a binder types specific to clsact
ingress/egress which is useful for drivers to distinguish who actually
got the block.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/pkt_cls.h   |  2 ++
 net/sched/sch_ingress.c | 36 +++++++++++++++++++++++++++++-------
 2 files changed, 31 insertions(+), 7 deletions(-)

diff --git a/include/net/pkt_cls.h b/include/net/pkt_cls.h
index febd52e..4e6cdf4 100644
--- a/include/net/pkt_cls.h
+++ b/include/net/pkt_cls.h
@@ -19,6 +19,8 @@ int unregister_tcf_proto_ops(struct tcf_proto_ops *ops);
 
 enum tcf_block_binder_type {
 	TCF_BLOCK_BINDER_TYPE_UNSPEC,
+	TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS,
+	TCF_BLOCK_BINDER_TYPE_CLSACT_EGRESS,
 };
 
 struct tcf_block_ext_info {
diff --git a/net/sched/sch_ingress.c b/net/sched/sch_ingress.c
index 9ccc1b8..b599db2 100644
--- a/net/sched/sch_ingress.c
+++ b/net/sched/sch_ingress.c
@@ -20,6 +20,7 @@
 
 struct ingress_sched_data {
 	struct tcf_block *block;
+	struct tcf_block_ext_info block_info;
 };
 
 static struct Qdisc *ingress_leaf(struct Qdisc *sch, unsigned long arg)
@@ -59,7 +60,10 @@ static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 	struct net_device *dev = qdisc_dev(sch);
 	int err;
 
-	err = tcf_block_get(&q->block, &dev->ingress_cl_list, sch);
+	q->block_info.binder_type = TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS;
+
+	err = tcf_block_get_ext(&q->block, &dev->ingress_cl_list,
+				sch, &q->block_info);
 	if (err)
 		return err;
 
@@ -72,8 +76,10 @@ static int ingress_init(struct Qdisc *sch, struct nlattr *opt)
 static void ingress_destroy(struct Qdisc *sch)
 {
 	struct ingress_sched_data *q = qdisc_priv(sch);
+	struct net_device *dev = qdisc_dev(sch);
 
-	tcf_block_put(q->block);
+	tcf_block_put_ext(q->block, &dev->ingress_cl_list,
+			  sch, &q->block_info);
 	net_dec_ingress_queue();
 }
 
@@ -114,6 +120,8 @@ static struct Qdisc_ops ingress_qdisc_ops __read_mostly = {
 struct clsact_sched_data {
 	struct tcf_block *ingress_block;
 	struct tcf_block *egress_block;
+	struct tcf_block_ext_info ingress_block_info;
+	struct tcf_block_ext_info egress_block_info;
 };
 
 static unsigned long clsact_find(struct Qdisc *sch, u32 classid)
@@ -153,13 +161,19 @@ static int clsact_init(struct Qdisc *sch, struct nlattr *opt)
 	struct net_device *dev = qdisc_dev(sch);
 	int err;
 
-	err = tcf_block_get(&q->ingress_block, &dev->ingress_cl_list, sch);
+	q->ingress_block_info.binder_type = TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS;
+
+	err = tcf_block_get_ext(&q->ingress_block, &dev->ingress_cl_list,
+				sch, &q->ingress_block_info);
 	if (err)
 		return err;
 
-	err = tcf_block_get(&q->egress_block, &dev->egress_cl_list, sch);
+	q->egress_block_info.binder_type = TCF_BLOCK_BINDER_TYPE_CLSACT_EGRESS;
+
+	err = tcf_block_get_ext(&q->egress_block, &dev->egress_cl_list,
+				sch, &q->egress_block_info);
 	if (err)
-		return err;
+		goto err_egress_block_get;
 
 	net_inc_ingress_queue();
 	net_inc_egress_queue();
@@ -167,14 +181,22 @@ static int clsact_init(struct Qdisc *sch, struct nlattr *opt)
 	sch->flags |= TCQ_F_CPUSTATS;
 
 	return 0;
+
+err_egress_block_get:
+	tcf_block_put_ext(q->ingress_block, &dev->ingress_cl_list,
+			  sch, &q->ingress_block_info);
+	return err;
 }
 
 static void clsact_destroy(struct Qdisc *sch)
 {
 	struct clsact_sched_data *q = qdisc_priv(sch);
+	struct net_device *dev = qdisc_dev(sch);
 
-	tcf_block_put(q->egress_block);
-	tcf_block_put(q->ingress_block);
+	tcf_block_put_ext(q->egress_block, &dev->egress_cl_list,
+			  sch, &q->egress_block_info);
+	tcf_block_put_ext(q->ingress_block, &dev->ingress_cl_list,
+			  sch, &q->ingress_block_info);
 
 	net_dec_ingress_queue();
 	net_dec_egress_queue();
-- 
2.9.5
