From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/4] tc: util: bore up action_a2n()
Date: Sat, 23 Jul 2016 13:28:08 +0200
Message-ID: <1469273290-18539-3-git-send-email-phil@nwl.cc>
References: <1469273290-18539-1-git-send-email-phil@nwl.cc>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:46854 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751260AbcGWL2s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 07:28:48 -0400
In-Reply-To: <1469273290-18539-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's a pitty this function is used nowhere, so let's polish it for use:

* Loop over branch names, makes it clear that every former conditional
  was exactly identical.
* Support 'pipe' branch name, too.
* Make number parsing optional.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/tc_util.c | 56 +++++++++++++++++++++++++++++++++++---------------------
 tc/tc_util.h |  2 +-
 2 files changed, 36 insertions(+), 22 deletions(-)

diff --git a/tc/tc_util.c b/tc/tc_util.c
index fd6669f281cc1..cd7b40b0afe48 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -435,29 +435,43 @@ char *action_n2a(int action, char *buf, int len)
 	}
 }
 
-int action_a2n(char *arg, int *result)
+/* Convert action branch name into numeric format.
+ *
+ * Parameters:
+ * @arg - string to parse
+ * @result - pointer to output variable
+ * @allow_num - whether @arg may be in numeric format already
+ *
+ * In error case, returns -1 and does not touch @result. Otherwise returns 0.
+ */
+int action_a2n(char *arg, int *result, bool allow_num)
 {
-	int res;
-
-	if (matches(arg, "continue") == 0)
-		res = -1;
-	else if (matches(arg, "drop") == 0)
-		res = TC_ACT_SHOT;
-	else if (matches(arg, "shot") == 0)
-		res = TC_ACT_SHOT;
-	else if (matches(arg, "pass") == 0)
-		res = TC_ACT_OK;
-	else if (strcmp(arg, "ok") == 0)
-		res = TC_ACT_OK;
-	else if (matches(arg, "reclassify") == 0)
-		res = TC_ACT_RECLASSIFY;
-	else {
-		char dummy;
-
-		if (sscanf(arg, "%d%c", &res, &dummy) != 1)
-			return -1;
+	int n;
+	char dummy;
+	struct {
+		const char *a;
+		int n;
+	} a2n[] = {
+		{"continue", TC_ACT_UNSPEC},
+		{"drop", TC_ACT_SHOT},
+		{"shot", TC_ACT_SHOT},
+		{"pass", TC_ACT_OK},
+		{"ok", TC_ACT_OK},
+		{"reclassify", TC_ACT_RECLASSIFY},
+		{"pipe", TC_ACT_PIPE},
+		{ NULL },
+	}, *iter;
+
+	for (iter = a2n; iter->a; iter++) {
+		if (matches(arg, iter->a) != 0)
+			continue;
+		*result = iter->n;
+		return 0;
 	}
-	*result = res;
+	if (!allow_num || sscanf(arg, "%d%c", &n, &dummy) != 1)
+		return -1;
+
+	*result = n;
 	return 0;
 }
 
diff --git a/tc/tc_util.h b/tc/tc_util.h
index 744f18fdd9117..e7613ab1bd496 100644
--- a/tc/tc_util.h
+++ b/tc/tc_util.h
@@ -100,7 +100,7 @@ int tc_print_police(FILE *f, struct rtattr *tb);
 int parse_police(int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n);
 
 char *action_n2a(int action, char *buf, int len);
-int action_a2n(char *arg, int *result);
+int action_a2n(char *arg, int *result, bool allow_num);
 int act_parse_police(struct action_util *a, int *argc_p,
 		     char ***argv_p, int tca_id, struct nlmsghdr *n);
 int print_police(struct action_util *a, FILE *f, struct rtattr *tb);
-- 
2.8.2
