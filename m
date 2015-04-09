From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2-next 2/2] netns: allow to dump and monitor nsid
Date: Thu,  9 Apr 2015 10:30:14 +0200
Message-ID: <1428568214-8673-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1428568214-8673-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:35315 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755021AbbDIIaW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 04:30:22 -0400
In-Reply-To: <1428568214-8673-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two commands are added:
 - ip netns list-id
 - ip monitor nsid

A cache is also added to remember the association between the iproute2 netns
name (from /var/run/netns/) and the nsid.
To avoid interfering with the rth socket, a new rtnl socket (rtnsh) is used to
get nsid (we may send rtnl request during listing on rth).

Example:
$ ip netns list-id
nsid 0 (iproute2 netns name: foo)
$ ip monitor nsid
Deleted nsid 0 (iproute2 netns name: foo)
nsid 16 (iproute2 netns name: bar)

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/ll_map.h      |   1 +
 ip/ip_common.h        |   3 +
 ip/ipmonitor.c        |  17 ++++-
 ip/ipnetns.c          | 201 +++++++++++++++++++++++++++++++++++++++++++++++++-
 lib/ll_map.c          |   2 +-
 man/man8/ip-monitor.8 |   2 +-
 man/man8/ip-netns.8   |  10 +++
 7 files changed, 232 insertions(+), 4 deletions(-)

diff --git a/include/ll_map.h b/include/ll_map.h
index 4c78498e7e1e..b98a5714592e 100644
--- a/include/ll_map.h
+++ b/include/ll_map.h
@@ -10,5 +10,6 @@ extern const char *ll_index_to_name(unsigned idx);
 extern const char *ll_idx_n2a(unsigned idx, char *buf);
 extern int ll_index_to_type(unsigned idx);
 extern int ll_index_to_flags(unsigned idx);
+extern unsigned namehash(const char *str);
 
 #endif /* __LL_MAP_H__ */
diff --git a/ip/ip_common.h b/ip/ip_common.h
index 89a495ea1074..b082734d9e0c 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -34,6 +34,9 @@ extern int print_rule(const struct sockaddr_nl *who,
 		      struct nlmsghdr *n, void *arg);
 extern int print_netconf(const struct sockaddr_nl *who,
 			 struct nlmsghdr *n, void *arg);
+extern void netns_map_init(void);
+extern int print_nsid(const struct sockaddr_nl *who,
+		      struct nlmsghdr *n, void *arg);
 extern int do_ipaddr(int argc, char **argv);
 extern int do_ipaddrlabel(int argc, char **argv);
 extern int do_iproute(int argc, char **argv);
diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 7833a2632927..1205ee1c7039 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -32,7 +32,7 @@ static void usage(void)
 	fprintf(stderr, "Usage: ip monitor [ all | LISTofOBJECTS ] [ FILE ]"
 			"[ label ] [dev DEVICE]\n");
 	fprintf(stderr, "LISTofOBJECTS := link | address | route | mroute | prefix |\n");
-	fprintf(stderr, "                 neigh | netconf | rule\n");
+	fprintf(stderr, "                 neigh | netconf | rule | nsid\n");
 	fprintf(stderr, "FILE := file FILENAME\n");
 	exit(-1);
 }
@@ -129,6 +129,12 @@ static int accept_msg(const struct sockaddr_nl *who,
 		print_nlmsg_timestamp(fp, n);
 		return 0;
 	}
