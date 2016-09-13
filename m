From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v2 6/6] selftests: move watchdog tests from Documentation/watchdog
Date: Tue, 13 Sep 2016 14:18:45 -0600
Message-ID: <328de4c08ef23fe13cec88b45e3e1725cfc5c33b.1473795601.git.shuahkh@osg.samsung.com>
References: <cover.1473795601.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-watchdog@vger.kernel.org, linux-kselftest@vger.kernel.org
To: corbet@lwn.net, richardcochran@gmail.com, wim@iguana.be,
        linux@roeck-us.net, nab@linux-iscsi.org,
        maheshkhanwalkar@gmail.com, timur@codeaurora.org, arnd@arndb.de,
        ghackmann@google.com, ben@decadent.org.uk, thuth@redhat.com,
        christopher.s.hall@intel.com, john.stultz@linaro.org,
        sergei.shtylyov@cogentembedded.com, mpe@ellerman.id.au,
        jani.nikula@linux.intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1473795601.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1473795601.git.shuahkh@osg.samsung.com>
References: <cover.1473795601.git.shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove watchdog-test from Makefile to move the test to selftests.

Add Makefile and .gitignore to for watchdog-test. watchdog-test will
not be run as part of selftests suite and will not be included in
install targets.  It can be built separately for now.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 Documentation/watchdog/src/.gitignore            |   1 -
 Documentation/watchdog/src/Makefile              |   2 +-
 Documentation/watchdog/src/watchdog-test.c       | 105 -----------------------
 tools/testing/selftests/watchdog/.gitignore      |   1 +
 tools/testing/selftests/watchdog/Makefile        |   8 ++
 tools/testing/selftests/watchdog/watchdog-test.c | 105 +++++++++++++++++++++++
 6 files changed, 115 insertions(+), 107 deletions(-)
 delete mode 100644 Documentation/watchdog/src/watchdog-test.c
 create mode 100644 tools/testing/selftests/watchdog/.gitignore
 create mode 100644 tools/testing/selftests/watchdog/Makefile
 create mode 100644 tools/testing/selftests/watchdog/watchdog-test.c

diff --git a/Documentation/watchdog/src/.gitignore b/Documentation/watchdog/src/.gitignore
index ac90997..ff0ebb5 100644
--- a/Documentation/watchdog/src/.gitignore
+++ b/Documentation/watchdog/src/.gitignore
@@ -1,2 +1 @@
 watchdog-simple
-watchdog-test
diff --git a/Documentation/watchdog/src/Makefile b/Documentation/watchdog/src/Makefile
index 4a892c3..47be791 100644
--- a/Documentation/watchdog/src/Makefile
+++ b/Documentation/watchdog/src/Makefile
@@ -1,5 +1,5 @@
 # List of programs to build
