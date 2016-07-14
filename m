From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH iproute 3/5] ip6tnl: Support for fou encapsulation
Date: Thu, 14 Jul 2016 12:22:14 -0700
Message-ID: <1468524136-3389846-4-git-send-email-tom@herbertland.com>
References: <1468524136-3389846-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, <haoxuany@fb.com>,
	Tom Herbert <tom@herbertland.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:26843 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751798AbcGNTWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 15:22:43 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u6EJIvsH005894
	for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 12:22:42 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 246grs80nm-5
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 14 Jul 2016 12:22:39 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 4df15bae49f811e6974124be0593f280-a51fdaf0 for <netdev@vger.kernel.org>;	Thu,
 14 Jul 2016 12:22:29 -0700
In-Reply-To: <1468524136-3389846-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 ip/link_ip6tnl.c | 92 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 91 insertions(+), 1 deletion(-)

diff --git a/ip/link_ip6tnl.c b/ip/link_ip6tnl.c
index 8a31d0d..0c2eb05 100644
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
@@ -76,6 +79,10 @@ static int ip6tunnel_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u32 flags = 0;
 	__u32 link = 0;
 	__u8 proto = 0;
+	__u16 encaptype = 0;
+	__u16 encapflags = TUNNEL_ENCAP_FLAG_CSUM6;
+	__u16 encapsport = 0;
+	__u16 encapdport = 0;
 
 	memset(&laddr, 0, sizeof(laddr));
 	memset(&raddr, 0, sizeof(raddr));
@@ -142,6 +149,7 @@ get_failed:
 	}
 
 	while (argc > 0) {
+fprintf(stderr, "Process %s\n", *argv);
 		if (matches(*argv, "mode") == 0) {
 			NEXT_ARG();
 			if (strcmp(*argv, "ipv6/ipv6") == 0 ||
@@ -187,7 +195,7 @@ get_failed:
 			if (get_u8(&uval, *argv, 0))
 				invarg("invalid HLIM", *argv);
 			hop_limit = uval;
-		} else if (matches(*argv, "encaplimit") == 0) {
+		} else if (strcmp(*argv, "encaplimit") == 0) {
 			NEXT_ARG();
 			if (strcmp(*argv, "none") == 0) {
 				flags |= IP6_TNL_F_IGN_ENCAP_LIMIT;
@@ -241,6 +249,40 @@ get_failed:
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
@@ -255,6 +297,11 @@ get_failed:
 	addattr32(n, 1024, IFLA_IPTUN_FLAGS, flags);
 	addattr32(n, 1024, IFLA_IPTUN_LINK, link);
 
+	addattr16(n, 1024, IFLA_IPTUN_ENCAP_TYPE, encaptype);
+	addattr16(n, 1024, IFLA_IPTUN_ENCAP_FLAGS, encapflags);
+	addattr16(n, 1024, IFLA_IPTUN_ENCAP_SPORT, htons(encapsport));
+	addattr16(n, 1024, IFLA_IPTUN_ENCAP_DPORT, htons(encapdport));
+
 	return 0;
 }
 
@@ -339,6 +386,49 @@ static void ip6tunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb
 
 	if (flags & IP6_TNL_F_USE_ORIG_FWMARK)
 		fprintf(f, "fwmark inherit ");
+
+	if (tb[IFLA_IPTUN_ENCAP_TYPE] &&
+	    *(__u16 *)RTA_DATA(tb[IFLA_IPTUN_ENCAP_TYPE]) != TUNNEL_ENCAP_NONE) {
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
