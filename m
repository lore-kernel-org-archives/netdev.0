From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH iproute2] iplink: Expose IFLA_*_FWMARK attributes for supported link types
Date: Fri, 21 Apr 2017 14:14:53 -0400
Message-ID: <20170421181453.166316-1-kraigatgoog@gmail.com>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f174.google.com ([209.85.216.174]:35759 "EHLO
        mail-qt0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1041166AbdDUSW0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:22:26 -0400
Received: by mail-qt0-f174.google.com with SMTP id y33so76000475qta.2
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 11:22:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

This attribute allows the administrator to adjust the packet marking
attribute of tunnels that support policy based routing.

Signed-off-by: Craig Gallek <kraig@google.com>
---
 include/linux/if_tunnel.h |  3 +++
 ip/link_gre.c             | 16 ++++++++++++++++
 ip/link_gre6.c            | 24 +++++++++++++++++++++++-
 ip/link_ip6tnl.c          | 23 ++++++++++++++++++-----
 ip/link_iptnl.c           | 16 ++++++++++++++++
 ip/link_vti.c             | 16 ++++++++++++++++
 ip/link_vti6.c            | 15 +++++++++++++++
 7 files changed, 107 insertions(+), 6 deletions(-)

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 4f975f5704d8..7375335a0773 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -75,6 +75,7 @@ enum {
 	IFLA_IPTUN_ENCAP_SPORT,
 	IFLA_IPTUN_ENCAP_DPORT,
 	IFLA_IPTUN_COLLECT_METADATA,
+	IFLA_IPTUN_FWMARK,
 	__IFLA_IPTUN_MAX,
 };
 #define IFLA_IPTUN_MAX	(__IFLA_IPTUN_MAX - 1)
@@ -132,6 +133,7 @@ enum {
 	IFLA_GRE_ENCAP_DPORT,
 	IFLA_GRE_COLLECT_METADATA,
 	IFLA_GRE_IGNORE_DF,
+	IFLA_GRE_FWMARK,
 	__IFLA_GRE_MAX,
 };
 
@@ -147,6 +149,7 @@ enum {
 	IFLA_VTI_OKEY,
 	IFLA_VTI_LOCAL,
 	IFLA_VTI_REMOTE,
+	IFLA_VTI_FWMARK,
 	__IFLA_VTI_MAX,
 };
 
diff --git a/ip/link_gre.c b/ip/link_gre.c
index 35d437a15562..82df900614bf 100644
--- a/ip/link_gre.c
+++ b/ip/link_gre.c
@@ -42,11 +42,13 @@ static void print_usage(FILE *f)
 		"                            [ [no]encap-csum ]\n"
 		"                            [ [no]encap-csum6 ]\n"
 		"                            [ [no]encap-remcsum ]\n"
+		"                            [ fwmark MARK ]\n"
 		"\n"
 		"Where: ADDR := { IP_ADDRESS | any }\n"
 		"       TOS  := { NUMBER | inherit }\n"
 		"       TTL  := { 1..255 | inherit }\n"
 		"       KEY  := { DOTTED_QUAD | NUMBER }\n"
+		"       MARK := { 0x0..0xffffffff }\n"
 	);
 }
 
@@ -91,6 +93,7 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u16 encapsport = 0;
 	__u16 encapdport = 0;
 	__u8 metadata = 0;
+	__u32 fwmark = 0;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
 		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
@@ -160,6 +163,9 @@ get_failed:
 
 		if (greinfo[IFLA_GRE_COLLECT_METADATA])
 			metadata = 1;
