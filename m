From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH v4 2/2] [iproute2/tc] hfsc: add link layer overhead adaption
Date: Thu, 10 Jul 2008 22:34:54 +0300
Message-ID: <20080710193454.19601.97736.stgit@fate.lan>
References: <20080710193448.19601.673.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.dnainternet.fi ([87.94.96.108]:62617 "EHLO
	smtp1.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760927AbYGJTe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 15:34:56 -0400
In-Reply-To: <20080710193448.19601.673.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch adds 'mpu', 'mtu', 'overhead' and 'linklayer' options to hfsc. These
options are used to create size table for sch_hfsc. Size table is only used
and passed to kernel if these options are used.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 include/linux/pkt_sched.h |    5 +
 tc/q_hfsc.c               |  155 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 155 insertions(+), 5 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 5bf1444..46db55d 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -303,6 +303,9 @@ struct tc_htb_xstats
 struct tc_hfsc_qopt
 {
 	__u16	defcls;		/* default class */
+	__u16	__reserved;
+	struct tc_sizespec szopts;
+	__u16	stab[512];
 };
 
 struct tc_service_curve
@@ -326,6 +329,8 @@ enum
 	TCA_HFSC_RSC,
 	TCA_HFSC_FSC,
 	TCA_HFSC_USC,
+	TCA_HFSC_SZOPTS,
+	TCA_HFSC_STAB,
 	__TCA_HFSC_MAX,
 };
 
diff --git a/tc/q_hfsc.c b/tc/q_hfsc.c
index b190c71..e8bff6e 100644
--- a/tc/q_hfsc.c
+++ b/tc/q_hfsc.c
@@ -12,6 +12,7 @@
 
 #include <stdio.h>
 #include <stdlib.h>
+#include <stddef.h>
 #include <unistd.h>
 #include <syslog.h>
 #include <fcntl.h>
@@ -24,6 +25,9 @@
 #include "utils.h"
 #include "tc_util.h"
 
+#define endof(type, member) \
+	(offsetof(type, member) + sizeof(((type *)0)->member))
+
 static int hfsc_get_sc(int *, char ***, struct tc_service_curve *);
 
 
