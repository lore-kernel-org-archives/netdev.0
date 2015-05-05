From: Sonic Zhang <sonic.adi@gmail.com>
Subject: [PATCH] stmmac: call local_irq_save other than disable_irq in poll_controller
Date: Tue, 5 May 2015 15:55:53 +0800
Message-ID: <1430812553-7588-1-git-send-email-sonic.adi@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adi-buildroot-devel@lists.sourceforge.net>,
	Sonic Zhang <sonic.zhang@analog.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0062.outbound.protection.outlook.com ([157.56.111.62]:31921
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756729AbbEEIco (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2015 04:32:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sonic Zhang <sonic.zhang@analog.com>

It is possible that poll_controller is called from netpoll.c with irq
already disabled. Unexpected interrupt may be triggered if always
enable irq before returning from poll_controller.

Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 05c146f..830c008 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2465,9 +2465,11 @@ static irqreturn_t stmmac_interrupt(int irq, void *dev_id)
  */
 static void stmmac_poll_controller(struct net_device *dev)
 {
-	disable_irq(dev->irq);
+	unsigned long flags;
+
+	local_irq_save(flags);
 	stmmac_interrupt(dev->irq, dev);
-	enable_irq(dev->irq);
+	local_irq_restore(flags);
 }
 #endif
 
-- 
1.7.9.5
