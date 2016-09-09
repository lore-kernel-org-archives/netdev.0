From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH 4/9] selftests: move prctl tests from Documentation/prctl
Date: Fri,  9 Sep 2016 16:22:45 -0600
Message-ID: <06789bf107540c8ca15af60efb97b0f57ccca22d.1473458697.git.shuahkh@osg.samsung.com>
References: <cover.1473458697.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
To: corbet@lwn.net, richardcochran@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1473458697.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1473458697.git.shuahkh@osg.samsung.com>
References: <cover.1473458697.git.shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move prctl tests from Documentation/prctl to selftests/prctl.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 Documentation/prctl/.gitignore                     |  3 -
 Documentation/prctl/Makefile                       | 10 ---
 .../prctl/disable-tsc-ctxt-sw-stress-test.c        | 97 ----------------------
 .../prctl/disable-tsc-on-off-stress-test.c         | 96 ---------------------
 Documentation/prctl/disable-tsc-test.c             | 95 ---------------------
 tools/testing/selftests/prctl/.gitignore           |  3 +
 tools/testing/selftests/prctl/Makefile             | 10 +++
 .../prctl/disable-tsc-ctxt-sw-stress-test.c        | 97 ++++++++++++++++++++++
 .../prctl/disable-tsc-on-off-stress-test.c         | 96 +++++++++++++++++++++
 tools/testing/selftests/prctl/disable-tsc-test.c   | 95 +++++++++++++++++++++
 10 files changed, 301 insertions(+), 301 deletions(-)
 delete mode 100644 Documentation/prctl/.gitignore
 delete mode 100644 Documentation/prctl/Makefile
 delete mode 100644 Documentation/prctl/disable-tsc-ctxt-sw-stress-test.c
 delete mode 100644 Documentation/prctl/disable-tsc-on-off-stress-test.c
 delete mode 100644 Documentation/prctl/disable-tsc-test.c
 create mode 100644 tools/testing/selftests/prctl/.gitignore
 create mode 100644 tools/testing/selftests/prctl/Makefile
 create mode 100644 tools/testing/selftests/prctl/disable-tsc-ctxt-sw-stress-test.c
 create mode 100644 tools/testing/selftests/prctl/disable-tsc-on-off-stress-test.c
 create mode 100644 tools/testing/selftests/prctl/disable-tsc-test.c

