From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 2/3] ucc_geth: Fix netdev watchdog triggering on link
 changes
Date: Thu, 24 Dec 2009 18:31:05 +0300
Message-ID: <20091224153105.GB1206@oksana.dev.rtsoft.ru>
References: <20091224153034.GA32535@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>,
	Li Yang <leoli@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dev.rtsoft.ru ([213.79.90.226]:50365 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754830AbZLXPbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2009 10:31:09 -0500
Content-Disposition: inline
In-Reply-To: <20091224153034.GA32535@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 864fdf884e82bacbe8ca5e93bd43393a61d2e2b4 ("ucc_geth:
Fix hangs after switching from full to half duplex") ucc_geth driver
disables the controller during MAC configuration changes. Though,
disabling the controller might take quite awhile, and so the netdev
watchdog might get upset:

 NETDEV WATCHDOG: eth2 (ucc_geth): transmit queue 0 timed out
 ------------[ cut here ]------------
 Badness at c02729a8 [verbose debug info unavailable]
 NIP: c02729a8 LR: c02729a8 CTR: c01b6088
 REGS: c0451c40 TRAP: 0700   Not tainted  (2.6.32-trunk-8360e)
 [...]
 NIP [c02729a8] dev_watchdog+0x280/0x290
 LR [c02729a8] dev_watchdog+0x280/0x290
 Call Trace:
 [c0451cf0] [c02729a8] dev_watchdog+0x280/0x290 (unreliable)
 [c0451d50] [c00377c4] run_timer_softirq+0x164/0x224
 [c0451da0] [c0032a38] __do_softirq+0xb8/0x13c
 [c0451df0] [c00065cc] do_softirq+0xa0/0xac
 [c0451e00] [c003280c] irq_exit+0x7c/0x9c
 [c0451e10] [c00640c4] __ipipe_sync_stage+0x248/0x24c
 [...]

This patch fixes the issue by detaching the netdev during the
time we change the configuration.

Reported-by: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
Tested-by: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Cc: Stable <stable@vger.kernel.org> [2.6.32]
---
 drivers/net/ucc_geth.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 0f8c99e..7fff4c5 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -1563,7 +1563,10 @@ static int ugeth_disable(struct ucc_geth_private *ugeth, enum comm_dir mode)
 
 static void ugeth_quiesce(struct ucc_geth_private *ugeth)
 {
-	/* Wait for and prevent any further xmits. */
+	/* Prevent any further xmits, plus detach the device. */
+	netif_device_detach(ugeth->ndev);
+
+	/* Wait for any current xmits to finish. */
 	netif_tx_disable(ugeth->ndev);
 
 	/* Disable the interrupt to avoid NAPI rescheduling. */
@@ -1577,7 +1580,7 @@ static void ugeth_activate(struct ucc_geth_private *ugeth)
 {
 	napi_enable(&ugeth->napi);
 	enable_irq(ugeth->ug_info->uf_info.irq);
-	netif_tx_wake_all_queues(ugeth->ndev);
+	netif_device_attach(ugeth->ndev);
 }
 
 /* Called every time the controller might need to be made
-- 
1.6.3.3

