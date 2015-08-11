From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 net-next 2/2] iplink: bridge: add support for IFLA_BR_VLAN_FILTERING attribute
Date: Tue, 11 Aug 2015 15:56:24 +0300
Message-ID: <1439297784-1962-3-git-send-email-razor@blackwall.org>
References: <1439297784-1962-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38717 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964833AbbHKM4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 08:56:41 -0400
Received: by wicja10 with SMTP id ja10so67699231wic.1
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 05:56:40 -0700 (PDT)
In-Reply-To: <1439297784-1962-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

This patch implements support for the IFLA_BR_VLAN_FILTERING attribute
in iproute2 so it can enable/disable vlan_filtering.

Example:
$ ip link set br0 type bridge vlan_filtering 1
$ ip -d link show br0
6: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state
UP mode DEFAULT group default
    link/ether 08:00:27:ea:07:38 brd ff:ff:ff:ff:ff:ff promiscuity 0
    bridge forward_delay 1500 hello_time 200 max_age 2000 vlan_filtering 1
    addrgenmode eui64

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/linux/if_link.h |  1 +
 ip/iplink_bridge.c      | 14 ++++++++++++++
 2 files changed, 15 insertions(+)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index fa66d2bb3388..4f0a558e8fcf 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -228,6 +228,7 @@ enum {
 	IFLA_BR_AGEING_TIME,
 	IFLA_BR_STP_STATE,
 	IFLA_BR_PRIORITY,
+	IFLA_BR_VLAN_FILTERING,
 	__IFLA_BR_MAX,
 };
 
diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 2a0bf6e147d0..eeee71c98a93 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -26,6 +26,7 @@ static void explain(void)
 		"                  [ ageing_time AGEING_TIME ]\n"
 		"                  [ stp_state STP_STATE ]\n"
 		"                  [ priority PRIORITY ]\n"
+		"                  [ vlan_filtering VLAN_FILTERING ]\n"
 	);
 }
 
@@ -79,6 +80,15 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 				return -1;
 			}
 			addattr16(n, 1024, IFLA_BR_PRIORITY, prio);
+		} else if (matches(*argv, "vlan_filtering") == 0) {
+			__u8 vlan_filter;
+
+			NEXT_ARG();
+			if (get_u8(&vlan_filter, *argv, 0)) {
+				invarg("invalid vlan_filtering", *argv);
+				return -1;
+			}
+			addattr8(n, 1024, IFLA_BR_VLAN_FILTERING, vlan_filter);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -121,6 +131,10 @@ static void bridge_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_BR_PRIORITY])
 		fprintf(f, "priority %u ",
 			rta_getattr_u16(tb[IFLA_BR_PRIORITY]));
+
+	if (tb[IFLA_BR_VLAN_FILTERING])
+		fprintf(f, "vlan_filtering %u ",
+			rta_getattr_u8(tb[IFLA_BR_VLAN_FILTERING]));
 }
 
 struct link_util bridge_link_util = {
-- 
2.4.3
