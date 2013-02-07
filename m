From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH v3 2/2 net-next] net: fec: fix spin_lock dead lock
Date: Thu, 7 Feb 2013 08:59:59 +0800
Message-ID: <1360198799-25173-2-git-send-email-Frank.Li@freescale.com>
References: <1360198799-25173-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <B38611@freescale.com>,
	<s.hauer@pengutronix.de>, Frank Li <Frank.Li@freescale.com>
To: <lznuaa@gmail.com>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe003.messaging.microsoft.com ([216.32.181.183]:14783
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752296Ab3BGBh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 20:37:26 -0500
In-Reply-To: <1360198799-25173-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=========================================================
[ INFO: possible irq lock inversion dependency detected ]
3.8.0-rc5+ #82 Not tainted
---------------------------------------------------------
swapper/0/0 just changed the state of lock:
 (&(&fep->hw_lock)->rlock){..-...}, at: [<8034e2f8>] fec_enet_start_xmit+0x48/0x                      2cc
but this lock took another, SOFTIRQ-unsafe lock in the past:
(prepare_lock){+.+.+.}

and interrupts could create inverse lock ordering between them.
other info that might help us debug this:
Possible interrupt unsafe locking scenario:

CPU0				CPU1
----				----
lock(prepare_lock);
				local_irq_disable()
				lock(&(&fep->hw_lock)->rlock);
				lock(prepare_lock);
<Interrupt>
lock(&(&fep->hw_lock)->rlock);

*** DEADLOCK ***

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
No change from v1 to v3. 

 drivers/net/ethernet/freescale/fec_ptp.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_ptp.c b/drivers/net/ethernet/freescale/fec_ptp.c
index c40526c..1f17ca0 100644
--- a/drivers/net/ethernet/freescale/fec_ptp.c
+++ b/drivers/net/ethernet/freescale/fec_ptp.c
@@ -104,7 +104,7 @@ void fec_ptp_start_cyclecounter(struct net_device *ndev)
 	unsigned long flags;
 	int inc;
 
-	inc = 1000000000 / clk_get_rate(fep->clk_ptp);
+	inc = 1000000000 / fep->cycle_speed;
 
 	/* grab the ptp lock */
 	spin_lock_irqsave(&fep->tmreg_lock, flags);
@@ -363,6 +363,8 @@ void fec_ptp_init(struct net_device *ndev, struct platform_device *pdev)
 	fep->ptp_caps.settime = fec_ptp_settime;
 	fep->ptp_caps.enable = fec_ptp_enable;
 
+	fep->cycle_speed = clk_get_rate(fep->clk_ptp);
+
 	spin_lock_init(&fep->tmreg_lock);
 
 	fec_ptp_start_cyclecounter(ndev);
-- 
1.7.1
