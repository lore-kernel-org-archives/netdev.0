From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.26 2/5]S2io: Removed rx_lock and put_lock
Date: Wed, 23 Apr 2008 13:31:33 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10804231331000.10279-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:39444 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753249AbYDWRbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 13:31:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Removed rx_lock and put_lock as the buffer replenishment and receive completion 
  is handled serially.

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -Nurp 2-0-26-21-1/drivers/net/s2io.c 2-0-26-21-2/drivers/net/s2io.c
--- 2-0-26-21-1/drivers/net/s2io.c	2008-04-09 21:06:59.000000000 +0530
+++ 2-0-26-21-2/drivers/net/s2io.c	2008-04-09 21:08:07.000000000 +0530
@@ -2530,7 +2530,6 @@ static int fill_rx_buffers(struct s2io_n
 	struct config_param *config;
 	u64 tmp;
 	struct buffAdd *ba;
-	unsigned long flags;
 	struct RxD_t *first_rxdp = NULL;
 	u64 Buffer0_ptr = 0, Buffer1_ptr = 0;
 	struct RxD1 *rxdp1;
@@ -2578,15 +2577,7 @@ static int fill_rx_buffers(struct s2io_n
 			DBG_PRINT(INTR_DBG, "%s: Next block at: %p\n",
 				  dev->name, rxdp);
 		}
-		if(!napi) {
-			spin_lock_irqsave(&nic->put_lock, flags);
-			mac_control->rings[ring_no].put_pos =
-			(block_no * (rxd_count[nic->rxd_mode] + 1)) + off;
-			spin_unlock_irqrestore(&nic->put_lock, flags);
-		} else {
-			mac_control->rings[ring_no].put_pos =
-			(block_no * (rxd_count[nic->rxd_mode] + 1)) + off;
-		}
+
 		if ((rxdp->Control_1 & RXD_OWN_XENA) &&
 			((nic->rxd_mode == RXD_MODE_3B) &&
 				(rxdp->Control_2 & s2BIT(0)))) {
@@ -2964,7 +2955,7 @@ static void rx_intr_handler(struct ring_
 {
 	struct s2io_nic *nic = ring_data->nic;
 	struct net_device *dev = (struct net_device *) nic->dev;
-	int get_block, put_block, put_offset;
+	int get_block, put_block;
 	struct rx_curr_get_info get_info, put_info;
 	struct RxD_t *rxdp;
 	struct sk_buff *skb;
@@ -2973,19 +2964,11 @@ static void rx_intr_handler(struct ring_
 	struct RxD1* rxdp1;
 	struct RxD3* rxdp3;
 
-	spin_lock(&nic->rx_lock);
-
 	get_info = ring_data->rx_curr_get_info;
 	get_block = get_info.block_index;
 	memcpy(&put_info, &ring_data->rx_curr_put_info, sizeof(put_info));
 	put_block = put_info.block_index;
 	rxdp = ring_data->rx_blocks[get_block].rxds[get_info.offset].virt_addr;
-	if (!napi) {
-		spin_lock(&nic->put_lock);
-		put_offset = ring_data->put_pos;
-		spin_unlock(&nic->put_lock);
-	} else
-		put_offset = ring_data->put_pos;
 
 	while (RXD_IS_UP2DT(rxdp)) {
 		/*
@@ -3002,7 +2985,6 @@ static void rx_intr_handler(struct ring_
 			DBG_PRINT(ERR_DBG, "%s: The skb is ",
 				  dev->name);
 			DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");
-			spin_unlock(&nic->rx_lock);
 			return;
 		}
 		if (nic->rxd_mode == RXD_MODE_1) {
@@ -3058,8 +3040,6 @@ static void rx_intr_handler(struct ring_
 			}
 		}
 	}
-
-	spin_unlock(&nic->rx_lock);
 }
 
 /**
@@ -7083,7 +7063,6 @@ static void do_s2io_card_down(struct s2i
 {
 	int cnt = 0;
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
-	unsigned long flags;
 	register u64 val64 = 0;
 	struct config_param *config;
 	config = &sp->config;
@@ -7142,9 +7121,7 @@ static void do_s2io_card_down(struct s2i
 	free_tx_buffers(sp);
 
 	/* Free all Rx buffers */
-	spin_lock_irqsave(&sp->rx_lock, flags);
 	free_rx_buffers(sp);
-	spin_unlock_irqrestore(&sp->rx_lock, flags);
 
 	clear_bit(__S2IO_STATE_LINK_TASK, &(sp->state));
 }
@@ -8044,10 +8021,6 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	for (i = 0; i < sp->config.tx_fifo_num; i++)
 		spin_lock_init(&mac_control->fifos[i].tx_lock);
 
-	if (!napi)
-		spin_lock_init(&sp->put_lock);
-	spin_lock_init(&sp->rx_lock);
-
 	/*
 	 * SXE-002: Configure link and activity LED to init state
 	 * on driver load.
diff -Nurp 2-0-26-21-1/drivers/net/s2io.h 2-0-26-21-2/drivers/net/s2io.h
--- 2-0-26-21-1/drivers/net/s2io.h	2008-04-09 21:07:06.000000000 +0530
+++ 2-0-26-21-2/drivers/net/s2io.h	2008-04-09 21:08:17.000000000 +0530
@@ -703,9 +703,6 @@ struct ring_info {
 	 */
 	struct rx_curr_get_info rx_curr_get_info;
 
-	/* Index to the absolute position of the put pointer of Rx ring */
-	int put_pos;
-
 	/* Buffer Address store. */
 	struct buffAdd **ba;
 	struct s2io_nic *nic;
@@ -877,8 +874,6 @@ struct s2io_nic {
 
 	atomic_t rx_bufs_left[MAX_RX_RINGS];
 
-	spinlock_t put_lock;
-
 #define PROMISC     1
 #define ALL_MULTI   2
 
@@ -962,7 +957,6 @@ struct s2io_nic {
 	u8		lro;
 	u16		lro_max_aggr_per_sess;
 	volatile unsigned long state;
-	spinlock_t	rx_lock;
 	u64		general_int_mask;
 #define VPD_STRING_LEN 80
 	u8  product_name[VPD_STRING_LEN];

