From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net 2/3] r8169:add checking driver's runtime pm status in rtl8169_get_ethtool_stats()
Date: Thu, 28 Jul 2016 00:41:07 +0800
Message-ID: <1469637668-8751-3-git-send-email-hau@realtek.com>
References: <1469637668-8751-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469637668-8751-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Not to call rtl8169_update_counters() to dump tally counter when driver is in
runtime suspend state.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index f07604f..4a17342 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -2308,11 +2308,17 @@ static void rtl8169_get_ethtool_stats(struct net_device *dev,
 				      struct ethtool_stats *stats, u64 *data)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	struct pci_dev *pdev = tp->pci_dev;
 	struct rtl8169_counters *counters = tp->counters;
 
 	ASSERT_RTNL();
 
-	rtl8169_update_counters(dev);
+	pm_runtime_get_noresume(&pdev->dev);
+
+	if (pm_runtime_active(&pdev->dev))
+		rtl8169_update_counters(dev);
+
+	pm_runtime_put_noidle(&pdev->dev);
 
 	data[0] = le64_to_cpu(counters->tx_packets);
 	data[1] = le64_to_cpu(counters->rx_packets);
-- 
1.9.1
