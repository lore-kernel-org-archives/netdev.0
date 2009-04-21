From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-04-21
Date: Tue, 21 Apr 2009 17:25:03 -0400
Message-ID: <20090421212503.GN3369@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Another quick round of fixes intended for 2.6.30...phew!

iwlwifi: fix EEPROM validation mask to include OTP only devices

This lets iwlagn work with newer iwl6000 devices -- similar to adding a
PCI ID.

mac80211: fix alignment calculation bug

This fixes a botched alignment check in ieee80211_deliver_skb -- a
one-liner.

mwl8: fix build warning.

Another one-liner, it corrects a build warning due to improper
endian conversion of an 8-bit field.

iwl3945: use cancel_delayed_work_sync to cancel rfkill_poll

This prevents iwl3945 from queuing rfkill_poll while removing the
module.

mac80211: do not print WARN if config interface

This prevents an annoying and useless warning from showing-up in logs.

iwlwifi: add debugging for TX path

This adds some debugging messages to display sequence numbers for help
in tracking-down problems with the iwlwifi drivers.  The Intel
developers have requested this for their use, and it looks harmless.

iwlwifi: DMA fixes

This one is rather big, but it corrects a number of issues relating to
improper use of the DMA API that were uncovered when using iwlwifi with
swiotlb.  There is a bugzilla entry mentioned in the changelog.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 1bb593801ee32dd9d983dea3cbedf68f71345f78:
  Johannes Berg (1):
        atmel: fix netdev ops conversion

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Jay Sternberg (1):
      iwlwifi: fix EEPROM validation mask to include OTP only devices

Johannes Berg (1):
      mac80211: fix alignment calculation bug

Rami Rosen (1):
      mwl8: fix build warning.

Reinette Chatre (4):
      iwl3945: use cancel_delayed_work_sync to cancel rfkill_poll
      mac80211: do not print WARN if config interface
      iwlwifi: add debugging for TX path
      iwlwifi: DMA fixes

 drivers/net/wireless/iwlwifi/iwl-3945.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h     |    1 +
 drivers/net/wireless/iwlwifi/iwl-agn.c      |   11 +--
 drivers/net/wireless/iwlwifi/iwl-csr.h      |    2 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h      |    4 +
 drivers/net/wireless/iwlwifi/iwl-tx.c       |   99 ++++++++++--------
 drivers/net/wireless/iwlwifi/iwl3945-base.c |  148 +++++++++++++++++++--------
 drivers/net/wireless/mwl8k.c                |    3 +-
 net/mac80211/pm.c                           |   15 +++-
 net/mac80211/rx.c                           |    2 +-
 10 files changed, 185 insertions(+), 102 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wireless/iwlwifi/iwl-3945.c
index 2399328..527525c 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -1192,7 +1192,7 @@ int iwl3945_hw_nic_init(struct iwl_priv *priv)
 			return -ENOMEM;
 		}
 	} else
-		iwl_rx_queue_reset(priv, rxq);
+		iwl3945_rx_queue_reset(priv, rxq);
 
 	iwl3945_rx_replenish(priv);
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.h b/drivers/net/wireless/iwlwifi/iwl-3945.h
index ab7aaf6..5518884 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.h
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.h
@@ -215,6 +215,7 @@ extern int iwl3945_calc_sig_qual(int rssi_dbm, int noise_dbm);
 extern int iwl3945_tx_queue_init(struct iwl_priv *priv,
 			     struct iwl_tx_queue *txq, int count, u32 id);
 extern void iwl3945_rx_replenish(void *data);
+extern void iwl3945_rx_queue_reset(struct iwl_priv *priv, struct iwl_rx_queue *rxq);
 extern void iwl3945_tx_queue_free(struct iwl_priv *priv, struct iwl_tx_queue *txq);
 extern int iwl3945_send_cmd_pdu(struct iwl_priv *priv, u8 id, u16 len,
 			    const void *data);
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 3889158..1ef4192 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -976,11 +976,9 @@ void iwl_rx_handle(struct iwl_priv *priv)
 
 		rxq->queue[i] = NULL;
 
