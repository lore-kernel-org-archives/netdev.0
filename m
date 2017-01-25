From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 3/4] r8152: re-schedule napi for tx
Date: Wed, 25 Jan 2017 10:50:53 +0800
Message-ID: <1394712342-15778-239-Taiwan-albertk@realtek.com>
References: <1394712342-15778-236-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-236-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Re-schedule napi after napi_complete() for tx, if it is necessay.

In r8152_poll(), if the tx is completed after tx_bottom() and before
napi_complete(), the scheduling of napi would be lost. Then, no
one handles the next tx until the next napi_schedule() is called.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 3454238..f65109b 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1936,6 +1936,9 @@ static int r8152_poll(struct napi_struct *napi, int budget)
 		napi_complete(napi);
 		if (!list_empty(&tp->rx_done))
 			napi_schedule(napi);
+		else if (!skb_queue_empty(&tp->tx_queue) &&
+			 !list_empty(&tp->tx_free))
+			napi_schedule(&tp->napi);
 	}
 
 	return work_done;
-- 
2.7.4
