From: David Decotigny <ddecotig@gmail.com>
Subject: [ethtool PATCH v2 08/12] ethtool-copy.h: sync with net-next
Date: Thu,  3 Mar 2016 20:23:21 -0800
Message-ID: <1457065405-19049-9-git-send-email-ddecotig@gmail.com>
References: <1457065405-19049-1-git-send-email-ddecotig@gmail.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	David Miller <davem@redhat.com>,
	Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
	David Decotigny <decot@googlers.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:32888 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757940AbcCDEXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 23:23:52 -0500
Received: by mail-pa0-f68.google.com with SMTP id gc2so1758039pab.0
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2016 20:23:47 -0800 (PST)
In-Reply-To: <1457065405-19049-1-git-send-email-ddecotig@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Decotigny <decot@googlers.com>

This cover changes up to:

  commit 3f1ac7a700d039c61d8d8b99f28d605d489a60cf
  Author: David Decotigny <decot@googlers.com>
  Date:   Wed Feb 24 10:57:59 2016 -0800

      net: ethtool: add new ETHTOOL_xLINKSETTINGS API


Signed-off-by: David Decotigny <decot@googlers.com>
---
 ethtool-copy.h | 485 +++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 405 insertions(+), 80 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index d23ffc4..37fd6dc 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -10,8 +10,8 @@
  * Portions Copyright (C) Sun Microsystems 2008
  */
 
-#ifndef _LINUX_ETHTOOL_H
-#define _LINUX_ETHTOOL_H
+#ifndef _UAPI_LINUX_ETHTOOL_H
+#define _UAPI_LINUX_ETHTOOL_H
 
 #include <linux/types.h>
 #include <linux/if_ether.h>
