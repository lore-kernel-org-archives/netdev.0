From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2 net-next] iplink: bonding: add support for IFLA_BOND_TLB_DYNAMIC_LB
Date: Mon,  3 Aug 2015 12:19:55 +0200
Message-ID: <1438597195-18044-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:35811 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753095AbbHCKUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 06:20:00 -0400
Received: by wibxm9 with SMTP id xm9so114402492wib.0
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 03:19:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add support to be able to set and show the value of tlb_dynamic_lb
(IFLA_BOND_TLB_DYNAMIC_LB).
Example:
$ ip -d link show dev bond0 type bond
7: bond0: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noop state DOWN
mode DEFAULT group default
    link/ether ce:2f:e1:6e:d7:e0 brd ff:ff:ff:ff:ff:ff promiscuity 0
    bond mode balance-tlb miimon 100 updelay 0 downdelay 0 use_carrier 1
arp_interval 0 arp_validate none arp_all_targets any primary_reselect
always fail_over_mac none xmit_hash_policy layer2 resend_igmp 1
num_grat_arp 1 all_slaves_active 0 min_links 0 lp_interval 1
packets_per_slave 1 lacp_rate slow ad_select stable tlb_dynamic_lb 1
addrgenmode eui64

$ ip -d l set dev bond0 type bond tlb_dynamic_lb 0
$ ip -d link show dev bond0 type bond
7: bond0: <BROADCAST,MULTICAST,MASTER> mtu 1500 qdisc noop state DOWN
mode DEFAULT group default
    link/ether ce:2f:e1:6e:d7:e0 brd ff:ff:ff:ff:ff:ff promiscuity 0
    bond mode balance-tlb miimon 100 updelay 0 downdelay 0 use_carrier 1
arp_interval 0 arp_validate none arp_all_targets any primary_reselect
always fail_over_mac none xmit_hash_policy layer2 resend_igmp 1
num_grat_arp 1 all_slaves_active 0 min_links 0 lp_interval 1
packets_per_slave 1 lacp_rate slow ad_select stable tlb_dynamic_lb 0
addrgenmode eui64

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bond.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/ip/iplink_bond.c b/ip/iplink_bond.c
index 2a9783e4f114..1b50de909356 100644
--- a/ip/iplink_bond.c
+++ b/ip/iplink_bond.c
@@ -133,6 +133,7 @@ static void print_explain(FILE *f)
 		"                [ min_links MIN_LINKS ]\n"
 		"                [ lp_interval LP_INTERVAL ]\n"
 		"                [ packets_per_slave PACKETS_PER_SLAVE ]\n"
+		"		 [ tlb_dynamic_lb TLB_DYNAMIC_LB ]\n"
 		"                [ lacp_rate LACP_RATE ]\n"
 		"                [ ad_select AD_SELECT ]\n"
 		"                [ ad_user_port_key PORTKEY ]\n"
@@ -160,7 +161,7 @@ static int bond_parse_opt(struct link_util *lu, int argc, char **argv,
 {
 	__u8 mode, use_carrier, primary_reselect, fail_over_mac;
 	__u8 xmit_hash_policy, num_peer_notif, all_slaves_active;
-	__u8 lacp_rate, ad_select;
+	__u8 lacp_rate, ad_select, tlb_dynamic_lb;
 	__u16 ad_user_port_key, ad_actor_sys_prio;
 	__u32 miimon, updelay, downdelay, arp_interval, arp_validate;
 	__u32 arp_all_targets, resend_igmp, min_links, lp_interval;
@@ -374,6 +375,14 @@ static int bond_parse_opt(struct link_util *lu, int argc, char **argv,
 				return -1;
 			addattr_l(n, 1024, IFLA_BOND_AD_ACTOR_SYSTEM,
 				  abuf, len);
+		} else if (matches(*argv, "tlb_dynamic_lb") == 0) {
+			NEXT_ARG();
+			if (get_u8(&tlb_dynamic_lb, *argv, 0)) {
+				invarg("invalid tlb_dynamic_lb", *argv);
+				return -1;
+			}
+			addattr8(n, 1024, IFLA_BOND_TLB_DYNAMIC_LB,
+				 tlb_dynamic_lb);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -583,6 +592,11 @@ static void bond_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 				    RTA_PAYLOAD(tb[IFLA_BOND_AD_ACTOR_SYSTEM]),
 				    1 /*ARPHDR_ETHER*/, b1, sizeof(b1)));
 	}
+
+	if (tb[IFLA_BOND_TLB_DYNAMIC_LB]) {
+		fprintf(f, "tlb_dynamic_lb %u ",
+			rta_getattr_u8(tb[IFLA_BOND_TLB_DYNAMIC_LB]));
+	}
 }
 
 static void bond_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.4.3
