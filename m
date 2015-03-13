From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 8/8] iproute2: Add basic mpls support to iproute
Date: Fri, 13 Mar 2015 13:59:49 -0500
Message-ID: <87wq2kpvtm.fsf@x220.int.ebiederm.org>
References: <87bnjwspek.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:37210 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751549AbbCMTDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 15:03:32 -0400
In-Reply-To: <87bnjwspek.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Fri, 13 Mar 2015 13:50:11 -0500")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


- Pull in the uapi mpls.h
- Update rtnetlink.h to include the mpls rtnetlink notification multicast group.
- Define AF_MPLS in utils.h if it is not defined from elsewhere
  as is done with AF_DECnet

The address syntax for multiple mpls labels is a complete invention.
When I looked there seemed to be no wide spread convention for talking
about an mpls label stack in text for.  Sometimes people did:
"{ Label1, Label2, Label3 }", sometimes people would do:
"[ label3, label2, label1 ]", and most of the time label
stacks were not explicitly shown at all.

The syntax I wound up using, so it would not have spaces and so it
would visually distinct from other kinds of addresses is.

label1/label2/label3 Where label1 is the label at the top of the label
stack and label3 is the label at the bottom on the label stack.

When there is a single label this matches what seems to be convention
with other tools.  Just print out the numeric value of the mpls label.

The netlink protocol for labels uses the on the wire format for a
label stack. The ttl and traffic class are expected to be 0.  Using
the on the wire format is common and what happens with other address
types. BGP when passing label stacks also uses this technique with the
exception that the ttl byte is not included making each label in a BGP
label stack 3 bytes instead of 4.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 Makefile                  |  3 +++
 include/linux/mpls.h      | 34 +++++++++++++++++++++++++++
 include/linux/rtnetlink.h |  2 ++
 include/utils.h           | 10 ++++++++
 ip/ip.c                   |  4 +++-
 ip/ipmonitor.c            |  3 +++
 ip/iproute.c              |  4 +++-
 lib/mpls_ntop.c           | 48 +++++++++++++++++++++++++++++++++++++++
 lib/mpls_pton.c           | 58 +++++++++++++++++++++++++++++++++++++++++++++++
 lib/utils.c               | 31 +++++++++++++++++++++++--
 man/man8/ip-route.8.in    |  2 +-
 man/man8/ip.8             |  7 +++++-
 12 files changed, 200 insertions(+), 6 deletions(-)
 create mode 100644 include/linux/mpls.h
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
diff --git a/include/linux/mpls.h b/include/linux/mpls.h
new file mode 100644
index 000000000000..bc9abfe88c9a
--- /dev/null
+++ b/include/linux/mpls.h
@@ -0,0 +1,34 @@
+#ifndef _UAPI_MPLS_H
+#define _UAPI_MPLS_H
+
+#include <linux/types.h>
+#include <asm/byteorder.h>
+
+/* Reference: RFC 5462, RFC 3032
+ *
+ *  0                   1                   2                   3
+ *  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ * |                Label                  | TC  |S|       TTL     |
+ * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ *	Label:  Label Value, 20 bits
+ *	TC:     Traffic Class field, 3 bits
+ *	S:      Bottom of Stack, 1 bit
+ *	TTL:    Time to Live, 8 bits
+ */
+
+struct mpls_label {
+	__be32 entry;
+};
+
+#define MPLS_LS_LABEL_MASK      0xFFFFF000
+#define MPLS_LS_LABEL_SHIFT     12
+#define MPLS_LS_TC_MASK         0x00000E00
+#define MPLS_LS_TC_SHIFT        9
+#define MPLS_LS_S_MASK          0x00000100
+#define MPLS_LS_S_SHIFT         8
+#define MPLS_LS_TTL_MASK        0x000000FF
+#define MPLS_LS_TTL_SHIFT       0
+
+#endif /* _UAPI_MPLS_H */
diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 0d4100535bd7..2e0dc0f638ba 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -629,6 +629,8 @@ enum rtnetlink_groups {
 #define RTNLGRP_IPV6_NETCONF	RTNLGRP_IPV6_NETCONF
 	RTNLGRP_MDB,
 #define RTNLGRP_MDB		RTNLGRP_MDB
+	RTNLGRP_MPLS_ROUTE,
+#define RTNLGRP_MPLS_ROUTE	RTNLGRP_MPLS_ROUTE
 	__RTNLGRP_MAX
 };
 #define RTNLGRP_MAX	(__RTNLGRP_MAX - 1)
