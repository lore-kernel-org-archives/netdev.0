From: Saurabh Mohan <saurabh@cplanenetworks.com>
Subject: [PATCH iproute2] Support outside netns for tunnels.
Date: Mon, 4 Jan 2016 10:46:51 -0800
Message-ID: <1451933211-17330-1-git-send-email-saurabh@cplanenetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Saurabh Mohan <saurabh@cplanenetworks.com>
To: <netdev@vger.kernel.org>, <stephen@networkplumber.org>,
	<davem@davemloft.net>, <pshelar@nicira.com>, <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0120.outbound.protection.outlook.com ([65.55.169.120]:6303
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752090AbcADTB6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jan 2016 14:01:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch enchances a tunnel interface, like gre, to have the tunnel
encap/decap be in the context of a network namespace that is different from 
the namespace of the tunnel interface.

>From userspace this feature may be configured using the new 'onetns' keyword:
ip netns exec custa ip link add dev tun1 type gre local 10.0.0.1 \
 remote 10.0.0.2 onetns outside 

In the above example the tunnel would be in the 'custa' namespace and the 
tunnel endpoints would be in the 'outside' namespace.

Also, proposing the use of netns name 'global' to specify the global namespace.

If this patch set is accepted then I will add support for other tunnels as 
well.

Signed-off-by: Saurabh Mohan <saurabh@cplanenetworks.com>
---
 ip/iptunnel.c | 27 +++++++++++++++++++++++++++
 ip/link_gre.c | 43 +++++++++++++++++++++++++++++++++++++++++++
 ip/link_vti.c | 41 +++++++++++++++++++++++++++++++++++++++++
 3 files changed, 111 insertions(+)

diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 65a4e6e..8165a38 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -27,6 +27,7 @@
 #include "utils.h"
 #include "ip_common.h"
 #include "tunnel.h"
+#include "namespace.h"
 
 static void usage(void) __attribute__((noreturn));
 
@@ -38,6 +39,7 @@ static void usage(void)
 	fprintf(stderr, "          [ prl-default ADDR ] [ prl-nodefault ADDR ] [ prl-delete ADDR ]\n");
 	fprintf(stderr, "          [ 6rd-prefix ADDR ] [ 6rd-relay_prefix ADDR ] [ 6rd-reset ]\n");
 	fprintf(stderr, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
+	fprintf(stderr, "          [ onetns NAME ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: NAME := STRING\n");
 	fprintf(stderr, "       ADDR := { IP_ADDRESS | any }\n");
@@ -172,6 +174,22 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 					invarg("bad TOS value", *argv);
 				p->iph.tos |= uval;
 			}
+		} else if (strcmp(*argv, "onetns") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "global") == 0)
+				p->o_net.o_netns_flag |=
+					TUNNEL_ONETNS_FLAG_GLOBAL;
+			else {
+				p->o_net.o_netns_fd = netns_get_fd(*argv);
+				if (p->o_net.o_netns_fd < 0)
+					invarg("bad netns name %s\n", *argv);
+				else {
+					p->o_net.o_netns_flag |=
+						TUNNEL_ONETNS_FLAG_NETNS;
+					strncpy(p->o_net.netns, *argv,
+						sizeof(p->o_net.netns));
+				}
+			}
 		} else {
 			if (strcmp(*argv, "name") == 0)
 				NEXT_ARG();
@@ -374,6 +392,11 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 			printf(" okey %u", ntohl(p->o_key));
 	}
 
+	if (p->o_net.o_netns_flag & TUNNEL_ONETNS_FLAG_GLOBAL)
+		printf(" onetns global ");
+	if (p->o_net.o_netns_flag & TUNNEL_ONETNS_FLAG_NETNS)
+		printf(" onetns %s ", p->o_net.netns);
+
 	if (p->i_flags & GRE_SEQ)
 		printf("%s  Drop packets out of sequence.", _SL_);
 	if (p->i_flags & GRE_CSUM)
@@ -401,6 +424,10 @@ static int do_tunnels_list(struct ip_tunnel_parm *p)
 		fprintf(stderr, "/proc/net/dev read error\n");
 		goto end;
 	}
