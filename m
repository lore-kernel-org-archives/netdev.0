From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH iproute2 json v2 07/27] ip: iplink_bond.c: add json output support
Date: Thu, 17 Aug 2017 10:35:54 -0700
Message-ID: <20170817173614.54987-8-julien@cumulusnetworks.com>
References: <20170817173614.54987-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f174.google.com ([209.85.128.174]:38606 "EHLO
        mail-wr0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753490AbdHQRkp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 13:40:45 -0400
Received: by mail-wr0-f174.google.com with SMTP id 5so25410416wrz.5
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 10:40:44 -0700 (PDT)
In-Reply-To: <20170817173614.54987-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Schema and live example:
bond: IFLA_INFO_DATA
{
    "mode": {
        "type": "string",
        "attr": "IFLA_BOND_MODE"
    },
    "active_slave": {
        "type": "string",
        "attr": "IFLA_BOND_ACTIVE_SLAVE",
        "mutually_exclusive": {
            "active_slave_index": {
                "type": "int",
                "comment": "if active slave doesn't have a valid ifname"
            }
        }
    },
    "miimon": {
        "type": "uint",
        "attr": "IFLA_BOND_MIIMON"
    },
    "updelay": {
        "type": "uint",
        "attr": "IFLA_BOND_UPDELAY"
    },
    "downdelay": {
        "type": "uint",
        "attr": "IFLA_BOND_DOWNDELAY"
    },
    "use_carrier": {
        "type": "uint",
        "attr": "IFLA_BOND_USE_CARRIER"
    },
    "arp_interval": {
        "type": "uint",
        "attr": "IFLA_BOND_ARP_INTERVAL"
    },
    "arp_ip_target": {
        "type": "array",
        "attr": "IFLA_BOND_ARP_IP_TARGET",
        "array": [
            {
                "type": "string"
            }
        ]
    },
    "arp_validate": {
        "type": "string",
        "attr": "IFLA_BOND_ARP_VALIDATE"
    },
    "arp_all_targets": {
        "type": "string",
        "attr": "IFLA_BOND_ARP_ALL_TARGETS"
    },
    "primary": {
        "type": "string",
        "attr": "IFLA_BOND_PRIMARY",
        "mutually_exclusive": {
            "primary_index": {
                "type": "int",
                "comment": "if primary doesn't have a valid ifname"
            }
        }
    },
    "primary_reselect": {
        "type": "string",
        "attr": "IFLA_BOND_PRIMARY_RESELECT"
    },
    "fail_over_mac": {
        "type": "string",
        "attr": "IFLA_BOND_FAIL_OVER_MAC"
    },
    "xmit_hash_policy": {
        "type": "string",
        "attr": "IFLA_BOND_XMIT_HASH_POLICY"
    },
    "resend_igmp": {
        "type": "uint",
        "attr": "IFLA_BOND_RESEND_IGMP"
    },
    "num_peer_notif": {
        "type": "uint",
        "attr": "IFLA_BOND_NUM_PEER_NOTIF"
    },
    "all_slaves_active": {
        "type": "uint",
        "attr": "IFLA_BOND_ALL_SLAVES_ACTIVE"
    },
    "min_links": {
        "type": "uint",
        "attr": "IFLA_BOND_MIN_LINKS"
    },
    "lp_interval": {
        "type": "uint",
        "attr": "IFLA_BOND_LP_INTERVAL"
    },
    "packets_per_slave": {
        "type": "uint",
        "attr": "IFLA_BOND_PACKETS_PER_SLAVE"
    },
    "ad_lacp_rate": {
        "type": "string",
        "attr": "IFLA_BOND_AD_LACP_RATE"
    },
    "ad_select": {
        "type": "string",
        "attr": "IFLA_BOND_AD_SELECT"
    },
    "ad_info": {
        "type": "dict",
        "attr": "IFLA_BOND_AD_INFO",
        "dict": {
            "aggregator": {
                "type": "int",
                "attr": "IFLA_BOND_AD_INFO_AGGREGATOR"
            },
            "num_ports": {
                "type": "int",
                "attr": "IFLA_BOND_AD_INFO_NUM_PORTS"
            },
            "actor_key": {
                "type": "int",
                "attr": "IFLA_BOND_AD_INFO_ACTOR_KEY"
            },
            "partner_key": {
                "type": "int",
                "attr": "IFLA_BOND_AD_INFO_PARTNER_KEY"
            },
            "partner_mac": {
                "type": "string",
                "attr": "IFLA_BOND_AD_INFO_PARTNER_MAC"
            }
        }
    },
    "ad_actor_sys_prio": {
        "type": "uint",
        "attr": "IFLA_BOND_AD_ACTOR_SYS_PRIO"
    },
    "ad_user_port_key": {
        "type": "uint",
        "attr": "IFLA_BOND_AD_USER_PORT_KEY"
    },
    "ad_actor_system": {
        "type": "string",
        "attr": "IFLA_BOND_AD_ACTOR_SYSTEM"
    },
    "tlb_dynamic_lb": {
        "type": "uint",
        "attr": "IFLA_BOND_TLB_DYNAMIC_LB"
    }
}

$ ip link add dev bond42 type bond
$ ip link set dev swp5 master bond42
$ ip link set dev bond42 up
$ ip link set dev swp5 up
$ ip -details -json link show
[{
        "ifindex": 7,
        "ifname": "swp5",
        "flags": ["BROADCAST","MULTICAST","SLAVE","UP","LOWER_UP"],
        "mtu": 1500,
        "qdisc": "pfifo_fast",
        "master": "bond42",
        "operstate": "UP",
        "linkmode": "DEFAULT",
        "group": "default",
        "txqlen": 1000,
        "link_type": "ether",
        "address": "08:00:27:5c:03:c6",
        "broadcast": "ff:ff:ff:ff:ff:ff",
        "promiscuity": 0,
        "linkinfo": {
            "info_slave_kind": "bond",
            "info_slave_data": {
                "state": "BACKUP",
                "mii_status": "UP",
                "link_failure_count": 0,
                "perm_hwaddr": "08:00:27:5c:03:c6",
                "queue_id": 0,
                "ad_aggregator_id": 1,
                "ad_actor_oper_port_state": 79,
                "ad_partner_oper_port_state": 1
            }
        },
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    },{
        "ifindex": 14,
        "ifname": "bond42",
        "flags": ["NO-CARRIER","BROADCAST","MULTICAST","MASTER","UP"],
        "mtu": 1500,
        "qdisc": "noqueue",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "ether",
        "address": "08:00:27:5c:03:c6",
        "broadcast": "ff:ff:ff:ff:ff:ff",
        "promiscuity": 0,
        "linkinfo": {
            "info_kind": "bond",
            "info_data": {
                "mode": "802.3ad",
                "miimon": 100,
                "updelay": 0,
                "downdelay": 0,
                "use_carrier": 1,
                "arp_interval": 0,
                "arp_validate": null,
                "arp_all_targets": "any",
                "primary_reselect": "always",
                "fail_over_mac": "none",
                "xmit_hash_policy": "layer3+4",
                "resend_igmp": 1,
                "num_peer_notif": 1,
                "all_slaves_active": 0,
                "min_links": 1,
                "lp_interval": 1,
                "packets_per_slave": 1,
                "ad_lacp_rate": "fast",
                "ad_select": "stable",
                "ad_info": {
                    "aggregator": 1,
                    "num_ports": 1,
                    "actor_key": 0,
                    "partner_key": 1,
                    "partner_mac": "00:00:00:00:00:00"
                },
                "ad_actor_sys_prio": 65535,
                "ad_user_port_key": 0,
                "ad_actor_system": "00:00:00:00:00:00"
            }
        },
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 16,
        "num_rx_queues": 16,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    }
]

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 ip/iplink_bond.c | 231 ++++++++++++++++++++++++++++++++++++++-----------------
 1 file changed, 160 insertions(+), 71 deletions(-)

diff --git a/ip/iplink_bond.c b/ip/iplink_bond.c
index 772b05fd..2b5cf4f6 100644
--- a/ip/iplink_bond.c
+++ b/ip/iplink_bond.c
@@ -376,8 +376,8 @@ static void bond_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 
 	if (tb[IFLA_BOND_MODE]) {
 		const char *mode = get_name(mode_tbl,
-			rta_getattr_u8(tb[IFLA_BOND_MODE]));
-		fprintf(f, "mode %s ", mode);
+					    rta_getattr_u8(tb[IFLA_BOND_MODE]));
+		print_string(PRINT_ANY, "mode", "mode %s ", mode);
 	}
 
 	if (tb[IFLA_BOND_ACTIVE_SLAVE] &&
@@ -386,61 +386,97 @@ static void bond_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		const char *n = if_indextoname(ifindex, buf);
 
 		if (n)
-			fprintf(f, "active_slave %s ", n);
+			print_string(PRINT_ANY,
+				     "active_slave",
+				     "active_slave %s ",
+				     n);
 		else
-			fprintf(f, "active_slave %u ", ifindex);
+			print_uint(PRINT_ANY,
+				   "active_slave_index",
+				   "active_slave %u ",
+				   ifindex);
 	}
 
 	if (tb[IFLA_BOND_MIIMON])
