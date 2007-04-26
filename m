From: akpm@linux-foundation.org
Subject: [patch 09/11] forcedeth: improve NAPI logic
Date: Thu, 26 Apr 2007 00:23:23 -0700
Message-ID: <200704260723.l3Q7NNCj023844@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, mingo@elte.hu,
	aabdulla@nvidia.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:37217 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933334AbXDZHYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:24:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>

Another forcedeth.c thing: i noticed that its NAPI handler does not do
tx-ring processing.  The patch below implements this - tested on DESC_VER_2
hardware, with CONFIG_FORCEDETH_NAPI=y.

Signed-off-by: Ingo Molnar <mingo@elte.hu>
Cc: Ayaz Abdulla <aabdulla@nvidia.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/forcedeth.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff -puN drivers/net/forcedeth.c~forcedeth-improve-napi-logic drivers/net/forcedeth.c
--- a/drivers/net/forcedeth.c~forcedeth-improve-napi-logic
+++ a/drivers/net/forcedeth.c
@@ -3108,9 +3108,17 @@ static int nv_napi_poll(struct net_devic
 	int retcode;
 
 	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+		spin_lock_irqsave(&np->lock, flags);
+		nv_tx_done(dev);
+		spin_unlock_irqrestore(&np->lock, flags);
+
 		pkts = nv_rx_process(dev, limit);
 		retcode = nv_alloc_rx(dev);
 	} else {
+		spin_lock_irqsave(&np->lock, flags);
+		nv_tx_done_optimized(dev, np->tx_ring_size);
+		spin_unlock_irqrestore(&np->lock, flags);
+
 		pkts = nv_rx_process_optimized(dev, limit);
 		retcode = nv_alloc_rx_optimized(dev);
 	}
_
