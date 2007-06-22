From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH]: Nested compat attribute sch_prio example
Date: Fri, 22 Jun 2007 18:18:51 +0200
Message-ID: <467BF66B.4060609@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070901040305080109030105"
Cc: netdev@vger.kernel.org
To: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33950 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758014AbXFVQTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 12:19:02 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070901040305080109030105
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit

These two patches contain some example code how to use
the nested compat attribute in sch_prio.



--------------070901040305080109030105
Content-Type: text/x-diff;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[NET_SCHED]: sch_prio: nested compat attribute test

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 2ceff1c312a93446c95c41c3a54245a15278fe07
tree 7335b4957440cec27894dd38f3a707b4344f21ea
parent dece87e23c7cfa1159d3be0ea5b0db89a0fc5872
author Patrick McHardy <kaber@gw.localnet> Fri, 22 Jun 2007 18:10:44 +0200
committer Patrick McHardy <kaber@gw.localnet> Fri, 22 Jun 2007 18:10:44 +0200

 include/linux/pkt_sched.h |    9 +++++++++
 net/sched/sch_prio.c      |   15 ++++++++++++---
 2 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 2599d39..0bedabe 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -101,6 +101,15 @@ struct tc_prio_qopt
 	__u8	priomap[TC_PRIO_MAX+1];	/* Map: logical priority -> PRIO band */
 };
 
+enum
+{
+	TCA_PRIO_UNPSEC,
+	TCA_PRIO_TEST,
+	__TCA_PRIO_MAX
+};
+
+#define TCA_PRIO_MAX	(__TCA_PRIO_MAX - 1)
+
 /* TBF section */
 
 struct tc_tbf_qopt
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 6d7542c..40a13e8 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -198,10 +198,12 @@ prio_destroy(struct Qdisc* sch)
 static int prio_tune(struct Qdisc *sch, struct rtattr *opt)
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
-	struct tc_prio_qopt *qopt = RTA_DATA(opt);
+	struct tc_prio_qopt *qopt;
+	struct rtattr *tb[TCA_PRIO_MAX];
 	int i;
 
-	if (opt->rta_len < RTA_LENGTH(sizeof(*qopt)))
+	if (rtattr_parse_nested_compat(tb, TCA_PRIO_MAX, opt, (void *)&qopt,
+				       sizeof(*qopt)))
 		return -EINVAL;
 	if (qopt->bands > TCQ_PRIO_BANDS || qopt->bands < 2)
 		return -EINVAL;
@@ -211,6 +213,9 @@ static int prio_tune(struct Qdisc *sch, 
 			return -EINVAL;
 	}
 
+	if (tb[TCA_PRIO_TEST-1])
+		printk("TCA_PRIO_TEST: %u\n", *(u32 *)RTA_DATA(tb[TCA_PRIO_TEST-1]));
+
 	sch_tree_lock(sch);
 	q->bands = qopt->bands;
 	memcpy(q->prio2band, qopt->priomap, TC_PRIO_MAX+1);
@@ -268,11 +273,15 @@ static int prio_dump(struct Qdisc *sch, 
 {
 	struct prio_sched_data *q = qdisc_priv(sch);
 	unsigned char *b = skb_tail_pointer(skb);
+	struct rtattr *nest;
 	struct tc_prio_qopt opt;
 
 	opt.bands = q->bands;
 	memcpy(&opt.priomap, q->prio2band, TC_PRIO_MAX+1);
-	RTA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
+
+	nest = RTA_NEST_COMPAT(skb, TCA_OPTIONS, sizeof(opt), &opt);
+	RTA_PUT_U32(skb, TCA_PRIO_TEST, 321);
+	RTA_NEST_COMPAT_END(skb, nest);
 	return skb->len;
 
 rtattr_failure:

--------------070901040305080109030105
Content-Type: text/x-diff;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

[IPROUTE]: sch_prio: nested compat attribute test

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 37e8758e1238bf26172f25a0e3b0dec9c8c4f986
tree c79e320def8f4c5a5ed7f037f3ca6ec68487b375
parent d283ea3c852f54941ec785ad39dbfa4586f518c7
author Patrick McHardy <kaber@gw.localnet> Fri, 22 Jun 2007 18:00:04 +0200
committer Patrick McHardy <kaber@gw.localnet> Fri, 22 Jun 2007 18:00:04 +0200

 include/linux/pkt_sched.h |    9 +++++++++
 tc/q_prio.c               |   13 ++++++++++---
 2 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index dc61a85..77eaab1 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -101,6 +101,15 @@ struct tc_prio_qopt
 	__u8	priomap[TC_PRIO_MAX+1];	/* Map: logical priority -> PRIO band */
 };
 
+enum
+{
+	TCA_PRIO_UNSPEC,
+	TCA_PRIO_TEST,
+	__TCA_PRIO_MAX
+};
+
+#define TCA_PRIO_MAX	(__TCA_PRIO_MAX - 1)
+
 /* TBF section */
 
 struct tc_tbf_qopt
diff --git a/tc/q_prio.c b/tc/q_prio.c
index d696e1b..4934416 100644
--- a/tc/q_prio.c
+++ b/tc/q_prio.c
@@ -40,6 +40,7 @@ static int prio_parse_opt(struct qdisc_u
 	int pmap_mode = 0;
 	int idx = 0;
 	struct tc_prio_qopt opt={3,{ 1, 2, 2, 2, 1, 2, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1 }};
+	struct rtattr *nest;
 
 	while (argc > 0) {
 		if (strcmp(*argv, "bands") == 0) {
@@ -90,7 +91,9 @@ static int prio_parse_opt(struct qdisc_u
 			opt.priomap[idx] = opt.priomap[TC_PRIO_BESTEFFORT];
 	}
 */
-	addattr_l(n, 1024, TCA_OPTIONS, &opt, sizeof(opt));
+	nest = addattr_nest_compat(n, 1024, TCA_OPTIONS, &opt, sizeof(opt));
+	addattr32(n, 1024, TCA_PRIO_TEST, 123);
+	addattr_nest_compat_end(n, nest);
 	return 0;
 }
 
@@ -98,16 +101,20 @@ int prio_print_opt(struct qdisc_util *qu
 {
 	int i;
 	struct tc_prio_qopt *qopt;
+	struct rtattr *tb[TCA_PRIO_MAX+1];
 
 	if (opt == NULL)
 		return 0;
 
-	if (RTA_PAYLOAD(opt)  < sizeof(*qopt))
+	if (parse_rtattr_nested_compat(tb, TCA_PRIO_MAX, opt, (void *)&qopt, sizeof(*qopt)))
 		return -1;
-	qopt = RTA_DATA(opt);
+
 	fprintf(f, "bands %u priomap ", qopt->bands);
 	for (i=0; i<=TC_PRIO_MAX; i++)
 		fprintf(f, " %d", qopt->priomap[i]);
+
+	if (tb[TCA_PRIO_TEST])
+		fprintf(f, " TCA_PRIO_TEST: %u ", *(__u32 *)RTA_DATA(tb[TCA_PRIO_TEST]));
 	return 0;
 }
 

--------------070901040305080109030105--
