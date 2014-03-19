From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net-next] gianfar: Fix P1010 config regression (SQ polling)
Date: Wed, 19 Mar 2014 15:39:39 +0200
Message-ID: <1395236379-16116-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [65.55.88.13] ([65.55.88.13]:14312 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933771AbaCSNnW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 09:43:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The P1010 device tree restricts the number of
supported interrupt groups to 1, although the eth
controller can support 2 interrupt groups and the
driver assumes the Multi-Group mode ("fsl,etsec2" model).

So, in this case the assumption that the Multi-Group
mode (MQ_MG_MODE) devices always support 2 interrupt
groups is false.  To fix this, a check for the actual
number of interrupt groups enabled in the board's
device tree has been added in gfar_probe for the
"fsl,etsec2" devices.

Without this fix, P1010 based boards claim support for
2 Tx queues to the net stack but only one is actually
allocated, leading to NULL access in xmit.  This issue
was introduced by enabling Single-Queue polling for
the P1010 devices.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 14 ++++++++++++--
 1 file changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 6e12f93..9125d9a 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -754,9 +754,19 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 		num_tx_qs = 1;
 		num_rx_qs = 1;
 	} else { /* MQ_MG_MODE */
+		/* get the actual number of supported groups */
+		unsigned int num_grps = of_get_available_child_count(np);
+
+		if (num_grps == 0 || num_grps > MAXGROUPS) {
+			dev_err(&ofdev->dev, "Invalid # of int groups(%d)\n",
+				num_grps);
+			pr_err("Cannot do alloc_etherdev, aborting\n");
+			return -EINVAL;
+		}
+
 		if (poll_mode == GFAR_SQ_POLLING) {
-			num_tx_qs = 2; /* one txq per int group */
-			num_rx_qs = 2; /* one rxq per int group */
+			num_tx_qs = num_grps; /* one txq per int group */
+			num_rx_qs = num_grps; /* one rxq per int group */
 		} else { /* GFAR_MQ_POLLING */
 			num_tx_qs = tx_queues ? *tx_queues : 1;
 			num_rx_qs = rx_queues ? *rx_queues : 1;
-- 
1.7.11.7
