From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 3/7] test: Add test_ioctl() function to support a
 mock send_ioctl()
Date: Sat, 2 Jun 2012 01:37:13 +0100
Message-ID: <1338597433.2770.16.camel@bwh-desktop.uk.solarflarecom.com>
References: <1338597227.2770.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Mahesh Bandewar <maheshb@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35819 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760249Ab2FBAhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 20:37:16 -0400
In-Reply-To: <1338597227.2770.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

test_ioctl() verifies an ethtool ioctl structure and either returns a
canned response (if it was as expected) or aborts the test.

Adjust the file redirection in test_cmdline() so that test_ioctl() can
always print error messages.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 internal.h    |   10 ++++++++
 test-common.c |   70 +++++++++++++++++++++++++++++++++++++++++++++++---------
 2 files changed, 68 insertions(+), 12 deletions(-)

diff --git a/internal.h b/internal.h
index b013783..0fff2a5 100644
--- a/internal.h
+++ b/internal.h
@@ -103,6 +103,16 @@ struct cmd_context {
 #ifdef TEST_ETHTOOL
 int test_cmdline(const char *args);
 
+struct cmd_expect {
+	const void *cmd;	/* expected command; NULL at end of list */
+	size_t cmd_len;		/* length to match (might be < sizeof struct) */
+	int rc;			/* kernel return code */
+	const void *resp;	/* response to write back; may be NULL */
+	size_t resp_len;	/* length to write back */
+};
+int test_ioctl(const struct cmd_expect *expect, void *cmd);
+#define TEST_IOCTL_MISMATCH (-2)
+
 #ifndef TEST_NO_WRAPPERS
 int test_main(int argc, char **argp);
 #define main(...) test_main(__VA_ARGS__)
diff --git a/test-common.c b/test-common.c
index 69853aa..adc3cd4 100644
--- a/test-common.c
+++ b/test-common.c
@@ -10,6 +10,7 @@
  */
 
 #include <assert.h>
+#include <errno.h>
 #include <setjmp.h>
 #include <stdarg.h>
 #include <stdlib.h>
@@ -251,19 +252,52 @@ static void test_close_all(void)
 /* Wrap test main function */
 
 static jmp_buf test_return;
+static FILE *orig_stderr;
 
 void test_exit(int rc)
 {
 	longjmp(test_return, rc + 1);
 }
 
+int test_ioctl(const struct cmd_expect *expect, void *cmd)
+{
+	int rc;
+
+	if (!expect->cmd || *(u32 *)cmd != *(const u32 *)expect->cmd) {
+		/* We have no idea how long this command structure is */
+		fprintf(orig_stderr, "Unexpected ioctl: cmd=%#10x\n",
+			*(u32 *)cmd);
+		return TEST_IOCTL_MISMATCH;
+	}
+
+	if (memcmp(cmd, expect->cmd, expect->cmd_len)) {
+		fprintf(orig_stderr, "Expected ioctl structure:\n");
+		dump_hex(orig_stderr, expect->cmd, expect->cmd_len, 0);
+		fprintf(orig_stderr, "Actual ioctl structure:\n");
+		dump_hex(orig_stderr, cmd, expect->cmd_len, 0);
+		return TEST_IOCTL_MISMATCH;
+	}
+
+	if (expect->resp)
+		memcpy(cmd, expect->resp, expect->resp_len);
+	rc = expect->rc;
+
+	/* Convert kernel return code according to libc convention */
+	if (rc >= 0) {
+		return rc;
+	} else {
+		errno = -rc;
+		return -1;
+	}
+}
+
 int test_cmdline(const char *args)
 {
 	int argc, i;
 	char **argv;
 	const char *arg;
 	size_t len;
-	int dev_null = -1, old_stdout = -1, old_stderr = -1;
+	int dev_null = -1, orig_stdout_fd = -1, orig_stderr_fd = -1;
 	int rc;
 
 	/* Convert line to argv */
@@ -298,20 +332,28 @@ int test_cmdline(const char *args)
 
 	fflush(NULL);
 	dup2(dev_null, STDIN_FILENO);
-	if (!getenv("TEST_TEST_VERBOSE")) {
-		old_stdout = dup(STDOUT_FILENO);
-		if (old_stdout < 0) {
+	if (getenv("TEST_TEST_VERBOSE")) {
+		orig_stderr = stderr;
+	} else {
+		orig_stdout_fd = dup(STDOUT_FILENO);
+		if (orig_stdout_fd < 0) {
 			perror("dup stdout");
 			rc = -1;
 			goto out;
 		}
 		dup2(dev_null, STDOUT_FILENO);
-		old_stderr = dup(STDERR_FILENO);
-		if (old_stderr < 0) {
+		orig_stderr_fd = dup(STDERR_FILENO);
+		if (orig_stderr_fd < 0) {
 			perror("dup stderr");
 			rc = -1;
 			goto out;
 		}
+		orig_stderr = fdopen(orig_stderr_fd, "w");
+		if (orig_stderr == NULL) {
+			perror("fdopen orig_stderr_fd");
+			rc = -1;
+			goto out;
+		}
 		dup2(dev_null, STDERR_FILENO);
 	}
 
@@ -320,13 +362,17 @@ int test_cmdline(const char *args)
 
 out:
 	fflush(NULL);
-	if (old_stderr >= 0) {
-		dup2(old_stderr, STDERR_FILENO);
-		close(old_stderr);
+	if (orig_stderr_fd >= 0) {
+		dup2(orig_stderr_fd, STDERR_FILENO);
+		if (orig_stderr)
+			fclose(orig_stderr);
+		else
+			close(orig_stderr_fd);
 	}
-	if (old_stdout >= 0) {
-		dup2(old_stdout, STDOUT_FILENO);
-		close(old_stdout);
+	orig_stderr = NULL;
+	if (orig_stdout_fd >= 0) {
+		dup2(orig_stdout_fd, STDOUT_FILENO);
+		close(orig_stdout_fd);
 	}
 	if (dev_null >= 0)
 		close(dev_null);
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
