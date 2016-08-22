From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v4 2/5] net: ethernet: ti: davinci_cpdma: fix locking while ctrl_stop
Date: Mon, 22 Aug 2016 21:18:25 +0300
Message-ID: <1471889908-29983-3-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1471889908-29983-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org,
        nsekhar@ti.com, dlide@ti.com,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: davem@davemloft.net, netdev@vger.kernel.org, mugunthanvnm@ti.com,
        grygorii.strashko@ti.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:32866 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754126AbcHVSSj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 14:18:39 -0400
Received: by mail-lf0-f43.google.com with SMTP id b199so84151571lfe.0
        for <netdev@vger.kernel.org>; Mon, 22 Aug 2016 11:18:38 -0700 (PDT)
In-Reply-To: <1471889908-29983-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The interrupts shouldn't be disabled while receiving skb, but while
ctrl_stop, the channels are stopped and all remaining packets are
handled with netif_receive_skb(), it can cause WARN_ONCE when ctrl
is stopping while not all packets were handled with NAPIs:

lock_irq_save
    cpdma_ctlr_stop
       cpdma_chan_top
           __cpdma_chan_free
               cpsw_rx_handler
                   netif_receive_skb

So, split locking while ctrl stop thus interrupts are still
enabled while skbs handling. It can cause WARN_ONCE in rare
cases when ctrl is stopping while not all packets were handled
with NAPIs.

Reviewed-by: Mugunthan V N <mugunthanvnm@ti.com>
Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 167fd65..ffb32af 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -334,12 +334,14 @@ int cpdma_ctlr_stop(struct cpdma_ctlr *ctlr)
 	}
 
 	ctlr->state = CPDMA_STATE_TEARDOWN;
+	spin_unlock_irqrestore(&ctlr->lock, flags);
 
 	for (i = 0; i < ARRAY_SIZE(ctlr->channels); i++) {
 		if (ctlr->channels[i])
 			cpdma_chan_stop(ctlr->channels[i]);
 	}
 
+	spin_lock_irqsave(&ctlr->lock, flags);
 	dma_reg_write(ctlr, CPDMA_RXINTMASKCLEAR, 0xffffffff);
 	dma_reg_write(ctlr, CPDMA_TXINTMASKCLEAR, 0xffffffff);
 
-- 
1.9.1
