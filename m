From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH iproute2 net-next v2 2/3] iproute: add support for SRv6 local segment processing
Date: Wed, 9 Aug 2017 17:33:25 +0200
Message-ID: <20170809153326.29599-3-david.lebrun@uclouvain.be>
References: <20170809153326.29599-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:54859 "EHLO
        smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753426AbdHIPdY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 11:33:24 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp6.sgsi.ucl.ac.be (Postfix) with ESMTPS id 19DAC67DD03
        for <netdev@vger.kernel.org>; Wed,  9 Aug 2017 17:33:13 +0200 (CEST)
In-Reply-To: <20170809153326.29599-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the seg6local lightweight tunnel
("ip route add ... encap seg6local ...").

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 ip/iproute.c          |   2 +-
 ip/iproute_lwtunnel.c | 208 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 209 insertions(+), 1 deletion(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index cb695ad..7a37df5 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -100,7 +100,7 @@ static void usage(void)
 	fprintf(stderr, "TIME := NUMBER[s|ms]\n");
 	fprintf(stderr, "BOOL := [1|0]\n");
 	fprintf(stderr, "FEATURES := ecn\n");
-	fprintf(stderr, "ENCAPTYPE := [ mpls | ip | ip6 | seg6 ]\n");
+	fprintf(stderr, "ENCAPTYPE := [ mpls | ip | ip6 | seg6 | seg6local ]\n");
 	fprintf(stderr, "ENCAPHDR := [ MPLSLABEL | SEG6HDR ]\n");
 	fprintf(stderr, "SEG6HDR := [ mode SEGMODE ] segs ADDR1,ADDRi,ADDRn [hmac HMACKEYID] [cleanup]\n");
 	fprintf(stderr, "SEGMODE := [ encap | inline ]\n");
diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
index 16d2584..7dde4b2 100644
--- a/ip/iproute_lwtunnel.c
+++ b/ip/iproute_lwtunnel.c
@@ -29,6 +29,8 @@
 #include <linux/seg6.h>
 #include <linux/seg6_iptunnel.h>
 #include <linux/seg6_hmac.h>
+#include <linux/seg6_local.h>
+#include <net/if.h>
 
 static const char *format_encap_type(int type)
 {
@@ -45,6 +47,8 @@ static const char *format_encap_type(int type)
 		return "bpf";
 	case LWTUNNEL_ENCAP_SEG6:
 		return "seg6";
+	case LWTUNNEL_ENCAP_SEG6_LOCAL:
+		return "seg6local";
 	default:
 		return "unknown";
 	}
@@ -77,6 +81,8 @@ static int read_encap_type(const char *name)
 		return LWTUNNEL_ENCAP_BPF;
 	else if (strcmp(name, "seg6") == 0)
 		return LWTUNNEL_ENCAP_SEG6;
+	else if (strcmp(name, "seg6local") == 0)
+		return LWTUNNEL_ENCAP_SEG6_LOCAL;
 	else if (strcmp(name, "help") == 0)
 		encap_type_usage();
 
@@ -121,6 +127,94 @@ static void print_encap_seg6(FILE *fp, struct rtattr *encap)
 	print_srh(fp, tuninfo->srh);
 }
 
