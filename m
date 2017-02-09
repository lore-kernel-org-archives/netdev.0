From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next repost 1/3] tc: flower: provide generic masked u8 parser helper
Date: Thu,  9 Feb 2017 14:48:59 +0100
Message-ID: <1486648141-22955-2-git-send-email-simon.horman@netronome.com>
References: <1486648141-22955-1-git-send-email-simon.horman@netronome.com>
Cc: Jiri Pirko <jiri@resnulli.us>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37900 "EHLO
        mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752033AbdBINuZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 08:50:25 -0500
Received: by mail-wm0-f50.google.com with SMTP id r141so19696069wmg.1
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 05:49:17 -0800 (PST)
In-Reply-To: <1486648141-22955-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Provide generic masked u8 paser helper and use it to parse arp operations.

Also consistently use __u8 rather than uint8_t, in keeping with the
pervasive style in the file.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 tc/f_flower.c | 55 ++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 40 insertions(+), 15 deletions(-)

diff --git a/tc/f_flower.c b/tc/f_flower.c
index 0f2251315975..5554cc05118b 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -309,33 +309,30 @@ static int flower_parse_arp_ip_addr(char *str, __be16 eth_type,
 				      TCA_FLOWER_UNSPEC, TCA_FLOWER_UNSPEC, n);
 }
 
-static int flower_parse_arp_op(char *str, __be16 eth_type,
-			       int op_type, int mask_type,
-			       struct nlmsghdr *n)
+static int flower_parse_u8(char *str, int value_type, int mask_type,
+			   int (*value_from_name)(const char *str,
+						 __u8 *value),
+			   bool (*value_validate)(__u8 value),
+			   struct nlmsghdr *n)
 {
 	char *slash;
 	int ret, err = -1;
-	uint8_t value, mask;
+	__u8 value, mask;
 
 	slash = strchr(str, '/');
 	if (slash)
 		*slash = '\0';
 
-	if (!flower_eth_type_arp(eth_type))
-		goto err;
-
-	if (!strcmp(str, "request")) {
-		value = ARPOP_REQUEST;
-	} else if (!strcmp(str, "reply")) {
-		value = ARPOP_REPLY;
-	} else {
+	ret = value_from_name ? value_from_name(str, &value) : -1;
+	if (ret < 0) {
 		ret = get_u8(&value, str, 10);
 		if (ret)
 			goto err;
-		if (value && value != ARPOP_REQUEST && value != ARPOP_REPLY)
-			goto err;
 	}
 
+	if (value_validate && !value_validate(value))
+		goto err;
+
 	if (slash) {
 		ret = get_u8(&mask, slash + 1, 10);
 		if (ret)
@@ -345,7 +342,7 @@ static int flower_parse_arp_op(char *str, __be16 eth_type,
 		mask = UINT8_MAX;
 	}
 
-	addattr8(n, MAX_MSG, op_type, value);
+	addattr8(n, MAX_MSG, value_type, value);
 	addattr8(n, MAX_MSG, mask_type, mask);
 
 	err = 0;
@@ -355,6 +352,34 @@ err:
 	return err;
 }
 
+static int flower_arp_op_from_name(const char *name, __u8 *op)
+{
+	if (!strcmp(name, "request"))
+		*op = ARPOP_REQUEST;
+	else if (!strcmp(name, "reply"))
+		*op = ARPOP_REPLY;
+	else
+		return -1;
+
+	return 0;
+}
+
+static bool flow_arp_op_validate(__u8 op)
+{
+	return !op || op == ARPOP_REQUEST || op == ARPOP_REPLY;
+}
+
+static int flower_parse_arp_op(char *str, __be16 eth_type,
+			       int op_type, int mask_type,
+			       struct nlmsghdr *n)
+{
+	if (!flower_eth_type_arp(eth_type))
+		return -1;
+
+	return flower_parse_u8(str, op_type, mask_type, flower_arp_op_from_name,
+			       flow_arp_op_validate, n);
+}
+
 static int flower_icmp_attr_type(__be16 eth_type, __u8 ip_proto,
 				 enum flower_icmp_field field)
 {
-- 
2.7.0.rc3.207.g0ac5344
