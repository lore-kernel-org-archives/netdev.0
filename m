From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 08/14] bna: Initialization and Locking Fix
Date: Tue, 16 Aug 2011 14:19:45 -0700
Message-ID: <1313529591-3718-9-git-send-email-rmody@brocade.com>
References: <1313529591-3718-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Gurunatha Karaje <gkaraje@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:47910 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752909Ab1HPVUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 17:20:38 -0400
In-Reply-To: <1313529591-3718-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - Initialize rx_id to 0 for bnad_cleanup_rx
 - Return -ENOMEM in case if bna_rx_create fails
 - Count the Rx buffer allocation failures in bnad_alloc_n_post_rxbufs()
 - Remove unnecessary initialization of using_dac to false in bnad_pci_probe
 - Release lock if error while doing bna_num_txq_set in bnad_pci_probe
 - Release all the locks while doing free_netdev

Signed-off-by: Gurunatha Karaje <gkaraje@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bna_hw_defs.h |    1 +
 drivers/net/ethernet/brocade/bna/bnad.c        |   15 ++++++++++++---
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bna_hw_defs.h b/drivers/net/ethernet/brocade/bna/bna_hw_defs.h
index 07bb792..7ecdca5 100644
--- a/drivers/net/ethernet/brocade/bna/bna_hw_defs.h
+++ b/drivers/net/ethernet/brocade/bna/bna_hw_defs.h
@@ -99,6 +99,7 @@
 	(_bna)->bits.error_status_bits = (__HFN_INT_ERR_MASK);		\
 	(_bna)->bits.error_mask_bits = (__HFN_INT_ERR_MASK);		\
 	(_bna)->bits.halt_status_bits = __HFN_INT_LL_HALT;		\
+	(_bna)->bits.halt_mask_bits = __HFN_INT_LL_HALT;		\
 }
 
 #define ct2_reg_addr_init(_bna, _pcidev)				\
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 869d172..11c058e 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -409,6 +409,7 @@ bnad_alloc_n_post_rxbufs(struct bnad *bnad, struct bna_rcb *rcb)
 						rcb->rxq->buffer_size);
 		if (unlikely(!skb)) {
 			BNAD_UPDATE_CTR(bnad, rxbuf_alloc_failed);
+			rcb->rxq->rxbuf_alloc_failed++;
 			goto finishing;
 		}
 		unmap_array[unmap_prod].skb = skb;
@@ -1900,6 +1901,7 @@ bnad_cleanup_rx(struct bnad *bnad, u32 rx_id)
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 	rx_info->rx = NULL;
+	rx_info->rx_id = 0;
 
 	bnad_rx_res_free(bnad, res_info);
 }
@@ -1955,8 +1957,10 @@ bnad_setup_rx(struct bnad *bnad, u32 rx_id)
 	rx = bna_rx_create(&bnad->bna, bnad, rx_config, &rx_cbfn, res_info,
 			rx_info);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
-	if (!rx)
+	if (!rx) {
+		err = -ENOMEM;
 		goto err_return;
+	}
 	rx_info->rx = rx;
 
 	/*
@@ -3234,7 +3238,7 @@ static int __devinit
 bnad_pci_probe(struct pci_dev *pdev,
 		const struct pci_device_id *pcidev_id)
 {
-	bool	using_dac = false;
+	bool	using_dac;
 	int	err;
 	struct bnad *bnad;
 	struct bna *bna;
@@ -3357,6 +3361,11 @@ bnad_pci_probe(struct pci_dev *pdev,
 			bna_num_rxp_set(bna, BNAD_NUM_RXP + 1))
 			err = -EIO;
 	}
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
+	if (err)
+		goto disable_ioceth;
+
+	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_mod_res_req(&bnad->bna, &bnad->mod_res_info[0]);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
@@ -3410,9 +3419,9 @@ drv_uninit:
 	bnad_uninit(bnad);
 pci_uninit:
 	bnad_pci_uninit(pdev);
+free_netdev:
 	mutex_unlock(&bnad->conf_mutex);
 	bnad_lock_uninit(bnad);
-free_netdev:
 	free_netdev(netdev);
 	return err;
 }
-- 
1.7.1

