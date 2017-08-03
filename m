From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH 23/27] ip: link_iptnl.c: add json output support
Date: Thu,  3 Aug 2017 17:55:11 +0200
Message-ID: <20170803155515.99226-24-julien@cumulusnetworks.com>
References: <20170803155515.99226-1-julien@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:38692 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751996AbdHCP4D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 11:56:03 -0400
Received: by mail-wm0-f41.google.com with SMTP id m85so19193421wma.1
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 08:56:02 -0700 (PDT)
In-Reply-To: <20170803155515.99226-1-julien@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

Schema
{
    "remote": {
        "type": "string",
        "attr": "IFLA_IPTUN_REMOTE"
    },
    "local": {
        "type": "string",
        "attr": "IFLA_IPTUN_LOCAL"
    },
    "link": {
        "type": "string",
        "attr": "IFLA_IPTUN_LINK",
        "mutually_exclusive": {
            "link_index": {
                "type": "uint",
            }
        }
    },
    "ttl": {
        "type": "int",
        "attr": "IFLA_IPTUN_TTL"
    },
    "tos": {
        "type": "string",
        "attr": "IFLA_IPTUN_TOS"
    },
    "pmtudisc": {
        "type": "bool",
        "attr": "IFLA_IPTUN_PMTUDISC"
    },
    "isatap": {
        "type": "bool",
        "attr": "SIT_ISATAP & IFLA_IPTUN_FLAGS"
    },
    "6rd": {
        "type": "dict",
        "attr": "IFLA_IPTUN_6RD_PREFIXLEN",
        "dict": {
            "prefix": {
                "type": "string"
            },
            "prefixlen": {
                "type": "uint",
                "attr": "IFLA_IPTUN_6RD_PREFIXLEN"
            },
            "relay_prefix": {
                "type": "string"
            },
            "relay_prefixlen": {
                "type": "uint",
                "attr": "IFLA_IPTUN_6RD_PREFIXLEN"
            }
        }
    },
    "encap": {
        "type": "dict",
        "attr": "IFLA_IPTUN_ENCAP_TYPE",
        "dict": {
            "type": {
                "type": "string",
                "attr": "IFLA_IPTUN_ENCAP_TYPE"
            },
            "sport": {
                "type": "uint",
                "attr": "IFLA_IPTUN_ENCAP_SPORT"
            },
            "dport": {
                "type": "uint",
                "attr": "IFLA_IPTUN_ENCAP_DPORT"
            },
            "csum": {
                "type": "bool",
                "attr": "TUNNEL_ENCAP_FLAG_CSUM"
            },
            "csum6": {
                "type": "bool",
                "attr": "TUNNEL_ENCAP_FLAG_CSUM6"
            },
            "remcsum": {
                "type": "bool",
                "attr": "TUNNEL_ENCAP_FLAG_REMCSUM"
            }
        }
    }
}

$ ip tunnel add tun0 mode ipip local 192.0.2.1 remote 198.51.100.3
$ ip link show
10: tunl0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN mode DEFAULT group
default
    link/ipip 0.0.0.0 brd 0.0.0.0
11: tun0@NONE: <POINTOPOINT,NOARP> mtu 1480 qdisc noop state DOWN mode
DEFAULT group default
    link/ipip 192.0.2.1 peer 198.51.100.3
$ ip -details -json link show
[{
        "ifindex": 10,
        "ifname": "tunl0",
        "link": null,
        "flags": ["NOARP"],
        "mtu": 1480,
        "qdisc": "noop",
        "operstate": "DOWN",
        "linkmode": "DEFAULT",
        "group": "default",
        "link_type": "ipip",
        "address": "0.0.0.0",
        "broadcast": "0.0.0.0",
        "promiscuity": 0,
        "linkinfo": {
            "info_kind": "ipip",
            "info_data": {
                "remote": "any",
                "local": "any",
                "ttl": 0,
                "pmtudisc": false
            }
        },
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    },{
        "ifindex": 11,
        "ifname": "tun0",
        "link": null,
        "flags": ["POINTOPOINT","NOARP"],
        "mtu": 1480,
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
            "info_kind": "ipip",
            "info_data": {
                "remote": "198.51.100.3",
                "local": "192.0.2.1",
                "ttl": 0,
                "pmtudisc": true
            }
        },
        "num_tx_queues": 1,
        "num_rx_queues": 1,
        "gso_max_size": 65536,
        "gso_max_segs": 65535
    }
]
$

Signed-off-by: Julien Fortin <julien@cumulusnetworks.com>
---
 ip/link_iptnl.c | 155 ++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 106 insertions(+), 49 deletions(-)

