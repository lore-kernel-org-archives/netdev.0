From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH RFC v1 2/2] ethtool: add support to specify ring_cookie as VF/queue
Date: Tue,  6 Dec 2016 04:40:31 -0800
Message-ID: <20161206124031.32346-3-jacob.e.keller@intel.com>
References: <20161206124031.32346-1-jacob.e.keller@intel.com>
Cc: netdev@vger.kernel.org, Jacob Keller <jacob.e.keller@intel.com>
To: "John W . Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:18386 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753085AbcLFMkj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 6 Dec 2016 07:40:39 -0500
In-Reply-To: <20161206124031.32346-1-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to allow users to specify the ring_cookie as a VF/queue
value, ie: '0/25' means direct to the physical function queue 25, while
'3/10' means to direct to VF id 3, queue 10. It is driver dependent to
determine what the VF id is, excepting that 0 indicates the physical
function. This allows the user to more easily specify the matching
notation as it is understood by the kernel and some drivers. Since no
driver exists today with over 2,147,483,647 queues, this notation will
simply fail on drivers which don't recognize the new partitioning.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
---
 ethtool.8.in |  3 ++-
 rxclass.c    | 58 +++++++++++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 53 insertions(+), 8 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 5c36c06385f6..cb165fa4c77a 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -826,7 +826,8 @@ Specifies the Rx queue to send packets to, or some other action.
 nokeep;
 lB	l.
 -1	Drop the matched flow
-0 or higher	Rx queue to route the flow
+0 or higher	Route flow to specific Rx queue on the physical function
+N/M	Route flow to Rx queue M of specific virtual function N (0 indicates the physical function)
 .TE
 .TP
 .BI loc \ N
diff --git a/rxclass.c b/rxclass.c
index 7f0e765d3b47..de25550529b4 100644
--- a/rxclass.c
+++ b/rxclass.c
@@ -614,6 +614,7 @@ typedef enum {
 	OPT_IP4,
 	OPT_IP6,
 	OPT_MAC,
+	OPT_ACTION,
 } rule_opt_type_t;
 
 #define NFC_FLAG_RING		0x001
