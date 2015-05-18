From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH iproute2 08/10] tc: gred: Handle unsigned values properly in option parsing/printing
Date: Mon, 18 May 2015 11:35:12 -0400
Message-ID: <1431963314-56420-9-git-send-email-david.ward@ll.mit.edu>
References: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
Cc: David Ward <david.ward@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-4.mit.edu ([18.9.25.15]:54864 "EHLO
	dmz-mailsec-scanner-4.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932084AbbERPfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:35:38 -0400
In-Reply-To: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DPs, def_DP, and DP are unsigned values that are sent and received
in TCA_GRED_* netlink attributes; handle them properly when they
are parsed or printed. Use MAX_DPs as the initial value for def_DP
and DP, and fix the operator used for bounds checking them.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 tc/q_gred.c |   65 ++++++++++++++++++++++++++++------------------------------
 1 files changed, 31 insertions(+), 34 deletions(-)

diff --git a/tc/q_gred.c b/tc/q_gred.c
index d3e5ec7..0192d9f 100644
--- a/tc/q_gred.c
+++ b/tc/q_gred.c
@@ -53,34 +53,34 @@ static int init_gred(struct qdisc_util *qu, int argc, char **argv,
 
 	struct rtattr *tail;
 	struct tc_gred_sopt opt = { 0 };
-	int dps = 0;
-	int def_dp = -1;
+
+	opt.def_DP = MAX_DPs;
 
 	while (argc > 0) {
 		DPRINTF(stderr,"init_gred: invoked with %s\n",*argv);
 		if (strcmp(*argv, "DPs") == 0) {
 			NEXT_ARG();
-			DPRINTF(stderr,"init_gred: next_arg with %s\n",*argv);
-			dps = strtol(*argv, (char **)NULL, 10);
-			if (dps < 0 || dps >MAX_DPs) {
-				fprintf(stderr, "DPs =%d\n", dps);
+			if (get_unsigned(&opt.DPs, *argv, 10)) {
 				fprintf(stderr, "Illegal \"DPs\"\n");
-				fprintf(stderr, "GRED: only %d DPs are "
-					"currently supported\n",MAX_DPs);
+				return -1;
+			} else if (opt.DPs > MAX_DPs) {
+				fprintf(stderr, "GRED: only %u DPs are "
+					"currently supported\n", MAX_DPs);
 				return -1;
 			}
 		} else if (strcmp(*argv, "default") == 0) {
-			NEXT_ARG();
-			def_dp = strtol(*argv, (char **)NULL, 10);
-			if (dps == 0) {
-				fprintf(stderr, "\"default DP\" must be "
-					"defined after DPs\n");
+			if (opt.DPs == 0) {
+				fprintf(stderr, "\"default\" must be defined "
+					"after \"DPs\"\n");
 				return -1;
 			}
-			if (def_dp < 0 || def_dp > dps) {
-				fprintf(stderr,
-					"\"default DP\" must be less than %d\n",
-					opt.DPs);
+			NEXT_ARG();
+			if (get_unsigned(&opt.def_DP, *argv, 10)) {
+				fprintf(stderr, "Illegal \"default\"\n");
+				return -1;
+			} else if (opt.def_DP >= opt.DPs) {
+				fprintf(stderr, "\"default\" must be less than "
+					"\"DPs\"\n");
 				return -1;
 			}
 		} else if (strcmp(*argv, "grio") == 0) {
@@ -96,15 +96,12 @@ static int init_gred(struct qdisc_util *qu, int argc, char **argv,
 		argc--; argv++;
 	}
 
-	if (!dps || def_dp == -1) {
+	if (!opt.DPs || opt.def_DP == MAX_DPs) {
 		fprintf(stderr, "Illegal gred setup parameters \n");
 		return -1;
 	}
 
-	opt.DPs = dps;
-	opt.def_DP = def_dp;
-
-	DPRINTF("TC_GRED: sending DPs=%d default=%d\n",opt.DPs,opt.def_DP);
+	DPRINTF("TC_GRED: sending DPs=%u def_DP=%u\n",opt.DPs,opt.def_DP);
 	n->nlmsg_flags|=NLM_F_CREATE;
 	tail = NLMSG_TAIL(n);
 	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
@@ -118,7 +115,7 @@ static int init_gred(struct qdisc_util *qu, int argc, char **argv,
 static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct nlmsghdr *n)
 {
 	int ok=0;
-	struct tc_gred_qopt opt;
+	struct tc_gred_qopt opt = { 0 };
 	unsigned burst = 0;
 	unsigned avpkt = 0;
 	double probability = 0.02;
@@ -128,7 +125,7 @@ static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 	struct rtattr *tail;
 	__u32 max_P;
 
-	memset(&opt, 0, sizeof(opt));
+	opt.DP = MAX_DPs;
 
 	while (argc > 0) {
 		if (strcmp(*argv, "limit") == 0) {
@@ -160,14 +157,14 @@ static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 			ok++;
 		} else if (strcmp(*argv, "DP") == 0) {
 			NEXT_ARG();
-			opt.DP=strtol(*argv, (char **)NULL, 10);
-			DPRINTF ("\n ******* DP =%u\n",opt.DP);
-			if (opt.DP >MAX_DPs) { /* need a better error check */
-				fprintf(stderr, "DP =%u \n",opt.DP);
+			if (get_unsigned(&opt.DP, *argv, 10)) {
 				fprintf(stderr, "Illegal \"DP\"\n");
-				fprintf(stderr, "GRED: only %d DPs are currently supported\n",MAX_DPs);
 				return -1;
-			}
+			} else if (opt.DP >= MAX_DPs) {
+				fprintf(stderr, "GRED: only %u DPs are "
+					"currently supported\n", MAX_DPs);
+				return -1;
+			} /* need a better error check */
 			ok++;
 		} else if (strcmp(*argv, "burst") == 0) {
 			NEXT_ARG();
@@ -217,10 +214,10 @@ static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 		explain();
 		return -1;
 	}
-	if (!opt.qth_min || !opt.qth_max || !opt.limit || !avpkt ||
-	    (opt.DP<0)) {
-		fprintf(stderr, "Required parameter (min, max, limit, "
-		    "avpkt, DP) is missing\n");
+	if (opt.DP == MAX_DPs || !opt.limit || !opt.qth_min || !opt.qth_max ||
+	    !avpkt) {
+		fprintf(stderr, "Required parameter (DP, limit, min, max, "
+			"avpkt) is missing\n");
 		return -1;
 	}
 	if (!burst) {
-- 
1.7.1
