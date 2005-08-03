From: raghavendra.koushik@neterion.com
Subject: [PATCH 2.6.13-rc4 3/13] S2io: Software fixes
Date: Wed,  3 Aug 2005 12:29:20 -0700 (PDT)
Message-ID: <20050803192920.5FB9798336@linux.site>
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
        leonid.grossman@neterion.com, rapuru.sriram@neterion.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
Below patch includes fixes for few purely software bugs identified
since last release.
1. Keep track and display(as part of ethtool command output) the no. 
   of single-bit and double-bit ECC errors.
2. Handle race condition between intr handler and "interface down"
   routine.
3. Initial link state setting modified so that the link state displayed
   after "interface Up" is correct.
4. Fix for "Incorrect Tx packet count when TSO is enabled".
5. Disable periodic DMA of statistics and schedule one-shot DMA
   only when required.

Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
Signed-off-by: Raghavendra Koushik <raghavendra.koushik@neterion.com>
---
diff -uprN vanilla_linux/drivers/net/s2io.c linux-2.6.13-rc4/drivers/net/s2io.c
--- vanilla_linux/drivers/net/s2io.c	2005-08-02 02:40:31.000000000 -0700
+++ linux-2.6.13-rc4/drivers/net/s2io.c	2005-08-02 02:31:47.000000000 -0700
@@ -158,6 +158,9 @@ static char ethtool_stats_keys[][ETH_GST
 	{"rmac_pause_cnt"},
 	{"rmac_accepted_ip"},
 	{"rmac_err_tcp"},
+	{"\n DRIVER STATISTICS"},
+	{"single_bit_ecc_errs"},
+	{"double_bit_ecc_errs"},
 };
 
 #define S2IO_STAT_LEN sizeof(ethtool_stats_keys)/ ETH_GSTRING_LEN
@@ -237,7 +240,6 @@ static unsigned int tx_fifo_len[MAX_TX_F
 static unsigned int rx_ring_num = 1;
 static unsigned int rx_ring_sz[MAX_RX_RINGS] =
     {[0 ...(MAX_RX_RINGS - 1)] = 0 };
-static unsigned int Stats_refresh_time = 4;
 static unsigned int rts_frm_len[MAX_RX_RINGS] =
     {[0 ...(MAX_RX_RINGS - 1)] = 0 };
 static unsigned int use_continuous_tx_intrs = 1;
@@ -1083,9 +1085,6 @@ static int init_nic(struct s2io_nic *nic
 
 	/* Program statistics memory */
 	writeq(mac_control->stats_mem_phy, &bar0->stat_addr);
-	val64 = SET_UPDT_PERIOD(Stats_refresh_time) |
-		STAT_CFG_STAT_RO | STAT_CFG_STAT_EN;
-	writeq(val64, &bar0->stat_cfg);
 
 	/*
 	 * Initializing the sampling rate for the device to calculate the
@@ -2101,6 +2100,7 @@ static int s2io_poll(struct net_device *
 	u64 val64;
 	int i;
 
+	atomic_inc(&nic->isr_cnt);
 	mac_control = &nic->mac_control;
 	config = &nic->config;
 
@@ -2136,6 +2136,7 @@ static int s2io_poll(struct net_device *
 	}
 	/* Re enable the Rx interrupts. */
 	en_dis_able_nic_intrs(nic, RX_TRAFFIC_INTR, ENABLE_INTRS);
+	atomic_dec(&nic->isr_cnt);
 	return 0;
 
 no_rx:
@@ -2149,6 +2150,7 @@ no_rx:
 			break;
 		}
 	}
+	atomic_dec(&nic->isr_cnt);
 	return 1;
 }
 #endif
