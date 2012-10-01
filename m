From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] iproute2: manage VXLAN forwarding entries
Date: Mon, 1 Oct 2012 14:02:49 -0700
Message-ID: <20121001140249.797371b3@nehalam.linuxnetplumber.net>
References: <20120925150957.78591205@nehalam.linuxnetplumber.net>
	<20120927.184740.975766966558033959.davem@davemloft.net>
	<20120927160054.105f4711@nehalam.linuxnetplumber.net>
	<20120927.191200.1483743406607177228.davem@davemloft.net>
	<20121001140206.2bbf9c41@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jesse@nicira.com,
	chrisw@redhat.com, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49514 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757456Ab2JAVDg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2012 17:03:36 -0400
In-Reply-To: <20121001140206.2bbf9c41@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow extending bridge forwarding table to handle VXLAN as well.
Change format of output to be close to 'ip neighbour'
---
 bridge/br_common.h |    1 +
 bridge/bridge.c    |   18 ++++++++
 bridge/fdb.c       |  129 +++++++++++++++++++++++++++++++---------------------
 3 files changed, 97 insertions(+), 51 deletions(-)

diff --git a/bridge/br_common.h b/bridge/br_common.h
index ec1671d..718ecb9 100644
--- a/bridge/br_common.h
+++ b/bridge/br_common.h
@@ -7,6 +7,7 @@ extern int print_fdb(const struct sockaddr_nl *who,
 extern int do_fdb(int argc, char **argv);
 extern int do_monitor(int argc, char **argv);
 
+extern int preferred_family;
 extern int show_stats;
 extern int show_detail;
 extern int timestamp;
diff --git a/bridge/bridge.c b/bridge/bridge.c
index 4702340..e2c33b0 100644
--- a/bridge/bridge.c
+++ b/bridge/bridge.c
@@ -15,6 +15,7 @@
 #include "br_common.h"
 
 struct rtnl_handle rth = { .fd = -1 };
+int preferred_family = AF_UNSPEC;
 int resolve_hosts;
 int show_stats;
 int show_details;
@@ -86,6 +87,23 @@ main(int argc, char **argv)
 			++show_details;
 		} else if (matches(opt, "-timestamp") == 0) {
 			++timestamp;
+                } else if (matches(opt, "-family") == 0) {
+			argc--;
+			argv++;
+			if (argc <= 1)
+				usage();
+			if (strcmp(argv[1], "inet") == 0)
+				preferred_family = AF_INET;
+			else if (strcmp(argv[1], "inet6") == 0)
+				preferred_family = AF_INET6;
+			else if (strcmp(argv[1], "help") == 0)
+				usage();
+			else
+				invarg("invalid protocol family", argv[1]);
+		} else if (strcmp(opt, "-4") == 0) {
+			preferred_family = AF_INET;
+		} else if (strcmp(opt, "-6") == 0) {
+			preferred_family = AF_INET6;
 		} else {
 			fprintf(stderr, "Option \"%s\" is unknown, try \"bridge help\".\n", opt);
 			exit(-1);
diff --git a/bridge/fdb.c b/bridge/fdb.c
index eaefa81..6041acc 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -1,6 +1,8 @@
 /*
  * Get/set/delete fdb table with netlink
  *
+ * TODO: merge/replace this with ip neighbour
+ *
  * Authors:	Stephen Hemminger <shemminger@vyatta.com>
  */
 
@@ -20,13 +22,14 @@
 
 #include "libnetlink.h"
 #include "br_common.h"
+#include "rt_names.h"
 #include "utils.h"
 
 int filter_index;
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: bridge fdb { add | del } ADDR dev DEV {self|master}\n");
+	fprintf(stderr, "Usage: bridge fdb { add | del } ADDR dev DEV {self|master} [ temp ] [ dst IPADDR]\n");
 	fprintf(stderr, "       bridge fdb {show} [ dev DEV ]\n");
 	exit(-1);
 }
