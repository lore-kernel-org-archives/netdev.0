From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next] sfc: Use the correct maximum TX DMA ring size for
 SFC9100
Date: Thu, 23 Jan 2014 14:35:48 +0000
Message-ID: <52E128C4.7010806@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:25848 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753528AbaAWOfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 09:35:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>

As part of a workaround for a hardware erratum in the SFC9100 family
(SF bug 35388), the TX_DESC_UPD_DWORD register address is also used
for communicating with the event block, and only descriptor pointer
values < 2048 are valid.

If the TX DMA ring size is increased to 4096 descriptors (which the
firmware still allows) then we may write a descriptor pointer 
value >= 2048, which has entirely different and undesirable effects!

Limit the TX DMA ring size correctly when this workaround is in
effect.

Fixes: 8127d661e77f ('sfc: Add support for Solarflare SFC9100 family')
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
This patch limits the TX DMA ring size to <= 2048.
This bug fix is needed for all versions supporting EF10
i.e all versions including and after 3.12.

 drivers/net/ethernet/sfc/efx.h     |    3 +++
 drivers/net/ethernet/sfc/ethtool.c |    4 ++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.h b/drivers/net/ethernet/sfc/efx.h
index 6012247..dbd7b78 100644
--- a/drivers/net/ethernet/sfc/efx.h
+++ b/drivers/net/ethernet/sfc/efx.h
@@ -66,6 +66,9 @@ void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue);
 #define EFX_RXQ_MIN_ENT		128U
 #define EFX_TXQ_MIN_ENT(efx)	(2 * efx_tx_max_skb_descs(efx))
 
+#define EFX_TXQ_MAX_ENT(efx)	(EFX_WORKAROUND_35388(efx) ? \
+				 EFX_MAX_DMAQ_SIZE / 2 : EFX_MAX_DMAQ_SIZE)
+
 /* Filters */
 
 /**
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index f181522..2294289 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -591,7 +591,7 @@ static void efx_ethtool_get_ringparam(struct net_device *net_dev,
 	struct efx_nic *efx = netdev_priv(net_dev);
 
 	ring->rx_max_pending = EFX_MAX_DMAQ_SIZE;
-	ring->tx_max_pending = EFX_MAX_DMAQ_SIZE;
+	ring->tx_max_pending = EFX_TXQ_MAX_ENT(efx);
 	ring->rx_pending = efx->rxq_entries;
 	ring->tx_pending = efx->txq_entries;
 }
@@ -604,7 +604,7 @@ static int efx_ethtool_set_ringparam(struct net_device *net_dev,
 
 	if (ring->rx_mini_pending || ring->rx_jumbo_pending ||
 	    ring->rx_pending > EFX_MAX_DMAQ_SIZE ||
-	    ring->tx_pending > EFX_MAX_DMAQ_SIZE)
+	    ring->tx_pending > EFX_TXQ_MAX_ENT(efx))
 		return -EINVAL;
 
 	if (ring->rx_pending < EFX_RXQ_MIN_ENT) {
