From: Alexandru Copot <alex.mihai.c@gmail.com>
Subject: [PATCH 1/3 RFC v2] selftests: introduce testing abstractions
Date: Thu, 25 Apr 2013 14:04:58 +0300
Message-ID: <1366887900-24769-2-git-send-email-alex.mihai.c@gmail.com>
References: <1366887900-24769-1-git-send-email-alex.mihai.c@gmail.com>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, willemb@google.com, dborkman@redhat.com,
	ebiederm@xmission.com, gorcunov@openvz.org, palewis@adobe.com,
	edumazet@google.com, Alexandru Copot <alex.mihai.c@gmail.com>,
	Daniel Baluta <dbaluta@ixiacom.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f43.google.com ([209.85.214.43]:47887 "EHLO
	mail-bk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932107Ab3DYLFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 07:05:33 -0400
In-Reply-To: <1366887900-24769-1-git-send-email-alex.mihai.c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-of-by Alexandru Copot <alex.mihai.c@gmail.com>
Cc: Daniel Baluta <dbaluta@ixiacom.com>
---
 tools/testing/selftests/Makefile        |  3 +-
 tools/testing/selftests/lib/Makefile    | 14 +++++++
 tools/testing/selftests/lib/selftests.c | 57 ++++++++++++++++++++++++++++
 tools/testing/selftests/lib/selftests.h | 67 +++++++++++++++++++++++++++++++++
 4 files changed, 140 insertions(+), 1 deletion(-)
 create mode 100644 tools/testing/selftests/lib/Makefile
 create mode 100644 tools/testing/selftests/lib/selftests.c
 create mode 100644 tools/testing/selftests/lib/selftests.h

diff --git a/tools/testing/selftests/Makefile b/tools/testing/selftests/Makefile
index a480593..e0fccd9 100644
--- a/tools/testing/selftests/Makefile
+++ b/tools/testing/selftests/Makefile
@@ -1,4 +1,5 @@
-TARGETS = breakpoints
+TARGETS = lib
+TARGETS += breakpoints
 TARGETS += kcmp
 TARGETS += mqueue
 TARGETS += vm
diff --git a/tools/testing/selftests/lib/Makefile b/tools/testing/selftests/lib/Makefile
new file mode 100644
index 0000000..9c81d0c
--- /dev/null
+++ b/tools/testing/selftests/lib/Makefile
@@ -0,0 +1,14 @@
+
+CFLAGS = -Wall -O2 -c -g
+
+selftests.a: selftests.o
+	ar qc $@ $^
+
+%.c: %.h
+
+%.o: %.c
+	$(CC) $(CFLAGS) -o $@ $^
+
+clean:
+	rm -rf *.o *.a
+
diff --git a/tools/testing/selftests/lib/selftests.c b/tools/testing/selftests/lib/selftests.c
new file mode 100644
index 0000000..1a65785
--- /dev/null
+++ b/tools/testing/selftests/lib/selftests.c
@@ -0,0 +1,57 @@
+#include <stdio.h>
+#include <stdarg.h>
+
+#include "selftests.h"
+
+test_result_t __assert(int expr, const char *filename, int line, const char *fmt, ...)
+{
+	va_list vl;
+	const char *m;
+	char msg[BUFSIZ];
+
+	if (expr)
+		return TEST_PASS;
+
+	fprintf(stderr, "\n(%s:%d) ", filename, line);
+
+	va_start(vl, fmt);
+	m = va_arg(vl, char *);
+	if (!m)
+		m = fmt;
+	else
+		fprintf(stderr, "%s ", fmt);
+
+	vsnprintf(msg, sizeof msg, m, vl);
+	va_end(vl);
+
+	fprintf(stderr, "%s\n", msg);
+
+	return TEST_FAIL;
+}
+
+test_result_t run_all_tests(struct generic_test *test, void *param)
+{
+	int i;
+	char *ptr = test->testcases;
+	test_result_t rc = TEST_PASS;
+
+	rc = test->prepare ? test->prepare(param) : 0;
+	if (rc == TEST_FAIL)
+		return rc;
+
+	fprintf(stderr, "Testing: %s ", test->name);
+	for (i = 0; i < test->testcase_count; i++) {
+
+		rc |= test->run(ptr);
+		ptr += test->testcase_size;
+		
+		if (rc == TEST_FAIL && test->abort_on_fail) {
+			fprintf(stderr, "Test aborted\n");
+			break;
+		}
+	}
+
+	fprintf(stderr, "\t\t%s\n", rc ? "[FAIL]" : "[PASS]");
+	return rc;
+}
+
diff --git a/tools/testing/selftests/lib/selftests.h b/tools/testing/selftests/lib/selftests.h
new file mode 100644
index 0000000..6210199
--- /dev/null
+++ b/tools/testing/selftests/lib/selftests.h
@@ -0,0 +1,67 @@
+#ifndef SELFTESTS_H
+#define SELFTESTS_H
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <errno.h>
+
+typedef enum test_result {
+	TEST_PASS = 0,
+	TEST_FAIL,
+} test_result_t;
+
+test_result_t __assert(int expr, const char *filename, int line, const char *fmt, ...);
+
+#define abort(cond) do {							\
+	if (!(cond)) {								\
+		fprintf(stderr, "%s:%d %s\n", __FILE__, __LINE__, #cond);	\
+		perror("");							\
+		exit(EXIT_FAILURE);						\
+	}									\
+} while (0)
+
+#define pass_if(expr, label, ret)				\
+	do {                                                    \
+		if (expr) {					\
+			ret = TEST_PASS;			\
+			goto label;				\
+		}						\
+	} while (0)
+
+/* @expr:   a boolean expression
+ * @label:  jump here to free resources if it fails
+ * @ret:    a test_result_t variable that will hold the result of the test
+ *          This can be later returned from the test function.
+ */
+#define check(expr, label, ret, ...)					     \
+	do {                                                                 \
+		ret = __assert(expr, __FILE__, __LINE__,       		     \
+			       "Assertion '" #expr "' failed", __VA_ARGS__); \
+		if (!(expr)) {						     \
+			perror("");					     \
+			goto label;                                          \
+		}							     \
+	} while (0)
+
+struct generic_test {
+	const char *name;
+	void *private;
+
+
+	void *testcases;
+	int testcase_size;
+	int testcase_count;
+
+	/* Ends all tests if one fails */
+	int abort_on_fail;
+
+	test_result_t (*prepare)(void *);
+	test_result_t (*run)(void *);
+	test_result_t (*cleanup)(void *);
+};
+
+test_result_t run_all_tests(struct generic_test *test, void *param);
+
+#endif
+
+
-- 
1.8.2.1
