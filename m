From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [ethtool PATCH 2/6] Add support for NFC flow classifier extensions
Date: Thu, 21 Apr 2011 13:40:25 -0700
Message-ID: <20110421204025.23054.3310.stgit@gitlad.jf.intel.com>
References: <20110421202857.23054.63316.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:31248 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754317Ab1DUUk0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2011 16:40:26 -0400
In-Reply-To: <20110421202857.23054.63316.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that we can add VLAN Ethertype, TCI, and 64bits of
driver defined data to a network flow classifier allowing us to handle a
n-tuple flow contained within a network flow classifier.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 ethtool-copy.h |   39 ++++++++++++++++++++++++++++-----------
 1 files changed, 28 insertions(+), 11 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index 75c3ae7..5b45442 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -376,27 +376,42 @@ struct ethtool_usrip4_spec {
 	__u8    proto;
 };
 
+union ethtool_flow_union {
+	struct ethtool_tcpip4_spec		tcp_ip4_spec;
+	struct ethtool_tcpip4_spec		udp_ip4_spec;
+	struct ethtool_tcpip4_spec		sctp_ip4_spec;
+	struct ethtool_ah_espip4_spec		ah_ip4_spec;
+	struct ethtool_ah_espip4_spec		esp_ip4_spec;
+	struct ethtool_usrip4_spec		usr_ip4_spec;
+	struct ethhdr				ether_spec;
+	__u8					hdata[60];
+};
+
+struct ethtool_flow_ext {
+	__be16	vlan_etype;
+	__be16	vlan_tci;
+	__be32	data[2];
+};
+
 /**
  * struct ethtool_rx_flow_spec - specification for RX flow filter
  * @flow_type: Type of match to perform, e.g. %TCP_V4_FLOW
  * @h_u: Flow fields to match (dependent on @flow_type)
- * @m_u: Masks for flow field bits to be ignored
+ * @h_ext: Additional fields to match
+ * @m_u: Masks for flow field bits to be matched
+ * @m_ext: Masks for additional field bits to be matched
+ *	Note, all additional fields must be ignored unless @flow_type
+ *	includes the %FLOW_EXT flag.
  * @ring_cookie: RX ring/queue index to deliver to, or %RX_CLS_FLOW_DISC
  *	if packets should be discarded
  * @location: Index of filter in hardware table
  */
 struct ethtool_rx_flow_spec {
 	__u32		flow_type;
-	union {
-		struct ethtool_tcpip4_spec		tcp_ip4_spec;
-		struct ethtool_tcpip4_spec		udp_ip4_spec;
-		struct ethtool_tcpip4_spec		sctp_ip4_spec;
-		struct ethtool_ah_espip4_spec		ah_ip4_spec;
-		struct ethtool_ah_espip4_spec		esp_ip4_spec;
-		struct ethtool_usrip4_spec		usr_ip4_spec;
-		struct ethhdr				ether_spec;
-		__u8					hdata[72];
-	} h_u, m_u;
+	union ethtool_flow_union h_u;
+	struct ethtool_flow_ext h_ext;
+	union ethtool_flow_union m_u;
+	struct ethtool_flow_ext m_ext;
 	__u64		ring_cookie;
 	__u32		location;
 };
@@ -706,6 +721,8 @@ struct ethtool_flash {
 #define	IPV4_FLOW	0x10	/* hash only */
 #define	IPV6_FLOW	0x11	/* hash only */
 #define	ETHER_FLOW	0x12	/* spec only (ether_spec) */
+/* Flag to enable additional fields in struct ethtool_rx_flow_spec */
+#define	FLOW_EXT	0x80000000
 
 /* L3-L4 network traffic flow hash options */
 #define	RXH_L2DA	(1 << 1)

