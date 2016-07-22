From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 1/3] net: ethernet: ti: cpdma: fix lockup in cpdma_ctlr_destroy()
Date: Fri, 22 Jul 2016 16:58:45 +0300
Message-ID: <20160722135847.20557-2-grygorii.strashko@ti.com>
References: <20160722135847.20557-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160722135847.20557-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix deadlock in cpdma_ctlr_destroy() which is triggered now on
cpsw module removal:
 cpsw_remove()
 - cpdma_ctlr_destroy()
   - spin_lock_irqsave(&ctlr->lock, flags)
   - cpdma_ctlr_stop()
     - spin_lock_irqsave(&ctlr->lock, flags); <- deadlock
   - cpdma_chan_destroy()
     - spin_lock_irqsave(&ctlr->lock, flags); <- deadlock

The issue has not been observed before because CPDMA channels have
been destroyed manually by CPSW until commit d941ebe88a41 ("net:
ethernet: ti: cpsw: use destroy ctlr to destroy channels") was merged.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index a68652a..89242e9 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -436,7 +436,6 @@ int cpdma_ctlr_destroy(struct cpdma_ctlr *ctlr)
 	if (!ctlr)
 		return -EINVAL;
 
-	spin_lock_irqsave(&ctlr->lock, flags);
 	if (ctlr->state != CPDMA_STATE_IDLE)
 		cpdma_ctlr_stop(ctlr);
 
@@ -444,7 +443,6 @@ int cpdma_ctlr_destroy(struct cpdma_ctlr *ctlr)
 		cpdma_chan_destroy(ctlr->channels[i]);
 
 	cpdma_desc_pool_destroy(ctlr->pool);
-	spin_unlock_irqrestore(&ctlr->lock, flags);
 	return ret;
 }
 EXPORT_SYMBOL_GPL(cpdma_ctlr_destroy);
-- 
2.9.2
