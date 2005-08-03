From: raghavendra.koushik@neterion.com
Subject: [PATCH 2.6.13-rc4 4/13] S2io: Removed memory leaks
Date: Wed,  3 Aug 2005 12:30:43 -0700 (PDT)
Message-ID: <20050803193043.3B07898336@linux.site>
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
This patch fixes certain memory leaks discovered in free_tx_buffers()
and rx_osm_handler()

Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
Signed-off-by: Raghavendra Koushik <raghavendra.koushik@neterion.com>
---
diff -uprN vanilla_linux/drivers/net/s2io.c linux-2.6.13-rc4/drivers/net/s2io.c
--- vanilla_linux/drivers/net/s2io.c	2005-08-02 02:51:35.000000000 -0700
+++ linux-2.6.13-rc4/drivers/net/s2io.c	2005-08-02 02:51:26.000000000 -0700
@@ -1709,7 +1709,7 @@ static void free_tx_buffers(struct s2io_
 	int i, j;
 	mac_info_t *mac_control;
 	struct config_param *config;
-	int cnt = 0;
+	int cnt = 0, frg_cnt;
 
 	mac_control = &nic->mac_control;
 	config = &nic->config;
@@ -1722,11 +1722,33 @@ static void free_tx_buffers(struct s2io_
 			    (struct sk_buff *) ((unsigned long) txdp->
 						Host_Control);
 			if (skb == NULL) {
-				memset(txdp, 0, sizeof(TxD_t));
+				memset(txdp, 0, sizeof(TxD_t) *
+				       config->max_txds);
 				continue;
 			}
+			frg_cnt = skb_shinfo(skb)->nr_frags;
+			pci_unmap_single(nic->pdev, (dma_addr_t)
+					 txdp->Buffer_Pointer,
+					 skb->len - skb->data_len,
+					 PCI_DMA_TODEVICE);
+			if (frg_cnt) {
+				TxD_t *temp;
+				temp = txdp;
+				txdp++;
+				for (j = 0; j < frg_cnt; j++, txdp++) {
+					skb_frag_t *frag =
+					    &skb_shinfo(skb)->frags[j];
+					pci_unmap_page(nic->pdev,
+						       (dma_addr_t)
+						       txdp->
+						       Buffer_Pointer,
+						       frag->size,
+						       PCI_DMA_TODEVICE);
+				}
+				txdp = temp;
+			}
 			dev_kfree_skb(skb);
-			memset(txdp, 0, sizeof(TxD_t));
+			memset(txdp, 0, sizeof(TxD_t) * config->max_txds);
 			cnt++;
 		}
 		DBG_PRINT(INTR_DBG,
@@ -4570,6 +4592,11 @@ static int rx_osm_handler(ring_info_t *r
 		unsigned long long err = rxdp->Control_1 & RXD_T_CODE;
 		DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%llx\n",
 			  dev->name, err);
+		dev_kfree_skb(skb);
+		sp->stats.rx_crc_errors++;
+		atomic_dec(&sp->rx_bufs_left[ring_no]);
+		rxdp->Host_Control = 0;
+		return 0;
 	}
 
 	/* Updating statistics */
