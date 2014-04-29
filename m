From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH net-next 5/7] net:fec: add support for dumping transmit ring on timeout
Date: Tue, 29 Apr 2014 20:09:08 +0800
Message-ID: <1398773350-7293-5-git-send-email-Frank.Li@freescale.com>
References: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Frank Li <Frank.Li@freescale.com>
To: <lznuaa@gmail.com>, <shawn.guo@linaro.org>, <B38611@freescale.com>,
	<davem@davemloft.net>, <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0241.outbound.protection.outlook.com ([207.46.163.241]:24670
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751447AbaD2Nfu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2014 09:35:50 -0400
In-Reply-To: <1398773350-7293-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King <rmk+kernel@arm.linux.org.uk>

When we timeout on transmit, it would be useful to dump the transmit
ring, so we can see the ring state.  This can be helpful to diagnose
the cause of transmit timeouts.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
 drivers/net/ethernet/freescale/fec_main.c |   23 +++++++++++++++++++++++
 1 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 9de899e..7d506ae 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -291,6 +291,27 @@ static void *swap_buffer(void *bufaddr, int len)
 	return bufaddr;
 }
 
+static void fec_dump(struct net_device *ndev)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+	struct bufdesc *bdp = fep->tx_bd_base;
+	unsigned index = 0;
+
+	netdev_info(ndev, "TX ring dump\n");
+	pr_info("Nr     SC     addr       len  SKB\n");
+
+	do {
+		pr_info("%3u %c%c 0x%04x 0x%08lx %4u %p\n",
+			index,
+			bdp == fep->cur_tx ? 'S' : ' ',
+			bdp == fep->dirty_tx ? 'H' : ' ',
+			bdp->cbd_sc, bdp->cbd_bufaddr, bdp->cbd_datlen,
+			fep->tx_skbuff[index]);
+		bdp = fec_enet_get_nextdesc(bdp, fep);
+		index++;
+	} while (bdp != fep->tx_bd_base);
+}
+
 static int
 fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
 {
@@ -717,6 +738,8 @@ fec_timeout(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 
+	fec_dump(ndev);
+
 	ndev->stats.tx_errors++;
 
 	fep->delay_work.timeout = true;
-- 
1.7.8
