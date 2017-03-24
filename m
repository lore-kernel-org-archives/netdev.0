From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [ethtool] ethtool: support queue and VF fields for rxclass filters
Date: Thu, 23 Mar 2017 23:07:13 -0700
Message-ID: <20170324060713.81808-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:27298 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751235AbdCXGHV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 24 Mar 2017 02:07:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Recent kernels have made it possible to specify filters applying to
a virtual function by partitioning the ring_cookie (action) value. The
lower 32bits will represent the queue, while the next 8bits represent
the virtual function.

Add support to view and specify the ring_cookie in this way so that
users do not have to manually create action values, and don't need to
understand the underlying layout of the ring_cookie value.

Support using queue and VF fields which will fill in their specific bits
of the ring_cookie value, using new customized OPT_RING_VF and
OPT_RING_QUEUE.

Add support to display the ring cookie value as a split VF identifier
and queue.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 ethtool.8.in |   7 ++++
 rxclass.c    | 102 +++++++++++++++++++++++++++++++++++++++++++++++++----------
 2 files changed, 92 insertions(+), 17 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index aad96b7..13bc8b1 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -835,6 +835,13 @@ lB	l.
 0 or higher	Rx queue to route the flow
 .TE
 .TP
+.BI vf \ N
+Specifies the Virtual Function the filter applies to. A value of 0 indicates
+the PF, and thus the VF index is offset by 1. Not compatible with action.
+.TP
+.BI queue \ N
+Specifies the Rx queue to send packets to. Not compatible with action.
+.TP
 .BI loc \ N
 Specify the location/ID to insert the rule. This will overwrite
 any rule present in that location and will not go through any
diff --git a/rxclass.c b/rxclass.c
index c7bfeba..ebc3e1a 100644
--- a/rxclass.c
+++ b/rxclass.c
@@ -247,11 +247,19 @@ static void rxclass_print_nfc_rule(struct ethtool_rx_flow_spec *fsp)
 
 	rxclass_print_nfc_spec_ext(fsp);
 
-	if (fsp->ring_cookie != RX_CLS_FLOW_DISC)
-		fprintf(stdout, "\tAction: Direct to queue %llu\n",
-			fsp->ring_cookie);
-	else
+	if (fsp->ring_cookie != RX_CLS_FLOW_DISC) {
+		u64 vf = ethtool_get_flow_spec_ring_vf(fsp->ring_cookie);
+		u64 queue = ethtool_get_flow_spec_ring(fsp->ring_cookie);
+
+		if (vf)
+			fprintf(stdout, "\tAction: Direct to queue %llu\n",
+				queue);
+		else
+			fprintf(stdout, "\tAction: Direct to VF %llu queue %llu\n",
+				vf, queue);
+	} else {
 		fprintf(stdout, "\tAction: Drop\n");
+	}
 
 	fprintf(stdout, "\n");
 }
