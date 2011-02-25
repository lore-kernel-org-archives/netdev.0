From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 4/4] Add support for displaying a ntuple contained in
	an rx_flow_spec
Date: Fri, 25 Feb 2011 15:49:01 -0800
Message-ID: <20110225234901.8409.84682.stgit@gitlad.jf.intel.com>
References: <20110225233902.8409.74474.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:22539 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756479Ab1BYXtC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 18:49:02 -0500
In-Reply-To: <20110225233902.8409.74474.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is meant to add support for displaying a ntuple filter by using
the unused space contained within a standard rx_flow_spec.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 ethtool-copy.h |   20 ++++++++++++++++
 ethtool.8.in   |    6 +++++
 ethtool.c      |    3 ++
 rxclass.c      |   72 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 101 insertions(+), 0 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index dd1080b..4401238 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -376,10 +376,25 @@ struct ethtool_usrip4_spec {
 };
 
 /**
+ * struct ethtool_ntuple_spec_ext - flow spec extension for ntuple in nfc
+ * @unused: space unused by extension
+ * @vlan_etype: EtherType for vlan tagged packet to match
+ * @vlan_tci: VLAN tag to match
+ * @data: Driver-dependent data to match
+ */
+struct ethtool_ntuple_spec_ext {
+	__be32	unused[15];
+	__be16	vlan_etype;
+	__be16	vlan_tci;
+	__be32	data[2];
+};
+
+/**
  * struct ethtool_rx_flow_spec - specification for RX flow filter
  * @flow_type: Type of match to perform, e.g. %TCP_V4_FLOW
  * @h_u: Flow fields to match (dependent on @flow_type)
  * @m_u: Masks for flow field bits to be ignored
+ * @flow_type_ext: Type of extended match to perform, e.g. %NTUPLE_FLOW_EXT
  * @ring_cookie: RX ring/queue index to deliver to, or %RX_CLS_FLOW_DISC
  *	if packets should be discarded
  * @location: Index of filter in hardware table
@@ -394,8 +409,10 @@ struct ethtool_rx_flow_spec {
 		struct ethtool_ah_espip4_spec		esp_ip4_spec;
 		struct ethtool_usrip4_spec		usr_ip4_spec;
 		struct ethhdr				ether_spec;
+		struct ethtool_ntuple_spec_ext		ntuple_spec;
 		__u8					hdata[72];
 	} h_u, m_u;
+	__u32		flow_type_ext;
 	__u64		ring_cookie;
 	__u32		location;
 };
@@ -706,6 +723,9 @@ struct ethtool_flash {
 #define	IPV6_FLOW	0x11	/* hash only */
 #define	ETHER_FLOW	0x12	/* spec only (ether_spec) */
 
+/* Flow extension types for network flow classifier */
+#define NTUPLE_FLOW_EXT	0x01 /* indicates ntuple in nfc */
+
 /* L3-L4 network traffic flow hash options */
 #define	RXH_L2DA	(1 << 1)
 #define	RXH_VLAN	(1 << 2)
diff --git a/ethtool.8.in b/ethtool.8.in
index b68b010..9c768fb 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -278,6 +278,9 @@ ethtool \- query or control network driver and hardware settings
 .BM src-port
 .BM dst-port
 .BM spi
