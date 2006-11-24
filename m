From: nakam@linux-ipv6.org
Subject: [PATCH 7/7] [IP] TUNNEL: IPv6-over-IPv6 tunnel support.
Date: Fri, 24 Nov 2006 12:27:09 +0900
Message-ID: <1164338829943-git-send-email-nakam@linux-ipv6.org>
Cc: takamiya@po.ntts.co.jp, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi020.linux-ipv6.org ([203.178.140.20]:9869 "EHLO
	neptune.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S934241AbWKXDbw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Nov 2006 22:31:52 -0500
To: shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Fix ip6tunnel.c to be fit with current ip command style.
Unlike other modules currently iptunnel (and ip6tunnel) is not
designed as protocol-independent because of unarranged structure
between IPv4 and IPv6.

Usage: ip -f inet6 tunnel { add | change | del | show } [ NAME ]
          [ remote ADDR local ADDR ] [ dev PHYS_DEV ]
          [ encaplimit ELIM ]
          [ hoplimit HLIM ] [ tc TC ] [ fl FL ]
          [ dscp inherit ]

Where: NAME := STRING
       ADDR := IPV6_ADDRESS
       ELIM := { none | 0..255 }(default=4)
       HLIM := 0..255 (default=64)
       TC   := { 0x0..0xff | inherit }
       FL   := { 0x0..0xfffff | inherit }

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 include/linux/ip6_tunnel.h |   34 +++
 ip/Makefile                |    2 
 ip/ip6tunnel.c             |  543 +++++++++++++++++++++-----------------------
 ip/ip_common.h             |    1 
 ip/iptunnel.c              |    8 +
 5 files changed, 308 insertions(+), 280 deletions(-)

diff --git a/include/linux/ip6_tunnel.h b/include/linux/ip6_tunnel.h
new file mode 100644
index 0000000..5c23aeb
--- /dev/null
+++ b/include/linux/ip6_tunnel.h
@@ -0,0 +1,34 @@
+/*
+ * $Id$
+ */
+
+#ifndef _IP6_TUNNEL_H
+#define _IP6_TUNNEL_H
+
+#define IPV6_TLV_TNL_ENCAP_LIMIT 4
+#define IPV6_DEFAULT_TNL_ENCAP_LIMIT 4
+
+/* don't add encapsulation limit if one isn't present in inner packet */
+#define IP6_TNL_F_IGN_ENCAP_LIMIT 0x1
+/* copy the traffic class field from the inner packet */
+#define IP6_TNL_F_USE_ORIG_TCLASS 0x2
+/* copy the flowlabel from the inner packet */
+#define IP6_TNL_F_USE_ORIG_FLOWLABEL 0x4
+/* being used for Mobile IPv6 */
+#define IP6_TNL_F_MIP6_DEV 0x8
+/* copy DSCP from the outer packet */
+#define IP6_TNL_F_RCV_DSCP_COPY 0x10
+
+struct ip6_tnl_parm {
+	char name[IFNAMSIZ];	/* name of tunnel device */
+	int link;		/* ifindex of underlying L2 interface */
+	__u8 proto;		/* tunnel protocol */
+	__u8 encap_limit;	/* encapsulation limit for tunnel */
+	__u8 hop_limit;		/* hop limit for tunnel */
+	__u32 flowinfo;		/* traffic class and flowlabel for tunnel */
+	__u32 flags;		/* tunnel flags */
+	struct in6_addr laddr;	/* local tunnel end-point address */
+	struct in6_addr raddr;	/* remote tunnel end-point address */
+};
+
+#endif
diff --git a/ip/Makefile b/ip/Makefile
index 7d4b56f..a749993 100644
--- a/ip/Makefile
+++ b/ip/Makefile
@@ -1,5 +1,5 @@
 IPOBJ=ip.o ipaddress.o iproute.o iprule.o \
-    rtm_map.o iptunnel.o tunnel.o ipneigh.o ipntable.o iplink.o \
+    rtm_map.o iptunnel.o ip6tunnel.o tunnel.o ipneigh.o ipntable.o iplink.o \
     ipmaddr.o ipmonitor.o ipmroute.o ipprefix.o \
     ipxfrm.o xfrm_state.o xfrm_policy.o xfrm_monitor.o
 
diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index c8578e5..488afcb 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -28,139 +28,47 @@
 #include <stdio.h>
 #include <string.h>
 #include <stdlib.h>
-#include <errno.h>
-
-#include <sys/ioctl.h>
-#include <sys/socket.h>
-#include <net/if.h>
-#include <netinet/in.h>
-#include <netdb.h>
 #include <unistd.h>
+#include <sys/types.h>
+#include <sys/socket.h>
 #include <arpa/inet.h>
-
-#include <asm/types.h>
-#include <linux/sockios.h>
+#include <sys/ioctl.h>
 #include <linux/ip.h>
+#include <linux/if.h>
+#include <linux/if_arp.h>
 #include <linux/if_tunnel.h>
+#include <linux/ip6_tunnel.h>
 
-#include "ipv6_tunnel.h"
+#include "utils.h"
+#include "tunnel.h"
 
+#define IP6_FLOWINFO_TCLASS	htonl(0x0FF00000)
+#define IP6_FLOWINFO_FLOWLABEL	htonl(0x000FFFFF)
 
-int tunnel_local_packets = 0;
+#define DEFAULT_TNL_HOP_LIMIT	(64)
+
+static void usage(void) __attribute__((noreturn));
 
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ipv6tunnel { add | change | del | show } [ NAME ]\n");
-	fprintf(stderr, "          [ --allow-local-packets ]\n");
-	fprintf(stderr, "          [ --use-original-traffic-class ]\n");
-	fprintf(stderr, "          [ remote ADDR local ADDR ]\n");
-	fprintf(stderr, "          [ dev PHYS_DEV ]\n");
-	fprintf(stderr, "          [ encaplimit TEL ]\n");
-	fprintf(stderr, "          [ hoplimit HOPLIMIT ]\n"); 
-	fprintf(stderr, "          [ flowlabel FL ]\n");
+	fprintf(stderr, "Usage: ip -f inet6 tunnel { add | change | del | show } [ NAME ]\n");
+	fprintf(stderr, "          [ remote ADDR local ADDR ] [ dev PHYS_DEV ]\n");
+	fprintf(stderr, "          [ encaplimit ELIM ]\n");
+	fprintf(stderr ,"          [ hoplimit HLIM ] [ tc TC ] [ fl FL ]\n");
+	fprintf(stderr, "          [ dscp inherit ]\n");
+	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: NAME := STRING\n");
 	fprintf(stderr, "       ADDR := IPV6_ADDRESS\n");
-	fprintf(stderr, "       HOPLIMIT := 0..255\n");
-	fprintf(stderr, "       TEL := { none | 0..255 }\n");
-	fprintf(stderr, "       FL := 0x0..0xfffff\n");
-	fprintf(stderr, "       PHYS_DEV := STRING\n");
+	fprintf(stderr, "       ELIM := { none | 0..255 }(default=%d)\n",
+		IPV6_DEFAULT_TNL_ENCAP_LIMIT);
+	fprintf(stderr, "       HLIM := 0..255 (default=%d)\n",
+		DEFAULT_TNL_HOP_LIMIT);
+	fprintf(stderr, "       TC   := { 0x0..0xff | inherit }\n");
+	fprintf(stderr, "       FL   := { 0x0..0xfffff | inherit }\n");
 	exit(-1);
 }
 
