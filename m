From: Masahide Nakamura <nakam@linux-ipv6.org>
Subject: [PATCH] [iproute2] MONITOR: show IPv6 prefix list
Date: Tue, 11 Jan 2005 13:16:37 +0900
Message-ID: <20050111131637.7d1fe805@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org, nakam@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

This is also iproute2 patch, ipmonitor shows IPv6 prefix list notification
from kernel (tested on 2.6.10). Please apply it.

The ChangeSet is also available at:
<bk://bk.skbuff.net:38000/iproute2-prefix/>

Regards,


# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/01/11 12:45:13+09:00 nakam@linux-ipv6.org 
#   ipmonitor: show prefix information.
# 
# ip/ipprefix.c
#   2005/01/11 12:45:12+09:00 nakam@linux-ipv6.org +107 -0
# 
# BitKeeper/etc/logging_ok
#   2005/01/11 12:45:13+09:00 nakam@linux-ipv6.org +1 -0
#   Logging to logging@openlogging.org accepted
# 
# ip/ipprefix.c
#   2005/01/11 12:45:12+09:00 nakam@linux-ipv6.org +0 -0
#   BitKeeper file /home/nakam/src/bk/iproute2-prefix/ip/ipprefix.c
# 
# ip/ipmonitor.c
#   2005/01/11 12:45:12+09:00 nakam@linux-ipv6.org +12 -0
#   support prefix information.
# 
# ip/ip_common.h
#   2005/01/11 12:45:12+09:00 nakam@linux-ipv6.org +2 -0
#   print prefix information.
# 
# ip/Makefile
#   2005/01/11 12:45:12+09:00 nakam@linux-ipv6.org +1 -1
#   add a file for prefix information.
# 
diff -Nru a/ip/Makefile b/ip/Makefile
--- a/ip/Makefile	Tue Jan 11 13:11:20 2005
+++ b/ip/Makefile	Tue Jan 11 13:11:20 2005
@@ -1,6 +1,6 @@
 IPOBJ=ip.o ipaddress.o iproute.o iprule.o \
     rtm_map.o iptunnel.o ipneigh.o iplink.o \
-    ipmaddr.o ipmonitor.o ipmroute.o \
+    ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o
 
 RTMONOBJ=rtmon.o
diff -Nru a/ip/ip_common.h b/ip/ip_common.h
--- a/ip/ip_common.h	Tue Jan 11 13:11:20 2005
+++ b/ip/ip_common.h	Tue Jan 11 13:11:20 2005
@@ -15,6 +15,8 @@
 extern void ipneigh_reset_filter(void);
 extern int print_route(const struct sockaddr_nl *who, 
 		       struct nlmsghdr *n, void *arg);
+extern int print_prefix(const struct sockaddr_nl *who,
+			struct nlmsghdr *n, void *arg);
 extern int do_ipaddr(int argc, char **argv);
 extern int do_iproute(int argc, char **argv);
 extern int do_iprule(int argc, char **argv);
diff -Nru a/ip/ipmonitor.c b/ip/ipmonitor.c
--- a/ip/ipmonitor.c	Tue Jan 11 13:11:20 2005
+++ b/ip/ipmonitor.c	Tue Jan 11 13:11:20 2005
@@ -55,6 +55,10 @@
 		print_neigh(who, n, arg);
 		return 0;
 	}
