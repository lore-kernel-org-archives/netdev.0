From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH iproute2] mpls: Add basic mpls support to iproute
Date: Wed, 25 Feb 2015 11:37:28 -0600
Message-ID: <87lhjluc2v.fsf@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
	santiago@crfreenet.org, David Miller <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:42268 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752450AbbBYRk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 12:40:57 -0500
In-Reply-To: <87pp8xx6ik.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 25 Feb 2015 11:09:23 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This includes support for two new netlink attributes and mpls address
parsing and printing routines.

I don't like how I have AF_MPLS and the defines from include/uapi/linux/mpls.h
duplicated in include/utils.h but I drew a blank when thinking of a
better way to handle this.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---

The kernel side of this code hasn't gone in yet, so I expect it is
probably premature to pull this code into iproute2 but at the same
time this code is needed to use and understand the kernel code so I am
posting it now, and will resend later if needed.

 Makefile                  |  3 +++
 include/linux/rtnetlink.h |  4 +++
 include/utils.h           | 41 +++++++++++++++++++++++++++++
 ip/ip.c                   |  4 +++
 ip/ipmonitor.c            |  3 +++
 ip/iproute.c              | 36 +++++++++++++++++++++++++
 lib/mpls_ntop.c           | 67 +++++++++++++++++++++++++++++++++++++++++++++++
 lib/mpls_pton.c           | 58 ++++++++++++++++++++++++++++++++++++++++
 lib/utils.c               | 26 ++++++++++++++++--
 9 files changed, 240 insertions(+), 2 deletions(-)
 create mode 100644 lib/mpls_ntop.c
 create mode 100644 lib/mpls_pton.c

diff --git a/Makefile b/Makefile
index 9dbb29f3d0cd..ca6c2e141308 100644
--- a/Makefile
+++ b/Makefile
@@ -26,6 +26,9 @@ ADDLIB+=dnet_ntop.o dnet_pton.o
 #options for ipx
 ADDLIB+=ipx_ntop.o ipx_pton.o
 
+#options for mpls
+ADDLIB+=mpls_ntop.o mpls_pton.o
+
 CC = gcc
 HOSTCC = gcc
 DEFINES += -D_GNU_SOURCE
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 3eb78105399b..cf0866d1a8ff 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -303,6 +303,8 @@ enum rtattr_type_t {
 	RTA_TABLE,
 	RTA_MARK,
 	RTA_MFC_STATS,
+	RTA_LLGATEWAY,
+	RTA_NEWDST,
 	__RTA_MAX
 };
 
@@ -621,6 +623,8 @@ enum rtnetlink_groups {
 #define RTNLGRP_IPV6_NETCONF	RTNLGRP_IPV6_NETCONF
 	RTNLGRP_MDB,
 #define RTNLGRP_MDB		RTNLGRP_MDB
+	RTNLGRP_MPLS_ROUTE,
+#define RTNLGRP_MPLS_ROUTE	RTNLGRP_MPLS_ROUTE
 	__RTNLGRP_MAX
 };
 #define RTNLGRP_MAX	(__RTNLGRP_MAX - 1)
diff --git a/include/utils.h b/include/utils.h
index 3da22837d2e6..f36fee83bfbe 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -77,6 +77,44 @@ struct ipx_addr {
 	u_int8_t  ipx_node[IPX_NODE_LEN];
 };
 
+#ifndef AF_MPLS
+# define AF_MPLS 28
+#endif
+#ifndef PF_MPLS
+# define PF_MPLS AF_MPLS
+#endif
+
+#ifndef MPLS_LS_LABEL_MASK
+# define MPLS_LS_LABEL_MASK      0xFFFFF000
+#endif
+#ifndef MPLS_LS_LABEL_SHIFT
+# define MPLS_LS_LABEL_SHIFT     12
+#endif
+#ifndef MPLS_LS_TC_MASK
+# define MPLS_LS_TC_MASK         0x00000E00
+#endif
+#ifndef MPLS_LS_TC_SHIFT
+# define MPLS_LS_TC_SHIFT        9
+#endif
+#ifndef MPLS_LS_S_MASK
+# define MPLS_LS_S_MASK          0x00000100
+#endif
+#ifndef MPLS_LS_S_SHIFT
+# define MPLS_LS_S_SHIFT         8
+#endif
+#ifndef MPLS_LS_TTL_MASK
+# define MPLS_LS_TTL_MASK        0x000000FF
+#endif
+#ifndef MPLS_LS_TTL_SHIFT
+# define MPLS_LS_TTL_SHIFT       0
+#endif
+
+/* Maximum number of labels our helpers support */
+#define MPLS_MAX_LABELS 8
+struct mpls_addr {
+	u_int32_t label_stack_entry;
+};
+
 extern __u32 get_addr32(const char *name);
 extern int get_addr_1(inet_prefix *dst, const char *arg, int family);
 extern int get_prefix_1(inet_prefix *dst, char *arg, int family);