+
+		if (greinfo[IFLA_GRE_FWMARK])
+			fwmark = rta_getattr_u32(greinfo[IFLA_GRE_FWMARK]);
 	}
 
 	while (argc > 0) {
@@ -305,6 +311,10 @@ get_failed:
 			encapflags |= ~TUNNEL_ENCAP_FLAG_REMCSUM;
 		} else if (strcmp(*argv, "external") == 0) {
 			metadata = 1;
+		} else if (strcmp(*argv, "fwmark") == 0) {
+			NEXT_ARG();
+			if (get_u32(&fwmark, *argv, 0))
+				invarg("invalid fwmark\n", *argv);
 		} else
 			usage();
 		argc--; argv++;
@@ -335,6 +345,7 @@ get_failed:
 			addattr32(n, 1024, IFLA_GRE_LINK, link);
 		addattr_l(n, 1024, IFLA_GRE_TTL, &ttl, 1);
 		addattr_l(n, 1024, IFLA_GRE_TOS, &tos, 1);
+		addattr32(n, 1024, IFLA_GRE_FWMARK, fwmark);
 	} else {
 		addattr_l(n, 1024, IFLA_GRE_COLLECT_METADATA, NULL, 0);
 	}
@@ -426,6 +437,11 @@ static void gre_print_direct_opt(FILE *f, struct rtattr *tb[])
 		fputs("icsum ", f);
 	if (oflags & GRE_CSUM)
 		fputs("ocsum ", f);
+
+	if (tb[IFLA_GRE_FWMARK] && rta_getattr_u32(tb[IFLA_GRE_FWMARK])) {
+		fprintf(f, "fwmark 0x%x ",
+			rta_getattr_u32(tb[IFLA_GRE_FWMARK]));
+	}
 }
 
 static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
diff --git a/ip/link_gre6.c b/ip/link_gre6.c
index 1b4fb051b37f..205bada78054 100644
--- a/ip/link_gre6.c
+++ b/ip/link_gre6.c
@@ -43,6 +43,7 @@ static void print_usage(FILE *f)
 		"                                  [ tclass TCLASS ]\n"
 		"                                  [ flowlabel FLOWLABEL ]\n"
 		"                                  [ dscp inherit ]\n"
+		"                                  [ fwmark MARK ]\n"
 		"                                  [ dev PHYS_DEV ]\n"
 		"                                  [ noencap ]\n"
 		"                                  [ encap { fou | gue | none } ]\n"
@@ -57,7 +58,8 @@ static void print_usage(FILE *f)
 		"       KEY       := { DOTTED_QUAD | NUMBER }\n"
 		"       ELIM      := { none | 0..255 }(default=%d)\n"
 		"       TCLASS    := { 0x0..0xff | inherit }\n"
-		"       FLOWLABEL := { 0x0..0xfffff | inherit }\n",
+		"       FLOWLABEL := { 0x0..0xfffff | inherit }\n"
+		"       MARK      := { 0x0..0xffffffff | inherit }\n",
 		DEFAULT_TNL_HOP_LIMIT, IPV6_DEFAULT_TNL_ENCAP_LIMIT
 	);
 }
@@ -103,6 +105,7 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u16 encapsport = 0;
 	__u16 encapdport = 0;
 	int len;
+	__u32 fwmark = 0;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
 		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
@@ -174,6 +177,9 @@ get_failed:
 
 		if (greinfo[IFLA_GRE_ENCAP_DPORT])
 			encapdport = rta_getattr_u16(greinfo[IFLA_GRE_ENCAP_DPORT]);
+
+		if (greinfo[IFLA_GRE_FWMARK])
+			fwmark = rta_getattr_u32(greinfo[IFLA_GRE_FWMARK]);
 	}
 
 	while (argc > 0) {
@@ -339,6 +345,16 @@ get_failed:
 			encapflags |= TUNNEL_ENCAP_FLAG_REMCSUM;
 		} else if (strcmp(*argv, "noencap-remcsum") == 0) {
 			encapflags &= ~TUNNEL_ENCAP_FLAG_REMCSUM;
+		} else if (strcmp(*argv, "fwmark") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "inherit") == 0) {
+				flags |= IP6_TNL_F_USE_ORIG_FWMARK;
+				fwmark = 0;
+			} else {
+				if (get_u32(&fwmark, *argv, 0))
+					invarg("invalid fwmark\n", *argv);
+				flags &= ~IP6_TNL_F_USE_ORIG_FWMARK;
+			}
 		} else
 			usage();
 		argc--; argv++;
