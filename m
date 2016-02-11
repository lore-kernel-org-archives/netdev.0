From: Brian Russell <brussell@brocade.com>
Subject: [PATCH iproute2 net-next] iplink: vxlan: gpe support
Date: Thu, 11 Feb 2016 10:35:12 +0000
Message-ID: <1455186914-8952-2-git-send-email-brussell@brocade.com>
References: <1455186914-8952-1-git-send-email-brussell@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:60731 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750956AbcBKKfe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 05:35:34 -0500
Received: from pps.filterd (m0048192.ppops.net [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u1BASe0Z021796
	for <netdev@vger.kernel.org>; Thu, 11 Feb 2016 02:35:34 -0800
Received: from brmwp-exmb11.corp.brocade.com ([208.47.132.227])
	by mx0b-000f0801.pphosted.com with ESMTP id 20wh08brxu-2
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 11 Feb 2016 02:35:34 -0800
In-Reply-To: <1455186914-8952-1-git-send-email-brussell@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add VXLAN GPE support to ip link

Signed-off-by: Brian Russell <brussell@brocade.com>
---
 include/linux/if_link.h |  1 +
 ip/iplink_vxlan.c       | 21 ++++++++++++++++++---
 man/man8/ip-link.8.in   | 12 +++++++++++-
 3 files changed, 30 insertions(+), 4 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 0331c72..759ea6b 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -454,6 +454,7 @@ enum {
 	IFLA_VXLAN_GBP,
 	IFLA_VXLAN_REMCSUM_NOPARTIAL,
 	IFLA_VXLAN_COLLECT_METADATA,
+	IFLA_VXLAN_GPE,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index ede8482..df749fa 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -31,7 +31,7 @@ static void print_explain(FILE *f)
 	fprintf(f, "                 [ ageing SECONDS ] [ maxaddress NUMBER ]\n");
 	fprintf(f, "                 [ [no]udpcsum ] [ [no]udp6zerocsumtx ] [ [no]udp6zerocsumrx ]\n");
 	fprintf(f, "                 [ [no]remcsumtx ] [ [no]remcsumrx ]\n");
-	fprintf(f, "                 [ [no]external ] [ gbp ]\n");
+	fprintf(f, "                 [ [no]external ] [ gbp | gpe ]\n");
 	fprintf(f, "\n");
 	fprintf(f, "Where: VNI := 0-16777215\n");
 	fprintf(f, "       ADDR := { IP_ADDRESS | any }\n");
@@ -74,6 +74,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u8 remcsumrx = 0;
 	__u8 metadata = 0;
 	__u8 gbp = 0;
+	__u8 gpe = 0;
 	int dst_port_set = 0;
 	struct ifla_vxlan_port_range range = { 0, 0 };
 
@@ -217,6 +218,8 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			metadata = 0;
 		} else if (!matches(*argv, "gbp")) {
 			gbp = 1;
+		} else if (!matches(*argv, "gpe")) {
+			gpe = 1;
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -249,8 +252,9 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 		fprintf(stderr, "vxlan: destination port not specified\n"
 			"Will use Linux kernel default (non-standard value)\n");
 		fprintf(stderr,
-			"Use 'dstport 4789' to get the IANA assigned value\n"
-			"Use 'dstport 0' to get default and quiet this message\n");
+			"Use 'dstport %s' to get the IANA assigned value\n"
+			"Use 'dstport 0' to get default and quiet this message\n",
+			gpe ? "4790" : "4789");
 	}
 
 	addattr32(n, 1024, IFLA_VXLAN_ID, vni);
@@ -296,9 +300,17 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	if (dstport)
 		addattr16(n, 1024, IFLA_VXLAN_PORT, htons(dstport));
 
+	if (gbp && gpe) {
+		fprintf(stderr,
+			"vxlan: both gbp and gpe cannot be specified\n");
+		return -1;
+	}
+
 	if (gbp)
 		addattr_l(n, 1024, IFLA_VXLAN_GBP, NULL, 0);
 
+	if (gpe)
+		addattr_l(n, 1024, IFLA_VXLAN_GPE, NULL, 0);
 
 	return 0;
 }
@@ -445,6 +457,9 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 
 	if (tb[IFLA_VXLAN_GBP])
 		fputs("gbp ", f);
+
+	if (tb[IFLA_VXLAN_GPE])
+		fputs("gpe ", f);
 }
 
 static void vxlan_print_help(struct link_util *lu, int argc, char **argv,
diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 4d32343..2b92e81 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -422,7 +422,7 @@ the following additional arguments are supported:
 ] [
 .BI maxaddress " NUMBER "
 ] [
-.B gbp
+.BR gbp " | " gpe
 ]
 
 .in +8
@@ -554,6 +554,16 @@ Example:
 
 .in -4
 
+.sp
+.B gpe
+- enables the Generic Protocol extension (VXLAN-GPE). This parameter cannot
+be specified with the
+.B gbp
+parameter. Sending packets with encapsulations other than ethernet requires
+that the
+.B remote
+parameter be specified.
+
 .in -8
 
 .TP
-- 
2.1.4
