From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH iproute2 v2 3/3] lwtunnel: implement support for ip6 encap
Date: Wed, 16 Dec 2015 13:22:28 +0100
Message-ID: <25335db6a83c31df4a13bfff8dfc4c359f8f1ef9.1450267709.git.pabeni@redhat.com>
References: <cover.1450267709.git.pabeni@redhat.com>
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jiri Benc <jbenc@redhat.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33709 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933781AbbLPMWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 07:22:45 -0500
In-Reply-To: <cover.1450267709.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently ip6 encap support for lwtunnel is missing.
This patch implement it, mostly duplicating the ipv4 parts.

Also be sure to insert a space after the encap type, when
showing lwtunnel, to avoid the tunnel type and the following
argument being merged into a single word.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 ip/iproute_lwtunnel.c | 91 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 90 insertions(+), 1 deletion(-)

diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
index c825b82..b34e02c 100644
--- a/ip/iproute_lwtunnel.c
+++ b/ip/iproute_lwtunnel.c
@@ -95,6 +95,37 @@ static void print_encap_ip(FILE *fp, struct rtattr *encap)
 		fprintf(fp, "tos %d ", rta_getattr_u8(tb[LWTUNNEL_IP_TOS]));
 }
 
+static void print_encap_ip6(FILE *fp, struct rtattr *encap)
+{
+	struct rtattr *tb[LWTUNNEL_IP6_MAX+1];
+	char abuf[256];
+
+	parse_rtattr_nested(tb, LWTUNNEL_IP6_MAX, encap);
+
+	if (tb[LWTUNNEL_IP6_ID])
+		fprintf(fp, "id %llu ", ntohll(rta_getattr_u64(tb[LWTUNNEL_IP6_ID])));
+
+	if (tb[LWTUNNEL_IP6_SRC])
+		fprintf(fp, "src %s ",
+			rt_addr_n2a(AF_INET6,
+				    RTA_PAYLOAD(tb[LWTUNNEL_IP6_SRC]),
+				    RTA_DATA(tb[LWTUNNEL_IP6_SRC]),
+				    abuf, sizeof(abuf)));
+
+	if (tb[LWTUNNEL_IP6_DST])
+		fprintf(fp, "dst %s ",
+			rt_addr_n2a(AF_INET6,
+				    RTA_PAYLOAD(tb[LWTUNNEL_IP6_DST]),
+				    RTA_DATA(tb[LWTUNNEL_IP6_DST]),
+				    abuf, sizeof(abuf)));
+
+	if (tb[LWTUNNEL_IP6_HOPLIMIT])
+		fprintf(fp, "hoplimit %d ", rta_getattr_u8(tb[LWTUNNEL_IP6_HOPLIMIT]));
+
+	if (tb[LWTUNNEL_IP6_TC])
+		fprintf(fp, "tc %d ", rta_getattr_u8(tb[LWTUNNEL_IP6_TC]));
+}
+
 void lwt_print_encap(FILE *fp, struct rtattr *encap_type,
 			  struct rtattr *encap)
 {
@@ -105,7 +136,7 @@ void lwt_print_encap(FILE *fp, struct rtattr *encap_type,
 
 	et = rta_getattr_u16(encap_type);
 
-	fprintf(fp, " encap %s", format_encap_type(et));
+	fprintf(fp, " encap %s ", format_encap_type(et));
 
 	switch (et) {
 	case LWTUNNEL_ENCAP_MPLS:
@@ -114,6 +145,9 @@ void lwt_print_encap(FILE *fp, struct rtattr *encap_type,
 	case LWTUNNEL_ENCAP_IP:
 		print_encap_ip(fp, encap);
 		break;
+	case LWTUNNEL_ENCAP_IP6:
+		print_encap_ip6(fp, encap);
+		break;
 	}
 }
 
@@ -190,6 +224,58 @@ static int parse_encap_ip(struct rtattr *rta, size_t len, int *argcp, char ***ar
 	return 0;
 }
 
+static int parse_encap_ip6(struct rtattr *rta, size_t len, int *argcp, char ***argvp)
+{
+	int id_ok = 0, dst_ok = 0, tos_ok = 0, ttl_ok = 0;
+	char **argv = *argvp;
+	int argc = *argcp;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "id") == 0) {
+			__u64 id;
+			NEXT_ARG();
+			if (id_ok++)
+				duparg2("id", *argv);
+			if (get_u64(&id, *argv, 0))
+				invarg("\"id\" value is invalid\n", *argv);
+			rta_addattr64(rta, len, LWTUNNEL_IP6_ID, htonll(id));
+		} else if (strcmp(*argv, "dst") == 0) {
+			inet_prefix addr;
+			NEXT_ARG();
+			if (dst_ok++)
+				duparg2("dst", *argv);
+			get_addr(&addr, *argv, AF_INET6);
+			rta_addattr_l(rta, len, LWTUNNEL_IP6_DST, &addr.data, addr.bytelen);
+		} else if (strcmp(*argv, "tc") == 0) {
+			__u32 tc;
+			NEXT_ARG();
+			if (tos_ok++)
+				duparg2("tc", *argv);
+			if (rtnl_dsfield_a2n(&tc, *argv))
+				invarg("\"tc\" value is invalid\n", *argv);
+			rta_addattr8(rta, len, LWTUNNEL_IP6_TC, tc);
+		} else if (strcmp(*argv, "hoplimit") == 0) {
+			__u8 hoplimit;
+			NEXT_ARG();
+			if (ttl_ok++)
+				duparg2("hoplimit", *argv);
+			if (get_u8(&hoplimit, *argv, 0))
+				invarg("\"hoplimit\" value is invalid\n", *argv);
+			rta_addattr8(rta, len, LWTUNNEL_IP6_HOPLIMIT, hoplimit);
+		} else {
+			break;
+		}
+		argc--; argv++;
+	}
+
+	/* argv is currently the first unparsed argument,
+	 * but the lwt_parse_encap() caller will move to the next,
+	 * so step back */
+	*argcp = argc + 1;
+	*argvp = argv - 1;
+
+	return 0;
+}
 
 int lwt_parse_encap(struct rtattr *rta, size_t len, int *argcp, char ***argvp)
 {
@@ -217,6 +303,9 @@ int lwt_parse_encap(struct rtattr *rta, size_t len, int *argcp, char ***argvp)
 	case LWTUNNEL_ENCAP_IP:
 		parse_encap_ip(rta, len, &argc, &argv);
 		break;
+	case LWTUNNEL_ENCAP_IP6:
+		parse_encap_ip6(rta, len, &argc, &argv);
+		break;
 	default:
 		fprintf(stderr, "Error: unsupported encap type\n");
 		break;
-- 
1.8.3.1