@@ -356,6 +372,7 @@ get_failed:
 	addattr_l(n, 1024, IFLA_GRE_ENCAP_LIMIT, &encap_limit, 1);
 	addattr_l(n, 1024, IFLA_GRE_FLOWINFO, &flowinfo, 4);
 	addattr32(n, 1024, IFLA_GRE_FLAGS, flags);
+	addattr32(n, 1024, IFLA_GRE_FWMARK, fwmark);
 
 	addattr16(n, 1024, IFLA_GRE_ENCAP_TYPE, encaptype);
 	addattr16(n, 1024, IFLA_GRE_ENCAP_FLAGS, encapflags);
@@ -461,6 +478,11 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (oflags & GRE_CSUM)
 		fputs("ocsum ", f);
 
+	if (flags & IP6_TNL_F_USE_ORIG_FWMARK)
+		fprintf(f, "fwmark inherit ");
+	else if (tb[IFLA_GRE_FWMARK] && rta_getattr_u32(tb[IFLA_GRE_FWMARK]))
+		fprintf(f, "fwmark 0x%x ", rta_getattr_u32(tb[IFLA_GRE_FWMARK]));
+
 	if (tb[IFLA_GRE_ENCAP_TYPE] &&
 	    rta_getattr_u16(tb[IFLA_GRE_ENCAP_TYPE]) != TUNNEL_ENCAP_NONE) {
 		__u16 type = rta_getattr_u16(tb[IFLA_GRE_ENCAP_TYPE]);
diff --git a/ip/link_ip6tnl.c b/ip/link_ip6tnl.c
index 6bb968d3c918..505fb47622ed 100644
--- a/ip/link_ip6tnl.c
+++ b/ip/link_ip6tnl.c
@@ -41,7 +41,7 @@ static void print_usage(FILE *f)
 		"                  [ tclass TCLASS ]\n"
 		"                  [ flowlabel FLOWLABEL ]\n"
 		"                  [ dscp inherit ]\n"
-		"                  [ fwmark inherit ]\n"
+		"                  [ fwmark MARK ]\n"
 		"                  [ noencap ]\n"
 		"                  [ encap { fou | gue | none } ]\n"
 		"                  [ encap-sport PORT ]\n"
@@ -55,7 +55,8 @@ static void print_usage(FILE *f)
 		"       ELIM      := { none | 0..255 }(default=%d)\n"
 		"       HLIM      := 0..255 (default=%d)\n"
 		"       TCLASS    := { 0x0..0xff | inherit }\n"
-		"       FLOWLABEL := { 0x0..0xfffff | inherit }\n",
+		"       FLOWLABEL := { 0x0..0xfffff | inherit }\n"
+		"       MARK      := { 0x0..0xffffffff | inherit }\n",
 		IPV6_DEFAULT_TNL_ENCAP_LIMIT, DEFAULT_TNL_HOP_LIMIT
 	);
 }
@@ -99,6 +100,7 @@ static int ip6tunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u16 encapsport = 0;
 	__u16 encapdport = 0;
 	__u8 metadata = 0;
+	__u32 fwmark = 0;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
 		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
@@ -153,6 +155,9 @@ get_failed:
 			proto = rta_getattr_u8(iptuninfo[IFLA_IPTUN_PROTO]);
 		if (iptuninfo[IFLA_IPTUN_COLLECT_METADATA])
 			metadata = 1;
