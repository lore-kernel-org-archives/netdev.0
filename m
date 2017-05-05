From: Quentin Schulz <quentin.schulz@free-electrons.com>
Subject: [PATCH v4 4/4] can: m_can: add deep Suspend/Resume support
Date: Fri,  5 May 2017 15:50:33 +0200
Message-ID: <20170505135033.8349-4-quentin.schulz@free-electrons.com>
References: <20170505135033.8349-1-quentin.schulz@free-electrons.com>
Cc: Quentin Schulz <quentin.schulz@free-electrons.com>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
        thomas.petazzoni@free-electrons.com
To: wg@grandegger.com, mkl@pengutronix.de, mario.huettel@gmx.net,
        socketcan@hartkopp.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170505135033.8349-1-quentin.schulz@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds Power Management deep Suspend/Resume support for Bosch M_CAN
chip.

When entering deep sleep, the clocks are gated, the interrupts are
disabled. When resuming from deep sleep, the chip needs to be
reinitialized, the clocks ungated and the interrupts enabled.

Signed-off-by: Quentin Schulz <quentin.schulz@free-electrons.com>
---

v4:
 - added a TODO comment for efficient runtime PM support,
 - used m_can_clk_start/stop functions added in v4 to have symmetric
 suspend and resume functions.

v3:
 - do not close/reopen the can interface (which was previously done when
 calling m_can_close), basically do the same routine as in probe but
 it does not close/open the can device,
 - update commit log,

v2:
 - fix erroneous commit log,

 drivers/net/can/m_can/m_can.c | 15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index 653b304d7091..f4947a74b65f 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -1668,6 +1668,8 @@ static int m_can_plat_probe(struct platform_device *pdev)
 	return ret;
 }
 
+/* TODO: runtime PM with power down or sleep mode  */
+
 static __maybe_unused int m_can_suspend(struct device *dev)
 {
 	struct net_device *ndev = dev_get_drvdata(dev);
@@ -1676,10 +1678,10 @@ static __maybe_unused int m_can_suspend(struct device *dev)
 	if (netif_running(ndev)) {
 		netif_stop_queue(ndev);
 		netif_device_detach(ndev);
+		m_can_stop(ndev);
+		m_can_clk_stop(priv);
 	}
 
-	/* TODO: enter low power */
-
 	priv->can.state = CAN_STATE_SLEEPING;
 
 	return 0;
@@ -1690,11 +1692,18 @@ static __maybe_unused int m_can_resume(struct device *dev)
 	struct net_device *ndev = dev_get_drvdata(dev);
 	struct m_can_priv *priv = netdev_priv(ndev);
 
-	/* TODO: exit low power */
+	m_can_init_ram(priv);
 
 	priv->can.state = CAN_STATE_ERROR_ACTIVE;
 
 	if (netif_running(ndev)) {
+		int ret;
+
+		ret = m_can_clk_start(priv);
+		if (ret)
+			return ret;
+
+		m_can_start(ndev);
 		netif_device_attach(ndev);
 		netif_start_queue(ndev);
 	}
-- 
2.11.0
