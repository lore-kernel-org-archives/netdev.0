From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 1/7] drivers/net/chelsio: Use pr_<level>, netif_msg_<type>
Date: Mon, 22 Feb 2010 18:56:57 -0800
Message-ID: <819e937a3feefb278c2816db2947eff95dd6740a.1266893507.git.joe@perches.com>
References: <cover.1266893507.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1266893507.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert CH_<level> and CH_DBG uses to pr_<level> and netif equivalents
Remove CH_<level> and CH_DBG macro definitions

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/chelsio/common.h  |   24 ++----------------------
 drivers/net/chelsio/cxgb2.c   |   18 +++++++++---------
 drivers/net/chelsio/espi.c    |    4 ++--
 drivers/net/chelsio/pm3393.c  |   16 +++++++++-------
 drivers/net/chelsio/sge.c     |   10 +++++-----
 drivers/net/chelsio/subr.c    |   32 +++++++++++++++++---------------
 drivers/net/chelsio/vsc7326.c |   24 ++++++++++++------------
 7 files changed, 56 insertions(+), 72 deletions(-)

diff --git a/drivers/net/chelsio/common.h b/drivers/net/chelsio/common.h
index 9f89fd6..2d11afe 100644
--- a/drivers/net/chelsio/common.h
+++ b/drivers/net/chelsio/common.h
@@ -36,6 +36,8 @@
  *                                                                           *
  ****************************************************************************/
 
+#define pr_fmt(fmt) "cxgb: " fmt
+
 #ifndef _CXGB_COMMON_H_
 #define _CXGB_COMMON_H_
 
@@ -55,28 +57,6 @@
 #define DRV_DESCRIPTION "Chelsio 10Gb Ethernet Driver"
 #define DRV_NAME "cxgb"
 #define DRV_VERSION "2.2"
-#define PFX      DRV_NAME ": "
-
-#define CH_ERR(fmt, ...)   printk(KERN_ERR PFX fmt, ## __VA_ARGS__)
-#define CH_WARN(fmt, ...)  printk(KERN_WARNING PFX fmt, ## __VA_ARGS__)
-#define CH_ALERT(fmt, ...) printk(KERN_ALERT PFX fmt, ## __VA_ARGS__)
-
-/*
- * More powerful macro that selectively prints messages based on msg_enable.
- * For info and debugging messages.
- */
-#define CH_MSG(adapter, level, category, fmt, ...) do { \
-	if ((adapter)->msg_enable & NETIF_MSG_##category) \
-		printk(KERN_##level PFX "%s: " fmt, (adapter)->name, \
-		       ## __VA_ARGS__); \
-} while (0)
-
-#ifdef DEBUG
-# define CH_DBG(adapter, category, fmt, ...) \
-	CH_MSG(adapter, DEBUG, category, fmt, ## __VA_ARGS__)
-#else
-# define CH_DBG(fmt, ...)
-#endif
 
 #define CH_DEVICE(devid, ssid, idx) \
 	{ PCI_VENDOR_ID_CHELSIO, devid, PCI_ANY_ID, ssid, 0, 0, idx }
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index a54a32b..0f71304 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -974,7 +974,7 @@ void t1_fatal_err(struct adapter *adapter)
 		t1_sge_stop(adapter->sge);
 		t1_interrupts_disable(adapter);
 	}
-	CH_ALERT("%s: encountered fatal error, operation suspended\n",
+	pr_alert("%s: encountered fatal error, operation suspended\n",
 		 adapter->name);
 }
 
@@ -1018,7 +1018,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 		return err;
 
 	if (!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)) {
-		CH_ERR("%s: cannot find PCI device memory base address\n",
+		pr_err("%s: cannot find PCI device memory base address\n",
 		       pci_name(pdev));
 		err = -ENODEV;
 		goto out_disable_pdev;
@@ -1028,20 +1028,20 @@ static int __devinit init_one(struct pci_dev *pdev,
 		pci_using_dac = 1;
 
 		if (pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(64))) {
-			CH_ERR("%s: unable to obtain 64-bit DMA for "
+			pr_err("%s: unable to obtain 64-bit DMA for "
 			       "consistent allocations\n", pci_name(pdev));
 			err = -ENODEV;
 			goto out_disable_pdev;
 		}
 
 	} else if ((err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32))) != 0) {
-		CH_ERR("%s: no usable DMA configuration\n", pci_name(pdev));
+		pr_err("%s: no usable DMA configuration\n", pci_name(pdev));
 		goto out_disable_pdev;
 	}
 
 	err = pci_request_regions(pdev, DRV_NAME);
 	if (err) {
-		CH_ERR("%s: cannot obtain PCI resources\n", pci_name(pdev));
+		pr_err("%s: cannot obtain PCI resources\n", pci_name(pdev));
 		goto out_disable_pdev;
 	}
 