-		dma_sync_single_range_for_cpu(
-				&priv->pci_dev->dev, rxb->real_dma_addr,
-				rxb->aligned_dma_addr - rxb->real_dma_addr,
-				priv->hw_params.rx_buf_size,
-				PCI_DMA_FROMDEVICE);
+		pci_unmap_single(priv->pci_dev, rxb->real_dma_addr,
+				 priv->hw_params.rx_buf_size + 256,
+				 PCI_DMA_FROMDEVICE);
 		pkt = (struct iwl_rx_packet *)rxb->skb->data;
 
 		/* Reclaim a command buffer only if this packet is a response
@@ -1031,9 +1029,6 @@ void iwl_rx_handle(struct iwl_priv *priv)
 			rxb->skb = NULL;
 		}
 
-		pci_unmap_single(priv->pci_dev, rxb->real_dma_addr,
-				 priv->hw_params.rx_buf_size + 256,
-				 PCI_DMA_FROMDEVICE);
 		spin_lock_irqsave(&rxq->lock, flags);
 		list_add_tail(&rxb->list, &priv->rxq.rx_used);
 		spin_unlock_irqrestore(&rxq->lock, flags);
diff --git a/drivers/net/wireless/iwlwifi/iwl-csr.h b/drivers/net/wireless/iwlwifi/iwl-csr.h
index 2f12424..6e98314 100644
--- a/drivers/net/wireless/iwlwifi/iwl-csr.h
+++ b/drivers/net/wireless/iwlwifi/iwl-csr.h
@@ -223,7 +223,7 @@
 #define CSR_EEPROM_REG_MSK_DATA		(0xFFFF0000)
 
 /* EEPROM GP */
-#define CSR_EEPROM_GP_VALID_MSK		(0x00000006)
+#define CSR_EEPROM_GP_VALID_MSK		(0x00000007)
 #define CSR_EEPROM_GP_BAD_SIGNATURE	(0x00000000)
 #define CSR_EEPROM_GP_IF_OWNER_MSK	(0x00000180)
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-dev.h b/drivers/net/wireless/iwlwifi/iwl-dev.h
index ec9a138..cf7f0db 100644
--- a/drivers/net/wireless/iwlwifi/iwl-dev.h
+++ b/drivers/net/wireless/iwlwifi/iwl-dev.h
@@ -360,12 +360,16 @@ struct iwl_host_cmd {
 
 /**
  * struct iwl_rx_queue - Rx queue
+ * @bd: driver's pointer to buffer of receive buffer descriptors (rbd)
+ * @dma_addr: bus address of buffer of receive buffer descriptors (rbd)
  * @read: Shared index to newest available Rx buffer
  * @write: Shared index to oldest written Rx packet
  * @free_count: Number of pre-allocated buffers in rx_free
  * @rx_free: list of free SKBs for use
  * @rx_used: List of Rx buffers with no SKB
  * @need_update: flag to indicate we need to update read/write index
+ * @rb_stts: driver's pointer to receive buffer status
+ * @rb_stts_dma: bus address of receive buffer status
  *
  * NOTE:  rx_free and rx_used are used as a FIFO for iwl_rx_mem_buffers
  */
diff --git a/drivers/net/wireless/iwlwifi/iwl-tx.c b/drivers/net/wireless/iwlwifi/iwl-tx.c
index 1f117a4..71d5b8a 100644
--- a/drivers/net/wireless/iwlwifi/iwl-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-tx.c
@@ -799,6 +799,22 @@ int iwl_tx_skb(struct iwl_priv *priv, struct sk_buff *skb)
 	/* Copy MAC header from skb into command buffer */
 	memcpy(tx_cmd->hdr, hdr, hdr_len);
 
+
+	/* Total # bytes to be transmitted */
+	len = (u16)skb->len;
+	tx_cmd->len = cpu_to_le16(len);
+
+	if (info->control.hw_key)
+		iwl_tx_cmd_build_hwcrypto(priv, info, tx_cmd, skb, sta_id);
+
+	/* TODO need this for burst mode later on */
+	iwl_tx_cmd_build_basic(priv, tx_cmd, info, hdr, sta_id);
+
+	/* set is_hcca to 0; it probably will never be implemented */
+	iwl_tx_cmd_build_rate(priv, tx_cmd, info, fc, sta_id, 0);
+
+	iwl_update_tx_stats(priv, le16_to_cpu(fc), len);
+
 	/*
 	 * Use the first empty entry in this queue's command buffer array
 	 * to contain the Tx command and MAC header concatenated together
@@ -819,21 +835,30 @@ int iwl_tx_skb(struct iwl_priv *priv, struct sk_buff *skb)
 	else
 		len_org = 0;
 
+	/* Tell NIC about any 2-byte padding after MAC header */
+	if (len_org)
+		tx_cmd->tx_flags |= TX_CMD_FLG_MH_PAD_MSK;
+
 	/* Physical address of this Tx command's header (not MAC header!),
 	 * within command buffer array. */
 	txcmd_phys = pci_map_single(priv->pci_dev,
-				    out_cmd, sizeof(struct iwl_cmd),
+				    &out_cmd->hdr, len,
 				    PCI_DMA_BIDIRECTIONAL);
 	pci_unmap_addr_set(&out_cmd->meta, mapping, txcmd_phys);
-	pci_unmap_len_set(&out_cmd->meta, len, sizeof(struct iwl_cmd));
+	pci_unmap_len_set(&out_cmd->meta, len, len);
 	/* Add buffer containing Tx command and MAC(!) header to TFD's
 	 * first entry */
-	txcmd_phys += offsetof(struct iwl_cmd, hdr);
 	priv->cfg->ops->lib->txq_attach_buf_to_tfd(priv, txq,
 						   txcmd_phys, len, 1, 0);
 
-	if (info->control.hw_key)
-		iwl_tx_cmd_build_hwcrypto(priv, info, tx_cmd, skb, sta_id);
+	if (!ieee80211_has_morefrags(hdr->frame_control)) {
+		txq->need_update = 1;
+		if (qc)
+			priv->stations[sta_id].tid[tid].seq_number = seq_number;
+	} else {
+		wait_write_ptr = 1;
+		txq->need_update = 0;
+	}
 
 	/* Set up TFD's 2nd entry to point directly to remainder of skb,
 	 * if any (802.11 null frames have no payload). */
@@ -846,41 +871,29 @@ int iwl_tx_skb(struct iwl_priv *priv, struct sk_buff *skb)
 							   0, 0);
 	}
 