+
+		if (iptuninfo[IFLA_IPTUN_FWMARK])
+			fwmark = rta_getattr_u32(iptuninfo[IFLA_IPTUN_FWMARK]);
 	}
 
 	while (argc > 0) {
@@ -252,9 +257,14 @@ get_failed:
 			flags |= IP6_TNL_F_RCV_DSCP_COPY;
 		} else if (strcmp(*argv, "fwmark") == 0) {
 			NEXT_ARG();
-			if (strcmp(*argv, "inherit") != 0)
-				invarg("not inherit", *argv);
-			flags |= IP6_TNL_F_USE_ORIG_FWMARK;
+			if (strcmp(*argv, "inherit") == 0) {
+				flags |= IP6_TNL_F_USE_ORIG_FWMARK;
+				fwmark = 0;
+			} else {
+				if (get_u32(&fwmark, *argv, 0))
+					invarg("invalid fwmark\n", *argv);
+				flags &= ~IP6_TNL_F_USE_ORIG_FWMARK;
+			}
 		} else if (strcmp(*argv, "noencap") == 0) {
 			encaptype = TUNNEL_ENCAP_NONE;
 		} else if (strcmp(*argv, "encap") == 0) {
@@ -308,6 +318,7 @@ get_failed:
 	addattr32(n, 1024, IFLA_IPTUN_FLOWINFO, flowinfo);
 	addattr32(n, 1024, IFLA_IPTUN_FLAGS, flags);
 	addattr32(n, 1024, IFLA_IPTUN_LINK, link);
+	addattr32(n, 1024, IFLA_IPTUN_FWMARK, fwmark);
 
 	addattr16(n, 1024, IFLA_IPTUN_ENCAP_TYPE, encaptype);
 	addattr16(n, 1024, IFLA_IPTUN_ENCAP_FLAGS, encapflags);
@@ -398,6 +409,8 @@ static void ip6tunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb
 
 	if (flags & IP6_TNL_F_USE_ORIG_FWMARK)
 		fprintf(f, "fwmark inherit ");
+	else if (tb[IFLA_IPTUN_FWMARK] && rta_getattr_u32(tb[IFLA_IPTUN_FWMARK]))
+		fprintf(f, "fwmark 0x%x ", rta_getattr_u32(tb[IFLA_IPTUN_FWMARK]));
 
 	if (tb[IFLA_IPTUN_ENCAP_TYPE] &&
 	    rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_TYPE]) !=
diff --git a/ip/link_iptnl.c b/ip/link_iptnl.c
index f180b921e471..2f74d9b7df1a 100644
--- a/ip/link_iptnl.c
+++ b/ip/link_iptnl.c
@@ -52,10 +52,12 @@ static void print_usage(FILE *f, int sit)
 			"                [ isatap ]\n");
 	}
 	fprintf(f, "                [ external ]\n");
+	fprintf(f, "                [ fwmark MARK ]\n");
 	fprintf(f, "\n");
 	fprintf(f, "Where: ADDR := { IP_ADDRESS | any }\n");
 	fprintf(f, "       TOS  := { NUMBER | inherit }\n");
 	fprintf(f, "       TTL  := { 1..255 | inherit }\n");
+	fprintf(f, "       MARK := { 0x0..0xffffffff }\n");
 }
 
 static void usage(int sit) __attribute__((noreturn));
@@ -101,6 +103,7 @@ static int iptunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u16 encapsport = 0;
 	__u16 encapdport = 0;
 	__u8 metadata = 0;
+	__u32 fwmark = 0;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
 		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
@@ -179,6 +182,10 @@ get_failed:
 				rta_getattr_u16(iptuninfo[IFLA_IPTUN_6RD_RELAY_PREFIXLEN]);
 		if (iptuninfo[IFLA_IPTUN_COLLECT_METADATA])
 			metadata = 1;
