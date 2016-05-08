From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [iproute2 PATCH 1/1] tc simple action update and breakage
Date: Sun,  8 May 2016 10:44:35 -0400
Message-ID: <1462718675-7083-1-git-send-email-jhs@emojatatu.com>
Cc: netdev@vger.kernel.org, Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f196.google.com ([209.85.213.196]:33108 "EHLO
	mail-ig0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715AbcEHOoq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2016 10:44:46 -0400
Received: by mail-ig0-f196.google.com with SMTP id rc4so9298181igc.0
        for <netdev@vger.kernel.org>; Sun, 08 May 2016 07:44:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>

Brings it closer to more serious actions (adding branching
and allowing for late binding)

Unfortunately this breaks old syntax of the simple action.
But because simple is a pedagogical example unlikely to be used
in production environments (i.e its role is to serve as an example
on how to write actions), then this is ok.

New syntax for simple has new keyword "sdata". Example usage is:

sudo tc actions add action simple sdata "foobar" index 1
or
tc filter add dev $DEV parent ffff: protocol ip prio 1 u32\
match ip dst 17.0.0.1/32 flowid 1:10 action simple sdata "foobar"

Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_simple.c | 64 ++++++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 48 insertions(+), 16 deletions(-)

diff --git a/tc/m_simple.c b/tc/m_simple.c
index e167cca..8e85f99 100644
--- a/tc/m_simple.c
+++ b/tc/m_simple.c
@@ -81,9 +81,10 @@
 #endif
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... simple STRING\n"
-		"STRING being an arbitrary string\n"
-		"example: \"simple blah\"\n");
+	fprintf(stderr, "Usage:... simple [sdata STRING] [CONTROL] [index INDEX]\n");
+	fprintf(stderr, "\tSTRING being an arbitrary string\n"
+		"\tCONTROL := reclassify|pipe|drop|continue|ok\n"
+		"\tINDEX := optional index value used\n");
 }
 
 static void usage(void)
@@ -99,56 +100,87 @@ parse_simple(struct action_util *a, int *argc_p, char ***argv_p, int tca_id,
 	struct tc_defact sel = {};
 	int argc = *argc_p;
 	char **argv = *argv_p;
-	int ok = 0;
+	int ok = 0, maybe_bind = 0;
 	struct rtattr *tail;
 	char *simpdata = NULL;
 
-
 	while (argc > 0) {
 		if (matches(*argv, "simple") == 0) {
 			NEXT_ARG();
-			simpdata = *argv;
-			ok = 1;
-			argc--;
-			argv++;
 			break;
+		} else if (matches(*argv, "sdata") == 0) {
+			NEXT_ARG();
+			ok += 1;
+			simpdata = *argv;
 		} else if (matches(*argv, "help") == 0) {
 			usage();
 		} else {
 			break;
 		}
-
+		argc--;
+		argv++;
 	}
 
-	if (!ok) {
-		explain();
-		return -1;
+
+	if (argc) {
+		if (matches(*argv, "reclassify") == 0) {
+			sel.action = TC_ACT_RECLASSIFY;
+			argc--;
+			argv++;
+		} else if (matches(*argv, "pipe") == 0) {
+			sel.action = TC_ACT_PIPE;
+			argc--;
+			argv++;
+		} else if (matches(*argv, "drop") == 0 ||
+			   matches(*argv, "shot") == 0) {
+			sel.action = TC_ACT_SHOT;
+			argc--;
+			argv++;
+		} else if (matches(*argv, "continue") == 0) {
+			sel.action = TC_ACT_UNSPEC;
+			argc--;
+			argv++;
+		} else if (matches(*argv, "pass") == 0 ||
+			   matches(*argv, "ok") == 0) {
+			sel.action = TC_ACT_OK;
+			argc--;
+			argv++;
+		}
 	}
 
 	if (argc) {
 		if (matches(*argv, "index") == 0) {
 			NEXT_ARG();
 			if (get_u32(&sel.index, *argv, 10)) {
-				fprintf(stderr, "simple: Illegal \"index\"\n");
+				fprintf(stderr, "simple: Illegal \"index\"\n",
+					*argv);
 				return -1;
 			}
+			ok += 1;
 			argc--;
 			argv++;
 		}
 	}
 
-	if (strlen(simpdata) > (SIMP_MAX_DATA - 1)) {
+	if (!ok) {
+		explain();
+		return -1;
+	}
+
+	if (simpdata && (strlen(simpdata) > (SIMP_MAX_DATA - 1))) {
 		fprintf(stderr, "simple: Illegal string len %zu <%s>\n",
 			strlen(simpdata), simpdata);
 		return -1;
 	}
 
+
 	sel.action = TC_ACT_PIPE;
 
 	tail = NLMSG_TAIL(n);
 	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
 	addattr_l(n, MAX_MSG, TCA_DEF_PARMS, &sel, sizeof(sel));
-	addattr_l(n, MAX_MSG, TCA_DEF_DATA, simpdata, SIMP_MAX_DATA);
+	if (simpdata)
+		addattr_l(n, MAX_MSG, TCA_DEF_DATA, simpdata, SIMP_MAX_DATA);
 	tail->rta_len = (char *)NLMSG_TAIL(n) - (char *)tail;
 
 	*argc_p = argc;
-- 
1.9.1
