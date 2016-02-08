From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 v2 05/21] iplink: bridge: add support for IFLA_BR_GROUP_ADDR
Date: Tue,  9 Feb 2016 00:14:23 +0100
Message-ID: <1454973279-9170-6-git-send-email-razor@blackwall.org>
References: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:36371 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932527AbcBHXOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2016 18:14:48 -0500
Received: by mail-wm0-f52.google.com with SMTP id p63so135606876wmp.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2016 15:14:48 -0800 (PST)
In-Reply-To: <1454973279-9170-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This patch implements support for the IFLA_BR_GROUP_ADDR attribute
in iproute2 so it can change the group address.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 2ee4bd690a28..0a2845027acb 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -29,6 +29,7 @@ static void print_explain(FILE *f)
 		"                  [ stp_state STP_STATE ]\n"
 		"                  [ priority PRIORITY ]\n"
 		"                  [ group_fwd_mask MASK ]\n"
+		"                  [ group_address ADDRESS ]\n"
 		"                  [ vlan_filtering VLAN_FILTERING ]\n"
 		"                  [ vlan_protocol VLAN_PROTOCOL ]\n"
 		"\n"
@@ -120,6 +121,15 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 				invarg("invalid group_fwd_mask", *argv);
 
 			addattr16(n, 1024, IFLA_BR_GROUP_FWD_MASK, fwd_mask);
+		} else if (matches(*argv, "group_address") == 0) {
+			char llabuf[32];
+			int len;
+
+			NEXT_ARG();
+			len = ll_addr_a2n(llabuf, sizeof(llabuf), *argv);
+			if (len < 0)
+				return -1;
+			addattr_l(n, 1024, IFLA_BR_GROUP_ADDR, llabuf, len);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -244,6 +254,15 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_BR_GROUP_FWD_MASK])
 		fprintf(f, "group_fwd_mask %#x ",
 			rta_getattr_u16(tb[IFLA_BR_GROUP_FWD_MASK]));
+
+	if (tb[IFLA_BR_GROUP_ADDR]) {
+		SPRINT_BUF(mac);
+
+		fprintf(f, "group_address %s ",
+			ll_addr_n2a(RTA_DATA(tb[IFLA_BR_GROUP_ADDR]),
+				    RTA_PAYLOAD(tb[IFLA_BR_GROUP_ADDR]),
+				    1 /*ARPHDR_ETHER*/, mac, sizeof(mac)));
+	}
 }
 
 static void bridge_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.4.3
