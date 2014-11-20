From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v3 1/2] r8152: adjust r8152_submit_rx
Date: Thu, 20 Nov 2014 10:29:05 +0800
Message-ID: <1394712342-15778-99-Taiwan-albertk@realtek.com>
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

The behavior of handling the returned status from r8152_submit_rx()
is almost same, so let r8152_submit_rx() deal with the error
directly. This could avoid the duplicate code.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 40 ++++++++++++++++++++--------------------
 1 file changed, 20 insertions(+), 20 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 0a30fd3..3b89229 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1032,7 +1032,6 @@ static void read_bulk_callback(struct urb *urb)
 	int status = urb->status;
 	struct rx_agg *agg;
 	struct r8152 *tp;
-	int result;
 
 	agg = urb->context;
 	if (!agg)
@@ -1083,16 +1082,7 @@ static void read_bulk_callback(struct urb *urb)
 		break;
 	}
 
-	result = r8152_submit_rx(tp, agg, GFP_ATOMIC);
-	if (result == -ENODEV) {
-		set_bit(RTL8152_UNPLUG, &tp->flags);
-		netif_device_detach(tp->netdev);
-	} else if (result) {
-		spin_lock(&tp->rx_lock);
-		list_add_tail(&agg->list, &tp->rx_done);
-		spin_unlock(&tp->rx_lock);
-		tasklet_schedule(&tp->tl);
-	}
+	r8152_submit_rx(tp, agg, GFP_ATOMIC);
 }
 
 static void write_bulk_callback(struct urb *urb)
@@ -1680,7 +1670,6 @@ static void rx_bottom(struct r8152 *tp)
 		int len_used = 0;
 		struct urb *urb;
 		u8 *rx_data;
-		int ret;
 
 		list_del_init(cursor);
 
@@ -1733,13 +1722,7 @@ find_next_rx:
 		}
 
 submit:
-		ret = r8152_submit_rx(tp, agg, GFP_ATOMIC);
-		if (ret && ret != -ENODEV) {
-			spin_lock_irqsave(&tp->rx_lock, flags);
-			list_add_tail(&agg->list, &tp->rx_done);
-			spin_unlock_irqrestore(&tp->rx_lock, flags);
-			tasklet_schedule(&tp->tl);
-		}
+		r8152_submit_rx(tp, agg, GFP_ATOMIC);
 	}
 }
 
@@ -1806,11 +1789,28 @@ static void bottom_half(unsigned long data)
 static
 int r8152_submit_rx(struct r8152 *tp, struct rx_agg *agg, gfp_t mem_flags)
 {
+	int ret;
+
 	usb_fill_bulk_urb(agg->urb, tp->udev, usb_rcvbulkpipe(tp->udev, 1),
 			  agg->head, agg_buf_sz,
 			  (usb_complete_t)read_bulk_callback, agg);
 
-	return usb_submit_urb(agg->urb, mem_flags);
+	ret = usb_submit_urb(agg->urb, mem_flags);
+	if (ret == -ENODEV) {
+		set_bit(RTL8152_UNPLUG, &tp->flags);
+		netif_device_detach(tp->netdev);
+	} else if (ret) {
+		struct urb *urb = agg->urb;
+		unsigned long flags;
+
+		urb->actual_length = 0;
+		spin_lock_irqsave(&tp->rx_lock, flags);
+		list_add_tail(&agg->list, &tp->rx_done);
+		spin_unlock_irqrestore(&tp->rx_lock, flags);
+		tasklet_schedule(&tp->tl);
+	}
+
+	return ret;
 }
 
 static void rtl_drop_queued_tx(struct r8152 *tp)
-- 
1.9.3