@@ -654,7 +655,7 @@ static const struct rule_opts rule_nfc_tcp_ip4[] = {
 	{ "dst-port", OPT_BE16, NFC_FLAG_DPORT,
 	  offsetof(struct ethtool_rx_flow_spec, h_u.tcp_ip4_spec.pdst),
 	  offsetof(struct ethtool_rx_flow_spec, m_u.tcp_ip4_spec.pdst) },
-	{ "action", OPT_U64, NFC_FLAG_RING,
+	{ "action", OPT_ACTION, NFC_FLAG_RING,
 	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
 	{ "loc", OPT_U32, NFC_FLAG_LOC,
 	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
@@ -685,7 +686,7 @@ static const struct rule_opts rule_nfc_esp_ip4[] = {
 	{ "spi", OPT_BE32, NFC_FLAG_SPI,
 	  offsetof(struct ethtool_rx_flow_spec, h_u.esp_ip4_spec.spi),
 	  offsetof(struct ethtool_rx_flow_spec, m_u.esp_ip4_spec.spi) },
-	{ "action", OPT_U64, NFC_FLAG_RING,
+	{ "action", OPT_ACTION, NFC_FLAG_RING,
 	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
 	{ "loc", OPT_U32, NFC_FLAG_LOC,
 	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
@@ -728,7 +729,7 @@ static const struct rule_opts rule_nfc_usr_ip4[] = {
 	{ "dst-port", OPT_BE16, NFC_FLAG_DPORT,
 	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip4_spec.l4_4_bytes) + 2,
 	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip4_spec.l4_4_bytes) + 2 },
-	{ "action", OPT_U64, NFC_FLAG_RING,
+	{ "action", OPT_ACTION, NFC_FLAG_RING,
 	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
 	{ "loc", OPT_U32, NFC_FLAG_LOC,
 	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
@@ -762,7 +763,7 @@ static const struct rule_opts rule_nfc_tcp_ip6[] = {
 	{ "dst-port", OPT_BE16, NFC_FLAG_DPORT,
 	  offsetof(struct ethtool_rx_flow_spec, h_u.tcp_ip6_spec.pdst),
 	  offsetof(struct ethtool_rx_flow_spec, m_u.tcp_ip6_spec.pdst) },
-	{ "action", OPT_U64, NFC_FLAG_RING,
+	{ "action", OPT_ACTION, NFC_FLAG_RING,
 	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
 	{ "loc", OPT_U32, NFC_FLAG_LOC,
 	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
@@ -793,7 +794,7 @@ static const struct rule_opts rule_nfc_esp_ip6[] = {
 	{ "spi", OPT_BE32, NFC_FLAG_SPI,
 	  offsetof(struct ethtool_rx_flow_spec, h_u.esp_ip6_spec.spi),
 	  offsetof(struct ethtool_rx_flow_spec, m_u.esp_ip6_spec.spi) },
-	{ "action", OPT_U64, NFC_FLAG_RING,
+	{ "action", OPT_ACTION, NFC_FLAG_RING,
 	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
 	{ "loc", OPT_U32, NFC_FLAG_LOC,
 	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
@@ -836,7 +837,7 @@ static const struct rule_opts rule_nfc_usr_ip6[] = {
 	{ "dst-port", OPT_BE16, NFC_FLAG_DPORT,
 	  offsetof(struct ethtool_rx_flow_spec, h_u.usr_ip6_spec.l4_4_bytes) + 2,
 	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip6_spec.l4_4_bytes) + 2 },
-	{ "action", OPT_U64, NFC_FLAG_RING,
+	{ "action", OPT_ACTION, NFC_FLAG_RING,
 	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
 	{ "loc", OPT_U32, NFC_FLAG_LOC,
 	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
@@ -864,7 +865,7 @@ static const struct rule_opts rule_nfc_ether[] = {
 	{ "proto", OPT_BE16, NFC_FLAG_PROTO,
 	  offsetof(struct ethtool_rx_flow_spec, h_u.ether_spec.h_proto),
 	  offsetof(struct ethtool_rx_flow_spec, m_u.ether_spec.h_proto) },
-	{ "action", OPT_U64, NFC_FLAG_RING,
+	{ "action", OPT_ACTION, NFC_FLAG_RING,
 	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
 	{ "loc", OPT_U32, NFC_FLAG_LOC,
 	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
@@ -948,6 +949,40 @@ static int rxclass_get_ether(char *str, unsigned char *val)
 	return 0;
 }
 
+static int rxclass_get_action(char *str, unsigned long long *val)
+{
+	const long long max_queue = ~0ULL >> 32;
+	const long long max_vf = ~0ULL >> 8;
+	char *end_vf, *end_queue;
+	unsigned long long queue, vf;
+
+	/* If there is no '/' just read the full value like a u64 */
+	if (!strchr(str, '/'))
+		return rxclass_get_ulong(str, val, 64);
+
+	errno = 0;
+
+	vf = strtoull(str, &end_vf, 0);
+
+	/*
+	 * Ensure that we consume everything up to the slash, and that there
+	 * is more than the empty string following the slash.
+	 */
+	if ((*end_vf != '/') || !(*(end_vf + 1)) || errno || (vf > max_vf))
+		return -1;
+
+	errno = 0;
+
+	queue = strtoull(end_vf + 1, &end_queue, 0);
+
+	if (*end_queue || errno || (queue > max_queue))
+		return -1;
+
+	*val = (vf << ETHTOOL_RX_FLOW_SPEC_RING_VF_OFF) | queue;
+
+	return 0;
+}
+
 static int rxclass_get_val(char *str, unsigned char *p, u32 *flags,
 			   const struct rule_opts *opt)
 {
@@ -1070,6 +1105,14 @@ static int rxclass_get_val(char *str, unsigned char *p, u32 *flags,
 			memcpy(&p[opt->moffset], &mask, ETH_ALEN);
 		break;
 	}
+	case OPT_ACTION: {
+		unsigned long long val;
+		err = rxclass_get_action(str, &val);
+		if (err)
+			return -1;
+		*(u64 *)&p[opt->offset] = (u64)val;
+		break;
+	}
 	case OPT_NONE:
 	default:
 		return -1;
@@ -1183,6 +1226,7 @@ static int rxclass_get_mask(char *str, unsigned char *p,
 		memcpy(&p[opt->moffset], val, ETH_ALEN);
 		break;
 	}
+	case OPT_ACTION:
 	case OPT_NONE:
 	default:
 		return -1;
-- 
2.11.0.rc2.152.g4d04e67
