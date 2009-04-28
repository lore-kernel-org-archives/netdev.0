From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 6/6] ixgbe: enable hardware offload for sctp
Date: Tue, 28 Apr 2009 01:36:35 -0700
Message-ID: <20090428083634.32417.6021.stgit@localhost.localdomain>
References: <20090428083445.32417.77682.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.westchester.pa.mail.comcast.net ([76.96.62.56]:50608
	"EHLO QMTA06.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751633AbZD1Igw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 04:36:52 -0400
In-Reply-To: <20090428083445.32417.77682.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Inspired by: Vlad Yasevich <vladislav.yasevich@hp.com>

This is the code to enable ixgbe for hardware offload support
of CRC32c on both transmit and receive of SCTP traffic.

only 82599 supports this offload, not 82598.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   11 +++++++++--
 drivers/net/ixgbe/ixgbe_main.c    |    9 +++++++++
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index f0a20fa..a499b6b 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -311,10 +311,17 @@ static u32 ixgbe_get_tx_csum(struct net_device *netdev)
 
 static int ixgbe_set_tx_csum(struct net_device *netdev, u32 data)
 {
-	if (data)
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	if (data) {
 		netdev->features |= (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-	else
+		if (adapter->hw.mac.type == ixgbe_mac_82599EB)
+			netdev->features |= NETIF_F_SCTP_CSUM;
+	} else {
 		netdev->features &= ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
+		if (adapter->hw.mac.type == ixgbe_mac_82599EB)
+			netdev->features &= ~NETIF_F_SCTP_CSUM;
+	}
 
 	return 0;
 }
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 42b803d..c3dff8f 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4189,12 +4189,18 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 				if (ip_hdr(skb)->protocol == IPPROTO_TCP)
 					type_tucmd_mlhl |=
 					        IXGBE_ADVTXD_TUCMD_L4T_TCP;
+				else if (ip_hdr(skb)->protocol == IPPROTO_SCTP)
+					type_tucmd_mlhl |=
+					        IXGBE_ADVTXD_TUCMD_L4T_SCTP;
 				break;
 			case cpu_to_be16(ETH_P_IPV6):
 				/* XXX what about other V6 headers?? */
 				if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
 					type_tucmd_mlhl |=
 					        IXGBE_ADVTXD_TUCMD_L4T_TCP;
+				else if (ipv6_hdr(skb)->nexthdr == IPPROTO_SCTP)
+					type_tucmd_mlhl |=
+					        IXGBE_ADVTXD_TUCMD_L4T_SCTP;
 				break;
 			default:
 				if (unlikely(net_ratelimit())) {
@@ -4718,6 +4724,9 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	netdev->features |= NETIF_F_TSO6;
 	netdev->features |= NETIF_F_GRO;
 
+	if (adapter->hw.mac.type == ixgbe_mac_82599EB)
+		netdev->features |= NETIF_F_SCTP_CSUM;
+
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_TSO6;
 	netdev->vlan_features |= NETIF_F_IP_CSUM;

