From: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Subject: [PATCH 2.6.24 4/5]S2io: Check for device state before handling
 traffic
Date: Thu, 6 Sep 2007 06:51:14 -0400 (EDT)
Message-ID: <Pine.GSO.4.10.10709060646150.19944-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:36866 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754129AbXIFKvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2007 06:51:16 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

- Added check to return from the traffic handling function, if the card status
  is DOWN.
- Implemented Jeff's comments on incorrect return value in s2io_poll function.

Signed-off-by: Sivakumar Subramani <sivakumar.subramani@neterion.com>
Signed-off-by: Santosh Rastapur <santosh.rastapur@neterion.com>
Signed-off-by: Ramkrishna Vepa <ram.vepa@neterion.com>
---
diff -urpN patch_3/drivers/net/s2io.c patch_4/drivers/net/s2io.c
--- patch_3/drivers/net/s2io.c	2007-09-05 13:50:34.000000000 +0530
+++ patch_4/drivers/net/s2io.c	2007-09-05 14:11:17.000000000 +0530
@@ -130,6 +130,11 @@ static inline int rx_buffer_level(struct
 	return 0;
 }
 
+static inline int is_s2io_card_up(const struct s2io_nic * sp)
+{
+	return test_bit(__S2IO_STATE_CARD_UP, &sp->state);
+}
+
 /* Ethtool related variables and Macros. */
 static char s2io_gstrings[][ETH_GSTRING_LEN] = {
 	"Register test\t(offline)",
@@ -2710,6 +2715,12 @@ static int s2io_poll(struct net_device *
 	int i;
 
 	atomic_inc(&nic->isr_cnt);
+
+	if (!is_s2io_card_up(nic)) {
+		atomic_dec(&nic->isr_cnt);
+		return 0;
+	}
+
 	mac_control = &nic->mac_control;
 	config = &nic->config;
 
@@ -2845,12 +2856,6 @@ static void rx_intr_handler(struct ring_
 	struct RxD3* rxdp3;
 
 	spin_lock(&nic->rx_lock);
-	if (atomic_read(&nic->card_state) == CARD_DOWN) {
-		DBG_PRINT(INTR_DBG, "%s: %s going down for reset\n",
-			  __FUNCTION__, dev->name);
-		spin_unlock(&nic->rx_lock);
-		return;
-	}
 
 	get_info = ring_data->rx_curr_get_info;
 	get_block = get_info.block_index;
@@ -3994,7 +3999,7 @@ static int s2io_xmit(struct sk_buff *skb
 }
 
 	spin_lock_irqsave(&sp->tx_lock, flags);
-	if (atomic_read(&sp->card_state) == CARD_DOWN) {
+	if (!is_s2io_card_up(sp)) {
 		DBG_PRINT(TX_DBG, "%s: Card going down for reset\n",
 			  dev->name);
 		spin_unlock_irqrestore(&sp->tx_lock, flags);
@@ -4188,6 +4193,11 @@ static irqreturn_t s2io_msix_ring_handle
 
 	atomic_inc(&sp->isr_cnt);
 
+	if (!is_s2io_card_up(sp)) {
+		atomic_dec(&sp->isr_cnt);
+		return IRQ_HANDLED;
+	}
+
 	rx_intr_handler(ring);
 	s2io_chk_rx_buffers(sp, ring->ring_no);
 
@@ -4201,6 +4211,12 @@ static irqreturn_t s2io_msix_fifo_handle
 	struct s2io_nic *sp = fifo->nic;
 
 	atomic_inc(&sp->isr_cnt);
+
+	if (!is_s2io_card_up(sp)) {
+		atomic_dec(&sp->isr_cnt);
+		return IRQ_HANDLED;
+	}
+
 	tx_intr_handler(fifo);
 	atomic_dec(&sp->isr_cnt);
 	return IRQ_HANDLED;
@@ -4308,7 +4324,7 @@ static void s2io_handle_errors(void * de
 	struct swStat *sw_stat = &sp->mac_control.stats_info->sw_stat;
 	struct xpakStat *stats = &sp->mac_control.stats_info->xpak_stat;
 
-	if (unlikely(atomic_read(&sp->card_state) == CARD_DOWN))
+	if (!is_s2io_card_up(sp))
 		return;
 
 	if (pci_channel_offline(sp->pdev))
@@ -4579,6 +4595,12 @@ static irqreturn_t s2io_isr(int irq, voi
 		return IRQ_NONE;
 
 	atomic_inc(&sp->isr_cnt);
+
+	if (!is_s2io_card_up(sp)) {
+		atomic_dec(&sp->isr_cnt);
+		return IRQ_NONE;
+	}
+
 	mac_control = &sp->mac_control;
 	config = &sp->config;
 
@@ -4667,7 +4689,7 @@ static void s2io_updt_stats(struct s2io_
 	u64 val64;
 	int cnt = 0;
 
-	if (atomic_read(&sp->card_state) == CARD_UP) {
+	if (is_s2io_card_up(sp)) {
 		/* Apprx 30us on a 133 MHz bus */
 		val64 = SET_UPDT_CLICKS(10) |
 			STAT_CFG_ONE_SHOT_EN | STAT_CFG_STAT_EN;
@@ -6463,7 +6485,7 @@ static void s2io_set_link(struct work_st
 	if (!netif_running(dev))
 		goto out_unlock;
 
-	if (test_and_set_bit(0, &(nic->link_state))) {
+	if (test_and_set_bit(__S2IO_STATE_LINK_TASK, &(nic->state))) {
 		/* The card is being reset, no point doing anything */
 		goto out_unlock;
 	}
@@ -6519,7 +6541,7 @@ static void s2io_set_link(struct work_st
 		writeq(val64, &bar0->adapter_control);
 		s2io_link(nic, LINK_DOWN);
 	}
-	clear_bit(0, &(nic->link_state));
+	clear_bit(__S2IO_STATE_LINK_TASK, &(nic->state));
 
 out_unlock:
 	rtnl_unlock();
@@ -6828,10 +6850,10 @@ static void do_s2io_card_down(struct s2i
 
 	del_timer_sync(&sp->alarm_timer);
 	/* If s2io_set_link task is executing, wait till it completes. */
-	while (test_and_set_bit(0, &(sp->link_state))) {
+	while (test_and_set_bit(__S2IO_STATE_LINK_TASK, &(sp->state))) {
 		msleep(50);
 	}
-	atomic_set(&sp->card_state, CARD_DOWN);
+	clear_bit(__S2IO_STATE_CARD_UP, &sp->state);
 
 	/* disable Tx and Rx traffic on the NIC */
 	if (do_io)
@@ -6882,7 +6904,7 @@ static void do_s2io_card_down(struct s2i
 	free_rx_buffers(sp);
 	spin_unlock_irqrestore(&sp->rx_lock, flags);
 
-	clear_bit(0, &(sp->link_state));
+	clear_bit(__S2IO_STATE_LINK_TASK, &(sp->state));
 }
 
 static void s2io_card_down(struct s2io_nic * sp)
@@ -6975,8 +6997,7 @@ static int s2io_card_up(struct s2io_nic 
 		en_dis_able_nic_intrs(sp, interruptible, ENABLE_INTRS);
 	}
 
-
-	atomic_set(&sp->card_state, CARD_UP);
+	set_bit(__S2IO_STATE_CARD_UP, &sp->state);
 	return 0;
 }
 
@@ -7705,9 +7726,8 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	 * Initialize the tasklet status and link state flags
 	 * and the card state parameter
 	 */
-	atomic_set(&(sp->card_state), 0);
 	sp->tasklet_status = 0;
-	sp->link_state = 0;
+	sp->state = 0;
 
 	/* Initialize spinlocks */
 	spin_lock_init(&sp->tx_lock);
diff -urpN patch_3/drivers/net/s2io.h patch_4/drivers/net/s2io.h
--- patch_3/drivers/net/s2io.h	2007-09-05 13:50:37.000000000 +0530
+++ patch_4/drivers/net/s2io.h	2007-09-05 14:07:16.000000000 +0530
@@ -802,6 +802,13 @@ struct lro {
 	u8		saw_ts;
 };
 
+/* These flags represent the devices temporary state */
+enum s2io_device_state_t
+{
+	__S2IO_STATE_LINK_TASK=0,
+	__S2IO_STATE_CARD_UP
+};
+
 /* Structure representing one instance of the NIC */
 struct s2io_nic {
 	int rxd_mode;
@@ -879,10 +886,6 @@ struct s2io_nic {
 
 	int task_flag;
 	unsigned long long start_time;
-#define CARD_DOWN 1
-#define CARD_UP 2
-	atomic_t card_state;
-	volatile unsigned long link_state;
 	struct vlan_group *vlgrp;
 #define MSIX_FLG                0xA5
 	struct msix_entry *entries;
@@ -905,6 +908,7 @@ struct s2io_nic {
 	unsigned long	sending_both;
 	u8		lro;
 	u16		lro_max_aggr_per_sess;
+	volatile unsigned long state;
 	spinlock_t	rx_lock;
 	atomic_t	isr_cnt;
 	u64		general_int_mask;