@@ -31,7 +35,13 @@ static void
 explain_qdisc(void)
 {
 	fprintf(stderr,
-		"Usage: ... hfsc [ default CLASSID ]\n"
+		"Usage: ... hfsc [ default CLASSID ] [ mtu BYTES] [ mpu BYTES ]\n"
+		"                [ overhead BYTES ] [ linklayer TYPE ]\n"
+		"\n"
+		" mtu       : max packet size we create rate map for {2047}\n"
+		" mpu       : minimum packet size used in rate computations\n"
+		" overhead  : per-packet size overhead used in rate computations\n"
+		" linklayer : adapting to a linklayer e.g. atm\n"
 		"\n"
 		" default: default class for unclassified packets\n"
 	);
@@ -42,6 +52,13 @@ explain_class(void)
 {
 	fprintf(stderr,
 		"Usage: ... hfsc [ [ rt SC ] [ ls SC ] | [ sc SC ] ] [ ul SC ]\n"
+		"                [ mtu BYTES] [ mpu BYTES ] [ overhead BYTES ]\n"
+		"                [ linklayer TYPE ]\n"
+		"\n"
+		" mtu       : max packet size we create rate map for {2047}\n"
+		" mpu       : minimum packet size used in rate computations\n"
+		" overhead  : per-packet size overhead used in rate computations\n"
+		" linklayer : adapting to a linklayer e.g. atm\n"
 		"\n"
 		"SC := [ [ m1 BPS ] [ d SEC ] m2 BPS\n"
 		"\n"
@@ -67,14 +84,86 @@ explain1(char *arg)
 }
 
 static int
+hfsc_parse_stab(int *argcp, char ***argvp, unsigned *mtup,
+		unsigned int *linklayerp, short *overheadp,
+		unsigned short *mpup)
+{
+	char **argv = *argvp;
+	int argc = *argcp;
+	int next = 0;
+
+	if (matches(*argv, "mtu") == 0) {
+		NEXT_ARG();
+		if (get_u32(mtup, *argv, 10)) {
+			explain1("mtu");
+			return -1;
+		}
+	} else if (matches(*argv, "mpu") == 0) {
+		NEXT_ARG();
+		if (get_u16(mpup, *argv, 10)) {
+			explain1("mpu");
+			return -1;
+		}
+	} else if (matches(*argv, "overhead") == 0) {
+		NEXT_ARG();
+		if (get_s16(overheadp, *argv, 10)) {
+			explain1("overhead");
+			return -1;
+		}
+	} else if (matches(*argv, "linklayer") == 0) {
+		NEXT_ARG();
+		if (get_linklayer(linklayerp, *argv)) {
+			explain1("linklayer");
+			return -1;
+		}
+	} else {
+		next = 1;
+	}
+
+	*argvp = argv;
+	*argcp = argc;
+	return next;
+}
+
+static int
+hfsc_create_stab(struct tc_sizespec *szoptsp, __u16 *stabp, unsigned mtu,
+			unsigned int linklayer, short overhead,
+			unsigned short mpu)
+{
+	/* Only use stab when needed, mtu only defines stab properties so
+	 * it is not checked here. */
+	if (linklayer != LINKLAYER_ETHERNET || mpu != 0 || overhead != 0) {
+		szoptsp->mpu = mpu;
+		szoptsp->overhead = overhead;
+		if (tc_calc_stable(szoptsp, stabp, -1, mtu, linklayer) < 0) {
+			fprintf(stderr, "HFSC: failed to calculate size table.\n");
+			return -1;
+		}
+		return 1;
+	}
+	return 0;
+}
+
+static int
 hfsc_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
 	struct tc_hfsc_qopt qopt;
+	unsigned qopt_len;
+	unsigned mtu = 0;
+	unsigned int linklayer = LINKLAYER_ETHERNET; /* Assume ethernet */
+	short overhead = 0;
+	unsigned short mpu = 0;
+	int use_stab, next;
 
 	memset(&qopt, 0, sizeof(qopt));
 
 	while (argc > 0) {
-		if (matches(*argv, "default") == 0) {
+		next = hfsc_parse_stab(&argc, &argv, &mtu, &linklayer,
+					&overhead, &mpu);
+		if (next != 1) {
+			if (next < 0)
+				return next;
+		} else if (matches(*argv, "default") == 0) {
 			NEXT_ARG();
 			if (qopt.defcls != 0) {
 				fprintf(stderr, "HFSC: Double \"default\"\n");
@@ -95,7 +184,15 @@ hfsc_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 		argc--, argv++;
 	}
 
-	addattr_l(n, 1024, TCA_OPTIONS, &qopt, sizeof(qopt));
+	use_stab = hfsc_create_stab(&qopt.szopts, qopt.stab, mtu, linklayer,
+				overhead, mpu);
+	if (use_stab < 0)
+		return use_stab;
+	qopt_len = (use_stab > 0) ? endof(struct tc_hfsc_qopt, stab) :
+					endof(struct tc_hfsc_qopt, defcls);
+
+	addattr_l(n, 2024, TCA_OPTIONS, &qopt, qopt_len);
+
 	return 0;
 }
 
@@ -103,16 +200,27 @@ static int
 hfsc_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 {
 	struct tc_hfsc_qopt *qopt;
+	SPRINT_BUF(b1);
 
 	if (opt == NULL)
 		return 0;
-	if (RTA_PAYLOAD(opt) < sizeof(*qopt))
+	if (RTA_PAYLOAD(opt) < endof(struct tc_hfsc_qopt, defcls))
 		return -1;
 	qopt = RTA_DATA(opt);
 
 	if (qopt->defcls != 0)
 		fprintf(f, "default %x ", qopt->defcls);
 
+	if (show_details && RTA_PAYLOAD(opt) >=
+					endof(struct tc_hfsc_qopt, szopts)) {
+		if (qopt->szopts.mpu)
+			fprintf(f, "mpu %s ",
+				sprint_size(qopt->szopts.mpu, b1));
+		if (qopt->szopts.overhead)
+			fprintf(f, "overhead %s ",
+				sprint_size(qopt->szopts.overhead, b1));
+	}
+
 	return 0;
 }
 
@@ -145,14 +253,28 @@ hfsc_parse_class_opt(struct qdisc_util *qu, int argc, char **argv,
 	struct tc_service_curve rsc, fsc, usc;
 	int rsc_ok, fsc_ok, usc_ok;
 	struct rtattr *tail;
+	struct tc_sizespec szopts;
+	__u16 stab[512];
+	int use_stab, next;
+	unsigned mtu = 0;
+	unsigned int linklayer = LINKLAYER_ETHERNET; /* Assume ethernet */
+	short overhead = 0;
+	unsigned short mpu = 0;
 
 	memset(&rsc, 0, sizeof(rsc));
 	memset(&fsc, 0, sizeof(fsc));
 	memset(&usc, 0, sizeof(usc));
+	memset(&szopts, 0, sizeof(szopts));
+	memset(stab, 0, TCA_HFSC_STAB);
 	rsc_ok = fsc_ok = usc_ok = 0;
 
 	while (argc > 0) {
-		if (matches(*argv, "rt") == 0) {
+		next = hfsc_parse_stab(&argc, &argv, &mtu, &linklayer,
+					&overhead, &mpu);
+		if (next != 1) {
+			if (next < 0)
+				return next;
+		} else if (matches(*argv, "rt") == 0) {
 			NEXT_ARG();
 			if (hfsc_get_sc(&argc, &argv, &rsc) < 0) {
 				explain1("rt");
@@ -205,6 +327,10 @@ hfsc_parse_class_opt(struct qdisc_util *qu, int argc, char **argv,
 		return -1;
 	}
 
+	use_stab = hfsc_create_stab(&szopts, stab, mtu, linklayer, overhead, mpu);
+	if (use_stab < 0)
+		return use_stab;
+
 	tail = NLMSG_TAIL(n);
 
 	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
@@ -214,6 +340,10 @@ hfsc_parse_class_opt(struct qdisc_util *qu, int argc, char **argv,
 		addattr_l(n, 1024, TCA_HFSC_FSC, &fsc, sizeof(fsc));
 	if (usc_ok)
 		addattr_l(n, 1024, TCA_HFSC_USC, &usc, sizeof(usc));
+	if (use_stab) {
+		addattr_l(n, 2024, TCA_HFSC_SZOPTS, &szopts, sizeof(szopts));
+		addattr_l(n, 3024, TCA_HFSC_STAB, stab, TC_STAB_SIZE);
+	}
 
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 	return 0;
@@ -235,6 +365,8 @@ hfsc_print_class_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 {
 	struct rtattr *tb[TCA_HFSC_MAX+1];
 	struct tc_service_curve *rsc = NULL, *fsc = NULL, *usc = NULL;
+	struct tc_sizespec *szopts = NULL;
+	SPRINT_BUF(b1);
 
 	if (opt == NULL)
 		return 0;
@@ -259,6 +391,12 @@ hfsc_print_class_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 		else
 			usc = RTA_DATA(tb[TCA_HFSC_USC]);
 	}
+	if (tb[TCA_HFSC_SZOPTS]) {
+		if (RTA_PAYLOAD(tb[TCA_HFSC_SZOPTS]) < sizeof(*szopts))
+			fprintf(stderr, "HFSC: truncated rate options\n");
+		else
+			szopts = RTA_DATA(tb[TCA_HFSC_SZOPTS]);
+	}
 
 
 	if (rsc != NULL && fsc != NULL &&
@@ -273,6 +411,13 @@ hfsc_print_class_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	if (usc != NULL)
 		hfsc_print_sc(f, "ul", usc);
 
+	if (szopts != NULL && show_details) {
+		if (szopts->mpu)
+			fprintf(f, "mpu %s ", sprint_size(szopts->mpu, b1));
+		if (szopts->overhead)
+			fprintf(f, "overhead %s ", sprint_size(szopts->overhead, b1));
+	}
+
 	return 0;
 }
 

