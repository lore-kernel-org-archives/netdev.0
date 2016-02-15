From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH ethtool 2/3] Add IPv6 support to NFC
Date: Mon, 15 Feb 2016 14:59:56 +0000
Message-ID: <56C1E7EC.8020700@solarflare.com>
References: <56C1E73A.5090603@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Ben Hutchings <bwh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:60894 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753394AbcBOPAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 10:00:04 -0500
In-Reply-To: <56C1E73A.5090603@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 ethtool.c |  21 +++++
 rxclass.c | 272 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 279 insertions(+), 14 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 92c40b8..f18ad73 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -32,6 +32,7 @@
 #include <sys/stat.h>
 #include <stdio.h>
 #include <stddef.h>
+#include <stdbool.h>
 #include <errno.h>
 #include <sys/utsname.h>
 #include <limits.h>
@@ -3492,6 +3493,22 @@ static int do_permaddr(struct cmd_context *ctx)
 	return err;
 }
 
+static bool flow_type_is_ntuple_supported(__u32 flow_type)
+{
+	switch (flow_type) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+	case SCTP_V4_FLOW:
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+	case IPV4_USER_FLOW:
+	case ETHER_FLOW:
+		return true;
+	default:
+		return false;
+	}
+}
+
 static int flow_spec_to_ntuple(struct ethtool_rx_flow_spec *fsp,
 			       struct ethtool_rx_ntuple_flow_spec *ntuple)
 {
@@ -3515,6 +3532,10 @@ static int flow_spec_to_ntuple(struct ethtool_rx_flow_spec *fsp,
 	    fsp->m_ext.vlan_etype)
 		return -1;
 
+	/* IPv6 flow types are not supported by ntuple */
+	if (!flow_type_is_ntuple_supported(fsp->flow_type & ~FLOW_EXT))
+		return -1;
+
 	/* Set entire ntuple to ~0 to guarantee all masks are set */
 	memset(ntuple, ~0, sizeof(*ntuple));
 
diff --git a/rxclass.c b/rxclass.c
index cd686a3..d3150d5 100644
--- a/rxclass.c
+++ b/rxclass.c
@@ -39,6 +39,25 @@ static void rxclass_print_ipv4_rule(__be32 sip, __be32 sipm, __be32 dip,
 		tos, tosm);
 }
 
