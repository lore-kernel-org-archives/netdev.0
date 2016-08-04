From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH iproute v2 3/5] ip6tnl: Support for fou encapsulation
Date: Thu, 4 Aug 2016 13:34:55 -0700
Message-ID: <1470342897-2004557-4-git-send-email-tom@herbertland.com>
References: <1470342897-2004557-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, Tom Herbert <tom@herbertland.com>
To: <shemming@brocade.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:36351 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S965861AbcHDUfR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Aug 2016 16:35:17 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u74KQ4pf004892
	for <netdev@vger.kernel.org>; Thu, 4 Aug 2016 13:35:16 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 24m96d9mmh-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 04 Aug 2016 13:35:16 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)	by
 mx-out.facebook.com (10.103.99.97) with ESMTP	id
 f2b635665a8211e6b8d90002c9931860-493dbaf0 for <netdev@vger.kernel.org>;	Thu,
 04 Aug 2016 13:35:14 -0700
In-Reply-To: <1470342897-2004557-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 ip/link_ip6tnl.c | 92 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 91 insertions(+), 1 deletion(-)

diff --git a/ip/link_ip6tnl.c b/ip/link_ip6tnl.c
index 89861c6..59162a3 100644
--- a/ip/link_ip6tnl.c
+++ b/ip/link_ip6tnl.c
@@ -37,6 +37,9 @@ static void print_usage(FILE *f)
 	fprintf(f, "          [ dev PHYS_DEV ] [ encaplimit ELIM ]\n");
 	fprintf(f, "          [ hoplimit HLIM ] [ tclass TCLASS ] [ flowlabel FLOWLABEL ]\n");
 	fprintf(f, "          [ dscp inherit ] [ fwmark inherit ]\n");
+	fprintf(f, "          [ noencap ] [ encap { fou | gue | none } ]\n");
+	fprintf(f, "          [ encap-sport PORT ] [ encap-dport PORT ]\n");
+	fprintf(f, "          [ [no]encap-csum ] [ [no]encap-csum6 ] [ [no]encap-remcsum ]\n");
 	fprintf(f, "\n");
 	fprintf(f, "Where: NAME      := STRING\n");
 	fprintf(f, "       ADDR      := IPV6_ADDRESS\n");
@@ -82,6 +85,10 @@ static int ip6tunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u32 flags = 0;
 	__u32 link = 0;
 	__u8 proto = 0;
+	__u16 encaptype = 0;
+	__u16 encapflags = TUNNEL_ENCAP_FLAG_CSUM6;
+	__u16 encapsport = 0;
+	__u16 encapdport = 0;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
 		if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0) {
@@ -182,7 +189,7 @@ get_failed:
 			if (get_u8(&uval, *argv, 0))
 				invarg("invalid HLIM", *argv);
 			hop_limit = uval;
-		} else if (matches(*argv, "encaplimit") == 0) {
+		} else if (strcmp(*argv, "encaplimit") == 0) {
 			NEXT_ARG();
 			if (strcmp(*argv, "none") == 0) {
 				flags |= IP6_TNL_F_IGN_ENCAP_LIMIT;
@@ -236,6 +243,40 @@ get_failed:
 			if (strcmp(*argv, "inherit") != 0)
 				invarg("not inherit", *argv);
 			flags |= IP6_TNL_F_USE_ORIG_FWMARK;
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
+			encapflags |= ~TUNNEL_ENCAP_FLAG_REMCSUM;
 		} else
 			usage();
 		argc--, argv++;
@@ -250,6 +291,11 @@ get_failed:
 	addattr32(n, 1024, IFLA_IPTUN_FLAGS, flags);
 	addattr32(n, 1024, IFLA_IPTUN_LINK, link);
 
+	addattr16(n, 1024, IFLA_IPTUN_ENCAP_TYPE, encaptype);
+	addattr16(n, 1024, IFLA_IPTUN_ENCAP_FLAGS, encapflags);
+	addattr16(n, 1024, IFLA_IPTUN_ENCAP_SPORT, htons(encapsport));
+	addattr16(n, 1024, IFLA_IPTUN_ENCAP_DPORT, htons(encapdport));
+
 	return 0;
 }
 
@@ -334,6 +380,50 @@ static void ip6tunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb
 
 	if (flags & IP6_TNL_F_USE_ORIG_FWMARK)
 		fprintf(f, "fwmark inherit ");
+
+	if (tb[IFLA_IPTUN_ENCAP_TYPE] &&
+	    rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_TYPE]) !=
+	    TUNNEL_ENCAP_NONE) {
+		__u16 type = rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_TYPE]);
+		__u16 flags = rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_FLAGS]);
+		__u16 sport = rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_SPORT]);
+		__u16 dport = rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_DPORT]);
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
 
 static void ip6tunnel_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.8.0.rc2
