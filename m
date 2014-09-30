From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2 v2] ip link: Shortify printing the usage of link type
Date: Tue, 30 Sep 2014 08:17:31 +0300
Message-ID: <1412054251-29716-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f182.google.com ([209.85.217.182]:38781 "EHLO
	mail-lb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109AbaI3F0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 01:26:04 -0400
Received: by mail-lb0-f182.google.com with SMTP id z11so7556552lbi.27
        for <netdev@vger.kernel.org>; Mon, 29 Sep 2014 22:26:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow to print particular link type usage by:

    ip link help [TYPE]

Currently to print usage for some link type it is needed
to use the following way:

    ip link { add | del | set } type TYPE help

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/ip_common.h      |  2 ++
 ip/iplink.c         | 24 ++++++++++++++++++++++--
 ip/iplink_bond.c    | 16 ++++++++++++++--
 ip/iplink_can.c     | 16 ++++++++++++++--
 ip/iplink_hsr.c     | 16 ++++++++++++++--
 ip/iplink_ipoib.c   | 15 +++++++++++++--
 ip/iplink_macvlan.c | 16 ++++++++++++++--
 ip/iplink_macvtap.c | 14 +++++++++++++-
 ip/iplink_vlan.c    | 16 ++++++++++++++--
 ip/iplink_vxlan.c   | 34 +++++++++++++++++++++++-----------
 ip/link_gre.c       | 33 +++++++++++++++++++++++----------
 ip/link_gre6.c      | 45 +++++++++++++++++++++++++++++----------------
 ip/link_ip6tnl.c    | 42 +++++++++++++++++++++++++++---------------
 ip/link_iptnl.c     | 39 ++++++++++++++++++++++++++-------------
 ip/link_veth.c      | 14 +++++++++++++-
 ip/link_vti.c       | 28 ++++++++++++++++++++--------
 16 files changed, 281 insertions(+), 89 deletions(-)

diff --git a/ip/ip_common.h b/ip/ip_common.h
index e56d1ac..8351463 100644
--- a/ip/ip_common.h
+++ b/ip/ip_common.h
@@ -76,6 +76,8 @@ struct link_util
 					     struct rtattr *[]);
 	void			(*print_xstats)(struct link_util *, FILE *,
 					     struct rtattr *);
+	void			(*print_help)(struct link_util *, int, char **,
+					     FILE *);
 	bool			slave;
 };
 
diff --git a/ip/iplink.c b/ip/iplink.c
index cb9c870..2736e63 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -85,6 +85,7 @@ void iplink_usage(void)
 	fprintf(stderr, "       ip link show [ DEVICE | group GROUP ] [up]\n");
 
 	if (iplink_have_newlink()) {
+		fprintf(stderr, "       ip link help [ TYPE ]\n");
 		fprintf(stderr, "\n");
 		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |\n");
 		fprintf(stderr, "          bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan |\n");
@@ -1134,6 +1135,23 @@ static int do_set(int argc, char **argv)
 }
 #endif /* IPLINK_IOCTL_COMPAT */
 
+static void do_help(int argc, char **argv)
+{
+	struct link_util *lu = NULL;
+
+	if (argc <= 0) {
+		usage();
+		return ;
+	}
+
+	lu = get_link_kind(*argv);
+
+	if (lu && lu->print_help)
+		lu->print_help(lu, argc-1, argv+1, stdout);
+	else
+		usage();
+}
+
 int do_iplink(int argc, char **argv)
 {
 	if (argc > 0) {
@@ -1163,8 +1181,10 @@ int do_iplink(int argc, char **argv)
 		    matches(*argv, "lst") == 0 ||
 		    matches(*argv, "list") == 0)
 			return ipaddr_list_link(argc-1, argv+1);
-		if (matches(*argv, "help") == 0)
-			usage();
+		if (matches(*argv, "help") == 0) {
+			do_help(argc-1, argv+1);
+			return 0;
+		}
 	} else
 		return ipaddr_list_link(0, NULL);
 
diff --git a/ip/iplink_bond.c b/ip/iplink_bond.c
index 0a1ed03..3009ec9 100644
--- a/ip/iplink_bond.c
+++ b/ip/iplink_bond.c
@@ -112,9 +112,9 @@ static int get_index(const char **tbl, char *name)
 	return -1;
 }
 
