From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH iproute2-3.8 6/6] iproute2: Add "ip netns pids" and "ip netns identify"
Date: Thu, 17 Jan 2013 16:48:15 -0800
Message-ID: <877gnb48q8.fsf_-_@xmission.com>
References: <87a9u4q7k9.fsf@xmission.com>
	<1354039239.2701.8.camel@bwh-desktop.uk.solarflarecom.com>
	<87622v5ngt.fsf_-_@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, "Serge E. Hallyn" <serge@hallyn.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:56405 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754708Ab3ARAsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 19:48:36 -0500
In-Reply-To: <87622v5ngt.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Thu, 17 Jan 2013 16:44:34 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add command that go between network namespace names and process
identifiers.  The code builds and runs agains older kernels but
only works on Linux 3.8+ kernels where I have fixed stat to work
properly.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 ip/ipnetns.c        |  148 +++++++++++++++++++++++++++++++++++++++++++++++++++
 man/man8/ip-netns.8 |   18 ++++++
 2 files changed, 166 insertions(+), 0 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 33765b5..51b1c5e 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -13,6 +13,7 @@
 #include <dirent.h>
 #include <errno.h>
 #include <unistd.h>
+#include <ctype.h>
 
 #include "utils.h"
 #include "ip_common.h"
@@ -45,6 +46,8 @@ static int usage(void)
 	fprintf(stderr, "Usage: ip netns list\n");
 	fprintf(stderr, "       ip netns add NAME\n");
 	fprintf(stderr, "       ip netns delete NAME\n");
+	fprintf(stderr, "       ip netns identify PID\n");
+	fprintf(stderr, "       ip netns pids NAME\n");
 	fprintf(stderr, "       ip netns exec NAME cmd ...\n");
 	fprintf(stderr, "       ip netns monitor\n");
 	return EXIT_FAILURE;
@@ -174,6 +177,145 @@ static int netns_exec(int argc, char **argv)
 	return EXIT_FAILURE;
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
+		return EXIT_FAILURE;
+	}
+	if (argc > 1) {
+		fprintf(stderr, "extra arguments specified\n");
+		return EXIT_FAILURE;
+	}
+
+	name = argv[0];
+	snprintf(net_path, sizeof(net_path), "%s/%s", NETNS_RUN_DIR, name);
+	netns = open(net_path, O_RDONLY);
+	if (netns < 0) {
+		fprintf(stderr, "Cannot open network namespace: %s\n",
+			strerror(errno));
+		return EXIT_FAILURE;
+	}
+	if (fstat(netns, &netst) < 0) {
+		fprintf(stderr, "Stat of netns failed: %s\n",
+			strerror(errno));
+		return EXIT_FAILURE;
+	}
+	dir = opendir("/proc/");
+	if (!dir) {
+		fprintf(stderr, "Open of /proc failed: %s\n",
+			strerror(errno));
+		return EXIT_FAILURE;
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
+	return EXIT_SUCCESS;
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
+		return EXIT_FAILURE;
+	}
+	if (argc > 1) {
+		fprintf(stderr, "extra arguments specified\n");
+		return EXIT_FAILURE;
+	}
+	pidstr = argv[0];
+
+	if (!is_pid(pidstr)) {
+		fprintf(stderr, "Specified string '%s' is not a pid\n",
+			pidstr);
+		return EXIT_FAILURE;
+	}
+
+	snprintf(net_path, sizeof(net_path), "/proc/%s/ns/net", pidstr);
+	netns = open(net_path, O_RDONLY);
+	if (netns < 0) {
+		fprintf(stderr, "Cannot open network namespace: %s\n",
+			strerror(errno));
+		return EXIT_FAILURE;
+	}
+	if (fstat(netns, &netst) < 0) {
+		fprintf(stderr, "Stat of netns failed: %s\n",
+			strerror(errno));
+		return EXIT_FAILURE;
+	}
+	dir = opendir(NETNS_RUN_DIR);
+	if (!dir) {
+		/* Succeed treat a missing directory as an empty directory */
+		if (errno == ENOENT)
+			return EXIT_SUCCESS;
+
+		fprintf(stderr, "Failed to open directory %s:%s\n",
+			NETNS_RUN_DIR, strerror(errno));
+		return EXIT_FAILURE;
+	}
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
+	return EXIT_SUCCESS;
+	
+}
+
 static int netns_delete(int argc, char **argv)
 {
 	const char *name;
@@ -324,6 +466,12 @@ int do_netns(int argc, char **argv)
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
index ff08232..f5b025e 100644
--- a/man/man8/ip-netns.8
+++ b/man/man8/ip-netns.8
@@ -20,6 +20,14 @@ ip-netns \- process network namespace management
 .I NETNSNAME
 
 .ti -8
+.BR "ip netns identify"
+.I PID
+
+.ti -8
+.BR "ip netns pids" 
+.I NETNSNAME
+
+.ti -8
 .BR "ip netns exec "
 .I NETNSNAME command ...
 
@@ -73,6 +81,16 @@ network namespace will be freed, otherwise the network namespace
 persists until it has no more users.  ip netns delete may fail if
 the mount point is in use in another mount namespace.
 
+.SS ip netns identify PID - Report network namespaces names for process
+
+This command walks through /var/run/netns and finds all the network
+namespace names for network namespace of the specified process.
+
+.SS ip netns pids NAME - Report processes in the named network namespace
+
+This command walks through proc and finds all of the process who have
+the named network namespace as their primary network namespace.
+
 .SS ip netns exec NAME cmd ... - Run cmd in the named network namespace
 
 This command allows applications that are network namespace unaware
-- 
1.7.5.4