+.BM vlan-etype
+.BM vlan
+.BM user-def
 .BN action
 .BN loc
 .RB \ |\  flow-type \ \*(NC
@@ -764,6 +767,9 @@ Specify the value of the security parameter index field (applicable to
 AH/ESP packets)in the incoming packet to match along with an
 optional mask.
 .TP
+.BI vlan-etype \ N \\fR\ [\\fPvlan-etype-mask \ N \\fR]\\fP
+Includes the VLAN tag Ethertype and an optional mask.
+.TP
 .BI vlan \ N \\fR\ [\\fPvlan-mask \ N \\fR]\\fP
 Includes the VLAN tag and an optional mask.
 .TP
diff --git a/ethtool.c b/ethtool.c
index f4dfc39..d931353 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -254,6 +254,9 @@ static struct option {
 		"			[ src-port %d [src-port-mask %x] ]\n"
 		"			[ dst-port %d [dst-port-mask %x] ]\n"
 		"			[ spi %d [spi-mask %x] ]\n"
+		"			[ vlan-etype %x [vlan-etype-mask %x] ]\n"
+		"			[ vlan %x [vlan-mask %x] ]\n"
+		"			[ user-def %x [user-def-mask %x] ]\n"
 		"			[ action %d ]\n"
 		"			[ loc %d] |\n"
 		"		  flow-type ether|ip4|tcp4|udp4|sctp4|ah4|esp4\n"
diff --git a/rxclass.c b/rxclass.c
index f2a8c96..99071a4 100644
--- a/rxclass.c
+++ b/rxclass.c
@@ -30,6 +30,33 @@ struct rmgr_ctrl {
 static struct rmgr_ctrl rmgr;
 static int rmgr_init_done = 0;
 
+static void rmgr_print_nfc_spec_ext(struct ethtool_rx_flow_spec *fsp)
+{
+	u64 data, datam;
+	__u16 etype, etypem, tci, tcim;
+	
+	switch(fsp->flow_type_ext) {
+	case NTUPLE_FLOW_EXT:
+		etype = ntohs(fsp->h_u.ntuple_spec.vlan_etype);
+		etypem = ntohs(fsp->m_u.ntuple_spec.vlan_etype);
+		tci = ntohs(fsp->h_u.ntuple_spec.vlan_tci);
+		tcim = ntohs(fsp->m_u.ntuple_spec.vlan_tci);
+		data = (u64)ntohl(fsp->h_u.ntuple_spec.data[0]);
+		data = (u64)ntohl(fsp->h_u.ntuple_spec.data[1]) << 32;
+		datam = (u64)ntohl(fsp->m_u.ntuple_spec.data[0]);
+		datam = (u64)ntohl(fsp->m_u.ntuple_spec.data[1]) << 32;
+
+		fprintf(stdout,
+			"\tVLAN EtherType: 0x%x mask: 0x%x\n"
+			"\tVLAN: 0x%x mask: 0x%x\n"
+			"\tUser-defined: 0x%Lx mask: 0x%Lx\n",
+			etype, etypem, tci, tcim, data, datam);
+		break;
+	default:
+		break;
+	}
+}
+
 static void rmgr_print_nfc_rule(struct ethtool_rx_flow_spec *fsp)
 {
 	unsigned char	*smac, *smacm, *dmac, *dmacm;
@@ -127,6 +154,7 @@ static void rmgr_print_nfc_rule(struct ethtool_rx_flow_spec *fsp)
 		default:
 			break;
 		}
+		rmgr_print_nfc_spec_ext(fsp);
 		break;
 	case ETHER_FLOW:
 		dmac = fsp->h_u.ether_spec.h_dest;
@@ -148,6 +176,7 @@ static void rmgr_print_nfc_rule(struct ethtool_rx_flow_spec *fsp)
 			dmac[0], dmac[1], dmac[2], dmac[3], dmac[4], dmac[5],
 			dmacm[0], dmacm[1], dmacm[2], dmacm[3], dmacm[4], dmacm[5],
 			proto, protom);
+		rmgr_print_nfc_spec_ext(fsp);
 		break;
 	default:
 		fprintf(stdout,
@@ -516,6 +545,7 @@ typedef enum {
 #define NFC_FLAG_PROTO		0x080
 #define NTUPLE_FLAG_VLAN	0x100
 #define NTUPLE_FLAG_UDEF	0x200
+#define NTUPLE_FLAG_VETH	0x400
 
 struct rule_opts {
 	const char	*name;
@@ -545,6 +575,15 @@ static struct rule_opts rule_nfc_tcp_ip4[] = {
 	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
 	{ "loc", OPT_U32, NFC_FLAG_LOC,
 	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
+	{ "vlan-etype", OPT_BE16, NTUPLE_FLAG_VETH,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.ntuple_spec.vlan_etype),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.ntuple_spec.vlan_etype) },
+	{ "vlan", OPT_BE16, NTUPLE_FLAG_VLAN,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.ntuple_spec.vlan_tci),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.ntuple_spec.vlan_tci) },
+	{ "user-def", OPT_BE64, NTUPLE_FLAG_UDEF,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.ntuple_spec.data),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.ntuple_spec.data) },
 };
 
 static struct rule_opts rule_nfc_esp_ip4[] = {
@@ -564,6 +603,15 @@ static struct rule_opts rule_nfc_esp_ip4[] = {
 	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
 	{ "loc", OPT_U32, NFC_FLAG_LOC,
 	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
+	{ "vlan-etype", OPT_BE16, NTUPLE_FLAG_VETH,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.ntuple_spec.vlan_etype),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.ntuple_spec.vlan_etype) },
+	{ "vlan", OPT_BE16, NTUPLE_FLAG_VLAN,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.ntuple_spec.vlan_tci),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.ntuple_spec.vlan_tci) },
+	{ "user-def", OPT_BE64, NTUPLE_FLAG_UDEF,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.ntuple_spec.data),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.ntuple_spec.data) },
 };
 
 static struct rule_opts rule_nfc_usr_ip4[] = {
@@ -592,6 +640,15 @@ static struct rule_opts rule_nfc_usr_ip4[] = {
 	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
 	{ "loc", OPT_U32, NFC_FLAG_LOC,
 	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
+	{ "vlan-etype", OPT_BE16, NTUPLE_FLAG_VETH,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.ntuple_spec.vlan_etype),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.ntuple_spec.vlan_etype) },
+	{ "vlan", OPT_BE16, NTUPLE_FLAG_VLAN,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.ntuple_spec.vlan_tci),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.ntuple_spec.vlan_tci) },
+	{ "user-def", OPT_BE64, NTUPLE_FLAG_UDEF,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.ntuple_spec.data),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.ntuple_spec.data) },
 };
 
 static struct rule_opts rule_nfc_ether[] = {
@@ -608,6 +665,15 @@ static struct rule_opts rule_nfc_ether[] = {
 	  offsetof(struct ethtool_rx_flow_spec, ring_cookie), -1 },
 	{ "loc", OPT_U32, NFC_FLAG_LOC,
 	  offsetof(struct ethtool_rx_flow_spec, location), -1 },
+	{ "vlan-etype", OPT_BE16, NTUPLE_FLAG_VETH,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.ntuple_spec.vlan_etype),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.ntuple_spec.vlan_etype) },
+	{ "vlan", OPT_BE16, NTUPLE_FLAG_VLAN,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.ntuple_spec.vlan_tci),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.ntuple_spec.vlan_tci) },
+	{ "user-def", OPT_BE64, NTUPLE_FLAG_UDEF,
+	  offsetof(struct ethtool_rx_flow_spec, h_u.ntuple_spec.data),
+	  offsetof(struct ethtool_rx_flow_spec, m_u.ntuple_spec.data) },
 };
 
 static struct rule_opts rule_ntuple_tcp_ip4[] = {
@@ -1159,6 +1225,12 @@ int rxclass_parse_ruleopts(char **argp, int argc, void *fsp, u8 *loc_valid)
 	if (spec_type == ETH_SPEC_NFC) {
 		if (loc_valid && (flags & NFC_FLAG_LOC))
 			*loc_valid = 1;
+		if (flags & (NTUPLE_FLAG_VLAN |
+			     NTUPLE_FLAG_UDEF |
+			     NTUPLE_FLAG_VETH)) {
+			struct ethtool_rx_flow_spec *fs = fsp;
+			fs->flow_type_ext = NTUPLE_FLOW_EXT;
+		}
 	}
 
 	return 0;

