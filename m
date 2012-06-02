From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 1/7] Run tests in-process
Date: Sat, 2 Jun 2012 01:35:31 +0100
Message-ID: <1338597331.2770.14.camel@bwh-desktop.uk.solarflarecom.com>
References: <1338597227.2770.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Mahesh Bandewar <maheshb@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35775 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760247Ab2FBAff (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 20:35:35 -0400
In-Reply-To: <1338597227.2770.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wrap main(), exit(), and resource management so that ethtool commands
can be tested without starting a new process and without leaking.
This will allow deeper teesting that covers ioctl requests and
responses.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 .gitignore     |    1 -
 Makefile.am    |    6 +-
 ethtool.c      |    9 +-
 internal.h     |   42 ++++++++
 test-cmdline.c |    7 ++
 test-common.c  |  311 ++++++++++++++++++++++++++++++++++++++++++++++++++------
 6 files changed, 332 insertions(+), 44 deletions(-)

diff --git a/.gitignore b/.gitignore
index e10c4ef..62bf520 100644
--- a/.gitignore
+++ b/.gitignore
@@ -13,7 +13,6 @@ ethtool.spec
 ethtool.8
 ethtool
 test-cmdline
-test-one-cmdline
 stamp-h1
 config.*
 aclocal.m4
diff --git a/Makefile.am b/Makefile.am
index 789cd9a..d1aec43 100644
--- a/Makefile.am
+++ b/Makefile.am
@@ -12,11 +12,9 @@ ethtool_SOURCES = ethtool.c ethtool-copy.h internal.h net_tstamp-copy.h \
 		  rxclass.c sfpid.c
 
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
index f18f611..65bdd38 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3261,16 +3261,13 @@ static int do_getmodule(struct cmd_context *ctx)
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
 
 static int show_usage(struct cmd_context *ctx);
 
@@ -3451,7 +3448,7 @@ static int show_usage(struct cmd_context *ctx)
 	return 0;
 }
 