-	/* Tell NIC about any 2-byte padding after MAC header */
-	if (len_org)
-		tx_cmd->tx_flags |= TX_CMD_FLG_MH_PAD_MSK;
-
-	/* Total # bytes to be transmitted */
-	len = (u16)skb->len;
-	tx_cmd->len = cpu_to_le16(len);
-	/* TODO need this for burst mode later on */
-	iwl_tx_cmd_build_basic(priv, tx_cmd, info, hdr, sta_id);
-
-	/* set is_hcca to 0; it probably will never be implemented */
-	iwl_tx_cmd_build_rate(priv, tx_cmd, info, fc, sta_id, 0);
-
-	iwl_update_tx_stats(priv, le16_to_cpu(fc), len);
-
 	scratch_phys = txcmd_phys + sizeof(struct iwl_cmd_header) +
-		offsetof(struct iwl_tx_cmd, scratch);
+				offsetof(struct iwl_tx_cmd, scratch);
+
+	len = sizeof(struct iwl_tx_cmd) +
+		sizeof(struct iwl_cmd_header) + hdr_len;
+	/* take back ownership of DMA buffer to enable update */
+	pci_dma_sync_single_for_cpu(priv->pci_dev, txcmd_phys,
+				    len, PCI_DMA_BIDIRECTIONAL);
 	tx_cmd->dram_lsb_ptr = cpu_to_le32(scratch_phys);
 	tx_cmd->dram_msb_ptr = iwl_get_dma_hi_addr(scratch_phys);
 
-	if (!ieee80211_has_morefrags(hdr->frame_control)) {
-		txq->need_update = 1;
-		if (qc)
-			priv->stations[sta_id].tid[tid].seq_number = seq_number;
-	} else {
-		wait_write_ptr = 1;
-		txq->need_update = 0;
-	}
-
+	IWL_DEBUG_TX(priv, "sequence nr = 0X%x \n",
+		     le16_to_cpu(out_cmd->hdr.sequence));
+	IWL_DEBUG_TX(priv, "tx_flags = 0X%x \n", le32_to_cpu(tx_cmd->tx_flags));
 	iwl_print_hex_dump(priv, IWL_DL_TX, (u8 *)tx_cmd, sizeof(*tx_cmd));
