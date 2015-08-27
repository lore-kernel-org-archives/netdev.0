From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2] net: sched: consolidate tc_classify{,_compat}
Date: Thu, 27 Aug 2015 10:11:37 +0200
Message-ID: <0883dbc14bab78eb14cbed171c59143f24769edf.1440661724.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41145 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753587AbbH0ILo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 04:11:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For classifiers getting invoked via tc_classify(), we always need an
extra function call into tc_classify_compat(), as both are being
exported as symbols and tc_classify() itself doesn't do much except
handling of reclassifications when tp->classify() returned with
TC_ACT_RECLASSIFY.

CBQ and ATM are the only qdiscs that directly call into tc_classify_compat(),
all others use tc_classify(). When tc actions are being configured
out in the kernel, tc_classify() effectively does nothing besides
delegating.

We could spare this layer and consolidate both functions. Artificial
pktgen micro benchmark on single CPU constantly pushing skbs directly
into the netif_receive_skb() path with a dummy classifier on ingress
qdisc attached, improves slightly from 22.3Mpps to 23.1Mpps.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 v1 -> v2:
  - Addressed minor style nits found by Alexei.

 include/net/pkt_sched.h  |  4 +---
 net/core/dev.c           |  2 +-
 net/sched/sch_api.c      | 54 +++++++++++++++++++++---------------------------
 net/sched/sch_atm.c      |  2 +-
 net/sched/sch_cbq.c      |  2 +-
 net/sched/sch_choke.c    |  2 +-
 net/sched/sch_drr.c      |  2 +-
 net/sched/sch_dsmark.c   |  2 +-
 net/sched/sch_fq_codel.c |  2 +-
 net/sched/sch_hfsc.c     |  2 +-
 net/sched/sch_htb.c      |  2 +-
 net/sched/sch_multiq.c   |  2 +-
 net/sched/sch_prio.c     |  2 +-
 net/sched/sch_qfq.c      |  2 +-
 net/sched/sch_sfb.c      |  2 +-
 net/sched/sch_sfq.c      |  2 +-
 16 files changed, 39 insertions(+), 47 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 2342bf1..401038d 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -110,10 +110,8 @@ static inline void qdisc_run(struct Qdisc *q)
 		__qdisc_run(q);
 }
 
-int tc_classify_compat(struct sk_buff *skb, const struct tcf_proto *tp,
-		       struct tcf_result *res);
 int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
