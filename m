From: Alan Ott <alan@signal11.us>
Subject: [PATCH] mrf24j40: Enable link-layer acknowledgement and retry
Date: Fri,  5 Apr 2013 16:34:51 -0400
Message-ID: <1365194091-2542-1-git-send-email-alan@signal11.us>
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Alan Ott <alan@signal11.us>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:58770 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1162032Ab3DEUhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 16:37:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On the MRF24J40, link-layer acknowledgment request and retry must be
turned on explicitly for each packet.  Turn this on in the hardware based
on the FC_ACK_REQ bit being set in the packet.

Also, now that failure to receive an ACK will cause the hardware to report
failure of transmission, change the log level for this failure to debug
level.

Signed-off-by: Alan Ott <alan@signal11.us>
---
 drivers/net/ieee802154/mrf24j40.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index 6481faf..556151d 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -25,6 +25,7 @@
 #include <linux/pinctrl/consumer.h>
 #include <net/wpan-phy.h>
 #include <net/mac802154.h>
+#include <net/ieee802154.h>
 
 /* MRF24J40 Short Address Registers */
 #define REG_RXMCR    0x00  /* Receive MAC control */
@@ -349,7 +350,9 @@ static int mrf24j40_tx(struct ieee802154_dev *dev, struct sk_buff *skb)
 	if (ret)
 		goto err;
 	val |= 0x1;
-	val &= ~0x4;
+	/* Set TXNACKREQ if the ACK bit is set in the packet. */
+	if (skb->data[0] & IEEE802154_FC_ACK_REQ)
+		val |= 0x4;
 	write_short_reg(devrec, REG_TXNCON, val);
 
 	INIT_COMPLETION(devrec->tx_complete);
@@ -371,7 +374,7 @@ static int mrf24j40_tx(struct ieee802154_dev *dev, struct sk_buff *skb)
 	if (ret)
 		goto err;
 	if (val & 0x1) {
-		dev_err(printdev(devrec), "Error Sending. Retry count exceeded\n");
+		dev_dbg(printdev(devrec), "Error Sending. Retry count exceeded\n");
 		ret = -ECOMM; /* TODO: Better error code ? */
 	} else
 		dev_dbg(printdev(devrec), "Packet Sent\n");
-- 
1.7.11.2
