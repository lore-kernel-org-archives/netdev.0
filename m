From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2009-08-07
Date: Fri, 7 Aug 2009 14:39:17 -0400
Message-ID: <20090807183916.GI7545@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35037 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932718AbZHGSqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2009 14:46:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here are a few more late-comers intended for 2.6.31.  They are basically
simple one-liners (or might-as-well-be-one-liners), most fixing potential
security or crash issues or avoiding potentially obscure bugs.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 0bf52b981770cbf006323bab5177f2858a196766:
  Ingo Molnar (1):
        net: Fix spinlock use in alloc_netdev_mq()

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Bob Dunlop (1):
      libertas: correct packing of rxpd structure

Lennert Buytenhek (5):
      mwl8k: fix NULL pointer dereference on receive out-of-memory
      mwl8k: add various missing GET_HW_SPEC endian conversions
      mwl8k: call pci_unmap_single() before accessing command structure again
      mwl8k: prevent crash in ->configure_filter() if no interface was added
      mwl8k: prevent module unload hang

Zhu Yi (1):
      ipw2x00: Write outside array bounds

 drivers/net/wireless/ipw2x00/ipw2200.c  |    2 +-
 drivers/net/wireless/libertas/hostcmd.h |    4 ++--
 drivers/net/wireless/mwl8k.c            |   31 +++++++++++++++++++------------
 3 files changed, 22 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 44c29b3..6dcac73 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -6226,7 +6226,7 @@ static void ipw_add_scan_channels(struct ipw_priv *priv,
 			};
 
 			u8 channel;
-			while (channel_index < IPW_SCAN_CHANNELS) {
+			while (channel_index < IPW_SCAN_CHANNELS - 1) {
 				channel =
 				    priv->speed_scan[priv->speed_scan_pos];
 				if (channel == 0) {
diff --git a/drivers/net/wireless/libertas/hostcmd.h b/drivers/net/wireless/libertas/hostcmd.h
index 0a2e291..c8a1998 100644
--- a/drivers/net/wireless/libertas/hostcmd.h
+++ b/drivers/net/wireless/libertas/hostcmd.h
@@ -56,8 +56,8 @@ struct rxpd {
 			u8 bss_type;
 			/* BSS number */
 			u8 bss_num;
-		} bss;
-	} u;
+		} __attribute__ ((packed)) bss;
+	} __attribute__ ((packed)) u;
 
 	/* SNR */
 	u8 snr;
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index a263d5c..83967af 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -261,7 +261,7 @@ struct mwl8k_vif {
 	 */
 };
 
-#define MWL8K_VIF(_vif) (struct mwl8k_vif *)(&((_vif)->drv_priv))
+#define MWL8K_VIF(_vif) ((struct mwl8k_vif *)&((_vif)->drv_priv))
 
 static const struct ieee80211_channel mwl8k_channels[] = {
 	{ .center_freq = 2412, .hw_value = 1, },
@@ -1012,6 +1012,8 @@ static int rxq_process(struct ieee80211_hw *hw, int index, int limit)
 		rmb();
 
 		skb = rxq->rx_skb[rxq->rx_head];
+		if (skb == NULL)
+			break;
 		rxq->rx_skb[rxq->rx_head] = NULL;
 
 		rxq->rx_head = (rxq->rx_head + 1) % MWL8K_RX_DESCS;
@@ -1591,6 +1593,9 @@ static int mwl8k_post_cmd(struct ieee80211_hw *hw, struct mwl8k_cmd_pkt *cmd)
 	timeout = wait_for_completion_timeout(&cmd_wait,
 				msecs_to_jiffies(MWL8K_CMD_TIMEOUT_MS));
 
+	pci_unmap_single(priv->pdev, dma_addr, dma_size,
+					PCI_DMA_BIDIRECTIONAL);
+
 	result = &cmd->result;
 	if (!timeout) {
 		spin_lock_irq(&priv->fw_lock);
@@ -1610,8 +1615,6 @@ static int mwl8k_post_cmd(struct ieee80211_hw *hw, struct mwl8k_cmd_pkt *cmd)
 			       *result);
 	}
 
