From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Fri, 23 Mar 2007 02:57:42 -0400
Message-ID: <20070323065742.GA17613@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:52840 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933942AbXCWG5o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 02:57:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/Kconfig                          |   25 ++--
 drivers/net/cxgb3/common.h                   |   15 ++
 drivers/net/cxgb3/cxgb3_main.c               |   90 ++++++++++++--
 drivers/net/cxgb3/regs.h                     |   22 +++
 drivers/net/cxgb3/t3_hw.c                    |   15 ++-
 drivers/net/cxgb3/xgmac.c                    |  133 +++++++++++++++++--
 drivers/net/ewrk3.c                          |    3 +-
 drivers/net/mv643xx_eth.c                    |   14 ++
 drivers/net/myri10ge/myri10ge.c              |   22 +++-
 drivers/net/pci-skeleton.c                   |    4 +-
 drivers/net/saa9730.c                        |  177 +++++++++++++-------------
 drivers/net/skge.c                           |  110 +++++++++-------
 drivers/net/skge.h                           |    6 +-
 drivers/net/ucc_geth.c                       |    3 +-
 drivers/net/wireless/airo.c                  |    4 +-
 drivers/net/wireless/bcm43xx/bcm43xx_radio.c |   14 +-
 16 files changed, 460 insertions(+), 197 deletions(-)

Anton Blanchard (1):
      Fix return code in pci-skeleton.c

Brice Goglin (4):
      myri10ge: Serverworks HT2100 provides aligned PCIe completion
      myri10ge: update wcfifo and intr_coal_delay default values
      myri10ge: fix management of >4kB allocated pages
      myri10ge: update driver version to 1.3.0-1.226

Dale Farnsworth (1):
      mv643xx_eth: add mv643xx_eth_shutdown function

Divy Le Ray (5):
      cxgb3 - fix ethtool cmd on multiple queues port
      cxgb3 - Auto-load FW if mismatch detected
      cxgb3 - Fix potential MAC hang
      cxgb3 - T3B2 pcie config space
      cxgb3 - fix white spaces in drivers/net/Kconfig

Jeff Garzik (1):
      [netdrvr] ewrk3: correct card detection bug

Larry Finger (1):
      bcm43xx: MANUALWLAN fixes

Li Yang (1):
      Revert "ucc_geth: returns NETDEV_TX_BUSY when BD ring is full"

Michal Schmidt (1):
      airo: Fix an error path memory leak

Ralf Baechle (1):
      SAA9730: Fix large pile of warnings

Stephen Hemminger (3):
      skge: deadlock on tx timeout
      skge: mask irqs when device down
      skge: use per-port phy locking

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 5ff0922..c3f9f59 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2372,22 +2372,23 @@ config CHELSIO_T1_NAPI
 	  when the driver is receiving lots of packets from the card.
 
 config CHELSIO_T3
-        tristate "Chelsio Communications T3 10Gb Ethernet support"
-        depends on PCI
-        help
-          This driver supports Chelsio T3-based gigabit and 10Gb Ethernet
-          adapters.
+	tristate "Chelsio Communications T3 10Gb Ethernet support"
+	depends on PCI
+	select FW_LOADER
+	help
+	  This driver supports Chelsio T3-based gigabit and 10Gb Ethernet
+	  adapters.
 
-          For general information about Chelsio and our products, visit
-          our website at <http://www.chelsio.com>.
+	  For general information about Chelsio and our products, visit
+	  our website at <http://www.chelsio.com>.
 
-          For customer support, please visit our customer support page at
-          <http://www.chelsio.com/support.htm>.
+	  For customer support, please visit our customer support page at
+	  <http://www.chelsio.com/support.htm>.
 
-          Please send feedback to <linux-bugs@chelsio.com>.
+	  Please send feedback to <linux-bugs@chelsio.com>.
 
-          To compile this driver as a module, choose M here: the module
-          will be called cxgb3.
+	  To compile this driver as a module, choose M here: the module
+	  will be called cxgb3.
 
 config EHEA
 	tristate "eHEA Ethernet support"
diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index e23deeb..85e5543 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -260,6 +260,10 @@ struct mac_stats {
 	unsigned long serdes_signal_loss;
 	unsigned long xaui_pcs_ctc_err;
 	unsigned long xaui_pcs_align_change;
+
+	unsigned long num_toggled; /* # times toggled TxEn due to stuck TX */
+	unsigned long num_resets;  /* # times reset due to stuck TX */
+
 };
 
 struct tp_mib_stats {
@@ -400,6 +404,12 @@ struct adapter_params {
 	unsigned int rev;	/* chip revision */
 };
 
+enum {					    /* chip revisions */
+	T3_REV_A  = 0,
+	T3_REV_B  = 2,
+	T3_REV_B2 = 3,
+};
+
 struct trace_params {
 	u32 sip;
 	u32 sip_mask;
@@ -465,6 +475,10 @@ struct cmac {
 	struct adapter *adapter;
 	unsigned int offset;
 	unsigned int nucast;	/* # of address filters for unicast MACs */
+	unsigned int tcnt;
+	unsigned int xcnt;
+	unsigned int toggle_cnt;
+	unsigned int txen;
 	struct mac_stats stats;
 };
 
@@ -666,6 +680,7 @@ int t3_mac_set_address(struct cmac *mac, unsigned int idx, u8 addr[6]);
 int t3_mac_set_num_ucast(struct cmac *mac, int n);
 const struct mac_stats *t3_mac_update_stats(struct cmac *mac);
 int t3_mac_set_speed_duplex_fc(struct cmac *mac, int speed, int duplex, int fc);
+int t3b2_mac_watchdog_task(struct cmac *mac);
 
 void t3_mc5_prep(struct adapter *adapter, struct mc5 *mc5, int mode);
 int t3_mc5_init(struct mc5 *mc5, unsigned int nservers, unsigned int nfilters,
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 7ff834e..d553836 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -42,6 +42,7 @@
 #include <linux/workqueue.h>
 #include <linux/proc_fs.h>
 #include <linux/rtnetlink.h>
+#include <linux/firmware.h>
 #include <asm/uaccess.h>
 
 #include "common.h"
@@ -707,6 +708,28 @@ static void bind_qsets(struct adapter *adap)
 	}
 }
 
+#define FW_FNAME "t3fw-%d.%d.bin"
+
+static int upgrade_fw(struct adapter *adap)
+{
+	int ret;
+	char buf[64];
+	const struct firmware *fw;
+	struct device *dev = &adap->pdev->dev;
+
+	snprintf(buf, sizeof(buf), FW_FNAME, FW_VERSION_MAJOR,
+		 FW_VERSION_MINOR);
+	ret = request_firmware(&fw, buf, dev);
+	if (ret < 0) {
+		dev_err(dev, "could not upgrade firmware: unable to load %s\n",
+			buf);
+		return ret;
+	}
+	ret = t3_load_fw(adap, fw->data, fw->size);
+	release_firmware(fw);
+	return ret;
+}
+
 /**
  *	cxgb_up - enable the adapter
  *	@adapter: adapter being enabled
@@ -723,6 +746,8 @@ static int cxgb_up(struct adapter *adap)
 
 	if (!(adap->flags & FULL_INIT_DONE)) {
 		err = t3_check_fw_version(adap);
+		if (err == -EINVAL)
+			err = upgrade_fw(adap);
 		if (err)
 			goto out;
 
@@ -1031,7 +1056,11 @@ static char stats_strings[][ETH_GSTRING_LEN] = {
 	"VLANinsertions     ",
 	"TxCsumOffload      ",
 	"RxCsumGood         ",
-	"RxDrops            "
+	"RxDrops            ",
+
+	"CheckTXEnToggled   ",
+	"CheckResets        ",
+
 };
 
 static int get_stats_count(struct net_device *dev)
@@ -1145,6 +1174,9 @@ static void get_stats(struct net_device *dev, struct ethtool_stats *stats,
 	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_TX_CSUM);
 	*data++ = collect_sge_port_stats(adapter, pi, SGE_PSTAT_RX_CSUM_GOOD);
 	*data++ = s->rx_cong_drops;
+
+	*data++ = s->num_toggled;
+	*data++ = s->num_resets;
 }
 
 static inline void reg_block_dump(struct adapter *ap, void *buf,
@@ -1362,23 +1394,27 @@ static int set_rx_csum(struct net_device *dev, u32 data)
 
 static void get_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 {
-	struct adapter *adapter = dev->priv;
+	const struct adapter *adapter = dev->priv;
+	const struct port_info *pi = netdev_priv(dev);
+	const struct qset_params *q = &adapter->params.sge.qset[pi->first_qset];
 
 	e->rx_max_pending = MAX_RX_BUFFERS;
 	e->rx_mini_max_pending = 0;
 	e->rx_jumbo_max_pending = MAX_RX_JUMBO_BUFFERS;
 	e->tx_max_pending = MAX_TXQ_ENTRIES;
 
-	e->rx_pending = adapter->params.sge.qset[0].fl_size;
-	e->rx_mini_pending = adapter->params.sge.qset[0].rspq_size;
-	e->rx_jumbo_pending = adapter->params.sge.qset[0].jumbo_size;
-	e->tx_pending = adapter->params.sge.qset[0].txq_size[0];
+	e->rx_pending = q->fl_size;
+	e->rx_mini_pending = q->rspq_size;
+	e->rx_jumbo_pending = q->jumbo_size;
+	e->tx_pending = q->txq_size[0];
 }
 
 static int set_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 {
 	int i;
+	struct qset_params *q;
 	struct adapter *adapter = dev->priv;
+	const struct port_info *pi = netdev_priv(dev);
 
 	if (e->rx_pending > MAX_RX_BUFFERS ||
 	    e->rx_jumbo_pending > MAX_RX_JUMBO_BUFFERS ||
@@ -1393,9 +1429,8 @@ static int set_sge_param(struct net_device *dev, struct ethtool_ringparam *e)
 	if (adapter->flags & FULL_INIT_DONE)
 		return -EBUSY;
 
-	for (i = 0; i < SGE_QSETS; ++i) {
-		struct qset_params *q = &adapter->params.sge.qset[i];
-
+	q = &adapter->params.sge.qset[pi->first_qset];
+	for (i = 0; i < pi->nqsets; ++i, ++q) {
 		q->rspq_size = e->rx_mini_pending;
 		q->fl_size = e->rx_pending;
 		q->jumbo_size = e->rx_jumbo_pending;
@@ -2067,6 +2102,40 @@ static void check_link_status(struct adapter *adapter)
 	}
 }
 
+static void check_t3b2_mac(struct adapter *adapter)
+{
+	int i;
+
+	rtnl_lock();                      /* synchronize with ifdown */
+	for_each_port(adapter, i) {
+		struct net_device *dev = adapter->port[i];
+		struct port_info *p = netdev_priv(dev);
+		int status;
+
+		if (!netif_running(dev))
+			continue;
+
+		status = 0;
+		if (netif_running(dev))
+			status = t3b2_mac_watchdog_task(&p->mac);
+		if (status == 1)
+			p->mac.stats.num_toggled++;
+		else if (status == 2) {
+			struct cmac *mac = &p->mac;
+
+			t3_mac_set_mtu(mac, dev->mtu);
+			t3_mac_set_address(mac, 0, dev->dev_addr);
+			cxgb_set_rxmode(dev);
+			t3_link_start(&p->phy, mac, &p->link_config);
+			t3_mac_enable(mac, MAC_DIRECTION_RX | MAC_DIRECTION_TX);
+			t3_port_intr_enable(adapter, p->port_id);
+			p->mac.stats.num_resets++;
+		}
+	}
+	rtnl_unlock();
+}
+
+
 static void t3_adap_check_task(struct work_struct *work)
 {
 	struct adapter *adapter = container_of(work, struct adapter,
@@ -2087,6 +2156,9 @@ static void t3_adap_check_task(struct work_struct *work)
 		adapter->check_task_cnt = 0;
 	}
 
+	if (p->rev == T3_REV_B2)
+		check_t3b2_mac(adapter);
+
 	/* Schedule the next check update if any port is active. */
 	spin_lock(&adapter->work_lock);
 	if (adapter->open_device_map & PORT_MASK)
diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/cxgb3/regs.h
index b56c5f5..b38629a 100644
--- a/drivers/net/cxgb3/regs.h
+++ b/drivers/net/cxgb3/regs.h
@@ -1206,6 +1206,14 @@
 
 #define A_TP_RX_TRC_KEY0 0x120
 
+#define A_TP_TX_DROP_CNT_CH0 0x12d
+
+#define S_TXDROPCNTCH0RCVD    0
+#define M_TXDROPCNTCH0RCVD    0xffff
+#define V_TXDROPCNTCH0RCVD(x) ((x) << S_TXDROPCNTCH0RCVD)
+#define G_TXDROPCNTCH0RCVD(x) (((x) >> S_TXDROPCNTCH0RCVD) & \
+			       M_TXDROPCNTCH0RCVD)
+
 #define A_ULPRX_CTL 0x500
 
 #define S_ROUND_ROBIN    4
