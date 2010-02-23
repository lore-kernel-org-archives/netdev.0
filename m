From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 3/7] drivers/net/ixgbe: Use
	pr_<level> and netif_<level>
Date: Mon, 22 Feb 2010 18:56:59 -0800
Message-ID: <7abb29a3e64d4df0cb94167def585a4cd4b12116.1266893507.git.joe@perches.com>
References: <cover.1266893507.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1266893507.git.joe@perches.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Convert DPRINTK, commonly used for debugging, to netif_<level>
Remove #define PFX
Use #define pr_fmt
Convert a few printks to pr_<level>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ixgbe/ixgbe.h         |    6 --
 drivers/net/ixgbe/ixgbe_common.h  |   15 ++++-
 drivers/net/ixgbe/ixgbe_dcb_nl.c  |    5 +-
 drivers/net/ixgbe/ixgbe_ethtool.c |   40 ++++++++------
 drivers/net/ixgbe/ixgbe_fcoe.c    |   25 ++++----
 drivers/net/ixgbe/ixgbe_main.c    |  110 ++++++++++++++++---------------------
 drivers/net/ixgbe/ixgbe_phy.c     |    2 +
 drivers/net/ixgbe/ixgbe_sriov.c   |   11 ++--
 8 files changed, 106 insertions(+), 108 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 19e94ee..3c25bf0 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -44,12 +44,6 @@
 #include <linux/dca.h>
 #endif
 
