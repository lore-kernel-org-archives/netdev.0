From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net 2/3] r8169:eliminate error message in using ethtool -S when nic is down.
Date: Fri, 26 Feb 2016 16:40:45 +0800
Message-ID: <1456476046-5436-3-git-send-email-hau@realtek.com>
References: <1456476046-5436-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456476046-5436-1-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This issue is caused by runtime power management. When NIC is down (ifconfig down)
the NIC may be put into runtime suspend state, that cause driver cannot dump
tally counter successfully and incur error message "rtl_counters_cond == 1
(loop: 1000, delay: 10)"

In this patch I add deceting driver runtime pm state. If driver is in runtime
suspend state, I will skip dump tall counter.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 432b278..3e9eb64 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -2291,11 +2291,17 @@ static void rtl8169_get_ethtool_stats(struct net_device *dev,
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
