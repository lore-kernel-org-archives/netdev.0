From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] Gigabit Ethernet driver of Topcliff PCH
Date: Fri, 24 Sep 2010 21:07:33 -0700 (PDT)
Message-ID: <20100924.210733.15237730.davem@davemloft.net>
References: <4C989A8B.5070902@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, john.linn@xilinx.com, ralf@linux-mips.org,
	kristoffer@gaisler.com, mbizon@freebox.fr,
	gregory.v.rose@intel.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, okada533@dsn.okisemi.com,
	shimizu394@dsn.okisemi.com, morinaga526@dsn.okisemi.com,
	meego-dev@meego.com, qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	margie.foster@intel.com
To: masa-korg@dsn.okisemi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C989A8B.5070902@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Date: Tue, 21 Sep 2010 20:44:11 +0900

> The dev_pm_ops was used.
> Unnecessary "__attribute__ ((packed))" was deleted.
> 
> Signed-off-by: Masayuki Ohtake <masa-korg@dsn.okisemi.com>

Applied, but the driver didn't even build on my machine (sparc64,
problem is lack of vmalloc.h include) and once that problem was fixed
it emitted several warnings when building (casting pointers to "u32").

I therefore added the following fixes when commiting your driver:

diff --git a/drivers/net/pch_gbe/pch_gbe.h b/drivers/net/pch_gbe/pch_gbe.h
index 91250cd..b925ab3 100644
--- a/drivers/net/pch_gbe/pch_gbe.h
+++ b/drivers/net/pch_gbe/pch_gbe.h
@@ -29,6 +29,7 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
+#include <linux/vmalloc.h>
 #include <net/ip.h>
 
 /**
diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index adeadfc..53c56cf 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -1401,9 +1401,9 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
 		prefetch(skb->data);
 
 		pr_debug("RxDecNo = 0x%04x  Status[DMA:0x%02x GBE:0x%04x "
-			 "TCP:0x%08x]  BufInf = 0x%08x\n",
+			 "TCP:0x%08x]  BufInf = 0x%p\n",
 			 i, dma_status, gbec_status, tcp_ip_status,
-			 (u32) (buffer_info));
+			 buffer_info);
 		/* Error check */
 		if (unlikely(gbec_status & PCH_GBE_RXD_GMAC_STAT_NOTOCTAL)) {
 			adapter->stats.rx_frame_errors++;
@@ -1545,9 +1545,9 @@ int pch_gbe_setup_tx_resources(struct pch_gbe_adapter *adapter,
 		tx_desc = PCH_GBE_TX_DESC(*tx_ring, desNo);
 		tx_desc->gbec_status = DSC_INIT16;
 	}
-	pr_debug("tx_ring->desc = 0x%08x  tx_ring->dma = 0x%08llx\n"
+	pr_debug("tx_ring->desc = 0x%p  tx_ring->dma = 0x%08llx\n"
 		 "next_to_clean = 0x%08x  next_to_use = 0x%08x\n",
-		 (u32) tx_ring->desc, (unsigned long long)tx_ring->dma,
+		 tx_ring->desc, (unsigned long long)tx_ring->dma,
 		 tx_ring->next_to_clean, tx_ring->next_to_use);
 	return 0;
 }
@@ -1591,9 +1591,9 @@ int pch_gbe_setup_rx_resources(struct pch_gbe_adapter *adapter,
 		rx_desc = PCH_GBE_RX_DESC(*rx_ring, desNo);
 		rx_desc->gbec_status = DSC_INIT16;
 	}
-	pr_debug("rx_ring->desc = 0x%08x  rx_ring->dma = 0x%08llx "
+	pr_debug("rx_ring->desc = 0x%p  rx_ring->dma = 0x%08llx "
 		 "next_to_clean = 0x%08x  next_to_use = 0x%08x\n",
-		 (u32) rx_ring->desc, (unsigned long long)rx_ring->dma,
+		 rx_ring->desc, (unsigned long long)rx_ring->dma,
 		 rx_ring->next_to_clean, rx_ring->next_to_use);
 	return 0;
 }
@@ -2102,8 +2102,6 @@ static void pch_gbe_netpoll(struct net_device *netdev)
 	pch_gbe_intr(adapter->pdev->irq, netdev);
 	enable_irq(adapter->pdev->irq);
 }
-#else
-#define pch_gbe_netpoll NULL
 #endif
 
 static const struct net_device_ops pch_gbe_netdev_ops = {
@@ -2116,7 +2114,9 @@ static const struct net_device_ops pch_gbe_netdev_ops = {
 	.ndo_change_mtu = pch_gbe_change_mtu,
 	.ndo_do_ioctl = pch_gbe_ioctl,
 	.ndo_set_multicast_list = &pch_gbe_set_multi,
+#ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller = pch_gbe_netpoll,
+#endif
 };
 
 static pci_ers_result_t pch_gbe_io_error_detected(struct pci_dev *pdev,
@@ -2196,6 +2196,7 @@ static int __pch_gbe_suspend(struct pci_dev *pdev)
 	return retval;
 }
 
+#ifdef CONFIG_PM
 static int pch_gbe_suspend(struct device *device)
 {
 	struct pci_dev *pdev = to_pci_dev(device);
@@ -2203,7 +2204,6 @@ static int pch_gbe_suspend(struct device *device)
 	return __pch_gbe_suspend(pdev);
 }
 
-#ifdef CONFIG_PM
 static int pch_gbe_resume(struct device *device)
 {
 	struct pci_dev *pdev = to_pci_dev(device);
