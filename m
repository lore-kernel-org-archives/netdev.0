From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/17] fm10k: introduce ITR_IS_ADAPTIVE macro
Date: Thu,  3 Dec 2015 16:29:49 -0800
Message-ID: <1449188994-64940-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:22000 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754344AbbLDA36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 19:29:58 -0500
In-Reply-To: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Define a macro for identifying when the itr value is dynamic or
adaptive. The concept was taken from i40e. This helps make clear what
the check is, and reduces the line length to something more reasonable
in a few places.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Reviewed-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h         | 2 ++
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 6 ++----
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    | 2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index b178905..cea0d94 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -172,6 +172,8 @@ struct fm10k_ring_container {
 #define FM10K_ITR_20K		50	/* 50us */
 #define FM10K_ITR_ADAPTIVE	0x8000	/* adaptive interrupt moderation flag */
 
+#define ITR_IS_ADAPTIVE(itr) (!!(itr & FM10K_ITR_ADAPTIVE))
+
 #define FM10K_ITR_ENABLE	(FM10K_ITR_AUTOMASK | FM10K_ITR_MASK_CLEAR)
 
 static inline struct netdev_queue *txring_txq(const struct fm10k_ring *ring)
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index fd29145..a505a50 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -701,12 +701,10 @@ static int fm10k_get_coalesce(struct net_device *dev,
 {
 	struct fm10k_intfc *interface = netdev_priv(dev);
 
-	ec->use_adaptive_tx_coalesce =
-		!!(interface->tx_itr & FM10K_ITR_ADAPTIVE);
+	ec->use_adaptive_tx_coalesce = ITR_IS_ADAPTIVE(interface->tx_itr);
 	ec->tx_coalesce_usecs = interface->tx_itr & ~FM10K_ITR_ADAPTIVE;
 
-	ec->use_adaptive_rx_coalesce =
-		!!(interface->rx_itr & FM10K_ITR_ADAPTIVE);
+	ec->use_adaptive_rx_coalesce = ITR_IS_ADAPTIVE(interface->rx_itr);
 	ec->rx_coalesce_usecs = interface->rx_itr & ~FM10K_ITR_ADAPTIVE;
 
 	return 0;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index c5f7e0d..8207ee1 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1370,7 +1370,7 @@ static void fm10k_update_itr(struct fm10k_ring_container *ring_container)
 	unsigned int avg_wire_size, packets;
 
 	/* Only update ITR if we are using adaptive setting */
-	if (!(ring_container->itr & FM10K_ITR_ADAPTIVE))
+	if (!ITR_IS_ADAPTIVE(ring_container->itr))
 		goto clear_counts;
 
 	packets = ring_container->total_packets;
-- 
2.5.0