-
 	iwl_print_hex_dump(priv, IWL_DL_TX, (u8 *)tx_cmd->hdr, hdr_len);
 
 	/* Set up entry for this TFD in Tx byte-count array */
-	priv->cfg->ops->lib->txq_update_byte_cnt_tbl(priv, txq, len);
+	priv->cfg->ops->lib->txq_update_byte_cnt_tbl(priv, txq,
+						     le16_to_cpu(tx_cmd->len));
+
+	pci_dma_sync_single_for_device(priv->pci_dev, txcmd_phys,
+				       len, PCI_DMA_BIDIRECTIONAL);
 
 	/* Tell device the write index *just past* this latest filled TFD */
 	q->write_ptr = iwl_queue_inc_wrap(q->write_ptr, q->n_bd);
@@ -968,18 +981,9 @@ int iwl_enqueue_hcmd(struct iwl_priv *priv, struct iwl_host_cmd *cmd)
 			INDEX_TO_SEQ(q->write_ptr));
 	if (out_cmd->meta.flags & CMD_SIZE_HUGE)
 		out_cmd->hdr.sequence |= SEQ_HUGE_FRAME;
-	len = (idx == TFD_CMD_SLOTS) ?
-			IWL_MAX_SCAN_SIZE : sizeof(struct iwl_cmd);
-
-	phys_addr = pci_map_single(priv->pci_dev, out_cmd,
-				   len, PCI_DMA_BIDIRECTIONAL);
-	pci_unmap_addr_set(&out_cmd->meta, mapping, phys_addr);
-	pci_unmap_len_set(&out_cmd->meta, len, len);
-	phys_addr += offsetof(struct iwl_cmd, hdr);
+	len = sizeof(struct iwl_cmd) - sizeof(struct iwl_cmd_meta);
+	len += (idx == TFD_CMD_SLOTS) ?  IWL_MAX_SCAN_SIZE : 0;
 