+	if (n->nlmsg_type == RTM_NEWPREFIX) {
+		print_prefix(who, n, arg);
+		return 0;
+	}
 	if (n->nlmsg_type == 15) {
 		char *tstr;
 		time_t secs = ((__u32*)NLMSG_DATA(n))[0];
@@ -87,6 +91,7 @@
 	int llink=0;
 	int laddr=0;
 	int lroute=0;
+	int lprefix=0;
 
 	ipaddr_reset_filter(1);
 	iproute_reset_filter();
@@ -105,6 +110,9 @@
 		} else if (matches(*argv, "route") == 0) {
 			lroute=1;
 			groups = 0;
+		} else if (matches(*argv, "prefix") == 0) {
+			lprefix=1;
+			groups = 0;
 		} else if (strcmp(*argv, "all") == 0) {
 			groups = ~RTMGRP_TC;
 		} else if (matches(*argv, "help") == 0) {
@@ -129,6 +137,10 @@
 			groups |= RTMGRP_IPV4_ROUTE;
 		if (!preferred_family || preferred_family == AF_INET6)
 			groups |= RTMGRP_IPV6_ROUTE;
+	}
+	if (lprefix) {
+		if (!preferred_family || preferred_family == AF_INET6)
+			groups |= RTMGRP_IPV6_PREFIX;
 	}
 
 	if (file) {
diff -Nru a/ip/ipprefix.c b/ip/ipprefix.c
--- /dev/null	Wed Dec 31 16:00:00 1969
+++ b/ip/ipprefix.c	Tue Jan 11 13:11:20 2005
@@ -0,0 +1,107 @@
+/*
+ * Copyright (C)2005 USAGI/WIDE Project
+ * 
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ * 
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * 
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+/*
+ * based on ip.c, iproute.c
+ */
+/*
+ * Authors:
+ *	Masahide NAKAMURA @USAGI
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <netinet/icmp6.h>
+#include "utils.h"
+
+/* prefix flags; see kernel's net/ipv6/addrconf.c and include/net/if_inet6.h */
+#define IF_PREFIX_ONLINK	0x01
+#define IF_PREFIX_AUTOCONF	0x02
+
+int print_prefix(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
+{
+	FILE *fp = (FILE*)arg;
+	struct prefixmsg *prefix = NLMSG_DATA(n);
+	int len = n->nlmsg_len;
+	struct rtattr * tb[RTA_MAX+1];
+	int family = preferred_family;
+
+	if (n->nlmsg_type != RTM_NEWPREFIX) {
+		fprintf(stderr, "Not a prefix: %08x %08x %08x\n",
+			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
+		return 0;
+	}
+
+	len -= NLMSG_LENGTH(sizeof(*prefix));
+	if (len < 0) {
+		fprintf(stderr, "BUG: wrong nlmsg len %d\n", len);
+		return -1;
+	}
+
+	if (family == AF_UNSPEC)
+		family = AF_INET6;
+	if (family != AF_INET6)
+		return 0;
+
+	if (prefix->prefix_family != AF_INET6) {
+		fprintf(stderr, "wrong family %d\n", prefix->prefix_family);
+		return 0;
+	}
+	if (prefix->prefix_type != ND_OPT_PREFIX_INFORMATION) {
+		fprintf(stderr, "wrong ND type %d\n", prefix->prefix_type);
+		return 0;
+	}
+
+	memset(tb, 0, sizeof(tb));
+	parse_rtattr(tb, RTA_MAX, RTM_RTA(prefix), len);
+
+	fprintf(fp, "prefix ");
+
+	if (tb[PREFIX_ADDRESS]) {
+		struct in6_addr *pfx;
+		char abuf[256];
+
+		pfx = (struct in6_addr *)RTA_DATA(tb[PREFIX_ADDRESS]);
+
+		memset(abuf, '\0', sizeof(abuf));
+		fprintf(fp, "%s", rt_addr_n2a(family, sizeof(*pfx), pfx, 
+					      abuf, sizeof(abuf)));
+	}
+	fprintf(fp, "/%u ", prefix->prefix_len);
+
+	fprintf(fp, "dev %s ", ll_index_to_name(prefix->prefix_ifindex));
+
+	if (prefix->prefix_flags & IF_PREFIX_ONLINK)
+		fprintf(fp, "onlink ");
+	if (prefix->prefix_flags & IF_PREFIX_AUTOCONF)
+		fprintf(fp, "autoconf ");
+
+	if (tb[PREFIX_CACHEINFO]) {
+		struct prefix_cacheinfo *pc;
+		pc = (struct prefix_cacheinfo *)tb[PREFIX_CACHEINFO];
+
+		fprintf(fp, "valid %u ", pc->valid_time);
+		fprintf(fp, "preferred %u ", pc->preferred_time);
+	}
+
+	fprintf(fp, "\n");
+	fflush(fp);
+
+	return 0;
+}
+


-- 
Masahide NAKAMURA