@@ -1069,7 +1069,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 
 			adapter->regs = ioremap(mmio_start, mmio_len);
 			if (!adapter->regs) {
-				CH_ERR("%s: cannot map device registers\n",
+				pr_err("%s: cannot map device registers\n",
 				       pci_name(pdev));
 				err = -ENOMEM;
 				goto out_free_dev;
@@ -1148,8 +1148,8 @@ static int __devinit init_one(struct pci_dev *pdev,
 	for (i = 0; i < bi->port_number; ++i) {
 		err = register_netdev(adapter->port[i].dev);
 		if (err)
-			CH_WARN("%s: cannot register net device %s, skipping\n",
-				pci_name(pdev), adapter->port[i].dev->name);
+			pr_warning("%s: cannot register net device %s, skipping\n",
+				   pci_name(pdev), adapter->port[i].dev->name);
 		else {
 			/*
 			 * Change the name we use for messages to the name of
@@ -1162,7 +1162,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 		}
 	}
 	if (!adapter->registered_device_map) {
-		CH_ERR("%s: could not register any net devices\n",
+		pr_err("%s: could not register any net devices\n",
 		       pci_name(pdev));
 		goto out_release_adapter_res;
 	}
diff --git a/drivers/net/chelsio/espi.c b/drivers/net/chelsio/espi.c
index 1e0749e..639ff19 100644
--- a/drivers/net/chelsio/espi.c
+++ b/drivers/net/chelsio/espi.c
@@ -76,7 +76,7 @@ static int tricn_write(adapter_t *adapter, int bundle_addr, int module_addr,
 	} while (busy && --attempts);
 
 	if (busy)
-		CH_ERR("%s: TRICN write timed out\n", adapter->name);
+		pr_err("%s: TRICN write timed out\n", adapter->name);
 
 	return busy;
 }
@@ -86,7 +86,7 @@ static int tricn_init(adapter_t *adapter)
 	int i, sme = 1;
 
 	if (!(readl(adapter->regs + A_ESPI_RX_RESET)  & F_RX_CLK_STATUS)) {
-		CH_ERR("%s: ESPI clock not ready\n", adapter->name);
+		pr_err("%s: ESPI clock not ready\n", adapter->name);
 		return -1;
 	}
 
diff --git a/drivers/net/chelsio/pm3393.c b/drivers/net/chelsio/pm3393.c
index 33d674f..a6eb30a 100644
--- a/drivers/net/chelsio/pm3393.c
+++ b/drivers/net/chelsio/pm3393.c
@@ -251,8 +251,9 @@ static int pm3393_interrupt_handler(struct cmac *cmac)
 	/* Read the master interrupt status register. */
 	pmread(cmac, SUNI1x10GEXP_REG_MASTER_INTERRUPT_STATUS,
 	       &master_intr_status);
-	CH_DBG(cmac->adapter, INTR, "PM3393 intr cause 0x%x\n",
-	       master_intr_status);
+	if (netif_msg_intr(cmac->adapter))
+		dev_dbg(&cmac->adapter->pdev->dev, "PM3393 intr cause 0x%x\n",
+			master_intr_status);
 
 	/* TBD XXX Lets just clear everything for now */
 	pm3393_interrupt_clear(cmac);
@@ -776,11 +777,12 @@ static int pm3393_mac_reset(adapter_t * adapter)
 		successful_reset = (is_pl4_reset_finished && !is_pl4_outof_lock
 				    && is_xaui_mabc_pll_locked);
 
-		CH_DBG(adapter, HW,
-		       "PM3393 HW reset %d: pl4_reset 0x%x, val 0x%x, "
-		       "is_pl4_outof_lock 0x%x, xaui_locked 0x%x\n",
-		       i, is_pl4_reset_finished, val, is_pl4_outof_lock,
-		       is_xaui_mabc_pll_locked);
+		if (netif_msg_hw(adapter))
+			dev_dbg(&adapter->pdev->dev,
+				"PM3393 HW reset %d: pl4_reset 0x%x, val 0x%x, "
+				"is_pl4_outof_lock 0x%x, xaui_locked 0x%x\n",
+				i, is_pl4_reset_finished, val,
+				is_pl4_outof_lock, is_xaui_mabc_pll_locked);
 	}
 	return successful_reset ? 0 : 1;
 }
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 8e12505..7138411 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -953,7 +953,7 @@ int t1_sge_intr_error_handler(struct sge *sge)
 		sge->stats.respQ_empty++;
 	if (cause & F_RESPQ_OVERFLOW) {
 		sge->stats.respQ_overflow++;
-		CH_ALERT("%s: SGE response queue overflow\n",
+		pr_alert("%s: SGE response queue overflow\n",
 			 adapter->name);
 	}
 	if (cause & F_FL_EXHAUSTED) {
@@ -962,12 +962,12 @@ int t1_sge_intr_error_handler(struct sge *sge)
 	}
 	if (cause & F_PACKET_TOO_BIG) {
 		sge->stats.pkt_too_big++;
-		CH_ALERT("%s: SGE max packet size exceeded\n",
+		pr_alert("%s: SGE max packet size exceeded\n",
 			 adapter->name);
 	}
 	if (cause & F_PACKET_MISMATCH) {
 		sge->stats.pkt_mismatch++;
-		CH_ALERT("%s: SGE packet mismatch\n", adapter->name);
+		pr_alert("%s: SGE packet mismatch\n", adapter->name);
 	}
 	if (cause & SGE_INT_FATAL)
 		t1_fatal_err(adapter);
@@ -1101,7 +1101,7 @@ static void unexpected_offload(struct adapter *adapter, struct freelQ *fl)
 
 	pci_dma_sync_single_for_cpu(adapter->pdev, pci_unmap_addr(ce, dma_addr),
 			    pci_unmap_len(ce, dma_len), PCI_DMA_FROMDEVICE);
-	CH_ERR("%s: unexpected offload packet, cmd %u\n",
+	pr_err("%s: unexpected offload packet, cmd %u\n",
 	       adapter->name, *skb->data);
 	recycle_fl_buf(fl, fl->cidx);
 }
@@ -1687,7 +1687,7 @@ static int t1_sge_tx(struct sk_buff *skb, struct adapter *adapter,
 			netif_stop_queue(dev);
 			set_bit(dev->if_port, &sge->stopped_tx_queues);
 			sge->stats.cmdQ_full[2]++;
-			CH_ERR("%s: Tx ring full while queue awake!\n",
+			pr_err("%s: Tx ring full while queue awake!\n",
 			       adapter->name);
 		}
 		spin_unlock(&q->lock);
diff --git a/drivers/net/chelsio/subr.c b/drivers/net/chelsio/subr.c
index 2402d37..2c2dda3 100644
--- a/drivers/net/chelsio/subr.c
+++ b/drivers/net/chelsio/subr.c
@@ -90,7 +90,7 @@ int __t1_tpi_write(adapter_t *adapter, u32 addr, u32 value)
 	tpi_busy = t1_wait_op_done(adapter, A_TPI_CSR, F_TPIRDY, 1,
 				   TPI_ATTEMPTS, 3);
 	if (tpi_busy)
-		CH_ALERT("%s: TPI write to 0x%x failed\n",
+		pr_alert("%s: TPI write to 0x%x failed\n",
 			 adapter->name, addr);
 	return tpi_busy;
 }
@@ -118,7 +118,7 @@ int __t1_tpi_read(adapter_t *adapter, u32 addr, u32 *valp)
 	tpi_busy = t1_wait_op_done(adapter, A_TPI_CSR, F_TPIRDY, 1,
 				   TPI_ATTEMPTS, 3);
 	if (tpi_busy)
-		CH_ALERT("%s: TPI read from 0x%x failed\n",
+		pr_alert("%s: TPI read from 0x%x failed\n",
 			 adapter->name, addr);
 	else
 		*valp = readl(adapter->regs + A_TPI_RD_DATA);
@@ -262,7 +262,7 @@ static int mi1_wait_until_ready(adapter_t *adapter, int mi1_reg)
 			udelay(10);
 	} while (busy && --attempts);
 	if (busy)
-		CH_ALERT("%s: MDIO operation timed out\n", adapter->name);
+		pr_alert("%s: MDIO operation timed out\n", adapter->name);
 	return busy;
 }
 
@@ -581,7 +581,7 @@ int t1_seeprom_read(adapter_t *adapter, u32 addr, __le32 *data)
 	} while (!(val & F_VPD_OP_FLAG) && --i);
 
 	if (!(val & F_VPD_OP_FLAG)) {
-		CH_ERR("%s: reading EEPROM address 0x%x failed\n",
+		pr_err("%s: reading EEPROM address 0x%x failed\n",
 		       adapter->name, addr);
 		return -EIO;
 	}
@@ -734,8 +734,9 @@ int t1_elmer0_ext_intr_handler(adapter_t *adapter)
 		break;
 	case CHBT_BOARD_8000:
 	case CHBT_BOARD_CHT110:
-		CH_DBG(adapter, INTR, "External interrupt cause 0x%x\n",
-		       cause);
+		if (netif_msg_intr(adapter))
+			dev_dbg(&adapter->pdev->dev, 
+				"External interrupt cause 0x%x\n", cause);
 		if (cause & ELMER0_GP_BIT1) {        /* PMC3393 INTB */
 			struct cmac *mac = adapter->port[0].mac;
 
@@ -746,8 +747,9 @@ int t1_elmer0_ext_intr_handler(adapter_t *adapter)
 
 			t1_tpi_read(adapter,
 					A_ELMER0_GPI_STAT, &mod_detect);
-			CH_MSG(adapter, INFO, LINK, "XPAK %s\n",
-			       mod_detect ? "removed" : "inserted");
+			if (netif_msg_link(adapter))
+				dev_info(&adapter->pdev->dev, "XPAK %s\n",
+					 mod_detect ? "removed" : "inserted");
 		}
 		break;
 #ifdef CONFIG_CHELSIO_T1_COUGAR
@@ -1084,7 +1086,7 @@ static void __devinit init_link_config(struct link_config *lc,
 
 #ifdef CONFIG_CHELSIO_T1_COUGAR
 	if (bi->clock_cspi && !(adapter->cspi = t1_cspi_create(adapter))) {
-		CH_ERR("%s: CSPI initialization failed\n",
+		pr_err("%s: CSPI initialization failed\n",
 		       adapter->name);
 		goto error;
 	}
@@ -1105,20 +1107,20 @@ int __devinit t1_init_sw_modules(adapter_t *adapter,
 
 	adapter->sge = t1_sge_create(adapter, &adapter->params.sge);
 	if (!adapter->sge) {
-		CH_ERR("%s: SGE initialization failed\n",
+		pr_err("%s: SGE initialization failed\n",
 		       adapter->name);
 		goto error;
 	}
 
 	if (bi->espi_nports && !(adapter->espi = t1_espi_create(adapter))) {
-		CH_ERR("%s: ESPI initialization failed\n",
+		pr_err("%s: ESPI initialization failed\n",
 		       adapter->name);
 		goto error;
 	}
 
 	adapter->tp = t1_tp_create(adapter, &adapter->params.tp);
 	if (!adapter->tp) {
-		CH_ERR("%s: TP initialization failed\n",
+		pr_err("%s: TP initialization failed\n",
 		       adapter->name);
 		goto error;
 	}
@@ -1138,14 +1140,14 @@ int __devinit t1_init_sw_modules(adapter_t *adapter,
 		adapter->port[i].phy = bi->gphy->create(adapter->port[i].dev,
 							phy_addr, bi->mdio_ops);
 		if (!adapter->port[i].phy) {
-			CH_ERR("%s: PHY %d initialization failed\n",
+			pr_err("%s: PHY %d initialization failed\n",
 			       adapter->name, i);
 			goto error;
 		}
 
 		adapter->port[i].mac = mac = bi->gmac->create(adapter, i);
 		if (!mac) {
-			CH_ERR("%s: MAC %d initialization failed\n",
+			pr_err("%s: MAC %d initialization failed\n",
 			       adapter->name, i);
 			goto error;
 		}
@@ -1157,7 +1159,7 @@ int __devinit t1_init_sw_modules(adapter_t *adapter,
 		if (!t1_is_asic(adapter) || bi->chip_mac == CHBT_MAC_DUMMY)
 			mac->ops->macaddress_get(mac, hw_addr);
 		else if (vpd_macaddress_get(adapter, i, hw_addr)) {
-			CH_ERR("%s: could not read MAC address from VPD ROM\n",
+			pr_err("%s: could not read MAC address from VPD ROM\n",
 			       adapter->port[i].dev->name);
 			goto error;
 		}
diff --git a/drivers/net/chelsio/vsc7326.c b/drivers/net/chelsio/vsc7326.c
index 99b51f6..c844111 100644
--- a/drivers/net/chelsio/vsc7326.c
+++ b/drivers/net/chelsio/vsc7326.c
@@ -48,14 +48,14 @@ static void vsc_read(adapter_t *adapter, u32 addr, u32 *val)
 		i++;
 	} while (((status & 1) == 0) && (i < 50));
 	if (i == 50)
-		CH_ERR("Invalid tpi read from MAC, breaking loop.\n");
+		pr_err("Invalid tpi read from MAC, breaking loop.\n");
 
 	t1_tpi_read(adapter, (REG_LOCAL_DATA << 2) + 4, &vlo);
 	t1_tpi_read(adapter, REG_LOCAL_DATA << 2, &vhi);
 
 	*val = (vhi << 16) | vlo;
 
-	/* CH_ERR("rd: block: 0x%x  sublock: 0x%x  reg: 0x%x  data: 0x%x\n",
+	/* pr_err("rd: block: 0x%x  sublock: 0x%x  reg: 0x%x  data: 0x%x\n",
 		((addr&0xe000)>>13), ((addr&0x1e00)>>9),
 		((addr&0x01fe)>>1), *val); */
 	spin_unlock_bh(&adapter->mac_lock);
@@ -66,7 +66,7 @@ static void vsc_write(adapter_t *adapter, u32 addr, u32 data)
 	spin_lock_bh(&adapter->mac_lock);
 	t1_tpi_write(adapter, (addr << 2) + 4, data & 0xFFFF);
 	t1_tpi_write(adapter, addr << 2, (data >> 16) & 0xFFFF);
-	/* CH_ERR("wr: block: 0x%x  sublock: 0x%x  reg: 0x%x  data: 0x%x\n",
+	/* pr_err("wr: block: 0x%x  sublock: 0x%x  reg: 0x%x  data: 0x%x\n",
 		((addr&0xe000)>>13), ((addr&0x1e00)>>9),
 		((addr&0x01fe)>>1), data); */
 	spin_unlock_bh(&adapter->mac_lock);
@@ -225,7 +225,7 @@ static void run_table(adapter_t *adapter, struct init_table *ib, int len)
 	for (i = 0; i < len; i++) {
 		if (ib[i].addr == INITBLOCK_SLEEP) {
 			udelay( ib[i].data );
-			CH_ERR("sleep %d us\n",ib[i].data);
+			pr_err("sleep %d us\n",ib[i].data);
 		} else
 			vsc_write( adapter, ib[i].addr, ib[i].data );
 	}
@@ -241,7 +241,7 @@ static int bist_rd(adapter_t *adapter, int moduleid, int address)
 	    (address != 0x2) &&
 	    (address != 0xd) &&
 	    (address != 0xe))
-			CH_ERR("No bist address: 0x%x\n", address);
+			pr_err("No bist address: 0x%x\n", address);
 
 	data = ((0x00 << 24) | ((address & 0xff) << 16) | (0x00 << 8) |
 		((moduleid & 0xff) << 0));
@@ -251,9 +251,9 @@ static int bist_rd(adapter_t *adapter, int moduleid, int address)
 
 	vsc_read(adapter, REG_RAM_BIST_RESULT, &result);
 	if ((result & (1 << 9)) != 0x0)
-		CH_ERR("Still in bist read: 0x%x\n", result);
+		pr_err("Still in bist read: 0x%x\n", result);
 	else if ((result & (1 << 8)) != 0x0)
-		CH_ERR("bist read error: 0x%x\n", result);
+		pr_err("bist read error: 0x%x\n", result);
 
 	return (result & 0xff);
 }
@@ -268,10 +268,10 @@ static int bist_wr(adapter_t *adapter, int moduleid, int address, int value)
 	    (address != 0x2) &&
 	    (address != 0xd) &&
 	    (address != 0xe))
-			CH_ERR("No bist address: 0x%x\n", address);
+			pr_err("No bist address: 0x%x\n", address);
 
 	if (value > 255)
-		CH_ERR("Suspicious write out of range value: 0x%x\n", value);
+		pr_err("Suspicious write out of range value: 0x%x\n", value);
 
 	data = ((0x01 << 24) | ((address & 0xff) << 16) | (value << 8) |
 		((moduleid & 0xff) << 0));
@@ -281,9 +281,9 @@ static int bist_wr(adapter_t *adapter, int moduleid, int address, int value)
 
 	vsc_read(adapter, REG_RAM_BIST_CMD, &result);
 	if ((result & (1 << 27)) != 0x0)
-		CH_ERR("Still in bist write: 0x%x\n", result);
+		pr_err("Still in bist write: 0x%x\n", result);
 	else if ((result & (1 << 26)) != 0x0)
-		CH_ERR("bist write error: 0x%x\n", result);
+		pr_err("bist write error: 0x%x\n", result);
 
 	return 0;
 }
@@ -306,7 +306,7 @@ static int check_bist(adapter_t *adapter, int moduleid)
 	column = ((bist_rd(adapter,moduleid, 0x0e)<<8) +
 			(bist_rd(adapter,moduleid, 0x0d)));
 	if ((result & 3) != 0x3)
-		CH_ERR("Result: 0x%x  BIST error in ram %d, column: 0x%04x\n",
+		pr_err("Result: 0x%x  BIST error in ram %d, column: 0x%04x\n",
 			result, moduleid, column);
 	return 0;
 }
-- 
1.7.0.14.g7e948
