From: Dmitry Kozlov <xeb@mail.ru>
Subject: [PATCH RESEND] iproute2: GRE over IPv6 tunnel support.
Date: Sat, 28 Sep 2013 11:32:51 +0400
Message-ID: <20130928113251.75738a49@comp1>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Templin, Fred L" <Fred.L.Templin@boeing.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback1.mail.ru ([94.100.176.18]:40746 "EHLO
	fallback1.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751814Ab3I1Hn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 03:43:57 -0400
Received: from smtp49.i.mail.ru (smtp49.i.mail.ru [94.100.177.109])
	by fallback1.mail.ru (mPOP.Fallback_MX) with ESMTP id 2DA962969D23
	for <netdev@vger.kernel.org>; Sat, 28 Sep 2013 11:33:21 +0400 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRE over IPv6 tunnel support.

Signed-off-by: Dmitry Kozlov <xeb@mail.ru>
---
 ip/Makefile    |   3 +-
 ip/ip6tunnel.c | 131 ++++++++++++++++---
 ip/iplink.c    |   7 +-
 ip/link_gre6.c | 398 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 516 insertions(+), 23 deletions(-)
 create mode 100644 ip/link_gre6.c

diff --git a/ip/Makefile b/ip/Makefile
index 48bd4a1..f10d22f 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -5,7 +5,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o ipnetns.o \
     iplink_vlan.o link_veth.o link_gre.o iplink_can.o \
     iplink_macvlan.o iplink_macvtap.o ipl2tp.o link_vti.o \
     iplink_vxlan.o tcp_metrics.o iplink_ipoib.o ipnetconf.o link_ip6tnl.o \
-    link_iptnl.o
+    link_iptnl.o link_gre6.o
 
 RTMONOBJ=rtmon.o
 
@@ -23,7 +23,6 @@ all: $(TARGETS) $(SCRIPTS)
 
 ip: $(IPOBJ) $(LIBNETLINK)
 
-
 rtmon: $(RTMONOBJ)
 
 install: all
diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index 216e982..463be42 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -48,11 +48,12 @@ static void usage(void) __attribute__((noreturn));
 static void usage(void)
 {
 	fprintf(stderr, "Usage: ip -f inet6 tunnel { add | change | del | show } [ NAME ]\n");
-	fprintf(stderr, "          [ mode { ip6ip6 | ipip6 | any } ]\n");
+	fprintf(stderr, "          [ mode { ip6ip6 | ipip6 | ip6gre | any } ]\n");
 	fprintf(stderr, "          [ remote ADDR local ADDR ] [ dev PHYS_DEV ]\n");
 	fprintf(stderr, "          [ encaplimit ELIM ]\n");
 	fprintf(stderr ,"          [ hoplimit TTL ] [ tclass TCLASS ] [ flowlabel FLOWLABEL ]\n");
 	fprintf(stderr, "          [ dscp inherit ]\n");
+	fprintf(stderr, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: NAME      := STRING\n");
 	fprintf(stderr, "       ADDR      := IPV6_ADDRESS\n");
@@ -62,10 +63,11 @@ static void usage(void)
 		DEFAULT_TNL_HOP_LIMIT);
 	fprintf(stderr, "       TCLASS    := { 0x0..0xff | inherit }\n");
 	fprintf(stderr, "       FLOWLABEL := { 0x0..0xfffff | inherit }\n");
+	fprintf(stderr, "       KEY       := { DOTTED_QUAD | NUMBER }\n");
 	exit(-1);
 }
 
