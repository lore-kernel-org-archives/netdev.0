From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [net-next-2.6 PATCH] v3 ethtool: add ntuple flow specifier data to
	network flow classifier
Date: Fri, 08 Apr 2011 21:01:59 -0700
Message-ID: <20110409040159.6064.79138.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28459 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750740Ab1DIECH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Apr 2011 00:02:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is meant to add an ntuple data extensions to the rx network flow
classification specifiers.  The idea is to allow ntuple to be displayed via
the network flow classification interface.

The first patch had some left over stuff from the original flow extension
flags I had added.  That bit is removed in this patch.

The second had some left over comments that stated we ignored bits in the
masks when we actually match them.

This work is based on input from Ben Hutchings.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 include/linux/ethtool.h |   53 ++++++++++++++++++++++++++++-------------------
 net/socket.c            |   14 ++++++------
 2 files changed, 39 insertions(+), 28 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index c04d131..c7eff13 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -380,27 +380,42 @@ struct ethtool_usrip4_spec {
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
@@ -458,16 +473,10 @@ struct ethtool_rxnfc {
 
 struct compat_ethtool_rx_flow_spec {
 	u32		flow_type;
-	union {
-		struct ethtool_tcpip4_spec		tcp_ip4_spec;
-		struct ethtool_tcpip4_spec		udp_ip4_spec;
-		struct ethtool_tcpip4_spec		sctp_ip4_spec;
-		struct ethtool_ah_espip4_spec		ah_ip4_spec;
-		struct ethtool_ah_espip4_spec		esp_ip4_spec;
-		struct ethtool_usrip4_spec		usr_ip4_spec;
-		struct ethhdr				ether_spec;
-		u8					hdata[72];
-	} h_u, m_u;
+	union ethtool_flow_union h_u;
+	struct ethtool_flow_ext h_ext;
+	union ethtool_flow_union m_u;
+	struct ethtool_flow_ext m_ext;
 	compat_u64	ring_cookie;
 	u32		location;
 };
@@ -1072,6 +1081,8 @@ struct ethtool_ops {
 #define	IPV4_FLOW	0x10	/* hash only */
 #define	IPV6_FLOW	0x11	/* hash only */
 #define	ETHER_FLOW	0x12	/* spec only (ether_spec) */
+/* Flag to enable additional fields in struct ethtool_rx_flow_spec */
+#define	FLOW_EXT	0x80000000
 
 /* L3-L4 network traffic flow hash options */
 #define	RXH_L2DA	(1 << 1)
diff --git a/net/socket.c b/net/socket.c
index 5212447..575c84f 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2643,13 +2643,13 @@ static int ethtool_ioctl(struct net *net, struct compat_ifreq __user *ifr32)
 		return -EFAULT;
 
 	if (convert_in) {
-		/* We expect there to be holes between fs.m_u and
+		/* We expect there to be holes between fs.m_ext and
 		 * fs.ring_cookie and at the end of fs, but nowhere else.
 		 */
-		BUILD_BUG_ON(offsetof(struct compat_ethtool_rxnfc, fs.m_u) +
-			     sizeof(compat_rxnfc->fs.m_u) !=
-			     offsetof(struct ethtool_rxnfc, fs.m_u) +
-			     sizeof(rxnfc->fs.m_u));
+		BUILD_BUG_ON(offsetof(struct compat_ethtool_rxnfc, fs.m_ext) +
+			     sizeof(compat_rxnfc->fs.m_ext) !=
+			     offsetof(struct ethtool_rxnfc, fs.m_ext) +
+			     sizeof(rxnfc->fs.m_ext));
 		BUILD_BUG_ON(
 			offsetof(struct compat_ethtool_rxnfc, fs.location) -
 			offsetof(struct compat_ethtool_rxnfc, fs.ring_cookie) !=
@@ -2657,7 +2657,7 @@ static int ethtool_ioctl(struct net *net, struct compat_ifreq __user *ifr32)
 			offsetof(struct ethtool_rxnfc, fs.ring_cookie));
 
 		if (copy_in_user(rxnfc, compat_rxnfc,
-				 (void *)(&rxnfc->fs.m_u + 1) -
+				 (void *)(&rxnfc->fs.m_ext + 1) -
 				 (void *)rxnfc) ||
 		    copy_in_user(&rxnfc->fs.ring_cookie,
 				 &compat_rxnfc->fs.ring_cookie,
@@ -2674,7 +2674,7 @@ static int ethtool_ioctl(struct net *net, struct compat_ifreq __user *ifr32)
 
 	if (convert_out) {
 		if (copy_in_user(compat_rxnfc, rxnfc,
-				 (const void *)(&rxnfc->fs.m_u + 1) -
+				 (const void *)(&rxnfc->fs.m_ext + 1) -
 				 (const void *)rxnfc) ||
 		    copy_in_user(&compat_rxnfc->fs.ring_cookie,
 				 &rxnfc->fs.ring_cookie,