+static const char *seg6_action_names[SEG6_LOCAL_ACTION_MAX + 1] = {
+	[SEG6_LOCAL_ACTION_END]			= "End",
+	[SEG6_LOCAL_ACTION_END_X]		= "End.X",
+	[SEG6_LOCAL_ACTION_END_T]		= "End.T",
+	[SEG6_LOCAL_ACTION_END_DX2]		= "End.DX2",
+	[SEG6_LOCAL_ACTION_END_DX6]		= "End.DX6",
+	[SEG6_LOCAL_ACTION_END_DX4]		= "End.DX4",
+	[SEG6_LOCAL_ACTION_END_DT6]		= "End.DT6",
+	[SEG6_LOCAL_ACTION_END_DT4]		= "End.DT4",
+	[SEG6_LOCAL_ACTION_END_B6]		= "End.B6",
+	[SEG6_LOCAL_ACTION_END_B6_ENCAP]	= "End.B6.Encaps",
+	[SEG6_LOCAL_ACTION_END_BM]		= "End.BM",
+	[SEG6_LOCAL_ACTION_END_S]		= "End.S",
+	[SEG6_LOCAL_ACTION_END_AS]		= "End.AS",
+	[SEG6_LOCAL_ACTION_END_AM]		= "End.AM",
+};
+
+static const char *format_action_type(int action)
+{
+	if (action < 0 || action > SEG6_LOCAL_ACTION_MAX)
+		return "<invalid>";
+
+	return seg6_action_names[action] ?: "<unknown>";
+}
+
+static int read_action_type(const char *name)
+{
+	int i;
+
+	for (i = 0; i < SEG6_LOCAL_ACTION_MAX + 1; i++) {
+		if (!seg6_action_names[i])
+			continue;
+
+		if (strcmp(seg6_action_names[i], name) == 0)
+			return i;
+	}
+
+	return SEG6_LOCAL_ACTION_UNSPEC;
+}
+
+static void print_encap_seg6local(FILE *fp, struct rtattr *encap)
+{
+	struct rtattr *tb[SEG6_LOCAL_MAX + 1];
+	char ifbuf[IFNAMSIZ];
+	int action;
+
+	parse_rtattr_nested(tb, SEG6_LOCAL_MAX, encap);
+
+	if (!tb[SEG6_LOCAL_ACTION])
+		return;
+
+	action = rta_getattr_u32(tb[SEG6_LOCAL_ACTION]);
+
+	fprintf(fp, "action %s ", format_action_type(action));
+
+	if (tb[SEG6_LOCAL_SRH]) {
+		fprintf(fp, "srh ");
+		print_srh(fp, RTA_DATA(tb[SEG6_LOCAL_SRH]));
+	}
+
+	if (tb[SEG6_LOCAL_TABLE])
+		fprintf(fp, "table %u ", rta_getattr_u32(tb[SEG6_LOCAL_TABLE]));
+
+	if (tb[SEG6_LOCAL_NH4]) {
+		fprintf(fp, "nh4 %s ",
+			rt_addr_n2a_rta(AF_INET, tb[SEG6_LOCAL_NH4]));
+	}
+
+	if (tb[SEG6_LOCAL_NH6]) {
+		fprintf(fp, "nh6 %s ",
+			rt_addr_n2a_rta(AF_INET6, tb[SEG6_LOCAL_NH6]));
+	}
+
+	if (tb[SEG6_LOCAL_IIF]) {
+		int iif = rta_getattr_u32(tb[SEG6_LOCAL_IIF]);
+
+		fprintf(fp, "iif %s ",
+			if_indextoname(iif, ifbuf) ?: "<unknown>");
+	}
+
+	if (tb[SEG6_LOCAL_OIF]) {
+		int oif = rta_getattr_u32(tb[SEG6_LOCAL_OIF]);
+
+		fprintf(fp, "oif %s ",
+			if_indextoname(oif, ifbuf) ?: "<unknown>");
+	}
+}
+
 static void print_encap_mpls(FILE *fp, struct rtattr *encap)
 {
 	struct rtattr *tb[MPLS_IPTUNNEL_MAX+1];
@@ -290,6 +384,9 @@ void lwt_print_encap(FILE *fp, struct rtattr *encap_type,
 	case LWTUNNEL_ENCAP_SEG6:
 		print_encap_seg6(fp, encap);
 		break;
+	case LWTUNNEL_ENCAP_SEG6_LOCAL:
+		print_encap_seg6local(fp, encap);
+		break;
 	}
 }
 
@@ -412,6 +509,114 @@ static int parse_encap_seg6(struct rtattr *rta, size_t len, int *argcp,
 	return 0;
 }
 