-	priv->cfg->ops->lib->txq_attach_buf_to_tfd(priv, txq,
-						   phys_addr, fix_size, 1,
-						   U32_PAD(cmd->len));
 
 #ifdef CONFIG_IWLWIFI_DEBUG
 	switch (out_cmd->hdr.cmd) {
@@ -1007,6 +1011,15 @@ int iwl_enqueue_hcmd(struct iwl_priv *priv, struct iwl_host_cmd *cmd)
 		/* Set up entry in queue's byte count circular buffer */
 		priv->cfg->ops->lib->txq_update_byte_cnt_tbl(priv, txq, 0);
 
+	phys_addr = pci_map_single(priv->pci_dev, &out_cmd->hdr,
+				   fix_size, PCI_DMA_BIDIRECTIONAL);
+	pci_unmap_addr_set(&out_cmd->meta, mapping, phys_addr);
+	pci_unmap_len_set(&out_cmd->meta, len, fix_size);
+
+	priv->cfg->ops->lib->txq_attach_buf_to_tfd(priv, txq,
+						   phys_addr, fix_size, 1,
+						   U32_PAD(cmd->len));
+
 	/* Increment and update queue's write index */
 	q->write_ptr = iwl_queue_inc_wrap(q->write_ptr, q->n_bd);
 	ret = iwl_txq_update_write_ptr(priv, txq);
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index da61ecd..617c423 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -972,7 +972,7 @@ static int iwl3945_tx_skb(struct iwl_priv *priv, struct sk_buff *skb)
 	dma_addr_t phys_addr;
 	dma_addr_t txcmd_phys;
 	int txq_id = skb_get_queue_mapping(skb);
-	u16 len, idx, len_org, hdr_len;
+	u16 len, idx, len_org, hdr_len; /* TODO: len_org is not used */
 	u8 id;
 	u8 unicast;
 	u8 sta_id;
@@ -1074,6 +1074,40 @@ static int iwl3945_tx_skb(struct iwl_priv *priv, struct sk_buff *skb)
 	/* Copy MAC header from skb into command buffer */
 	memcpy(tx->hdr, hdr, hdr_len);
 
+
+	if (info->control.hw_key)
+		iwl3945_build_tx_cmd_hwcrypto(priv, info, out_cmd, skb, sta_id);
+
+	/* TODO need this for burst mode later on */
+	iwl3945_build_tx_cmd_basic(priv, out_cmd, info, hdr, sta_id);
+
+	/* set is_hcca to 0; it probably will never be implemented */
+	iwl3945_hw_build_tx_cmd_rate(priv, out_cmd, info, hdr, sta_id, 0);
+
+	/* Total # bytes to be transmitted */
+	len = (u16)skb->len;
+	tx->len = cpu_to_le16(len);
+
+
+	tx->tx_flags &= ~TX_CMD_FLG_ANT_A_MSK;
+	tx->tx_flags &= ~TX_CMD_FLG_ANT_B_MSK;
+
+	if (!ieee80211_has_morefrags(hdr->frame_control)) {
+		txq->need_update = 1;
+		if (qc)
+			priv->stations_39[sta_id].tid[tid].seq_number = seq_number;
+	} else {
+		wait_write_ptr = 1;
+		txq->need_update = 0;
+	}
+
+	IWL_DEBUG_TX(priv, "sequence nr = 0X%x \n",
+		     le16_to_cpu(out_cmd->hdr.sequence));
+	IWL_DEBUG_TX(priv, "tx_flags = 0X%x \n", le32_to_cpu(tx->tx_flags));
+	iwl_print_hex_dump(priv, IWL_DL_TX, tx, sizeof(*tx));
+	iwl_print_hex_dump(priv, IWL_DL_TX, (u8 *)tx->hdr,
+			   ieee80211_hdrlen(fc));
+
 	/*
 	 * Use the first empty entry in this queue's command buffer array
 	 * to contain the Tx command and MAC header concatenated together
@@ -1096,22 +1130,18 @@ static int iwl3945_tx_skb(struct iwl_priv *priv, struct sk_buff *skb)
 
 	/* Physical address of this Tx command's header (not MAC header!),
 	 * within command buffer array. */
-	txcmd_phys = pci_map_single(priv->pci_dev,
-				    out_cmd, sizeof(struct iwl_cmd),
-				    PCI_DMA_TODEVICE);
+	txcmd_phys = pci_map_single(priv->pci_dev, &out_cmd->hdr,
+				    len, PCI_DMA_TODEVICE);
+	/* we do not map meta data ... so we can safely access address to
+	 * provide to unmap command*/
 	pci_unmap_addr_set(&out_cmd->meta, mapping, txcmd_phys);
-	pci_unmap_len_set(&out_cmd->meta, len, sizeof(struct iwl_cmd));
-	/* Add buffer containing Tx command and MAC(!) header to TFD's
-	 * first entry */
-	txcmd_phys += offsetof(struct iwl_cmd, hdr);
+	pci_unmap_len_set(&out_cmd->meta, len, len);
 
 	/* Add buffer containing Tx command and MAC(!) header to TFD's
 	 * first entry */
 	priv->cfg->ops->lib->txq_attach_buf_to_tfd(priv, txq,
 						   txcmd_phys, len, 1, 0);
 
-	if (info->control.hw_key)
-		iwl3945_build_tx_cmd_hwcrypto(priv, info, out_cmd, skb, sta_id);
 
 	/* Set up TFD's 2nd entry to point directly to remainder of skb,
 	 * if any (802.11 null frames have no payload). */
@@ -1124,32 +1154,6 @@ static int iwl3945_tx_skb(struct iwl_priv *priv, struct sk_buff *skb)
 							   0, U32_PAD(len));
 	}
 
-	/* Total # bytes to be transmitted */
-	len = (u16)skb->len;
-	tx->len = cpu_to_le16(len);
-
-	/* TODO need this for burst mode later on */
-	iwl3945_build_tx_cmd_basic(priv, out_cmd, info, hdr, sta_id);
-
-	/* set is_hcca to 0; it probably will never be implemented */
-	iwl3945_hw_build_tx_cmd_rate(priv, out_cmd, info, hdr, sta_id, 0);
-
-	tx->tx_flags &= ~TX_CMD_FLG_ANT_A_MSK;
-	tx->tx_flags &= ~TX_CMD_FLG_ANT_B_MSK;
-
-	if (!ieee80211_has_morefrags(hdr->frame_control)) {
-		txq->need_update = 1;
-		if (qc)
-			priv->stations_39[sta_id].tid[tid].seq_number = seq_number;
-	} else {
-		wait_write_ptr = 1;
-		txq->need_update = 0;
-	}
-
-	iwl_print_hex_dump(priv, IWL_DL_TX, tx, sizeof(*tx));
-
-	iwl_print_hex_dump(priv, IWL_DL_TX, (u8 *)tx->hdr,
-			   ieee80211_hdrlen(fc));
 
 	/* Tell device the write index *just past* this latest filled TFD */
 	q->write_ptr = iwl_queue_inc_wrap(q->write_ptr, q->n_bd);
