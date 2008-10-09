From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: ip: gre: Add GRE configuration support through rtnl_link
Date: Thu, 9 Oct 2008 15:08:24 +0800
Message-ID: <20081009070824.GA17003@gondor.apana.org.au>
References: <20081009070424.GA16684@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53926 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755783AbYJIHI1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 03:08:27 -0400
Content-Disposition: inline
In-Reply-To: <20081009070424.GA16684@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip: gre: Add GRE configuration support through rtnl_link

This patch adds support for configuring GRE tunnels using the
new rtnl_link interface.  This only works on kernels that have
the new GRE configuration interface.

This is accessed through the "ip link" command.  The previous
tunnel configuration interface "ip tunnel" remains as it is
and should be retained for compatibility with old kernels.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index d4efe40..b9b8760 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -2,6 +2,7 @@
 #define _IF_TUNNEL_H_
 
 #include <linux/types.h>
+#include <linux/ip.h>
 
 #define SIOCGETTUNNEL   (SIOCDEVPRIVATE + 0)
 #define SIOCADDTUNNEL   (SIOCDEVPRIVATE + 1)
@@ -47,4 +48,26 @@ struct ip_tunnel_prl {
 /* PRL flags */
 #define	PRL_DEFAULT		0x0001
 
+enum
+{
+	IFLA_GRE_UNSPEC,
+	IFLA_GRE_LINK,
+	IFLA_GRE_IFLAGS,
+	IFLA_GRE_OFLAGS,
+	IFLA_GRE_IKEY,
+	IFLA_GRE_OKEY,
+	IFLA_GRE_LOCAL,
+	IFLA_GRE_REMOTE,
+	IFLA_GRE_TTL,
+	IFLA_GRE_TOS,
+	IFLA_GRE_PMTUDISC,
+	IFLA_GRE_TYPE,
+	__IFLA_GRE_MAX,
+};
+
+#define IFLA_GRE_MAX	(__IFLA_GRE_MAX - 1)
+
+#define GRE_TYPE_TUN	0x00000000
+#define GRE_TYPE_TAP	0x00000001
+
 #endif /* _IF_TUNNEL_H_ */
diff --git a/ip/Makefile b/ip/Makefile
index 73978ff..98ba876 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -2,7 +2,7 @@ IPOBJ=ip.o ipaddress.o ipaddrlabel.o iproute.o iprule.o \
     rtm_map.o iptunnel.o ip6tunnel.o tunnel.o ipneigh.o ipntable.o iplink.o \
     ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o \
-    iplink_vlan.o link_veth.o
+    iplink_vlan.o link_veth.o link_gre.o
 
 RTMONOBJ=rtmon.o
 
diff --git a/ip/link_gre.c b/ip/link_gre.c
new file mode 100644
index 0000000..e92b0d3
--- /dev/null
+++ b/ip/link_gre.c
@@ -0,0 +1,294 @@
+/*
+ * link_gre.c	gre driver module
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Herbert Xu <herbert@gondor.apana.org.au>
+ *
+ */
+
+#include <string.h>
+#include <net/if.h>
+#include <linux/if_tunnel.h>
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <arpa/inet.h>
+
+#include "rt_names.h"
+#include "utils.h"
+#include "ip_common.h"
+#include "tunnel.h"
+
+static void usage(void) __attribute__((noreturn));
+static void usage(void)
+{
+	fprintf(stderr, "Usage: ip link { add | set | change | replace | del } NAME\n");
+	fprintf(stderr, "          type { gre | gretap } [ remote ADDR ] [ local ADDR ]\n");
+	fprintf(stderr, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
+	fprintf(stderr, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, "Where: NAME := STRING\n");
+	fprintf(stderr, "       ADDR := { IP_ADDRESS | any }\n");
+	fprintf(stderr, "       TOS  := { NUMBER | inherit }\n");
+	fprintf(stderr, "       TTL  := { 1..255 | inherit }\n");
+	fprintf(stderr, "       KEY  := { DOTTED_QUAD | NUMBER }\n");
+	exit(-1);
+}
+
+static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
+			 struct nlmsghdr *n)
+{
+	__u16 iflags = 0;
+	__u16 oflags = 0;
+	unsigned ikey = 0;
+	unsigned okey = 0;
+	unsigned saddr = 0;
+	unsigned daddr = 0;
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
+		} else if (!matches(*argv, "nopmtudisc")) {
+			__u8 val = 0;
+
+			addattr_l(n, 1024, IFLA_GRE_PMTUDISC, &val, 1);
+		} else if (!matches(*argv, "pmtudisc")) {
+			__u8 val = 1;
+
+			addattr_l(n, 1024, IFLA_GRE_PMTUDISC, &val, 1);
+		} else if (!matches(*argv, "remote")) {
+			NEXT_ARG();
+			if (strcmp(*argv, "any"))
+				daddr = get_addr32(*argv);
+		} else if (!matches(*argv, "local")) {
+			NEXT_ARG();
+			if (strcmp(*argv, "any"))
+				saddr = get_addr32(*argv);
+		} else if (!matches(*argv, "dev")) {
+			unsigned link;
+
+			NEXT_ARG();
+			link = tnl_ioctl_get_ifindex(*argv);
+			if (link == 0)
+				exit(-1);
+
+			addattr32(n, 1024, IFLA_GRE_LINK, link);
+		} else if (!matches(*argv, "ttl") ||
+			   !matches(*argv, "hoplimit")) {
+			unsigned uval;
+			__u8 ttl;
+
+			NEXT_ARG();
+			if (strcmp(*argv, "inherit") != 0) {
+				if (get_unsigned(&uval, *argv, 0))
+					invarg("invalid TTL\n", *argv);
+				if (uval > 255)
+					invarg("TTL must be <= 255\n", *argv);
+				ttl = uval;
+				addattr_l(n, 1024, IFLA_GRE_TTL, &ttl, 1);
+			}
+		} else if (!matches(*argv, "tos") ||
+			   !matches(*argv, "tclass") ||
+			   !matches(*argv, "dsfield")) {
+			__u32 uval;
+			__u8 tos;
+
+			NEXT_ARG();
+			if (strcmp(*argv, "inherit") != 0) {
+				if (rtnl_dsfield_a2n(&uval, *argv))
+					invarg("bad TOS value", *argv);
+				tos = uval;
+			} else
+				tos = 1;
+			addattr_l(n, 1024, IFLA_GRE_TOS, &tos, 1);
+		} else 
+			usage();
+		argc--; argv++;
+	}
+
+	if (!ikey && IN_MULTICAST(ntohl(daddr))) {
+		ikey = daddr;
+		iflags |= GRE_KEY;
+	}
+	if (!okey && IN_MULTICAST(ntohl(daddr))) {
+		okey = daddr;
+		oflags |= GRE_KEY;
+	}
+	if (IN_MULTICAST(ntohl(daddr)) && !saddr) {
+		fprintf(stderr, "Broadcast tunnel requires a source address.\n");
+		return -1;
+	}
+
+	addattr32(n, 1024, IFLA_GRE_IKEY, ikey);
+	addattr32(n, 1024, IFLA_GRE_OKEY, okey);
+	addattr_l(n, 1024, IFLA_GRE_IFLAGS, &iflags, 2);
+	addattr_l(n, 1024, IFLA_GRE_OFLAGS, &oflags, 2);
+	addattr_l(n, 1024, IFLA_GRE_LOCAL, &saddr, 4);
+	addattr_l(n, 1024, IFLA_GRE_REMOTE, &daddr, 4);
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
+
+	if (!tb)
+		return;
+
+	if (tb[IFLA_GRE_REMOTE]) {
+		unsigned addr = *(__u32 *)RTA_DATA(tb[IFLA_GRE_REMOTE]);
+
+		if (addr)
+			remote = format_host(AF_INET, 4, &addr, s1, sizeof(s1));
+	}
+
+	fprintf(f, "remote %s ", remote);
+
+	if (tb[IFLA_GRE_LOCAL]) {
+		unsigned addr = *(__u32 *)RTA_DATA(tb[IFLA_GRE_LOCAL]);
+
+		if (addr)
+			local = format_host(AF_INET, 4, &addr, s1, sizeof(s1));
+	}
+
+	fprintf(f, "local %s ", local);
+
+	if (tb[IFLA_GRE_LINK] && *(__u32 *)RTA_DATA(tb[IFLA_GRE_LINK])) {
+		unsigned link = *(__u32 *)RTA_DATA(tb[IFLA_GRE_LINK]);
+		char *n = tnl_ioctl_get_ifname(link);
+
+		if (n)
+			fprintf(f, "dev %s ", n);
+		else
+			fprintf(f, "dev %u ", link);
+	}
+
+	if (tb[IFLA_GRE_TTL] && *(__u8 *)RTA_DATA(tb[IFLA_GRE_TTL]))
+		fprintf(f, "ttl %d ", *(__u8 *)RTA_DATA(tb[IFLA_GRE_TTL]));
+	else
+		fprintf(f, "ttl inherit ");
+
+	if (tb[IFLA_GRE_TOS] && *(__u8 *)RTA_DATA(tb[IFLA_GRE_TOS])) {
+		int tos = *(__u8 *)RTA_DATA(tb[IFLA_GRE_TOS]);
+
+		fputs("tos ", f);
+		if (tos == 1)
+			fputs("inherit ", f);
+		else
+			fprintf(f, "0x%x ", tos);
+	}
+
+	if (tb[IFLA_GRE_PMTUDISC] &&
+	    !*(__u8 *)RTA_DATA(tb[IFLA_GRE_PMTUDISC]))
+		fputs("nopmtudisc ", f);
+
+	if (tb[IFLA_GRE_IFLAGS])
+		iflags = *(__u16 *)RTA_DATA(tb[IFLA_GRE_IFLAGS]);
+
+	if (tb[IFLA_GRE_OFLAGS])
+		oflags = *(__u16 *)RTA_DATA(tb[IFLA_GRE_OFLAGS]);
+
+	if (iflags & GRE_KEY && tb[IFLA_GRE_IKEY] &&
+	    *(__u32 *)RTA_DATA(tb[IFLA_GRE_IKEY])) {
+		inet_ntop(AF_INET, RTA_DATA(tb[IFLA_GRE_IKEY]), s2, sizeof(s2));
+		fprintf(f, "ikey %s ", s2);
+	}
+
+	if (oflags & GRE_KEY && tb[IFLA_GRE_OKEY] &&
+	    *(__u32 *)RTA_DATA(tb[IFLA_GRE_OKEY])) {
+		inet_ntop(AF_INET, RTA_DATA(tb[IFLA_GRE_OKEY]), s2, sizeof(s2));
+		fprintf(f, "ikey %s ", s2);
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
+struct link_util gre_link_util = {
+	.id = "gre",
+	.maxattr = IFLA_GRE_MAX,
+	.parse_opt = gre_parse_opt,
+	.print_opt = gre_print_opt,
+};
+
+struct link_util gretap_link_util = {
+	.id = "gretap",
+	.maxattr = IFLA_GRE_MAX,
+	.parse_opt = gre_parse_opt,
+	.print_opt = gre_print_opt,
+};
