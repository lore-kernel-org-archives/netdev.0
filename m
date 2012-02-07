From: greearb@candelatech.com
Subject: [PATCH 5/5] e1000e:  Support RXFCS feature flag.
Date: Tue,  7 Feb 2012 11:51:21 -0800
Message-ID: <1328644281-7914-2-git-send-email-greearb@candelatech.com>
References: <1328644281-7914-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35691 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756574Ab2BGTvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 14:51:35 -0500
In-Reply-To: <1328644281-7914-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This enables enabling/disabling reception of the Ethernet
FCS.  This can be useful when sniffing packets.

For e1000e, enabling RXFCS can change the default
behaviour for how the NIC handles CRC.  Disabling RXFCS
will take the NIC back to defaults, which can be configured
as part of the module options.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 45e5ae8... 04a21fc... M	drivers/net/ethernet/intel/e1000e/e1000.h
:100644 100644 0c94e55... 22bafbd... M	drivers/net/ethernet/intel/e1000e/netdev.c
:100644 100644 9c6a56d... ff796e4... M	drivers/net/ethernet/intel/e1000e/param.c
 drivers/net/ethernet/intel/e1000e/e1000.h  |    1 +
 drivers/net/ethernet/intel/e1000e/netdev.c |   41 +++++++++++++++++++++++-----
 drivers/net/ethernet/intel/e1000e/param.c  |    5 +++-
 3 files changed, 39 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 45e5ae8..04a21fc 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -461,6 +461,7 @@ struct e1000_info {
 #define FLAG2_CHECK_PHY_HANG              (1 << 9)
 #define FLAG2_NO_DISABLE_RX               (1 << 10)
 #define FLAG2_PCIM2PCI_ARBITER_WA         (1 << 11)
+#define FLAG2_DFLT_CRC_STRIPPING          (1 << 12)
 
 #define E1000_RX_DESC_PS(R, i)	    \
 	(&(((union e1000_rx_desc_packet_split *)((R).desc))[i]))
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 0c94e55..22bafbd 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -936,8 +936,16 @@ static bool e1000_clean_rx_irq(struct e1000_ring *rx_ring, int *work_done,
 		}
 
 		/* adjust length to remove Ethernet CRC */
-		if (!(adapter->flags2 & FLAG2_CRC_STRIPPING))
-			length -= 4;
+		if (!(adapter->flags2 & FLAG2_CRC_STRIPPING)) {
+			/* If configured to store CRC, don't subtract FCS,
+			 * but keep the FCS bytes out of the total_rx_bytes
+			 * counter
+			 */
+			if (netdev->features & NETIF_F_RXFCS)
+				total_rx_bytes -= 4;
+			else
+				length -= 4;
+		}
 
 		total_rx_bytes += length;
 		total_rx_packets++;
@@ -1298,8 +1306,10 @@ static bool e1000_clean_rx_irq_ps(struct e1000_ring *rx_ring, int *work_done,
 						   PAGE_SIZE, DMA_FROM_DEVICE);
 
 			/* remove the CRC */
-			if (!(adapter->flags2 & FLAG2_CRC_STRIPPING))
-				l1 -= 4;
+			if (!(adapter->flags2 & FLAG2_CRC_STRIPPING)) {
+				if (!(netdev->features & NETIF_F_RXFCS))
+					l1 -= 4;
+			}
 
 			skb_put(skb, l1);
 			goto copydone;
@@ -1325,8 +1335,10 @@ static bool e1000_clean_rx_irq_ps(struct e1000_ring *rx_ring, int *work_done,
 		/* strip the ethernet crc, problem is we're using pages now so
 		 * this whole operation can get a little cpu intensive
 		 */
-		if (!(adapter->flags2 & FLAG2_CRC_STRIPPING))
-			pskb_trim(skb, skb->len - 4);
+		if (!(adapter->flags2 & FLAG2_CRC_STRIPPING)) {
+			if (!(netdev->features & NETIF_F_RXFCS))
+				pskb_trim(skb, skb->len - 4);
+		}
 
 copydone:
 		total_rx_bytes += skb->len;
@@ -5990,7 +6002,7 @@ static int e1000_set_features(struct net_device *netdev,
 		adapter->flags |= FLAG_TSO_FORCE;
 
 	if (!(changed & (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX |
-			 NETIF_F_RXCSUM | NETIF_F_RXHASH)))
+			 NETIF_F_RXCSUM | NETIF_F_RXHASH | NETIF_F_RXFCS)))
 		return 0;
 
 	/*
@@ -6004,6 +6016,20 @@ static int e1000_set_features(struct net_device *netdev,
 		return -EINVAL;
 	}
 
+	if (changed & NETIF_F_RXFCS) {
+		if (features & NETIF_F_RXFCS) {
+			adapter->flags2 &= ~FLAG2_CRC_STRIPPING;
+		} else {
+			/* We need to take it back to defaults, which might mean
+			 * stripping is still disabled at the adapter level.
+			 */
+			if (adapter->flags2 & FLAG2_DFLT_CRC_STRIPPING)
+				adapter->flags2 |= FLAG2_CRC_STRIPPING;
+			else
+				adapter->flags2 &= ~FLAG2_CRC_STRIPPING;
+		}
+	}
+
 	netdev->features = features;
 
 	if (netif_running(netdev))
@@ -6203,6 +6229,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	/* Set user-changeable features (subset of all device features) */
 	netdev->hw_features = netdev->features;
+	netdev->hw_features |= NETIF_F_RXFCS;
 
 	if (adapter->flags & FLAG_HAS_HW_VLAN_FILTER)
 		netdev->features |= NETIF_F_HW_VLAN_FILTER;
diff --git a/drivers/net/ethernet/intel/e1000e/param.c b/drivers/net/ethernet/intel/e1000e/param.c
index 9c6a56d..ff796e4 100644
--- a/drivers/net/ethernet/intel/e1000e/param.c
+++ b/drivers/net/ethernet/intel/e1000e/param.c
@@ -463,10 +463,13 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 		if (num_CrcStripping > bd) {
 			unsigned int crc_stripping = CrcStripping[bd];
 			e1000_validate_option(&crc_stripping, &opt, adapter);
-			if (crc_stripping == OPTION_ENABLED)
+			if (crc_stripping == OPTION_ENABLED) {
 				adapter->flags2 |= FLAG2_CRC_STRIPPING;
+				adapter->flags2 |= FLAG2_DFLT_CRC_STRIPPING;
+			}
 		} else {
 			adapter->flags2 |= FLAG2_CRC_STRIPPING;
+			adapter->flags2 |= FLAG2_DFLT_CRC_STRIPPING;
 		}
 	}
 	{ /* Kumeran Lock Loss Workaround */
-- 
1.7.3.4
