From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 05/21] igb: Add DMA Coalescing feature to driver
Date: Sat, 12 Mar 2011 04:20:12 -0800
Message-ID: <1299932428-3114-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:11283 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753846Ab1CLMUx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2011 07:20:53 -0500
In-Reply-To: <1299932428-3114-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch add DMA Coalescing which is a power-saving feature that
coalesces DMA writes in order to stay in a low-power state as much
as possible.  Feature is disabled by default.

Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/igb/e1000_defines.h |   29 ++++++++++++++++++-
 drivers/net/igb/e1000_regs.h    |    9 ++++++
 drivers/net/igb/igb.h           |    6 ++++
 drivers/net/igb/igb_ethtool.c   |    6 ++++
 drivers/net/igb/igb_main.c      |   59 ++++++++++++++++++++++++++++++++++++++-
 5 files changed, 107 insertions(+), 2 deletions(-)

diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index 97969ad..9bb1928 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -287,7 +287,34 @@
 #define E1000_TCTL_COLD   0x003ff000    /* collision distance */
 #define E1000_TCTL_RTLC   0x01000000    /* Re-transmit on late collision */
 
-/* Transmit Arbitration Count */
+/* DMA Coalescing register fields */
+#define E1000_DMACR_DMACWT_MASK         0x00003FFF /* DMA Coalescing
+							* Watchdog Timer */
+#define E1000_DMACR_DMACTHR_MASK        0x00FF0000 /* DMA Coalescing Receive
+							* Threshold */
+#define E1000_DMACR_DMACTHR_SHIFT       16
+#define E1000_DMACR_DMAC_LX_MASK        0x30000000 /* Lx when no PCIe
+							* transactions */
+#define E1000_DMACR_DMAC_LX_SHIFT       28
+#define E1000_DMACR_DMAC_EN             0x80000000 /* Enable DMA Coalescing */
+
+#define E1000_DMCTXTH_DMCTTHR_MASK      0x00000FFF /* DMA Coalescing Transmit
+							* Threshold */
+
+#define E1000_DMCTLX_TTLX_MASK          0x00000FFF /* Time to LX request */
+
+#define E1000_DMCRTRH_UTRESH_MASK       0x0007FFFF /* Receive Traffic Rate
+							* Threshold */
+#define E1000_DMCRTRH_LRPRCW            0x80000000 /* Rcv packet rate in
+							* current window */
+
+#define E1000_DMCCNT_CCOUNT_MASK        0x01FFFFFF /* DMA Coal Rcv Traffic
+							* Current Cnt */
+
+#define E1000_FCRTC_RTH_COAL_MASK       0x0003FFF0 /* Flow ctrl Rcv Threshold
+							* High val */
+#define E1000_FCRTC_RTH_COAL_SHIFT      4
+#define E1000_PCIEMISC_LX_DECISION      0x00000080 /* Lx power decision */
 
 /* SerDes Control */
 #define E1000_SCTL_DISABLE_SERDES_LOOPBACK 0x0400
diff --git a/drivers/net/igb/e1000_regs.h b/drivers/net/igb/e1000_regs.h
index b2f8e59..ad77ed5 100644
--- a/drivers/net/igb/e1000_regs.h
+++ b/drivers/net/igb/e1000_regs.h
@@ -106,6 +106,15 @@
 
 #define E1000_RQDPC(_n) (0x0C030 + ((_n) * 0x40))
 
