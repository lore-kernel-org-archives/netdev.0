From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: [PATCH iproute2 1/2] tc: flower: Introduce vlan support
Date: Mon, 22 Aug 2016 13:24:53 +0300
Message-ID: <1471861494-8299-2-git-send-email-hadarh@mellanox.com>
References: <1471861494-8299-1-git-send-email-hadarh@mellanox.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Jiri Pirko <jiri@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49750 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754726AbcHVKZf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 06:25:35 -0400
In-Reply-To: <1471861494-8299-1-git-send-email-hadarh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Classification according to vlan id and vlan priority.

Example script that adds vlan filter:

 # add ingress qdisc
 tc qdisc add dev ens4f0 ingress

 # add a flower filter with vlan id and priority classification
 tc filter add dev ens4f0 protocol 802.1Q parent ffff: \
	flower \
		indev ens4f0 \
		vlan_ethtype ipv4 \
		vlan_id 100 \
		vlan_prio 3 \
	action vlan pop

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
---
 include/linux/pkt_cls.h        |  5 +++
 include/linux/tc_act/tc_vlan.h |  3 ++
 man/man8/tc-flower.8           | 25 ++++++++++++-
 tc/f_flower.c                  | 80 ++++++++++++++++++++++++++++++++++++++++--
 4 files changed, 109 insertions(+), 4 deletions(-)

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index 5e6c61e..25a8fae 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -374,6 +374,11 @@ enum {
 	TCA_FLOWER_KEY_UDP_DST,		/* be16 */
 
 	TCA_FLOWER_FLAGS,
+
+	TCA_FLOWER_KEY_VLAN_ID,
+	TCA_FLOWER_KEY_VLAN_PRIO,
+	TCA_FLOWER_KEY_VLAN_ETH_TYPE,
+
 	__TCA_FLOWER_MAX,
 };
 
diff --git a/include/linux/tc_act/tc_vlan.h b/include/linux/tc_act/tc_vlan.h
index 31151ff..26ae695 100644
--- a/include/linux/tc_act/tc_vlan.h
+++ b/include/linux/tc_act/tc_vlan.h
@@ -16,6 +16,9 @@
 
 #define TCA_VLAN_ACT_POP	1
 #define TCA_VLAN_ACT_PUSH	2