@@ -119,6 +157,9 @@ int dnet_pton(int af, const char *src, void *addr);
 const char *ipx_ntop(int af, const void *addr, char *str, size_t len);
 int ipx_pton(int af, const char *src, void *addr);
 
+const char *mpls_ntop(int af, const void *addr, char *str, size_t len);
+int mpls_pton(int af, const char *src, void *addr);
+
 extern int __iproute2_hz_internal;
 extern int __get_hz(void);
 
diff --git a/ip/ip.c b/ip/ip.c
index da16b15f8b55..53be50dd378b 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -200,6 +200,8 @@ int main(int argc, char **argv)
 				preferred_family = AF_PACKET;
 			else if (strcmp(argv[1], "ipx") == 0)
 				preferred_family = AF_IPX;
+			else if (strcmp(argv[1], "mpls") == 0)
+				preferred_family = AF_MPLS;
 			else if (strcmp(argv[1], "bridge") == 0)
 				preferred_family = AF_BRIDGE;
 			else if (strcmp(argv[1], "help") == 0)
@@ -216,6 +218,8 @@ int main(int argc, char **argv)
 			preferred_family = AF_IPX;
 		} else if (strcmp(opt, "-D") == 0) {
 			preferred_family = AF_DECnet;
+		} else if (strcmp(opt, "-M") == 0) {
+			preferred_family = AF_MPLS;
 		} else if (strcmp(opt, "-B") == 0) {
 			preferred_family = AF_BRIDGE;
 		} else if (matches(opt, "-human") == 0 ||
diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 5ec8f4181222..03e50c7eb787 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -163,6 +163,7 @@ int do_ipmonitor(int argc, char **argv)
 	groups |= nl_mgrp(RTNLGRP_NEIGH);
 	groups |= nl_mgrp(RTNLGRP_IPV4_NETCONF);
 	groups |= nl_mgrp(RTNLGRP_IPV6_NETCONF);
+	groups |= nl_mgrp(RTNLGRP_MPLS_ROUTE);
 
 	rtnl_close(&rth);
 
@@ -229,6 +230,8 @@ int do_ipmonitor(int argc, char **argv)
 			groups |= nl_mgrp(RTNLGRP_IPV4_ROUTE);
 		if (!preferred_family || preferred_family == AF_INET6)
 			groups |= nl_mgrp(RTNLGRP_IPV6_ROUTE);
+		if (!preferred_family || preferred_family == AF_MPLS)
+			groups |= nl_mgrp(RTNLGRP_MPLS_ROUTE)
 	}
 	if (lmroute) {
 		if (!preferred_family || preferred_family == AF_INET)
diff --git a/ip/iproute.c b/ip/iproute.c
index 76d8e36ccc2b..939b661b2a7a 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -23,6 +23,7 @@
 #include <netinet/ip.h>
 #include <arpa/inet.h>
 #include <linux/in_route.h>
+#include <linux/if_arp.h>
 #include <errno.h>
 
 #include "rt_names.h"
@@ -278,6 +279,8 @@ static int calc_host_len(const struct rtmsg *r)
 		return 16;
 	else if (r->rtm_family == AF_IPX)
 		return 80;
+	else if (r->rtm_family == AF_MPLS)
+		return 20;
 	else
 		return -1;
 }
@@ -386,6 +389,13 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	} else if (r->rtm_src_len) {
 		fprintf(fp, "from 0/%u ", r->rtm_src_len);
 	}
+	if (tb[RTA_NEWDST]) {
+		fprintf(fp, "as %s ", format_host(r->rtm_family,
+						  RTA_PAYLOAD(tb[RTA_NEWDST]),
+						  RTA_DATA(tb[RTA_NEWDST]),
+						  abuf, sizeof(abuf))
+			);
+	}
 	if (r->rtm_tos && filter.tosmask != -1) {
 		SPRINT_BUF(b1);
 		fprintf(fp, "tos %s ", rtnl_dsfield_n2a(r->rtm_tos, b1, sizeof(b1)));
@@ -398,6 +408,14 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				    RTA_DATA(tb[RTA_GATEWAY]),
 				    abuf, sizeof(abuf)));
 	}
