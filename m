From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC iproute v1 1/4] afnetns: add iproute bits for afnetns
Date: Mon, 13 Mar 2017 00:01:35 +0100
Message-ID: <20170312230138.5096-2-hannes@stressinduktion.org>
References: <20170312230138.5096-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:42994 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935487AbdCLXBq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:01:46 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id B8EDC20638
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:43 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id 825B8240CF
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:42 -0400 (EDT)
In-Reply-To: <20170312230138.5096-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Like ip netns, ip afnetns ... provides the basic utility features to
create, delete afnet namespaces and execute commands inside afnetns.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/namespace.h |   5 ++
 include/utils.h     |   1 +
 ip/Makefile         |   2 +-
 ip/ip.c             |   5 +-
 ip/ip_common.h      |   1 +
 ip/ipafnetns.c      | 227 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/utils.c         |  36 +++++++++
 7 files changed, 274 insertions(+), 3 deletions(-)
 create mode 100644 ip/ipafnetns.c

diff --git a/include/namespace.h b/include/namespace.h
index 51324b21ba0cd5..acecc8c1f0d2b8 100644
--- a/include/namespace.h
+++ b/include/namespace.h
@@ -7,6 +7,7 @@
 #include <sys/syscall.h>
 #include <errno.h>
 
+#define AFNETNS_RUN_DIR "/var/run/afnetns"
 #define NETNS_RUN_DIR "/var/run/netns"
 #define NETNS_ETC_DIR "/etc/netns"
 
@@ -14,6 +15,10 @@
 #define CLONE_NEWNET 0x40000000	/* New network namespace (lo, device, names sockets, etc) */
 #endif
 
+#ifndef CLONE_NEWAFNET
+#define CLONE_NEWAFNET	0x00001000	/* Clone new afnet context */
+#endif
+
 #ifndef MNT_DETACH
 #define MNT_DETACH	0x00000002	/* Just detach from the tree */
 #endif /* MNT_DETACH */
