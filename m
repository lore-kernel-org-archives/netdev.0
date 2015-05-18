From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH iproute2/net-next] tc: gred: Add support for TCA_GRED_LIMIT attribute
Date: Mon, 18 May 2015 11:35:14 -0400
Message-ID: <1431963314-56420-11-git-send-email-david.ward@ll.mit.edu>
References: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
Cc: David Ward <david.ward@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-2.mit.edu ([18.9.25.13]:48541 "EHLO
	dmz-mailsec-scanner-2.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752290AbbERPfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:35:48 -0400
In-Reply-To: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the qdisc limit to be set, which is particularly useful when
the default VQ is not configured with RED parameters.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 include/linux/pkt_sched.h |    3 ++-
 tc/q_gred.c               |   20 +++++++++++++++++++-
 2 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 534b847..700f50a 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -268,7 +268,8 @@ enum {
        TCA_GRED_STAB,
        TCA_GRED_DPS,
        TCA_GRED_MAX_P,
-	   __TCA_GRED_MAX,
+       TCA_GRED_LIMIT,
+       __TCA_GRED_MAX,
 };
 
 #define TCA_GRED_MAX (__TCA_GRED_MAX - 1)
diff --git a/tc/q_gred.c b/tc/q_gred.c
index 463d725..f31daa3 100644
--- a/tc/q_gred.c
+++ b/tc/q_gred.c
@@ -38,7 +38,7 @@
 static void explain(void)
 {
 	fprintf(stderr, "Usage: tc qdisc { add | replace | change } ... gred setup vqs NUMBER\n");
-	fprintf(stderr, "           default DEFAULT_VQ [ grio ]\n");
+	fprintf(stderr, "           default DEFAULT_VQ [ grio ] [ limit BYTES ]\n");
 	fprintf(stderr, "       tc qdisc change ... gred vq VQ [ prio VALUE ] limit BYTES\n");
 	fprintf(stderr, "           min BYTES max BYTES avpkt BYTES [ burst PACKETS ]\n");
 	fprintf(stderr, "           [ probability PROBABILITY ] [ bandwidth KBPS ]\n");
@@ -50,6 +50,7 @@ static int init_gred(struct qdisc_util *qu, int argc, char **argv,
 
 	struct rtattr *tail;
 	struct tc_gred_sopt opt = { 0 };
+	__u32 limit = 0;
 
 	opt.def_DP = MAX_DPs;
 
@@ -83,6 +84,12 @@ static int init_gred(struct qdisc_util *qu, int argc, char **argv,
 			}
 		} else if (strcmp(*argv, "grio") == 0) {
 			opt.grio = 1;
+		} else if (strcmp(*argv, "limit") == 0) {
+			NEXT_ARG();
+			if (get_size(&limit, *argv)) {
+				fprintf(stderr, "Illegal \"limit\"\n");
+				return -1;
+			}
 		} else if (strcmp(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -104,6 +111,8 @@ static int init_gred(struct qdisc_util *qu, int argc, char **argv,
 	tail = NLMSG_TAIL(n);
 	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
 	addattr_l(n, 1024, TCA_GRED_DPS, &opt, sizeof(struct tc_gred_sopt));
+	if (limit)
+		addattr32(n, 1024, TCA_GRED_LIMIT, limit);
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 	return 0;
 }
@@ -264,6 +273,7 @@ static int gred_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	struct tc_gred_sopt *sopt;
 	struct tc_gred_qopt *qopt;
 	__u32 *max_p = NULL;
+	__u32 *limit = NULL;
 	unsigned i;
 	SPRINT_BUF(b1);
 	SPRINT_BUF(b2);
@@ -281,6 +291,10 @@ static int gred_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	    RTA_PAYLOAD(tb[TCA_GRED_MAX_P]) >= sizeof(__u32) * MAX_DPs)
 		max_p = RTA_DATA(tb[TCA_GRED_MAX_P]);
 
+	if (tb[TCA_GRED_LIMIT] &&
+	    RTA_PAYLOAD(tb[TCA_GRED_LIMIT]) == sizeof(__u32))
+		limit = RTA_DATA(tb[TCA_GRED_LIMIT]);
+
 	sopt = RTA_DATA(tb[TCA_GRED_DPS]);
 	qopt = RTA_DATA(tb[TCA_GRED_PARMS]);
 	if (RTA_PAYLOAD(tb[TCA_GRED_DPS]) < sizeof(*sopt) ||
@@ -296,6 +310,10 @@ static int gred_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 		sopt->def_DP,
 		sopt->grio ? "grio " : "");
 
+	if (limit)
+		fprintf(f, "limit %s ",
+			sprint_size(*limit, b1));
+
 	for (i=0;i<MAX_DPs;i++, qopt++) {
 		if (qopt->DP >= MAX_DPs) continue;
 		fprintf(f, "\n vq %u prio %hhu limit %s min %s max %s ",
-- 
1.7.1
