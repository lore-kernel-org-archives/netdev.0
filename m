From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net] 8139too:fix system hang when there is a tx timeout event.
Date: Thu, 28 Jul 2016 02:39:57 +0800
Message-ID: <1469644797-13334-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If tx timeout event occur, kernel will call rtl8139_tx_timeout_task() to reset
hardware. But in this function, driver does not stop tx and rx function before
reset hardware, that will cause system hang.

In this patch, add stop tx and rx function before reset hardware.

Signed-off-by: Chunhao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/8139too.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/realtek/8139too.c b/drivers/net/ethernet/realtek/8139too.c
index ef668d3..0d77f3c 100644
--- a/drivers/net/ethernet/realtek/8139too.c
+++ b/drivers/net/ethernet/realtek/8139too.c
@@ -1667,6 +1667,10 @@ static void rtl8139_tx_timeout_task (struct work_struct *work)
 	int i;
 	u8 tmp8;
 
+	napi_disable(&tp->napi);
+	netif_stop_queue(dev);
+	synchronize_sched();
+
 	netdev_dbg(dev, "Transmit timeout, status %02x %04x %04x media %02x\n",
 		   RTL_R8(ChipCmd), RTL_R16(IntrStatus),
 		   RTL_R16(IntrMask), RTL_R8(MediaStatus));
@@ -1696,10 +1700,10 @@ static void rtl8139_tx_timeout_task (struct work_struct *work)
 	spin_unlock_irq(&tp->lock);
 
 	/* ...and finally, reset everything */
-	if (netif_running(dev)) {
-		rtl8139_hw_start (dev);
-		netif_wake_queue (dev);
-	}
+	napi_enable(&tp->napi);
+	rtl8139_hw_start (dev);
+	netif_wake_queue (dev);
+
 	spin_unlock_bh(&tp->rx_lock);
 }
 
-- 
1.9.1
