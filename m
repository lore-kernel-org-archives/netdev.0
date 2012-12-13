From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 v2] ip: use rtnelink to manage mroute
Date: Thu, 13 Dec 2012 10:16:42 +0100
Message-ID: <1355390202-6868-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20121212102617.0a3249e4@nehalam.linuxnetplumber.net>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:39998 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752927Ab2LMJST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2012 04:18:19 -0500
In-Reply-To: <20121212102617.0a3249e4@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mroute was using /proc/net/ip_mr_[vif|cache] to display mroute entries. Hence,
only RT_TABLE_DEFAULT was displayed and only IPv4.
With rtnetlink, it is possible to display all tables for IPv4 and IPv6. The output
format is kept. Also, like before the patch, statistics are displayed when user specify
the '-s' argument.

The patch also adds the support of 'ip monitor mroute', which is now possible.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

v2: fix compilation warnings on 64bits arch

 ip/ip_common.h |   3 +
 ip/ipmonitor.c |  35 ++++++-
 ip/ipmroute.c  | 297 ++++++++++++++++++++++++++++++++++-----------------------
 3 files changed, 214 insertions(+), 121 deletions(-)
 create mode 100644 ip/ipmonitor.

diff --git a/ip/ip_common.h b/ip/ip_common.h
index a394669..de56810 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -16,11 +16,14 @@ extern int ipaddr_list_link(int argc, char **argv);
 extern int iproute_monitor(int argc, char **argv);
 extern void iplink_usage(void) __attribute__((noreturn));
 extern void iproute_reset_filter(void);
+extern void ipmroute_reset_filter(void);
 extern void ipaddr_reset_filter(int);
 extern void ipneigh_reset_filter(void);
 extern void ipntable_reset_filter(void);
 extern int print_route(const struct sockaddr_nl *who,
 		       struct nlmsghdr *n, void *arg);