-static void explain(void)
+static void print_explain(FILE *f)
 {
-	fprintf(stderr,
+	fprintf(f,
 		"Usage: ... bond [ mode BONDMODE ] [ active_slave SLAVE_DEV ]\n"
 		"                [ clear_active_slave ] [ miimon MIIMON ]\n"
 		"                [ updelay UPDELAY ] [ downdelay DOWNDELAY ]\n"
@@ -147,6 +147,11 @@ static void explain(void)
 	);
 }
 
+static void explain(void)
+{
+	print_explain(stderr);
+}
+
 static int bond_parse_opt(struct link_util *lu, int argc, char **argv,
 			  struct nlmsghdr *n)
 {
@@ -530,9 +535,16 @@ static void bond_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	}
 }
 
+static void bond_print_help(struct link_util *lu, int argc, char **argv,
+	FILE *f)
+{
+	print_explain(f);
+}
+
 struct link_util bond_link_util = {
 	.id		= "bond",
 	.maxattr	= IFLA_BOND_MAX,
 	.parse_opt	= bond_parse_opt,
 	.print_opt	= bond_print_opt,
+	.print_help	= bond_print_help,
 };
diff --git a/ip/iplink_can.c b/ip/iplink_can.c
index 3bef82a..5b92426 100644
--- a/ip/iplink_can.c
+++ b/ip/iplink_can.c
@@ -19,9 +19,9 @@
 #include "utils.h"
 #include "ip_common.h"
 
-static void usage(void)
+static void print_usage(FILE *f)
 {
-	fprintf(stderr,
+	fprintf(f,
 		"Usage: ip link set DEVICE type can\n"
 		"\t[ bitrate BITRATE [ sample-point SAMPLE-POINT] ] | \n"
 		"\t[ tq TQ prop-seg PROP_SEG phase-seg1 PHASE-SEG1\n "
@@ -52,6 +52,11 @@ static void usage(void)
 		);
 }
 
+static void usage(void)
+{
+	print_usage(stderr);
+}
+
 static int get_float(float *val, const char *arg)
 {
 	float res;
@@ -344,10 +349,17 @@ static void can_print_xstats(struct link_util *lu,
 	}
 }
 
+static void can_print_help(struct link_util *lu, int argc, char **argv,
+	FILE *f)
+{
+	print_usage(f);
+}
+
 struct link_util can_link_util = {
 	.id		= "can",
 	.maxattr	= IFLA_CAN_MAX,
 	.parse_opt	= can_parse_opt,
 	.print_opt	= can_print_opt,
 	.print_xstats	= can_print_xstats,
+	.print_help	= can_print_help,
 };
diff --git a/ip/iplink_hsr.c b/ip/iplink_hsr.c
index 136da35..65fbec8 100644
--- a/ip/iplink_hsr.c
+++ b/ip/iplink_hsr.c
@@ -21,9 +21,9 @@
 #include "utils.h"
 #include "ip_common.h"
 
-static void usage(void)
+static void print_usage(FILE *f)
 {
-	fprintf(stderr,
+	fprintf(f,
 "Usage:\tip link add name NAME type hsr slave1 SLAVE1-IF slave2 SLAVE2-IF\n"
 "\t[ supervision ADDR-BYTE ]\n"
 "\n"
@@ -36,6 +36,11 @@ static void usage(void)
 "	frames (default = 0)\n");
 }
 
+static void usage(void)
+{
+	print_usage(stderr);
+}
+
 static int hsr_parse_opt(struct link_util *lu, int argc, char **argv,
 			 struct nlmsghdr *n)
 {
@@ -121,9 +126,16 @@ static void hsr_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 				    b1, sizeof(b1)));
 }
 
+static void hsr_print_help(struct link_util *lu, int argc, char **argv,
+	FILE *f)
+{
+	print_usage(f);
+}
+
 struct link_util hsr_link_util = {
 	.id		= "hsr",
 	.maxattr	= IFLA_VLAN_MAX,
 	.parse_opt	= hsr_parse_opt,
 	.print_opt	= hsr_print_opt,
+	.print_help	= hsr_print_help,
 };
