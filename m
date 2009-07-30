From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/3] ixgbe: Fix usage of second flags bitmap when
	using LRO/RSC
Date: Thu, 30 Jul 2009 15:25:28 -0700
Message-ID: <20090730222528.26121.30521.stgit@localhost.localdomain>
References: <20090730222501.26121.2952.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:60345 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752525AbZG3WZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 18:25:58 -0400
In-Reply-To: <20090730222501.26121.2952.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

A second set of feature flag bits was added, and the hardware RSC engine
flags were moved there.  However, the code itself didn't make the move
completely to use the new bitmap.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Acked-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |    6 +++---
 drivers/net/ixgbe/ixgbe_main.c    |   12 ++++++------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 2a97800..7ddb50c 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1999,13 +1999,13 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 
 	ethtool_op_set_flags(netdev, data);
 
-	if (!(adapter->flags & IXGBE_FLAG2_RSC_CAPABLE))
+	if (!(adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE))
 		return 0;
 
 	/* if state changes we need to update adapter->flags and reset */
 	if ((!!(data & ETH_FLAG_LRO)) != 
-	    (!!(adapter->flags & IXGBE_FLAG2_RSC_ENABLED))) {
-		adapter->flags ^= IXGBE_FLAG2_RSC_ENABLED;
+	    (!!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED))) {
+		adapter->flags2 ^= IXGBE_FLAG2_RSC_ENABLED;
 		if (netif_running(netdev))
 			ixgbe_reinit_locked(adapter);
 		else
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 60c4a8b..110c65a 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -780,7 +780,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		prefetch(next_rxd);
 		cleaned_count++;
 
-		if (adapter->flags & IXGBE_FLAG2_RSC_CAPABLE)
+		if (adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE)
 			rsc_count = ixgbe_get_rsc_count(rx_desc);
 
 		if (rsc_count) {
@@ -2036,7 +2036,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 			IXGBE_WRITE_REG(hw, IXGBE_PSRTYPE(0), psrtype);
 		}
 	} else {
-		if (!(adapter->flags & IXGBE_FLAG2_RSC_ENABLED) &&
+		if (!(adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) &&
 		    (netdev->mtu <= ETH_DATA_LEN))
 			rx_buf_len = MAXIMUM_ETHERNET_VLAN_SIZE;
 		else
@@ -2165,7 +2165,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_RDRXCTL, rdrxctl);
 	}
 
-	if (adapter->flags & IXGBE_FLAG2_RSC_ENABLED) {
+	if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
 		/* Enable 82599 HW-RSC */
 		for (i = 0; i < adapter->num_rx_queues; i++) {
 			j = adapter->rx_ring[i].reg_idx;
@@ -3812,8 +3812,8 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82598;
 	} else if (hw->mac.type == ixgbe_mac_82599EB) {
 		adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82599;
-		adapter->flags |= IXGBE_FLAG2_RSC_CAPABLE;
-		adapter->flags |= IXGBE_FLAG2_RSC_ENABLED;
+		adapter->flags2 |= IXGBE_FLAG2_RSC_CAPABLE;
+		adapter->flags2 |= IXGBE_FLAG2_RSC_ENABLED;
 		adapter->flags |= IXGBE_FLAG_FDIR_HASH_CAPABLE;
 		adapter->ring_feature[RING_F_FDIR].indices =
 		                                         IXGBE_MAX_FDIR_INDICES;
@@ -5618,7 +5618,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
-	if (adapter->flags & IXGBE_FLAG2_RSC_ENABLED)
+	if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
 		netdev->features |= NETIF_F_LRO;
 
 	/* make sure the EEPROM is good */