+	if (p->o_net.o_netns_flag & TUNNEL_ONETNS_FLAG_GLOBAL)
+		printf(" onetns global ");
+	if (p->o_net.o_netns_flag & TUNNEL_ONETNS_FLAG_NETNS)
+		printf(" onetns %s ", p->o_net.netns);
 
 	while (fgets(buf, sizeof(buf), fp) != NULL) {
 		char name[IFNAMSIZ];
diff --git a/ip/link_gre.c b/ip/link_gre.c
index c85741f..4f51aa4 100644
--- a/ip/link_gre.c
+++ b/ip/link_gre.c
@@ -22,6 +22,7 @@
 #include "utils.h"
 #include "ip_common.h"
 #include "tunnel.h"
+#include "namespace.h"
 
 static void print_usage(FILE *f)
 {
@@ -32,6 +33,7 @@ static void print_usage(FILE *f)
 	fprintf(f, "          [ noencap ] [ encap { fou | gue | none } ]\n");
 	fprintf(f, "          [ encap-sport PORT ] [ encap-dport PORT ]\n");
 	fprintf(f, "          [ [no]encap-csum ] [ [no]encap-csum6 ] [ [no]encap-remcsum ]\n");
+	fprintf(f, "          [ onetns NAME ]\n");
 	fprintf(f, "\n");
 	fprintf(f, "Where: NAME := STRING\n");
 	fprintf(f, "       ADDR := { IP_ADDRESS | any }\n");
@@ -75,6 +77,9 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u16 encapsport = 0;
 	__u16 encapdport = 0;
 	__u8 metadata = 0;
+	__u32 o_netns = 0;
+	__u8 o_netns_flag = 0;
+	char netns_name[NAME_MAX];
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
 		memset(&req, 0, sizeof(req));
@@ -152,6 +157,14 @@ get_failed:
 
 		if (greinfo[IFLA_GRE_COLLECT_METADATA])
 			metadata = 1;
+		if (greinfo[IFLA_GRE_ONETNS_FLAGS])
+			o_netns_flag = rta_getattr_u8(
+						greinfo[IFLA_GRE_ONETNS_FLAGS]);
+		if (greinfo[IFLA_GRE_ONETNS_FD])
+			o_netns = rta_getattr_u32(greinfo[IFLA_GRE_ONETNS_FD]);
+		if (greinfo[IFLA_GRE_ONETNS_NAME])
+			netns_name[0] = '\0';
+
 	}
 
 	while (argc > 0) {
@@ -297,6 +310,21 @@ get_failed:
 			encapflags |= ~TUNNEL_ENCAP_FLAG_REMCSUM;
 		} else if (strcmp(*argv, "external") == 0) {
 			metadata = 1;
+		} else if (strcmp(*argv, "onetns") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "global") == 0)
+				o_netns_flag |= TUNNEL_ONETNS_FLAG_GLOBAL;
+			else {
+				o_netns = netns_get_fd(*argv);
+				if (o_netns < 0)
+					invarg("invalid onetns %s\n", *argv);
+				else {
+					o_netns_flag |=
+						TUNNEL_ONETNS_FLAG_NETNS;
+					strncpy(netns_name, *argv,
+						sizeof(netns_name));
+				}
+			}
 		} else
 			usage();
 		argc--; argv++;
@@ -333,6 +361,9 @@ get_failed:
 	addattr16(n, 1024, IFLA_GRE_ENCAP_DPORT, htons(encapdport));
 	if (metadata)
 		addattr_l(n, 1024, IFLA_GRE_COLLECT_METADATA, NULL, 0);
+	addattr8(n, 1024, IFLA_IPTUN_ONETNS_FLAGS, o_netns_flag);
+	addattr_l(n, 1024, IFLA_GRE_ONETNS_FD, &o_netns, 1);
+	addattrstrz(n, 1024, IFLA_GRE_ONETNS_NAME, netns_name);
 
 	return 0;
 }
@@ -345,6 +376,7 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	const char *remote = "any";
 	unsigned iflags = 0;
 	unsigned oflags = 0;
+	__u8 o_netns_flag = 0;
 
 	if (!tb)
 		return;
@@ -466,6 +498,17 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		else
 			fputs("noencap-remcsum ", f);
 	}
