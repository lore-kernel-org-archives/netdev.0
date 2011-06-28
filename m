From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the wireless-current
 tree
Date: Tue, 28 Jun 2011 14:02:19 +1000
Message-ID: <20110628140219.1480dc7a.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>,
	"Wey-Yi Guy" <wey-yi.w.guy@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/wireless/iwlwifi/iwl-tx.c between commits 1107a08a1a3e
("iwlagn: fix cmd queue unmap"), e815407d395e ("iwlagn: map command
buffers BIDI") and 2627c002cbed ("iwlagn: use PCI_DMA_* for pci_*
operations") from the wireless-current tree and commit 795414db8607
("iwlagn: don't use the PCI wrappers for DMA operation") from the net
tree.

I fixed it up (I think - see below) and can carry the fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/iwlwifi/iwl-tx.c
index 9eee978,fd8aee9..0000000
--- a/drivers/net/wireless/iwlwifi/iwl-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-tx.c
@@@ -126,9 -126,8 +126,8 @@@ static inline u8 iwl_tfd_get_num_tbs(st
  }
  
  static void iwlagn_unmap_tfd(struct iwl_priv *priv, struct iwl_cmd_meta *meta,
 -			     struct iwl_tfd *tfd)
 +			     struct iwl_tfd *tfd, enum dma_data_direction dma_dir)
  {
- 	struct pci_dev *dev = priv->pci_dev;
  	int i;
  	int num_tbs;
  
@@@ -150,8 -149,8 +149,8 @@@
  
  	/* Unmap chunks, if any. */
  	for (i = 1; i < num_tbs; i++)
- 		pci_unmap_single(dev, iwl_tfd_tb_get_addr(tfd, i),
+ 		dma_unmap_single(priv->bus.dev, iwl_tfd_tb_get_addr(tfd, i),
 -				iwl_tfd_tb_get_len(tfd, i), DMA_TO_DEVICE);
 +				iwl_tfd_tb_get_len(tfd, i), dma_dir);
  }
  
  /**
@@@ -167,8 -166,7 +166,8 @@@ void iwlagn_txq_free_tfd(struct iwl_pri
  	struct iwl_tfd *tfd_tmp = txq->tfds;
  	int index = txq->q.read_ptr;
  
 -	iwlagn_unmap_tfd(priv, &txq->meta[index], &tfd_tmp[index]);
 +	iwlagn_unmap_tfd(priv, &txq->meta[index], &tfd_tmp[index],
- 			 PCI_DMA_TODEVICE);
++			 DMA_TO_DEVICE);
  
  	/* free SKB */
  	if (txq->txb) {
@@@ -311,8 -309,10 +310,8 @@@ void iwl_cmd_queue_unmap(struct iwl_pri
  		i = get_cmd_index(q, q->read_ptr);
  
  		if (txq->meta[i].flags & CMD_MAPPED) {
 -			dma_unmap_single(priv->bus.dev,
 -					 dma_unmap_addr(&txq->meta[i], mapping),
 -					 dma_unmap_len(&txq->meta[i], len),
 +			iwlagn_unmap_tfd(priv, &txq->meta[i], &txq->tfds[i],
- 					 PCI_DMA_BIDIRECTIONAL);
+ 					 DMA_BIDIRECTIONAL);
  			txq->meta[i].flags = 0;
  		}
  
@@@ -693,12 -698,11 +692,12 @@@ int iwl_enqueue_hcmd(struct iwl_priv *p
  			continue;
  		if (!(cmd->dataflags[i] & IWL_HCMD_DFL_NOCOPY))
  			continue;
- 		phys_addr = pci_map_single(priv->pci_dev, (void *)cmd->data[i],
- 					   cmd->len[i], PCI_DMA_BIDIRECTIONAL);
- 		if (pci_dma_mapping_error(priv->pci_dev, phys_addr)) {
+ 		phys_addr = dma_map_single(priv->bus.dev, (void *)cmd->data[i],
 -					   cmd->len[i], DMA_TO_DEVICE);
++					   cmd->len[i], DMA_BIDIRECTIONAL);
+ 		if (dma_mapping_error(priv->bus.dev, phys_addr)) {
  			iwlagn_unmap_tfd(priv, out_meta,
 -					 &txq->tfds[q->write_ptr]);
 +					 &txq->tfds[q->write_ptr],
- 					 PCI_DMA_BIDIRECTIONAL);
++					 DMA_BIDIRECTIONAL);
  			idx = -ENOMEM;
  			goto out;
  		}
@@@ -802,7 -806,7 +801,7 @@@ void iwl_tx_cmd_complete(struct iwl_pri
  	cmd = txq->cmd[cmd_index];
  	meta = &txq->meta[cmd_index];
  
- 	iwlagn_unmap_tfd(priv, meta, &txq->tfds[index], PCI_DMA_BIDIRECTIONAL);
 -	iwlagn_unmap_tfd(priv, meta, &txq->tfds[index]);
++	iwlagn_unmap_tfd(priv, meta, &txq->tfds[index], DMA_BIDIRECTIONAL);
  
  	/* Input error checking is done when commands are added to queue. */
  	if (meta->flags & CMD_WANT_SKB) {