@@ -1661,6 +1665,37 @@ static void iwl3945_rx_allocate(struct iwl_priv *priv)
 	spin_unlock_irqrestore(&rxq->lock, flags);
 }
 
+void iwl3945_rx_queue_reset(struct iwl_priv *priv, struct iwl_rx_queue *rxq)
+{
+	unsigned long flags;
+	int i;
+	spin_lock_irqsave(&rxq->lock, flags);
+	INIT_LIST_HEAD(&rxq->rx_free);
+	INIT_LIST_HEAD(&rxq->rx_used);
+	/* Fill the rx_used queue with _all_ of the Rx buffers */
+	for (i = 0; i < RX_FREE_BUFFERS + RX_QUEUE_SIZE; i++) {
+		/* In the reset function, these buffers may have been allocated
+		 * to an SKB, so we need to unmap and free potential storage */
+		if (rxq->pool[i].skb != NULL) {
+			pci_unmap_single(priv->pci_dev,
+					 rxq->pool[i].real_dma_addr,
+					 priv->hw_params.rx_buf_size,
+					 PCI_DMA_FROMDEVICE);
+			priv->alloc_rxb_skb--;
+			dev_kfree_skb(rxq->pool[i].skb);
+			rxq->pool[i].skb = NULL;
+		}
+		list_add_tail(&rxq->pool[i].list, &rxq->rx_used);
+	}
+
+	/* Set us so that we have processed and used all buffers, but have
+	 * not restocked the Rx queue with fresh buffers */
+	rxq->read = rxq->write = 0;
+	rxq->free_count = 0;
+	spin_unlock_irqrestore(&rxq->lock, flags);
+}
+EXPORT_SYMBOL(iwl3945_rx_queue_reset);
+
 /*
  * this should be called while priv->lock is locked
  */
@@ -1685,6 +1720,34 @@ void iwl3945_rx_replenish(void *data)
 	spin_unlock_irqrestore(&priv->lock, flags);
 }
 