+static void rxclass_print_ipv6_rule(__be32 *sip, __be32 *sipm, __be32 *dip,
+				    __be32 *dipm, u8 tclass, u8 tclassm)
+{
+	char sip_str[INET6_ADDRSTRLEN];
+	char sipm_str[INET6_ADDRSTRLEN];
+	char dip_str[INET6_ADDRSTRLEN];
+	char dipm_str[INET6_ADDRSTRLEN];
+
+	fprintf(stdout,
+		"\tSrc IP addr: %s mask: %s\n"
+		"\tDest IP addr: %s mask: %s\n"
+		"\tTraffic Class: 0x%x mask: 0x%x\n",
+		inet_ntop(AF_INET6, sip, sip_str, INET6_ADDRSTRLEN),
+		inet_ntop(AF_INET6, sipm, sipm_str, INET6_ADDRSTRLEN),
+		inet_ntop(AF_INET6, dip, dip_str, INET6_ADDRSTRLEN),
+		inet_ntop(AF_INET6, dipm, dipm_str, INET6_ADDRSTRLEN),
+		tclass, tclassm);
+}
+
 static void rxclass_print_nfc_spec_ext(struct ethtool_rx_flow_spec *fsp)
 {
 	if (fsp->flow_type & FLOW_EXT) {
@@ -127,7 +146,7 @@ static void rxclass_print_nfc_rule(struct ethtool_rx_flow_spec *fsp)
 			ntohl(fsp->h_u.esp_ip4_spec.spi),
 			ntohl(fsp->m_u.esp_ip4_spec.spi));
 		break;
-	case IP_USER_FLOW:
+	case IPV4_USER_FLOW:
 		fprintf(stdout, "\tRule Type: Raw IPv4\n");
 		rxclass_print_ipv4_rule(fsp->h_u.usr_ip4_spec.ip4src,
 				     fsp->m_u.usr_ip4_spec.ip4src,
@@ -143,6 +162,62 @@ static void rxclass_print_nfc_rule(struct ethtool_rx_flow_spec *fsp)
 			ntohl(fsp->h_u.usr_ip4_spec.l4_4_bytes),
 			ntohl(fsp->m_u.usr_ip4_spec.l4_4_bytes));
 		break;
+	case TCP_V6_FLOW:
+	case UDP_V6_FLOW:
+	case SCTP_V6_FLOW:
+		if (flow_type == TCP_V6_FLOW)
+			fprintf(stdout, "\tRule Type: TCP over IPv6\n");
+		else if (flow_type == UDP_V6_FLOW)
+			fprintf(stdout, "\tRule Type: UDP over IPv6\n");
+		else
+			fprintf(stdout, "\tRule Type: SCTP over IPv6\n");
+		rxclass_print_ipv6_rule(fsp->h_u.tcp_ip6_spec.ip6src,
+				     fsp->m_u.tcp_ip6_spec.ip6src,
+				     fsp->h_u.tcp_ip6_spec.ip6dst,
+				     fsp->m_u.tcp_ip6_spec.ip6dst,
+				     fsp->h_u.tcp_ip6_spec.tclass,
+				     fsp->m_u.tcp_ip6_spec.tclass);
+		fprintf(stdout,
+			"\tSrc port: %d mask: 0x%x\n"
+			"\tDest port: %d mask: 0x%x\n",
+			ntohs(fsp->h_u.tcp_ip6_spec.psrc),
+			ntohs(fsp->m_u.tcp_ip6_spec.psrc),
+			ntohs(fsp->h_u.tcp_ip6_spec.pdst),
+			ntohs(fsp->m_u.tcp_ip6_spec.pdst));
+		break;
+	case AH_V6_FLOW:
+	case ESP_V6_FLOW:
+		if (flow_type == AH_V6_FLOW)
+			fprintf(stdout, "\tRule Type: IPSEC AH over IPv6\n");
+		else
+			fprintf(stdout, "\tRule Type: IPSEC ESP over IPv6\n");
+		rxclass_print_ipv6_rule(fsp->h_u.ah_ip6_spec.ip6src,
+				     fsp->m_u.ah_ip6_spec.ip6src,
+				     fsp->h_u.ah_ip6_spec.ip6dst,
+				     fsp->m_u.ah_ip6_spec.ip6dst,
+				     fsp->h_u.ah_ip6_spec.tclass,
+				     fsp->m_u.ah_ip6_spec.tclass);
+		fprintf(stdout,
+			"\tSPI: %d mask: 0x%x\n",
+			ntohl(fsp->h_u.esp_ip6_spec.spi),
+			ntohl(fsp->m_u.esp_ip6_spec.spi));
+		break;
+	case IPV6_USER_FLOW:
+		fprintf(stdout, "\tRule Type: Raw IPv6\n");
+		rxclass_print_ipv6_rule(fsp->h_u.usr_ip6_spec.ip6src,
+				     fsp->m_u.usr_ip6_spec.ip6src,
+				     fsp->h_u.usr_ip6_spec.ip6dst,
+				     fsp->m_u.usr_ip6_spec.ip6dst,
+				     fsp->h_u.usr_ip6_spec.tclass,
+				     fsp->m_u.usr_ip6_spec.tclass);
+		fprintf(stdout,
+			"\tProtocol: %d mask: 0x%x\n"
+			"\tL4 bytes: 0x%x mask: 0x%x\n",
+			fsp->h_u.usr_ip6_spec.l4_proto,
+			fsp->m_u.usr_ip6_spec.l4_proto,
+			ntohl(fsp->h_u.usr_ip6_spec.l4_4_bytes),
+			ntohl(fsp->m_u.usr_ip6_spec.l4_4_bytes));
+		break;
 	case ETHER_FLOW:
 		dmac = fsp->h_u.ether_spec.h_dest;
 		dmacm = fsp->m_u.ether_spec.h_dest;
@@ -190,21 +265,20 @@ static void rxclass_print_rule(struct ethtool_rx_flow_spec *fsp)
 	case SCTP_V4_FLOW:
 	case AH_V4_FLOW:
 	case ESP_V4_FLOW:
-	case ETHER_FLOW:
-		rxclass_print_nfc_rule(fsp);
-		break;
-	case IP_USER_FLOW:
-		if (fsp->h_u.usr_ip4_spec.ip_ver == ETH_RX_NFC_IP4) {
-			rxclass_print_nfc_rule(fsp);
-			break;
-		}
-		/* IPv6 User Flow falls through to the case below */
 	case TCP_V6_FLOW:
 	case UDP_V6_FLOW:
 	case SCTP_V6_FLOW:
 	case AH_V6_FLOW:
 	case ESP_V6_FLOW:
-		fprintf(stderr, "IPv6 flows not implemented\n");
+	case IPV6_USER_FLOW:
+	case ETHER_FLOW:
+		rxclass_print_nfc_rule(fsp);
+		break;
+	case IPV4_USER_FLOW:
+		if (fsp->h_u.usr_ip4_spec.ip_ver == ETH_RX_NFC_IP4)
+			rxclass_print_nfc_rule(fsp);
+		else /* IPv6 uses IPV6_USER_FLOW */
+			fprintf(stderr, "IPV4_USER_FLOW with wrong ip_ver\n");
 		break;
 	default:
 		fprintf(stderr, "rxclass: Unknown flow type\n");
@@ -530,6 +604,7 @@ typedef enum {
 	OPT_BE32,
 	OPT_BE64,
 	OPT_IP4,
+	OPT_IP6,
 	OPT_MAC,
 } rule_opt_type_t;
 
@@ -663,6 +738,114 @@ static const struct rule_opts rule_nfc_usr_ip4[] = {
 	  offsetof(struct ethtool_rx_flow_spec, m_ext.h_dest) },
 };
 
