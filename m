From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net v3 3/4] r8152: re-schedule napi for tx
Date: Thu, 26 Jan 2017 09:38:33 +0800
Message-ID: <1394712342-15778-250-Taiwan-albertk@realtek.com>
References: <1394712342-15778-236-Taiwan-albertk@realtek.com>
 <1394712342-15778-247-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([211.75.126.72]:35523 "EHLO
        rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752669AbdAZBjG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 20:39:06 -0500
In-Reply-To: <1394712342-15778-247-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Re-schedule napi after napi_complete() for tx, if it is necessay.

In r8152_poll(), if the tx is completed after tx_bottom() and before
napi_complete(), the scheduling of napi would be lost. Then, no
one handles the next tx until the next napi_schedule() is called.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index ec882be..4785d2b 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -1936,6 +1936,9 @@ static int r8152_poll(struct napi_struct *napi, int budget)
 		napi_complete(napi);
 		if (!list_empty(&tp->rx_done))
 			napi_schedule(napi);
+		else if (!skb_queue_empty(&tp->tx_queue) &&
+			 !list_empty(&tp->tx_free))
+			napi_schedule(napi);
 	}
 
 	return work_done;
-- 
2.7.4