-static int do_ioctl_get_ifindex(char *dev)
-{
-	struct ifreq ifr;
-	int fd;
-	int err;
-
-//	fprintf(stderr, "do_ioctl_get_ifindex\n");
-
-	strcpy(ifr.ifr_name, dev);
-	fd = socket(AF_INET6, SOCK_DGRAM, 0);
-	err = ioctl(fd, SIOCGIFINDEX, &ifr);
-	if (err) {
-		perror("ioctl");
-		return 0;
-	}
-	close(fd);
-	return ifr.ifr_ifindex;
-}
-
-static char *do_ioctl_get_ifname(int idx)
-{
-	static struct ifreq ifr;
-	int fd;
-	int err;
-
-//	fprintf(stderr, "do_ioctl_get_ifname\n");
-
-	ifr.ifr_ifindex = idx;
-	fd = socket(AF_INET6, SOCK_DGRAM, 0);
-	err = ioctl(fd, SIOCGIFNAME, &ifr);
-	if (err) {
-		perror("ioctl");
-		return NULL;
-	}
-	close(fd);
-	return ifr.ifr_name;
-}
-
-static int do_get_ioctl(char *basedev, struct ipv6_tnl_parm *p)
-{
-	struct ifreq ifr;
-	int fd;
-	int err;
-
-//	fprintf(stderr, "do_get_ioctl\n");
-
-	strcpy(ifr.ifr_name, basedev);
-	ifr.ifr_ifru.ifru_data = (void *)p;
-	fd = socket(AF_INET6, SOCK_DGRAM, 0);
-	err = ioctl(fd, SIOCGETTUNNEL, &ifr);
-	if (err)
-		perror("ioctl");
-	close(fd);
-	return err;
-}
-
-static int do_add_ioctl(int cmd, char *basedev, struct ipv6_tnl_parm *p)
-{
-	struct ifreq ifr;
-	int fd;
-	int err;
-
-//	fprintf(stderr, "do_add_ioctl\n");
-
-	strcpy(ifr.ifr_name, basedev);
-	ifr.ifr_ifru.ifru_data = (void *)p;
-	fd = socket(AF_INET6, SOCK_DGRAM, 0);
-	err = ioctl(fd, cmd, &ifr);
-	if (err)
-		perror("ioctl");
-	close(fd);
-	return err;
-}
-
-
-static int do_del_ioctl(char *basedev, struct ipv6_tnl_parm *p)
-{
-	struct ifreq ifr;
-	int fd;
-	int err;
-
-//	fprintf(stderr, "do_del_ioctl\n");
-
-	strcpy(ifr.ifr_name, basedev);
-	ifr.ifr_ifru.ifru_data = (void *)p;
-	fd = socket(AF_INET6, SOCK_DGRAM, 0);
-	err = ioctl(fd, SIOCDELTUNNEL, &ifr);
-	if (err)
-		perror("ioctl");
-	close(fd);
-	return err;
-}
-
-void print_tunnel(struct ipv6_tnl_parm *p)
+static void print_tunnel(struct ip6_tnl_parm *p)
 {
 	char remote[64];
 	char local[64];
@@ -168,235 +76,312 @@ void print_tunnel(struct ipv6_tnl_parm *
 	inet_ntop(AF_INET6, &p->raddr, remote, sizeof(remote));
 	inet_ntop(AF_INET6, &p->laddr, local, sizeof(local));
 
-	printf("%s: %s/IPv6 remote %s local %s",
-	       p->name,
-	       (p->proto == IPPROTO_IPV6 ? "IPv6" : "unknown"),
-	       remote, local);
+	printf("%s: %s/ipv6 remote %s local %s",
+	       p->name, tnl_strproto(p->proto), remote, local);
 	if (p->link) {
-		char *n = do_ioctl_get_ifname(p->link);
+		char *n = tnl_ioctl_get_ifname(p->link);
 		if (n)
 			printf(" dev %s", n);
 	}
-	if (p->encap_limit)
-		printf(" encaplimit %d", p->encap_limit);
 
-	printf(" hoplimit %d", p->hop_limit);
+	if (p->flags & IP6_TNL_F_IGN_ENCAP_LIMIT)
+		printf(" encaplimit none");
+	else
+		printf(" encaplimit %u", p->encap_limit);
 
-	if (p->flow_lbl)
-		printf(" flowlabel 0x%x", p->flow_lbl);
+	printf(" hoplimit %u", p->hop_limit);
 
-	if (p->flags) {
-		char flags[33];
-		char *fp = flags;
-		memset(flags, 0, 33);
-		if (p->flags & IPV6_TNL_F_IGN_ENCAP_LIMIT) {
-			*fp = 'E';
-			fp++;
-		}
-		if (p->flags & IPV6_TNL_F_USE_ORIG_TCLASS) {
-			*fp = 'T';
-			fp++;
-		}
-		if (p->flags & IPV6_TNL_F_ALLOW_LOCAL) {
-			*fp = 'L';
-			fp++;
-		}
-		if (p->flags & IPV6_TNL_F_KERNEL_DEV) {
-			*fp = 'K';
-			fp++;
-		}
-		if (p->flags & IPV6_TNL_F_MIPV6_DEV) {
-			*fp = 'M';
-			fp++;
-		}
-		if (p->flags & IPV6_TNL_F_RCV_ONLY) {
-			*fp = 'R';
-			fp++;
-		}
-		printf(" flags %s", flags);
+	if (p->flags & IP6_TNL_F_USE_ORIG_TCLASS)
+		printf(" tc inherit");
+	else {
+		__u32 val = ntohl(p->flowinfo & IP6_FLOWINFO_TCLASS);
+		printf(" tc 0x%02x", (__u8)(val >> 20));
 	}
-	printf("\n");
-}
-
-void resolve_name(char *name, struct in6_addr *ip6)
-{ 
-	struct addrinfo ai, *res; 
-	int err; 
-	memset(&ai, 0, sizeof(struct addrinfo)); 
-	ai.ai_family = AF_INET6; 
-	ai.ai_protocol = IPPROTO_IPV6; 
-	ai.ai_flags = AI_NUMERICHOST;
-	err = getaddrinfo(name, NULL, &ai, &res);
-	if (err)
-		exit(-1);
 
-	*ip6 = ((struct sockaddr_in6 *) (res->ai_addr))->sin6_addr;
-	freeaddrinfo(res); 
-} 
-
-int get_u8(__u8 *val, char *arg)
-{
-	unsigned long res = 0;
-	char *ptr;
-
-	if (!arg || !*arg)
-		return -1;
-	res = strtoul(arg, &ptr, 0);
-	if (!ptr || ptr == arg || *ptr || res > 0xFF)
-		return -1;
-	*val = (__u8) res;
-	return 0;
-}
+	if (p->flags & IP6_TNL_F_USE_ORIG_FLOWLABEL)
+		printf(" fl inherit");
+	else
+		printf(" fl 0x%05x", ntohl(p->flowinfo & IP6_FLOWINFO_FLOWLABEL));
 
-int get_u20(__u32 *val, char *arg)
-{
-	unsigned long res = 0;
-	char *ptr;
+	printf(" (flowinfo 0x%08x)", ntohl(p->flowinfo));
 
-	if (!arg || !*arg)
-		return -1;
-	res = strtoul(arg, &ptr, 0);
-	if (!ptr || ptr == arg || *ptr || res > 0xFFFFF)
-		return -1;
-	*val = res;
-	return 0;
+	if (p->flags & IP6_TNL_F_RCV_DSCP_COPY)
+		printf(" dscp inherit");
 }
 
-static int parse_args(int argc, char **argv, struct ipv6_tnl_parm *p)
+static int parse_args(int argc, char **argv, struct ip6_tnl_parm *p)
 {
 	char medium[IFNAMSIZ];
 
-//	fprintf(stderr, "parse_args\n");
-
-	memset(p, 0, sizeof(*p));
-	p->hop_limit = -1;
-	p->encap_limit = IPV6_DEFAULT_TNL_ENCAP_LIMIT;
-	p->proto = IPPROTO_IPV6;
-	memset(&medium, 0, sizeof(medium));
+	memset(medium, 0, sizeof(medium));
 
 	while (argc > 0) {
-		if (!strcmp(*argv, "--help") || !strcmp(*argv, "-h")) {
-			usage();
-		} else if (!strcmp(*argv, "--allow-local-packets")) {
-			p->flags |= IPV6_TNL_F_ALLOW_LOCAL;
-		} else if (!strcmp(*argv, "--use-original-traffic-class")) {
-			p->flags |= IPV6_TNL_F_USE_ORIG_TCLASS;
-		} else if (!strcmp(*argv, "remote")) {
-			argv++; 
-			if (--argc <= 0) 
-				usage();
-			resolve_name(*argv, &p->raddr);
-		} else if (!strcmp(*argv, "local")) {
-			argv++; 
-			if (--argc <= 0) 
-				usage();
-			resolve_name(*argv, &p->laddr);
-		} else if (!strcmp(*argv, "dev")) {
-			argv++; 
-			if (--argc <= 0) 
-				usage();
+		if (strcmp(*argv, "remote") == 0) {
+			inet_prefix raddr;
+			NEXT_ARG();
+			get_prefix(&raddr, *argv, preferred_family);
+			if (raddr.family == AF_UNSPEC)
+				invarg("\"remote\" address family is AF_UNSPEC", *argv);
+			memcpy(&p->raddr, &raddr.data, sizeof(p->raddr));
+		} else if (strcmp(*argv, "local") == 0) {
+			inet_prefix laddr;
+			NEXT_ARG();
+			get_prefix(&laddr, *argv, preferred_family);
+			if (laddr.family == AF_UNSPEC)
+				invarg("\"local\" address family is AF_UNSPEC", *argv);
+			memcpy(&p->laddr, &laddr.data, sizeof(p->laddr));
+		} else if (strcmp(*argv, "dev") == 0) {
+			NEXT_ARG();
 			strncpy(medium, *argv, IFNAMSIZ - 1);
-		} else if (!strcmp(*argv, "hoplimit")) {
-			__u8 uval;
-			argv++; 
-			if (--argc <= 0) 
-				usage();
-			if (get_u8(&uval, *argv) < -1)
-				usage();
-			p->hop_limit = uval;
-		} else if (!strcmp(*argv, "flowlabel")) {
-			__u32 uval;
-			argv++; 
-			if (--argc <= 0) 
-				usage();
-			if (get_u20(&uval, *argv) < -1)
-				usage();
-			p->flow_lbl = uval;
-		} else if (!strcmp(*argv, "encaplimit")) {
-			argv++; 
-			if (--argc <= 0) 
-				usage();
-			if (!strcmp(*argv, "none")) {
-				p->flags |= IPV6_TNL_F_IGN_ENCAP_LIMIT;
+		} else if (strcmp(*argv, "encaplimit") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "none") == 0) {
+				p->flags |= IP6_TNL_F_IGN_ENCAP_LIMIT;
 			} else {
 				__u8 uval;
-				if (get_u8(&uval, *argv) < -1)
-					usage();
+				if (get_u8(&uval, *argv, 0) < -1)
+					invarg("invalid ELIM", *argv);
 				p->encap_limit = uval;
 			}
+		} else if (strcmp(*argv, "hoplimit") == 0) {
+			__u8 uval;
+			NEXT_ARG();
+			if (get_u8(&uval, *argv, 0))
+				invarg("invalid HLIM", *argv);
+			p->hop_limit = uval;
+		} else if (strcmp(*argv, "tc") == 0) {
+			__u8 uval;
+			NEXT_ARG();
+			if (strcmp(*argv, "inherit") == 0)
+				p->flags |= IP6_TNL_F_USE_ORIG_TCLASS;
+			else {
+				if (get_u8(&uval, *argv, 16))
+					invarg("invalid TC", *argv);
+				p->flowinfo |= htonl((__u32)uval << 20) & IP6_FLOWINFO_TCLASS;
+				p->flags &= ~IP6_TNL_F_USE_ORIG_TCLASS;
+			}
+		} else if (strcmp(*argv, "fl") == 0) {
+			__u32 uval;
+			NEXT_ARG();
+			if (strcmp(*argv, "inherit") == 0)
+				p->flags |= IP6_TNL_F_USE_ORIG_FLOWLABEL;
+			else {
+				if (get_u32(&uval, *argv, 16))
+					invarg("invalid FL", *argv);
+				if (uval > 0xFFFFF)
+					invarg("invalid FL", *argv);
+				p->flowinfo |= htonl(uval) & IP6_FLOWINFO_FLOWLABEL;
+				p->flags &= ~IP6_TNL_F_USE_ORIG_FLOWLABEL;
+			}
+		} else if (strcmp(*argv, "dscp") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "inherit") != 0)
+				invarg("not inherit", *argv);
+			p->flags |= IP6_TNL_F_RCV_DSCP_COPY;
 		} else {
-			if (p->name[0])
+			if (strcmp(*argv, "name") == 0) {
+				NEXT_ARG();
+			}
+			if (matches(*argv, "help") == 0)
 				usage();
+			if (p->name[0])
+				duparg2("name", *argv);
 			strncpy(p->name, *argv, IFNAMSIZ - 1);
 		}
 		argc--; argv++;
 	}
 	if (medium[0]) {
-		p->link = do_ioctl_get_ifindex(medium);
+		p->link = tnl_ioctl_get_ifindex(medium);
 		if (p->link == 0)
 			return -1;
 	}
 	return 0;
 }
 