diff --git a/ip/iplink_ipoib.c b/ip/iplink_ipoib.c
index 5c1c68c..6087cbe 100644
--- a/ip/iplink_ipoib.c
+++ b/ip/iplink_ipoib.c
@@ -19,9 +19,9 @@
 #include "utils.h"
 #include "ip_common.h"
 
-static void explain(void)
+static void print_explain(FILE *f)
 {
-	fprintf(stderr,
+	fprintf(f,
 		"Usage: ... ipoib [pkey PKEY] [mode {datagram | connected}]"
 		"[umcast {0|1}]\n"
 		"\n"
@@ -29,6 +29,10 @@ static void explain(void)
 	);
 }
 
+static void explain(void)
+{
+	print_explain(stderr);
+}
 
 static int mode_arg(void)
 {
@@ -106,9 +110,16 @@ static void ipoib_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	fprintf(f, "umcast  %.4x ", rta_getattr_u16(tb[IFLA_IPOIB_UMCAST]));
 }
 
+static void ipoib_print_help(struct link_util *lu, int argc, char **argv,
+	FILE *f)
+{
+	print_explain(f);
+}
+
 struct link_util ipoib_link_util = {
 	.id		= "ipoib",
 	.maxattr	= IFLA_IPOIB_MAX,
 	.parse_opt	= ipoib_parse_opt,
 	.print_opt	= ipoib_print_opt,
+	.print_help	= ipoib_print_help,
 };
diff --git a/ip/iplink_macvlan.c b/ip/iplink_macvlan.c
index ec51106..826b659 100644
--- a/ip/iplink_macvlan.c
+++ b/ip/iplink_macvlan.c
@@ -20,13 +20,18 @@
 #include "utils.h"
 #include "ip_common.h"
 
-static void explain(void)
+static void print_explain(FILE *f)
 {
-	fprintf(stderr,
+	fprintf(f,
 		"Usage: ... macvlan mode { private | vepa | bridge | passthru }\n"
 	);
 }
 
+static void explain(void)
+{
+	print_explain(stderr);
+}
+
 static int mode_arg(void)
 {
         fprintf(stderr, "Error: argument of \"mode\" must be \"private\", "
@@ -88,9 +93,16 @@ static void macvlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[]
 		:				 "unknown");
 }
 
+static void macvlan_print_help(struct link_util *lu, int argc, char **argv,
+	FILE *f)
+{
+	print_explain(f);
+}
+
 struct link_util macvlan_link_util = {
 	.id		= "macvlan",
 	.maxattr	= IFLA_MACVLAN_MAX,
 	.parse_opt	= macvlan_parse_opt,
 	.print_opt	= macvlan_print_opt,
+	.print_help	= macvlan_print_help,
 };
diff --git a/ip/iplink_macvtap.c b/ip/iplink_macvtap.c
index bea9f0c..9c2cd74 100644
--- a/ip/iplink_macvtap.c
+++ b/ip/iplink_macvtap.c
@@ -17,13 +17,18 @@
 #include "utils.h"
 #include "ip_common.h"
 
-static void explain(void)
+static void print_explain(FILE *f)
 {
 	fprintf(stderr,
 		"Usage: ... macvtap mode { private | vepa | bridge | passthru }\n"
 	);
 }
 
+static void explain(void)
+{
+	print_explain(stderr);
+}
+
 static int mode_arg(const char *arg)
 {
         fprintf(stderr, "Error: argument of \"mode\" must be \"private\", "
@@ -85,9 +90,16 @@ static void macvtap_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[]
 		:				 "unknown");
 }
 
+static void macvtap_print_help(struct link_util *lu, int argc, char **argv,
+	FILE *f)
+{
+	print_explain(f);
+}
+
 struct link_util macvtap_link_util = {
 	.id		= "macvtap",
 	.maxattr	= IFLA_MACVLAN_MAX,
 	.parse_opt	= macvtap_parse_opt,
 	.print_opt	= macvtap_print_opt,
+	.print_help	= macvtap_print_help,
 };
diff --git a/ip/iplink_vlan.c b/ip/iplink_vlan.c
index 94b52ae..5bd766f 100644
--- a/ip/iplink_vlan.c
+++ b/ip/iplink_vlan.c
@@ -18,9 +18,9 @@
 #include "utils.h"
 #include "ip_common.h"
 
-static void explain(void)
+static void print_explain(FILE *f)
 {
-	fprintf(stderr,
+	fprintf(f,
 		"Usage: ... vlan [ protocol VLANPROTO ] id VLANID"
 		"                [ FLAG-LIST ]\n"
 		"                [ ingress-qos-map QOS-MAP ] [ egress-qos-map QOS-MAP ]\n"
@@ -35,6 +35,11 @@ static void explain(void)
 	);
 }
 
+static void explain(void)
+{
+	print_explain(stderr);
+}
+
 static int on_off(const char *msg, const char *arg)
 {
 	fprintf(stderr, "Error: argument of \"%s\" must be \"on\" or \"off\", not \"%s\"\n", msg, arg);
@@ -226,9 +231,16 @@ static void vlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		vlan_print_map(f, "egress-qos-map", tb[IFLA_VLAN_EGRESS_QOS]);
 }
 
+static void vlan_print_help(struct link_util *lu, int argc, char **argv,
+	FILE *f)
+{
+	print_explain(f);
+}
+
 struct link_util vlan_link_util = {
 	.id		= "vlan",
 	.maxattr	= IFLA_VLAN_MAX,
 	.parse_opt	= vlan_parse_opt,
 	.print_opt	= vlan_print_opt,
+	.print_help	= vlan_print_help,
 };
diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index d92cfe8..f410423 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -21,19 +21,24 @@
 #include "utils.h"
 #include "ip_common.h"
 
+static void print_explain(FILE *f)
+{
+	fprintf(f, "Usage: ... vxlan id VNI [ { group | remote } ADDR ] [ local ADDR ]\n");
+	fprintf(f, "                 [ ttl TTL ] [ tos TOS ] [ dev PHYS_DEV ]\n");
+	fprintf(f, "                 [ dstport PORT ] [ srcport MIN MAX ]\n");
+	fprintf(f, "                 [ [no]learning ] [ [no]proxy ] [ [no]rsc ]\n");
+	fprintf(f, "                 [ [no]l2miss ] [ [no]l3miss ]\n");
+	fprintf(f, "                 [ ageing SECONDS ] [ maxaddress NUMBER ]\n");
+	fprintf(f, "\n");
+	fprintf(f, "Where: VNI := 0-16777215\n");
+	fprintf(f, "       ADDR := { IP_ADDRESS | any }\n");
+	fprintf(f, "       TOS  := { NUMBER | inherit }\n");
+	fprintf(f, "       TTL  := { 1..255 | inherit }\n");
+}
+
 static void explain(void)
 {
-	fprintf(stderr, "Usage: ... vxlan id VNI [ { group | remote } ADDR ] [ local ADDR ]\n");
-	fprintf(stderr, "                 [ ttl TTL ] [ tos TOS ] [ dev PHYS_DEV ]\n");
-	fprintf(stderr, "                 [ dstport PORT ] [ srcport MIN MAX ]\n");
-	fprintf(stderr, "                 [ [no]learning ] [ [no]proxy ] [ [no]rsc ]\n");
-	fprintf(stderr, "                 [ [no]l2miss ] [ [no]l3miss ]\n");
-	fprintf(stderr, "                 [ ageing SECONDS ] [ maxaddress NUMBER ]\n");
-	fprintf(stderr, "\n");
-	fprintf(stderr, "Where: VNI := 0-16777215\n");
-	fprintf(stderr, "       ADDR := { IP_ADDRESS | any }\n");
-	fprintf(stderr, "       TOS  := { NUMBER | inherit }\n");
-	fprintf(stderr, "       TTL  := { 1..255 | inherit }\n");
+	print_explain(stderr);
 }
 
 static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
@@ -365,9 +370,16 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		    fprintf(f, "maxaddr %u ", maxaddr);
 }
 
+static void vxlan_print_help(struct link_util *lu, int argc, char **argv,
+	FILE *f)
+{
+	print_explain(f);
+}
+
 struct link_util vxlan_link_util = {
 	.id		= "vxlan",
 	.maxattr	= IFLA_VXLAN_MAX,
 	.parse_opt	= vxlan_parse_opt,
 	.print_opt	= vxlan_print_opt,
+	.print_help	= vxlan_print_help,
 };
diff --git a/ip/link_gre.c b/ip/link_gre.c
index fda84d8..83653d0 100644
--- a/ip/link_gre.c
+++ b/ip/link_gre.c
@@ -23,19 +23,24 @@
 #include "ip_common.h"
 #include "tunnel.h"
 
+static void print_usage(FILE *f)
+{
+	fprintf(f, "Usage: ip link { add | set | change | replace | del } NAME\n");
+	fprintf(f, "          type { gre | gretap } [ remote ADDR ] [ local ADDR ]\n");
+	fprintf(f, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
+	fprintf(f, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
+	fprintf(f, "\n");
+	fprintf(f, "Where: NAME := STRING\n");
+	fprintf(f, "       ADDR := { IP_ADDRESS | any }\n");
+	fprintf(f, "       TOS  := { NUMBER | inherit }\n");
+	fprintf(f, "       TTL  := { 1..255 | inherit }\n");
+	fprintf(f, "       KEY  := { DOTTED_QUAD | NUMBER }\n");
+}
+
 static void usage(void) __attribute__((noreturn));
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip link { add | set | change | replace | del } NAME\n");
-	fprintf(stderr, "          type { gre | gretap } [ remote ADDR ] [ local ADDR ]\n");
-	fprintf(stderr, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
-	fprintf(stderr, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
-	fprintf(stderr, "\n");
-	fprintf(stderr, "Where: NAME := STRING\n");
-	fprintf(stderr, "       ADDR := { IP_ADDRESS | any }\n");
-	fprintf(stderr, "       TOS  := { NUMBER | inherit }\n");
-	fprintf(stderr, "       TTL  := { 1..255 | inherit }\n");
-	fprintf(stderr, "       KEY  := { DOTTED_QUAD | NUMBER }\n");
+	print_usage(stderr);
 	exit(-1);
 }
 
@@ -354,11 +359,18 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		fputs("ocsum ", f);
 }
 
+static void gre_print_help(struct link_util *lu, int argc, char **argv,
+	FILE *f)
+{
+	print_usage(f);
+}
+
 struct link_util gre_link_util = {
 	.id = "gre",
 	.maxattr = IFLA_GRE_MAX,
 	.parse_opt = gre_parse_opt,
 	.print_opt = gre_print_opt,
+	.print_help = gre_print_help,
 };
 
 struct link_util gretap_link_util = {
@@ -366,4 +378,5 @@ struct link_util gretap_link_util = {
 	.maxattr = IFLA_GRE_MAX,
 	.parse_opt = gre_parse_opt,
 	.print_opt = gre_print_opt,
+	.print_help = gre_print_help,
 };
diff --git a/ip/link_gre6.c b/ip/link_gre6.c
index c7183e2..f18919c 100644
--- a/ip/link_gre6.c
+++ b/ip/link_gre6.c
@@ -30,25 +30,30 @@
 
 #define DEFAULT_TNL_HOP_LIMIT	(64)
 
-static void usage(void) __attribute__((noreturn));
-static void usage(void)
+static void print_usage(FILE *f)
 {
-	fprintf(stderr, "Usage: ip link { add | set | change | replace | del } NAME\n");
-	fprintf(stderr, "          type { ip6gre | ip6gretap } [ remote ADDR ] [ local ADDR ]\n");
-	fprintf(stderr, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
-	fprintf(stderr, "          [ hoplimit TTL ] [ encaplimit ELIM ]\n");
-	fprintf(stderr, "          [ tclass TCLASS ] [ flowlabel FLOWLABEL ]\n");
-	fprintf(stderr, "          [ dscp inherit ] [ dev PHYS_DEV ]\n");
-	fprintf(stderr, "\n");
-	fprintf(stderr, "Where: NAME      := STRING\n");
-	fprintf(stderr, "       ADDR      := IPV6_ADDRESS\n");
-	fprintf(stderr, "       TTL       := { 0..255 } (default=%d)\n",
+	fprintf(f, "Usage: ip link { add | set | change | replace | del } NAME\n");
+	fprintf(f, "          type { ip6gre | ip6gretap } [ remote ADDR ] [ local ADDR ]\n");
+	fprintf(f, "          [ [i|o]seq ] [ [i|o]key KEY ] [ [i|o]csum ]\n");
+	fprintf(f, "          [ hoplimit TTL ] [ encaplimit ELIM ]\n");
+	fprintf(f, "          [ tclass TCLASS ] [ flowlabel FLOWLABEL ]\n");
+	fprintf(f, "          [ dscp inherit ] [ dev PHYS_DEV ]\n");
+	fprintf(f, "\n");
+	fprintf(f, "Where: NAME      := STRING\n");
+	fprintf(f, "       ADDR      := IPV6_ADDRESS\n");
+	fprintf(f, "       TTL       := { 0..255 } (default=%d)\n",
 		DEFAULT_TNL_HOP_LIMIT);
-	fprintf(stderr, "       KEY       := { DOTTED_QUAD | NUMBER }\n");
-	fprintf(stderr, "       ELIM      := { none | 0..255 }(default=%d)\n",
+	fprintf(f, "       KEY       := { DOTTED_QUAD | NUMBER }\n");
+	fprintf(f, "       ELIM      := { none | 0..255 }(default=%d)\n",
 		IPV6_DEFAULT_TNL_ENCAP_LIMIT);
-	fprintf(stderr, "       TCLASS    := { 0x0..0xff | inherit }\n");
-	fprintf(stderr, "       FLOWLABEL := { 0x0..0xfffff | inherit }\n");
+	fprintf(f, "       TCLASS    := { 0x0..0xff | inherit }\n");
+	fprintf(f, "       FLOWLABEL := { 0x0..0xfffff | inherit }\n");
+}
+
+static void usage(void) __attribute__((noreturn));
+static void usage(void)
+{
+	print_usage(stderr);
 	exit(-1);
 }
 
@@ -386,11 +391,18 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		fputs("ocsum ", f);
 }
 
+static void gre_print_help(struct link_util *lu, int argc, char **argv,
+	FILE *f)
+{
+	print_usage(f);
+}
+
 struct link_util ip6gre_link_util = {
 	.id = "ip6gre",
 	.maxattr = IFLA_GRE_MAX,
 	.parse_opt = gre_parse_opt,
 	.print_opt = gre_print_opt,
+	.print_help = gre_print_help,
 };
 
 struct link_util ip6gretap_link_util = {
@@ -398,4 +410,5 @@ struct link_util ip6gretap_link_util = {
 	.maxattr = IFLA_GRE_MAX,
 	.parse_opt = gre_parse_opt,
 	.print_opt = gre_print_opt,
+	.print_help = gre_print_help,
 };
diff --git a/ip/link_ip6tnl.c b/ip/link_ip6tnl.c
index 1c7f56c..5ed3d5a 100644
--- a/ip/link_ip6tnl.c
+++ b/ip/link_ip6tnl.c
@@ -29,24 +29,29 @@
 
 #define DEFAULT_TNL_HOP_LIMIT	(64)
 
-static void usage(void) __attribute__((noreturn));
-static void usage(void)
+static void print_usage(FILE *f)
 {
-	fprintf(stderr, "Usage: ip link { add | set | change | replace | del } NAME\n");
-	fprintf(stderr, "          [ mode { ip6ip6 | ipip6 | any } ]\n");
-	fprintf(stderr, "          type ip6tnl [ remote ADDR ] [ local ADDR ]\n");
-	fprintf(stderr, "          [ dev PHYS_DEV ] [ encaplimit ELIM ]\n");
-	fprintf(stderr ,"          [ hoplimit HLIM ] [ tclass TCLASS ] [ flowlabel FLOWLABEL ]\n");
-	fprintf(stderr, "          [ dscp inherit ] [ fwmark inherit ]\n");
-	fprintf(stderr, "\n");
-	fprintf(stderr, "Where: NAME      := STRING\n");
-	fprintf(stderr, "       ADDR      := IPV6_ADDRESS\n");
-	fprintf(stderr, "       ELIM      := { none | 0..255 }(default=%d)\n",
+	fprintf(f, "Usage: ip link { add | set | change | replace | del } NAME\n");
+	fprintf(f, "          [ mode { ip6ip6 | ipip6 | any } ]\n");
+	fprintf(f, "          type ip6tnl [ remote ADDR ] [ local ADDR ]\n");
+	fprintf(f, "          [ dev PHYS_DEV ] [ encaplimit ELIM ]\n");
+	fprintf(f ,"          [ hoplimit HLIM ] [ tclass TCLASS ] [ flowlabel FLOWLABEL ]\n");
+	fprintf(f, "          [ dscp inherit ] [ fwmark inherit ]\n");
+	fprintf(f, "\n");
+	fprintf(f, "Where: NAME      := STRING\n");
+	fprintf(f, "       ADDR      := IPV6_ADDRESS\n");
+	fprintf(f, "       ELIM      := { none | 0..255 }(default=%d)\n",
 		IPV6_DEFAULT_TNL_ENCAP_LIMIT);
-	fprintf(stderr, "       HLIM      := 0..255 (default=%d)\n",
+	fprintf(f, "       HLIM      := 0..255 (default=%d)\n",
 		DEFAULT_TNL_HOP_LIMIT);
-	fprintf(stderr, "       TCLASS    := { 0x0..0xff | inherit }\n");
-	fprintf(stderr, "       FLOWLABEL := { 0x0..0xfffff | inherit }\n");
+	fprintf(f, "       TCLASS    := { 0x0..0xff | inherit }\n");
+	fprintf(f, "       FLOWLABEL := { 0x0..0xfffff | inherit }\n");
+}
+
+static void usage(void) __attribute__((noreturn));
+static void usage(void)
+{
+	print_usage(stderr);
 	exit(-1);
 }
 
@@ -335,9 +340,16 @@ static void ip6tunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb
 		fprintf(f, "fwmark inherit ");
 }
 
+static void ip6tunnel_print_help(struct link_util *lu, int argc, char **argv,
+	FILE *f)
+{
+	print_usage(f);
+}
+
 struct link_util ip6tnl_link_util = {
 	.id = "ip6tnl",
 	.maxattr = IFLA_IPTUN_MAX,
 	.parse_opt = ip6tunnel_parse_opt,
 	.print_opt = ip6tunnel_print_opt,
+	.print_help = ip6tunnel_print_help,
 };
diff --git a/ip/link_iptnl.c b/ip/link_iptnl.c
index d5324f8..ea13ce9 100644
--- a/ip/link_iptnl.c
+++ b/ip/link_iptnl.c
@@ -23,22 +23,27 @@
 #include "ip_common.h"
 #include "tunnel.h"
 
-static void usage(int sit) __attribute__((noreturn));
-static void usage(int sit)
+static void print_usage(FILE *f, int sit)
 {
-	fprintf(stderr, "Usage: ip link { add | set | change | replace | del } NAME\n");
-	fprintf(stderr, "          type { ipip | sit } [ remote ADDR ] [ local ADDR ]\n");
-	fprintf(stderr, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
-	fprintf(stderr, "          [ 6rd-prefix ADDR ] [ 6rd-relay_prefix ADDR ] [ 6rd-reset ]\n");
+	fprintf(f, "Usage: ip link { add | set | change | replace | del } NAME\n");
+	fprintf(f, "          type { ipip | sit } [ remote ADDR ] [ local ADDR ]\n");
+	fprintf(f, "          [ ttl TTL ] [ tos TOS ] [ [no]pmtudisc ] [ dev PHYS_DEV ]\n");
+	fprintf(f, "          [ 6rd-prefix ADDR ] [ 6rd-relay_prefix ADDR ] [ 6rd-reset ]\n");
 	if (sit) {
-		fprintf(stderr, "          [ mode { ip6ip | ipip | any } ]\n");
-		fprintf(stderr, "          [ isatap ]\n");
+		fprintf(f, "          [ mode { ip6ip | ipip | any } ]\n");
+		fprintf(f, "          [ isatap ]\n");
 	}
-	fprintf(stderr, "\n");
-	fprintf(stderr, "Where: NAME := STRING\n");
-	fprintf(stderr, "       ADDR := { IP_ADDRESS | any }\n");
-	fprintf(stderr, "       TOS  := { NUMBER | inherit }\n");
-	fprintf(stderr, "       TTL  := { 1..255 | inherit }\n");
+	fprintf(f, "\n");
+	fprintf(f, "Where: NAME := STRING\n");
+	fprintf(f, "       ADDR := { IP_ADDRESS | any }\n");
+	fprintf(f, "       TOS  := { NUMBER | inherit }\n");
+	fprintf(f, "       TTL  := { 1..255 | inherit }\n");
+}
+
+static void usage(int sit) __attribute__((noreturn));
+static void usage(int sit)
+{
+	print_usage(stderr, sit);
 	exit(-1);
 }
 
@@ -347,11 +352,18 @@ static void iptunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[
 	}
 }
 
+static void iptunnel_print_help(struct link_util *lu, int argc, char **argv,
+	FILE *f)
+{
+	print_usage(f, strcmp(lu->id, "sit") == 0);
+}
+
 struct link_util ipip_link_util = {
 	.id = "ipip",
 	.maxattr = IFLA_IPTUN_MAX,
 	.parse_opt = iptunnel_parse_opt,
 	.print_opt = iptunnel_print_opt,
+	.print_help = iptunnel_print_help,
 };
 
 struct link_util sit_link_util = {
@@ -359,4 +371,5 @@ struct link_util sit_link_util = {
 	.maxattr = IFLA_IPTUN_MAX,
 	.parse_opt = iptunnel_parse_opt,
 	.print_opt = iptunnel_print_opt,
+	.print_help = iptunnel_print_help,
 };
diff --git a/ip/link_veth.c b/ip/link_veth.c
index 1196a1b..314216c 100644
--- a/ip/link_veth.c
+++ b/ip/link_veth.c
@@ -17,12 +17,17 @@
 #include "utils.h"
 #include "ip_common.h"
 
-static void usage(void)
+static void print_usage(FILE *f)
 {
 	printf("Usage: ip link <options> type veth [peer <options>]\n"
 	       "To get <options> type 'ip link add help'\n");
 }
 
+static void usage(void)
+{
+	print_usage(stderr);
+}
+
 static int veth_parse_opt(struct link_util *lu, int argc, char **argv,
 			  struct nlmsghdr *hdr)
 {
@@ -79,7 +84,14 @@ static int veth_parse_opt(struct link_util *lu, int argc, char **argv,
 	return argc - 1 - err;
 }
 
+static void veth_print_help(struct link_util *lu, int argc, char **argv,
+	FILE *f)
+{
+	print_usage(f);
+}
+
 struct link_util veth_link_util = {
 	.id = "veth",
 	.parse_opt = veth_parse_opt,
+	.print_help = veth_print_help,
 };
diff --git a/ip/link_vti.c b/ip/link_vti.c
index 6274c83..59ac4c4 100644
--- a/ip/link_vti.c
+++ b/ip/link_vti.c
@@ -24,17 +24,22 @@
 #include "tunnel.h"
 
 
+static void print_usage(FILE *f)
+{
+	fprintf(f, "Usage: ip link { add | set | change | replace | del } NAME\n");
+	fprintf(f, "          type { vti } [ remote ADDR ] [ local ADDR ]\n");
+	fprintf(f, "          [ [i|o]key KEY ]\n");
+	fprintf(f, "          [ dev PHYS_DEV ]\n");
+	fprintf(f, "\n");
+	fprintf(f, "Where: NAME := STRING\n");
+	fprintf(f, "       ADDR := { IP_ADDRESS }\n");
+	fprintf(f, "       KEY  := { DOTTED_QUAD | NUMBER }\n");
+}
+
 static void usage(void) __attribute__((noreturn));
 static void usage(void)
 {
-	fprintf(stderr, "Usage: ip link { add | set | change | replace | del } NAME\n");
-	fprintf(stderr, "          type { vti } [ remote ADDR ] [ local ADDR ]\n");
-	fprintf(stderr, "          [ [i|o]key KEY ]\n");
-	fprintf(stderr, "          [ dev PHYS_DEV ]\n");
-	fprintf(stderr, "\n");
-	fprintf(stderr, "Where: NAME := STRING\n");
-	fprintf(stderr, "       ADDR := { IP_ADDRESS }\n");
-	fprintf(stderr, "       KEY  := { DOTTED_QUAD | NUMBER }\n");
+	print_usage(stderr);
 	exit(-1);
 }
 
@@ -240,9 +245,16 @@ static void vti_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	}
 }
 
+static void vti_print_help(struct link_util *lu, int argc, char **argv,
+	FILE *f)
+{
+	print_usage(f);
+}
+
 struct link_util vti_link_util = {
 	.id = "vti",
 	.maxattr = IFLA_VTI_MAX,
 	.parse_opt = vti_parse_opt,
 	.print_opt = vti_print_opt,
+	.print_help = vti_print_help,
 };
-- 
2.1.0