-static void print_tunnel(struct ip6_tnl_parm *p)
+static void print_tunnel(struct ip6_tnl_parm2 *p)
 {
 	char remote[64];
 	char local[64];
@@ -104,9 +106,29 @@ static void print_tunnel(struct ip6_tnl_parm *p)
 
 	if (p->flags & IP6_TNL_F_RCV_DSCP_COPY)
 		printf(" dscp inherit");
+
+	if (p->proto == IPPROTO_GRE) {
+		if ((p->i_flags&GRE_KEY) && (p->o_flags&GRE_KEY) && p->o_key == p->i_key)
+			printf(" key %u", ntohl(p->i_key));
+		else if ((p->i_flags|p->o_flags)&GRE_KEY) {
+			if (p->i_flags&GRE_KEY)
+				printf(" ikey %u ", ntohl(p->i_key));
+			if (p->o_flags&GRE_KEY)
+				printf(" okey %u ", ntohl(p->o_key));
+		}
+
+		if (p->i_flags&GRE_SEQ)
+			printf("%s  Drop packets out of sequence.\n", _SL_);
+		if (p->i_flags&GRE_CSUM)
+			printf("%s  Checksum in received packet is required.", _SL_);
+		if (p->o_flags&GRE_SEQ)
+			printf("%s  Sequence packets on output.", _SL_);
+		if (p->o_flags&GRE_CSUM)
+			printf("%s  Checksum output packets.", _SL_);
+	}
 }
 
-static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm *p)
+static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm2 *p)
 {
 	int count = 0;
 	char medium[IFNAMSIZ];
@@ -124,6 +146,9 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm *p)
 				 strcmp(*argv, "ipip6") == 0 ||
 				 strcmp(*argv, "ip4ip6") == 0)
 				p->proto = IPPROTO_IPIP;
+			else if (strcmp(*argv, "ip6gre") == 0 ||
+				 strcmp(*argv, "gre/ipv6") == 0)
+				p->proto = IPPROTO_GRE;
 			else if (strcmp(*argv, "any/ipv6") == 0 ||
 				 strcmp(*argv, "any") == 0)
 				p->proto = 0;
@@ -202,6 +227,60 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm *p)
 			if (strcmp(*argv, "inherit") != 0)
 				invarg("not inherit", *argv);
 			p->flags |= IP6_TNL_F_RCV_DSCP_COPY;
+		} else if (strcmp(*argv, "key") == 0) {
+			unsigned uval;
+			NEXT_ARG();
+			p->i_flags |= GRE_KEY;
+			p->o_flags |= GRE_KEY;
+			if (strchr(*argv, '.'))
+				p->i_key = p->o_key = get_addr32(*argv);
+			else {
+				if (get_unsigned(&uval, *argv, 0)<0) {
+					fprintf(stderr, "invalid value of \"key\"\n");
+					exit(-1);
+				}
+				p->i_key = p->o_key = htonl(uval);
+			}
+		} else if (strcmp(*argv, "ikey") == 0) {
+			unsigned uval;
+			NEXT_ARG();
+			p->i_flags |= GRE_KEY;
+			if (strchr(*argv, '.'))
+				p->i_key = get_addr32(*argv);
+			else {
+				if (get_unsigned(&uval, *argv, 0)<0) {
+					fprintf(stderr, "invalid value of \"ikey\"\n");
+					exit(-1);
+				}
+				p->i_key = htonl(uval);
+			}
+		} else if (strcmp(*argv, "okey") == 0) {
+			unsigned uval;
+			NEXT_ARG();
+			p->o_flags |= GRE_KEY;
+			if (strchr(*argv, '.'))
+				p->o_key = get_addr32(*argv);
+			else {
+				if (get_unsigned(&uval, *argv, 0)<0) {
+					fprintf(stderr, "invalid value of \"okey\"\n");
+					exit(-1);
+				}
+				p->o_key = htonl(uval);
+			}
+		} else if (strcmp(*argv, "seq") == 0) {
+			p->i_flags |= GRE_SEQ;
+			p->o_flags |= GRE_SEQ;
+		} else if (strcmp(*argv, "iseq") == 0) {
+			p->i_flags |= GRE_SEQ;
+		} else if (strcmp(*argv, "oseq") == 0) {
+			p->o_flags |= GRE_SEQ;
+		} else if (strcmp(*argv, "csum") == 0) {
+			p->i_flags |= GRE_CSUM;
+			p->o_flags |= GRE_CSUM;
+		} else if (strcmp(*argv, "icsum") == 0) {
+			p->i_flags |= GRE_CSUM;
+		} else if (strcmp(*argv, "ocsum") == 0) {
+			p->o_flags |= GRE_CSUM;
 		} else {
 			if (strcmp(*argv, "name") == 0) {
 				NEXT_ARG();
@@ -212,7 +291,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm *p)
 				duparg2("name", *argv);
 			strncpy(p->name, *argv, IFNAMSIZ - 1);
 			if (cmd == SIOCCHGTUNNEL && count == 0) {
-				struct ip6_tnl_parm old_p;
+				struct ip6_tnl_parm2 old_p;
 				memset(&old_p, 0, sizeof(old_p));
 				if (tnl_get_ioctl(*argv, &old_p))
 					return -1;
@@ -230,7 +309,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip6_tnl_parm *p)
 	return 0;
 }
 
