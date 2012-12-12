From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH ETHTOOL] Added dst-mac parameter for L3/L4 flow spec rules. This is usefull in vSwitch configurations.
Date: Wed, 12 Dec 2012 14:13:20 +0200
Message-ID: <1355314400-14909-5-git-send-email-amirv@mellanox.com>
References: <1355314400-14909-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Yan Burman <yanb@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:35562 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751884Ab2LLMNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 07:13:37 -0500
In-Reply-To: <1355314400-14909-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yan Burman <yanb@mellanox.com>

Signed-off-by: Yan Burman <yanb@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 ethtool-copy.h | 11 +++++++----
 ethtool.8.in   |  6 ++++++
 ethtool.c      |  5 +++++
 rxclass.c      | 62 ++++++++++++++++++++++++++++++++++++++++------------------
 4 files changed, 61 insertions(+), 23 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 4801eef..d352f20 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -500,13 +500,15 @@ union ethtool_flow_union {
 	struct ethtool_ah_espip4_spec		esp_ip4_spec;
 	struct ethtool_usrip4_spec		usr_ip4_spec;
 	struct ethhdr				ether_spec;
-	__u8					hdata[60];
+	__u8					hdata[52];
 };
 
 struct ethtool_flow_ext {
-	__be16	vlan_etype;
-	__be16	vlan_tci;
-	__be32	data[2];
+	__u8		padding[2];
+	unsigned char	h_dest[ETH_ALEN];	/* destination eth addr	*/
+	__be16		vlan_etype;
+	__be16		vlan_tci;
+	__be32		data[2];
 };
 
 /**
@@ -1027,6 +1029,7 @@ enum ethtool_sfeatures_retval_bits {
 #define	ETHER_FLOW	0x12	/* spec only (ether_spec) */
 /* Flag to enable additional fields in struct ethtool_rx_flow_spec */
 #define	FLOW_EXT	0x80000000
+#define	FLOW_MAC_EXT	0x40000000
 
 /* L3-L4 network traffic flow hash options */
 #define	RXH_L2DA	(1 << 1)
diff --git a/ethtool.8.in b/ethtool.8.in
index e701919..a52e484 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -268,6 +268,7 @@ ethtool \- query or control network driver and hardware settings
 .BM vlan\-etype
 .BM vlan
 .BM user\-def
