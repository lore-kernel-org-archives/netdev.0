From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH net-next 2/2] r8152: adjust rtl_start_rx
Date: Wed, 12 Nov 2014 05:07:40 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2ECE429@RTITMBSV03.realtek.com.tw>
References: <1394712342-15778-90-Taiwan-albertk@realtek.com>
	<20141107.113522.837502028522211960.davem@davemloft.net>
	<0835B3720019904CB8F7AA43166CEEB2ECE0A3@RTITMBSV03.realtek.com.tw>
 <20141111.215056.2165761189796303933.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141111.215056.2165761189796303933.davem@davemloft.net>
Content-Language: zh-TW
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller [mailto:davem@davemloft.net] 
> Sent: Wednesday, November 12, 2014 10:51 AM
[...]
> Ok, but if we are looping here in rtl_start_rx() and r8152_submit_rx()
> fails due to a memory allocation failure, there is nothing which is
> going to make such a memory allocation succeed in the next iteration
> of the loop.
> 
> Unless you can prove that often it can succeed after an initial
> failure, this is just wasted work and in fact making it take longer
> for the system to reclaim memory when under pressure because these
> extra iterations are completely wasted cpu work.

How about that when a error occurs, add the remaining rx
to the list without submission? Then, the remianing rx
could be re-submitted later, and the rtl_start_rx() could
be completed as soon as possible.

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 0a30fd3..3273e3d 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1991,14 +1991,35 @@ static void rxdy_gated_en(struct r8152 *tp, bool enable)
 
 static int rtl_start_rx(struct r8152 *tp)
 {
+	struct list_head rx_queue;
 	int i, ret = 0;
 
 	INIT_LIST_HEAD(&tp->rx_done);
 	for (i = 0; i < RTL8152_MAX_RX; i++) {
 		INIT_LIST_HEAD(&tp->rx_info[i].list);
 		ret = r8152_submit_rx(tp, &tp->rx_info[i], GFP_KERNEL);
-		if (ret)
+		if (ret) {
+			i++;
 			break;
+		}
+	}
+
+	INIT_LIST_HEAD(&rx_queue);
+	for (; i < RTL8152_MAX_RX; i++) {
+		struct rx_agg *agg = &tp->rx_info[i];
+		struct urb *urb = agg->urb;
+
+		INIT_LIST_HEAD(&agg->list);
+		urb->actual_length = 0;
+		list_add_tail(&agg->list, &rx_queue);
+	}
+
+	if (!list_empty(&rx_queue)) {
+		unsigned long flags;
+
+		spin_lock_irqsave(&tp->rx_lock, flags);
+		list_splice_tail(&rx_queue, &tp->rx_done);
+		spin_unlock_irqrestore(&tp->rx_lock, flags);
 	}
 
 	return ret;
 
Best Regards,
Hayes
