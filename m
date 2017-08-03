From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH 24/27] ip: link_vti.c: add json output support
Date: Thu,  3 Aug 2017 17:55:12 +0200
Message-ID: <20170803155515.99226-25-julien@cumulusnetworks.com>
References: <20170803155515.99226-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:34759 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751154AbdHCP4E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 11:56:04 -0400
Received: by mail-wm0-f51.google.com with SMTP id t138so5636619wmt.1
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 08:56:03 -0700 (PDT)
In-Reply-To: <20170803155515.99226-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Schema:
{
    "remote": {
        "type": "string",
        "attr": "IFLA_VTI_REMOTE"
    },
    "local": {
        "type": "string",
        "attr": "IFLA_VTI_LOCAL"
    },
    "link": {
        "type": "string",
        "attr": "IFLA_VTI_LINK",
        "mutually_exclusive": {
            "link_index": {
                "type": "uint",
            }
        }
    },
    "ikey": {
        "type": "string",
        "attr": "IFLA_VTI_IKEY"
    },
    "okey": {
        "type": "string",
        "attr": "IFLA_VTI_OKEY"
    }
}

$ ip tunnel add vti0 mode vti local 192.0.2.1 remote 198.51.100.3
$ ip link show
10: ip_vti0@NONE: <NOARP> mtu 1428 qdisc noop state DOWN mode DEFAULT group
default
    link/ipip 0.0.0.0 brd 0.0.0.0
11: vti0@NONE: <POINTOPOINT,NOARP> mtu 1428 qdisc noop state DOWN mode
DEFAULT group default
    link/ipip 192.0.2.1 peer 198.51.100.3
$ ./ip -details -json link show
[{
        "ifindex": 10,
        "ifname": "ip_vti0",
        "link": null,
        "flags": ["NOARP"],
        "mtu": 1428,
        "qdisc": "noop",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "ipip",
        "address": "0.0.0.0",
        "broadcast": "0.0.0.0",
        "promiscuity": 0,
        "linkinfo": {
            "info_kind": "vti",
            "info_data": {
                "remote": "any",
                "local": "any",
                "ikey": "0.0.0.0",
                "okey": "0.0.0.0"
            }
        },
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    },{
        "ifindex": 11,
        "ifname": "vti0",
        "link": null,
        "flags": ["POINTOPOINT","NOARP"],
        "mtu": 1428,
        "qdisc": "noop",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "ipip",
        "address": "192.0.2.1",
        "link_pointtopoint": true,
        "broadcast": "198.51.100.3",
        "promiscuity": 0,
        "linkinfo": {
            "info_kind": "vti",
            "info_data": {
                "remote": "198.51.100.3",
                "local": "192.0.2.1",
                "ikey": "0.0.0.0",
                "okey": "0.0.0.0"
            }
        },
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    }
]
$

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 ip/link_vti.c | 23 ++++++++++++++---------
 1 file changed, 14 insertions(+), 9 deletions(-)

diff --git a/ip/link_vti.c b/ip/link_vti.c
index d5242ac7..74336aff 100644
--- a/ip/link_vti.c
+++ b/ip/link_vti.c
@@ -223,7 +223,7 @@ static void vti_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			remote = format_host(AF_INET, 4, &addr);
 	}
 
-	fprintf(f, "remote %s ", remote);
+	print_string(PRINT_ANY, "remote", "remote %s ", remote);
 
 	if (tb[IFLA_VTI_LOCAL]) {
 		unsigned int addr = rta_getattr_u32(tb[IFLA_VTI_LOCAL]);
@@ -232,31 +232,36 @@ static void vti_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			local = format_host(AF_INET, 4, &addr);
 	}
 
-	fprintf(f, "local %s ", local);
+	print_string(PRINT_ANY, "local", "local %s ", local);
 
 	if (tb[IFLA_VTI_LINK] &&
 	    (link = rta_getattr_u32(tb[IFLA_VTI_LINK]))) {
 		const char *n = if_indextoname(link, s2);
 
 		if (n)
-			fprintf(f, "dev %s ", n);
+			print_string(PRINT_ANY, "link", "dev %s ", n);
 		else
-			fprintf(f, "dev %u ", link);
+			print_uint(PRINT_ANY, "link_index", "dev %u ", link);
 	}
 
 	if (tb[IFLA_VTI_IKEY]) {
 		inet_ntop(AF_INET, RTA_DATA(tb[IFLA_VTI_IKEY]), s2, sizeof(s2));
-		fprintf(f, "ikey %s ", s2);
+		print_string(PRINT_ANY, "ikey", "ikey %s ", s2);
 	}
 
 	if (tb[IFLA_VTI_OKEY]) {
 		inet_ntop(AF_INET, RTA_DATA(tb[IFLA_VTI_OKEY]), s2, sizeof(s2));
-		fprintf(f, "okey %s ", s2);
+		print_string(PRINT_ANY, "okey", "okey %s ", s2);
 	}
 
-	if (tb[IFLA_VTI_FWMARK] && rta_getattr_u32(tb[IFLA_VTI_FWMARK])) {
-		fprintf(f, "fwmark 0x%x ",
-			rta_getattr_u32(tb[IFLA_VTI_FWMARK]));
+	if (tb[IFLA_VTI_FWMARK]) {
+		__u32 fwmark = rta_getattr_u32(tb[IFLA_VTI_FWMARK]);
+
+		if (fwmark) {
+			snprintf(s2, sizeof(s2), "0x%x", fwmark);
+
+			print_string(PRINT_ANY, "fwmark", "fwmark %s ", s2);
+		}
 	}
 }
 
-- 
2.13.3
