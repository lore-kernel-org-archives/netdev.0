From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 04/10] ixgbe: Add a second feature flags variable,
	move HW RSC capability there
Date: Thu, 04 Jun 2009 19:00:47 -0700
Message-ID: <20090605020047.8468.67704.stgit@localhost.localdomain>
References: <20090605015948.8468.25862.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.emeryville.ca.mail.comcast.net ([76.96.30.32]:48364 "EHLO
	QMTA03.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752247AbZFECBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2009 22:01:02 -0400
In-Reply-To: <20090605015948.8468.25862.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

This adds a second feature flag variable to use for future feature
expansion.  Add HW RSC to this new feature flags variable.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h         |    5 +++--
 drivers/net/ixgbe/ixgbe_ethtool.c |    6 +++---
 drivers/net/ixgbe/ixgbe_main.c    |   12 ++++++------
 3 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 00c303a..59167d7 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -317,10 +317,11 @@ struct ixgbe_adapter {
 #define IXGBE_FLAG_IN_WATCHDOG_TASK             (u32)(1 << 23)
 #define IXGBE_FLAG_IN_SFP_LINK_TASK             (u32)(1 << 24)
 #define IXGBE_FLAG_IN_SFP_MOD_TASK              (u32)(1 << 25)
-#define IXGBE_FLAG_RSC_CAPABLE                  (u32)(1 << 26)
-#define IXGBE_FLAG_RSC_ENABLED                  (u32)(1 << 27)
 #define IXGBE_FLAG_FCOE_ENABLED                 (u32)(1 << 29)
 
+	u32 flags2;
+#define IXGBE_FLAG2_RSC_CAPABLE                 (u32)(1)
+#define IXGBE_FLAG2_RSC_ENABLED                 (u32)(1 << 1)
 /* default to trying for four seconds */
 #define IXGBE_TRY_LINK_TIMEOUT (4 * HZ)
 
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 003b6e5..ce9cf7e 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1997,13 +1997,13 @@ static int ixgbe_set_flags(struct net_device *netdev, u32 data)
 
 	ethtool_op_set_flags(netdev, data);
 
-	if (!(adapter->flags & IXGBE_FLAG_RSC_CAPABLE))
+	if (!(adapter->flags & IXGBE_FLAG2_RSC_CAPABLE))
 		return 0;
 
 	/* if state changes we need to update adapter->flags and reset */
 	if ((!!(data & ETH_FLAG_LRO)) != 
-	    (!!(adapter->flags & IXGBE_FLAG_RSC_ENABLED))) {
-		adapter->flags ^= IXGBE_FLAG_RSC_ENABLED;
+	    (!!(adapter->flags & IXGBE_FLAG2_RSC_ENABLED))) {
+		adapter->flags ^= IXGBE_FLAG2_RSC_ENABLED;
 		if (netif_running(netdev))
 			ixgbe_reinit_locked(adapter);
 		else
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index f81fff5..2553173 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -748,7 +748,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		prefetch(next_rxd);
 		cleaned_count++;
 
-		if (adapter->flags & IXGBE_FLAG_RSC_CAPABLE)
+		if (adapter->flags & IXGBE_FLAG2_RSC_CAPABLE)
 			rsc_count = ixgbe_get_rsc_count(rx_desc);
 
 		if (rsc_count) {
@@ -1968,7 +1968,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 			IXGBE_WRITE_REG(hw, IXGBE_PSRTYPE(0), psrtype);
 		}
 	} else {
-		if (!(adapter->flags & IXGBE_FLAG_RSC_ENABLED) &&
+		if (!(adapter->flags & IXGBE_FLAG2_RSC_ENABLED) &&
 		    (netdev->mtu <= ETH_DATA_LEN))
 			rx_buf_len = MAXIMUM_ETHERNET_VLAN_SIZE;
 		else
@@ -2097,7 +2097,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_RDRXCTL, rdrxctl);
 	}
 
-	if (adapter->flags & IXGBE_FLAG_RSC_ENABLED) {
+	if (adapter->flags & IXGBE_FLAG2_RSC_ENABLED) {
 		/* Enable 82599 HW-RSC */
 		for (i = 0; i < adapter->num_rx_queues; i++) {
 			j = adapter->rx_ring[i].reg_idx;
@@ -3632,8 +3632,8 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82598;
 	} else if (hw->mac.type == ixgbe_mac_82599EB) {
 		adapter->max_msix_q_vectors = MAX_MSIX_Q_VECTORS_82599;
-		adapter->flags |= IXGBE_FLAG_RSC_CAPABLE;
-		adapter->flags |= IXGBE_FLAG_RSC_ENABLED;
+		adapter->flags |= IXGBE_FLAG2_RSC_CAPABLE;
+		adapter->flags |= IXGBE_FLAG2_RSC_ENABLED;
 #ifdef IXGBE_FCOE
 		adapter->flags |= IXGBE_FLAG_FCOE_ENABLED;
 		adapter->ring_feature[RING_F_FCOE].indices = IXGBE_FCRETA_SIZE;
@@ -5323,7 +5323,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
-	if (adapter->flags & IXGBE_FLAG_RSC_ENABLED)
+	if (adapter->flags & IXGBE_FLAG2_RSC_ENABLED)
 		netdev->features |= NETIF_F_LRO;
 
 	/* make sure the EEPROM is good */

