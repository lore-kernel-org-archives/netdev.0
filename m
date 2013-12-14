From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 15/15] sfc: Remove unnecessary condition for
 processing the TX timestamp queue
Date: Sat, 14 Dec 2013 23:07:36 +0000
Message-ID: <1387062456.12172.73.camel@deadeye.wl.decadent.org.uk>
References: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17455 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753979Ab3LNXHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 18:07:40 -0500
In-Reply-To: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ptp.c |   16 ++++------------
 1 files changed, 4 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 06c6420f40d7..084e2d44790f 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -890,13 +890,10 @@ static enum ptp_packet_state efx_ptp_match_rx(struct efx_nic *efx,
 /* Process any queued receive events and corresponding packets
  *
  * q is returned with all the packets that are ready for delivery.
- * true is returned if at least one of those packets requires
- * synchronisation.
  */
-static bool efx_ptp_process_events(struct efx_nic *efx, struct sk_buff_head *q)
+static void efx_ptp_process_events(struct efx_nic *efx, struct sk_buff_head *q)
 {
 	struct efx_ptp_data *ptp = efx->ptp_data;
-	bool rc = false;
 	struct sk_buff *skb;
 
 	while ((skb = skb_dequeue(&ptp->rxq))) {
@@ -907,7 +904,6 @@ static bool efx_ptp_process_events(struct efx_nic *efx, struct sk_buff_head *q)
 			__skb_queue_tail(q, skb);
 		} else if (efx_ptp_match_rx(efx, skb) ==
 			   PTP_PACKET_STATE_MATCHED) {
-			rc = true;
 			__skb_queue_tail(q, skb);
 		} else if (time_after(jiffies, match->expiry)) {
 			match->state = PTP_PACKET_STATE_TIMED_OUT;
@@ -921,8 +917,6 @@ static bool efx_ptp_process_events(struct efx_nic *efx, struct sk_buff_head *q)
 			break;
 		}
 	}
-
-	return rc;
 }
 
 /* Complete processing of a received packet */
@@ -1088,12 +1082,10 @@ static void efx_ptp_worker(struct work_struct *work)
 	efx_ptp_drop_time_expired_events(efx);
 
 	__skb_queue_head_init(&tempq);
-	if (efx_ptp_process_events(efx, &tempq) ||
-	    !skb_queue_empty(&ptp_data->txq)) {
+	efx_ptp_process_events(efx, &tempq);
 
-		while ((skb = skb_dequeue(&ptp_data->txq)))
-			efx_ptp_xmit_skb(efx, skb);
-	}
+	while ((skb = skb_dequeue(&ptp_data->txq)))
+		efx_ptp_xmit_skb(efx, skb);
 
 	while ((skb = __skb_dequeue(&tempq)))
 		efx_ptp_process_rx(efx, skb);

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