diff --git a/include/utils.h b/include/utils.h
index 2db09c7f790f..c8d8635c15e2 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -78,6 +78,13 @@ struct ipx_addr {
 	u_int8_t  ipx_node[IPX_NODE_LEN];
 };
 
+#ifndef AF_MPLS
+# define AF_MPLS 28
+#endif
+
+/* Maximum number of labels the mpls helpers support */
+#define MPLS_MAX_LABELS 8
+
 extern __u32 get_addr32(const char *name);
 extern int get_addr_1(inet_prefix *dst, const char *arg, int family);
 extern int get_prefix_1(inet_prefix *dst, char *arg, int family);
@@ -123,6 +130,9 @@ int dnet_pton(int af, const char *src, void *addr);
 const char *ipx_ntop(int af, const void *addr, char *str, size_t len);
 int ipx_pton(int af, const char *src, void *addr);
 
+const char *mpls_ntop(int af, const void *addr, char *str, size_t len);
+int mpls_pton(int af, const char *src, void *addr);
+
 extern int __iproute2_hz_internal;
 extern int __get_hz(void);
 
diff --git a/ip/ip.c b/ip/ip.c
index 85256d8ea0c1..f7f214b2f5ab 100644
--- a/ip/ip.c
+++ b/ip/ip.c
@@ -52,7 +52,7 @@ static void usage(void)
 "                   netns | l2tp | fou | tcp_metrics | token | netconf }\n"
 "       OPTIONS := { -V[ersion] | -s[tatistics] | -d[etails] | -r[esolve] |\n"
 "                    -h[uman-readable] | -iec |\n"
-"                    -f[amily] { inet | inet6 | ipx | dnet | bridge | link } |\n"
+"                    -f[amily] { inet | inet6 | ipx | dnet | mpls | bridge | link } |\n"
 "                    -4 | -6 | -I | -D | -B | -0 |\n"
 "                    -l[oops] { maximum-addr-flush-attempts } |\n"
 "                    -o[neline] | -t[imestamp] | -ts[hort] | -b[atch] [filename] |\n"
