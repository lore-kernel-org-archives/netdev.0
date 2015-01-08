From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2 v2] iplink: print out addrgenmode attribute
Date: Thu,  8 Jan 2015 09:49:55 +0100
Message-ID: <1420706995-2107-1-git-send-email-jiri@resnulli.us>
Cc: stephen@networkplumber.org, thaller@redhat.com, vadim4j@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:40152 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753420AbbAHIt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 03:49:59 -0500
Received: by mail-wi0-f174.google.com with SMTP id h11so1761339wiw.1
        for <netdev@vger.kernel.org>; Thu, 08 Jan 2015 00:49:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

addrgenmode is currently write only by ip. So display this information
if provided by kernel as well.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>

---
v1->v2:
-rebased on current master (instead of net-next branch)
---
 ip/ipaddress.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 28dfe8c..d8bda30 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -255,6 +255,29 @@ static void print_linktype(FILE *fp, struct rtattr *tb)
 	}
 }
 
+static void print_af_spec(FILE *fp, struct rtattr *af_spec_attr)
+{
+	struct rtattr *inet6_attr;
+	struct rtattr *tb[IFLA_INET6_MAX + 1];
+
+	inet6_attr = parse_rtattr_one_nested(AF_INET6, af_spec_attr);
+	if (!inet6_attr)
+		return;
+
+	parse_rtattr_nested(tb, IFLA_INET6_MAX, inet6_attr);
+
+	if (tb[IFLA_INET6_ADDR_GEN_MODE]) {
+		switch (rta_getattr_u8(tb[IFLA_INET6_ADDR_GEN_MODE])) {
+		case IN6_ADDR_GEN_MODE_EUI64:
+			fprintf(fp, "addrgenmode eui64 ");
+			break;
+		case IN6_ADDR_GEN_MODE_NONE:
+			fprintf(fp, "addrgenmode none ");
+			break;
+		}
+	}
+}
+
 static void print_vfinfo(FILE *fp, struct rtattr *vfinfo)
 {
 	struct ifla_vf_mac *vf_mac;
@@ -658,6 +681,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
 	if (tb[IFLA_LINKINFO] && show_details)
 		print_linktype(fp, tb[IFLA_LINKINFO]);
 
+	if (do_link && tb[IFLA_AF_SPEC] && show_details)
+		print_af_spec(fp, tb[IFLA_AF_SPEC]);
+
 	if ((do_link || show_details) && tb[IFLA_IFALIAS]) {
 		fprintf(fp, "%s    alias %s", _SL_,
 			rta_getattr_str(tb[IFLA_IFALIAS]));
-- 
1.9.3
