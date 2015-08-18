From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] igb: Fix oops caused by missing queue pairing
Date: Tue, 18 Aug 2015 14:09:08 -0700
Message-ID: <1439932162-1995-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shota Suzuki <suzuki_shota_t3@lab.ntt.co.jp>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, stable <stable@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5294 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753387AbbHRVJ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 17:09:26 -0400
In-Reply-To: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shota Suzuki <suzuki_shota_t3@lab.ntt.co.jp>

When initializing igb driver (e.g. 82576, I350), IGB_FLAG_QUEUE_PAIRS is
set if adapter->rss_queues exceeds half of max_rss_queues in
igb_init_queue_configuration().
On the other hand, IGB_FLAG_QUEUE_PAIRS is not set even if the number of
queues exceeds half of max_combined in igb_set_channels() when changing
the number of queues by "ethtool -L".
In this case, if numvecs is larger than MAX_MSIX_ENTRIES (10), the size
of adapter->msix_entries[], an overflow can occur in
igb_set_interrupt_capability(), which in turn leads to an oops.

Fix this problem as follows:
 - When changing the number of queues by "ethtool -L", set
   IGB_FLAG_QUEUE_PAIRS in the same way as initializing igb driver.
 - When increasing the size of q_vector, reallocate it appropriately.
   (With IGB_FLAG_QUEUE_PAIRS set, the size of q_vector gets larger.)

Another possible way to fix this problem is to cap the queues at its
initial number, which is the number of the initial online cpus. But this
is not the optimal way because we cannot increase queues when another
cpu becomes online.

Note that before commit cd14ef54d25b ("igb: Change to use statically
allocated array for MSIx entries"), this problem did not cause oops
but just made the number of queues become 1 because of entering msi_only
mode in igb_set_interrupt_capability().

Fixes: 907b7835799f ("igb: Add ethtool support to configure number of channels")
CC: stable <stable@vger.kernel.org>
Signed-off-by: Shota Suzuki <suzuki_shota_t3@lab.ntt.co.jp>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h         |  1 +
 drivers/net/ethernet/intel/igb/igb_ethtool.c |  5 ++++-
 drivers/net/ethernet/intel/igb/igb_main.c    | 16 ++++++++++++++--
 3 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index c2bd4f9..212d668 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -540,6 +540,7 @@ void igb_ptp_rx_pktstamp(struct igb_q_vector *q_vector, unsigned char *va,
 			 struct sk_buff *skb);
 int igb_ptp_set_ts_config(struct net_device *netdev, struct ifreq *ifr);
 int igb_ptp_get_ts_config(struct net_device *netdev, struct ifreq *ifr);
+void igb_set_flag_queue_pairs(struct igb_adapter *, const u32);
 #ifdef CONFIG_IGB_HWMON
 void igb_sysfs_exit(struct igb_adapter *adapter);
 int igb_sysfs_init(struct igb_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index b7b9c67..7426276 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -3008,6 +3008,7 @@ static int igb_set_channels(struct net_device *netdev,
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	unsigned int count = ch->combined_count;
+	unsigned int max_combined = 0;
 
 	/* Verify they are not requesting separate vectors */
 	if (!count || ch->rx_count || ch->tx_count)
@@ -3018,11 +3019,13 @@ static int igb_set_channels(struct net_device *netdev,
 		return -EINVAL;
 
 	/* Verify the number of channels doesn't exceed hw limits */
-	if (count > igb_max_channels(adapter))
+	max_combined = igb_max_channels(adapter);
+	if (count > max_combined)
 		return -EINVAL;
 
 	if (count != adapter->rss_queues) {
 		adapter->rss_queues = count;
+		igb_set_flag_queue_pairs(adapter, max_combined);
 
 		/* Hardware has to reinitialize queues and interrupts to
 		 * match the new configuration.
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 41e2740..7b97e847 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1205,10 +1205,14 @@ static int igb_alloc_q_vector(struct igb_adapter *adapter,
 
 	/* allocate q_vector and rings */
 	q_vector = adapter->q_vector[v_idx];
-	if (!q_vector)
+	if (!q_vector) {
 		q_vector = kzalloc(size, GFP_KERNEL);
-	else
+	} else if (size > ksize(q_vector)) {
+		kfree_rcu(q_vector, rcu);
+		q_vector = kzalloc(size, GFP_KERNEL);
+	} else {
 		memset(q_vector, 0, size);
+	}
 	if (!q_vector)
 		return -ENOMEM;
 
@@ -2888,6 +2892,14 @@ static void igb_init_queue_configuration(struct igb_adapter *adapter)
 
 	adapter->rss_queues = min_t(u32, max_rss_queues, num_online_cpus());
 
+	igb_set_flag_queue_pairs(adapter, max_rss_queues);
+}
+
+void igb_set_flag_queue_pairs(struct igb_adapter *adapter,
+			      const u32 max_rss_queues)
+{
+	struct e1000_hw *hw = &adapter->hw;
+
 	/* Determine if we need to pair queues. */
 	switch (hw->mac.type) {
 	case e1000_82575:
-- 
2.4.3
