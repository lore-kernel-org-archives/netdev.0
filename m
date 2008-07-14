From: Patrick McHardy <kaber@trash.net>
Subject: net-sched: cls_flow: add perturbation support
Date: Mon, 14 Jul 2008 14:41:36 +0200
Message-ID: <487B4980.8030801@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080409070002090600090109"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43321 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752621AbYGNMnF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2008 08:43:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080409070002090600090109
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------080409070002090600090109
Content-Type: text/x-diff;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 271186e5e2e091dd3b1f0bffa28203a2cbaa89d3
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Jul 14 14:34:39 2008 +0200

    net-sched: cls_flow: add perturbation support
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index 99efbed..7cf7824 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -374,6 +374,7 @@ enum
 	TCA_FLOW_ACT,
 	TCA_FLOW_POLICE,
 	TCA_FLOW_EMATCHES,
+	TCA_FLOW_PERTURB,
 	__TCA_FLOW_MAX
 };
 
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 971b867..8f63a1a 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -36,6 +36,8 @@ struct flow_filter {
 	struct list_head	list;
 	struct tcf_exts		exts;
 	struct tcf_ematch_tree	ematches;
+	struct timer_list	perturb_timer;
+	u32			perturb_period;
 	u32			handle;
 
 	u32			nkeys;
@@ -47,11 +49,9 @@ struct flow_filter {
 	u32			addend;
 	u32			divisor;
 	u32			baseclass;
+	u32			hashrnd;
 };
 
-static u32 flow_hashrnd __read_mostly;
-static int flow_hashrnd_initted __read_mostly;
-
 static const struct tcf_ext_map flow_ext_map = {
 	.action	= TCA_FLOW_ACT,
 	.police	= TCA_FLOW_POLICE,
@@ -348,7 +348,7 @@ static int flow_classify(struct sk_buff *skb, struct tcf_proto *tp,
 		}
 
 		if (f->mode == FLOW_MODE_HASH)
-			classid = jhash2(keys, f->nkeys, flow_hashrnd);
+			classid = jhash2(keys, f->nkeys, f->hashrnd);
 		else {
 			classid = keys[0];
 			classid = (classid & f->mask) ^ f->xor;
@@ -369,6 +369,15 @@ static int flow_classify(struct sk_buff *skb, struct tcf_proto *tp,
 	return -1;
 }
 
+static void flow_perturbation(unsigned long arg)
+{
+	struct flow_filter *f = (struct flow_filter *)arg;
+
+	get_random_bytes(&f->hashrnd, 4);
+	if (f->perturb_period)
+		mod_timer(&f->perturb_timer, jiffies + f->perturb_period);
+}
+
 static const struct nla_policy flow_policy[TCA_FLOW_MAX + 1] = {
 	[TCA_FLOW_KEYS]		= { .type = NLA_U32 },
 	[TCA_FLOW_MODE]		= { .type = NLA_U32 },
@@ -381,6 +390,7 @@ static const struct nla_policy flow_policy[TCA_FLOW_MAX + 1] = {
 	[TCA_FLOW_ACT]		= { .type = NLA_NESTED },
 	[TCA_FLOW_POLICE]	= { .type = NLA_NESTED },
 	[TCA_FLOW_EMATCHES]	= { .type = NLA_NESTED },
+	[TCA_FLOW_PERTURB]	= { .type = NLA_U32 },
 };
 
 static int flow_change(struct tcf_proto *tp, unsigned long base,
@@ -394,6 +404,7 @@ static int flow_change(struct tcf_proto *tp, unsigned long base,
 	struct tcf_exts e;
 	struct tcf_ematch_tree t;
 	unsigned int nkeys = 0;
+	unsigned int perturb_period = 0;
 	u32 baseclass = 0;
 	u32 keymask = 0;
 	u32 mode;
@@ -442,6 +453,14 @@ static int flow_change(struct tcf_proto *tp, unsigned long base,
 			mode = nla_get_u32(tb[TCA_FLOW_MODE]);
 		if (mode != FLOW_MODE_HASH && nkeys > 1)
 			goto err2;
+
+		if (mode == FLOW_MODE_HASH)
+			perturb_period = f->perturb_period;
+		if (tb[TCA_FLOW_PERTURB]) {
+			if (mode != FLOW_MODE_HASH)
+				goto err2;
+			perturb_period = nla_get_u32(tb[TCA_FLOW_PERTURB]) * HZ;
+		}
 	} else {
 		err = -EINVAL;
 		if (!handle)
@@ -455,6 +474,12 @@ static int flow_change(struct tcf_proto *tp, unsigned long base,
 		if (mode != FLOW_MODE_HASH && nkeys > 1)
 			goto err2;
 
+		if (tb[TCA_FLOW_PERTURB]) {
+			if (mode != FLOW_MODE_HASH)
+				goto err2;
+			perturb_period = nla_get_u32(tb[TCA_FLOW_PERTURB]) * HZ;
+		}
+
 		if (TC_H_MAJ(baseclass) == 0)
 			baseclass = TC_H_MAKE(tp->q->handle, baseclass);
 		if (TC_H_MIN(baseclass) == 0)
@@ -467,6 +492,11 @@ static int flow_change(struct tcf_proto *tp, unsigned long base,
 
 		f->handle = handle;
 		f->mask	  = ~0U;
+
+		get_random_bytes(&f->hashrnd, 4);
+		f->perturb_timer.function = flow_perturbation;
+		f->perturb_timer.data = (unsigned long)f;
+		init_timer_deferrable(&f->perturb_timer);
 	}
 
 	tcf_exts_change(tp, &f->exts, &e);
@@ -495,6 +525,11 @@ static int flow_change(struct tcf_proto *tp, unsigned long base,
 	if (baseclass)
 		f->baseclass = baseclass;
 
+	f->perturb_period = perturb_period;
+	del_timer(&f->perturb_timer);
+	if (perturb_period)
+		mod_timer(&f->perturb_timer, jiffies + perturb_period);
+
 	if (*arg == 0)
 		list_add_tail(&f->list, &head->filters);
 
@@ -512,6 +547,7 @@ err1:
 
 static void flow_destroy_filter(struct tcf_proto *tp, struct flow_filter *f)
 {
+	del_timer_sync(&f->perturb_timer);
 	tcf_exts_destroy(tp, &f->exts);
 	tcf_em_tree_destroy(tp, &f->ematches);
 	kfree(f);
@@ -532,11 +568,6 @@ static int flow_init(struct tcf_proto *tp)
 {
 	struct flow_head *head;
 
-	if (!flow_hashrnd_initted) {
-		get_random_bytes(&flow_hashrnd, 4);
-		flow_hashrnd_initted = 1;
-	}
-
 	head = kzalloc(sizeof(*head), GFP_KERNEL);
 	if (head == NULL)
 		return -ENOBUFS;
@@ -605,6 +636,9 @@ static int flow_dump(struct tcf_proto *tp, unsigned long fh,
 	if (f->baseclass)
 		NLA_PUT_U32(skb, TCA_FLOW_BASECLASS, f->baseclass);
 
+	if (f->perturb_period)
+		NLA_PUT_U32(skb, TCA_FLOW_PERTURB, f->perturb_period / HZ);
+
 	if (tcf_exts_dump(skb, &f->exts, &flow_ext_map) < 0)
 		goto nla_put_failure;
 #ifdef CONFIG_NET_EMATCH

--------------080409070002090600090109--
