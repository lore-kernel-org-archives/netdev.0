From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 6/8] tg3: Don't allocate jumbo ring for 5780
 class devs
Date: Thu, 14 Oct 2010 13:37:43 -0700
Message-ID: <1287088665-22135-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2074 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756023Ab0JNUiG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Oct 2010 16:38:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 5714, 5715, and 5780 devices do not have a separate rx jumbo
producer ring.  This patch changes the code so that resources are not
allocated for it.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 84530d9..17ca0a3 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6219,7 +6219,8 @@ static void tg3_rx_prodring_free(struct tg3 *tp,
 		tg3_rx_skb_free(tp, &tpr->rx_std_buffers[i],
 				tp->rx_pkt_map_sz);
 
-	if (tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) {
+	if ((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) &&
+	    !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) {
 		for (i = 0; i <= tp->rx_jmb_ring_mask; i++)
 			tg3_rx_skb_free(tp, &tpr->rx_jmb_buffers[i],
 					TG3_RX_JMB_MAP_SZ);
@@ -6246,7 +6247,7 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
 	if (tpr != &tp->napi[0].prodring) {
 		memset(&tpr->rx_std_buffers[0], 0,
 		       TG3_RX_STD_BUFF_RING_SIZE(tp));
-		if (tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE)
+		if (tpr->rx_jmb_buffers)
 			memset(&tpr->rx_jmb_buffers[0], 0,
 			       TG3_RX_JMB_BUFF_RING_SIZE(tp));
 		goto done;
@@ -6289,7 +6290,8 @@ static int tg3_rx_prodring_alloc(struct tg3 *tp,
 		}
 	}
 
-	if (!(tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE))
+	if (!(tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) ||
+	    (tp->tg3_flags2 & TG3_FLG2_5780_CLASS))
 		goto done;
 
 	memset(tpr->rx_jmb, 0, TG3_RX_JMB_RING_BYTES(tp));
@@ -6361,7 +6363,8 @@ static int tg3_rx_prodring_init(struct tg3 *tp,
 	if (!tpr->rx_std)
 		goto err_out;
 
-	if (tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) {
+	if ((tp->tg3_flags & TG3_FLAG_JUMBO_CAPABLE) &&
+	    !(tp->tg3_flags2 & TG3_FLG2_5780_CLASS)) {
 		tpr->rx_jmb_buffers = kzalloc(TG3_RX_JMB_BUFF_RING_SIZE(tp),
 					      GFP_KERNEL);
 		if (!tpr->rx_jmb_buffers)
-- 
1.7.2.2