@@ -206,6 +206,8 @@ int main(int argc, char **argv)
 			preferred_family = AF_IPX;
 		} else if (strcmp(opt, "-D") == 0) {
 			preferred_family = AF_DECnet;
+		} else if (strcmp(opt, "-M") == 0) {
+			preferred_family = AF_MPLS;
 		} else if (strcmp(opt, "-B") == 0) {
 			preferred_family = AF_BRIDGE;
 		} else if (matches(opt, "-human") == 0 ||
diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 6b5e66534551..7833a2632927 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -158,6 +158,7 @@ int do_ipmonitor(int argc, char **argv)
 	groups |= nl_mgrp(RTNLGRP_IPV6_IFADDR);
 	groups |= nl_mgrp(RTNLGRP_IPV4_ROUTE);
 	groups |= nl_mgrp(RTNLGRP_IPV6_ROUTE);
+	groups |= nl_mgrp(RTNLGRP_MPLS_ROUTE);
 	groups |= nl_mgrp(RTNLGRP_IPV4_MROUTE);
 	groups |= nl_mgrp(RTNLGRP_IPV6_MROUTE);
 	groups |= nl_mgrp(RTNLGRP_IPV6_PREFIX);
@@ -235,6 +236,8 @@ int do_ipmonitor(int argc, char **argv)
 			groups |= nl_mgrp(RTNLGRP_IPV4_ROUTE);
 		if (!preferred_family || preferred_family == AF_INET6)
 			groups |= nl_mgrp(RTNLGRP_IPV6_ROUTE);
+		if (!preferred_family || preferred_family == AF_MPLS)
+			groups |= nl_mgrp(RTNLGRP_MPLS_ROUTE);
 	}
 	if (lmroute) {
 		if (!preferred_family || preferred_family == AF_INET)
diff --git a/ip/iproute.c b/ip/iproute.c
index b97aa4b598bf..07b2cca96225 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -76,7 +76,7 @@ static void usage(void)
 	fprintf(stderr, "             [ scope SCOPE ] [ metric METRIC ]\n");
 	fprintf(stderr, "INFO_SPEC := NH OPTIONS FLAGS [ nexthop NH ]...\n");
 	fprintf(stderr, "NH := [ via [ FAMILY ] ADDRESS ] [ dev STRING ] [ weight NUMBER ] NHFLAGS\n");
-	fprintf(stderr, "FAMILY := [ inet | inet6 | ipx | dnet | bridge | link ]");
+	fprintf(stderr, "FAMILY := [ inet | inet6 | ipx | dnet | mpls | bridge | link ]");
 	fprintf(stderr, "OPTIONS := FLAGS [ mtu NUMBER ] [ advmss NUMBER ] [ as [ to ] ADDRESS ]\n");
 	fprintf(stderr, "           [ rtt TIME ] [ rttvar TIME ] [ reordering NUMBER ]\n");
 	fprintf(stderr, "           [ window NUMBER] [ cwnd NUMBER ] [ initcwnd NUMBER ]\n");
@@ -292,6 +292,8 @@ static int calc_host_len(const struct rtmsg *r)
 		return 16;
 	else if (r->rtm_family == AF_IPX)
 		return 80;
+	else if (r->rtm_family == AF_MPLS)
+		return 20;
 	else
 		return -1;
 }
diff --git a/lib/mpls_ntop.c b/lib/mpls_ntop.c
new file mode 100644
index 000000000000..945d6d5e4535
--- /dev/null
+++ b/lib/mpls_ntop.c
@@ -0,0 +1,48 @@
+#include <errno.h>
+#include <string.h>
+#include <sys/types.h>
+#include <netinet/in.h>
+#include <linux/mpls.h>
+
+#include "utils.h"
+
+static const char *mpls_ntop1(const struct mpls_label *addr, char *buf, size_t buflen)
+{
+	size_t destlen = buflen;
+	char *dest = buf;
+	int count;
+
+	for (count = 0; count < MPLS_MAX_LABELS; count++) {
+		uint32_t entry = ntohl(addr[count].entry);
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
+		return mpls_ntop1((struct mpls_label *)addr, buf, buflen);
+	default:
+		errno = EAFNOSUPPORT;
+	}
+
+	return NULL;
+}
diff --git a/lib/mpls_pton.c b/lib/mpls_pton.c
new file mode 100644
index 000000000000..bd448cfcf14a
--- /dev/null
+++ b/lib/mpls_pton.c
@@ -0,0 +1,58 @@
+#include <errno.h>
+#include <string.h>
+#include <sys/types.h>
+#include <netinet/in.h>
+#include <linux/mpls.h>
+
+#include "utils.h"
+
+
+static int mpls_pton1(const char *name, struct mpls_label *addr)
+{
+	char *endp;
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
+		addr->entry = htonl(label << MPLS_LS_LABEL_SHIFT);
+		if (*endp == '\0') {
+			addr->entry |= htonl(1 << MPLS_LS_S_SHIFT);
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
+		err = mpls_pton1(src, (struct mpls_label *)addr);
+		break;
+	default:
+		errno = EAFNOSUPPORT;
+		err = -1;
+	}
+
+	return err;
+}
diff --git a/lib/utils.c b/lib/utils.c
index b293407e550d..4d19718b8763 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -26,6 +26,7 @@
 #include <linux/pkt_sched.h>
 #include <linux/param.h>
 #include <linux/if_arp.h>
