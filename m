From: David Ahern <dsa@cumulusnetworks.com>
Subject: [iproute2 net-next 4/8] move cmd_exec to lib utils
Date: Sun, 11 Dec 2016 16:53:11 -0800
Message-ID: <1481503995-24825-5-git-send-email-dsa@cumulusnetworks.com>
References: <1481503995-24825-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:32871 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754032AbcLLAxZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Dec 2016 19:53:25 -0500
Received: by mail-pg0-f47.google.com with SMTP id 3so29061399pgd.0
        for <netdev@vger.kernel.org>; Sun, 11 Dec 2016 16:53:25 -0800 (PST)
In-Reply-To: <1481503995-24825-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Code move only; no functional change intended.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/utils.h |  2 ++
 ip/ipnetns.c    | 34 ----------------------------------
 lib/Makefile    |  2 +-
 lib/exec.c      | 40 +++++++++++++++++++++++++++++++++++++++++
 4 files changed, 43 insertions(+), 35 deletions(-)
 create mode 100644 lib/exec.c

diff --git a/include/utils.h b/include/utils.h
index 26c970daa5d0..ac4517a3bde1 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -256,4 +256,6 @@ char *int_to_str(int val, char *buf);
 int get_guid(__u64 *guid, const char *arg);
 int get_real_family(int rtm_type, int rtm_family);
 
+int cmd_exec(const char *cmd, char **argv, bool do_fork);
+
 #endif /* __UTILS_H__ */
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index bd1e9013706c..db9a541769f1 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -357,40 +357,6 @@ static int netns_list(int argc, char **argv)
 	return 0;
 }
 
-static int cmd_exec(const char *cmd, char **argv, bool do_fork)
-{
-	fflush(stdout);
-	if (do_fork) {
-		int status;
-		pid_t pid;
-
-		pid = fork();
-		if (pid < 0) {
-			perror("fork");
-			exit(1);
-		}
-
-		if (pid != 0) {
-			/* Parent  */
-			if (waitpid(pid, &status, 0) < 0) {
-				perror("waitpid");
-				exit(1);
-			}
-
-			if (WIFEXITED(status)) {
-				return WEXITSTATUS(status);
-			}
-
-			exit(1);
-		}
-	}
-
-	if (execvp(cmd, argv)  < 0)
-		fprintf(stderr, "exec of \"%s\" failed: %s\n",
-				cmd, strerror(errno));
-	_exit(1);
-}
-
 static int on_netns_exec(char *nsname, void *arg)
 {
 	char **argv = arg;
diff --git a/lib/Makefile b/lib/Makefile
index 5b7ec169048a..749073261c49 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -8,7 +8,7 @@ CFLAGS += -fPIC
 
 UTILOBJ = utils.o rt_names.o ll_types.o ll_proto.o ll_addr.o \
 	inet_proto.o namespace.o json_writer.o \
-	names.o color.o bpf.o
+	names.o color.o bpf.o exec.o
 
 NLOBJ=libgenl.o ll_map.o libnetlink.o
 
diff --git a/lib/exec.c b/lib/exec.c
new file mode 100644
index 000000000000..96edbc422e84
--- /dev/null
+++ b/lib/exec.c
@@ -0,0 +1,40 @@
+#include <sys/wait.h>
+#include <stdio.h>
+#include <errno.h>
+#include <unistd.h>
+
+#include "utils.h"
+
+int cmd_exec(const char *cmd, char **argv, bool do_fork)
+{
+	fflush(stdout);
+	if (do_fork) {
+		int status;
+		pid_t pid;
+
+		pid = fork();
+		if (pid < 0) {
+			perror("fork");
+			exit(1);
+		}
+
+		if (pid != 0) {
+			/* Parent  */
+			if (waitpid(pid, &status, 0) < 0) {
+				perror("waitpid");
+				exit(1);
+			}
+
+			if (WIFEXITED(status)) {
+				return WEXITSTATUS(status);
+			}
+
+			exit(1);
+		}
+	}
+
+	if (execvp(cmd, argv)  < 0)
+		fprintf(stderr, "exec of \"%s\" failed: %s\n",
+				cmd, strerror(errno));
+	_exit(1);
+}
-- 
2.1.4
