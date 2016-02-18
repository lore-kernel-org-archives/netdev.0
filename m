From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net] r8169:fix "rtl_counters_cond == 1 (loop: 1000, delay: 10)" log spam.
Date: Thu, 18 Feb 2016 22:57:07 +0800
Message-ID: <1455807427-3177-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There will be a log spam when there is no cable plugged.
Please refer to following links.
https://bugzilla.kernel.org/show_bug.cgi?id=104351
https://bugzilla.kernel.org/show_bug.cgi?id=107421

This issue is caused by runtime power management. When there is no cable
plugged, the driver will be suspend (runtime suspend) by OS and NIC will
be put into the D3 state. During this time, if OS call rtl8169_get_stats64()
to dump tally counter, because NIC is in D3 state, the register value read by
driver will return all 0xff. This will let driver think tally counter flag is not
toggled and then sends the warning  message "rtl_counters_cond == 1 (loop: 1000,
delay: 10)" to kernel log.

I add checking driver's pm runtime status in rtl8169_get_stats64() to fix
this issue.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 537974c..798b30c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7730,10 +7730,13 @@ rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->mmio_addr;
+	struct pci_dev *pdev = tp->pci_dev;
 	struct rtl8169_counters *counters = tp->counters;
 	unsigned int start;
 
-	if (netif_running(dev))
+	pm_runtime_get_noresume(&pdev->dev);
+
+	if (netif_running(dev) && pm_runtime_active(&pdev->dev))
 		rtl8169_rx_missed(dev, ioaddr);
 
 	do {
@@ -7761,7 +7764,8 @@ rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	 * Fetch additonal counter values missing in stats collected by driver
 	 * from tally counters.
 	 */
-	rtl8169_update_counters(dev);
+	if (pm_runtime_active(&pdev->dev))
+		rtl8169_update_counters(dev);
 
 	/*
 	 * Subtract values fetched during initalization.
@@ -7774,6 +7778,8 @@ rtl8169_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 	stats->tx_aborted_errors = le16_to_cpu(counters->tx_aborted) -
 		le16_to_cpu(tp->tc_offset.tx_aborted);
 
+	pm_runtime_put_noidle(&pdev->dev);
+
 	return stats;
 }
 
-- 
1.9.1
