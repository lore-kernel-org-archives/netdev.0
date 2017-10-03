From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/9] fm10k: use spinlock to implement mailbox lock
Date: Tue,  3 Oct 2017 09:31:31 -0700
Message-ID: <20171003163138.47569-3-jeffrey.t.kirsher@intel.com>
References: <20171003163138.47569-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:17001 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750820AbdJCQb6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Oct 2017 12:31:58 -0400
In-Reply-To: <20171003163138.47569-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Lets not re-invent the locking wheel. Remove our bitlock and use
a proper spinlock instead.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h     | 15 +++++----------
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c |  3 +++
 2 files changed, 8 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index ba70c58ca920..74542e9d63c7 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -276,7 +276,6 @@ enum fm10k_state_t {
 	__FM10K_SERVICE_SCHED,
 	__FM10K_SERVICE_REQUEST,
 	__FM10K_SERVICE_DISABLE,
-	__FM10K_MBX_LOCK,
 	__FM10K_LINK_DOWN,
 	__FM10K_UPDATING_STATS,
 	/* This value must be last and determines the BITMAP size */
@@ -346,6 +345,8 @@ struct fm10k_intfc {
 
 	struct fm10k_hw_stats stats;
 	struct fm10k_hw hw;
+	/* Mailbox lock */
+	spinlock_t mbx_lock;
 	u32 __iomem *uc_addr;
 	u32 __iomem *sw_addr;
 	u16 msg_enable;
@@ -386,23 +387,17 @@ struct fm10k_intfc {
 
 static inline void fm10k_mbx_lock(struct fm10k_intfc *interface)
 {
-	/* busy loop if we cannot obtain the lock as some calls
-	 * such as ndo_set_rx_mode may be made in atomic context
-	 */
-	while (test_and_set_bit(__FM10K_MBX_LOCK, interface->state))
-		udelay(20);
+	spin_lock(&interface->mbx_lock);
 }
 
 static inline void fm10k_mbx_unlock(struct fm10k_intfc *interface)
 {
-	/* flush memory to make sure state is correct */
-	smp_mb__before_atomic();
-	clear_bit(__FM10K_MBX_LOCK, interface->state);
+	spin_unlock(&interface->mbx_lock);
 }
 
 static inline int fm10k_mbx_trylock(struct fm10k_intfc *interface)
 {
-	return !test_and_set_bit(__FM10K_MBX_LOCK, interface->state);
+	return spin_trylock(&interface->mbx_lock);
 }
 
 /* fm10k_test_staterr - test bits in Rx descriptor status and error fields */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 4e5e3e64beda..240772ad5d69 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1921,6 +1921,9 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 	netdev_rss_key_fill(rss_key, sizeof(rss_key));
 	memcpy(interface->rssrk, rss_key, sizeof(rss_key));
 
+	/* Initialize the mailbox lock */
+	spin_lock_init(&interface->mbx_lock);
+
 	/* Start off interface as being down */
 	set_bit(__FM10K_DOWN, interface->state);
 	set_bit(__FM10K_UPDATING_STATS, interface->state);
-- 
2.14.2