-#define PFX "ixgbe: "
-#define DPRINTK(nlevel, klevel, fmt, args...) \
-	((void)((NETIF_MSG_##nlevel & adapter->msg_enable) && \
-	printk(KERN_##klevel PFX "%s: %s: " fmt, adapter->netdev->name, \
-		__func__ , ## args)))
-
 /* TX/RX descriptor defines */
 #define IXGBE_DEFAULT_TXD		    512
 #define IXGBE_MAX_TXD			   4096
diff --git a/drivers/net/ixgbe/ixgbe_common.h b/drivers/net/ixgbe/ixgbe_common.h
index 13606d4..f3e5672 100644
--- a/drivers/net/ixgbe/ixgbe_common.h
+++ b/drivers/net/ixgbe/ixgbe_common.h
@@ -98,11 +98,18 @@ s32 ixgbe_blink_led_stop_generic(struct ixgbe_hw *hw, u32 index);
 #define IXGBE_WRITE_FLUSH(a) IXGBE_READ_REG(a, IXGBE_STATUS)
 
 #ifdef DEBUG
-extern char *ixgbe_get_hw_dev_name(struct ixgbe_hw *hw);
-#define hw_dbg(hw, format, arg...) \
-	printk(KERN_DEBUG "%s: " format, ixgbe_get_hw_dev_name(hw), ##arg)
+#define hw_dbg(_hw, format, arg...)					\
+	netdev_printk(KERN_DEBUG,					\
+		((struct ixgbe_adapter *)(((_hw)->back))->netdev,	\
+		      format, ##arg)
 #else
-#define hw_dbg(hw, format, arg...) do {} while (0)
+#define hw_dbg(_hw, format, arg...)					\
+do {									\
+	if (0)								\
+		netdev_printk(KERN_DEBUG,				\
+			      ((struct ixgbe_adapter *)((_hw)->back))->netdev, \
+			      format, ##arg);				\
+} while (0)
 #endif
 
 #endif /* IXGBE_COMMON */
diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index dd4883f..b233d7e 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -26,6 +26,8 @@
 
 *******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include "ixgbe.h"
 #include <linux/dcbnl.h>
 #include "ixgbe_dcb_82598.h"
@@ -121,7 +123,8 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 			goto out;
 
 		if (!(adapter->flags & IXGBE_FLAG_MSIX_ENABLED)) {
-			DPRINTK(DRV, ERR, "Enable failed, needs MSI-X\n");
+			netif_err(adapter, drv, adapter->netdev,
+				  "Enable failed, needs MSI-X\n");
 			err = 1;
 			goto out;
 		}
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 0d23434..2264665 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -25,6 +25,8 @@
 
 *******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 /* ethtool support for ixgbe */
 
 #include <linux/types.h>
@@ -293,8 +295,8 @@ static int ixgbe_set_settings(struct net_device *netdev,
 		hw->mac.autotry_restart = true;
 		err = hw->mac.ops.setup_link(hw, advertised, true, true);
 		if (err) {
-			DPRINTK(PROBE, INFO,
-			        "setup link failed with code %d\n", err);
+			netif_info(adapter, probe, adapter->netdev,
+				   "setup link failed with code %d\n", err);
 			hw->mac.ops.setup_link(hw, old, true, true);
 		}
 	} else {
@@ -1189,8 +1191,9 @@ static struct ixgbe_reg_test reg_test_82598[] = {
 		writel((_test[pat] & W), (adapter->hw.hw_addr + R));          \
 		val = readl(adapter->hw.hw_addr + R);                         \
 		if (val != (_test[pat] & W & M)) {                            \
-			DPRINTK(DRV, ERR, "pattern test reg %04X failed: got "\
-					  "0x%08X expected 0x%08X\n",         \
+			netif_err(adapter, drv, adapter->netdev,	\
+				  "pattern test reg %04X failed: got "	\
+				  "0x%08X expected 0x%08X\n",		\
 				R, val, (_test[pat] & W & M));                \
 			*data = R;                                            \
 			writel(before, adapter->hw.hw_addr + R);              \
@@ -1207,8 +1210,9 @@ static struct ixgbe_reg_test reg_test_82598[] = {
 	writel((W & M), (adapter->hw.hw_addr + R));                           \
 	val = readl(adapter->hw.hw_addr + R);                                 \
 	if ((W & M) != (val & M)) {                                           \
-		DPRINTK(DRV, ERR, "set/check reg %04X test failed: got 0x%08X "\
-				 "expected 0x%08X\n", R, (val & M), (W & M)); \
+		netif_err(adapter, drv, adapter->netdev,		\
+			  "set/check reg %04X test failed: got 0x%08X "	\
+			  "expected 0x%08X\n", R, (val & M), (W & M));	\
 		*data = R;                                                    \
 		writel(before, (adapter->hw.hw_addr + R));                    \
 		return 1;                                                     \
@@ -1241,8 +1245,9 @@ static int ixgbe_reg_test(struct ixgbe_adapter *adapter, u64 *data)
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_STATUS, toggle);
 	after = IXGBE_READ_REG(&adapter->hw, IXGBE_STATUS) & toggle;
 	if (value != after) {
-		DPRINTK(DRV, ERR, "failed STATUS register test got: "
-		        "0x%08X expected: 0x%08X\n", after, value);
+		netif_err(adapter, drv, adapter->netdev,
+			  "failed STATUS register test got: "
+			  "0x%08X expected: 0x%08X\n", after, value);
 		*data = 1;
 		return 1;
 	}
@@ -1342,8 +1347,9 @@ static int ixgbe_intr_test(struct ixgbe_adapter *adapter, u64 *data)
 		*data = 1;
 		return -1;
 	}
-	DPRINTK(HW, INFO, "testing %s interrupt\n",
-		(shared_int ? "shared" : "unshared"));
+	netif_info(adapter, hw, adapter->netdev,
+		   "testing %s interrupt\n",
+		   shared_int ? "shared" : "unshared");
 
 	/* Disable all the interrupts */
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, 0xFFFFFFFF);
@@ -1848,7 +1854,7 @@ static void ixgbe_diag_test(struct net_device *netdev,
 	if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
 		/* Offline tests */
 
-		DPRINTK(HW, INFO, "offline testing starting\n");
+		netif_info(adapter, hw, adapter->netdev, "offline testing starting\n");
 
 		/* Link test performed before hardware reset so autoneg doesn't
 		 * interfere with test result */
@@ -1861,17 +1867,17 @@ static void ixgbe_diag_test(struct net_device *netdev,
 		else
 			ixgbe_reset(adapter);
 
-		DPRINTK(HW, INFO, "register testing starting\n");
+		netif_info(adapter, hw, adapter->netdev, "register testing starting\n");
 		if (ixgbe_reg_test(adapter, &data[0]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
 		ixgbe_reset(adapter);
-		DPRINTK(HW, INFO, "eeprom testing starting\n");
+		netif_info(adapter, hw, adapter->netdev, "eeprom testing starting\n");
 		if (ixgbe_eeprom_test(adapter, &data[1]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
 		ixgbe_reset(adapter);
-		DPRINTK(HW, INFO, "interrupt testing starting\n");
+		netif_info(adapter, hw, adapter->netdev, "interrupt testing starting\n");
 		if (ixgbe_intr_test(adapter, &data[2]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
@@ -1879,14 +1885,14 @@ static void ixgbe_diag_test(struct net_device *netdev,
 		 * loopback diagnostic. */
 		if (adapter->flags & (IXGBE_FLAG_SRIOV_ENABLED |
 				      IXGBE_FLAG_VMDQ_ENABLED)) {
-			DPRINTK(HW, INFO, "Skip MAC loopback diagnostic in VT "
+			netif_info(adapter, hw, adapter->netdev, "Skip MAC loopback diagnostic in VT "
 				"mode\n");
 			data[3] = 0;
 			goto skip_loopback;
 		}
 
 		ixgbe_reset(adapter);
-		DPRINTK(HW, INFO, "loopback testing starting\n");
+		netif_info(adapter, hw, adapter->netdev, "loopback testing starting\n");
 		if (ixgbe_loopback_test(adapter, &data[3]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
 
@@ -1897,7 +1903,7 @@ skip_loopback:
 		if (if_running)
 			dev_open(netdev);
 	} else {
-		DPRINTK(HW, INFO, "online testing starting\n");
+		netif_info(adapter, hw, adapter->netdev, "online testing starting\n");
 		/* Online tests */
 		if (ixgbe_link_test(adapter, &data[4]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index 4123dec..16c1b92 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -25,6 +25,7 @@
 
 *******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include "ixgbe.h"
 #ifdef CONFIG_IXGBE_DCB
@@ -163,19 +164,19 @@ int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
 
 	adapter = netdev_priv(netdev);
 	if (xid >= IXGBE_FCOE_DDP_MAX) {
-		DPRINTK(DRV, WARNING, "xid=0x%x out-of-range\n", xid);
+		netif_warn(adapter, drv, adapter->netdev, "xid=0x%x out-of-range\n", xid);
 		return 0;
 	}
 
 	fcoe = &adapter->fcoe;
 	if (!fcoe->pool) {
-		DPRINTK(DRV, WARNING, "xid=0x%x no ddp pool for fcoe\n", xid);
+		netif_warn(adapter, drv, adapter->netdev, "xid=0x%x no ddp pool for fcoe\n", xid);
 		return 0;
 	}
 
 	ddp = &fcoe->ddp[xid];
 	if (ddp->sgl) {
-		DPRINTK(DRV, ERR, "xid 0x%x w/ non-null sgl=%p nents=%d\n",
+		netif_err(adapter, drv, adapter->netdev, "xid 0x%x w/ non-null sgl=%p nents=%d\n",
 			xid, ddp->sgl, ddp->sgc);
 		return 0;
 	}
@@ -184,14 +185,14 @@ int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
 	/* setup dma from scsi command sgl */
 	dmacount = pci_map_sg(adapter->pdev, sgl, sgc, DMA_FROM_DEVICE);
 	if (dmacount == 0) {
-		DPRINTK(DRV, ERR, "xid 0x%x DMA map error\n", xid);
+		netif_err(adapter, drv, adapter->netdev, "xid 0x%x DMA map error\n", xid);
 		return 0;
 	}
 
 	/* alloc the udl from our ddp pool */
 	ddp->udl = pci_pool_alloc(fcoe->pool, GFP_KERNEL, &ddp->udp);
 	if (!ddp->udl) {
-		DPRINTK(DRV, ERR, "failed allocated ddp context\n");
+		netif_err(adapter, drv, adapter->netdev, "failed allocated ddp context\n");
 		goto out_noddp_unmap;
 	}
 	ddp->sgl = sgl;
@@ -229,7 +230,7 @@ int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
 			j++;
 			/* max number of buffers allowed in one DDP context */
 			if (j > IXGBE_BUFFCNT_MAX) {
-				DPRINTK(DRV, ERR, "xid=%x:%d,%d,%d:addr=%llx "
+				netif_err(adapter, drv, adapter->netdev, "xid=%x:%d,%d,%d:addr=%llx "
 					"not enough descriptors\n",
 					xid, i, j, dmacount, (u64)addr);
 				goto out_noddp_free;
@@ -381,7 +382,7 @@ int ixgbe_fso(struct ixgbe_adapter *adapter,
 	struct fc_frame_header *fh;
 
 	if (skb_is_gso(skb) && (skb_shinfo(skb)->gso_type != SKB_GSO_FCOE)) {
-		DPRINTK(DRV, ERR, "Wrong gso type %d:expecting SKB_GSO_FCOE\n",
+		netif_err(adapter, drv, adapter->netdev, "Wrong gso type %d:expecting SKB_GSO_FCOE\n",
 			skb_shinfo(skb)->gso_type);
 		return -EINVAL;
 	}
@@ -408,7 +409,7 @@ int ixgbe_fso(struct ixgbe_adapter *adapter,
 		fcoe_sof_eof |= IXGBE_ADVTXD_FCOEF_SOF;
 		break;
 	default:
-		DPRINTK(DRV, WARNING, "unknown sof = 0x%x\n", sof);
+		netif_warn(adapter, drv, adapter->netdev, "unknown sof = 0x%x\n", sof);
 		return -EINVAL;
 	}
 
@@ -435,7 +436,7 @@ int ixgbe_fso(struct ixgbe_adapter *adapter,
 		fcoe_sof_eof |= IXGBE_ADVTXD_FCOEF_EOF_A;
 		break;
 	default:
-		DPRINTK(DRV, WARNING, "unknown eof = 0x%x\n", eof);
+		netif_warn(adapter, drv, adapter->netdev, "unknown eof = 0x%x\n", eof);
 		return -EINVAL;
 	}
 
@@ -511,7 +512,7 @@ void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter)
 					     adapter->pdev, IXGBE_FCPTR_MAX,
 					     IXGBE_FCPTR_ALIGN, PAGE_SIZE);
 		if (!fcoe->pool)
-			DPRINTK(DRV, ERR,
+			netif_err(adapter, drv, adapter->netdev,
 				"failed to allocated FCoE DDP pool\n");
 
 		spin_lock_init(&fcoe->lock);
@@ -599,7 +600,7 @@ int ixgbe_fcoe_enable(struct net_device *netdev)
 	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
 		goto out_enable;
 
-	DPRINTK(DRV, INFO, "Enabling FCoE offload features.\n");
+	netif_info(adapter, drv, adapter->netdev, "Enabling FCoE offload features.\n");
 	if (netif_running(netdev))
 		netdev->netdev_ops->ndo_stop(netdev);
 
@@ -645,7 +646,7 @@ int ixgbe_fcoe_disable(struct net_device *netdev)
 	if (!(adapter->flags & IXGBE_FLAG_FCOE_ENABLED))
 		goto out_disable;
 
-	DPRINTK(DRV, INFO, "Disabling FCoE offload features.\n");
+	netif_info(adapter, drv, adapter->netdev, "Disabling FCoE offload features.\n");
 	if (netif_running(netdev))
 		netdev->netdev_ops->ndo_stop(netdev);
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 43a8de3..5b80771 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -25,6 +25,8 @@
 
 *******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/module.h>
 #include <linux/pci.h>
@@ -354,7 +356,7 @@ static inline bool ixgbe_check_tx_hang(struct ixgbe_adapter *adapter,
 		/* detected Tx unit hang */
 		union ixgbe_adv_tx_desc *tx_desc;
 		tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);
-		DPRINTK(DRV, ERR, "Detected Tx Unit Hang\n"
+		netif_err(adapter, drv, adapter->netdev, "Detected Tx Unit Hang\n"
 			"  Tx Queue             <%d>\n"
 			"  TDH, TDT             <%x>, <%x>\n"
 			"  next_to_use          <%x>\n"
@@ -470,7 +472,7 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 	if (adapter->detect_tx_hung) {
 		if (ixgbe_check_tx_hang(adapter, tx_ring, i)) {
 			/* schedule immediate reset if we believe we hung */
-			DPRINTK(PROBE, INFO,
+			netif_info(adapter, probe, adapter->netdev,
 			        "tx hang %d detected, resetting adapter\n",
 			        adapter->tx_timeout_count + 1);
 			ixgbe_tx_timeout(adapter->netdev);
@@ -1245,7 +1247,7 @@ static void ixgbe_check_fan_failure(struct ixgbe_adapter *adapter, u32 eicr)
 
 	if ((adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE) &&
 	    (eicr & IXGBE_EICR_GPI_SDP1)) {
-		DPRINTK(PROBE, CRIT, "Fan has stopped, replace the adapter\n");
+		netif_crit(adapter, probe, adapter->netdev, "Fan has stopped, replace the adapter\n");
 		/* write to clear the interrupt */
 		IXGBE_WRITE_REG(hw, IXGBE_EICR, IXGBE_EICR_GPI_SDP1);
 	}
@@ -1727,7 +1729,7 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 		                  handler, 0, adapter->name[vector],
 		                  adapter->q_vector[vector]);
 		if (err) {
-			DPRINTK(PROBE, ERR,
+			netif_err(adapter, probe, adapter->netdev,
 			        "request_irq failed for MSIX interrupt "
 			        "Error: %d\n", err);
 			goto free_queue_irqs;
@@ -1738,7 +1740,7 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 	err = request_irq(adapter->msix_entries[vector].vector,
 	                  ixgbe_msix_lsc, 0, adapter->name[vector], netdev);
 	if (err) {
-		DPRINTK(PROBE, ERR,
+		netif_err(adapter, probe, adapter->netdev,
 			"request_irq for msix_lsc failed: %d\n", err);
 		goto free_queue_irqs;
 	}
@@ -1922,7 +1924,7 @@ static int ixgbe_request_irq(struct ixgbe_adapter *adapter)
 	}
 
 	if (err)
-		DPRINTK(PROBE, ERR, "request_irq failed, Error %d\n", err);
+		netif_err(adapter, probe, adapter->netdev, "request_irq failed, Error %d\n", err);
 
 	return err;
 }
@@ -1993,7 +1995,7 @@ static void ixgbe_configure_msi_and_legacy(struct ixgbe_adapter *adapter)
 	map_vector_to_rxq(adapter, 0, 0);
 	map_vector_to_txq(adapter, 0, 0);
 
-	DPRINTK(HW, INFO, "Legacy interrupt IVAR setup done\n");
+	netif_info(adapter, hw, adapter->netdev, "Legacy interrupt IVAR setup done\n");
 }
 
 /**
@@ -2808,7 +2810,7 @@ static inline void ixgbe_rx_desc_queue_enable(struct ixgbe_adapter *adapter,
 			msleep(1);
 	}
 	if (k >= IXGBE_MAX_RX_DESC_POLL) {
-		DPRINTK(DRV, ERR, "RXDCTL.ENABLE on Rx queue %d "
+		netif_err(adapter, drv, adapter->netdev, "RXDCTL.ENABLE on Rx queue %d "
 		        "not set within the polling period\n", rxr);
 	}
 	ixgbe_release_rx_desc(&adapter->hw, adapter->rx_ring[rxr],
@@ -2926,7 +2928,7 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 			} while (--wait_loop &&
 			         !(txdctl & IXGBE_TXDCTL_ENABLE));
 			if (!wait_loop)
-				DPRINTK(DRV, ERR, "Could not enable "
+				netif_err(adapter, drv, adapter->netdev, "Could not enable "
 				        "Tx Queue %d\n", j);
 		}
 	}
@@ -2971,7 +2973,7 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE) {
 		u32 esdp = IXGBE_READ_REG(hw, IXGBE_ESDP);
 		if (esdp & IXGBE_ESDP_SDP1)
-			DPRINTK(DRV, CRIT,
+			netif_crit(adapter, drv, adapter->netdev,
 				"Fan has stopped, replace the adapter\n");
 	}
 
@@ -3001,7 +3003,7 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	} else {
 		err = ixgbe_non_sfp_link_config(hw);
 		if (err)
-			DPRINTK(PROBE, ERR, "link_config FAILED %d\n", err);
+			netif_err(adapter, probe, adapter->netdev, "link_config FAILED %d\n", err);
 	}
 
 	for (i = 0; i < adapter->num_tx_queues; i++)
@@ -3429,12 +3431,12 @@ static inline bool ixgbe_set_fcoe_queues(struct ixgbe_adapter *adapter)
 		adapter->num_tx_queues = 1;
 #ifdef CONFIG_IXGBE_DCB
 		if (adapter->flags & IXGBE_FLAG_DCB_ENABLED) {
-			DPRINTK(PROBE, INFO, "FCoE enabled with DCB \n");
+			netif_info(adapter, probe, adapter->netdev, "FCoE enabled with DCB \n");
 			ixgbe_set_dcb_queues(adapter);
 		}
 #endif
 		if (adapter->flags & IXGBE_FLAG_RSS_ENABLED) {
-			DPRINTK(PROBE, INFO, "FCoE enabled with RSS \n");
+			netif_info(adapter, probe, adapter->netdev, "FCoE enabled with RSS \n");
 			if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) ||
 			    (adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
 				ixgbe_set_fdir_queues(adapter);
@@ -3547,7 +3549,7 @@ static void ixgbe_acquire_msix_vectors(struct ixgbe_adapter *adapter,
 		 * This just means we'll go with either a single MSI
 		 * vector or fall back to legacy interrupts.
 		 */
-		DPRINTK(HW, DEBUG, "Unable to allocate MSI-X interrupts\n");
+		netif_printk(adapter, hw, KERN_DEBUG, adapter->netdev, "Unable to allocate MSI-X interrupts\n");
 		adapter->flags &= ~IXGBE_FLAG_MSIX_ENABLED;
 		kfree(adapter->msix_entries);
 		adapter->msix_entries = NULL;
@@ -3944,8 +3946,9 @@ static int ixgbe_set_interrupt_capability(struct ixgbe_adapter *adapter)
 	if (!err) {
 		adapter->flags |= IXGBE_FLAG_MSI_ENABLED;
 	} else {
-		DPRINTK(HW, DEBUG, "Unable to allocate MSI interrupt, "
-		        "falling back to legacy.  Error: %d\n", err);
+		netif_printk(adapter, hw, KERN_DEBUG, adapter->netdev,
+			     "Unable to allocate MSI interrupt, "
+			     "falling back to legacy.  Error: %d\n", err);
 		/* reset err */
 		err = 0;
 	}
@@ -4067,24 +4070,24 @@ int ixgbe_init_interrupt_scheme(struct ixgbe_adapter *adapter)
 
 	err = ixgbe_set_interrupt_capability(adapter);
 	if (err) {
-		DPRINTK(PROBE, ERR, "Unable to setup interrupt capabilities\n");
+		netif_err(adapter, probe, adapter->netdev, "Unable to setup interrupt capabilities\n");
 		goto err_set_interrupt;
 	}
 
 	err = ixgbe_alloc_q_vectors(adapter);
 	if (err) {
-		DPRINTK(PROBE, ERR, "Unable to allocate memory for queue "
+		netif_err(adapter, probe, adapter->netdev, "Unable to allocate memory for queue "
 		        "vectors\n");
 		goto err_alloc_q_vectors;
 	}
 
 	err = ixgbe_alloc_queues(adapter);
 	if (err) {
-		DPRINTK(PROBE, ERR, "Unable to allocate memory for queues\n");
+		netif_err(adapter, probe, adapter->netdev, "Unable to allocate memory for queues\n");
 		goto err_alloc_queues;
 	}
 
-	DPRINTK(DRV, INFO, "Multiqueue %s: Rx Queue count = %u, "
+	netif_info(adapter, drv, adapter->netdev, "Multiqueue %s: Rx Queue count = %u, "
 	        "Tx Queue count = %u\n",
 	        (adapter->num_rx_queues > 1) ? "Enabled" :
 	        "Disabled", adapter->num_rx_queues, adapter->num_tx_queues);
@@ -4165,7 +4168,7 @@ static void ixgbe_sfp_task(struct work_struct *work)
 				"supported module.\n");
 			unregister_netdev(adapter->netdev);
 		} else {
-			DPRINTK(PROBE, INFO, "detected SFP+: %d\n",
+			netif_info(adapter, probe, adapter->netdev, "detected SFP+: %d\n",
 			        hw->phy.sfp_type);
 		}
 		/* don't need this routine any more */
@@ -4344,7 +4347,7 @@ int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
 err:
 	vfree(tx_ring->tx_buffer_info);
 	tx_ring->tx_buffer_info = NULL;
-	DPRINTK(PROBE, ERR, "Unable to allocate memory for the transmit "
+	netif_err(adapter, probe, adapter->netdev, "Unable to allocate memory for the transmit "
 	                    "descriptor ring\n");
 	return -ENOMEM;
 }
@@ -4367,7 +4370,7 @@ static int ixgbe_setup_all_tx_resources(struct ixgbe_adapter *adapter)
 		err = ixgbe_setup_tx_resources(adapter, adapter->tx_ring[i]);
 		if (!err)
 			continue;
-		DPRINTK(PROBE, ERR, "Allocation for Tx Queue %u failed\n", i);
+		netif_err(adapter, probe, adapter->netdev, "Allocation for Tx Queue %u failed\n", i);
 		break;
 	}
 
@@ -4392,7 +4395,7 @@ int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
 	if (!rx_ring->rx_buffer_info)
 		rx_ring->rx_buffer_info = vmalloc(size);
 	if (!rx_ring->rx_buffer_info) {
-		DPRINTK(PROBE, ERR,
+		netif_err(adapter, probe, adapter->netdev,
 		        "vmalloc allocation failed for the rx desc ring\n");
 		goto alloc_failed;
 	}
@@ -4405,7 +4408,7 @@ int ixgbe_setup_rx_resources(struct ixgbe_adapter *adapter,
 	rx_ring->desc = pci_alloc_consistent(pdev, rx_ring->size, &rx_ring->dma);
 
 	if (!rx_ring->desc) {
-		DPRINTK(PROBE, ERR,
+		netif_err(adapter, probe, adapter->netdev,
 		        "Memory allocation failed for the rx desc ring\n");
 		vfree(rx_ring->rx_buffer_info);
 		goto alloc_failed;
@@ -4439,7 +4442,7 @@ static int ixgbe_setup_all_rx_resources(struct ixgbe_adapter *adapter)
 		err = ixgbe_setup_rx_resources(adapter, adapter->rx_ring[i]);
 		if (!err)
 			continue;
-		DPRINTK(PROBE, ERR, "Allocation for Rx Queue %u failed\n", i);
+		netif_err(adapter, probe, adapter->netdev, "Allocation for Rx Queue %u failed\n", i);
 		break;
 	}
 
@@ -4536,7 +4539,7 @@ static int ixgbe_change_mtu(struct net_device *netdev, int new_mtu)
 	if ((new_mtu < 68) || (max_frame > IXGBE_MAX_JUMBO_FRAME_SIZE))
 		return -EINVAL;
 
-	DPRINTK(PROBE, INFO, "changing MTU from %d to %d\n",
+	netif_info(adapter, probe, adapter->netdev, "changing MTU from %d to %d\n",
 	        netdev->mtu, new_mtu);
 	/* must set new MTU before calling down or up */
 	netdev->mtu = new_mtu;
@@ -4650,8 +4653,7 @@ static int ixgbe_resume(struct pci_dev *pdev)
 
 	err = pci_enable_device_mem(pdev);
 	if (err) {
-		printk(KERN_ERR "ixgbe: Cannot enable PCI device from "
-				"suspend\n");
+		pr_err("Cannot enable PCI device from suspend\n");
 		return err;
 	}
 	pci_set_master(pdev);
@@ -4660,8 +4662,7 @@ static int ixgbe_resume(struct pci_dev *pdev)
 
 	err = ixgbe_init_interrupt_scheme(adapter);
 	if (err) {
-		printk(KERN_ERR "ixgbe: Cannot initialize interrupts for "
-		                "device\n");
+		pr_err("Cannot initialize interrupts for device\n");
 		return err;
 	}
 
@@ -5048,7 +5049,7 @@ static void ixgbe_fdir_reinit_task(struct work_struct *work)
 			set_bit(__IXGBE_FDIR_INIT_DONE,
 			        &(adapter->tx_ring[i]->reinit_state));
 	} else {
-		DPRINTK(PROBE, ERR, "failed to finish FDIR re-initialization, "
+		netif_err(adapter, probe, adapter->netdev, "failed to finish FDIR re-initialization, "
 		        "ignored adding FDIR ATR filters \n");
 	}
 	/* Done FDIR Re-initialization, enable transmits */
@@ -5120,9 +5121,7 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 				flow_tx = !!(rmcs & IXGBE_RMCS_TFCE_802_3X);
 			}
 
-			printk(KERN_INFO "ixgbe: %s NIC Link is Up %s, "
-			       "Flow Control: %s\n",
-			       netdev->name,
+			netdev_info(netdev, "NIC Link is Up %s, Flow Control: %s\n",
 			       (link_speed == IXGBE_LINK_SPEED_10GB_FULL ?
 			        "10 Gbps" :
 			        (link_speed == IXGBE_LINK_SPEED_1GB_FULL ?
@@ -5140,8 +5139,7 @@ static void ixgbe_watchdog_task(struct work_struct *work)
 		adapter->link_up = false;
 		adapter->link_speed = 0;
 		if (netif_carrier_ok(netdev)) {
-			printk(KERN_INFO "ixgbe: %s NIC Link is Down\n",
-			       netdev->name);
+			netdev_info(netdev, "NIC Link is Down\n");
 			netif_carrier_off(netdev);
 		}
 	}
@@ -5317,9 +5315,9 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 				break;
 			default:
 				if (unlikely(net_ratelimit())) {
-					DPRINTK(PROBE, WARNING,
-					 "partial checksum but proto=%x!\n",
-					 skb->protocol);
+					netif_warn(adapter, probe, adapter->netdev,
+						   "partial checksum but proto=%x!\n",
+						   skb->protocol);
 				}
 				break;
 			}
@@ -5913,7 +5911,7 @@ static void __devinit ixgbe_probe_vf(struct ixgbe_adapter *adapter,
 	adapter->flags |= IXGBE_FLAG_SRIOV_ENABLED;
 	err = pci_enable_sriov(adapter->pdev, adapter->num_vfs);
 	if (err) {
-		DPRINTK(PROBE, ERR,
+		netif_err(adapter, probe, adapter->netdev,
 			"Failed to enable PCI sriov: %d\n", err);
 		goto err_novfs;
 	}
@@ -5938,7 +5936,7 @@ static void __devinit ixgbe_probe_vf(struct ixgbe_adapter *adapter,
 	}
 
 	/* Oh oh */
-	DPRINTK(PROBE, ERR,
+	netif_err(adapter, probe, adapter->netdev,
 		"Unable to allocate memory for VF "
 		"Data Storage - SRIOV disabled\n");
 	pci_disable_sriov(adapter->pdev);
@@ -6099,7 +6097,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	if (adapter->flags & IXGBE_FLAG_FAN_FAIL_CAPABLE) {
 		u32 esdp = IXGBE_READ_REG(hw, IXGBE_ESDP);
 		if (esdp & IXGBE_ESDP_SDP1)
-			DPRINTK(PROBE, CRIT,
+			netif_crit(adapter, probe, adapter->netdev,
 				"Fan has stopped, replace the adapter\n");
 	}
 
@@ -6279,7 +6277,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	}
 #endif
 	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
-		DPRINTK(PROBE, INFO, "IOV is enabled with %d VFs\n",
+		netif_info(adapter, probe, adapter->netdev, "IOV is enabled with %d VFs\n",
 			adapter->num_vfs);
 		for (i = 0; i < adapter->num_vfs; i++)
 			ixgbe_vf_configuration(pdev, (i | 0x10000000));
@@ -6378,7 +6376,7 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	pci_release_selected_regions(pdev, pci_select_bars(pdev,
 	                             IORESOURCE_MEM));
 
-	DPRINTK(PROBE, INFO, "complete\n");
+	netif_info(adapter, probe, adapter->netdev, "complete\n");
 
 	free_netdev(netdev);
 
@@ -6428,7 +6426,7 @@ static pci_ers_result_t ixgbe_io_slot_reset(struct pci_dev *pdev)
 	int err;
 
 	if (pci_enable_device_mem(pdev)) {
-		DPRINTK(PROBE, ERR,
+		netif_err(adapter, probe, adapter->netdev,
 		        "Cannot re-enable PCI device after reset.\n");
 		result = PCI_ERS_RESULT_DISCONNECT;
 	} else {
@@ -6467,7 +6465,7 @@ static void ixgbe_io_resume(struct pci_dev *pdev)
 
 	if (netif_running(netdev)) {
 		if (ixgbe_up(adapter)) {
-			DPRINTK(PROBE, INFO, "ixgbe_up failed after reset\n");
+			netif_info(adapter, probe, adapter->netdev, "ixgbe_up failed after reset\n");
 			return;
 		}
 	}
@@ -6503,10 +6501,8 @@ static struct pci_driver ixgbe_driver = {
 static int __init ixgbe_init_module(void)
 {
 	int ret;
-	printk(KERN_INFO "%s: %s - version %s\n", ixgbe_driver_name,
-	       ixgbe_driver_string, ixgbe_driver_version);
-
-	printk(KERN_INFO "%s: %s\n", ixgbe_driver_name, ixgbe_copyright);
+	pr_info("%s - version %s\n", ixgbe_driver_string, ixgbe_driver_version);
+	pr_info("%s\n", ixgbe_copyright);
 
 #ifdef CONFIG_IXGBE_DCA
 	dca_register_notify(&dca_notifier);
@@ -6545,18 +6541,6 @@ static int ixgbe_notify_dca(struct notifier_block *nb, unsigned long event,
 }
 
 #endif /* CONFIG_IXGBE_DCA */
-#ifdef DEBUG
-/**
- * ixgbe_get_hw_dev_name - return device name string
- * used by hardware layer to print debugging information
- **/
-char *ixgbe_get_hw_dev_name(struct ixgbe_hw *hw)
-{
-	struct ixgbe_adapter *adapter = hw->back;
-	return adapter->netdev->name;
-}
-
-#endif
 module_exit(ixgbe_exit_module);
 
 /* ixgbe_main.c */
diff --git a/drivers/net/ixgbe/ixgbe_phy.c b/drivers/net/ixgbe/ixgbe_phy.c
index 1c1efd3..33b7cfc 100644
--- a/drivers/net/ixgbe/ixgbe_phy.c
+++ b/drivers/net/ixgbe/ixgbe_phy.c
@@ -28,7 +28,9 @@
 #include <linux/pci.h>
 #include <linux/delay.h>
 #include <linux/sched.h>
+#include <linux/netdevice.h>
 
+#include "ixgbe.h"
 #include "ixgbe_common.h"
 #include "ixgbe_phy.h"
 
diff --git a/drivers/net/ixgbe/ixgbe_sriov.c b/drivers/net/ixgbe/ixgbe_sriov.c
index d4cd20f..068c031 100644
--- a/drivers/net/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ixgbe/ixgbe_sriov.c
@@ -25,6 +25,7 @@
 
 *******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/types.h>
 #include <linux/module.h>
@@ -152,7 +153,7 @@ int ixgbe_set_vf_mac(struct ixgbe_adapter *adapter,
 	adapter->vfinfo[vf].rar = hw->mac.ops.set_rar(hw, vf + 1, mac_addr,
 	                                              vf, IXGBE_RAH_AV);
 	if (adapter->vfinfo[vf].rar < 0) {
-		DPRINTK(DRV, ERR, "Could not set MAC Filter for VF %d\n", vf);
+		netif_err(adapter, drv, adapter->netdev, "Could not set MAC Filter for VF %d\n", vf);
 		return -1;
 	}
 
@@ -172,7 +173,7 @@ int ixgbe_vf_configuration(struct pci_dev *pdev, unsigned int event_mask)
 
 	if (enable) {
 		random_ether_addr(vf_mac_addr);
-		DPRINTK(PROBE, INFO, "IOV: VF %d is enabled "
+		netif_info(adapter, probe, adapter->netdev, "IOV: VF %d is enabled "
 		       "mac %02X:%02X:%02X:%02X:%02X:%02X\n",
 		       vfn,
 		       vf_mac_addr[0], vf_mac_addr[1], vf_mac_addr[2],
@@ -221,7 +222,7 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 	retval = ixgbe_read_mbx(hw, msgbuf, mbx_size, vf);
 
 	if (retval)
-		printk(KERN_ERR "Error receiving message from VF\n");
+		pr_err("Error receiving message from VF\n");
 
 	/* this is a message we already processed, do nothing */
 	if (msgbuf[0] & (IXGBE_VT_MSGTYPE_ACK | IXGBE_VT_MSGTYPE_NACK))
@@ -235,7 +236,7 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 	if (msgbuf[0] == IXGBE_VF_RESET) {
 		unsigned char *vf_mac = adapter->vfinfo[vf].vf_mac_addresses;
 		u8 *addr = (u8 *)(&msgbuf[1]);
-		DPRINTK(PROBE, INFO, "VF Reset msg received from vf %d\n", vf);
+		netif_info(adapter, probe, adapter->netdev, "VF Reset msg received from vf %d\n", vf);
 		adapter->vfinfo[vf].clear_to_send = false;
 		ixgbe_vf_reset_msg(adapter, vf);
 		adapter->vfinfo[vf].clear_to_send = true;
@@ -286,7 +287,7 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 		retval = ixgbe_set_vf_vlan(adapter, add, vid, vf);
 		break;
 	default:
-		DPRINTK(DRV, ERR, "Unhandled Msg %8.8x\n", msgbuf[0]);
+		netif_err(adapter, drv, adapter->netdev, "Unhandled Msg %8.8x\n", msgbuf[0]);
 		retval = IXGBE_ERR_MBX;
 		break;
 	}
-- 
1.7.0.14.g7e948


------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
