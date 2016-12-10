From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH 5/5] net: ethernet: ti: cpsw: sync rates for channels in dual emac mode
Date: Sat, 10 Dec 2016 14:23:50 +0200
Message-ID: <1481372630-14914-6-git-send-email-ivan.khoronzhuk@linaro.org>
References: <1481372630-14914-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: linux-omap@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com, grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1481372630-14914-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The channels are common for both ndevs in dual emac mode. Hence, keep
in sync their rates.

Signed-off-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
---
 drivers/net/ethernet/ti/cpsw.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 7ccfa63..b203143 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -2020,9 +2020,10 @@ static int cpsw_ndo_set_tx_maxrate(struct net_device *ndev, int queue, u32 rate)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
 	struct cpsw_common *cpsw = priv->cpsw;
+	struct cpsw_slave *slave;
 	u32 min_rate;
 	u32 ch_rate;
-	int ret;
+	int i, ret;
 
 	ch_rate = netdev_get_tx_queue(ndev, queue)->tx_maxrate;
 	if (ch_rate == rate)
@@ -2053,6 +2054,15 @@ static int cpsw_ndo_set_tx_maxrate(struct net_device *ndev, int queue, u32 rate)
 	if (ret)
 		return ret;
 
+	/* update rates for slaves tx queues */
+	for (i = 0; i < cpsw->data.slaves; i++) {
+		slave = &cpsw->slaves[i];
+		if (!slave->ndev)
+			continue;
+
+		netdev_get_tx_queue(slave->ndev, queue)->tx_maxrate = rate;
+	}
+
 	cpsw_split_res(ndev);
 	return ret;
 }
-- 
2.7.4
