From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 1/7] ethtool-copy.h: sync with net-next-2.6
Date: Thu, 23 Sep 2010 22:48:03 +0100
Message-ID: <1285278483.7794.28.camel@achroite.uk.solarflarecom.com>
References: <1285278428.7794.27.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:54524 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754897Ab0IWVsG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 17:48:06 -0400
In-Reply-To: <1285278428.7794.27.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool-copy.h |  228 ++++++++++++++++++++++++++++++++++++++-----------------
 1 files changed, 157 insertions(+), 71 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 894f1da..1be08cf 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -14,6 +14,7 @@
 #define _LINUX_ETHTOOL_H
 
 #include <linux/types.h>
+#include <linux/if_ether.h>
 
 /* This should work for both 32 and 64 bit userland. */
 struct ethtool_cmd {
@@ -314,9 +315,20 @@ enum ethtool_flags {
 };
 
 /* The following structures are for supporting RX network flow
- * classification configuration. Note, all multibyte fields, e.g.,
- * ip4src, ip4dst, psrc, pdst, spi, etc. are expected to be in network
- * byte order.
+ * classification and RX n-tuple configuration. Note, all multibyte
+ * fields, e.g., ip4src, ip4dst, psrc, pdst, spi, etc. are expected to
+ * be in network byte order.
+ */
+
+/**
+ * struct ethtool_tcpip4_spec - flow specification for TCP/IPv4 etc.
+ * @ip4src: Source host
+ * @ip4dst: Destination host
+ * @psrc: Source port
+ * @pdst: Destination port
+ * @tos: Type-of-service
+ *
+ * This can be used to specify a TCP/IPv4, UDP/IPv4 or SCTP/IPv4 flow.
  */
 struct ethtool_tcpip4_spec {
 	__be32	ip4src;
@@ -326,6 +338,15 @@ struct ethtool_tcpip4_spec {
 	__u8    tos;
 };
 
+/**
+ * struct ethtool_ah_espip4_spec - flow specification for IPsec/IPv4
+ * @ip4src: Source host
+ * @ip4dst: Destination host
+ * @spi: Security parameters index
+ * @tos: Type-of-service
+ *
+ * This can be used to specify an IPsec transport or tunnel over IPv4.
+ */
 struct ethtool_ah_espip4_spec {
 	__be32	ip4src;
 	__be32	ip4dst;
@@ -333,21 +354,17 @@ struct ethtool_ah_espip4_spec {
 	__u8    tos;
 };
 
-struct ethtool_rawip4_spec {
-	__be32	ip4src;
-	__be32	ip4dst;
-	__u8	hdata[64];
-};
-
-struct ethtool_ether_spec {
-	__be16	ether_type;
-	__u8	frame_size;
-	__u8	eframe[16];
-};
-
 #define	ETH_RX_NFC_IP4	1
-#define	ETH_RX_NFC_IP6	2
 
+/**
+ * struct ethtool_usrip4_spec - general flow specification for IPv4
+ * @ip4src: Source host
+ * @ip4dst: Destination host
+ * @l4_4_bytes: First 4 bytes of transport (layer 4) header
+ * @tos: Type-of-service
+ * @ip_ver: Value must be %ETH_RX_NFC_IP4; mask must be 0
+ * @proto: Transport protocol number; mask must be 0
+ */
 struct ethtool_usrip4_spec {
 	__be32	ip4src;
 	__be32	ip4dst;
@@ -357,6 +374,15 @@ struct ethtool_usrip4_spec {
 	__u8    proto;
 };
 
+/**
+ * struct ethtool_rx_flow_spec - specification for RX flow filter
+ * @flow_type: Type of match to perform, e.g. %TCP_V4_FLOW
+ * @h_u: Flow fields to match (dependent on @flow_type)
+ * @m_u: Masks for flow field bits to be ignored
+ * @ring_cookie: RX ring/queue index to deliver to, or %RX_CLS_FLOW_DISC
+ *	if packets should be discarded
+ * @location: Index of filter in hardware table
+ */
 struct ethtool_rx_flow_spec {
 	__u32		flow_type;
 	union {
@@ -365,36 +391,91 @@ struct ethtool_rx_flow_spec {
 		struct ethtool_tcpip4_spec		sctp_ip4_spec;
 		struct ethtool_ah_espip4_spec		ah_ip4_spec;
 		struct ethtool_ah_espip4_spec		esp_ip4_spec;
-		struct ethtool_rawip4_spec		raw_ip4_spec;
-		struct ethtool_ether_spec		ether_spec;
 		struct ethtool_usrip4_spec		usr_ip4_spec;
-		__u8					hdata[64];
-	} h_u, m_u; /* entry, mask */
+		struct ethhdr				ether_spec;
+		__u8					hdata[72];
+	} h_u, m_u;
 	__u64		ring_cookie;
 	__u32		location;
 };
 
+/**
+ * struct ethtool_rxnfc - command to get or set RX flow classification rules
+ * @cmd: Specific command number - %ETHTOOL_GRXFH, %ETHTOOL_SRXFH,
+ *	%ETHTOOL_GRXRINGS, %ETHTOOL_GRXCLSRLCNT, %ETHTOOL_GRXCLSRULE,
+ *	%ETHTOOL_GRXCLSRLALL, %ETHTOOL_SRXCLSRLDEL or %ETHTOOL_SRXCLSRLINS
+ * @flow_type: Type of flow to be affected, e.g. %TCP_V4_FLOW
+ * @data: Command-dependent value
+ * @fs: Flow filter specification
+ * @rule_cnt: Number of rules to be affected
+ * @rule_locs: Array of valid rule indices
+ *
+ * For %ETHTOOL_GRXFH and %ETHTOOL_SRXFH, @data is a bitmask indicating
+ * the fields included in the flow hash, e.g. %RXH_IP_SRC.  The following
+ * structure fields must not be used.
+ *
+ * For %ETHTOOL_GRXRINGS, @data is set to the number of RX rings/queues
+ * on return.
+ *
+ * For %ETHTOOL_GRXCLSRLCNT, @rule_cnt is set to the number of defined
+ * rules on return.
+ *
+ * For %ETHTOOL_GRXCLSRULE, @fs.@location specifies the index of an
+ * existing filter rule on entry and @fs contains the rule on return.
+ *
+ * For %ETHTOOL_GRXCLSRLALL, @rule_cnt specifies the array size of the
+ * user buffer for @rule_locs on entry.  On return, @data is the size
+ * of the filter table and @rule_locs contains the indices of the
+ * defined rules.
+ *
+ * For %ETHTOOL_SRXCLSRLINS, @fs specifies the filter rule to add or
+ * update.  @fs.@location specifies the index to use and must not be
+ * ignored.
+ *
+ * For %ETHTOOL_SRXCLSRLDEL, @fs.@location specifies the index of an
+ * existing filter rule on entry.
+ *
+ * Implementation of indexed classification rules generally requires a
+ * TCAM.
+ */
 struct ethtool_rxnfc {
 	__u32				cmd;
 	__u32				flow_type;
-	/* The rx flow hash value or the rule DB size */
 	__u64				data;
-	/* The following fields are not valid and must not be used for
-	 * the ETHTOOL_{G,X}RXFH commands. */
 	struct ethtool_rx_flow_spec	fs;
 	__u32				rule_cnt;
 	__u32				rule_locs[0];
 };
 
+/**
+ * struct ethtool_rxfh_indir - command to get or set RX flow hash indirection
+ * @cmd: Specific command number - %ETHTOOL_GRXFHINDIR or %ETHTOOL_SRXFHINDIR
+ * @size: On entry, the array size of the user buffer.  On return from
+ *	%ETHTOOL_GRXFHINDIR, the array size of the hardware indirection table.
+ * @ring_index: RX ring/queue index for each hash value
+ */
 struct ethtool_rxfh_indir {
 	__u32	cmd;
-	/* On entry, this is the array size of the user buffer.  On
-	 * return from ETHTOOL_GRXFHINDIR, this is the array size of
-	 * the hardware indirection table. */
 	__u32	size;
-	__u32	ring_index[0];	/* ring/queue index for each hash value */
+	__u32	ring_index[0];
 };
 
+/**
+ * struct ethtool_rx_ntuple_flow_spec - specification for RX flow filter
+ * @flow_type: Type of match to perform, e.g. %TCP_V4_FLOW
+ * @h_u: Flow field values to match (dependent on @flow_type)
+ * @m_u: Masks for flow field value bits to be ignored
+ * @vlan_tag: VLAN tag to match
+ * @vlan_tag_mask: Mask for VLAN tag bits to be ignored
+ * @data: Driver-dependent data to match
+ * @data_mask: Mask for driver-dependent data bits to be ignored
+ * @action: RX ring/queue index to deliver to (non-negative) or other action
+ *	(negative, e.g. %ETHTOOL_RXNTUPLE_ACTION_DROP)
+ *
+ * For flow types %TCP_V4_FLOW, %UDP_V4_FLOW and %SCTP_V4_FLOW, where
+ * a field value and mask are both zero this is treated as if all mask
+ * bits are set i.e. the field is ignored.
+ */
 struct ethtool_rx_ntuple_flow_spec {
 	__u32		 flow_type;
 	union {
@@ -403,22 +484,26 @@ struct ethtool_rx_ntuple_flow_spec {
 		struct ethtool_tcpip4_spec		sctp_ip4_spec;
 		struct ethtool_ah_espip4_spec		ah_ip4_spec;
 		struct ethtool_ah_espip4_spec		esp_ip4_spec;
-		struct ethtool_rawip4_spec		raw_ip4_spec;
-		struct ethtool_ether_spec		ether_spec;
 		struct ethtool_usrip4_spec		usr_ip4_spec;
-		__u8					hdata[64];
-	} h_u, m_u; /* entry, mask */
+		struct ethhdr				ether_spec;
+		__u8					hdata[72];
+	} h_u, m_u;
 
 	__u16	        vlan_tag;
 	__u16	        vlan_tag_mask;
-	__u64		data;      /* user-defined flow spec data */
-	__u64		data_mask; /* user-defined flow spec mask */
+	__u64		data;
+	__u64		data_mask;
 
-	/* signed to distinguish between queue and actions (DROP) */
 	__s32		action;
-#define ETHTOOL_RXNTUPLE_ACTION_DROP -1
+#define ETHTOOL_RXNTUPLE_ACTION_DROP	(-1)	/* drop packet */
+#define ETHTOOL_RXNTUPLE_ACTION_CLEAR	(-2)	/* clear filter */
 };
 
+/**
+ * struct ethtool_rx_ntuple - command to set or clear RX flow filter
+ * @cmd: Command number - %ETHTOOL_SRXNTUPLE
+ * @fs: Flow filter specification
+ */
 struct ethtool_rx_ntuple {
 	__u32					cmd;
 	struct ethtool_rx_ntuple_flow_spec	fs;
@@ -444,29 +529,29 @@ struct ethtool_flash {
 #define ETHTOOL_GREGS		0x00000004 /* Get NIC registers. */
 #define ETHTOOL_GWOL		0x00000005 /* Get wake-on-lan options. */
 #define ETHTOOL_SWOL		0x00000006 /* Set wake-on-lan options. */
-#define ETHTOOL_GMSGLVL	0x00000007 /* Get driver message level */
-#define ETHTOOL_SMSGLVL	0x00000008 /* Set driver msg level. */
+#define ETHTOOL_GMSGLVL		0x00000007 /* Get driver message level */
+#define ETHTOOL_SMSGLVL		0x00000008 /* Set driver msg level. */
 #define ETHTOOL_NWAY_RST	0x00000009 /* Restart autonegotiation. */
 #define ETHTOOL_GLINK		0x0000000a /* Get link status (ethtool_value) */
-#define ETHTOOL_GEEPROM	0x0000000b /* Get EEPROM data */
-#define ETHTOOL_SEEPROM	0x0000000c /* Set EEPROM data. */
+#define ETHTOOL_GEEPROM		0x0000000b /* Get EEPROM data */
+#define ETHTOOL_SEEPROM		0x0000000c /* Set EEPROM data. */
 #define ETHTOOL_GCOALESCE	0x0000000e /* Get coalesce config */
 #define ETHTOOL_SCOALESCE	0x0000000f /* Set coalesce config. */
 #define ETHTOOL_GRINGPARAM	0x00000010 /* Get ring parameters */
 #define ETHTOOL_SRINGPARAM	0x00000011 /* Set ring parameters. */
 #define ETHTOOL_GPAUSEPARAM	0x00000012 /* Get pause parameters */
 #define ETHTOOL_SPAUSEPARAM	0x00000013 /* Set pause parameters. */
-#define ETHTOOL_GRXCSUM	0x00000014 /* Get RX hw csum enable (ethtool_value) */
-#define ETHTOOL_SRXCSUM	0x00000015 /* Set RX hw csum enable (ethtool_value) */
-#define ETHTOOL_GTXCSUM	0x00000016 /* Get TX hw csum enable (ethtool_value) */
-#define ETHTOOL_STXCSUM	0x00000017 /* Set TX hw csum enable (ethtool_value) */
+#define ETHTOOL_GRXCSUM		0x00000014 /* Get RX hw csum enable (ethtool_value) */
+#define ETHTOOL_SRXCSUM		0x00000015 /* Set RX hw csum enable (ethtool_value) */
+#define ETHTOOL_GTXCSUM		0x00000016 /* Get TX hw csum enable (ethtool_value) */
+#define ETHTOOL_STXCSUM		0x00000017 /* Set TX hw csum enable (ethtool_value) */
 #define ETHTOOL_GSG		0x00000018 /* Get scatter-gather enable
 					    * (ethtool_value) */
 #define ETHTOOL_SSG		0x00000019 /* Set scatter-gather enable
 					    * (ethtool_value). */
 #define ETHTOOL_TEST		0x0000001a /* execute NIC self-test. */
 #define ETHTOOL_GSTRINGS	0x0000001b /* get specified string set */
-#define ETHTOOL_PHYS_ID	0x0000001c /* identify the NIC */
+#define ETHTOOL_PHYS_ID		0x0000001c /* identify the NIC */
 #define ETHTOOL_GSTATS		0x0000001d /* get NIC-specific statistics */
 #define ETHTOOL_GTSO		0x0000001e /* Get TSO enable (ethtool_value) */
 #define ETHTOOL_STSO		0x0000001f /* Set TSO enable (ethtool_value) */
@@ -477,8 +562,8 @@ struct ethtool_flash {
 #define ETHTOOL_SGSO		0x00000024 /* Set GSO enable (ethtool_value) */
 #define ETHTOOL_GFLAGS		0x00000025 /* Get flags bitmap(ethtool_value) */
 #define ETHTOOL_SFLAGS		0x00000026 /* Set flags bitmap(ethtool_value) */
-#define ETHTOOL_GPFLAGS	0x00000027 /* Get driver-private flags bitmap */
-#define ETHTOOL_SPFLAGS	0x00000028 /* Set driver-private flags bitmap */
+#define ETHTOOL_GPFLAGS		0x00000027 /* Get driver-private flags bitmap */
+#define ETHTOOL_SPFLAGS		0x00000028 /* Set driver-private flags bitmap */
 
 #define ETHTOOL_GRXFH		0x00000029 /* Get RX flow hash configuration */
 #define ETHTOOL_SRXFH		0x0000002a /* Set RX flow hash configuration */
@@ -505,18 +590,18 @@ struct ethtool_flash {
 /* Indicates what features are supported by the interface. */
 #define SUPPORTED_10baseT_Half		(1 << 0)
 #define SUPPORTED_10baseT_Full		(1 << 1)
-#define SUPPORTED_100baseT_Half	(1 << 2)
-#define SUPPORTED_100baseT_Full	(1 << 3)
+#define SUPPORTED_100baseT_Half		(1 << 2)
+#define SUPPORTED_100baseT_Full		(1 << 3)
 #define SUPPORTED_1000baseT_Half	(1 << 4)
 #define SUPPORTED_1000baseT_Full	(1 << 5)
 #define SUPPORTED_Autoneg		(1 << 6)
 #define SUPPORTED_TP			(1 << 7)
 #define SUPPORTED_AUI			(1 << 8)
 #define SUPPORTED_MII			(1 << 9)
-#define SUPPORTED_FIBRE		(1 << 10)
+#define SUPPORTED_FIBRE			(1 << 10)
 #define SUPPORTED_BNC			(1 << 11)
 #define SUPPORTED_10000baseT_Full	(1 << 12)
-#define SUPPORTED_Pause		(1 << 13)
+#define SUPPORTED_Pause			(1 << 13)
 #define SUPPORTED_Asym_Pause		(1 << 14)
 #define SUPPORTED_2500baseX_Full	(1 << 15)
 #define SUPPORTED_Backplane		(1 << 16)
@@ -526,8 +611,8 @@ struct ethtool_flash {
 #define SUPPORTED_10000baseR_FEC	(1 << 20)
 
 /* Indicates what features are advertised by the interface. */
-#define ADVERTISED_10baseT_Half	(1 << 0)
-#define ADVERTISED_10baseT_Full	(1 << 1)
+#define ADVERTISED_10baseT_Half		(1 << 0)
+#define ADVERTISED_10baseT_Full		(1 << 1)
 #define ADVERTISED_100baseT_Half	(1 << 2)
 #define ADVERTISED_100baseT_Full	(1 << 3)
 #define ADVERTISED_1000baseT_Half	(1 << 4)
@@ -566,12 +651,12 @@ struct ethtool_flash {
 #define DUPLEX_FULL		0x01
 
 /* Which connector port. */
-#define PORT_TP		0x00
+#define PORT_TP			0x00
 #define PORT_AUI		0x01
 #define PORT_MII		0x02
 #define PORT_FIBRE		0x03
 #define PORT_BNC		0x04
-#define PORT_DA		0x05
+#define PORT_DA			0x05
 #define PORT_NONE		0xef
 #define PORT_OTHER		0xff
 
@@ -585,7 +670,7 @@ struct ethtool_flash {
 /* Enable or disable autonegotiation.  If this is set to enable,
  * the forced link modes above are completely ignored.
  */
-#define AUTONEG_DISABLE	0x00
+#define AUTONEG_DISABLE		0x00
 #define AUTONEG_ENABLE		0x01
 
 /* Mode MDI or MDI-X */
@@ -602,22 +687,23 @@ struct ethtool_flash {
 #define WAKE_MAGIC		(1 << 5)
 #define WAKE_MAGICSECURE	(1 << 6) /* only meaningful if WAKE_MAGIC */
 
-/* L3-L4 network traffic flow types */
-#define	TCP_V4_FLOW	0x01
-#define	UDP_V4_FLOW	0x02
-#define	SCTP_V4_FLOW	0x03
-#define	AH_ESP_V4_FLOW	0x04
-#define	TCP_V6_FLOW	0x05
-#define	UDP_V6_FLOW	0x06
-#define	SCTP_V6_FLOW	0x07
-#define	AH_ESP_V6_FLOW	0x08
-#define	AH_V4_FLOW	0x09
-#define	ESP_V4_FLOW	0x0a
-#define	AH_V6_FLOW	0x0b
-#define	ESP_V6_FLOW	0x0c
-#define	IP_USER_FLOW	0x0d
-#define	IPV4_FLOW	0x10
-#define	IPV6_FLOW	0x11
+/* L2-L4 network traffic flow types */
+#define	TCP_V4_FLOW	0x01	/* hash or spec (tcp_ip4_spec) */
+#define	UDP_V4_FLOW	0x02	/* hash or spec (udp_ip4_spec) */
+#define	SCTP_V4_FLOW	0x03	/* hash or spec (sctp_ip4_spec) */
+#define	AH_ESP_V4_FLOW	0x04	/* hash only */
+#define	TCP_V6_FLOW	0x05	/* hash only */
+#define	UDP_V6_FLOW	0x06	/* hash only */
+#define	SCTP_V6_FLOW	0x07	/* hash only */
+#define	AH_ESP_V6_FLOW	0x08	/* hash only */
+#define	AH_V4_FLOW	0x09	/* hash or spec (ah_ip4_spec) */
+#define	ESP_V4_FLOW	0x0a	/* hash or spec (esp_ip4_spec) */
+#define	AH_V6_FLOW	0x0b	/* hash only */
+#define	ESP_V6_FLOW	0x0c	/* hash only */
+#define	IP_USER_FLOW	0x0d	/* spec only (usr_ip4_spec) */
+#define	IPV4_FLOW	0x10	/* hash only */
+#define	IPV6_FLOW	0x11	/* hash only */
+#define	ETHER_FLOW	0x12	/* spec only (ether_spec) */
 
 /* L3-L4 network traffic flow hash options */
 #define	RXH_L2DA	(1 << 1)
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

