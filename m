From: Russell King <rmk+kernel@armlinux.org.uk>
Subject: [PATCH] net: mv643xx_eth: ensure coalesce settings survive
 read-modify-write
Date: Tue, 01 Nov 2016 10:50:01 +0000
Message-ID: <E1c1Wdl-0000tO-Ql@rmk-PC.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.armlinux.org.uk ([78.32.30.218]:45076 "EHLO
        pandora.armlinux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1168617AbcKAKuH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 06:50:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The coalesce settings behave badly when changing just one value:

... # ethtool -c eth0
rx-usecs: 249
... # ethtool -C eth0 tx-usecs 250
... # ethtool -c eth0
rx-usecs: 248

This occurs due to rounding errors when calculating the microseconds
value - the divisons round down.  This causes (eg) the rx-usecs to
decrease by one every time the tx-usecs value is set as per the above.

Fix this by making the divison round-to-nearest.

Signed-off-by: Russell King <rmk+kernel@armlinux.org.uk>
---
 drivers/net/ethernet/marvell/mv643xx_eth.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 2a85202de6da..8a472cbfda09 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -1429,6 +1429,7 @@ static unsigned int get_rx_coal(struct mv643xx_eth_private *mp)
 		temp = (val & 0x003fff00) >> 8;
 
 	temp *= 64000000;
+	temp += mp->t_clk / 2;
 	do_div(temp, mp->t_clk);
 
 	return (unsigned int)temp;
@@ -1465,6 +1466,7 @@ static unsigned int get_tx_coal(struct mv643xx_eth_private *mp)
 
 	temp = (rdlp(mp, TX_FIFO_URGENT_THRESHOLD) & 0x3fff0) >> 4;
 	temp *= 64000000;
+	temp += mp->t_clk / 2;
 	do_div(temp, mp->t_clk);
 
 	return (unsigned int)temp;
-- 
2.1.0
