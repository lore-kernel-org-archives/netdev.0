From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Subject: [PATCH] net: fec: turn on device when extracting statistics
Date: Fri, 25 Nov 2016 13:02:00 +0300
Message-ID: <1480068120-22137-1-git-send-email-nikita.yoush@cogentembedded.com>
Cc: Chris Healy <cphealy@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>
To: Fugang Duan <fugang.duan@nxp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Troy Kisky <troy.kisky@boundarydevices.com>,
        Andrew Lunn <andrew@lunn.ch>, Eric Nelson <eric@nelint.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Johannes Berg <johannes@sipsolutions.net>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:33509 "EHLO
        mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751694AbcKYKD0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 05:03:26 -0500
Received: by mail-lf0-f51.google.com with SMTP id c13so46657114lfg.0
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 02:02:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Execution 'ethtool -S' on fec device that is down causes OOPS on Vybrid
board:

Unhandled fault: external abort on non-linefetch (0x1008) at 0xe0898200
pgd = ddecc000
[e0898200] *pgd=9e406811, *pte=400d1653, *ppte=400d1453
Internal error: : 1008 [#1] SMP ARM
...

Reason of OOPS is that fec_enet_get_ethtool_stats() accesses fec
registers while IPG clock is stopped by PM.

Fix that by wrapping statistics extraction into pm_runtime_get_sync()
... pm_runtime_put_autosuspend() braces.

Signed-off-by: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 5aa9d4ded214..9c7592b80ce8 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2317,10 +2317,19 @@ static void fec_enet_get_ethtool_stats(struct net_device *dev,
 	struct ethtool_stats *stats, u64 *data)
 {
 	struct fec_enet_private *fep = netdev_priv(dev);
-	int i;
+	int i, ret;
+
+	ret = pm_runtime_get_sync(&fep->pdev->dev);
+	if (IS_ERR_VALUE(ret)) {
+		memset(data, 0, sizeof(*data) * ARRAY_SIZE(fec_stats));
+		return;
+	}
 
 	for (i = 0; i < ARRAY_SIZE(fec_stats); i++)
 		data[i] = readl(fep->hwp + fec_stats[i].offset);
+
+	pm_runtime_mark_last_busy(&fep->pdev->dev);
+	pm_runtime_put_autosuspend(&fep->pdev->dev);
 }
 
 static void fec_enet_get_strings(struct net_device *netdev,
-- 
2.1.4
