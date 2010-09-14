From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCHv2 net-next-2.6 1/2] ethtool: Complete kernel-doc comments
 for RX flow filter and hash control
Date: Tue, 14 Sep 2010 20:10:03 +0100
Message-ID: <1284491403.2289.5.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Santwona Behera <santwona.behera@sun.com>,
	Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:17520 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753089Ab0INTKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Sep 2010 15:10:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are now several interfaces within the ethtool API for getting
and setting RX flow filtering and hashing behaviour, most of which are
poorly documented.  This adds kernel-doc comments for all these
interfaces, based on the existing incomplete comments and on the
initial implementations.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
Changes since v1:
- Mention ETHTOOL_RXNTUPLE_ACTION_DROP as a specific possible action for
  ethtool_rx_ntuple_flow_spec
- Don't claim that ETHTOOL_GRXNTUPLE uses struct ethtool_rx_ntuple
- Add comments for the IPv4 flow specification structures that are
  currently used

Ben.

 include/linux/ethtool.h |  129 +++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 113 insertions(+), 16 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 991269e..4b3ba05 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -314,9 +314,20 @@ enum ethtool_flags {
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
@@ -326,6 +337,15 @@ struct ethtool_tcpip4_spec {
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
@@ -348,6 +368,15 @@ struct ethtool_ether_spec {
 #define	ETH_RX_NFC_IP4	1
 #define	ETH_RX_NFC_IP6	2
 
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
@@ -357,6 +386,15 @@ struct ethtool_usrip4_spec {
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
@@ -369,32 +407,87 @@ struct ethtool_rx_flow_spec {
 		struct ethtool_ether_spec		ether_spec;
 		struct ethtool_usrip4_spec		usr_ip4_spec;
 		__u8					hdata[64];
-	} h_u, m_u; /* entry, mask */
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
+ * Zero values in @h_u may be ignored, as if all the corresponding
+ * mask bits were set.
+ */
 struct ethtool_rx_ntuple_flow_spec {
 	__u32		 flow_type;
 	union {
@@ -407,18 +500,22 @@ struct ethtool_rx_ntuple_flow_spec {
 		struct ethtool_ether_spec		ether_spec;
 		struct ethtool_usrip4_spec		usr_ip4_spec;
 		__u8					hdata[64];
-	} h_u, m_u; /* entry, mask */
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
+#define ETHTOOL_RXNTUPLE_ACTION_DROP -1		/* drop packet */
 };
 
+/**
+ * struct ethtool_rx_ntuple - command to set RX flow filter
+ * @cmd: Command number - %ETHTOOL_SRXNTUPLE
+ * @fs: Flow filter specification
+ */
 struct ethtool_rx_ntuple {
 	__u32					cmd;
 	struct ethtool_rx_ntuple_flow_spec	fs;
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

