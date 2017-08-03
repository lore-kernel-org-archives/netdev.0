From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH 19/27] ip: ipmacsec.c: add json output support
Date: Thu,  3 Aug 2017 17:55:07 +0200
Message-ID: <20170803155515.99226-20-julien@cumulusnetworks.com>
References: <20170803155515.99226-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36193 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751940AbdHCPz6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 11:55:58 -0400
Received: by mail-wm0-f52.google.com with SMTP id t201so19081072wmt.1
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 08:55:57 -0700 (PDT)
In-Reply-To: <20170803155515.99226-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Schema
{
    "sci": {
        "type": "string",
        "attr": "IFLA_MACSEC_SCI"
    },
    "protect": {
        "type": "string",
        "attr": "IFLA_MACSEC_PROTECT"
    },
    "cipher_suite": {
        "type": "string",
        "attr": "IFLA_MACSEC_CIPHER_SUITE"
    },
    "icv_len": {
        "type": "uint",
        "attr": "IFLA_MACSEC_ICV_LEN"
    },
    "encoding_sa": {
        "type": "uint",
        "attr": "IFLA_MACSEC_ENCODING_SA"
    },
    "validation": {
        "type": "string",
        "attr": "IFLA_MACSEC_VALIDATION"
    },
    "encrypt": {
        "type": "string",
        "attr": "IFLA_MACSEC_ENCRYPT"
    },
    "inc_sci": {
        "type": "string",
        "attr": "IFLA_MACSEC_INC_SCI"
    },
    "es": {
        "type": "string",
        "attr": "IFLA_MACSEC_ES"
    },
    "scb": {
        "type": "string",
        "attr": "IFLA_MACSEC_SCB"
    },
    "replay_protect": {
        "type": "string",
        "attr": "IFLA_MACSEC_REPLAY_PROTECT"
    },
    "window": {
        "type": "int",
        "attr": ""
    }
}

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 ip/ipmacsec.c | 84 ++++++++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 66 insertions(+), 18 deletions(-)

diff --git a/ip/ipmacsec.c b/ip/ipmacsec.c
index aa89a00f..ecc371a5 100644
--- a/ip/ipmacsec.c
+++ b/ip/ipmacsec.c
@@ -561,9 +561,14 @@ static int validate_secy_dump(struct rtattr **attrs)
 static void print_flag(FILE *f, struct rtattr *attrs[], const char *desc,
 		       int field)
 {
-	if (attrs[field])
-		fprintf(f, "%s %s ", desc,
-			values_on_off[!!rta_getattr_u8(attrs[field])]);
+	if (attrs[field]) {
+		const char *v = values_on_off[!!rta_getattr_u8(attrs[field])];
+
+		if (is_json_context())
+			print_string(PRINT_JSON, desc, NULL, v);
+		else
+			fprintf(f, "%s %s ", desc, v);
+	}
 }
 
 #define DEFAULT_CIPHER_NAME "GCM-AES-128"
@@ -1017,8 +1022,16 @@ static void macsec_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		return;
 
 	if (tb[IFLA_MACSEC_SCI]) {
-		fprintf(f, "sci %016llx ",
-			ntohll(rta_getattr_u64(tb[IFLA_MACSEC_SCI])));
+		if (is_json_context()) {
+			SPRINT_BUF(b1);
+
+			snprintf(b1, sizeof(b1), "%016llx",
+				 ntohll(rta_getattr_u64(tb[IFLA_MACSEC_SCI])));
+			print_string(PRINT_JSON, "sci", NULL, b1);
+		} else {
+			fprintf(f, "sci %016llx ",
+				ntohll(rta_getattr_u64(tb[IFLA_MACSEC_SCI])));
+		}
 	}
 
 	print_flag(f, tb, "protect", IFLA_MACSEC_PROTECT);
@@ -1026,35 +1039,70 @@ static void macsec_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_MACSEC_CIPHER_SUITE]) {
 		__u64 csid = rta_getattr_u64(tb[IFLA_MACSEC_CIPHER_SUITE]);
 
-		fprintf(f, "cipher %s ", cs_id_to_name(csid));
+		print_string(PRINT_ANY,
+			     "cipher_suite",
+			     "cipher %s ",
+			     cs_id_to_name(csid));
 	}
 
 	if (tb[IFLA_MACSEC_ICV_LEN]) {
-		fprintf(f, "icvlen %hhu ",
-			rta_getattr_u8(tb[IFLA_MACSEC_ICV_LEN]));
+		if (is_json_context()) {
+			char b2[4];
+
+			snprintf(b2, sizeof(b2), "%hhu",
+				 rta_getattr_u8(tb[IFLA_MACSEC_ICV_LEN]));
+			print_uint(PRINT_JSON, "icv_len", NULL, atoi(b2));
+		} else {
+			fprintf(f, "icvlen %hhu ",
+				rta_getattr_u8(tb[IFLA_MACSEC_ICV_LEN]));
+		}
 	}
 
 	if (tb[IFLA_MACSEC_ENCODING_SA]) {
-		fprintf(f, "encodingsa %hhu ",
-			rta_getattr_u8(tb[IFLA_MACSEC_ENCODING_SA]));
+		if (is_json_context()) {
+			char b2[4];
+
+			snprintf(b2, sizeof(b2), "%hhu",
+				 rta_getattr_u8(tb[IFLA_MACSEC_ENCODING_SA]));
+			print_uint(PRINT_JSON, "encoding_sa", NULL, atoi(b2));
+		} else {
+			fprintf(f, "encodingsa %hhu ",
+				rta_getattr_u8(tb[IFLA_MACSEC_ENCODING_SA]));
+		}
 	}
 
 	if (tb[IFLA_MACSEC_VALIDATION]) {
 		__u8 val = rta_getattr_u8(tb[IFLA_MACSEC_VALIDATION]);
 
-		fprintf(f, "validate %s ", VALIDATE_STR[val]);
+		print_string(PRINT_ANY,
+			     "validation",
+			     "validate %s ",
+			     VALIDATE_STR[val]);
+	}
+
+	const char *inc_sci, *es, *replay;
+
+	if (is_json_context()) {
+		inc_sci = "inc_sci";
+		replay = "replay_protect";
+		es = "es";
+	} else {
+		inc_sci = "send_sci";
+		es = "end_station";
+		replay = "replay";
 	}
 
 	print_flag(f, tb, "encrypt", IFLA_MACSEC_ENCRYPT);
-	print_flag(f, tb, "send_sci", IFLA_MACSEC_INC_SCI);
-	print_flag(f, tb, "end_station", IFLA_MACSEC_ES);
+	print_flag(f, tb, inc_sci, IFLA_MACSEC_INC_SCI);
+	print_flag(f, tb, es, IFLA_MACSEC_ES);
 	print_flag(f, tb, "scb", IFLA_MACSEC_SCB);
+	print_flag(f, tb, replay, IFLA_MACSEC_REPLAY_PROTECT);
 
-	print_flag(f, tb, "replay", IFLA_MACSEC_REPLAY_PROTECT);
-	if (tb[IFLA_MACSEC_WINDOW]) {
-		fprintf(f, "window %d ",
-			rta_getattr_u32(tb[IFLA_MACSEC_WINDOW]));
-	}
+	if (tb[IFLA_MACSEC_WINDOW])
+		print_int(PRINT_ANY,
+			  "window",
+			  "window %d ",
+			  rta_getattr_u32(tb[IFLA_MACSEC_WINDOW]));
 }
 
 static bool check_txsc_flags(bool es, bool scb, bool sci)
-- 
2.13.3
