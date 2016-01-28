From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next 38/40] net: fec: recover from lost rxf_0 interrupt
Date: Thu, 28 Jan 2016 14:26:02 -0700
Message-ID: <1454016364-30985-39-git-send-email-troy.kisky@boundarydevices.com>
References: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@freescale.com, l.stach@pengutronix.de,
	andrew@lunn.ch, tremyfr@gmail.com, linux@arm.linux.org.uk,
	linux-arm-kernel@lists.infradead.org, laci@boundarydevices.com,
	shawnguo@kernel.org, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, B38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34360 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967843AbcA1V3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 16:29:12 -0500
Received: by mail-pf0-f176.google.com with SMTP id o185so25033793pfb.1
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 13:29:12 -0800 (PST)
In-Reply-To: <1454016364-30985-1-git-send-email-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following is true of linux-3.14. I have not been able
to verify on mainline, because I cannot get the cpuidle
driver to work.

If gpio6 workaround is not used for interrupts, then
it is possible for the entire receive queue to become
full without an interrupt. If that happens, and the last
rxf_0 interrupt is lost, then the FEC can no longer receive
packets. However packet transmission is still fine, so the tx
watchdog will never fire. The only way to recover before this
is a ifconfig down/up. Skipping the FEC_ENET_RXF_0 check
will allow the rx queue to recover from the condition when
the next packet is transmitted.

This patch also has the advantage of increasing iperf speed.

Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
---
 drivers/net/ethernet/freescale/fec_main.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 00c9b7e..8372d9b 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1608,9 +1608,10 @@ static int fec_enet_napi_q1(struct napi_struct *napi, int budget)
 		}
 
 		writel(events, fep->hwp + FEC_IEVENT);
-		if (events & FEC_ENET_RXF_0)
-			pkts += fec_rxq(ndev, fep, fep->rx_queue[0],
-					budget - pkts);
+		/* don't check FEC_ENET_RXF_0, to recover from a full queue
+		 * but bit clear condition
+		 */
+		pkts += fec_rxq(ndev, fep, fep->rx_queue[0], budget - pkts);
 		if (events & FEC_ENET_TXF_0)
 			fec_txq(ndev, fep, fep->tx_queue[0]);
 	} while (pkts < budget);
-- 
2.5.0
