From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/16] r8169: Support RX-ALL flag.
Date: Fri, 24 Feb 2012 02:13:04 -0800
Message-ID: <1330078389-8203-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Ben Greear <greearb@candelatech.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41098 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755915Ab2BXKNS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Feb 2012 05:13:18 -0500
In-Reply-To: <1330078389-8203-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This allows the NIC to receive packets with bad FCS and
Runts, which can help when sniffing.

NOTE:  r8169, at least on my NIC, silently drops packets
with bad FCS instead of counting them.  It seems they are
only received in any fashion if the RxCRC flag is set
(which this patch allows).

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 drivers/net/ethernet/realtek/r8169.c |   51 +++++++++++++++++++++++++--------
 1 files changed, 38 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 5eb6858..0517a6a 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1626,21 +1626,32 @@ static void __rtl8169_set_features(struct net_device *dev,
 				   netdev_features_t features)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-
+	netdev_features_t changed = features ^ dev->features;
 	void __iomem *ioaddr = tp->mmio_addr;
 
-	if (features & NETIF_F_RXCSUM)
-		tp->cp_cmd |= RxChkSum;
-	else
-		tp->cp_cmd &= ~RxChkSum;
+	if (!(changed & (NETIF_F_RXALL | NETIF_F_RXCSUM | NETIF_F_HW_VLAN_RX)))
+		return;
 
-	if (dev->features & NETIF_F_HW_VLAN_RX)
-		tp->cp_cmd |= RxVlan;
-	else
-		tp->cp_cmd &= ~RxVlan;
+	if (changed & (NETIF_F_RXCSUM | NETIF_F_HW_VLAN_RX)) {
+		if (features & NETIF_F_RXCSUM)
+			tp->cp_cmd |= RxChkSum;
+		else
+			tp->cp_cmd &= ~RxChkSum;
 
-	RTL_W16(CPlusCmd, tp->cp_cmd);
-	RTL_R16(CPlusCmd);
+		if (dev->features & NETIF_F_HW_VLAN_RX)
+			tp->cp_cmd |= RxVlan;
+		else
+			tp->cp_cmd &= ~RxVlan;
+
+		RTL_W16(CPlusCmd, tp->cp_cmd);
+		RTL_R16(CPlusCmd);
+	}
+	if (changed & NETIF_F_RXALL) {
+		int tmp = (RTL_R32(RxConfig) & ~(AcceptErr | AcceptRunt));
+		if (features & NETIF_F_RXALL)
+			tmp |= (AcceptErr | AcceptRunt);
+		RTL_W32(RxConfig, tmp);
+	}
 }
 
 static int rtl8169_set_features(struct net_device *dev,
@@ -4174,6 +4185,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		/* 8110SCd requires hardware Rx VLAN - disallow toggling */
 		dev->hw_features &= ~NETIF_F_HW_VLAN_RX;
 
+	dev->hw_features |= NETIF_F_RXALL;
+
 	tp->hw_start = cfg->hw_start;
 	tp->event_slow = cfg->event_slow;
 
@@ -5747,11 +5760,20 @@ static int rtl_rx(struct net_device *dev, struct rtl8169_private *tp, u32 budget
 				rtl_schedule_task(tp, RTL_FLAG_TASK_RESET_PENDING);
 				dev->stats.rx_fifo_errors++;
 			}
+			if ((status & (RxRUNT | RxCRC)) &&
+			    !(status & (RxRWT | RxFOVF)) &&
+			    (dev->features & NETIF_F_RXALL))
+				goto process_pkt;
+
 			rtl8169_mark_to_asic(desc, rx_buf_sz);
 		} else {
 			struct sk_buff *skb;
-			dma_addr_t addr = le64_to_cpu(desc->addr);
-			int pkt_size = (status & 0x00003fff) - 4;
+			dma_addr_t addr;
+			int pkt_size;
+
+process_pkt:
+			addr = le64_to_cpu(desc->addr);
+			pkt_size = (status & 0x00003fff) - 4;
 
 			/*
 			 * The driver does not support incoming fragmented
@@ -6025,6 +6047,9 @@ static void rtl_set_rx_mode(struct net_device *dev)
 		}
 	}
 
+	if (dev->features & NETIF_F_RXALL)
+		rx_mode |= (AcceptErr | AcceptRunt);
+
 	tmp = (RTL_R32(RxConfig) & ~RX_CONFIG_ACCEPT_MASK) | rx_mode;
 
 	if (tp->mac_version > RTL_GIGA_MAC_VER_06) {
-- 
1.7.7.6
