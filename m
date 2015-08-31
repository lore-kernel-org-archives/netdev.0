From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH iproute2] iplink: Add support for IFLA_BR_VLAN_PROTOCOL attribute
Date: Mon, 31 Aug 2015 18:48:46 +0900
Message-ID: <1441014526-4818-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:38144 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505AbbHaJsz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2015 05:48:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for bridge vlan_protocol.

Example:
$ ip link set br0 type bridge vlan_protocol 802.1ad
$ ip -d link show br0
4: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state
UP mode DEFAULT group default qlen 1000
    link/ether 44:37:e6:ab:cd:ef brd ff:ff:ff:ff:ff:ff promiscuity 0
    bridge forward_delay 0 hello_time 200 max_age 2000 ageing_time 30000
stp_state 0 priority 32768 vlan_filtering 0 vlan_protocol 802.1ad
addrgenmode eui64

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 include/linux/if_link.h |  1 +
 ip/iplink_bridge.c      | 21 +++++++++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 8f105cf..3c6d81c 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -229,6 +229,7 @@ enum {
 	IFLA_BR_STP_STATE,
 	IFLA_BR_PRIORITY,
 	IFLA_BR_VLAN_FILTERING,
+	IFLA_BR_VLAN_PROTOCOL,
 	__IFLA_BR_MAX,
 };
 
diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index f1c6968..0080409 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -14,6 +14,7 @@
 #include <string.h>
 #include <linux/if_link.h>
 
+#include "rt_names.h"
 #include "utils.h"
 #include "ip_common.h"
 
@@ -27,6 +28,9 @@ static void print_explain(FILE *f)
 		"                  [ stp_state STP_STATE ]\n"
 		"                  [ priority PRIORITY ]\n"
 		"                  [ vlan_filtering VLAN_FILTERING ]\n"
+		"                  [ vlan_protocol VLAN_PROTOCOL ]\n"
+		"\n"
+		"Where: VLAN_PROTOCOL := { 802.1Q | 802.1ad }\n"
 	);
 }
 
@@ -88,6 +92,15 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 				return -1;
 			}
 			addattr8(n, 1024, IFLA_BR_VLAN_FILTERING, vlan_filter);
+		} else if (matches(*argv, "vlan_protocol") == 0) {
+			__u16 vlan_proto;
+
+			NEXT_ARG();
+			if (ll_proto_a2n(&vlan_proto, *argv)) {
+				invarg("invalid vlan_protocol", *argv);
+				return -1;
+			}
+			addattr16(n, 1024, IFLA_BR_VLAN_PROTOCOL, vlan_proto);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -134,6 +147,14 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_BR_VLAN_FILTERING])
 		fprintf(f, "vlan_filtering %u ",
 			rta_getattr_u8(tb[IFLA_BR_VLAN_FILTERING]));
+
+	if (tb[IFLA_BR_VLAN_PROTOCOL]) {
+		SPRINT_BUF(b1);
+
+		fprintf(f, "vlan_protocol %s ",
+			ll_proto_n2a(rta_getattr_u16(tb[IFLA_BR_VLAN_PROTOCOL]),
+				     b1, sizeof(b1)));
+	}
 }
 
 static void bridge_print_help(struct link_util *lu, int argc, char **argv,
-- 
1.8.1.2
