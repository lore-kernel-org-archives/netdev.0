From: Jesse Gross <jesse@kernel.org>
Subject: [PATCH iproute2 1/2] vxlan: Follow kernel defaults for outer UDP checksum.
Date: Fri, 18 Mar 2016 17:51:08 -0700
Message-ID: <1458348669-48437-1-git-send-email-jesse@kernel.org>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:37307 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750748AbcCSAvN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2016 20:51:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On recent kernels, UDP checksum computation has become more efficient and
the default behavior was changed, however, the ip command overrides this
by always specifying a particular behavior.

If the user does not specify that UDP checksums should either be computed
or not then we don't need to send an explicit netlink message - the kernel
can just use its default behavior.

Signed-off-by: Jesse Gross <jesse@kernel.org>
---
 ip/iplink_vxlan.c | 35 +++++++++++++++++++++++++++--------
 1 file changed, 27 insertions(+), 8 deletions(-)

diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index ede8482..be5636f 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -68,8 +68,11 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u32 maxaddr = 0;
 	__u16 dstport = 0;
 	__u8 udpcsum = 0;
+	bool udpcsum_set = false;
 	__u8 udp6zerocsumtx = 0;
+	bool udp6zerocsumtx_set = false;
 	__u8 udp6zerocsumrx = 0;
+	bool udp6zerocsumrx_set = false;
 	__u8 remcsumtx = 0;
 	__u8 remcsumrx = 0;
 	__u8 metadata = 0;
@@ -193,16 +196,22 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			l3miss = 1;
 		} else if (!matches(*argv, "udpcsum")) {
 			udpcsum = 1;
+			udpcsum_set = true;
 		} else if (!matches(*argv, "noudpcsum")) {
 			udpcsum = 0;
+			udpcsum_set = true;
 		} else if (!matches(*argv, "udp6zerocsumtx")) {
 			udp6zerocsumtx = 1;
+			udp6zerocsumtx_set = true;
 		} else if (!matches(*argv, "noudp6zerocsumtx")) {
 			udp6zerocsumtx = 0;
+			udp6zerocsumtx_set = true;
 		} else if (!matches(*argv, "udp6zerocsumrx")) {
 			udp6zerocsumrx = 1;
+			udp6zerocsumrx_set = true;
 		} else if (!matches(*argv, "noudp6zerocsumrx")) {
 			udp6zerocsumrx = 0;
+			udp6zerocsumrx_set = true;
 		} else if (!matches(*argv, "remcsumtx")) {
 			remcsumtx = 1;
 		} else if (!matches(*argv, "noremcsumtx")) {
@@ -277,13 +286,16 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	addattr8(n, 1024, IFLA_VXLAN_RSC, rsc);
 	addattr8(n, 1024, IFLA_VXLAN_L2MISS, l2miss);
 	addattr8(n, 1024, IFLA_VXLAN_L3MISS, l3miss);
-	addattr8(n, 1024, IFLA_VXLAN_UDP_CSUM, udpcsum);
-	addattr8(n, 1024, IFLA_VXLAN_UDP_ZERO_CSUM6_TX, udp6zerocsumtx);
-	addattr8(n, 1024, IFLA_VXLAN_UDP_ZERO_CSUM6_RX, udp6zerocsumrx);
 	addattr8(n, 1024, IFLA_VXLAN_REMCSUM_TX, remcsumtx);
 	addattr8(n, 1024, IFLA_VXLAN_REMCSUM_RX, remcsumrx);
 	addattr8(n, 1024, IFLA_VXLAN_COLLECT_METADATA, metadata);
 
+	if (udpcsum_set)
+		addattr8(n, 1024, IFLA_VXLAN_UDP_CSUM, udpcsum);
+	if (udp6zerocsumtx_set)
+		addattr8(n, 1024, IFLA_VXLAN_UDP_ZERO_CSUM6_TX, udp6zerocsumtx);
+	if (udp6zerocsumrx_set)
+		addattr8(n, 1024, IFLA_VXLAN_UDP_ZERO_CSUM6_RX, udp6zerocsumrx);
 	if (noage)
 		addattr32(n, 1024, IFLA_VXLAN_AGEING, 0);
 	else if (age)
@@ -420,16 +432,23 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	    ((maxaddr = rta_getattr_u32(tb[IFLA_VXLAN_LIMIT])) != 0))
 		    fprintf(f, "maxaddr %u ", maxaddr);
 
-	if (tb[IFLA_VXLAN_UDP_CSUM] && rta_getattr_u8(tb[IFLA_VXLAN_UDP_CSUM]))
+	if (tb[IFLA_VXLAN_UDP_CSUM]) {
+		if (!rta_getattr_u8(tb[IFLA_VXLAN_UDP_CSUM]))
+			fputs("no", f);
 		fputs("udpcsum ", f);
+	}
 
-	if (tb[IFLA_VXLAN_UDP_ZERO_CSUM6_TX] &&
-	    rta_getattr_u8(tb[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]))
+	if (tb[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]) {
+		if (!rta_getattr_u8(tb[IFLA_VXLAN_UDP_ZERO_CSUM6_TX]))
+			fputs("no", f);
 		fputs("udp6zerocsumtx ", f);
+	}
 
-	if (tb[IFLA_VXLAN_UDP_ZERO_CSUM6_RX] &&
-	    rta_getattr_u8(tb[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]))
+	if (tb[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]) {
+		if (!rta_getattr_u8(tb[IFLA_VXLAN_UDP_ZERO_CSUM6_RX]))
+			fputs("no", f);
 		fputs("udp6zerocsumrx ", f);
+	}
 
 	if (tb[IFLA_VXLAN_REMCSUM_TX] &&
 	    rta_getattr_u8(tb[IFLA_VXLAN_REMCSUM_TX]))
-- 
2.5.0
