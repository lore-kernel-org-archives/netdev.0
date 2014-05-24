From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [PATCH 1/1] actions: correctly report the number of actions flushed
Date: Sat, 24 May 2014 09:13:35 -0400
Message-ID: <1400937215-15542-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:39939 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845AbaEXNNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 09:13:45 -0400
Received: by mail-pb0-f41.google.com with SMTP id uo5so5416526pbc.14
        for <netdev@vger.kernel.org>; Sat, 24 May 2014 06:13:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

This also fixes a long standing bug of not sanely reporting the
action chain ordering

Sample scenario test

on window 1(event window):
run "tc monitor" and observe events

on window 2:
sudo tc actions add action drop index 10
sudo tc actions add action ok index 12
sudo tc actions ls action gact
sudo tc actions flush action gact

See the event window reporting two entries
(doing another listing should show empty generic actions)

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_action.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/tc/m_action.c b/tc/m_action.c
index 5cd5e67..7dbcf5b 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -249,37 +249,38 @@ static int
 tc_print_one_action(FILE * f, struct rtattr *arg)
 {
 
-	struct rtattr *tb[TCA_ACT_MAX + 1];
+	struct rtattr *tb[TCA_MAX + 1];
 	int err = 0;
 	struct action_util *a = NULL;
 
 	if (arg == NULL)
 		return -1;
 
-	parse_rtattr_nested(tb, TCA_ACT_MAX, arg);
-	if (tb[TCA_ACT_KIND] == NULL) {
+	parse_rtattr_nested(tb, TCA_MAX, arg);
+	if (tb[TCA_KIND] == NULL) {
 		fprintf(stderr, "NULL Action!\n");
 		return -1;
 	}
 
 
-	a = get_action_kind(RTA_DATA(tb[TCA_ACT_KIND]));
+	a = get_action_kind(RTA_DATA(tb[TCA_KIND]));
 	if (NULL == a)
 		return err;
 
 	if (tab_flush) {
-		fprintf(f," %s \n", a->id);
+		__u32 *delete_count = RTA_DATA(tb[TCA_FCNT]);
+		fprintf(f," %s (%d entries)\n", a->id, *delete_count);
 		tab_flush = 0;
 		return 0;
 	}
 
-	err = a->print_aopt(a,f,tb[TCA_ACT_OPTIONS]);
+	err = a->print_aopt(a,f,tb[TCA_OPTIONS]);
 
 
 	if (0 > err)
 		return err;
 
-	if (show_stats && tb[TCA_ACT_STATS]) {
+	if (show_stats && tb[TCA_STATS]) {
 		fprintf(f, "\tAction statistics:\n");
 		print_tcstats2_attr(f, tb[TCA_ACT_STATS], "\t", NULL);
 		fprintf(f, "\n");
-- 
1.7.9.5
