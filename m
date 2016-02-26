From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net 1/3] r8169:fix nic sometimes doesn't work after changing the mac address.
Date: Fri, 26 Feb 2016 16:40:44 +0800
Message-ID: <1456476046-5436-2-git-send-email-hau@realtek.com>
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

When there is no AC power, NIC doesn't work after changing mac address.
Please refer to following link.
http://www.spinics.net/lists/netdev/msg356572.html

This issue is caused by runtime power management. When there is no AC power, if we
put NIC down (ifconfig down), the driver will be put in runtime suspend state and
device will in D3 state. In this time, driver cannot access hardware regisers. So
if you set new mac address during this time, it will not work. And then, after
resume, the NIC will keep using the old mac address and so the network will not
work normally.

In this patch I add detecting runtime pm state when setting mac address. If
driver is in runtime suspend, I will skip setting mac address and  set the new
mac address during runtime resume.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 4caeacb..432b278 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4457,6 +4457,7 @@ static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
 static int rtl_set_mac_address(struct net_device *dev, void *p)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	struct pci_dev *pdev = tp->pci_dev;
 	struct sockaddr *addr = p;
 
 	if (!is_valid_ether_addr(addr->sa_data))
@@ -4464,7 +4465,12 @@ static int rtl_set_mac_address(struct net_device *dev, void *p)
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
-	rtl_rar_set(tp, dev->dev_addr);
+	pm_runtime_get_noresume(&pdev->dev);
+
+	if (pm_runtime_active(&pdev->dev))
+		rtl_rar_set(tp, dev->dev_addr);
+
+	pm_runtime_put_noidle(&pdev->dev);
 
 	return 0;
 }
@@ -7872,6 +7878,8 @@ static int rtl8169_runtime_resume(struct device *device)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
 
+	rtl_rar_set(tp, dev->dev_addr);
+
 	if (!tp->TxDescArray)
 		return 0;
 
-- 
1.9.1