+
+		if (iptuninfo[IFLA_IPTUN_FWMARK])
+			fwmark = rta_getattr_u32(iptuninfo[IFLA_IPTUN_FWMARK]);
+
 	}
 
 	while (argc > 0) {
@@ -301,6 +308,10 @@ get_failed:
 			ip6rdprefixlen = 16;
 			ip6rdrelayprefix = 0;
 			ip6rdrelayprefixlen = 0;
+		} else if (strcmp(*argv, "fwmark") == 0) {
+			NEXT_ARG();
+			if (get_u32(&fwmark, *argv, 0))
+				invarg("invalid fwmark\n", *argv);
 		} else
 			usage(strcmp(lu->id, "sit") == 0);
 		argc--, argv++;
@@ -322,6 +333,7 @@ get_failed:
 	addattr8(n, 1024, IFLA_IPTUN_TTL, ttl);
 	addattr8(n, 1024, IFLA_IPTUN_TOS, tos);
 	addattr8(n, 1024, IFLA_IPTUN_PMTUDISC, pmtudisc);
+	addattr32(n, 1024, IFLA_IPTUN_FWMARK, fwmark);
 
 	addattr16(n, 1024, IFLA_IPTUN_ENCAP_TYPE, encaptype);
 	addattr16(n, 1024, IFLA_IPTUN_ENCAP_FLAGS, encapflags);
@@ -471,6 +483,10 @@ static void iptunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[
 		else
 			fputs("noencap-remcsum ", f);
 	}
+
+	if (tb[IFLA_IPTUN_FWMARK] && rta_getattr_u32(tb[IFLA_IPTUN_FWMARK]))
+		fprintf(f, "fwmark 0x%x ",
+			rta_getattr_u32(tb[IFLA_IPTUN_FWMARK]));
 }
 
 static void iptunnel_print_help(struct link_util *lu, int argc, char **argv,
diff --git a/ip/link_vti.c b/ip/link_vti.c
index 95bc23e92897..d5242ac762fd 100644
--- a/ip/link_vti.c
+++ b/ip/link_vti.c
@@ -31,9 +31,11 @@ static void print_usage(FILE *f)
 		"               [ local ADDR ]\n"
 		"               [ [i|o]key KEY ]\n"
 		"               [ dev PHYS_DEV ]\n"
+		"               [ fwmark MARK ]\n"
 		"\n"
 		"Where: ADDR := { IP_ADDRESS }\n"
 		"       KEY  := { DOTTED_QUAD | NUMBER }\n"
+		"       MARK := { 0x0..0xffffffff }\n"
 	);
 }
 
@@ -67,6 +69,7 @@ static int vti_parse_opt(struct link_util *lu, int argc, char **argv,
 	unsigned int saddr = 0;
 	unsigned int daddr = 0;
 	unsigned int link = 0;
+	unsigned int fwmark = 0;
 	int len;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
@@ -109,6 +112,9 @@ get_failed:
 
 		if (vtiinfo[IFLA_VTI_LINK])
 			link = rta_getattr_u8(vtiinfo[IFLA_VTI_LINK]);
+
+		if (vtiinfo[IFLA_VTI_FWMARK])
+			fwmark = rta_getattr_u32(vtiinfo[IFLA_VTI_FWMARK]);
 	}
 
 	while (argc > 0) {
@@ -180,6 +186,10 @@ get_failed:
 					*argv);
 				exit(-1);
 			}
+		} else if (strcmp(*argv, "fwmark") == 0) {
+			NEXT_ARG();
+			if (get_u32(&fwmark, *argv, 0))
+				invarg("invalid fwmark\n", *argv);
 		} else
 			usage();
 		argc--; argv++;
@@ -189,6 +199,7 @@ get_failed:
 	addattr32(n, 1024, IFLA_VTI_OKEY, okey);
 	addattr_l(n, 1024, IFLA_VTI_LOCAL, &saddr, 4);
 	addattr_l(n, 1024, IFLA_VTI_REMOTE, &daddr, 4);
+	addattr32(n, 1024, IFLA_VTI_FWMARK, fwmark);
 	if (link)
 		addattr32(n, 1024, IFLA_VTI_LINK, link);
 
