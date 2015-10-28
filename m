From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 1/4] sfc: use __GFP_NOWARN when allocating RX pages
 from atomic context.
Date: Wed, 28 Oct 2015 15:01:29 +0000
Message-ID: <5630E349.70207@solarflare.com>
References: <5630E2FD.3070609@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:1439 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750964AbbJ1PEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 11:04:46 -0400
In-Reply-To: <5630E2FD.3070609@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandra Kossovsky <Alexandra.Kossovsky@oktetlabs.ru>

If we fail to allocate a page when in atomic context this is
handled by scheduling a fill in non-atomic context.
As such, a warning is not needed.

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/rx.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 809ea461..3f0e129 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -163,8 +163,15 @@ static int efx_init_rx_buffers(struct efx_rx_queue *rx_queue, bool atomic)
 	do {
 		page = efx_reuse_page(rx_queue);
 		if (page == NULL) {
+			/* GFP_ATOMIC may fail because of various reasons,
+			 * and we re-schedule rx_fill from non-atomic
+			 * context in such a case.  So, use __GFP_NO_WARN
+			 * in case of atomic.
+			 */
 			page = alloc_pages(__GFP_COLD | __GFP_COMP |
-					   (atomic ? GFP_ATOMIC : GFP_KERNEL),
+					   (atomic ?
+					    (GFP_ATOMIC | __GFP_NOWARN)
+					    : GFP_KERNEL),
 					   efx->rx_buffer_order);
 			if (unlikely(page == NULL))
 				return -ENOMEM;
