From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 1/7] r8152: adjust rx_bottom
Date: Mon, 19 Jan 2015 15:13:31 +0800
Message-ID: <1394712342-15778-119-Taiwan-albertk@realtek.com>
References: <1394712342-15778-118-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-118-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If a error occurs when submitting rx, skip the remaining submissions
and try to submit them again next time.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 2e22442..78a8917 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1655,7 +1655,7 @@ static int rx_bottom(struct r8152 *tp, int budget)
 {
 	unsigned long flags;
 	struct list_head *cursor, *next, rx_queue;
-	int work_done = 0;
+	int ret = 0, work_done = 0;
 
 	if (!skb_queue_empty(&tp->rx_queue)) {
 		while (work_done < budget) {
@@ -1746,7 +1746,18 @@ find_next_rx:
 		}
 
 submit:
-		r8152_submit_rx(tp, agg, GFP_ATOMIC);
+		if (!ret) {
+			ret = r8152_submit_rx(tp, agg, GFP_ATOMIC);
+		} else {
+			urb->actual_length = 0;
+			list_add_tail(&agg->list, next);
+		}
+	}
+
+	if (!list_empty(&rx_queue)) {
+		spin_lock_irqsave(&tp->rx_lock, flags);
+		list_splice_tail(&rx_queue, &tp->rx_done);
+		spin_unlock_irqrestore(&tp->rx_lock, flags);
 	}
 
 out1:
-- 
2.1.0
