From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 02/10] liquidio: Macro replacements
Date: Sun, 3 Jul 2016 13:56:48 -0700
Message-ID: <1467579416-24219-3-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1467579416-24219-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0045.outbound.protection.outlook.com ([104.47.32.45]:54401
	"EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932236AbcGCVa5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jul 2016 17:30:57 -0400
In-Reply-To: <1467579416-24219-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch has minor replacements of ACCESS_ONCE macros with
WRITE_ONCE and replacement of BUG_ON with polite version WARN_ON.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 .../net/ethernet/cavium/liquidio/cn66xx_device.c   | 16 +---
 .../net/ethernet/cavium/liquidio/cn66xx_device.h   |  2 -
 .../net/ethernet/cavium/liquidio/cn68xx_device.c   | 13 +---
 .../net/ethernet/cavium/liquidio/cn68xx_device.h   |  1 -
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c | 24 ++----
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 58 +++++++--------
 .../net/ethernet/cavium/liquidio/octeon_console.c  | 35 +++------
 .../net/ethernet/cavium/liquidio/octeon_device.c   | 85 ----------------------
 .../net/ethernet/cavium/liquidio/octeon_device.h   |  3 +-
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c | 17 +----
 drivers/net/ethernet/cavium/liquidio/octeon_droq.h | 17 +----
 drivers/net/ethernet/cavium/liquidio/octeon_main.h |  2 +-
 .../net/ethernet/cavium/liquidio/octeon_mem_ops.c  | 24 ++----
 .../net/ethernet/cavium/liquidio/octeon_network.h  |  2 +-
 drivers/net/ethernet/cavium/liquidio/octeon_nic.c  | 12 ---
 .../net/ethernet/cavium/liquidio/request_manager.c | 62 ++--------------
 .../ethernet/cavium/liquidio/response_manager.c    | 14 ----
 17 files changed, 66 insertions(+), 321 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
index d35864a..ee40b47 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.c
@@ -19,26 +19,16 @@
 * This file may also be available under a different license from Cavium.
 * Contact Cavium, Inc. for more information
 **********************************************************************/
-#include <linux/version.h>
-#include <linux/types.h>
-#include <linux/list.h>
-#include <linux/interrupt.h>
 #include <linux/pci.h>
-#include <linux/kthread.h>
 #include <linux/netdevice.h>
-#include "octeon_config.h"
 #include "liquidio_common.h"
 #include "octeon_droq.h"
 #include "octeon_iq.h"
 #include "response_manager.h"
 #include "octeon_device.h"
-#include "octeon_nic.h"
 #include "octeon_main.h"
-#include "octeon_network.h"
 #include "cn66xx_regs.h"
 #include "cn66xx_device.h"
-#include "liquidio_image.h"
-#include "octeon_mem_ops.h"
 
 int lio_cn6xxx_soft_reset(struct octeon_device *oct)
 {
@@ -547,14 +537,14 @@ static void lio_cn6xxx_get_pcie_qlmport(struct octeon_device *oct)
 	dev_dbg(&oct->pci_dev->dev, "Using PCIE Port %d\n", oct->pcie_port);
 }
 
-void
+static void
 lio_cn6xxx_process_pcie_error_intr(struct octeon_device *oct, u64 intr64)
 {
 	dev_err(&oct->pci_dev->dev, "Error Intr: 0x%016llx\n",
 		CVM_CAST64(intr64));
 }
 
-int lio_cn6xxx_process_droq_intr_regs(struct octeon_device *oct)
+static int lio_cn6xxx_process_droq_intr_regs(struct octeon_device *oct)
 {
 	struct octeon_droq *droq;
 	int oq_no;
@@ -579,7 +569,7 @@ int lio_cn6xxx_process_droq_intr_regs(struct octeon_device *oct)
 			continue;
 
 		droq = oct->droq[oq_no];
-		pkt_count = octeon_droq_check_hw_for_pkts(oct, droq);
+		pkt_count = octeon_droq_check_hw_for_pkts(droq);
 		if (pkt_count) {
 			oct->droq_intr |= (1ULL << oq_no);
 			if (droq->ops.poll_mode) {
diff --git a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
index fe2932c..28c4722 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn66xx_device.h
@@ -82,8 +82,6 @@ void lio_cn6xxx_setup_iq_regs(struct octeon_device *oct, u32 iq_no);
 void lio_cn6xxx_setup_oq_regs(struct octeon_device *oct, u32 oq_no);
 void lio_cn6xxx_enable_io_queues(struct octeon_device *oct);
 void lio_cn6xxx_disable_io_queues(struct octeon_device *oct);
-void lio_cn6xxx_process_pcie_error_intr(struct octeon_device *oct, u64 intr64);
-int lio_cn6xxx_process_droq_intr_regs(struct octeon_device *oct);
 irqreturn_t lio_cn6xxx_process_interrupt_regs(void *dev);
 void lio_cn6xxx_reinit_regs(struct octeon_device *oct);
 void lio_cn6xxx_bar1_idx_setup(struct octeon_device *oct, u64 core_addr,
diff --git a/drivers/net/ethernet/cavium/liquidio/cn68xx_device.c b/drivers/net/ethernet/cavium/liquidio/cn68xx_device.c
index 8e830d0..29755bc 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn68xx_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/cn68xx_device.c
@@ -19,28 +19,17 @@
 * This file may also be available under a different license from Cavium.
 * Contact Cavium, Inc. for more information
 **********************************************************************/
-#include <linux/version.h>
-#include <linux/types.h>
-#include <linux/list.h>
-#include <linux/interrupt.h>
 #include <linux/pci.h>
-#include <linux/kthread.h>
 #include <linux/netdevice.h>
-#include "octeon_config.h"
 #include "liquidio_common.h"
 #include "octeon_droq.h"
 #include "octeon_iq.h"
 #include "response_manager.h"
 #include "octeon_device.h"
-#include "octeon_nic.h"
 #include "octeon_main.h"
-#include "octeon_network.h"
 #include "cn66xx_regs.h"
 #include "cn66xx_device.h"
 #include "cn68xx_regs.h"
-#include "cn68xx_device.h"
-#include "liquidio_image.h"
-#include "octeon_mem_ops.h"
 
 static void lio_cn68xx_set_dpi_regs(struct octeon_device *oct)
 {
@@ -129,7 +118,7 @@ static inline void lio_cn68xx_vendor_message_fix(struct octeon_device *oct)
 	pci_write_config_dword(oct->pci_dev, CN6XXX_PCIE_FLTMSK, val);
 }
 
-int lio_is_210nv(struct octeon_device *oct)
+static int lio_is_210nv(struct octeon_device *oct)
 {
 	u64 mio_qlm4_cfg = lio_pci_readq(oct, CN6XXX_MIO_QLM4_CFG);
 
diff --git a/drivers/net/ethernet/cavium/liquidio/cn68xx_device.h b/drivers/net/ethernet/cavium/liquidio/cn68xx_device.h
index d4e1c9f..ea7bdcc 100644
--- a/drivers/net/ethernet/cavium/liquidio/cn68xx_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/cn68xx_device.h
@@ -28,6 +28,5 @@
 #define  __CN68XX_DEVICE_H__
 
 int lio_setup_cn68xx_octeon_device(struct octeon_device *oct);
-int lio_is_210nv(struct octeon_device *oct);
 
 #endif
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index a060586..0f29dc4 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -19,13 +19,9 @@
 * This file may also be available under a different license from Cavium.
 * Contact Cavium, Inc. for more information
 **********************************************************************/
-#include <linux/version.h>
 #include <linux/netdevice.h>
 #include <linux/net_tstamp.h>
-#include <linux/ethtool.h>
-#include <linux/dma-mapping.h>
 #include <linux/pci.h>
-#include "octeon_config.h"
 #include "liquidio_common.h"
 #include "octeon_droq.h"
 #include "octeon_iq.h"
@@ -36,9 +32,6 @@
 #include "octeon_network.h"
 #include "cn66xx_regs.h"
 #include "cn66xx_device.h"
-#include "cn68xx_regs.h"
-#include "cn68xx_device.h"
-#include "liquidio_image.h"
 
 static int octnet_get_link_stats(struct net_device *netdev);
 
@@ -346,20 +339,18 @@ static void octnet_mdio_resp_callback(struct octeon_device *oct,
 				      u32 status,
 				      void *buf)
 {
-	struct oct_mdio_cmd_resp *mdio_cmd_rsp;
 	struct oct_mdio_cmd_context *mdio_cmd_ctx;
 	struct octeon_soft_command *sc = (struct octeon_soft_command *)buf;
 
-	mdio_cmd_rsp = (struct oct_mdio_cmd_resp *)sc->virtrptr;
 	mdio_cmd_ctx = (struct oct_mdio_cmd_context *)sc->ctxptr;
 
 	oct = lio_get_device(mdio_cmd_ctx->octeon_id);
 	if (status) {
 		dev_err(&oct->pci_dev->dev, "MIDO instruction failed. Status: %llx\n",
 			CVM_CAST64(status));
-		ACCESS_ONCE(mdio_cmd_ctx->cond) = -1;
+		WRITE_ONCE(mdio_cmd_ctx->cond, -1);
 	} else {
-		ACCESS_ONCE(mdio_cmd_ctx->cond) = 1;
+		WRITE_ONCE(mdio_cmd_ctx->cond, 1);
 	}
 	wake_up_interruptible(&mdio_cmd_ctx->wc);
 }
@@ -390,7 +381,7 @@ octnet_mdio45_access(struct lio *lio, int op, int loc, int *value)
 	mdio_cmd_rsp = (struct oct_mdio_cmd_resp *)sc->virtrptr;
 	mdio_cmd = (struct oct_mdio_cmd *)sc->virtdptr;
 
-	ACCESS_ONCE(mdio_cmd_ctx->cond) = 0;
+	WRITE_ONCE(mdio_cmd_ctx->cond, 0);
 	mdio_cmd_ctx->octeon_id = lio_get_device_id(oct_dev);
 	mdio_cmd->op = op;
 	mdio_cmd->mdio_addr = loc;
@@ -429,7 +420,7 @@ octnet_mdio45_access(struct lio *lio, int op, int loc, int *value)
 			octeon_swap_8B_data((u64 *)(&mdio_cmd_rsp->resp),
 					    sizeof(struct oct_mdio_cmd) / 8);
 
-			if (ACCESS_ONCE(mdio_cmd_ctx->cond) == 1) {
+			if (READ_ONCE(mdio_cmd_ctx->cond) == 1) {
 				if (!op)
 					*value = mdio_cmd_rsp->resp.value1;
 			} else {
@@ -623,7 +614,8 @@ lio_get_pauseparam(struct net_device *netdev, struct ethtool_pauseparam *pause)
 
 static void
 lio_get_ethtool_stats(struct net_device *netdev,
-		      struct ethtool_stats *stats, u64 *data)
+		      struct ethtool_stats *stats  __attribute__((unused)),
+		      u64 *data)
 {
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct_dev = lio->oct_dev;
@@ -1067,7 +1059,7 @@ static int octnet_set_intrmod_cfg(struct lio *lio,
 	return 0;
 }
 
-void
+static void
 octnet_nic_stats_callback(struct octeon_device *oct_dev,
 			  u32 status, void *ptr)
 {
@@ -1552,7 +1544,7 @@ static int lio_nway_reset(struct net_device *netdev)
 }
 
 /* Return register dump len. */
-static int lio_get_regs_len(struct net_device *dev)
+static int lio_get_regs_len(struct net_device *dev __attribute__((unused)))
 {
 	return OCT_ETHTOOL_REGDUMP_LEN;
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 4a5629f..3d229c0 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -20,25 +20,12 @@
 * Contact Cavium, Inc. for more information
 **********************************************************************/
 #include <linux/version.h>
-#include <linux/module.h>
-#include <linux/crc32.h>
-#include <linux/dma-mapping.h>
 #include <linux/pci.h>
-#include <linux/pci_ids.h>
-#include <linux/ip.h>
-#include <net/ip.h>
-#include <linux/ipv6.h>
 #include <linux/net_tstamp.h>
 #include <linux/if_vlan.h>
 #include <linux/firmware.h>
-#include <linux/ethtool.h>
 #include <linux/ptp_clock_kernel.h>
-#include <linux/types.h>
-#include <linux/list.h>
-#include <linux/workqueue.h>
-#include <linux/interrupt.h>
 #include <net/vxlan.h>
-#include "octeon_config.h"
 #include "liquidio_common.h"
 #include "octeon_droq.h"
 #include "octeon_iq.h"
@@ -49,7 +36,6 @@
 #include "octeon_network.h"
 #include "cn66xx_regs.h"
 #include "cn66xx_device.h"
-#include "cn68xx_regs.h"
 #include "cn68xx_device.h"
 #include "liquidio_image.h"
 
@@ -252,8 +238,7 @@ static int lio_wait_for_oq_pkts(struct octeon_device *oct)
 		for (i = 0; i < MAX_OCTEON_OUTPUT_QUEUES(oct); i++) {
 			if (!(oct->io_qmask.oq & (1ULL << i)))
 				continue;
-			pkt_cnt += octeon_droq_check_hw_for_pkts(oct,
-								 oct->droq[i]);
+			pkt_cnt += octeon_droq_check_hw_for_pkts(oct->droq[i]);
 		}
 		if (pkt_cnt > 0) {
 			pending_pkts += pkt_cnt;
@@ -508,7 +493,8 @@ static pci_ers_result_t liquidio_pcie_error_detected(struct pci_dev *pdev,
  * \brief mmio handler
  * @param pdev Pointer to PCI device
  */
-static pci_ers_result_t liquidio_pcie_mmio_enabled(struct pci_dev *pdev)
+static pci_ers_result_t liquidio_pcie_mmio_enabled(
+				struct pci_dev *pdev __attribute__((unused)))
 {
 	/* We should never hit this since we never ask for a reset for a Fatal
 	 * Error. We always return DISCONNECT in io_error above.
@@ -524,7 +510,8 @@ static pci_ers_result_t liquidio_pcie_mmio_enabled(struct pci_dev *pdev)
  * Restart the card from scratch, as if from a cold-boot. Implementation
  * resembles the first-half of the octeon_resume routine.
  */
-static pci_ers_result_t liquidio_pcie_slot_reset(struct pci_dev *pdev)
+static pci_ers_result_t liquidio_pcie_slot_reset(
+				struct pci_dev *pdev __attribute__((unused)))
 {
 	/* We should never hit this since we never ask for a reset for a Fatal
 	 * Error. We always return DISCONNECT in io_error above.
@@ -541,7 +528,7 @@ static pci_ers_result_t liquidio_pcie_slot_reset(struct pci_dev *pdev)
  * its OK to resume normal operation. Implementation resembles the
  * second-half of the octeon_resume routine.
  */
-static void liquidio_pcie_resume(struct pci_dev *pdev)
+static void liquidio_pcie_resume(struct pci_dev *pdev __attribute__((unused)))
 {
 	/* Nothing to be done here. */
 }
@@ -552,7 +539,8 @@ static void liquidio_pcie_resume(struct pci_dev *pdev)
  * @param pdev Pointer to PCI device
  * @param state state to suspend to
  */
-static int liquidio_suspend(struct pci_dev *pdev, pm_message_t state)
+static int liquidio_suspend(struct pci_dev *pdev __attribute__((unused)),
+			    pm_message_t state __attribute__((unused)))
 {
 	return 0;
 }
@@ -561,7 +549,7 @@ static int liquidio_suspend(struct pci_dev *pdev, pm_message_t state)
  * \brief called when resuming
  * @param pdev Pointer to PCI device
  */
-static int liquidio_resume(struct pci_dev *pdev)
+static int liquidio_resume(struct pci_dev *pdev __attribute__((unused)))
 {
 	return 0;
 }
@@ -1105,7 +1093,9 @@ static int octeon_setup_interrupt(struct octeon_device *oct)
  * @param pdev PCI device structure
  * @param ent unused
  */
-static int liquidio_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
+static int
+liquidio_probe(struct pci_dev *pdev,
+	       const struct pci_device_id *ent __attribute__((unused)))
 {
 	struct octeon_device *oct_dev = NULL;
 	struct handshake *hs;
@@ -1725,8 +1715,10 @@ static int liquidio_ptp_settime(struct ptp_clock_info *ptp,
  * @param rq request
  * @param on is it on
  */
-static int liquidio_ptp_enable(struct ptp_clock_info *ptp,
-			       struct ptp_clock_request *rq, int on)
+static int
+liquidio_ptp_enable(struct ptp_clock_info *ptp __attribute__((unused)),
+		    struct ptp_clock_request *rq __attribute__((unused)),
+		    int on __attribute__((unused)))
 {
 	return -EOPNOTSUPP;
 }
@@ -1867,7 +1859,7 @@ static int octeon_setup_droq(struct octeon_device *oct, int q_no, int num_descs,
  * @param buf pointer to resp structure
  */
 static void if_cfg_callback(struct octeon_device *oct,
-			    u32 status,
+			    u32 status __attribute__((unused)),
 			    void *buf)
 {
 	struct octeon_soft_command *sc = (struct octeon_soft_command *)buf;
@@ -1881,7 +1873,7 @@ static void if_cfg_callback(struct octeon_device *oct,
 	if (resp->status)
 		dev_err(&oct->pci_dev->dev, "nic if cfg instruction failed. Status: %llx\n",
 			CVM_CAST64(resp->status));
-	ACCESS_ONCE(ctx->cond) = 1;
+	WRITE_ONCE(ctx->cond, 1);
 
 	snprintf(oct->fw_info.liquidio_firmware_version, 32, "%s",
 		 resp->cfg_info.liquidio_firmware_version);
@@ -1901,7 +1893,8 @@ static void if_cfg_callback(struct octeon_device *oct,
  * @returns selected queue number
  */
 static u16 select_q(struct net_device *dev, struct sk_buff *skb,
-		    void *accel_priv, select_queue_fallback_t fallback)
+		    void *accel_priv __attribute__((unused)),
+		    select_queue_fallback_t fallback __attribute__((unused)))
 {
 	u32 qindex = 0;
 	struct lio *lio;
@@ -1921,7 +1914,7 @@ static u16 select_q(struct net_device *dev, struct sk_buff *skb,
  * @param arg	   - farg registered in droq_ops
  */
 static void
-liquidio_push_packet(u32 octeon_id,
+liquidio_push_packet(u32 octeon_id __attribute__((unused)),
 		     void *skbuff,
 		     u32 len,
 		     union octeon_rh *rh,
@@ -2526,7 +2519,7 @@ static void liquidio_set_mcast_list(struct net_device *netdev)
 	struct octnic_ctrl_pkt nctrl;
 	struct netdev_hw_addr *ha;
 	u64 *mc;
-	int ret, i;
+	int ret;
 	int mc_count = min(netdev_mc_count(netdev), MAX_OCTEON_MULTICAST_ADDR);
 
 	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
@@ -2542,7 +2535,6 @@ static void liquidio_set_mcast_list(struct net_device *netdev)
 	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
 
 	/* copy all the addresses into the udd */
-	i = 0;
 	mc = &nctrl.udd[0];
 	netdev_for_each_mc_addr(ha, netdev) {
 		*mc = 0;
@@ -2707,7 +2699,7 @@ static int liquidio_change_mtu(struct net_device *netdev, int new_mtu)
  * @param ifr interface request
  * @param cmd command
  */
-static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
+static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr)
 {
 	struct hwtstamp_config conf;
 	struct lio *lio = GET_LIO(netdev);
@@ -2768,7 +2760,7 @@ static int liquidio_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
 	switch (cmd) {
 	case SIOCSHWTSTAMP:
-		return hwtstamp_ioctl(netdev, ifr, cmd);
+		return hwtstamp_ioctl(netdev, ifr);
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -3545,7 +3537,7 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		dev_dbg(&octeon_dev->pci_dev->dev,
 			"requesting config for interface %d, iqs %d, oqs %d\n",
 			ifidx_or_pfnum, num_iqueues, num_oqueues);
-		ACCESS_ONCE(ctx->cond) = 0;
+		WRITE_ONCE(ctx->cond, 0);
 		ctx->octeon_id = lio_get_device_id(octeon_dev);
 		init_waitqueue_head(&ctx->wc);
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_console.c b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
index 466147e..bceff8a 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_console.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_console.c
@@ -23,27 +23,14 @@
 /**
  * @file octeon_console.c
  */
-#include <linux/version.h>
-#include <linux/types.h>
-#include <linux/list.h>
-#include <linux/interrupt.h>
 #include <linux/pci.h>
-#include <linux/kthread.h>
 #include <linux/netdevice.h>
-#include "octeon_config.h"
 #include "liquidio_common.h"
 #include "octeon_droq.h"
 #include "octeon_iq.h"
 #include "response_manager.h"
 #include "octeon_device.h"
-#include "octeon_nic.h"
 #include "octeon_main.h"
-#include "octeon_network.h"
-#include "cn66xx_regs.h"
-#include "cn66xx_device.h"
-#include "cn68xx_regs.h"
-#include "cn68xx_device.h"
-#include "liquidio_image.h"
 #include "octeon_mem_ops.h"
 
 static void octeon_remote_lock(void);
@@ -51,6 +38,8 @@ static void octeon_remote_unlock(void);
 static u64 cvmx_bootmem_phy_named_block_find(struct octeon_device *oct,
 					     const char *name,
 					     u32 flags);
+static int octeon_console_read(struct octeon_device *oct, u32 console_num,
+			       char *buffer, u32 buf_size);
 
 #define MIN(a, b) min((a), (b))
 #define CAST_ULL(v) ((u64)(v))
@@ -170,8 +159,8 @@ struct octeon_pci_console_desc {
 				offsetof(struct cvmx_bootmem_desc, field),   \
 				SIZEOF_FIELD(struct cvmx_bootmem_desc, field))
 
-#define __cvmx_bootmem_lock(flags)
-#define __cvmx_bootmem_unlock(flags)
+#define __cvmx_bootmem_lock(flags)	(flags = flags)
+#define __cvmx_bootmem_unlock(flags)	(flags = flags)
 
 /**
  * This macro returns a member of the
@@ -440,8 +429,7 @@ int octeon_wait_for_bootloader(struct octeon_device *oct,
 }
 
 static void octeon_console_handle_result(struct octeon_device *oct,
-					 size_t console_num,
-					 char *buffer, s32 bytes_read)
+					 size_t console_num)
 {
 	struct octeon_console *console;
 
@@ -505,14 +493,11 @@ static void check_console(struct work_struct *work)
 		 */
 		bytes_read =
 			octeon_console_read(oct, console_num, console_buffer,
-					    sizeof(console_buffer) - 1, 0);
+					    sizeof(console_buffer) - 1);
 		if (bytes_read > 0) {
 			total_read += bytes_read;
-			if (console->waiting) {
-				octeon_console_handle_result(oct, console_num,
-							     console_buffer,
-							     bytes_read);
-			}
+			if (console->waiting)
+				octeon_console_handle_result(oct, console_num);
 			if (octeon_console_debug_enabled(console_num)) {
 				output_console_line(oct, console, console_num,
 						    console_buffer, bytes_read);
@@ -675,8 +660,8 @@ static inline int octeon_console_avail_bytes(u32 buffer_size,
 	       octeon_console_free_bytes(buffer_size, wr_idx, rd_idx);
 }
 
-int octeon_console_read(struct octeon_device *oct, u32 console_num,
-			char *buffer, u32 buf_size, u32 flags)
+static int octeon_console_read(struct octeon_device *oct, u32 console_num,
+			       char *buffer, u32 buf_size)
 {
 	int bytes_to_read;
 	u32 rd_idx, wr_idx;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 3372207..046f096 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -19,27 +19,19 @@
 * This file may also be available under a different license from Cavium.
 * Contact Cavium, Inc. for more information
 **********************************************************************/
-#include <linux/types.h>
-#include <linux/list.h>
-#include <linux/interrupt.h>
 #include <linux/pci.h>
 #include <linux/crc32.h>
-#include <linux/kthread.h>
 #include <linux/netdevice.h>
 #include <linux/vmalloc.h>
-#include "octeon_config.h"
 #include "liquidio_common.h"
 #include "octeon_droq.h"
 #include "octeon_iq.h"
 #include "response_manager.h"
 #include "octeon_device.h"
-#include "octeon_nic.h"
 #include "octeon_main.h"
 #include "octeon_network.h"
 #include "cn66xx_regs.h"
 #include "cn66xx_device.h"
-#include "cn68xx_regs.h"
-#include "cn68xx_device.h"
 #include "liquidio_image.h"
 #include "octeon_mem_ops.h"
 
@@ -752,13 +744,11 @@ struct octeon_device *octeon_allocate_device(u32 pci_id,
 /* this function is only for setting up the first queue */
 int octeon_setup_instr_queues(struct octeon_device *oct)
 {
-	u32 num_iqs = 0;
 	u32 num_descs = 0;
 	u32 iq_no = 0;
 	union oct_txpciq txpciq;
 	int numa_node = cpu_to_node(iq_no % num_online_cpus());
 
-	num_iqs = 1;
 	/* this causes queue 0 to be default queue */
 	if (OCTEON_CN6XXX(oct))
 		num_descs =
@@ -793,13 +783,11 @@ int octeon_setup_instr_queues(struct octeon_device *oct)
 
 int octeon_setup_output_queues(struct octeon_device *oct)
 {
-	u32 num_oqs = 0;
 	u32 num_descs = 0;
 	u32 desc_size = 0;
 	u32 oq_no = 0;
 	int numa_node = cpu_to_node(oq_no % num_online_cpus());
 
-	num_oqs = 1;
 	/* this causes queue 0 to be default queue */
 	if (OCTEON_CN6XXX(oct)) {
 		num_descs =
@@ -1019,79 +1007,6 @@ octeon_register_dispatch_fn(struct octeon_device *oct,
 	return 0;
 }
 
-/* octeon_unregister_dispatch_fn
- * Parameters:
- *   oct       - octeon device
- *   opcode    - driver should unregister the function for this opcode
- *   subcode   - driver should unregister the function for this subcode
- * Description:
- *   Unregister the function set for this opcode+subcode.
- * Returns:
- *   Success: 0
- *   Failure: 1
- * Locks:
- *   No locks are held.
- */
-int
-octeon_unregister_dispatch_fn(struct octeon_device *oct, u16 opcode,
-			      u16 subcode)
-{
-	int retval = 0;
-	u32 idx;
-	struct list_head *dispatch, *dfree = NULL, *tmp2;
-	u16 combined_opcode = OPCODE_SUBCODE(opcode, subcode);
-
-	idx = combined_opcode & OCTEON_OPCODE_MASK;
-
-	spin_lock_bh(&oct->dispatch.lock);
-
-	if (oct->dispatch.count == 0) {
-		spin_unlock_bh(&oct->dispatch.lock);
-		dev_err(&oct->pci_dev->dev,
-			"No dispatch functions registered for this device\n");
-		return 1;
-	}
-
-	if (oct->dispatch.dlist[idx].opcode == combined_opcode) {
-		dispatch = &oct->dispatch.dlist[idx].list;
-		if (dispatch->next != dispatch) {
-			dispatch = dispatch->next;
-			oct->dispatch.dlist[idx].opcode =
-				((struct octeon_dispatch *)dispatch)->opcode;
-			oct->dispatch.dlist[idx].dispatch_fn =
-				((struct octeon_dispatch *)
-				 dispatch)->dispatch_fn;
-			oct->dispatch.dlist[idx].arg =
-				((struct octeon_dispatch *)dispatch)->arg;
-			list_del(dispatch);
-			dfree = dispatch;
-		} else {
-			oct->dispatch.dlist[idx].opcode = 0;
-			oct->dispatch.dlist[idx].dispatch_fn = NULL;
-			oct->dispatch.dlist[idx].arg = NULL;
-		}
-	} else {
-		retval = 1;
-		list_for_each_safe(dispatch, tmp2,
-				   &(oct->dispatch.dlist[idx].
-				     list)) {
-			if (((struct octeon_dispatch *)dispatch)->opcode ==
-			    combined_opcode) {
-				list_del(dispatch);
-				dfree = dispatch;
-				retval = 0;
-			}
-		}
-	}
-
-	if (!retval)
-		oct->dispatch.count--;
-
-	spin_unlock_bh(&oct->dispatch.lock);
-	vfree(dfree);
-	return retval;
-}
-
 int octeon_core_drv_init(struct octeon_recv_info *recv_info, void *buf)
 {
 	u32 i;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index b4e566d..579acd4 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -585,8 +585,7 @@ int octeon_add_console(struct octeon_device *oct, u32 console_num);
 int octeon_console_write(struct octeon_device *oct, u32 console_num,
 			 char *buffer, u32 write_request_size, u32 flags);
 int octeon_console_write_avail(struct octeon_device *oct, u32 console_num);
-int octeon_console_read(struct octeon_device *oct, u32 console_num,
-			char *buffer, u32 buf_size, u32 flags);
+
 int octeon_console_read_avail(struct octeon_device *oct, u32 console_num);
 
 /** Removes all attached consoles. */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index d9bb2f7..8bfbe8c 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -19,30 +19,18 @@
 * This file may also be available under a different license from Cavium.
 * Contact Cavium, Inc. for more information
 **********************************************************************/
-#include <linux/version.h>
-#include <linux/types.h>
-#include <linux/list.h>
 #include <linux/pci.h>
-#include <linux/kthread.h>
 #include <linux/netdevice.h>
 #include <linux/vmalloc.h>
-#include "octeon_config.h"
 #include "liquidio_common.h"
 #include "octeon_droq.h"
 #include "octeon_iq.h"
 #include "response_manager.h"
 #include "octeon_device.h"
-#include "octeon_nic.h"
 #include "octeon_main.h"
 #include "octeon_network.h"
 #include "cn66xx_regs.h"
 #include "cn66xx_device.h"
-#include "cn68xx_regs.h"
-#include "cn68xx_device.h"
-#include "liquidio_image.h"
-#include "octeon_mem_ops.h"
-
-/* #define CAVIUM_ONLY_PERF_MODE */
 
 #define     CVM_MIN(d1, d2)           (((d1) < (d2)) ? (d1) : (d2))
 #define     CVM_MAX(d1, d2)           (((d1) > (d2)) ? (d1) : (d2))
@@ -104,8 +92,7 @@ static inline void *octeon_get_dispatch_arg(struct octeon_device *octeon_dev,
 	return fn_arg;
 }
 
-u32 octeon_droq_check_hw_for_pkts(struct octeon_device *oct,
-				  struct octeon_droq *droq)
+u32 octeon_droq_check_hw_for_pkts(struct octeon_droq *droq)
 {
 	u32 pkt_count = 0;
 
@@ -810,7 +797,7 @@ octeon_droq_process_poll_pkts(struct octeon_device *oct,
 
 		total_pkts_processed += pkts_processed;
 
-		octeon_droq_check_hw_for_pkts(oct, droq);
+		octeon_droq_check_hw_for_pkts(droq);
 	}
 
 	spin_unlock(&droq->lock);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
index 886772c..5a6fb91 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.h
@@ -416,24 +416,9 @@ int octeon_register_dispatch_fn(struct octeon_device *oct,
 				u16 subcode,
 				octeon_dispatch_fn_t fn, void *fn_arg);
 
-/**  Remove registration for an opcode/subcode. This will delete the mapping for
- *   an opcode/subcode. The dispatch function will be unregistered and will no
- *   longer be called if a packet with the opcode/subcode arrives in the driver
- *   output queues.
- *   @param  oct        -  the octeon device to unregister from.
- *   @param  opcode     -  the opcode to be unregistered.
- *   @param  subcode    -  the subcode to be unregistered.
- *
- *   @return Success: 0; Failure: 1
- */
-int octeon_unregister_dispatch_fn(struct octeon_device *oct,
-				  u16 opcode,
-				  u16 subcode);
-
 void octeon_droq_print_stats(void);
 
-u32 octeon_droq_check_hw_for_pkts(struct octeon_device *oct,
-				  struct octeon_droq *droq);
+u32 octeon_droq_check_hw_for_pkts(struct octeon_droq *droq);
 
 int octeon_create_droq(struct octeon_device *oct, u32 q_no,
 		       u32 num_descs, u32 desc_size, void *app_ctx);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_main.h b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
index 0ff3efc..bc14e4c 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_main.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_main.h
@@ -174,7 +174,7 @@ sleep_cond(wait_queue_head_t *wait_queue, int *condition)
 
 	init_waitqueue_entry(&we, current);
 	add_wait_queue(wait_queue, &we);
-	while (!(ACCESS_ONCE(*condition))) {
+	while (!(READ_ONCE(*condition))) {
 		set_current_state(TASK_INTERRUPTIBLE);
 		if (signal_pending(current))
 			goto out;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
index 5aecef8..95a4bbe 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_mem_ops.c
@@ -19,43 +19,29 @@
  * This file may also be available under a different license from Cavium.
  * Contact Cavium, Inc. for more information
  **********************************************************************/
-#include <linux/version.h>
-#include <linux/types.h>
-#include <linux/list.h>
-#include <linux/interrupt.h>
 #include <linux/pci.h>
-#include <linux/kthread.h>
 #include <linux/netdevice.h>
-#include "octeon_config.h"
 #include "liquidio_common.h"
 #include "octeon_droq.h"
 #include "octeon_iq.h"
 #include "response_manager.h"
 #include "octeon_device.h"
-#include "octeon_nic.h"
-#include "octeon_main.h"
-#include "octeon_network.h"
-#include "cn66xx_regs.h"
-#include "cn66xx_device.h"
-#include "cn68xx_regs.h"
-#include "cn68xx_device.h"
-#include "liquidio_image.h"
-#include "octeon_mem_ops.h"
 
 #define MEMOPS_IDX   MAX_BAR1_MAP_INDEX
 
+#ifdef __BIG_ENDIAN_BITFIELD
 static inline void
-octeon_toggle_bar1_swapmode(struct octeon_device *oct __attribute__((unused)),
-			    u32 idx __attribute__((unused)))
+octeon_toggle_bar1_swapmode(struct octeon_device *oct, u32 idx)
 {
-#ifdef __BIG_ENDIAN_BITFIELD
 	u32 mask;
 
 	mask = oct->fn_list.bar1_idx_read(oct, idx);
 	mask = (mask & 0x2) ? (mask & ~2) : (mask | 2);
 	oct->fn_list.bar1_idx_write(oct, idx, mask);
-#endif
 }
+#else
+#define octeon_toggle_bar1_swapmode(oct, idx) (oct = oct)
+#endif
 
 static void
 octeon_pci_fastwrite(struct octeon_device *oct, u8 __iomem *mapped_addr,
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index 24bcbd4..5d89f55 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -357,7 +357,7 @@ lio_map_ring_info(struct octeon_droq *droq, u32 i)
 	dma_addr = dma_map_single(&oct->pci_dev->dev, &droq->info_list[i],
 				  OCT_DROQ_INFO_SIZE, DMA_FROM_DEVICE);
 
-	BUG_ON(dma_mapping_error(&oct->pci_dev->dev, dma_addr));
+	WARN_ON(dma_mapping_error(&oct->pci_dev->dev, dma_addr));
 
 	return (u64)dma_addr;
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
index 36f1970..166727b 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
@@ -19,14 +19,9 @@
  * This file may also be available under a different license from Cavium.
  * Contact Cavium, Inc. for more information
  **********************************************************************/
-#include <linux/version.h>
-#include <linux/types.h>
-#include <linux/list.h>
 #include <linux/interrupt.h>
 #include <linux/pci.h>
-#include <linux/kthread.h>
 #include <linux/netdevice.h>
-#include "octeon_config.h"
 #include "liquidio_common.h"
 #include "octeon_droq.h"
 #include "octeon_iq.h"
@@ -34,13 +29,6 @@
 #include "octeon_device.h"
 #include "octeon_nic.h"
 #include "octeon_main.h"
-#include "octeon_network.h"
-#include "cn66xx_regs.h"
-#include "cn66xx_device.h"
-#include "cn68xx_regs.h"
-#include "cn68xx_device.h"
-#include "liquidio_image.h"
-#include "octeon_mem_ops.h"
 
 void *
 octeon_alloc_soft_command_resp(struct octeon_device    *oct,
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 7eafa75..5e2211f 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -19,28 +19,17 @@
  * This file may also be available under a different license from Cavium.
  * Contact Cavium, Inc. for more information
  **********************************************************************/
-#include <linux/version.h>
-#include <linux/types.h>
-#include <linux/list.h>
-#include <linux/interrupt.h>
 #include <linux/pci.h>
-#include <linux/kthread.h>
 #include <linux/netdevice.h>
 #include <linux/vmalloc.h>
-#include "octeon_config.h"
 #include "liquidio_common.h"
 #include "octeon_droq.h"
 #include "octeon_iq.h"
 #include "response_manager.h"
 #include "octeon_device.h"
-#include "octeon_nic.h"
 #include "octeon_main.h"
 #include "octeon_network.h"
-#include "cn66xx_regs.h"
 #include "cn66xx_device.h"
-#include "cn68xx_regs.h"
-#include "cn68xx_device.h"
-#include "liquidio_image.h"
 
 #define INCR_INSTRQUEUE_PKT_COUNT(octeon_dev_ptr, iq_no, field, count)  \
 	(octeon_dev_ptr->instr_queue[iq_no]->stats.field += count)
@@ -301,40 +290,8 @@ static inline void __copy_cmd_into_iq(struct octeon_instr_queue *iq,
 	memcpy(iqptr, cmd, cmdsize);
 }
 
-static inline int
-__post_command(struct octeon_device *octeon_dev __attribute__((unused)),
-	       struct octeon_instr_queue *iq,
-	       u32 force_db __attribute__((unused)), u8 *cmd)
-{
-	u32 index = -1;
-
-	/* This ensures that the read index does not wrap around to the same
-	 * position if queue gets full before Octeon could fetch any instr.
-	 */
-	if (atomic_read(&iq->instr_pending) >= (s32)(iq->max_count - 1))
-		return -1;
-
-	__copy_cmd_into_iq(iq, cmd);
-
-	/* "index" is returned, host_write_index is modified. */
-	index = iq->host_write_index;
-	INCR_INDEX_BY1(iq->host_write_index, iq->max_count);
-	iq->fill_cnt++;
-
-	/* Flush the command into memory. We need to be sure the data is in
-	 * memory before indicating that the instruction is pending.
-	 */
-	wmb();
-
-	atomic_inc(&iq->instr_pending);
-
-	return index;
-}
-
 static inline struct iq_post_status
-__post_command2(struct octeon_device *octeon_dev __attribute__((unused)),
-		struct octeon_instr_queue *iq,
-		u32 force_db __attribute__((unused)), u8 *cmd)
+__post_command2(struct octeon_instr_queue *iq, u8 *cmd)
 {
 	struct iq_post_status st;
 
@@ -579,7 +536,7 @@ octeon_send_command(struct octeon_device *oct, u32 iq_no,
 	 */
 	spin_lock_bh(&iq->post_lock);
 
-	st = __post_command2(oct, iq, force_db, cmd);
+	st = __post_command2(iq, cmd);
 
 	if (st.status != IQ_SEND_FAILED) {
 		octeon_report_sent_bytes_to_bql(buf, reqtype);
@@ -618,8 +575,8 @@ octeon_prepare_soft_command(struct octeon_device *oct,
 	struct octeon_instr_irh *irh;
 	struct octeon_instr_rdp *rdp;
 
-	BUG_ON(opcode > 15);
-	BUG_ON(subcode > 127);
+	WARN_ON(opcode > 15);
+	WARN_ON(subcode > 127);
 
 	oct_cfg = octeon_get_conf(oct);
 
@@ -661,7 +618,6 @@ int octeon_send_soft_command(struct octeon_device *oct,
 {
 	struct octeon_instr_ih2 *ih2;
 	struct octeon_instr_irh *irh;
-	struct octeon_instr_rdp *rdp;
 	u32 len;
 
 	ih2 = (struct octeon_instr_ih2 *)&sc->cmd.cmd2.ih2;
@@ -671,12 +627,10 @@ int octeon_send_soft_command(struct octeon_device *oct,
 	}
 	irh = (struct octeon_instr_irh *)&sc->cmd.cmd2.irh;
 	if (irh->rflag) {
-		BUG_ON(!sc->dmarptr);
-		BUG_ON(!sc->status_word);
+		WARN_ON(!sc->dmarptr);
+		WARN_ON(!sc->status_word);
 		*sc->status_word = COMPLETION_WORD_INIT;
 
-		rdp = (struct octeon_instr_rdp *)&sc->cmd.cmd2.rdp;
-
 		sc->cmd.cmd2.rptr = sc->dmarptr;
 	}
 	len = (u32)ih2->dlengsz;
@@ -748,7 +702,7 @@ struct octeon_soft_command *octeon_alloc_soft_command(struct octeon_device *oct,
 	struct octeon_soft_command *sc = NULL;
 	struct list_head *tmp;
 
-	BUG_ON((offset + datasize + rdatasize + ctxsize) >
+	WARN_ON((offset + datasize + rdatasize + ctxsize) >
 	       SOFT_COMMAND_BUFFER_SIZE);
 
 	spin_lock(&oct->sc_buf_pool.lock);
@@ -795,7 +749,7 @@ struct octeon_soft_command *octeon_alloc_soft_command(struct octeon_device *oct,
 	offset = (offset + datasize + 127) & 0xffffff80;
 
 	if (rdatasize) {
-		BUG_ON(rdatasize < 16);
+		WARN_ON(rdatasize < 16);
 		sc->virtrptr = (u8 *)sc + offset;
 		sc->dmarptr = dma_addr + offset;
 		sc->rdatasize = rdatasize;
diff --git a/drivers/net/ethernet/cavium/liquidio/response_manager.c b/drivers/net/ethernet/cavium/liquidio/response_manager.c
index c93210f..0cc2f66 100644
--- a/drivers/net/ethernet/cavium/liquidio/response_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/response_manager.c
@@ -19,28 +19,14 @@
  * This file may also be available under a different license from Cavium.
  * Contact Cavium, Inc. for more information
  **********************************************************************/
-#include <linux/version.h>
-#include <linux/types.h>
-#include <linux/list.h>
-#include <linux/interrupt.h>
-#include <linux/dma-mapping.h>
 #include <linux/pci.h>
-#include <linux/kthread.h>
 #include <linux/netdevice.h>
-#include "octeon_config.h"
 #include "liquidio_common.h"
 #include "octeon_droq.h"
 #include "octeon_iq.h"
 #include "response_manager.h"
 #include "octeon_device.h"
-#include "octeon_nic.h"
 #include "octeon_main.h"
-#include "octeon_network.h"
-#include "cn66xx_regs.h"
-#include "cn66xx_device.h"
-#include "cn68xx_regs.h"
-#include "cn68xx_device.h"
-#include "liquidio_image.h"
 
 static void oct_poll_req_completion(struct work_struct *work);
 
-- 
1.8.3.1