+static void ip6_tnl_parm_init(struct ip6_tnl_parm *p, int apply_default)
+{
+	memset(p, 0, sizeof(*p));
+	p->proto = IPPROTO_IPV6;
+	if (apply_default) {
+		p->hop_limit = DEFAULT_TNL_HOP_LIMIT;
+		p->encap_limit = IPV6_DEFAULT_TNL_ENCAP_LIMIT;
+	}
+}
+
+/*
+ * @p1: user specified parameter
+ * @p2: database entry
+ */
+static int ip6_tnl_parm_match(const struct ip6_tnl_parm *p1,
+			      const struct ip6_tnl_parm *p2)
+{
+	return ((!p1->link || p1->link == p2->link) &&
+		(!p1->name[0] || strcmp(p1->name, p2->name) == 0) &&
+		(memcmp(&p1->laddr, &in6addr_any, sizeof(p1->laddr)) == 0 ||
+		 memcmp(&p1->laddr, &p2->laddr, sizeof(p1->laddr)) == 0) &&
+		(memcmp(&p1->raddr, &in6addr_any, sizeof(p1->raddr)) == 0 ||
+		 memcmp(&p1->raddr, &p2->raddr, sizeof(p1->raddr)) == 0) &&
+		(!p1->proto || !p2->proto || p1->proto == p2->proto) &&
+		(!p1->encap_limit || p1->encap_limit == p2->encap_limit) &&
+		(!p1->hop_limit || p1->hop_limit == p2->hop_limit) &&
+		(!(p1->flowinfo & IP6_FLOWINFO_TCLASS) ||
+		 !((p1->flowinfo ^ p2->flowinfo) & IP6_FLOWINFO_TCLASS)) &&
+		(!(p1->flowinfo & IP6_FLOWINFO_FLOWLABEL) ||
+		 !((p1->flowinfo ^ p2->flowinfo) & IP6_FLOWINFO_FLOWLABEL)) &&
+		(!p1->flags || (p1->flags & p2->flags)));
+}
+
+static int do_tunnels_list(struct ip6_tnl_parm *p)
+{
+	char buf[512];
+	int err = -1;
+	FILE *fp = fopen("/proc/net/dev", "r");
+	if (fp == NULL) {
+		perror("fopen");
+		goto end;
+	}
+
+	/* skip two lines at the begenning of the file */
+	fgets(buf, sizeof(buf), fp);
+	fgets(buf, sizeof(buf), fp);
+
+	while (fgets(buf, sizeof(buf), fp) != NULL) {
+		char name[IFNAMSIZ];
+		int type;
+		unsigned long rx_bytes, rx_packets, rx_errs, rx_drops,
+			rx_fifo, rx_frame,
+			tx_bytes, tx_packets, tx_errs, tx_drops,
+			tx_fifo, tx_colls, tx_carrier, rx_multi;
+		struct ip6_tnl_parm p1;
+		char *ptr;
+
+		buf[sizeof(buf) - 1] = '\0';
+		if ((ptr = strchr(buf, ':')) == NULL ||
+		    (*ptr++ = 0, sscanf(buf, "%s", name) != 1)) {
+			fprintf(stderr, "Wrong format of /proc/net/dev. Sorry.\n");
+			goto end;
+		}
+		if (sscanf(ptr, "%ld%ld%ld%ld%ld%ld%ld%*d%ld%ld%ld%ld%ld%ld%ld",
+			   &rx_bytes, &rx_packets, &rx_errs, &rx_drops,
+			   &rx_fifo, &rx_frame, &rx_multi,
+			   &tx_bytes, &tx_packets, &tx_errs, &tx_drops,
+			   &tx_fifo, &tx_colls, &tx_carrier) != 14)
+			continue;
+		if (p->name[0] && strcmp(p->name, name))
+			continue;
+		type = tnl_ioctl_get_iftype(name);
+		if (type == -1) {
+			fprintf(stderr, "Failed to get type of [%s]\n", name);
+			continue;
+		}
+		if (type != ARPHRD_TUNNEL6)
+			continue;
+		memset(&p1, 0, sizeof(p1));
+		ip6_tnl_parm_init(&p1, 0);
+		strcpy(p1.name, name);
+		p1.link = tnl_ioctl_get_ifindex(p1.name);
+		if (p1.link == 0)
+			continue;
+		if (tnl_get_ioctl(p1.name, &p1))
+			continue;
+		if (!ip6_tnl_parm_match(p, &p1))
+			continue;
+		print_tunnel(&p1);
+		if (show_stats) {
+			printf("%s", _SL_);
+			printf("RX: Packets    Bytes        Errors CsumErrs OutOfSeq Mcasts%s", _SL_);
+			printf("    %-10ld %-12ld %-6ld %-8ld %-8ld %-8ld%s",
+			       rx_packets, rx_bytes, rx_errs, rx_frame, rx_fifo, rx_multi, _SL_);
+			printf("TX: Packets    Bytes        Errors DeadLoop NoRoute  NoBufs%s", _SL_);
+			printf("    %-10ld %-12ld %-6ld %-8ld %-8ld %-6ld",
+			       tx_packets, tx_bytes, tx_errs, tx_colls, tx_carrier, tx_drops);
+		}
+		printf("\n");
+	}
+	err = 0;
+
+ end:
+	if (fp)
+		fclose(fp);
+	return err;
+}
+
 static int do_show(int argc, char **argv)
 {
-        struct ipv6_tnl_parm p;
+        struct ip6_tnl_parm p;
+
+	ip6_tnl_parm_init(&p, 0);
 
         if (parse_args(argc, argv, &p) < 0)
                 return -1;
 
-	if (do_get_ioctl(p.name[0] ? p.name : "ip6tnl0", &p))
-                return -1;
+	if (!p.name[0] || show_stats)
+		do_tunnels_list(&p);
+	else {
+		if (tnl_get_ioctl(p.name, &p))
+			return -1;
+		print_tunnel(&p);
+		printf("\n");
+	}
 
-        print_tunnel(&p);
         return 0;
 }
 