@@ -1834,6 +1842,8 @@
 #define V_TXPAUSEEN(x) ((x) << S_TXPAUSEEN)
 #define F_TXPAUSEEN    V_TXPAUSEEN(1U)
 
+#define A_XGM_TX_PAUSE_QUANTA 0x808
+
 #define A_XGM_RX_CTRL 0x80c
 
 #define S_RXEN    0
@@ -1920,6 +1930,11 @@
 
 #define A_XGM_TXFIFO_CFG 0x888
 
+#define S_TXIPG    13
+#define M_TXIPG    0xff
+#define V_TXIPG(x) ((x) << S_TXIPG)
+#define G_TXIPG(x) (((x) >> S_TXIPG) & M_TXIPG)
+
 #define S_TXFIFOTHRESH    4
 #define M_TXFIFOTHRESH    0x1ff
 
@@ -2190,6 +2205,13 @@
 
 #define A_XGM_RX_MAX_PKT_SIZE_ERR_CNT 0x9a4
 
+#define A_XGM_TX_SPI4_SOP_EOP_CNT 0x9a8
+
+#define S_TXSPI4SOPCNT    16
+#define M_TXSPI4SOPCNT    0xffff
+#define V_TXSPI4SOPCNT(x) ((x) << S_TXSPI4SOPCNT)
+#define G_TXSPI4SOPCNT(x) (((x) >> S_TXSPI4SOPCNT) & M_TXSPI4SOPCNT)
+
 #define A_XGM_RX_SPI4_SOP_EOP_CNT 0x9ac
 
 #define XGMAC0_1_BASE_ADDR 0xa00
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index eaa7a2e..791ed6d 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -681,7 +681,8 @@ enum {
 	SF_ERASE_SECTOR = 0xd8,	/* erase sector */
 
 	FW_FLASH_BOOT_ADDR = 0x70000,	/* start address of FW in flash */
-	FW_VERS_ADDR = 0x77ffc	/* flash address holding FW version */
+	FW_VERS_ADDR = 0x77ffc,    /* flash address holding FW version */
+	FW_MIN_SIZE = 8            /* at least version and csum */
 };
 
 /**
@@ -935,7 +936,7 @@ int t3_load_fw(struct adapter *adapter, const u8 *fw_data, unsigned int size)
 	const u32 *p = (const u32 *)fw_data;
 	int ret, addr, fw_sector = FW_FLASH_BOOT_ADDR >> 16;
 
-	if (size & 3)
+	if ((size & 3) || size < FW_MIN_SIZE)
 		return -EINVAL;
 	if (size > FW_VERS_ADDR + 8 - FW_FLASH_BOOT_ADDR)
 		return -EFBIG;
@@ -3243,15 +3244,17 @@ void early_hw_init(struct adapter *adapter, const struct adapter_info *ai)
 }
 
 /*
- * Reset the adapter.  PCIe cards lose their config space during reset, PCI-X
+ * Reset the adapter. 
+ * Older PCIe cards lose their config space during reset, PCI-X
  * ones don't.
  */
 int t3_reset_adapter(struct adapter *adapter)
 {
-	int i;
+	int i, save_and_restore_pcie = 
+	    adapter->params.rev < T3_REV_B2 && is_pcie(adapter);
 	uint16_t devid = 0;
 
-	if (is_pcie(adapter))
+	if (save_and_restore_pcie)
 		pci_save_state(adapter->pdev);
 	t3_write_reg(adapter, A_PL_RST, F_CRSTWRM | F_CRSTWRMMODE);
 
@@ -3269,7 +3272,7 @@ int t3_reset_adapter(struct adapter *adapter)
 	if (devid != 0x1425)
 		return -1;
 
-	if (is_pcie(adapter))
+	if (save_and_restore_pcie)
 		pci_restore_state(adapter->pdev);
 	return 0;
 }
diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index 907a272..2b42c13 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -124,9 +124,6 @@ int t3_mac_reset(struct cmac *mac)
 			xaui_serdes_reset(mac);
 	}
 
-	if (adap->params.rev > 0)
-		t3_write_reg(adap, A_XGM_PAUSE_TIMER + oft, 0xf000);
-
 	val = F_MAC_RESET_;
 	if (is_10G(adap))
 		val |= F_PCS_RESET_;
@@ -145,6 +142,58 @@ int t3_mac_reset(struct cmac *mac)
 	return 0;
 }
 
