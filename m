From: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Subject: [PATCH 2.6.25 1/1]S2io: Multiqueue network device support implementation
Date: Tue, 22 Jan 2008 19:45:21 -0500 (EST)
Message-ID: <Pine.GSO.4.10.10801221942530.24414-100000@guinness>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: support@neterion.com
To: netdev@vger.kernel.org, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:34964 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755278AbYAWApc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 19:45:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Multiqueue netwrok device support implementation.
- Added a loadable parameter "multiq" to enable/disable multiqueue support,
  by default it is disabled.
- skb->queue_mapping is not used for queue/fifo selection. FIFO iselection is
  based on IP-TOS value, 0x0-0xF TOS values are mapped to 8 FIFOs.
- Added per FIFO flags FIFO_QUEUE_START and FIFO_QUEUE_STOP. Check this flag
  for starting and stopping netif queue and update the flags accordingly.
- In tx_intr_handler added a check to ensure that we have free TXDs before wak-
  ing up the queue.
- Added helper functions for queue manipulation(start/stop/wakeup) to invoke
  appropriate netif_ functions.
- Calling netif_start/stop for link up/down case respectively.

Signed-off-by: Surjit Reang <surjit.reang@neterion.com>
Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
---
diff -Nurp orig/drivers/net/s2io.c patch1/drivers/net/s2io.c
--- orig/drivers/net/s2io.c	2007-12-21 12:10:29.000000000 -0800
+++ patch1/drivers/net/s2io.c	2007-12-21 13:36:59.000000000 -0800
@@ -50,6 +50,8 @@
  *                 Possible values '1' for enable , '0' for disable.
  *                 Default is '2' - which means disable in promisc mode
  *                 and enable in non-promiscuous mode.
+ * multiq: This parameter used to enable/disable MULTIQUEUE support.          *
+ *      Possible values '1' for enable and '0' for disable. Default is '0'    *
  ************************************************************************/
 
 #include <linux/module.h>
@@ -84,7 +86,7 @@
 #include "s2io.h"
 #include "s2io-regs.h"
 
