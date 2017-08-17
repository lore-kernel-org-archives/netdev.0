From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH iproute2 json v2 13/27] ip: iplink_geneve.c: add json output support
Date: Thu, 17 Aug 2017 10:36:00 -0700
Message-ID: <20170817173614.54987-14-julien@cumulusnetworks.com>
References: <20170817173614.54987-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f178.google.com ([209.85.128.178]:33935 "EHLO
        mail-wr0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753541AbdHQRlT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 13:41:19 -0400
Received: by mail-wr0-f178.google.com with SMTP id y96so47237272wrc.1
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 10:41:18 -0700 (PDT)
In-Reply-To: <20170817173614.54987-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Schema:
{
    "id": {
        "type": "uint",
        "attr": "IFLA_GENEVE_ID"
    },
    "remote": {
        "type": "string",
        "attr": "IFLA_GENEVE_REMOTE"
    },
    "remote6": {
        "type": "string",
        "attr": "IFLA_GENEVE_REMOTE6"
    },
    "ttl": {
        "type": "int",
        "attr": "IFLA_GENEVE_TTL"
    },
    "tos": {
        "type": "string",
        "attr": "IFLA_GENEVE_TOS"
    },
    "label": {
        "type": "string",
        "attr": "IFLA_GENEVE_LABEL"
    },
    "port": {
        "type": "uint",
        "attr": "IFLA_GENEVE_PORT"
    },
    "collect_metadata": {
        "type": "bool",
        "attr": "IFLA_GENEVE_COLLECT_METADATA"
    },
    "udp_csum": {
        "type": "bool",
        "attr": "IFLA_GENEVE_UDP_CSUM"
    },
    "udp_zero_csum6_tx": {
        "type": "bool",
        "attr": "IFLA_GENEVE_UDP_ZERO_CSUM6_TX"
    },
    "udp_zero_csum6_rx": {
        "type": "bool",
        "attr": "IFLA_GENEVE_UDP_ZERO_CSUM6_RX"
    }
}

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 ip/iplink_geneve.c | 86 +++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 63 insertions(+), 23 deletions(-)

diff --git a/ip/iplink_geneve.c b/ip/iplink_geneve.c
index 594a3e59..f0f1d1c7 100644
--- a/ip/iplink_geneve.c
+++ b/ip/iplink_geneve.c
@@ -237,22 +237,28 @@ static void geneve_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		return;
 
 	vni = rta_getattr_u32(tb[IFLA_GENEVE_ID]);
-	fprintf(f, "id %u ", vni);
+	print_uint(PRINT_ANY, "id", "id %u ", vni);
 
 	if (tb[IFLA_GENEVE_REMOTE]) {
 		__be32 addr = rta_getattr_u32(tb[IFLA_GENEVE_REMOTE]);
 
 		if (addr)
-			fprintf(f, "remote %s ",
-				format_host(AF_INET, 4, &addr));
+			print_string(PRINT_ANY,
+				     "remote",
+				     "remote %s ",
+				     format_host(AF_INET, 4, &addr));
 	} else if (tb[IFLA_GENEVE_REMOTE6]) {
 		struct in6_addr addr;
 
 		memcpy(&addr, RTA_DATA(tb[IFLA_GENEVE_REMOTE6]), sizeof(struct in6_addr));
 		if (!IN6_IS_ADDR_UNSPECIFIED(&addr)) {
 			if (!IN6_IS_ADDR_MULTICAST(&addr))
-				fprintf(f, "remote %s ",
-					format_host(AF_INET6, sizeof(struct in6_addr), &addr));
+				print_string(PRINT_ANY,
+					     "remote6",
+					     "remote %s ",
+					     format_host(AF_INET6,
+							 sizeof(struct in6_addr),
+							 &addr));
 		}
 	}
 
@@ -260,47 +266,81 @@ static void geneve_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		__u8 ttl = rta_getattr_u8(tb[IFLA_GENEVE_TTL]);
 
 		if (ttl)
-			fprintf(f, "ttl %d ", ttl);
+			print_int(PRINT_ANY, "ttl", "ttl %d ", ttl);
 	}
 
 	if (tb[IFLA_GENEVE_TOS] &&
 	    (tos = rta_getattr_u8(tb[IFLA_GENEVE_TOS]))) {
-		if (tos == 1)
-			fprintf(f, "tos inherit ");
-		else
-			fprintf(f, "tos %#x ", tos);
+		if (is_json_context()) {
+			print_0xhex(PRINT_JSON, "tos", "%#x", tos);
+		} else {
+			if (tos == 1) {
+				print_string(PRINT_FP,
+					     "tos",
+					     "tos %s ",
+					     "inherit");
+			} else {
+				fprintf(f, "tos %#x ", tos);
+			}
+		}
 	}
 
 	if (tb[IFLA_GENEVE_LABEL]) {
 		__u32 label = rta_getattr_u32(tb[IFLA_GENEVE_LABEL]);
 
 		if (label)
-			fprintf(f, "flowlabel %#x ", ntohl(label));
+			print_0xhex(PRINT_ANY,
+				    "label",
+				    "flowlabel %#x ",
+				    ntohl(label));
 	}
 
 	if (tb[IFLA_GENEVE_PORT])
