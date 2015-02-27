From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] ss: Allow to specify sport/dport without ':'
Date: Fri, 27 Feb 2015 23:54:36 +0200
Message-ID: <1425074076-30040-1-git-send-email-vadim4j@gmail.com>
Cc: netdev@vger.kernel.org, Vadim Kochan <vadim4j@gmail.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:44884 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755471AbbB0WF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 17:05:59 -0500
Received: by lbiv13 with SMTP id v13so1121327lbi.11
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 14:05:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Ugly change but it allows to specify sport/dport w/o ':'

    # ss dport = 80 and sport = 44862

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 misc/ss.c       | 14 +++++++++-----
 misc/ssfilter.h |  4 +++-
 misc/ssfilter.y | 23 +++++++++++++++++------
 3 files changed, 29 insertions(+), 12 deletions(-)

diff --git a/misc/ss.c b/misc/ss.c
index 21a4366..196b020 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1380,7 +1380,7 @@ static int xll_name_to_index(const char *dev)
 	return ll_name_to_index(dev);
 }
 
-void *parse_hostcond(char *addr)
+void *parse_hostcond(char *addr, bool is_port)
 {
 	char *port = NULL;
 	struct aafilter a = { .port = -1 };
@@ -1473,10 +1473,14 @@ void *parse_hostcond(char *addr)
 	} else {
 		port = strrchr(strchr(addr, '/') ? : addr, ':');
 	}
+
+	if (is_port)
+		port = addr;
+
 	if (port && *port) {
-		if (*port != ':')
-			return NULL;
-		*port++ = 0;
+		if (*port == ':')
+			*port++ = 0;
+
 		if (*port && *port != '*') {
 			if (get_integer(&a.port, port, 0)) {
 				struct servent *se1 = NULL;
@@ -1517,7 +1521,7 @@ void *parse_hostcond(char *addr)
 			}
 		}
 	}
-	if (addr && *addr && *addr != '*') {
+	if (!is_port && addr && *addr && *addr != '*') {
 		if (get_prefix_1(&a.addr, addr, fam)) {
 			if (get_dns_host(&a, addr, fam)) {
 				fprintf(stderr, "Error: an inet prefix is expected rather than \"%s\".\n", addr);
diff --git a/misc/ssfilter.h b/misc/ssfilter.h
index 00b92e3..b20092b 100644
--- a/misc/ssfilter.h
+++ b/misc/ssfilter.h
@@ -9,6 +9,8 @@
 #define SSF_S_LE  8
 #define SSF_S_AUTO  9
 
+#include <stdbool.h>
+
 struct ssfilter
 {
 	int type;
@@ -17,5 +19,5 @@ struct ssfilter
 };
 
 int ssfilter_parse(struct ssfilter **f, int argc, char **argv, FILE *fp);
-void *parse_hostcond(char*);
+void *parse_hostcond(char *addr, bool is_port);
 
diff --git a/misc/ssfilter.y b/misc/ssfilter.y
index 2e9d962..a258d04 100644
--- a/misc/ssfilter.y
+++ b/misc/ssfilter.y
@@ -25,6 +25,7 @@ static char		**yy_argv;
 static int		yy_argc;
 static FILE		*yy_fp;
 static ssfilter_t	*yy_ret;
+static int tok_type = -1;
 
 static int yylex(void);
 
@@ -220,14 +221,22 @@ int yylex(void)
 		return '(';
 	if (strcmp(curtok, ")") == 0)
 		return ')';
-	if (strcmp(curtok, "dst") == 0)
+	if (strcmp(curtok, "dst") == 0) {
+		tok_type = DCOND;
 		return DCOND;
-	if (strcmp(curtok, "src") == 0)
+	}
+	if (strcmp(curtok, "src") == 0) {
+                tok_type = SCOND;
 		return SCOND;
-	if (strcmp(curtok, "dport") == 0)
+        }
+	if (strcmp(curtok, "dport") == 0) {
+		tok_type = DPORT;
 		return DPORT;
-	if (strcmp(curtok, "sport") == 0)
+	}
+	if (strcmp(curtok, "sport") == 0) {
+		tok_type = SPORT;
 		return SPORT;
+	}
 	if (strcmp(curtok, ">=") == 0 ||
 	    strcmp(curtok, "ge") == 0 ||
 	    strcmp(curtok, "geq") == 0)
@@ -250,9 +259,11 @@ int yylex(void)
 	if (strcmp(curtok, "<") == 0 ||
 	    strcmp(curtok, "lt") == 0)
 		return '<';
-	if (strcmp(curtok, "autobound") == 0)
+	if (strcmp(curtok, "autobound") == 0) {
+		tok_type = AUTOBOUND;
 		return AUTOBOUND;
-	yylval = (void*)parse_hostcond(curtok);
+	}
+	yylval = (void*)parse_hostcond(curtok, tok_type == SPORT || tok_type == DPORT);
 	if (yylval == NULL) {
 		fprintf(stderr, "Cannot parse dst/src address.\n");
 		exit(1);
-- 
2.2.2
