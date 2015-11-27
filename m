From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH iproute] vxlan: Add support for remote checksum offload
Date: Fri, 27 Nov 2015 10:23:43 -0800
Message-ID: <1448648623-3336620-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>, Tom Herbert <tom@herbertland.com>
To: <shemming@brocade.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:34787 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754961AbbK0SX6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2015 13:23:58 -0500
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.15.0.59/8.15.0.59) with SMTP id tARINYXJ011824
	for <netdev@vger.kernel.org>; Fri, 27 Nov 2015 10:23:58 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0089730.ppops.net with ESMTP id 1ye8t5u8yk-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 27 Nov 2015 10:23:58 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 048e009e953411e5b5d60002c992ebde-679f6230 for <netdev@vger.kernel.org>;	Fri,
 27 Nov 2015 10:23:55 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support to remote checksum checksum offload
to VXLAN. This patch adds remcsumtx and remcsumrx to ip vxlan
configuration to enable remote checksum offload for transmit
and receive on the VXLAN tunnel.

https://tools.ietf.org/html/draft-herbert-vxlan-rco-00

Example:

ip link add name vxlan0 type vxlan id 42 group 239.1.1.1 dev eth0 \
    udpcsum remcsumtx remcsumrx

Testing:

Ran single netperf over mlnx4 to illustrate the effest:

- Without RCO (UDP csum set to zero)
  4335.99 Mbps
- With RCO enabled
  7661.81 Mbps

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 ip/iplink_vxlan.c | 21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 473ff97..db29bf0 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -30,6 +30,7 @@ static void print_explain(FILE *f)
 	fprintf(f, "                 [ [no]l2miss ] [ [no]l3miss ]\n");
 	fprintf(f, "                 [ ageing SECONDS ] [ maxaddress NUMBER ]\n");
 	fprintf(f, "                 [ [no]udpcsum ] [ [no]udp6zerocsumtx ] [ [no]udp6zerocsumrx ]\n");
+	fprintf(f, "                 [ [no]remcsumtx ] [ [no]remcsumrx ]\n");
 	fprintf(f, "                 [ gbp ]\n");
 	fprintf(f, "\n");
 	fprintf(f, "Where: VNI := 0-16777215\n");
@@ -69,6 +70,8 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u8 udpcsum = 0;
 	__u8 udp6zerocsumtx = 0;
 	__u8 udp6zerocsumrx = 0;
+	__u8 remcsumtx = 0;
+	__u8 remcsumrx = 0;
 	__u8 gbp = 0;
 	int dst_port_set = 0;
 	struct ifla_vxlan_port_range range = { 0, 0 };
@@ -199,6 +202,14 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			udp6zerocsumrx = 1;
 		} else if (!matches(*argv, "noudp6zerocsumrx")) {
 			udp6zerocsumrx = 0;
+		} else if (!matches(*argv, "remcsumtx")) {
+			remcsumtx = 1;
+		} else if (!matches(*argv, "noremcsumtx")) {
+			remcsumtx = 0;
+		} else if (!matches(*argv, "remcsumrx")) {
+			remcsumrx = 1;
+		} else if (!matches(*argv, "noremcsumrx")) {
+			remcsumrx = 0;
 		} else if (!matches(*argv, "gbp")) {
 			gbp = 1;
 		} else if (matches(*argv, "help") == 0) {
@@ -259,6 +270,8 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	addattr8(n, 1024, IFLA_VXLAN_UDP_CSUM, udpcsum);
 	addattr8(n, 1024, IFLA_VXLAN_UDP_ZERO_CSUM6_TX, udp6zerocsumtx);
 	addattr8(n, 1024, IFLA_VXLAN_UDP_ZERO_CSUM6_RX, udp6zerocsumrx);
+	addattr8(n, 1024, IFLA_VXLAN_REMCSUM_TX, remcsumtx);
+	addattr8(n, 1024, IFLA_VXLAN_REMCSUM_RX, remcsumrx);
 
 	if (noage)
 		addattr32(n, 1024, IFLA_VXLAN_AGEING, 0);
@@ -407,6 +420,14 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	    rta_getattr_u8(tb[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]))
 		fputs("udp6zerocsumrx ", f);
 
+	if (tb[IFLA_VXLAN_REMCSUM_TX] &&
+	    rta_getattr_u8(tb[IFLA_VXLAN_REMCSUM_TX]))
+		fputs("remcsumtx ", f);
+
+	if (tb[IFLA_VXLAN_REMCSUM_RX] &&
+	    rta_getattr_u8(tb[IFLA_VXLAN_REMCSUM_RX]))
+		fputs("remcsumrx ", f);
+
 	if (tb[IFLA_VXLAN_GBP])
 		fputs("gbp ", f);
 }
-- 
2.4.6