+int t3b2_mac_reset(struct cmac *mac)
+{
+	struct adapter *adap = mac->adapter;
+	unsigned int oft = mac->offset;
+	u32 val;
+
+	if (!macidx(mac)) 
+		t3_set_reg_field(adap, A_MPS_CFG, F_PORT0ACTIVE, 0);
+	else
+		t3_set_reg_field(adap, A_MPS_CFG, F_PORT1ACTIVE, 0);
+
+	t3_write_reg(adap, A_XGM_RESET_CTRL + oft, F_MAC_RESET_);
+	t3_read_reg(adap, A_XGM_RESET_CTRL + oft);    /* flush */
+
+	msleep(10);
+
+	/* Check for xgm Rx fifo empty */
+	if (t3_wait_op_done(adap, A_XGM_RX_MAX_PKT_SIZE_ERR_CNT + oft,
+			    0x80000000, 1, 5, 2)) {
+		CH_ERR(adap, "MAC %d Rx fifo drain failed\n",
+		       macidx(mac));
+		return -1;
+	}
+
+	t3_write_reg(adap, A_XGM_RESET_CTRL + oft, 0);
+	t3_read_reg(adap, A_XGM_RESET_CTRL + oft);    /* flush */
+
+	val = F_MAC_RESET_;
+	if (is_10G(adap))
+		val |= F_PCS_RESET_;
+	else if (uses_xaui(adap))
+		val |= F_PCS_RESET_ | F_XG2G_RESET_;
+	else
+		val |= F_RGMII_RESET_ | F_XG2G_RESET_;
+	t3_write_reg(adap, A_XGM_RESET_CTRL + oft, val);
+	t3_read_reg(adap, A_XGM_RESET_CTRL + oft);  /* flush */
+	if ((val & F_PCS_RESET_) && adap->params.rev) {
+		msleep(1);
+		t3b_pcs_reset(mac);
+	}
+	t3_write_reg(adap, A_XGM_RX_CFG + oft, 
+		     F_DISPAUSEFRAMES | F_EN1536BFRAMES |
+		     F_RMFCS | F_ENJUMBO | F_ENHASHMCAST);
+
+	if (!macidx(mac)) 
+		t3_set_reg_field(adap, A_MPS_CFG, 0, F_PORT0ACTIVE);
+	else
+		t3_set_reg_field(adap, A_MPS_CFG, 0, F_PORT1ACTIVE);
+
+	return 0;
+}
+
 /*
  * Set the exact match register 'idx' to recognize the given Ethernet address.
  */
@@ -251,9 +300,11 @@ int t3_mac_set_mtu(struct cmac *mac, unsigned int mtu)
 	 * Adjust the PAUSE frame watermarks.  We always set the LWM, and the
 	 * HWM only if flow-control is enabled.
 	 */
-	hwm = max(MAC_RXFIFO_SIZE - 3 * mtu, MAC_RXFIFO_SIZE / 2U);
-	hwm = min(hwm, 3 * MAC_RXFIFO_SIZE / 4 + 1024);
-	lwm = hwm - 1024;
+	hwm = max_t(unsigned int, MAC_RXFIFO_SIZE - 3 * mtu, 
+		    MAC_RXFIFO_SIZE * 38 / 100);
+	hwm = min(hwm, MAC_RXFIFO_SIZE - 8192);
+	lwm = min(3 * (int)mtu, MAC_RXFIFO_SIZE / 4);
+
 	v = t3_read_reg(adap, A_XGM_RXFIFO_CFG + mac->offset);
 	v &= ~V_RXFIFOPAUSELWM(M_RXFIFOPAUSELWM);
 	v |= V_RXFIFOPAUSELWM(lwm / 8);
@@ -270,7 +321,15 @@ int t3_mac_set_mtu(struct cmac *mac, unsigned int mtu)
 	thres = mtu > thres ? (mtu - thres + 7) / 8 : 0;
 	thres = max(thres, 8U);	/* need at least 8 */
 	t3_set_reg_field(adap, A_XGM_TXFIFO_CFG + mac->offset,
-			 V_TXFIFOTHRESH(M_TXFIFOTHRESH), V_TXFIFOTHRESH(thres));
+			 V_TXFIFOTHRESH(M_TXFIFOTHRESH) | V_TXIPG(M_TXIPG),
+			 V_TXFIFOTHRESH(thres) | V_TXIPG(1));
+
+	if (adap->params.rev > 0)
+		t3_write_reg(adap, A_XGM_PAUSE_TIMER + mac->offset,
+			     (hwm - lwm) * 4 / 8);
+	t3_write_reg(adap, A_XGM_TX_PAUSE_QUANTA + mac->offset,
+		     MAC_RXFIFO_SIZE * 4 * 8 / 512);
+
 	return 0;
 }
 
@@ -298,12 +357,6 @@ int t3_mac_set_speed_duplex_fc(struct cmac *mac, int speed, int duplex, int fc)
 				 V_PORTSPEED(M_PORTSPEED), val);
 	}
 
-	val = t3_read_reg(adap, A_XGM_RXFIFO_CFG + oft);
-	val &= ~V_RXFIFOPAUSEHWM(M_RXFIFOPAUSEHWM);
-	if (fc & PAUSE_TX)
-		val |= V_RXFIFOPAUSEHWM(G_RXFIFOPAUSELWM(val) + 128);	/* +1KB */
-	t3_write_reg(adap, A_XGM_RXFIFO_CFG + oft, val);
-
 	t3_set_reg_field(adap, A_XGM_TX_CFG + oft, F_TXPAUSEEN,
 			 (fc & PAUSE_RX) ? F_TXPAUSEEN : 0);
 	return 0;
@@ -318,9 +371,17 @@ int t3_mac_enable(struct cmac *mac, int which)
 	if (which & MAC_DIRECTION_TX) {
 		t3_write_reg(adap, A_XGM_TX_CTRL + oft, F_TXEN);
 		t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_CFG_CH0 + idx);
-		t3_write_reg(adap, A_TP_PIO_DATA, 0xbf000001);
+		t3_write_reg(adap, A_TP_PIO_DATA, 0xc0ede401);
 		t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_MODE);
 		t3_set_reg_field(adap, A_TP_PIO_DATA, 1 << idx, 1 << idx);
+
+		t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_CNT_CH0 + idx);
+		mac->tcnt = (G_TXDROPCNTCH0RCVD(t3_read_reg(adap,
+							    A_TP_PIO_DATA)));
+		mac->xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap,
+						A_XGM_TX_SPI4_SOP_EOP_CNT)));
+		mac->txen = F_TXEN;
+		mac->toggle_cnt = 0;
 	}
 	if (which & MAC_DIRECTION_RX)
 		t3_write_reg(adap, A_XGM_RX_CTRL + oft, F_RXEN);
@@ -337,13 +398,50 @@ int t3_mac_disable(struct cmac *mac, int which)
 		t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_CFG_CH0 + idx);
 		t3_write_reg(adap, A_TP_PIO_DATA, 0xc000001f);
 		t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_MODE);
-		t3_set_reg_field(adap, A_TP_PIO_DATA, 1 << idx, 0);
+		t3_set_reg_field(adap, A_TP_PIO_DATA, 1 << idx, 1 << idx);
+		mac->txen = 0;
 	}
 	if (which & MAC_DIRECTION_RX)
 		t3_write_reg(adap, A_XGM_RX_CTRL + mac->offset, 0);
 	return 0;
 }
 
+int t3b2_mac_watchdog_task(struct cmac *mac)
+{
+	struct adapter *adap = mac->adapter;
+	unsigned int tcnt, xcnt;
+	int status;
+
+	t3_write_reg(adap, A_TP_PIO_ADDR, A_TP_TX_DROP_CNT_CH0 + macidx(mac));
+	tcnt = (G_TXDROPCNTCH0RCVD(t3_read_reg(adap, A_TP_PIO_DATA)));
+	xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap, 
+					   A_XGM_TX_SPI4_SOP_EOP_CNT +
+					   mac->offset)));
+
+	if (tcnt != mac->tcnt && xcnt == 0 && mac->xcnt == 0) {
+		if (mac->toggle_cnt > 4) {
+			t3b2_mac_reset(mac);
+			mac->toggle_cnt = 0;
+			status = 2;
+		} else {
+			t3_write_reg(adap, A_XGM_TX_CTRL + mac->offset, 0);
+			t3_read_reg(adap, A_XGM_TX_CTRL + mac->offset);
+			t3_write_reg(adap, A_XGM_TX_CTRL + mac->offset,
+				     mac->txen);
+			t3_read_reg(adap, A_XGM_TX_CTRL + mac->offset);
+			mac->toggle_cnt++;
+			status = 1;
+		}	
+	} else {
+		mac->toggle_cnt = 0;
+		status = 0;
+	}
+	mac->tcnt = tcnt;
+	mac->xcnt = xcnt;
+
+	return status;
+}
+
 /*
  * This function is called periodically to accumulate the current values of the
  * RMON counters into the port statistics.  Since the packet counters are only
@@ -375,6 +473,11 @@ const struct mac_stats *t3_mac_update_stats(struct cmac *mac)
 	RMON_UPDATE(mac, rx_too_long, RX_OVERSIZE_FRAMES);
 	mac->stats.rx_too_long += RMON_READ(mac, A_XGM_RX_MAX_PKT_SIZE_ERR_CNT);
 
+	v = RMON_READ(mac, A_XGM_RX_MAX_PKT_SIZE_ERR_CNT);
+	if (mac->adapter->params.rev == T3_REV_B2)
+		v &= 0x7fffffff;
+	mac->stats.rx_too_long += v;
+
 	RMON_UPDATE(mac, rx_frames_64, RX_64B_FRAMES);
 	RMON_UPDATE(mac, rx_frames_65_127, RX_65_127B_FRAMES);
 	RMON_UPDATE(mac, rx_frames_128_255, RX_128_255B_FRAMES);
diff --git a/drivers/net/ewrk3.c b/drivers/net/ewrk3.c
index c8c41f0..714ea11 100644
--- a/drivers/net/ewrk3.c
+++ b/drivers/net/ewrk3.c
@@ -414,10 +414,9 @@ ewrk3_hw_init(struct net_device *dev, u_long iobase)
 	icr &= 0x70;
 	outb(icr, EWRK3_ICR);	/* Disable all the IRQs */
 
