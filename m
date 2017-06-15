From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2/net-next] tc: don't print error message on miss when parsing control action with default
Date: Thu, 15 Jun 2017 14:10:51 +0200
Message-ID: <20170615121051.1877-1-jiri@resnulli.us>
Cc: stephen@networkplumber.org, jbenc@redhat.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35375 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751902AbdFOMK4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 08:10:56 -0400
Received: by mail-wr0-f195.google.com with SMTP id z45so3237748wrb.2
        for <netdev@vger.kernel.org>; Thu, 15 Jun 2017 05:10:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

In case default control action parsing takes place, it is ok to miss.
So don't print error message.

Fixes: e67aba559581 ("tc: actions: add helpers to parse and print control actions")
Reported-by: Jiri Benc <jbenc@redhat.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 tc/tc_util.c | 36 ++++++++++++++++++++++--------------
 1 file changed, 22 insertions(+), 14 deletions(-)

diff --git a/tc/tc_util.c b/tc/tc_util.c
index 5a0f96a..3710468 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -481,18 +481,8 @@ static int action_a2n(char *arg, int *result, bool allow_num)
 	return 0;
 }
 
-/* Parse action control including possible options.
- *
- * Parameters:
- * @argc_p - pointer to argc to parse
- * @argv_p - pointer to argv to parse
- * @result_p - pointer to output variable
- * @allow_num - whether action may be in numeric format already
- *
- * In error case, returns -1 and does not touch @result_1p. Otherwise returns 0.
- */
-int parse_action_control(int *argc_p, char ***argv_p,
-			 int *result_p, bool allow_num)
+static int __parse_action_control(int *argc_p, char ***argv_p, int *result_p,
+				  bool allow_num, bool ignore_a2n_miss)
 {
 	int argc = *argc_p;
 	char **argv = *argv_p;
@@ -501,7 +491,8 @@ int parse_action_control(int *argc_p, char ***argv_p,
 	if (!argc)
 		return -1;
 	if (action_a2n(*argv, &result, allow_num) == -1) {
-		fprintf(stderr, "Bad action type %s\n", *argv);
+		if (!ignore_a2n_miss)
+			fprintf(stderr, "Bad action type %s\n", *argv);
 		return -1;
 	}
 	if (result == TC_ACT_GOTO_CHAIN) {
@@ -534,6 +525,23 @@ int parse_action_control(int *argc_p, char ***argv_p,
  * @argv_p - pointer to argv to parse
  * @result_p - pointer to output variable
  * @allow_num - whether action may be in numeric format already
+ *
+ * In error case, returns -1 and does not touch @result_1p. Otherwise returns 0.
+ */
+int parse_action_control(int *argc_p, char ***argv_p,
+			 int *result_p, bool allow_num)
+{
+	return __parse_action_control(argc_p, argv_p, result_p,
+				      allow_num, false);
+}
+
+/* Parse action control including possible options.
+ *
+ * Parameters:
+ * @argc_p - pointer to argc to parse
+ * @argv_p - pointer to argv to parse
+ * @result_p - pointer to output variable
+ * @allow_num - whether action may be in numeric format already
  * @default_result - set as a result in case of parsing error
  *
  * In case there is an error during parsing, the default result is used.
@@ -542,7 +550,7 @@ void parse_action_control_dflt(int *argc_p, char ***argv_p,
 			       int *result_p, bool allow_num,
 			       int default_result)
 {
-	if (parse_action_control(argc_p, argv_p, result_p, allow_num))
+	if (__parse_action_control(argc_p, argv_p, result_p, allow_num, true))
 		*result_p = default_result;
 }
 
-- 
2.9.3
