From: William Tu <u9012063@gmail.com>
Subject: [PATCHv3 iproute2 net-next] gre: add support for ERSPAN tunnel
Date: Fri, 18 Aug 2017 05:54:08 -0700
Message-ID: <1503060848-42034-1-git-send-email-u9012063@gmail.com>
Cc: Meenakshi Vohra <mvohra@vmware.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35427 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750846AbdHRMyY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 08:54:24 -0400
Received: by mail-pg0-f65.google.com with SMTP id t80so8843309pgb.2
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 05:54:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch adds ERSPAN type II tunnel support.  The implementation
is based on the draft at https://tools.ietf.org/html/draft-foschiano-erspan-01
One of the purposes is for Linux box to be able to receive ERSPAN
monitoring traffic sent from the Cisco switch, by creating a ERSPAN
tunnel device.  In addition, the patch also adds ERSPAN TX, so traffic
can also be encapsulated into ERSPAN and sent out.

The implementation reuses the key as ERSPAN session ID, and
field 'erspan' as ERSPAN Index fields:
./ip link add dev ers11 type erspan seq key 100 erspan 123 \
		local 172.16.1.200 remote 172.16.1.100

Signed-off-by: William Tu <u9012063@gmail.com>
Signed-off-by: Meenakshi Vohra <mvohra@vmware.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
---
v2->v3:
  - make erspan index 0 as reserved, only set to kernel
    when index is non-zero
  - endianness: make the index host byte order

v1->v2:
  Add manual entry for ERSPAN.
  Check 20-bit ERSPAN index field.
---
 include/linux/if_tunnel.h |  1 +
 ip/ipaddress.c            |  2 +-
 ip/iplink.c               |  5 +++--
 ip/link_gre.c             | 29 ++++++++++++++++++++++++++++-
 man/man8/ip-address.8.in  |  1 +
 man/man8/ip-link.8.in     | 19 ++++++++++++++++---
 6 files changed, 50 insertions(+), 7 deletions(-)

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 7375335a0773..21834cac4c0d 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -134,6 +134,7 @@ enum {
 	IFLA_GRE_COLLECT_METADATA,
 	IFLA_GRE_IGNORE_DF,
 	IFLA_GRE_FWMARK,
+	IFLA_GRE_ERSPAN_INDEX,
 	__IFLA_GRE_MAX,
 };
 
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 4d37c5e04507..f7296991e483 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -76,7 +76,7 @@ static void usage(void)
 	fprintf(stderr, "LFT := forever | SECONDS\n");
 	fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |\n");
 	fprintf(stderr, "          bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan | lowpan |\n");
-	fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti | nlmon | can |\n");
+	fprintf(stderr, "          gre | gretap | erspan | ip6gre | ip6gretap | vti | nlmon | can |\n");
 	fprintf(stderr, "          bond_slave | ipvlan | geneve | bridge_slave | vrf | hsr | macsec }\n");
 
 	exit(-1);
diff --git a/ip/iplink.c b/ip/iplink.c
index 5aff2fde38da..62430110bfab 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -112,8 +112,9 @@ void iplink_usage(void)
 			"\n"
 			"TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |\n"
 			"          bridge | bond | team | ipoib | ip6tnl | ipip | sit | vxlan |\n"
-			"          gre | gretap | ip6gre | ip6gretap | vti | nlmon | team_slave |\n"
-			"          bond_slave | ipvlan | geneve | bridge_slave | vrf | macsec }\n");
+			"          gre | gretap | erspan | ip6gre | ip6gretap | vti | nlmon |\n"
+			"          team_slave | bond_slave | ipvlan | geneve | bridge_slave |\n"
+			"          vrf | macsec }\n");
 	}
 	exit(-1);
 }
diff --git a/ip/link_gre.c b/ip/link_gre.c
index c2ec5f26902f..56c3fb8819db 100644
--- a/ip/link_gre.c
+++ b/ip/link_gre.c
@@ -26,7 +26,7 @@
 static void print_usage(FILE *f)
 {
 	fprintf(f,
-		"Usage: ... { gre | gretap } [ remote ADDR ]\n"
+		"Usage: ... { gre | gretap | erspan } [ remote ADDR ]\n"
 		"                            [ local ADDR ]\n"
 		"                            [ [i|o]seq ]\n"
 		"                            [ [i|o]key KEY ]\n"
@@ -44,6 +44,7 @@ static void print_usage(FILE *f)
 		"                            [ [no]encap-csum6 ]\n"
 		"                            [ [no]encap-remcsum ]\n"
 		"                            [ fwmark MARK ]\n"
+		"                            [ erspan IDX ]\n"
 		"\n"
 		"Where: ADDR := { IP_ADDRESS | any }\n"
 		"       TOS  := { NUMBER | inherit }\n"
@@ -96,6 +97,7 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u8 metadata = 0;
 	__u8 ignore_df = 0;
 	__u32 fwmark = 0;
+	__u32 erspan_idx = 0;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
 		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
@@ -172,6 +174,9 @@ get_failed:
 
 		if (greinfo[IFLA_GRE_FWMARK])
 			fwmark = rta_getattr_u32(greinfo[IFLA_GRE_FWMARK]);
+
+		if (greinfo[IFLA_GRE_ERSPAN_INDEX])
+			erspan_idx = rta_getattr_u32(greinfo[IFLA_GRE_ERSPAN_INDEX]);
 	}
 
 	while (argc > 0) {
@@ -328,6 +333,12 @@ get_failed:
 			NEXT_ARG();
 			if (get_u32(&fwmark, *argv, 0))
 				invarg("invalid fwmark\n", *argv);
+		} else if (strcmp(*argv, "erspan") == 0) {
+			NEXT_ARG();
+			if (get_u32(&erspan_idx, *argv, 0))
+				invarg("invalid erspan index\n", *argv);
+			if (erspan_idx & ~((1<<20) - 1) || erspan_idx == 0)
+				invarg("erspan index must be > 0 and <= 20-bit\n", *argv);
 		} else
 			usage();
 		argc--; argv++;
@@ -359,6 +370,8 @@ get_failed:
 		addattr_l(n, 1024, IFLA_GRE_TTL, &ttl, 1);
 		addattr_l(n, 1024, IFLA_GRE_TOS, &tos, 1);
 		addattr32(n, 1024, IFLA_GRE_FWMARK, fwmark);
+		if (erspan_idx != 0)
+			addattr32(n, 1024, IFLA_GRE_ERSPAN_INDEX, erspan_idx);
 	} else {
 		addattr_l(n, 1024, IFLA_GRE_COLLECT_METADATA, NULL, 0);
 	}
