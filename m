From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 04/10] sfc: Remove TX completions from adaptive IRQ
 scoring
Date: Sat, 10 Mar 2012 00:49:49 +0000
Message-ID: <1331340589.2537.14.camel@bwh-desktop>
References: <1331340409.2537.10.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:51244 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758793Ab2CJAtw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 19:49:52 -0500
In-Reply-To: <1331340409.2537.10.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RX and TX completions on the same event queue are generally not associated
with the same flows.  The inclusion of TX completions in the adaptive IRQ
score is more of a source of noise rather than useful feedback.  Therefore,
do not include them in the score, and adjust the default threshold scores
down.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |    4 ++--
 drivers/net/ethernet/sfc/nic.c |    1 -
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 1908ba7..00e13ab 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -163,12 +163,12 @@ static int phy_flash_cfg;
 module_param(phy_flash_cfg, int, 0644);
 MODULE_PARM_DESC(phy_flash_cfg, "Set PHYs into reflash mode initially");
 
-static unsigned irq_adapt_low_thresh = 10000;
+static unsigned irq_adapt_low_thresh = 8000;
 module_param(irq_adapt_low_thresh, uint, 0644);
 MODULE_PARM_DESC(irq_adapt_low_thresh,
 		 "Threshold score for reducing IRQ moderation");
 
-static unsigned irq_adapt_high_thresh = 20000;
+static unsigned irq_adapt_high_thresh = 16000;
 module_param(irq_adapt_high_thresh, uint, 0644);
 MODULE_PARM_DESC(irq_adapt_high_thresh,
 		 "Threshold score for increasing IRQ moderation");
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 2bf4283..5da8af5 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -822,7 +822,6 @@ efx_handle_tx_event(struct efx_channel *channel, efx_qword_t *event)
 			channel, tx_ev_q_label % EFX_TXQ_TYPES);
 		tx_packets = ((tx_ev_desc_ptr - tx_queue->read_count) &
 			      tx_queue->ptr_mask);
-		channel->irq_mod_score += tx_packets;
 		efx_xmit_done(tx_queue, tx_ev_desc_ptr);
 	} else if (EFX_QWORD_FIELD(*event, FSF_AZ_TX_EV_WQ_FF_FULL)) {
 		/* Rewrite the FIFO write pointer */
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