+static const struct rule_opts rule_nfc_tcp_ip6[] = {
+	{ "src-ip", OPT_IP6, NFC_FLAG_SADDR,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.tcp_ip6_spec.ip6src),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.tcp_ip6_spec.ip6src) },
+	{ "dst-ip", OPT_IP6, NFC_FLAG_DADDR,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.tcp_ip6_spec.ip6dst),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.tcp_ip6_spec.ip6dst) },
+	{ "tclass", OPT_U8, NFC_FLAG_TOS,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.tcp_ip6_spec.tclass),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.tcp_ip6_spec.tclass) },
+	{ "src-port", OPT_BE16, NFC_FLAG_SPORT,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.tcp_ip6_spec.psrc),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.tcp_ip6_spec.psrc) },
+	{ "dst-port", OPT_BE16, NFC_FLAG_DPORT,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.tcp_ip6_spec.pdst),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.tcp_ip6_spec.pdst) },
+	{ "action", OPT_U64, NFC_FLAG_RING,
+	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
+	{ "loc", OPT_U32, NFC_FLAG_LOC,
+	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
+	{ "vlan-etype", OPT_BE16, NTUPLE_FLAG_VETH,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.vlan_etype),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.vlan_etype) },
+	{ "vlan", OPT_BE16, NTUPLE_FLAG_VLAN,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.vlan_tci),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.vlan_tci) },
+	{ "user-def", OPT_BE64, NTUPLE_FLAG_UDEF,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.data),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.data) },
+	{ "dst-mac", OPT_MAC, NFC_FLAG_MAC_ADDR,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.h_dest),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.h_dest) },
+};
+
+static const struct rule_opts rule_nfc_esp_ip6[] = {
+	{ "src-ip", OPT_IP6, NFC_FLAG_SADDR,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.esp_ip6_spec.ip6src),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.esp_ip6_spec.ip6src) },
+	{ "dst-ip", OPT_IP6, NFC_FLAG_DADDR,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.esp_ip6_spec.ip6dst),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.esp_ip6_spec.ip6dst) },
+	{ "tclass", OPT_U8, NFC_FLAG_TOS,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.esp_ip6_spec.tclass),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.esp_ip6_spec.tclass) },
+	{ "spi", OPT_BE32, NFC_FLAG_SPI,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.esp_ip6_spec.spi),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.esp_ip6_spec.spi) },
+	{ "action", OPT_U64, NFC_FLAG_RING,
+	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
+	{ "loc", OPT_U32, NFC_FLAG_LOC,
+	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
+	{ "vlan-etype", OPT_BE16, NTUPLE_FLAG_VETH,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.vlan_etype),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.vlan_etype) },
+	{ "vlan", OPT_BE16, NTUPLE_FLAG_VLAN,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.vlan_tci),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.vlan_tci) },
+	{ "user-def", OPT_BE64, NTUPLE_FLAG_UDEF,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.data),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.data) },
+	{ "dst-mac", OPT_MAC, NFC_FLAG_MAC_ADDR,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.h_dest),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.h_dest) },
+};
+
+static const struct rule_opts rule_nfc_usr_ip6[] = {
+	{ "src-ip", OPT_IP6, NFC_FLAG_SADDR,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip6_spec.ip6src),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip6_spec.ip6src) },
+	{ "dst-ip", OPT_IP6, NFC_FLAG_DADDR,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip6_spec.ip6dst),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip6_spec.ip6dst) },
+	{ "tclass", OPT_U8, NFC_FLAG_TOS,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip6_spec.tclass),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip6_spec.tclass) },
+	{ "l4proto", OPT_U8, NFC_FLAG_PROTO,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip6_spec.l4_proto),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip6_spec.l4_proto) },
+	{ "l4data", OPT_BE32, NFC_FLAG_SPI,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip6_spec.l4_4_bytes),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip6_spec.l4_4_bytes) },
+	{ "spi", OPT_BE32, NFC_FLAG_SPI,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip6_spec.l4_4_bytes),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip6_spec.l4_4_bytes) },
+	{ "src-port", OPT_BE16, NFC_FLAG_SPORT,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip6_spec.l4_4_bytes),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip6_spec.l4_4_bytes) },
+	{ "dst-port", OPT_BE16, NFC_FLAG_DPORT,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip6_spec.l4_4_bytes) + 2,
+	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip6_spec.l4_4_bytes) + 2 },
+	{ "action", OPT_U64, NFC_FLAG_RING,
+	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
+	{ "loc", OPT_U32, NFC_FLAG_LOC,
+	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
+	{ "vlan-etype", OPT_BE16, NTUPLE_FLAG_VETH,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.vlan_etype),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.vlan_etype) },
+	{ "vlan", OPT_BE16, NTUPLE_FLAG_VLAN,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.vlan_tci),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.vlan_tci) },
+	{ "user-def", OPT_BE64, NTUPLE_FLAG_UDEF,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.data),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.data) },
+	{ "dst-mac", OPT_MAC, NFC_FLAG_MAC_ADDR,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.h_dest),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.h_dest) },
+};
+
 static const struct rule_opts rule_nfc_ether[] = {
 	{ "src", OPT_MAC, NFC_FLAG_SADDR,
 	  offsetof(struct ethtool_rx_flow_spec, h_u.ether_spec.h_source),
@@ -726,6 +909,14 @@ static int rxclass_get_ipv4(char *str, __be32 *val)
 	return 0;
 }
 
+static int rxclass_get_ipv6(char *str, __be32 *val)
+{
+	if (!inet_pton(AF_INET6, str, val))
+		return -1;
+
+	return 0;
+}
+
 static int rxclass_get_ether(char *str, unsigned char *val)
 {
 	unsigned int buf[ETH_ALEN];
@@ -851,6 +1042,19 @@ static int rxclass_get_val(char *str, unsigned char *p, u32 *flags,
 			*(__be32 *)&p[opt->moffset] = (__be32)mask;
 		break;
 	}
+	case OPT_IP6: {
+		__be32 val[4];
+		int i;
+		err = rxclass_get_ipv6(str, val);
+		if (err)
+			return -1;
+		for (i = 0; i < 4; i++) {
+			((__be32 *)&p[opt->offset])[i] = val[i];
+			if (opt->moffset >= 0)
+				((__be32 *)&p[opt->moffset])[i] = (__be32)mask;
+		}
+		break;
+	}
 	case OPT_MAC: {
 		unsigned char val[ETH_ALEN];
 		err = rxclass_get_ether(str, val);
@@ -950,6 +1154,19 @@ static int rxclass_get_mask(char *str, unsigned char *p,
 		*(__be32 *)&p[opt->moffset] = ~val;
 		break;
 	}
+	case OPT_IP6: {
+		__be32 val[4];
+		int i;
+		err = rxclass_get_ipv6(str, val);
+		if (err)
+			return -1;
+		for (i = 0; i < 4; i++) {
+			((__be32 *)&p[opt->offset])[i] = val[i];
+			if (opt->moffset >= 0)
+				((__be32 *)&p[opt->moffset])[i] = ~val[i];
+		}
+		break;
+	}
 	case OPT_MAC: {
 		unsigned char val[ETH_ALEN];
 		int i;
@@ -996,7 +1213,19 @@ int rxclass_parse_ruleopts(struct cmd_context *ctx,
 	else if (!strcmp(argp[0], "esp4"))
 		flow_type = ESP_V4_FLOW;
 	else if (!strcmp(argp[0], "ip4"))
-		flow_type = IP_USER_FLOW;
+		flow_type = IPV4_USER_FLOW;
+	else if (!strcmp(argp[0], "tcp6"))
+		flow_type = TCP_V6_FLOW;
+	else if (!strcmp(argp[0], "udp6"))
+		flow_type = UDP_V6_FLOW;
+	else if (!strcmp(argp[0], "sctp6"))
+		flow_type = SCTP_V6_FLOW;
+	else if (!strcmp(argp[0], "ah6"))
+		flow_type = AH_V6_FLOW;
+	else if (!strcmp(argp[0], "esp6"))
+		flow_type = ESP_V6_FLOW;
+	else if (!strcmp(argp[0], "ip6"))
+		flow_type = IPV6_USER_FLOW;
 	else if (!strcmp(argp[0], "ether"))
 		flow_type = ETHER_FLOW;
 	else
@@ -1014,10 +1243,25 @@ int rxclass_parse_ruleopts(struct cmd_context *ctx,
 		options = rule_nfc_esp_ip4;
 		n_opts = ARRAY_SIZE(rule_nfc_esp_ip4);
 		break;
-	case IP_USER_FLOW:
+	case IPV4_USER_FLOW:
 		options = rule_nfc_usr_ip4;
 		n_opts = ARRAY_SIZE(rule_nfc_usr_ip4);
 		break;
+	case TCP_V6_FLOW:
+	case UDP_V6_FLOW:
+	case SCTP_V6_FLOW:
+		options = rule_nfc_tcp_ip6;
+		n_opts = ARRAY_SIZE(rule_nfc_tcp_ip6);
+		break;
+	case AH_V6_FLOW:
+	case ESP_V6_FLOW:
+		options = rule_nfc_esp_ip6;
+		n_opts = ARRAY_SIZE(rule_nfc_esp_ip6);
+		break;
+	case IPV6_USER_FLOW:
+		options = rule_nfc_usr_ip6;
+		n_opts = ARRAY_SIZE(rule_nfc_usr_ip6);
+		break;
 	case ETHER_FLOW:
 		options = rule_nfc_ether;
 		n_opts = ARRAY_SIZE(rule_nfc_ether);
@@ -1081,7 +1325,7 @@ int rxclass_parse_ruleopts(struct cmd_context *ctx,
 		}
 	}
 
-	if (flow_type == IP_USER_FLOW)
+	if (flow_type == IPV4_USER_FLOW)
 		fsp->h_u.usr_ip4_spec.ip_ver = ETH_RX_NFC_IP4;
 	if (flags & (NTUPLE_FLAG_VLAN | NTUPLE_FLAG_UDEF | NTUPLE_FLAG_VETH))
 		fsp->flow_type |= FLOW_EXT;