diff --git a/Documentation/prctl/.gitignore b/Documentation/prctl/.gitignore
deleted file mode 100644
index 0b5c274..0000000
--- a/Documentation/prctl/.gitignore
+++ /dev/null
@@ -1,3 +0,0 @@
-disable-tsc-ctxt-sw-stress-test
-disable-tsc-on-off-stress-test
-disable-tsc-test
diff --git a/Documentation/prctl/Makefile b/Documentation/prctl/Makefile
deleted file mode 100644
index 44de308..0000000
--- a/Documentation/prctl/Makefile
+++ /dev/null
@@ -1,10 +0,0 @@
-ifndef CROSS_COMPILE
-# List of programs to build
-hostprogs-$(CONFIG_X86) := disable-tsc-ctxt-sw-stress-test disable-tsc-on-off-stress-test disable-tsc-test
-# Tell kbuild to always build the programs
-always := $(hostprogs-y)
-
-HOSTCFLAGS_disable-tsc-ctxt-sw-stress-test.o += -I$(objtree)/usr/include
-HOSTCFLAGS_disable-tsc-on-off-stress-test.o += -I$(objtree)/usr/include
-HOSTCFLAGS_disable-tsc-test.o += -I$(objtree)/usr/include
-endif
diff --git a/Documentation/prctl/disable-tsc-ctxt-sw-stress-test.c b/Documentation/prctl/disable-tsc-ctxt-sw-stress-test.c
deleted file mode 100644
index f7499d1..0000000
--- a/Documentation/prctl/disable-tsc-ctxt-sw-stress-test.c
+++ /dev/null
@@ -1,97 +0,0 @@
-/*
- * Tests for prctl(PR_GET_TSC, ...) / prctl(PR_SET_TSC, ...)
- *
- * Tests if the control register is updated correctly
- * at context switches
- *
- * Warning: this test will cause a very high load for a few seconds
- *
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <signal.h>
-#include <inttypes.h>
-#include <wait.h>
-
-
-#include <sys/prctl.h>
-#include <linux/prctl.h>
-
-/* Get/set the process' ability to use the timestamp counter instruction */
-#ifndef PR_GET_TSC
-#define PR_GET_TSC 25
-#define PR_SET_TSC 26
-# define PR_TSC_ENABLE		1   /* allow the use of the timestamp counter */
-# define PR_TSC_SIGSEGV		2   /* throw a SIGSEGV instead of reading the TSC */
-#endif
-
-static uint64_t rdtsc(void)
-{
-uint32_t lo, hi;
-/* We cannot use "=A", since this would use %rax on x86_64 */
-__asm__ __volatile__ ("rdtsc" : "=a" (lo), "=d" (hi));
-return (uint64_t)hi << 32 | lo;
-}
-
-static void sigsegv_expect(int sig)
-{
-	/* */
-}
-
-static void segvtask(void)
-{
-	if (prctl(PR_SET_TSC, PR_TSC_SIGSEGV) < 0)
-	{
-		perror("prctl");
-		exit(0);
-	}
-	signal(SIGSEGV, sigsegv_expect);
-	alarm(10);
-	rdtsc();
-	fprintf(stderr, "FATAL ERROR, rdtsc() succeeded while disabled\n");
-	exit(0);
-}
-
-
-static void sigsegv_fail(int sig)
-{
-	fprintf(stderr, "FATAL ERROR, rdtsc() failed while enabled\n");
-	exit(0);
-}
-
-static void rdtsctask(void)
-{
-	if (prctl(PR_SET_TSC, PR_TSC_ENABLE) < 0)
-	{
-		perror("prctl");
-		exit(0);
-	}
-	signal(SIGSEGV, sigsegv_fail);
-	alarm(10);
-	for(;;) rdtsc();
-}
-
-
-int main(void)
-{
-	int n_tasks = 100, i;
-
-	fprintf(stderr, "[No further output means we're allright]\n");
-
-	for (i=0; i<n_tasks; i++)
-		if (fork() == 0)
-		{
-			if (i & 1)
-				segvtask();
-			else
-				rdtsctask();
-		}
-
-	for (i=0; i<n_tasks; i++)
-		wait(NULL);
-
-	exit(0);
-}
-
diff --git a/Documentation/prctl/disable-tsc-on-off-stress-test.c b/Documentation/prctl/disable-tsc-on-off-stress-test.c
deleted file mode 100644
index a06f027..0000000
--- a/Documentation/prctl/disable-tsc-on-off-stress-test.c
+++ /dev/null
@@ -1,96 +0,0 @@
-/*
- * Tests for prctl(PR_GET_TSC, ...) / prctl(PR_SET_TSC, ...)
- *
- * Tests if the control register is updated correctly
- * when set with prctl()
- *
- * Warning: this test will cause a very high load for a few seconds
- *
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <signal.h>
-#include <inttypes.h>
-#include <wait.h>
-
-
-#include <sys/prctl.h>
-#include <linux/prctl.h>
-
-/* Get/set the process' ability to use the timestamp counter instruction */
-#ifndef PR_GET_TSC
-#define PR_GET_TSC 25
-#define PR_SET_TSC 26
-# define PR_TSC_ENABLE		1   /* allow the use of the timestamp counter */
-# define PR_TSC_SIGSEGV		2   /* throw a SIGSEGV instead of reading the TSC */
-#endif
-
-/* snippet from wikipedia :-) */
-
-static uint64_t rdtsc(void)
-{
-uint32_t lo, hi;
-/* We cannot use "=A", since this would use %rax on x86_64 */
-__asm__ __volatile__ ("rdtsc" : "=a" (lo), "=d" (hi));
-return (uint64_t)hi << 32 | lo;
-}
-
-int should_segv = 0;
-
-static void sigsegv_cb(int sig)
-{
-	if (!should_segv)
-	{
-		fprintf(stderr, "FATAL ERROR, rdtsc() failed while enabled\n");
-		exit(0);
-	}
-	if (prctl(PR_SET_TSC, PR_TSC_ENABLE) < 0)
-	{
-		perror("prctl");
-		exit(0);
-	}
-	should_segv = 0;
-
-	rdtsc();
-}
-
-static void task(void)
-{
-	signal(SIGSEGV, sigsegv_cb);
-	alarm(10);
-	for(;;)
-	{
-		rdtsc();
-		if (should_segv)
-		{
-			fprintf(stderr, "FATAL ERROR, rdtsc() succeeded while disabled\n");
-			exit(0);
-		}
-		if (prctl(PR_SET_TSC, PR_TSC_SIGSEGV) < 0)
-		{
-			perror("prctl");
-			exit(0);
-		}
-		should_segv = 1;
-	}
-}
-
-
-int main(void)
-{
-	int n_tasks = 100, i;
-
-	fprintf(stderr, "[No further output means we're allright]\n");
-
-	for (i=0; i<n_tasks; i++)
-		if (fork() == 0)
-			task();
-
-	for (i=0; i<n_tasks; i++)
-		wait(NULL);
-
-	exit(0);
-}
-
diff --git a/Documentation/prctl/disable-tsc-test.c b/Documentation/prctl/disable-tsc-test.c
deleted file mode 100644
index 8d494f7..0000000
--- a/Documentation/prctl/disable-tsc-test.c
+++ /dev/null
@@ -1,95 +0,0 @@
-/*
- * Tests for prctl(PR_GET_TSC, ...) / prctl(PR_SET_TSC, ...)
- *
- * Basic test to test behaviour of PR_GET_TSC and PR_SET_TSC
- */
-
-#include <stdio.h>
-#include <stdlib.h>
-#include <unistd.h>
-#include <signal.h>
-#include <inttypes.h>
-
-
-#include <sys/prctl.h>
-#include <linux/prctl.h>
-
-/* Get/set the process' ability to use the timestamp counter instruction */
-#ifndef PR_GET_TSC
-#define PR_GET_TSC 25
-#define PR_SET_TSC 26
-# define PR_TSC_ENABLE		1   /* allow the use of the timestamp counter */
-# define PR_TSC_SIGSEGV		2   /* throw a SIGSEGV instead of reading the TSC */
-#endif
-
-const char *tsc_names[] =
-{
-	[0] = "[not set]",
-	[PR_TSC_ENABLE] = "PR_TSC_ENABLE",
-	[PR_TSC_SIGSEGV] = "PR_TSC_SIGSEGV",
-};
-
-static uint64_t rdtsc(void)
-{
-uint32_t lo, hi;
-/* We cannot use "=A", since this would use %rax on x86_64 */
-__asm__ __volatile__ ("rdtsc" : "=a" (lo), "=d" (hi));
-return (uint64_t)hi << 32 | lo;
-}
-
-static void sigsegv_cb(int sig)
-{
-	int tsc_val = 0;
-
-	printf("[ SIG_SEGV ]\n");
-	printf("prctl(PR_GET_TSC, &tsc_val); ");
-	fflush(stdout);
-
-	if ( prctl(PR_GET_TSC, &tsc_val) == -1)
-		perror("prctl");
-
-	printf("tsc_val == %s\n", tsc_names[tsc_val]);
-	printf("prctl(PR_SET_TSC, PR_TSC_ENABLE)\n");
-	fflush(stdout);
-	if ( prctl(PR_SET_TSC, PR_TSC_ENABLE) == -1)
-		perror("prctl");
-
-	printf("rdtsc() == ");
-}
-
-int main(void)
-{
-	int tsc_val = 0;
-
-	signal(SIGSEGV, sigsegv_cb);
-
-	printf("rdtsc() == %llu\n", (unsigned long long)rdtsc());
-	printf("prctl(PR_GET_TSC, &tsc_val); ");
-	fflush(stdout);
-
-	if ( prctl(PR_GET_TSC, &tsc_val) == -1)
-		perror("prctl");
-
-	printf("tsc_val == %s\n", tsc_names[tsc_val]);
-	printf("rdtsc() == %llu\n", (unsigned long long)rdtsc());
-	printf("prctl(PR_SET_TSC, PR_TSC_ENABLE)\n");
-	fflush(stdout);
-
-	if ( prctl(PR_SET_TSC, PR_TSC_ENABLE) == -1)
-		perror("prctl");
-
-	printf("rdtsc() == %llu\n", (unsigned long long)rdtsc());
-	printf("prctl(PR_SET_TSC, PR_TSC_SIGSEGV)\n");
-	fflush(stdout);
-
-	if ( prctl(PR_SET_TSC, PR_TSC_SIGSEGV) == -1)
-		perror("prctl");
-
-	printf("rdtsc() == ");
-	fflush(stdout);
-	printf("%llu\n", (unsigned long long)rdtsc());
-	fflush(stdout);
-
-	exit(EXIT_SUCCESS);
-}
-
diff --git a/tools/testing/selftests/prctl/.gitignore b/tools/testing/selftests/prctl/.gitignore
new file mode 100644
index 0000000..0b5c274
--- /dev/null
+++ b/tools/testing/selftests/prctl/.gitignore
@@ -0,0 +1,3 @@
+disable-tsc-ctxt-sw-stress-test
+disable-tsc-on-off-stress-test
+disable-tsc-test
diff --git a/tools/testing/selftests/prctl/Makefile b/tools/testing/selftests/prctl/Makefile
new file mode 100644
index 0000000..44de308
--- /dev/null
+++ b/tools/testing/selftests/prctl/Makefile
@@ -0,0 +1,10 @@
+ifndef CROSS_COMPILE
+# List of programs to build
+hostprogs-$(CONFIG_X86) := disable-tsc-ctxt-sw-stress-test disable-tsc-on-off-stress-test disable-tsc-test
+# Tell kbuild to always build the programs
+always := $(hostprogs-y)
+
+HOSTCFLAGS_disable-tsc-ctxt-sw-stress-test.o += -I$(objtree)/usr/include
+HOSTCFLAGS_disable-tsc-on-off-stress-test.o += -I$(objtree)/usr/include
+HOSTCFLAGS_disable-tsc-test.o += -I$(objtree)/usr/include
+endif
diff --git a/tools/testing/selftests/prctl/disable-tsc-ctxt-sw-stress-test.c b/tools/testing/selftests/prctl/disable-tsc-ctxt-sw-stress-test.c
new file mode 100644
index 0000000..f7499d1
--- /dev/null
+++ b/tools/testing/selftests/prctl/disable-tsc-ctxt-sw-stress-test.c
@@ -0,0 +1,97 @@
+/*
+ * Tests for prctl(PR_GET_TSC, ...) / prctl(PR_SET_TSC, ...)
+ *
+ * Tests if the control register is updated correctly
+ * at context switches
+ *
+ * Warning: this test will cause a very high load for a few seconds
+ *
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <signal.h>
+#include <inttypes.h>
+#include <wait.h>
+
+
+#include <sys/prctl.h>
+#include <linux/prctl.h>
+
+/* Get/set the process' ability to use the timestamp counter instruction */
+#ifndef PR_GET_TSC
+#define PR_GET_TSC 25
+#define PR_SET_TSC 26
+# define PR_TSC_ENABLE		1   /* allow the use of the timestamp counter */
+# define PR_TSC_SIGSEGV		2   /* throw a SIGSEGV instead of reading the TSC */
+#endif
+
+static uint64_t rdtsc(void)
+{
+uint32_t lo, hi;
+/* We cannot use "=A", since this would use %rax on x86_64 */
+__asm__ __volatile__ ("rdtsc" : "=a" (lo), "=d" (hi));
+return (uint64_t)hi << 32 | lo;
+}
+
+static void sigsegv_expect(int sig)
+{
+	/* */
+}
+
+static void segvtask(void)
+{
+	if (prctl(PR_SET_TSC, PR_TSC_SIGSEGV) < 0)
+	{
+		perror("prctl");
+		exit(0);
+	}
+	signal(SIGSEGV, sigsegv_expect);
+	alarm(10);
+	rdtsc();
+	fprintf(stderr, "FATAL ERROR, rdtsc() succeeded while disabled\n");
+	exit(0);
+}
+
+
+static void sigsegv_fail(int sig)
+{
+	fprintf(stderr, "FATAL ERROR, rdtsc() failed while enabled\n");
+	exit(0);
+}
+
+static void rdtsctask(void)
+{
+	if (prctl(PR_SET_TSC, PR_TSC_ENABLE) < 0)
+	{
+		perror("prctl");
+		exit(0);
+	}
+	signal(SIGSEGV, sigsegv_fail);
+	alarm(10);
+	for(;;) rdtsc();
+}
+
+
+int main(void)
+{
+	int n_tasks = 100, i;
+
+	fprintf(stderr, "[No further output means we're allright]\n");
+
+	for (i=0; i<n_tasks; i++)
+		if (fork() == 0)
+		{
+			if (i & 1)
+				segvtask();
+			else
+				rdtsctask();
+		}
+
+	for (i=0; i<n_tasks; i++)
+		wait(NULL);
+
+	exit(0);
+}
+
diff --git a/tools/testing/selftests/prctl/disable-tsc-on-off-stress-test.c b/tools/testing/selftests/prctl/disable-tsc-on-off-stress-test.c
new file mode 100644
index 0000000..a06f027
--- /dev/null
+++ b/tools/testing/selftests/prctl/disable-tsc-on-off-stress-test.c
@@ -0,0 +1,96 @@
+/*
+ * Tests for prctl(PR_GET_TSC, ...) / prctl(PR_SET_TSC, ...)
+ *
+ * Tests if the control register is updated correctly
+ * when set with prctl()
+ *
+ * Warning: this test will cause a very high load for a few seconds
+ *
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <signal.h>
+#include <inttypes.h>
+#include <wait.h>
+
+
+#include <sys/prctl.h>
+#include <linux/prctl.h>
+
+/* Get/set the process' ability to use the timestamp counter instruction */
+#ifndef PR_GET_TSC
+#define PR_GET_TSC 25
+#define PR_SET_TSC 26
+# define PR_TSC_ENABLE		1   /* allow the use of the timestamp counter */
+# define PR_TSC_SIGSEGV		2   /* throw a SIGSEGV instead of reading the TSC */
+#endif
+
+/* snippet from wikipedia :-) */
+
+static uint64_t rdtsc(void)
+{
+uint32_t lo, hi;
+/* We cannot use "=A", since this would use %rax on x86_64 */
+__asm__ __volatile__ ("rdtsc" : "=a" (lo), "=d" (hi));
+return (uint64_t)hi << 32 | lo;
+}
+
+int should_segv = 0;
+
+static void sigsegv_cb(int sig)
+{
+	if (!should_segv)
+	{
+		fprintf(stderr, "FATAL ERROR, rdtsc() failed while enabled\n");
+		exit(0);
+	}
+	if (prctl(PR_SET_TSC, PR_TSC_ENABLE) < 0)
+	{
+		perror("prctl");
+		exit(0);
+	}
+	should_segv = 0;
+
+	rdtsc();
+}
+
+static void task(void)
+{
+	signal(SIGSEGV, sigsegv_cb);
+	alarm(10);
+	for(;;)
+	{
+		rdtsc();
+		if (should_segv)
+		{
+			fprintf(stderr, "FATAL ERROR, rdtsc() succeeded while disabled\n");
+			exit(0);
+		}
+		if (prctl(PR_SET_TSC, PR_TSC_SIGSEGV) < 0)
+		{
+			perror("prctl");
+			exit(0);
+		}
+		should_segv = 1;
+	}
+}
+
+
+int main(void)
+{
+	int n_tasks = 100, i;
+
+	fprintf(stderr, "[No further output means we're allright]\n");
+
+	for (i=0; i<n_tasks; i++)
+		if (fork() == 0)
+			task();
+
+	for (i=0; i<n_tasks; i++)
+		wait(NULL);
+
+	exit(0);
+}
+
diff --git a/tools/testing/selftests/prctl/disable-tsc-test.c b/tools/testing/selftests/prctl/disable-tsc-test.c
new file mode 100644
index 0000000..8d494f7
--- /dev/null
+++ b/tools/testing/selftests/prctl/disable-tsc-test.c
@@ -0,0 +1,95 @@
+/*
+ * Tests for prctl(PR_GET_TSC, ...) / prctl(PR_SET_TSC, ...)
+ *
+ * Basic test to test behaviour of PR_GET_TSC and PR_SET_TSC
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <signal.h>
+#include <inttypes.h>
+
+
+#include <sys/prctl.h>
+#include <linux/prctl.h>
+
+/* Get/set the process' ability to use the timestamp counter instruction */
+#ifndef PR_GET_TSC
+#define PR_GET_TSC 25
+#define PR_SET_TSC 26
+# define PR_TSC_ENABLE		1   /* allow the use of the timestamp counter */
+# define PR_TSC_SIGSEGV		2   /* throw a SIGSEGV instead of reading the TSC */
+#endif
+
+const char *tsc_names[] =
+{
+	[0] = "[not set]",
+	[PR_TSC_ENABLE] = "PR_TSC_ENABLE",
+	[PR_TSC_SIGSEGV] = "PR_TSC_SIGSEGV",
+};
+
+static uint64_t rdtsc(void)
+{
+uint32_t lo, hi;
+/* We cannot use "=A", since this would use %rax on x86_64 */
+__asm__ __volatile__ ("rdtsc" : "=a" (lo), "=d" (hi));
+return (uint64_t)hi << 32 | lo;
+}
+
+static void sigsegv_cb(int sig)
+{
+	int tsc_val = 0;
+
+	printf("[ SIG_SEGV ]\n");
+	printf("prctl(PR_GET_TSC, &tsc_val); ");
+	fflush(stdout);
+
+	if ( prctl(PR_GET_TSC, &tsc_val) == -1)
+		perror("prctl");
+
+	printf("tsc_val == %s\n", tsc_names[tsc_val]);
+	printf("prctl(PR_SET_TSC, PR_TSC_ENABLE)\n");
+	fflush(stdout);
+	if ( prctl(PR_SET_TSC, PR_TSC_ENABLE) == -1)
+		perror("prctl");
+
+	printf("rdtsc() == ");
+}
+
+int main(void)
+{
+	int tsc_val = 0;
+
+	signal(SIGSEGV, sigsegv_cb);
+
+	printf("rdtsc() == %llu\n", (unsigned long long)rdtsc());
+	printf("prctl(PR_GET_TSC, &tsc_val); ");
+	fflush(stdout);
+
+	if ( prctl(PR_GET_TSC, &tsc_val) == -1)
+		perror("prctl");
+
+	printf("tsc_val == %s\n", tsc_names[tsc_val]);
+	printf("rdtsc() == %llu\n", (unsigned long long)rdtsc());
+	printf("prctl(PR_SET_TSC, PR_TSC_ENABLE)\n");
+	fflush(stdout);
+
+	if ( prctl(PR_SET_TSC, PR_TSC_ENABLE) == -1)
+		perror("prctl");
+
+	printf("rdtsc() == %llu\n", (unsigned long long)rdtsc());
+	printf("prctl(PR_SET_TSC, PR_TSC_SIGSEGV)\n");
+	fflush(stdout);
+
+	if ( prctl(PR_SET_TSC, PR_TSC_SIGSEGV) == -1)
+		perror("prctl");
+
+	printf("rdtsc() == ");
+	fflush(stdout);
+	printf("%llu\n", (unsigned long long)rdtsc());
+	fflush(stdout);
+
+	exit(EXIT_SUCCESS);
+}
+
-- 
2.7.4
