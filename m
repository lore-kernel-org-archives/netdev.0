From: Andreas Henriksson <andreas@fatal.se>
Subject: [PATCH 07/12] Fix corruption when using batch files with comments and broken lines.
Date: Fri, 12 Oct 2007 10:56:42 +0200
Message-ID: <1192179407-22461-7-git-send-email-andreas@fatal.se>
References: <1192179407-22461-1-git-send-email-andreas@fatal.se>
 <1192179407-22461-2-git-send-email-andreas@fatal.se>
 <1192179407-22461-3-git-send-email-andreas@fatal.se>
 <1192179407-22461-4-git-send-email-andreas@fatal.se>
 <1192179407-22461-5-git-send-email-andreas@fatal.se>
 <1192179407-22461-6-git-send-email-andreas@fatal.se>
Cc: netdev@vger.kernel.org, Andreas Henriksson <andreas@fatal.se>
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-1-9a.ghn.gbg.bostream.se ([82.182.69.4]:38403 "EHLO
	scream.fatal.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419AbXJLI5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2007 04:57:40 -0400
In-Reply-To: <1192179407-22461-6-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I could only reproduce on some old pentium machine, don't know why.
Anyway, the patch fixes a problem resulting in a double free
that occurs when using batch files that contains a special combination
of broken up lines and comments as reported in:
http://bugs.debian.org/398912

Thanks to Michal Pokrywka <mpokrywka@hoga.pl> for testcase and information
on which conditions problem could be reproduced under.

Signed-off-by: Andreas Henriksson <andreas@fatal.se>
---
 include/utils.h |    2 +-
 lib/utils.c     |    8 +++++---
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index 7da2b29..9ee55fd 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -144,7 +144,7 @@ int print_timestamp(FILE *fp);
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
 
 extern int cmdlineno;
-extern size_t getcmdline(char **line, size_t *len, FILE *in);
+extern ssize_t getcmdline(char **line, size_t *len, FILE *in);
 extern int makeargs(char *line, char *argv[], int maxargs);
 
 #endif /* __UTILS_H__ */
diff --git a/lib/utils.c b/lib/utils.c
index 4c42dfd..ffef6fe 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -642,9 +642,9 @@ int print_timestamp(FILE *fp)
 int cmdlineno;
 
 /* Like glibc getline but handle continuation lines and comments */
-size_t getcmdline(char **linep, size_t *lenp, FILE *in)
+ssize_t getcmdline(char **linep, size_t *lenp, FILE *in)
 {
-	size_t cc;
+	ssize_t cc;
 	char *cp;
 
 	if ((cc = getline(linep, lenp, in)) < 0)
@@ -672,9 +672,11 @@ size_t getcmdline(char **linep, size_t *lenp, FILE *in)
 		if (cp)
 			*cp = '\0';
 
-		*linep = realloc(*linep, strlen(*linep) + strlen(line1) + 1);
+		*lenp = strlen(*linep) + strlen(line1) + 1;
+		*linep = realloc(*linep, *lenp);
 		if (!*linep) {
 			fprintf(stderr, "Out of memory\n");
+			*lenp = 0;
 			return -1;
 		}
 		cc += cc1 - 2;
-- 
1.5.3.4

