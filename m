From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 1/5] be2net: Fix race in posting rx buffers.
Date: Tue, 23 Aug 2011 11:11:51 +0530
Message-ID: <1314078115-8121-2-git-send-email-sathya.perla@emulex.com>
References: <1314078115-8121-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:27624 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751595Ab1HWFmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2011 01:42:49 -0400
In-Reply-To: <1314078115-8121-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a possibility of be_post_rx_frags() being called simultaneously from
both be_worker() (when rx_post_starved) and be_poll_rx() (when rxq->used is 0).
This can be avoided by posting rx buffers only when some completions have been
reaped.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index ef62594..09eb699 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1862,7 +1862,7 @@ loop_continue:
 	}
 
 	/* Refill the queue */
-	if (atomic_read(&rxo->q.used) < RX_FRAGS_REFILL_WM)
+	if (work_done && atomic_read(&rxo->q.used) < RX_FRAGS_REFILL_WM)
 		be_post_rx_frags(rxo, GFP_ATOMIC);
 
 	/* All consumed */
-- 
1.7.4