+extern int print_mroute(const struct sockaddr_nl *who,
+			struct nlmsghdr *n, void *arg);
 extern int print_prefix(const struct sockaddr_nl *who,
 			struct nlmsghdr *n, void *arg);
 extern int print_rule(const struct sockaddr_nl *who,
diff --git a/ip/ipmonitor. b/ip/ipmonitor.
new file mode 100644
index 0000000..e69de29
diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index d971623..09a339c 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -43,10 +43,26 @@ int accept_msg(const struct sockaddr_nl *who,
 		print_timestamp(fp);
 
 	if (n->nlmsg_type == RTM_NEWROUTE || n->nlmsg_type == RTM_DELROUTE) {
-		if (prefix_banner)
-			fprintf(fp, "[ROUTE]");
-		print_route(who, n, arg);
-		return 0;
+		struct rtmsg *r = NLMSG_DATA(n);
+		int len = n->nlmsg_len - NLMSG_LENGTH(sizeof(*r));
+
+		if (len < 0) {
+			fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
+			return -1;
+		}
+
+		if (r->rtm_family == RTNL_FAMILY_IPMR ||
+		    r->rtm_family == RTNL_FAMILY_IP6MR) {
+			if (prefix_banner)
+				fprintf(fp, "[MROUTE]");
+			print_mroute(who, n, arg);
+			return 0;
+		} else {
+			if (prefix_banner)
+				fprintf(fp, "[ROUTE]");
+			print_route(who, n, arg);
+			return 0;
+		}
 	}
 	if (n->nlmsg_type == RTM_NEWLINK || n->nlmsg_type == RTM_DELLINK) {
 		ll_remember_index(who, n, NULL);
@@ -123,6 +139,7 @@ int do_ipmonitor(int argc, char **argv)
 	int llink=0;
 	int laddr=0;
 	int lroute=0;
+	int lmroute=0;
 	int lprefix=0;
 	int lneigh=0;
 	int lnetconf=0;
@@ -130,6 +147,7 @@ int do_ipmonitor(int argc, char **argv)
 	rtnl_close(&rth);
 	ipaddr_reset_filter(1);
 	iproute_reset_filter();
+	ipmroute_reset_filter();
 	ipneigh_reset_filter();
 
 	while (argc > 0) {
@@ -145,6 +163,9 @@ int do_ipmonitor(int argc, char **argv)
 		} else if (matches(*argv, "route") == 0) {
 			lroute=1;
 			groups = 0;
+		} else if (matches(*argv, "mroute") == 0) {
+			lmroute=1;
+			groups = 0;
 		} else if (matches(*argv, "prefix") == 0) {
 			lprefix=1;
 			groups = 0;
@@ -180,6 +201,12 @@ int do_ipmonitor(int argc, char **argv)
 		if (!preferred_family || preferred_family == AF_INET6)
 			groups |= nl_mgrp(RTNLGRP_IPV6_ROUTE);
 	}
+	if (lmroute) {
+		if (!preferred_family || preferred_family == AF_INET)
+			groups |= nl_mgrp(RTNLGRP_IPV4_MROUTE);
+		if (!preferred_family || preferred_family == AF_INET6)
+			groups |= nl_mgrp(RTNLGRP_IPV6_MROUTE);
+	}
 	if (lprefix) {
 		if (!preferred_family || preferred_family == AF_INET6)
 			groups |= nl_mgrp(RTNLGRP_IPV6_PREFIX);
diff --git a/ip/ipmroute.c b/ip/ipmroute.c
index 945727d..defcfc5 100644
--- a/ip/ipmroute.c
+++ b/ip/ipmroute.c
@@ -15,6 +15,7 @@
 #include <unistd.h>
 #include <syslog.h>
 #include <fcntl.h>
+#include <inttypes.h>
 #include <sys/ioctl.h>
 #include <sys/socket.h>
 #include <netinet/in.h>
@@ -26,167 +27,229 @@
 #include <linux/if_arp.h>
 #include <linux/sockios.h>
 
+#include <rt_names.h>
 #include "utils.h"
-
-char filter_dev[16];
-int  filter_family;
+#include "ip_common.h"
 
 static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip mroute show [ PREFIX ] [ from PREFIX ] [ iif DEVICE ]\n");
+	fprintf(stderr, "Usage: ip mroute show [ [ to ] PREFIX ] [ from PREFIX ] [ iif DEVICE ]\n");
 #if 0
 	fprintf(stderr, "Usage: ip mroute [ add | del ] DESTINATION from SOURCE [ iif DEVICE ] [ oif DEVICE ]\n");
 #endif
 	exit(-1);
 }
 
-static char *viftable[32];
-
 struct rtfilter
 {
+	int tb;
+	int af;
+	int iif;
 	inet_prefix mdst;
 	inet_prefix msrc;
 } filter;
 
-static void read_viftable(void)
+int print_mroute(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 {
-	char buf[256];
-	FILE *fp = fopen("/proc/net/ip_mr_vif", "r");
-
-	if (!fp)
-		return;
-
-	if (!fgets(buf, sizeof(buf), fp)) {
-		fclose(fp);
-		return;
+	FILE *fp = (FILE*)arg;
+	struct rtmsg *r = NLMSG_DATA(n);
+	int len = n->nlmsg_len;
+	struct rtattr * tb[RTA_MAX+1];
+	char abuf[256];
+	char obuf[256];
+	SPRINT_BUF(b1);
+	__u32 table;
+	int iif = 0;
+	int family;
+
+	if ((n->nlmsg_type != RTM_NEWROUTE &&
+	     n->nlmsg_type != RTM_DELROUTE) ||
+	    !(n->nlmsg_flags & NLM_F_MULTI)) {
+		fprintf(stderr, "Not a multicast route: %08x %08x %08x\n",
+			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
+		return 0;
 	}
-	while (fgets(buf, sizeof(buf), fp)) {
-		int vifi;
-		char dev[256];
-
-		if (sscanf(buf, "%d%s", &vifi, dev) < 2)
-			continue;
-
-		if (vifi<0 || vifi>31)
-			continue;
-
-		viftable[vifi] = strdup(dev);
+	len -= NLMSG_LENGTH(sizeof(*r));
+	if (len < 0) {
+		fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
+		return -1;
 	}
-	fclose(fp);
-}
-
-static void read_mroute_list(FILE *ofp)
-{
-	char buf[256];
-	FILE *fp = fopen("/proc/net/ip_mr_cache", "r");
-
-	if (!fp)
-		return;
-
-	if (!fgets(buf, sizeof(buf), fp)) {
-		fclose(fp);
-		return;
+	if (r->rtm_type != RTN_MULTICAST) {
+		fprintf(stderr, "Not a multicast route (type: %s)\n",
+			rtnl_rtntype_n2a(r->rtm_type, b1, sizeof(b1)));
+		return 0;
 	}
 
-	while (fgets(buf, sizeof(buf), fp)) {
-		inet_prefix maddr, msrc;
-		unsigned pkts, b, w;
-		int vifi;
-		char oiflist[256];
-		char sbuf[256];
-		char mbuf[256];
-		char obuf[256];
-
-		oiflist[0] = 0;
-		if (sscanf(buf, "%x%x%d%u%u%u %[^\n]",
-			   maddr.data, msrc.data, &vifi,
-			   &pkts, &b, &w, oiflist) < 6)
-			continue;
-
-		if (vifi!=-1 && (vifi < 0 || vifi>31))
-			continue;
-
-		if (filter_dev[0] && (vifi<0 || strcmp(filter_dev, viftable[vifi])))
-			continue;
-		if (filter.mdst.family && inet_addr_match(&maddr, &filter.mdst, filter.mdst.bitlen))
-			continue;
-		if (filter.msrc.family && inet_addr_match(&msrc, &filter.msrc, filter.msrc.bitlen))
-			continue;
-
-		snprintf(obuf, sizeof(obuf), "(%s, %s)",
-			 format_host(AF_INET, 4, &msrc.data[0], sbuf, sizeof(sbuf)),
-			 format_host(AF_INET, 4, &maddr.data[0], mbuf, sizeof(mbuf)));
-
-		fprintf(ofp, "%-32s Iif: ", obuf);
-
-		if (vifi == -1)
-			fprintf(ofp, "unresolved ");
-		else
-			fprintf(ofp, "%-10s ", viftable[vifi]);
-
-		if (oiflist[0]) {
-			char *next = NULL;
-			char *p = oiflist;
-			int ovifi, ottl;
-
-			fprintf(ofp, "Oifs: ");
-
-			while (p) {
-				next = strchr(p, ' ');
-				if (next) {
-					*next = 0;
-					next++;
-				}
-				if (sscanf(p, "%d:%d", &ovifi, &ottl)<2) {
-					p = next;
-					continue;
-				}
-				p = next;
-
-				fprintf(ofp, "%s", viftable[ovifi]);
-				if (ottl>1)
-					fprintf(ofp, "(ttl %d) ", ovifi);
-				else
-					fprintf(ofp, " ");
+	parse_rtattr(tb, RTA_MAX, RTM_RTA(r), len);
+	table = rtm_get_table(r, tb);
+
+	if (filter.tb > 0 && filter.tb != table)
+		return 0;
+
+	if (tb[RTA_IIF])
+		iif = *(int*)RTA_DATA(tb[RTA_IIF]);
+	if (filter.iif && filter.iif != iif)
+		return 0;
+
+	if (filter.af && filter.af != r->rtm_family)
+		return 0;
+
+	if (tb[RTA_DST] &&
+	    filter.mdst.bitlen > 0 &&
+	    inet_addr_match(RTA_DATA(tb[RTA_DST]), &filter.mdst, filter.mdst.bitlen))
+		return 0;
+
+	if (tb[RTA_SRC] &&
+	    filter.msrc.bitlen > 0 &&
+	    inet_addr_match(RTA_DATA(tb[RTA_SRC]), &filter.msrc, filter.msrc.bitlen))
+		return 0;
+
+	family = r->rtm_family == RTNL_FAMILY_IPMR ? AF_INET : AF_INET6;
+
+	if (n->nlmsg_type == RTM_DELROUTE)
+		fprintf(fp, "Deleted ");
+
+	if (tb[RTA_SRC])
+		len = snprintf(obuf, sizeof(obuf),
+			       "(%s, ", rt_addr_n2a(family,
+						    RTA_PAYLOAD(tb[RTA_SRC]),
+						    RTA_DATA(tb[RTA_SRC]),
+						    abuf, sizeof(abuf)));
+	else
+		len = sprintf(obuf, "(unknown, ");
+	if (tb[RTA_DST])
+		snprintf(obuf + len, sizeof(obuf) - len,
+			 "%s)", rt_addr_n2a(family, RTA_PAYLOAD(tb[RTA_DST]),
+					    RTA_DATA(tb[RTA_DST]),
+					    abuf, sizeof(abuf)));
+	else
+		snprintf(obuf + len, sizeof(obuf) - len, "unknown) ");
+
+	fprintf(fp, "%-32s Iif: ", obuf);
+	if (iif)
+		fprintf(fp, "%-10s ", ll_index_to_name(iif));
+	else
+		fprintf(fp, "unresolved ");
+
+	if (tb[RTA_MULTIPATH]) {
+		struct rtnexthop *nh = RTA_DATA(tb[RTA_MULTIPATH]);
+		int first = 1;
+
+		len = RTA_PAYLOAD(tb[RTA_MULTIPATH]);
+
+		for (;;) {
+			if (len < sizeof(*nh))
+				break;
+			if (nh->rtnh_len > len)
+				break;
+
+			if (first) {
+				fprintf(fp, "Oifs: ");
+				first = 0;
 			}
+			fprintf(fp, "%s", ll_index_to_name(nh->rtnh_ifindex));
+			if (nh->rtnh_hops > 1)
+				fprintf(fp, "(ttl %d) ", nh->rtnh_hops);
+			else
+				fprintf(fp, " ");
+			len -= NLMSG_ALIGN(nh->rtnh_len);
+			nh = RTNH_NEXT(nh);
 		}
-
-		if (show_stats && b) {
-			fprintf(ofp, "%s  %u packets, %u bytes", _SL_, pkts, b);
-			if (w)
-				fprintf(ofp, ", %u arrived on wrong iif.", w);
-		}
-		fprintf(ofp, "\n");
 	}
-	fclose(fp);
+	if (show_stats && tb[RTA_MFC_STATS]) {
+		struct rta_mfc_stats *mfcs = RTA_DATA(tb[RTA_MFC_STATS]);
+
+		fprintf(fp, "%s  %"PRIu64" packets, %"PRIu64" bytes", _SL_,
+			(uint64_t)mfcs->mfcs_packets,
+			(uint64_t)mfcs->mfcs_bytes);
+		if (mfcs->mfcs_wrong_if)
+			fprintf(fp, ", %"PRIu64" arrived on wrong iif.",
+				(uint64_t)mfcs->mfcs_wrong_if);
+	}
+	fprintf(fp, "\n");
+	fflush(fp);
+	return 0;
 }
 
+void ipmroute_reset_filter(void)
+{
+	memset(&filter, 0, sizeof(filter));
+	filter.mdst.bitlen = -1;
+	filter.msrc.bitlen = -1;
+}
 
 static int mroute_list(int argc, char **argv)
 {
+	char *id = NULL;
+	int family;
+
+	ipmroute_reset_filter();
+	if (preferred_family == AF_UNSPEC)
+		family = AF_INET;
+	else
+		family = AF_INET6;
+	if (family == AF_INET) {
+		filter.af = RTNL_FAMILY_IPMR;
+		filter.tb = RT_TABLE_DEFAULT;  /* for backward compatibility */
+	} else
+		filter.af = RTNL_FAMILY_IP6MR;
+
 	while (argc > 0) {
-		if (strcmp(*argv, "iif") == 0) {
+		if (matches(*argv, "table") == 0) {
+			__u32 tid;
 			NEXT_ARG();
-			strncpy(filter_dev, *argv, sizeof(filter_dev)-1);
+			if (rtnl_rttable_a2n(&tid, *argv)) {
+				if (strcmp(*argv, "all") == 0) {
+					filter.tb = 0;
+				} else if (strcmp(*argv, "help") == 0) {
+					usage();
+				} else {
+					invarg("table id value is invalid\n", *argv);
+				}
+			} else
+				filter.tb = tid;
+		} else if (strcmp(*argv, "iif") == 0) {
+			NEXT_ARG();
+			id = *argv;
 		} else if (matches(*argv, "from") == 0) {
 			NEXT_ARG();
-			get_prefix(&filter.msrc, *argv, AF_INET);
+			get_prefix(&filter.msrc, *argv, family);
 		} else {
 			if (strcmp(*argv, "to") == 0) {
 				NEXT_ARG();
 			}
 			if (matches(*argv, "help") == 0)
 				usage();
-			get_prefix(&filter.mdst, *argv, AF_INET);
+			get_prefix(&filter.mdst, *argv, family);
 		}
-		argv++; argc--;
+		argc--; argv++;
 	}
 
-	read_viftable();
-	read_mroute_list(stdout);
-	return 0;
+	ll_init_map(&rth);
+
+	if (id)  {
+		int idx;
+
+		if ((idx = ll_name_to_index(id)) == 0) {
+			fprintf(stderr, "Cannot find device \"%s\"\n", id);
+			return -1;
+		}
+		filter.iif = idx;
+	}
+
+	if (rtnl_wilddump_request(&rth, filter.af, RTM_GETROUTE) < 0) {
+		perror("Cannot send dump request");
+		return 1;
+	}
+
+	if (rtnl_dump_filter(&rth, print_mroute, stdout) < 0) {
+		fprintf(stderr, "Dump terminated\n");
+		exit(1);
+	}
+
+	exit(0);
 }
 
 int do_multiroute(int argc, char **argv)
-- 
1.8.0.1
