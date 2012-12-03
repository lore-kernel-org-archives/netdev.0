From: Cong Wang <amwang@redhat.com>
Subject: [PATCH iproute2 v2] Add mdb command to bridge
Date: Mon,  3 Dec 2012 21:03:44 +0800
Message-ID: <1354539824-7898-2-git-send-email-amwang@redhat.com>
References: <1354539824-7898-1-git-send-email-amwang@redhat.com>
Cc: bridge@lists.linux-foundation.org, Cong Wang <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Graf <tgraf@suug.ch>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15756 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752354Ab2LCNEa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2012 08:04:30 -0500
In-Reply-To: <1354539824-7898-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

V2: sync with the kernel patch
    handle IPv6 addr
    a few cleanup

Sample output:

	# ./bridge/bridge mdb
	bridge dev br0
	multicast database:
	port eth0, group 224.8.8.9
	port eth1, group 224.8.8.8
	router ports: 2

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 bridge/Makefile    |    2 +-
 bridge/br_common.h |    1 +
 bridge/bridge.c    |    1 +
 bridge/mdb.c       |  181 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 184 insertions(+), 1 deletions(-)

diff --git a/bridge/Makefile b/bridge/Makefile
index 9a6743e..67aceb4 100644
--- a/bridge/Makefile
+++ b/bridge/Makefile
@@ -1,4 +1,4 @@
-BROBJ = bridge.o fdb.o monitor.o link.o
+BROBJ = bridge.o fdb.o monitor.o link.o mdb.o
 
 include ../Config
 
diff --git a/bridge/br_common.h b/bridge/br_common.h
index 718ecb9..67fd75c 100644
--- a/bridge/br_common.h
+++ b/bridge/br_common.h
@@ -5,6 +5,7 @@ extern int print_fdb(const struct sockaddr_nl *who,
 		     struct nlmsghdr *n, void *arg);
 
 extern int do_fdb(int argc, char **argv);
+extern int do_mdb(int argc, char **argv);
 extern int do_monitor(int argc, char **argv);
 
 extern int preferred_family;
