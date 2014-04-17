From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] tg3: update rx_jumbo_pending ring param only when jumbo frames are enabled
Date: Thu, 17 Apr 2014 14:51:08 +0200
Message-ID: <1397739068-14240-1-git-send-email-ivecera@redhat.com>
Cc: mchan@broadcom.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53496 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756162AbaDQNY4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Apr 2014 09:24:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch fixes a problem with dropped jumbo frames after usage of
'ethtool -G ... rx'.

Scenario:
1. ip link set eth0 up
2. ethtool -G eth0 rx N # <- This zeroes rx-jumbo
3. ip link set mtu 9000 dev eth0

The ethtool command set rx_jumbo_pending to zero so any received jumbo
packets are dropped and you need to use 'ethtool -G eth0 rx-jumbo N'
to workaround the issue.
The patch changes the logic so rx_jumbo_pending value is changed only if
jumbo frames are enabled (MTU > 1500).

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/broadcom/tg3.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index b9f7022..e5d95c5 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -12286,7 +12286,9 @@ static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *e
 	if (tg3_flag(tp, MAX_RXPEND_64) &&
 	    tp->rx_pending > 63)
 		tp->rx_pending = 63;
-	tp->rx_jumbo_pending = ering->rx_jumbo_pending;
+
+	if (tg3_flag(tp, JUMBO_RING_ENABLE))
+		tp->rx_jumbo_pending = ering->rx_jumbo_pending;
 
 	for (i = 0; i < tp->irq_max; i++)
 		tp->napi[i].tx_pending = ering->tx_pending;
-- 
1.8.3.2
