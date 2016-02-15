From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH ethtool 1/3] ethtool-copy.h: sync with net-next
Date: Mon, 15 Feb 2016 14:59:46 +0000
Message-ID: <56C1E7E2.9090605@solarflare.com>
References: <56C1E73A.5090603@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Ben Hutchings <bwh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:36756 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753394AbcBOO7x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 09:59:53 -0500
In-Reply-To: <56C1E73A.5090603@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This covers kernel changes up to:

commit 72bb68721f80a1441e871b6afc9ab0b3793d5031
Author: Edward Cree <ecree@solarflare.com>
Date:   Fri Feb 5 11:16:21 2016 +0000

    ethtool: add IPv6 to the NFC API

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 ethtool-copy.h | 149 ++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 142 insertions(+), 7 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index d23ffc4..39e89e3 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -215,6 +215,11 @@ enum tunable_id {
 	ETHTOOL_ID_UNSPEC,
 	ETHTOOL_RX_COPYBREAK,
 	ETHTOOL_TX_COPYBREAK,
+	/*
+	 * Add your fresh new tubale attribute above and remember to update
+	 * tunable_strings[] in net/core/ethtool.c
+	 */
+	__ETHTOOL_TUNABLE_COUNT,
 };
 
 enum tunable_type_id {
@@ -537,6 +542,7 @@ struct ethtool_pauseparam {
  *	now deprecated
  * @ETH_SS_FEATURES: Device feature names
  * @ETH_SS_RSS_HASH_FUNCS: RSS hush function names
+ * @ETH_SS_PHY_STATS: Statistic names, for use with %ETHTOOL_GPHYSTATS
  */
 enum ethtool_stringset {
 	ETH_SS_TEST		= 0,
@@ -545,6 +551,8 @@ enum ethtool_stringset {
 	ETH_SS_NTUPLE_FILTERS,
 	ETH_SS_FEATURES,
 	ETH_SS_RSS_HASH_FUNCS,
+	ETH_SS_TUNABLES,
+	ETH_SS_PHY_STATS,
 };
 
 /**
@@ -740,6 +748,56 @@ struct ethtool_usrip4_spec {
 	__u8    proto;
 };
 
+/**
+ * struct ethtool_tcpip6_spec - flow specification for TCP/IPv6 etc.
+ * @ip6src: Source host
+ * @ip6dst: Destination host
+ * @psrc: Source port
+ * @pdst: Destination port
+ * @tclass: Traffic Class
+ *
+ * This can be used to specify a TCP/IPv6, UDP/IPv6 or SCTP/IPv6 flow.
+ */
+struct ethtool_tcpip6_spec {
+	__be32	ip6src[4];
+	__be32	ip6dst[4];
+	__be16	psrc;
+	__be16	pdst;
+	__u8    tclass;
+};
+
+/**
+ * struct ethtool_ah_espip6_spec - flow specification for IPsec/IPv6
+ * @ip6src: Source host
+ * @ip6dst: Destination host
+ * @spi: Security parameters index
+ * @tclass: Traffic Class
+ *
+ * This can be used to specify an IPsec transport or tunnel over IPv6.
+ */
+struct ethtool_ah_espip6_spec {
+	__be32	ip6src[4];
+	__be32	ip6dst[4];
+	__be32	spi;
+	__u8    tclass;
+};
+
+/**
+ * struct ethtool_usrip6_spec - general flow specification for IPv6
+ * @ip6src: Source host
+ * @ip6dst: Destination host
+ * @l4_4_bytes: First 4 bytes of transport (layer 4) header
+ * @tclass: Traffic Class
+ * @l4_proto: Transport protocol number (nexthdr after any Extension Headers)
+ */
+struct ethtool_usrip6_spec {
+	__be32	ip6src[4];
+	__be32	ip6dst[4];
+	__be32	l4_4_bytes;
+	__u8    tclass;
+	__u8    l4_proto;
+};
+
 union ethtool_flow_union {
 	struct ethtool_tcpip4_spec		tcp_ip4_spec;
 	struct ethtool_tcpip4_spec		udp_ip4_spec;
@@ -747,6 +805,12 @@ union ethtool_flow_union {
 	struct ethtool_ah_espip4_spec		ah_ip4_spec;
 	struct ethtool_ah_espip4_spec		esp_ip4_spec;
 	struct ethtool_usrip4_spec		usr_ip4_spec;
+	struct ethtool_tcpip6_spec		tcp_ip6_spec;
+	struct ethtool_tcpip6_spec		udp_ip6_spec;
+	struct ethtool_tcpip6_spec		sctp_ip6_spec;
+	struct ethtool_ah_espip6_spec		ah_ip6_spec;
+	struct ethtool_ah_espip6_spec		esp_ip6_spec;
+	struct ethtool_usrip6_spec		usr_ip6_spec;
 	struct ethhdr				ether_spec;
 	__u8					hdata[52];
 };
@@ -796,6 +860,31 @@ struct ethtool_rx_flow_spec {
 	__u32		location;
 };
 
+/* How rings are layed out when accessing virtual functions or
+ * offloaded queues is device specific. To allow users to do flow
+ * steering and specify these queues the ring cookie is partitioned
+ * into a 32bit queue index with an 8 bit virtual function id.
+ * This also leaves the 3bytes for further specifiers. It is possible
+ * future devices may support more than 256 virtual functions if
+ * devices start supporting PCIe w/ARI. However at the moment I
+ * do not know of any devices that support this so I do not reserve
+ * space for this at this time. If a future patch consumes the next
+ * byte it should be aware of this possiblity.
+ */
+#define ETHTOOL_RX_FLOW_SPEC_RING	0x00000000FFFFFFFFLL
+#define ETHTOOL_RX_FLOW_SPEC_RING_VF	0x000000FF00000000LL
+#define ETHTOOL_RX_FLOW_SPEC_RING_VF_OFF 32
+static __inline__ __u64 ethtool_get_flow_spec_ring(__u64 ring_cookie)
+{
+	return ETHTOOL_RX_FLOW_SPEC_RING & ring_cookie;
+};
+
+static __inline__ __u64 ethtool_get_flow_spec_ring_vf(__u64 ring_cookie)
+{
+	return (ETHTOOL_RX_FLOW_SPEC_RING_VF & ring_cookie) >>
+				ETHTOOL_RX_FLOW_SPEC_RING_VF_OFF;
+};
+
 /**
  * struct ethtool_rxnfc - command to get or set RX flow classification rules
  * @cmd: Specific command number - %ETHTOOL_GRXFH, %ETHTOOL_SRXFH,
@@ -1062,6 +1151,11 @@ struct ethtool_sfeatures {
  * the 'hwtstamp_tx_types' and 'hwtstamp_rx_filters' enumeration values,
  * respectively.  For example, if the device supports HWTSTAMP_TX_ON,
  * then (1 << HWTSTAMP_TX_ON) in 'tx_types' will be set.
+ *
+ * Drivers should only report the filters they actually support without
+ * upscaling in the SIOCSHWTSTAMP ioctl. If the SIOCSHWSTAMP request for
+ * HWTSTAMP_FILTER_V1_SYNC is supported by HWTSTAMP_FILTER_V1_EVENT, then the
+ * driver should only report HWTSTAMP_FILTER_V1_EVENT in this op.
  */
 struct ethtool_ts_info {
 	__u32	cmd;
@@ -1189,6 +1283,7 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_SRSSH		0x00000047 /* Set RX flow hash configuration */
 #define ETHTOOL_GTUNABLE	0x00000048 /* Get tunable configuration */
 #define ETHTOOL_STUNABLE	0x00000049 /* Set tunable configuration */
+#define ETHTOOL_GPHYSTATS	0x0000004a /* get PHY-specific statistics */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -1264,23 +1359,61 @@ enum ethtool_sfeatures_retval_bits {
  * it was forced up into this mode or autonegotiated.
  */
 
-/* The forced speed, 10Mb, 100Mb, gigabit, [2.5|10|20|40|56]GbE. */
+/* The forced speed, 10Mb, 100Mb, gigabit, [2.5|5|10|20|25|40|50|56|100]GbE. */
 #define SPEED_10		10
 #define SPEED_100		100
 #define SPEED_1000		1000
 #define SPEED_2500		2500
+#define SPEED_5000		5000
 #define SPEED_10000		10000
 #define SPEED_20000		20000
+#define SPEED_25000		25000
 #define SPEED_40000		40000
+#define SPEED_50000		50000
 #define SPEED_56000		56000
+#define SPEED_100000		100000
 
 #define SPEED_UNKNOWN		-1
 
+static __inline__ int ethtool_validate_speed(__u32 speed)
+{
+	switch (speed) {
+	case SPEED_10:
+	case SPEED_100:
+	case SPEED_1000:
+	case SPEED_2500:
+	case SPEED_5000:
+	case SPEED_10000:
+	case SPEED_20000:
+	case SPEED_25000:
+	case SPEED_40000:
+	case SPEED_50000:
+	case SPEED_56000:
+	case SPEED_100000:
+	case SPEED_UNKNOWN:
+		return 1;
+	}
+
+	return 0;
+}
+
 /* Duplex, half or full. */
 #define DUPLEX_HALF		0x00
 #define DUPLEX_FULL		0x01
 #define DUPLEX_UNKNOWN		0xff
 
+static __inline__ int ethtool_validate_duplex(__u8 duplex)
+{
+	switch (duplex) {
+	case DUPLEX_HALF:
+	case DUPLEX_FULL:
+	case DUPLEX_UNKNOWN:
+		return 1;
+	}
+
+	return 0;
+}
+
 /* Which connector port. */
 #define PORT_TP			0x00
 #define PORT_AUI		0x01
@@ -1324,15 +1457,17 @@ enum ethtool_sfeatures_retval_bits {
 #define	UDP_V4_FLOW	0x02	/* hash or spec (udp_ip4_spec) */
 #define	SCTP_V4_FLOW	0x03	/* hash or spec (sctp_ip4_spec) */
 #define	AH_ESP_V4_FLOW	0x04	/* hash only */
-#define	TCP_V6_FLOW	0x05	/* hash only */
-#define	UDP_V6_FLOW	0x06	/* hash only */
-#define	SCTP_V6_FLOW	0x07	/* hash only */
+#define	TCP_V6_FLOW	0x05	/* hash or spec (tcp_ip6_spec; nfc only) */
+#define	UDP_V6_FLOW	0x06	/* hash or spec (udp_ip6_spec; nfc only) */
+#define	SCTP_V6_FLOW	0x07	/* hash or spec (sctp_ip6_spec; nfc only) */
 #define	AH_ESP_V6_FLOW	0x08	/* hash only */
 #define	AH_V4_FLOW	0x09	/* hash or spec (ah_ip4_spec) */
 #define	ESP_V4_FLOW	0x0a	/* hash or spec (esp_ip4_spec) */
-#define	AH_V6_FLOW	0x0b	/* hash only */
-#define	ESP_V6_FLOW	0x0c	/* hash only */
-#define	IP_USER_FLOW	0x0d	/* spec only (usr_ip4_spec) */
+#define	AH_V6_FLOW	0x0b	/* hash or spec (ah_ip6_spec; nfc only) */
+#define	ESP_V6_FLOW	0x0c	/* hash or spec (esp_ip6_spec; nfc only) */
+#define	IPV4_USER_FLOW	0x0d	/* spec only (usr_ip4_spec) */
+#define	IP_USER_FLOW	IPV4_USER_FLOW
+#define	IPV6_USER_FLOW	0x0e	/* spec only (usr_ip6_spec; nfc only) */
 #define	IPV4_FLOW	0x10	/* hash only */
 #define	IPV6_FLOW	0x11	/* hash only */
 #define	ETHER_FLOW	0x12	/* spec only (ether_spec) */