-hostprogs-y := watchdog-simple watchdog-test
+hostprogs-y := watchdog-simple
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
diff --git a/Documentation/watchdog/src/watchdog-test.c b/Documentation/watchdog/src/watchdog-test.c
deleted file mode 100644
index 6983d05..0000000
--- a/Documentation/watchdog/src/watchdog-test.c
+++ /dev/null
@@ -1,105 +0,0 @@
-/*
- * Watchdog Driver Test Program
- */
-
-#include <errno.h>
-#include <stdio.h>
-#include <stdlib.h>
-#include <string.h>
-#include <unistd.h>
-#include <fcntl.h>
-#include <signal.h>
-#include <sys/ioctl.h>
-#include <linux/types.h>
-#include <linux/watchdog.h>
-
-int fd;
-const char v = 'V';
-
-/*
- * This function simply sends an IOCTL to the driver, which in turn ticks
- * the PC Watchdog card to reset its internal timer so it doesn't trigger
- * a computer reset.
- */
-static void keep_alive(void)
-{
-    int dummy;
-
-    printf(".");
-    ioctl(fd, WDIOC_KEEPALIVE, &dummy);
-}
-
-/*
- * The main program.  Run the program with "-d" to disable the card,
- * or "-e" to enable the card.
- */
-
-static void term(int sig)
-{
-    int ret = write(fd, &v, 1);
-
-    close(fd);
-    if (ret < 0)
-	printf("\nStopping watchdog ticks failed (%d)...\n", errno);
-    else
-	printf("\nStopping watchdog ticks...\n");
-    exit(0);
-}
-
-int main(int argc, char *argv[])
-{
-    int flags;
-    unsigned int ping_rate = 1;
-    int ret;
-
-    setbuf(stdout, NULL);
-
-    fd = open("/dev/watchdog", O_WRONLY);
-
-    if (fd == -1) {
-	printf("Watchdog device not enabled.\n");
-	exit(-1);
-    }
-
-    if (argc > 1) {
-	if (!strncasecmp(argv[1], "-d", 2)) {
-	    flags = WDIOS_DISABLECARD;
-	    ioctl(fd, WDIOC_SETOPTIONS, &flags);
-	    printf("Watchdog card disabled.\n");
-	    goto end;
-	} else if (!strncasecmp(argv[1], "-e", 2)) {
-	    flags = WDIOS_ENABLECARD;
-	    ioctl(fd, WDIOC_SETOPTIONS, &flags);
-	    printf("Watchdog card enabled.\n");
-	    goto end;
-	} else if (!strncasecmp(argv[1], "-t", 2) && argv[2]) {
-	    flags = atoi(argv[2]);
-	    ioctl(fd, WDIOC_SETTIMEOUT, &flags);
-	    printf("Watchdog timeout set to %u seconds.\n", flags);
-	    goto end;
-	} else if (!strncasecmp(argv[1], "-p", 2) && argv[2]) {
-	    ping_rate = strtoul(argv[2], NULL, 0);
-	    printf("Watchdog ping rate set to %u seconds.\n", ping_rate);
-	} else {
-	    printf("-d to disable, -e to enable, -t <n> to set " \
-		"the timeout,\n-p <n> to set the ping rate, and \n");
-	    printf("run by itself to tick the card.\n");
-	    goto end;
-	}
-    }
-
-    printf("Watchdog Ticking Away!\n");
-
-    signal(SIGINT, term);
-
-    while(1) {
-	keep_alive();
-	sleep(ping_rate);
-    }
-end:
-    ret = write(fd, &v, 1);
-    if (ret < 0)
-	printf("Stopping watchdog ticks failed (%d)...\n", errno);
-    close(fd);
-    return 0;
-}
diff --git a/tools/testing/selftests/watchdog/.gitignore b/tools/testing/selftests/watchdog/.gitignore
new file mode 100644
index 0000000..5aac515
--- /dev/null
+++ b/tools/testing/selftests/watchdog/.gitignore
@@ -0,0 +1 @@
+watchdog-test
diff --git a/tools/testing/selftests/watchdog/Makefile b/tools/testing/selftests/watchdog/Makefile
new file mode 100644
index 0000000..f863c66
--- /dev/null
+++ b/tools/testing/selftests/watchdog/Makefile
@@ -0,0 +1,8 @@
+TEST_PROGS := watchdog-test
+
+all: $(TEST_PROGS)
+
+include ../lib.mk
+
+clean:
+	rm -fr $(TEST_PROGS)
diff --git a/tools/testing/selftests/watchdog/watchdog-test.c b/tools/testing/selftests/watchdog/watchdog-test.c
new file mode 100644
index 0000000..6983d05
--- /dev/null
+++ b/tools/testing/selftests/watchdog/watchdog-test.c
@@ -0,0 +1,105 @@
+/*
+ * Watchdog Driver Test Program
+ */
+
+#include <errno.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <unistd.h>
+#include <fcntl.h>
+#include <signal.h>
+#include <sys/ioctl.h>
+#include <linux/types.h>
+#include <linux/watchdog.h>
+
+int fd;
+const char v = 'V';
+
+/*
+ * This function simply sends an IOCTL to the driver, which in turn ticks
+ * the PC Watchdog card to reset its internal timer so it doesn't trigger
+ * a computer reset.
+ */
+static void keep_alive(void)
+{
+    int dummy;
+
+    printf(".");
+    ioctl(fd, WDIOC_KEEPALIVE, &dummy);
+}
+
+/*
+ * The main program.  Run the program with "-d" to disable the card,
+ * or "-e" to enable the card.
+ */
+
+static void term(int sig)
+{
+    int ret = write(fd, &v, 1);
+
+    close(fd);
+    if (ret < 0)
+	printf("\nStopping watchdog ticks failed (%d)...\n", errno);
+    else
+	printf("\nStopping watchdog ticks...\n");
+    exit(0);
+}
+
+int main(int argc, char *argv[])
+{
+    int flags;
+    unsigned int ping_rate = 1;
+    int ret;
+
+    setbuf(stdout, NULL);
+
+    fd = open("/dev/watchdog", O_WRONLY);
+
+    if (fd == -1) {
+	printf("Watchdog device not enabled.\n");
+	exit(-1);
+    }
+
+    if (argc > 1) {
+	if (!strncasecmp(argv[1], "-d", 2)) {
+	    flags = WDIOS_DISABLECARD;
+	    ioctl(fd, WDIOC_SETOPTIONS, &flags);
+	    printf("Watchdog card disabled.\n");
+	    goto end;
+	} else if (!strncasecmp(argv[1], "-e", 2)) {
+	    flags = WDIOS_ENABLECARD;
+	    ioctl(fd, WDIOC_SETOPTIONS, &flags);
+	    printf("Watchdog card enabled.\n");
+	    goto end;
+	} else if (!strncasecmp(argv[1], "-t", 2) && argv[2]) {
+	    flags = atoi(argv[2]);
+	    ioctl(fd, WDIOC_SETTIMEOUT, &flags);
+	    printf("Watchdog timeout set to %u seconds.\n", flags);
+	    goto end;
+	} else if (!strncasecmp(argv[1], "-p", 2) && argv[2]) {
+	    ping_rate = strtoul(argv[2], NULL, 0);
+	    printf("Watchdog ping rate set to %u seconds.\n", ping_rate);
+	} else {
+	    printf("-d to disable, -e to enable, -t <n> to set " \
+		"the timeout,\n-p <n> to set the ping rate, and \n");
+	    printf("run by itself to tick the card.\n");
+	    goto end;
+	}
+    }
+
+    printf("Watchdog Ticking Away!\n");
+
+    signal(SIGINT, term);
+
+    while(1) {
+	keep_alive();
+	sleep(ping_rate);
+    }
+end:
+    ret = write(fd, &v, 1);
+    if (ret < 0)
+	printf("Stopping watchdog ticks failed (%d)...\n", errno);
+    close(fd);
+    return 0;
+}
-- 
2.7.4