-	if (nicsr == (CSR_TXD | CSR_RXD))
+	if (nicsr != (CSR_TXD | CSR_RXD))
 		return -ENXIO;
 
-
 	/* Check that the EEPROM is alive and well and not living on Pluto... */
 	for (chksum = 0, i = 0; i < EEPROM_MAX; i += 2) {
 		union {
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 1ee27c3..c9f55bc 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1516,9 +1516,23 @@ static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 	return 0;
 }
 
+static void mv643xx_eth_shutdown(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct mv643xx_private *mp = netdev_priv(dev);
+	unsigned int port_num = mp->port_num;
+
+	/* Mask all interrupts on ethernet port */
+	mv_write(MV643XX_ETH_INTERRUPT_MASK_REG(port_num), 0);
+	mv_read (MV643XX_ETH_INTERRUPT_MASK_REG(port_num));
+
+	eth_port_reset(port_num);
+}
+
 static struct platform_driver mv643xx_eth_driver = {
 	.probe = mv643xx_eth_probe,
 	.remove = mv643xx_eth_remove,
+	.shutdown = mv643xx_eth_shutdown,
 	.driver = {
 		.name = MV643XX_ETH_NAME,
 	},
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index ac02b3b..b05b20e 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -71,7 +71,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.2.0"
+#define MYRI10GE_VERSION_STR "1.3.0-1.226"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -234,7 +234,7 @@ static int myri10ge_msi = 1;	/* enable msi by default */
 module_param(myri10ge_msi, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(myri10ge_msi, "Enable Message Signalled Interrupts\n");
 
-static int myri10ge_intr_coal_delay = 25;
+static int myri10ge_intr_coal_delay = 75;
 module_param(myri10ge_intr_coal_delay, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_intr_coal_delay, "Interrupt coalescing delay\n");
 
@@ -279,7 +279,7 @@ static int myri10ge_fill_thresh = 256;
 module_param(myri10ge_fill_thresh, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(myri10ge_fill_thresh, "Number of empty rx slots allowed\n");
 
-static int myri10ge_wcfifo = 1;
+static int myri10ge_wcfifo = 0;
 module_param(myri10ge_wcfifo, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_wcfifo, "Enable WC Fifo when WC is enabled\n");
 
@@ -905,6 +905,14 @@ myri10ge_alloc_rx_pages(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
 		    (rx->page_offset + bytes <= MYRI10GE_ALLOC_SIZE)) {
 			/* we can use part of previous page */
 			get_page(rx->page);
+#if MYRI10GE_ALLOC_SIZE > 4096
+			/* Firmware cannot cross 4K boundary.. */
+			if ((rx->page_offset >> 12) !=
+			    ((rx->page_offset + bytes - 1) >> 12)) {
+				rx->page_offset =
+				    (rx->page_offset + bytes) & ~4095;
+			}
+#endif
 		} else {
 			/* we need a new page */
 			page =
@@ -2483,6 +2491,8 @@ static void myri10ge_enable_ecrc(struct myri10ge_priv *mgp)
 
 #define PCI_DEVICE_ID_INTEL_E5000_PCIE23 0x25f7
 #define PCI_DEVICE_ID_INTEL_E5000_PCIE47 0x25fa
+#define PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_FIRST 0x140
+#define PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_LAST 0x142
 
 static void myri10ge_select_firmware(struct myri10ge_priv *mgp)
 {
@@ -2514,6 +2524,12 @@ static void myri10ge_select_firmware(struct myri10ge_priv *mgp)
 			   ((bridge->vendor == PCI_VENDOR_ID_SERVERWORKS
 			     && bridge->device ==
 			     PCI_DEVICE_ID_SERVERWORKS_HT2000_PCIE)
+			    /* ServerWorks HT2100 */
+			    || (bridge->vendor == PCI_VENDOR_ID_SERVERWORKS
+				&& bridge->device >=
+				PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_FIRST
+				&& bridge->device <=
+				PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_LAST)
 			    /* All Intel E5000 PCIE ports */
 			    || (bridge->vendor == PCI_VENDOR_ID_INTEL
 				&& bridge->device >=
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index 00ca0fd..6ca4e4f 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -710,8 +710,8 @@ match:
 		tp->chipset,
 		rtl_chip_info[tp->chipset].name);
 
-	i = register_netdev (dev);
-	if (i)
+	rc = register_netdev (dev);
+	if (rc)
 		goto err_out_unmap;
 
 	DPRINTK ("EXIT, returning 0\n");
diff --git a/drivers/net/saa9730.c b/drivers/net/saa9730.c
index b269513..143958f 100644
--- a/drivers/net/saa9730.c
+++ b/drivers/net/saa9730.c
@@ -64,37 +64,37 @@ static unsigned int pci_irq_line;
 
 static void evm_saa9730_enable_lan_int(struct lan_saa9730_private *lp)
 {
-	outl(readl(&lp->evm_saa9730_regs->InterruptBlock1) | EVM_LAN_INT,
-	     &lp->evm_saa9730_regs->InterruptBlock1);
-	outl(readl(&lp->evm_saa9730_regs->InterruptStatus1) | EVM_LAN_INT,
-	     &lp->evm_saa9730_regs->InterruptStatus1);
-	outl(readl(&lp->evm_saa9730_regs->InterruptEnable1) | EVM_LAN_INT |
-	     EVM_MASTER_EN, &lp->evm_saa9730_regs->InterruptEnable1);
+	writel(readl(&lp->evm_saa9730_regs->InterruptBlock1) | EVM_LAN_INT,
+	       &lp->evm_saa9730_regs->InterruptBlock1);
+	writel(readl(&lp->evm_saa9730_regs->InterruptStatus1) | EVM_LAN_INT,
+	       &lp->evm_saa9730_regs->InterruptStatus1);
+	writel(readl(&lp->evm_saa9730_regs->InterruptEnable1) | EVM_LAN_INT |
+	       EVM_MASTER_EN, &lp->evm_saa9730_regs->InterruptEnable1);
 }
 
 static void evm_saa9730_disable_lan_int(struct lan_saa9730_private *lp)
 {
-	outl(readl(&lp->evm_saa9730_regs->InterruptBlock1) & ~EVM_LAN_INT,
-	     &lp->evm_saa9730_regs->InterruptBlock1);
-	outl(readl(&lp->evm_saa9730_regs->InterruptEnable1) & ~EVM_LAN_INT,
-	     &lp->evm_saa9730_regs->InterruptEnable1);
+	writel(readl(&lp->evm_saa9730_regs->InterruptBlock1) & ~EVM_LAN_INT,
+	       &lp->evm_saa9730_regs->InterruptBlock1);
+	writel(readl(&lp->evm_saa9730_regs->InterruptEnable1) & ~EVM_LAN_INT,
+	       &lp->evm_saa9730_regs->InterruptEnable1);
 }
 
 static void evm_saa9730_clear_lan_int(struct lan_saa9730_private *lp)
 {
-	outl(EVM_LAN_INT, &lp->evm_saa9730_regs->InterruptStatus1);
+	writel(EVM_LAN_INT, &lp->evm_saa9730_regs->InterruptStatus1);
 }
 
 static void evm_saa9730_block_lan_int(struct lan_saa9730_private *lp)
 {
-	outl(readl(&lp->evm_saa9730_regs->InterruptBlock1) & ~EVM_LAN_INT,
-	     &lp->evm_saa9730_regs->InterruptBlock1);
+	writel(readl(&lp->evm_saa9730_regs->InterruptBlock1) & ~EVM_LAN_INT,
+	       &lp->evm_saa9730_regs->InterruptBlock1);
 }
 
 static void evm_saa9730_unblock_lan_int(struct lan_saa9730_private *lp)
 {
-	outl(readl(&lp->evm_saa9730_regs->InterruptBlock1) | EVM_LAN_INT,
-	     &lp->evm_saa9730_regs->InterruptBlock1);
+	writel(readl(&lp->evm_saa9730_regs->InterruptBlock1) | EVM_LAN_INT,
+	       &lp->evm_saa9730_regs->InterruptBlock1);
 }
 
 static void __attribute_used__ show_saa9730_regs(struct lan_saa9730_private *lp)
@@ -147,7 +147,7 @@ static void __attribute_used__ show_saa9730_regs(struct lan_saa9730_private *lp)
 	printk("lp->lan_saa9730_regs->RxStatus = %x\n",
 	       readl(&lp->lan_saa9730_regs->RxStatus));
 	for (i = 0; i < LAN_SAA9730_CAM_DWORDS; i++) {
-		outl(i, &lp->lan_saa9730_regs->CamAddress);
+		writel(i, &lp->lan_saa9730_regs->CamAddress);
 		printk("lp->lan_saa9730_regs->CamData = %x\n",
 		       readl(&lp->lan_saa9730_regs->CamData));
 	}
@@ -288,28 +288,27 @@ static int lan_saa9730_allocate_buffers(struct pci_dev *pdev,
 	 * Set rx buffer A and rx buffer B to point to the first two buffer
 	 * spaces.
 	 */
-	outl(lp->dma_addr + rxoffset,
-	     &lp->lan_saa9730_regs->RxBuffA);
-	outl(lp->dma_addr + rxoffset +
-	     LAN_SAA9730_PACKET_SIZE * LAN_SAA9730_RCV_Q_SIZE,
-	     &lp->lan_saa9730_regs->RxBuffB);
+	writel(lp->dma_addr + rxoffset, &lp->lan_saa9730_regs->RxBuffA);
+	writel(lp->dma_addr + rxoffset +
+	       LAN_SAA9730_PACKET_SIZE * LAN_SAA9730_RCV_Q_SIZE,
+	       &lp->lan_saa9730_regs->RxBuffB);
 
 	/*
 	 * Set txm_buf_a and txm_buf_b to point to the first two buffer
 	 * space
 	 */
-	outl(lp->dma_addr + txoffset,
-	     &lp->lan_saa9730_regs->TxBuffA);
-	outl(lp->dma_addr + txoffset +
-	     LAN_SAA9730_PACKET_SIZE * LAN_SAA9730_TXM_Q_SIZE,
-	     &lp->lan_saa9730_regs->TxBuffB);
+	writel(lp->dma_addr + txoffset,
+	       &lp->lan_saa9730_regs->TxBuffA);
+	writel(lp->dma_addr + txoffset +
+	       LAN_SAA9730_PACKET_SIZE * LAN_SAA9730_TXM_Q_SIZE,
+	       &lp->lan_saa9730_regs->TxBuffB);
 
 	/* Set packet number */
-	outl((lp->DmaRcvPackets << PK_COUNT_RX_A_SHF) |
-	     (lp->DmaRcvPackets << PK_COUNT_RX_B_SHF) |
-	     (lp->DmaTxmPackets << PK_COUNT_TX_A_SHF) |
-	     (lp->DmaTxmPackets << PK_COUNT_TX_B_SHF),
-	     &lp->lan_saa9730_regs->PacketCount);
+	writel((lp->DmaRcvPackets << PK_COUNT_RX_A_SHF) |
+	       (lp->DmaRcvPackets << PK_COUNT_RX_B_SHF) |
+	       (lp->DmaTxmPackets << PK_COUNT_TX_A_SHF) |
+	       (lp->DmaTxmPackets << PK_COUNT_TX_B_SHF),
+	       &lp->lan_saa9730_regs->PacketCount);
 
 	return 0;
 
@@ -326,10 +325,10 @@ static int lan_saa9730_cam_load(struct lan_saa9730_private *lp)
 
 	for (i = 0; i < LAN_SAA9730_CAM_DWORDS; i++) {
 		/* First set address to where data is written */
-		outl(i, &lp->lan_saa9730_regs->CamAddress);
-		outl((NetworkAddress[0] << 24) | (NetworkAddress[1] << 16)
-		     | (NetworkAddress[2] << 8) | NetworkAddress[3],
-		     &lp->lan_saa9730_regs->CamData);
+		writel(i, &lp->lan_saa9730_regs->CamAddress);
+		writel((NetworkAddress[0] << 24) | (NetworkAddress[1] << 16) |
+		       (NetworkAddress[2] << 8) | NetworkAddress[3],
+		       &lp->lan_saa9730_regs->CamData);
 		NetworkAddress += 4;
 	}
 	return 0;
@@ -365,8 +364,8 @@ static int lan_saa9730_mii_init(struct lan_saa9730_private *lp)
 	}
 
 	/* Now set the control and address register. */
-	outl(MD_CA_BUSY | PHY_STATUS | PHY_ADDRESS << MD_CA_PHY_SHF,
-	     &lp->lan_saa9730_regs->StationMgmtCtl);
+	writel(MD_CA_BUSY | PHY_STATUS | PHY_ADDRESS << MD_CA_PHY_SHF,
+	       &lp->lan_saa9730_regs->StationMgmtCtl);
 
 	/* check link status, spin here till station is not busy */
 	i = 0;
@@ -391,23 +390,23 @@ static int lan_saa9730_mii_init(struct lan_saa9730_private *lp)
 		/* Link is down, reset the PHY first. */
 
 		/* set PHY address = 'CONTROL' */
-		outl(PHY_ADDRESS << MD_CA_PHY_SHF | MD_CA_WR | PHY_CONTROL,
-		     &lp->lan_saa9730_regs->StationMgmtCtl);
+		writel(PHY_ADDRESS << MD_CA_PHY_SHF | MD_CA_WR | PHY_CONTROL,
+		       &lp->lan_saa9730_regs->StationMgmtCtl);
 
 		/* Wait for 1 ms. */
 		mdelay(1);
 
 		/* set 'CONTROL' = force reset and renegotiate */
-		outl(PHY_CONTROL_RESET | PHY_CONTROL_AUTO_NEG |
-		     PHY_CONTROL_RESTART_AUTO_NEG,
-		     &lp->lan_saa9730_regs->StationMgmtData);
+		writel(PHY_CONTROL_RESET | PHY_CONTROL_AUTO_NEG |
+		       PHY_CONTROL_RESTART_AUTO_NEG,
+		       &lp->lan_saa9730_regs->StationMgmtData);
 
 		/* Wait for 50 ms. */
 		mdelay(50);
 
 		/* set 'BUSY' to start operation */
-		outl(MD_CA_BUSY | PHY_ADDRESS << MD_CA_PHY_SHF | MD_CA_WR |
-		     PHY_CONTROL, &lp->lan_saa9730_regs->StationMgmtCtl);
+		writel(MD_CA_BUSY | PHY_ADDRESS << MD_CA_PHY_SHF | MD_CA_WR |
+		       PHY_CONTROL, &lp->lan_saa9730_regs->StationMgmtCtl);
 
 		/* await completion */
 		i = 0;
@@ -427,9 +426,9 @@ static int lan_saa9730_mii_init(struct lan_saa9730_private *lp)
 
 		for (l = 0; l < 2; l++) {
 			/* set PHY address = 'STATUS' */
-			outl(MD_CA_BUSY | PHY_ADDRESS << MD_CA_PHY_SHF |
-			     PHY_STATUS,
-			     &lp->lan_saa9730_regs->StationMgmtCtl);
+			writel(MD_CA_BUSY | PHY_ADDRESS << MD_CA_PHY_SHF |
+			       PHY_STATUS,
+			       &lp->lan_saa9730_regs->StationMgmtCtl);
 
 			/* await completion */
 			i = 0;
@@ -462,35 +461,35 @@ static int lan_saa9730_mii_init(struct lan_saa9730_private *lp)
 static int lan_saa9730_control_init(struct lan_saa9730_private *lp)
 {
 	/* Initialize DMA control register. */
-	outl((LANMB_ANY << DMA_CTL_MAX_XFER_SHF) |
-	     (LANEND_LITTLE << DMA_CTL_ENDIAN_SHF) |
-	     (LAN_SAA9730_RCV_Q_INT_THRESHOLD << DMA_CTL_RX_INT_COUNT_SHF)
-	     | DMA_CTL_RX_INT_TO_EN | DMA_CTL_RX_INT_EN |
-	     DMA_CTL_MAC_RX_INT_EN | DMA_CTL_MAC_TX_INT_EN,
-	     &lp->lan_saa9730_regs->LanDmaCtl);
+	writel((LANMB_ANY << DMA_CTL_MAX_XFER_SHF) |
+	       (LANEND_LITTLE << DMA_CTL_ENDIAN_SHF) |
+	       (LAN_SAA9730_RCV_Q_INT_THRESHOLD << DMA_CTL_RX_INT_COUNT_SHF)
+	       | DMA_CTL_RX_INT_TO_EN | DMA_CTL_RX_INT_EN |
+	       DMA_CTL_MAC_RX_INT_EN | DMA_CTL_MAC_TX_INT_EN,
+	       &lp->lan_saa9730_regs->LanDmaCtl);
 
 	/* Initial MAC control register. */
-	outl((MACCM_MII << MAC_CONTROL_CONN_SHF) | MAC_CONTROL_FULL_DUP,
-	     &lp->lan_saa9730_regs->MacCtl);
+	writel((MACCM_MII << MAC_CONTROL_CONN_SHF) | MAC_CONTROL_FULL_DUP,
+	       &lp->lan_saa9730_regs->MacCtl);
 
 	/* Initialize CAM control register. */
-	outl(CAM_CONTROL_COMP_EN | CAM_CONTROL_BROAD_ACC,
-	     &lp->lan_saa9730_regs->CamCtl);
+	writel(CAM_CONTROL_COMP_EN | CAM_CONTROL_BROAD_ACC,
+	       &lp->lan_saa9730_regs->CamCtl);
 
 	/*
 	 * Initialize CAM enable register, only turn on first entry, should
 	 * contain own addr.
 	 */
-	outl(0x0001, &lp->lan_saa9730_regs->CamEnable);
+	writel(0x0001, &lp->lan_saa9730_regs->CamEnable);
 
 	/* Initialize Tx control register */
-	outl(TX_CTL_EN_COMP, &lp->lan_saa9730_regs->TxCtl);
+	writel(TX_CTL_EN_COMP, &lp->lan_saa9730_regs->TxCtl);
 
 	/* Initialize Rcv control register */
-	outl(RX_CTL_STRIP_CRC, &lp->lan_saa9730_regs->RxCtl);
+	writel(RX_CTL_STRIP_CRC, &lp->lan_saa9730_regs->RxCtl);
 
 	/* Reset DMA engine */
-	outl(DMA_TEST_SW_RESET, &lp->lan_saa9730_regs->DmaTest);
+	writel(DMA_TEST_SW_RESET, &lp->lan_saa9730_regs->DmaTest);
 
 	return 0;
 }
@@ -500,14 +499,14 @@ static int lan_saa9730_stop(struct lan_saa9730_private *lp)
 	int i;
 
 	/* Stop DMA first */
-	outl(readl(&lp->lan_saa9730_regs->LanDmaCtl) &
-	     ~(DMA_CTL_EN_TX_DMA | DMA_CTL_EN_RX_DMA),
-	     &lp->lan_saa9730_regs->LanDmaCtl);
+	writel(readl(&lp->lan_saa9730_regs->LanDmaCtl) &
+	       ~(DMA_CTL_EN_TX_DMA | DMA_CTL_EN_RX_DMA),
+	       &lp->lan_saa9730_regs->LanDmaCtl);
 
 	/* Set the SW Reset bits in DMA and MAC control registers */
-	outl(DMA_TEST_SW_RESET, &lp->lan_saa9730_regs->DmaTest);
-	outl(readl(&lp->lan_saa9730_regs->MacCtl) | MAC_CONTROL_RESET,
-	     &lp->lan_saa9730_regs->MacCtl);
+	writel(DMA_TEST_SW_RESET, &lp->lan_saa9730_regs->DmaTest);
+	writel(readl(&lp->lan_saa9730_regs->MacCtl) | MAC_CONTROL_RESET,
+	       &lp->lan_saa9730_regs->MacCtl);
 
 	/*
 	 * Wait for MAC reset to have finished. The reset bit is auto cleared
@@ -532,8 +531,8 @@ static int lan_saa9730_dma_init(struct lan_saa9730_private *lp)
 	/* Stop lan controller. */
 	lan_saa9730_stop(lp);
 
-	outl(LAN_SAA9730_DEFAULT_TIME_OUT_CNT,
-	     &lp->lan_saa9730_regs->Timeout);
+	writel(LAN_SAA9730_DEFAULT_TIME_OUT_CNT,
+	       &lp->lan_saa9730_regs->Timeout);
 
 	return 0;
 }
@@ -552,19 +551,19 @@ static int lan_saa9730_start(struct lan_saa9730_private *lp)
 	lp->PendingTxmPacketIndex = 0;
 	lp->PendingTxmBufferIndex = 0;
 
-	outl(readl(&lp->lan_saa9730_regs->LanDmaCtl) | DMA_CTL_EN_TX_DMA |
-	     DMA_CTL_EN_RX_DMA, &lp->lan_saa9730_regs->LanDmaCtl);
+	writel(readl(&lp->lan_saa9730_regs->LanDmaCtl) | DMA_CTL_EN_TX_DMA |
+	       DMA_CTL_EN_RX_DMA, &lp->lan_saa9730_regs->LanDmaCtl);
 
 	/* For Tx, turn on MAC then DMA */
-	outl(readl(&lp->lan_saa9730_regs->TxCtl) | TX_CTL_TX_EN,
-	     &lp->lan_saa9730_regs->TxCtl);
+	writel(readl(&lp->lan_saa9730_regs->TxCtl) | TX_CTL_TX_EN,
+	       &lp->lan_saa9730_regs->TxCtl);
 
 	/* For Rx, turn on DMA then MAC */
-	outl(readl(&lp->lan_saa9730_regs->RxCtl) | RX_CTL_RX_EN,
-	     &lp->lan_saa9730_regs->RxCtl);
+	writel(readl(&lp->lan_saa9730_regs->RxCtl) | RX_CTL_RX_EN,
+	       &lp->lan_saa9730_regs->RxCtl);
 
 	/* Set Ok2Use to let hardware own the buffers.	*/
-	outl(OK2USE_RX_A | OK2USE_RX_B, &lp->lan_saa9730_regs->Ok2Use);
+	writel(OK2USE_RX_A | OK2USE_RX_B, &lp->lan_saa9730_regs->Ok2Use);
 
 	return 0;
 }
@@ -587,7 +586,7 @@ static int lan_saa9730_tx(struct net_device *dev)
 		printk("lan_saa9730_tx interrupt\n");
 
 	/* Clear interrupt. */
-	outl(DMA_STATUS_MAC_TX_INT, &lp->lan_saa9730_regs->DmaStatus);
+	writel(DMA_STATUS_MAC_TX_INT, &lp->lan_saa9730_regs->DmaStatus);
 
 	while (1) {
 		pPacket = lp->TxmBuffer[lp->PendingTxmBufferIndex]
@@ -660,8 +659,8 @@ static int lan_saa9730_rx(struct net_device *dev)
 		printk("lan_saa9730_rx interrupt\n");
 
 	/* Clear receive interrupts. */
-	outl(DMA_STATUS_MAC_RX_INT | DMA_STATUS_RX_INT |
-	     DMA_STATUS_RX_TO_INT, &lp->lan_saa9730_regs->DmaStatus);
+	writel(DMA_STATUS_MAC_RX_INT | DMA_STATUS_RX_INT |
+	       DMA_STATUS_RX_TO_INT, &lp->lan_saa9730_regs->DmaStatus);
 
 	/* Address next packet */
 	BufferIndex = lp->NextRcvBufferIndex;
@@ -725,8 +724,8 @@ static int lan_saa9730_rx(struct net_device *dev)
 		*pPacket = cpu_to_le32(RXSF_READY << RX_STAT_CTL_OWNER_SHF);
 
 		/* Make sure A or B is available to hardware as appropriate. */
-		outl(BufferIndex ? OK2USE_RX_B : OK2USE_RX_A,
-		     &lp->lan_saa9730_regs->Ok2Use);
+		writel(BufferIndex ? OK2USE_RX_B : OK2USE_RX_A,
+		       &lp->lan_saa9730_regs->Ok2Use);
 
 		/* Go to next packet in sequence. */
 		lp->NextRcvPacketIndex++;
@@ -844,8 +843,8 @@ static int lan_saa9730_write(struct lan_saa9730_private *lp,
 			    (len << TX_STAT_CTL_LENGTH_SHF));
 
 	/* Make sure A or B is available to hardware as appropriate. */
-	outl(BufferIndex ? OK2USE_TX_B : OK2USE_TX_A,
-	     &lp->lan_saa9730_regs->Ok2Use);
+	writel(BufferIndex ? OK2USE_TX_B : OK2USE_TX_A,
+	       &lp->lan_saa9730_regs->Ok2Use);
 
 	return 0;
 }
@@ -938,15 +937,15 @@ static void lan_saa9730_set_multicast(struct net_device *dev)
 
 	if (dev->flags & IFF_PROMISC) {
 		/* accept all packets */
-		outl(CAM_CONTROL_COMP_EN | CAM_CONTROL_STATION_ACC |
-		     CAM_CONTROL_GROUP_ACC | CAM_CONTROL_BROAD_ACC,
-		     &lp->lan_saa9730_regs->CamCtl);
+		writel(CAM_CONTROL_COMP_EN | CAM_CONTROL_STATION_ACC |
+		       CAM_CONTROL_GROUP_ACC | CAM_CONTROL_BROAD_ACC,
+		       &lp->lan_saa9730_regs->CamCtl);
 	} else {
 		if (dev->flags & IFF_ALLMULTI) {
 			/* accept all multicast packets */
-			outl(CAM_CONTROL_COMP_EN | CAM_CONTROL_GROUP_ACC |
-			     CAM_CONTROL_BROAD_ACC,
-			     &lp->lan_saa9730_regs->CamCtl);
+			writel(CAM_CONTROL_COMP_EN | CAM_CONTROL_GROUP_ACC |
+			       CAM_CONTROL_BROAD_ACC,
+			       &lp->lan_saa9730_regs->CamCtl);
 		} else {
 			/*
 			 * Will handle the multicast stuff later. -carstenl
diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 8fecf1b..39c6677 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -105,7 +105,8 @@ static const int txqaddr[] = { Q_XA1, Q_XA2 };
 static const int rxqaddr[] = { Q_R1, Q_R2 };
 static const u32 rxirqmask[] = { IS_R1_F, IS_R2_F };
 static const u32 txirqmask[] = { IS_XA1_F, IS_XA2_F };
-static const u32 irqmask[] = { IS_R1_F|IS_XA1_F, IS_R2_F|IS_XA2_F };
+static const u32 napimask[] = { IS_R1_F|IS_XA1_F, IS_R2_F|IS_XA2_F };
+static const u32 portmask[] = { IS_PORT_1, IS_PORT_2 };
 
 static int skge_get_regs_len(struct net_device *dev)
 {
@@ -671,7 +672,7 @@ static void skge_led(struct skge_port *skge, enum led_mode mode)
 	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
 
-	mutex_lock(&hw->phy_mutex);
+	spin_lock_bh(&hw->phy_lock);
 	if (hw->chip_id == CHIP_ID_GENESIS) {
 		switch (mode) {
 		case LED_MODE_OFF:
@@ -742,7 +743,7 @@ static void skge_led(struct skge_port *skge, enum led_mode mode)
 				     PHY_M_LED_MO_RX(MO_LED_ON));
 		}
 	}
-	mutex_unlock(&hw->phy_mutex);
+	spin_unlock_bh(&hw->phy_lock);
 }
 
 /* blink LED's for finding board */
@@ -1316,7 +1317,7 @@ static void xm_phy_init(struct skge_port *skge)
 	xm_phy_write(hw, port, PHY_XMAC_CTRL, ctrl);
 
 	/* Poll PHY for status changes */
-	schedule_delayed_work(&skge->link_thread, LINK_HZ);
+	mod_timer(&skge->link_timer, jiffies + LINK_HZ);
 }
 
 static void xm_check_link(struct net_device *dev)
@@ -1391,10 +1392,9 @@ static void xm_check_link(struct net_device *dev)
  * Since internal PHY is wired to a level triggered pin, can't
  * get an interrupt when carrier is detected.
  */
-static void xm_link_timer(struct work_struct *work)
+static void xm_link_timer(unsigned long arg)
 {
-	struct skge_port *skge =
-		container_of(work, struct skge_port, link_thread.work);
+	struct skge_port *skge = (struct skge_port *) arg;
 	struct net_device *dev = skge->netdev;
  	struct skge_hw *hw = skge->hw;
 	int port = skge->port;
@@ -1414,13 +1414,13 @@ static void xm_link_timer(struct work_struct *work)
 			goto nochange;
 	}
 
-	mutex_lock(&hw->phy_mutex);
+	spin_lock(&hw->phy_lock);
 	xm_check_link(dev);
-	mutex_unlock(&hw->phy_mutex);
+	spin_unlock(&hw->phy_lock);
 
 nochange:
 	if (netif_running(dev))
-		schedule_delayed_work(&skge->link_thread, LINK_HZ);
+		mod_timer(&skge->link_timer, jiffies + LINK_HZ);
 }
 
 static void genesis_mac_init(struct skge_hw *hw, int port)
@@ -2323,7 +2323,7 @@ static void skge_phy_reset(struct skge_port *skge)
 	netif_stop_queue(skge->netdev);
 	netif_carrier_off(skge->netdev);
 
-	mutex_lock(&hw->phy_mutex);
+	spin_lock_bh(&hw->phy_lock);
 	if (hw->chip_id == CHIP_ID_GENESIS) {
 		genesis_reset(hw, port);
 		genesis_mac_init(hw, port);
@@ -2331,7 +2331,7 @@ static void skge_phy_reset(struct skge_port *skge)
 		yukon_reset(hw, port);
 		yukon_init(hw, port);
 	}
-	mutex_unlock(&hw->phy_mutex);
+	spin_unlock_bh(&hw->phy_lock);
 
 	dev->set_multicast_list(dev);
 }
@@ -2354,12 +2354,12 @@ static int skge_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		/* fallthru */
 	case SIOCGMIIREG: {
 		u16 val = 0;
-		mutex_lock(&hw->phy_mutex);
+		spin_lock_bh(&hw->phy_lock);
 		if (hw->chip_id == CHIP_ID_GENESIS)
 			err = __xm_phy_read(hw, skge->port, data->reg_num & 0x1f, &val);
 		else
 			err = __gm_phy_read(hw, skge->port, data->reg_num & 0x1f, &val);
-		mutex_unlock(&hw->phy_mutex);
+		spin_unlock_bh(&hw->phy_lock);
 		data->val_out = val;
 		break;
 	}
@@ -2368,14 +2368,14 @@ static int skge_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		mutex_lock(&hw->phy_mutex);
+		spin_lock_bh(&hw->phy_lock);
 		if (hw->chip_id == CHIP_ID_GENESIS)
 			err = xm_phy_write(hw, skge->port, data->reg_num & 0x1f,
 				   data->val_in);
 		else
 			err = gm_phy_write(hw, skge->port, data->reg_num & 0x1f,
 				   data->val_in);
-		mutex_unlock(&hw->phy_mutex);
+		spin_unlock_bh(&hw->phy_lock);
 		break;
 	}
 	return err;
@@ -2481,12 +2481,12 @@ static int skge_up(struct net_device *dev)
 		goto free_rx_ring;
 
 	/* Initialize MAC */
-	mutex_lock(&hw->phy_mutex);
+	spin_lock_bh(&hw->phy_lock);
 	if (hw->chip_id == CHIP_ID_GENESIS)
 		genesis_mac_init(hw, port);
 	else
 		yukon_mac_init(hw, port);
-	mutex_unlock(&hw->phy_mutex);
+	spin_unlock_bh(&hw->phy_lock);
 
 	/* Configure RAMbuffers */
 	chunk = hw->ram_size / ((hw->ports + 1)*2);
@@ -2504,6 +2504,11 @@ static int skge_up(struct net_device *dev)
 	skge_write8(hw, Q_ADDR(rxqaddr[port], Q_CSR), CSR_START | CSR_IRQ_CL_F);
 	skge_led(skge, LED_MODE_ON);
 
+	spin_lock_irq(&hw->hw_lock);
+	hw->intr_mask |= portmask[port];
+	skge_write32(hw, B0_IMSK, hw->intr_mask);
+	spin_unlock_irq(&hw->hw_lock);
+
 	netif_poll_enable(dev);
 	return 0;
 
@@ -2531,7 +2536,14 @@ static int skge_down(struct net_device *dev)
 
 	netif_stop_queue(dev);
 	if (hw->chip_id == CHIP_ID_GENESIS && hw->phy_type == SK_PHY_XMAC)
-		cancel_delayed_work(&skge->link_thread);
+		del_timer_sync(&skge->link_timer);
+
+	netif_poll_disable(dev);
+
+	spin_lock_irq(&hw->hw_lock);
+	hw->intr_mask &= ~portmask[port];
+	skge_write32(hw, B0_IMSK, hw->intr_mask);
+	spin_unlock_irq(&hw->hw_lock);
 
 	skge_write8(skge->hw, SK_REG(skge->port, LNK_LED_REG), LED_OFF);
 	if (hw->chip_id == CHIP_ID_GENESIS)
@@ -2575,8 +2587,10 @@ static int skge_down(struct net_device *dev)
 
 	skge_led(skge, LED_MODE_OFF);
 
-	netif_poll_disable(dev);
+	netif_tx_lock_bh(dev);
 	skge_tx_clean(dev);
+	netif_tx_unlock_bh(dev);
+
 	skge_rx_clean(skge);
 
 	kfree(skge->rx_ring.start);
@@ -2721,7 +2735,6 @@ static void skge_tx_clean(struct net_device *dev)
 	struct skge_port *skge = netdev_priv(dev);
 	struct skge_element *e;
 
-	netif_tx_lock_bh(dev);
 	for (e = skge->tx_ring.to_clean; e != skge->tx_ring.to_use; e = e->next) {
 		struct skge_tx_desc *td = e->desc;
 		skge_tx_free(skge, e, td->control);
@@ -2730,7 +2743,6 @@ static void skge_tx_clean(struct net_device *dev)
 
 	skge->tx_ring.to_clean = e;
 	netif_wake_queue(dev);
-	netif_tx_unlock_bh(dev);
 }
 
 static void skge_tx_timeout(struct net_device *dev)
@@ -3049,7 +3061,7 @@ static int skge_poll(struct net_device *dev, int *budget)
 
 	spin_lock_irqsave(&hw->hw_lock, flags);
 	__netif_rx_complete(dev);
-	hw->intr_mask |= irqmask[skge->port];
+	hw->intr_mask |= napimask[skge->port];
   	skge_write32(hw, B0_IMSK, hw->intr_mask);
 	skge_read32(hw, B0_IMSK);
 	spin_unlock_irqrestore(&hw->hw_lock, flags);
@@ -3160,28 +3172,29 @@ static void skge_error_irq(struct skge_hw *hw)
 }
 
 /*
- * Interrupt from PHY are handled in work queue
+ * Interrupt from PHY are handled in tasklet (softirq)
  * because accessing phy registers requires spin wait which might
  * cause excess interrupt latency.
  */
-static void skge_extirq(struct work_struct *work)
+static void skge_extirq(unsigned long arg)
 {
-	struct skge_hw *hw = container_of(work, struct skge_hw, phy_work);
+	struct skge_hw *hw = (struct skge_hw *) arg;
 	int port;
 
-	mutex_lock(&hw->phy_mutex);
 	for (port = 0; port < hw->ports; port++) {
 		struct net_device *dev = hw->dev[port];
-		struct skge_port *skge = netdev_priv(dev);
 
 		if (netif_running(dev)) {
+			struct skge_port *skge = netdev_priv(dev);
+
+			spin_lock(&hw->phy_lock);
 			if (hw->chip_id != CHIP_ID_GENESIS)
 				yukon_phy_intr(skge);
 			else if (hw->phy_type == SK_PHY_BCOM)
 				bcom_phy_intr(skge);
+			spin_unlock(&hw->phy_lock);
 		}
 	}
-	mutex_unlock(&hw->phy_mutex);
 
 	spin_lock_irq(&hw->hw_lock);
 	hw->intr_mask |= IS_EXT_REG;
@@ -3206,7 +3219,7 @@ static irqreturn_t skge_intr(int irq, void *dev_id)
 	status &= hw->intr_mask;
 	if (status & IS_EXT_REG) {
 		hw->intr_mask &= ~IS_EXT_REG;
-		schedule_work(&hw->phy_work);
+		tasklet_schedule(&hw->phy_task);
 	}
 
 	if (status & (IS_XA1_F|IS_R1_F)) {
@@ -3282,23 +3295,28 @@ static int skge_set_mac_address(struct net_device *dev, void *p)
 
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 
-	/* disable Rx */
-	ctrl = gma_read16(hw, port, GM_GP_CTRL);
-	gma_write16(hw, port, GM_GP_CTRL, ctrl & ~GM_GPCR_RX_ENA);
+	if (!netif_running(dev)) {
+		memcpy_toio(hw->regs + B2_MAC_1 + port*8, dev->dev_addr, ETH_ALEN);
+		memcpy_toio(hw->regs + B2_MAC_2 + port*8, dev->dev_addr, ETH_ALEN);
+	} else {
+		/* disable Rx */
+		spin_lock_bh(&hw->phy_lock);
+		ctrl = gma_read16(hw, port, GM_GP_CTRL);
+		gma_write16(hw, port, GM_GP_CTRL, ctrl & ~GM_GPCR_RX_ENA);
 
-	memcpy_toio(hw->regs + B2_MAC_1 + port*8, dev->dev_addr, ETH_ALEN);
-	memcpy_toio(hw->regs + B2_MAC_2 + port*8, dev->dev_addr, ETH_ALEN);
+		memcpy_toio(hw->regs + B2_MAC_1 + port*8, dev->dev_addr, ETH_ALEN);
+		memcpy_toio(hw->regs + B2_MAC_2 + port*8, dev->dev_addr, ETH_ALEN);
 
-	if (netif_running(dev)) {
 		if (hw->chip_id == CHIP_ID_GENESIS)
 			xm_outaddr(hw, port, XM_SA, dev->dev_addr);
 		else {
 			gma_set_addr(hw, port, GM_SRC_ADDR_1L, dev->dev_addr);
 			gma_set_addr(hw, port, GM_SRC_ADDR_2L, dev->dev_addr);
 		}
-	}
 
-	gma_write16(hw, port, GM_GP_CTRL, ctrl);
+		gma_write16(hw, port, GM_GP_CTRL, ctrl);
+		spin_unlock_bh(&hw->phy_lock);
+	}
 
 	return 0;
 }
@@ -3413,10 +3431,9 @@ static int skge_reset(struct skge_hw *hw)
 	else
 		hw->ram_size = t8 * 4096;
 
-	hw->intr_mask = IS_HW_ERR | IS_PORT_1;
-	if (hw->ports > 1)
-		hw->intr_mask |= IS_PORT_2;
+	hw->intr_mask = IS_HW_ERR;
 
+	/* Use PHY IRQ for all but fiber based Genesis board */
 	if (!(hw->chip_id == CHIP_ID_GENESIS && hw->phy_type == SK_PHY_XMAC))
 		hw->intr_mask |= IS_EXT_REG;
 
@@ -3484,14 +3501,12 @@ static int skge_reset(struct skge_hw *hw)
 
 	skge_write32(hw, B0_IMSK, hw->intr_mask);
 
-	mutex_lock(&hw->phy_mutex);
 	for (i = 0; i < hw->ports; i++) {
 		if (hw->chip_id == CHIP_ID_GENESIS)
 			genesis_reset(hw, i);
 		else
 			yukon_reset(hw, i);
 	}
-	mutex_unlock(&hw->phy_mutex);
 
 	return 0;
 }
@@ -3539,6 +3554,7 @@ static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 	skge->netdev = dev;
 	skge->hw = hw;
 	skge->msg_enable = netif_msg_init(debug, default_msg);
+
 	skge->tx_ring.count = DEFAULT_TX_RING_SIZE;
 	skge->rx_ring.count = DEFAULT_RX_RING_SIZE;
 
@@ -3555,7 +3571,7 @@ static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 	skge->port = port;
 
 	/* Only used for Genesis XMAC */
-	INIT_DELAYED_WORK(&skge->link_thread, xm_link_timer);
+	setup_timer(&skge->link_timer, xm_link_timer, (unsigned long) skge);
 
 	if (hw->chip_id != CHIP_ID_GENESIS) {
 		dev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
@@ -3637,9 +3653,9 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 	}
 
 	hw->pdev = pdev;
-	mutex_init(&hw->phy_mutex);
-	INIT_WORK(&hw->phy_work, skge_extirq);
 	spin_lock_init(&hw->hw_lock);
+	spin_lock_init(&hw->phy_lock);
+	tasklet_init(&hw->phy_task, &skge_extirq, (unsigned long) hw);
 
 	hw->regs = ioremap_nocache(pci_resource_start(pdev, 0), 0x4000);
 	if (!hw->regs) {
@@ -3725,6 +3741,8 @@ static void __devexit skge_remove(struct pci_dev *pdev)
 	dev0 = hw->dev[0];
 	unregister_netdev(dev0);
 
+	tasklet_disable(&hw->phy_task);
+
 	spin_lock_irq(&hw->hw_lock);
 	hw->intr_mask = 0;
 	skge_write32(hw, B0_IMSK, 0);
diff --git a/drivers/net/skge.h b/drivers/net/skge.h
index e9354df..86467ae 100644
--- a/drivers/net/skge.h
+++ b/drivers/net/skge.h
@@ -2424,8 +2424,8 @@ struct skge_hw {
 	u32	     	     ram_size;
 	u32	     	     ram_offset;
 	u16		     phy_addr;
-	struct work_struct   phy_work;
-	struct mutex	     phy_mutex;
+	spinlock_t	     phy_lock;
+	struct tasklet_struct phy_task;
 };
 
 enum pause_control {
@@ -2457,7 +2457,7 @@ struct skge_port {
 
 	struct net_device_stats net_stats;
 
-	struct delayed_work  link_thread;
+	struct timer_list    link_timer;
 	enum pause_control   flow_control;
 	enum pause_status    flow_status;
 	u8		     rx_csum;
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index dab88b9..639e1e6 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3607,7 +3607,6 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (bd == ugeth->confBd[txQ]) {
 		if (!netif_queue_stopped(dev))
 			netif_stop_queue(dev);
-		return NETDEV_TX_BUSY;
 	}
 
 	ugeth->txBd[txQ] = bd;
@@ -3623,7 +3622,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irq(&ugeth->lock);
 
-	return NETDEV_TX_OK;
+	return 0;
 }
 
 static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit)
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index a8c2bfe..2ada76a 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -2852,7 +2852,7 @@ static struct net_device *_init_airo_card( unsigned short irq, int port,
 	if (rc) {
 		airo_print_err(dev->name, "register interrupt %d failed, rc %d",
 				irq, rc);
-		goto err_out_unlink;
+		goto err_out_nets;
 	}
 	if (!is_pcmcia) {
 		if (!request_region( dev->base_addr, 64, dev->name )) {
@@ -2935,6 +2935,8 @@ err_out_res:
 	        release_region( dev->base_addr, 64 );
 err_out_irq:
 	free_irq(dev->irq, dev);
+err_out_nets:
+	airo_networks_free(ai);
 err_out_unlink:
 	del_airo_dev(dev);
 err_out_thr:
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_radio.c b/drivers/net/wireless/bcm43xx/bcm43xx_radio.c
index 32beb91..ee1e7a2 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_radio.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_radio.c
@@ -882,10 +882,10 @@ static void _stack_save(u32 *_stackptr, size_t *stackidx,
 {
 	u32 *stackptr = &(_stackptr[*stackidx]);
 
-	assert((offset & 0xF000) == 0x0000);
-	assert((id & 0xF0) == 0x00);
+	assert((offset & 0xE000) == 0x0000);
+	assert((id & 0xF8) == 0x00);
 	*stackptr = offset;
-	*stackptr |= ((u32)id) << 12;
+	*stackptr |= ((u32)id) << 13;
 	*stackptr |= ((u32)value) << 16;
 	(*stackidx)++;
 	assert(*stackidx < BCM43xx_INTERFSTACK_SIZE);
@@ -896,12 +896,12 @@ static u16 _stack_restore(u32 *stackptr,
 {
 	size_t i;
 
-	assert((offset & 0xF000) == 0x0000);
-	assert((id & 0xF0) == 0x00);
+	assert((offset & 0xE000) == 0x0000);
+	assert((id & 0xF8) == 0x00);
 	for (i = 0; i < BCM43xx_INTERFSTACK_SIZE; i++, stackptr++) {
-		if ((*stackptr & 0x00000FFF) != offset)
+		if ((*stackptr & 0x00001FFF) != offset)
 			continue;
-		if (((*stackptr & 0x0000F000) >> 12) != id)
+		if (((*stackptr & 0x00007000) >> 13) != id)
 			continue;
 		return ((*stackptr & 0xFFFF0000) >> 16);
 	}
