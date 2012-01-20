From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] gred: support TCA_GRED_MAX_P attribute
Date: Fri, 20 Jan 2012 16:27:50 +0100
Message-ID: <1327073270.12389.26.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:63484 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753441Ab2ATP1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 10:27:54 -0500
Received: by werb13 with SMTP id b13so512670wer.19
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2012 07:27:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCA_GRED_MAX_P permits to express high resolution probabilities.

New output (on 3.3+ kernel) :

disc gred 9442: root refcnt 17 
 DP:0 (prio 1) Average Queue 0b Measured Queue 0b  
	 Packet drops: 0 (forced 0 early 0)  
	 Packet totals: 20 (bytes 2584)  
 limit 31460b min 3000b max 9000b ewma 5 probability 0.05 Scell_log 15


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 tc/q_gred.c |   21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/tc/q_gred.c b/tc/q_gred.c
index 5fa0cc7..a4df3a6 100644
--- a/tc/q_gred.c
+++ b/tc/q_gred.c
@@ -21,6 +21,7 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <string.h>
+#include <math.h>
 
 #include "utils.h"
 #include "tc_util.h"
@@ -125,6 +126,7 @@ static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 	int wlog;
 	__u8 sbuf[256];
 	struct rtattr *tail;
+	__u32 max_P;
 
 	memset(&opt, 0, sizeof(opt));
 
@@ -251,14 +253,17 @@ static int gred_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
 	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
 	addattr_l(n, 1024, TCA_GRED_PARMS, &opt, sizeof(opt));
 	addattr_l(n, 1024, TCA_GRED_STAB, sbuf, 256);
+	max_P = probability * pow(2, 32);
+	addattr32(n, 1024, TCA_GRED_MAX_P, max_P);
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 	return 0;
 }
 
 static int gred_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 {
-	struct rtattr *tb[TCA_GRED_STAB+1];
+	struct rtattr *tb[TCA_GRED_MAX + 1];
 	struct tc_gred_qopt *qopt;
+	__u32 *max_p = NULL;
 	int i;
 	SPRINT_BUF(b1);
 	SPRINT_BUF(b2);
@@ -269,11 +274,15 @@ static int gred_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 	if (opt == NULL)
 		return 0;
 
-	parse_rtattr_nested(tb, TCA_GRED_STAB, opt);
+	parse_rtattr_nested(tb, TCA_GRED_MAX, opt);
 
 	if (tb[TCA_GRED_PARMS] == NULL)
 		return -1;
 
+	if (tb[TCA_GRED_MAX_P] &&
+	    RTA_PAYLOAD(tb[TCA_GRED_MAX_P]) >= sizeof(__u32) * MAX_DPs)
+		max_p = RTA_DATA(tb[TCA_GRED_MAX_P]);
+
 	qopt = RTA_DATA(tb[TCA_GRED_PARMS]);
 	if (RTA_PAYLOAD(tb[TCA_GRED_PARMS])  < sizeof(*qopt)*MAX_DPs) {
 		fprintf(f,"\n GRED received message smaller than expected\n");
@@ -302,8 +311,12 @@ static int gred_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 				sprint_size(qopt->limit, b1),
 				sprint_size(qopt->qth_min, b2),
 				sprint_size(qopt->qth_max, b3));
-				fprintf(f, "ewma %u Plog %u Scell_log %u",
-				    qopt->Wlog, qopt->Plog, qopt->Scell_log);
+		fprintf(f, "ewma %u ", qopt->Wlog);
+		if (max_p)
+			fprintf(f, "probability %lg ", max_p[i] / pow(2, 32));
+		else
+			fprintf(f, "Plog %u ", qopt->Plog);
+		fprintf(f, "Scell_log %u", qopt->Scell_log);
 	}
 	return 0;
 }
