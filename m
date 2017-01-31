From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH] net: ethernet: ti: cpsw: fix  NULL pointer dereference in switch mode
Date: Tue, 31 Jan 2017 14:04:04 -0600
Message-ID: <20170131200404.29150-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In switch mode on struct cpsw_slave->ndev field will be initialized with
proper value only for the one cpsw slave port, as result
cpsw_get_usage_count() will generate "Unable to handle kernel NULL pointer
dereference" exception when first ethernet interface is opening
cpsw_ndo_open(). This issue causes boot regression on AM335x EVM and
reproducible on am57xx-evm (switch mode).
Fix it by adding additional check for !cpsw->slaves[i].ndev in
cpsw_get_usage_count().

Cc: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
fixes: 03fd01ad0eea ("net: ethernet: ti: cpsw: don't duplicate ndev_running")
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 67b7323..35a95dc 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -677,7 +677,7 @@ static int cpsw_get_usage_count(struct cpsw_common *cpsw)
 	u32 usage_count = 0;
 
 	for (i = 0; i < cpsw->data.slaves; i++)
-		if (netif_running(cpsw->slaves[i].ndev))
+		if (cpsw->slaves[i].ndev && netif_running(cpsw->slaves[i].ndev))
 			usage_count++;
 
 	return usage_count;
-- 
2.10.1.dirty
