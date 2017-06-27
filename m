From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH net-next 2/3] net: ethernet: ti: cpsw: fix sw timestamping for non PTP packets
Date: Tue, 27 Jun 2017 16:58:52 +0300
Message-ID: <1498571933-3663-3-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1498571933-3663-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, linux-omap@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: m-karicheri2@ti.com, w-kwok2@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1498571933-3663-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The cpts can timestmap only ptp packets at this moment, so driver
cannot mark every packet as though it's going to be timestamped,
only because h/w timestamping for given skb is enabled with
SKBTX_HW_TSTAMP. It doesn't allow to use sw timestamping, as result
outgoing packet is not timestamped at all if it's not PTP and h/w
timestamping is enabled. So, fix it by setting SKBTX_IN_PROGRESS
only for PTP packets.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c |  3 ++-
 drivers/net/ethernet/ti/cpts.h | 16 ++++++++++++++++
 2 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 422994e..1850e34 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1598,6 +1598,7 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	struct cpsw_common *cpsw = priv->cpsw;
+	struct cpts *cpts = cpsw->cpts;
 	struct netdev_queue *txq;
 	struct cpdma_chan *txch;
 	int ret, q_idx;
@@ -1609,7 +1610,7 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 	}
 
 	if (skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP &&
-	    cpts_is_tx_enabled(cpsw->cpts))
+	    cpts_is_tx_enabled(cpts) && cpts_can_timestamp(cpts, skb))
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 
 	q_idx = skb_get_queue_mapping(skb);
diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
index c96eca2..01ea82b 100644
--- a/drivers/net/ethernet/ti/cpts.h
+++ b/drivers/net/ethernet/ti/cpts.h
@@ -30,6 +30,7 @@
 #include <linux/of.h>
 #include <linux/ptp_clock_kernel.h>
 #include <linux/skbuff.h>
+#include <linux/ptp_classify.h>
 #include <linux/timecounter.h>
 
 struct cpsw_cpts {
@@ -155,6 +156,16 @@ static inline bool cpts_is_tx_enabled(struct cpts *cpts)
 	return !!cpts->tx_enable;
 }
 
+static inline bool cpts_can_timestamp(struct cpts *cpts, struct sk_buff *skb)
+{
+	unsigned int class = ptp_classify_raw(skb);
+
+	if (class == PTP_CLASS_NONE)
+		return false;
+
+	return true;
+}
+
 #else
 struct cpts;
 
@@ -203,6 +214,11 @@ static inline bool cpts_is_tx_enabled(struct cpts *cpts)
 {
 	return false;
 }
+
+static inline bool cpts_can_timestamp(struct cpts *cpts, struct sk_buff *skb)
+{
+	return false;
+}
 #endif
 
 
-- 
2.7.4