-		fprintf(f, "miimon %u ", rta_getattr_u32(tb[IFLA_BOND_MIIMON]));
+		print_uint(PRINT_ANY,
+			   "miimon",
+			   "miimon %u ",
+			   rta_getattr_u32(tb[IFLA_BOND_MIIMON]));
 
 	if (tb[IFLA_BOND_UPDELAY])
-		fprintf(f, "updelay %u ", rta_getattr_u32(tb[IFLA_BOND_UPDELAY]));
+		print_uint(PRINT_ANY,
+			   "updelay",
+			   "updelay %u ",
+			   rta_getattr_u32(tb[IFLA_BOND_UPDELAY]));
 
 	if (tb[IFLA_BOND_DOWNDELAY])
-		fprintf(f, "downdelay %u ",
-			rta_getattr_u32(tb[IFLA_BOND_DOWNDELAY]));
+		print_uint(PRINT_ANY,
+			   "downdelay",
+			   "downdelay %u ",
+			   rta_getattr_u32(tb[IFLA_BOND_DOWNDELAY]));
 
 	if (tb[IFLA_BOND_USE_CARRIER])
-		fprintf(f, "use_carrier %u ",
-			rta_getattr_u8(tb[IFLA_BOND_USE_CARRIER]));
+		print_uint(PRINT_ANY,
+			   "use_carrier",
+			   "use_carrier %u ",
+			   rta_getattr_u8(tb[IFLA_BOND_USE_CARRIER]));
 
 	if (tb[IFLA_BOND_ARP_INTERVAL])