diff --git a/bridge/bridge.c b/bridge/bridge.c
index e2c33b0..1fcd365 100644
--- a/bridge/bridge.c
+++ b/bridge/bridge.c
@@ -43,6 +43,7 @@ static const struct cmd {
 	int (*func)(int argc, char **argv);
 } cmds[] = {
 	{ "fdb", 	do_fdb },
+	{ "mdb", 	do_mdb },
 	{ "monitor",	do_monitor },
 	{ "help",	do_help },
 	{ 0 }
diff --git a/bridge/mdb.c b/bridge/mdb.c
new file mode 100644
index 0000000..3e62331
--- /dev/null
+++ b/bridge/mdb.c
@@ -0,0 +1,181 @@
+/*
+ * Get mdb table with netlink
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <time.h>
+#include <fcntl.h>
+#include <sys/socket.h>
+#include <sys/time.h>
+#include <net/if.h>
+#include <netinet/in.h>
+#include <linux/if_bridge.h>
+#include <linux/if_ether.h>
+#include <linux/neighbour.h>
+#include <linux/if_bridge.h>
+#include <string.h>
+#include <arpa/inet.h>
+
+#include "libnetlink.h"
+#include "br_common.h"
+#include "rt_names.h"
+#include "utils.h"
+
+#ifndef MDBA_RTA
+#define MDBA_RTA(r) \
+	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct br_port_msg))))
+#endif
+
+int filter_index;
+
+static void usage(void)
+{
+	fprintf(stderr, "       bridge mdb {show} [ dev DEV ]\n");
+	exit(-1);
+}
+
+static void br_print_router_ports(FILE *f, struct rtattr *attr)
+{
+	uint32_t *port_ifindex;
+	struct rtattr *i;
+	int rem;
+
+	rem = RTA_PAYLOAD(attr);
+	for (i = RTA_DATA(attr); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+		port_ifindex = RTA_DATA(i);
+		fprintf(f, "%s ", ll_index_to_name(*port_ifindex));
+	}
+	fprintf(f, "\n");
+}
+
+static void print_mdb_entry(FILE *f, struct br_mdb_entry *e)
+{
+	SPRINT_BUF(abuf);
+
+	if (e->addr.proto == htons(ETH_P_IP))
+		fprintf(f, "port %s, group %s\n", ll_index_to_name(e->ifindex),
+			inet_ntop(AF_INET, &e->addr.u.ip4, abuf, sizeof(abuf)));
+	else
+		fprintf(f, "port %s, group %s\n", ll_index_to_name(e->ifindex),
+			inet_ntop(AF_INET6, &e->addr.u.ip6, abuf, sizeof(abuf)));
+}
+
+static void br_print_mdb_entry(FILE *f, struct rtattr *attr)
+{
+	struct rtattr *i;
+	int rem;
+	struct br_mdb_entry *e;
+
+	rem = RTA_PAYLOAD(attr);
+	for (i = RTA_DATA(attr); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+		e = RTA_DATA(i);
+		print_mdb_entry(f, e);
+	}
+}
+
+int print_mdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+{
+	FILE *fp = arg;
+	struct br_port_msg *r = NLMSG_DATA(n);
+	int len = n->nlmsg_len;
+	struct rtattr * tb[MDBA_MAX+1];
+
+	if (n->nlmsg_type != RTM_GETMDB) {
+		fprintf(stderr, "Not RTM_GETMDB: %08x %08x %08x\n",
+			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
+
+		return 0;
+	}
+
+	len -= NLMSG_LENGTH(sizeof(*r));
+	if (len < 0) {
+		fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
+		return -1;
+	}
+
+	if (filter_index && filter_index != r->ifindex)
+		return 0;
+
+	if (!filter_index && r->ifindex)
+		fprintf(fp, "bridge dev %s\n", ll_index_to_name(r->ifindex));
+
+	parse_rtattr(tb, MDBA_MAX, MDBA_RTA(r), n->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
+
+	if (tb[MDBA_MDB]) {
+		struct rtattr *i;
+		int rem = RTA_PAYLOAD(tb[MDBA_MDB]);
+
+		fprintf(fp, "multicast database:\n");
+
+		for (i = RTA_DATA(tb[MDBA_MDB]); RTA_OK(i, rem); i = RTA_NEXT(i, rem))
+			br_print_mdb_entry(fp, i);
+	}
+
+	if (tb[MDBA_ROUTER]) {
+		struct rtattr *i;
+		int rem = RTA_PAYLOAD(tb[MDBA_ROUTER]);
+
+		fprintf(fp, "router ports: ");
+
+		for (i = RTA_DATA(tb[MDBA_ROUTER]); RTA_OK(i, rem); i = RTA_NEXT(i, rem))
+			br_print_router_ports(fp, i);
+	}
+
+	return 0;
+}
+
+static int mdb_show(int argc, char **argv)
+{
+	char *filter_dev = NULL;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "dev") == 0) {
+			NEXT_ARG();
+			if (filter_dev)
+				duparg("dev", *argv);
+			filter_dev = *argv;
+		}
+		argc--; argv++;
+	}
+
+	if (filter_dev) {
+		filter_index = if_nametoindex(filter_dev);
+		if (filter_index == 0) {
+			fprintf(stderr, "Cannot find device \"%s\"\n",
+				filter_dev);
+			return -1;
+		}
+	}
+
+	if (rtnl_wilddump_request(&rth, PF_BRIDGE, RTM_GETMDB) < 0) {
+		perror("Cannot send dump request");
+		exit(1);
+	}
+
+	if (rtnl_dump_filter(&rth, print_mdb, stdout) < 0) {
+		fprintf(stderr, "Dump terminated\n");
+		exit(1);
+	}
+
+	return 0;
+}
+
+int do_mdb(int argc, char **argv)
+{
+	ll_init_map(&rth);
+
+	if (argc > 0) {
+		if (matches(*argv, "show") == 0 ||
+		    matches(*argv, "lst") == 0 ||
+		    matches(*argv, "list") == 0)
+			return mdb_show(argc-1, argv+1);
+		if (matches(*argv, "help") == 0)
+			usage();
+	} else
+		return mdb_show(0, NULL);
+
+	fprintf(stderr, "Command \"%s\" is unknown, try \"bridge mdb help\".\n", *argv);
+	exit(-1);
+}