@@ -35,15 +38,15 @@ static const char *state_n2a(unsigned s)
 {
 	static char buf[32];
 
-	if (s & NUD_PERMANENT) 
-		return "local";
+	if (s & NUD_PERMANENT)
+		return "permanent";
 
 	if (s & NUD_NOARP)
 		return "static";
 
 	if (s & NUD_STALE)
 		return "stale";
-	
+
 	if (s & NUD_REACHABLE)
 		return "";
 
@@ -51,24 +54,19 @@ static const char *state_n2a(unsigned s)
 	return buf;
 }
 
-static char *fmt_time(char *b, size_t l, unsigned long tick)
-{
-	static int hz;
-	
-	if (hz == 0)
-		hz = __get_user_hz();
-
-	snprintf(b, l, "%lu.%02lu", tick / hz, ((tick % hz) * hz) / 100);
-	return b;
-}
-
 int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 {
+	FILE *fp = arg;
 	struct ndmsg *r = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr * tb[NDA_MAX+1];
-	const __u8 *addr = NULL;
-	char b1[32];
+
+	if (n->nlmsg_type != RTM_NEWNEIGH && n->nlmsg_type != RTM_DELNEIGH) {
+		fprintf(stderr, "Not RTM_NEWNEIGH: %08x %08x %08x\n",
+			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
+
+		return 0;
+	}
 
 	len -= NLMSG_LENGTH(sizeof(*r));
 	if (len < 0) {
@@ -86,37 +84,49 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		     n->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
 
 	if (n->nlmsg_type == RTM_DELNEIGH)
-		printf("Deleted ");
-
-	if (tb[NDA_LLADDR])
-		addr = RTA_DATA(tb[NDA_LLADDR]);
-	else {
-		fprintf(stderr, "missing lladdr\n");
-		return -1;
+		fprintf(fp, "Deleted ");
+
+	if (tb[NDA_LLADDR]) {
+		SPRINT_BUF(b1);
+		fprintf(fp, "%s ",
+			ll_addr_n2a(RTA_DATA(tb[NDA_LLADDR]),
+				    RTA_PAYLOAD(tb[NDA_LLADDR]),
+				    ll_index_to_type(r->ndm_ifindex),
+				    b1, sizeof(b1)));
 	}
-
-	printf("%s\t%.2x:%.2x:%.2x:%.2x:%.2x:%.2x\t%s %s",
-		ll_index_to_name(r->ndm_ifindex),
-		addr[0], addr[1], addr[2],
-		addr[3], addr[4], addr[5],
-		state_n2a(r->ndm_state),
-		(r->ndm_flags & NTF_SELF) ? "self" : "master");
-
+	
+	if (!filter_index && r->ndm_ifindex)
+		fprintf(fp, "dev %s ", ll_index_to_name(r->ndm_ifindex));
+
+	if (tb[NDA_DST]) {
+		SPRINT_BUF(abuf);
+		fprintf(fp, "dst %s ",
+			format_host(AF_INET,
+				    RTA_PAYLOAD(tb[NDA_DST]),
+				    RTA_DATA(tb[NDA_DST]),
+				    abuf, sizeof(abuf)));
+	}
+		
 	if (show_stats && tb[NDA_CACHEINFO]) {
 		struct nda_cacheinfo *ci = RTA_DATA(tb[NDA_CACHEINFO]);
+		int hz = get_user_hz();
 
-		printf("\t%8s", fmt_time(b1, sizeof(b1), ci->ndm_updated));
-		printf(" %8s", fmt_time(b1, sizeof(b1), ci->ndm_used));
+		fprintf(fp, " used %d/%d", ci->ndm_used/hz,
+		       ci->ndm_updated/hz);
 	}
-	printf("\n");
+	if (r->ndm_flags & NTF_SELF)
+		fprintf(fp, "self ");
+	if (r->ndm_flags & NTF_MASTER)
+		fprintf(fp, "master ");
 
+	fprintf(fp, "%s\n", state_n2a(r->ndm_state));
 	return 0;
 }
 
 static int fdb_show(int argc, char **argv)
 {
 	char *filter_dev = NULL;
-	
+
 	while (argc > 0) {
 		if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
@@ -128,8 +138,10 @@ static int fdb_show(int argc, char **argv)
 	}
 
 	if (filter_dev) {
-		if ((filter_index = if_nametoindex(filter_dev)) == 0) {
-			fprintf(stderr, "Cannot find device \"%s\"\n", filter_dev);
+		filter_index = if_nametoindex(filter_dev);
+		if (filter_index == 0) {
+			fprintf(stderr, "Cannot find device \"%s\"\n",
+				filter_dev);
 			return -1;
 		}
 	}
@@ -138,11 +150,8 @@ static int fdb_show(int argc, char **argv)
 		perror("Cannot send dump request");
 		exit(1);
 	}
-	
-	printf("port\tmac addr\t\tflags%s\n",
-	       show_stats ? "\t updated     used" : "");
 
-	if (rtnl_dump_filter(&rth, print_fdb, NULL) < 0) {
+	if (rtnl_dump_filter(&rth, print_fdb, stdout) < 0) {
 		fprintf(stderr, "Dump terminated\n");
 		exit(1);
 	}
@@ -160,6 +169,8 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 	char *addr = NULL;
 	char *d = NULL;
 	char abuf[ETH_ALEN];
+	int dst_ok = 0;
+	inet_prefix dst;
 
 	memset(&req, 0, sizeof(req));
 
@@ -173,21 +184,27 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 		if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
 			d = *argv;
-		} else if (strcmp(*argv, "local") == 0) {
-			req.ndm.ndm_state = NUD_PERMANENT;
-		} else if (strcmp(*argv, "temp") == 0) {
-			req.ndm.ndm_state = NUD_REACHABLE;
+		} else if (strcmp(*argv, "dst") == 0) {
+			NEXT_ARG();
+			if (dst_ok)
+				duparg2("dst", *argv);
+			get_addr(&dst, *argv, preferred_family);
+			dst_ok = 1;
 		} else if (strcmp(*argv, "self") == 0) {
 			req.ndm.ndm_flags |= NTF_SELF;
-		} else if (strcmp(*argv, "master") == 0) {
+		} else if (matches(*argv, "master") == 0) {
 			req.ndm.ndm_flags |= NTF_MASTER;
+		} else if (matches(*argv, "local") == 0|| 
+			   matches(*argv, "permanent") == 0) {
+			req.ndm.ndm_state |= NUD_PERMANENT;
+		} else if (matches(*argv, "temp") == 0) {
+			req.ndm.ndm_state |= NUD_REACHABLE;
 		} else {
 			if (strcmp(*argv, "to") == 0) {
 				NEXT_ARG();
 			}
-			if (matches(*argv, "help") == 0) {
-				NEXT_ARG();
-			}
+			if (matches(*argv, "help") == 0)
+				usage();
 			if (addr)
 				duparg2("to", *argv);
 			addr = *argv;
@@ -200,7 +217,15 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 		exit(-1);
 	}
 
-	if (sscanf(addr, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx", 
+	/* Assume self */
+	if (!(req.ndm.ndm_flags&(NTF_SELF|NTF_MASTER)))
+		req.ndm.ndm_flags |= NTF_SELF;
+
+	/* Assume permanent */
+	if (!(req.ndm.ndm_state&(NUD_PERMANENT|NUD_REACHABLE)))
+		req.ndm.ndm_state |= NUD_PERMANENT;
+
+	if (sscanf(addr, "%hhx:%hhx:%hhx:%hhx:%hhx:%hhx",
 		   abuf, abuf+1, abuf+2,
 		   abuf+3, abuf+4, abuf+5) != 6) {
 		fprintf(stderr, "Invalid mac address %s\n", addr);
@@ -208,6 +233,8 @@ static int fdb_modify(int cmd, int flags, int argc, char **argv)
 	}
 
 	addattr_l(&req.n, sizeof(req), NDA_LLADDR, abuf, ETH_ALEN);
+	if (dst_ok)
+		addattr_l(&req.n, sizeof(req), NDA_DST, &dst.data, dst.bytelen);
 
 	req.ndm.ndm_ifindex = ll_name_to_index(d);
 	if (req.ndm.ndm_ifindex == 0) {
-- 
1.7.10.4