-		fprintf(f, "arp_interval %u ",
-			rta_getattr_u32(tb[IFLA_BOND_ARP_INTERVAL]));
+		print_uint(PRINT_ANY,
+			   "arp_interval",
+			   "arp_interval %u ",
+			   rta_getattr_u32(tb[IFLA_BOND_ARP_INTERVAL]));
 
 	if (tb[IFLA_BOND_ARP_IP_TARGET]) {
 		struct rtattr *iptb[BOND_MAX_ARP_TARGETS + 1];
 		int i;
 
 		parse_rtattr_nested(iptb, BOND_MAX_ARP_TARGETS,
-			tb[IFLA_BOND_ARP_IP_TARGET]);
+				    tb[IFLA_BOND_ARP_IP_TARGET]);
 
-		if (iptb[0])
-			fprintf(f, "arp_ip_target ");
+		if (iptb[0]) {
+			open_json_array(PRINT_JSON, "arp_ip_target");
+			print_string(PRINT_FP, NULL, "arp_ip_target ", NULL);
+		}
 
 		for (i = 0; i < BOND_MAX_ARP_TARGETS; i++) {
 			if (iptb[i])
-				fprintf(f, "%s",
-					rt_addr_n2a_rta(AF_INET, iptb[i]));
-			if (i < BOND_MAX_ARP_TARGETS-1 && iptb[i+1])
+				print_string(PRINT_ANY,
+					     NULL,
+					     "%s",
+					     rt_addr_n2a_rta(AF_INET, iptb[i]));
+			if (!is_json_context()
+			    && i < BOND_MAX_ARP_TARGETS-1
+			    && iptb[i+1])
 				fprintf(f, ",");
 		}
 
