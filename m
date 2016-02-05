From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH 2/2] fm10k: correctly report error when changing number of channels
Date: Fri,  5 Feb 2016 12:30:21 -0800
Message-ID: <1454704221-14238-3-git-send-email-jacob.e.keller@intel.com>
References: <1454704221-14238-1-git-send-email-jacob.e.keller@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:35789 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756708AbcBEUad (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2016 15:30:33 -0500
In-Reply-To: <1454704221-14238-1-git-send-email-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously, the fm10k driver would incorrectly allow changing the number
of combined channels when this would have altered user configured RSS
indirection table. With the new ethtool operation .reset_rxfh_indir, we
are now able to correctly handle the changes to number of channels. This
requires several changes:

(a) we must first store whether or not the RSS redirection table has
    been manually configured, as there is no way to tell the default
    table from an explicit request. Do this by implementing
    reset_rxfh_indir ethtool op, and storing a flag to indicate how the
    redirection table is set.

(b) replace the fm10k_init_reta code with a check of intialized
    netdevice to instead check the new FM10K_FLAG_RETA_TABLE_CONFIGURED.
    This will ensure that the table is always repopulated if we're in
    the default (unconfigured) state. We still must repopulate if
    somehow the reta table is changed to what will become an invalid
    state due to new RSS limits. However, since this should no longer
    happen, add a dev_err() call to indicate clearly to user what
    happened.

(c) modify the fm10k_set_channels call to check that th new count is
    within bounds on the reta table. This check is only enforced if the
    user has manually configured the RSS indirection table, since the
    driver should be free to repopulate its own default configuration.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h         |  2 ++
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 45 ++++++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    | 11 ++++--
 3 files changed, 55 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 83f386714e87..983bdda9509b 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -268,6 +268,7 @@ struct fm10k_intfc {
 #define FM10K_FLAG_RX_TS_ENABLED		(u32)(BIT(3))
 #define FM10K_FLAG_SWPRI_CONFIG			(u32)(BIT(4))
 #define FM10K_FLAG_DEBUG_STATS			(u32)(BIT(5))
+#define FM10K_FLAG_RETA_TABLE_CONFIGURED	(u32)(BIT(6))
 	int xcast_mode;
 
 	/* Tx fast path data */
@@ -475,6 +476,7 @@ netdev_tx_t fm10k_xmit_frame_ring(struct sk_buff *skb,
 void fm10k_tx_timeout_reset(struct fm10k_intfc *interface);
 bool fm10k_check_tx_hang(struct fm10k_ring *tx_ring);
 void fm10k_alloc_rx_buffers(struct fm10k_ring *rx_ring, u16 cleaned_count);
+void fm10k_init_reta(struct fm10k_intfc *interface);
 
 /* PCI */
 void fm10k_mbx_free_irq(struct fm10k_intfc *);
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 6a9f9886cb98..febfa2b009ea 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -1060,6 +1060,8 @@ static int fm10k_set_reta(struct net_device *netdev, const u32 *indir)
 	if (!indir)
 		return 0;
 
+	interface->flags |= FM10K_FLAG_RETA_TABLE_CONFIGURED;
+
 	/* Verify user input. */
 	rss_i = interface->ring_feature[RING_F_RSS].indices;
 	for (i = fm10k_get_reta_size(netdev); i--;) {
@@ -1137,6 +1139,25 @@ static int fm10k_set_rssh(struct net_device *netdev, const u32 *indir,
 	return 0;
 }
 
+static int fm10k_reset_rssh(struct net_device *netdev)
+{
+	struct fm10k_intfc *interface = netdev_priv(netdev);
+	struct fm10k_hw *hw = &interface->hw;
+	int i;
+
+	/* user has requested default configuration so clear configured flag */
+	interface->flags &= ~FM10K_FLAG_RETA_TABLE_CONFIGURED;
+
+	/* initialize the reta table to driver defaults */
+	fm10k_init_reta(interface);
+
+	/* write the new RETA table to hardware */
+	for (i = 0; i < FM10K_RETA_SIZE; i++)
+		fm10k_write_reg(hw, FM10K_RETA(0, i), interface->reta[i]);
+
+	return 0;
+}
+
 static unsigned int fm10k_max_channels(struct net_device *dev)
 {
 	struct fm10k_intfc *interface = netdev_priv(dev);
@@ -1173,6 +1194,8 @@ static int fm10k_set_channels(struct net_device *dev,
 	struct fm10k_intfc *interface = netdev_priv(dev);
 	unsigned int count = ch->combined_count;
 	struct fm10k_hw *hw = &interface->hw;
+	u32 reta0, reta1, reta2, reta3;
+	int i, rss_i = 0;
 
 	/* verify they are not requesting separate vectors */
 	if (!count || ch->rx_count || ch->tx_count)
@@ -1186,6 +1209,27 @@ static int fm10k_set_channels(struct net_device *dev,
 	if (count > fm10k_max_channels(dev))
 		return -EINVAL;
 
+	/* determine the current number of queues used by the reta table */
+	for (i = FM10K_RETA_SIZE; i--;) {
+		reta0 = (interface->reta[i] << 24) >> 24;
+		reta1 = (interface->reta[i] << 16) >> 24;
+		reta2 = (interface->reta[i] <<  8) >> 24;
+		reta3 = (interface->reta[i])       >> 24;
+
+		if (reta0 > rss_i)
+			rss_i = reta0;
+		if (reta1 > rss_i)
+			rss_i = reta1;
+		if (reta2 > rss_i)
+			rss_i = reta2;
+		if (reta3 > rss_i)
+			rss_i = reta3;
+	}
+
+	/* verify the request doesn't invalidate the current reta table */
+	if (count < rss_i)
+		return -EINVAL;
+
 	interface->ring_feature[RING_F_RSS].limit = count;
 
 	/* use setup TC to update any traffic class queue mapping */
@@ -1242,6 +1286,7 @@ static const struct ethtool_ops fm10k_ethtool_ops = {
 	.get_rxfh_key_size	= fm10k_get_rssrk_size,
 	.get_rxfh		= fm10k_get_rssh,
 	.set_rxfh		= fm10k_set_rssh,
+	.reset_rxfh_indir	= fm10k_reset_rssh,
 	.get_channels		= fm10k_get_channels,
 	.set_channels		= fm10k_set_channels,
 	.get_ts_info            = fm10k_get_ts_info,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 134ce4daa994..54205d3da29e 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1932,13 +1932,14 @@ static void fm10k_assign_rings(struct fm10k_intfc *interface)
 	fm10k_cache_ring_rss(interface);
 }
 
-static void fm10k_init_reta(struct fm10k_intfc *interface)
+void fm10k_init_reta(struct fm10k_intfc *interface)
 {
 	u16 i, rss_i = interface->ring_feature[RING_F_RSS].indices;
 	u32 reta, base;
 
-	/* If the netdev is initialized we have to maintain table if possible */
-	if (interface->netdev->reg_state != NETREG_UNINITIALIZED) {
+	/* if the redirection table is user-configured, we must maintain it
+	 * when possible. */
+	if (interface->flags & FM10K_FLAG_RETA_TABLE_CONFIGURED) {
 		for (i = FM10K_RETA_SIZE; i--;) {
 			reta = interface->reta[i];
 			if ((((reta << 24) >> 24) < rss_i) &&
@@ -1946,6 +1947,10 @@ static void fm10k_init_reta(struct fm10k_intfc *interface)
 			    (((reta <<  8) >> 24) < rss_i) &&
 			    (((reta)       >> 24) < rss_i))
 				continue;
+
+			/* this should never happen */
+			dev_err(&interface->pdev->dev,
+				"RSS indirection table is invalid and must be reconfigured\n");
 			goto repopulate_reta;
 		}
 
-- 
2.7.0.236.gda096a0.dirty
