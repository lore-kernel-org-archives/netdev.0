From: Philipp Zabel <p.zabel@pengutronix.de>
Subject: [PATCH] net: fec: ptp: fix NULL pointer dereference if ptp_clock is not set
Date: Wed, 22 Oct 2014 16:34:35 +0200
Message-ID: <1413988475-6565-1-git-send-email-p.zabel@pengutronix.de>
Cc: netdev@vger.kernel.org, Philipp Zabel <p.zabel@pengutronix.de>
To: "David S. Miller" <davem@davemloft.net>,
	Luwei Zhou <b45643@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55932 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752293AbaJVOej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 10:34:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 278d24047891 (net: fec: ptp: Enable PPS output based on ptp clock)
fec_enet_interrupt calls fec_ptp_check_pps_event unconditionally, which calls
into ptp_clock_event. If fep->ptp_clock is NULL, ptp_clock_event tries to
dereference the NULL pointer.
Since on i.MX53 fep->bufdesc_ex is not set, fec_ptp_init is never called,
and fep->ptp_clock is NULL, which reliably causes a kernel panic.

This patch adds a check for fep->ptp_clock == NULL in fec_enet_interrupt.

Signed-off-by: Philipp Zabel <p.zabel@pengutronix.de>
---
 drivers/net/ethernet/freescale/fec_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 81b96cf..50a851d 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1581,7 +1581,8 @@ fec_enet_interrupt(int irq, void *dev_id)
 		complete(&fep->mdio_done);
 	}
 
-	fec_ptp_check_pps_event(fep);
+	if (fep->ptp_clock)
+		fec_ptp_check_pps_event(fep);
 
 	return ret;
 }
-- 
2.1.1
