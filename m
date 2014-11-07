From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 2/2] r8152: adjust rtl_start_rx
Date: Fri, 7 Nov 2014 17:55:11 +0800
Message-ID: <1394712342-15778-90-Taiwan-albertk@realtek.com>
References: <1394712342-15778-88-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-88-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Submit all the rx buffers, even though a error occurs. Otherwise
the buffers which are not submitted would be lost until next
rtl_start_rx() is called. Besides, the fail buffer could be
re-submitted later.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index ad62994..5e0386f 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1993,10 +1993,16 @@ static int rtl_start_rx(struct r8152 *tp)
 
 	INIT_LIST_HEAD(&tp->rx_done);
 	for (i = 0; i < RTL8152_MAX_RX; i++) {
+		int rr;
+
 		INIT_LIST_HEAD(&tp->rx_info[i].list);
-		ret = r8152_submit_rx(tp, &tp->rx_info[i], GFP_KERNEL);
-		if (ret)
-			break;
+
+		rr = r8152_submit_rx(tp, &tp->rx_info[i], GFP_KERNEL);
+		if (rr)
+			netif_err(tp, rx_err, tp->netdev,
+				  "Couldn't submit rx[%d], ret = %d\n", i, rr);
+		if (!ret)
+			ret = rr;
 	}
 
 	return ret;
-- 
1.9.3