+	if (tb[RTA_LLGATEWAY]) {
+		SPRINT_BUF(b1);
+		fprintf(fp, "llvia %s ",
+			ll_addr_n2a(RTA_DATA(tb[RTA_LLGATEWAY]),
+				    RTA_PAYLOAD(tb[RTA_LLGATEWAY]),
+				    ARPHRD_VOID /* Unknown link-layer address type */,
+				    b1, sizeof(b1)));
+	}
 	if (tb[RTA_OIF] && filter.oifmask != -1)
 		fprintf(fp, "dev %s ", ll_index_to_name(*(int*)RTA_DATA(tb[RTA_OIF])));
 
@@ -770,6 +788,13 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			if (req.r.rtm_family == AF_UNSPEC)
 				req.r.rtm_family = addr.family;
 			addattr_l(&req.n, sizeof(req), RTA_PREFSRC, &addr.data, addr.bytelen);
+		} else if (strcmp(*argv, "as") == 0) {
+			inet_prefix addr;
+			NEXT_ARG();
+			get_addr(&addr, *argv, req.r.rtm_family);
+			if (req.r.rtm_family == AF_UNSPEC)
+				req.r.rtm_family = addr.family;
+			addattr_l(&req.n, sizeof(req), RTA_NEWDST, &addr.data, addr.bytelen);
 		} else if (strcmp(*argv, "via") == 0) {
 			inet_prefix addr;
 			gw_ok = 1;
@@ -778,6 +803,17 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 			if (req.r.rtm_family == AF_UNSPEC)
 				req.r.rtm_family = addr.family;
 			addattr_l(&req.n, sizeof(req), RTA_GATEWAY, &addr.data, addr.bytelen);
+		} else if (strcmp(*argv, "llvia") == 0) {
+			char abuf[32];
+			int len;
+			gw_ok = 1;
+			NEXT_ARG();
+			len = ll_addr_a2n(abuf, sizeof(abuf), *argv);
+			if (len <= 0) {
+				invarg("Invalid llvia address", *argv);
+				len = 0;
+			}
+			addattr_l(&req.n, sizeof(req), RTA_LLGATEWAY, abuf, len);
 		} else if (strcmp(*argv, "from") == 0) {
 			inet_prefix addr;
 			NEXT_ARG();
diff --git a/lib/mpls_ntop.c b/lib/mpls_ntop.c
new file mode 100644
index 000000000000..c6c7afae75b8
--- /dev/null
+++ b/lib/mpls_ntop.c
@@ -0,0 +1,67 @@
+#include <errno.h>
+#include <string.h>
+#include <sys/types.h>
+#include <netinet/in.h>
+
+#include "utils.h"
+
+static const char *mpls_ntop1(const struct mpls_addr *addr, char *buf, size_t buflen)
+{
+	unsigned count;
+
+	for (count = 0; count < MPLS_MAX_LABELS; count++) {
+		uint32_t entry = ntohl(addr->label_stack_entry);
+		uint32_t label = (entry & MPLS_LS_LABEL_MASK) >> MPLS_LS_LABEL_SHIFT;
+		int len = snprintf(buf, buflen, "%u", label);
+
+		/* Is this the end? */
+		if (entry & MPLS_LS_S_MASK)
+			return buf;
+
+		buf += len;
+		buflen -= len;
+	}
+	errno = -E2BIG;
+	return NULL;
+}
+
+static const char *mpls_ntop1(const struct mpls_addr *addr, char *buf, size_t buflen)
+{
+	size_t destlen = buflen;
+	char *dest = buf;
+	int count;
+
+	for (count = 0; count < MPLS_MAX_LABELS; count++) {
+		uint32_t entry = ntohl(addr[count].label_stack_entry);
+		uint32_t label = (entry & MPLS_LS_LABEL_MASK) >> MPLS_LS_LABEL_SHIFT;
+		int len = snprintf(dest, destlen, "%u", label);
+
+		/* Is this the end? */
+		if (entry & MPLS_LS_S_MASK)
+			return buf;
+
+
+		dest += len;
+		destlen -= len;
+		if (destlen) {
+			*dest = '/';
+			dest++;
+			destlen--;
+		}
+	}
+	errno = -E2BIG;
+	return NULL;
+}
+
+const char *mpls_ntop(int af, const void *addr, char *buf, size_t buflen)
+{
+	switch(af) {
+	case AF_MPLS:
+		errno = 0;
+		return mpls_ntop1((struct mpls_addr *)addr, buf, buflen);
+	default:
+		errno = EAFNOSUPPORT;
+	}
+
+	return NULL;
+}
diff --git a/lib/mpls_pton.c b/lib/mpls_pton.c
new file mode 100644
index 000000000000..be99b159b256
--- /dev/null
+++ b/lib/mpls_pton.c
@@ -0,0 +1,58 @@
+#include <errno.h>
+#include <string.h>
+#include <sys/types.h>
+#include <netinet/in.h>
+
+#include "utils.h"
+
+
+static int mpls_pton1(const char *name, struct mpls_addr *addr)
+{
+	char *endp;
+	unsigned long label;
+	unsigned count;
+
+	for (count = 0; count < MPLS_MAX_LABELS; count++) {
+		unsigned long label;
+
+		label = strtoul(name, &endp, 0);
+		/* Fail when the label value is out or range */
+		if (label >= (1 << 20))
+			return 0;
+
+		if (endp == name) /* no digits */
+			return 0;
+
+		addr->label_stack_entry = htonl(label << MPLS_LS_LABEL_SHIFT);
+		if (*endp == '\0') {
+			addr->label_stack_entry |= htonl(1 << MPLS_LS_S_SHIFT);
+			return 1;
+		}
+
+		/* Bad character in the address */
+		if (*endp != '/')
+			return 0;
+
+		name = endp + 1;
+		addr += 1;
+	}
+	/* The address was too long */
+	return 0;
+}
+
+int mpls_pton(int af, const char *src, void *addr)
+{
+	int err;
+
+	switch(af) {
+	case AF_MPLS:
+		errno = 0;
+		err = mpls_pton1(src, (struct mpls_addr *)addr);
+		break;
+	default:
+		errno = EAFNOSUPPORT;
+		err = -1;
+	}
+
+	return err;
+}
diff --git a/lib/utils.c b/lib/utils.c
index efebe189758f..8385eeb2c30e 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -389,7 +389,7 @@ int get_addr_1(inet_prefix *addr, const char *name, int family)
 	if (strcmp(name, "default") == 0 ||
 	    strcmp(name, "all") == 0 ||
 	    strcmp(name, "any") == 0) {
-		if (family == AF_DECnet)
+		if ((family == AF_DECnet) || (family == AF_MPLS))
 			return -1;
 		addr->family = family;
 		addr->bytelen = (family == AF_INET6 ? 16 : 4);
@@ -419,6 +419,23 @@ int get_addr_1(inet_prefix *addr, const char *name, int family)
 		return 0;
 	}
 
+	if (family == AF_MPLS) {
+		int i;
+		addr->family = AF_MPLS;
+		if (mpls_pton(AF_MPLS, name, addr->data) <= 0)
+			return -1;
+		addr->bytelen = 4;
+		addr->bitlen = 20;
+		/* How many bytes do I need? */
+		for (i = 0; i < 8; i++) {
+			if (ntohl(addr->data[i]) & MPLS_LS_S_MASK) {
+				addr->bytelen = (i + 1)*4;
+				break;
+			}
+		}
+		return 0;
+	}
+
 	addr->family = AF_INET;
 	if (family != AF_UNSPEC && family != AF_INET)
 		return -1;
@@ -442,7 +459,7 @@ int get_prefix_1(inet_prefix *dst, char *arg, int family)
 	if (strcmp(arg, "default") == 0 ||
 	    strcmp(arg, "any") == 0 ||
 	    strcmp(arg, "all") == 0) {
-		if (family == AF_DECnet)
+		if ((family == AF_DECnet) || (family = AF_MPLS))
 			return -1;
 		dst->family = family;
 		dst->bytelen = 0;
@@ -463,6 +480,9 @@ int get_prefix_1(inet_prefix *dst, char *arg, int family)
 		case AF_DECnet:
 			dst->bitlen = 16;
 			break;
+		case AF_MPLS:
+			dst->bitlen = 20;
+			break;
 		default:
 		case AF_INET:
 			dst->bitlen = 32;
@@ -630,6 +650,8 @@ const char *rt_addr_n2a(int af, const void *addr, char *buf, int buflen)
 	case AF_INET:
 	case AF_INET6:
 		return inet_ntop(af, addr, buf, buflen);
+	case AF_MPLS:
+		return mpls_ntop(af, addr, buf, buflen);
 	case AF_IPX:
 		return ipx_ntop(af, addr, buf, buflen);
 	case AF_DECnet:
-- 
2.2.1