+	if (tb[IFLA_GRE_ONETNS_FLAGS]) {
+		o_netns_flag = rta_getattr_u8(tb[IFLA_GRE_ONETNS_FLAGS]);
+		if (o_netns_flag & TUNNEL_ONETNS_FLAG_GLOBAL)
+			fprintf(f, "onetns global ");
+	}
+	if ((o_netns_flag & TUNNEL_ONETNS_FLAG_NETNS) &&
+	    tb[IFLA_GRE_ONETNS_NAME]) {
+		const char *name = rta_getattr_str(tb[IFLA_GRE_ONETNS_NAME]);
+
+		fprintf(f, "onetns %s ", name);
+	}
 }
 
 static void gre_print_help(struct link_util *lu, int argc, char **argv,
diff --git a/ip/link_vti.c b/ip/link_vti.c
index f3fea33..7f6d4ae 100644
--- a/ip/link_vti.c
+++ b/ip/link_vti.c
@@ -30,6 +30,7 @@ static void print_usage(FILE *f)
 	fprintf(f, "          type { vti } [ remote ADDR ] [ local ADDR ]\n");
 	fprintf(f, "          [ [i|o]key KEY ]\n");
 	fprintf(f, "          [ dev PHYS_DEV ]\n");
+	fprintf(f, "          [ onetns NAME ]\n");
 	fprintf(f, "\n");
 	fprintf(f, "Where: NAME := STRING\n");
 	fprintf(f, "       ADDR := { IP_ADDRESS }\n");
@@ -61,6 +62,9 @@ static int vti_parse_opt(struct link_util *lu, int argc, char **argv,
 	unsigned daddr = 0;
 	unsigned link = 0;
 	int len;
+	__u32 o_netns = 0;
+	__u8  o_netns_flag = 0;
+	char netns_name[NAME_MAX];
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
 		memset(&req, 0, sizeof(req));
@@ -110,6 +114,13 @@ get_failed:
 
 		if (vtiinfo[IFLA_VTI_LINK])
 			link = *(__u8 *)RTA_DATA(vtiinfo[IFLA_VTI_LINK]);
+		if (vtiinfo[IFLA_VTI_ONETNS_FLAGS])
+			o_netns_flag = rta_getattr_u8(
+					    vtiinfo[IFLA_VTI_ONETNS_FLAGS]);
+		if (vtiinfo[IFLA_VTI_ONETNS_FD])
+			o_netns = rta_getattr_u32(vtiinfo[IFLA_VTI_ONETNS_FD]);
+		if (vtiinfo[IFLA_VTI_ONETNS_NAME])
+			netns_name[0] = '\0';
 	}
 
 	while (argc > 0) {
@@ -181,6 +192,21 @@ get_failed:
 					*argv);
 				exit(-1);
 			}
+		} else if (strcmp(*argv, "onetns") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "global") == 0)
+				o_netns_flag |= TUNNEL_ONETNS_FLAG_GLOBAL;
+			else {
+				o_netns = netns_get_fd(*argv);
+				if (o_netns < 0)
+					invarg("invalid onetns %s\n", *argv);
+				else {
+					o_netns_flag |=
+						TUNNEL_ONETNS_FLAG_NETNS;
+					strncpy(netns_name, *argv,
+						sizeof(netns_name));
+				}
+			}
 		} else
 			usage();
 		argc--; argv++;
@@ -192,6 +218,9 @@ get_failed:
 	addattr_l(n, 1024, IFLA_VTI_REMOTE, &daddr, 4);
 	if (link)
 		addattr32(n, 1024, IFLA_VTI_LINK, link);
+	addattr8(n, 1024, IFLA_IPTUN_ONETNS_FLAGS, o_netns_flag);
+	addattr_l(n, 1024, IFLA_VTI_ONETNS_FD, &o_netns, 1);
+	addattrstrz(n, 1024, IFLA_VTI_ONETNS_NAME, netns_name);
 
 	return 0;
 }
@@ -202,6 +231,7 @@ static void vti_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	char s2[64];
 	const char *local = "any";
 	const char *remote = "any";
+	__u8 o_netns_flag = 0;
 
 	if (!tb)
 		return;
@@ -243,6 +273,17 @@ static void vti_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		inet_ntop(AF_INET, RTA_DATA(tb[IFLA_VTI_OKEY]), s2, sizeof(s2));
 		fprintf(f, "okey %s ", s2);
 	}
+	if (tb[IFLA_VTI_ONETNS_FLAGS]) {
+		o_netns_flag = rta_getattr_u8(tb[IFLA_VTI_ONETNS_FLAGS]);
+		if (o_netns_flag & TUNNEL_ONETNS_FLAG_GLOBAL)
+			fprintf(f, "onetns global ");
+	}
+	if ((o_netns_flag & TUNNEL_ONETNS_FLAG_NETNS) &&
+	    tb[IFLA_VTI_ONETNS_NAME]) {
+		const char *name = rta_getattr_str(tb[IFLA_VTI_ONETNS_NAME]);
+
+		fprintf(f, "onetns %s ", name);
+	}
 }
 
 static void vti_print_help(struct link_util *lu, int argc, char **argv,
-- 
1.9.1