@@ -600,6 +608,8 @@ typedef enum {
 	OPT_U16,
 	OPT_U32,
 	OPT_U64,
+	OPT_RING_VF,
+	OPT_RING_QUEUE,
 	OPT_BE16,
 	OPT_BE32,
 	OPT_BE64,
@@ -608,19 +618,21 @@ typedef enum {
 	OPT_MAC,
 } rule_opt_type_t;
 
-#define NFC_FLAG_RING		0x001
-#define NFC_FLAG_LOC		0x002
-#define NFC_FLAG_SADDR		0x004
-#define NFC_FLAG_DADDR		0x008
-#define NFC_FLAG_SPORT		0x010
-#define NFC_FLAG_DPORT		0x020
-#define NFC_FLAG_SPI		0x030
-#define NFC_FLAG_TOS		0x040
-#define NFC_FLAG_PROTO		0x080
-#define NTUPLE_FLAG_VLAN	0x100
-#define NTUPLE_FLAG_UDEF	0x200
-#define NTUPLE_FLAG_VETH	0x400
-#define NFC_FLAG_MAC_ADDR	0x800
+#define NFC_FLAG_RING		0x0001
+#define NFC_FLAG_LOC		0x0002
+#define NFC_FLAG_SADDR		0x0004
+#define NFC_FLAG_DADDR		0x0008
+#define NFC_FLAG_SPORT		0x0010
+#define NFC_FLAG_DPORT		0x0020
+#define NFC_FLAG_SPI		0x0030
+#define NFC_FLAG_TOS		0x0040
+#define NFC_FLAG_PROTO		0x0080
+#define NTUPLE_FLAG_VLAN	0x0100
+#define NTUPLE_FLAG_UDEF	0x0200
+#define NTUPLE_FLAG_VETH	0x0400
+#define NFC_FLAG_MAC_ADDR	0x0800
+#define NFC_FLAG_RING_VF	0x1000
+#define NFC_FLAG_RING_QUEUE	0x2000
 
 struct rule_opts {
 	const char	*name;
@@ -648,6 +660,10 @@ static const struct rule_opts rule_nfc_tcp_ip4[] = {
 	  offsetof(struct ethtool_rx_flow_spec, m_u.tcp_ip4_spec.pdst) },
 	{ "action", OPT_U64, NFC_FLAG_RING,
 	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
+	{ "vf", OPT_RING_VF, NFC_FLAG_RING_VF,
+	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
+	{ "queue", OPT_RING_QUEUE, NFC_FLAG_RING_QUEUE,
+	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
 	{ "loc", OPT_U32, NFC_FLAG_LOC,
 	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
 	{ "vlan-etype", OPT_BE16, NTUPLE_FLAG_VETH,
@@ -679,6 +695,10 @@ static const struct rule_opts rule_nfc_esp_ip4[] = {
 	  offsetof(struct ethtool_rx_flow_spec, m_u.esp_ip4_spec.spi) },
 	{ "action", OPT_U64, NFC_FLAG_RING,
 	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
+	{ "vf", OPT_RING_VF, NFC_FLAG_RING_VF,
+	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
+	{ "queue", OPT_RING_QUEUE, NFC_FLAG_RING_QUEUE,
+	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
 	{ "loc", OPT_U32, NFC_FLAG_LOC,
 	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
 	{ "vlan-etype", OPT_BE16, NTUPLE_FLAG_VETH,
@@ -722,6 +742,10 @@ static const struct rule_opts rule_nfc_usr_ip4[] = {
 	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip4_spec.l4_4_bytes) + 2 },
 	{ "action", OPT_U64, NFC_FLAG_RING,
 	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
+	{ "vf", OPT_RING_VF, NFC_FLAG_RING_VF,
+	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
+	{ "queue", OPT_RING_QUEUE, NFC_FLAG_RING_QUEUE,
+	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
 	{ "loc", OPT_U32, NFC_FLAG_LOC,
 	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
 	{ "vlan-etype", OPT_BE16, NTUPLE_FLAG_VETH,
@@ -756,6 +780,10 @@ static const struct rule_opts rule_nfc_tcp_ip6[] = {
 	  offsetof(struct ethtool_rx_flow_spec, m_u.tcp_ip6_spec.pdst) },
 	{ "action", OPT_U64, NFC_FLAG_RING,
 	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
+	{ "vf", OPT_RING_VF, NFC_FLAG_RING_VF,
+	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
+	{ "queue", OPT_RING_QUEUE, NFC_FLAG_RING_QUEUE,
+	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
 	{ "loc", OPT_U32, NFC_FLAG_LOC,
 	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
 	{ "vlan-etype", OPT_BE16, NTUPLE_FLAG_VETH,
@@ -787,6 +815,10 @@ static const struct rule_opts rule_nfc_esp_ip6[] = {
 	  offsetof(struct ethtool_rx_flow_spec, m_u.esp_ip6_spec.spi) },
 	{ "action", OPT_U64, NFC_FLAG_RING,
 	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
+	{ "vf", OPT_RING_VF, NFC_FLAG_RING_VF,
+	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
+	{ "queue", OPT_RING_QUEUE, NFC_FLAG_RING_QUEUE,
+	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
 	{ "loc", OPT_U32, NFC_FLAG_LOC,
 	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
 	{ "vlan-etype", OPT_BE16, NTUPLE_FLAG_VETH,
@@ -830,6 +862,10 @@ static const struct rule_opts rule_nfc_usr_ip6[] = {
 	  offsetof(struct ethtool_rx_flow_spec, m_u.usr_ip6_spec.l4_4_bytes) + 2 },
 	{ "action", OPT_U64, NFC_FLAG_RING,
 	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
+	{ "vf", OPT_RING_VF, NFC_FLAG_RING_VF,
+	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
+	{ "queue", OPT_RING_QUEUE, NFC_FLAG_RING_QUEUE,
+	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
 	{ "loc", OPT_U32, NFC_FLAG_LOC,
 	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
 	{ "vlan-etype", OPT_BE16, NTUPLE_FLAG_VETH,
@@ -858,6 +894,10 @@ static const struct rule_opts rule_nfc_ether[] = {
 	  offsetof(struct ethtool_rx_flow_spec, m_u.ether_spec.h_proto) },
 	{ "action", OPT_U64, NFC_FLAG_RING,
 	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
+	{ "vf", OPT_RING_VF, NFC_FLAG_RING_VF,
+	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
+	{ "queue", OPT_RING_QUEUE, NFC_FLAG_RING_QUEUE,
+	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
 	{ "loc", OPT_U32, NFC_FLAG_LOC,
 	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
 	{ "vlan-etype", OPT_BE16, NTUPLE_FLAG_VETH,
@@ -1002,6 +1042,24 @@ static int rxclass_get_val(char *str, unsigned char *p, u32 *flags,
 			*(u64 *)&p[opt->moffset] = (u64)mask;
 		break;
 	}
+	case OPT_RING_VF: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 8);
+		if (err)
+			return -1;
+		*(u64 *)&p[opt->offset] &= ~ETHTOOL_RX_FLOW_SPEC_RING_VF;
+		*(u64 *)&p[opt->offset] = (u64)val << ETHTOOL_RX_FLOW_SPEC_RING_VF_OFF;
+		break;
+	}
+	case OPT_RING_QUEUE: {
+		unsigned long long val;
+		err = rxclass_get_ulong(str, &val, 32);
+		if (err)
+			return -1;
+		*(u64 *)&p[opt->offset] &= ~ETHTOOL_RX_FLOW_SPEC_RING;
+		*(u64 *)&p[opt->offset] |= (u64)val;
+		break;
+	}
 	case OPT_BE16: {
 		unsigned long long val;
 		err = rxclass_get_ulong(str, &val, 16);
@@ -1320,6 +1378,16 @@ int rxclass_parse_ruleopts(struct cmd_context *ctx,
 		}
 	}
 
+	if ((flags & NFC_FLAG_RING) && (flags & NFC_FLAG_RING_QUEUE)) {
+		fprintf(stderr, "action and queue are not compatible\n");
+			return -1;
+	}
+
+	if ((flags & NFC_FLAG_RING) && (flags & NFC_FLAG_RING_VF)) {
+		fprintf(stderr, "action and vf are not compatible\n");
+			return -1;
+	}
+
 	if (flow_type == IPV4_USER_FLOW)
 		fsp->h_u.usr_ip4_spec.ip_ver = ETH_RX_NFC_IP4;
 	if (flags & (NTUPLE_FLAG_VLAN | NTUPLE_FLAG_UDEF | NTUPLE_FLAG_VETH))
-- 
2.12.0