-		if (iptb[0])
-			fprintf(f, " ");
+		if (iptb[0]) {
+			print_string(PRINT_FP, NULL, " ", NULL);
+			close_json_array(PRINT_JSON, NULL);
+		}
 	}
 
 	if (tb[IFLA_BOND_ARP_VALIDATE]) {
-		const char *arp_validate = get_name(arp_validate_tbl,
-			rta_getattr_u32(tb[IFLA_BOND_ARP_VALIDATE]));
-		fprintf(f, "arp_validate %s ", arp_validate);
+		__u32 arp_v = rta_getattr_u32(tb[IFLA_BOND_ARP_VALIDATE]);
+		const char *arp_validate = get_name(arp_validate_tbl, arp_v);
+
+		if (!arp_v && is_json_context())
+			print_null(PRINT_JSON, "arp_validate", NULL, NULL);
+		else
+			print_string(PRINT_ANY,
+				     "arp_validate",
+				     "arp_validate %s ",
+				     arp_validate);
 	}
 
 	if (tb[IFLA_BOND_ARP_ALL_TARGETS]) {
 		const char *arp_all_targets = get_name(arp_all_targets_tbl,
-			rta_getattr_u32(tb[IFLA_BOND_ARP_ALL_TARGETS]));
-		fprintf(f, "arp_all_targets %s ", arp_all_targets);
+						       rta_getattr_u32(tb[IFLA_BOND_ARP_ALL_TARGETS]));
+		print_string(PRINT_ANY,
+			     "arp_all_targets",
+			     "arp_all_targets %s ",
+			     arp_all_targets);
 	}
 
 	if (tb[IFLA_BOND_PRIMARY] &&
@@ -449,123 +485,176 @@ static void bond_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		const char *n = if_indextoname(ifindex, buf);
 
 		if (n)
-			fprintf(f, "primary %s ", n);
+			print_string(PRINT_ANY, "primary", "primary %s ", n);
 		else
-			fprintf(f, "primary %u ", ifindex);
+			print_uint(PRINT_ANY,
+				   "primary_index",
+				   "primary %u ",
+				   ifindex);
 	}
 
 	if (tb[IFLA_BOND_PRIMARY_RESELECT]) {
 		const char *primary_reselect = get_name(primary_reselect_tbl,
-			rta_getattr_u8(tb[IFLA_BOND_PRIMARY_RESELECT]));
-		fprintf(f, "primary_reselect %s ", primary_reselect);
+							rta_getattr_u8(tb[IFLA_BOND_PRIMARY_RESELECT]));
+		print_string(PRINT_ANY,
+			     "primary_reselect",
+			     "primary_reselect %s ",
+			     primary_reselect);
 	}
 
 	if (tb[IFLA_BOND_FAIL_OVER_MAC]) {
 		const char *fail_over_mac = get_name(fail_over_mac_tbl,
-			rta_getattr_u8(tb[IFLA_BOND_FAIL_OVER_MAC]));
-		fprintf(f, "fail_over_mac %s ", fail_over_mac);
+						     rta_getattr_u8(tb[IFLA_BOND_FAIL_OVER_MAC]));
+		print_string(PRINT_ANY,
+			     "fail_over_mac",
+			     "fail_over_mac %s ",
+			     fail_over_mac);
 	}
 
 	if (tb[IFLA_BOND_XMIT_HASH_POLICY]) {
 		const char *xmit_hash_policy = get_name(xmit_hash_policy_tbl,
-			rta_getattr_u8(tb[IFLA_BOND_XMIT_HASH_POLICY]));
-		fprintf(f, "xmit_hash_policy %s ", xmit_hash_policy);
+							rta_getattr_u8(tb[IFLA_BOND_XMIT_HASH_POLICY]));
+		print_string(PRINT_ANY,
+			     "xmit_hash_policy",
+			     "xmit_hash_policy %s ",
+			     xmit_hash_policy);
 	}
 
 	if (tb[IFLA_BOND_RESEND_IGMP])
-		fprintf(f, "resend_igmp %u ",
-			rta_getattr_u32(tb[IFLA_BOND_RESEND_IGMP]));
+		print_uint(PRINT_ANY,
+			   "resend_igmp",
+			   "resend_igmp %u ",
+			   rta_getattr_u32(tb[IFLA_BOND_RESEND_IGMP]));
 
 	if (tb[IFLA_BOND_NUM_PEER_NOTIF])
-		fprintf(f, "num_grat_arp %u ",
-			rta_getattr_u8(tb[IFLA_BOND_NUM_PEER_NOTIF]));
+		print_uint(PRINT_ANY,
+			   "num_peer_notif",
+			   "num_grat_arp %u ",
+			   rta_getattr_u8(tb[IFLA_BOND_NUM_PEER_NOTIF]));
 
 	if (tb[IFLA_BOND_ALL_SLAVES_ACTIVE])
