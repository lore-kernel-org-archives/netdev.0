From: Andreas Oetken <ennoerlangen@googlemail.com>
Subject: [PATCH 1/1] altera tse: Fix network-delays and -retransmissions after high throughput.
Date: Tue, 14 Apr 2015 22:25:26 +0200
Message-ID: <1429043126-10829-1-git-send-email-ennoerlangen@gmail.com>
Cc: Andreas Oetken <ennoerlangen@gmail.com>,
	Andreas Oetken <andreas@oetken.name>
To: Vince Bridgers <vbridger@opensource.altera.com>,
	netdev@vger.kernel.org, nios2-dev@lists.rocketboards.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:34139 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754198AbbDNUZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 16:25:56 -0400
Received: by wgso17 with SMTP id o17so25079206wgs.1
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 13:25:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Oetken <andreas@oetken.name>

Fix bug which occurs when more than <limit> packets are available during napi-poll,
leading to "delays" and retransmissions on the network.

Check for (count < limit) before checking the get_rx_status in tse_rx-function. get_rx_status is reading from the response-fifo.
If there is currently a response in the fifo, reading the last byte of the response pops the value from the fifo.
If the limit is check as second condition and the limit is reached the fifo is popped but the packet is not processed.

Signed-off-by: Andreas Oetken <ennoerlangen@gmail.com>
---
 drivers/net/ethernet/altera/altera_tse_main.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index 6725dc0..b927b8b 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -376,8 +376,12 @@ static int tse_rx(struct altera_tse_private *priv, int limit)
 	u16 pktlength;
 	u16 pktstatus;
 
-	while (((rxstatus = priv->dmaops->get_rx_status(priv)) != 0) &&
-	       (count < limit))  {
+	/* Check for limit first. get_rx_status is reading the from the
+	* response-fifo. If there is a currently a response in the fifo,
+	* reading the last byte of the response pops the value from the fifo.
+	*/
+	while ((count < limit) &&
+		((rxstatus = priv->dmaops->get_rx_status(priv)) != 0)) {
 		pktstatus = rxstatus >> 16;
 		pktlength = rxstatus & 0xffff;
 
-- 
2.1.4