+#define VLAN_PRIO_MASK		0x7
+#define VLAN_VID_MASK		0x0fff
+
 
 struct tc_vlan {
 	tc_gen;
diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index 9ae10e6..74f7664 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -23,7 +23,13 @@ flower \- flow based traffic control filter
 .R " | { "
 .BR dst_mac " | " src_mac " } "
 .IR mac_address " | "
-.BR eth_type " { " ipv4 " | " ipv6 " | "
+.BR eth_type " { " ipv4 " | " ipv6 " | " 802.1Q " | "
+.IR ETH_TYPE " } | "
+.B vlan_id
+.IR VID " | "
+.B vlan_prio
+.IR PRIORITY " | "
+.BR vlan_eth_type " { " ipv4 " | " ipv6 " | "
 .IR ETH_TYPE " } | "
 .BR ip_proto " { " tcp " | " udp " | "
 .IR IP_PROTO " } | { "
@@ -70,6 +76,23 @@ Do not process filter by hardware.
 Match on source or destination MAC address.
 .TP
 .BI eth_type " ETH_TYPE"
+Match on the next protocol.
+.I ETH_TYPE
+may be either
+.BR ipv4 , ipv6 , 802.1Q ,
+or an unsigned 16bit value in hexadecimal format.
+.TP
+.BI vlan_id " VID"
+Match on vlan tag id.
+.I VID
+is an unsigned 12bit value in decimal format.
+.TP
+.BI vlan_prio " priority"
+Match on vlan tag priority.
+.I PRIORITY
+is an unsigned 3bit value in decimal format.
+.TP
+.BI vlan_eth_type " VLAN_ETH_TYPE"
 Match on layer three protocol.
 .I ETH_TYPE
 may be either
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 791ade7..2ab2de1 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -17,6 +17,7 @@
 #include <net/if.h>
 #include <linux/if_ether.h>
 #include <linux/ip.h>
+#include <linux/tc_act/tc_vlan.h>
 
 #include "utils.h"
 #include "tc_util.h"
@@ -30,6 +31,9 @@ static void explain(void)
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: MATCH-LIST := [ MATCH-LIST ] MATCH\n");
 	fprintf(stderr, "       MATCH      := { indev DEV-NAME |\n");
+	fprintf(stderr, "                       vlan_id VID |\n");
+	fprintf(stderr, "                       vlan_prio PRIORITY |\n");
+	fprintf(stderr, "                       vlan_ethtype [ ipv4 | ipv6 | ETH-TYPE ] |\n");
 	fprintf(stderr, "                       dst_mac MAC-ADDR |\n");
 	fprintf(stderr, "                       src_mac MAC-ADDR |\n");
 	fprintf(stderr, "                       [ipv4 | ipv6 ] |\n");
@@ -61,6 +65,24 @@ static int flower_parse_eth_addr(char *str, int addr_type, int mask_type,
 	return 0;
 }
 
+static int flower_parse_vlan_eth_type(char *str, __be16 eth_type, int type,
+				      __be16 *p_vlan_eth_type,
+				      struct nlmsghdr *n)
+{
+	__be16 vlan_eth_type;
+
+	if (eth_type != htons(ETH_P_8021Q)) {
+		fprintf(stderr, "Can't set \"vlan_ethtype\" if ethertype isn't 802.1Q\n");
+		return -1;
+	}
+
+	if (ll_proto_a2n(&vlan_eth_type, str))
+		invarg("invalid vlan_ethtype", str);
+	addattr16(n, MAX_MSG, type, vlan_eth_type);
+	*p_vlan_eth_type = vlan_eth_type;
+	return 0;
+}
+
 static int flower_parse_ip_proto(char *str, __be16 eth_type, int type,
 				 __u8 *p_ip_proto, struct nlmsghdr *n)
 {
@@ -167,6 +189,7 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 	struct tcmsg *t = NLMSG_DATA(n);
 	struct rtattr *tail;
 	__be16 eth_type = TC_H_MIN(t->tcm_info);
+	__be16 vlan_ethtype = 0;
 	__u8 ip_proto = 0xff;
 	__u32 flags = 0;
 
@@ -208,6 +231,42 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 			NEXT_ARG();
 			strncpy(ifname, *argv, sizeof(ifname) - 1);
 			addattrstrz(n, MAX_MSG, TCA_FLOWER_INDEV, ifname);
+		} else if (matches(*argv, "vlan_id") == 0) {
+			__u16 vid;
+
+			NEXT_ARG();
+			if (eth_type != htons(ETH_P_8021Q)) {
+				fprintf(stderr, "Can't set \"vlan_id\" if ethertype isn't 802.1Q\n");
+				return -1;
+			}
+			ret = get_u16(&vid, *argv, 10);
+			if (ret < 0 || vid & ~0xfff) {
+				fprintf(stderr, "Illegal \"vlan_id\"\n");
+				return -1;
+			}
+			addattr16(n, MAX_MSG, TCA_FLOWER_KEY_VLAN_ID, vid);
+		} else if (matches(*argv, "vlan_prio") == 0) {
+			__u8 vlan_prio;
+
+			NEXT_ARG();
+			if (eth_type != htons(ETH_P_8021Q)) {
+				fprintf(stderr, "Can't set \"vlan_prio\" if ethertype isn't 802.1Q\n");
+				return -1;
+			}
+			ret = get_u8(&vlan_prio, *argv, 10);
+			if (ret < 0 || vlan_prio & ~VLAN_PRIO_MASK) {
+				fprintf(stderr, "Illegal \"vlan_prio\"\n");
+				return -1;
+			}
+			addattr8(n, MAX_MSG, TCA_FLOWER_KEY_VLAN_PRIO,
+				 vlan_prio);
+		} else if (matches(*argv, "vlan_ethtype") == 0) {
+			NEXT_ARG();
+			ret = flower_parse_vlan_eth_type(*argv, eth_type,
+							 TCA_FLOWER_KEY_VLAN_ETH_TYPE,
+							 &vlan_ethtype, n);
+			if (ret < 0)
+				return -1;
 		} else if (matches(*argv, "dst_mac") == 0) {
 			NEXT_ARG();
 			ret = flower_parse_eth_addr(*argv,
@@ -230,7 +289,8 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 			}
 		} else if (matches(*argv, "ip_proto") == 0) {
 			NEXT_ARG();
-			ret = flower_parse_ip_proto(*argv, eth_type,
+			ret = flower_parse_ip_proto(*argv, vlan_ethtype ?
+						    vlan_ethtype : eth_type,
 						    TCA_FLOWER_KEY_IP_PROTO,
 						    &ip_proto, n);
 			if (ret < 0) {
@@ -239,7 +299,8 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 			}
 		} else if (matches(*argv, "dst_ip") == 0) {
 			NEXT_ARG();
-			ret = flower_parse_ip_addr(*argv, eth_type,
+			ret = flower_parse_ip_addr(*argv, vlan_ethtype ?
+						   vlan_ethtype : eth_type,
 						   TCA_FLOWER_KEY_IPV4_DST,
 						   TCA_FLOWER_KEY_IPV4_DST_MASK,
 						   TCA_FLOWER_KEY_IPV6_DST,
@@ -251,7 +312,8 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 			}
 		} else if (matches(*argv, "src_ip") == 0) {
 			NEXT_ARG();
-			ret = flower_parse_ip_addr(*argv, eth_type,
+			ret = flower_parse_ip_addr(*argv, vlan_ethtype ?
+						   vlan_ethtype : eth_type,
 						   TCA_FLOWER_KEY_IPV4_SRC,
 						   TCA_FLOWER_KEY_IPV4_SRC_MASK,
 						   TCA_FLOWER_KEY_IPV6_SRC,
@@ -477,6 +539,18 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 		fprintf(f, "\n  indev %s", rta_getattr_str(attr));
 	}
 
+	if (tb[TCA_FLOWER_KEY_VLAN_ID]) {
+		struct rtattr *attr = tb[TCA_FLOWER_KEY_VLAN_ID];
+
+		fprintf(f, "\n  vlan_id %d", rta_getattr_u16(attr));
+	}
+
+	if (tb[TCA_FLOWER_KEY_VLAN_PRIO]) {
+		struct rtattr *attr = tb[TCA_FLOWER_KEY_VLAN_PRIO];
+
+		fprintf(f, "\n  vlan_prio %d", rta_getattr_u8(attr));
+	}
+
 	flower_print_eth_addr(f, "dst_mac", tb[TCA_FLOWER_KEY_ETH_DST],
 			      tb[TCA_FLOWER_KEY_ETH_DST_MASK]);
 	flower_print_eth_addr(f, "src_mac", tb[TCA_FLOWER_KEY_ETH_SRC],
-- 
1.8.3.1