+static int parse_encap_seg6local(struct rtattr *rta, size_t len, int *argcp,
+				 char ***argvp)
+{
+	int segs_ok = 0, hmac_ok = 0, table_ok = 0, nh4_ok = 0, nh6_ok = 0;
+	int iif_ok = 0, oif_ok = 0, action_ok = 0, srh_ok = 0;
+	__u32 action = 0, table, iif, oif;
+	struct ipv6_sr_hdr *srh;
+	char **argv = *argvp;
+	int argc = *argcp;
+	char segbuf[1024];
+	inet_prefix addr;
+	__u32 hmac = 0;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "action") == 0) {
+			NEXT_ARG();
+			if (action_ok++)
+				duparg2("action", *argv);
+			action = read_action_type(*argv);
+			if (!action)
+				invarg("\"action\" value is invalid\n", *argv);
+			rta_addattr32(rta, len, SEG6_LOCAL_ACTION, action);
+		} else if (strcmp(*argv, "table") == 0) {
+			NEXT_ARG();
+			if (table_ok++)
+				duparg2("table", *argv);
+			get_u32(&table, *argv, 0);
+			rta_addattr32(rta, len, SEG6_LOCAL_TABLE, table);
+		} else if (strcmp(*argv, "nh4") == 0) {
+			NEXT_ARG();
+			if (nh4_ok++)
+				duparg2("nh4", *argv);
+			get_addr(&addr, *argv, AF_INET);
+			rta_addattr_l(rta, len, SEG6_LOCAL_NH4, &addr.data,
+				      addr.bytelen);
+		} else if (strcmp(*argv, "nh6") == 0) {
+			NEXT_ARG();
+			if (nh6_ok++)
+				duparg2("nh6", *argv);
+			get_addr(&addr, *argv, AF_INET6);
+			rta_addattr_l(rta, len, SEG6_LOCAL_NH6, &addr.data,
+				      addr.bytelen);
+		} else if (strcmp(*argv, "iif") == 0) {
+			NEXT_ARG();
+			if (iif_ok++)
+				duparg2("iif", *argv);
+			iif = if_nametoindex(*argv);
+			if (!iif)
+				invarg("\"iif\" interface not found\n", *argv);
+			rta_addattr32(rta, len, SEG6_LOCAL_IIF, iif);
+		} else if (strcmp(*argv, "oif") == 0) {
+			NEXT_ARG();
+			if (oif_ok++)
+				duparg2("oif", *argv);
+			oif = if_nametoindex(*argv);
+			if (!oif)
+				invarg("\"oif\" interface not found\n", *argv);
+			rta_addattr32(rta, len, SEG6_LOCAL_OIF, oif);
+		} else if (strcmp(*argv, "srh") == 0) {
+			NEXT_ARG();
+			if (srh_ok++)
+				duparg2("srh", *argv);
+			if (strcmp(*argv, "segs") != 0)
+				invarg("missing \"segs\" attribute for srh\n",
+					*argv);
+			NEXT_ARG();
+			if (segs_ok++)
+				duparg2("segs", *argv);
+			strncpy(segbuf, *argv, 1024);
+			segbuf[1023] = 0;
+			if (!NEXT_ARG_OK())
+				break;
+			NEXT_ARG();
+			if (strcmp(*argv, "hmac") == 0) {
+				NEXT_ARG();
+				if (hmac_ok++)
+					duparg2("hmac", *argv);
+				get_u32(&hmac, *argv, 0);
+			} else {
+				continue;
+			}
+		} else {
+			break;
+		}
+		argc--; argv++;
+	}
+
+	if (!action) {
+		fprintf(stderr, "Missing action type\n");
+		exit(-1);
+	}
+
+	if (srh_ok) {
+		int srhlen;
+
+		srh = parse_srh(segbuf, hmac,
+				action == SEG6_LOCAL_ACTION_END_B6_ENCAP);
+		srhlen = (srh->hdrlen + 1) << 3;
+		rta_addattr_l(rta, len, SEG6_LOCAL_SRH, srh, srhlen);
+		free(srh);
+	}
+
+	*argcp = argc + 1;
+	*argvp = argv - 1;
+
+	return 0;
+}
+
 static int parse_encap_mpls(struct rtattr *rta, size_t len,
 			    int *argcp, char ***argvp)
 {
@@ -771,6 +976,9 @@ int lwt_parse_encap(struct rtattr *rta, size_t len, int *argcp, char ***argvp)
 	case LWTUNNEL_ENCAP_SEG6:
 		parse_encap_seg6(rta, len, &argc, &argv);
 		break;
+	case LWTUNNEL_ENCAP_SEG6_LOCAL:
+		parse_encap_seg6local(rta, len, &argc, &argv);
+		break;
 	default:
 		fprintf(stderr, "Error: unsupported encap type\n");
 		break;
-- 
2.10.2