-		fprintf(f, "dstport %u ",
-			rta_getattr_be16(tb[IFLA_GENEVE_PORT]));
+		print_uint(PRINT_ANY,
+			   "port",
+			   "dstport %u ",
+			   rta_getattr_be16(tb[IFLA_GENEVE_PORT]));
 
 	if (tb[IFLA_GENEVE_COLLECT_METADATA])
-		fputs("external ", f);
+		print_bool(PRINT_ANY, "collect_metadata", "external ", true);
 
 	if (tb[IFLA_GENEVE_UDP_CSUM]) {
-		if (!rta_getattr_u8(tb[IFLA_GENEVE_UDP_CSUM]))
-			fputs("no", f);
-		fputs("udpcsum ", f);
+		if (is_json_context()) {
+			print_bool(PRINT_JSON,
+				   "udp_csum",
+				   NULL,
+				   rta_getattr_u8(tb[IFLA_GENEVE_UDP_CSUM]));
+		} else {
+			if (!rta_getattr_u8(tb[IFLA_GENEVE_UDP_CSUM]))
+				fputs("no", f);
+			fputs("udpcsum ", f);
+		}
 	}
 
 	if (tb[IFLA_GENEVE_UDP_ZERO_CSUM6_TX]) {
-		if (!rta_getattr_u8(tb[IFLA_GENEVE_UDP_ZERO_CSUM6_TX]))
-			fputs("no", f);
-		fputs("udp6zerocsumtx ", f);
+		if (is_json_context()) {
+			print_bool(PRINT_JSON,
+				   "udp_zero_csum6_tx",
+				   NULL,
+				   rta_getattr_u8(tb[IFLA_GENEVE_UDP_ZERO_CSUM6_TX]));
+		} else {
+			if (!rta_getattr_u8(tb[IFLA_GENEVE_UDP_ZERO_CSUM6_TX]))
+				fputs("no", f);
+			fputs("udp6zerocsumtx ", f);
+		}
 	}
 
 	if (tb[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]) {
-		if (!rta_getattr_u8(tb[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]))
-			fputs("no", f);
-		fputs("udp6zerocsumrx ", f);
+		if (is_json_context()) {
+			print_bool(PRINT_JSON,
+				   "udp_zero_csum6_rx",
+				   NULL,
+				   rta_getattr_u8(tb[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]));
+		} else {
+			if (!rta_getattr_u8(tb[IFLA_GENEVE_UDP_ZERO_CSUM6_RX]))
+				fputs("no", f);
+			fputs("udp6zerocsumrx ", f);
+		}
 	}
 }
 
-- 
2.14.1
