From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2-next 2/3] ipnetns: allow to get and set netns ids
Date: Tue, 20 Jan 2015 11:36:02 +0100
Message-ID: <1421750163-20348-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1421750163-20348-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:53581 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753701AbbATKgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 05:36:20 -0500
In-Reply-To: <1421750163-20348-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel now provides ids for peer netns. This patch implements a new command
'set' to assign an id.
When netns are listed, if an id is assigned, it is now displayed.

Example:
 $ ip netns add foo
 $ ip netns set foo 1
 $ ip netns
 foo (id: 1)
 init_net

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/libnetlink.h |   8 ++++
 ip/ipnetns.c         | 113 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 man/man8/ip-netns.8  |  14 +++++++
 3 files changed, 134 insertions(+), 1 deletion(-)

diff --git a/include/libnetlink.h b/include/libnetlink.h
index d081e54210ea..898275b824d4 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -158,6 +158,14 @@ extern int rtnl_from_file(FILE *, rtnl_filter_t handler,
 #define NDTA_PAYLOAD(n) NLMSG_PAYLOAD(n,sizeof(struct ndtmsg))
 #endif
 
+#ifndef NETNS_RTA
+#define NETNS_RTA(r) \
+	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct rtgenmsg))))
+#endif
+#ifndef NETNS_PAYLOAD
+#define NETNS_PAYLOAD(n)	NLMSG_PAYLOAD(n,sizeof(struct rtgenmsg))
+#endif
+
 /* User defined nlmsg_type which is used mostly for logging netlink
  * messages from dump file */
 #define NLMSG_TSTAMP	15
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 123318eb6adf..8c86673db581 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -15,6 +15,8 @@
 #include <unistd.h>
 #include <ctype.h>
 
+#include <linux/net_namespace.h>
+
 #include "utils.h"
 #include "ip_common.h"
 #include "namespace.h"
@@ -23,6 +25,7 @@ static int usage(void)
 {
 	fprintf(stderr, "Usage: ip netns list\n");
 	fprintf(stderr, "       ip netns add NAME\n");
+	fprintf(stderr, "       ip netns set NAME NETNSID\n");
 	fprintf(stderr, "       ip netns delete NAME\n");
 	fprintf(stderr, "       ip netns identify [PID]\n");
 	fprintf(stderr, "       ip netns pids NAME\n");
@@ -31,10 +34,56 @@ static int usage(void)
 	exit(-1);
 }
 
+static int get_netnsid_from_name(const char *name)
+{
+	struct {
+		struct nlmsghdr n;
+		struct rtgenmsg g;
+		char            buf[1024];
+	} req, answer;
+	struct rtattr *tb[NETNSA_MAX + 1];
+	struct rtgenmsg *rthdr;
+	int len, fd;
+
+	memset(&req, 0, sizeof(req));
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct rtgenmsg));
+	req.n.nlmsg_flags = NLM_F_REQUEST;
+	req.n.nlmsg_type = RTM_GETNSID;
+	req.g.rtgen_family = AF_UNSPEC;
+
+	fd = netns_get_fd(name);
+	if (fd < 0)
+		return fd;
+
+	addattr32(&req.n, 1024, NETNSA_FD, fd);
+	if (rtnl_talk(&rth, &req.n, 0, 0, &answer.n) < 0) {
+		close(fd);
+		return -2;
+	}
+	close(fd);
+
+	/* Validate message and parse attributes */
+	if (answer.n.nlmsg_type == NLMSG_ERROR)
+		return -1;
+
+	rthdr = NLMSG_DATA(&answer.n);
+	len = answer.n.nlmsg_len - NLMSG_SPACE(sizeof(*rthdr));
+	if (len < 0)
+		return -1;
+
+	parse_rtattr(tb, NETNSA_MAX, NETNS_RTA(rthdr), len);
+
+	if (tb[NETNSA_NSID])
+		return rta_getattr_u32(tb[NETNSA_NSID]);
+
+	return -1;
+}
+
 static int netns_list(int argc, char **argv)
 {
 	struct dirent *entry;
 	DIR *dir;
+	int id;
 
 	dir = opendir(NETNS_RUN_DIR);
 	if (!dir)
@@ -45,7 +94,11 @@ static int netns_list(int argc, char **argv)
 			continue;
 		if (strcmp(entry->d_name, "..") == 0)
 			continue;
-		printf("%s\n", entry->d_name);
+		printf("%s", entry->d_name);
+		id = get_netnsid_from_name(entry->d_name);
+		if (id >= 0)
+			printf(" (id: %d)", id);
+		printf("\n");
 	}
 	closedir(dir);
 	return 0;
