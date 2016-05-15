From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v5 net-next 02/14] net: define gso types for IPx over IPv4 and IPv6
Date: Sun, 15 May 2016 16:42:23 -0700
Message-ID: <1463355755-3481375-3-git-send-email-tom@herbertland.com>
References: <1463355755-3481375-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:57860 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751934AbcEOXmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 May 2016 19:42:49 -0400
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u4FNfBVW023589
	for <netdev@vger.kernel.org>; Sun, 15 May 2016 16:42:49 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 22x03xx35r-1
	(version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 15 May 2016 16:42:48 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 ba63bf241af611e6a12624be0595f910-d34ebc50 for <netdev@vger.kernel.org>;	Sun,
 15 May 2016 16:42:47 -0700
In-Reply-To: <1463355755-3481375-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch defines two new GSO definitions SKB_GSO_IPXIP4 and
SKB_GSO_IPXIP6 along with corresponding NETIF_F_GSO_IPXIP4 and
NETIF_F_GSO_IPXIP6. These are used to described IP in IP
tunnel and what the outer protocol is. The inner protocol
can be deduced from other GSO types (e.g. SKB_GSO_TCPV4 and
SKB_GSO_TCPV6). The GSO types of SKB_GSO_IPIP and SKB_GSO_SIT
are removed (these are both instances of SKB_GSO_IPXIP4).
SKB_GSO_IPXIP6 will be used when support for GSO with IP
encapsulation over IPv6 is added.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |  5 ++---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         |  4 ++--
 drivers/net/ethernet/intel/i40e/i40e_main.c       |  3 +--
 drivers/net/ethernet/intel/i40e/i40e_txrx.c       |  3 +--
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c     |  3 +--
 drivers/net/ethernet/intel/i40evf/i40evf_main.c   |  3 +--
 drivers/net/ethernet/intel/igb/igb_main.c         |  3 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  3 +--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  3 +--
 include/linux/netdev_features.h                   | 12 ++++++------
 include/linux/netdevice.h                         |  4 ++--
 include/linux/skbuff.h                            |  4 ++--
 net/core/ethtool.c                                |  4 ++--
 net/ipv4/af_inet.c                                |  2 +-
 net/ipv4/ipip.c                                   |  2 +-
 net/ipv6/ip6_offload.c                            |  4 ++--
 net/ipv6/sit.c                                    |  4 ++--
 net/netfilter/ipvs/ip_vs_xmit.c                   | 17 +++++++----------
 18 files changed, 36 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index d465bd7..0a5b770 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -13259,12 +13259,11 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
 		NETIF_F_RXHASH | NETIF_F_HW_VLAN_CTAG_TX;
 	if (!chip_is_e1x) {
 		dev->hw_features |= NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL |
-				    NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT;
+				    NETIF_F_GSO_IPXIP4;
 		dev->hw_enc_features =
 			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_SG |
 			NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 |
-			NETIF_F_GSO_IPIP |
-			NETIF_F_GSO_SIT |
+			NETIF_F_GSO_IPXIP4 |
 			NETIF_F_GSO_GRE | NETIF_F_GSO_UDP_TUNNEL;
 	}
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 5a0dca3..bfc1e94 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -6311,7 +6311,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_SG |
 			   NETIF_F_TSO | NETIF_F_TSO6 |
 			   NETIF_F_GSO_UDP_TUNNEL | NETIF_F_GSO_GRE |
-			   NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT |
+			   NETIF_F_GSO_IPXIP4 |
 			   NETIF_F_GSO_UDP_TUNNEL_CSUM | NETIF_F_GSO_GRE_CSUM |
 			   NETIF_F_GSO_PARTIAL | NETIF_F_RXHASH |
 			   NETIF_F_RXCSUM | NETIF_F_LRO | NETIF_F_GRO;
@@ -6321,7 +6321,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 			NETIF_F_TSO | NETIF_F_TSO6 |
 			NETIF_F_GSO_UDP_TUNNEL | NETIF_F_GSO_GRE |
 			NETIF_F_GSO_UDP_TUNNEL_CSUM | NETIF_F_GSO_GRE_CSUM |
-			NETIF_F_GSO_IPIP | NETIF_F_GSO_SIT |
+			NETIF_F_GSO_IPXIP4;
 			NETIF_F_GSO_PARTIAL;
 	dev->gso_partial_features = NETIF_F_GSO_UDP_TUNNEL_CSUM |
 				    NETIF_F_GSO_GRE_CSUM;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 1cd0ebf..242a1ff 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9083,8 +9083,7 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 				   NETIF_F_TSO6			|
 				   NETIF_F_GSO_GRE		|
 				   NETIF_F_GSO_GRE_CSUM		|
-				   NETIF_F_GSO_IPIP		|
-				   NETIF_F_GSO_SIT		|
+				   NETIF_F_GSO_IPXIP4		|
 				   NETIF_F_GSO_UDP_TUNNEL	|
 				   NETIF_F_GSO_UDP_TUNNEL_CSUM	|
 				   NETIF_F_GSO_PARTIAL		|
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 99a524d..0a8122c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2284,8 +2284,7 @@ static int i40e_tso(struct sk_buff *skb, u8 *hdr_len, u64 *cd_type_cmd_tso_mss)
 
 	if (skb_shinfo(skb)->gso_type & (SKB_GSO_GRE |
 					 SKB_GSO_GRE_CSUM |
-					 SKB_GSO_IPIP |
-					 SKB_GSO_SIT |
+					 SKB_GSO_IPXIP4 |
 					 SKB_GSO_UDP_TUNNEL |
 					 SKB_GSO_UDP_TUNNEL_CSUM)) {
 		if (!(skb_shinfo(skb)->gso_type & SKB_GSO_PARTIAL) &&
diff --git a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
index fd7dae46..2bbbbd0 100644
--- a/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40evf/i40e_txrx.c
@@ -1559,8 +1559,7 @@ static int i40e_tso(struct sk_buff *skb, u8 *hdr_len, u64 *cd_type_cmd_tso_mss)
 
 	if (skb_shinfo(skb)->gso_type & (SKB_GSO_GRE |
 					 SKB_GSO_GRE_CSUM |
-					 SKB_GSO_IPIP |
-					 SKB_GSO_SIT |
+					 SKB_GSO_IPXIP4 |
 					 SKB_GSO_UDP_TUNNEL |
 					 SKB_GSO_UDP_TUNNEL_CSUM)) {
 		if (!(skb_shinfo(skb)->gso_type & SKB_GSO_PARTIAL) &&
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 642bb45..02d0a1c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2230,8 +2230,7 @@ int i40evf_process_config(struct i40evf_adapter *adapter)
 				   NETIF_F_TSO6			|
 				   NETIF_F_GSO_GRE		|
 				   NETIF_F_GSO_GRE_CSUM		|
-				   NETIF_F_GSO_IPIP		|
-				   NETIF_F_GSO_SIT		|
+				   NETIF_F_GSO_IPXIP4		|
 				   NETIF_F_GSO_UDP_TUNNEL	|
 				   NETIF_F_GSO_UDP_TUNNEL_CSUM	|
 				   NETIF_F_GSO_PARTIAL		|
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 2172769..808d48f 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2418,8 +2418,7 @@ static int igb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 #define IGB_GSO_PARTIAL_FEATURES (NETIF_F_GSO_GRE | \
 				  NETIF_F_GSO_GRE_CSUM | \
-				  NETIF_F_GSO_IPIP | \
-				  NETIF_F_GSO_SIT | \
+				  SKB_GSO_IPXIP4 | \
 				  NETIF_F_GSO_UDP_TUNNEL | \
 				  NETIF_F_GSO_UDP_TUNNEL_CSUM)
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index d08fbcf..28e3b5a 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9482,8 +9482,7 @@ skip_sriov:
 
 #define IXGBE_GSO_PARTIAL_FEATURES (NETIF_F_GSO_GRE | \
 				    NETIF_F_GSO_GRE_CSUM | \
-				    NETIF_F_GSO_IPIP | \
-				    NETIF_F_GSO_SIT | \
+				    NETIF_F_GSO_IPXIP4 | \
 				    NETIF_F_GSO_UDP_TUNNEL | \
 				    NETIF_F_GSO_UDP_TUNNEL_CSUM)
 
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 5e348b1..d86e511 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -4062,8 +4062,7 @@ static int ixgbevf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 #define IXGBEVF_GSO_PARTIAL_FEATURES (NETIF_F_GSO_GRE | \
 				      NETIF_F_GSO_GRE_CSUM | \
-				      NETIF_F_GSO_IPIP | \
-				      NETIF_F_GSO_SIT | \
+				      NETIF_F_GSO_IPXIP4 | \
 				      NETIF_F_GSO_UDP_TUNNEL | \
 				      NETIF_F_GSO_UDP_TUNNEL_CSUM)
 
diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index bc87362..aa7b240 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -44,8 +44,8 @@ enum {
 	NETIF_F_FSO_BIT,		/* ... FCoE segmentation */
 	NETIF_F_GSO_GRE_BIT,		/* ... GRE with TSO */
 	NETIF_F_GSO_GRE_CSUM_BIT,	/* ... GRE with csum with TSO */
-	NETIF_F_GSO_IPIP_BIT,		/* ... IPIP tunnel with TSO */
-	NETIF_F_GSO_SIT_BIT,		/* ... SIT tunnel with TSO */
+	NETIF_F_GSO_IPXIP4_BIT,		/* ... IP4 or IP6 over IP4 with TSO */
+	NETIF_F_GSO_IPXIP6_BIT,		/* ... IP4 or IP6 over IP6 with TSO */
 	NETIF_F_GSO_UDP_TUNNEL_BIT,	/* ... UDP TUNNEL with TSO */
 	NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT,/* ... UDP TUNNEL with TSO & CSUM */
 	NETIF_F_GSO_PARTIAL_BIT,	/* ... Only segment inner-most L4
@@ -121,8 +121,8 @@ enum {
 #define NETIF_F_RXALL		__NETIF_F(RXALL)
 #define NETIF_F_GSO_GRE		__NETIF_F(GSO_GRE)
 #define NETIF_F_GSO_GRE_CSUM	__NETIF_F(GSO_GRE_CSUM)
-#define NETIF_F_GSO_IPIP	__NETIF_F(GSO_IPIP)
-#define NETIF_F_GSO_SIT		__NETIF_F(GSO_SIT)
+#define NETIF_F_GSO_IPXIP4	__NETIF_F(GSO_IPXIP4)
+#define NETIF_F_GSO_IPXIP6	__NETIF_F(GSO_IPXIP6)
 #define NETIF_F_GSO_UDP_TUNNEL	__NETIF_F(GSO_UDP_TUNNEL)
 #define NETIF_F_GSO_UDP_TUNNEL_CSUM __NETIF_F(GSO_UDP_TUNNEL_CSUM)
 #define NETIF_F_TSO_MANGLEID	__NETIF_F(TSO_MANGLEID)
@@ -200,8 +200,8 @@ enum {
 
 #define NETIF_F_GSO_ENCAP_ALL	(NETIF_F_GSO_GRE |			\
 				 NETIF_F_GSO_GRE_CSUM |			\
-				 NETIF_F_GSO_IPIP |			\
-				 NETIF_F_GSO_SIT |			\
+				 NETIF_F_GSO_IPXIP4 |			\
+				 NETIF_F_GSO_IPXIP6 |			\
 				 NETIF_F_GSO_UDP_TUNNEL |		\
 				 NETIF_F_GSO_UDP_TUNNEL_CSUM)
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c2f5112..b36c3cc 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -4007,8 +4007,8 @@ static inline bool net_gso_ok(netdev_features_t features, int gso_type)
 	BUILD_BUG_ON(SKB_GSO_FCOE    != (NETIF_F_FSO >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_GRE     != (NETIF_F_GSO_GRE >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_GRE_CSUM != (NETIF_F_GSO_GRE_CSUM >> NETIF_F_GSO_SHIFT));
-	BUILD_BUG_ON(SKB_GSO_IPIP    != (NETIF_F_GSO_IPIP >> NETIF_F_GSO_SHIFT));
-	BUILD_BUG_ON(SKB_GSO_SIT     != (NETIF_F_GSO_SIT >> NETIF_F_GSO_SHIFT));
+	BUILD_BUG_ON(SKB_GSO_IPXIP4  != (NETIF_F_GSO_IPXIP4 >> NETIF_F_GSO_SHIFT));
+	BUILD_BUG_ON(SKB_GSO_IPXIP6  != (NETIF_F_GSO_IPXIP6 >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL != (NETIF_F_GSO_UDP_TUNNEL >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_UDP_TUNNEL_CSUM != (NETIF_F_GSO_UDP_TUNNEL_CSUM >> NETIF_F_GSO_SHIFT));
 	BUILD_BUG_ON(SKB_GSO_PARTIAL != (NETIF_F_GSO_PARTIAL >> NETIF_F_GSO_SHIFT));
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c413c58..65968a9 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -471,9 +471,9 @@ enum {
 
 	SKB_GSO_GRE_CSUM = 1 << 8,
 
-	SKB_GSO_IPIP = 1 << 9,
+	SKB_GSO_IPXIP4 = 1 << 9,
 
-	SKB_GSO_SIT = 1 << 10,
+	SKB_GSO_IPXIP6 = 1 << 10,
 
 	SKB_GSO_UDP_TUNNEL = 1 << 11,
 
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index bdb4013..f403481 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -84,8 +84,8 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_FSO_BIT] =              "tx-fcoe-segmentation",
 	[NETIF_F_GSO_GRE_BIT] =		 "tx-gre-segmentation",
 	[NETIF_F_GSO_GRE_CSUM_BIT] =	 "tx-gre-csum-segmentation",
-	[NETIF_F_GSO_IPIP_BIT] =	 "tx-ipip-segmentation",
-	[NETIF_F_GSO_SIT_BIT] =		 "tx-sit-segmentation",
+	[NETIF_F_GSO_IPXIP4_BIT] =	 "tx-ipxip4-segmentation",
+	[NETIF_F_GSO_IPXIP6_BIT] =	 "tx-ipxip6-segmentation",
 	[NETIF_F_GSO_UDP_TUNNEL_BIT] =	 "tx-udp_tnl-segmentation",
 	[NETIF_F_GSO_UDP_TUNNEL_CSUM_BIT] = "tx-udp_tnl-csum-segmentation",
 	[NETIF_F_GSO_PARTIAL_BIT] =	 "tx-gso-partial",
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 7f08d45..25040b1 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1483,7 +1483,7 @@ out_unlock:
 static int ipip_gro_complete(struct sk_buff *skb, int nhoff)
 {
 	skb->encapsulation = 1;
-	skb_shinfo(skb)->gso_type |= SKB_GSO_IPIP;
+	skb_shinfo(skb)->gso_type |= SKB_GSO_IPXIP4;
 	return inet_gro_complete(skb, nhoff);
 }
 
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 9282748..9783701 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -219,7 +219,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (unlikely(skb->protocol != htons(ETH_P_IP)))
 		goto tx_error;
 
-	if (iptunnel_handle_offloads(skb, SKB_GSO_IPIP))
+	if (iptunnel_handle_offloads(skb, SKB_GSO_IPXIP4))
 		goto tx_error;
 
 	skb_set_inner_ipproto(skb, IPPROTO_IPIP);
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 9ad743b..787e55f 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -86,7 +86,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 	proto = ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr);
 
 	if (skb->encapsulation &&
-	    skb_shinfo(skb)->gso_type & (SKB_GSO_SIT|SKB_GSO_IPIP))
+	    skb_shinfo(skb)->gso_type & (SKB_GSO_IPXIP4 | SKB_GSO_IPXIP6))
 		udpfrag = proto == IPPROTO_UDP && encap;
 	else
 		udpfrag = proto == IPPROTO_UDP && !skb->encapsulation;
@@ -294,7 +294,7 @@ out_unlock:
 static int sit_gro_complete(struct sk_buff *skb, int nhoff)
 {
 	skb->encapsulation = 1;
-	skb_shinfo(skb)->gso_type |= SKB_GSO_SIT;
+	skb_shinfo(skb)->gso_type |= SKB_GSO_IPXIP4;
 	return ipv6_gro_complete(skb, nhoff);
 }
 
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index a13d8c1..0a5a255 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -913,7 +913,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		goto tx_error;
 	}
 
-	if (iptunnel_handle_offloads(skb, SKB_GSO_SIT)) {
+	if (iptunnel_handle_offloads(skb, SKB_GSO_IPXIP4)) {
 		ip_rt_put(rt);
 		goto tx_error;
 	}
@@ -1000,7 +1000,7 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	const struct iphdr  *tiph = &tunnel->parms.iph;
 
-	if (iptunnel_handle_offloads(skb, SKB_GSO_IPIP))
+	if (iptunnel_handle_offloads(skb, SKB_GSO_IPXIP4))
 		goto tx_error;
 
 	skb_set_inner_ipproto(skb, IPPROTO_IPIP);
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index 6d19d2e..01d3d89 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -932,17 +932,14 @@ error:
 
 static inline int __tun_gso_type_mask(int encaps_af, int orig_af)
 {
-	if (encaps_af == AF_INET) {
-		if (orig_af == AF_INET)
-			return SKB_GSO_IPIP;
-
-		return SKB_GSO_SIT;
+	switch (encaps_af) {
+	case AF_INET:
+		return SKB_GSO_IPXIP4;
+	case AF_INET6:
+		return SKB_GSO_IPXIP6;
+	default:
+		return 0;
 	}
-
-	/* GSO: we need to provide proper SKB_GSO_ value for IPv6:
-	 * SKB_GSO_SIT/IPV6
-	 */
-	return 0;
 }
 
 /*
-- 
2.8.0.rc2
