From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/16] igbvf: cleanup msleep() and min/max() usage
Date: Sun, 22 Feb 2015 19:25:31 -0800
Message-ID: <1424661944-1779-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1424661944-1779-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:3457 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752152AbbBWDZw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Feb 2015 22:25:52 -0500
In-Reply-To: <1424661944-1779-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed a few cases of when we used msleep() when we should have been
using usleep_range().  Also updated the usage of min/max() to use
min_t/max_t().

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/igbvf/ethtool.c | 10 +++++-----
 drivers/net/ethernet/intel/igbvf/netdev.c  |  2 +-
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/ethtool.c b/drivers/net/ethernet/intel/igbvf/ethtool.c
index 91a1190..c6996fe 100644
--- a/drivers/net/ethernet/intel/igbvf/ethtool.c
+++ b/drivers/net/ethernet/intel/igbvf/ethtool.c
@@ -224,12 +224,12 @@ static int igbvf_set_ringparam(struct net_device *netdev,
 	if ((ring->rx_mini_pending) || (ring->rx_jumbo_pending))
 		return -EINVAL;
 
-	new_rx_count = max(ring->rx_pending, (u32)IGBVF_MIN_RXD);
-	new_rx_count = min(new_rx_count, (u32)IGBVF_MAX_RXD);
+	new_rx_count = max_t(u32, ring->rx_pending, IGBVF_MIN_RXD);
+	new_rx_count = min_t(u32, new_rx_count, IGBVF_MAX_RXD);
 	new_rx_count = ALIGN(new_rx_count, REQ_RX_DESCRIPTOR_MULTIPLE);
 
-	new_tx_count = max(ring->tx_pending, (u32)IGBVF_MIN_TXD);
-	new_tx_count = min(new_tx_count, (u32)IGBVF_MAX_TXD);
+	new_tx_count = max_t(u32, ring->tx_pending, IGBVF_MIN_TXD);
+	new_tx_count = min_t(u32, new_tx_count, IGBVF_MAX_TXD);
 	new_tx_count = ALIGN(new_tx_count, REQ_TX_DESCRIPTOR_MULTIPLE);
 
 	if ((new_tx_count == adapter->tx_ring->count) &&
@@ -239,7 +239,7 @@ static int igbvf_set_ringparam(struct net_device *netdev,
 	}
 
 	while (test_and_set_bit(__IGBVF_RESETTING, &adapter->state))
-		msleep(1);
+		usleep_range(1000, 2000);
 
 	if (!netif_running(adapter->netdev)) {
 		adapter->tx_ring->count = new_tx_count;
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 55f1404..c17ea4b 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1552,7 +1552,7 @@ void igbvf_reinit_locked(struct igbvf_adapter *adapter)
 {
 	might_sleep();
 	while (test_and_set_bit(__IGBVF_RESETTING, &adapter->state))
-		msleep(1);
+		usleep_range(1000, 2000);
 	igbvf_down(adapter);
 	igbvf_up(adapter);
 	clear_bit(__IGBVF_RESETTING, &adapter->state);
-- 
1.9.3
