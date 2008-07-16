From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 04/10] mv643xx_eth: fix transmit-reclaim-in-napi-poll
Date: Wed, 16 Jul 2008 12:32:22 +0200
Message-ID: <20080716103222.GE8545@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:44731 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756301AbYGPKcX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 06:32:23 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv643xx_eth driver allows doing transmit reclaim from within the
napi poll routine, but after doing reclaim, it would forget to check
the free transmit descriptor count and wake up the transmit queue if
the reclaim caused enough descriptors for a new packet to become
available.  This would cause the netdev watchdog to occasionally kick
in during certain workloads with combined receive and transmit traffic.

Fix this by adding a wakeup check identical to the one in the
interrupt handler to the napi poll routine.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index d7620c5..3211369 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -626,6 +626,12 @@ static int mv643xx_eth_poll(struct napi_struct *napi, int budget)
 		for (i = 0; i < 8; i++)
 			if (mp->txq_mask & (1 << i))
 				txq_reclaim(mp->txq + i, 0);
+
+		if (netif_carrier_ok(mp->dev)) {
+			spin_lock(&mp->lock);
+			__txq_maybe_wake(mp->txq + mp->txq_primary);
+			spin_unlock(&mp->lock);
+		}
 	}
 #endif
 
-- 
1.5.3.4
