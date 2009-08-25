From: Joe Perches <joe@perches.com>
Subject: [PATCH 8/9] s2io.c: Standardize statistics accessors
Date: Mon, 24 Aug 2009 20:29:47 -0700
Message-ID: <baf19313af3115591acac29852fbe1efeea02224.1251170438.git.joe@perches.com>
References: <cover.1251170438.git.joe@perches.com>
Cc: Anil Murthy <anil.murthy@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Ramkrishna Vepa <ram.vepa@neterion.com>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-next@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <cover.1251170438.git.joe@perches.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Regularize the declaration and uses of
	struct config_param *config = &sp->config;
	struct mac_info *mac_control = &sp->mac_control;
and use
	struct stat_block *stats = mac_control->stats_info;
	struct swStat *swstats = &stats->sw_stat;
	struct xpakStat *xstats = &stats->xpak_stat;
and convert the longish uses like
	nic->mac_control.stats_info->sw_stat.<foo>
to
	swstats-><foo>
etc.

This also makes the statistics code marginally smaller
and presumably faster.

Old:
$ size s2io.o
   text	   data	    bss	    dec	    hex	filename
 114289	    516	  33360	 148165	  242c5	s2io.o
New:
$ size s2io.o
   text	   data	    bss	    dec	    hex	filename
 114097	    516	  33360	 147973	  24205	s2io.o

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/s2io.c |  851 +++++++++++++++++++++++++---------------------------
 1 files changed, 408 insertions(+), 443 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 4897f04..06223df 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -363,8 +363,8 @@ static void s2io_vlan_rx_register(struct net_device *dev,
 	int i;
 	struct s2io_nic *nic = netdev_priv(dev);
 	unsigned long flags[MAX_TX_FIFOS];
-	struct mac_info *mac_control = &nic->mac_control;
 	struct config_param *config = &nic->config;
+	struct mac_info *mac_control = &nic->mac_control;
 
 	for (i = 0; i < config->tx_fifo_num; i++) {
 		struct fifo_info *fifo = &mac_control->fifos[i];
@@ -387,8 +387,8 @@ static void s2io_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 	int i;
 	struct s2io_nic *nic = netdev_priv(dev);
 	unsigned long flags[MAX_TX_FIFOS];
-	struct mac_info *mac_control = &nic->mac_control;
 	struct config_param *config = &nic->config;
+	struct mac_info *mac_control = &nic->mac_control;
 
 	for (i = 0; i < config->tx_fifo_num; i++) {
 		struct fifo_info *fifo = &mac_control->fifos[i];
@@ -640,14 +640,10 @@ static int init_shared_mem(struct s2io_nic *nic)
 	struct net_device *dev = nic->dev;
 	unsigned long tmp;
 	struct buffAdd *ba;
-
-	struct mac_info *mac_control;
-	struct config_param *config;
+	struct config_param *config = &nic->config;
+	struct mac_info *mac_control = &nic->mac_control;
 	unsigned long long mem_allocated = 0;
 
-	mac_control = &nic->mac_control;
-	config = &nic->config;
-
 	/* Allocation and initialization of TXDLs in FIFOs */
 	size = 0;
 	for (i = 0; i < config->tx_fifo_num; i++) {
@@ -949,19 +945,23 @@ static void free_shared_mem(struct s2io_nic *nic)
 	int i, j, blk_cnt, size;
 	void *tmp_v_addr;
 	dma_addr_t tmp_p_addr;
-	struct mac_info *mac_control;
-	struct config_param *config;
 	int lst_size, lst_per_page;
 	struct net_device *dev;
 	int page_num = 0;
+	struct config_param *config;
+	struct mac_info *mac_control;
+	struct stat_block *stats;
+	struct swStat *swstats;
 
 	if (!nic)
 		return;
 
 	dev = nic->dev;
 
-	mac_control = &nic->mac_control;
 	config = &nic->config;
+	mac_control = &nic->mac_control;
+	stats = mac_control->stats_info;
+	swstats = &stats->sw_stat;
 
 	lst_size = sizeof(struct TxD) * config->max_txds;
 	lst_per_page = PAGE_SIZE / lst_size;
@@ -984,8 +984,7 @@ static void free_shared_mem(struct s2io_nic *nic)
 			pci_free_consistent(nic->pdev, PAGE_SIZE,
 					    fli->list_virt_addr,
 					    fli->list_phy_addr);
-			nic->mac_control.stats_info->sw_stat.mem_freed
-				+= PAGE_SIZE;
+			swstats->mem_freed += PAGE_SIZE;
 		}
 		/* If we got a zero DMA address during allocation,
 		 * free the page now
@@ -999,12 +998,10 @@ static void free_shared_mem(struct s2io_nic *nic)
 				  dev->name);
 			DBG_PRINT(INIT_DBG, "Virtual address %p\n",
 				  mac_control->zerodma_virt_addr);
-			nic->mac_control.stats_info->sw_stat.mem_freed
-				+= PAGE_SIZE;
+			swstats->mem_freed += PAGE_SIZE;
 		}
 		kfree(fifo->list_info);
-		nic->mac_control.stats_info->sw_stat.mem_freed +=
-			nic->config.tx_cfg[i].fifo_len *
+		swstats->mem_freed += nic->config.tx_cfg[i].fifo_len *
 			sizeof(struct list_info_hold);
 	}
 
@@ -1020,10 +1017,10 @@ static void free_shared_mem(struct s2io_nic *nic)
 				break;
 			pci_free_consistent(nic->pdev, size,
 					    tmp_v_addr, tmp_p_addr);
-			nic->mac_control.stats_info->sw_stat.mem_freed += size;
+			swstats->mem_freed += size;
 			kfree(ring->rx_blocks[j].rxds);
-			nic->mac_control.stats_info->sw_stat.mem_freed +=
-				sizeof(struct rxd_info) * rxd_count[nic->rxd_mode];
+			swstats->mem_freed += sizeof(struct rxd_info) *
+				rxd_count[nic->rxd_mode];
 		}
 	}
 
@@ -1042,21 +1039,20 @@ static void free_shared_mem(struct s2io_nic *nic)
 				while (k != rxd_count[nic->rxd_mode]) {
 					struct buffAdd *ba = &ring->ba[j][k];
 					kfree(ba->ba_0_org);
-					nic->mac_control.stats_info->sw_stat.\
-						mem_freed += (BUF0_LEN + ALIGN_SIZE);
+					swstats->mem_freed +=
+						BUF0_LEN + ALIGN_SIZE;
 					kfree(ba->ba_1_org);
-					nic->mac_control.stats_info->sw_stat.\
-						mem_freed += (BUF1_LEN + ALIGN_SIZE);
+					swstats->mem_freed +=
+						BUF1_LEN + ALIGN_SIZE;
 					k++;
 				}
 				kfree(ring->ba[j]);
-				nic->mac_control.stats_info->sw_stat.mem_freed +=
-					(sizeof(struct buffAdd) *
-					 (rxd_count[nic->rxd_mode] + 1));
+				swstats->mem_freed += sizeof(struct buffAdd) *
+					(rxd_count[nic->rxd_mode] + 1);
 			}
 			kfree(ring->ba);
-			nic->mac_control.stats_info->sw_stat.mem_freed +=
-				(sizeof(struct buffAdd *) * blk_cnt);
+			swstats->mem_freed += sizeof(struct buffAdd *) *
+				blk_cnt;
 		}
 	}
 
@@ -1065,15 +1061,14 @@ static void free_shared_mem(struct s2io_nic *nic)
 		struct tx_fifo_config *tx_cfg = &config->tx_cfg[i];
 
 		if (fifo->ufo_in_band_v) {
-			nic->mac_control.stats_info->sw_stat.mem_freed
-				+= (tx_cfg->fifo_len * sizeof(u64));
+			swstats->mem_freed += tx_cfg->fifo_len *
+				sizeof(u64);
 			kfree(fifo->ufo_in_band_v);
 		}
 	}
 
 	if (mac_control->stats_mem) {
-		nic->mac_control.stats_info->sw_stat.mem_freed +=
-			mac_control->stats_mem_sz;
+		swstats->mem_freed += mac_control->stats_mem_sz;
 		pci_free_consistent(nic->pdev,
 				    mac_control->stats_mem_sz,
 				    mac_control->stats_mem,
@@ -1190,9 +1185,7 @@ static int init_tti(struct s2io_nic *nic, int link)
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
 	register u64 val64 = 0;
 	int i;
-	struct config_param *config;
-
-	config = &nic->config;
+	struct config_param *config = &nic->config;
 
 	for (i = 0; i < config->tx_fifo_num; i++) {
 		/*
@@ -1271,14 +1264,11 @@ static int init_nic(struct s2io_nic *nic)
 	void __iomem *add;
 	u32 time;
 	int i, j;
-	struct mac_info *mac_control;
-	struct config_param *config;
 	int dtx_cnt = 0;
 	unsigned long long mem_share;
 	int mem_size;
-
-	mac_control = &nic->mac_control;
-	config = &nic->config;
+	struct config_param *config = &nic->config;
+	struct mac_info *mac_control = &nic->mac_control;
 
 	/* to set the swapper controle on the card */
 	if (s2io_set_swapper(nic)) {
@@ -2290,11 +2280,8 @@ static int start_nic(struct s2io_nic *nic)
 	struct net_device *dev = nic->dev;
 	register u64 val64 = 0;
 	u16 subid, i;
-	struct mac_info *mac_control;
-	struct config_param *config;
-
-	mac_control = &nic->mac_control;
-	config = &nic->config;
+	struct config_param *config = &nic->config;
+	struct mac_info *mac_control = &nic->mac_control;
 
 	/*  PRC Initialization and configuration */
 	for (i = 0; i < config->rx_ring_num; i++) {
@@ -2446,12 +2433,11 @@ static void free_tx_buffers(struct s2io_nic *nic)
 	struct sk_buff *skb;
 	struct TxD *txdp;
 	int i, j;
-	struct mac_info *mac_control;
-	struct config_param *config;
 	int cnt = 0;
-
-	mac_control = &nic->mac_control;
-	config = &nic->config;
+	struct config_param *config = &nic->config;
+	struct mac_info *mac_control = &nic->mac_control;
+	struct stat_block *stats = mac_control->stats_info;
+	struct swStat *swstats = &stats->sw_stat;
 
 	for (i = 0; i < config->tx_fifo_num; i++) {
 		struct tx_fifo_config *tx_cfg = &config->tx_cfg[i];
@@ -2463,8 +2449,7 @@ static void free_tx_buffers(struct s2io_nic *nic)
 			txdp = (struct TxD *)fifo->list_info[j].list_virt_addr;
 			skb = s2io_txdl_getskb(&mac_control->fifos[i], txdp, j);
 			if (skb) {
-				nic->mac_control.stats_info->sw_stat.mem_freed
-					+= skb->truesize;
+				swstats->mem_freed += skb->truesize;
 				dev_kfree_skb(skb);
 				cnt++;
 			}
@@ -2493,11 +2478,6 @@ static void stop_nic(struct s2io_nic *nic)
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
 	register u64 val64 = 0;
 	u16 interruptible;
-	struct mac_info *mac_control;
-	struct config_param *config;
-
-	mac_control = &nic->mac_control;
-	config = &nic->config;
 
 	/*  Disable all interrupts */
 	en_dis_err_alarms(nic, ENA_ALL_INTRS, DISABLE_INTRS);
@@ -2548,7 +2528,7 @@ static int fill_rx_buffers(struct s2io_nic *nic, struct ring_info *ring,
 	int rxd_index = 0;
 	struct RxD1 *rxdp1;
 	struct RxD3 *rxdp3;
-	struct swStat *stats = &ring->nic->mac_control.stats_info->sw_stat;
+	struct swStat *swstats = &ring->nic->mac_control.stats_info->sw_stat;
 
 	alloc_cnt = ring->pkt_cnt - ring->rx_bufs_left;
 
@@ -2609,11 +2589,11 @@ static int fill_rx_buffers(struct s2io_nic *nic, struct ring_info *ring,
 				wmb();
 				first_rxdp->Control_1 |= RXD_OWN_XENA;
 			}
-			stats->mem_alloc_fail_cnt++;
+			swstats->mem_alloc_fail_cnt++;
 
 			return -ENOMEM ;
 		}
-		stats->mem_allocated += skb->truesize;
+		swstats->mem_allocated += skb->truesize;
 
 		if (ring->rxd_mode == RXD_MODE_1) {
 			/* 1 buffer mode - normal operation mode */
@@ -2742,8 +2722,8 @@ end:
 	return SUCCESS;
 
 pci_map_failed:
-	stats->pci_map_fail_cnt++;
-	stats->mem_freed += skb->truesize;
+	swstats->pci_map_fail_cnt++;
+	swstats->mem_freed += skb->truesize;
 	dev_kfree_skb_irq(skb);
 	return -ENOMEM;
 }
@@ -2754,12 +2734,13 @@ static void free_rxd_blk(struct s2io_nic *sp, int ring_no, int blk)
 	int j;
 	struct sk_buff *skb;
 	struct RxD_t *rxdp;
-	struct mac_info *mac_control;
 	struct buffAdd *ba;
 	struct RxD1 *rxdp1;
 	struct RxD3 *rxdp3;
+	struct mac_info *mac_control = &sp->mac_control;
+	struct stat_block *stats = mac_control->stats_info;
+	struct swStat *swstats = &stats->sw_stat;
 
-	mac_control = &sp->mac_control;
 	for (j = 0 ; j < rxd_count[sp->rxd_mode]; j++) {
 		rxdp = mac_control->rings[ring_no].
 			rx_blocks[blk].rxds[j].virt_addr;
@@ -2792,7 +2773,7 @@ static void free_rxd_blk(struct s2io_nic *sp, int ring_no, int blk)
 					 PCI_DMA_FROMDEVICE);
 			memset(rxdp, 0, sizeof(struct RxD3));
 		}
-		sp->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
+		swstats->mem_freed += skb->truesize;
 		dev_kfree_skb(skb);
 		mac_control->rings[ring_no].rx_bufs_left -= 1;
 	}
@@ -2811,11 +2792,8 @@ static void free_rx_buffers(struct s2io_nic *sp)
 {
 	struct net_device *dev = sp->dev;
 	int i, blk = 0, buf_cnt = 0;
-	struct mac_info *mac_control;
-	struct config_param *config;
-
-	mac_control = &sp->mac_control;
-	config = &sp->config;
+	struct config_param *config = &sp->config;
+	struct mac_info *mac_control = &sp->mac_control;
 
 	for (i = 0; i < config->rx_ring_num; i++) {
 		struct ring_info *ring = &mac_control->rings[i];
@@ -2859,8 +2837,6 @@ static int s2io_poll_msix(struct napi_struct *napi, int budget)
 {
 	struct ring_info *ring = container_of(napi, struct ring_info, napi);
 	struct net_device *dev = ring->dev;
-	struct config_param *config;
-	struct mac_info *mac_control;
 	int pkts_processed = 0;
 	u8 __iomem *addr = NULL;
 	u8 val8 = 0;
@@ -2868,9 +2844,6 @@ static int s2io_poll_msix(struct napi_struct *napi, int budget)
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
 	int budget_org = budget;
 
-	config = &nic->config;
-	mac_control = &nic->mac_control;
-
 	if (unlikely(!is_s2io_card_up(nic)))
 		return 0;
 
@@ -2892,15 +2865,12 @@ static int s2io_poll_msix(struct napi_struct *napi, int budget)
 static int s2io_poll_inta(struct napi_struct *napi, int budget)
 {
 	struct s2io_nic *nic = container_of(napi, struct s2io_nic, napi);
-	struct config_param *config;
-	struct mac_info *mac_control;
 	int pkts_processed = 0;
 	int ring_pkts_processed, i;
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
 	int budget_org = budget;
-
-	config = &nic->config;
-	mac_control = &nic->mac_control;
+	struct config_param *config = &nic->config;
+	struct mac_info *mac_control = &nic->mac_control;
 
 	if (unlikely(!is_s2io_card_up(nic)))
 		return 0;
@@ -2936,20 +2906,17 @@ static int s2io_poll_inta(struct napi_struct *napi, int budget)
 static void s2io_netpoll(struct net_device *dev)
 {
 	struct s2io_nic *nic = netdev_priv(dev);
-	struct mac_info *mac_control;
-	struct config_param *config;
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
 	u64 val64 = 0xFFFFFFFFFFFFFFFFULL;
 	int i;
+	struct config_param *config = &nic->config;
+	struct mac_info *mac_control = &nic->mac_control;
 
 	if (pci_channel_offline(nic->pdev))
 		return;
 
 	disable_irq(dev->irq);
 
-	mac_control = &nic->mac_control;
-	config = &nic->config;
-
 	writeq(val64, &bar0->rx_traffic_int);
 	writeq(val64, &bar0->tx_traffic_int);
 
@@ -3110,6 +3077,8 @@ static void tx_intr_handler(struct fifo_info *fifo_data)
 	int pkt_cnt = 0;
 	unsigned long flags = 0;
 	u8 err_mask;
+	struct stat_block *stats = nic->mac_control.stats_info;
+	struct swStat *swstats = &stats->sw_stat;
 
 	if (!spin_trylock_irqsave(&fifo_data->tx_lock, flags))
 		return;
@@ -3126,36 +3095,30 @@ static void tx_intr_handler(struct fifo_info *fifo_data)
 			unsigned long long err;
 			err = txdlp->Control_1 & TXD_T_CODE;
 			if (err & 0x1) {
-				nic->mac_control.stats_info->sw_stat.
-					parity_err_cnt++;
+				swstats->parity_err_cnt++;
 			}
 
 			/* update t_code statistics */
 			err_mask = err >> 48;
 			switch (err_mask) {
 			case 2:
-				nic->mac_control.stats_info->sw_stat.
-					tx_buf_abort_cnt++;
+				swstats->tx_buf_abort_cnt++;
 				break;
 
 			case 3:
-				nic->mac_control.stats_info->sw_stat.
-					tx_desc_abort_cnt++;
+				swstats->tx_desc_abort_cnt++;
 				break;
 
 			case 7:
-				nic->mac_control.stats_info->sw_stat.
-					tx_parity_err_cnt++;
+				swstats->tx_parity_err_cnt++;
 				break;
 
 			case 10:
-				nic->mac_control.stats_info->sw_stat.
-					tx_link_loss_cnt++;
+				swstats->tx_link_loss_cnt++;
 				break;
 
 			case 15:
-				nic->mac_control.stats_info->sw_stat.
-					tx_list_proc_err_cnt++;
+				swstats->tx_list_proc_err_cnt++;
 				break;
 			}
 		}
@@ -3171,7 +3134,7 @@ static void tx_intr_handler(struct fifo_info *fifo_data)
 
 		/* Updating the statistics block */
 		nic->dev->stats.tx_bytes += skb->len;
-		nic->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
+		swstats->mem_freed += skb->truesize;
 		dev_kfree_skb_irq(skb);
 
 		get_info.offset++;
@@ -3350,7 +3313,8 @@ static void s2io_updt_xpak_counter(struct net_device *dev)
 	u64 addr  = 0x0;
 
 	struct s2io_nic *sp = netdev_priv(dev);
-	struct stat_block *stat_info = sp->mac_control.stats_info;
+	struct stat_block *stats = sp->mac_control.stats_info;
+	struct xpakStat *xstats = &stats->xpak_stat;
 
 	/* Check the communication with the MDIO slave */
 	addr = MDIO_CTRL1;
@@ -3382,30 +3346,30 @@ static void s2io_updt_xpak_counter(struct net_device *dev)
 
 	flag = CHECKBIT(val64, 0x7);
 	type = 1;
-	s2io_chk_xpak_counter(&stat_info->xpak_stat.alarm_transceiver_temp_high,
-			      &stat_info->xpak_stat.xpak_regs_stat,
+	s2io_chk_xpak_counter(&xstats->alarm_transceiver_temp_high,
+			      &xstats->xpak_regs_stat,
 			      0x0, flag, type);
 
 	if (CHECKBIT(val64, 0x6))
-		stat_info->xpak_stat.alarm_transceiver_temp_low++;
+		xstats->alarm_transceiver_temp_low++;
 
 	flag = CHECKBIT(val64, 0x3);
 	type = 2;
-	s2io_chk_xpak_counter(&stat_info->xpak_stat.alarm_laser_bias_current_high,
-			      &stat_info->xpak_stat.xpak_regs_stat,
+	s2io_chk_xpak_counter(&xstats->alarm_laser_bias_current_high,
+			      &xstats->xpak_regs_stat,
 			      0x2, flag, type);
 
 	if (CHECKBIT(val64, 0x2))
-		stat_info->xpak_stat.alarm_laser_bias_current_low++;
+		xstats->alarm_laser_bias_current_low++;
 
 	flag = CHECKBIT(val64, 0x1);
 	type = 3;
-	s2io_chk_xpak_counter(&stat_info->xpak_stat.alarm_laser_output_power_high,
-			      &stat_info->xpak_stat.xpak_regs_stat,
+	s2io_chk_xpak_counter(&xstats->alarm_laser_output_power_high,
+			      &xstats->xpak_regs_stat,
 			      0x4, flag, type);
 
 	if (CHECKBIT(val64, 0x0))
-		stat_info->xpak_stat.alarm_laser_output_power_low++;
+		xstats->alarm_laser_output_power_low++;
 
 	/* Reading the Warning flags */
 	addr = 0xA074;
@@ -3413,22 +3377,22 @@ static void s2io_updt_xpak_counter(struct net_device *dev)
 	val64 = s2io_mdio_read(MDIO_MMD_PMAPMD, addr, dev);
 
 	if (CHECKBIT(val64, 0x7))
-		stat_info->xpak_stat.warn_transceiver_temp_high++;
+		xstats->warn_transceiver_temp_high++;
 
 	if (CHECKBIT(val64, 0x6))
-		stat_info->xpak_stat.warn_transceiver_temp_low++;
+		xstats->warn_transceiver_temp_low++;
 
 	if (CHECKBIT(val64, 0x3))
-		stat_info->xpak_stat.warn_laser_bias_current_high++;
+		xstats->warn_laser_bias_current_high++;
 
 	if (CHECKBIT(val64, 0x2))
-		stat_info->xpak_stat.warn_laser_bias_current_low++;
+		xstats->warn_laser_bias_current_low++;
 
 	if (CHECKBIT(val64, 0x1))
-		stat_info->xpak_stat.warn_laser_output_power_high++;
+		xstats->warn_laser_output_power_high++;
 
 	if (CHECKBIT(val64, 0x0))
-		stat_info->xpak_stat.warn_laser_output_power_low++;
+		xstats->warn_laser_output_power_low++;
 }
 
 /**
@@ -3514,6 +3478,8 @@ static void s2io_reset(struct s2io_nic *sp)
 	u16 val16;
 	unsigned long long up_cnt, down_cnt, up_time, down_time, reset_cnt;
 	unsigned long long mem_alloc_cnt, mem_free_cnt, watchdog_cnt;
+	struct stat_block *stats;
+	struct swStat *swstats;
 
 	DBG_PRINT(INIT_DBG, "%s - Resetting XFrame card %s\n",
 		  __func__, sp->dev->name);
@@ -3567,25 +3533,30 @@ static void s2io_reset(struct s2io_nic *sp)
 	/* Reset device statistics maintained by OS */
 	memset(&sp->stats, 0, sizeof(struct net_device_stats));
 
-	up_cnt = sp->mac_control.stats_info->sw_stat.link_up_cnt;
-	down_cnt = sp->mac_control.stats_info->sw_stat.link_down_cnt;
-	up_time = sp->mac_control.stats_info->sw_stat.link_up_time;
-	down_time = sp->mac_control.stats_info->sw_stat.link_down_time;
-	reset_cnt = sp->mac_control.stats_info->sw_stat.soft_reset_cnt;
-	mem_alloc_cnt = sp->mac_control.stats_info->sw_stat.mem_allocated;
-	mem_free_cnt = sp->mac_control.stats_info->sw_stat.mem_freed;
-	watchdog_cnt = sp->mac_control.stats_info->sw_stat.watchdog_timer_cnt;
+	stats = sp->mac_control.stats_info;
+	swstats = &stats->sw_stat;
+
 	/* save link up/down time/cnt, reset/memory/watchdog cnt */
-	memset(sp->mac_control.stats_info, 0, sizeof(struct stat_block));
+	up_cnt = swstats->link_up_cnt;
+	down_cnt = swstats->link_down_cnt;
+	up_time = swstats->link_up_time;
+	down_time = swstats->link_down_time;
+	reset_cnt = swstats->soft_reset_cnt;
+	mem_alloc_cnt = swstats->mem_allocated;
+	mem_free_cnt = swstats->mem_freed;
+	watchdog_cnt = swstats->watchdog_timer_cnt;
+
+	memset(stats, 0, sizeof(struct stat_block));
+
 	/* restore link up/down time/cnt, reset/memory/watchdog cnt */
-	sp->mac_control.stats_info->sw_stat.link_up_cnt = up_cnt;
-	sp->mac_control.stats_info->sw_stat.link_down_cnt = down_cnt;
-	sp->mac_control.stats_info->sw_stat.link_up_time = up_time;
-	sp->mac_control.stats_info->sw_stat.link_down_time = down_time;
-	sp->mac_control.stats_info->sw_stat.soft_reset_cnt = reset_cnt;
-	sp->mac_control.stats_info->sw_stat.mem_allocated = mem_alloc_cnt;
-	sp->mac_control.stats_info->sw_stat.mem_freed = mem_free_cnt;
-	sp->mac_control.stats_info->sw_stat.watchdog_timer_cnt = watchdog_cnt;
+	swstats->link_up_cnt = up_cnt;
+	swstats->link_down_cnt = down_cnt;
+	swstats->link_up_time = up_time;
+	swstats->link_down_time = down_time;
+	swstats->soft_reset_cnt = reset_cnt;
+	swstats->mem_allocated = mem_alloc_cnt;
+	swstats->mem_freed = mem_free_cnt;
+	swstats->watchdog_timer_cnt = watchdog_cnt;
 
 	/* SXE-002: Configure link and activity LED to turn it off */
 	subid = sp->pdev->subsystem_device;
@@ -3827,29 +3798,31 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 	u16 msi_control; /* Temp variable */
 	int ret, i, j, msix_indx = 1;
 	int size;
+	struct stat_block *stats = nic->mac_control.stats_info;
+	struct swStat *swstats = &stats->sw_stat;
 
 	size = nic->num_entries * sizeof(struct msix_entry);
 	nic->entries = kzalloc(size, GFP_KERNEL);
 	if (!nic->entries) {
 		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n",
 			  __func__);
-		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
+		swstats->mem_alloc_fail_cnt++;
 		return -ENOMEM;
 	}
-	nic->mac_control.stats_info->sw_stat.mem_allocated += size;
+	swstats->mem_allocated += size;
 
 	size = nic->num_entries * sizeof(struct s2io_msix_entry);
 	nic->s2io_entries = kzalloc(size, GFP_KERNEL);
 	if (!nic->s2io_entries) {
 		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n",
 			  __func__);
-		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
+		swstats->mem_alloc_fail_cnt++;
 		kfree(nic->entries);
-		nic->mac_control.stats_info->sw_stat.mem_freed
+		swstats->mem_freed
 			+= (nic->num_entries * sizeof(struct msix_entry));
 		return -ENOMEM;
 	}
-	nic->mac_control.stats_info->sw_stat.mem_allocated += size;
+	swstats->mem_allocated += size;
 
 	nic->entries[0].entry = 0;
 	nic->s2io_entries[0].entry = 0;
@@ -3880,11 +3853,11 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 	if (ret) {
 		DBG_PRINT(ERR_DBG, "s2io: Enabling MSI-X failed\n");
 		kfree(nic->entries);
-		nic->mac_control.stats_info->sw_stat.mem_freed
-			+= (nic->num_entries * sizeof(struct msix_entry));
+		swstats->mem_freed += nic->num_entries *
+			sizeof(struct msix_entry);
 		kfree(nic->s2io_entries);
-		nic->mac_control.stats_info->sw_stat.mem_freed
-			+= (nic->num_entries * sizeof(struct s2io_msix_entry));
+		swstats->mem_freed += nic->num_entries *
+			sizeof(struct s2io_msix_entry);
 		nic->entries = NULL;
 		nic->s2io_entries = NULL;
 		return -ENOMEM;
@@ -4006,6 +3979,7 @@ static void remove_inta_isr(struct s2io_nic *sp)
 static int s2io_open(struct net_device *dev)
 {
 	struct s2io_nic *sp = netdev_priv(dev);
+	struct swStat *swstats = &sp->mac_control.stats_info->sw_stat;
 	int err = 0;
 
 	/*
@@ -4036,13 +4010,13 @@ hw_init_failed:
 	if (sp->config.intr_type == MSI_X) {
 		if (sp->entries) {
 			kfree(sp->entries);
-			sp->mac_control.stats_info->sw_stat.mem_freed
-				+= (sp->num_entries * sizeof(struct msix_entry));
+			swstats->mem_freed += sp->num_entries *
+				sizeof(struct msix_entry);
 		}
 		if (sp->s2io_entries) {
 			kfree(sp->s2io_entries);
-			sp->mac_control.stats_info->sw_stat.mem_freed
-				+= (sp->num_entries * sizeof(struct s2io_msix_entry));
+			swstats->mem_freed += sp->num_entries *
+				sizeof(struct s2io_msix_entry);
 		}
 	}
 	return err;
@@ -4110,15 +4084,13 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags = 0;
 	u16 vlan_tag = 0;
 	struct fifo_info *fifo = NULL;
-	struct mac_info *mac_control;
-	struct config_param *config;
 	int do_spin_lock = 1;
 	int offload_type;
 	int enable_per_list_interrupt = 0;
-	struct swStat *stats = &sp->mac_control.stats_info->sw_stat;
-
-	mac_control = &sp->mac_control;
-	config = &sp->config;
+	struct config_param *config = &sp->config;
+	struct mac_info *mac_control = &sp->mac_control;
+	struct stat_block *stats = mac_control->stats_info;
+	struct swStat *swstats = &stats->sw_stat;
 
 	DBG_PRINT(TX_DBG, "%s: In Neterion Tx routine\n", dev->name);
 
@@ -4308,23 +4280,24 @@ static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Avoid "put" pointer going beyond "get" pointer */
 	if (((put_off+1) == queue_len ? 0 : (put_off+1)) == get_off) {
-		sp->mac_control.stats_info->sw_stat.fifo_full_cnt++;
+		swstats->fifo_full_cnt++;
 		DBG_PRINT(TX_DBG,
 			  "No free TxDs for xmit, Put: 0x%x Get:0x%x\n",
 			  put_off, get_off);
 		s2io_stop_tx_queue(sp, fifo->fifo_no);
 	}
-	mac_control->stats_info->sw_stat.mem_allocated += skb->truesize;
+	swstats->mem_allocated += skb->truesize;
 	spin_unlock_irqrestore(&fifo->tx_lock, flags);
 
 	if (sp->config.intr_type == MSI_X)
 		tx_intr_handler(fifo);
 
 	return NETDEV_TX_OK;
+
 pci_map_failed:
-	stats->pci_map_fail_cnt++;
+	swstats->pci_map_fail_cnt++;
 	s2io_stop_tx_queue(sp, fifo->fifo_no);
-	stats->mem_freed += skb->truesize;
+	swstats->mem_freed += skb->truesize;
 	dev_kfree_skb(skb);
 	spin_unlock_irqrestore(&fifo->tx_lock, flags);
 	return NETDEV_TX_OK;
@@ -4816,8 +4789,8 @@ static irqreturn_t s2io_isr(int irq, void *dev_id)
 	if (!is_s2io_card_up(sp))
 		return IRQ_NONE;
 
-	mac_control = &sp->mac_control;
 	config = &sp->config;
+	mac_control = &sp->mac_control;
 
 	/*
 	 * Identify the cause for interrupt and call the appropriate
@@ -4934,44 +4907,35 @@ static void s2io_updt_stats(struct s2io_nic *sp)
 static struct net_device_stats *s2io_get_stats(struct net_device *dev)
 {
 	struct s2io_nic *sp = netdev_priv(dev);
-	struct mac_info *mac_control;
-	struct config_param *config;
+	struct config_param *config = &sp->config;
+	struct mac_info *mac_control = &sp->mac_control;
+	struct stat_block *stats = mac_control->stats_info;
 	int i;
 
-
-	mac_control = &sp->mac_control;
-	config = &sp->config;
-
 	/* Configure Stats for immediate updt */
 	s2io_updt_stats(sp);
 
 	/* Using sp->stats as a staging area, because reset (due to mtu
 	   change, for example) will clear some hardware counters */
-	dev->stats.tx_packets +=
-		le32_to_cpu(mac_control->stats_info->tmac_frms) -
+	dev->stats.tx_packets += le32_to_cpu(stats->tmac_frms) -
 		sp->stats.tx_packets;
-	sp->stats.tx_packets =
-		le32_to_cpu(mac_control->stats_info->tmac_frms);
-	dev->stats.tx_errors +=
-		le32_to_cpu(mac_control->stats_info->tmac_any_err_frms) -
+	sp->stats.tx_packets = le32_to_cpu(stats->tmac_frms);
+
+	dev->stats.tx_errors += le32_to_cpu(stats->tmac_any_err_frms) -
 		sp->stats.tx_errors;
-	sp->stats.tx_errors =
-		le32_to_cpu(mac_control->stats_info->tmac_any_err_frms);
-	dev->stats.rx_errors +=
-		le64_to_cpu(mac_control->stats_info->rmac_drop_frms) -
+	sp->stats.tx_errors = le32_to_cpu(stats->tmac_any_err_frms);
+
+	dev->stats.rx_errors += le64_to_cpu(stats->rmac_drop_frms) -
 		sp->stats.rx_errors;
-	sp->stats.rx_errors =
-		le64_to_cpu(mac_control->stats_info->rmac_drop_frms);
-	dev->stats.multicast =
-		le32_to_cpu(mac_control->stats_info->rmac_vld_mcst_frms) -
+	sp->stats.rx_errors = le64_to_cpu(stats->rmac_drop_frms);
+
+	dev->stats.multicast = le32_to_cpu(stats->rmac_vld_mcst_frms) -
 		sp->stats.multicast;
-	sp->stats.multicast =
-		le32_to_cpu(mac_control->stats_info->rmac_vld_mcst_frms);
-	dev->stats.rx_length_errors =
-		le64_to_cpu(mac_control->stats_info->rmac_long_frms) -
+	sp->stats.multicast = le32_to_cpu(stats->rmac_vld_mcst_frms);
+
+	dev->stats.rx_length_errors = le64_to_cpu(stats->rmac_long_frms) -
 		sp->stats.rx_length_errors;
-	sp->stats.rx_length_errors =
-		le64_to_cpu(mac_control->stats_info->rmac_long_frms);
+	sp->stats.rx_length_errors = le64_to_cpu(stats->rmac_long_frms);
 
 	/* collect per-ring rx_packets and rx_bytes */
 	dev->stats.rx_packets = dev->stats.rx_bytes = 0;
@@ -5803,6 +5767,7 @@ static void s2io_vpd_read(struct s2io_nic *nic)
 	u8 data;
 	int i = 0, cnt, fail = 0;
 	int vpd_addr = 0x80;
+	struct swStat *swstats = &nic->mac_control.stats_info->sw_stat;
 
 	if (nic->device_type == XFRAME_II_DEVICE) {
 		strcpy(nic->product_name, "Xframe II 10GbE network adapter");
@@ -5815,10 +5780,10 @@ static void s2io_vpd_read(struct s2io_nic *nic)
 
 	vpd_data = kmalloc(256, GFP_KERNEL);
 	if (!vpd_data) {
-		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
+		swstats->mem_alloc_fail_cnt++;
 		return;
 	}
-	nic->mac_control.stats_info->sw_stat.mem_allocated += 256;
+	swstats->mem_allocated += 256;
 
 	for (i = 0; i < 256; i += 4) {
 		pci_write_config_byte(nic->pdev, (vpd_addr + 2), i);
@@ -5858,7 +5823,7 @@ static void s2io_vpd_read(struct s2io_nic *nic)
 		memcpy(nic->product_name, &vpd_data[3], vpd_data[1]);
 	}
 	kfree(vpd_data);
-	nic->mac_control.stats_info->sw_stat.mem_freed += 256;
+	swstats->mem_freed += 256;
 }
 
 /**
@@ -6350,273 +6315,275 @@ static void s2io_get_ethtool_stats(struct net_device *dev,
 {
 	int i = 0, k;
 	struct s2io_nic *sp = netdev_priv(dev);
-	struct stat_block *stat_info = sp->mac_control.stats_info;
+	struct stat_block *stats = sp->mac_control.stats_info;
+	struct swStat *swstats = &stats->sw_stat;
+	struct xpakStat *xstats = &stats->xpak_stat;
 
 	s2io_updt_stats(sp);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->tmac_frms_oflow) << 32  |
-		le32_to_cpu(stat_info->tmac_frms);
+		(u64)le32_to_cpu(stats->tmac_frms_oflow) << 32  |
+		le32_to_cpu(stats->tmac_frms);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->tmac_data_octets_oflow) << 32 |
-		le32_to_cpu(stat_info->tmac_data_octets);
-	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_drop_frms);
+		(u64)le32_to_cpu(stats->tmac_data_octets_oflow) << 32 |
+		le32_to_cpu(stats->tmac_data_octets);
+	tmp_stats[i++] = le64_to_cpu(stats->tmac_drop_frms);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->tmac_mcst_frms_oflow) << 32 |
-		le32_to_cpu(stat_info->tmac_mcst_frms);
+		(u64)le32_to_cpu(stats->tmac_mcst_frms_oflow) << 32 |
+		le32_to_cpu(stats->tmac_mcst_frms);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->tmac_bcst_frms_oflow) << 32 |
-		le32_to_cpu(stat_info->tmac_bcst_frms);
-	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_pause_ctrl_frms);
+		(u64)le32_to_cpu(stats->tmac_bcst_frms_oflow) << 32 |
+		le32_to_cpu(stats->tmac_bcst_frms);
+	tmp_stats[i++] = le64_to_cpu(stats->tmac_pause_ctrl_frms);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->tmac_ttl_octets_oflow) << 32 |
-		le32_to_cpu(stat_info->tmac_ttl_octets);
+		(u64)le32_to_cpu(stats->tmac_ttl_octets_oflow) << 32 |
+		le32_to_cpu(stats->tmac_ttl_octets);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->tmac_ucst_frms_oflow) << 32 |
-		le32_to_cpu(stat_info->tmac_ucst_frms);
+		(u64)le32_to_cpu(stats->tmac_ucst_frms_oflow) << 32 |
+		le32_to_cpu(stats->tmac_ucst_frms);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->tmac_nucst_frms_oflow) << 32 |
-		le32_to_cpu(stat_info->tmac_nucst_frms);
+		(u64)le32_to_cpu(stats->tmac_nucst_frms_oflow) << 32 |
+		le32_to_cpu(stats->tmac_nucst_frms);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->tmac_any_err_frms_oflow) << 32 |
-		le32_to_cpu(stat_info->tmac_any_err_frms);
-	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_ttl_less_fb_octets);
-	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_vld_ip_octets);
+		(u64)le32_to_cpu(stats->tmac_any_err_frms_oflow) << 32 |
+		le32_to_cpu(stats->tmac_any_err_frms);
+	tmp_stats[i++] = le64_to_cpu(stats->tmac_ttl_less_fb_octets);
+	tmp_stats[i++] = le64_to_cpu(stats->tmac_vld_ip_octets);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->tmac_vld_ip_oflow) << 32 |
-		le32_to_cpu(stat_info->tmac_vld_ip);
+		(u64)le32_to_cpu(stats->tmac_vld_ip_oflow) << 32 |
+		le32_to_cpu(stats->tmac_vld_ip);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->tmac_drop_ip_oflow) << 32 |
-		le32_to_cpu(stat_info->tmac_drop_ip);
+		(u64)le32_to_cpu(stats->tmac_drop_ip_oflow) << 32 |
+		le32_to_cpu(stats->tmac_drop_ip);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->tmac_icmp_oflow) << 32 |
-		le32_to_cpu(stat_info->tmac_icmp);
+		(u64)le32_to_cpu(stats->tmac_icmp_oflow) << 32 |
+		le32_to_cpu(stats->tmac_icmp);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->tmac_rst_tcp_oflow) << 32 |
-		le32_to_cpu(stat_info->tmac_rst_tcp);
-	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_tcp);
-	tmp_stats[i++] = (u64)le32_to_cpu(stat_info->tmac_udp_oflow) << 32 |
-		le32_to_cpu(stat_info->tmac_udp);
+		(u64)le32_to_cpu(stats->tmac_rst_tcp_oflow) << 32 |
+		le32_to_cpu(stats->tmac_rst_tcp);
+	tmp_stats[i++] = le64_to_cpu(stats->tmac_tcp);
+	tmp_stats[i++] = (u64)le32_to_cpu(stats->tmac_udp_oflow) << 32 |
+		le32_to_cpu(stats->tmac_udp);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->rmac_vld_frms_oflow) << 32 |
-		le32_to_cpu(stat_info->rmac_vld_frms);
+		(u64)le32_to_cpu(stats->rmac_vld_frms_oflow) << 32 |
+		le32_to_cpu(stats->rmac_vld_frms);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->rmac_data_octets_oflow) << 32 |
-		le32_to_cpu(stat_info->rmac_data_octets);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_fcs_err_frms);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_drop_frms);
+		(u64)le32_to_cpu(stats->rmac_data_octets_oflow) << 32 |
+		le32_to_cpu(stats->rmac_data_octets);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_fcs_err_frms);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_drop_frms);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->rmac_vld_mcst_frms_oflow) << 32 |
-		le32_to_cpu(stat_info->rmac_vld_mcst_frms);
+		(u64)le32_to_cpu(stats->rmac_vld_mcst_frms_oflow) << 32 |
+		le32_to_cpu(stats->rmac_vld_mcst_frms);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->rmac_vld_bcst_frms_oflow) << 32 |
-		le32_to_cpu(stat_info->rmac_vld_bcst_frms);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_in_rng_len_err_frms);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_out_rng_len_err_frms);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_long_frms);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_pause_ctrl_frms);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_unsup_ctrl_frms);
+		(u64)le32_to_cpu(stats->rmac_vld_bcst_frms_oflow) << 32 |
+		le32_to_cpu(stats->rmac_vld_bcst_frms);
+	tmp_stats[i++] = le32_to_cpu(stats->rmac_in_rng_len_err_frms);
+	tmp_stats[i++] = le32_to_cpu(stats->rmac_out_rng_len_err_frms);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_long_frms);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_pause_ctrl_frms);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_unsup_ctrl_frms);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->rmac_ttl_octets_oflow) << 32 |
-		le32_to_cpu(stat_info->rmac_ttl_octets);
+		(u64)le32_to_cpu(stats->rmac_ttl_octets_oflow) << 32 |
+		le32_to_cpu(stats->rmac_ttl_octets);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->rmac_accepted_ucst_frms_oflow) << 32
-		| le32_to_cpu(stat_info->rmac_accepted_ucst_frms);
+		(u64)le32_to_cpu(stats->rmac_accepted_ucst_frms_oflow) << 32
+		| le32_to_cpu(stats->rmac_accepted_ucst_frms);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->rmac_accepted_nucst_frms_oflow)
-		<< 32 | le32_to_cpu(stat_info->rmac_accepted_nucst_frms);
+		(u64)le32_to_cpu(stats->rmac_accepted_nucst_frms_oflow)
+		<< 32 | le32_to_cpu(stats->rmac_accepted_nucst_frms);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->rmac_discarded_frms_oflow) << 32 |
-		le32_to_cpu(stat_info->rmac_discarded_frms);
+		(u64)le32_to_cpu(stats->rmac_discarded_frms_oflow) << 32 |
+		le32_to_cpu(stats->rmac_discarded_frms);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->rmac_drop_events_oflow)
-		<< 32 | le32_to_cpu(stat_info->rmac_drop_events);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_less_fb_octets);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_frms);
+		(u64)le32_to_cpu(stats->rmac_drop_events_oflow)
+		<< 32 | le32_to_cpu(stats->rmac_drop_events);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_ttl_less_fb_octets);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_ttl_frms);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->rmac_usized_frms_oflow) << 32 |
-		le32_to_cpu(stat_info->rmac_usized_frms);
+		(u64)le32_to_cpu(stats->rmac_usized_frms_oflow) << 32 |
+		le32_to_cpu(stats->rmac_usized_frms);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->rmac_osized_frms_oflow) << 32 |
-		le32_to_cpu(stat_info->rmac_osized_frms);
+		(u64)le32_to_cpu(stats->rmac_osized_frms_oflow) << 32 |
+		le32_to_cpu(stats->rmac_osized_frms);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->rmac_frag_frms_oflow) << 32 |
-		le32_to_cpu(stat_info->rmac_frag_frms);
+		(u64)le32_to_cpu(stats->rmac_frag_frms_oflow) << 32 |
+		le32_to_cpu(stats->rmac_frag_frms);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->rmac_jabber_frms_oflow) << 32 |
-		le32_to_cpu(stat_info->rmac_jabber_frms);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_64_frms);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_65_127_frms);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_128_255_frms);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_256_511_frms);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_512_1023_frms);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_1024_1518_frms);
+		(u64)le32_to_cpu(stats->rmac_jabber_frms_oflow) << 32 |
+		le32_to_cpu(stats->rmac_jabber_frms);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_ttl_64_frms);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_ttl_65_127_frms);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_ttl_128_255_frms);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_ttl_256_511_frms);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_ttl_512_1023_frms);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_ttl_1024_1518_frms);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->rmac_ip_oflow) << 32 |
-		le32_to_cpu(stat_info->rmac_ip);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ip_octets);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_hdr_err_ip);
+		(u64)le32_to_cpu(stats->rmac_ip_oflow) << 32 |
+		le32_to_cpu(stats->rmac_ip);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_ip_octets);
+	tmp_stats[i++] = le32_to_cpu(stats->rmac_hdr_err_ip);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->rmac_drop_ip_oflow) << 32 |
-		le32_to_cpu(stat_info->rmac_drop_ip);
+		(u64)le32_to_cpu(stats->rmac_drop_ip_oflow) << 32 |
+		le32_to_cpu(stats->rmac_drop_ip);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->rmac_icmp_oflow) << 32 |
-		le32_to_cpu(stat_info->rmac_icmp);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_tcp);
+		(u64)le32_to_cpu(stats->rmac_icmp_oflow) << 32 |
+		le32_to_cpu(stats->rmac_icmp);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_tcp);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->rmac_udp_oflow) << 32 |
-		le32_to_cpu(stat_info->rmac_udp);
+		(u64)le32_to_cpu(stats->rmac_udp_oflow) << 32 |
+		le32_to_cpu(stats->rmac_udp);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->rmac_err_drp_udp_oflow) << 32 |
-		le32_to_cpu(stat_info->rmac_err_drp_udp);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_xgmii_err_sym);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q0);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q1);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q2);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q3);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q4);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q5);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q6);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_frms_q7);
-	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q0);
-	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q1);
-	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q2);
-	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q3);
-	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q4);
-	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q5);
-	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q6);
-	tmp_stats[i++] = le16_to_cpu(stat_info->rmac_full_q7);
+		(u64)le32_to_cpu(stats->rmac_err_drp_udp_oflow) << 32 |
+		le32_to_cpu(stats->rmac_err_drp_udp);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_xgmii_err_sym);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_frms_q0);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_frms_q1);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_frms_q2);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_frms_q3);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_frms_q4);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_frms_q5);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_frms_q6);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_frms_q7);
+	tmp_stats[i++] = le16_to_cpu(stats->rmac_full_q0);
+	tmp_stats[i++] = le16_to_cpu(stats->rmac_full_q1);
+	tmp_stats[i++] = le16_to_cpu(stats->rmac_full_q2);
+	tmp_stats[i++] = le16_to_cpu(stats->rmac_full_q3);
+	tmp_stats[i++] = le16_to_cpu(stats->rmac_full_q4);
+	tmp_stats[i++] = le16_to_cpu(stats->rmac_full_q5);
+	tmp_stats[i++] = le16_to_cpu(stats->rmac_full_q6);
+	tmp_stats[i++] = le16_to_cpu(stats->rmac_full_q7);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->rmac_pause_cnt_oflow) << 32 |
-		le32_to_cpu(stat_info->rmac_pause_cnt);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_xgmii_data_err_cnt);
-	tmp_stats[i++] = le64_to_cpu(stat_info->rmac_xgmii_ctrl_err_cnt);
+		(u64)le32_to_cpu(stats->rmac_pause_cnt_oflow) << 32 |
+		le32_to_cpu(stats->rmac_pause_cnt);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_xgmii_data_err_cnt);
+	tmp_stats[i++] = le64_to_cpu(stats->rmac_xgmii_ctrl_err_cnt);
 	tmp_stats[i++] =
-		(u64)le32_to_cpu(stat_info->rmac_accepted_ip_oflow) << 32 |
-		le32_to_cpu(stat_info->rmac_accepted_ip);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_err_tcp);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rd_req_cnt);
-	tmp_stats[i++] = le32_to_cpu(stat_info->new_rd_req_cnt);
-	tmp_stats[i++] = le32_to_cpu(stat_info->new_rd_req_rtry_cnt);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rd_rtry_cnt);
-	tmp_stats[i++] = le32_to_cpu(stat_info->wr_rtry_rd_ack_cnt);
-	tmp_stats[i++] = le32_to_cpu(stat_info->wr_req_cnt);
-	tmp_stats[i++] = le32_to_cpu(stat_info->new_wr_req_cnt);
-	tmp_stats[i++] = le32_to_cpu(stat_info->new_wr_req_rtry_cnt);
-	tmp_stats[i++] = le32_to_cpu(stat_info->wr_rtry_cnt);
-	tmp_stats[i++] = le32_to_cpu(stat_info->wr_disc_cnt);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rd_rtry_wr_ack_cnt);
-	tmp_stats[i++] = le32_to_cpu(stat_info->txp_wr_cnt);
-	tmp_stats[i++] = le32_to_cpu(stat_info->txd_rd_cnt);
-	tmp_stats[i++] = le32_to_cpu(stat_info->txd_wr_cnt);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rxd_rd_cnt);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rxd_wr_cnt);
-	tmp_stats[i++] = le32_to_cpu(stat_info->txf_rd_cnt);
-	tmp_stats[i++] = le32_to_cpu(stat_info->rxf_wr_cnt);
+		(u64)le32_to_cpu(stats->rmac_accepted_ip_oflow) << 32 |
+		le32_to_cpu(stats->rmac_accepted_ip);
+	tmp_stats[i++] = le32_to_cpu(stats->rmac_err_tcp);
+	tmp_stats[i++] = le32_to_cpu(stats->rd_req_cnt);
+	tmp_stats[i++] = le32_to_cpu(stats->new_rd_req_cnt);
+	tmp_stats[i++] = le32_to_cpu(stats->new_rd_req_rtry_cnt);
+	tmp_stats[i++] = le32_to_cpu(stats->rd_rtry_cnt);
+	tmp_stats[i++] = le32_to_cpu(stats->wr_rtry_rd_ack_cnt);
+	tmp_stats[i++] = le32_to_cpu(stats->wr_req_cnt);
+	tmp_stats[i++] = le32_to_cpu(stats->new_wr_req_cnt);
+	tmp_stats[i++] = le32_to_cpu(stats->new_wr_req_rtry_cnt);
+	tmp_stats[i++] = le32_to_cpu(stats->wr_rtry_cnt);
+	tmp_stats[i++] = le32_to_cpu(stats->wr_disc_cnt);
+	tmp_stats[i++] = le32_to_cpu(stats->rd_rtry_wr_ack_cnt);
+	tmp_stats[i++] = le32_to_cpu(stats->txp_wr_cnt);
+	tmp_stats[i++] = le32_to_cpu(stats->txd_rd_cnt);
+	tmp_stats[i++] = le32_to_cpu(stats->txd_wr_cnt);
+	tmp_stats[i++] = le32_to_cpu(stats->rxd_rd_cnt);
+	tmp_stats[i++] = le32_to_cpu(stats->rxd_wr_cnt);
+	tmp_stats[i++] = le32_to_cpu(stats->txf_rd_cnt);
+	tmp_stats[i++] = le32_to_cpu(stats->rxf_wr_cnt);
 
 	/* Enhanced statistics exist only for Hercules */
 	if (sp->device_type == XFRAME_II_DEVICE) {
 		tmp_stats[i++] =
-			le64_to_cpu(stat_info->rmac_ttl_1519_4095_frms);
+			le64_to_cpu(stats->rmac_ttl_1519_4095_frms);
 		tmp_stats[i++] =
-			le64_to_cpu(stat_info->rmac_ttl_4096_8191_frms);
+			le64_to_cpu(stats->rmac_ttl_4096_8191_frms);
 		tmp_stats[i++] =
-			le64_to_cpu(stat_info->rmac_ttl_8192_max_frms);
-		tmp_stats[i++] = le64_to_cpu(stat_info->rmac_ttl_gt_max_frms);
-		tmp_stats[i++] = le64_to_cpu(stat_info->rmac_osized_alt_frms);
-		tmp_stats[i++] = le64_to_cpu(stat_info->rmac_jabber_alt_frms);
-		tmp_stats[i++] = le64_to_cpu(stat_info->rmac_gt_max_alt_frms);
-		tmp_stats[i++] = le64_to_cpu(stat_info->rmac_vlan_frms);
-		tmp_stats[i++] = le32_to_cpu(stat_info->rmac_len_discard);
-		tmp_stats[i++] = le32_to_cpu(stat_info->rmac_fcs_discard);
-		tmp_stats[i++] = le32_to_cpu(stat_info->rmac_pf_discard);
-		tmp_stats[i++] = le32_to_cpu(stat_info->rmac_da_discard);
-		tmp_stats[i++] = le32_to_cpu(stat_info->rmac_red_discard);
-		tmp_stats[i++] = le32_to_cpu(stat_info->rmac_rts_discard);
-		tmp_stats[i++] = le32_to_cpu(stat_info->rmac_ingm_full_discard);
-		tmp_stats[i++] = le32_to_cpu(stat_info->link_fault_cnt);
+			le64_to_cpu(stats->rmac_ttl_8192_max_frms);
+		tmp_stats[i++] = le64_to_cpu(stats->rmac_ttl_gt_max_frms);
+		tmp_stats[i++] = le64_to_cpu(stats->rmac_osized_alt_frms);
+		tmp_stats[i++] = le64_to_cpu(stats->rmac_jabber_alt_frms);
+		tmp_stats[i++] = le64_to_cpu(stats->rmac_gt_max_alt_frms);
+		tmp_stats[i++] = le64_to_cpu(stats->rmac_vlan_frms);
+		tmp_stats[i++] = le32_to_cpu(stats->rmac_len_discard);
+		tmp_stats[i++] = le32_to_cpu(stats->rmac_fcs_discard);
+		tmp_stats[i++] = le32_to_cpu(stats->rmac_pf_discard);
+		tmp_stats[i++] = le32_to_cpu(stats->rmac_da_discard);
+		tmp_stats[i++] = le32_to_cpu(stats->rmac_red_discard);
+		tmp_stats[i++] = le32_to_cpu(stats->rmac_rts_discard);
+		tmp_stats[i++] = le32_to_cpu(stats->rmac_ingm_full_discard);
+		tmp_stats[i++] = le32_to_cpu(stats->link_fault_cnt);
 	}
 
 	tmp_stats[i++] = 0;
-	tmp_stats[i++] = stat_info->sw_stat.single_ecc_errs;
-	tmp_stats[i++] = stat_info->sw_stat.double_ecc_errs;
-	tmp_stats[i++] = stat_info->sw_stat.parity_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.serious_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.soft_reset_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.fifo_full_cnt;
+	tmp_stats[i++] = swstats->single_ecc_errs;
+	tmp_stats[i++] = swstats->double_ecc_errs;
+	tmp_stats[i++] = swstats->parity_err_cnt;
+	tmp_stats[i++] = swstats->serious_err_cnt;
+	tmp_stats[i++] = swstats->soft_reset_cnt;
+	tmp_stats[i++] = swstats->fifo_full_cnt;
 	for (k = 0; k < MAX_RX_RINGS; k++)
-		tmp_stats[i++] = stat_info->sw_stat.ring_full_cnt[k];
-	tmp_stats[i++] = stat_info->xpak_stat.alarm_transceiver_temp_high;
-	tmp_stats[i++] = stat_info->xpak_stat.alarm_transceiver_temp_low;
-	tmp_stats[i++] = stat_info->xpak_stat.alarm_laser_bias_current_high;
-	tmp_stats[i++] = stat_info->xpak_stat.alarm_laser_bias_current_low;
-	tmp_stats[i++] = stat_info->xpak_stat.alarm_laser_output_power_high;
-	tmp_stats[i++] = stat_info->xpak_stat.alarm_laser_output_power_low;
-	tmp_stats[i++] = stat_info->xpak_stat.warn_transceiver_temp_high;
-	tmp_stats[i++] = stat_info->xpak_stat.warn_transceiver_temp_low;
-	tmp_stats[i++] = stat_info->xpak_stat.warn_laser_bias_current_high;
-	tmp_stats[i++] = stat_info->xpak_stat.warn_laser_bias_current_low;
-	tmp_stats[i++] = stat_info->xpak_stat.warn_laser_output_power_high;
-	tmp_stats[i++] = stat_info->xpak_stat.warn_laser_output_power_low;
-	tmp_stats[i++] = stat_info->sw_stat.clubbed_frms_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.sending_both;
-	tmp_stats[i++] = stat_info->sw_stat.outof_sequence_pkts;
-	tmp_stats[i++] = stat_info->sw_stat.flush_max_pkts;
-	if (stat_info->sw_stat.num_aggregations) {
-		u64 tmp = stat_info->sw_stat.sum_avg_pkts_aggregated;
+		tmp_stats[i++] = swstats->ring_full_cnt[k];
+	tmp_stats[i++] = xstats->alarm_transceiver_temp_high;
+	tmp_stats[i++] = xstats->alarm_transceiver_temp_low;
+	tmp_stats[i++] = xstats->alarm_laser_bias_current_high;
+	tmp_stats[i++] = xstats->alarm_laser_bias_current_low;
+	tmp_stats[i++] = xstats->alarm_laser_output_power_high;
+	tmp_stats[i++] = xstats->alarm_laser_output_power_low;
+	tmp_stats[i++] = xstats->warn_transceiver_temp_high;
+	tmp_stats[i++] = xstats->warn_transceiver_temp_low;
+	tmp_stats[i++] = xstats->warn_laser_bias_current_high;
+	tmp_stats[i++] = xstats->warn_laser_bias_current_low;
+	tmp_stats[i++] = xstats->warn_laser_output_power_high;
+	tmp_stats[i++] = xstats->warn_laser_output_power_low;
+	tmp_stats[i++] = swstats->clubbed_frms_cnt;
+	tmp_stats[i++] = swstats->sending_both;
+	tmp_stats[i++] = swstats->outof_sequence_pkts;
+	tmp_stats[i++] = swstats->flush_max_pkts;
+	if (swstats->num_aggregations) {
+		u64 tmp = swstats->sum_avg_pkts_aggregated;
 		int count = 0;
 		/*
 		 * Since 64-bit divide does not work on all platforms,
 		 * do repeated subtraction.
 		 */
-		while (tmp >= stat_info->sw_stat.num_aggregations) {
-			tmp -= stat_info->sw_stat.num_aggregations;
+		while (tmp >= swstats->num_aggregations) {
+			tmp -= swstats->num_aggregations;
 			count++;
 		}
 		tmp_stats[i++] = count;
 	} else
 		tmp_stats[i++] = 0;
-	tmp_stats[i++] = stat_info->sw_stat.mem_alloc_fail_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.pci_map_fail_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.watchdog_timer_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.mem_allocated;
-	tmp_stats[i++] = stat_info->sw_stat.mem_freed;
-	tmp_stats[i++] = stat_info->sw_stat.link_up_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.link_down_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.link_up_time;
-	tmp_stats[i++] = stat_info->sw_stat.link_down_time;
-
-	tmp_stats[i++] = stat_info->sw_stat.tx_buf_abort_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.tx_desc_abort_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.tx_parity_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.tx_link_loss_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.tx_list_proc_err_cnt;
-
-	tmp_stats[i++] = stat_info->sw_stat.rx_parity_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.rx_abort_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.rx_parity_abort_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.rx_rda_fail_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.rx_unkn_prot_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.rx_fcs_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.rx_buf_size_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.rx_rxd_corrupt_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.rx_unkn_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.tda_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.pfc_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.pcc_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.tti_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.tpa_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.sm_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.lso_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.mac_tmac_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.mac_rmac_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.xgxs_txgxs_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.xgxs_rxgxs_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.rc_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.prc_pcix_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.rpa_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.rda_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.rti_err_cnt;
-	tmp_stats[i++] = stat_info->sw_stat.mc_err_cnt;
+	tmp_stats[i++] = swstats->mem_alloc_fail_cnt;
+	tmp_stats[i++] = swstats->pci_map_fail_cnt;
+	tmp_stats[i++] = swstats->watchdog_timer_cnt;
+	tmp_stats[i++] = swstats->mem_allocated;
+	tmp_stats[i++] = swstats->mem_freed;
+	tmp_stats[i++] = swstats->link_up_cnt;
+	tmp_stats[i++] = swstats->link_down_cnt;
+	tmp_stats[i++] = swstats->link_up_time;
+	tmp_stats[i++] = swstats->link_down_time;
+
+	tmp_stats[i++] = swstats->tx_buf_abort_cnt;
+	tmp_stats[i++] = swstats->tx_desc_abort_cnt;
+	tmp_stats[i++] = swstats->tx_parity_err_cnt;
+	tmp_stats[i++] = swstats->tx_link_loss_cnt;
+	tmp_stats[i++] = swstats->tx_list_proc_err_cnt;
+
+	tmp_stats[i++] = swstats->rx_parity_err_cnt;
+	tmp_stats[i++] = swstats->rx_abort_cnt;
+	tmp_stats[i++] = swstats->rx_parity_abort_cnt;
+	tmp_stats[i++] = swstats->rx_rda_fail_cnt;
+	tmp_stats[i++] = swstats->rx_unkn_prot_cnt;
+	tmp_stats[i++] = swstats->rx_fcs_err_cnt;
+	tmp_stats[i++] = swstats->rx_buf_size_err_cnt;
+	tmp_stats[i++] = swstats->rx_rxd_corrupt_cnt;
+	tmp_stats[i++] = swstats->rx_unkn_err_cnt;
+	tmp_stats[i++] = swstats->tda_err_cnt;
+	tmp_stats[i++] = swstats->pfc_err_cnt;
+	tmp_stats[i++] = swstats->pcc_err_cnt;
+	tmp_stats[i++] = swstats->tti_err_cnt;
+	tmp_stats[i++] = swstats->tpa_err_cnt;
+	tmp_stats[i++] = swstats->sm_err_cnt;
+	tmp_stats[i++] = swstats->lso_err_cnt;
+	tmp_stats[i++] = swstats->mac_tmac_err_cnt;
+	tmp_stats[i++] = swstats->mac_rmac_err_cnt;
+	tmp_stats[i++] = swstats->xgxs_txgxs_err_cnt;
+	tmp_stats[i++] = swstats->xgxs_rxgxs_err_cnt;
+	tmp_stats[i++] = swstats->rc_err_cnt;
+	tmp_stats[i++] = swstats->prc_pcix_err_cnt;
+	tmp_stats[i++] = swstats->rpa_err_cnt;
+	tmp_stats[i++] = swstats->rda_err_cnt;
+	tmp_stats[i++] = swstats->rti_err_cnt;
+	tmp_stats[i++] = swstats->mc_err_cnt;
 }
 
 static int s2io_ethtool_get_regs_len(struct net_device *dev)
@@ -6912,12 +6879,10 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 				DBG_PRINT(INFO_DBG, "%s: Out of ", dev->name);
 				DBG_PRINT(INFO_DBG, "memory to allocate ");
 				DBG_PRINT(INFO_DBG, "1 buf mode SKBs\n");
-				sp->mac_control.stats_info->sw_stat.
-					mem_alloc_fail_cnt++;
+				stats->mem_alloc_fail_cnt++;
 				return -ENOMEM ;
 			}
-			sp->mac_control.stats_info->sw_stat.mem_allocated
-				+= (*skb)->truesize;
+			stats->mem_allocated += (*skb)->truesize;
 			/* storing the mapped addr in a temp variable
 			 * such it will be used for next rxd whose
 			 * Host Control is NULL
@@ -6943,12 +6908,10 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 				DBG_PRINT(INFO_DBG, "%s: Out of ", dev->name);
 				DBG_PRINT(INFO_DBG, "memory to allocate ");
 				DBG_PRINT(INFO_DBG, "2 buf mode SKBs\n");
-				sp->mac_control.stats_info->sw_stat.
-					mem_alloc_fail_cnt++;
+				stats->mem_alloc_fail_cnt++;
 				return -ENOMEM;
 			}
-			sp->mac_control.stats_info->sw_stat.mem_allocated
-				+= (*skb)->truesize;
+			stats->mem_allocated += (*skb)->truesize;
 			rxdp3->Buffer2_ptr = *temp2 =
 				pci_map_single(sp->pdev, (*skb)->data,
 					       dev->mtu + 4,
@@ -7010,8 +6973,8 @@ static void set_rxd_buffer_size(struct s2io_nic *sp, struct RxD_t *rxdp,
 static  int rxd_owner_bit_reset(struct s2io_nic *sp)
 {
 	int i, j, k, blk_cnt = 0, size;
-	struct mac_info *mac_control = &sp->mac_control;
 	struct config_param *config = &sp->config;
+	struct mac_info *mac_control = &sp->mac_control;
 	struct net_device *dev = sp->dev;
 	struct RxD_t *rxdp = NULL;
 	struct sk_buff *skb = NULL;
@@ -7239,8 +7202,8 @@ static void s2io_card_down(struct s2io_nic *sp)
 static int s2io_card_up(struct s2io_nic *sp)
 {
 	int i, ret = 0;
-	struct mac_info *mac_control;
 	struct config_param *config;
+	struct mac_info *mac_control;
 	struct net_device *dev = (struct net_device *)sp->dev;
 	u16 interruptible;
 
@@ -7258,8 +7221,8 @@ static int s2io_card_up(struct s2io_nic *sp)
 	 * Initializing the Rx buffers. For now we are considering only 1
 	 * Rx ring and initializing buffers into 30 Rx blocks
 	 */
-	mac_control = &sp->mac_control;
 	config = &sp->config;
+	mac_control = &sp->mac_control;
 
 	for (i = 0; i < config->rx_ring_num; i++) {
 		struct ring_info *ring = &mac_control->rings[i];
@@ -7387,11 +7350,12 @@ out_unlock:
 static void s2io_tx_watchdog(struct net_device *dev)
 {
 	struct s2io_nic *sp = netdev_priv(dev);
+	struct swStat *swstats = &sp->mac_control.stats_info->sw_stat;
 
 	if (netif_carrier_ok(dev)) {
-		sp->mac_control.stats_info->sw_stat.watchdog_timer_cnt++;
+		swstats->watchdog_timer_cnt++;
 		schedule_work(&sp->rst_timer_task);
-		sp->mac_control.stats_info->sw_stat.soft_reset_cnt++;
+		swstats->soft_reset_cnt++;
 	}
 }
 
@@ -7423,50 +7387,51 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 	unsigned long long err = rxdp->Control_1 & RXD_T_CODE;
 	struct lro *uninitialized_var(lro);
 	u8 err_mask;
+	struct swStat *swstats = &sp->mac_control.stats_info->sw_stat;
 
 	skb->dev = dev;
 
 	if (err) {
 		/* Check for parity error */
 		if (err & 0x1)
-			sp->mac_control.stats_info->sw_stat.parity_err_cnt++;
+			swstats->parity_err_cnt++;
 
 		err_mask = err >> 48;
 		switch (err_mask) {
 		case 1:
-			sp->mac_control.stats_info->sw_stat.rx_parity_err_cnt++;
+			swstats->rx_parity_err_cnt++;
 			break;
 
 		case 2:
-			sp->mac_control.stats_info->sw_stat.rx_abort_cnt++;
+			swstats->rx_abort_cnt++;
 			break;
 
 		case 3:
-			sp->mac_control.stats_info->sw_stat.rx_parity_abort_cnt++;
+			swstats->rx_parity_abort_cnt++;
 			break;
 
 		case 4:
-			sp->mac_control.stats_info->sw_stat.rx_rda_fail_cnt++;
+			swstats->rx_rda_fail_cnt++;
 			break;
 
 		case 5:
-			sp->mac_control.stats_info->sw_stat.rx_unkn_prot_cnt++;
+			swstats->rx_unkn_prot_cnt++;
 			break;
 
 		case 6:
-			sp->mac_control.stats_info->sw_stat.rx_fcs_err_cnt++;
+			swstats->rx_fcs_err_cnt++;
 			break;
 
 		case 7:
-			sp->mac_control.stats_info->sw_stat.rx_buf_size_err_cnt++;
+			swstats->rx_buf_size_err_cnt++;
 			break;
 
 		case 8:
-			sp->mac_control.stats_info->sw_stat.rx_rxd_corrupt_cnt++;
+			swstats->rx_rxd_corrupt_cnt++;
 			break;
 
 		case 15:
-			sp->mac_control.stats_info->sw_stat.rx_unkn_err_cnt++;
+			swstats->rx_unkn_err_cnt++;
 			break;
 		}
 		/*
@@ -7480,7 +7445,7 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 			DBG_PRINT(ERR_DBG, "%s: Rx error Value: 0x%x\n",
 				  dev->name, err_mask);
 			dev->stats.rx_crc_errors++;
-			sp->mac_control.stats_info->sw_stat.mem_freed
+			swstats->mem_freed
 				+= skb->truesize;
 			dev_kfree_skb(skb);
 			ring_data->rx_bufs_left -= 1;
@@ -7545,13 +7510,11 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 					queue_rx_frame(lro->parent,
 						       lro->vlan_tag);
 					clear_lro_session(lro);
-					sp->mac_control.stats_info->
-						sw_stat.flush_max_pkts++;
+					swstats->flush_max_pkts++;
 					goto aggregate;
 				case 2: /* Flush both */
 					lro->parent->data_len = lro->frags_len;
-					sp->mac_control.stats_info->
-						sw_stat.sending_both++;
+					swstats->sending_both++;
 					queue_rx_frame(lro->parent,
 						       lro->vlan_tag);
 					clear_lro_session(lro);
@@ -7580,7 +7543,7 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 	} else
 		skb->ip_summed = CHECKSUM_NONE;
 
-	sp->mac_control.stats_info->sw_stat.mem_freed += skb->truesize;
+	swstats->mem_freed += skb->truesize;
 send_up:
 	skb_record_rx_queue(skb, ring_no);
 	queue_rx_frame(skb, RXD_GET_VLAN_TAG(rxdp->Control_2));
@@ -7605,6 +7568,7 @@ aggregate:
 static void s2io_link(struct s2io_nic *sp, int link)
 {
 	struct net_device *dev = (struct net_device *)sp->dev;
+	struct swStat *swstats = &sp->mac_control.stats_info->sw_stat;
 
 	if (link != sp->last_link_state) {
 		init_tti(sp, link);
@@ -7612,17 +7576,16 @@ static void s2io_link(struct s2io_nic *sp, int link)
 			DBG_PRINT(ERR_DBG, "%s: Link down\n", dev->name);
 			s2io_stop_all_tx_queue(sp);
 			netif_carrier_off(dev);
-			if (sp->mac_control.stats_info->sw_stat.link_up_cnt)
-				sp->mac_control.stats_info->sw_stat.
-					link_up_time = jiffies - sp->start_time;
-			sp->mac_control.stats_info->sw_stat.link_down_cnt++;
+			if (swstats->link_up_cnt)
+				swstats->link_up_time =
+					jiffies - sp->start_time;
+			swstats->link_down_cnt++;
 		} else {
 			DBG_PRINT(ERR_DBG, "%s: Link Up\n", dev->name);
-			if (sp->mac_control.stats_info->sw_stat.link_down_cnt)
-				sp->mac_control.stats_info->
-					sw_stat.link_down_time =
+			if (swstats->link_down_cnt)
+				swstats->link_down_time =
 					jiffies - sp->start_time;
-			sp->mac_control.stats_info->sw_stat.link_up_cnt++;
+			swstats->link_up_cnt++;
 			netif_carrier_on(dev);
 			s2io_wake_all_tx_queue(sp);
 		}
@@ -7800,8 +7763,8 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	u64 val64 = 0, tmp64 = 0;
 	struct XENA_dev_config __iomem *bar0 = NULL;
 	u16 subid;
-	struct mac_info *mac_control;
 	struct config_param *config;
+	struct mac_info *mac_control;
 	int mode;
 	u8 dev_intr_type = intr_type;
 	u8 dev_multiq = 0;
@@ -7887,8 +7850,8 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	 * these parameters are not not specified during load time, they
 	 * are initialized with default values.
 	 */
-	mac_control = &sp->mac_control;
 	config = &sp->config;
+	mac_control = &sp->mac_control;
 
 	config->napi = napi;
 	config->tx_steering_type = tx_steering_type;
@@ -8433,7 +8396,8 @@ static void update_L3L4_header(struct s2io_nic *sp, struct lro *lro)
 	struct iphdr *ip = lro->iph;
 	struct tcphdr *tcp = lro->tcph;
 	__sum16 nchk;
-	struct stat_block *statinfo = sp->mac_control.stats_info;
+	struct swStat *swstats = &sp->mac_control.stats_info->sw_stat;
+
 	DBG_PRINT(INFO_DBG, "%s: Been here...\n", __func__);
 
 	/* Update L3 header */
@@ -8455,8 +8419,8 @@ static void update_L3L4_header(struct s2io_nic *sp, struct lro *lro)
 	/* Update counters required for calculation of
 	 * average no. of packets aggregated.
 	 */
-	statinfo->sw_stat.sum_avg_pkts_aggregated += lro->sg_num;
-	statinfo->sw_stat.num_aggregations++;
+	swstats->sum_avg_pkts_aggregated += lro->sg_num;
+	swstats->num_aggregations++;
 }
 
 static void aggregate_new_rx(struct lro *lro, struct iphdr *ip,
@@ -8547,6 +8511,7 @@ static int s2io_club_tcp_session(struct ring_info *ring_data, u8 *buffer,
 	struct tcphdr *tcph;
 	int ret = 0, i;
 	u16 vlan_tag = 0;
+	struct swStat *swstats = &sp->mac_control.stats_info->sw_stat;
 
 	ret = check_L2_lro_capable(buffer, &ip, (struct tcphdr **)tcp,
 				   rxdp, sp);
@@ -8572,8 +8537,7 @@ static int s2io_club_tcp_session(struct ring_info *ring_data, u8 *buffer,
 					  (*lro)->tcp_next_seq,
 					  ntohl(tcph->seq));
 
-				sp->mac_control.stats_info->
-					sw_stat.outof_sequence_pkts++;
+				swstats->outof_sequence_pkts++;
 				ret = 2;
 				break;
 			}
@@ -8667,6 +8631,7 @@ static void lro_append_pkt(struct s2io_nic *sp, struct lro *lro,
 			   struct sk_buff *skb, u32 tcp_len)
 {
 	struct sk_buff *first = lro->parent;
+	struct swStat *swstats = &sp->mac_control.stats_info->sw_stat;
 
 	first->len += tcp_len;
 	first->data_len = lro->frags_len;
@@ -8677,7 +8642,7 @@ static void lro_append_pkt(struct s2io_nic *sp, struct lro *lro,
 		skb_shinfo(first)->frag_list = skb;
 	first->truesize += skb->truesize;
 	lro->last_frag = skb;
-	sp->mac_control.stats_info->sw_stat.clubbed_frms_cnt++;
+	swstats->clubbed_frms_cnt++;
 	return;
 }
 
-- 
1.6.3.1.10.g659a0.dirty
