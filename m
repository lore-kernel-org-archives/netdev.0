From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: [PATCH iproute2 v3 net-next] iplink_bond: add support for ad_actor and port_key options
Date: Sat,  9 May 2015 00:01:59 -0700
Message-ID: <e389fe24551b2c94286545fd91e7018cb29f4467.1431153512.git.jtoppins@cumulusnetworks.com>
References: <cover.1431150701.git.jtoppins@cumulusnetworks.com>
To: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	shm@cumulusnetworks.com, razor@blackwall.org,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:34836 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753613AbbEIHCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 03:02:49 -0400
Received: by pdbqd1 with SMTP id qd1so105324114pdb.2
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 00:02:48 -0700 (PDT)
In-Reply-To: <cover.1431150701.git.jtoppins@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for setting and displaying the following bonding
options:
* ad_user_port_key
* ad_actor_sys_prio
* ad_actor_system

Signed-off-by: Jonathan Toppins <jtoppins@cumulusnetworks.com>
---
 v2:
    * rebased
 v3:
    * fixed a checkpatch line length warning

 ip/iplink_bond.c |   49 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 49 insertions(+)

diff --git a/ip/iplink_bond.c b/ip/iplink_bond.c
index a573f92..2a9783e 100644
--- a/ip/iplink_bond.c
+++ b/ip/iplink_bond.c
@@ -135,6 +135,9 @@ static void print_explain(FILE *f)
 		"                [ packets_per_slave PACKETS_PER_SLAVE ]\n"
 		"                [ lacp_rate LACP_RATE ]\n"
 		"                [ ad_select AD_SELECT ]\n"
+		"                [ ad_user_port_key PORTKEY ]\n"
+		"                [ ad_actor_sys_prio SYSPRIO ]\n"
+		"                [ ad_actor_system LLADDR ]\n"
 		"\n"
 		"BONDMODE := balance-rr|active-backup|balance-xor|broadcast|802.3ad|balance-tlb|balance-alb\n"
 		"ARP_VALIDATE := none|active|backup|all\n"
@@ -158,6 +161,7 @@ static int bond_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u8 mode, use_carrier, primary_reselect, fail_over_mac;
 	__u8 xmit_hash_policy, num_peer_notif, all_slaves_active;
 	__u8 lacp_rate, ad_select;
+	__u16 ad_user_port_key, ad_actor_sys_prio;
 	__u32 miimon, updelay, downdelay, arp_interval, arp_validate;
 	__u32 arp_all_targets, resend_igmp, min_links, lp_interval;
 	__u32 packets_per_slave;
@@ -344,6 +348,32 @@ static int bond_parse_opt(struct link_util *lu, int argc, char **argv,
 			}
 			ad_select = get_index(ad_select_tbl, *argv);
 			addattr8(n, 1024, IFLA_BOND_AD_SELECT, ad_select);
+		} else if (matches(*argv, "ad_user_port_key") == 0) {
+			NEXT_ARG();
+			if (get_u16(&ad_user_port_key, *argv, 0)) {
+				invarg("invalid ad_user_port_key", *argv);
+				return -1;
+			}
+			addattr16(n, 1024, IFLA_BOND_AD_USER_PORT_KEY,
+				  ad_user_port_key);
+		} else if (matches(*argv, "ad_actor_sys_prio") == 0) {
+			NEXT_ARG();
+			if (get_u16(&ad_actor_sys_prio, *argv, 0)) {
+				invarg("invalid ad_actor_sys_prio", *argv);
+				return -1;
+			}
+			addattr16(n, 1024, IFLA_BOND_AD_ACTOR_SYS_PRIO,
+				  ad_actor_sys_prio);
+		} else if (matches(*argv, "ad_actor_system") == 0) {
+			int len;
+			char abuf[32];
+
+			NEXT_ARG();
+			len = ll_addr_a2n(abuf, sizeof(abuf), *argv);
+			if (len < 0)
+				return -1;
+			addattr_l(n, 1024, IFLA_BOND_AD_ACTOR_SYSTEM,
+				  abuf, len);
 		} else if (matches(*argv, "help") == 0) {
 			explain();
 			return -1;
@@ -534,6 +564,25 @@ static void bond_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 				ll_addr_n2a(p, ETH_ALEN, 0, b, sizeof(b)));
 		}
 	}
+
+	if (tb[IFLA_BOND_AD_ACTOR_SYS_PRIO]) {
+		fprintf(f, "ad_actor_sys_prio %u ",
+			rta_getattr_u16(tb[IFLA_BOND_AD_ACTOR_SYS_PRIO]));
+	}
+
+	if (tb[IFLA_BOND_AD_USER_PORT_KEY]) {
+		fprintf(f, "ad_user_port_key %u ",
+			rta_getattr_u16(tb[IFLA_BOND_AD_USER_PORT_KEY]));
+	}
+
+	if (tb[IFLA_BOND_AD_ACTOR_SYSTEM]) {
+		/* We assume the l2 address is an Ethernet MAC address */
+		SPRINT_BUF(b1);
+		fprintf(f, "ad_actor_system %s ",
+			ll_addr_n2a(RTA_DATA(tb[IFLA_BOND_AD_ACTOR_SYSTEM]),
+				    RTA_PAYLOAD(tb[IFLA_BOND_AD_ACTOR_SYSTEM]),
+				    1 /*ARPHDR_ETHER*/, b1, sizeof(b1)));
+	}
 }
 
 static void bond_print_help(struct link_util *lu, int argc, char **argv,
-- 
1.7.10.4
