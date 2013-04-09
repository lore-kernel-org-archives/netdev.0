From: Alexandru Copot <alex.mihai.c@gmail.com>
Subject: [PATCH 1/3 net-next RFC] selftest: add abstractions for net selftests
Date: Tue,  9 Apr 2013 13:30:59 +0300
Message-ID: <1365503461-26309-2-git-send-email-alex.mihai.c@gmail.com>
References: <1365503461-26309-1-git-send-email-alex.mihai.c@gmail.com>
Cc: willemb@google.com, dborkman@redhat.com, edumazet@google.com,
	Alexandru Copot <alex.mihai.c@gmail.com>,
	Daniel Baluta <dbaluta@ixiacom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f50.google.com ([209.85.214.50]:38626 "EHLO
	mail-bk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936614Ab3DIKdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Apr 2013 06:33:04 -0400
Received: by mail-bk0-f50.google.com with SMTP id jg1so3504163bkc.9
        for <netdev@vger.kernel.org>; Tue, 09 Apr 2013 03:33:02 -0700 (PDT)
In-Reply-To: <1365503461-26309-1-git-send-email-alex.mihai.c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-of by Alexandru Copot <alex.mihai.c@gmail.com>
Cc: Daniel Baluta <dbaluta@ixiacom.com>
---
 tools/testing/selftests/net/selftests.c | 30 +++++++++++++++++++++++
 tools/testing/selftests/net/selftests.h | 42 +++++++++++++++++++++++++++++++++
 2 files changed, 72 insertions(+)
 create mode 100644 tools/testing/selftests/net/selftests.c
 create mode 100644 tools/testing/selftests/net/selftests.h

diff --git a/tools/testing/selftests/net/selftests.c b/tools/testing/selftests/net/selftests.c
new file mode 100644
index 0000000..cd6e427
--- /dev/null
+++ b/tools/testing/selftests/net/selftests.c
@@ -0,0 +1,30 @@
+#include <stdio.h>
+
+#include "selftests.h"
+
+int run_all_tests(struct generic_test *test, void *param)
+{
+	int i;
+	int rc, allrc;
+	char *ptr;
+
+	rc = test->prepare ? test->prepare(param) : 0;
+	if (rc)
+		return rc;
+
+	allrc = 0;
+	printf("Testing: %s ", test->name);
+	ptr = test->testcases;
+	for (i = 0; i < test->testcase_count; i++) {
+		rc = test->run(ptr);
+		allrc |= rc;
+
+		if (test->abort_on_fail && rc) {
+			printf("Testcase %d failed, aborting\n", i);
+		}
+
+		ptr += test->testcase_size;
+	}
+	printf("\t\t%s\n", allrc ? "[FAIL]" : "[PASS]");
+	return allrc;
+}
diff --git a/tools/testing/selftests/net/selftests.h b/tools/testing/selftests/net/selftests.h
new file mode 100644
index 0000000..e289f03
--- /dev/null
+++ b/tools/testing/selftests/net/selftests.h
@@ -0,0 +1,42 @@
+#ifndef SELFTESTS_H
+#define SELFTESTS_H
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <errno.h>
+
+#define ASSERT(cond) do {								\
+	if (!(cond))     {								\
+			fprintf(stderr, "%s:%d %s\n", __FILE__, __LINE__, #cond);	\
+			perror("");							\
+			exit(EXIT_FAILURE);						\
+		}									\
+} while (0)
+
+#define CHECK(cond,fmt,...)			        \
+	do {						\
+		if (!(cond)) {                          \
+			fprintf(stderr, "(%s, %d): " fmt,	\
+					__FILE__, __LINE__, ##__VA_ARGS__); \
+			perror("");              	\
+			return 1;			\
+		}					\
+	} while (0)
+
+struct generic_test {
+	const char *name;
+	void *testcases;
+	int testcase_size;
+	int testcase_count;
+
+	int abort_on_fail;
+
+	int (*prepare)(void *);
+	int (*run)(void *);
+	int (*cleanup)(void *);
+};
+
+int run_all_tests(struct generic_test *test, void *param);
+
+#endif
+
-- 
1.8.2
