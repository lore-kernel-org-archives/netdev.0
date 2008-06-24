From: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Subject: [PATCH v2 2/2] [iproute2/tc] hfsc: add link layer overhead adaption
Date: Tue, 24 Jun 2008 11:55:20 +0300
Message-ID: <20080624085519.22540.40534.stgit@fate.lan>
References: <20080624085514.22540.91038.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@osdl.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.dnainternet.fi ([87.94.96.112]:40017 "EHLO
	smtp2.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753759AbYFXIzW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 04:55:22 -0400
In-Reply-To: <20080624085514.22540.91038.stgit@fate.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch adds 'mpu', 'mtu', 'overhead' and 'linklayer' options to hfsc. These
options are used to create size table for sch_hfsc. Size table is only used
and passed to kernel if these options are used.

Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
---

 include/linux/pkt_sched.h |    2 +
 tc/q_hfsc.c               |   71 ++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 72 insertions(+), 1 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index b8366fb..43c11f2 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -326,6 +326,8 @@ enum
 	TCA_HFSC_RSC,
 	TCA_HFSC_FSC,
 	TCA_HFSC_USC,
+	TCA_HFSC_SZOPTS,
+	TCA_HFSC_STAB,
 	__TCA_HFSC_MAX,
 };
 
diff --git a/tc/q_hfsc.c b/tc/q_hfsc.c
index b190c71..aa1c9b0 100644
--- a/tc/q_hfsc.c
+++ b/tc/q_hfsc.c
@@ -42,6 +42,13 @@ explain_class(void)
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
@@ -145,14 +152,45 @@ hfsc_parse_class_opt(struct qdisc_util *qu, int argc, char **argv,
 	struct tc_service_curve rsc, fsc, usc;
 	int rsc_ok, fsc_ok, usc_ok;
 	struct rtattr *tail;
+	struct tc_sizespec szopts;
+	__u16 stab[512];
+	int use_stab;
+	unsigned mtu = 0;
+	unsigned int linklayer = LINKLAYER_ETHERNET; /* Assume ethernet */
+	unsigned short overhead = 0, mpu = 0;
 
 	memset(&rsc, 0, sizeof(rsc));
 	memset(&fsc, 0, sizeof(fsc));
 	memset(&usc, 0, sizeof(usc));
+	memset(&szopts, 0, sizeof(szopts));
 	rsc_ok = fsc_ok = usc_ok = 0;
 
 	while (argc > 0) {
-		if (matches(*argv, "rt") == 0) {
+		if (matches(*argv, "mtu") == 0) {
+			NEXT_ARG();
+			if (get_u32(&mtu, *argv, 10)) {
+				explain1("mtu");
+				return -1;
+			}
+		} else if (matches(*argv, "mpu") == 0) {
+			NEXT_ARG();
+			if (get_u16(&mpu, *argv, 10)) {
+				explain1("mpu");
+				return -1;
+			}
+		} else if (matches(*argv, "overhead") == 0) {
+			NEXT_ARG();
+			if (get_u16(&overhead, *argv, 10)) {
+				explain1("overhead");
+				return -1;
+			}
+		} else if (matches(*argv, "linklayer") == 0) {
+			NEXT_ARG();
+			if (get_linklayer(&linklayer, *argv)) {
+				explain1("linklayer");
+				return -1;
+			}
+		} else if (matches(*argv, "rt") == 0) {
 			NEXT_ARG();
 			if (hfsc_get_sc(&argc, &argv, &rsc) < 0) {
 				explain1("rt");
@@ -205,6 +243,18 @@ hfsc_parse_class_opt(struct qdisc_util *qu, int argc, char **argv,
 		return -1;
 	}
 
+	/* Only use stab when needed, mtu only defines stab properties so
+	 * it is not checked for. */
+	use_stab = (linklayer != LINKLAYER_ETHERNET || mpu != 0 || overhead != 0);
+	if (use_stab) {
+		szopts.mpu = mpu;
+		szopts.overhead = overhead;
+		if (tc_calc_stable(&szopts, stab, -1, mtu, linklayer) < 0) {
+			fprintf(stderr, "HFSC: failed to calculate rate table.\n");
+			return -1;
+		}
+	}
+
 	tail = NLMSG_TAIL(n);
 
 	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
@@ -214,6 +264,10 @@ hfsc_parse_class_opt(struct qdisc_util *qu, int argc, char **argv,
 		addattr_l(n, 1024, TCA_HFSC_FSC, &fsc, sizeof(fsc));
 	if (usc_ok)
 		addattr_l(n, 1024, TCA_HFSC_USC, &usc, sizeof(usc));
+	if (use_stab) {
+		addattr_l(n, 2024, TCA_HFSC_SZOPTS, &szopts, sizeof(szopts));
+		addattr_l(n, 3024, TCA_HFSC_STAB, stab, TC_STAB_SIZE);
+	}
 
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 	return 0;
@@ -235,6 +289,8 @@ hfsc_print_class_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 {
 	struct rtattr *tb[TCA_HFSC_MAX+1];
 	struct tc_service_curve *rsc = NULL, *fsc = NULL, *usc = NULL;
+	struct tc_sizespec *szopts = NULL;
+	SPRINT_BUF(b1);
 
 	if (opt == NULL)
 		return 0;
@@ -259,6 +315,12 @@ hfsc_print_class_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
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
@@ -273,6 +335,13 @@ hfsc_print_class_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
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
 