@@ -21,7 +21,8 @@
  */
 
 /**
- * struct ethtool_cmd - link control and status
+ * struct ethtool_cmd - DEPRECATED, link control and status
+ * This structure is DEPRECATED, please use struct ethtool_link_settings.
  * @cmd: Command number = %ETHTOOL_GSET or %ETHTOOL_SSET
  * @supported: Bitmask of %SUPPORTED_* flags for the link modes,
  *	physical connectors and other link features for which the
@@ -31,7 +32,7 @@
  *	physical connectors and other link features that are
  *	advertised through autonegotiation or enabled for
  *	auto-detection.
- * @speed: Low bits of the speed
+ * @speed: Low bits of the speed, 1Mb units, 0 to INT_MAX or SPEED_UNKNOWN
  * @duplex: Duplex mode; one of %DUPLEX_*
  * @port: Physical connector type; one of %PORT_*
  * @phy_address: MDIO address of PHY (transceiver); 0 or 255 if not
@@ -47,7 +48,7 @@
  *	obsoleted by &struct ethtool_coalesce.  Read-only; deprecated.
  * @maxrxpkt: Historically used to report RX IRQ coalescing; now
  *	obsoleted by &struct ethtool_coalesce.  Read-only; deprecated.
- * @speed_hi: High bits of the speed
+ * @speed_hi: High bits of the speed, 1Mb units, 0 to INT_MAX or SPEED_UNKNOWN
  * @eth_tp_mdix: Ethernet twisted-pair MDI(-X) status; one of
  *	%ETH_TP_MDI_*.  If the status is unknown or not applicable, the
  *	value will be %ETH_TP_MDI_INVALID.  Read-only.
@@ -110,7 +111,7 @@ struct ethtool_cmd {
 	__u32	reserved[2];
 };
 
-static __inline__ void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
+static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
 					 __u32 speed)
 {
 
@@ -118,7 +119,7 @@ static __inline__ void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
 	ep->speed_hi = (__u16)(speed >> 16);
 }
 
-static __inline__ __u32 ethtool_cmd_speed(const struct ethtool_cmd *ep)
+static inline __u32 ethtool_cmd_speed(const struct ethtool_cmd *ep)
 {
 	return (ep->speed_hi << 16) | ep->speed;
 }
@@ -215,6 +216,11 @@ enum tunable_id {
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
@@ -537,6 +543,7 @@ struct ethtool_pauseparam {
  *	now deprecated
  * @ETH_SS_FEATURES: Device feature names
  * @ETH_SS_RSS_HASH_FUNCS: RSS hush function names
+ * @ETH_SS_PHY_STATS: Statistic names, for use with %ETHTOOL_GPHYSTATS
  */
 enum ethtool_stringset {
 	ETH_SS_TEST		= 0,
@@ -545,6 +552,8 @@ enum ethtool_stringset {
 	ETH_SS_NTUPLE_FILTERS,
 	ETH_SS_FEATURES,
 	ETH_SS_RSS_HASH_FUNCS,
+	ETH_SS_TUNABLES,
+	ETH_SS_PHY_STATS,
 };
 
 /**
@@ -740,6 +749,56 @@ struct ethtool_usrip4_spec {
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
@@ -747,6 +806,12 @@ union ethtool_flow_union {
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
@@ -796,6 +861,31 @@ struct ethtool_rx_flow_spec {
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
+static inline __u64 ethtool_get_flow_spec_ring(__u64 ring_cookie)
+{
+	return ETHTOOL_RX_FLOW_SPEC_RING & ring_cookie;
+};
+
+static inline __u64 ethtool_get_flow_spec_ring_vf(__u64 ring_cookie)
+{
+	return (ETHTOOL_RX_FLOW_SPEC_RING_VF & ring_cookie) >>
+				ETHTOOL_RX_FLOW_SPEC_RING_VF_OFF;
+};
+
 /**
  * struct ethtool_rxnfc - command to get or set RX flow classification rules
  * @cmd: Specific command number - %ETHTOOL_GRXFH, %ETHTOOL_SRXFH,
@@ -1062,6 +1152,11 @@ struct ethtool_sfeatures {
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
@@ -1108,10 +1203,29 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_F_WISH          (1 << ETHTOOL_F_WISH__BIT)
 #define ETHTOOL_F_COMPAT        (1 << ETHTOOL_F_COMPAT__BIT)
 
+#define MAX_NUM_QUEUE		4096
+
+/**
+ * struct ethtool_per_queue_op - apply sub command to the queues in mask.
+ * @cmd: ETHTOOL_PERQUEUE
+ * @sub_command: the sub command which apply to each queues
+ * @queue_mask: Bitmap of the queues which sub command apply to
+ * @data: A complete command structure following for each of the queues addressed
+ */
+struct ethtool_per_queue_op {
+	__u32	cmd;
+	__u32	sub_command;
+	__u32	queue_mask[DIV_ROUND_UP(MAX_NUM_QUEUE, 32)];
+	char	data[];
+};
 
 /* CMDs currently supported */
-#define ETHTOOL_GSET		0x00000001 /* Get settings. */
-#define ETHTOOL_SSET		0x00000002 /* Set settings. */
+#define ETHTOOL_GSET		0x00000001 /* DEPRECATED, Get settings.
+					    * Please use ETHTOOL_GLINKSETTINGS
+					    */
+#define ETHTOOL_SSET		0x00000002 /* DEPRECATED, Set settings.
+					    * Please use ETHTOOL_SLINKSETTINGS
+					    */
 #define ETHTOOL_GDRVINFO	0x00000003 /* Get driver info. */
 #define ETHTOOL_GREGS		0x00000004 /* Get NIC registers. */
 #define ETHTOOL_GWOL		0x00000005 /* Get wake-on-lan options. */
@@ -1189,74 +1303,143 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_SRSSH		0x00000047 /* Set RX flow hash configuration */
 #define ETHTOOL_GTUNABLE	0x00000048 /* Get tunable configuration */
 #define ETHTOOL_STUNABLE	0x00000049 /* Set tunable configuration */
+#define ETHTOOL_GPHYSTATS	0x0000004a /* get PHY-specific statistics */
+
+#define ETHTOOL_PERQUEUE	0x0000004b /* Set per queue options */
+
+#define ETHTOOL_GLINKSETTINGS	0x0000004c /* Get ethtool_link_settings */
+#define ETHTOOL_SLINKSETTINGS	0x0000004d /* Set ethtool_link_settings */
+
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
 #define SPARC_ETH_SSET		ETHTOOL_SSET
 
-#define SUPPORTED_10baseT_Half		(1 << 0)
-#define SUPPORTED_10baseT_Full		(1 << 1)
-#define SUPPORTED_100baseT_Half		(1 << 2)
-#define SUPPORTED_100baseT_Full		(1 << 3)
-#define SUPPORTED_1000baseT_Half	(1 << 4)
-#define SUPPORTED_1000baseT_Full	(1 << 5)
-#define SUPPORTED_Autoneg		(1 << 6)
-#define SUPPORTED_TP			(1 << 7)
-#define SUPPORTED_AUI			(1 << 8)
-#define SUPPORTED_MII			(1 << 9)
-#define SUPPORTED_FIBRE			(1 << 10)
-#define SUPPORTED_BNC			(1 << 11)
-#define SUPPORTED_10000baseT_Full	(1 << 12)
-#define SUPPORTED_Pause			(1 << 13)
-#define SUPPORTED_Asym_Pause		(1 << 14)
-#define SUPPORTED_2500baseX_Full	(1 << 15)
-#define SUPPORTED_Backplane		(1 << 16)
-#define SUPPORTED_1000baseKX_Full	(1 << 17)
-#define SUPPORTED_10000baseKX4_Full	(1 << 18)
-#define SUPPORTED_10000baseKR_Full	(1 << 19)
-#define SUPPORTED_10000baseR_FEC	(1 << 20)
-#define SUPPORTED_20000baseMLD2_Full	(1 << 21)
-#define SUPPORTED_20000baseKR2_Full	(1 << 22)
-#define SUPPORTED_40000baseKR4_Full	(1 << 23)
-#define SUPPORTED_40000baseCR4_Full	(1 << 24)
-#define SUPPORTED_40000baseSR4_Full	(1 << 25)
-#define SUPPORTED_40000baseLR4_Full	(1 << 26)
-#define SUPPORTED_56000baseKR4_Full	(1 << 27)
-#define SUPPORTED_56000baseCR4_Full	(1 << 28)
-#define SUPPORTED_56000baseSR4_Full	(1 << 29)
-#define SUPPORTED_56000baseLR4_Full	(1 << 30)
-
-#define ADVERTISED_10baseT_Half		(1 << 0)
-#define ADVERTISED_10baseT_Full		(1 << 1)
-#define ADVERTISED_100baseT_Half	(1 << 2)
-#define ADVERTISED_100baseT_Full	(1 << 3)
-#define ADVERTISED_1000baseT_Half	(1 << 4)
-#define ADVERTISED_1000baseT_Full	(1 << 5)
-#define ADVERTISED_Autoneg		(1 << 6)
-#define ADVERTISED_TP			(1 << 7)
-#define ADVERTISED_AUI			(1 << 8)
-#define ADVERTISED_MII			(1 << 9)
-#define ADVERTISED_FIBRE		(1 << 10)
-#define ADVERTISED_BNC			(1 << 11)
-#define ADVERTISED_10000baseT_Full	(1 << 12)
-#define ADVERTISED_Pause		(1 << 13)
-#define ADVERTISED_Asym_Pause		(1 << 14)
-#define ADVERTISED_2500baseX_Full	(1 << 15)
-#define ADVERTISED_Backplane		(1 << 16)
-#define ADVERTISED_1000baseKX_Full	(1 << 17)
-#define ADVERTISED_10000baseKX4_Full	(1 << 18)
-#define ADVERTISED_10000baseKR_Full	(1 << 19)
-#define ADVERTISED_10000baseR_FEC	(1 << 20)
-#define ADVERTISED_20000baseMLD2_Full	(1 << 21)
-#define ADVERTISED_20000baseKR2_Full	(1 << 22)
-#define ADVERTISED_40000baseKR4_Full	(1 << 23)
-#define ADVERTISED_40000baseCR4_Full	(1 << 24)
-#define ADVERTISED_40000baseSR4_Full	(1 << 25)
-#define ADVERTISED_40000baseLR4_Full	(1 << 26)
-#define ADVERTISED_56000baseKR4_Full	(1 << 27)
-#define ADVERTISED_56000baseCR4_Full	(1 << 28)
-#define ADVERTISED_56000baseSR4_Full	(1 << 29)
-#define ADVERTISED_56000baseLR4_Full	(1 << 30)
+/* Link mode bit indices */
+enum ethtool_link_mode_bit_indices {
+	ETHTOOL_LINK_MODE_10baseT_Half_BIT	= 0,
+	ETHTOOL_LINK_MODE_10baseT_Full_BIT	= 1,
+	ETHTOOL_LINK_MODE_100baseT_Half_BIT	= 2,
+	ETHTOOL_LINK_MODE_100baseT_Full_BIT	= 3,
+	ETHTOOL_LINK_MODE_1000baseT_Half_BIT	= 4,
+	ETHTOOL_LINK_MODE_1000baseT_Full_BIT	= 5,
+	ETHTOOL_LINK_MODE_Autoneg_BIT		= 6,
+	ETHTOOL_LINK_MODE_TP_BIT		= 7,
+	ETHTOOL_LINK_MODE_AUI_BIT		= 8,
+	ETHTOOL_LINK_MODE_MII_BIT		= 9,
+	ETHTOOL_LINK_MODE_FIBRE_BIT		= 10,
+	ETHTOOL_LINK_MODE_BNC_BIT		= 11,
+	ETHTOOL_LINK_MODE_10000baseT_Full_BIT	= 12,
+	ETHTOOL_LINK_MODE_Pause_BIT		= 13,
+	ETHTOOL_LINK_MODE_Asym_Pause_BIT	= 14,
+	ETHTOOL_LINK_MODE_2500baseX_Full_BIT	= 15,
+	ETHTOOL_LINK_MODE_Backplane_BIT		= 16,
+	ETHTOOL_LINK_MODE_1000baseKX_Full_BIT	= 17,
+	ETHTOOL_LINK_MODE_10000baseKX4_Full_BIT	= 18,
+	ETHTOOL_LINK_MODE_10000baseKR_Full_BIT	= 19,
+	ETHTOOL_LINK_MODE_10000baseR_FEC_BIT	= 20,
+	ETHTOOL_LINK_MODE_20000baseMLD2_Full_BIT = 21,
+	ETHTOOL_LINK_MODE_20000baseKR2_Full_BIT	= 22,
+	ETHTOOL_LINK_MODE_40000baseKR4_Full_BIT	= 23,
+	ETHTOOL_LINK_MODE_40000baseCR4_Full_BIT	= 24,
+	ETHTOOL_LINK_MODE_40000baseSR4_Full_BIT	= 25,
+	ETHTOOL_LINK_MODE_40000baseLR4_Full_BIT	= 26,
+	ETHTOOL_LINK_MODE_56000baseKR4_Full_BIT	= 27,
+	ETHTOOL_LINK_MODE_56000baseCR4_Full_BIT	= 28,
+	ETHTOOL_LINK_MODE_56000baseSR4_Full_BIT	= 29,
+	ETHTOOL_LINK_MODE_56000baseLR4_Full_BIT	= 30,
+
+	/* Last allowed bit for __ETHTOOL_LINK_MODE_LEGACY_MASK is bit
+	 * 31. Please do NOT define any SUPPORTED_* or ADVERTISED_*
+	 * macro for bits > 31. The only way to use indices > 31 is to
+	 * use the new ETHTOOL_GLINKSETTINGS/ETHTOOL_SLINKSETTINGS API.
+	 */
+
+	__ETHTOOL_LINK_MODE_LAST
+	  = ETHTOOL_LINK_MODE_56000baseLR4_Full_BIT,
+};
+
+#define __ETHTOOL_LINK_MODE_LEGACY_MASK(base_name)	\
+	(1UL << (ETHTOOL_LINK_MODE_ ## base_name ## _BIT))
+
+/* DEPRECATED macros. Please migrate to
+ * ETHTOOL_GLINKSETTINGS/ETHTOOL_SLINKSETTINGS API. Please do NOT
+ * define any new SUPPORTED_* macro for bits > 31.
+ */
+#define SUPPORTED_10baseT_Half		__ETHTOOL_LINK_MODE_LEGACY_MASK(10baseT_Half)
+#define SUPPORTED_10baseT_Full		__ETHTOOL_LINK_MODE_LEGACY_MASK(10baseT_Full)
+#define SUPPORTED_100baseT_Half		__ETHTOOL_LINK_MODE_LEGACY_MASK(100baseT_Half)
+#define SUPPORTED_100baseT_Full		__ETHTOOL_LINK_MODE_LEGACY_MASK(100baseT_Full)
+#define SUPPORTED_1000baseT_Half	__ETHTOOL_LINK_MODE_LEGACY_MASK(1000baseT_Half)
+#define SUPPORTED_1000baseT_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(1000baseT_Full)
+#define SUPPORTED_Autoneg		__ETHTOOL_LINK_MODE_LEGACY_MASK(Autoneg)
+#define SUPPORTED_TP			__ETHTOOL_LINK_MODE_LEGACY_MASK(TP)
+#define SUPPORTED_AUI			__ETHTOOL_LINK_MODE_LEGACY_MASK(AUI)
+#define SUPPORTED_MII			__ETHTOOL_LINK_MODE_LEGACY_MASK(MII)
+#define SUPPORTED_FIBRE			__ETHTOOL_LINK_MODE_LEGACY_MASK(FIBRE)
+#define SUPPORTED_BNC			__ETHTOOL_LINK_MODE_LEGACY_MASK(BNC)
+#define SUPPORTED_10000baseT_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(10000baseT_Full)
+#define SUPPORTED_Pause			__ETHTOOL_LINK_MODE_LEGACY_MASK(Pause)
+#define SUPPORTED_Asym_Pause		__ETHTOOL_LINK_MODE_LEGACY_MASK(Asym_Pause)
+#define SUPPORTED_2500baseX_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(2500baseX_Full)
+#define SUPPORTED_Backplane		__ETHTOOL_LINK_MODE_LEGACY_MASK(Backplane)
+#define SUPPORTED_1000baseKX_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(1000baseKX_Full)
+#define SUPPORTED_10000baseKX4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(10000baseKX4_Full)
+#define SUPPORTED_10000baseKR_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(10000baseKR_Full)
+#define SUPPORTED_10000baseR_FEC	__ETHTOOL_LINK_MODE_LEGACY_MASK(10000baseR_FEC)
+#define SUPPORTED_20000baseMLD2_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(20000baseMLD2_Full)
+#define SUPPORTED_20000baseKR2_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(20000baseKR2_Full)
+#define SUPPORTED_40000baseKR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(40000baseKR4_Full)
+#define SUPPORTED_40000baseCR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(40000baseCR4_Full)
+#define SUPPORTED_40000baseSR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(40000baseSR4_Full)
+#define SUPPORTED_40000baseLR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(40000baseLR4_Full)
+#define SUPPORTED_56000baseKR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(56000baseKR4_Full)
+#define SUPPORTED_56000baseCR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(56000baseCR4_Full)
+#define SUPPORTED_56000baseSR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(56000baseSR4_Full)
+#define SUPPORTED_56000baseLR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(56000baseLR4_Full)
+/* Please do not define any new SUPPORTED_* macro for bits > 31, see
+ * notice above.
+ */
+
+/*
+ * DEPRECATED macros. Please migrate to
+ * ETHTOOL_GLINKSETTINGS/ETHTOOL_SLINKSETTINGS API. Please do NOT
+ * define any new ADERTISE_* macro for bits > 31.
+ */
+#define ADVERTISED_10baseT_Half		__ETHTOOL_LINK_MODE_LEGACY_MASK(10baseT_Half)
+#define ADVERTISED_10baseT_Full		__ETHTOOL_LINK_MODE_LEGACY_MASK(10baseT_Full)
+#define ADVERTISED_100baseT_Half	__ETHTOOL_LINK_MODE_LEGACY_MASK(100baseT_Half)
+#define ADVERTISED_100baseT_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(100baseT_Full)
+#define ADVERTISED_1000baseT_Half	__ETHTOOL_LINK_MODE_LEGACY_MASK(1000baseT_Half)
+#define ADVERTISED_1000baseT_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(1000baseT_Full)
+#define ADVERTISED_Autoneg		__ETHTOOL_LINK_MODE_LEGACY_MASK(Autoneg)
+#define ADVERTISED_TP			__ETHTOOL_LINK_MODE_LEGACY_MASK(TP)
+#define ADVERTISED_AUI			__ETHTOOL_LINK_MODE_LEGACY_MASK(AUI)
+#define ADVERTISED_MII			__ETHTOOL_LINK_MODE_LEGACY_MASK(MII)
+#define ADVERTISED_FIBRE		__ETHTOOL_LINK_MODE_LEGACY_MASK(FIBRE)
+#define ADVERTISED_BNC			__ETHTOOL_LINK_MODE_LEGACY_MASK(BNC)
+#define ADVERTISED_10000baseT_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(10000baseT_Full)
+#define ADVERTISED_Pause		__ETHTOOL_LINK_MODE_LEGACY_MASK(Pause)
+#define ADVERTISED_Asym_Pause		__ETHTOOL_LINK_MODE_LEGACY_MASK(Asym_Pause)
+#define ADVERTISED_2500baseX_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(2500baseX_Full)
+#define ADVERTISED_Backplane		__ETHTOOL_LINK_MODE_LEGACY_MASK(Backplane)
+#define ADVERTISED_1000baseKX_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(1000baseKX_Full)
+#define ADVERTISED_10000baseKX4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(10000baseKX4_Full)
+#define ADVERTISED_10000baseKR_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(10000baseKR_Full)
+#define ADVERTISED_10000baseR_FEC	__ETHTOOL_LINK_MODE_LEGACY_MASK(10000baseR_FEC)
+#define ADVERTISED_20000baseMLD2_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(20000baseMLD2_Full)
+#define ADVERTISED_20000baseKR2_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(20000baseKR2_Full)
+#define ADVERTISED_40000baseKR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(40000baseKR4_Full)
+#define ADVERTISED_40000baseCR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(40000baseCR4_Full)
+#define ADVERTISED_40000baseSR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(40000baseSR4_Full)
+#define ADVERTISED_40000baseLR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(40000baseLR4_Full)
+#define ADVERTISED_56000baseKR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(56000baseKR4_Full)
+#define ADVERTISED_56000baseCR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(56000baseCR4_Full)
+#define ADVERTISED_56000baseSR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(56000baseSR4_Full)
+#define ADVERTISED_56000baseLR4_Full	__ETHTOOL_LINK_MODE_LEGACY_MASK(56000baseLR4_Full)
+/* Please do not define any new ADVERTISED_* macro for bits > 31, see
+ * notice above.
+ */
 
 /* The following are all involved in forcing a particular link
  * mode for the device for setting things.  When getting the
@@ -1264,23 +1447,44 @@ enum ethtool_sfeatures_retval_bits {
  * it was forced up into this mode or autonegotiated.
  */
 
-/* The forced speed, 10Mb, 100Mb, gigabit, [2.5|10|20|40|56]GbE. */
+/* The forced speed, in units of 1Mb. All values 0 to INT_MAX are legal. */
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
@@ -1324,15 +1528,17 @@ enum ethtool_sfeatures_retval_bits {
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
@@ -1398,4 +1604,123 @@ enum ethtool_reset_flags {
 };
 #define ETH_RESET_SHARED_SHIFT	16
 
-#endif /* _LINUX_ETHTOOL_H */
+
+/**
+ * struct ethtool_link_settings - link control and status
+ *
+ * IMPORTANT, Backward compatibility notice: When implementing new
+ *	user-space tools, please first try %ETHTOOL_GLINKSETTINGS, and
+ *	if it succeeds use %ETHTOOL_SLINKSETTINGS to change link
+ *	settings; do not use %ETHTOOL_SSET if %ETHTOOL_GLINKSETTINGS
+ *	succeeded: stick to %ETHTOOL_GLINKSETTINGS/%SLINKSETTINGS in
+ *	that case.  Conversely, if %ETHTOOL_GLINKSETTINGS fails, use
+ *	%ETHTOOL_GSET to query and %ETHTOOL_SSET to change link
+ *	settings; do not use %ETHTOOL_SLINKSETTINGS if
+ *	%ETHTOOL_GLINKSETTINGS failed: stick to
+ *	%ETHTOOL_GSET/%ETHTOOL_SSET in that case.
+ *
+ * @cmd: Command number = %ETHTOOL_GLINKSETTINGS or %ETHTOOL_SLINKSETTINGS
+ * @speed: Link speed (Mbps)
+ * @duplex: Duplex mode; one of %DUPLEX_*
+ * @port: Physical connector type; one of %PORT_*
+ * @phy_address: MDIO address of PHY (transceiver); 0 or 255 if not
+ *	applicable.  For clause 45 PHYs this is the PRTAD.
+ * @autoneg: Enable/disable autonegotiation and auto-detection;
+ *	either %AUTONEG_DISABLE or %AUTONEG_ENABLE
+ * @mdio_support: Bitmask of %ETH_MDIO_SUPPORTS_* flags for the MDIO
+ *	protocols supported by the interface; 0 if unknown.
+ *	Read-only.
+ * @eth_tp_mdix: Ethernet twisted-pair MDI(-X) status; one of
+ *	%ETH_TP_MDI_*.  If the status is unknown or not applicable, the
+ *	value will be %ETH_TP_MDI_INVALID.  Read-only.
+ * @eth_tp_mdix_ctrl: Ethernet twisted pair MDI(-X) control; one of
+ *	%ETH_TP_MDI_*.  If MDI(-X) control is not implemented, reads
+ *	yield %ETH_TP_MDI_INVALID and writes may be ignored or rejected.
+ *	When written successfully, the link should be renegotiated if
+ *	necessary.
+ * @link_mode_masks_nwords: Number of 32-bit words for each of the
+ *	supported, advertising, lp_advertising link mode bitmaps. For
+ *	%ETHTOOL_GLINKSETTINGS: on entry, number of words passed by user
+ *	(>= 0); on return, if handshake in progress, negative if
+ *	request size unsupported by kernel: absolute value indicates
+ *	kernel recommended size and cmd field is 0, as well as all the
+ *	other fields; otherwise (handshake completed), strictly
+ *	positive to indicate size used by kernel and cmd field is
+ *	%ETHTOOL_GLINKSETTINGS, all other fields populated by driver. For
+ *	%ETHTOOL_SLINKSETTINGS: must be valid on entry, ie. a positive
+ *	value returned previously by %ETHTOOL_GLINKSETTINGS, otherwise
+ *	refused. For drivers: ignore this field (use kernel's
+ *	__ETHTOOL_LINK_MODE_MASK_NBITS instead), any change to it will
+ *	be overwritten by kernel.
+ * @supported: Bitmap with each bit meaning given by
+ *	%ethtool_link_mode_bit_indices for the link modes, physical
+ *	connectors and other link features for which the interface
+ *	supports autonegotiation or auto-detection.  Read-only.
+ * @advertising: Bitmap with each bit meaning given by
+ *	%ethtool_link_mode_bit_indices for the link modes, physical
+ *	connectors and other link features that are advertised through
+ *	autonegotiation or enabled for auto-detection.
+ * @lp_advertising: Bitmap with each bit meaning given by
+ *	%ethtool_link_mode_bit_indices for the link modes, and other
+ *	link features that the link partner advertised through
+ *	autonegotiation; 0 if unknown or not applicable.  Read-only.
+ *
+ * If autonegotiation is disabled, the speed and @duplex represent the
+ * fixed link mode and are writable if the driver supports multiple
+ * link modes.  If it is enabled then they are read-only; if the link
+ * is up they represent the negotiated link mode; if the link is down,
+ * the speed is 0, %SPEED_UNKNOWN or the highest enabled speed and
+ * @duplex is %DUPLEX_UNKNOWN or the best enabled duplex mode.
+ *
+ * Some hardware interfaces may have multiple PHYs and/or physical
+ * connectors fitted or do not allow the driver to detect which are
+ * fitted.  For these interfaces @port and/or @phy_address may be
+ * writable, possibly dependent on @autoneg being %AUTONEG_DISABLE.
+ * Otherwise, attempts to write different values may be ignored or
+ * rejected.
+ *
+ * Deprecated %ethtool_cmd fields transceiver, maxtxpkt and maxrxpkt
+ * are not available in %ethtool_link_settings. Until all drivers are
+ * converted to ignore them or to the new %ethtool_link_settings API,
+ * for both queries and changes, users should always try
+ * %ETHTOOL_GLINKSETTINGS first, and if it fails with -ENOTSUPP stick
+ * only to %ETHTOOL_GSET and %ETHTOOL_SSET consistently. If it
+ * succeeds, then users should stick to %ETHTOOL_GLINKSETTINGS and
+ * %ETHTOOL_SLINKSETTINGS (which would support drivers implementing
+ * either %ethtool_cmd or %ethtool_link_settings).
+ *
+ * Users should assume that all fields not marked read-only are
+ * writable and subject to validation by the driver.  They should use
+ * %ETHTOOL_GLINKSETTINGS to get the current values before making specific
+ * changes and then applying them with %ETHTOOL_SLINKSETTINGS.
+ *
+ * Drivers that implement %get_link_ksettings and/or
+ * %set_link_ksettings should ignore the @cmd
+ * and @link_mode_masks_nwords fields (any change to them overwritten
+ * by kernel), and rely only on kernel's internal
+ * %__ETHTOOL_LINK_MODE_MASK_NBITS and
+ * %ethtool_link_mode_mask_t. Drivers that implement
+ * %set_link_ksettings() should validate all fields other than @cmd
+ * and @link_mode_masks_nwords that are not described as read-only or
+ * deprecated, and must ignore all fields described as read-only.
+ */
+struct ethtool_link_settings {
+	__u32	cmd;
+	__u32	speed;
+	__u8	duplex;
+	__u8	port;
+	__u8	phy_address;
+	__u8	autoneg;
+	__u8	mdio_support;
+	__u8	eth_tp_mdix;
+	__u8	eth_tp_mdix_ctrl;
+	__s8	link_mode_masks_nwords;
+	__u32	reserved[8];
+	__u32	link_mode_masks[0];
+	/* layout of link_mode_masks fields:
+	 * __u32 map_supported[link_mode_masks_nwords];
+	 * __u32 map_advertising[link_mode_masks_nwords];
+	 * __u32 map_lp_advertising[link_mode_masks_nwords];
+	 */
+};
+#endif /* _UAPI_LINUX_ETHTOOL_H */
-- 
2.7.0.rc3.207.g0ac5344