+#include <linux/mpls.h>
 #include <time.h>
 #include <sys/time.h>
 #include <errno.h>
@@ -390,7 +391,7 @@ int get_addr_1(inet_prefix *addr, const char *name, int family)
 	if (strcmp(name, "default") == 0 ||
 	    strcmp(name, "all") == 0 ||
 	    strcmp(name, "any") == 0) {
-		if (family == AF_DECnet)
+		if ((family == AF_DECnet) || (family == AF_MPLS))
 			return -1;
 		addr->family = family;
 		addr->bytelen = (family == AF_INET6 ? 16 : 4);
@@ -432,6 +433,23 @@ int get_addr_1(inet_prefix *addr, const char *name, int family)
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
@@ -455,7 +473,7 @@ int get_prefix_1(inet_prefix *dst, char *arg, int family)
 	if (strcmp(arg, "default") == 0 ||
 	    strcmp(arg, "any") == 0 ||
 	    strcmp(arg, "all") == 0) {
-		if (family == AF_DECnet)
+		if ((family == AF_DECnet) || (family = AF_MPLS))
 			return -1;
 		dst->family = family;
 		dst->bytelen = 0;
@@ -476,6 +494,9 @@ int get_prefix_1(inet_prefix *dst, char *arg, int family)
 		case AF_DECnet:
 			dst->bitlen = 16;
 			break;
+		case AF_MPLS:
+			dst->bitlen = 20;
+			break;
 		default:
 		case AF_INET:
 			dst->bitlen = 32;
@@ -639,6 +660,8 @@ const char *rt_addr_n2a(int af, int len, const void *addr, char *buf, int buflen
 	case AF_INET:
 	case AF_INET6:
 		return inet_ntop(af, addr, buf, buflen);
+	case AF_MPLS:
+		return mpls_ntop(af, addr, buf, buflen);
 	case AF_IPX:
 		return ipx_ntop(af, addr, buf, buflen);
 	case AF_DECnet:
@@ -667,6 +690,8 @@ int read_family(const char *name)
 		family = AF_PACKET;
 	else if (strcmp(name, "ipx") == 0)
 		family = AF_IPX;
+	else if (strcmp(name, "mpls") == 0)
+		family = AF_MPLS;
 	else if (strcmp(name, "bridge") == 0)
 		family = AF_BRIDGE;
 	return family;
@@ -684,6 +709,8 @@ const char *family_name(int family)
 		return "link";
 	if (family == AF_IPX)
 		return "ipx";
+	if (family == AF_MPLS)
+		return "mpls";
 	if (family == AF_BRIDGE)
 		return "bridge";
 	return "???";
diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index 5112344971c0..1163536d0e9c 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -90,7 +90,7 @@ replace " } "
 
 .ti -8
 .IR FAMILY " := [ "
-.BR inet " | " inet6 " | " ipx " | " dnet " | " bridge " | " link " ]"
+.BR inet " | " inet6 " | " ipx " | " dnet " | " mpls " | " bridge " | " link " ]"
 
 .ti -8
 .IR OPTIONS " := " FLAGS " [ "
diff --git a/man/man8/ip.8 b/man/man8/ip.8
index 016e8c660cd0..1755473ee32a 100644
--- a/man/man8/ip.8
+++ b/man/man8/ip.8
@@ -73,7 +73,7 @@ Zero (0) means loop until all addresses are removed.
 .TP
 .BR "\-f" , " \-family " <FAMILY>
 Specifies the protocol family to use. The protocol family identifier can be one of
-.BR "inet" , " inet6" , " bridge" , " ipx" , " dnet"
+.BR "inet" , " inet6" , " bridge" , " ipx" , " dnet" , " mpls"
 or
 .BR link .
 If this option is not present,
@@ -115,6 +115,11 @@ shortcut for
 .BR "\-family ipx" .
 
 .TP
+.B \-M
+shortcut for
+.BR "\-family mpls" .
+
+.TP
 .B \-0
 shortcut for
 .BR "\-family link" .
-- 
2.2.1
