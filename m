From: raghavendra.koushik@neterion.com
Subject: [PATCH 2.6.12.1 5/12] S2io: Performance improvements
Date: Thu,  7 Jul 2005 15:27:41 -0700 (PDT)
Message-ID: <20050707222741.71C3E89826@linux.site>
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
This patch relates to mostly performance related changes.
1. Fixed incorrect computation of PANIC level in rx_buffer_level().
2. Removed unnecessary PIOs(read/write of tx_traffic_int and 
   rx_traffic_int) from interrupt handler and removed read of
   general_int_status register from xmit routine.			    
3. Enable two-buffer mode(for Rx path) automatically for SGI
   systems. This improves Rx performance dramatically on 
   SGI systems.

Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
Signed-off-by: Raghavendra Koushik <raghavendra.koushik@neterion.com>
---
diff -uprN vanilla_kernel/drivers/net/s2io.c linux-2.6.12-rc6/drivers/net/s2io.c
--- vanilla_kernel/drivers/net/s2io.c	2005-06-28 02:00:08.000000000 -0700
+++ linux-2.6.12-rc6/drivers/net/s2io.c	2005-06-28 02:00:18.000000000 -0700
@@ -99,8 +99,7 @@ static inline int rx_buffer_level(nic_t 
 	mac_control = &sp->mac_control;
 	if ((mac_control->rings[ring].pkt_cnt - rxb_size) > 16) {
 		level = LOW;
-		if ((mac_control->rings[ring].pkt_cnt - rxb_size) <
-				MAX_RXDS_PER_BLOCK) {
+		if (rxb_size <= MAX_RXDS_PER_BLOCK) {
 			level = PANIC;
 		}
 	}
@@ -2194,7 +2193,6 @@ static void rx_intr_handler(ring_info_t 
 {
 	nic_t *nic = ring_data->nic;
 	struct net_device *dev = (struct net_device *) nic->dev;
-	XENA_dev_config_t __iomem *bar0 = nic->bar0;
 	int get_block, get_offset, put_block, put_offset, ring_bufs;
 	rx_curr_get_info_t get_info, put_info;
 	RxD_t *rxdp;
@@ -2202,8 +2200,6 @@ static void rx_intr_handler(ring_info_t 
 #ifndef CONFIG_S2IO_NAPI
 	int pkt_cnt = 0;
 #endif
-	register u64 val64;
-
 	spin_lock(&nic->rx_lock);
 	if (atomic_read(&nic->card_state) == CARD_DOWN) {
 		DBG_PRINT(ERR_DBG, "%s: %s going down for reset\n",
@@ -2211,13 +2207,6 @@ static void rx_intr_handler(ring_info_t 
 		spin_unlock(&nic->rx_lock);
 	}
 
-	/*
-	 * rx_traffic_int reg is an R1 register, hence we read and write
-	 * back the same value in the register to clear it
-	 */
-	val64 = readq(&bar0->tx_traffic_int);
-	writeq(val64, &bar0->tx_traffic_int);
-
 	get_info = ring_data->rx_curr_get_info;
 	get_block = get_info.block_index;
 	put_info = ring_data->rx_curr_put_info;
@@ -2313,20 +2302,11 @@ static void rx_intr_handler(ring_info_t 
 static void tx_intr_handler(fifo_info_t *fifo_data)
 {
 	nic_t *nic = fifo_data->nic;
-	XENA_dev_config_t __iomem *bar0 = nic->bar0;
 	struct net_device *dev = (struct net_device *) nic->dev;
 	tx_curr_get_info_t get_info, put_info;
 	struct sk_buff *skb;
 	TxD_t *txdlp;
 	u16 j, frg_cnt;
-	register u64 val64 = 0;
-
-	/*
-	 * tx_traffic_int reg is an R1 register, hence we read and write
-	 * back the same value in the register to clear it
-	 */
-	val64 = readq(&bar0->tx_traffic_int);
-	writeq(val64, &bar0->tx_traffic_int);
 
 	get_info = fifo_data->tx_curr_get_info;
 	put_info = fifo_data->tx_curr_put_info;
@@ -2819,7 +2799,6 @@ int s2io_xmit(struct sk_buff *skb, struc
 #endif
 	mac_info_t *mac_control;
 	struct config_param *config;
-	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 
 	mac_control = &sp->mac_control;
 	config = &sp->config;
@@ -2871,7 +2850,6 @@ int s2io_xmit(struct sk_buff *skb, struc
 	}
 
 	txdp->Control_2 |= config->tx_intr_type;
-
 	txdp->Control_1 |= (TXD_BUFFER0_SIZE(frg_len) |
 			    TXD_GATHER_CODE_FIRST);
 	txdp->Control_1 |= TXD_LIST_OWN_XENA;
@@ -2891,6 +2869,8 @@ int s2io_xmit(struct sk_buff *skb, struc
 	val64 = mac_control->fifos[queue].list_info[put_off].list_phy_addr;
 	writeq(val64, &tx_fifo->TxDL_Pointer);
 
+	wmb();
+
 	val64 = (TX_FIFO_LAST_TXD_NUM(frg_cnt) | TX_FIFO_FIRST_LIST |
 		 TX_FIFO_LAST_LIST);
 
@@ -2900,9 +2880,6 @@ int s2io_xmit(struct sk_buff *skb, struc
 #endif
 	writeq(val64, &tx_fifo->List_Control);
 
-	/* Perform a PCI read to flush previous writes */
-	val64 = readq(&bar0->general_int_status);
-
 	put_off++;
 	put_off %= mac_control->fifos[queue].tx_curr_put_info.fifo_len + 1;
 	mac_control->fifos[queue].tx_curr_put_info.offset = put_off;
@@ -2941,7 +2918,7 @@ static irqreturn_t s2io_isr(int irq, voi
 	nic_t *sp = dev->priv;
 	XENA_dev_config_t __iomem *bar0 = sp->bar0;
 	int i;
-	u64 reason = 0;
+	u64 reason = 0, val64;
 	mac_info_t *mac_control;
 	struct config_param *config;
 
@@ -2979,6 +2956,13 @@ static irqreturn_t s2io_isr(int irq, voi
 #else
 	/* If Intr is because of Rx Traffic */
 	if (reason & GEN_INTR_RXTRAFFIC) {
+		/*
+		 * rx_traffic_int reg is an R1 register, writing all 1's
+		 * will ensure that the actual interrupt causing bit get's
+		 * cleared and hence a read can be avoided.
+		 */
+		val64 = 0xFFFFFFFFFFFFFFFFULL;
+		writeq(val64, &bar0->rx_traffic_int);
 		for (i = 0; i < config->rx_ring_num; i++) {
 			rx_intr_handler(&mac_control->rings[i]);
 		}
@@ -2987,6 +2971,14 @@ static irqreturn_t s2io_isr(int irq, voi
 
 	/* If Intr is because of Tx Traffic */
 	if (reason & GEN_INTR_TXTRAFFIC) {
+		/*
+		 * tx_traffic_int reg is an R1 register, writing all 1's
+		 * will ensure that the actual interrupt causing bit get's
+		 * cleared and hence a read can be avoided.
+		 */
+		val64 = 0xFFFFFFFFFFFFFFFFULL;
+		writeq(val64, &bar0->tx_traffic_int);
+
 		for (i = 0; i < config->tx_fifo_num; i++)
 			tx_intr_handler(&mac_control->fifos[i]);
 	}
diff -uprN vanilla_kernel/drivers/net/s2io.h linux-2.6.12-rc6/drivers/net/s2io.h
--- vanilla_kernel/drivers/net/s2io.h	2005-06-28 02:00:08.000000000 -0700
+++ linux-2.6.12-rc6/drivers/net/s2io.h	2005-06-28 02:00:18.000000000 -0700
@@ -13,6 +13,11 @@
 #ifndef _S2IO_H
 #define _S2IO_H
 
+/* Enable 2 buffer mode by default for SGI system */
+#ifdef CONFIG_IA64_SGI_SN2
+#define CONFIG_2BUFF_MODE
+#endif
+
 #define TBD 0
 #define BIT(loc)		(0x8000000000000000ULL >> (loc))
 #define vBIT(val, loc, sz)	(((u64)val) << (64-loc-sz))