+/* Assumes that the skb field of the buffers in 'pool' is kept accurate.
+ * If an SKB has been detached, the POOL needs to have its SKB set to NULL
+ * This free routine walks the list of POOL entries and if SKB is set to
+ * non NULL it is unmapped and freed
+ */
+static void iwl3945_rx_queue_free(struct iwl_priv *priv, struct iwl_rx_queue *rxq)
+{
+	int i;
+	for (i = 0; i < RX_QUEUE_SIZE + RX_FREE_BUFFERS; i++) {
+		if (rxq->pool[i].skb != NULL) {
+			pci_unmap_single(priv->pci_dev,
+					 rxq->pool[i].real_dma_addr,
+					 priv->hw_params.rx_buf_size,
+					 PCI_DMA_FROMDEVICE);
+			dev_kfree_skb(rxq->pool[i].skb);
+		}
+	}
+
+	pci_free_consistent(priv->pci_dev, 4 * RX_QUEUE_SIZE, rxq->bd,
+			    rxq->dma_addr);
+	pci_free_consistent(priv->pci_dev, sizeof(struct iwl_rb_status),
+			    rxq->rb_stts, rxq->rb_stts_dma);
+	rxq->bd = NULL;
+	rxq->rb_stts  = NULL;
+}
+EXPORT_SYMBOL(iwl3945_rx_queue_free);
+
+
 /* Convert linear signal-to-noise ratio into dB */
 static u8 ratio2dB[100] = {
 /*	 0   1   2   3   4   5   6   7   8   9 */
@@ -1802,9 +1865,9 @@ static void iwl3945_rx_handle(struct iwl_priv *priv)
 
 		rxq->queue[i] = NULL;
 
-		pci_dma_sync_single_for_cpu(priv->pci_dev, rxb->real_dma_addr,
-					    priv->hw_params.rx_buf_size,
-					    PCI_DMA_FROMDEVICE);
+		pci_unmap_single(priv->pci_dev, rxb->real_dma_addr,
+				priv->hw_params.rx_buf_size,
+				PCI_DMA_FROMDEVICE);
 		pkt = (struct iwl_rx_packet *)rxb->skb->data;
 
 		/* Reclaim a command buffer only if this packet is a response
@@ -1852,9 +1915,6 @@ static void iwl3945_rx_handle(struct iwl_priv *priv)
 			rxb->skb = NULL;
 		}
 
-		pci_unmap_single(priv->pci_dev, rxb->real_dma_addr,
-				priv->hw_params.rx_buf_size,
-				PCI_DMA_FROMDEVICE);
 		spin_lock_irqsave(&rxq->lock, flags);
 		list_add_tail(&rxb->list, &priv->rxq.rx_used);
 		spin_unlock_irqrestore(&rxq->lock, flags);
@@ -5196,12 +5256,12 @@ static void __devexit iwl3945_pci_remove(struct pci_dev *pdev)
 	sysfs_remove_group(&pdev->dev.kobj, &iwl3945_attribute_group);
 
 	iwl_rfkill_unregister(priv);
-	cancel_delayed_work(&priv->rfkill_poll);
+	cancel_delayed_work_sync(&priv->rfkill_poll);
 
 	iwl3945_dealloc_ucode_pci(priv);
 
 	if (priv->rxq.bd)
-		iwl_rx_queue_free(priv, &priv->rxq);
+		iwl3945_rx_queue_free(priv, &priv->rxq);
 	iwl3945_hw_txq_ctx_free(priv);
 
 	iwl3945_unset_hw_params(priv);
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index b5dbf6d..a9a9704 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -893,8 +893,7 @@ static int mwl8k_rxq_init(struct ieee80211_hw *hw, int index)
 		rx_desc->next_rx_desc_phys_addr =
 			cpu_to_le32(rxq->rx_desc_dma
 						+ nexti * sizeof(*rx_desc));
-		rx_desc->rx_ctrl =
-			cpu_to_le32(MWL8K_RX_CTRL_OWNED_BY_HOST);
+		rx_desc->rx_ctrl = MWL8K_RX_CTRL_OWNED_BY_HOST;
 	}
 
 	return 0;
diff --git a/net/mac80211/pm.c b/net/mac80211/pm.c
index 0273023..81985d2 100644
--- a/net/mac80211/pm.c
+++ b/net/mac80211/pm.c
@@ -156,8 +156,19 @@ int __ieee80211_resume(struct ieee80211_hw *hw)
 		case NL80211_IFTYPE_ADHOC:
 		case NL80211_IFTYPE_AP:
 		case NL80211_IFTYPE_MESH_POINT:
-			WARN_ON(ieee80211_if_config(sdata, changed));
-			ieee80211_bss_info_change_notify(sdata, ~0);
+			/*
+			 * Driver's config_interface can fail if rfkill is
+			 * enabled. Accommodate this return code.
+			 * FIXME: When mac80211 has knowledge of rfkill
+			 * state the code below can change back to:
+			 *   WARN(ieee80211_if_config(sdata, changed));
+			 *   ieee80211_bss_info_change_notify(sdata, ~0);
+			 */
+			if (ieee80211_if_config(sdata, changed))
+				printk(KERN_DEBUG "%s: failed to configure interface during resume\n",
+				       sdata->dev->name);
+			else
+				ieee80211_bss_info_change_notify(sdata, ~0);
 			break;
 		case NL80211_IFTYPE_WDS:
 			break;
diff --git a/net/mac80211/rx.c b/net/mac80211/rx.c
index 5fa7aed..9776f73 100644
--- a/net/mac80211/rx.c
+++ b/net/mac80211/rx.c
@@ -1397,7 +1397,7 @@ ieee80211_deliver_skb(struct ieee80211_rx_data *rx)
 		 * mac80211. That also explains the __skb_push()
 		 * below.
 		 */
-		align = (unsigned long)skb->data & 4;
+		align = (unsigned long)skb->data & 3;
 		if (align) {
 			if (WARN_ON(skb_headroom(skb) < 3)) {
 				dev_kfree_skb(skb);
-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
