From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH] drivers: net: cpsw: fix wrong regs access in cpsw_ndo_open
Date: Tue, 19 Apr 2016 21:09:49 +0300
Message-ID: <1461089389-17508-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The cpsw_ndo_open() could try to access CPSW registers before
calling pm_runtime_get_sync(). This will trigger L3 error:

 WARNING: CPU: 0 PID: 21 at drivers/bus/omap_l3_noc.c:147 l3_interrupt_handler+0x220/0x34c()
 44000000.ocp:L3 Custom Error: MASTER M2 (64-bit) TARGET L4_FAST (Idle): Data Access in Supervisor mode during Functional access

and CPSW will stop functioning.

Hence, fix it by moving pm_runtime_get_sync() before the first access
to CPSW registers in cpsw_ndo_open().

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 54bcc38..0fa75a8 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1244,12 +1244,12 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	int i, ret;
 	u32 reg;
 
+	pm_runtime_get_sync(&priv->pdev->dev);
+
 	if (!cpsw_common_res_usage_state(priv))
 		cpsw_intr_disable(priv);
 	netif_carrier_off(ndev);
 
-	pm_runtime_get_sync(&priv->pdev->dev);
-
 	reg = priv->version;
 
 	dev_info(priv->dev, "initializing cpsw version %d.%d (%d)\n",
-- 
2.8.1
