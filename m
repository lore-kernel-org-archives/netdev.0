From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net 3/4] gianfar: Fix Rx BSY error handling
Date: Fri, 23 Oct 2015 11:42:00 +0300
Message-ID: <1445589721-26206-4-git-send-email-claudiu.manoil@freescale.com>
References: <1445589721-26206-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0105.outbound.protection.outlook.com ([157.56.111.105]:24500
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750847AbbJWImV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 04:42:21 -0400
In-Reply-To: <1445589721-26206-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Rx BSY error interrupt indicates that a frame was
received and discarded due to lack of buffers, so it's
a rx ring overflow condition and has nothing to do with
with bad rx packets.  Use the right counter.

BSY conditions happen when the SoC is under performance
stress.  Doing *more* work in stress situations by trying
to schedule NAPI is not a good idea as the stressed system
becomes still more stressed.  The Rx interrupt is already
at work making sure the NAPI is scheduled.
So calling gfar_receive() here does not help.  This issue
was present since day 1.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 939ed8f..ce38d26 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -3462,11 +3462,9 @@ static irqreturn_t gfar_error(int irq, void *grp_id)
 		netif_dbg(priv, tx_err, dev, "Transmit Error\n");
 	}
 	if (events & IEVENT_BSY) {
-		dev->stats.rx_errors++;
+		dev->stats.rx_over_errors++;
 		atomic64_inc(&priv->extra_stats.rx_bsy);
 
-		gfar_receive(irq, grp_id);
-
 		netif_dbg(priv, rx_err, dev, "busy error (rstat: %x)\n",
 			  gfar_read(&regs->rstat));
 	}
-- 
1.7.11.7