diff --git a/ip/link_iptnl.c b/ip/link_iptnl.c
index d24e7376..6a725e91 100644
--- a/ip/link_iptnl.c
+++ b/ip/link_iptnl.c
@@ -398,7 +398,7 @@ static void iptunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[
 			remote = format_host(AF_INET, 4, &addr);
 	}
 
-	fprintf(f, "remote %s ", remote);
+	print_string(PRINT_ANY, "remote", "remote %s ", remote);
 
 	if (tb[IFLA_IPTUN_LOCAL]) {
 		unsigned int addr = rta_getattr_u32(tb[IFLA_IPTUN_LOCAL]);
@@ -407,43 +407,55 @@ static void iptunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[
 			local = format_host(AF_INET, 4, &addr);
 	}
 
-	fprintf(f, "local %s ", local);
+	print_string(PRINT_ANY, "local", "local %s ", local);
 
 	if (tb[IFLA_IPTUN_LINK] && rta_getattr_u32(tb[IFLA_IPTUN_LINK])) {
 		unsigned int link = rta_getattr_u32(tb[IFLA_IPTUN_LINK]);
 		const char *n = if_indextoname(link, s2);
 
 		if (n)
-			fprintf(f, "dev %s ", n);
+			print_string(PRINT_ANY, "link", "dev %s ", n);
 		else
-			fprintf(f, "dev %u ", link);
+			print_int(PRINT_ANY, "link_index", "dev %u ", link);
 	}
 
-	if (tb[IFLA_IPTUN_TTL] && rta_getattr_u8(tb[IFLA_IPTUN_TTL]))
-		fprintf(f, "ttl %d ", rta_getattr_u8(tb[IFLA_IPTUN_TTL]));
-	else
-		fprintf(f, "ttl inherit ");
+	if (tb[IFLA_IPTUN_TTL]) {
+		__u8 ttl = rta_getattr_u8(tb[IFLA_IPTUN_TTL]);
+
+		if (ttl)
+			print_int(PRINT_ANY, "ttl", "ttl %d ", ttl);
+		else
+			print_int(PRINT_JSON, "ttl", NULL, ttl);
+	} else {
+		print_string(PRINT_FP, NULL, "ttl %s ", "inherit");
+	}
 
-	if (tb[IFLA_IPTUN_TOS] && rta_getattr_u8(tb[IFLA_IPTUN_TOS])) {
+	if (tb[IFLA_IPTUN_TOS]) {
 		int tos = rta_getattr_u8(tb[IFLA_IPTUN_TOS]);
 
-		fputs("tos ", f);
-		if (tos == 1)
-			fputs("inherit ", f);
-		else
-			fprintf(f, "0x%x ", tos);
+		if (tos) {
+			if (is_json_context()) {
+				print_0xhex(PRINT_JSON, "tos", "%#x", tos);
+			} else {
+				fputs("tos ", f);
+				if (tos == 1)
+					fputs("inherit ", f);
+				else
+					fprintf(f, "0x%x ", tos);
+			}
+		}
 	}
 
 	if (tb[IFLA_IPTUN_PMTUDISC] && rta_getattr_u8(tb[IFLA_IPTUN_PMTUDISC]))
-		fprintf(f, "pmtudisc ");
+		print_bool(PRINT_ANY, "pmtudisc", "pmtudisc ", true);
 	else
-		fprintf(f, "nopmtudisc ");
+		print_bool(PRINT_ANY, "pmtudisc", "nopmtudisc ", false);
 
 	if (tb[IFLA_IPTUN_FLAGS]) {
 		__u16 iflags = rta_getattr_u16(tb[IFLA_IPTUN_FLAGS]);
 
 		if (iflags & SIT_ISATAP)
-			fprintf(f, "isatap ");
+			print_bool(PRINT_ANY, "isatap", "isatap ", true);
 	}
 
 	if (tb[IFLA_IPTUN_6RD_PREFIXLEN] &&
@@ -453,14 +465,32 @@ static void iptunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[
 		__u32 relayprefix =
 			rta_getattr_u32(tb[IFLA_IPTUN_6RD_RELAY_PREFIX]);
 
-		printf("6rd-prefix %s/%u ",
-		       inet_ntop(AF_INET6, RTA_DATA(tb[IFLA_IPTUN_6RD_PREFIX]),
-				 s1, sizeof(s1)),
-		       prefixlen);
-		if (relayprefix) {
-			printf("6rd-relay_prefix %s/%u ",
-			       format_host(AF_INET, 4, &relayprefix),
-			       relayprefixlen);
+		const char *prefix = inet_ntop(AF_INET6,
+					       RTA_DATA(tb[IFLA_IPTUN_6RD_PREFIX]),
+					       s1, sizeof(s1));
+
+		if (is_json_context()) {
+			print_string(PRINT_JSON, "prefix", NULL, prefix);
+			print_int(PRINT_JSON, "prefixlen", NULL, prefixlen);
+			if (relayprefix) {
+				print_string(PRINT_JSON,
+					     "relay_prefix",
+					     NULL,
+					     format_host(AF_INET,
+							 4,
+							 &relayprefix));
+				print_int(PRINT_JSON,
+					  "relay_prefixlen",
+					  NULL,
+					  relayprefixlen);
+			}
+		} else {
+			printf("6rd-prefix %s/%u ", prefix, prefixlen);
+			if (relayprefix) {
+				printf("6rd-relay_prefix %s/%u ",
+				       format_host(AF_INET, 4, &relayprefix),
+				       relayprefixlen);
+			}
 		}
 	}
 
@@ -470,45 +500,72 @@ static void iptunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[
 		__u16 sport = rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_SPORT]);
 		__u16 dport = rta_getattr_u16(tb[IFLA_IPTUN_ENCAP_DPORT]);
 
-		fputs("encap ", f);
+		print_string(PRINT_FP, NULL, "encap ", NULL);
 		switch (type) {
 		case TUNNEL_ENCAP_FOU:
-			fputs("fou ", f);
+			print_string(PRINT_ANY, "type", "%s ", "fou");
 			break;
 		case TUNNEL_ENCAP_GUE:
-			fputs("gue ", f);
+			print_string(PRINT_ANY, "type", "%s ", "gue");
 			break;
 		default:
-			fputs("unknown ", f);
+			print_null(PRINT_ANY, "type", "unknown ", NULL);
 			break;
 		}
 
-		if (sport == 0)
-			fputs("encap-sport auto ", f);
-		else
-			fprintf(f, "encap-sport %u", ntohs(sport));
+		if (is_json_context()) {
+			print_uint(PRINT_JSON,
+				   "sport",
+				   NULL,
+				   sport ? ntohs(sport) : 0);
+			print_uint(PRINT_JSON, "dport", NULL, ntohs(dport));
+			print_bool(PRINT_JSON,
+				   "csum",
+				   NULL,
+				   flags & TUNNEL_ENCAP_FLAG_CSUM);
+			print_bool(PRINT_JSON,
+				   "csum6",
+				   NULL,
+				   flags & TUNNEL_ENCAP_FLAG_CSUM6);
+			print_bool(PRINT_JSON,
+				   "remcsum",
+				   NULL,
+				   flags & TUNNEL_ENCAP_FLAG_REMCSUM);
+			close_json_object();
+		} else {
+			if (sport == 0)
+				fputs("encap-sport auto ", f);
+			else
+				fprintf(f, "encap-sport %u", ntohs(sport));
 
-		fprintf(f, "encap-dport %u ", ntohs(dport));
+			fprintf(f, "encap-dport %u ", ntohs(dport));
 
-		if (flags & TUNNEL_ENCAP_FLAG_CSUM)
-			fputs("encap-csum ", f);
-		else
-			fputs("noencap-csum ", f);
+			if (flags & TUNNEL_ENCAP_FLAG_CSUM)
+				fputs("encap-csum ", f);
+			else
+				fputs("noencap-csum ", f);
 
-		if (flags & TUNNEL_ENCAP_FLAG_CSUM6)
-			fputs("encap-csum6 ", f);
-		else
-			fputs("noencap-csum6 ", f);
+			if (flags & TUNNEL_ENCAP_FLAG_CSUM6)
+				fputs("encap-csum6 ", f);
+			else
+				fputs("noencap-csum6 ", f);
 
-		if (flags & TUNNEL_ENCAP_FLAG_REMCSUM)
-			fputs("encap-remcsum ", f);
-		else
-			fputs("noencap-remcsum ", f);
+			if (flags & TUNNEL_ENCAP_FLAG_REMCSUM)
+				fputs("encap-remcsum ", f);
+			else
+				fputs("noencap-remcsum ", f);
+		}
 	}
 
-	if (tb[IFLA_IPTUN_FWMARK] && rta_getattr_u32(tb[IFLA_IPTUN_FWMARK]))
-		fprintf(f, "fwmark 0x%x ",
-			rta_getattr_u32(tb[IFLA_IPTUN_FWMARK]));
+	if (tb[IFLA_IPTUN_FWMARK]) {
+		__u32 fwmark = rta_getattr_u32(tb[IFLA_IPTUN_FWMARK]);
+
+		if (fwmark) {
+			snprintf(s2, sizeof(s2), "0x%x", fwmark);
+
+			print_string(PRINT_ANY, "fwmark", "fwmark %s ", s2);
+		}
+	}
 }
 
 static void iptunnel_print_help(struct link_util *lu, int argc, char **argv,
-- 
2.13.3
