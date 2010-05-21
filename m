From: Dan Smith <danms@us.ibm.com>
Subject: [PATCH] Add ip route {save,restore}
Date: Fri, 21 May 2010 09:45:11 -0700
Message-ID: <1274460311-4036-1-git-send-email-danms@us.ibm.com>
Cc: netdev@vger.kernel.org
To: shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:51695 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755950Ab0EUQpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 12:45:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds save and restore commands to "ip route". Save dumps
the RTNL stream to stdout which can then be passed to restore later.
This may be helpful in some normal situations, and will allow C/R to
migrate the routing information in userspace.  Tweaking of the stream
can be done by userspace helpers to convert between versions and adjust
things like device indexes when restoring routes in a different
environment.

By factoring out some of the common bits of print_route() into
filter_nlmsg(), the "save" command can use the same selection logic
as "list," allowing the caller to save only specific routes as
necessary.

The only change since the RFC is the addition of manpage and doc
material.

Signed-off-by: Dan Smith <danms@us.ibm.com>
---
 doc/ip-cref.tex |   35 +++++++++++
 ip/iproute.c    |  169 +++++++++++++++++++++++++++++++++++++++++--------------
 man/man8/ip.8   |   22 +++++++
 3 files changed, 184 insertions(+), 42 deletions(-)

diff --git a/doc/ip-cref.tex b/doc/ip-cref.tex
index 056e3bf..d8fed66 100644
--- a/doc/ip-cref.tex
+++ b/doc/ip-cref.tex
@@ -1675,6 +1675,41 @@ information about this route is shown:
 \item \verb|used| --- the number of lookups of this route since its creation.
 \end{itemize}
 
+\subsection{{\tt ip route save} -- save routing tables}
+\label{IP-ROUTE-SAVE}
+
+\paragraph{Description:} this command saves the contents of the routing
+tables or the route(s) selected by some criteria to standard output.
+
+\paragraph{Arguments:} \verb|ip route save| has the same arguments as
+\verb|ip route show|.
+
+\paragraph{Example:} This saves all the routes to the {\tt saved\_routes}
+file:
+\begin{verbatim}
+dan@caffeine:~ # ip route save > saved_routes
+\end{verbatim}
+
+\paragraph{Output format:} The format of the data stream provided by
+\verb|ip route save| is that of \verb|rtnetlink|.  See
+\verb|rtnetlink(7)| for more information.
+
+\subsection{{\tt ip route restore} -- restore routing tables}
+\label{IP-ROUTE-RESTORE}
+
+\paragraph{Description:} this command restores the contents of the routing
+tables according to a data stream as provided by \verb|ip route save| via
+standard input.  Note that any routes already in the table are left unchanged.
+Any routes in the input stream that already exist in the tables are ignored.
+
+\paragraph{Arguments:} This command takes no arguments.
+
+\paragraph{Example:} This restores all routes that were saved to the
+{\tt saved\_routes} file:
+
+\begin{verbatim}
+dan@caffeine:~ # ip route restore < saved_routes
+\end{verbatim}
 
 \subsection{{\tt ip route flush} --- flush routing tables}
 \label{IP-ROUTE-FLUSH}
diff --git a/ip/iproute.c b/ip/iproute.c
index 8252e18..3049975 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -23,6 +23,7 @@
 #include <netinet/ip.h>
 #include <arpa/inet.h>
 #include <linux/in_route.h>
+#include <errno.h>
 
 #include "rt_names.h"
 #include "utils.h"
@@ -32,7 +33,11 @@
 #define RTAX_RTTVAR RTAX_HOPS
 #endif
 
-
+enum list_action {
+	IPROUTE_LIST,
+	IPROUTE_FLUSH,
+	IPROUTE_SAVE,
+};
 static const char *mx_names[RTAX_MAX+1] = {
 	[RTAX_MTU]	= "mtu",
 	[RTAX_WINDOW]	= "window",
@@ -53,6 +58,8 @@ static void usage(void) __attribute__((noreturn));
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip route { list | flush } SELECTOR\n");
+	fprintf(stderr, "       ip route save SELECTOR\n");
+	fprintf(stderr, "       ip route restore\n");
 	fprintf(stderr, "       ip route get ADDRESS [ from ADDRESS iif STRING ]\n");
 	fprintf(stderr, "                            [ oif STRING ]  [ tos TOS ]\n");
 	fprintf(stderr, "       ip route { add | del | change | append | replace | monitor } ROUTE\n");
@@ -115,46 +122,16 @@ static int flush_update(void)
 	return 0;
 }
 
