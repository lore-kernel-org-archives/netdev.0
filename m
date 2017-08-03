From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH 26/27] ip: link_macvlan.c: add json output support
Date: Thu,  3 Aug 2017 17:55:14 +0200
Message-ID: <20170803155515.99226-27-julien@cumulusnetworks.com>
References: <20170803155515.99226-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f174.google.com ([209.85.128.174]:36118 "EHLO
        mail-wr0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751996AbdHCP4G (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 11:56:06 -0400
Received: by mail-wr0-f174.google.com with SMTP id y43so7405373wrd.3
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 08:56:05 -0700 (PDT)
In-Reply-To: <20170803155515.99226-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Schema:
{
    "mode": {
        "type": "string",
        "attr": "IFLA_MACVLAN_MODE"
    },
    "nopromisc": {
        "type": "bool",
        "attr": "MACVLAN_FLAG_NOPROMISC"
    },
    "macaddr_count": {
        "type": "int",
        "attr": "IFLA_MACVLAN_MACADDR_COUNT"
    },
    "macaddr_data": {
        "type": "array",
        "attr": "IFLA_MACVLAN_MACADDR_DATA",
        "array": [
            {
                "type": "string"
            }
        ]
    },
}

$ ip link add name peth0 link eth0 type macvlan
$ ip -details -json link show peth0
[{
        "ifindex": 26,
        "ifname": "peth0",
        "link": "eth0",
        "flags": ["BROADCAST","MULTICAST"],
        "mtu": 1500,
        "qdisc": "noop",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "ether",
        "address": "7a:84:48:3e:7b:1c",
        "broadcast": "ff:ff:ff:ff:ff:ff",
        "promiscuity": 0,
        "linkinfo": {
            "info_kind": "macvlan",
            "info_data": {
                "mode": "vepa"
            }
        },
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    }
]

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 ip/iplink_macvlan.c | 37 +++++++++++++++++++++++++------------
 1 file changed, 25 insertions(+), 12 deletions(-)

diff --git a/ip/iplink_macvlan.c b/ip/iplink_macvlan.c
index 662eb6ff..b966a615 100644
--- a/ip/iplink_macvlan.c
+++ b/ip/iplink_macvlan.c
@@ -193,13 +193,15 @@ static void macvlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[]
 		return;
 
 	mode = rta_getattr_u32(tb[IFLA_MACVLAN_MODE]);
-	fprintf(f, "mode %s ",
-		  mode == MACVLAN_MODE_PRIVATE ? "private"
-		: mode == MACVLAN_MODE_VEPA    ? "vepa"
-		: mode == MACVLAN_MODE_BRIDGE  ? "bridge"
-		: mode == MACVLAN_MODE_PASSTHRU  ? "passthru"
-		: mode == MACVLAN_MODE_SOURCE  ? "source"
-		:				 "unknown");
+	print_string(PRINT_ANY,
+		     "mode",
+		     "mode %s ",
+		     mode == MACVLAN_MODE_PRIVATE ? "private"
+		     : mode == MACVLAN_MODE_VEPA    ? "vepa"
+		     : mode == MACVLAN_MODE_BRIDGE  ? "bridge"
+		     : mode == MACVLAN_MODE_PASSTHRU  ? "passthru"
+		     : mode == MACVLAN_MODE_SOURCE  ? "source"
+		     :				 "unknown");
 
 	if (!tb[IFLA_MACVLAN_FLAGS] ||
 	    RTA_PAYLOAD(tb[IFLA_MACVLAN_FLAGS]) < sizeof(__u16))
@@ -208,7 +210,7 @@ static void macvlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[]
 		flags = rta_getattr_u16(tb[IFLA_MACVLAN_FLAGS]);
 
 	if (flags & MACVLAN_FLAG_NOPROMISC)
-		fprintf(f, "nopromisc ");
+		print_bool(PRINT_ANY, "nopromisc", "nopromisc ", true);
 
 	/* in source mode, there are more options to print */
 
@@ -220,7 +222,7 @@ static void macvlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[]
 		return;
 
 	count = rta_getattr_u32(tb[IFLA_MACVLAN_MACADDR_COUNT]);
-	fprintf(f, "remotes (%d) ", count);
+	print_int(PRINT_ANY, "macaddr_count", "remotes (%d) ", count);
 
 	if (!tb[IFLA_MACVLAN_MACADDR_DATA])
 		return;
@@ -228,18 +230,29 @@ static void macvlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[]
 	rta = RTA_DATA(tb[IFLA_MACVLAN_MACADDR_DATA]);
 	len = RTA_PAYLOAD(tb[IFLA_MACVLAN_MACADDR_DATA]);
 
+	open_json_array(PRINT_JSON, "macaddr_data");
 	for (; RTA_OK(rta, len); rta = RTA_NEXT(rta, len)) {
 		if (rta->rta_type != IFLA_MACVLAN_MACADDR ||
 		    RTA_PAYLOAD(rta) < 6)
 			continue;
 		addr = RTA_DATA(rta);
-		fprintf(f, "%.2x:%.2x:%.2x:%.2x:%.2x:%.2x ", addr[0],
-			addr[1], addr[2], addr[3], addr[4], addr[5]);
+		if (is_json_context()) {
+			SPRINT_BUF(b1);
+
+			snprintf(b1, sizeof(b1),
+				 "%.2x:%.2x:%.2x:%.2x:%.2x:%.2x", addr[0],
+				 addr[1], addr[2], addr[3], addr[4], addr[5]);
+			print_string(PRINT_JSON, NULL, NULL, b1);
+		} else {
+			fprintf(f, "%.2x:%.2x:%.2x:%.2x:%.2x:%.2x ", addr[0],
+				addr[1], addr[2], addr[3], addr[4], addr[5]);
+		}
 	}
+	close_json_array(PRINT_JSON, NULL);
 }
 
 static void macvlan_print_help(struct link_util *lu, int argc, char **argv,
-	FILE *f)
+			       FILE *f)
 {
 	print_explain(lu, f);
 }
-- 
2.13.3
