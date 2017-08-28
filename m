From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH iproute2 net-next 1/2] iproute: add support for seg6 l2encap mode
Date: Mon, 28 Aug 2017 20:05:24 +0100
Message-ID: <20170828190525.15655-2-david.lebrun@uclouvain.be>
References: <20170828190525.15655-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:40986 "EHLO
        smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751398AbdH1TE5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 15:04:57 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp2.sgsi.ucl.ac.be (Postfix) with ESMTPS id 7ED6067DBE8
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 21:04:47 +0200 (CEST)
In-Reply-To: <20170828190525.15655-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for the L2ENCAP seg6 mode, enabling to encapsulate
L2 frames within SRv6 packets.

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 ip/iproute_lwtunnel.c | 39 ++++++++++++++++++++++++++++-----------
 1 file changed, 28 insertions(+), 11 deletions(-)

diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
index 14294c6..f125670 100644
--- a/ip/iproute_lwtunnel.c
+++ b/ip/iproute_lwtunnel.c
@@ -110,6 +110,30 @@ static void print_srh(FILE *fp, struct ipv6_sr_hdr *srh)
 	}
 }
 
+static const char *format_seg6mode_type(int mode)
+{
+	if (mode == SEG6_IPTUN_MODE_ENCAP)
+		return "encap";
+	else if (mode == SEG6_IPTUN_MODE_INLINE)
+		return "inline";
+	else if (mode == SEG6_IPTUN_MODE_L2ENCAP)
+		return "l2encap";
+
+	return "<unknown>";
+}
+
+static int read_seg6mode_type(const char *mode)
+{
+	if (strcmp(mode, "encap") == 0)
+		return SEG6_IPTUN_MODE_ENCAP;
+	else if (strcmp(mode, "inline") == 0)
+		return SEG6_IPTUN_MODE_INLINE;
+	else if (strcmp(mode, "l2encap") == 0)
+		return SEG6_IPTUN_MODE_L2ENCAP;
+
+	return -1;
+}
+
 static void print_encap_seg6(FILE *fp, struct rtattr *encap)
 {
 	struct rtattr *tb[SEG6_IPTUNNEL_MAX+1];
@@ -121,8 +145,7 @@ static void print_encap_seg6(FILE *fp, struct rtattr *encap)
 		return;
 
 	tuninfo = RTA_DATA(tb[SEG6_IPTUNNEL_SRH]);
-	fprintf(fp, "mode %s ",
-		(tuninfo->mode == SEG6_IPTUN_MODE_ENCAP) ? "encap" : "inline");
+	fprintf(fp, "mode %s ", format_seg6mode_type(tuninfo->mode));
 
 	print_srh(fp, tuninfo->srh);
 }
@@ -457,11 +480,8 @@ static int parse_encap_seg6(struct rtattr *rta, size_t len, int *argcp,
 			NEXT_ARG();
 			if (mode_ok++)
 				duparg2("mode", *argv);
-			if (strcmp(*argv, "encap") == 0)
-				encap = 1;
-			else if (strcmp(*argv, "inline") == 0)
-				encap = 0;
-			else
+			encap = read_seg6mode_type(*argv);
+			if (encap < 0)
 				invarg("\"mode\" value is invalid\n", *argv);
 		} else if (strcmp(*argv, "segs") == 0) {
 			NEXT_ARG();
@@ -490,10 +510,7 @@ static int parse_encap_seg6(struct rtattr *rta, size_t len, int *argcp,
 	tuninfo = malloc(sizeof(*tuninfo) + srhlen);
 	memset(tuninfo, 0, sizeof(*tuninfo) + srhlen);
 
-	if (encap)
-		tuninfo->mode = SEG6_IPTUN_MODE_ENCAP;
-	else
-		tuninfo->mode = SEG6_IPTUN_MODE_INLINE;
+	tuninfo->mode = encap;
 
 	memcpy(tuninfo->srh, srh, srhlen);
 
-- 
2.10.2
