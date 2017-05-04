From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: [PATCH iproute2] vxlan: Add support for modifying vxlan device attributes
Date: Thu,  4 May 2017 14:46:34 -0700
Message-ID: <1493934394-26317-1-git-send-email-girish.moodalbail@oracle.com>
Cc: <netdev@vger.kernel.org>
To: <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27190 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751351AbdEDVzS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 17:55:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ability to change vxlan device attributes was added to kernel through
commit 8bcdc4f3a20b ("vxlan: add changelink support"), however one
cannot do the same through ip(8) command.  Changing the allowed vxlan
device attributes using 'ip link set dev <vxlan_name> type vxlan
<allowed_attributes>' currently fails with 'operation not supported'
error.  This failure is due to the incorrect rtnetlink message
construction for the 'ip link set' operation.

The vxlan_parse_opt() callback function is called for parsing options
for both 'ip link add' and 'ip link set'. For the 'add' case, we pass
down default values for those attributes that were not provided as CLI
options. However, for the 'set' case we should be only passing down the
explicitly provided attributes and not any other (default) attributes.

Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
---
 ip/iplink_vxlan.c | 73 ++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 59 insertions(+), 14 deletions(-)

diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index b4ebb13..c8959aa 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -72,16 +72,25 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	struct in6_addr daddr6 = IN6ADDR_ANY_INIT;
 	unsigned int link = 0;
 	__u8 tos = 0;
+	bool tos_set = false;
 	__u8 ttl = 0;
+	bool ttl_set = false;
 	__u32 label = 0;
+	bool label_set = false;
 	__u8 learning = 1;
+	bool learning_set = false;
 	__u8 proxy = 0;
+	bool proxy_set = false;
 	__u8 rsc = 0;
+	bool rsc_set = false;
 	__u8 l2miss = 0;
+	bool l2miss_set = false;
 	__u8 l3miss = 0;
+	bool l3miss_set = false;
 	__u8 noage = 0;
 	__u32 age = 0;
 	__u32 maxaddr = 0;
+	bool maxaddr_set = false;
 	__u16 dstport = 0;
 	__u8 udpcsum = 0;
 	bool udpcsum_set = false;
@@ -90,12 +99,17 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u8 udp6zerocsumrx = 0;
 	bool udp6zerocsumrx_set = false;
 	__u8 remcsumtx = 0;
+	bool remcsumtx_set = false;
 	__u8 remcsumrx = 0;
+	bool remcsumrx_set = false;
 	__u8 metadata = 0;
+	bool metadata_set = false;
 	__u8 gbp = 0;
 	__u8 gpe = 0;
 	int dst_port_set = 0;
 	struct ifla_vxlan_port_range range = { 0, 0 };
+	bool set_op = (n->nlmsg_type == RTM_NEWLINK &&
+		       !(n->nlmsg_flags & NLM_F_CREATE));
 
 	while (argc > 0) {
 		if (!matches(*argv, "id") ||
@@ -152,6 +166,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 					invarg("TTL must be <= 255", *argv);
 				ttl = uval;
 			}
+			ttl_set = true;
 		} else if (!matches(*argv, "tos") ||
 			   !matches(*argv, "dsfield")) {
 			__u32 uval;
@@ -163,6 +178,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 				tos = uval;
 			} else
 				tos = 1;
+			tos_set = true;
 		} else if (!matches(*argv, "label") ||
 			   !matches(*argv, "flowlabel")) {
 			__u32 uval;
@@ -172,6 +188,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			    (uval & ~LABEL_MAX_MASK))
 				invarg("invalid flowlabel", *argv);
 			label = htonl(uval);
