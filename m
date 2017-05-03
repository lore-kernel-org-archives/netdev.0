From: Quentin Schulz <quentin.schulz@free-electrons.com>
Subject: [PATCH 2/2] can: m_can: add deep Suspend/Resume support
Date: Wed,  3 May 2017 14:11:43 +0200
Message-ID: <20170503121143.25090-2-quentin.schulz@free-electrons.com>
References: <20170503121143.25090-1-quentin.schulz@free-electrons.com>
Cc: Quentin Schulz <quentin.schulz@free-electrons.com>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
        thomas.petazzoni@free-electrons.com
To: wg@grandegger.com, mkl@pengutronix.de, mario.huettel@gmx.net,
        socketcan@hartkopp.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170503121143.25090-1-quentin.schulz@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds Power Management deep Suspend/Resume support for Bosch M_CAN
chip.

When the chip resumes from deep sleep, the RAM needs to be initialized
as it is done when the driver probes. The net interface also needs to be
closed and reopened to be fully functional.

Signed-off-by: Quentin Schulz <quentin.schulz@free-electrons.com>
---
 drivers/net/can/m_can/m_can.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
index 3f0445440146..9e0143b528f1 100644
--- a/drivers/net/can/m_can/m_can.c
+++ b/drivers/net/can/m_can/m_can.c
@@ -1670,12 +1670,10 @@ static __maybe_unused int m_can_suspend(struct device *dev)
 	struct m_can_priv *priv = netdev_priv(ndev);
 
 	if (netif_running(ndev)) {
-		netif_stop_queue(ndev);
 		netif_device_detach(ndev);
+		m_can_close(ndev);
 	}
 
-	/* TODO: enter low power */
-
 	priv->can.state = CAN_STATE_SLEEPING;
 
 	return 0;
@@ -1686,13 +1684,13 @@ static __maybe_unused int m_can_resume(struct device *dev)
 	struct net_device *ndev = dev_get_drvdata(dev);
 	struct m_can_priv *priv = netdev_priv(ndev);
 
-	/* TODO: exit low power */
+	m_can_init_ram(priv);
 
 	priv->can.state = CAN_STATE_ERROR_ACTIVE;
 
 	if (netif_running(ndev)) {
+		m_can_open(ndev);
 		netif_device_attach(ndev);
-		netif_start_queue(ndev);
 	}
 
 	return 0;
-- 
2.11.0
