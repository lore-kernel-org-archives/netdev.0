From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH for 3.8] iproute2: Add "ip netns pids" and "ip netns identify"
Date: Mon, 26 Nov 2012 17:16:06 -0600
Message-ID: <87a9u4q7k9.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:45471 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757153Ab2KZXQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2012 18:16:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add command that go between network namespace names and process
identifiers.  The code builds and runs agains older kernels but
only works on Linux 3.8+ kernels where I have fixed stat to work
properly.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---

I don't know if this is too soon to send this patch to iproute as the
kernel code that fixes stat is currently sitting in my for-next branch
of:
git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git

and has not hit Linus's tree yet.  Still the code runs and is harmless
on older kernels so it should be harmless whatever happens with it.

 ip/ipnetns.c        |  141 +++++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/ip-netns.8 |    5 ++-
 2 files changed, 145 insertions(+), 1 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index e41a598..c55fe3a 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -13,6 +13,7 @@
 #include <dirent.h>
 #include <errno.h>
 #include <unistd.h>
+#include <ctype.h>
 
 #include "utils.h"
 #include "ip_common.h"
@@ -48,6 +49,8 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip netns list\n");
 	fprintf(stderr, "       ip netns add NAME\n");
 	fprintf(stderr, "       ip netns delete NAME\n");
+	fprintf(stderr, "       ip netns identify PID\n");
+	fprintf(stderr, "       ip netns pids NAME\n");
 	fprintf(stderr, "       ip netns exec NAME cmd ...\n");
 	fprintf(stderr, "       ip netns monitor\n");
 	exit(-1);
@@ -171,6 +174,138 @@ static int netns_exec(int argc, char **argv)
 	exit(-1);
 }
 
+static int is_pid(const char *str)
+{
+	int ch;
+	for (; (ch = *str); str++) {
+		if (!isdigit(ch))
+			return 0;
+	}
+	return 1;
+}
+
+static int netns_pids(int argc, char **argv)
+{
+	const char *name;
+	char net_path[MAXPATHLEN];
+	int netns;
+	struct stat netst;
+	DIR *dir;
+	struct dirent *entry;
+
+	if (argc < 1) {
+		fprintf(stderr, "No netns name specified\n");
+		return -1;
+	}
+	if (argc > 1) {
+		fprintf(stderr, "extra arguments specified\n");
+		return -1;
+	}
+
+	name = argv[0];
+	snprintf(net_path, sizeof(net_path), "%s/%s", NETNS_RUN_DIR, name);
+	netns = open(net_path, O_RDONLY);
+	if (netns < 0) {
+		fprintf(stderr, "Cannot open network namespace: %s\n",
+			strerror(errno));
+		return -1;
+	}
+	if (fstat(netns, &netst) < 0) {
+		fprintf(stderr, "Stat of netns failed: %s\n",
+			strerror(errno));
+		return -1;
+	}
+	dir = opendir("/proc/");
+	if (!dir) {
+		fprintf(stderr, "Open of /proc failed: %s\n",
+			strerror(errno));
+		return -1;
+	}
+	while((entry = readdir(dir))) {
+		char pid_net_path[MAXPATHLEN];
+		struct stat st;
+		if (!is_pid(entry->d_name))
+			continue;
+		snprintf(pid_net_path, sizeof(pid_net_path), "/proc/%s/ns/net",
+			entry->d_name);
+		if (stat(pid_net_path, &st) != 0)
+			continue;
+		if ((st.st_dev == netst.st_dev) &&
+		    (st.st_ino == netst.st_ino)) {
+			printf("%s\n", entry->d_name);
+		}
+	}
+	closedir(dir);
+	return 0;
+	
+}
+
+static int netns_identify(int argc, char **argv)
+{
+	const char *pidstr;
+	char net_path[MAXPATHLEN];
+	int netns;
+	struct stat netst;
+	DIR *dir;
+	struct dirent *entry;
+
+	if (argc < 1) {
+		fprintf(stderr, "No pid specified\n");
+		return -1;
+	}
+	if (argc > 1) {
+		fprintf(stderr, "extra arguments specified\n");
+		return -1;
+	}
+	pidstr = argv[0];
+
+	if (!is_pid(pidstr)) {
+		fprintf(stderr, "Specified string '%s' is not a pid\n",
+			pidstr);
+		return -1;
+	}
+
+	snprintf(net_path, sizeof(net_path), "/proc/%s/ns/net", pidstr);
+	netns = open(net_path, O_RDONLY);
+	if (netns < 0) {
+		fprintf(stderr, "Cannot open network namespace: %s\n",
+			strerror(errno));
+		return -1;
+	}
+	if (fstat(netns, &netst) < 0) {
+		fprintf(stderr, "Stat of netns failed: %s\n",
+			strerror(errno));
+		return -1;
+	}
+	dir = opendir(NETNS_RUN_DIR);
+	if (!dir)
+		return 0;
+
+	while((entry = readdir(dir))) {
+		char name_path[MAXPATHLEN];
+		struct stat st;
+
+		if (strcmp(entry->d_name, ".") == 0)
+			continue;
+		if (strcmp(entry->d_name, "..") == 0)
+			continue;
+
+		snprintf(name_path, sizeof(name_path), "%s/%s",	NETNS_RUN_DIR,
+			entry->d_name);
+
+		if (stat(name_path, &st) != 0)
+			continue;
+
+		if ((st.st_dev == netst.st_dev) &&
+		    (st.st_ino == netst.st_ino)) {
+			printf("%s\n", entry->d_name);
+		}
+	}
+	closedir(dir);
+	return 0;
+	
+}
+
 static int netns_delete(int argc, char **argv)
 {
 	const char *name;
@@ -298,6 +433,12 @@ int do_netns(int argc, char **argv)
 	if (matches(*argv, "delete") == 0)
 		return netns_delete(argc-1, argv+1);
 
+	if (matches(*argv, "identify") == 0)
+		return netns_identify(argc-1, argv+1);
+
+	if (matches(*argv, "pids") == 0)
+		return netns_pids(argc-1, argv+1);
+
 	if (matches(*argv, "exec") == 0)
 		return netns_exec(argc-1, argv+1);
 
diff --git a/man/man8/ip-netns.8 b/man/man8/ip-netns.8
index 349ee7e..e639836 100644
--- a/man/man8/ip-netns.8
+++ b/man/man8/ip-netns.8
@@ -1,4 +1,4 @@
-.TH IP\-NETNS 8 "20 Dec 2011" "iproute2" "Linux"
+.TH IP\-NETNS 8 "26 Dec 2012" "iproute2" "Linux"
 .SH NAME
 ip-netns \- process network namespace management
 .SH SYNOPSIS
@@ -58,6 +58,9 @@ their traditional location in /etc.
 .SS ip netns delete NAME - delete the name of a network namespace
 .SS ip netns exec NAME cmd ... - Run cmd in the named network namespace
 
+.SS ip netns pids NAME - Report processes in the named network namespace
+.SS ip netns identify PID - Report network namespaces names for process
+
 .SH EXAMPLES
 
 .SH SEE ALSO
-- 
1.7.5.4
