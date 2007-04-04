From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Wed, 4 Apr 2007 00:01:24 -0400
Message-ID: <20070404040124.GA19225@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:37388 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933274AbXDDEBa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2007 00:01:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/b44.c                 |    2 +-
 drivers/net/cxgb3/common.h        |    9 +++++--
 drivers/net/cxgb3/cxgb3_main.c    |   35 +++++++++++++++++++---------
 drivers/net/cxgb3/cxgb3_offload.c |    4 ++-
 drivers/net/cxgb3/mc5.c           |    3 ++
 drivers/net/cxgb3/regs.h          |    4 +++
 drivers/net/cxgb3/sge.c           |    2 +-
 drivers/net/cxgb3/t3_hw.c         |   24 ++++++++++++++-----
 drivers/net/cxgb3/version.h       |    5 +++-
 drivers/net/cxgb3/xgmac.c         |    1 -
 drivers/net/r8169.c               |   46 ++++++++++++++++++++-----------------
 11 files changed, 89 insertions(+), 46 deletions(-)

Bill Helfinstine (1):
      b44: fix IFF_ALLMULTI handling of CAM slots

Divy Le Ray (4):
      cxgb3 - Safeguard TCAM size usage
      cxgb3 - detect NIC only adapters
      cxgb3 - Tighten xgmac workaround
      cxgb3 - Firwmare update

Francois Romieu (2):
      r8169: issue request_irq after the private data are completely initialized
      r8169: fix suspend/resume for down interface

diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index aaada57..d742bfe 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -1709,7 +1709,7 @@ static void __b44_set_rx_mode(struct net_device *dev)
 		bw32(bp, B44_RXCONFIG, val);
 	} else {
 		unsigned char zero[6] = {0, 0, 0, 0, 0, 0};
-		int i = 0;
+		int i = 1;
 
 		__b44_set_mac_addr(bp);
 
diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 85e5543..97128d8 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -112,8 +112,7 @@ enum {
 };
 
 enum {
-	SUPPORTED_OFFLOAD = 1 << 24,
-	SUPPORTED_IRQ = 1 << 25
+	SUPPORTED_IRQ      = 1 << 24
 };
 
 enum {				/* adapter interrupt-maintained statistics */
@@ -358,6 +357,9 @@ enum {
 	MC5_MODE_72_BIT = 2
 };
 
+/* MC5 min active region size */
+enum { MC5_MIN_TIDS = 16 };
+
 struct vpd_params {
 	unsigned int cclk;
 	unsigned int mclk;
@@ -402,6 +404,7 @@ struct adapter_params {
 	unsigned int stats_update_period;	/* MAC stats accumulation period */
 	unsigned int linkpoll_period;	/* link poll period in 0.1s */
 	unsigned int rev;	/* chip revision */
+	unsigned int offload;
 };
 
 enum {					    /* chip revisions */
@@ -602,7 +605,7 @@ static inline int is_10G(const struct adapter *adap)
 
 static inline int is_offload(const struct adapter *adap)
 {
-	return adapter_info(adap)->caps & SUPPORTED_OFFLOAD;
+	return adap->params.offload;
 }
 
 static inline unsigned int core_ticks_per_usec(const struct adapter *adap)
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index d553836..26240fd 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -185,16 +185,26 @@ void t3_os_link_changed(struct adapter *adapter, int port_id, int link_stat,
 			int speed, int duplex, int pause)
 {
 	struct net_device *dev = adapter->port[port_id];
+	struct port_info *pi = netdev_priv(dev);
+	struct cmac *mac = &pi->mac;
 
 	/* Skip changes from disabled ports. */
 	if (!netif_running(dev))
 		return;
 
 	if (link_stat != netif_carrier_ok(dev)) {
-		if (link_stat)
+		if (link_stat) {
+			t3_set_reg_field(adapter,
+					 A_XGM_TXFIFO_CFG + mac->offset,
+					 F_ENDROPPKT, 0);
 			netif_carrier_on(dev);
-		else
+		} else {
 			netif_carrier_off(dev);
+			t3_set_reg_field(adapter,
+					 A_XGM_TXFIFO_CFG + mac->offset,
+					 F_ENDROPPKT, F_ENDROPPKT);
+		}
+
 		link_report(dev);
 	}
 }
@@ -407,7 +417,7 @@ static void quiesce_rx(struct adapter *adap)
 static int setup_sge_qsets(struct adapter *adap)
 {
 	int i, j, err, irq_idx = 0, qset_idx = 0, dummy_dev_idx = 0;
-	unsigned int ntxq = is_offload(adap) ? SGE_TXQ_PER_SET : 1;
+	unsigned int ntxq = SGE_TXQ_PER_SET;
 
 	if (adap->params.rev > 0 && !(adap->flags & USING_MSI))
 		irq_idx = -1;
@@ -485,12 +495,14 @@ static ssize_t show_##name(struct device *d, struct device_attribute *attr, \
 static ssize_t set_nfilters(struct net_device *dev, unsigned int val)
 {
 	struct adapter *adap = dev->priv;
+	int min_tids = is_offload(adap) ? MC5_MIN_TIDS : 0;
 
 	if (adap->flags & FULL_INIT_DONE)
 		return -EBUSY;
 	if (val && adap->params.rev == 0)
 		return -EINVAL;
-	if (val > t3_mc5_size(&adap->mc5) - adap->params.mc5.nservers)
+	if (val > t3_mc5_size(&adap->mc5) - adap->params.mc5.nservers -
+	    min_tids)
 		return -EINVAL;
 	adap->params.mc5.nfilters = val;
 	return 0;
@@ -508,7 +520,8 @@ static ssize_t set_nservers(struct net_device *dev, unsigned int val)
 
 	if (adap->flags & FULL_INIT_DONE)
 		return -EBUSY;
-	if (val > t3_mc5_size(&adap->mc5) - adap->params.mc5.nfilters)
+	if (val > t3_mc5_size(&adap->mc5) - adap->params.mc5.nfilters -
+	    MC5_MIN_TIDS)
 		return -EINVAL;
 	adap->params.mc5.nservers = val;
 	return 0;
@@ -708,7 +721,7 @@ static void bind_qsets(struct adapter *adap)
 	}
 }
 
-#define FW_FNAME "t3fw-%d.%d.bin"
+#define FW_FNAME "t3fw-%d.%d.%d.bin"
 
 static int upgrade_fw(struct adapter *adap)
 {
@@ -718,7 +731,7 @@ static int upgrade_fw(struct adapter *adap)
 	struct device *dev = &adap->pdev->dev;
 
 	snprintf(buf, sizeof(buf), FW_FNAME, FW_VERSION_MAJOR,
-		 FW_VERSION_MINOR);
+		 FW_VERSION_MINOR, FW_VERSION_MICRO);
 	ret = request_firmware(&fw, buf, dev);
 	if (ret < 0) {
 		dev_err(dev, "could not upgrade firmware: unable to load %s\n",
@@ -919,7 +932,7 @@ static int cxgb_open(struct net_device *dev)
 		return err;
 
 	set_bit(pi->port_id, &adapter->open_device_map);
-	if (!ofld_disable) {
+	if (is_offload(adapter) && !ofld_disable) {
 		err = offload_open(dev);
 		if (err)
 			printk(KERN_WARNING
@@ -2116,7 +2129,7 @@ static void check_t3b2_mac(struct adapter *adapter)
 			continue;
 
 		status = 0;
-		if (netif_running(dev))
+		if (netif_running(dev) && netif_carrier_ok(dev))
 			status = t3b2_mac_watchdog_task(&p->mac);
 		if (status == 1)
 			p->mac.stats.num_toggled++;
@@ -2267,9 +2280,9 @@ static void __devinit print_port_info(struct adapter *adap,
 
 		if (!test_bit(i, &adap->registered_device_map))
 			continue;
-		printk(KERN_INFO "%s: %s %s RNIC (rev %d) %s%s\n",
+		printk(KERN_INFO "%s: %s %s %sNIC (rev %d) %s%s\n",
 		       dev->name, ai->desc, pi->port_type->desc,
-		       adap->params.rev, buf,
+		       is_offload(adap) ? "R" : "", adap->params.rev, buf,
 		       (adap->flags & USING_MSIX) ? " MSI-X" :
 		       (adap->flags & USING_MSI) ? " MSI" : "");
 		if (adap->name == dev->name && adap->params.vpd.mclk)
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index f6ed033..eed7a48 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -553,7 +553,9 @@ int cxgb3_alloc_atid(struct t3cdev *tdev, struct cxgb3_client *client,
 	struct tid_info *t = &(T3C_DATA(tdev))->tid_maps;
 
 	spin_lock_bh(&t->atid_lock);
-	if (t->afree) {
+	if (t->afree &&
+	    t->atids_in_use + atomic_read(&t->tids_in_use) + MC5_MIN_TIDS <=
+	    t->ntids) {
 		union active_open_entry *p = t->afree;
 
 		atid = (p - t->atid_tab) + t->atid_base;
diff --git a/drivers/net/cxgb3/mc5.c b/drivers/net/cxgb3/mc5.c
index 644d62e..84c1ffa 100644
--- a/drivers/net/cxgb3/mc5.c
+++ b/drivers/net/cxgb3/mc5.c
@@ -328,6 +328,9 @@ int t3_mc5_init(struct mc5 *mc5, unsigned int nservers, unsigned int nfilters,
 	unsigned int tcam_size = mc5->tcam_size;
 	struct adapter *adap = mc5->adapter;
 
+	if (!tcam_size)
+		return 0;
+
 	if (nroutes > MAX_ROUTES || nroutes + nservers + nfilters > tcam_size)
 		return -EINVAL;
 
diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index b38629a..f8be41c 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -1940,6 +1940,10 @@
 
 #define V_TXFIFOTHRESH(x) ((x) << S_TXFIFOTHRESH)
 
+#define S_ENDROPPKT    21
+#define V_ENDROPPKT(x) ((x) << S_ENDROPPKT)
+#define F_ENDROPPKT    V_ENDROPPKT(1U)
+
 #define A_XGM_SERDES_CTRL 0x890
 #define A_XGM_SERDES_CTRL0 0x8e0
 
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index c237834..027ab2c 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -2631,7 +2631,7 @@ int t3_sge_alloc_qset(struct adapter *adapter, unsigned int id, int nports,
 	q->txq[TXQ_ETH].stop_thres = nports *
 	    flits_to_desc(sgl_len(MAX_SKB_FRAGS + 1) + 3);
 
-	if (ntxq == 1) {
+	if (!is_offload(adapter)) {
 #ifdef USE_RX_PAGE
 		q->fl[0].buf_size = RX_PAGE_SIZE;
 #else
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 791ed6d..d83f075 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -438,23 +438,23 @@ static const struct adapter_info t3_adap_info[] = {
 	{2, 0, 0, 0,
 	 F_GPIO2_OEN | F_GPIO4_OEN |
 	 F_GPIO2_OUT_VAL | F_GPIO4_OUT_VAL, F_GPIO3 | F_GPIO5,
-	 SUPPORTED_OFFLOAD,
+	 0,
 	 &mi1_mdio_ops, "Chelsio PE9000"},
 	{2, 0, 0, 0,
 	 F_GPIO2_OEN | F_GPIO4_OEN |
 	 F_GPIO2_OUT_VAL | F_GPIO4_OUT_VAL, F_GPIO3 | F_GPIO5,
-	 SUPPORTED_OFFLOAD,
+	 0,
 	 &mi1_mdio_ops, "Chelsio T302"},
 	{1, 0, 0, 0,
 	 F_GPIO1_OEN | F_GPIO6_OEN | F_GPIO7_OEN | F_GPIO10_OEN |
 	 F_GPIO1_OUT_VAL | F_GPIO6_OUT_VAL | F_GPIO10_OUT_VAL, 0,
-	 SUPPORTED_10000baseT_Full | SUPPORTED_AUI | SUPPORTED_OFFLOAD,
+	 SUPPORTED_10000baseT_Full | SUPPORTED_AUI,
 	 &mi1_mdio_ext_ops, "Chelsio T310"},
 	{2, 0, 0, 0,
 	 F_GPIO1_OEN | F_GPIO2_OEN | F_GPIO4_OEN | F_GPIO5_OEN | F_GPIO6_OEN |
 	 F_GPIO7_OEN | F_GPIO10_OEN | F_GPIO11_OEN | F_GPIO1_OUT_VAL |
 	 F_GPIO5_OUT_VAL | F_GPIO6_OUT_VAL | F_GPIO10_OUT_VAL, 0,
-	 SUPPORTED_10000baseT_Full | SUPPORTED_AUI | SUPPORTED_OFFLOAD,
+	 SUPPORTED_10000baseT_Full | SUPPORTED_AUI,
 	 &mi1_mdio_ext_ops, "Chelsio T320"},
 };
 
@@ -2900,6 +2900,9 @@ static int mc7_init(struct mc7 *mc7, unsigned int mc7_clock, int mem_type)
 	struct adapter *adapter = mc7->adapter;
 	const struct mc7_timing_params *p = &mc7_timings[mem_type];
 
+	if (!mc7->size)
+		return 0;
+
 	val = t3_read_reg(adapter, mc7->offset + A_MC7_CFG);
 	slow = val & F_SLOW;
 	width = G_WIDTH(val);
@@ -3100,8 +3103,10 @@ int t3_init_hw(struct adapter *adapter, u32 fw_params)
 	do {			/* wait for uP to initialize */
 		msleep(20);
 	} while (t3_read_reg(adapter, A_CIM_HOST_ACC_DATA) && --attempts);
-	if (!attempts)
+	if (!attempts) {
+		CH_ERR(adapter, "uP initialization timed out\n");
 		goto out_err;
+	}
 
 	err = 0;
 out_err:
@@ -3201,7 +3206,7 @@ static void __devinit mc7_prep(struct adapter *adapter, struct mc7 *mc7,
 	mc7->name = name;
 	mc7->offset = base_addr - MC7_PMRX_BASE_ADDR;
 	cfg = t3_read_reg(adapter, mc7->offset + A_MC7_CFG);
-	mc7->size = mc7_calc_size(cfg);
+	mc7->size = mc7->size = G_DEN(cfg) == M_DEN ? 0 : mc7_calc_size(cfg);
 	mc7->width = G_WIDTH(cfg);
 }
 
@@ -3228,6 +3233,7 @@ void early_hw_init(struct adapter *adapter, const struct adapter_info *ai)
 		     V_I2C_CLKDIV(adapter->params.vpd.cclk / 80 - 1));
 	t3_write_reg(adapter, A_T3DBG_GPIO_EN,
 		     ai->gpio_out | F_GPIO0_OEN | F_GPIO0_OUT_VAL);
+	t3_write_reg(adapter, A_MC5_DB_SERVER_INDEX, 0);
 
 	if (adapter->params.rev == 0 || !uses_xaui(adapter))
 		val |= F_ENRGMII;
@@ -3326,7 +3332,13 @@ int __devinit t3_prep_adapter(struct adapter *adapter,
 		p->tx_num_pgs = pm_num_pages(p->chan_tx_size, p->tx_pg_size);
 		p->ntimer_qs = p->cm_size >= (128 << 20) ||
 		    adapter->params.rev > 0 ? 12 : 6;
+	}
+
+	adapter->params.offload = t3_mc7_size(&adapter->pmrx) &&
+				  t3_mc7_size(&adapter->pmtx) &&
+				  t3_mc7_size(&adapter->cm);
 
+	if (is_offload(adapter)) {
 		adapter->params.mc5.nservers = DEFAULT_NSERVERS;
 		adapter->params.mc5.nfilters = adapter->params.rev > 0 ?
 		    DEFAULT_NFILTERS : 0;
diff --git a/drivers/net/cxgb3/version.h b/drivers/net/cxgb3/version.h
index 82278f8..042e27e 100644
--- a/drivers/net/cxgb3/version.h
+++ b/drivers/net/cxgb3/version.h
@@ -36,6 +36,9 @@
 #define DRV_NAME "cxgb3"
 /* Driver version */
 #define DRV_VERSION "1.0-ko"
+
+/* Firmware version */
 #define FW_VERSION_MAJOR 3
-#define FW_VERSION_MINOR 2
+#define FW_VERSION_MINOR 3
+#define FW_VERSION_MICRO 0
 #endif				/* __CHELSIO_VERSION_H */
diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index 2b42c13..94aaff0 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -471,7 +471,6 @@ const struct mac_stats *t3_mac_update_stats(struct cmac *mac)
 	RMON_UPDATE(mac, rx_symbol_errs, RX_SYM_CODE_ERR_FRAMES);
 
 	RMON_UPDATE(mac, rx_too_long, RX_OVERSIZE_FRAMES);
-	mac->stats.rx_too_long += RMON_READ(mac, A_XGM_RX_MAX_PKT_SIZE_ERR_CNT);
 
 	v = RMON_READ(mac, A_XGM_RX_MAX_PKT_SIZE_ERR_CNT);
 	if (mac->adapter->params.rev == T3_REV_B2)
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 521b5f0..6a77b8a 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -66,6 +66,7 @@ VERSION 2.2LK	<2005/01/25>
 #include <linux/init.h>
 #include <linux/dma-mapping.h>
 
+#include <asm/system.h>
 #include <asm/io.h>
 #include <asm/irq.h>
 
@@ -486,6 +487,7 @@ static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
 				void __iomem *);
 static int rtl8169_change_mtu(struct net_device *dev, int new_mtu);
 static void rtl8169_down(struct net_device *dev);
+static void rtl8169_rx_clear(struct rtl8169_private *tp);
 
 #ifdef CONFIG_R8169_NAPI
 static int rtl8169_poll(struct net_device *dev, int *budget);
@@ -1751,16 +1753,10 @@ static int rtl8169_open(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct pci_dev *pdev = tp->pci_dev;
-	int retval;
+	int retval = -ENOMEM;
 
-	rtl8169_set_rxbufsize(tp, dev);
-
-	retval =
-	    request_irq(dev->irq, rtl8169_interrupt, IRQF_SHARED, dev->name, dev);
-	if (retval < 0)
-		goto out;
 
-	retval = -ENOMEM;
+	rtl8169_set_rxbufsize(tp, dev);
 
 	/*
 	 * Rx and Tx desscriptors needs 256 bytes alignment.
@@ -1769,19 +1765,26 @@ static int rtl8169_open(struct net_device *dev)
 	tp->TxDescArray = pci_alloc_consistent(pdev, R8169_TX_RING_BYTES,
 					       &tp->TxPhyAddr);
 	if (!tp->TxDescArray)
-		goto err_free_irq;
+		goto out;
 
 	tp->RxDescArray = pci_alloc_consistent(pdev, R8169_RX_RING_BYTES,
 					       &tp->RxPhyAddr);
 	if (!tp->RxDescArray)
-		goto err_free_tx;
+		goto err_free_tx_0;
 
 	retval = rtl8169_init_ring(dev);
 	if (retval < 0)
-		goto err_free_rx;
+		goto err_free_rx_1;
 
 	INIT_DELAYED_WORK(&tp->task, NULL);
 
+	smp_mb();
+
+	retval = request_irq(dev->irq, rtl8169_interrupt, IRQF_SHARED,
+			     dev->name, dev);
+	if (retval < 0)
+		goto err_release_ring_2;
+
 	rtl8169_hw_start(dev);
 
 	rtl8169_request_timer(dev);
@@ -1790,14 +1793,14 @@ static int rtl8169_open(struct net_device *dev)
 out:
 	return retval;
 
-err_free_rx:
+err_release_ring_2:
+	rtl8169_rx_clear(tp);
+err_free_rx_1:
 	pci_free_consistent(pdev, R8169_RX_RING_BYTES, tp->RxDescArray,
 			    tp->RxPhyAddr);
-err_free_tx:
+err_free_tx_0:
 	pci_free_consistent(pdev, R8169_TX_RING_BYTES, tp->TxDescArray,
 			    tp->TxPhyAddr);
-err_free_irq:
-	free_irq(dev->irq, dev);
 	goto out;
 }
 
@@ -2887,7 +2890,7 @@ static int rtl8169_suspend(struct pci_dev *pdev, pm_message_t state)
 	void __iomem *ioaddr = tp->mmio_addr;
 
 	if (!netif_running(dev))
-		goto out;
+		goto out_pci_suspend;
 
 	netif_device_detach(dev);
 	netif_stop_queue(dev);
@@ -2901,10 +2904,11 @@ static int rtl8169_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	spin_unlock_irq(&tp->lock);
 
+out_pci_suspend:
 	pci_save_state(pdev);
 	pci_enable_wake(pdev, pci_choose_state(pdev, state), tp->wol_enabled);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
-out:
+
 	return 0;
 }
 
@@ -2912,15 +2916,15 @@ static int rtl8169_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+	pci_enable_wake(pdev, PCI_D0, 0);
+
 	if (!netif_running(dev))
 		goto out;
 
 	netif_device_attach(dev);
 
-	pci_set_power_state(pdev, PCI_D0);
-	pci_restore_state(pdev);
-	pci_enable_wake(pdev, PCI_D0, 0);
-
 	rtl8169_schedule_work(dev, rtl8169_reset_task);
 out:
 	return 0;
