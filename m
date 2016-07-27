From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net 1/3] r8169:fix kernel log spam when set or get hardware wol setting.
Date: Thu, 28 Jul 2016 00:41:06 +0800
Message-ID: <1469637668-8751-2-git-send-email-hau@realtek.com>
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

NIC will be put into D3 state during runtime suspend state.
When set or get hardware wol setting, driver will write or read hardware
register. If we set or get hardware wol setting in runtime suspend state,
because NIC will in D3 state, the register value read by driver will return all
0xff. That will let driver thinking register flag is not toggled and then prints
the warning message "rtl_counters_cond == 1 (loop: 1000, delay: 10)" to kernel
log.

For fixing this issue, add checking driver's pm runtime status in
rtl8169_get_wol() and rtl8169_set_wol().

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 0e62d74..f07604f 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1749,13 +1749,21 @@ static u32 __rtl8169_get_wol(struct rtl8169_private *tp)
 static void rtl8169_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	struct pci_dev *pdev = tp->pci_dev;
+
+	pm_runtime_get_noresume(&pdev->dev);
 
 	rtl_lock_work(tp);
 
 	wol->supported = WAKE_ANY;
-	wol->wolopts = __rtl8169_get_wol(tp);
+	if (pm_runtime_active(&pdev->dev))
+		wol->wolopts = __rtl8169_get_wol(tp);
+	else
+		wol->wolopts = tp->saved_wolopts;
 
 	rtl_unlock_work(tp);
+
+	pm_runtime_put_noidle(&pdev->dev);
 }
 
 static void __rtl8169_set_wol(struct rtl8169_private *tp, u32 wolopts)
@@ -1845,6 +1853,9 @@ static void __rtl8169_set_wol(struct rtl8169_private *tp, u32 wolopts)
 static int rtl8169_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	struct pci_dev *pdev = tp->pci_dev;
+
+	pm_runtime_get_noresume(&pdev->dev);
 
 	rtl_lock_work(tp);
 
@@ -1852,12 +1863,17 @@ static int rtl8169_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 		tp->features |= RTL_FEATURE_WOL;
 	else
 		tp->features &= ~RTL_FEATURE_WOL;
-	__rtl8169_set_wol(tp, wol->wolopts);
+	if (pm_runtime_active(&pdev->dev))
+		__rtl8169_set_wol(tp, wol->wolopts);
+	else
+		tp->saved_wolopts = wol->wolopts;
 
 	rtl_unlock_work(tp);
 
 	device_set_wakeup_enable(&tp->pci_dev->dev, wol->wolopts);
 
+	pm_runtime_put_noidle(&pdev->dev);
+
 	return 0;
 }
 
-- 
1.9.1