+/* DMA Coalescing registers */
+#define E1000_DMACR             0x02508 /* Control Register */
+#define E1000_DMCTXTH           0x03550 /* Transmit Threshold */
+#define E1000_DMCTLX            0x02514 /* Time to Lx Request */
+#define E1000_DMCRTRH           0x05DD0 /* Receive Packet Rate Threshold */
+#define E1000_DMCCNT            0x05DD4 /* Current Rx Count */
+#define E1000_FCRTC             0x02170 /* Flow Control Rx high watermark */
+#define E1000_PCIEMISC          0x05BB8 /* PCIE misc config register */
+
 /* TX Rate Limit Registers */
 #define E1000_RTTDQSEL	0x3604	/* Tx Desc Plane Queue Select - WO */
 #define E1000_RTTBCNRC	0x36B0	/* Tx BCN Rate-Scheduler Config - WO */
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index bbc5ebf..1c687e2 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -333,6 +333,12 @@ struct igb_adapter {
 #define IGB_FLAG_DCA_ENABLED       (1 << 1)
 #define IGB_FLAG_QUAD_PORT_A       (1 << 2)
 #define IGB_FLAG_QUEUE_PAIRS       (1 << 3)
+#define IGB_FLAG_DMAC              (1 << 4)
+
+/* DMA Coalescing defines */
+#define IGB_MIN_TXPBSIZE           20408
+#define IGB_TX_BUF_4096            4096
+#define IGB_DMCTLX_DCFLUSH_DIS     0x80000000  /* Disable DMA Coal Flush */
 
 #define IGB_82576_TSYNC_SHIFT 19
 #define IGB_82580_TSYNC_SHIFT 24
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index df15a91..d976733 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -2009,6 +2009,12 @@ static int igb_set_coalesce(struct net_device *netdev,
 	if ((adapter->flags & IGB_FLAG_QUEUE_PAIRS) && ec->tx_coalesce_usecs)
 		return -EINVAL;
 
+	/* If ITR is disabled, disable DMAC */
+	if (ec->rx_coalesce_usecs == 0) {
+		if (adapter->flags & IGB_FLAG_DMAC)
+			adapter->flags &= ~IGB_FLAG_DMAC;
+	}
+
 	/* convert to rate of irq's per second */
 	if (ec->rx_coalesce_usecs && ec->rx_coalesce_usecs <= 3)
 		adapter->rx_itr_setting = ec->rx_coalesce_usecs;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 8c6af11..49476f7 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1674,7 +1674,58 @@ void igb_reset(struct igb_adapter *adapter)
 
 	if (hw->mac.ops.init_hw(hw))
 		dev_err(&pdev->dev, "Hardware Error\n");
+	if (hw->mac.type > e1000_82580) {
+		if (adapter->flags & IGB_FLAG_DMAC) {
+			u32 reg;
 
+			/*
+			 * DMA Coalescing high water mark needs to be higher
+			 * than * the * Rx threshold.  The Rx threshold is
+			 * currently * pba - 6, so we * should use a high water
+			 * mark of pba * - 4. */
+			hwm = (pba - 4) << 10;
+
+			reg = (((pba-6) << E1000_DMACR_DMACTHR_SHIFT)
+			       & E1000_DMACR_DMACTHR_MASK);
+
+			/* transition to L0x or L1 if available..*/
+			reg |= (E1000_DMACR_DMAC_EN | E1000_DMACR_DMAC_LX_MASK);
+
+			/* watchdog timer= +-1000 usec in 32usec intervals */
+			reg |= (1000 >> 5);
+			wr32(E1000_DMACR, reg);
+
+			/* no lower threshold to disable coalescing(smart fifb)
+			 * -UTRESH=0*/
+			wr32(E1000_DMCRTRH, 0);
+
+			/* set hwm to PBA -  2 * max frame size */
+			wr32(E1000_FCRTC, hwm);
+
+			/*
+			 * This sets the time to wait before requesting tran-
+			 * sition to * low power state to number of usecs needed
+			 * to receive 1 512 * byte frame at gigabit line rate
+			 */
+			reg = rd32(E1000_DMCTLX);
+			reg |= IGB_DMCTLX_DCFLUSH_DIS;
+
+			/* Delay 255 usec before entering Lx state. */
+			reg |= 0xFF;
+			wr32(E1000_DMCTLX, reg);
+
+			/* free space in Tx packet buffer to wake from DMAC */
+			wr32(E1000_DMCTXTH,
+			     (IGB_MIN_TXPBSIZE -
+			     (IGB_TX_BUF_4096 + adapter->max_frame_size))
+			     >> 6);
+
+			/* make low power state decision controlled by DMAC */
+			reg = rd32(E1000_PCIEMISC);
+			reg |= E1000_PCIEMISC_LX_DECISION;
+			wr32(E1000_PCIEMISC, reg);
+		} /* end if IGB_FLAG_DMAC set */
+	}
 	if (hw->mac.type == e1000_82580) {
 		u32 reg = rd32(E1000_PCIEMISC);
 		wr32(E1000_PCIEMISC,
@@ -2157,6 +2208,9 @@ static void __devinit igb_probe_vfs(struct igb_adapter * adapter)
 			random_ether_addr(mac_addr);
 			igb_set_vf_mac(adapter, i, mac_addr);
 		}
+		/* DMA Coalescing is not supported in IOV mode. */
+		if (adapter->flags & IGB_FLAG_DMAC)
+			adapter->flags &= ~IGB_FLAG_DMAC;
 	}
 #endif /* CONFIG_PCI_IOV */
 }
@@ -2331,6 +2385,9 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 	/* Explicitly disable IRQ since the NIC can be in any state. */
 	igb_irq_disable(adapter);
 
+	if (hw->mac.type == e1000_i350)
+		adapter->flags &= ~IGB_FLAG_DMAC;
+
 	set_bit(__IGB_DOWN, &adapter->state);
 	return 0;
 }
-- 
1.7.4

