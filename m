From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 1/4] net: ethernet: ti: cpdma: fix lockup in cpdma_ctlr_destroy()
Date: Thu, 28 Jul 2016 20:50:34 +0300
Message-ID: <20160728175037.22053-2-grygorii.strashko@ti.com>
References: <20160728175037.22053-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:43537 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932628AbcG1Rut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 13:50:49 -0400
In-Reply-To: <20160728175037.22053-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix deadlock in cpdma_ctlr_destroy() which is triggered now on
cpsw module removal:
 cpsw_remove()
 - cpdma_ctlr_destroy()
   - spin_lock_irqsave(&ctlr->lock, flags)
   - cpdma_ctlr_stop()
     - spin_lock_irqsave(&ctlr->lock, flags);
   - cpdma_chan_destroy()
     - spin_lock_irqsave(&ctlr->lock, flags);

The issue has not been observed before because CPDMA channels have
been destroyed manually by CPSW until commit d941ebe88a41 ("net:
ethernet: ti: cpsw: use destroy ctlr to destroy channels") was merged.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index c8154ff..fdc0f4f 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -357,13 +357,11 @@ EXPORT_SYMBOL_GPL(cpdma_ctlr_stop);
 
 int cpdma_ctlr_destroy(struct cpdma_ctlr *ctlr)
 {
-	unsigned long flags;
 	int ret = 0, i;
 
 	if (!ctlr)
 		return -EINVAL;
 
-	spin_lock_irqsave(&ctlr->lock, flags);
 	if (ctlr->state != CPDMA_STATE_IDLE)
 		cpdma_ctlr_stop(ctlr);
 
@@ -371,7 +369,6 @@ int cpdma_ctlr_destroy(struct cpdma_ctlr *ctlr)
 		cpdma_chan_destroy(ctlr->channels[i]);
 
 	cpdma_desc_pool_destroy(ctlr->pool);
-	spin_unlock_irqrestore(&ctlr->lock, flags);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(cpdma_ctlr_destroy);
-- 
2.9.2