-#define DRV_VERSION "2.0.26.15-2"
+#define DRV_VERSION "2.0.26.16"
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "Neterion";
@@ -93,6 +95,12 @@ static char s2io_driver_version[] = DRV_
 static int rxd_size[2] = {32,48};
 static int rxd_count[2] = {127,85};
 
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+/* mapping from tos value to fifo number
+ * 0x0-0xF TOS values are mapped to 8 FIFOs */
+static int tos_map[] = {0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7};
+#endif
+
 static inline int RXD_IS_UP2DT(struct RxD_t *rxdp)
 {
 	int ret;
@@ -458,6 +466,7 @@ MODULE_VERSION(DRV_VERSION);
 /* Module Loadable parameters. */
 S2IO_PARM_INT(tx_fifo_num, 1);
 S2IO_PARM_INT(rx_ring_num, 1);
+S2IO_PARM_INT(multiq, 0);
 
 
 S2IO_PARM_INT(rx_ring_mode, 1);
@@ -533,6 +542,101 @@ static struct pci_driver s2io_driver = {
 /* A simplifier macro used both by init and free shared_mem Fns(). */
 #define TXD_MEM_PAGE_CNT(len, per_each) ((len+per_each - 1) / per_each)
 
+/* netqueue manipulation helper functions */
+static inline void s2io_stop_all_tx_queue(struct s2io_nic *sp)
+{
+	int i;
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	if (sp->config.multiq) {
+		for (i = 0; i < sp->config.tx_fifo_num; i++)
+			netif_stop_subqueue(sp->dev, i);
+	} else
+#endif
+	{
+		for (i = 0; i < sp->config.tx_fifo_num; i++)
+			sp->mac_control.fifos[i].queue_state = FIFO_QUEUE_STOP;
+		netif_stop_queue(sp->dev);
+	}
+}
+
+static inline void s2io_stop_tx_queue(struct s2io_nic *sp, int fifo_no)
+{
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	if (sp->config.multiq)
+		netif_stop_subqueue(sp->dev, fifo_no);
+	else
+#endif
+	{
+		sp->mac_control.fifos[fifo_no].queue_state =
+			FIFO_QUEUE_STOP;
+		netif_stop_queue(sp->dev);
+	}
+}
+
+static inline void s2io_start_all_tx_queue(struct s2io_nic *sp)
+{
+	int i;
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	if (sp->config.multiq) {
+		for (i = 0; i < sp->config.tx_fifo_num; i++)
+			netif_start_subqueue(sp->dev, i);
+	} else
+#endif
+	{
+		for (i = 0; i < sp->config.tx_fifo_num; i++)
+			sp->mac_control.fifos[i].queue_state = FIFO_QUEUE_START;
+		netif_start_queue(sp->dev);
+	}
+}
+
+static inline void s2io_start_tx_queue(struct s2io_nic *sp, int fifo_no)
+{
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	if (multiq)
+		netif_start_subqueue(sp->dev, fifo_no);
+	else
+#endif
+	{
+		sp->mac_control.fifos[fifo_no].queue_state =
+			FIFO_QUEUE_START;
+		netif_start_queue(sp->dev);
+	}
+}
+
+static inline void s2io_wake_all_tx_queue(struct s2io_nic *sp)
+{
+	int i;
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	if (sp->config.multiq) {
+			for (i = 0; i < sp->config.tx_fifo_num; i++)
+				netif_wake_subqueue(sp->dev, i);
+	} else
+#endif
+	{
+		for (i = 0; i < sp->config.tx_fifo_num; i++)
+			sp->mac_control.fifos[i].queue_state = FIFO_QUEUE_START;
+		netif_wake_queue(sp->dev);
+	}
+}
+
+static inline void s2io_wake_tx_queue(
+	struct fifo_info *fifo, int cnt, u8 multiq)
+{
+
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	if (multiq) {
+		if (cnt && __netif_subqueue_stopped(fifo->dev, fifo->fifo_no))
+			netif_wake_subqueue(fifo->dev, fifo->fifo_no);
+	} else
+#endif
+	if (cnt && (fifo->queue_state == FIFO_QUEUE_STOP)) {
+		if (netif_queue_stopped(fifo->dev)) {
+			fifo->queue_state = FIFO_QUEUE_START;
+			netif_wake_queue(fifo->dev);
+		}
+	}
+}
+
 /**
  * init_shared_mem - Allocation and Initialization of Memory
  * @nic: Device private variable.
@@ -614,6 +718,7 @@ static int init_shared_mem(struct s2io_n
 		mac_control->fifos[i].fifo_no = i;
 		mac_control->fifos[i].nic = nic;
 		mac_control->fifos[i].max_txds = MAX_SKB_FRAGS + 2;
+		mac_control->fifos[i].dev = dev;
 
 		for (j = 0; j < page_num; j++) {
 			int k = 0;
@@ -2975,10 +3080,10 @@ static void rx_intr_handler(struct ring_
 static void tx_intr_handler(struct fifo_info *fifo_data)
 {
 	struct s2io_nic *nic = fifo_data->nic;
-	struct net_device *dev = (struct net_device *) nic->dev;
 	struct tx_curr_get_info get_info, put_info;
-	struct sk_buff *skb;
+	struct sk_buff *skb = NULL;
 	struct TxD *txdlp;
+	int pkt_cnt = 0;
 	unsigned long flags = 0;
 	u8 err_mask;
 
@@ -3040,6 +3145,8 @@ static void tx_intr_handler(struct fifo_
 			return;
 		}
 
+		pkt_cnt++;
+
 		/* Updating the statistics block */
 		nic->stats.tx_bytes += skb->len;
 		nic->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
@@ -3054,8 +3161,7 @@ static void tx_intr_handler(struct fifo_
 		    get_info.offset;
 	}
 
-	if (netif_queue_stopped(dev))
-		netif_wake_queue(dev);
+	s2io_wake_tx_queue(fifo_data, pkt_cnt, nic->config.multiq);
 
 	spin_unlock_irqrestore(&fifo_data->tx_lock, flags);
 }
@@ -3939,7 +4045,7 @@ static int s2io_open(struct net_device *
 		goto hw_init_failed;
 	}
 
-	netif_start_queue(dev);
+	s2io_start_all_tx_queue(sp);
 	return 0;
 
 hw_init_failed:
@@ -3985,7 +4091,7 @@ static int s2io_close(struct net_device 
 	if (!is_s2io_card_up(sp))
 		return 0;
 
-	netif_stop_queue(dev);
+	s2io_stop_all_tx_queue(sp);
 
 	/* delete all populated mac entries */
 	for (offset = 1; offset < config->max_mc_addr; offset++) {
@@ -4055,9 +4161,34 @@ static int s2io_xmit(struct sk_buff *skb
 		vlan_priority = vlan_tag >> 13;
 		queue = config->fifo_mapping[vlan_priority];
 	}
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	else if (skb->protocol == htons(ETH_P_IP) && sp->config.multiq) {
+		struct iphdr *ip;
+		ip = ip_hdr(skb);
+
+		/* get fifo number based on TOS value */
+		queue = tos_map[IPTOS_TOS(ip->tos) >> 1];
+	}
+#endif
 
 	fifo = &mac_control->fifos[queue];
 	spin_lock_irqsave(&fifo->tx_lock, flags);
+
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	if (sp->config.multiq) {
+		if (__netif_subqueue_stopped(dev, fifo->fifo_no)) {
+			spin_unlock_irqrestore(&fifo->tx_lock, flags);
+			return NETDEV_TX_BUSY;
+		}
+	} else
+#endif
+	if (unlikely(fifo->queue_state == FIFO_QUEUE_STOP)) {
+		if (netif_queue_stopped(dev)) {
+			spin_unlock_irqrestore(&fifo->tx_lock, flags);
+			return NETDEV_TX_BUSY;
+		}
+	}
+
 	put_off = (u16) fifo->tx_curr_put_info.offset;
 	get_off = (u16) fifo->tx_curr_get_info.offset;
 	txdp = (struct TxD *) fifo->list_info[put_off].list_virt_addr;
@@ -4067,7 +4198,7 @@ static int s2io_xmit(struct sk_buff *skb
 	if (txdp->Host_Control ||
 		   ((put_off+1) == queue_len ? 0 : (put_off+1)) == get_off) {
 		DBG_PRINT(TX_DBG, "Error in xmit, No free TXDs.\n");
-		netif_stop_queue(dev);
+		s2io_stop_tx_queue(sp, fifo->fifo_no);
 		dev_kfree_skb(skb);
 		spin_unlock_irqrestore(&fifo->tx_lock, flags);
 		return 0;
@@ -4173,7 +4304,7 @@ static int s2io_xmit(struct sk_buff *skb
 		DBG_PRINT(TX_DBG,
 			  "No free TxDs for xmit, Put: 0x%x Get:0x%x\n",
 			  put_off, get_off);
-		netif_stop_queue(dev);
+		s2io_stop_tx_queue(sp, fifo->fifo_no);
 	}
 	mac_control->stats_info->sw_stat.mem_allocated += skb->truesize;
 	dev->trans_start = jiffies;
@@ -4182,7 +4313,7 @@ static int s2io_xmit(struct sk_buff *skb
 	return 0;
 pci_map_failed:
 	stats->pci_map_fail_cnt++;
-	netif_stop_queue(dev);
+	s2io_stop_tx_queue(sp, fifo->fifo_no);
 	stats->mem_freed += skb->truesize;
 	dev_kfree_skb(skb);
 	spin_unlock_irqrestore(&fifo->tx_lock, flags);
@@ -4594,7 +4725,7 @@ static void s2io_handle_errors(void * de
 	return;
 
 reset:
-	netif_stop_queue(dev);
+	s2io_stop_all_tx_queue(sp);
 	schedule_work(&sp->rst_timer_task);
 	sw_stat->soft_reset_cnt++;
 	return;
@@ -6581,16 +6712,16 @@ static int s2io_change_mtu(struct net_de
 
 	dev->mtu = new_mtu;
 	if (netif_running(dev)) {
+		s2io_stop_all_tx_queue(sp);
 		s2io_card_down(sp);
-		netif_stop_queue(dev);
+
 		ret = s2io_card_up(sp);
 		if (ret) {
 			DBG_PRINT(ERR_DBG, "%s: Device bring up failed\n",
 				  __FUNCTION__);
 			return ret;
 		}
-		if (netif_queue_stopped(dev))
-			netif_wake_queue(dev);
+		s2io_wake_all_tx_queue(sp);
 	} else { /* Device is down */
 		struct XENA_dev_config __iomem *bar0 = sp->bar0;
 		u64 val64 = new_mtu;
@@ -6698,7 +6829,7 @@ static void s2io_set_link(struct work_st
 			} else {
 				DBG_PRINT(ERR_DBG, "%s: Error: ", dev->name);
 				DBG_PRINT(ERR_DBG, "device is not Quiescent\n");
-				netif_stop_queue(dev);
+				s2io_stop_all_tx_queue(nic);
 			}
 		}
 		val64 = readq(&bar0->adapter_control);
@@ -7177,7 +7308,8 @@ static void s2io_restart_nic(struct work
 		DBG_PRINT(ERR_DBG, "%s: Device bring up failed\n",
 			  dev->name);
 	}
-	netif_wake_queue(dev);
+	s2io_wake_all_tx_queue(sp);
+
 	DBG_PRINT(ERR_DBG, "%s: was reset by Tx watchdog timer\n",
 		  dev->name);
 out_unlock:
@@ -7456,6 +7588,7 @@ static void s2io_link(struct s2io_nic * 
 		init_tti(sp, link);
 		if (link == LINK_DOWN) {
 			DBG_PRINT(ERR_DBG, "%s: Link down\n", dev->name);
+			s2io_stop_all_tx_queue(sp);
 			netif_carrier_off(dev);
 			if(sp->mac_control.stats_info->sw_stat.link_up_cnt)
 			sp->mac_control.stats_info->sw_stat.link_up_time =
@@ -7468,6 +7601,7 @@ static void s2io_link(struct s2io_nic * 
 				jiffies - sp->start_time;
 			sp->mac_control.stats_info->sw_stat.link_up_cnt++;
 			netif_carrier_on(dev);
+			s2io_wake_all_tx_queue(sp);
 		}
 	}
 	sp->last_link_state = link;
@@ -7504,7 +7638,8 @@ static void s2io_init_pci(struct s2io_ni
 	pci_read_config_word(sp->pdev, PCI_COMMAND, &pci_cmd);
 }
 
-static int s2io_verify_parm(struct pci_dev *pdev, u8 *dev_intr_type)
+static int s2io_verify_parm(struct pci_dev *pdev, u8 *dev_intr_type,
+	u8 *dev_multiq)
 {
 	if ((tx_fifo_num > MAX_TX_FIFOS) ||
 		(tx_fifo_num < FIFO_DEFAULT_NUM)) {
@@ -7518,6 +7653,19 @@ static int s2io_verify_parm(struct pci_d
 		DBG_PRINT(ERR_DBG, "tx fifos\n");
 	}
 
+#ifndef CONFIG_NETDEVICES_MULTIQUEUE
+	if (multiq) {
+		DBG_PRINT(ERR_DBG, "s2io: Multiqueue support not enabled\n");
+		multiq = 0;
+	}
+#endif
+
+	/* if multiqueue is enabled configure all fifos	*/
+	if (multiq) {
+		tx_fifo_num = MAX_TX_FIFOS;
+		*dev_multiq = multiq;
+	}
+
 	if ( rx_ring_num > 8) {
 		DBG_PRINT(ERR_DBG, "s2io: Requested number of Rx rings not "
 			 "supported\n");
@@ -7609,9 +7757,11 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	struct config_param *config;
 	int mode;
 	u8 dev_intr_type = intr_type;
+	u8 dev_multiq = 0;
 	DECLARE_MAC_BUF(mac);
 
-	if ((ret = s2io_verify_parm(pdev, &dev_intr_type)))
+	ret = s2io_verify_parm(pdev, &dev_intr_type, &dev_multiq);
+	if (ret)
 		return ret;
 
 	if ((ret = pci_enable_device(pdev))) {
@@ -7643,7 +7793,13 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		return -ENODEV;
 	}
 
-	dev = alloc_etherdev(sizeof(struct s2io_nic));
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	if (dev_multiq)
+		dev = alloc_etherdev_mq(sizeof(struct s2io_nic), MAX_TX_FIFOS);
+	else
+#endif
+		dev = alloc_etherdev(sizeof(struct s2io_nic));
+
 	if (dev == NULL) {
 		DBG_PRINT(ERR_DBG, "Device allocation failed\n");
 		pci_disable_device(pdev);
@@ -7694,6 +7850,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 
 	/* Tx side parameters. */
 	config->tx_fifo_num = tx_fifo_num;
+	config->multiq = dev_multiq;
 	for (i = 0; i < MAX_TX_FIFOS; i++) {
 		config->tx_cfg[i].fifo_len = tx_fifo_len[i];
 		config->tx_cfg[i].fifo_priority = i;
@@ -7807,6 +7964,11 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		dev->features |= NETIF_F_HW_CSUM;
 	}
 
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	if (config->multiq)
+		dev->features |= NETIF_F_MULTI_QUEUE;
+#endif
+
 	dev->tx_timeout = &s2io_tx_watchdog;
 	dev->watchdog_timeo = WATCH_DOG_TIMEOUT;
 	INIT_WORK(&sp->rst_timer_task, s2io_restart_nic);
@@ -7963,6 +8125,16 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		    DBG_PRINT(ERR_DBG, "%s: Interrupt type MSI-X\n", dev->name);
 		    break;
 	}
+
+	if (sp->config.multiq) {
+		for (i = 0; i < sp->config.tx_fifo_num; i++)
+			mac_control->fifos[i].multiq = config->multiq;
+		DBG_PRINT(ERR_DBG, "%s: Multiqueue support enabled\n",
+			dev->name);
+	} else
+		DBG_PRINT(ERR_DBG, "%s: Multiqueue support disabled\n",
+			dev->name);
+
 	if (sp->lro)
 		DBG_PRINT(ERR_DBG, "%s: Large receive offload enabled\n",
 			  dev->name);
diff -Nurp orig/drivers/net/s2io.h patch1/drivers/net/s2io.h
--- orig/drivers/net/s2io.h	2007-12-21 12:10:29.000000000 -0800
+++ patch1/drivers/net/s2io.h	2007-12-21 13:36:28.000000000 -0800
@@ -464,6 +464,7 @@ struct config_param {
 	int max_mc_addr;	/* xena=64 herc=256 */
 	int max_mac_addr;	/* xena=16 herc=64 */
 	int mc_start_offset;	/* xena=16 herc=64 */
+	u8 multiq;
 };
 
 /* Structure representing MAC Addrs */
@@ -721,6 +722,17 @@ struct fifo_info {
 	 */
 	struct tx_curr_get_info tx_curr_get_info;
 
+
+#define FIFO_QUEUE_START 0
+#define FIFO_QUEUE_STOP 1
+	int queue_state;
+
+	/* copy of sp->dev pointer */
+	struct net_device *dev;
+
+	/* copy of multiq status */
+	u8 multiq;
+
 	/* Per fifo lock */
 	spinlock_t tx_lock;
 
@@ -756,7 +768,7 @@ struct mac_info {
 	dma_addr_t stats_mem_phy;	/* Physical address of the stat block */
 	u32 stats_mem_sz;
 	struct stat_block *stats_info;	/* Logical address of the stat block */
-};
+} ____cacheline_aligned;
 
 /* structure representing the user defined MAC addresses */
 struct usr_addr {