@@ -2179,6 +2181,13 @@ static void rx_intr_handler(ring_info_t 
 #endif
 	register u64 val64;
 
+	spin_lock(&nic->rx_lock);
+	if (atomic_read(&nic->card_state) == CARD_DOWN) {
+		DBG_PRINT(ERR_DBG, "%s: %s going down for reset\n",
+			  __FUNCTION__, dev->name);
+		spin_unlock(&nic->rx_lock);
+	}
+
 	/*
 	 * rx_traffic_int reg is an R1 register, hence we read and write
 	 * back the same value in the register to clear it
@@ -2210,6 +2219,7 @@ static void rx_intr_handler(ring_info_t 
 			DBG_PRINT(ERR_DBG, "%s: The skb is ",
 				  dev->name);
 			DBG_PRINT(ERR_DBG, "Null in Rx Intr\n");
+			spin_unlock(&nic->rx_lock);
 			return;
 		}
 #ifndef CONFIG_2BUFF_MODE
@@ -2262,6 +2272,7 @@ static void rx_intr_handler(ring_info_t 
 			break;
 #endif
 	}
+	spin_unlock(&nic->rx_lock);
 }
 
 /**
@@ -2345,7 +2356,6 @@ static void tx_intr_handler(fifo_info_t 
 		       (sizeof(TxD_t) * fifo_data->max_txds));
 
 		/* Updating the statistics block */
-		nic->stats.tx_packets++;
 		nic->stats.tx_bytes += skb->len;
 		dev_kfree_skb_irq(skb);
 
@@ -2393,13 +2403,16 @@ static void alarm_intr_handler(struct s2
 	writeq(val64, &bar0->mc_err_reg);
 	if (val64 & (MC_ERR_REG_ECC_ALL_SNG | MC_ERR_REG_ECC_ALL_DBL)) {
 		if (val64 & MC_ERR_REG_ECC_ALL_DBL) {
+			nic->mac_control.stats_info->sw_stat.
+				double_ecc_errs++;
 			DBG_PRINT(ERR_DBG, "%s: Device indicates ",
 				  dev->name);
 			DBG_PRINT(ERR_DBG, "double ECC error!!\n");
 			netif_stop_queue(dev);
 			schedule_work(&nic->rst_timer_task);
 		} else {
-			/* Device can recover from Single ECC errors */
+			nic->mac_control.stats_info->sw_stat.
+				single_ecc_errs++;
 		}
 	}
 
@@ -2695,7 +2708,7 @@ int s2io_open(struct net_device *dev)
 	 * Nic is initialized
 	 */
 	netif_carrier_off(dev);
-	sp->last_link_state = LINK_DOWN;
+	sp->last_link_state = 0; /* Unkown link state */
 
 	/* Initialize H/W and enable interrupts */
 	if (s2io_card_up(sp)) {
@@ -2909,6 +2922,7 @@ static irqreturn_t s2io_isr(int irq, voi
 	mac_info_t *mac_control;
 	struct config_param *config;
 
+	atomic_inc(&sp->isr_cnt);
 	mac_control = &sp->mac_control;
 	config = &sp->config;
 
@@ -2924,6 +2938,7 @@ static irqreturn_t s2io_isr(int irq, voi
 
 	if (!reason) {
 		/* The interrupt was not raised by Xena. */
+		atomic_dec(&sp->isr_cnt);
 		return IRQ_NONE;
 	}
 
@@ -2972,6 +2987,7 @@ static irqreturn_t s2io_isr(int irq, voi
 					  dev->name);
 				DBG_PRINT(ERR_DBG, " in ISR!!\n");
 				clear_bit(0, (&sp->tasklet_status));
+				atomic_dec(&sp->isr_cnt);
 				return IRQ_HANDLED;
 			}
 			clear_bit(0, (&sp->tasklet_status));
@@ -2981,10 +2997,37 @@ static irqreturn_t s2io_isr(int irq, voi
 	}
 #endif
 
+	atomic_dec(&sp->isr_cnt);
 	return IRQ_HANDLED;
 }
 
 /**
+ * s2io_updt_stats -
+ */
+static void s2io_updt_stats(nic_t *sp)
+{
+	XENA_dev_config_t __iomem *bar0 = sp->bar0;
+	u64 val64;
+	int cnt = 0;
+
+	if (atomic_read(&sp->card_state) == CARD_UP) {
+		/* Apprx 30us on a 133 MHz bus */
+		val64 = SET_UPDT_CLICKS(10) |
+			STAT_CFG_ONE_SHOT_EN | STAT_CFG_STAT_EN;
+		writeq(val64, &bar0->stat_cfg);
+		do {
+			udelay(100);
+			val64 = readq(&bar0->stat_cfg);
+			if (!(val64 & BIT(0)))
+				break;
+			cnt++;
+			if (cnt == 5)
+				break; /* Updt failed */
+		} while(1);
+	}
+}
+
+/**
  *  s2io_get_stats - Updates the device statistics structure.
  *  @dev : pointer to the device structure.
  *  Description:
@@ -3004,6 +3047,11 @@ struct net_device_stats *s2io_get_stats(
 	mac_control = &sp->mac_control;
 	config = &sp->config;
 
+	/* Configure Stats for immediate updt */
+	s2io_updt_stats(sp);
+
+	sp->stats.tx_packets =
+		le32_to_cpu(mac_control->stats_info->tmac_frms);
 	sp->stats.tx_errors =
 		le32_to_cpu(mac_control->stats_info->tmac_any_err_frms);
 	sp->stats.rx_errors =
@@ -4018,6 +4066,7 @@ static void s2io_get_ethtool_stats(struc
 	nic_t *sp = dev->priv;
 	StatInfo_t *stat_info = sp->mac_control.stats_info;
 
+	s2io_updt_stats(sp);
 	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_frms);
 	tmp_stats[i++] = le32_to_cpu(stat_info->tmac_data_octets);
 	tmp_stats[i++] = le64_to_cpu(stat_info->tmac_drop_frms);
@@ -4057,6 +4106,9 @@ static void s2io_get_ethtool_stats(struc
 	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_pause_cnt);
 	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_accepted_ip);
 	tmp_stats[i++] = le32_to_cpu(stat_info->rmac_err_tcp);
+	tmp_stats[i++] = 0;
+	tmp_stats[i++] = stat_info->sw_stat.single_ecc_errs;
+	tmp_stats[i++] = stat_info->sw_stat.double_ecc_errs;
 }
 
 int s2io_ethtool_get_regs_len(struct net_device *dev)
@@ -4353,14 +4405,27 @@ static void s2io_card_down(nic_t * sp)
 			break;
 		}
 	} while (1);
