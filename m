From: Andy Zhou <azhou@nicira.com>
Subject: [net-next 1/5] net: Add rx-vxlan feature bit
Date: Fri,  1 Aug 2014 14:54:41 -0700
Message-ID: <1406930085-26445-2-git-send-email-azhou@nicira.com>
References: <1406930085-26445-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:59029 "HELO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756367AbaHAV7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 17:59:44 -0400
Received: by mail-pa0-f48.google.com with SMTP id et14so6508922pad.35
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2014 14:59:38 -0700 (PDT)
In-Reply-To: <1406930085-26445-1-git-send-email-azhou@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a ndo feature bit that controls turning on and off NIC VXLAN
receive offload

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 Documentation/networking/netdev-features.txt     |    5 +++++
 drivers/net/ethernet/emulex/benet/be_main.c      |    6 ++++--
 drivers/net/ethernet/intel/i40e/i40e_main.c      |    1 +
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |   11 ++++++++---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    7 +++++--
 include/linux/netdev_features.h                  |    4 ++++
 net/core/ethtool.c                               |    1 +
 7 files changed, 28 insertions(+), 7 deletions(-)

diff --git a/Documentation/networking/netdev-features.txt b/Documentation/networking/netdev-features.txt
index f310ede..6436768 100644
--- a/Documentation/networking/netdev-features.txt
+++ b/Documentation/networking/netdev-features.txt
@@ -165,3 +165,8 @@ This requests that the NIC receive all possible frames, including errored
 frames (such as bad FCS, etc).  This can be helpful when sniffing a link with
 bad packets on it.  Some NICs may receive more packets if also put into normal
 PROMISC mode.
+
+*   rx-vxlan
+NIC can parse udp tunneled frames. The NIC may make use of the inner frame
+information, in addition to the outer UDP frame to verify, offload(RX)
+and steer the packet.
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 9c50814..f8cbd9a 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4418,10 +4418,12 @@ static void be_netdev_init(struct net_device *netdev)
 	struct be_adapter *adapter = netdev_priv(netdev);
 
 	if (skyhawk_chip(adapter)) {
+		netdev->hw_features |= NETIF_F_GSO_UDP_TUNNEL |
+				       NETIF_F_RX_UT_VXLAN;
+
 		netdev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 					   NETIF_F_TSO | NETIF_F_TSO6 |
-					   NETIF_F_GSO_UDP_TUNNEL;
-		netdev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
+					   netdev->hw_features;
 	}
 	netdev->hw_features |= NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6 |
 		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_RXCSUM |
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 821fcc1..a77ad6d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7205,6 +7205,7 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 			   NETIF_F_TSO6		       |
 			   NETIF_F_RXCSUM	       |
 			   NETIF_F_RXHASH	       |
+			   NETIF_F_RX_UT_VXLAN	       |
 			   0;
 
 	if (!(pf->flags & I40E_FLAG_MFP_ENABLED))
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index bb536aa..e563b55 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2596,9 +2596,14 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 
 	if (mdev->dev->caps.tunnel_offload_mode == MLX4_TUNNEL_OFFLOAD_MODE_VXLAN) {
 		dev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
-					NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL;
-		dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
-		dev->features    |= NETIF_F_GSO_UDP_TUNNEL;
+					NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL |
+					NETIF_F_RX_UT_VXLAN;
+
+		dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL |
+				    NETIF_F_RX_UT_VXLAN;
+
+		dev->features    |= NETIF_F_GSO_UDP_TUNNEL |
+				    NETIF_F_RX_UT_VXLAN;
 	}
 
 	mdev->pndev[port] = dev;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 0fdbcc8..227cfb1 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2312,8 +2312,11 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter, struct net_device *netdev,
 					  NETIF_F_TSO6;
 	}
 
-	if (qlcnic_encap_rx_offload(adapter))
-		netdev->hw_enc_features |= NETIF_F_RXCSUM;
+	if (qlcnic_encap_rx_offload(adapter)) {
+		netdev->features |= NETIF_F_RX_UT_VXLAN;
+		netdev->hw_enc_features |= NETIF_F_RXCSUM |
+					   NETIF_F_RX_UT_VXLAN;
+	}
 
 	netdev->hw_features = netdev->features;
 	netdev->priv_flags |= IFF_UNICAST_FLT;
diff --git a/include/linux/netdev_features.h b/include/linux/netdev_features.h
index dcfdecb..b7414e1 100644
--- a/include/linux/netdev_features.h
+++ b/include/linux/netdev_features.h
@@ -57,6 +57,7 @@ enum {
 	NETIF_F_NTUPLE_BIT,		/* N-tuple filters supported */
 	NETIF_F_RXHASH_BIT,		/* Receive hashing offload */
 	NETIF_F_RXCSUM_BIT,		/* Receive checksumming offload */
+	NETIF_F_RX_UT_VXLAN_BIT,	/* UDP TUNNEL VXLAN RX */
 	NETIF_F_NOCACHE_COPY_BIT,	/* Use no-cache copyfromuser */
 	NETIF_F_LOOPBACK_BIT,		/* Enable loopback */
 	NETIF_F_RXFCS_BIT,		/* Append FCS to skb pkt data */
@@ -119,6 +120,7 @@ enum {
 #define NETIF_F_GSO_UDP_TUNNEL	__NETIF_F(GSO_UDP_TUNNEL)
 #define NETIF_F_GSO_UDP_TUNNEL_CSUM __NETIF_F(GSO_UDP_TUNNEL_CSUM)
 #define NETIF_F_GSO_MPLS	__NETIF_F(GSO_MPLS)
+#define NETIF_F_RX_UT_VXLAN	__NETIF_F(RX_UT_VXLAN)
 #define NETIF_F_HW_VLAN_STAG_FILTER __NETIF_F(HW_VLAN_STAG_FILTER)
 #define NETIF_F_HW_VLAN_STAG_RX	__NETIF_F(HW_VLAN_STAG_RX)
 #define NETIF_F_HW_VLAN_STAG_TX	__NETIF_F(HW_VLAN_STAG_TX)
@@ -184,4 +186,6 @@ enum {
 				 NETIF_F_GSO_UDP_TUNNEL_CSUM |		\
 				 NETIF_F_GSO_MPLS)
 
+#define NETIF_F_RX_UT_ALL	(NETIF_F_RX_UT_VXLAN)
+
 #endif	/* _LINUX_NETDEV_FEATURES_H */
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 17cb912..2075b79 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -92,6 +92,7 @@ static const char netdev_features_strings[NETDEV_FEATURE_COUNT][ETH_GSTRING_LEN]
 	[NETIF_F_NTUPLE_BIT] =           "rx-ntuple-filter",
 	[NETIF_F_RXHASH_BIT] =           "rx-hashing",
 	[NETIF_F_RXCSUM_BIT] =           "rx-checksum",
+	[NETIF_F_RX_UT_VXLAN_BIT] =      "rx-vxlan",
 	[NETIF_F_NOCACHE_COPY_BIT] =     "tx-nocache-copy",
 	[NETIF_F_LOOPBACK_BIT] =         "loopback",
 	[NETIF_F_RXFCS_BIT] =            "rx-fcs",
-- 
1.7.9.5