@@ -242,6 +253,11 @@ static void vti_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		inet_ntop(AF_INET, RTA_DATA(tb[IFLA_VTI_OKEY]), s2, sizeof(s2));
 		fprintf(f, "okey %s ", s2);
 	}
+
+	if (tb[IFLA_VTI_FWMARK] && rta_getattr_u32(tb[IFLA_VTI_FWMARK])) {
+		fprintf(f, "fwmark 0x%x ",
+			rta_getattr_u32(tb[IFLA_VTI_FWMARK]));
+	}
 }
 
 static void vti_print_help(struct link_util *lu, int argc, char **argv,
diff --git a/ip/link_vti6.c b/ip/link_vti6.c
index 9ca127af8a5d..be4e33cee606 100644
--- a/ip/link_vti6.c
+++ b/ip/link_vti6.c
@@ -32,10 +32,12 @@ static void usage(void)
 	fprintf(stderr, "          type { vti6 } [ remote ADDR ] [ local ADDR ]\n");
 	fprintf(stderr, "          [ [i|o]key KEY ]\n");
 	fprintf(stderr, "          [ dev PHYS_DEV ]\n");
+	fprintf(stderr, "          [ fwmark MARK ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: NAME := STRING\n");
 	fprintf(stderr, "       ADDR := { IPV6_ADDRESS }\n");
 	fprintf(stderr, "       KEY  := { DOTTED_QUAD | NUMBER }\n");
+	fprintf(stderr, "       MARK := { 0x0..0xffffffff }\n");
 	exit(-1);
 }
 
@@ -62,6 +64,7 @@ static int vti6_parse_opt(struct link_util *lu, int argc, char **argv,
 	unsigned int ikey = 0;
 	unsigned int okey = 0;
 	unsigned int link = 0;
+	__u32 fwmark = 0;
 	int len;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
@@ -104,6 +107,9 @@ get_failed:
 
 		if (vtiinfo[IFLA_VTI_LINK])
 			link = rta_getattr_u8(vtiinfo[IFLA_VTI_LINK]);
+
+		if (vtiinfo[IFLA_VTI_FWMARK])
+			fwmark = rta_getattr_u32(vtiinfo[IFLA_VTI_FWMARK]);
 	}
 
 	while (argc > 0) {
@@ -178,6 +184,10 @@ get_failed:
 			link = if_nametoindex(*argv);
 			if (link == 0)
 				exit(-1);
+		} else if (strcmp(*argv, "fwmark") == 0) {
+			NEXT_ARG();
+			if (get_u32(&fwmark, *argv, 0))
+				invarg("invalid fwmark\n", *argv);
 		} else
 			usage();
 		argc--; argv++;
@@ -187,6 +197,7 @@ get_failed:
 	addattr32(n, 1024, IFLA_VTI_OKEY, okey);
 	addattr_l(n, 1024, IFLA_VTI_LOCAL, &saddr, sizeof(saddr));
 	addattr_l(n, 1024, IFLA_VTI_REMOTE, &daddr, sizeof(daddr));
+	addattr32(n, 1024, IFLA_VTI_FWMARK, fwmark);
 	if (link)
 		addattr32(n, 1024, IFLA_VTI_LINK, link);
 
@@ -239,6 +250,10 @@ static void vti6_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		inet_ntop(AF_INET, RTA_DATA(tb[IFLA_VTI_OKEY]), s2, sizeof(s2));
 		fprintf(f, "okey %s ", s2);
 	}
+
+	if (tb[IFLA_VTI_FWMARK] && rta_getattr_u32(tb[IFLA_VTI_FWMARK])) {
+		fprintf(f, "fwmark 0x%x ", rta_getattr_u32(tb[IFLA_VTI_FWMARK]));
+	}
 }
 
 struct link_util vti6_link_util = {
-- 
2.12.2.816.g2cccc81164-goog
