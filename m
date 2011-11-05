From: David Lamparter <equinox@diac24.net>
Subject: [PATCH iproute2] link/vlan: Add 802.1ad / QinQ support
Date: Sat,  5 Nov 2011 18:05:51 +0100
Message-ID: <1320512751-1249150-1-git-send-email-equinox@diac24.net>
References: <1320512055-1231037-2-git-send-email-equinox@diac24.net>
Cc: netdev@vger.kernel.org, David Lamparter <equinox@diac24.net>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:55516 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753878Ab1KERGJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Nov 2011 13:06:09 -0400
In-Reply-To: <1320512055-1231037-2-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this adds the IFLA_VLAN_PROTOCOL attribute to the link family of
commands. The attribute is only added when a protocol is given on the
command line and only displayed if it has a value other than 0x8100.

Signed-off-by: David Lamparter <equinox@diac24.net>
---
 include/linux/if_link.h |    1 +
 ip/iplink_vlan.c        |   34 ++++++++++++++++++++++++++++++++--
 2 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 304c44f..0e6eeec 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -223,6 +223,7 @@ enum {
 	IFLA_VLAN_FLAGS,
 	IFLA_VLAN_EGRESS_QOS,
 	IFLA_VLAN_INGRESS_QOS,
+	IFLA_VLAN_PROTOCOL,
 	__IFLA_VLAN_MAX,
 };
 
diff --git a/ip/iplink_vlan.c b/ip/iplink_vlan.c
index 223feb3..95a5dae 100644
--- a/ip/iplink_vlan.c
+++ b/ip/iplink_vlan.c
@@ -13,6 +13,7 @@
 #include <stdlib.h>
 #include <string.h>
 #include <linux/if_vlan.h>
+#include <linux/if_ether.h>
 
 #include "rt_names.h"
 #include "utils.h"
@@ -21,7 +22,7 @@
 static void explain(void)
 {
 	fprintf(stderr,
-		"Usage: ... vlan id VLANID [ FLAG-LIST ]\n"
+		"Usage: ... vlan id VLANID [ protocol ENCAPSULATION ] [ FLAG-LIST ]\n"
 		"                          [ ingress-qos-map QOS-MAP ] [ egress-qos-map QOS-MAP ]\n"
 		"\n"
 		"VLANID := 0-4095\n"
@@ -30,6 +31,7 @@ static void explain(void)
 		"        [ loose_binding { on | off } ]\n"
 		"QOS-MAP := [ QOS-MAP ] QOS-MAPPING\n"
 		"QOS-MAPPING := FROM:TO\n"
+		"ENCAPSULATION := 802.1Q | 802.1ad | 9100 | 9200 | 9300\n"
 	);
 }
 
@@ -77,7 +79,7 @@ static int vlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			  struct nlmsghdr *n)
 {
 	struct ifla_vlan_flags flags = { 0 };
-	__u16 id;
+	__u16 id, proto;
 
 	while (argc > 0) {
 		if (matches(*argv, "id") == 0) {
@@ -85,6 +87,21 @@ static int vlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			if (get_u16(&id, *argv, 0))
 				invarg("id is invalid", *argv);
 			addattr_l(n, 1024, IFLA_VLAN_ID, &id, 2);
+		} else if (matches(*argv, "protocol") == 0) {
+			NEXT_ARG();
+			if (strcmp(*argv, "802.1Q") == 0)
+				proto = ETH_P_8021Q;
+			else if (strcmp(*argv, "802.1ad") == 0)
+				proto = ETH_P_8021AD;
+			else if (strcmp(*argv, "9100") == 0)
+				proto = 0x9100;
+			else if (strcmp(*argv, "9200") == 0)
+				proto = 0x9200;
+			else if (strcmp(*argv, "9300") == 0)
+				proto = 0x9300;
+			else
+				invarg("protocol is invalid", *argv);
+			addattr_l(n, 1024, IFLA_VLAN_PROTOCOL, &proto, 2);
 		} else if (matches(*argv, "reorder_hdr") == 0) {
 			NEXT_ARG();
 			flags.mask |= VLAN_FLAG_REORDER_HDR;
@@ -183,6 +200,19 @@ static void vlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	    RTA_PAYLOAD(tb[IFLA_VLAN_ID]) < sizeof(__u16))
 		return;
 
+	if (tb[IFLA_VLAN_PROTOCOL]) {
+		unsigned protocol = *(__u16 *)RTA_DATA(tb[IFLA_VLAN_PROTOCOL]);
+		switch (protocol) {
+		case ETH_P_8021Q:
+			break;
+		case ETH_P_8021AD:
+			fprintf(f, "protocol 802.1ad ");
+			break;
+		default:
+			fprintf(f, "protocol %04x ", protocol);
+			break;
+		}
+	}
 	fprintf(f, "id %u ", *(__u16 *)RTA_DATA(tb[IFLA_VLAN_ID]));
 
 	if (tb[IFLA_VLAN_FLAGS]) {
-- 
1.7.7
