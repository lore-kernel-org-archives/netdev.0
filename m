From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH iproute v3 1/5] ila: Support for checksum neutral translation
Date: Tue, 9 Aug 2016 14:41:35 -0700
Message-ID: <1470778899-2854697-2-git-send-email-tom@herbertland.com>
References: <1470778899-2854697-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, Tom Herbert <tom@herbertland.com>
To: <stephen@networkplumber.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:27987 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932564AbcHIVlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 17:41:50 -0400
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.11/8.16.0.11) with SMTP id u79LZfic000372
	for <netdev@vger.kernel.org>; Tue, 9 Aug 2016 14:41:49 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 24nbcqssmw-2
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 14:41:49 -0700
Received: from facebook.com (2401:db00:21:6030:face:0:92:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 11e9496e5e7a11e6866a24be0593f280-f66f6af0 for <netdev@vger.kernel.org>;	Tue,
 09 Aug 2016 14:41:46 -0700
In-Reply-To: <1470778899-2854697-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add configuration of ila LWT tunnels for checksum mode including
checksum neutral translation.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 ip/iproute_lwtunnel.c | 58 +++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 56 insertions(+), 2 deletions(-)

diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
index bdbb15d..b656143 100644
--- a/ip/iproute_lwtunnel.c
+++ b/ip/iproute_lwtunnel.c
@@ -90,6 +90,32 @@ static void print_encap_ip(FILE *fp, struct rtattr *encap)
 		fprintf(fp, "tos %d ", rta_getattr_u8(tb[LWTUNNEL_IP_TOS]));
 }
 
+static char *ila_csum_mode2name(__u8 csum_mode)
+{
+	switch (csum_mode) {
+	case ILA_CSUM_ADJUST_TRANSPORT:
+		return "adj-transport";
+	case ILA_CSUM_NEUTRAL_MAP:
+		return "neutral-map";
+	case ILA_CSUM_NO_ACTION:
+		return "no-action";
+	default:
+		return "unknown";
+	}
+}
+
+static __u8 ila_csum_name2mode(char *name)
+{
+	if (strcmp(name, "adj-transport") == 0)
+		return ILA_CSUM_ADJUST_TRANSPORT;
+	else if (strcmp(name, "neutral-map") == 0)
+		return ILA_CSUM_NEUTRAL_MAP;
+	else if (strcmp(name, "no-action") == 0)
+		return ILA_CSUM_NO_ACTION;
+	else
+		return -1;
+}
+
 static void print_encap_ila(FILE *fp, struct rtattr *encap)
 {
 	struct rtattr *tb[ILA_ATTR_MAX+1];
@@ -103,6 +129,10 @@ static void print_encap_ila(FILE *fp, struct rtattr *encap)
 			   abuf, sizeof(abuf));
 		fprintf(fp, " %s ", abuf);
 	}
+
+	if (tb[ILA_ATTR_CSUM_MODE])
+		fprintf(fp, " csum-mode %s ",
+			ila_csum_mode2name(rta_getattr_u8(tb[ILA_ATTR_CSUM_MODE])));
 }
 
 static void print_encap_ip6(FILE *fp, struct rtattr *encap)
@@ -246,10 +276,34 @@ static int parse_encap_ila(struct rtattr *rta, size_t len,
 		exit(1);
 	}
 
+	argc--; argv++;
+
 	rta_addattr64(rta, 1024, ILA_ATTR_LOCATOR, locator);
 
-	*argcp = argc;
-	*argvp = argv;
+	while (argc > 0) {
+		if (strcmp(*argv, "csum-mode") == 0) {
+			__u8 csum_mode;
+
+			NEXT_ARG();
+
+			csum_mode = ila_csum_name2mode(*argv);
+			if (csum_mode < 0)
+				invarg("\"csum-mode\" value is invalid\n", *argv);
+
+			rta_addattr8(rta, 1024, ILA_ATTR_CSUM_MODE, csum_mode);
+
+			argc--; argv++;
+		} else {
+			break;
+		}
+	}
+
+	/* argv is currently the first unparsed argument,
+	 * but the lwt_parse_encap() caller will move to the next,
+	 * so step back
+	 */
+	*argcp = argc + 1;
+	*argvp = argv - 1;
 
 	return 0;
 }
-- 
2.8.0.rc2
