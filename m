From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 1/5] mv643xx_eth: fix NAPI 'rotting packet' issue
Date: Sun, 24 Aug 2008 04:04:36 +0200
Message-ID: <20080824020436.GB8762@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>, Nicolas Pitre <nico@cam.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:45075 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751491AbYHXCEi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 22:04:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a receive interrupt occurs, mv643xx_eth would first process the
receive descriptors and then ACK the receive interrupt, instead of the
other way round.

This would leave a small race window between processing the last
receive descriptor and clearing the receive interrupt status in which
a new packet could come in, which would then 'rot' in the receive
ring until the next receive interrupt would come in.

Fix this by ACKing (clearing) the receive interrupt condition before
processing the receive descriptors.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 46819af..af279f2 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -650,8 +650,6 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 
 	if (rx < budget) {
 		netif_rx_complete(mp->dev, napi);
-		wrl(mp, INT_CAUSE(mp->port_num), 0);
-		wrl(mp, INT_CAUSE_EXT(mp->port_num), 0);
 		wrl(mp, INT_MASK(mp->port_num), INT_TX_END | INT_RX | INT_EXT);
 	}
 
@@ -1796,6 +1794,7 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 	 */
 #ifdef MV643XX_ETH_NAPI
 	if (int_cause & INT_RX) {
+		wrl(mp, INT_CAUSE(mp->port_num), ~(int_cause & INT_RX));
 		wrl(mp, INT_MASK(mp->port_num), 0x00000000);
 		rdl(mp, INT_MASK(mp->port_num));
 
-- 
1.5.6.4