-
-
-
 static int do_add(int cmd, int argc, char **argv)
 {
-	struct ipv6_tnl_parm p;
+	struct ip6_tnl_parm p;
+
+	ip6_tnl_parm_init(&p, 1);
 
 	if (parse_args(argc, argv, &p) < 0)
 		return -1;
-	
-	return do_add_ioctl(cmd, 
-			    cmd == SIOCCHGTUNNEL && p.name[0] ?
-			    p.name : "ip6tnl0", &p);
+
+	return tnl_add_ioctl(cmd,
+			     cmd == SIOCCHGTUNNEL && p.name[0] ?
+			     p.name : "ip6tnl0", p.name, &p);
 }
 
-int do_del(int argc, char **argv)
+static int do_del(int argc, char **argv)
 {
-	struct ipv6_tnl_parm p;
+	struct ip6_tnl_parm p;
+
+	ip6_tnl_parm_init(&p, 1);
 
 	if (parse_args(argc, argv, &p) < 0)
 		return -1;
 
-	return do_del_ioctl(p.name[0] ? p.name : "ip6tnl0", &p);
+	return tnl_del_ioctl(p.name[0] ? p.name : "ip6tnl0", p.name, &p);
 }
 
-
-int main(int argc, char **argv) 
+int do_ip6tunnel(int argc, char **argv) 
 { 
-	argc--;
-	argv++;
+	switch (preferred_family) {
+	case AF_UNSPEC:
+		preferred_family = AF_INET6;
+		break;
+	case AF_INET6:
+		break;
+	default:
+		fprintf(stderr, "Unsupported family:%d\n", preferred_family);
+		exit(-1);
+	}
+
 	if (argc > 0) {
-		if (strcmp(*argv, "add") == 0)
+		if (matches(*argv, "add") == 0)
 			return do_add(SIOCADDTUNNEL, argc - 1, argv + 1);
-		else if (strcmp(*argv, "change") == 0)
+		if (matches(*argv, "change") == 0)
 			return do_add(SIOCCHGTUNNEL, argc - 1, argv + 1);
-		else if (strcmp(*argv, "del") == 0)
+		if (matches(*argv, "del") == 0)
 			return do_del(argc - 1, argv + 1);
-		else if (strcmp(*argv, "show") == 0)
+		if (matches(*argv, "show") == 0 ||
+		    matches(*argv, "lst") == 0 ||
+		    matches(*argv, "list") == 0)
 			return do_show(argc - 1, argv + 1);
-		else
+		if (matches(*argv, "help") == 0)
 			usage();
-
 	} else
 		return do_show(0, NULL);
 
-	return 0;
+	fprintf(stderr, "Command \"%s\" is unknown, try \"ip -f inet6 tunnel help\".\n", *argv);
+	exit(-1);
 }
