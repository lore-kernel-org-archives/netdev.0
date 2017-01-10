From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH iproute2 3/3] iproute: add support for SR-IPv6 lwtunnel encapsulation
Date: Tue, 10 Jan 2017 17:41:26 +0100
Message-ID: <1484066486-22152-4-git-send-email-david.lebrun@uclouvain.be>
References: <1484066486-22152-1-git-send-email-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:52176 "EHLO
        smtp1.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764056AbdAJQks (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 11:40:48 -0500
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp1.sgsi.ucl.ac.be (Postfix) with ESMTPS id 2E1A467DA6C
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 17:40:35 +0100 (CET)
In-Reply-To: <1484066486-22152-1-git-send-email-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for SEG6 encapsulation type
("ip route add ... encap seg6 ...").

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 ip/iproute.c          |   6 +-
 ip/iproute_lwtunnel.c | 160 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 164 insertions(+), 2 deletions(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index e433de8..a102e33 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -98,8 +98,10 @@ static void usage(void)
 	fprintf(stderr, "TIME := NUMBER[s|ms]\n");
 	fprintf(stderr, "BOOL := [1|0]\n");
 	fprintf(stderr, "FEATURES := ecn\n");
-	fprintf(stderr, "ENCAPTYPE := [ mpls | ip | ip6 ]\n");
-	fprintf(stderr, "ENCAPHDR := [ MPLSLABEL ]\n");
+	fprintf(stderr, "ENCAPTYPE := [ mpls | ip | ip6 | seg6 ]\n");
+	fprintf(stderr, "ENCAPHDR := [ MPLSLABEL | SEG6HDR ]\n");
+	fprintf(stderr, "SEG6HDR := [ mode SEGMODE ] segs ADDR1,ADDRi,ADDRn [hmac HMACKEYID] [cleanup]\n");
+	fprintf(stderr, "SEGMODE := [ encap | inline ]\n");
 	exit(-1);
 }
 
diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
index 1a92cec..3ee6dcc 100644
--- a/ip/iproute_lwtunnel.c
+++ b/ip/iproute_lwtunnel.c
@@ -26,6 +26,10 @@
 #include "iproute_lwtunnel.h"
 #include "bpf_util.h"
 
+#include <linux/seg6.h>
+#include <linux/seg6_iptunnel.h>
+#include <linux/seg6_hmac.h>
+
 static const char *format_encap_type(int type)
 {
 	switch (type) {
@@ -39,6 +43,8 @@ static const char *format_encap_type(int type)
 		return "ila";
 	case LWTUNNEL_ENCAP_BPF:
 		return "bpf";
+	case LWTUNNEL_ENCAP_SEG6:
+		return "seg6";
 	default:
 		return "unknown";
 	}
@@ -69,12 +75,51 @@ static int read_encap_type(const char *name)
 		return LWTUNNEL_ENCAP_ILA;
 	else if (strcmp(name, "bpf") == 0)
 		return LWTUNNEL_ENCAP_BPF;
+	else if (strcmp(name, "seg6") == 0)
+		return LWTUNNEL_ENCAP_SEG6;
 	else if (strcmp(name, "help") == 0)
 		encap_type_usage();
 
 	return LWTUNNEL_ENCAP_NONE;
 }
 
+static void print_encap_seg6(FILE *fp, struct rtattr *encap)
+{
+	struct rtattr *tb[SEG6_IPTUNNEL_MAX+1];
+	struct seg6_iptunnel_encap *tuninfo;
+	struct ipv6_sr_hdr *srh;
+	int i;
+
+	parse_rtattr_nested(tb, SEG6_IPTUNNEL_MAX, encap);
+
+	if (!tb[SEG6_IPTUNNEL_SRH])
+	return;
+
+	tuninfo = RTA_DATA(tb[SEG6_IPTUNNEL_SRH]);
+	fprintf(fp, "mode %s ",
+		(tuninfo->mode == SEG6_IPTUN_MODE_ENCAP) ? "encap" : "inline");
+
+	srh = tuninfo->srh;
+
+	fprintf(fp, "segs %d [ ", srh->first_segment + 1);
+
+	for (i = srh->first_segment; i >= 0; i--)
+		fprintf(fp, "%s ",
+			rt_addr_n2a(AF_INET6, 16, &srh->segments[i]));
+
+	fprintf(fp, "] ");
+
+	if (sr_has_cleanup(srh))
+
+	if (sr_has_hmac(srh)) {
+		unsigned int offset = ((srh->hdrlen + 1) << 3) - 40;
+		struct sr6_tlv_hmac *tlv;
+
+		tlv = (struct sr6_tlv_hmac *)((char *)srh + offset);
+		fprintf(fp, "hmac 0x%X ", ntohl(tlv->hmackeyid));
+	}
+}
+
 static void print_encap_mpls(FILE *fp, struct rtattr *encap)
 {
 	struct rtattr *tb[MPLS_IPTUNNEL_MAX+1];
@@ -238,9 +283,121 @@ void lwt_print_encap(FILE *fp, struct rtattr *encap_type,
 	case LWTUNNEL_ENCAP_BPF:
 		print_encap_bpf(fp, encap);
 		break;
+	case LWTUNNEL_ENCAP_SEG6:
+		print_encap_seg6(fp, encap);
+		break;
 	}
 }
 
+static int parse_encap_seg6(struct rtattr *rta, size_t len, int *argcp,
+			    char ***argvp)
+{
+	int mode_ok = 0, segs_ok = 0, cleanup_ok = 0, hmac_ok = 0;
+	struct seg6_iptunnel_encap *tuninfo;
+	struct ipv6_sr_hdr *srh;
+	char **argv = *argvp;
+	char segbuf[1024];
+	int argc = *argcp;
+	__u8 cleanup = 0;
+	int encap = -1;
+	__u32 hmac = 0;
+	int nsegs = 0;
+	int srhlen;
+	char *s;
+	int i;
+
+	while (argc > 0) {
+		if (strcmp(*argv, "mode") == 0) {
+			NEXT_ARG();
+			if (mode_ok++)
+				duparg2("mode", *argv);
+			if (strcmp(*argv, "encap") == 0)
+				encap = 1;
+			else if (strcmp(*argv, "inline") == 0)
+				encap = 0;
+			else
+				invarg("\"mode\" value is invalid\n", *argv);
+		} else if (strcmp(*argv, "segs") == 0) {
+			NEXT_ARG();
+			if (segs_ok++)
+				duparg2("segs", *argv);
+			if (encap == -1)
+				invarg("\"segs\" provided before \"mode\"\n",
+				       *argv);
+
+			strncpy(segbuf, *argv, 1024);
+			segbuf[1023] = 0;
+		} else if (strcmp(*argv, "cleanup") == 0) {
+			if (cleanup_ok++)
+				duparg2("cleanup", *argv);
+			cleanup = 1;
+		} else if (strcmp(*argv, "hmac") == 0) {
+			NEXT_ARG();
+			if (hmac_ok++)
+				duparg2("hmac", *argv);
+			get_u32(&hmac, *argv, 0);
+		} else {
+			break;
+		}
+		argc--; argv++;
+	}
+
+	s = segbuf;
+	for (i = 0; *s; *s++ == ',' ? i++ : *s);
+	nsegs = i + 1;
+
+	if (!encap)
+		nsegs++;
+
+	srhlen = 8 + 16*nsegs;
+
+	if (hmac)
+		srhlen += 40;
+
+	tuninfo = malloc(sizeof(*tuninfo) + srhlen);
+	memset(tuninfo, 0, sizeof(*tuninfo) + srhlen);
+
+	if (encap)
+		tuninfo->mode = SEG6_IPTUN_MODE_ENCAP;
+	else
+		tuninfo->mode = SEG6_IPTUN_MODE_INLINE;
+
+	srh = tuninfo->srh;
+	srh->hdrlen = (srhlen >> 3) - 1;
+	srh->type = 4;
+	srh->segments_left = nsegs - 1;
+	srh->first_segment = nsegs - 1;
+
+	if (cleanup)
+		srh->flag_1 |= SR6_FLAG1_CLEANUP;
+	if (hmac)
+		srh->flag_1 |= SR6_FLAG1_HMAC;
+
+	i = srh->first_segment;
+	for (s = strtok(segbuf, ","); s; s = strtok(NULL, ",")) {
+		inet_get_addr(s, NULL, &srh->segments[i]);
+		i--;
+	}
+
+	if (hmac) {
+		struct sr6_tlv_hmac *tlv;
+
+		tlv = (struct sr6_tlv_hmac *)((char *)srh + srhlen - 40);
+		tlv->tlvhdr.type = SR6_TLV_HMAC;
+		tlv->tlvhdr.len = 38;
+		tlv->hmackeyid = htonl(hmac);
+	}
+
+	rta_addattr_l(rta, len, SEG6_IPTUNNEL_SRH, tuninfo,
+		      sizeof(*tuninfo) + srhlen);
+	free(tuninfo);
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
@@ -573,6 +730,9 @@ int lwt_parse_encap(struct rtattr *rta, size_t len, int *argcp, char ***argvp)
 		if (parse_encap_bpf(rta, len, &argc, &argv) < 0)
 			exit(-1);
 		break;
+	case LWTUNNEL_ENCAP_SEG6:
+		parse_encap_seg6(rta, len, &argc, &argv);
+		break;
 	default:
 		fprintf(stderr, "Error: unsupported encap type\n");
 		break;
-- 
2.7.3
