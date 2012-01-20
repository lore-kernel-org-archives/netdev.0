From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH iproute2] choke: support TCA_CHOKE_MAX_P
Date: Fri, 20 Jan 2012 16:19:44 +0100
Message-ID: <1327072784.12389.22.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:59420 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753626Ab2ATPTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 10:19:47 -0500
Received: by wics10 with SMTP id s10so504816wic.19
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2012 07:19:46 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCA_CHOKE_MAX_P permits to express high resolution RED probability.

tc qdisc add dev $DEV parent 1:1 handle 10: est 1sec 8sec choke \
	limit 90 ecn min 10 max 30 probability 0.05 bandwidth 10Mbit

Before patch :

tc -s -d qdisc show dev eth3
qdisc ... limit 90p min 10p max 30p ecn ewma 3 Plog 19 Scell_log 13

After :

qdisc ... limit 90p min 10p max 30p ecn ewma 3 probability 0.05
Scell_log 13


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 tc/q_choke.c |   20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/tc/q_choke.c b/tc/q_choke.c
index 7816f62..c616926 100644
--- a/tc/q_choke.c
+++ b/tc/q_choke.c
@@ -18,6 +18,7 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <string.h>
+#include <math.h>
 
 #include "utils.h"
 #include "tc_util.h"
@@ -41,6 +42,7 @@ static int choke_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	int ecn_ok = 0;
 	int wlog;
 	__u8 sbuf[256];
+	__u32 max_P;
 	struct rtattr *tail;
 
 	memset(&opt, 0, sizeof(opt));
@@ -156,25 +158,31 @@ static int choke_parse_opt(struct qdisc_util *qu, int argc, char **argv,
 	addattr_l(n, 1024, TCA_OPTIONS, NULL, 0);
 	addattr_l(n, 1024, TCA_CHOKE_PARMS, &opt, sizeof(opt));
 	addattr_l(n, 1024, TCA_CHOKE_STAB, sbuf, 256);
+	max_P = probability * pow(2, 32);
+	addattr_l(n, 1024, TCA_CHOKE_MAX_P, &max_P, sizeof(max_P));
 	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
 	return 0;
 }
 
 static int choke_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 {
-	struct rtattr *tb[TCA_CHOKE_STAB+1];
+	struct rtattr *tb[TCA_CHOKE_MAX+1];
 	const struct tc_red_qopt *qopt;
+	__u32 max_P = 0;
 
 	if (opt == NULL)
 		return 0;
 
-	parse_rtattr_nested(tb, TCA_CHOKE_STAB, opt);
+	parse_rtattr_nested(tb, TCA_CHOKE_MAX, opt);
 
 	if (tb[TCA_CHOKE_PARMS] == NULL)
 		return -1;
 	qopt = RTA_DATA(tb[TCA_CHOKE_PARMS]);
 	if (RTA_PAYLOAD(tb[TCA_CHOKE_PARMS])  < sizeof(*qopt))
 		return -1;
+	if (tb[TCA_CHOKE_MAX_P] &&
+	    RTA_PAYLOAD(tb[TCA_CHOKE_MAX_P]) >= sizeof(__u32))
+		max_P = *(__u32 *)RTA_DATA(tb[TCA_CHOKE_MAX_P]);
 
 	fprintf(f, "limit %up min %up max %up ",
 		qopt->limit, qopt->qth_min, qopt->qth_max);
@@ -183,8 +191,12 @@ static int choke_print_opt(struct qdisc_util *qu, FILE *f, struct rtattr *opt)
 		fprintf(f, "ecn ");
 
 	if (show_details) {
-		fprintf(f, "ewma %u Plog %u Scell_log %u",
-			qopt->Wlog, qopt->Plog, qopt->Scell_log);
+		fprintf(f, "ewma %u ", qopt->Wlog);
+		if (max_P)
+			fprintf(f, "probability %g ", max_P / pow(2, 32));
+		else
+			fprintf(f, "Plog %u ", qopt->Plog);
+		fprintf(f, "Scell_log %u", qopt->Scell_log);
 	}
 	return 0;
 }
