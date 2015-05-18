From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH iproute2 07/10] tc: gred: Improve parameter/statistics output
Date: Mon, 18 May 2015 11:35:11 -0400
Message-ID: <1431963314-56420-8-git-send-email-david.ward@ll.mit.edu>
References: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
Cc: David Ward <david.ward@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dmz-mailsec-scanner-8.mit.edu ([18.7.68.37]:62355 "EHLO
	dmz-mailsec-scanner-8.mit.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932260AbbERPfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 11:35:38 -0400
In-Reply-To: <1431963314-56420-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make the output more consistent with the RED qdisc, and only show
details/statistics if the appropriate flag is set when calling tc.

Show the parameters used with "gred setup". Add missing statistics
"pdrop" and "other". Fix format specifiers for unsigned values.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 tc/q_gred.c |   63 +++++++++++++++++++++++++++++++++-------------------------
 1 files changed, 36 insertions(+), 27 deletions(-)

diff --git a/tc/q_gred.c b/tc/q_gred.c
index 65caeee..d3e5ec7 100644
--- a/tc/q_gred.c
+++ b/tc/q_gred.c
@@ -265,14 +265,13 @@ static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 static int gred_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 {
 	struct rtattr *tb[TCA_GRED_MAX + 1];
+	struct tc_gred_sopt *sopt;
 	struct tc_gred_qopt *qopt;
 	__u32 *max_p = NULL;
-	int i;
+	unsigned i;
 	SPRINT_BUF(b1);
 	SPRINT_BUF(b2);
 	SPRINT_BUF(b3);
-	SPRINT_BUF(b4);
-	SPRINT_BUF(b5);
 
 	if (opt == NULL)
 		return 0;
@@ -286,40 +285,50 @@ static int gred_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	    RTA_PAYLOAD(tb[TCA_GRED_MAX_P]) >= sizeof(__u32) * MAX_DPs)
 		max_p = RTA_DATA(tb[TCA_GRED_MAX_P]);
 
+	sopt = RTA_DATA(tb[TCA_GRED_DPS]);
 	qopt = RTA_DATA(tb[TCA_GRED_PARMS]);
-	if (RTA_PAYLOAD(tb[TCA_GRED_PARMS])  < sizeof(*qopt)*MAX_DPs) {
+	if (RTA_PAYLOAD(tb[TCA_GRED_DPS]) < sizeof(*sopt) ||
+	    RTA_PAYLOAD(tb[TCA_GRED_PARMS]) < sizeof(*qopt)*MAX_DPs) {
 		fprintf(f,"\n GRED received message smaller than expected\n");
 		return -1;
-		}
+	}
 
 /* Bad hack! should really return a proper message as shown above*/
 
+	fprintf(f, "DPs %u default %u %s",
+		sopt->DPs,
+		sopt->def_DP,
+		sopt->grio ? "grio " : "");
+
 	for (i=0;i<MAX_DPs;i++, qopt++) {
 		if (qopt->DP >= MAX_DPs) continue;
-		fprintf(f, "\n DP:%d (prio %d) Average Queue %s Measured "
-		    "Queue %s  ",
+		fprintf(f, "\n DP %u prio %hhu limit %s min %s max %s ",
 			qopt->DP,
 			qopt->prio,
-			sprint_size(qopt->qave, b4),
-			sprint_size(qopt->backlog, b5));
-		fprintf(f, "\n\t Packet drops: %d (forced %d early %d)  ",
-			qopt->forced+qopt->early,
-			qopt->forced,
-			qopt->early);
-		fprintf(f, "\n\t Packet totals: %u (bytes %u)  ",
-			qopt->packets,
-			qopt->bytesin);
-		if (show_details)
-			fprintf(f, "\n limit %s min %s max %s ",
-				sprint_size(qopt->limit, b1),
-				sprint_size(qopt->qth_min, b2),
-				sprint_size(qopt->qth_max, b3));
-		fprintf(f, "ewma %u ", qopt->Wlog);
-		if (max_p)
-			fprintf(f, "probability %lg ", max_p[i] / pow(2, 32));
-		else
-			fprintf(f, "Plog %u ", qopt->Plog);
-		fprintf(f, "Scell_log %u", qopt->Scell_log);
+			sprint_size(qopt->limit, b1),
+			sprint_size(qopt->qth_min, b2),
+			sprint_size(qopt->qth_max, b3));
+		if (show_details) {
+			fprintf(f, "ewma %u ", qopt->Wlog);
+			if (max_p)
+				fprintf(f, "probability %lg ", max_p[i] / pow(2, 32));
+			else
+				fprintf(f, "Plog %u ", qopt->Plog);
+			fprintf(f, "Scell_log %u ", qopt->Scell_log);
+		}
+		if (show_stats) {
+			fprintf(f, "\n  Queue size: average %s current %s ",
+				sprint_size(qopt->qave, b1),
+				sprint_size(qopt->backlog, b2));
+			fprintf(f, "\n  Dropped packets: forced %u early %u pdrop %u other %u ",
+				qopt->forced,
+				qopt->early,
+				qopt->pdrop,
+				qopt->other);
+			fprintf(f, "\n  Total packets: %u (%s) ",
+				qopt->packets,
+				sprint_size(qopt->bytesin, b1));
+		}
 	}
 	return 0;
 }
-- 
1.7.1
