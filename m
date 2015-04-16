From: Andreas Oetken <ennoerlangen@googlemail.com>
Subject: [PATCH 1/1] altera tse: Fix network-delays and -retransmissions after high throughput.
Date: Thu, 16 Apr 2015 23:48:08 +0200
Message-ID: <1429220888-18119-1-git-send-email-ennoerlangen@gmail.com>
References: <1429043126-10829-1-git-send-email-ennoerlangen@gmail.com>
Cc: Andreas Oetken <ennoerlangen@gmail.com>,
	Andreas Oetken <andreas@oetken.name>
To: Vince Bridgers <vbridger@opensource.altera.com>,
	netdev@vger.kernel.org, nios2-dev@lists.rocketboards.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:36078 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbbDPVs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 17:48:28 -0400
Received: by wgsk9 with SMTP id k9so94949508wgs.3
        for <netdev@vger.kernel.org>; Thu, 16 Apr 2015 14:48:27 -0700 (PDT)
In-Reply-To: <1429043126-10829-1-git-send-email-ennoerlangen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Oetken <andreas@oetken.name>

Fix bug which occurs when more than <limit> packets are available during
napi-poll, leading to "delays" and retransmissions on the network.

Check for (count < limit) before checking the get_rx_status in tse_rx-function.
Function get_rx_status is reading from the response-fifo.
If there is currently a response in the fifo,
reading the last byte of the response pops the value from the fifo.
If the limit is checked as second condition
and the limit is reached the fifo is popped but the packet is not processed.

Signed-off-by: Andreas Oetken <ennoerlangen@gmail.com>
---
 drivers/net/ethernet/altera/altera_tse_main.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index 6725dc0..dbbbd34 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -376,8 +376,13 @@ static int tse_rx(struct altera_tse_private *priv, int limit)
 	u16 pktlength;
 	u16 pktstatus;
 
-	while (((rxstatus = priv->dmaops->get_rx_status(priv)) != 0) &&
-	       (count < limit))  {
+	/* Check for count < limit first as get_rx_status is changing
+	* the response-fifo so we must process the next packet
+	* after calling get_rx_status if a response is pending.
+	* (reading the last byte of the response pops the value from the fifo.)
+	*/
+	while ((count < limit) &&
+	       ((rxstatus = priv->dmaops->get_rx_status(priv)) != 0)) {
 		pktstatus = rxstatus >> 16;
 		pktlength = rxstatus & 0xffff;
 
-- 
2.1.4
