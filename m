From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next-2.6 PATCH 02/10] ethtool: add ntuple flow specifier to
	network flow classifier
Date: Fri, 25 Feb 2011 15:32:49 -0800
Message-ID: <20110225233249.7920.70334.stgit@gitlad.jf.intel.com>
References: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:63658 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932815Ab1BYXcu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Feb 2011 18:32:50 -0500
In-Reply-To: <20110225232357.7920.58559.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is meant to add an ntuple define type to the rx network flow
classification specifiers.  The idea is to allow ntuple to be displayed and
possibly configured via the network flow classification interface.  To do
this I added a ntuple_flow_spec_ext to the lsit of supported filters, and
added a flow_type_ext value to the structure in an unused hole within the
ethtool_rx_flow_spec structure.

Due to the fact that the flow specifier structures are only 4 byte aligned
instead of 8 I had to break the user data field into 2 sections.  In
addition I added the vlan ethertype field since this is what ixgbe was
using the user-data for currently and it allows for the fields to stay 4
byte aligned while occupying space at the end of the flow_spec.

In order to guarantee byte ordering I also thought it best to keep all
fields in the flow_spec area a big endian value, as such I added vlan, vlan
ethertype, and data as big endian values.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 include/linux/ethtool.h |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index aac3e2e..3d1f8e0 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -378,10 +378,25 @@ struct ethtool_usrip4_spec {
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
@@ -396,8 +411,10 @@ struct ethtool_rx_flow_spec {
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
@@ -955,6 +972,9 @@ struct ethtool_ops {
 #define	IPV6_FLOW	0x11	/* hash only */
 #define	ETHER_FLOW	0x12	/* spec only (ether_spec) */
 
+/* Flow extension types for network flow classifier */
+#define NTUPLE_FLOW_EXT	0x01 /* indicates ntuple in nfc */
+
 /* L3-L4 network traffic flow hash options */
 #define	RXH_L2DA	(1 << 1)
 #define	RXH_VLAN	(1 << 2)

