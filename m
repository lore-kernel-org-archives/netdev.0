From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH iproute2 net-next 1/3] iproute: add helper functions for SRH processing
Date: Wed, 9 Aug 2017 15:16:59 +0200
Message-ID: <20170809131701.21304-2-david.lebrun@uclouvain.be>
References: <20170809131701.21304-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:38202 "EHLO
        smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752050AbdHINRX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 09:17:23 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp5.sgsi.ucl.ac.be (Postfix) with ESMTPS id D106967DBDC
        for <netdev@vger.kernel.org>; Wed,  9 Aug 2017 15:17:03 +0200 (CEST)
In-Reply-To: <20170809131701.21304-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds two helper functions to print and parse
Segment Routing Headers.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 ip/iproute_lwtunnel.c | 124 +++++++++++++++++++++++++++++---------------------
 1 file changed, 72 insertions(+), 52 deletions(-)

diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
index 5c0c7d1..16d2584 100644
--- a/ip/iproute_lwtunnel.c
+++ b/ip/iproute_lwtunnel.c
@@ -83,24 +83,10 @@ static int read_encap_type(const char *name)
 	return LWTUNNEL_ENCAP_NONE;
 }
 
-static void print_encap_seg6(FILE *fp, struct rtattr *encap)
+static void print_srh(FILE *fp, struct ipv6_sr_hdr *srh)
 {
-	struct rtattr *tb[SEG6_IPTUNNEL_MAX+1];
-	struct seg6_iptunnel_encap *tuninfo;
-	struct ipv6_sr_hdr *srh;
 	int i;
 
-	parse_rtattr_nested(tb, SEG6_IPTUNNEL_MAX, encap);
-
-	if (!tb[SEG6_IPTUNNEL_SRH])
-		return;
-
-	tuninfo = RTA_DATA(tb[SEG6_IPTUNNEL_SRH]);
-	fprintf(fp, "mode %s ",
-		(tuninfo->mode == SEG6_IPTUN_MODE_ENCAP) ? "encap" : "inline");
-
-	srh = tuninfo->srh;
-
 	fprintf(fp, "segs %d [ ", srh->first_segment + 1);
 
 	for (i = srh->first_segment; i >= 0; i--)
@@ -118,6 +104,23 @@ static void print_encap_seg6(FILE *fp, struct rtattr *encap)
 	}
 }
 
+static void print_encap_seg6(FILE *fp, struct rtattr *encap)
+{
+	struct rtattr *tb[SEG6_IPTUNNEL_MAX+1];
+	struct seg6_iptunnel_encap *tuninfo;
+
+	parse_rtattr_nested(tb, SEG6_IPTUNNEL_MAX, encap);
+
+	if (!tb[SEG6_IPTUNNEL_SRH])
+		return;
+
+	tuninfo = RTA_DATA(tb[SEG6_IPTUNNEL_SRH]);
+	fprintf(fp, "mode %s ",
+		(tuninfo->mode == SEG6_IPTUN_MODE_ENCAP) ? "encap" : "inline");
+
+	print_srh(fp, tuninfo->srh);
+}
+
 static void print_encap_mpls(FILE *fp, struct rtattr *encap)
 {
 	struct rtattr *tb[MPLS_IPTUNNEL_MAX+1];
@@ -290,6 +293,55 @@ void lwt_print_encap(FILE *fp, struct rtattr *encap_type,
 	}
 }
 
+static struct ipv6_sr_hdr *parse_srh(char *segbuf, int hmac, bool encap)
+{
+	struct ipv6_sr_hdr *srh;
+	int nsegs = 0;
+	int srhlen;
+	char *s;
+	int i;
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
+	srh = malloc(srhlen);
+	memset(srh, 0, srhlen);
+
+	srh->hdrlen = (srhlen >> 3) - 1;
+	srh->type = 4;
+	srh->segments_left = nsegs - 1;
+	srh->first_segment = nsegs - 1;
+
+	if (hmac)
+		srh->flags |= SR6_FLAG1_HMAC;
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
+	return srh;
+}
+
 static int parse_encap_seg6(struct rtattr *rta, size_t len, int *argcp,
 			    char ***argvp)
 {
@@ -301,10 +353,7 @@ static int parse_encap_seg6(struct rtattr *rta, size_t len, int *argcp,
 	int argc = *argcp;
 	int encap = -1;
 	__u32 hmac = 0;
-	int nsegs = 0;
 	int srhlen;
-	char *s;
-	int i;
 
 	while (argc > 0) {
 		if (strcmp(*argv, "mode") == 0) {
@@ -338,17 +387,8 @@ static int parse_encap_seg6(struct rtattr *rta, size_t len, int *argcp,
 		argc--; argv++;
 	}
 
-	s = segbuf;
-	for (i = 0; *s; *s++ == ',' ? i++ : *s);
-	nsegs = i + 1;
-
-	if (!encap)
-		nsegs++;
-
-	srhlen = 8 + 16*nsegs;
-
-	if (hmac)
-		srhlen += 40;
+	srh = parse_srh(segbuf, hmac, encap);
+	srhlen = (srh->hdrlen + 1) << 3;
 
 	tuninfo = malloc(sizeof(*tuninfo) + srhlen);
 	memset(tuninfo, 0, sizeof(*tuninfo) + srhlen);
@@ -358,33 +398,13 @@ static int parse_encap_seg6(struct rtattr *rta, size_t len, int *argcp,
 	else
 		tuninfo->mode = SEG6_IPTUN_MODE_INLINE;
 
-	srh = tuninfo->srh;
-	srh->hdrlen = (srhlen >> 3) - 1;
-	srh->type = 4;
-	srh->segments_left = nsegs - 1;
-	srh->first_segment = nsegs - 1;
-
-	if (hmac)
-		srh->flags |= SR6_FLAG1_HMAC;
-
-	i = srh->first_segment;
-	for (s = strtok(segbuf, ","); s; s = strtok(NULL, ",")) {
-		inet_get_addr(s, NULL, &srh->segments[i]);
-		i--;
-	}
-
-	if (hmac) {
-		struct sr6_tlv_hmac *tlv;
-
-		tlv = (struct sr6_tlv_hmac *)((char *)srh + srhlen - 40);
-		tlv->tlvhdr.type = SR6_TLV_HMAC;
-		tlv->tlvhdr.len = 38;
-		tlv->hmackeyid = htonl(hmac);
-	}
+	memcpy(tuninfo->srh, srh, srhlen);
 
 	rta_addattr_l(rta, len, SEG6_IPTUNNEL_SRH, tuninfo,
 		      sizeof(*tuninfo) + srhlen);
+
 	free(tuninfo);
+	free(srh);
 
 	*argcp = argc + 1;
 	*argvp = argv - 1;
-- 
2.10.2
