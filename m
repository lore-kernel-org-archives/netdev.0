From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH iproute2 09/10] tc: gred: Adopt the term VQ in the command syntax and output
Date: Mon, 18 May 2015 11:35:13 -0400
Message-ID: <1431963314-56420-10-git-send-email-david.ward@ll.mit.edu>
References: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
Cc: David Ward <david.ward@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-5.mit.edu ([18.7.68.34]:46437 "EHLO
	dmz-mailsec-scanner-5.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932272AbbERPfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:35:46 -0400
In-Reply-To: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the GRED kernel source code, both of the terms "drop parameters"
(DP) and "virtual queue" (VQ) are used to refer to the same thing.
Each "DP" is better understood as a "set of drop parameters", since
it has values for limit, min, max, avpkt, etc. This terminology can
result in confusion when creating a GRED qdisc having multiple DPs.
Netlink attributes and struct members with the DP name seem to have
been left intact for compatibility, while the term VQ was otherwise
adopted in the code, which is more intuitive.

Use the VQ term in the tc command syntax and output (but maintain
compatibility with the old syntax).

Rewrite the usage text to be concise and similar to other qdiscs.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 tc/q_gred.c |   37 ++++++++++++++++++-------------------
 1 files changed, 18 insertions(+), 19 deletions(-)

diff --git a/tc/q_gred.c b/tc/q_gred.c
index 0192d9f..463d725 100644
--- a/tc/q_gred.c
+++ b/tc/q_gred.c
@@ -37,14 +37,11 @@
 
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... gred DP drop-probability limit BYTES "
-	    "min BYTES max BYTES\n");
-	fprintf(stderr, "    avpkt BYTES burst PACKETS probability PROBABILITY "
-	    "bandwidth KBPS\n");
-	fprintf(stderr, "    [prio value]\n");
-	fprintf(stderr," OR ...\n");
-	fprintf(stderr," gred setup DPs <num of DPs> default <default DP> "
-	    "[grio]\n");
+	fprintf(stderr, "Usage: tc qdisc { add | replace | change } ... gred setup vqs NUMBER\n");
+	fprintf(stderr, "           default DEFAULT_VQ [ grio ]\n");
+	fprintf(stderr, "       tc qdisc change ... gred vq VQ [ prio VALUE ] limit BYTES\n");
+	fprintf(stderr, "           min BYTES max BYTES avpkt BYTES [ burst PACKETS ]\n");
+	fprintf(stderr, "           [ probability PROBABILITY ] [ bandwidth KBPS ]\n");
 }
 
 static int init_gred(struct qdisc_util *qu, int argc, char **argv,
@@ -58,20 +55,21 @@ static int init_gred(struct qdisc_util *qu, int argc, char **argv,
 
 	while (argc > 0) {
 		DPRINTF(stderr,"init_gred: invoked with %s\n",*argv);
-		if (strcmp(*argv, "DPs") == 0) {
+		if (strcmp(*argv, "vqs") == 0 ||
+		    strcmp(*argv, "DPs") == 0) {
 			NEXT_ARG();
 			if (get_unsigned(&opt.DPs, *argv, 10)) {
-				fprintf(stderr, "Illegal \"DPs\"\n");
+				fprintf(stderr, "Illegal \"vqs\"\n");
 				return -1;
 			} else if (opt.DPs > MAX_DPs) {
-				fprintf(stderr, "GRED: only %u DPs are "
+				fprintf(stderr, "GRED: only %u VQs are "
 					"currently supported\n", MAX_DPs);
 				return -1;
 			}
 		} else if (strcmp(*argv, "default") == 0) {
 			if (opt.DPs == 0) {
 				fprintf(stderr, "\"default\" must be defined "
-					"after \"DPs\"\n");
+					"after \"vqs\"\n");
 				return -1;
 			}
 			NEXT_ARG();
@@ -80,7 +78,7 @@ static int init_gred(struct qdisc_util *qu, int argc, char **argv,
 				return -1;
 			} else if (opt.def_DP >= opt.DPs) {
 				fprintf(stderr, "\"default\" must be less than "
-					"\"DPs\"\n");
+					"\"vqs\"\n");
 				return -1;
 			}
 		} else if (strcmp(*argv, "grio") == 0) {
@@ -155,13 +153,14 @@ static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 				return -1;
 			}
 			ok++;
-		} else if (strcmp(*argv, "DP") == 0) {
+		} else if (strcmp(*argv, "vq") == 0 ||
+			   strcmp(*argv, "DP") == 0) {
 			NEXT_ARG();
 			if (get_unsigned(&opt.DP, *argv, 10)) {
-				fprintf(stderr, "Illegal \"DP\"\n");
+				fprintf(stderr, "Illegal \"vq\"\n");
 				return -1;
 			} else if (opt.DP >= MAX_DPs) {
-				fprintf(stderr, "GRED: only %u DPs are "
+				fprintf(stderr, "GRED: only %u VQs are "
 					"currently supported\n", MAX_DPs);
 				return -1;
 			} /* need a better error check */
@@ -216,7 +215,7 @@ static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 	}
 	if (opt.DP == MAX_DPs || !opt.limit || !opt.qth_min || !opt.qth_max ||
 	    !avpkt) {
-		fprintf(stderr, "Required parameter (DP, limit, min, max, "
+		fprintf(stderr, "Required parameter (vq, limit, min, max, "
 			"avpkt) is missing\n");
 		return -1;
 	}
@@ -292,14 +291,14 @@ static int gred_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 
 /* Bad hack! should really return a proper message as shown above*/
 
-	fprintf(f, "DPs %u default %u %s",
+	fprintf(f, "vqs %u default %u %s",
 		sopt->DPs,
 		sopt->def_DP,
 		sopt->grio ? "grio " : "");
 
 	for (i=0;i<MAX_DPs;i++, qopt++) {
 		if (qopt->DP >= MAX_DPs) continue;
-		fprintf(f, "\n DP %u prio %hhu limit %s min %s max %s ",
+		fprintf(f, "\n vq %u prio %hhu limit %s min %s max %s ",
 			qopt->DP,
 			qopt->prio,
 			sprint_size(qopt->limit, b1),
-- 
1.7.1
