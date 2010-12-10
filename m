From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [PATCH] iproute2: ip: add wilcard support for device matching
Date: Fri, 10 Dec 2010 16:58:12 +0200
Message-ID: <1291993092-8675-1-git-send-email-opurdila@ixiacom.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Vlad Dogaru <ddvlad@rosedu.org>,
	Octavian Purdila <opurdila@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:9101 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755564Ab0LJO7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 09:59:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the users to specify a wildcard when selecting a device:

$ ip set link dev dummy* up

We do this by expanding the original command line in multiple lines
which we then feed via a pipe to a forked ip processed run in batch
mode.

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 ip/ip.c |   70 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 70 insertions(+), 0 deletions(-)

diff --git a/ip/ip.c b/ip/ip.c
index b127d57..2e26488 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -18,6 +18,8 @@
 #include <netinet/in.h>
 #include <string.h>
 #include <errno.h>
+#include <sys/types.h>
+#include <sys/wait.h>
 
 #include "SNAPSHOT.h"
 #include "utils.h"
@@ -139,10 +141,72 @@ static int batch(const char *name)
 	return ret;
 }
 
+int main(int argc, char **argv);
+
+int expand_dev_pattern(int argc, char **argv, int pos)
+{
+	FILE *proc;
+	size_t n, dev_no;
+	char scanf_pattern[64], *line = NULL, *dev_base = argv[pos];
+	int p[2], i;
+	pid_t pid;
+
+	*strchr(dev_base, '*') = 0;
+	snprintf(scanf_pattern, sizeof(scanf_pattern), " %s%%d:", dev_base);
+
+	if (pipe(p) < 0) {
+		fprintf(stderr, "pipe() failed: %s\n", strerror(errno));
+		return -1;
+	}
+
+	pid = fork();
+	switch (pid) {
+	case -1:
+		fprintf(stderr, "fork failed: %s\n", strerror(errno));
+		return -1;
+	case 0:
+	{
+		char *nargv[] = { argv[0], "-b", "-" };
+		int ret;
+
+		dup2(p[0], 0); close(p[0]); close(p[1]);
+		ret = main(3, nargv);
+		exit(ret);
+	}
+	default:
+		dup2(p[1], 1); close(p[0]); close(p[1]);
+	}
+
+	proc = fopen("/proc/net/dev", "r");
+	if (!proc) {
+		fprintf(stderr, "can't open /proc/net/dev\n");
+		return -1;
+	}
+
+	while (getline(&line, &n, proc) > 0) {
+		if (sscanf(line, scanf_pattern, &dev_no) == 1) {
+			for (i = 1; i < argc; i++)
+				if (i != pos)
+					printf("%s ", argv[i]);
+				else
+					printf("%s%d ", dev_base, dev_no);
+			printf("\n");
+		}
+	}
+	free(line);
+
+	fflush(stdout); close(1);
+
+	waitpid(pid, NULL, 0);
+
+	return 0;
+}
 
 int main(int argc, char **argv)
 {
 	char *basename;
+	int i = 0;
+
 
 	basename = strrchr(argv[0], '/');
 	if (basename == NULL)
@@ -150,6 +214,12 @@ int main(int argc, char **argv)
 	else
 		basename++;
 
+	for (i = 1; i < argc - 1; i++) {
+		if (matches(argv[i], "dev") == 0 && strchr(argv[i+1], '*')) {
+			return expand_dev_pattern(argc, argv, i+1);
+		}
+	}
+
 	while (argc > 1) {
 		char *opt = argv[1];
 		if (strcmp(opt,"--") == 0) {
-- 
1.7.1