-int main(int argc, char **argp, char **envp)
+int main(int argc, char **argp)
 {
 	int (*func)(struct cmd_context *);
 	int want_device;
diff --git a/internal.h b/internal.h
index 55f0d8a..10abe25 100644
--- a/internal.h
+++ b/internal.h
@@ -6,7 +6,11 @@
 #ifdef HAVE_CONFIG_H
 #include "ethtool-config.h"
 #endif
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
 #include <sys/types.h>
+#include <unistd.h>
 #include <endian.h>
 #include <sys/ioctl.h>
 #include <net/if.h>
@@ -98,6 +102,44 @@ struct cmd_context {
 
 #ifdef TEST_ETHTOOL
 int test_cmdline(const char *args);
+
+#ifndef TEST_NO_WRAPPERS
+int test_main(int argc, char **argp);
+#define main(...) test_main(__VA_ARGS__)
+void test_exit(int rc) __attribute__((noreturn));
+#undef exit
+#define exit(rc) test_exit(rc)
+void *test_malloc(size_t size);
+#undef malloc
+#define malloc(size) test_malloc(size)
+void *test_calloc(size_t nmemb, size_t size);
+#undef calloc
+#define calloc(nmemb, size) test_calloc(nmemb, size)
+char *test_strdup(const char *s);
+#undef strdup
+#define strdup(s) test_strdup(s)
+void *test_free(void *ptr);
+#undef free
+#define free(ptr) test_free(ptr)
+void *test_realloc(void *ptr, size_t size);
+#undef realloc
+#define realloc(ptr, size) test_realloc(ptr, size)
+int test_open(const char *pathname, int flag, ...);
+#undef open
+#define open(...) test_open(__VA_ARGS__)
+int test_socket(int domain, int type, int protocol);
+#undef socket
+#define socket(...) test_socket(__VA_ARGS__)
+int test_close(int fd);
+#undef close
+#define close(fd) test_close(fd)
+FILE *test_fopen(const char *path, const char *mode);
+#undef fopen
+#define fopen(path, mode) test_fopen(path, mode)
+int test_fclose(FILE *fh);
+#undef fclose
+#define fclose(fh) test_fclose(fh)
+#endif
 #endif
 
 int send_ioctl(struct cmd_context *ctx, void *cmd);
diff --git a/test-cmdline.c b/test-cmdline.c
index c30b0e6..c62bb97 100644
--- a/test-cmdline.c
+++ b/test-cmdline.c
@@ -9,6 +9,7 @@
 
 #include <stdio.h>
 #include <stdlib.h>
+#define TEST_NO_WRAPPERS
 #include "internal.h"
 
 static struct test_case {
@@ -232,6 +233,12 @@ static struct test_case {
 	{ 1, "-0" },
 };
 
+int send_ioctl(struct cmd_context *ctx, void *cmd)
+{
+	/* If we get this far then parsing succeeded */
+	test_exit(0);
+}
+
 int main(void)
 {
 	struct test_case *tc;
diff --git a/test-common.c b/test-common.c
index 4ea84c8..69853aa 100644
--- a/test-common.c
+++ b/test-common.c
@@ -2,27 +2,268 @@
  * Common test functions for ethtool
  * Copyright 2011 Solarflare Communications Inc.
  *
+ * Partly derived from kernel <linux/list.h>.
+ *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
  * by the Free Software Foundation, incorporated herein by reference.
  */
 
+#include <assert.h>
+#include <setjmp.h>
+#include <stdarg.h>
 #include <stdlib.h>
 #include <string.h>
 #include <sys/fcntl.h>
-#include <sys/wait.h>
 #include <unistd.h>
+#define TEST_NO_WRAPPERS
 #include "internal.h"
 
+/* List utilities */
+
+struct list_head {
+	struct list_head *next, *prev;
+};
+
+#define LIST_HEAD_INIT(name) { &(name), &(name) }
+
+static void init_list_head(struct list_head *list)
+{
+	list->next = list;
+	list->prev = list;
+}
+
+static void list_add(struct list_head *new, struct list_head *head)
+{
+	head->next->prev = new;
+	new->next = head->next;
+	new->prev = head;
+	head->next = new;
+}
+
+static void list_del(struct list_head *entry)
+{
+	entry->next->prev = entry->prev;
+	entry->prev->next = entry->next;
+	entry->next = NULL;
+	entry->prev = NULL;
+}
+
+#define list_for_each_safe(pos, n, head) \
+	for (pos = (head)->next, n = pos->next; pos != (head); \
+		pos = n, n = pos->next)
+
+/* Free memory at end of test */
+
+static struct list_head malloc_list = LIST_HEAD_INIT(malloc_list);
+
+void *test_malloc(size_t size)
+{
+	struct list_head *block = malloc(sizeof(*block) + size);
+
+	if (!block)
+		return NULL;
+	list_add(block, &malloc_list);
+	return block + 1;
+}
+
+void *test_calloc(size_t nmemb, size_t size)
+{
+	void *ptr = test_malloc(nmemb * size);
+
+	if (ptr)
+		memset(ptr, 0, nmemb * size);
+	return ptr;
+}
+
+char *test_strdup(const char *s)
+{
+	size_t size = strlen(s) + 1;
+	char *dup = test_malloc(size);
+
+	if (dup)
+		memcpy(dup, s, size);
+	return dup;
+}
+
+void test_free(void *ptr)
+{
+	struct list_head *block;
+
+	if (!ptr)
+		return;
+	block = (struct list_head *)ptr - 1;
+	list_del(block);
+	free(block);
+}
+
+void *test_realloc(void *ptr, size_t size)
+{
+	struct list_head *block;
+
+	if (ptr) {
+		block = (struct list_head *)ptr - 1;
+		list_del(block);
+	}
+	block = realloc(block, sizeof(*block) + size);
+	if (!block)
+		return NULL;
+	list_add(block, &malloc_list);
+	return block + 1;
+}
+
+static void test_free_all(void)
+{
+	struct list_head *block, *next;
+
+	list_for_each_safe(block, next, &malloc_list)
+		free(block);
+	init_list_head(&malloc_list);
+}
+
+/* Close files at end of test */
+
+struct file_node {
+	struct list_head link;
+	FILE *fh;
+	int fd;
+};
+
+static struct list_head file_list = LIST_HEAD_INIT(file_list);
+
+int test_open(const char *pathname, int flag, ...)
+{
+	struct file_node *node;
+	mode_t mode;
+
+	if (flag & O_CREAT) {
+		va_list ap;
+		va_start(ap, flag);
+		mode = va_arg(ap, mode_t);
+		va_end(ap);
+	} else {
+		mode = 0;
+	}
+
+	node = malloc(sizeof(*node));
+	if (!node)
+		return -1;
+
+	node->fd = open(pathname, flag, mode);
+	if (node->fd < 0) {
+		free(node);
+		return -1;
+	}
+
+	node->fh = NULL;
+	list_add(&node->link, &file_list);
+	return node->fd;
+}
+
+int test_socket(int domain, int type, int protocol)
+{
+	struct file_node *node;
+
+	node = malloc(sizeof(*node));
+	if (!node)
+		return -1;
+
+	node->fd = socket(domain, type, protocol);
+	if (node->fd < 0) {
+		free(node);
+		return -1;
+	}
+
+	node->fh = NULL;
+	list_add(&node->link, &file_list);
+	return node->fd;
+}
+
+int test_close(int fd)
+{
+	struct list_head *head, *next;
+
+	if (fd >= 0) {
+		list_for_each_safe(head, next, &file_list) {
+			if (((struct file_node *)head)->fd == fd) {
+				list_del(head);
+				free(head);
+				break;
+			}
+		}
+	}
+
+	return close(fd);
+}
+
+FILE *test_fopen(const char *path, const char *mode)
+{
+	struct file_node *node;
+
+	node = malloc(sizeof(*node));
+	if (!node)
+		return NULL;
+
+	node->fh = fopen(path, mode);
+	if (!node->fh) {
+		free(node);
+		return NULL;
+	}
+
+	node->fd = -1;
+	list_add(&node->link, &file_list);
+	return node->fh;	
+}
+
+int test_fclose(FILE *fh)
+{
+	struct list_head *head, *next;
+
+	assert(fh);
+
+	list_for_each_safe(head, next, &file_list) {
+		if (((struct file_node *)head)->fh == fh) {
+			list_del(head);
+			free(head);
+			break;
+		}
+	}
+
+	return fclose(fh);
+}
+
+static void test_close_all(void)
+{
+	struct list_head *head, *next;
+	struct file_node *node;
+
+	list_for_each_safe(head, next, &file_list) {
+		node = (struct file_node *)head;
+		if (node->fh)
+			fclose(node->fh);
+		else
+			close(node->fd);
+		free(node);
+	}
+	init_list_head(&file_list);
+}
+
+/* Wrap test main function */
+
+static jmp_buf test_return;
+
+void test_exit(int rc)
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
@@ -37,12 +278,12 @@ int test_cmdline(const char *args)
 			break;
 		arg += len + 1;
 	}
-	argv = calloc(argc + 1, sizeof(argv[0]));
-	argv[0] = strdup("ethtool");
+	argv = test_calloc(argc + 1, sizeof(argv[0]));
+	argv[0] = test_strdup("ethtool");
 	arg = args;
 	for (i = 1; i < argc; i++) {
 		len = strcspn(arg, " ");
-		argv[i] = malloc(len + 1);
+		argv[i] = test_malloc(len + 1);
 		memcpy(argv[i], arg, len);
 		argv[i][len] = 0;
 		arg += len + 1;
@@ -56,37 +297,41 @@ int test_cmdline(const char *args)
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
+	if (!getenv("TEST_TEST_VERBOSE")) {
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
+	rc = setjmp(test_return);
+	rc = rc ? rc - 1 : test_main(argc, argv);
+
+out:
+	fflush(NULL);
+	if (old_stderr >= 0) {
+		dup2(old_stderr, STDERR_FILENO);
+		close(old_stderr);
 	}
-	close(dev_null);
-	if (waitpid(pid, &status, 0) < 0) {
-		perror("waitpid");
-		rc = -1;
-		goto out;
+	if (old_stdout >= 0) {
+		dup2(old_stdout, STDOUT_FILENO);
+		close(old_stdout);
 	}
-	rc = WIFEXITED(status) ? WEXITSTATUS(status) : -1;
+	if (dev_null >= 0)
+		close(dev_null);
 
-out:
-	for (i = 0; i < argc; i++)
-		free(argv[i]);
-	free(argv);
+	test_free_all();
+	test_close_all();
 	return rc;
 }
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
