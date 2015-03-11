From: George Joseph <george.joseph@fairview5.com>
Subject: [PATCH 1/1] net: fec: fix oops after transmit queue timeout
Date: Wed, 11 Mar 2015 11:00:15 -0600
Message-ID: <1426093216-18370-1-git-send-email-george.joseph@fairview5.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Nimrod Andy <B38611@freescale.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	Frank Li <Frank.Li@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:40600 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055AbbCKRFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 13:05:24 -0400
Received: by igal13 with SMTP id l13so41817691iga.5
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 10:05:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a transmit queue timeout happens, dev_watchdog calls fec_timeout
which in turns schedules fec_enet_timeout_work.  fec_enet_timeout_work
uses container_of to get the private data structure (fep) then tries to
use fep->netdev.  Unfortunately, nobody ever set fep->netdev so the result
is a NULL pointer oops.

With fep->netdev set right after fep is allocated in fep_probe, the
drivers recovers nicely after the tx queue timeout.

Signed-off-by: George Joseph <george.joseph@fairview5.com>
Tested-by: George Joseph <george.joseph@fairview5.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 3dca494..f6392ad 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -3161,6 +3161,7 @@ fec_probe(struct platform_device *pdev)
 	/* setup board info structure */
 	fep = netdev_priv(ndev);
 
+	fep->netdev = ndev;
 	fep->num_rx_queues = num_rx_qs;
 	fep->num_tx_queues = num_tx_qs;
 
-- 
2.1.0
