From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH v2 1/6] selftests: move dnotify_test from Documentation/filesystems
Date: Tue, 13 Sep 2016 14:18:40 -0600
Message-ID: <9ff3eb8efe6d6f233c5e85bda712f2ff8a31dbf8.1473795601.git.shuahkh@osg.samsung.com>
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

Move dnotify_test.c, Makefile, and .gitignore from Documentation/filesystems
to selftests/filesystems.

Remove filesystems build target from Documentation/Makefile and update
selftests/filesystems/Makefile to work under selftests. dnotify_test will
not be run as part of selftests suite and will not be included in install
targets. It can be built separately for now.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 Documentation/Makefile                             |  2 +-
 Documentation/filesystems/.gitignore               |  1 -
 Documentation/filesystems/Makefile                 |  5 ----
 Documentation/filesystems/dnotify_test.c           | 34 ----------------------
 tools/testing/selftests/filesystems/.gitignore     |  1 +
 tools/testing/selftests/filesystems/Makefile       |  7 +++++
 tools/testing/selftests/filesystems/dnotify_test.c | 34 ++++++++++++++++++++++
 7 files changed, 43 insertions(+), 41 deletions(-)
 delete mode 100644 Documentation/filesystems/.gitignore
 delete mode 100644 Documentation/filesystems/Makefile
 delete mode 100644 Documentation/filesystems/dnotify_test.c
 create mode 100644 tools/testing/selftests/filesystems/.gitignore
 create mode 100644 tools/testing/selftests/filesystems/Makefile
 create mode 100644 tools/testing/selftests/filesystems/dnotify_test.c

diff --git a/Documentation/Makefile b/Documentation/Makefile
index de955e1..0473710 100644
--- a/Documentation/Makefile
+++ b/Documentation/Makefile
@@ -1,3 +1,3 @@
 subdir-y := accounting auxdisplay blackfin \
-	filesystems filesystems ia64 laptops mic misc-devices \
+	ia64 laptops mic misc-devices \
 	networking pcmcia prctl ptp timers vDSO watchdog
diff --git a/Documentation/filesystems/.gitignore b/Documentation/filesystems/.gitignore
deleted file mode 100644
index 31d6e42..0000000
--- a/Documentation/filesystems/.gitignore
+++ /dev/null
@@ -1 +0,0 @@
-dnotify_test
diff --git a/Documentation/filesystems/Makefile b/Documentation/filesystems/Makefile
deleted file mode 100644
index 883010c..0000000
--- a/Documentation/filesystems/Makefile
+++ /dev/null
@@ -1,5 +0,0 @@
-# List of programs to build
-hostprogs-y := dnotify_test
-
-# Tell kbuild to always build the programs
-always := $(hostprogs-y)
diff --git a/Documentation/filesystems/dnotify_test.c b/Documentation/filesystems/dnotify_test.c
deleted file mode 100644
index 8b37b4a..0000000
--- a/Documentation/filesystems/dnotify_test.c
+++ /dev/null
@@ -1,34 +0,0 @@
-#define _GNU_SOURCE	/* needed to get the defines */
-#include <fcntl.h>	/* in glibc 2.2 this has the needed
-				   values defined */
-#include <signal.h>
-#include <stdio.h>
-#include <unistd.h>
-
-static volatile int event_fd;
-
-static void handler(int sig, siginfo_t *si, void *data)
-{
-	event_fd = si->si_fd;
-}
-
-int main(void)
-{
-	struct sigaction act;
-	int fd;
-
-	act.sa_sigaction = handler;
-	sigemptyset(&act.sa_mask);
-	act.sa_flags = SA_SIGINFO;
-	sigaction(SIGRTMIN + 1, &act, NULL);
-
-	fd = open(".", O_RDONLY);
-	fcntl(fd, F_SETSIG, SIGRTMIN + 1);
-	fcntl(fd, F_NOTIFY, DN_MODIFY|DN_CREATE|DN_MULTISHOT);
-	/* we will now be notified if any of the files
-	   in "." is modified or new files are created */
-	while (1) {
-		pause();
-		printf("Got event on fd=%d\n", event_fd);
-	}
-}
diff --git a/tools/testing/selftests/filesystems/.gitignore b/tools/testing/selftests/filesystems/.gitignore
new file mode 100644
index 0000000..31d6e42
--- /dev/null
+++ b/tools/testing/selftests/filesystems/.gitignore
@@ -0,0 +1 @@
+dnotify_test
diff --git a/tools/testing/selftests/filesystems/Makefile b/tools/testing/selftests/filesystems/Makefile
new file mode 100644
index 0000000..0ab1130
--- /dev/null
+++ b/tools/testing/selftests/filesystems/Makefile
@@ -0,0 +1,7 @@
+TEST_PROGS := dnotify_test
+all: $(TEST_PROGS)
+
+include ../lib.mk
+
+clean:
+	rm -fr $(TEST_PROGS)
diff --git a/tools/testing/selftests/filesystems/dnotify_test.c b/tools/testing/selftests/filesystems/dnotify_test.c
new file mode 100644
index 0000000..8b37b4a
--- /dev/null
+++ b/tools/testing/selftests/filesystems/dnotify_test.c
@@ -0,0 +1,34 @@
+#define _GNU_SOURCE	/* needed to get the defines */
+#include <fcntl.h>	/* in glibc 2.2 this has the needed
+				   values defined */
+#include <signal.h>
+#include <stdio.h>
+#include <unistd.h>
+
+static volatile int event_fd;
+
+static void handler(int sig, siginfo_t *si, void *data)
+{
+	event_fd = si->si_fd;
+}
+
+int main(void)
+{
+	struct sigaction act;
+	int fd;
+
+	act.sa_sigaction = handler;
+	sigemptyset(&act.sa_mask);
+	act.sa_flags = SA_SIGINFO;
+	sigaction(SIGRTMIN + 1, &act, NULL);
+
+	fd = open(".", O_RDONLY);
+	fcntl(fd, F_SETSIG, SIGRTMIN + 1);
+	fcntl(fd, F_NOTIFY, DN_MODIFY|DN_CREATE|DN_MULTISHOT);
+	/* we will now be notified if any of the files
+	   in "." is modified or new files are created */
+	while (1) {
+		pause();
+		printf("Got event on fd=%d\n", event_fd);
+	}
+}
-- 
2.7.4
