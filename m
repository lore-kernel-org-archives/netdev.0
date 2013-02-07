From: Frank Li <Frank.Li@freescale.com>
Subject: [PATCH v3 1/2 net-next] net: fec: correct fix method about miss init spinlock
Date: Thu, 7 Feb 2013 08:59:58 +0800
Message-ID: <1360198799-25173-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <B38611@freescale.com>,
	<s.hauer@pengutronix.de>, Frank Li <Frank.Li@freescale.com>
To: <lznuaa@gmail.com>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe002.messaging.microsoft.com ([213.199.154.140]:38683
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755715Ab3BGBh1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 20:37:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Old method will cause init spinlock twice.
New method will avoid init spinlock twice and fix miss init spinlock
at fec_restart.

BUG: spinlock bad magic on CPU#1, swapper/0/1
lock: 0xbfae0f8c, .magic: 00000000, .owner: <none>/-1, .owner_cpu: 0
Backtrace:
 [<80011d54>] (dump_backtrace+0x0/0x10c) from [<804e7800>] (dump_stack+0x18/0x1c)
 r6:bfae0000 r5:bfae0f8c r4:00000000 r3:806c1310
 [<804e77e8>] (dump_stack+0x0/0x1c) from [<804e9f20>] (spin_dump+0x80/0x94)
 [<804e9ea0>] (spin_dump+0x0/0x94) from [<804e9f60>] (spin_bug+0x2c/0x30)
 r5:805f6f8c r4:bfae0f8c
 [<804e9f34>] (spin_bug+0x0/0x30) from [<80257984>] (do_raw_spin_lock+0x170/0x1b0                                         )
 r5:806b4950 r4:bfae0f8c
 [<80257814>] (do_raw_spin_lock+0x0/0x1b0) from [<804ed15c>] (_raw_spin_lock_irqs                                         ave+0x18/0x20)
 [<804ed144>] (_raw_spin_lock_irqsave+0x0/0x20) from [<8033c694>] (fec_ptp_start_                                         cyclecounter+0x3c/0x120)
 r4:bfae0f8c r3:00000002
 [<8033c658>] (fec_ptp_start_cyclecounter+0x0/0x120) from [<80339e08>] (fec_resta                                         rt+0x56c/0x5f8)
 r8:00000000 r7:806e6f48 r6:00000112 r5:806b4950 r4:bfae0000
 [<8033989c>] (fec_restart+0x0/0x5f8) from [<8033b9e4>] (fec_probe+0x508/0xa48)

Signed-off-by: Frank Li <Frank.Li@freescale.com>
---
Change from v2 to v3.
 * rebase to net-next
 * revert old fix

Change from v2 to v1.
 * avoid reinit hwreg_lock twice

 drivers/net/ethernet/freescale/fec.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 51215e1..0fe68c4 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -1609,7 +1609,6 @@ static int fec_enet_init(struct net_device *ndev)
 	}
 
 	spin_lock_init(&fep->hw_lock);
-	spin_lock_init(&fep->tmreg_lock);
 
 	fep->netdev = ndev;
 
@@ -1841,6 +1840,9 @@ fec_probe(struct platform_device *pdev)
 
 	fec_reset_phy(pdev);
 
+	if (fep->bufdesc_ex)
+		fec_ptp_init(ndev, pdev);
+
 	ret = fec_enet_init(ndev);
 	if (ret)
 		goto failed_init;
@@ -1856,9 +1858,6 @@ fec_probe(struct platform_device *pdev)
 	if (ret)
 		goto failed_register;
 
-	if (fep->bufdesc_ex)
-		fec_ptp_init(ndev, pdev);
-
 	return 0;
 
 failed_register:
-- 
1.7.1
