From: "David B. Robins" <linux@davidrobins.net>
Subject: [PATCH] net: usb: asix: Fix crash on skb alloc failure
Date: Wed, 30 Sep 2015 16:20:04 -0400
Message-ID: <1443644404-6452-1-git-send-email-linux@davidrobins.net>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David B. Robins" <linux@davidrobins.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-149-18-83.lightspeed.fshrin.sbcglobal.net ([99.149.18.83]:33513
	"EHLO i4031.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753567AbbI3UHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 16:07:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If asix_rx_fixup_internal() fails to allocate rx->ax_skb, it will return
but not clear rx->size. rx points to driver private data. A later call
assumes that nonzero size means ax_skb was allocated and passes a null
ax_skb to skb_put. Changed allocation failure return to clear size first.

Found testing board with AX88772B devices.

Signed-off-by: David B. Robins <linux@davidrobins.net>
---
 drivers/net/usb/asix_common.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 75d6f26..079069a 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -91,8 +91,10 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
 			}
 			rx->ax_skb = netdev_alloc_skb_ip_align(dev->net,
 							       rx->size);
-			if (!rx->ax_skb)
+			if (!rx->ax_skb) {
+				rx->size = 0;
 				return 0;
+			}
 		}
 
 		if (rx->size > dev->net->mtu + ETH_HLEN + VLAN_HLEN) {
-- 
1.9.1
