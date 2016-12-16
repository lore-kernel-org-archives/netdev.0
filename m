From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH net 2/3] cpsw/netcp: davinci_cpdma: sanitize inter-module API
Date: Fri, 16 Dec 2016 10:19:58 +0100
Message-ID: <20161216092017.2560717-2-arnd@arndb.de>
References: <20161216092017.2560717-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        "David S. Miller" <davem@davemloft.net>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        =?UTF-8?q?Uwe=20Kleine-K=C3=B6nig?=
        <u.kleine-koenig@pengutronix.de>, linux-omap@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161216092017.2560717-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The davinci_cpdma module is a helper library that is used by the
actual device drivers and does nothing by itself, so all its API
functions need to be exported.

Four new functions were added recently without an export, so now
we get a build error:

ERROR: "cpdma_chan_set_weight" [drivers/net/ethernet/ti/ti_cpsw.ko] undefined!
ERROR: "cpdma_chan_get_rate" [drivers/net/ethernet/ti/ti_cpsw.ko] undefined!
ERROR: "cpdma_chan_get_min_rate" [drivers/net/ethernet/ti/ti_cpsw.ko] undefined!
ERROR: "cpdma_chan_set_rate" [drivers/net/ethernet/ti/ti_cpsw.ko] undefined!

This exports those symbols. After taking a closer look, I found two
more global functions in this file that are not exported and not used
anywhere, so they can obviously be removed. There is also one function
that is only used internally in this module, and should be 'static'.

Fixes: 8f32b90981dc ("net: ethernet: ti: davinci_cpdma: add set rate for a channel")
Fixes: 0fc6432cc78d ("net: ethernet: ti: davinci_cpdma: add weight function for channels")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/ti/davinci_cpdma.c | 59 ++++++++++-----------------------
 drivers/net/ethernet/ti/davinci_cpdma.h |  4 ---
 2 files changed, 17 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/ti/davinci_cpdma.c b/drivers/net/ethernet/ti/davinci_cpdma.c
index 36518fc5c7cc..b9d40f0cdf6c 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.c
+++ b/drivers/net/ethernet/ti/davinci_cpdma.c
@@ -628,6 +628,23 @@ int cpdma_ctlr_destroy(struct cpdma_ctlr *ctlr)
 }
 EXPORT_SYMBOL_GPL(cpdma_ctlr_destroy);
 
+static int cpdma_chan_int_ctrl(struct cpdma_chan *chan, bool enable)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&chan->lock, flags);
+	if (chan->state != CPDMA_STATE_ACTIVE) {
+		spin_unlock_irqrestore(&chan->lock, flags);
+		return -EINVAL;
+	}
+
+	dma_reg_write(chan->ctlr, enable ? chan->int_set : chan->int_clear,
+		      chan->mask);
+	spin_unlock_irqrestore(&chan->lock, flags);
+
+	return 0;
+}
+
 int cpdma_ctlr_int_ctrl(struct cpdma_ctlr *ctlr, bool enable)
 {
 	unsigned long flags;
@@ -1274,46 +1291,4 @@ int cpdma_chan_stop(struct cpdma_chan *chan)
 }
 EXPORT_SYMBOL_GPL(cpdma_chan_stop);
 
-int cpdma_chan_int_ctrl(struct cpdma_chan *chan, bool enable)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&chan->lock, flags);
-	if (chan->state != CPDMA_STATE_ACTIVE) {
-		spin_unlock_irqrestore(&chan->lock, flags);
-		return -EINVAL;
-	}
-
-	dma_reg_write(chan->ctlr, enable ? chan->int_set : chan->int_clear,
-		      chan->mask);
-	spin_unlock_irqrestore(&chan->lock, flags);
-
-	return 0;
-}
-
-int cpdma_control_get(struct cpdma_ctlr *ctlr, int control)
-{
-	unsigned long flags;
-	int ret;
-
-	spin_lock_irqsave(&ctlr->lock, flags);
-	ret = _cpdma_control_get(ctlr, control);
-	spin_unlock_irqrestore(&ctlr->lock, flags);
-
-	return ret;
-}
-
-int cpdma_control_set(struct cpdma_ctlr *ctlr, int control, int value)
-{
-	unsigned long flags;
-	int ret;
-
-	spin_lock_irqsave(&ctlr->lock, flags);
-	ret = _cpdma_control_set(ctlr, control, value);
-	spin_unlock_irqrestore(&ctlr->lock, flags);
-
-	return ret;
-}
-EXPORT_SYMBOL_GPL(cpdma_control_set);
-
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/ethernet/ti/davinci_cpdma.h b/drivers/net/ethernet/ti/davinci_cpdma.h
index 4a167db2abab..36d0a09a3d44 100644
--- a/drivers/net/ethernet/ti/davinci_cpdma.h
+++ b/drivers/net/ethernet/ti/davinci_cpdma.h
@@ -87,7 +87,6 @@ int cpdma_chan_process(struct cpdma_chan *chan, int quota);
 
 int cpdma_ctlr_int_ctrl(struct cpdma_ctlr *ctlr, bool enable);
 void cpdma_ctlr_eoi(struct cpdma_ctlr *ctlr, u32 value);
-int cpdma_chan_int_ctrl(struct cpdma_chan *chan, bool enable);
 u32 cpdma_ctrl_rxchs_state(struct cpdma_ctlr *ctlr);
 u32 cpdma_ctrl_txchs_state(struct cpdma_ctlr *ctlr);
 bool cpdma_check_free_tx_desc(struct cpdma_chan *chan);
@@ -111,7 +110,4 @@ enum cpdma_control {
 	CPDMA_RX_BUFFER_OFFSET,		/* read-write */
 };
 
-int cpdma_control_get(struct cpdma_ctlr *ctlr, int control);
-int cpdma_control_set(struct cpdma_ctlr *ctlr, int control, int value);
-
 #endif
-- 
2.9.0
