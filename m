From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH iproute2 2/3] gre: add support for collect metadata flag
Date: Tue, 15 Dec 2015 16:48:26 +0100
Message-ID: <60286413f0d62fed304d1dbc0b309a2a118bc009.1450193891.git.pabeni@redhat.com>
References: <cover.1450193891.git.pabeni@redhat.com>
Cc: netdev@vger.kernel.org, Roopa Prabhu <roopa@cumulusnetworks.com>
To: shemming@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33763 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754147AbbLOPtH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2015 10:49:07 -0500
In-Reply-To: <cover.1450193891.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add support for IFLA_GRE_COLLECT_METADATA via the
'collectmetadata' keyword to the gre link.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 ip/link_gre.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/ip/link_gre.c b/ip/link_gre.c
index 58f416c..8be157f 100644
--- a/ip/link_gre.c
+++ b/ip/link_gre.c
@@ -74,6 +74,7 @@ static int gre_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u16 encapflags = 0;
 	__u16 encapsport = 0;
 	__u16 encapdport = 0;
+	__u8 metadata = 0;
 
 	if (!(n->nlmsg_flags & NLM_F_CREATE)) {
 		memset(&req, 0, sizeof(req));
@@ -148,6 +149,9 @@ get_failed:
 			encapsport = rta_getattr_u16(greinfo[IFLA_GRE_ENCAP_SPORT]);
 		if (greinfo[IFLA_GRE_ENCAP_DPORT])
 			encapdport = rta_getattr_u16(greinfo[IFLA_GRE_ENCAP_DPORT]);
+
+		if (greinfo[IFLA_GRE_COLLECT_METADATA])
+			metadata = 1;
 	}
 
 	while (argc > 0) {
@@ -291,6 +295,8 @@ get_failed:
 			encapflags |= TUNNEL_ENCAP_FLAG_REMCSUM;
 		} else if (strcmp(*argv, "noencap-remcsum") == 0) {
 			encapflags |= ~TUNNEL_ENCAP_FLAG_REMCSUM;
+		} else if (strcmp(*argv, "collectmetadata") == 0) {
+			metadata = 1;
 		} else
 			usage();
 		argc--; argv++;
@@ -325,6 +331,8 @@ get_failed:
 	addattr16(n, 1024, IFLA_GRE_ENCAP_FLAGS, encapflags);
 	addattr16(n, 1024, IFLA_GRE_ENCAP_SPORT, htons(encapsport));
 	addattr16(n, 1024, IFLA_GRE_ENCAP_DPORT, htons(encapdport));
+	if (metadata)
+		addattr_l(n, 1024, IFLA_GRE_COLLECT_METADATA, NULL, 0);
 
 	return 0;
 }
@@ -413,6 +421,9 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (oflags & GRE_CSUM)
 		fputs("ocsum ", f);
 
+	if (tb[IFLA_GRE_COLLECT_METADATA])
+		fputs("collectmetadata ", f);
+
 	if (tb[IFLA_GRE_ENCAP_TYPE] &&
 	    *(__u16 *)RTA_DATA(tb[IFLA_GRE_ENCAP_TYPE]) != TUNNEL_ENCAP_NONE) {
 		__u16 type = rta_getattr_u16(tb[IFLA_GRE_ENCAP_TYPE]);
-- 
1.8.3.1
