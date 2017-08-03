From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH 25/27] ip: link_vti6.c: add json output support
Date: Thu,  3 Aug 2017 17:55:13 +0200
Message-ID: <20170803155515.99226-26-julien@cumulusnetworks.com>
References: <20170803155515.99226-1-julien@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:38071 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752016AbdHCP4F (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 11:56:05 -0400
Received: by mail-wr0-f182.google.com with SMTP id f21so7360354wrf.5
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 08:56:04 -0700 (PDT)
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

➜  ~ ip -6 tunnel add name vti6 mode vti6 local 2001:db8:1::1/64 remote
2001:0db8:85a3:0000:0000:8a2e:0370:7334
➜  ~ ip link show
10: ip6tnl0@NONE: <NOARP> mtu 1452 qdisc noop state DOWN mode DEFAULT
group default
    link/tunnel6 :: brd ::
11: ip6_vti0@NONE: <NOARP> mtu 1500 qdisc noop state DOWN mode DEFAULT
group default
    link/tunnel6 :: brd ::
12: vti6@NONE: <POINTOPOINT,NOARP> mtu 1500 qdisc noop state DOWN mode
DEFAULT group default
    link/tunnel6 2001:db8:1::1 peer 2001:db8:85a3::8a2e:370:7334
➜  ~ ./ip -details -json link show
[{
        "ifindex": 10,
        "ifname": "ip6tnl0",
        "link": null,
        "flags": ["NOARP"],
        "mtu": 1452,
        "qdisc": "noop",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "tunnel6",
        "address": "::",
        "broadcast": "::",
        "promiscuity": 0,
        "linkinfo": {
            "info_kind": "ip6tnl",
            "info_data": {
                "proto": "ip6ip6",
                "remote": "::",
                "local": "::",
                "encap_limit": 0,
                "ttl": 0,
                "flowinfo_tclass": "0x00",
                "flowlabel": "0x00000",
                "flowinfo": "0x00000000"
            }
        },
        "inet6_addr_gen_mode": "eui64",
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    },{
        "ifindex": 11,
        "ifname": "ip6_vti0",
        "link": null,
        "flags": ["NOARP"],
        "mtu": 1500,
        "qdisc": "noop",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "tunnel6",
        "address": "::",
        "broadcast": "::",
        "promiscuity": 0,
        "linkinfo": {
            "info_kind": "vti6",
            "info_data": {
                "remote": "::",
                "local": "::",
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
        "ifindex": 12,
        "ifname": "vti6",
        "link": null,
        "flags": ["POINTOPOINT","NOARP"],
        "mtu": 1500,
        "qdisc": "noop",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "tunnel6",
        "address": "2001:db8:1::1",
        "link_pointtopoint": true,
        "broadcast": "2001:db8:85a3::8a2e:370:7334",
        "promiscuity": 0,
        "linkinfo": {
            "info_kind": "vti6",
            "info_data": {
                "remote": "2001:db8:85a3::8a2e:370:7334",
                "local": "2001:db8:1::1",
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

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 ip/link_vti6.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/ip/link_vti6.c b/ip/link_vti6.c
index be4e33ce..7193e30b 100644
--- a/ip/link_vti6.c
+++ b/ip/link_vti6.c
@@ -222,7 +222,7 @@ static void vti6_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		remote = format_host(AF_INET6, 16, &daddr);
 	}
 
-	fprintf(f, "remote %s ", remote);
+	print_string(PRINT_ANY, "remote", "remote %s ", remote);
 
 	if (tb[IFLA_VTI_LOCAL]) {
 		memcpy(&saddr, RTA_DATA(tb[IFLA_VTI_LOCAL]), sizeof(saddr));
@@ -230,29 +230,35 @@ static void vti6_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		local = format_host(AF_INET6, 16, &saddr);
 	}
 
-	fprintf(f, "local %s ", local);
+	print_string(PRINT_ANY, "local", "local %s ", local);
 
 	if (tb[IFLA_VTI_LINK] && (link = rta_getattr_u32(tb[IFLA_VTI_LINK]))) {
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
-		fprintf(f, "fwmark 0x%x ", rta_getattr_u32(tb[IFLA_VTI_FWMARK]));
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
