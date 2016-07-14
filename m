From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH iproute 4/5] gre6: Support for fou encapsulation
Date: Thu, 14 Jul 2016 12:22:15 -0700
Message-ID: <1468524136-3389846-5-git-send-email-tom@herbertland.com>
References: <1468524136-3389846-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <haoxuany@fb.com>,
	Tom Herbert <tom@herbertland.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:17346 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751347AbcGNTWd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 15:22:33 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u6EJKS2Z000387
	for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 12:22:32 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 246grc80u5-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 12:22:32 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 4eb3b0dc49f811e6974124be0593f280-a51fdaf0 for <netdev@vger.kernel.org>;	Thu,
 14 Jul 2016 12:22:30 -0700
In-Reply-To: <1468524136-3389846-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 ip/link_gre6.c | 101 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 101 insertions(+)

diff --git a/ip/link_gre6.c b/ip/link_gre6.c
index bddfc0f..e18132e 100644
--- a/ip/link_gre6.c
+++ b/ip/link_gre6.c
@@ -38,6 +38,9 @@ static void print_usage(FILE *f)
 	fprintf(f, "          [ hoplimit TTL ] [ encaplimit ELIM ]\n");
 	fprintf(f, "          [ tclass TCLASS ] [ flowlabel FLOWLABEL ]\n");
 	fprintf(f, "          [ dscp inherit ] [ dev PHYS_DEV ]\n");
+	fprintf(f, "          [ noencap ] [ encap { fou | gue | none } ]\n");
+	fprintf(f, "          [ encap-sport PORT ] [ encap-dport PORT ]\n");
+	fprintf(f, "          [ [no]encap-csum ] [ [no]encap-csum6 ] [ [no]encap-remcsum ]\n");
 	fprintf(f, "\n");
 	fprintf(f, "Where: NAME      := STRING\n");
 	fprintf(f, "       ADDR      := IPV6_ADDRESS\n");
@@ -80,6 +83,10 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
 	unsigned int flags = 0;
 	__u8 hop_limit = DEFAULT_TNL_HOP_LIMIT;
 	__u8 encap_limit = IPV6_DEFAULT_TNL_ENCAP_LIMIT;
+	__u16 encaptype = 0;
+	__u16 encapflags = TUNNEL_ENCAP_FLAG_CSUM6;
+	__u16 encapsport = 0;
+	__u16 encapdport = 0;
 	int len;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
@@ -148,6 +155,18 @@ get_failed:
 
 		if (greinfo[IFLA_GRE_FLAGS])
 			flags = rta_getattr_u32(greinfo[IFLA_GRE_FLAGS]);
+
+		if (greinfo[IFLA_GRE_ENCAP_TYPE])
+			encaptype = rta_getattr_u16(greinfo[IFLA_GRE_ENCAP_TYPE]);
+
+		if (greinfo[IFLA_GRE_ENCAP_FLAGS])
+			encapflags = rta_getattr_u16(greinfo[IFLA_GRE_ENCAP_FLAGS]);
+
+		if (greinfo[IFLA_GRE_ENCAP_SPORT])
+			encapsport = rta_getattr_u16(greinfo[IFLA_GRE_ENCAP_SPORT]);
+
+		if (greinfo[IFLA_GRE_ENCAP_DPORT])
+			encapdport = rta_getattr_u16(greinfo[IFLA_GRE_ENCAP_DPORT]);
 	}
 
 	while (argc > 0) {
@@ -279,6 +298,40 @@ get_failed:
 			if (strcmp(*argv, "inherit") != 0)
 				invarg("not inherit", *argv);
 			flags |= IP6_TNL_F_RCV_DSCP_COPY;
+		} else if (strcmp(*argv, "noencap") == 0) {
+			encaptype = TUNNEL_ENCAP_NONE;
+		} else if (strcmp(*argv, "encap") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "fou") == 0)
+				encaptype = TUNNEL_ENCAP_FOU;
+			else if (strcmp(*argv, "gue") == 0)
+				encaptype = TUNNEL_ENCAP_GUE;
+			else if (strcmp(*argv, "none") == 0)
+				encaptype = TUNNEL_ENCAP_NONE;
+			else
+				invarg("Invalid encap type.", *argv);
+		} else if (strcmp(*argv, "encap-sport") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "auto") == 0)
+				encapsport = 0;
+			else if (get_u16(&encapsport, *argv, 0))
+				invarg("Invalid source port.", *argv);
+		} else if (strcmp(*argv, "encap-dport") == 0) {
+			NEXT_ARG();
+			if (get_u16(&encapdport, *argv, 0))
+				invarg("Invalid destination port.", *argv);
+		} else if (strcmp(*argv, "encap-csum") == 0) {
+			encapflags |= TUNNEL_ENCAP_FLAG_CSUM;
+		} else if (strcmp(*argv, "noencap-csum") == 0) {
+			encapflags &= ~TUNNEL_ENCAP_FLAG_CSUM;
+		} else if (strcmp(*argv, "encap-udp6-csum") == 0) {
+			encapflags |= TUNNEL_ENCAP_FLAG_CSUM6;
+		} else if (strcmp(*argv, "noencap-udp6-csum") == 0) {
+			encapflags &= ~TUNNEL_ENCAP_FLAG_CSUM6;
+		} else if (strcmp(*argv, "encap-remcsum") == 0) {
+			encapflags |= TUNNEL_ENCAP_FLAG_REMCSUM;
+		} else if (strcmp(*argv, "noencap-remcsum") == 0) {
+			encapflags &= ~TUNNEL_ENCAP_FLAG_REMCSUM;
 		} else
 			usage();
 		argc--; argv++;