-static void ip6_tnl_parm_init(struct ip6_tnl_parm *p, int apply_default)
+static void ip6_tnl_parm_init(struct ip6_tnl_parm2 *p, int apply_default)
 {
 	memset(p, 0, sizeof(*p));
 	p->proto = IPPROTO_IPV6;
@@ -244,8 +323,8 @@ static void ip6_tnl_parm_init(struct ip6_tnl_parm *p, int apply_default)
  * @p1: user specified parameter
  * @p2: database entry
  */
-static int ip6_tnl_parm_match(const struct ip6_tnl_parm *p1,
-			      const struct ip6_tnl_parm *p2)
+static int ip6_tnl_parm_match(const struct ip6_tnl_parm2 *p1,
+			      const struct ip6_tnl_parm2 *p2)
 {
 	return ((!p1->link || p1->link == p2->link) &&
 		(!p1->name[0] || strcmp(p1->name, p2->name) == 0) &&
@@ -263,7 +342,7 @@ static int ip6_tnl_parm_match(const struct ip6_tnl_parm *p1,
 		(!p1->flags || (p1->flags & p2->flags)));
 }
 
-static int do_tunnels_list(struct ip6_tnl_parm *p)
+static int do_tunnels_list(struct ip6_tnl_parm2 *p)
 {
 	char buf[512];
 	int err = -1;
@@ -287,7 +366,7 @@ static int do_tunnels_list(struct ip6_tnl_parm *p)
 			rx_fifo, rx_frame,
 			tx_bytes, tx_packets, tx_errs, tx_drops,
 			tx_fifo, tx_colls, tx_carrier, rx_multi;
-		struct ip6_tnl_parm p1;
+		struct ip6_tnl_parm2 p1;
 		char *ptr;
 
 		buf[sizeof(buf) - 1] = '\0';
@@ -312,10 +391,12 @@ static int do_tunnels_list(struct ip6_tnl_parm *p)
 			fprintf(stderr, "Failed to get type of \"%s\"\n", name);
 			continue;
 		}
-		if (type != ARPHRD_TUNNEL6)
+		if (type != ARPHRD_TUNNEL6 && type != ARPHRD_IP6GRE)
 			continue;
 		memset(&p1, 0, sizeof(p1));
 		ip6_tnl_parm_init(&p1, 0);
+		if (type == ARPHRD_IP6GRE)
+			p1.proto = IPPROTO_GRE;
 		strcpy(p1.name, name);
 		p1.link = ll_name_to_index(p1.name);
 		if (p1.link == 0)
@@ -346,7 +427,7 @@ static int do_tunnels_list(struct ip6_tnl_parm *p)
 
 static int do_show(int argc, char **argv)
 {
-        struct ip6_tnl_parm p;
+        struct ip6_tnl_parm2 p;
 
 	ll_init_map(&rth);
 	ip6_tnl_parm_init(&p, 0);
@@ -369,28 +450,44 @@ static int do_show(int argc, char **argv)
 
 static int do_add(int cmd, int argc, char **argv)
 {
-	struct ip6_tnl_parm p;
+	struct ip6_tnl_parm2 p;
 
 	ip6_tnl_parm_init(&p, 1);
 
 	if (parse_args(argc, argv, cmd, &p) < 0)
 		return -1;
 
-	return tnl_add_ioctl(cmd,
-			     cmd == SIOCCHGTUNNEL && p.name[0] ?
-			     p.name : "ip6tnl0", p.name, &p);
+	switch (p.proto) {
+	case IPPROTO_IPIP:
+	case IPPROTO_IPV6:
+		return tnl_add_ioctl(cmd, "ip6tnl0", p.name, &p);
+	case IPPROTO_GRE:
+		return tnl_add_ioctl(cmd, "ip6gre0", p.name, &p);
+	default:
+		fprintf(stderr, "cannot determine tunnel mode (ip6ip6, ipip6 or gre)\n");
+	}
+	return -1;
 }
 
 static int do_del(int argc, char **argv)
 {
-	struct ip6_tnl_parm p;
+	struct ip6_tnl_parm2 p;
 
 	ip6_tnl_parm_init(&p, 1);
 
 	if (parse_args(argc, argv, SIOCDELTUNNEL, &p) < 0)
 		return -1;
 
-	return tnl_del_ioctl(p.name[0] ? p.name : "ip6tnl0", p.name, &p);
+	switch (p.proto) {
+	case IPPROTO_IPIP:
+	case IPPROTO_IPV6:
+		return tnl_del_ioctl("ip6tnl0", p.name, &p);
+	case IPPROTO_GRE:
+		return tnl_del_ioctl("ip6gre0", p.name, &p);
+	default:
+		return tnl_del_ioctl(p.name, p.name, &p);
+	}
+	return -1;
 }
 
 int do_ip6tunnel(int argc, char **argv)
diff --git a/ip/iplink.c b/ip/iplink.c
index ada9d42..16cb6fe 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -85,7 +85,8 @@ void iplink_usage(void)
 	if (iplink_have_newlink()) {
 		fprintf(stderr, "\n");
 		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | can |\n");
-		fprintf(stderr, "          bridge | ipoib | ip6tnl | ipip | sit | vxlan }\n");
+		fprintf(stderr, "          bridge | ipoib | ip6tnl | ipip | sit | vxlan |\n");
+		fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap }\n");
 	}
 	exit(-1);
 }
@@ -243,7 +244,7 @@ static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 			}
 			ivt.vf = vf;
 			addattr_l(&req->n, sizeof(*req), IFLA_VF_TX_RATE, &ivt, sizeof(ivt));