-		fprintf(f, "all_slaves_active %u ",
-			rta_getattr_u8(tb[IFLA_BOND_ALL_SLAVES_ACTIVE]));
+		print_uint(PRINT_ANY,
+			   "all_slaves_active",
+			   "all_slaves_active %u ",
+			   rta_getattr_u8(tb[IFLA_BOND_ALL_SLAVES_ACTIVE]));
 
 	if (tb[IFLA_BOND_MIN_LINKS])
-		fprintf(f, "min_links %u ",
-			rta_getattr_u32(tb[IFLA_BOND_MIN_LINKS]));
+		print_uint(PRINT_ANY,
+			   "min_links",
+			   "min_links %u ",
+			   rta_getattr_u32(tb[IFLA_BOND_MIN_LINKS]));
 
 	if (tb[IFLA_BOND_LP_INTERVAL])
-		fprintf(f, "lp_interval %u ",
-			rta_getattr_u32(tb[IFLA_BOND_LP_INTERVAL]));
+		print_uint(PRINT_ANY,
+			   "lp_interval",
+			   "lp_interval %u ",
+			   rta_getattr_u32(tb[IFLA_BOND_LP_INTERVAL]));
 
 	if (tb[IFLA_BOND_PACKETS_PER_SLAVE])
-		fprintf(f, "packets_per_slave %u ",
-			rta_getattr_u32(tb[IFLA_BOND_PACKETS_PER_SLAVE]));
+		print_uint(PRINT_ANY,
+			   "packets_per_slave",
+			   "packets_per_slave %u ",
+			   rta_getattr_u32(tb[IFLA_BOND_PACKETS_PER_SLAVE]));
 
 	if (tb[IFLA_BOND_AD_LACP_RATE]) {
 		const char *lacp_rate = get_name(lacp_rate_tbl,
-			rta_getattr_u8(tb[IFLA_BOND_AD_LACP_RATE]));
-		fprintf(f, "lacp_rate %s ", lacp_rate);
+						 rta_getattr_u8(tb[IFLA_BOND_AD_LACP_RATE]));
+		print_string(PRINT_ANY,
+			     "ad_lacp_rate",
+			     "lacp_rate %s ",
+			     lacp_rate);
 	}
 
 	if (tb[IFLA_BOND_AD_SELECT]) {
 		const char *ad_select = get_name(ad_select_tbl,
-			rta_getattr_u8(tb[IFLA_BOND_AD_SELECT]));
-		fprintf(f, "ad_select %s ", ad_select);
+						 rta_getattr_u8(tb[IFLA_BOND_AD_SELECT]));
+		print_string(PRINT_ANY,
+			     "ad_select",
+			     "ad_select %s ",
+			     ad_select);
 	}
 
 	if (tb[IFLA_BOND_AD_INFO]) {
 		struct rtattr *adtb[IFLA_BOND_AD_INFO_MAX + 1];
 
 		parse_rtattr_nested(adtb, IFLA_BOND_AD_INFO_MAX,
-			tb[IFLA_BOND_AD_INFO]);
+				    tb[IFLA_BOND_AD_INFO]);
+
+		open_json_object("ad_info");
 
 		if (adtb[IFLA_BOND_AD_INFO_AGGREGATOR])
-			fprintf(f, "ad_aggregator %d ",
-			  rta_getattr_u16(adtb[IFLA_BOND_AD_INFO_AGGREGATOR]));
+			print_int(PRINT_ANY,
+				  "aggregator",
+				  "ad_aggregator %d ",
+				  rta_getattr_u16(adtb[IFLA_BOND_AD_INFO_AGGREGATOR]));
 
 		if (adtb[IFLA_BOND_AD_INFO_NUM_PORTS])
-			fprintf(f, "ad_num_ports %d ",
-			  rta_getattr_u16(adtb[IFLA_BOND_AD_INFO_NUM_PORTS]));
+			print_int(PRINT_ANY,
+				  "num_ports",
+				  "ad_num_ports %d ",
+				  rta_getattr_u16(adtb[IFLA_BOND_AD_INFO_NUM_PORTS]));
 
 		if (adtb[IFLA_BOND_AD_INFO_ACTOR_KEY])