-	spin_lock_irqsave(&sp->tx_lock, flags);
 	s2io_reset(sp);
 
-	/* Free all unused Tx and Rx buffers */
+	/* Waiting till all Interrupt handlers are complete */
+	cnt = 0;
+	do {
+		msleep(10);
+		if (!atomic_read(&sp->isr_cnt))
+			break;
+		cnt++;
+	} while(cnt < 5);
+
+	spin_lock_irqsave(&sp->tx_lock, flags);
+	/* Free all Tx buffers */
 	free_tx_buffers(sp);
+	spin_unlock_irqrestore(&sp->tx_lock, flags);
+
+	/* Free all Rx buffers */
+	spin_lock_irqsave(&sp->rx_lock, flags);
 	free_rx_buffers(sp);
+	spin_unlock_irqrestore(&sp->rx_lock, flags);
 
-	spin_unlock_irqrestore(&sp->tx_lock, flags);
 	clear_bit(0, &(sp->link_state));
 }
 
@@ -4647,7 +4712,6 @@ module_param(tx_fifo_num, int, 0);
 module_param(rx_ring_num, int, 0);
 module_param_array(tx_fifo_len, uint, NULL, 0);
 module_param_array(rx_ring_sz, uint, NULL, 0);
-module_param(Stats_refresh_time, int, 0);
 module_param_array(rts_frm_len, uint, NULL, 0);
 module_param(use_continuous_tx_intrs, int, 1);
 module_param(rmac_pause_time, int, 0);
@@ -4804,6 +4868,9 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	for (i = 0; i < config->rx_ring_num; i++)
 		atomic_set(&sp->rx_bufs_left[i], 0);
 
+	/* Initialize the number of ISRs currently running */
+	atomic_set(&sp->isr_cnt, 0);
+
 	/*  initialize the shared memory used by the NIC and the host */
 	if (init_shared_mem(sp)) {
 		DBG_PRINT(ERR_DBG, "%s: Memory allocation failed\n",
@@ -4938,6 +5005,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 #ifndef CONFIG_S2IO_NAPI
 	spin_lock_init(&sp->put_lock);
 #endif
+	spin_lock_init(&sp->rx_lock);
 
 	/*
 	 * SXE-002: Configure link and activity LED to init state
@@ -4961,13 +5029,16 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		goto register_failed;
 	}
 
+	/* Initialize device name */
+	strcpy(sp->name, dev->name);
+	strcat(sp->name, ": Neterion Xframe I 10GbE adapter");
+
 	/*
 	 * Make Link state as off at this point, when the Link change
 	 * interrupt comes the state will be automatically changed to
 	 * the right state.
 	 */
 	netif_carrier_off(dev);
-	sp->last_link_state = LINK_DOWN;
 
 	return 0;
 
diff -uprN vanilla_linux/drivers/net/s2io.h linux-2.6.13-rc4/drivers/net/s2io.h
--- vanilla_linux/drivers/net/s2io.h	2005-08-02 02:32:11.000000000 -0700
+++ linux-2.6.13-rc4/drivers/net/s2io.h	2005-08-02 02:31:51.000000000 -0700
@@ -195,6 +195,9 @@ typedef struct stat_block {
 	u32 rxd_rd_cnt;
 	u32 rxf_wr_cnt;
 	u32 txf_rd_cnt;
+
+/* Software statistics maintained by driver */
+	swStat_t sw_stat;
 } StatInfo_t;
 
 /*
@@ -678,6 +681,8 @@ struct s2io_nic {
 #define CARD_UP 2
 	atomic_t card_state;
 	volatile unsigned long link_state;
+	spinlock_t	rx_lock;
+	atomic_t	isr_cnt;
 };
 
 #define RESET_ERROR 1;