-		struct tcf_result *res);
+		struct tcf_result *res, bool compat_mode);
 
 static inline __be16 tc_skb_protocol(const struct sk_buff *skb)
 {
diff --git a/net/core/dev.c b/net/core/dev.c
index b1f3f48..7bb24f1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3657,7 +3657,7 @@ static inline struct sk_buff *handle_ing(struct sk_buff *skb,
 	skb->tc_verd = SET_TC_AT(skb->tc_verd, AT_INGRESS);
 	qdisc_bstats_cpu_update(cl->q, skb);
 
-	switch (tc_classify(skb, cl, &cl_res)) {
+	switch (tc_classify(skb, cl, &cl_res, false)) {
 	case TC_ACT_OK:
 	case TC_ACT_RECLASSIFY:
 		skb->tc_index = TC_H_MIN(cl_res.classid);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index f06aa01..c49c6e4 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -1806,51 +1806,45 @@ done:
  * to this qdisc, (optionally) tests for protocol and asks
  * specific classifiers.
  */
-int tc_classify_compat(struct sk_buff *skb, const struct tcf_proto *tp,
-		       struct tcf_result *res)
+int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
+		struct tcf_result *res, bool compat_mode)
 {
 	__be16 protocol = tc_skb_protocol(skb);
-	int err;
+#ifdef CONFIG_NET_CLS_ACT
+	const struct tcf_proto *old_tp = tp;
+	int limit = 0;
 
+reclassify:
+#endif
 	for (; tp; tp = rcu_dereference_bh(tp->next)) {
+		int err;
+
 		if (tp->protocol != protocol &&
 		    tp->protocol != htons(ETH_P_ALL))
 			continue;
-		err = tp->classify(skb, tp, res);
 
+		err = tp->classify(skb, tp, res);
+#ifdef CONFIG_NET_CLS_ACT
+		if (unlikely(err == TC_ACT_RECLASSIFY && !compat_mode))
+			goto reset;
+#endif
 		if (err >= 0)
 			return err;
 	}
-	return -1;
-}
-EXPORT_SYMBOL(tc_classify_compat);
 
-int tc_classify(struct sk_buff *skb, const struct tcf_proto *tp,
-		struct tcf_result *res)
-{
-	int err = 0;
-#ifdef CONFIG_NET_CLS_ACT
-	const struct tcf_proto *otp = tp;
-	int limit = 0;
-reclassify:
-#endif
-
-	err = tc_classify_compat(skb, tp, res);
+	return -1;
 #ifdef CONFIG_NET_CLS_ACT
-	if (err == TC_ACT_RECLASSIFY) {
-		tp = otp;
-
-		if (unlikely(limit++ >= MAX_REC_LOOP)) {
-			net_notice_ratelimited("%s: packet reclassify loop rule prio %u protocol %02x\n",
-					       tp->q->ops->id,
-					       tp->prio & 0xffff,
-					       ntohs(tp->protocol));
-			return TC_ACT_SHOT;
-		}
-		goto reclassify;
+reset:
+	if (unlikely(limit++ >= MAX_REC_LOOP)) {
+		net_notice_ratelimited("%s: reclassify loop, rule prio %u, protocol %02x\n",
+				       tp->q->ops->id, tp->prio & 0xffff,
+				       ntohs(tp->protocol));
+		return TC_ACT_SHOT;
 	}
+
+	tp = old_tp;
+	goto reclassify;
 #endif
-	return err;
 }
 EXPORT_SYMBOL(tc_classify);
 
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index e3e2cc5..1911af3 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -375,7 +375,7 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		list_for_each_entry(flow, &p->flows, list) {
 			fl = rcu_dereference_bh(flow->filter_list);
 			if (fl) {
-				result = tc_classify_compat(skb, fl, &res);
+				result = tc_classify(skb, fl, &res, true);
 				if (result < 0)
 					continue;
 				flow = (struct atm_flow_data *)res.class;
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index beeb75f..c538d9e 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -240,7 +240,7 @@ cbq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 		/*
 		 * Step 2+n. Apply classifier.
 		 */
-		result = tc_classify_compat(skb, fl, &res);
+		result = tc_classify(skb, fl, &res, true);
 		if (!fl || result < 0)
 			goto fallback;
 
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 6a783af..665bde0 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -201,7 +201,7 @@ static bool choke_classify(struct sk_buff *skb,
 	int result;
 
 	fl = rcu_dereference_bh(q->filter_list);
-	result = tc_classify(skb, fl, &res);
+	result = tc_classify(skb, fl, &res, false);
 	if (result >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
diff --git a/net/sched/sch_drr.c b/net/sched/sch_drr.c
index 3387060..f26bdea 100644
--- a/net/sched/sch_drr.c
+++ b/net/sched/sch_drr.c
@@ -331,7 +331,7 @@ static struct drr_class *drr_classify(struct sk_buff *skb, struct Qdisc *sch,
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	fl = rcu_dereference_bh(q->filter_list);
-	result = tc_classify(skb, fl, &res);
+	result = tc_classify(skb, fl, &res, false);
 	if (result >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index 66700a6..c4d45fd 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -230,7 +230,7 @@ static int dsmark_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	else {
 		struct tcf_result res;
 		struct tcf_proto *fl = rcu_dereference_bh(p->filter_list);
-		int result = tc_classify(skb, fl, &res);
+		int result = tc_classify(skb, fl, &res, false);
 
 		pr_debug("result %d class 0x%04x\n", result, res.classid);
 
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index a9ba030..4c834e9 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -92,7 +92,7 @@ static unsigned int fq_codel_classify(struct sk_buff *skb, struct Qdisc *sch,
 		return fq_codel_hash(q, skb) + 1;
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-	result = tc_classify(skb, filter, &res);
+	result = tc_classify(skb, filter, &res, false);
 	if (result >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index e6c7416..b7ebe2c 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1165,7 +1165,7 @@ hfsc_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	head = &q->root;
 	tcf = rcu_dereference_bh(q->root.filter_list);
-	while (tcf && (result = tc_classify(skb, tcf, &res)) >= 0) {
+	while (tcf && (result = tc_classify(skb, tcf, &res, false)) >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
 		case TC_ACT_QUEUED:
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index cf4b0f8..15ccd7f 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -229,7 +229,7 @@ static struct htb_class *htb_classify(struct sk_buff *skb, struct Qdisc *sch,
 	}
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-	while (tcf && (result = tc_classify(skb, tcf, &res)) >= 0) {
+	while (tcf && (result = tc_classify(skb, tcf, &res, false)) >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
 		case TC_ACT_QUEUED:
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 42dd218..4e904ca 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -46,7 +46,7 @@ multiq_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 	int err;
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-	err = tc_classify(skb, fl, &res);
+	err = tc_classify(skb, fl, &res, false);
 #ifdef CONFIG_NET_CLS_ACT
 	switch (err) {
 	case TC_ACT_STOLEN:
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 8e5cd34..ba6487f 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -42,7 +42,7 @@ prio_classify(struct sk_buff *skb, struct Qdisc *sch, int *qerr)
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	if (TC_H_MAJ(skb->priority) != sch->handle) {
 		fl = rcu_dereference_bh(q->filter_list);
-		err = tc_classify(skb, fl, &res);
+		err = tc_classify(skb, fl, &res, false);
 #ifdef CONFIG_NET_CLS_ACT
 		switch (err) {
 		case TC_ACT_STOLEN:
diff --git a/net/sched/sch_qfq.c b/net/sched/sch_qfq.c
index ffaeea6..3dc3a6e 100644
--- a/net/sched/sch_qfq.c
+++ b/net/sched/sch_qfq.c
@@ -717,7 +717,7 @@ static struct qfq_class *qfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
 	fl = rcu_dereference_bh(q->filter_list);
-	result = tc_classify(skb, fl, &res);
+	result = tc_classify(skb, fl, &res, false);
 	if (result >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index dcdff5c..5bbb633 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -258,7 +258,7 @@ static bool sfb_classify(struct sk_buff *skb, struct tcf_proto *fl,
 	struct tcf_result res;
 	int result;
 
-	result = tc_classify(skb, fl, &res);
+	result = tc_classify(skb, fl, &res, false);
 	if (result >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 52f75a5..3abab53 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -179,7 +179,7 @@ static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 		return sfq_hash(q, skb) + 1;
 
 	*qerr = NET_XMIT_SUCCESS | __NET_XMIT_BYPASS;
-	result = tc_classify(skb, fl, &res);
+	result = tc_classify(skb, fl, &res, false);
 	if (result >= 0) {
 #ifdef CONFIG_NET_CLS_ACT
 		switch (result) {
-- 
1.9.3