-	pci_unmap_single(priv->pdev, dma_addr, dma_size,
-					PCI_DMA_BIDIRECTIONAL);
 	return rc;
 }
 
@@ -1654,18 +1657,18 @@ static int mwl8k_cmd_get_hw_spec(struct ieee80211_hw *hw)
 	memset(cmd->perm_addr, 0xff, sizeof(cmd->perm_addr));
 	cmd->ps_cookie = cpu_to_le32(priv->cookie_dma);
 	cmd->rx_queue_ptr = cpu_to_le32(priv->rxq[0].rx_desc_dma);
-	cmd->num_tx_queues = MWL8K_TX_QUEUES;
+	cmd->num_tx_queues = cpu_to_le32(MWL8K_TX_QUEUES);
 	for (i = 0; i < MWL8K_TX_QUEUES; i++)
 		cmd->tx_queue_ptrs[i] = cpu_to_le32(priv->txq[i].tx_desc_dma);
-	cmd->num_tx_desc_per_queue = MWL8K_TX_DESCS;
-	cmd->total_rx_desc = MWL8K_RX_DESCS;
+	cmd->num_tx_desc_per_queue = cpu_to_le32(MWL8K_TX_DESCS);
+	cmd->total_rx_desc = cpu_to_le32(MWL8K_RX_DESCS);
 
 	rc = mwl8k_post_cmd(hw, &cmd->header);
 
 	if (!rc) {
 		SET_IEEE80211_PERM_ADDR(hw, cmd->perm_addr);
 		priv->num_mcaddrs = le16_to_cpu(cmd->num_mcaddrs);
-		priv->fw_rev = cmd->fw_rev;
+		priv->fw_rev = le32_to_cpu(cmd->fw_rev);
 		priv->hw_rev = cmd->hw_rev;
 		priv->region_code = le16_to_cpu(cmd->region_code);
 	}
@@ -3216,15 +3219,19 @@ static int mwl8k_configure_filter_wt(struct work_struct *wt)
 	struct dev_addr_list *mclist = worker->mclist;
 
 	struct mwl8k_priv *priv = hw->priv;
-	struct mwl8k_vif *mv_vif;
 	int rc = 0;
 
 	if (changed_flags & FIF_BCN_PRBRESP_PROMISC) {
 		if (*total_flags & FIF_BCN_PRBRESP_PROMISC)
 			rc = mwl8k_cmd_set_pre_scan(hw);
 		else {
-			mv_vif = MWL8K_VIF(priv->vif);
-			rc = mwl8k_cmd_set_post_scan(hw, mv_vif->bssid);
+			u8 *bssid;
+
+			bssid = "\x00\x00\x00\x00\x00\x00";
+			if (priv->vif != NULL)
+				bssid = MWL8K_VIF(priv->vif)->bssid;
+
+			rc = mwl8k_cmd_set_post_scan(hw, bssid);
 		}
 	}
 
@@ -3726,6 +3733,8 @@ static void __devexit mwl8k_remove(struct pci_dev *pdev)
 
 	ieee80211_stop_queues(hw);
 
+	ieee80211_unregister_hw(hw);
+
 	/* Remove tx reclaim tasklet */
 	tasklet_kill(&priv->tx_reclaim_task);
 
@@ -3739,8 +3748,6 @@ static void __devexit mwl8k_remove(struct pci_dev *pdev)
 	for (i = 0; i < MWL8K_TX_QUEUES; i++)
 		mwl8k_txq_reclaim(hw, i, 1);
 
-	ieee80211_unregister_hw(hw);
-
 	for (i = 0; i < MWL8K_TX_QUEUES; i++)
 		mwl8k_txq_deinit(hw, i);
 
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
