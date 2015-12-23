From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 1/2] ethtool-copy.h: sync with net
Date: Wed, 23 Dec 2015 12:58:30 +0100
Message-ID: <1450871911-19509-2-git-send-email-andrew@lunn.ch>
References: <1450871911-19509-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48592 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932172AbbLWL6l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 06:58:41 -0500
In-Reply-To: <1450871911-19509-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    This covers kernel changes up to:

commit eff3cddc222c88943ff515ae9335687c9e2cbaf6
Author: Jacob Keller <jacob.e.keller@intel.com>
Date:   Wed Apr 22 14:40:30 2015 -0700

    clarify implementation of ethtool's get_ts_info op

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 ethtool-copy.h | 55 +++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 49 insertions(+), 6 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index d23ffc4..57fa390 100644
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
@@ -110,7 +110,7 @@ struct ethtool_cmd {
 	__u32	reserved[2];
 };
 
-static __inline__ void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
+static inline void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
 					 __u32 speed)
 {
 
@@ -118,7 +118,7 @@ static __inline__ void ethtool_cmd_speed_set(struct ethtool_cmd *ep,
 	ep->speed_hi = (__u16)(speed >> 16);
 }
 
-static __inline__ __u32 ethtool_cmd_speed(const struct ethtool_cmd *ep)
+static inline __u32 ethtool_cmd_speed(const struct ethtool_cmd *ep)
 {
 	return (ep->speed_hi << 16) | ep->speed;
 }
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
@@ -796,6 +804,31 @@ struct ethtool_rx_flow_spec {
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
@@ -1062,6 +1095,11 @@ struct ethtool_sfeatures {
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
@@ -1189,6 +1227,7 @@ enum ethtool_sfeatures_retval_bits {
 #define ETHTOOL_SRSSH		0x00000047 /* Set RX flow hash configuration */
 #define ETHTOOL_GTUNABLE	0x00000048 /* Get tunable configuration */
 #define ETHTOOL_STUNABLE	0x00000049 /* Set tunable configuration */
+#define ETHTOOL_GPHYSTATS	0x0000004a /* get PHY-specific statistics */
 
 /* compatibility with older code */
 #define SPARC_ETH_GSET		ETHTOOL_GSET
@@ -1264,15 +1303,19 @@ enum ethtool_sfeatures_retval_bits {
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
 
@@ -1398,4 +1441,4 @@ enum ethtool_reset_flags {
 };
 #define ETH_RESET_SHARED_SHIFT	16
 
-#endif /* _LINUX_ETHTOOL_H */
+#endif /* _UAPI_LINUX_ETHTOOL_H */
-- 
2.1.4
