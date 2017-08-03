From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH 27/27] ip: iplink_vlan.c: add json output support
Date: Thu,  3 Aug 2017 17:55:15 +0200
Message-ID: <20170803155515.99226-28-julien@cumulusnetworks.com>
References: <20170803155515.99226-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37740 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752030AbdHCP4H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 11:56:07 -0400
Received: by mail-wm0-f53.google.com with SMTP id t201so19247630wmt.0
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 08:56:06 -0700 (PDT)
In-Reply-To: <20170803155515.99226-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Schema:
{
    "protocol": {
        "type": "string",
        "attr": "IFLA_VLAN_PROTOCOL"
    },
    "id": {
        "type": "uint",
        "attr": "IFLA_VLAN_ID"
    },
    "flags": {
        "type": "array",
        "attr": "IFLA_VLAN_FLAGS",
        "array": [
            {
                "type": "string"
            }
        ]
    },
    "ingress_qos": {
        "type": "array",
        "attr": "IFLA_VLAN_INGRESS_QOS",
        "array": [
            {
                "type": "dict",
                "dict": {
                    "from": {
                        "type": "uint"
                    },
                    "to": {
                        "type": "uint"
                    }
                }
            }
        ]
    },
    "egress_qos": {
        "type": "array",
        "attr": "IFLA_VLAN_EGRESS_QOS",
        "array": [
            {
                "type": "dict",
                "dict": {
                    "from": {
                        "type": "uint"
                    },
                    "to": {
                        "type": "uint"
                    }
                }
            }
        ]
    }
}

$ ip link add name eth0.42 link eth0 type vlan id 42
$ ip -details -json link show
[{
        "ifindex": 30,
        "ifname": "eth0.42",
        "link": "eth0",
        "flags": ["BROADCAST","MULTICAST"],
        "mtu": 1500,
        "qdisc": "noop",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "ether",
        "address": "08:00:27:db:31:88",
        "broadcast": "ff:ff:ff:ff:ff:ff",
        "promiscuity": 0,
        "linkinfo": {
            "info_kind": "vlan",
            "info_data": {
                "protocol": "802.1Q",
                "id": 42,
                "flags": ["REORDER_HDR"]
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
 ip/iplink_vlan.c | 62 ++++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 44 insertions(+), 18 deletions(-)

diff --git a/ip/iplink_vlan.c b/ip/iplink_vlan.c
index b47236d8..4d78cf9e 100644
--- a/ip/iplink_vlan.c
+++ b/ip/iplink_vlan.c
@@ -164,37 +164,51 @@ static int vlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	return 0;
 }
 
-static void vlan_print_map(FILE *f, char *name, struct rtattr *attr)
+static void vlan_print_map(FILE *f,
+			   const char *name_json,
+			   const char *name_fp,
+			   struct rtattr *attr)
 {
 	struct ifla_vlan_qos_mapping *m;
 	struct rtattr *i;
 	int rem;
 
-	fprintf(f, "\n      %s { ", name);
+	open_json_array(PRINT_JSON, name_json);
+	print_string(PRINT_FP, NULL, "\n      %s { ", name_fp);
 
 	rem = RTA_PAYLOAD(attr);
 	for (i = RTA_DATA(attr); RTA_OK(i, rem); i = RTA_NEXT(i, rem)) {
 		m = RTA_DATA(i);
-		fprintf(f, "%u:%u ", m->from, m->to);
+
+		if (is_json_context()) {
+			open_json_object(NULL);
+			print_uint(PRINT_JSON, "from", NULL, m->from);
+			print_uint(PRINT_JSON, "to", NULL, m->to);
+			close_json_object();
+		} else {
+			fprintf(f, "%u:%u ", m->from, m->to);
+		}
 	}
-	fprintf(f, "} ");
+
+	close_json_array(PRINT_JSON, NULL);
+	print_string(PRINT_FP, NULL, "%s ", "}");
 }
 
 static void vlan_print_flags(FILE *fp, __u32 flags)
 {
-	fprintf(fp, "<");
-#define _PF(f)	if (flags & VLAN_FLAG_##f) { \
-			flags &= ~VLAN_FLAG_##f; \
-			fprintf(fp, #f "%s", flags ? "," : ""); \
-		}
+	open_json_array(PRINT_ANY, is_json_context() ? "flags" : "<");
+#define _PF(f)	if (flags & VLAN_FLAG_##f) {				\
+		flags &= ~VLAN_FLAG_##f;				\
+		print_string(PRINT_ANY, NULL, flags ? "%s," : "%s", #f); \
+	}
 	_PF(REORDER_HDR);
 	_PF(GVRP);
 	_PF(MVRP);
 	_PF(LOOSE_BINDING);
 #undef _PF
 	if (flags)
-		fprintf(fp, "%x", flags);
-	fprintf(fp, "> ");
+		print_hex(PRINT_ANY, NULL, "%x", flags);
+	close_json_array(PRINT_ANY, "> ");
 }
 
 static void vlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
@@ -214,13 +228,19 @@ static void vlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		return;
 
 	if (tb[IFLA_VLAN_PROTOCOL])
-		fprintf(f, "protocol %s ",
-			ll_proto_n2a(rta_getattr_u16(tb[IFLA_VLAN_PROTOCOL]),
+		print_string(PRINT_ANY,
+			     "protocol",
+			     "protocol %s ",
+			     ll_proto_n2a(
+				     rta_getattr_u16(tb[IFLA_VLAN_PROTOCOL]),
 				     b1, sizeof(b1)));
 	else
-		fprintf(f, "protocol 802.1q ");
+		print_string(PRINT_ANY, "protocol", "protocol %s ", "802.1q");
 
-	fprintf(f, "id %u ", rta_getattr_u16(tb[IFLA_VLAN_ID]));
+	print_uint(PRINT_ANY,
+		   "id",
+		   "id %u ",
+		   rta_getattr_u16(tb[IFLA_VLAN_ID]));
 
 	if (tb[IFLA_VLAN_FLAGS]) {
 		if (RTA_PAYLOAD(tb[IFLA_VLAN_FLAGS]) < sizeof(*flags))
@@ -229,13 +249,19 @@ static void vlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		vlan_print_flags(f, flags->flags);
 	}
 	if (tb[IFLA_VLAN_INGRESS_QOS])
-		vlan_print_map(f, "ingress-qos-map", tb[IFLA_VLAN_INGRESS_QOS]);
+		vlan_print_map(f,
+			       "ingress_qos",
+			       "ingress-qos-map",
+			       tb[IFLA_VLAN_INGRESS_QOS]);
 	if (tb[IFLA_VLAN_EGRESS_QOS])
-		vlan_print_map(f, "egress-qos-map", tb[IFLA_VLAN_EGRESS_QOS]);
+		vlan_print_map(f,
+			       "egress_qos",
+			       "egress-qos-map",
+			       tb[IFLA_VLAN_EGRESS_QOS]);
 }
 
 static void vlan_print_help(struct link_util *lu, int argc, char **argv,
-	FILE *f)
+			    FILE *f)
 {
 	print_explain(f);
 }
-- 
2.13.3
