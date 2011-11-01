From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 20/21] Run tests in-process
Date: Tue, 1 Nov 2011 23:23:46 +0000
Message-ID: <1320189826.2758.52.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:38829 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932447Ab1KAXXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 19:23:50 -0400
In-Reply-To: <1320186901.2758.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change definition of main() and use of exit() so that ethtool commands
can be tested without starting a new process.  This will allow deeper
testing that covers ioctl requests and responses.

Fix the obvious socket and memory leaks.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 Makefile.am    |    6 +---
 ethtool.c      |   25 +++++++++++++-------
 internal.h     |    5 ++++
 test-cmdline.c |    6 +++++
 test-common.c  |   65 +++++++++++++++++++++++++++++++------------------------
 5 files changed, 66 insertions(+), 41 deletions(-)

diff --git a/Makefile.am b/Makefile.am
index 4b0eb17..cfc2b79 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -12,11 +12,9 @@ ethtool_SOURCES = ethtool.c ethtool-copy.h internal.h \
 		  rxclass.c
 
 TESTS = test-cmdline
-check_PROGRAMS = test-cmdline test-one-cmdline
-test_cmdline_SOURCES = test-cmdline.c test-common.c
+check_PROGRAMS = test-cmdline
+test_cmdline_SOURCES = test-cmdline.c test-common.c $(ethtool_SOURCES) 
 test_cmdline_CFLAGS = -DTEST_ETHTOOL
-test_one_cmdline_SOURCES = $(ethtool_SOURCES)
-test_one_cmdline_CFLAGS = -DTEST_ETHTOOL
 
 dist-hook:
 	cp $(top_srcdir)/ethtool.spec $(distdir)
diff --git a/ethtool.c b/ethtool.c
index 8e757e9..f192376 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -259,7 +259,7 @@ static void exit_bad_args(void)
 	fprintf(stderr,
 		"ethtool: bad command line argument(s)\n"
 		"For more information run ethtool -h\n");
-	exit(1);
+	ethtool_exit(1);
 }
 
 static int show_usage(struct cmd_context *ctx)
@@ -2754,6 +2754,7 @@ static int do_grxfhindir(struct cmd_context *ctx)
 	err = send_ioctl(ctx, indir);
 	if (err < 0) {
 		perror("Cannot get RX flow hash indirection table");
+		free(indir);
 		return 103;
 	}
 
@@ -2766,6 +2767,8 @@ static int do_grxfhindir(struct cmd_context *ctx)
 		if (i % 8 == 7)
 			fputc('\n', stdout);
 	}
+
+	free(indir);
 	return 0;
 }
 
@@ -2817,14 +2820,16 @@ static int do_srxfhindir(struct cmd_context *ctx)
 		if (sum == 0) {
 			fprintf(stderr,
 				"At least one weight must be non-zero\n");
-			exit(1);
+			free(indir);
+			ethtool_exit(1);
 		}
 
 		if (sum > indir->size) {
 			fprintf(stderr,
 				"Total weight exceeds the size of the "
 				"indirection table\n");
-			exit(1);
+			free(indir);
+			ethtool_exit(1);
 		}
 
 		j = -1;
@@ -2844,6 +2849,7 @@ static int do_srxfhindir(struct cmd_context *ctx)
 		return 105;
 	}
 
+	free(indir);
 	return 0;
 }
 
@@ -3199,18 +3205,15 @@ static int do_setfwdump(struct cmd_context *ctx)
 	return 0;
 }
 
+#ifndef TEST_ETHTOOL
 int send_ioctl(struct cmd_context *ctx, void *cmd)
 {
-#ifndef TEST_ETHTOOL
 	ctx->ifr.ifr_data = cmd;
 	return ioctl(ctx->fd, SIOCETHTOOL, &ctx->ifr);
-#else
-	/* If we get this far then parsing succeeded */
-	exit(0);
-#endif
 }
+#endif
 
-int main(int argc, char **argp, char **envp)
+int ethtool_main(int argc, char **argp)
 {
 	int (*func)(struct cmd_context *);
 	int want_device;
@@ -3265,12 +3268,16 @@ opt_found:
 		memset(&ctx.ifr, 0, sizeof(ctx.ifr));
 		strcpy(ctx.ifr.ifr_name, ctx.devname);
 
+#ifndef TEST_ETHTOOL
 		/* Open control socket. */
 		ctx.fd = socket(AF_INET, SOCK_DGRAM, 0);
 		if (ctx.fd < 0) {
 			perror("Cannot get control socket");
 			return 70;
 		}
+#else
+		ctx.fd = -1;
+#endif
 	} else {
 		ctx.fd = -1;
 	}
