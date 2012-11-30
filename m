From: Cong Wang <amwang@redhat.com>
Subject: [PATCH iproute2 v1] Add mdb command to bridge
Date: Fri, 30 Nov 2012 17:58:34 +0800
Message-ID: <1354269514-1863-3-git-send-email-amwang@redhat.com>
References: <1354269514-1863-1-git-send-email-amwang@redhat.com>
Cc: Cong Wang <amwang@redhat.com>, bridge@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Jesper Dangaard Brouer <brouer@redhat.com>, Thomas Graf <tgraf@suug.ch>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1354269514-1863-1-git-send-email-amwang@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Sample output:

	# ./bridge/bridge mdb
	bridge dev br0
	multicast database:
	port no 1, multicast addr 224.8.8.9
	port no 2, multicast addr 224.8.8.8
	router ports: 2

TODO: display device name too

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Thomas Graf <tgraf@suug.ch>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 bridge/Makefile           |    2 +-
 bridge/br_common.h        |   35 ++++++++++
 bridge/bridge.c           |    1 +
 bridge/mdb.c              |  157 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/rtnetlink.h |    3 +
 5 files changed, 197 insertions(+), 1 deletions(-)

diff --git a/bridge/Makefile b/bridge/Makefile
index 9a6743e..67aceb4 100644
--- a/bridge/Makefile
+++ b/bridge/Makefile
@@ -1,4 +1,4 @@
-BROBJ = bridge.o fdb.o monitor.o link.o
+BROBJ = bridge.o fdb.o monitor.o link.o mdb.o
 
 include ../Config
 
diff --git a/bridge/br_common.h b/bridge/br_common.h
index 718ecb9..83b2b9f 100644
--- a/bridge/br_common.h
+++ b/bridge/br_common.h
@@ -5,6 +5,7 @@ extern int print_fdb(const struct sockaddr_nl *who,
 		     struct nlmsghdr *n, void *arg);
 
 extern int do_fdb(int argc, char **argv);
+extern int do_mdb(int argc, char **argv);
 extern int do_monitor(int argc, char **argv);
 
 extern int preferred_family;
@@ -12,3 +13,37 @@ extern int show_stats;
 extern int show_detail;
 extern int timestamp;
 extern struct rtnl_handle rth;
+
+/* Bridge multicast database attributes
+ * [MDBA_MDB] = {
+ *    [MDBA_MCADDR]
+ *    [MDBA_BRPORT_NO]
+ * }
+ * [MDBA_ROUTER] = {
+ *    [MDBA_BRPORT_NO]
+ * }
+ */
+enum {
+	MDBA_UNSPEC,
+	MDBA_MDB,
+	MDBA_ROUTER,
+	__MDBA_MAX,
+};
+#define MDBA_MAX (__MDBA_MAX - 1)
+
+enum {
+	MDBA_MDB_UNSPEC,
+	MDBA_MCADDR,
+	MDBA_BRPORT_NO,
+	__MDBA_MDB_MAX,
+};
+#define MDBA_MDB_MAX (__MDBA_MDB_MAX - 1)
+
+struct br_port_msg {
+        int ifindex;
+};
+
+#ifndef MDBA_RTA
+#define MDBA_RTA(r) \
+	((struct rtattr*)(((char*)(r)) + NLMSG_ALIGN(sizeof(struct br_port_msg))))
+#endif
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
index 0000000..f2f4ff2
--- /dev/null
+++ b/bridge/mdb.c
@@ -0,0 +1,157 @@
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
+#include <string.h>
+#include <arpa/inet.h>
+
+#include "libnetlink.h"
+#include "br_common.h"
+#include "rt_names.h"
+#include "utils.h"
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
+	uint16_t *port_no;
+	struct rtattr *i;
+	int rem;
+
+	fprintf(f, "router ports: ");
+
+	rem = RTA_PAYLOAD(attr);
+	for (i = RTA_DATA(attr); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+		port_no = RTA_DATA(i);
+		fprintf(f, "%u ", *port_no);
+	}
+	fprintf(f, "\n");
+}
+
+static void br_print_mdb_entry(FILE *f, struct rtattr *attr)
+{
+	uint32_t addr;
+	uint16_t port_no;
+	struct rtattr *i;
+	int rem;
+	SPRINT_BUF(abuf);
+
+	fprintf(f, "multicast database:\n");
+
+	rem = RTA_PAYLOAD(attr);
+	for (i = RTA_DATA(attr); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
+		port_no = rta_getattr_u16(i);
+		i = RTA_NEXT(i, rem);
+		addr = rta_getattr_u32(i);
+		fprintf(f, "port no %u, multicast addr %s\n", port_no, inet_ntop(AF_INET, &addr, abuf, sizeof(abuf)));
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
+		fprintf(stderr, "Not RTM_MDB: %08x %08x %08x\n",
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
+	if (tb[MDBA_MDB])
+		br_print_mdb_entry(fp, tb[MDBA_MDB]);
+
+	if (tb[MDBA_ROUTER])
+		br_print_router_ports(fp, tb[MDBA_ROUTER]);
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
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 0e3e0c1..f400b5e 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -120,6 +120,9 @@ enum {
 	RTM_SETDCB,
 #define RTM_SETDCB RTM_SETDCB
 
+	RTM_GETMDB = 86,
+#define RTM_GETMDB RTM_GETMDB
+
 	__RTM_MAX,
 #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
 };
