From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 1/2] ethtool-copy.h: sync with net
Date: Wed, 17 Feb 2016 21:37:15 +0100
Message-ID: <1455741436-25728-2-git-send-email-andrew@lunn.ch>
References: <1455741436-25728-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50619 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965253AbcBQUh3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 15:37:29 -0500
In-Reply-To: <1455741436-25728-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Additional, add MAX_INT to internal.h, which is now required by
ethtool-copy.h.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 ethtool-copy.h | 119 ++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 internal.h     |   3 ++
 2 files changed, 113 insertions(+), 9 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 57fa390..bce6c95 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -31,7 +31,7 @@
  *	physical connectors and other link features that are
  *	advertised through autonegotiation or enabled for
  *	auto-detection.
- * @speed: Low bits of the speed
+ * @speed: Low bits of the speed, 1Mb units, 0 to INT_MAX or SPEED_UNKNOWN
  * @duplex: Duplex mode; one of %DUPLEX_*
  * @port: Physical connector type; one of %PORT_*
  * @phy_address: MDIO address of PHY (transceiver); 0 or 255 if not
@@ -47,7 +47,7 @@
  *	obsoleted by &struct ethtool_coalesce.  Read-only; deprecated.
  * @maxrxpkt: Historically used to report RX IRQ coalescing; now
  *	obsoleted by &struct ethtool_coalesce.  Read-only; deprecated.
- * @speed_hi: High bits of the speed
+ * @speed_hi: High bits of the speed, 1Mb units, 0 to INT_MAX or SPEED_UNKNOWN
  * @eth_tp_mdix: Ethernet twisted-pair MDI(-X) status; one of
  *	%ETH_TP_MDI_*.  If the status is unknown or not applicable, the
  *	value will be %ETH_TP_MDI_INVALID.  Read-only.
@@ -748,6 +748,56 @@ struct ethtool_usrip4_spec {
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
@@ -755,6 +805,12 @@ union ethtool_flow_union {
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
@@ -1111,6 +1167,31 @@ struct ethtool_ts_info {
 	__u32	rx_reserved[3];
 };
 
+enum ethtool_phy_pkg_gen_flags {
+	ETH_PKT_RANDOM	= (1 << 0),
+	ETH_PKT_ERROR	= (1 << 1),
+};
+
+/**
+ * struct ethtool_phy_pkt_get - command to request the phy to generate packets.
+ * @cmd: command number = %ETHTOOL_PHY_PKT_GEN
+ * @count: number of packets to generate
+ * @len: length of generated packets
+ * @ipg: inter packet gap in bytes.
+ * @flags: a bitmask of flags from &enum ethtool_phy_pkg_gen_flags
+ *
+ * PHY drivers may not support all of these parameters. If the
+ * requested parameter value cannot be supported an error should be
+ * returned.
+ */
+struct ethtool_phy_pkt_gen {
+	__u32	cmd;
+	__u32	count;
+	__u32	len;
+	__u32	ipg;
+	__u32	flags;
+};
+
 /*
  * %ETHTOOL_SFEATURES changes features present in features[].valid to the
  * values of corresponding bits in features[].requested. Bits in .requested
@@ -1228,6 +1309,7 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_GTUNABLE	0x00000048 /* Get tunable configuration */
 #define ETHTOOL_STUNABLE	0x00000049 /* Set tunable configuration */
 #define ETHTOOL_GPHYSTATS	0x0000004a /* get PHY-specific statistics */
+#define ETHTOOL_PHY_PKT_GEN	0x0000004b /* Gnerate packets in the PHY */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -1303,7 +1385,7 @@ enum ethtool_sfeatures_retval_bits {
  * it was forced up into this mode or autonegotiated.
  */
 
-/* The forced speed, 10Mb, 100Mb, gigabit, [2.5|5|10|20|25|40|50|56|100]GbE. */
+/* The forced speed, in units of 1Mb. All values 0 to INT_MAX are legal. */
 #define SPEED_10		10
 #define SPEED_100		100
 #define SPEED_1000		1000
@@ -1319,11 +1401,28 @@ enum ethtool_sfeatures_retval_bits {
 
 #define SPEED_UNKNOWN		-1
 
+static inline int ethtool_validate_speed(__u32 speed)
+{
+	return speed <= INT_MAX || speed == SPEED_UNKNOWN;
+}
+
 /* Duplex, half or full. */
 #define DUPLEX_HALF		0x00
 #define DUPLEX_FULL		0x01
 #define DUPLEX_UNKNOWN		0xff
 
+static inline int ethtool_validate_duplex(__u8 duplex)
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
@@ -1367,15 +1466,17 @@ enum ethtool_sfeatures_retval_bits {
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
diff --git a/internal.h b/internal.h
index b5ef646..ce137fe 100644
--- a/internal.h
+++ b/internal.h
@@ -29,6 +29,9 @@ typedef uint16_t u16;
 typedef uint8_t u8;
 typedef int32_t s32;
 
+/* and from <linux/kernel.h> */
+#define INT_MAX ((int)(~0U>>1))
+
 #include "ethtool-copy.h"
 #include "net_tstamp-copy.h"
 
-- 
2.1.4