+.RB [ dst-mac \ \*(MA\ [ m \ \*(MA]]
 .BN action
 .BN loc
 .RB |
@@ -739,6 +740,11 @@ Includes the VLAN tag and an optional mask.
 .BI user\-def \ N \\fR\ [\\fPm \ N \\fR]\\fP
 Includes 64-bits of user-specific data and an optional mask.
 .TP
+.BR dst-mac \ \*(MA\ [ m \ \*(MA]
+Includes the destination MAC address, specified as 6 bytes in hexadecimal
+separated by colons, along with an optional mask.
+Valid for all IPv4 based flow-types.
+.TP
 .BI action \ N
 Specifies the Rx queue to send packets to, or some other action.
 .TS
diff --git a/ethtool.c b/ethtool.c
index 345c21c..55bc082 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3231,6 +3231,10 @@ static int flow_spec_to_ntuple(struct ethtool_rx_flow_spec *fsp,
 	if (fsp->location != RX_CLS_LOC_ANY)
 		return -1;
 
+	/* destination MAC address in L3/L4 rules is not supported by ntuple */
+	if (fsp->flow_type & FLOW_MAC_EXT)
+		return -1;
+
 	/* verify ring cookie can transfer to action */
 	if (fsp->ring_cookie > INT_MAX && fsp->ring_cookie < (u64)(-2))
 		return -1;
@@ -3814,6 +3818,7 @@ static const struct option {
 	  "			[ vlan-etype %x [m %x] ]\n"
 	  "			[ vlan %x [m %x] ]\n"
 	  "			[ user-def %x [m %x] ]\n"
+	  "			[ dst-mac %x:%x:%x:%x:%x:%x [m %x:%x:%x:%x:%x:%x] ]\n"
 	  "			[ action %d ]\n"
 	  "			[ loc %d]] |\n"
 	  "		delete %d\n" },
diff --git a/rxclass.c b/rxclass.c
index e1633a8..1564b62 100644
--- a/rxclass.c
+++ b/rxclass.c
@@ -41,26 +41,38 @@ static void rxclass_print_ipv4_rule(__be32 sip, __be32 sipm, __be32 dip,
 
 static void rxclass_print_nfc_spec_ext(struct ethtool_rx_flow_spec *fsp)
 {
-	u64 data, datam;
-	__u16 etype, etypem, tci, tcim;
+	if (fsp->flow_type & FLOW_EXT) {
+		u64 data, datam;
+		__u16 etype, etypem, tci, tcim;
+		etype = ntohs(fsp->h_ext.vlan_etype);
+		etypem = ntohs(~fsp->m_ext.vlan_etype);
+		tci = ntohs(fsp->h_ext.vlan_tci);
+		tcim = ntohs(~fsp->m_ext.vlan_tci);
+		data = (u64)ntohl(fsp->h_ext.data[0]) << 32;
+		data = (u64)ntohl(fsp->h_ext.data[1]);
+		datam = (u64)ntohl(~fsp->m_ext.data[0]) << 32;
+		datam |= (u64)ntohl(~fsp->m_ext.data[1]);
 
-	if (!(fsp->flow_type & FLOW_EXT))
-		return;
+		fprintf(stdout,
+			"\tVLAN EtherType: 0x%x mask: 0x%x\n"
+			"\tVLAN: 0x%x mask: 0x%x\n"
+			"\tUser-defined: 0x%llx mask: 0x%llx\n",
+			etype, etypem, tci, tcim, data, datam);
+	}
 
-	etype = ntohs(fsp->h_ext.vlan_etype);
-	etypem = ntohs(~fsp->m_ext.vlan_etype);
-	tci = ntohs(fsp->h_ext.vlan_tci);
-	tcim = ntohs(~fsp->m_ext.vlan_tci);
-	data = (u64)ntohl(fsp->h_ext.data[0]) << 32;
-	data = (u64)ntohl(fsp->h_ext.data[1]);
-	datam = (u64)ntohl(~fsp->m_ext.data[0]) << 32;
-	datam |= (u64)ntohl(~fsp->m_ext.data[1]);
+	if (fsp->flow_type & FLOW_MAC_EXT) {
+		unsigned char *dmac, *dmacm;
 
-	fprintf(stdout,
-		"\tVLAN EtherType: 0x%x mask: 0x%x\n"
-		"\tVLAN: 0x%x mask: 0x%x\n"
-		"\tUser-defined: 0x%llx mask: 0x%llx\n",
-		etype, etypem, tci, tcim, data, datam);
+		dmac = fsp->h_ext.h_dest;
+		dmacm = fsp->m_ext.h_dest;
+
+		fprintf(stdout,
+			"\tDest MAC addr: %02X:%02X:%02X:%02X:%02X:%02X"
+			" mask: %02X:%02X:%02X:%02X:%02X:%02X\n",
+			dmac[0], dmac[1], dmac[2], dmac[3], dmac[4],
+			dmac[5], dmacm[0], dmacm[1], dmacm[2], dmacm[3],
+			dmacm[4], dmacm[5]);
+	}
 }
 
 static void rxclass_print_nfc_rule(struct ethtool_rx_flow_spec *fsp)
@@ -70,7 +82,7 @@ static void rxclass_print_nfc_rule(struct ethtool_rx_flow_spec *fsp)
 
 	fprintf(stdout,	"Filter: %d\n", fsp->location);
 
-	flow_type = fsp->flow_type & ~FLOW_EXT;
+	flow_type = fsp->flow_type & ~(FLOW_EXT | FLOW_MAC_EXT);
 
 	invert_flow_mask(fsp);
 
@@ -172,7 +184,7 @@ static void rxclass_print_nfc_rule(struct ethtool_rx_flow_spec *fsp)
 static void rxclass_print_rule(struct ethtool_rx_flow_spec *fsp)
 {
 	/* print the rule in this location */
-	switch (fsp->flow_type & ~FLOW_EXT) {
+	switch (fsp->flow_type & ~(FLOW_EXT | FLOW_MAC_EXT)) {
 	case TCP_V4_FLOW:
 	case UDP_V4_FLOW:
 	case SCTP_V4_FLOW:
@@ -533,6 +545,7 @@ typedef enum {
 #define NTUPLE_FLAG_VLAN	0x100
 #define NTUPLE_FLAG_UDEF	0x200
 #define NTUPLE_FLAG_VETH	0x400
+#define NFC_FLAG_MAC_ADDR	0x800
 
 struct rule_opts {
 	const char	*name;
@@ -571,6 +584,9 @@ static const struct rule_opts rule_nfc_tcp_ip4[] = {
 	{ "user-def", OPT_BE64, NTUPLE_FLAG_UDEF,
 	  offsetof(struct ethtool_rx_flow_spec, h_ext.data),
 	  offsetof(struct ethtool_rx_flow_spec, m_ext.data) },
+	{ "dst-mac", OPT_MAC, NFC_FLAG_MAC_ADDR,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.h_dest),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.h_dest) },
 };
 
 static const struct rule_opts rule_nfc_esp_ip4[] = {
@@ -599,6 +615,9 @@ static const struct rule_opts rule_nfc_esp_ip4[] = {
 	{ "user-def", OPT_BE64, NTUPLE_FLAG_UDEF,
 	  offsetof(struct ethtool_rx_flow_spec, h_ext.data),
 	  offsetof(struct ethtool_rx_flow_spec, m_ext.data) },
+	{ "dst-mac", OPT_MAC, NFC_FLAG_MAC_ADDR,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.h_dest),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.h_dest) },
 };
 
 static const struct rule_opts rule_nfc_usr_ip4[] = {
@@ -639,6 +658,9 @@ static const struct rule_opts rule_nfc_usr_ip4[] = {
 	{ "user-def", OPT_BE64, NTUPLE_FLAG_UDEF,
 	  offsetof(struct ethtool_rx_flow_spec, h_ext.data),
 	  offsetof(struct ethtool_rx_flow_spec, m_ext.data) },
+	{ "dst-mac", OPT_MAC, NFC_FLAG_MAC_ADDR,
+	  offsetof(struct ethtool_rx_flow_spec, h_ext.h_dest),
+	  offsetof(struct ethtool_rx_flow_spec, m_ext.h_dest) },
 };
 
 static const struct rule_opts rule_nfc_ether[] = {
@@ -1063,6 +1085,8 @@ int rxclass_parse_ruleopts(struct cmd_context *ctx,
 		fsp->h_u.usr_ip4_spec.ip_ver = ETH_RX_NFC_IP4;
 	if (flags & (NTUPLE_FLAG_VLAN | NTUPLE_FLAG_UDEF | NTUPLE_FLAG_VETH))
 		fsp->flow_type |= FLOW_EXT;
+	if (flags & NFC_FLAG_MAC_ADDR)
+		fsp->flow_type |= FLOW_MAC_EXT;
 
 	return 0;
 
-- 
1.7.11.3
