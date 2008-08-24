From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 3/5] mv643xx_eth: fix inconsistent lock semantics
Date: Sun, 24 Aug 2008 04:05:22 +0200
Message-ID: <20080824020522.GD8762@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>,
	Nicolas Pitre <nico@cam.org>,
	Gerhard Bertelsmann <info@gerhard-bertelsmann.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:57603 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752713AbYHXCFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Aug 2008 22:05:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nicolas Pitre noted that mv643xx_eth_poll was incorrectly using
non-IRQ-safe locks while checking whether to wake up the netdevice's
transmit queue.  Convert the locking to *_irq() variants, since we
are running from softirq context where interrupts are enabled.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 8a91d79..30e6d4b 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -634,9 +634,9 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 				txq_reclaim(mp->txq + i, 0);
 
 		if (netif_carrier_ok(mp->dev)) {
-			spin_lock(&mp->lock);
+			spin_lock_irq(&mp->lock);
 			__txq_maybe_wake(mp->txq + mp->txq_primary);
-			spin_unlock(&mp->lock);
+			spin_unlock_irq(&mp->lock);
 		}
 	}
 #endif
-- 
1.5.6.4