-			fprintf(f, "ad_actor_key %d ",
-			  rta_getattr_u16(adtb[IFLA_BOND_AD_INFO_ACTOR_KEY]));
+			print_int(PRINT_ANY,
+				  "actor_key",
+				  "ad_actor_key %d ",
+				  rta_getattr_u16(adtb[IFLA_BOND_AD_INFO_ACTOR_KEY]));
 
 		if (adtb[IFLA_BOND_AD_INFO_PARTNER_KEY])
-			fprintf(f, "ad_partner_key %d ",
-			  rta_getattr_u16(adtb[IFLA_BOND_AD_INFO_PARTNER_KEY]));
+			print_int(PRINT_ANY,
+				  "partner_key",
+				  "ad_partner_key %d ",
+				  rta_getattr_u16(adtb[IFLA_BOND_AD_INFO_PARTNER_KEY]));
 
 		if (adtb[IFLA_BOND_AD_INFO_PARTNER_MAC]) {
 			unsigned char *p =
 				RTA_DATA(adtb[IFLA_BOND_AD_INFO_PARTNER_MAC]);
 			SPRINT_BUF(b);
-			fprintf(f, "ad_partner_mac %s ",
-				ll_addr_n2a(p, ETH_ALEN, 0, b, sizeof(b)));
+			print_string(PRINT_ANY,
+				     "partner_mac",
+				     "ad_partner_mac %s ",
+				     ll_addr_n2a(p, ETH_ALEN, 0, b, sizeof(b)));
 		}
+
+		close_json_object();
 	}
 
 	if (tb[IFLA_BOND_AD_ACTOR_SYS_PRIO]) {
-		fprintf(f, "ad_actor_sys_prio %u ",
-			rta_getattr_u16(tb[IFLA_BOND_AD_ACTOR_SYS_PRIO]));
+		print_uint(PRINT_ANY,
+			   "ad_actor_sys_prio",
+			   "ad_actor_sys_prio %u ",
+			   rta_getattr_u16(tb[IFLA_BOND_AD_ACTOR_SYS_PRIO]));
 	}
 
 	if (tb[IFLA_BOND_AD_USER_PORT_KEY]) {
-		fprintf(f, "ad_user_port_key %u ",
-			rta_getattr_u16(tb[IFLA_BOND_AD_USER_PORT_KEY]));
+		print_uint(PRINT_ANY,
+			   "ad_user_port_key",
+			   "ad_user_port_key %u ",
+			   rta_getattr_u16(tb[IFLA_BOND_AD_USER_PORT_KEY]));
 	}
 
 	if (tb[IFLA_BOND_AD_ACTOR_SYSTEM]) {
 		/* We assume the l2 address is an Ethernet MAC address */
 		SPRINT_BUF(b1);
-		fprintf(f, "ad_actor_system %s ",
-			ll_addr_n2a(RTA_DATA(tb[IFLA_BOND_AD_ACTOR_SYSTEM]),
-				    RTA_PAYLOAD(tb[IFLA_BOND_AD_ACTOR_SYSTEM]),
-				    1 /*ARPHDR_ETHER*/, b1, sizeof(b1)));
+
+		print_string(PRINT_ANY,
+			     "ad_actor_system",
+			     "ad_actor_system %s ",
+			     ll_addr_n2a(RTA_DATA(tb[IFLA_BOND_AD_ACTOR_SYSTEM]),
+					 RTA_PAYLOAD(tb[IFLA_BOND_AD_ACTOR_SYSTEM]),
+					 1 /*ARPHDR_ETHER*/, b1, sizeof(b1)));
 	}
 
 	if (tb[IFLA_BOND_TLB_DYNAMIC_LB]) {
-		fprintf(f, "tlb_dynamic_lb %u ",
-			rta_getattr_u8(tb[IFLA_BOND_TLB_DYNAMIC_LB]));
+		print_uint(PRINT_ANY,
+			   "tlb_dynamic_lb",
+			   "tlb_dynamic_lb %u ",
+			   rta_getattr_u8(tb[IFLA_BOND_TLB_DYNAMIC_LB]));
 	}
 }
 
 static void bond_print_help(struct link_util *lu, int argc, char **argv,
-	FILE *f)
+			    FILE *f)
 {
 	print_explain(f);
 }
-- 
2.14.1
