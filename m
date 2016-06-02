From: Yangbo Lu <yangbo.lu@nxp.com>
Subject: [PATCH] gianfar: fix the last transmit buffer descriptor
Date: Thu, 2 Jun 2016 17:36:28 +0800
Message-ID: <1464860188-47854-1-git-send-email-yangbo.lu@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Claudiu Manoil <claudiu.manoil@freescale.com>,
	Yangbo Lu <yangbo.lu@nxp.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0085.outbound.protection.outlook.com ([65.55.169.85]:10688
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932440AbcFBJqr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2016 05:46:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the transmit hardware timestamping is enabled, an additional
TxBD would be added and would be set as the last TxBD with TXBD_LAST
and TXBD_INTERRUPT. However this has been broken by a patch recently.
This made the software couldn't get transmit hardware timestamps and
resulted in call trace. So, this patch is to fix this issue.

Fixes: 48963b4492e9 ("gianfar: Remove redundant ops for do_tstamp
       from xmit()")
Signed-off-by: Yangbo Lu <yangbo.lu@nxp.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 7615e06..2e6785b 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -2440,7 +2440,8 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 						 tx_queue->tx_ring_size);
 
 	if (likely(!nr_frags)) {
-		lstatus |= BD_LFLAG(TXBD_LAST | TXBD_INTERRUPT);
+		if (likely(!do_tstamp))
+			lstatus |= BD_LFLAG(TXBD_LAST | TXBD_INTERRUPT);
 	} else {
 		u32 lstatus_start = lstatus;
 
-- 
2.1.0.27.g96db324