diff --git a/internal.h b/internal.h
index cb126b3..8505396 100644
--- a/internal.h
+++ b/internal.h
@@ -98,7 +98,12 @@ struct cmd_context {
 };
 
 #ifdef TEST_ETHTOOL
+int ethtool_main(int argc, char **argp);
+void ethtool_exit(int rc) __attribute__((noreturn));
 int test_cmdline(const char *args);
+#else
+#define ethtool_main(...) main(__VA_ARGS__)
+#define ethtool_exit(rc) exit(rc)
 #endif
 
 int send_ioctl(struct cmd_context *ctx, void *cmd);
diff --git a/test-cmdline.c b/test-cmdline.c
index 7dd3b7c..df1aeed 100644
--- a/test-cmdline.c
+++ b/test-cmdline.c
@@ -213,6 +213,12 @@ static struct test_case {
 	{ 1, "-0" },
 };
 
+int send_ioctl(struct cmd_context *ctx, void *cmd)
+{
+	/* If we get this far then parsing succeeded */
+	ethtool_exit(0);
+}
+
 int main(void)
 {
 	struct test_case *tc;
diff --git a/test-common.c b/test-common.c
index 4ea84c8..5a06ac7 100644
--- a/test-common.c
+++ b/test-common.c
@@ -7,22 +7,27 @@
  * by the Free Software Foundation, incorporated herein by reference.
  */
 
+#include <setjmp.h>
 #include <stdlib.h>
 #include <string.h>
 #include <sys/fcntl.h>
-#include <sys/wait.h>
 #include <unistd.h>
 #include "internal.h"
 
+static jmp_buf test_return;
+
+void ethtool_exit(int rc)
+{
+	longjmp(test_return, rc + 1);
+}
+
 int test_cmdline(const char *args)
 {
 	int argc, i;
 	char **argv;
 	const char *arg;
 	size_t len;
-	pid_t pid;
-	int dev_null;
-	int status;
+	int dev_null = -1, old_stdout = -1, old_stderr = -1;
 	int rc;
 
 	/* Convert line to argv */
@@ -56,35 +61,39 @@ int test_cmdline(const char *args)
 	}
 
 	fflush(NULL);
-	pid = fork();
-
-	/* Child */
-	if (pid == 0) {
-		dup2(dev_null, STDIN_FILENO);
-		if (!getenv("ETHTOOL_TEST_VERBOSE")) {
-			dup2(dev_null, STDOUT_FILENO);
-			dup2(dev_null, STDERR_FILENO);
+	dup2(dev_null, STDIN_FILENO);
+	if (!getenv("ETHTOOL_TEST_VERBOSE")) {
+		old_stdout = dup(STDOUT_FILENO);
+		if (old_stdout < 0) {
+			perror("dup stdout");
+			rc = -1;
+			goto out;
 		}
-		execv("./test-one-cmdline", argv);
-		_exit(126);
+		dup2(dev_null, STDOUT_FILENO);
+		old_stderr = dup(STDERR_FILENO);
+		if (old_stderr < 0) {
+			perror("dup stderr");
+			rc = -1;
+			goto out;
+		}
+		dup2(dev_null, STDERR_FILENO);
 	}
 
-	/* Parent */
-	if (pid < 0) {
-		perror("fork");
-		close(dev_null);
-		rc = -1;
-		goto out;
-	}
-	close(dev_null);
-	if (waitpid(pid, &status, 0) < 0) {
-		perror("waitpid");
-		rc = -1;
-		goto out;
-	}
-	rc = WIFEXITED(status) ? WEXITSTATUS(status) : -1;
+	rc = setjmp(test_return);
+	rc = rc ? rc - 1 : ethtool_main(argc, argv);
 
 out:
+	fflush(NULL);
+	if (old_stderr >= 0) {
+		dup2(old_stderr, STDERR_FILENO);
+		close(old_stderr);
+	}
+	if (old_stdout >= 0) {
+		dup2(old_stdout, STDOUT_FILENO);
+		close(old_stdout);
+	}
+	if (dev_null >= 0)
+		close(dev_null);
 	for (i = 0; i < argc; i++)
 		free(argv[i]);
 	free(argv);
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