+			label_set = true;
 		} else if (!matches(*argv, "ageing")) {
 			NEXT_ARG();
 			if (strcmp(*argv, "none") == 0)
@@ -184,6 +201,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 				maxaddr = 0;
 			else if (get_u32(&maxaddr, *argv, 0))
 				invarg("max addresses", *argv);
+			maxaddr_set = true;
 		} else if (!matches(*argv, "port") ||
 			   !matches(*argv, "srcport")) {
 			NEXT_ARG();
@@ -199,24 +217,34 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			dst_port_set = 1;
 		} else if (!matches(*argv, "nolearning")) {
 			learning = 0;
+			learning_set = true;
 		} else if (!matches(*argv, "learning")) {
 			learning = 1;
+			learning_set = true;
 		} else if (!matches(*argv, "noproxy")) {
 			proxy = 0;
+			proxy_set = true;
 		} else if (!matches(*argv, "proxy")) {
 			proxy = 1;
+			proxy_set = true;
 		} else if (!matches(*argv, "norsc")) {
 			rsc = 0;
+			rsc_set = true;
 		} else if (!matches(*argv, "rsc")) {
 			rsc = 1;
+			rsc_set = true;
 		} else if (!matches(*argv, "nol2miss")) {
 			l2miss = 0;
+			l2miss_set = true;
 		} else if (!matches(*argv, "l2miss")) {
 			l2miss = 1;
+			l2miss_set = true;
 		} else if (!matches(*argv, "nol3miss")) {
 			l3miss = 0;
+			l3miss_set = true;
 		} else if (!matches(*argv, "l3miss")) {
 			l3miss = 1;
+			l3miss_set = true;
 		} else if (!matches(*argv, "udpcsum")) {
 			udpcsum = 1;
 			udpcsum_set = true;
@@ -237,17 +265,24 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			udp6zerocsumrx_set = true;
 		} else if (!matches(*argv, "remcsumtx")) {
 			remcsumtx = 1;
+			remcsumtx_set = true;
 		} else if (!matches(*argv, "noremcsumtx")) {
 			remcsumtx = 0;
+			remcsumtx_set = true;
 		} else if (!matches(*argv, "remcsumrx")) {
 			remcsumrx = 1;
+			remcsumrx_set = true;
 		} else if (!matches(*argv, "noremcsumrx")) {
 			remcsumrx = 0;
+			remcsumrx_set = true;
 		} else if (!matches(*argv, "external")) {
 			metadata = 1;
 			learning = 0;
+			metadata_set = true;
+			learning_set = true;
 		} else if (!matches(*argv, "noexternal")) {
 			metadata = 0;
+			metadata_set = true;
 		} else if (!matches(*argv, "gbp")) {
 			gbp = 1;
 		} else if (!matches(*argv, "gpe")) {
@@ -287,7 +322,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 
 	if (!dst_port_set && gpe) {
 		dstport = 4790;
-	} else if (!dst_port_set) {
+	} else if (!dst_port_set && !set_op) {
 		fprintf(stderr, "vxlan: destination port not specified\n"
 			"Will use Linux kernel default (non-standard value)\n");
 		fprintf(stderr,
@@ -316,18 +351,28 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 
 	if (link)
 		addattr32(n, 1024, IFLA_VXLAN_LINK, link);
-	addattr32(n, 1024, IFLA_VXLAN_LABEL, label);
-	addattr8(n, 1024, IFLA_VXLAN_TTL, ttl);
-	addattr8(n, 1024, IFLA_VXLAN_TOS, tos);
-	addattr8(n, 1024, IFLA_VXLAN_LEARNING, learning);
-	addattr8(n, 1024, IFLA_VXLAN_PROXY, proxy);
-	addattr8(n, 1024, IFLA_VXLAN_RSC, rsc);
-	addattr8(n, 1024, IFLA_VXLAN_L2MISS, l2miss);
-	addattr8(n, 1024, IFLA_VXLAN_L3MISS, l3miss);
-	addattr8(n, 1024, IFLA_VXLAN_REMCSUM_TX, remcsumtx);
-	addattr8(n, 1024, IFLA_VXLAN_REMCSUM_RX, remcsumrx);
-	addattr8(n, 1024, IFLA_VXLAN_COLLECT_METADATA, metadata);
-
+	if (label_set)
+		addattr32(n, 1024, IFLA_VXLAN_LABEL, label);
+	if (ttl_set)
+		addattr8(n, 1024, IFLA_VXLAN_TTL, ttl);
+	if (tos_set)
+		addattr8(n, 1024, IFLA_VXLAN_TOS, tos);
+	if (!set_op || learning_set)
+		addattr8(n, 1024, IFLA_VXLAN_LEARNING, learning);
+	if (proxy_set)
+		addattr8(n, 1024, IFLA_VXLAN_PROXY, proxy);
+	if (rsc_set)
+		addattr8(n, 1024, IFLA_VXLAN_RSC, rsc);
+	if (l2miss_set)
+		addattr8(n, 1024, IFLA_VXLAN_L2MISS, l2miss);
+	if (l3miss_set)
+		addattr8(n, 1024, IFLA_VXLAN_L3MISS, l3miss);
+	if (remcsumtx_set)
+		addattr8(n, 1024, IFLA_VXLAN_REMCSUM_TX, remcsumtx);
+	if (remcsumrx_set)
+		addattr8(n, 1024, IFLA_VXLAN_REMCSUM_RX, remcsumrx);
+	if (metadata_set)
+		addattr8(n, 1024, IFLA_VXLAN_COLLECT_METADATA, metadata);
 	if (udpcsum_set)
 		addattr8(n, 1024, IFLA_VXLAN_UDP_CSUM, udpcsum);
 	if (udp6zerocsumtx_set)
@@ -338,7 +383,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 		addattr32(n, 1024, IFLA_VXLAN_AGEING, 0);
 	else if (age)
 		addattr32(n, 1024, IFLA_VXLAN_AGEING, age);
-	if (maxaddr)
+	if (maxaddr_set)
 		addattr32(n, 1024, IFLA_VXLAN_LIMIT, maxaddr);
 	if (range.low || range.high)
 		addattr_l(n, 1024, IFLA_VXLAN_PORT_RANGE,
-- 
1.8.3.1
