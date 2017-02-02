From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next 4/7] tc: flower: provide generic masked u8 print helper
Date: Thu,  2 Feb 2017 11:38:37 +0100
Message-ID: <1486031920-10784-5-git-send-email-simon.horman@netronome.com>
References: <1486031920-10784-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36596 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750970AbdBBKi6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 05:38:58 -0500
Received: by mail-wm0-f41.google.com with SMTP id c85so83751205wmi.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 02:38:57 -0800 (PST)
In-Reply-To: <1486031920-10784-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide generic masked u8 print helper and use it to print arp operations.

Also:
* Make name parameter of arp op print helper const.
* Consistently use __u8 rather than uint8_t, in keeping with the
  pervasive style in the file.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 tc/f_flower.c | 44 +++++++++++++++++++++++++++++++++-----------
 1 file changed, 33 insertions(+), 11 deletions(-)

diff --git a/tc/f_flower.c b/tc/f_flower.c
index 5554cc05118b..6a0bedcc4d5d 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -352,6 +352,18 @@ err:
 	return err;
 }
 
+static const char *flower_print_arp_op_to_name(__u8 op)
+{
+	switch (op) {
+	case ARPOP_REQUEST:
+		return "request";
+	case ARPOP_REPLY:
+		return "reply";
+	default:
+		return NULL;
+	}
+}
+
 static int flower_arp_op_from_name(const char *name, __u8 *op)
 {
 	if (!strcmp(name, "request"))
@@ -993,31 +1005,41 @@ static void flower_print_icmp(FILE *f, char *name, struct rtattr *attr)
 		fprintf(f, "\n  %s %d", name, rta_getattr_u8(attr));
 }
 
-static void flower_print_arp_op(FILE *f, char *name,
-				struct rtattr *op_attr,
-				struct rtattr *mask_attr)
+static void flower_print_masked_u8(FILE *f, const char *name,
+				   struct rtattr *attr,
+				   struct rtattr *mask_attr,
+				   const char *(*value_to_str)(__u8 value))
 {
-	uint8_t op, mask;
+	const char *value_str = NULL;
+	__u8 value, mask;
 
-	if (!op_attr)
+	if (!attr)
 		return;
 
-	op = rta_getattr_u8(op_attr);
+	value = rta_getattr_u8(attr);
 	mask = mask_attr ? rta_getattr_u8(mask_attr) : UINT8_MAX;
+	if (mask == UINT8_MAX && value_to_str)
+		value_str = value_to_str(value);
 
 	fprintf(f, "\n  %s ", name);
 
-	if (mask == UINT8_MAX && op == ARPOP_REQUEST)
-		fprintf(f, "request");
-	else if (mask == UINT8_MAX && op == ARPOP_REPLY)
-		fprintf(f, "reply");
+	if (value_str)
+		fputs(value_str, f);
 	else
-		fprintf(f, "%d", op);
+		fprintf(f, "%d", value);
 
 	if (mask != UINT8_MAX)
 		fprintf(f, "/%d", mask);
 }
 
+static void flower_print_arp_op(FILE *f, const char *name,
+				struct rtattr *op_attr,
+				struct rtattr *mask_attr)
+{
+	flower_print_masked_u8(f, name, op_attr, mask_attr,
+			       flower_print_arp_op_to_name);
+}
+
 static int flower_print_opt(struct filter_util *qu, FILE *f,
 			    struct rtattr *opt, __u32 handle)
 {
-- 
2.7.0.rc3.207.g0ac5344