-		
+
 		} else if (matches(*argv, "spoofchk") == 0) {
 			struct ifla_vf_spoofchk ivs;
 			NEXT_ARG();
@@ -286,7 +287,6 @@ static int iplink_parse_vf(int vf, int *argcp, char ***argvp,
 	return 0;
 }
 
-
 int iplink_parse(int argc, char **argv, struct iplink_req *req,
 		char **name, char **type, char **link, char **dev, int *group)
 {
@@ -811,7 +811,6 @@ static int set_address(struct ifreq *ifr, int brd)
 	return 0;
 }
 
-
 static int do_set(int argc, char **argv)
 {
 	char *dev = NULL;
diff --git a/ip/link_gre6.c b/ip/link_gre6.c
new file mode 100644
index 0000000..4c9c536
--- /dev/null
+++ b/ip/link_gre6.c
@@ -0,0 +1,398 @@
+/*
+ * link_gre6.c	gre driver module
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Dmitry Kozlov <xeb@mail.ru>
+ *
+ */
+
+#include <string.h>
+#include <net/if.h>
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <arpa/inet.h>
+
+#include <linux/ip.h>
+#include <linux/if_tunnel.h>
+#include <linux/ip6_tunnel.h>
+
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+#include "tunnel.h"
+
+#define IP6_FLOWINFO_TCLASS	htonl(0x0FF00000)
+#define IP6_FLOWINFO_FLOWLABEL	htonl(0x000FFFFF)
+
+#define DEFAULT_TNL_HOP_LIMIT	(64)
+
+static void usage(void) __attribute__((noreturn));
+static void usage(void)
+{
+	fprintf(stderr, "Usage: ip link { add | set | change | replace | del } NAME\n");
+	fprintf(stderr, "          type { ip6gre | ip6gretap } [ remote ADDR ] [ local ADDR ]\n");
+	fprintf(stderr, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
+	fprintf(stderr, "          [ hoplimit TTL ] [ encaplimit ELIM ]\n");
+	fprintf(stderr, "          [ tclass TCLASS ] [ flowlabel FLOWLABEL ]\n");
+	fprintf(stderr, "          [ dscp inherit ] [ dev PHYS_DEV ]\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, "Where: NAME      := STRING\n");
+	fprintf(stderr, "       ADDR      := IPV6_ADDRESS\n");
+	fprintf(stderr, "       TTL       := { 0..255 } (default=%d)\n",
+		DEFAULT_TNL_HOP_LIMIT);
+	fprintf(stderr, "       KEY       := { DOTTED_QUAD | NUMBER }\n");
+	fprintf(stderr, "       ELIM      := { none | 0..255 }(default=%d)\n",
+		IPV6_DEFAULT_TNL_ENCAP_LIMIT);
+	fprintf(stderr, "       TCLASS    := { 0x0..0xff | inherit }\n");
+	fprintf(stderr, "       FLOWLABEL := { 0x0..0xfffff | inherit }\n");
+	exit(-1);
+}
+
+static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
+			 struct nlmsghdr *n)
+{
+	struct {
+		struct nlmsghdr n;
+		struct ifinfomsg i;
+		char buf[1024];
+	} req;
+	struct ifinfomsg *ifi = (struct ifinfomsg *)(n + 1);
+	struct rtattr *tb[IFLA_MAX + 1];
+	struct rtattr *linkinfo[IFLA_INFO_MAX+1];
+	struct rtattr *greinfo[IFLA_GRE_MAX + 1];
+	__u16 iflags = 0;
+	__u16 oflags = 0;
+	unsigned ikey = 0;
+	unsigned okey = 0;
+	struct in6_addr raddr = IN6ADDR_ANY_INIT;
+	struct in6_addr laddr = IN6ADDR_ANY_INIT;
+	unsigned link = 0;
+	unsigned flowinfo = 0;
+	unsigned flags = 0;
+	__u8 hop_limit = DEFAULT_TNL_HOP_LIMIT;
+	__u8 encap_limit = IPV6_DEFAULT_TNL_ENCAP_LIMIT;
+	int len;
+
+	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
+		memset(&req, 0, sizeof(req));
+
+		req.n.nlmsg_len = NLMSG_LENGTH(sizeof(*ifi));
+		req.n.nlmsg_flags = NLM_F_REQUEST;
+		req.n.nlmsg_type = RTM_GETLINK;
+		req.i.ifi_family = preferred_family;
+		req.i.ifi_index = ifi->ifi_index;
+
+		if (rtnl_talk(&rth, &req.n, 0, 0, &req.n) < 0) {
+get_failed:
+			fprintf(stderr,
+				"Failed to get existing tunnel info.\n");
+			return -1;
+		}
+
+		len = req.n.nlmsg_len;
+		len -= NLMSG_LENGTH(sizeof(*ifi));
+		if (len < 0)
+			goto get_failed;
+
+		parse_rtattr(tb, IFLA_MAX, IFLA_RTA(&req.i), len);
+
+		if (!tb[IFLA_LINKINFO])
+			goto get_failed;
+
+		parse_rtattr_nested(linkinfo, IFLA_INFO_MAX, tb[IFLA_LINKINFO]);
+
+		if (!linkinfo[IFLA_INFO_DATA])
+			goto get_failed;
+
+		parse_rtattr_nested(greinfo, IFLA_GRE_MAX,
+				    linkinfo[IFLA_INFO_DATA]);
+
+		if (greinfo[IFLA_GRE_IKEY])
+			ikey = rta_getattr_u32(greinfo[IFLA_GRE_IKEY]);
+
+		if (greinfo[IFLA_GRE_OKEY])
+			okey = rta_getattr_u32(greinfo[IFLA_GRE_OKEY]);
+
+		if (greinfo[IFLA_GRE_IFLAGS])
+			iflags = rta_getattr_u16(greinfo[IFLA_GRE_IFLAGS]);
+
+		if (greinfo[IFLA_GRE_OFLAGS])
+			oflags = rta_getattr_u16(greinfo[IFLA_GRE_OFLAGS]);
+
+		if (greinfo[IFLA_GRE_LOCAL])
+			memcpy(&laddr, RTA_DATA(greinfo[IFLA_GRE_LOCAL]), sizeof(laddr));
+
+		if (greinfo[IFLA_GRE_REMOTE])
+			memcpy(&raddr, RTA_DATA(greinfo[IFLA_GRE_REMOTE]), sizeof(raddr));
+
+		if (greinfo[IFLA_GRE_TTL])
+			hop_limit = rta_getattr_u8(greinfo[IFLA_GRE_TTL]);
+
+		if (greinfo[IFLA_GRE_LINK])
+			link = rta_getattr_u32(greinfo[IFLA_GRE_LINK]);
+
+		if (greinfo[IFLA_GRE_ENCAP_LIMIT])
+			encap_limit = rta_getattr_u8(greinfo[IFLA_GRE_ENCAP_LIMIT]);
+
+		if (greinfo[IFLA_GRE_FLOWINFO])
+			flowinfo = rta_getattr_u32(greinfo[IFLA_GRE_FLOWINFO]);
+
+		if (greinfo[IFLA_GRE_FLAGS])
+			flags = rta_getattr_u32(greinfo[IFLA_GRE_FLAGS]);
+	}
+
+	while (argc > 0) {
+		if (!matches(*argv, "key")) {
+			unsigned uval;
+
+			NEXT_ARG();
+			iflags |= GRE_KEY;
+			oflags |= GRE_KEY;
+			if (strchr(*argv, '.'))
+				uval = get_addr32(*argv);
+			else {
+				if (get_unsigned(&uval, *argv, 0) < 0) {
+					fprintf(stderr,
+						"Invalid value for \"key\"\n");
+					exit(-1);
+				}
+				uval = htonl(uval);
+			}
+
+			ikey = okey = uval;
+		} else if (!matches(*argv, "ikey")) {
+			unsigned uval;
+
+			NEXT_ARG();
+			iflags |= GRE_KEY;
+			if (strchr(*argv, '.'))
+				uval = get_addr32(*argv);
+			else {
+				if (get_unsigned(&uval, *argv, 0)<0) {
+					fprintf(stderr, "invalid value of \"ikey\"\n");
+					exit(-1);
+				}
+				uval = htonl(uval);
+			}
+			ikey = uval;
+		} else if (!matches(*argv, "okey")) {
+			unsigned uval;
+
+			NEXT_ARG();
+			oflags |= GRE_KEY;
+			if (strchr(*argv, '.'))
+				uval = get_addr32(*argv);
+			else {
+				if (get_unsigned(&uval, *argv, 0)<0) {
+					fprintf(stderr, "invalid value of \"okey\"\n");
+					exit(-1);
+				}
+				uval = htonl(uval);
+			}
+			okey = uval;
+		} else if (!matches(*argv, "seq")) {
+			iflags |= GRE_SEQ;
+			oflags |= GRE_SEQ;
+		} else if (!matches(*argv, "iseq")) {
+			iflags |= GRE_SEQ;
+		} else if (!matches(*argv, "oseq")) {
+			oflags |= GRE_SEQ;
+		} else if (!matches(*argv, "csum")) {
+			iflags |= GRE_CSUM;
+			oflags |= GRE_CSUM;
+		} else if (!matches(*argv, "icsum")) {
+			iflags |= GRE_CSUM;
+		} else if (!matches(*argv, "ocsum")) {
+			oflags |= GRE_CSUM;
+		} else if (!matches(*argv, "remote")) {
+			inet_prefix addr;
+			NEXT_ARG();
+			get_prefix(&addr, *argv, preferred_family);
+			if (addr.family == AF_UNSPEC)
+				invarg("\"remote\" address family is AF_UNSPEC", *argv);
+			memcpy(&raddr, &addr.data, sizeof(raddr));
+		} else if (!matches(*argv, "local")) {
+			inet_prefix addr;
+			NEXT_ARG();
+			get_prefix(&addr, *argv, preferred_family);
+			if (addr.family == AF_UNSPEC)
+				invarg("\"local\" address family is AF_UNSPEC", *argv);
+			memcpy(&laddr, &addr.data, sizeof(laddr));
+		} else if (!matches(*argv, "dev")) {
+			NEXT_ARG();
+			link = if_nametoindex(*argv);
+			if (link == 0)
+				exit(-1);
+		} else if (!matches(*argv, "ttl") ||
+			   !matches(*argv, "hoplimit")) {
+			__u8 uval;
+			NEXT_ARG();
+			if (get_u8(&uval, *argv, 0))
+				invarg("invalid TTL", *argv);
+			hop_limit = uval;
+		} else if (!matches(*argv, "tos") ||
+			   !matches(*argv, "tclass") ||
+			   !matches(*argv, "dsfield")) {
+			__u8 uval;
+			NEXT_ARG();
+			if (strcmp(*argv, "inherit") == 0)
+				flags |= IP6_TNL_F_USE_ORIG_TCLASS;
+			else {
+				if (get_u8(&uval, *argv, 16))
+					invarg("invalid TClass", *argv);
+				flowinfo |= htonl((__u32)uval << 20) & IP6_FLOWINFO_TCLASS;
+				flags &= ~IP6_TNL_F_USE_ORIG_TCLASS;
+			}
+		} else if (strcmp(*argv, "flowlabel") == 0 ||
+			   strcmp(*argv, "fl") == 0) {
+			__u32 uval;
+			NEXT_ARG();
+			if (strcmp(*argv, "inherit") == 0)
+				flags |= IP6_TNL_F_USE_ORIG_FLOWLABEL;
+			else {
+				if (get_u32(&uval, *argv, 16))
+					invarg("invalid Flowlabel", *argv);
+				if (uval > 0xFFFFF)
+					invarg("invalid Flowlabel", *argv);
+				flowinfo |= htonl(uval) & IP6_FLOWINFO_FLOWLABEL;
+				flags &= ~IP6_TNL_F_USE_ORIG_FLOWLABEL;
+			}
+		} else if (strcmp(*argv, "dscp") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "inherit") != 0)
+				invarg("not inherit", *argv);
+			flags |= IP6_TNL_F_RCV_DSCP_COPY;
+		} else
+			usage();
+		argc--; argv++;
+	}
+
+	addattr32(n, 1024, IFLA_GRE_IKEY, ikey);
+	addattr32(n, 1024, IFLA_GRE_OKEY, okey);
+	addattr_l(n, 1024, IFLA_GRE_IFLAGS, &iflags, 2);
+	addattr_l(n, 1024, IFLA_GRE_OFLAGS, &oflags, 2);
+	addattr_l(n, 1024, IFLA_GRE_LOCAL, &laddr, sizeof(laddr));
+	addattr_l(n, 1024, IFLA_GRE_REMOTE, &raddr, sizeof(raddr));
+	if (link)
+		addattr32(n, 1024, IFLA_GRE_LINK, link);
+	addattr_l(n, 1024, IFLA_GRE_TTL, &hop_limit, 1);
+	addattr_l(n, 1024, IFLA_GRE_ENCAP_LIMIT, &encap_limit, 1);
+	addattr_l(n, 1024, IFLA_GRE_FLOWINFO, &flowinfo, 4);
+	addattr_l(n, 1024, IFLA_GRE_FLAGS, &flowinfo, 4);
+
+	return 0;
+}
+
+static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
+{
+	char s1[1024];
+	char s2[64];
+	const char *local = "any";
+	const char *remote = "any";
+	unsigned iflags = 0;
+	unsigned oflags = 0;
+	unsigned flags = 0;
+	unsigned flowinfo = 0;
+	struct in6_addr in6_addr_any = IN6ADDR_ANY_INIT;
+
+	if (!tb)
+		return;
+
+	if (tb[IFLA_GRE_FLAGS])
+		flags = rta_getattr_u32(tb[IFLA_GRE_FLAGS]);
+
+	if (tb[IFLA_GRE_FLOWINFO])
+		flags = rta_getattr_u32(tb[IFLA_GRE_FLOWINFO]);
+
+	if (tb[IFLA_GRE_REMOTE]) {
+		struct in6_addr addr;
+		memcpy(&addr, RTA_DATA(tb[IFLA_GRE_REMOTE]), sizeof(addr));
+
+		if (memcmp(&addr, &in6_addr_any, sizeof(addr)))
+			remote = format_host(AF_INET6, sizeof(addr), &addr, s1, sizeof(s1));
+	}
+
+	fprintf(f, "remote %s ", remote);
+
+	if (tb[IFLA_GRE_LOCAL]) {
+		struct in6_addr addr;
+		memcpy(&addr, RTA_DATA(tb[IFLA_GRE_LOCAL]), sizeof(addr));
+
+		if (memcmp(&addr, &in6_addr_any, sizeof(addr)))
+			local = format_host(AF_INET6, sizeof(addr), &addr, s1, sizeof(s1));
+	}
+
+	fprintf(f, "local %s ", local);
+
+	if (tb[IFLA_GRE_LINK] && rta_getattr_u32(tb[IFLA_GRE_LINK])) {
+		unsigned link = rta_getattr_u32(tb[IFLA_GRE_LINK]);
+		const char *n = if_indextoname(link, s2);
+
+		if (n)
+			fprintf(f, "dev %s ", n);
+		else
+			fprintf(f, "dev %u ", link);
+	}
+
+	if (tb[IFLA_GRE_TTL] && rta_getattr_u8(tb[IFLA_GRE_TTL]))
+		fprintf(f, "hoplimit %d ", rta_getattr_u8(tb[IFLA_GRE_TTL]));
+
+	if (flags & IP6_TNL_F_IGN_ENCAP_LIMIT)
+		fprintf(f, "encaplimit none ");
+	else if (tb[IFLA_GRE_ENCAP_LIMIT]) {
+		int encap_limit = rta_getattr_u8(tb[IFLA_GRE_ENCAP_LIMIT]);
+
+		fprintf(f, "encaplimit %d ", encap_limit);
+	}
+
+	if (flags & IP6_TNL_F_USE_ORIG_FLOWLABEL)
+		fprintf(f, "flowlabel inherit ");
+	else
+		fprintf(f, "flowlabel 0x%05x ", ntohl(flowinfo & IP6_FLOWINFO_FLOWLABEL));
+
+	if (flags & IP6_TNL_F_RCV_DSCP_COPY)
+		fprintf(f, "dscp inherit ");
+
+	if (tb[IFLA_GRE_IFLAGS])
+		iflags = rta_getattr_u16(tb[IFLA_GRE_IFLAGS]);
+
+	if (tb[IFLA_GRE_OFLAGS])
+		oflags = rta_getattr_u16(tb[IFLA_GRE_OFLAGS]);
+
+	if ((iflags & GRE_KEY) && tb[IFLA_GRE_IKEY]) {
+		inet_ntop(AF_INET, RTA_DATA(tb[IFLA_GRE_IKEY]), s2, sizeof(s2));
+		fprintf(f, "ikey %s ", s2);
+	}
+
+	if ((oflags & GRE_KEY) && tb[IFLA_GRE_OKEY]) {
+		inet_ntop(AF_INET, RTA_DATA(tb[IFLA_GRE_OKEY]), s2, sizeof(s2));
+		fprintf(f, "okey %s ", s2);
+	}
+
+	if (iflags & GRE_SEQ)
+		fputs("iseq ", f);
+	if (oflags & GRE_SEQ)
+		fputs("oseq ", f);
+	if (iflags & GRE_CSUM)
+		fputs("icsum ", f);
+	if (oflags & GRE_CSUM)
+		fputs("ocsum ", f);
+}
+
+struct link_util ip6gre_link_util = {
+	.id = "ip6gre",
+	.maxattr = IFLA_GRE_MAX,
+	.parse_opt = gre_parse_opt,
+	.print_opt = gre_print_opt,
+};
+
+struct link_util ip6gretap_link_util = {
+	.id = "ip6gretap",
+	.maxattr = IFLA_GRE_MAX,
+	.parse_opt = gre_parse_opt,
+	.print_opt = gre_print_opt,
+};
-- 
1.8.3.2