diff --git a/include/utils.h b/include/utils.h
index 22369e0b4e0374..59fdd76b502b3c 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -256,6 +256,7 @@ int do_each_netns(int (*func)(char *nsname, void *arg), void *arg,
 char *int_to_str(int val, char *buf);
 int get_guid(__u64 *guid, const char *arg);
 int get_real_family(int rtm_type, int rtm_family);
+int cmd_exec(const char *cmd, char **argv, bool do_fork);
 
 int cmd_exec(const char *cmd, char **argv, bool do_fork);
 int make_path(const char *path, mode_t mode);
diff --git a/ip/Makefile b/ip/Makefile
index 4276a34b529e3f..4da6f33968ffe1 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -8,7 +8,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     link_iptnl.o link_gre6.o iplink_bond.o iplink_bond_slave.o iplink_hsr.o \
     iplink_bridge.o iplink_bridge_slave.o ipfou.o iplink_ipvlan.o \
     iplink_geneve.o iplink_vrf.o iproute_lwtunnel.o ipmacsec.o ipila.o \
-    ipvrf.o iplink_xstats.o
+    ipvrf.o iplink_xstats.o ipafnetns.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/ip.c b/ip/ip.c
index 07050b07592ac1..6aa8aaab4c03f9 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -51,8 +51,8 @@ static void usage(void)
 "       ip [ -force ] -batch filename\n"
 "where  OBJECT := { link | address | addrlabel | route | rule | neigh | ntable |\n"
 "                   tunnel | tuntap | maddress | mroute | mrule | monitor | xfrm |\n"
-"                   netns | l2tp | fou | macsec | tcp_metrics | token | netconf | ila |\n"
-"                   vrf }\n"
+"                   netns | afnetns | l2tp | fou | macsec | tcp_metrics | token |\n"
+"                   netconf | ila | vrf }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
 "                    -h[uman-readable] | -iec |\n"
 "                    -f[amily] { inet | inet6 | ipx | dnet | mpls | bridge | link } |\n"
@@ -99,6 +99,7 @@ static const struct cmd {
 	{ "mroute",	do_multiroute },
 	{ "mrule",	do_multirule },
 	{ "netns",	do_netns },
+	{ "afnetns",	do_afnetns },
 	{ "netconf",	do_ipnetconf },
 	{ "vrf",	do_ipvrf},
 	{ "help",	do_help },
diff --git a/ip/ip_common.h b/ip/ip_common.h
index 5a39623aa21d9f..1f59db40038ef2 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -50,6 +50,7 @@ int do_multiaddr(int argc, char **argv);
 int do_multiroute(int argc, char **argv);
 int do_multirule(int argc, char **argv);
 int do_netns(int argc, char **argv);
+int do_afnetns(int argc, char **argv);
 int do_xfrm(int argc, char **argv);
 int do_ipl2tp(int argc, char **argv);
 int do_ipfou(int argc, char **argv);
diff --git a/ip/ipafnetns.c b/ip/ipafnetns.c
new file mode 100644
index 00000000000000..5b7a7e59bc947a
--- /dev/null
+++ b/ip/ipafnetns.c
@@ -0,0 +1,227 @@
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <stdio.h>
+#include <dirent.h>
+#include <fcntl.h>
+
+#include "utils.h"
+#include "ip_common.h"
+#include "namespace.h"
+
+static void usage(void)
+{
+	static const char *help =
+		"Usage: ip afnetns list\n"
+		"       ip afnetns add NAME\n"
+		"       ip afnetns del NAME\n"
+		"       ip afnetns exec NAME cmd ...\n";
+	fputs(help, stderr);
+}
+
+static int afnetns_list(void)
+{
+	struct dirent *entry;
+	DIR *dir;
+
+	dir = opendir(AFNETNS_RUN_DIR);
+	if (!dir)
+		return 0;
+
+	while ((entry = readdir(dir))) {
+		if (!strcmp(entry->d_name, ".") ||
+		    !strcmp(entry->d_name, ".."))
+			continue;
+		printf("%s\n", entry->d_name);
+	}
+	closedir(dir);
+
+	return 0;
+}
+
+static int create_afnetns_dir(void)
+{
+	int err;
+	const mode_t mode = S_IRWXU|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH;
+
+	err = mkdir(AFNETNS_RUN_DIR, mode);
+	if (!err || errno == EEXIST)
+		return 0;
+
+	fprintf(stderr, "Could not create afnet run dir \"%s\": %s\n",
+		AFNETNS_RUN_DIR, strerror(errno));
+	return err;
+}
+
+static int afnetns_delete(int argc, char **argv)
+{
+	const char *name;
+	char *path;
+	int err;
+
+	if (argc < 1) {
+		fputs("No afnetns name specified\n", stderr);
+		return -1;
+	}
+
+	name = argv[0];
+	err = asprintf(&path, "%s/%s", AFNETNS_RUN_DIR, name);
+	if (err < 0) {
+		perror("asprintf");
+		return err;
+	}
+
+	err = umount2(path, MNT_DETACH);
+	if (err)
+		fprintf(stderr, "Cannot umount afnet namespace file \"%s\": %s\n",
+			path, strerror(errno));
+
+	err = unlink(path);
+	if (err) {
+		fprintf(stderr, "Cannot remove afnet namespace file \"%s\": %s\n",
+			path, strerror(errno));
+		goto out;
+	}
+
+out:
+	free(path);
+	return err;
+}
+
+static int afnetns_add(int argc, char **argv)
+{
+	const char *name;
+	int err, fd;
+	char *path;
+
+	if (argc < 1) {
+		fputs("No afnetns name specified\n", stderr);
+		return -1;
+	}
+
+	err = create_afnetns_dir();
+	if (err)
+		return err;
+
+	name = argv[0];
+	err = asprintf(&path, "%s/%s", AFNETNS_RUN_DIR, name);
+	if (err < 0) {
+		perror("asprintf");
+		return err;
+	}
+
+	fd = open(path, O_RDONLY|O_CREAT|O_EXCL, 0);
+	if (fd < 0) {
+		err = fd;
+		fprintf(stderr, "Cannot create afnetns file \"%s\": %s\n",
+			path, strerror(errno));
+		goto out;
+	}
+	err = close(fd);
+	if (err) {
+		perror("close");
+		goto out;
+	}
+
+	err = unshare(CLONE_NEWAFNET);
+	if (err < 0) {
+		fprintf(stderr, "Failed to create a new afnet namesapce \"%s\": %s\n",
+			name, strerror(errno));
+		goto out;
+	}
+
+	err = mount("/proc/self/ns/afnet", path, "none", MS_BIND, NULL);
+	if (err < 0) {
+		fprintf(stderr, "Bind /proc/self/ns/afnet -> %s failed: %s\n",
+			path, strerror(errno));
+		goto out_delete;
+	}
+
+	err = 0;
+out:
+	free(path);
+	return err;
+out_delete:
+	afnetns_delete(argc, argv);
+	goto out;
+}
+
+static int afnetns_switch(const char *name)
+{
+	int err, ns;
+	char *path;
+
+	err = asprintf(&path, "%s/%s", AFNETNS_RUN_DIR, name);
+	if (err < 0) {
+		perror("asprintf");
+		return err;
+	};
+
+	ns = open(path, O_RDONLY | O_CLOEXEC);
+	if (ns < 0) {
+		fprintf(stderr, "Cannot open afnet namespace \"%s\": %s\n",
+			name, strerror(errno));
+		err = ns;
+		goto out;
+	}
+
+	err = setns(ns, CLONE_NEWAFNET);
+	if (err) {
+		fprintf(stderr, "setting the afnet namespace \"%s\" failed: %s\n",
+			name, strerror(errno));
+		goto out;
+	}
+	err = close(ns);
+	if (err) {
+		perror("close");
+		goto out;
+	}
+
+out:
+	free(path);
+	return err;
+}
+
+static int afnetns_exec(int argc, char **argv)
+{
+	const char *cmd;
+	int err;
+
+	if (argc < 2) {
+		fputs("No netns name and or commands specified\n", stderr);
+		return -1;
+	}
+
+	err = afnetns_switch(argv[0]);
+	if (err)
+		return err;
+
+	cmd = argv[1];
+	return -cmd_exec(cmd, argv + 1, !!batch_mode);
+}
+
+int do_afnetns(int argc, char **argv)
+{
+	if (argc < 1)
+		return afnetns_list();
+
+	if (!matches(*argv, "help")) {
+		usage();
+		return 0;
+	}
+
+	if (!matches(*argv, "list") || !matches(*argv, "show") ||
+	    !matches(*argv, "lst"))
+		return afnetns_list();
+
+	if (!matches(*argv, "add"))
+		return afnetns_add(argc-1, argv+1);
+
+	if (!matches(*argv, "delete"))
+		return afnetns_delete(argc-1, argv+1);
+
+	if (!matches(*argv, "exec"))
+		return afnetns_exec(argc-1, argv+1);
+
+	fprintf(stderr, "Command \"%s\" is unkown, try \"ip afnetns help\".\n", *argv);
+	return -1;
+}
diff --git a/lib/utils.c b/lib/utils.c
index 6d5642f4f1f3fa..d80618f7c485a4 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -17,7 +17,9 @@
 #include <syslog.h>
 #include <fcntl.h>
 #include <limits.h>
+#include <sys/types.h>
 #include <sys/socket.h>
+#include <sys/wait.h>
 #include <netinet/in.h>
 #include <string.h>
 #include <netdb.h>
@@ -1214,3 +1216,37 @@ int get_real_family(int rtm_type, int rtm_family)
 
 	return rtm_family == RTNL_FAMILY_IPMR ? AF_INET : AF_INET6;
 }
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
2.9.3