@@ -355,6 +408,61 @@ out_delete:
 	return -1;
 }
 
+static int set_netnsid_from_name(const char *name, int nsid)
+{
+	struct {
+		struct nlmsghdr n;
+		struct rtgenmsg g;
+		char            buf[1024];
+	} req;
+	int fd, err = 0;
+
+	memset(&req, 0, sizeof(req));
+	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct rtgenmsg));
+	req.n.nlmsg_flags = NLM_F_REQUEST;
+	req.n.nlmsg_type = RTM_NEWNSID;
+	req.g.rtgen_family = AF_UNSPEC;
+
+	fd = netns_get_fd(name);
+	if (fd < 0)
+		return fd;
+
+	addattr32(&req.n, 1024, NETNSA_FD, fd);
+	addattr32(&req.n, 1024, NETNSA_NSID, nsid);
+	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
+		err = -2;
+
+	close(fd);
+	return err;
+}
+
+static int netns_set(int argc, char **argv)
+{
+	char netns_path[MAXPATHLEN];
+	const char *name;
+	int netns, nsid;
+
+	if (argc < 1) {
+		fprintf(stderr, "No netns name specified\n");
+		return -1;
+	}
+	if (argc < 2) {
+		fprintf(stderr, "No nsid specified\n");
+		return -1;
+	}
+	name = argv[0];
+	nsid = atoi(argv[1]);
+
+	snprintf(netns_path, sizeof(netns_path), "%s/%s", NETNS_RUN_DIR, name);
+	netns = open(netns_path, O_RDONLY | O_CLOEXEC);
+	if (netns < 0) {
+		fprintf(stderr, "Cannot open network namespace \"%s\": %s\n",
+			name, strerror(errno));
+		return -1;
+	}
+
+	return set_netnsid_from_name(name, nsid);
+}
 
 static int netns_monitor(int argc, char **argv)
 {
@@ -410,6 +518,9 @@ int do_netns(int argc, char **argv)
 	if (matches(*argv, "add") == 0)
 		return netns_add(argc-1, argv+1);
 
+	if (matches(*argv, "set") == 0)
+		return netns_set(argc-1, argv+1);
+
 	if (matches(*argv, "delete") == 0)
 		return netns_delete(argc-1, argv+1);
 
diff --git a/man/man8/ip-netns.8 b/man/man8/ip-netns.8
index 74343ed6b640..95fc5e6b8a45 100644
--- a/man/man8/ip-netns.8
+++ b/man/man8/ip-netns.8
@@ -20,6 +20,10 @@ ip-netns \- process network namespace management
 .I NETNSNAME
 
 .ti -8
+.BR "ip netns" " { " set " } "
+.I NETNSNAME NETNSID
+
+.ti -8
 .BR "ip netns identify"
 .RI "[ " PID " ]"
 
@@ -85,6 +89,16 @@ persists until it has no more users.  ip netns delete may fail if
 the mount point is in use in another mount namespace.
 
 .TP
+.B ip netns set NAME NETNSID - assign an id to a peer network namespace
+.sp
+This command assigns a id to a peer network namespace. This id is valid
+only in the current network namespace.
+This id will be used by the kernel in some netlink messages. If no id is
+assigned when the kernel needs it, it will be automatically assigned by
+the kernel.
+Once it is assigned, it's not possible to change it.
+
+.TP
 .B ip netns identify [PID] - Report network namespaces names for process
 .sp
 This command walks through /var/run/netns and finds all the network
-- 
2.2.2
