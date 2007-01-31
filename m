From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Subject: [PATCH 2.6.20 3/5] s2io: Fixes in updating skb->truesize and code
 cleanup.
Date: Wed, 31 Jan 2007 13:32:57 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10701311330590.23100-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: leonid.grossman@neterion.com, alicia.pena@neterion.com,
	ramkrishna.vepa@neterion.com, ananda.raju@neterion.com,
	sreenivasa.honnur@neterion.com, sriram.rapuru@neterion.com,
	sivakumar.subramani@neterion.com, santosh.rastapur@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:47689 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030527AbXAaSc6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jan 2007 13:32:58 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

1. Fix for updating skb->truesize properly.
2. Disable NAPI only if more than one ring configured in case of MSI/MSI-X
   interrupts. Previously we were disabling NAPI irrespective of number of
   rings when MSI/MSI-X interrupts were used.
3. Code cleanup.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
---
diff -urpN patch2/drivers/net/s2io.c patch3/drivers/net/s2io.c
--- patch2/drivers/net/s2io.c	2007-01-31 22:49:54.000000000 +0530
+++ patch3/drivers/net/s2io.c	2007-01-31 22:50:24.000000000 +0530
@@ -459,7 +459,7 @@ static int init_shared_mem(struct s2io_n
 	void *tmp_v_addr, *tmp_v_addr_next;
 	dma_addr_t tmp_p_addr, tmp_p_addr_next;
 	RxD_block_t *pre_rxd_blk = NULL;
-	int i, j, blk_cnt, rx_sz, tx_sz;
+	int i, j, blk_cnt;
 	int lst_size, lst_per_page;
 	struct net_device *dev = nic->dev;
 	unsigned long tmp;
@@ -484,7 +484,6 @@ static int init_shared_mem(struct s2io_n
 	}
 
 	lst_size = (sizeof(TxD_t) * config->max_txds);
-	tx_sz = lst_size * size;
 	lst_per_page = PAGE_SIZE / lst_size;
 
 	for (i = 0; i < config->tx_fifo_num; i++) {
@@ -583,7 +582,6 @@ static int init_shared_mem(struct s2io_n
 		size = (size * (sizeof(RxD1_t)));
 	else
 		size = (size * (sizeof(RxD3_t)));
-	rx_sz = size;
 
 	for (i = 0; i < config->rx_ring_num; i++) {
 		mac_control->rings[i].rx_curr_get_info.block_index = 0;
@@ -624,6 +622,8 @@ static int init_shared_mem(struct s2io_n
 			rx_blocks->rxds = kmalloc(sizeof(rxd_info_t)*
 						  rxd_count[nic->rxd_mode],
 						  GFP_KERNEL);
+			if (!rx_blocks->rxds)
+				return -ENOMEM;
 			for (l=0; l<rxd_count[nic->rxd_mode];l++) {
 				rx_blocks->rxds[l].virt_addr =
 					rx_blocks->block_virt_addr +
@@ -2259,6 +2259,7 @@ static int fill_rxd_3buf(nic_t *nic, RxD
 		return -ENOMEM ;
 	}
 	frag_list = skb_shinfo(skb)->frag_list;
+	skb->truesize += frag_list->truesize;
 	frag_list->next = NULL;
 	tmp = (void *)ALIGN((long)frag_list->data, ALIGN_SIZE + 1);
 	frag_list->data = tmp;
@@ -3185,6 +3186,8 @@ static void alarm_intr_handler(struct s2
 	register u64 val64 = 0, err_reg = 0;
 	u64 cnt;
 	int i;
+	if (atomic_read(&nic->card_state) == CARD_DOWN)
+		return;
 	nic->mac_control.stats_info->sw_stat.ring_full_cnt = 0;
 	/* Handling the XPAK counters update */
 	if(nic->mac_control.stats_info->xpak_stat.xpak_timer_count < 72000) {
@@ -6576,7 +6579,6 @@ static int rx_osm_handler(ring_info_t *r
 			skb_put(skb, buf1_len);
 			skb->len += buf2_len;
 			skb->data_len += buf2_len;
-			skb->truesize += buf2_len;
 			skb_put(skb_shinfo(skb)->frag_list, buf2_len);
 			sp->stats.rx_bytes += buf1_len;
 
@@ -6797,6 +6799,8 @@ static int s2io_verify_parm(struct pci_d
 					"Defaulting to INTA\n");
 		*dev_intr_type = INTA;
 	}
+	if ( (rx_ring_num > 1) && (*dev_intr_type != INTA) )
+		napi = 0;
 	if (rx_ring_mode > 3) {
 		DBG_PRINT(ERR_DBG, "s2io: Requested ring mode not supported\n");
 		DBG_PRINT(ERR_DBG, "s2io: Defaulting to 3-buffer mode\n");
@@ -7312,7 +7316,7 @@ int __init s2io_starter(void)
  * Description: This function is the cleanup routine for the driver. It unregist * ers the driver.
  */
 
-static void s2io_closer(void)
+static __exit void s2io_closer(void)
 {
 	pci_unregister_driver(&s2io_driver);
 	DBG_PRINT(INIT_DBG, "cleanup done\n");
@@ -7633,6 +7637,7 @@ static void lro_append_pkt(nic_t *sp, lr
 		lro->last_frag->next = skb;
 	else
 		skb_shinfo(first)->frag_list = skb;
+	first->truesize += skb->truesize;
 	lro->last_frag = skb;
 	sp->mac_control.stats_info->sw_stat.clubbed_frms_cnt++;
 	return;

