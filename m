From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [iproute2 PATH 1/2] tc action policer: Avoid nonsensical input
Date: Wed, 25 May 2016 06:05:48 -0400
Message-ID: <1464170749-7626-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	xiyou.wangcong@gmail.com, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f194.google.com ([209.85.213.194]:34217 "EHLO
	mail-ig0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750733AbcEYKF5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 06:05:57 -0400
Received: by mail-ig0-f194.google.com with SMTP id lp2so4490043igb.1
        for <netdev@vger.kernel.org>; Wed, 25 May 2016 03:05:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

The user must at least specify a choice of the token bucket or
ewma policing or late binding index. TB policing requires at minimal
a rate and burst.

In addition fix formatting issues (80 chars etc).

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_police.c | 45 ++++++++++++++++++++++++++++++---------------
 1 file changed, 30 insertions(+), 15 deletions(-)

diff --git a/tc/m_police.c b/tc/m_police.c
index 97558bd..8752d4f 100644
--- a/tc/m_police.c
+++ b/tc/m_police.c
@@ -99,7 +99,6 @@ static int police_action_a2n(const char *arg, int *result)
 	return 0;
 }
 
-
 static int get_police_result(int *action, int *result, char *arg)
 {
 	char *p = strchr(arg, '/');
@@ -121,8 +120,8 @@ static int get_police_result(int *action, int *result, char *arg)
 	return 0;
 }
 
-
-int act_parse_police(struct action_util *a, int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n)
+int act_parse_police(struct action_util *a, int *argc_p, char ***argv_p,
+		     int tca_id, struct nlmsghdr *n)
 {
 	int argc = *argc_p;
 	char **argv = *argv_p;
@@ -258,10 +257,21 @@ int act_parse_police(struct action_util *a, int *argc_p, char ***argv_p, int tca
 	if (!ok)
 		return -1;
 
-	if (p.rate.rate && !buffer) {
+	if (p.rate.rate && avrate)
+		return -1;
+
+	/* Must at least do late binding, use TB or ewma policing */
+	if (!p.rate.rate && !avrate && !p.index) {
+		fprintf(stderr, "\"rate\" or \"avrate\" MUST be specified.\n");
+		return -1;
+	}
+
+	/* When the TB policer is used, burst is required */
+	if (p.rate.rate && !buffer && !avrate) {
 		fprintf(stderr, "\"burst\" requires \"rate\".\n");
 		return -1;
 	}
+
 	if (p.peakrate.rate) {
 		if (!p.rate.rate) {
 			fprintf(stderr, "\"peakrate\" requires \"rate\".\n");
@@ -276,8 +286,9 @@ int act_parse_police(struct action_util *a, int *argc_p, char ***argv_p, int tca
 	if (p.rate.rate) {
 		p.rate.mpu = mpu;
 		p.rate.overhead = overhead;
-		if (tc_calc_rtable(&p.rate, rtab, Rcell_log, mtu, linklayer) < 0) {
-			fprintf(stderr, "TBF: failed to calculate rate table.\n");
+		if (tc_calc_rtable(&p.rate, rtab, Rcell_log, mtu,
+				   linklayer) < 0) {
+			fprintf(stderr, "POLICE: failed to calculate rate table.\n");
 			return -1;
 		}
 		p.burst = tc_calc_xmittime(p.rate.rate, buffer);
@@ -286,7 +297,8 @@ int act_parse_police(struct action_util *a, int *argc_p, char ***argv_p, int tca
 	if (p.peakrate.rate) {
 		p.peakrate.mpu = mpu;
 		p.peakrate.overhead = overhead;
-		if (tc_calc_rtable(&p.peakrate, ptab, Pcell_log, mtu, linklayer) < 0) {
+		if (tc_calc_rtable(&p.peakrate, ptab, Pcell_log, mtu,
+				   linklayer) < 0) {
 			fprintf(stderr, "POLICE: failed to calculate peak rate table.\n");
 			return -1;
 		}
@@ -317,8 +329,7 @@ int parse_police(int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n)
 	return act_parse_police(NULL, argc_p, argv_p, tca_id, n);
 }
 
-int
-print_police(struct action_util *a, FILE *f, struct rtattr *arg)
+int print_police(struct action_util *a, FILE *f, struct rtattr *arg)
 {
 	SPRINT_BUF(b1);
 	SPRINT_BUF(b2);
@@ -354,22 +365,26 @@ print_police(struct action_util *a, FILE *f, struct rtattr *arg)
 	if (p->peakrate.rate)
 		fprintf(f, "peakrate %s ", sprint_rate(p->peakrate.rate, b1));
 	if (tb[TCA_POLICE_AVRATE])
-		fprintf(f, "avrate %s ", sprint_rate(rta_getattr_u32(tb[TCA_POLICE_AVRATE]), b1));
-	fprintf(f, "action %s", police_action_n2a(p->action, b1, sizeof(b1)));
+		fprintf(f, "avrate %s ",
+			sprint_rate(rta_getattr_u32(tb[TCA_POLICE_AVRATE]),
+				    b1));
+	fprintf(f, "action %s",
+		police_action_n2a(p->action, b1, sizeof(b1)));
 	if (tb[TCA_POLICE_RESULT]) {
-		fprintf(f, "/%s ", police_action_n2a(*(int *)RTA_DATA(tb[TCA_POLICE_RESULT]), b1, sizeof(b1)));
+		fprintf(f, "/%s",
+			police_action_n2a(*(int *)RTA_DATA(tb[TCA_POLICE_RESULT]), b1, sizeof(b1)));
 	} else
 		fprintf(f, " ");
 	fprintf(f, "overhead %ub ", p->rate.overhead);
 	linklayer = (p->rate.linklayer & TC_LINKLAYER_MASK);
 	if (linklayer > TC_LINKLAYER_ETHERNET || show_details)
 		fprintf(f, "linklayer %s ", sprint_linklayer(linklayer, b2));
-	fprintf(f, "\nref %d bind %d\n", p->refcnt, p->bindcnt);
+	fprintf(f, "\n\tref %d bind %d\n", p->refcnt, p->bindcnt);
 
 	return 0;
 }
 
-int
-tc_print_police(FILE *f, struct rtattr *arg) {
+int tc_print_police(FILE *f, struct rtattr *arg)
+{
 	return print_police(&police_action_util, f, arg);
 }
-- 
1.9.1
