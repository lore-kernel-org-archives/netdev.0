From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 01/15] drivers: net: cpsw: fix suspend when all ethX devices are down
Date: Wed, 15 Jun 2016 14:55:49 +0300
Message-ID: <20160615115603.4897-2-grygorii.strashko@ti.com>
References: <20160615115603.4897-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	Rob Herring <robh+dt@kernel.org>, <devicetree@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Sekhar Nori <nsekhar@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160615115603.4897-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The cpsw_suspend() could trigger L3 error and CPSW will stop
functioning if System enters suspend when all ethX net-devices are
down - in this case CPSW could be already suspended by PM runtime, but
cpsw_suspend() will try to call soft_reset_slave() unconditionally
and access CPSW registers.

Hence, fix it by moving soft_reset_slave() from cpsw_suspend() to
cpsw_slave_stop(). This way slave ports will be reset when CPSW is
active and will be in proper state during Suspend.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index e6bb0ec..736c77a 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1244,6 +1244,7 @@ static void cpsw_slave_stop(struct cpsw_slave *slave, struct cpsw_priv *priv)
 	slave->phy = NULL;
 	cpsw_ale_control_set(priv->ale, slave_port,
 			     ALE_PORT_STATE, ALE_PORT_STATE_DISABLE);
+	soft_reset_slave(slave);
 }
 
 static int cpsw_ndo_open(struct net_device *ndev)
@@ -2558,12 +2559,10 @@ static int cpsw_suspend(struct device *dev)
 		for (i = 0; i < priv->data.slaves; i++) {
 			if (netif_running(priv->slaves[i].ndev))
 				cpsw_ndo_stop(priv->slaves[i].ndev);
-			soft_reset_slave(priv->slaves + i);
 		}
 	} else {
 		if (netif_running(ndev))
 			cpsw_ndo_stop(ndev);
-		for_each_slave(priv, soft_reset_slave);
 	}
 
 	pm_runtime_put_sync(&pdev->dev);
-- 
2.8.4
