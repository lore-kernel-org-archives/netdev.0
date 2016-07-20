From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/20] fm10k: prevent multiple threads updating statistics
Date: Wed, 20 Jul 2016 15:23:41 -0700
Message-ID: <1469053438-85381-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	guru.anbalagane@oracle.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4181 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755241AbcGTWYB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2016 18:24:01 -0400
In-Reply-To: <1469053438-85381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Also prevent updating stats while the interface is down. If we're
already updating stats, just return doing nothing. When we take the
device down, block stat updates until we come back up. This ensures that
we avoid tearing down rings when we're updating statistics, and prevents
updating statistics until we're up.

We can't re-use the __FM10K_DOWN for this because it wouldn't prevent
multiple threads from accessing statistics. Neither does it prevent the
case where we start updating stats and then start going down in another
thread.

The fm10k_get_stats64 is except from this, because it has a completely
different flow which does not suffer from the same issues as
fm10k_update_stats might.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h     |  1 +
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c | 14 ++++++++++++++
 2 files changed, 15 insertions(+)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index e98b86b..c8d0817 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -362,6 +362,7 @@ enum fm10k_state_t {
 	__FM10K_SERVICE_DISABLE,
 	__FM10K_MBX_LOCK,
 	__FM10K_LINK_DOWN,
+	__FM10K_UPDATING_STATS,
 };
 
 static inline void fm10k_mbx_lock(struct fm10k_intfc *interface)
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index be0b7de..4439376 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -372,6 +372,10 @@ void fm10k_update_stats(struct fm10k_intfc *interface)
 	u64 bytes, pkts;
 	int i;
 
+	/* ensure only one thread updates stats at a time */
+	if (test_and_set_bit(__FM10K_UPDATING_STATS, &interface->state))
+		return;
+
 	/* do not allow stats update via service task for next second */
 	interface->next_stats_update = jiffies + HZ;
 
@@ -449,6 +453,8 @@ void fm10k_update_stats(struct fm10k_intfc *interface)
 	/* Fill out the OS statistics structure */
 	net_stats->rx_errors = rx_errors;
 	net_stats->rx_dropped = interface->stats.nodesc_drop.count;
+
+	clear_bit(__FM10K_UPDATING_STATS, &interface->state);
 }
 
 /**
@@ -1572,6 +1578,9 @@ void fm10k_up(struct fm10k_intfc *interface)
 	/* configure interrupts */
 	hw->mac.ops.update_int_moderator(hw);
 
+	/* enable statistics capture again */
+	clear_bit(__FM10K_UPDATING_STATS, &interface->state);
+
 	/* clear down bit to indicate we are ready to go */
 	clear_bit(__FM10K_DOWN, &interface->state);
 
@@ -1629,6 +1638,10 @@ void fm10k_down(struct fm10k_intfc *interface)
 	/* capture stats one last time before stopping interface */
 	fm10k_update_stats(interface);
 
+	/* prevent updating statistics while we're down */
+	while (test_and_set_bit(__FM10K_UPDATING_STATS, &interface->state))
+		usleep_range(1000, 2000);
+
 	/* Disable DMA engine for Tx/Rx */
 	err = hw->mac.ops.stop_hw(hw);
 	if (err)
@@ -1757,6 +1770,7 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 
 	/* Start off interface as being down */
 	set_bit(__FM10K_DOWN, &interface->state);
+	set_bit(__FM10K_UPDATING_STATS, &interface->state);
 
 	return 0;
 }
-- 
2.5.5