-int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+int filter_nlmsg(struct nlmsghdr *n, struct rtattr **tb, int host_len)
 {
-	FILE *fp = (FILE*)arg;
 	struct rtmsg *r = NLMSG_DATA(n);
-	int len = n->nlmsg_len;
-	struct rtattr * tb[RTA_MAX+1];
-	char abuf[256];
 	inet_prefix dst;
 	inet_prefix src;
-	inet_prefix prefsrc;
 	inet_prefix via;
-	int host_len = -1;
-	static int ip6_multiple_tables;
+	inet_prefix prefsrc;
 	__u32 table;
-	SPRINT_BUF(b1);
-	static int hz;
-
-	if (n->nlmsg_type != RTM_NEWROUTE && n->nlmsg_type != RTM_DELROUTE) {
-		fprintf(stderr, "Not a route: %08x %08x %08x\n",
-			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
-		return 0;
-	}
-	if (filter.flushb && n->nlmsg_type != RTM_NEWROUTE)
-		return 0;
-	len -= NLMSG_LENGTH(sizeof(*r));
-	if (len < 0) {
-		fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
-		return -1;
-	}
-
-	if (r->rtm_family == AF_INET6)
-		host_len = 128;
-	else if (r->rtm_family == AF_INET)
-		host_len = 32;
-	else if (r->rtm_family == AF_DECnet)
-		host_len = 16;
-	else if (r->rtm_family == AF_IPX)
-		host_len = 80;
+	static int ip6_multiple_tables;
 
-	parse_rtattr(tb, RTA_MAX, RTM_RTA(r), len);
 	table = rtm_get_table(r, tb);
 
 	if (r->rtm_family == AF_INET6 && table != RT_TABLE_MAIN)
@@ -281,6 +258,56 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	    *(int*)RTA_DATA(tb[RTA_PRIORITY]) == -1)
 		return 0;
 
+	return 1;
+}
+
+int calc_host_len(struct rtmsg *r)
+{
+	if (r->rtm_family == AF_INET6)
+		return 128;
+	else if (r->rtm_family == AF_INET)
+		return 32;
+	else if (r->rtm_family == AF_DECnet)
+		return 16;
+	else if (r->rtm_family == AF_IPX)
+		return 80;
+	else
+		return -1;
+}
+
+int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+{
+	FILE *fp = (FILE*)arg;
+	struct rtmsg *r = NLMSG_DATA(n);
+	int len = n->nlmsg_len;
+	struct rtattr * tb[RTA_MAX+1];
+	char abuf[256];
+	int host_len = -1;
+	__u32 table;
+	SPRINT_BUF(b1);
+	static int hz;
+
+	if (n->nlmsg_type != RTM_NEWROUTE && n->nlmsg_type != RTM_DELROUTE) {
+		fprintf(stderr, "Not a route: %08x %08x %08x\n",
+			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
+		return 0;
+	}
+	if (filter.flushb && n->nlmsg_type != RTM_NEWROUTE)
+		return 0;
+	len -= NLMSG_LENGTH(sizeof(*r));
+	if (len < 0) {
+		fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
+		return -1;
+	}
+
+	host_len = calc_host_len(r);
+
+ 	parse_rtattr(tb, RTA_MAX, RTM_RTA(r), len);
+	table = rtm_get_table(r, tb);
+
+	if (!filter_nlmsg(n, tb, host_len))
+		return 0;
+
 	if (filter.flushb) {
 		struct nlmsghdr *fn;
 		if (NLMSG_ALIGN(filter.flushp) + n->nlmsg_len > filter.flushe) {
@@ -1041,17 +1068,51 @@ static int iproute_flush_cache(void)
 	return 0;
 }
 
+int save_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+{
+	int ret;
+	int len = n->nlmsg_len;
+	struct rtmsg *r = NLMSG_DATA(n);
+	struct rtattr *tb[RTA_MAX+1];
+	int host_len = -1;
+
+	if (isatty(STDOUT_FILENO)) {
+		fprintf(stderr, "Not sending binary stream to stdout\n");
+		return -1;
+	}
+
+	host_len = calc_host_len(r);
+	len -= NLMSG_LENGTH(sizeof(*r));
+ 	parse_rtattr(tb, RTA_MAX, RTM_RTA(r), len);
+
+	if (!filter_nlmsg(n, tb, host_len))
+		return 0;
+
+	ret = write(STDOUT_FILENO, n, n->nlmsg_len);
+	if ((ret > 0) && (ret != n->nlmsg_len)) {
+		fprintf(stderr, "Short write while saving nlmsg\n");
+		ret = -EIO;
+	}
+
+	return ret == n->nlmsg_len ? 0 : ret;
+}
 
-static int iproute_list_or_flush(int argc, char **argv, int flush)
+static int iproute_list_flush_or_save(int argc, char **argv, int action)
 {
 	int do_ipv6 = preferred_family;
 	char *id = NULL;
 	char *od = NULL;
+	rtnl_filter_t filter_fn;
+
+	if (action == IPROUTE_SAVE)
+		filter_fn = save_route;
+	else
+		filter_fn = print_route;
 
 	iproute_reset_filter();
 	filter.tb = RT_TABLE_MAIN;
 
-	if (flush && argc <= 0) {
+	if ((action == IPROUTE_FLUSH) && argc <= 0) {
 		fprintf(stderr, "\"ip route flush\" requires arguments.\n");
 		return -1;
 	}
@@ -1201,7 +1262,7 @@ static int iproute_list_or_flush(int argc, char **argv, int flush)
 		}
 	}
 
-	if (flush) {
+	if (action == IPROUTE_FLUSH) {
 		int round = 0;
 		char flushb[4096-512];
 		time_t start = time(0);
@@ -1226,7 +1287,7 @@ static int iproute_list_or_flush(int argc, char **argv, int flush)
 				exit(1);
 			}
 			filter.flushed = 0;
-			if (rtnl_dump_filter(&rth, print_route, stdout, NULL, NULL) < 0) {
+			if (rtnl_dump_filter(&rth, filter_fn, stdout, NULL, NULL) < 0) {
 				fprintf(stderr, "Flush terminated\n");
 				exit(1);
 			}
@@ -1269,7 +1330,7 @@ static int iproute_list_or_flush(int argc, char **argv, int flush)
 		}
 	}
 
-	if (rtnl_dump_filter(&rth, print_route, stdout, NULL, NULL) < 0) {
+	if (rtnl_dump_filter(&rth, filter_fn, stdout, NULL, NULL) < 0) {
 		fprintf(stderr, "Dump terminated\n");
 		exit(1);
 	}
@@ -1436,6 +1497,26 @@ int iproute_get(int argc, char **argv)
 	exit(0);
 }
 
+int restore_handler(struct sockaddr_nl *nl, struct nlmsghdr *n, void *arg)
+{
+	int ret;
+
+	n->nlmsg_flags |= NLM_F_REQUEST | NLM_F_CREATE | NLM_F_ACK;
+
+	ll_init_map(&rth);
+
+	ret = rtnl_talk(&rth, n, 0, 0, n, NULL, NULL);
+	if ((ret < 0) && (errno == EEXIST))
+		ret = 0;
+
+	return ret;
+}
+
+int iproute_restore(void)
+{
+	exit(rtnl_from_file(stdin, &restore_handler, NULL));
+}
+
 void iproute_reset_filter()
 {
 	memset(&filter, 0, sizeof(filter));
@@ -1446,7 +1527,7 @@ void iproute_reset_filter()
 int do_iproute(int argc, char **argv)
 {
 	if (argc < 1)
-		return iproute_list_or_flush(0, NULL, 0);
+		return iproute_list_flush_or_save(0, NULL, IPROUTE_LIST);
 
 	if (matches(*argv, "add") == 0)
 		return iproute_modify(RTM_NEWROUTE, NLM_F_CREATE|NLM_F_EXCL,
@@ -1471,11 +1552,15 @@ int do_iproute(int argc, char **argv)
 				      argc-1, argv+1);
 	if (matches(*argv, "list") == 0 || matches(*argv, "show") == 0
 	    || matches(*argv, "lst") == 0)
-		return iproute_list_or_flush(argc-1, argv+1, 0);
+		return iproute_list_flush_or_save(argc-1, argv+1, IPROUTE_LIST);
 	if (matches(*argv, "get") == 0)
 		return iproute_get(argc-1, argv+1);
 	if (matches(*argv, "flush") == 0)
-		return iproute_list_or_flush(argc-1, argv+1, 1);
+		return iproute_list_flush_or_save(argc-1, argv+1, IPROUTE_FLUSH);
+	if (matches(*argv, "save") == 0)
+		return iproute_list_flush_or_save(argc-1, argv+1, IPROUTE_SAVE);
+	if (matches(*argv, "restore") == 0)
+		return iproute_restore();
 	if (matches(*argv, "help") == 0)
 		usage();
 	fprintf(stderr, "Command \"%s\" is unknown, try \"ip route help\".\n", *argv);
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index a5d2915..8158f5e 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -132,6 +132,13 @@ tentative " | " deprecated " | " dadfailed " | " temporary " ]"
 .I  SELECTOR
 
 .ti -8
+.BR "ip route save"
+.I SELECTOR
+
+.ti -8
+.BR "ip route restore"
+
+.ti -8
 .B  ip route get
 .IR ADDRESS " [ "
 .BI from " ADDRESS " iif " STRING"
@@ -1867,6 +1874,21 @@ however, no packets are actually sent.  With the
 argument, the kernel pretends that a packet arrived from this interface
 and searches for a path to forward the packet.
 
+.SS ip route save - save routing table information to stdout
+this command behaves like
+.BR "ip route show"
+except that the output is raw data suitable for passing to
+.BR "ip route restore" .
+
+.SS ip route restore - restore routing table information from stdin
+this command expects to read a data stream as returned from
+.BR "ip route save" .
+It will attempt to restore the routing table information exactly as
+it was at the time of the save, so any translation of information
+in the stream (such as device indexes) must be done first.  Any existing
+routes are left unchanged.  Any routes specified in the data stream that
+already exist in the table will be ignored.
+
 .SH ip rule - routing policy database management
 
 .BR "Rule" s
-- 
1.7.0.4

