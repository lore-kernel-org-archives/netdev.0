From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH 1/1] iproute2 actions: BugFix action stats to display with -s
Date: Sun, 21 Sep 2014 12:29:14 -0400
Message-ID: <1411316954-9745-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:44638 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752749AbaIUQ3d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Sep 2014 12:29:33 -0400
Received: by mail-ig0-f174.google.com with SMTP id r10so1512163igi.1
        for <netdev@vger.kernel.org>; Sun, 21 Sep 2014 09:29:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Was broken by commit 288abf513f5d11b98f09c6977d2019097afb7e9f
Lets not be too clever and have a separate call to print flushed
actions info.

Broken looks like:
root@moja-1:~# tc actions add  action drop index 4
root@moja-1:~# tc -s actions ls action gact

    action order 0: gact action drop
     random type none pass val 0
     index 4 ref 1 bind 0 installed 9 sec used 4 sec

The fixed version looks like:
    action order 0: gact action drop
     random type none pass val 0
     index 4 ref 1 bind 0 installed 9 sec used 4 sec
         Sent 108948 bytes 1297 pkts (dropped 1297, overlimits 0)

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_action.c |   55 ++++++++++++++++++++++++++++++++++++-------------------
 1 file changed, 36 insertions(+), 19 deletions(-)

diff --git a/tc/m_action.c b/tc/m_action.c
index 7dbcf5b..486123e 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -249,38 +249,31 @@ static int
 tc_print_one_action(FILE * f, struct rtattr *arg)
 {
 
-	struct rtattr *tb[TCA_MAX + 1];
+	struct rtattr *tb[TCA_ACT_MAX + 1];
 	int err = 0;
 	struct action_util *a = NULL;
 
 	if (arg == NULL)
 		return -1;
 
-	parse_rtattr_nested(tb, TCA_MAX, arg);
-	if (tb[TCA_KIND] == NULL) {
+	parse_rtattr_nested(tb, TCA_ACT_MAX, arg);
+
+	if (tb[TCA_ACT_KIND] == NULL) {
 		fprintf(stderr, "NULL Action!\n");
 		return -1;
 	}
 
 
-	a = get_action_kind(RTA_DATA(tb[TCA_KIND]));
+	a = get_action_kind(RTA_DATA(tb[TCA_ACT_KIND]));
 	if (NULL == a)
 		return err;
 
-	if (tab_flush) {
-		__u32 *delete_count = RTA_DATA(tb[TCA_FCNT]);
-		fprintf(f," %s (%d entries)\n", a->id, *delete_count);
-		tab_flush = 0;
-		return 0;
-	}
-
-	err = a->print_aopt(a,f,tb[TCA_OPTIONS]);
-
+	err = a->print_aopt(a, f, tb[TCA_ACT_OPTIONS]);
 
 	if (0 > err)
 		return err;
 
-	if (show_stats && tb[TCA_STATS]) {
+	if (show_stats && tb[TCA_ACT_STATS]) {
 		fprintf(f, "\tAction statistics:\n");
 		print_tcstats2_attr(f, tb[TCA_ACT_STATS], "\t", NULL);
 		fprintf(f, "\n");
@@ -289,8 +282,34 @@ tc_print_one_action(FILE * f, struct rtattr *arg)
 	return 0;
 }
 
+static int
+tc_print_action_flush(FILE *f, const struct rtattr *arg)
+{
+
+	struct rtattr *tb[TCA_MAX + 1];
+	int err = 0;
+	struct action_util *a = NULL;
+	__u32 *delete_count = 0;
+
+	parse_rtattr_nested(tb, TCA_MAX, arg);
+
+	if (tb[TCA_KIND] == NULL) {
+		fprintf(stderr, "NULL Action!\n");
+		return -1;
+	}
+
+	a = get_action_kind(RTA_DATA(tb[TCA_KIND]));
+	if (NULL == a)
+		return err;
+
+	delete_count = RTA_DATA(tb[TCA_FCNT]);
+	fprintf(f," %s (%d entries)\n", a->id, *delete_count);
+	tab_flush = 0;
+	return 0;
+}
+
 int
-tc_print_action(FILE * f, const struct rtattr *arg)
+tc_print_action(FILE *f, const struct rtattr *arg)
 {
 
 	int i;
@@ -301,10 +320,8 @@ tc_print_action(FILE * f, const struct rtattr *arg)
 
 	parse_rtattr_nested(tb, TCA_ACT_MAX_PRIO, arg);
 
-	if (tab_flush && NULL != tb[0]  && NULL == tb[1]) {
-		int ret = tc_print_one_action(f, tb[0]);
-		return ret;
-	}
+	if (tab_flush && NULL != tb[0]  && NULL == tb[1])
+		return tc_print_action_flush(f, tb[0]);
 
 	for (i = 0; i < TCA_ACT_MAX_PRIO; i++) {
 		if (tb[i]) {
-- 
1.7.9.5
