From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v3 2/2] r8152: adjust rtl_start_rx
Date: Thu, 20 Nov 2014 10:29:06 +0800
Message-ID: <1394712342-15778-100-Taiwan-albertk@realtek.com>
References: <1394712342-15778-88-Taiwan-albertk@realtek.com>
 <1394712342-15778-98-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-98-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If there is a error for r8152_submit_rx(), add the remaining rx
buffers to the list. Then the remaining rx buffers could be
submitted later.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 3b89229..4a9ece0 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2001,6 +2001,25 @@ static int rtl_start_rx(struct r8152 *tp)
 			break;
 	}
 
+	if (ret && ++i < RTL8152_MAX_RX) {
+		struct list_head rx_queue;
+		unsigned long flags;
+
+		INIT_LIST_HEAD(&rx_queue);
+
+		do {
+			struct rx_agg *agg = &tp->rx_info[i++];
+			struct urb *urb = agg->urb;
+
+			urb->actual_length = 0;
+			list_add_tail(&agg->list, &rx_queue);
+		} while (i < RTL8152_MAX_RX);
+
+		spin_lock_irqsave(&tp->rx_lock, flags);
+		list_splice_tail(&rx_queue, &tp->rx_done);
+		spin_unlock_irqrestore(&tp->rx_lock, flags);
+	}
+
 	return ret;
 }
 
-- 
1.9.3