@@ -297,6 +350,11 @@ get_failed:
 	addattr_l(n, 1024, IFLA_GRE_FLOWINFO, &flowinfo, 4);
 	addattr_l(n, 1024, IFLA_GRE_FLAGS, &flowinfo, 4);
 
+	addattr16(n, 1024, IFLA_GRE_ENCAP_TYPE, encaptype);
+	addattr16(n, 1024, IFLA_GRE_ENCAP_FLAGS, encapflags);
+	addattr16(n, 1024, IFLA_GRE_ENCAP_SPORT, htons(encapsport));
+	addattr16(n, 1024, IFLA_GRE_ENCAP_DPORT, htons(encapdport));
+
 	return 0;
 }
 
@@ -395,6 +453,49 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		fputs("icsum ", f);
 	if (oflags & GRE_CSUM)
 		fputs("ocsum ", f);
+
+	if (tb[IFLA_GRE_ENCAP_TYPE] &&
+	    *(__u16 *)RTA_DATA(tb[IFLA_GRE_ENCAP_TYPE]) != TUNNEL_ENCAP_NONE) {
+		__u16 type = rta_getattr_u16(tb[IFLA_GRE_ENCAP_TYPE]);
+		__u16 flags = rta_getattr_u16(tb[IFLA_GRE_ENCAP_FLAGS]);
+		__u16 sport = rta_getattr_u16(tb[IFLA_GRE_ENCAP_SPORT]);
+		__u16 dport = rta_getattr_u16(tb[IFLA_GRE_ENCAP_DPORT]);
+
+		fputs("encap ", f);
+		switch (type) {
+		case TUNNEL_ENCAP_FOU:
+			fputs("fou ", f);
+			break;
+		case TUNNEL_ENCAP_GUE:
+			fputs("gue ", f);
+			break;
+		default:
+			fputs("unknown ", f);
+			break;
+		}
+
+		if (sport == 0)
+			fputs("encap-sport auto ", f);
+		else
+			fprintf(f, "encap-sport %u", ntohs(sport));
+
+		fprintf(f, "encap-dport %u ", ntohs(dport));
+
+		if (flags & TUNNEL_ENCAP_FLAG_CSUM)
+			fputs("encap-csum ", f);
+		else
+			fputs("noencap-csum ", f);
+
+		if (flags & TUNNEL_ENCAP_FLAG_CSUM6)
+			fputs("encap-csum6 ", f);
+		else
+			fputs("noencap-csum6 ", f);
+
+		if (flags & TUNNEL_ENCAP_FLAG_REMCSUM)
+			fputs("encap-remcsum ", f);
+		else
+			fputs("noencap-remcsum ", f);
+	}
 }
 
 static void gre_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.8.0.rc2