@@ -473,6 +486,12 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_GRE_IGNORE_DF] && rta_getattr_u8(tb[IFLA_GRE_IGNORE_DF]))
 		fputs("ignore-df ", f);
 
+	if (tb[IFLA_GRE_ERSPAN_INDEX]) {
+		__u32 erspan_idx = rta_getattr_u32(tb[IFLA_GRE_ERSPAN_INDEX]);
+
+		fprintf(f, "erspan_index %u ", erspan_idx);
+	}
+
 	if (tb[IFLA_GRE_ENCAP_TYPE] &&
 	    rta_getattr_u16(tb[IFLA_GRE_ENCAP_TYPE]) != TUNNEL_ENCAP_NONE) {
 		__u16 type = rta_getattr_u16(tb[IFLA_GRE_ENCAP_TYPE]);
@@ -538,3 +557,11 @@ struct link_util gretap_link_util = {
 	.print_opt = gre_print_opt,
 	.print_help = gre_print_help,
 };
+
+struct link_util erspan_link_util = {
+	.id = "erspan",
+	.maxattr = IFLA_GRE_MAX,
+	.parse_opt = gre_parse_opt,
+	.print_opt = gre_print_opt,
+	.print_help = gre_print_help,
+};
diff --git a/man/man8/ip-address.8.in b/man/man8/ip-address.8.in
index 43385813a134..988a79652f6f 100644
--- a/man/man8/ip-address.8.in
+++ b/man/man8/ip-address.8.in
@@ -120,6 +120,7 @@ ip-address \- protocol address management
 .BR sit " |"
 .BR gre " |"
 .BR gretap " |"
+.BR erspan " |"
 .BR ip6gre " |"
 .BR ip6gretap " |"
 .BR vti " |"
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index c0207281905d..851b308cbe1a 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -202,6 +202,7 @@ ip-link \- network device configuration
 .BR sit " |"
 .BR gre " |"
 .BR gretap " |"
+.BR erspan " |"
 .BR ip6gre " |"
 .BR ip6gretap " |"
 .BR vti " |"
@@ -297,6 +298,9 @@ Link types:
 .BR gretap
 - Virtual L2 tunnel interface GRE over IPv4
 .sp
+.BR erspan
+- Encapsulated Remote SPAN over GRE and IPv4
+.sp
 .BR ip6gre
 - Virtual tunnel interface GRE over IPv6
 .sp
@@ -643,13 +647,13 @@ keyword.
 .in -8
 
 .TP
-GRE, IPIP, SIT Type Support
+GRE, IPIP, SIT, ERSPAN Type Support
 For a link of types
-.I GRE/IPIP/SIT
+.I GRE/IPIP/SIT/ERSPAN
 the following additional arguments are supported:
 
 .BI "ip link add " DEVICE
-.BR type " { " gre " | " ipip " | " sit " }"
+.BR type " { " gre " | " ipip " | " sit " | " erspan " }"
 .BI " remote " ADDR " local " ADDR
 [
 .BR encap " { " fou " | " gue " | " none " }"
@@ -663,6 +667,8 @@ the following additional arguments are supported:
 .I " [no]encap-remcsum "
 ] [
 .I " mode " { ip6ip | ipip | mplsip | any } "
+] [
+.BR erspan " \fIIDX "
 ]
 
 .in +8
@@ -707,6 +713,13 @@ MPLS-Over-IPv4, "any" indicates IPv6, IPv4 or MPLS Over IPv4. Supported for
 SIT where the default is "ip6ip" and IPIP where the default is "ipip".
 IPv6-Over-IPv4 is not supported for IPIP.
 
+.sp
+.BR erspan " \fIIDX "
+- specifies the ERSPAN index field.
+.IR IDX
+indicates a 20 bit index/port number associated with the ERSPAN
+traffic's source port and direction.
+
 .in -8
 
 .TP
-- 
2.7.4