diff --git a/ip/ip_common.h b/ip/ip_common.h
index 8f790e1..aeb9994 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -28,6 +28,7 @@ extern int do_iprule(int argc, char **ar
 extern int do_ipneigh(int argc, char **argv);
 extern int do_ipntable(int argc, char **argv);
 extern int do_iptunnel(int argc, char **argv);
+extern int do_ip6tunnel(int argc, char **argv);
 extern int do_iplink(int argc, char **argv);
 extern int do_ipmonitor(int argc, char **argv);
 extern int do_multiaddr(int argc, char **argv);
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 26ae30c..57a6ab0 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -31,6 +31,7 @@ #include <linux/if_tunnel.h>
 
 #include "rt_names.h"
 #include "utils.h"
+#include "ip_common.h"
 #include "tunnel.h"
 
 static void usage(void) __attribute__((noreturn));
@@ -455,6 +456,13 @@ int do_iptunnel(int argc, char **argv)
 		break;
 	case AF_INET:
 		break;
+	/*
+	 * This is silly enough but we have no easy way to make it
+	 * protocol-independent because of unarranged structure between
+	 * IPv4 and IPv6.
+	 */
+	case AF_INET6:
+		return do_ip6tunnel(argc, argv);
 	default:
 		fprintf(stderr, "Unsupported family:%d\n", preferred_family);
 		exit(-1);
-- 
1.4.2