+	if (n->nlmsg_type == RTM_NEWNSID || n->nlmsg_type == RTM_DELNSID) {
+		if (prefix_banner)
+			fprintf(fp, "[NSID]");
+		print_nsid(who, n, arg);
+		return 0;
+	}
 	if (n->nlmsg_type != NLMSG_ERROR && n->nlmsg_type != NLMSG_NOOP &&
 	    n->nlmsg_type != NLMSG_DONE) {
 		fprintf(fp, "Unknown message: type=0x%08x(%d) flags=0x%08x(%d)"
@@ -151,6 +157,7 @@ int do_ipmonitor(int argc, char **argv)
 	int lneigh=0;
 	int lnetconf=0;
 	int lrule=0;
+	int lnsid=0;
 	int ifindex=0;
 
 	groups |= nl_mgrp(RTNLGRP_LINK);
@@ -167,6 +174,7 @@ int do_ipmonitor(int argc, char **argv)
 	groups |= nl_mgrp(RTNLGRP_IPV6_NETCONF);
 	groups |= nl_mgrp(RTNLGRP_IPV4_RULE);
 	groups |= nl_mgrp(RTNLGRP_IPV6_RULE);
+	groups |= nl_mgrp(RTNLGRP_NSID);
 
 	rtnl_close(&rth);
 
@@ -200,6 +208,9 @@ int do_ipmonitor(int argc, char **argv)
 		} else if (matches(*argv, "rule") == 0) {
 			lrule = 1;
 			groups = 0;
+		} else if (matches(*argv, "nsid") == 0) {
+			lnsid = 1;
+			groups = 0;
 		} else if (strcmp(*argv, "all") == 0) {
 			prefix_banner=1;
 		} else if (matches(*argv, "help") == 0) {
@@ -264,6 +275,9 @@ int do_ipmonitor(int argc, char **argv)
 		if (!preferred_family || preferred_family == AF_INET6)
 			groups |= nl_mgrp(RTNLGRP_IPV6_RULE);
 	}
+	if (lnsid) {
+		groups |= nl_mgrp(RTNLGRP_NSID);
+	}
 	if (file) {
 		FILE *fp;
 		fp = fopen(file, "r");
@@ -277,6 +291,7 @@ int do_ipmonitor(int argc, char **argv)
 	if (rtnl_open(&rth, groups) < 0)
 		exit(1);
 	ll_init_map(&rth);
+	netns_map_init();
 
 	if (rtnl_listen(&rth, accept_msg, stdout) < 0)
 		exit(2);
diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 45e234a4d98c..7806335733cf 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -14,10 +14,12 @@
 #include <errno.h>
 #include <unistd.h>
 #include <ctype.h>
+#include <linux/limits.h>
 
 #include <linux/net_namespace.h>
 
 #include "utils.h"
+#include "hlist.h"
 #include "ip_common.h"
 #include "namespace.h"
 
@@ -31,9 +33,13 @@ static int usage(void)
 	fprintf(stderr, "       ip netns pids NAME\n");
 	fprintf(stderr, "       ip [-all] netns exec [NAME] cmd ...\n");
 	fprintf(stderr, "       ip netns monitor\n");
+	fprintf(stderr, "       ip netns list-id\n");
 	exit(-1);
 }
 
+/* This socket is used to get nsid */
+static struct rtnl_handle rtnsh = { .fd = -1 };
+
 #ifdef HAVE_NETNSID
 static int get_netnsid_from_name(const char *name)
 {
@@ -57,7 +63,7 @@ static int get_netnsid_from_name(const char *name)
 		return fd;
 
 	addattr32(&req.n, 1024, NETNSA_FD, fd);
-	if (rtnl_talk(&rth, &req.n, 0, 0, &answer.n) < 0) {
+	if (rtnl_talk(&rtnsh, &req.n, 0, 0, &answer.n) < 0) {
 		close(fd);
 		return -2;
 	}
@@ -86,6 +92,194 @@ static int get_netnsid_from_name(const char *name)
 }
 #endif /* HAVE_NETNSID */
 
+struct nsid_cache {
+	struct hlist_node	nsid_hash;
+	struct hlist_node	name_hash;
+	int			nsid;
+	char			name[NAME_MAX];
+};
+
+#define NSIDMAP_SIZE		128
+#define NSID_HASH_NSID(nsid)	(nsid & (NSIDMAP_SIZE - 1))
+#define NSID_HASH_NAME(name)	(namehash(name) & (NSIDMAP_SIZE - 1))
+
+static struct hlist_head	nsid_head[NSIDMAP_SIZE];
+static struct hlist_head	name_head[NSIDMAP_SIZE];
+
+static struct nsid_cache *netns_map_get_by_nsid(int nsid)
+{
+	uint32_t h = NSID_HASH_NSID(nsid);
+	struct hlist_node *n;
+
+	hlist_for_each(n, &nsid_head[h]) {
+		struct nsid_cache *c = container_of(n, struct nsid_cache,
+						    nsid_hash);
+		if (c->nsid == nsid)
+			return c;
+	}
+
+	return NULL;
+}
+
+static int netns_map_add(int nsid, char *name)
+{
+	struct nsid_cache *c;
+	uint32_t h;
+
+	if (netns_map_get_by_nsid(nsid) != NULL)
+		return -EEXIST;
+
+	c = malloc(sizeof(*c));
+	if (c == NULL) {
+		perror("malloc");
+		return -ENOMEM;
+	}
+	c->nsid = nsid;
+	strcpy(c->name, name);
+
+	h = NSID_HASH_NSID(nsid);
+	hlist_add_head(&c->nsid_hash, &nsid_head[h]);
+
+	h = NSID_HASH_NAME(name);
+	hlist_add_head(&c->name_hash, &name_head[h]);
+
+	return 0;
+}
+
+static void netns_map_del(struct nsid_cache *c)
+{
+	hlist_del(&c->name_hash);
+	hlist_del(&c->nsid_hash);
+	free(c);
+}
+
+void netns_map_init(void)
+{
+	static int initialized;
+	struct dirent *entry;
+	DIR *dir;
+	int nsid;
+
+	if (initialized)
+		return;
+
+	if (rtnl_open(&rtnsh, 0) < 0) {
+		fprintf(stderr, "Cannot open rtnetlink\n");
+		exit(1);
+	}
+
+	dir = opendir(NETNS_RUN_DIR);
+	if (!dir)
+		return;
+
+	while ((entry = readdir(dir)) != NULL) {
+		if (strcmp(entry->d_name, ".") == 0)
+			continue;
+		if (strcmp(entry->d_name, "..") == 0)
+			continue;
+		nsid = get_netnsid_from_name(entry->d_name);
+
+		if (nsid >= 0)
+			netns_map_add(nsid, entry->d_name);
+	}
+	closedir(dir);
+	initialized = 1;
+}
+
+static int netns_get_name(int nsid, char *name)
+{
+	struct dirent *entry;
+	DIR *dir;
+	int id;
+
+	dir = opendir(NETNS_RUN_DIR);
+	if (!dir)
+		return -ENOENT;
+
+	while ((entry = readdir(dir)) != NULL) {
+		if (strcmp(entry->d_name, ".") == 0)
+			continue;
+		if (strcmp(entry->d_name, "..") == 0)
+			continue;
+		id = get_netnsid_from_name(entry->d_name);
+
+		if (nsid == id) {
+			strcpy(name, entry->d_name);
+			closedir(dir);
+			return 0;
+		}
+	}
+	closedir(dir);
+	return -ENOENT;
+}
+
+int print_nsid(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+{
+	struct rtgenmsg *rthdr = NLMSG_DATA(n);
+	struct rtattr *tb[NETNSA_MAX+1];
+	int len = n->nlmsg_len;
+	FILE *fp = (FILE*)arg;
+	struct nsid_cache *c;
+	char name[NAME_MAX];
+	int nsid;
+
+	if (n->nlmsg_type != RTM_NEWNSID && n->nlmsg_type != RTM_DELNSID)
+		return 0;
+
+	len -= NLMSG_SPACE(sizeof(*rthdr));
+	if (len < 0) {
+		fprintf(stderr, "BUG: wrong nlmsg len %d in %s\n", len,
+			__func__);
+		return -1;
+	}
+
+	parse_rtattr(tb, NETNSA_MAX, NETNS_RTA(rthdr), len);
+	if (tb[NETNSA_NSID] == NULL) {
+		fprintf(stderr, "BUG: NETNSA_NSID is missing %s\n", __func__);
+		return -1;
+	}
+
+	if (n->nlmsg_type == RTM_DELNSID)
+		fprintf(fp, "Deleted ");
+
+	nsid = rta_getattr_u32(tb[NETNSA_NSID]);
+	fprintf(fp, "nsid %u ", nsid);
+
+	c = netns_map_get_by_nsid(nsid);
+	if (c != NULL) {
+		fprintf(fp, "(iproute2 netns name: %s)", c->name);
+		netns_map_del(c);
+	}
+
+	/* During 'ip monitor nsid', no chance to have new nsid in cache. */
+	if (c == NULL && n->nlmsg_type == RTM_NEWNSID)
+		if (netns_get_name(nsid, name) == 0) {
+			fprintf(fp, "(iproute2 netns name: %s)", name);
+			netns_map_add(nsid, name);
+		}
+
+	fprintf(fp, "\n");
+	fflush(fp);
+	return 0;
+}
+
+static int netns_list_id(int argc, char **argv)
+{
+#ifdef HAVE_NETNSID
+	if (rtnl_wilddump_request(&rth, AF_UNSPEC, RTM_GETNSID) < 0) {
+		perror("Cannot send dump request");
+		exit(1);
+	}
+	if (rtnl_dump_filter(&rth, print_nsid, stdout) < 0) {
+		fprintf(stderr, "Dump terminated\n");
+		exit(1);
+	}
+#else
+	fprintf(stderr, "HAVE_NETNSID is not set\n");
+#endif
+	return 0;
+}
+
 static int netns_list(int argc, char **argv)
 {
 	struct dirent *entry;
@@ -532,6 +726,8 @@ static int netns_monitor(int argc, char **argv)
 
 int do_netns(int argc, char **argv)
 {
+	netns_map_init();
+
 	if (argc < 1)
 		return netns_list(0, NULL);
 
@@ -539,6 +735,9 @@ int do_netns(int argc, char **argv)
 	    (matches(*argv, "lst") == 0))
 		return netns_list(argc-1, argv+1);
 
+	if ((matches(*argv, "list-id") == 0))
+		return netns_list_id(argc-1, argv+1);
+
 	if (matches(*argv, "help") == 0)
 		return usage();
 
diff --git a/lib/ll_map.c b/lib/ll_map.c
index db34a2aae7b9..c6f70274416d 100644
--- a/lib/ll_map.c
+++ b/lib/ll_map.c
@@ -52,7 +52,7 @@ static struct ll_cache *ll_get_by_index(unsigned index)
 	return NULL;
 }
 
-static unsigned namehash(const char *str)
+unsigned namehash(const char *str)
 {
 	unsigned hash = 5381;
 
diff --git a/man/man8/ip-monitor.8 b/man/man8/ip-monitor.8
index 5ce8dc736efd..165414688e7b 100644
--- a/man/man8/ip-monitor.8
+++ b/man/man8/ip-monitor.8
@@ -49,7 +49,7 @@ command is the first in the command line and then the object list follows:
 is the list of object types that we want to monitor.
 It may contain
 .BR link ", " address ", " route ", " mroute ", " prefix ", "
-.BR neigh ", " netconf " and " rule "."
+.BR neigh ", " netconf ", "  rule " and " nsid "."
 If no
 .B file
 argument is given,
diff --git a/man/man8/ip-netns.8 b/man/man8/ip-netns.8
index d34cdfe3783a..8d59437e1e9f 100644
--- a/man/man8/ip-netns.8
+++ b/man/man8/ip-netns.8
@@ -42,6 +42,9 @@ ip-netns \- process network namespace management
 .ti -8
 .BR "ip netns monitor"
 
+.ti -8
+.BR "ip netns list-id"
+
 .SH DESCRIPTION
 A network namespace is logically another copy of the network stack,
 with its own routes, firewall rules, and network devices.
@@ -172,6 +175,13 @@ executing.
 This command watches network namespace name addition and deletion events
 and prints a line for each event it sees.
 
+.TP
+.B ip netns list-id - list network namespace ids (nsid)
+.sp
+Network namespace ids are used to identify a peer network namespace. This
+command displays nsid of the current network namespace and provides the
+corresponding iproute2 netns name (from /var/run/netns) if any.
+
 .SH EXAMPLES
 .PP
 ip netns list
-- 
2.2.2
