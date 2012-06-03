From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 3/4] can: c_can: fix race condition in c_can_open()
Date: Mon,  4 Jun 2012 00:21:59 +0200
Message-ID: <1338762120-12695-4-git-send-email-mkl@pengutronix.de>
References: <1338762120-12695-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	AnilKumar Ch <anilkumar@ti.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
To: davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1338762120-12695-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: AnilKumar Ch <anilkumar@ti.com>

Fix the issue of C_CAN interrupts getting disabled forever when canconfig
utility is used multiple times. According to NAPI usage we disable all
the hardware interrupts in ISR and re-enable them in poll(). Current
implementation calls napi_enable() after hardware interrupts are enabled.
If we get any interrupts between these two steps then we do not process
those interrupts because napi is not enabled. Mostly these interrupts
come because of STATUS is not 0x7 or ERROR interrupts. If napi_enable()
happens before HW interrupts enabled then c_can_poll() function will be
called eventual re-enabling.

This patch moves the napi_enable() call before interrupts enabled.

Cc: stable@kernel.org # 2.6.39+
Signed-off-by: AnilKumar Ch <anilkumar@ti.com>
Acked-by: Wolfgang Grandegger <wg@grandegger.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/c_can/c_can.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_can.c
index fa01621..8dc84d6 100644
--- a/drivers/net/can/c_can/c_can.c
+++ b/drivers/net/can/c_can/c_can.c
@@ -1064,10 +1064,11 @@ static int c_can_open(struct net_device *dev)
 		goto exit_irq_fail;
 	}
 
+	napi_enable(&priv->napi);
+
 	/* start the c_can controller */
 	c_can_start(dev);
 
-	napi_enable(&priv->napi);
 	netif_start_queue(dev);
 
 	return 0;
-- 
1.7.4.1

