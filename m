From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: [PATCH iproute2 v2 1/1] vxlan: Add support for modifying vxlan device attributes
Date: Sat,  6 May 2017 11:37:43 -0700
Message-ID: <1494095863-21916-2-git-send-email-girish.moodalbail@oracle.com>
References: <1494095863-21916-1-git-send-email-girish.moodalbail@oracle.com>
Cc: <netdev@vger.kernel.org>
To: <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39048 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751836AbdEFSqm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 6 May 2017 14:46:42 -0400
In-Reply-To: <1494095863-21916-1-git-send-email-girish.moodalbail@oracle.com>
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
 ip/iplink_vxlan.c | 251 +++++++++++++++++++++++++++++++-----------------------
 1 file changed, 143 insertions(+), 108 deletions(-)

diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index b4ebb13..2bd619d 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -21,6 +21,8 @@
 #include "utils.h"
 #include "ip_common.h"
 
+#define VXLAN_ATTRSET(attrs, type) (((attrs) & (1L << (type))) != 0)
+
 static void print_explain(FILE *f)
 {
 	fprintf(f,
@@ -59,54 +61,50 @@ static void explain(void)
 	print_explain(stderr);
 }
 
+static void check_duparg(__u64 *attrs, int type, const char *key,
+			 const char *argv)
+{
+	if (!VXLAN_ATTRSET(*attrs, type)) {
+		*attrs |= (1L << type);
+		return;
+	}
+	duparg2(key, argv);
+}
+
 static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			  struct nlmsghdr *n)
 {
 	__u32 vni = 0;
-	int vni_set = 0;
-	__u32 saddr = 0;
 	__u32 gaddr = 0;
 	__u32 daddr = 0;
-	struct in6_addr saddr6 = IN6ADDR_ANY_INIT;
 	struct in6_addr gaddr6 = IN6ADDR_ANY_INIT;
 	struct in6_addr daddr6 = IN6ADDR_ANY_INIT;
-	unsigned int link = 0;
-	__u8 tos = 0;
-	__u8 ttl = 0;
-	__u32 label = 0;
 	__u8 learning = 1;
-	__u8 proxy = 0;
-	__u8 rsc = 0;
-	__u8 l2miss = 0;
-	__u8 l3miss = 0;
-	__u8 noage = 0;
-	__u32 age = 0;
-	__u32 maxaddr = 0;
 	__u16 dstport = 0;
-	__u8 udpcsum = 0;
-	bool udpcsum_set = false;
-	__u8 udp6zerocsumtx = 0;
-	bool udp6zerocsumtx_set = false;
-	__u8 udp6zerocsumrx = 0;
-	bool udp6zerocsumrx_set = false;
-	__u8 remcsumtx = 0;
-	__u8 remcsumrx = 0;
 	__u8 metadata = 0;
-	__u8 gbp = 0;
-	__u8 gpe = 0;
-	int dst_port_set = 0;
-	struct ifla_vxlan_port_range range = { 0, 0 };
+	__u64 attrs = 0;
+	bool set_op = (n->nlmsg_type == RTM_NEWLINK &&
+		       !(n->nlmsg_flags & NLM_F_CREATE));
 
 	while (argc > 0) {
 		if (!matches(*argv, "id") ||
 		    !matches(*argv, "vni")) {
+			/* We will add ID attribute outside of the loop since we
+			 * need to consider metadata information as well.
+			 */
 			NEXT_ARG();
+			check_duparg(&attrs, IFLA_VXLAN_ID, "id", *argv);
 			if (get_u32(&vni, *argv, 0) ||
 			    vni >= 1u << 24)
 				invarg("invalid id", *argv);
-			vni_set = 1;
 		} else if (!matches(*argv, "group")) {
+			if (daddr || !IN6_IS_ADDR_UNSPECIFIED(&daddr6)) {
+				fprintf(stderr, "vxlan: both group and remote");
+				fprintf(stderr, " cannot be specified\n");
+				return -1;
+			}
 			NEXT_ARG();
+			check_duparg(&attrs, IFLA_VXLAN_GROUP, "group", *argv);
 			if (!inet_get_addr(*argv, &gaddr, &gaddr6)) {
 				fprintf(stderr, "Invalid address \"%s\"\n", *argv);
 				return -1;
@@ -114,7 +112,13 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			if (!IN6_IS_ADDR_MULTICAST(&gaddr6) && !IN_MULTICAST(ntohl(gaddr)))
 				invarg("invalid group address", *argv);
 		} else if (!matches(*argv, "remote")) {
+			if (gaddr || !IN6_IS_ADDR_UNSPECIFIED(&gaddr6)) {
+				fprintf(stderr, "vxlan: both group and remote");
+				fprintf(stderr, " cannot be specified\n");
+				return -1;
+			}
 			NEXT_ARG();
+			check_duparg(&attrs, IFLA_VXLAN_GROUP, "remote", *argv);
 			if (!inet_get_addr(*argv, &daddr, &daddr6)) {
 				fprintf(stderr, "Invalid address \"%s\"\n", *argv);
 				return -1;
@@ -122,7 +126,11 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			if (IN6_IS_ADDR_MULTICAST(&daddr6) || IN_MULTICAST(ntohl(daddr)))
 				invarg("invalid remote address", *argv);
 		} else if (!matches(*argv, "local")) {
+			__u32 saddr = 0;
+			struct in6_addr saddr6 = IN6ADDR_ANY_INIT;
+
 			NEXT_ARG();
+			check_duparg(&attrs, IFLA_VXLAN_LOCAL, "local", *argv);
 			if (strcmp(*argv, "any")) {
 				if (!inet_get_addr(*argv, &saddr, &saddr6)) {
 					fprintf(stderr, "Invalid address \"%s\"\n", *argv);
@@ -132,19 +140,31 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 
 			if (IN_MULTICAST(ntohl(saddr)) || IN6_IS_ADDR_MULTICAST(&saddr6))
 				invarg("invalid local address", *argv);
+
+			if (saddr)
+				addattr_l(n, 1024, IFLA_VXLAN_LOCAL, &saddr, 4);
+			else if (!IN6_IS_ADDR_UNSPECIFIED(&saddr6))
+				addattr_l(n, 1024, IFLA_VXLAN_LOCAL6, &saddr6,
+					  sizeof(struct in6_addr));
 		} else if (!matches(*argv, "dev")) {
+			unsigned int link;
+
 			NEXT_ARG();
+			check_duparg(&attrs, IFLA_VXLAN_LINK, "dev", *argv);
 			link = if_nametoindex(*argv);
 			if (link == 0) {
 				fprintf(stderr, "Cannot find device \"%s\"\n",
 					*argv);
 				exit(-1);
 			}
+			addattr32(n, 1024, IFLA_VXLAN_LINK, link);
 		} else if (!matches(*argv, "ttl") ||
 			   !matches(*argv, "hoplimit")) {
 			unsigned int uval;
+			__u8 ttl = 0;
 
 			NEXT_ARG();
+			check_duparg(&attrs, IFLA_VXLAN_TTL, "ttl", *argv);
 			if (strcmp(*argv, "inherit") != 0) {
 				if (get_unsigned(&uval, *argv, 0))
 					invarg("invalid TTL", *argv);
@@ -152,106 +172,163 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 					invarg("TTL must be <= 255", *argv);
 				ttl = uval;
 			}
+			addattr8(n, 1024, IFLA_VXLAN_TTL, ttl);
 		} else if (!matches(*argv, "tos") ||
 			   !matches(*argv, "dsfield")) {
 			__u32 uval;
+			__u8 tos;
 
 			NEXT_ARG();
+			check_duparg(&attrs, IFLA_VXLAN_TOS, "tos", *argv);
 			if (strcmp(*argv, "inherit") != 0) {
 				if (rtnl_dsfield_a2n(&uval, *argv))
 					invarg("bad TOS value", *argv);
 				tos = uval;
 			} else
 				tos = 1;
+			addattr8(n, 1024, IFLA_VXLAN_TOS, tos);
 		} else if (!matches(*argv, "label") ||
 			   !matches(*argv, "flowlabel")) {
 			__u32 uval;
 
 			NEXT_ARG();
+			check_duparg(&attrs, IFLA_VXLAN_LABEL, "flowlabel",
+				     *argv);
 			if (get_u32(&uval, *argv, 0) ||
 			    (uval & ~LABEL_MAX_MASK))
 				invarg("invalid flowlabel", *argv);
-			label = htonl(uval);
+			addattr32(n, 1024, IFLA_VXLAN_LABEL, htonl(uval));
 		} else if (!matches(*argv, "ageing")) {
+			__u32 age;
+
 			NEXT_ARG();
+			check_duparg(&attrs, IFLA_VXLAN_AGEING, "ageing",
+				     *argv);
 			if (strcmp(*argv, "none") == 0)
-				noage = 1;
+				age = 0;
 			else if (get_u32(&age, *argv, 0))
 				invarg("ageing timer", *argv);
+			addattr32(n, 1024, IFLA_VXLAN_AGEING, age);
 		} else if (!matches(*argv, "maxaddress")) {
+			__u32 maxaddr;
+
 			NEXT_ARG();
+			check_duparg(&attrs, IFLA_VXLAN_LIMIT,
+				     "maxaddress", *argv);
 			if (strcmp(*argv, "unlimited") == 0)
 				maxaddr = 0;
 			else if (get_u32(&maxaddr, *argv, 0))
 				invarg("max addresses", *argv);
+			addattr32(n, 1024, IFLA_VXLAN_LIMIT, maxaddr);
 		} else if (!matches(*argv, "port") ||
 			   !matches(*argv, "srcport")) {
+			struct ifla_vxlan_port_range range = { 0, 0 };
+
 			NEXT_ARG();
+			check_duparg(&attrs, IFLA_VXLAN_PORT_RANGE, "srcport",
+				     *argv);
 			if (get_be16(&range.low, *argv, 0))
 				invarg("min port", *argv);
 			NEXT_ARG();
 			if (get_be16(&range.high, *argv, 0))
 				invarg("max port", *argv);
+			if (range.low || range.high) {
+				addattr_l(n, 1024, IFLA_VXLAN_PORT_RANGE,
+					  &range, sizeof(range));
+			}
 		} else if (!matches(*argv, "dstport")) {
 			NEXT_ARG();
+			check_duparg(&attrs, IFLA_VXLAN_PORT, "dstport", *argv);
 			if (get_u16(&dstport, *argv, 0))
 				invarg("dst port", *argv);
-			dst_port_set = 1;
 		} else if (!matches(*argv, "nolearning")) {
+			check_duparg(&attrs, IFLA_VXLAN_LEARNING, *argv, *argv);
 			learning = 0;
 		} else if (!matches(*argv, "learning")) {
+			check_duparg(&attrs, IFLA_VXLAN_LEARNING, *argv, *argv);
 			learning = 1;
 		} else if (!matches(*argv, "noproxy")) {
-			proxy = 0;
+			check_duparg(&attrs, IFLA_VXLAN_PROXY, *argv, *argv);
+			addattr8(n, 1024, IFLA_VXLAN_PROXY, 0);
 		} else if (!matches(*argv, "proxy")) {
-			proxy = 1;
+			check_duparg(&attrs, IFLA_VXLAN_PROXY, *argv, *argv);
+			addattr8(n, 1024, IFLA_VXLAN_PROXY, 1);
 		} else if (!matches(*argv, "norsc")) {
-			rsc = 0;
+			check_duparg(&attrs, IFLA_VXLAN_RSC, *argv, *argv);
+			addattr8(n, 1024, IFLA_VXLAN_RSC, 0);
 		} else if (!matches(*argv, "rsc")) {
-			rsc = 1;
+			check_duparg(&attrs, IFLA_VXLAN_RSC, *argv, *argv);
+			addattr8(n, 1024, IFLA_VXLAN_RSC, 1);
 		} else if (!matches(*argv, "nol2miss")) {
-			l2miss = 0;
+			check_duparg(&attrs, IFLA_VXLAN_L2MISS, *argv, *argv);
+			addattr8(n, 1024, IFLA_VXLAN_L2MISS, 0);
 		} else if (!matches(*argv, "l2miss")) {
-			l2miss = 1;
+			check_duparg(&attrs, IFLA_VXLAN_L2MISS, *argv, *argv);
+			addattr8(n, 1024, IFLA_VXLAN_L2MISS, 1);
 		} else if (!matches(*argv, "nol3miss")) {
-			l3miss = 0;
+			check_duparg(&attrs, IFLA_VXLAN_L3MISS, *argv, *argv);
+			addattr8(n, 1024, IFLA_VXLAN_L3MISS, 0);
 		} else if (!matches(*argv, "l3miss")) {
-			l3miss = 1;
+			check_duparg(&attrs, IFLA_VXLAN_L3MISS, *argv, *argv);
+			addattr8(n, 1024, IFLA_VXLAN_L3MISS, 1);
 		} else if (!matches(*argv, "udpcsum")) {
-			udpcsum = 1;
-			udpcsum_set = true;
+			check_duparg(&attrs, IFLA_VXLAN_UDP_CSUM, *argv, *argv);
+			addattr8(n, 1024, IFLA_VXLAN_UDP_CSUM, 1);
 		} else if (!matches(*argv, "noudpcsum")) {
-			udpcsum = 0;
-			udpcsum_set = true;
+			check_duparg(&attrs, IFLA_VXLAN_UDP_CSUM, *argv, *argv);
+			addattr8(n, 1024, IFLA_VXLAN_UDP_CSUM, 0);
 		} else if (!matches(*argv, "udp6zerocsumtx")) {
-			udp6zerocsumtx = 1;
-			udp6zerocsumtx_set = true;
+			check_duparg(&attrs, IFLA_VXLAN_UDP_ZERO_CSUM6_TX,
+				     *argv, *argv);
+			addattr8(n, 1024, IFLA_VXLAN_UDP_ZERO_CSUM6_TX, 1);
 		} else if (!matches(*argv, "noudp6zerocsumtx")) {
-			udp6zerocsumtx = 0;
-			udp6zerocsumtx_set = true;
+			check_duparg(&attrs, IFLA_VXLAN_UDP_ZERO_CSUM6_TX,
+				     *argv, *argv);
+			addattr8(n, 1024, IFLA_VXLAN_UDP_ZERO_CSUM6_TX, 0);
 		} else if (!matches(*argv, "udp6zerocsumrx")) {
-			udp6zerocsumrx = 1;
-			udp6zerocsumrx_set = true;
+			check_duparg(&attrs, IFLA_VXLAN_UDP_ZERO_CSUM6_RX,
+				     *argv, *argv);
+			addattr8(n, 1024, IFLA_VXLAN_UDP_ZERO_CSUM6_RX, 1);
 		} else if (!matches(*argv, "noudp6zerocsumrx")) {
-			udp6zerocsumrx = 0;
-			udp6zerocsumrx_set = true;
+			check_duparg(&attrs, IFLA_VXLAN_UDP_ZERO_CSUM6_RX,
+				     *argv, *argv);
+			addattr8(n, 1024, IFLA_VXLAN_UDP_ZERO_CSUM6_RX, 0);
 		} else if (!matches(*argv, "remcsumtx")) {
-			remcsumtx = 1;
+			check_duparg(&attrs, IFLA_VXLAN_REMCSUM_TX,
+				     *argv, *argv);
+			addattr8(n, 1024, IFLA_VXLAN_REMCSUM_TX, 1);
 		} else if (!matches(*argv, "noremcsumtx")) {
-			remcsumtx = 0;
+			check_duparg(&attrs, IFLA_VXLAN_REMCSUM_TX,
+				     *argv, *argv);
+			addattr8(n, 1024, IFLA_VXLAN_REMCSUM_TX, 0);
 		} else if (!matches(*argv, "remcsumrx")) {
-			remcsumrx = 1;
+			check_duparg(&attrs, IFLA_VXLAN_REMCSUM_RX,
+				     *argv, *argv);
+			addattr8(n, 1024, IFLA_VXLAN_REMCSUM_RX, 1);
 		} else if (!matches(*argv, "noremcsumrx")) {
-			remcsumrx = 0;
+			check_duparg(&attrs, IFLA_VXLAN_REMCSUM_RX,
+				     *argv, *argv);
+			addattr8(n, 1024, IFLA_VXLAN_REMCSUM_RX, 0);
 		} else if (!matches(*argv, "external")) {
+			check_duparg(&attrs, IFLA_VXLAN_COLLECT_METADATA,
+				     *argv, *argv);
 			metadata = 1;
 			learning = 0;
+			/* we will add LEARNING attribute outside of the loop */
+			addattr8(n, 1024, IFLA_VXLAN_COLLECT_METADATA,
+				 metadata);
 		} else if (!matches(*argv, "noexternal")) {
+			check_duparg(&attrs, IFLA_VXLAN_COLLECT_METADATA,
+				     *argv, *argv);
 			metadata = 0;
+			addattr8(n, 1024, IFLA_VXLAN_COLLECT_METADATA,
+				 metadata);
 		} else if (!matches(*argv, "gbp")) {
-			gbp = 1;
+			check_duparg(&attrs, IFLA_VXLAN_GBP, *argv, *argv);
+			addattr_l(n, 1024, IFLA_VXLAN_GBP, NULL, 0);
 		} else if (!matches(*argv, "gpe")) {
-			gpe = 1;
+			check_duparg(&attrs, IFLA_VXLAN_GPE, *argv, *argv);
+			addattr_l(n, 1024, IFLA_VXLAN_GPE, NULL, 0);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -263,31 +340,26 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 		argc--, argv++;
 	}
 
-	if (metadata && vni_set) {
+	if (metadata && VXLAN_ATTRSET(attrs, IFLA_VXLAN_ID)) {
 		fprintf(stderr, "vxlan: both 'external' and vni cannot be specified\n");
 		return -1;
 	}
 
-	if (!metadata && !vni_set) {
+	if (!metadata && !VXLAN_ATTRSET(attrs, IFLA_VXLAN_ID)) {
 		fprintf(stderr, "vxlan: missing virtual network identifier\n");
 		return -1;
 	}
 
-	if ((gaddr && daddr) ||
-	    (!IN6_IS_ADDR_UNSPECIFIED(&gaddr6) &&
-	     !IN6_IS_ADDR_UNSPECIFIED(&daddr6))) {
-		fprintf(stderr, "vxlan: both group and remote cannot be specified\n");
-		return -1;
-	}
-
-	if ((gaddr || !IN6_IS_ADDR_UNSPECIFIED(&gaddr6)) && !link) {
+	if ((gaddr || !IN6_IS_ADDR_UNSPECIFIED(&gaddr6)) &&
+	    !VXLAN_ATTRSET(attrs, IFLA_VXLAN_LINK)) {
 		fprintf(stderr, "vxlan: 'group' requires 'dev' to be specified\n");
 		return -1;
 	}
 
-	if (!dst_port_set && gpe) {
+	if (!VXLAN_ATTRSET(attrs, IFLA_VXLAN_PORT) &&
+	    VXLAN_ATTRSET(attrs, IFLA_VXLAN_GPE)) {
 		dstport = 4790;
-	} else if (!dst_port_set) {
+	} else if (!VXLAN_ATTRSET(attrs, IFLA_VXLAN_PORT) && !set_op) {
 		fprintf(stderr, "vxlan: destination port not specified\n"
 			"Will use Linux kernel default (non-standard value)\n");
 		fprintf(stderr,
@@ -309,49 +381,12 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	else if (preferred_family == AF_INET6)
 		addattr_l(n, 1024, IFLA_VXLAN_GROUP6, &daddr6, sizeof(struct in6_addr));
 
-	if (saddr)
-		addattr_l(n, 1024, IFLA_VXLAN_LOCAL, &saddr, 4);
-	else if (!IN6_IS_ADDR_UNSPECIFIED(&saddr6))
-		addattr_l(n, 1024, IFLA_VXLAN_LOCAL6, &saddr6, sizeof(struct in6_addr));
-
-	if (link)
-		addattr32(n, 1024, IFLA_VXLAN_LINK, link);
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
-	if (udpcsum_set)
-		addattr8(n, 1024, IFLA_VXLAN_UDP_CSUM, udpcsum);
-	if (udp6zerocsumtx_set)
-		addattr8(n, 1024, IFLA_VXLAN_UDP_ZERO_CSUM6_TX, udp6zerocsumtx);
-	if (udp6zerocsumrx_set)
-		addattr8(n, 1024, IFLA_VXLAN_UDP_ZERO_CSUM6_RX, udp6zerocsumrx);
-	if (noage)
-		addattr32(n, 1024, IFLA_VXLAN_AGEING, 0);
-	else if (age)
-		addattr32(n, 1024, IFLA_VXLAN_AGEING, age);
-	if (maxaddr)
-		addattr32(n, 1024, IFLA_VXLAN_LIMIT, maxaddr);
-	if (range.low || range.high)
-		addattr_l(n, 1024, IFLA_VXLAN_PORT_RANGE,
-			  &range, sizeof(range));
+	if (!set_op || VXLAN_ATTRSET(attrs, IFLA_VXLAN_LEARNING))
+		addattr8(n, 1024, IFLA_VXLAN_LEARNING, learning);
+
 	if (dstport)
 		addattr16(n, 1024, IFLA_VXLAN_PORT, htons(dstport));
 
-	if (gbp)
-		addattr_l(n, 1024, IFLA_VXLAN_GBP, NULL, 0);
-	if (gpe)
-		addattr_l(n, 1024, IFLA_VXLAN_GPE, NULL, 0);
-
-
 	return 0;
 }
 
-- 
1.8.3.1
