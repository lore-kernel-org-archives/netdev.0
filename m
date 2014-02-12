From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 01/13] sfc: Removed adhoc scheme to rate limit PTP
 event queue overflow message
Date: Wed, 12 Feb 2014 18:58:24 +0000
Message-ID: <52FBC450.7080301@solarflare.com>
References: <52FBC3C2.7030103@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50924 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752204AbaBLS61 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 13:58:27 -0500
In-Reply-To: <52FBC3C2.7030103@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laurence Evans <levans@solarflare.com>

Use conventional net_ratelimit() instead.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ptp.c |   22 ++--------------------
 1 files changed, 2 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index eb75fbd..52be63d 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -223,7 +223,6 @@ struct efx_ptp_timeset {
  * @evt_list: List of MC receive events awaiting packets
  * @evt_free_list: List of free events
  * @evt_lock: Lock for manipulating evt_list and evt_free_list
- * @evt_overflow: Boolean indicating that event list has overflowed
  * @rx_evts: Instantiated events (on evt_list and evt_free_list)
  * @workwq: Work queue for processing pending PTP operations
  * @work: Work task
@@ -275,7 +274,6 @@ struct efx_ptp_data {
 	struct list_head evt_list;
 	struct list_head evt_free_list;
 	spinlock_t evt_lock;
-	bool evt_overflow;
 	struct efx_ptp_event_rx rx_evts[MAX_RECEIVE_EVENTS];
 	struct workqueue_struct *workwq;
 	struct work_struct work;
@@ -941,11 +939,6 @@ static void efx_ptp_drop_time_expired_events(struct efx_nic *efx)
 			}
 		}
 	}
-	/* If the event overflow flag is set and the event list is now empty
-	 * clear the flag to re-enable the overflow warning message.
-	 */
-	if (ptp->evt_overflow && list_empty(&ptp->evt_list))
-		ptp->evt_overflow = false;
 	spin_unlock_bh(&ptp->evt_lock);
 }
 
@@ -989,11 +982,6 @@ static enum ptp_packet_state efx_ptp_match_rx(struct efx_nic *efx,
 			break;
 		}
 	}
-	/* If the event overflow flag is set and the event list is now empty
-	 * clear the flag to re-enable the overflow warning message.
-	 */
-	if (ptp->evt_overflow && list_empty(&ptp->evt_list))
-		ptp->evt_overflow = false;
 	spin_unlock_bh(&ptp->evt_lock);
 
 	return rc;
@@ -1147,7 +1135,6 @@ static int efx_ptp_stop(struct efx_nic *efx)
 	list_for_each_safe(cursor, next, &efx->ptp_data->evt_list) {
 		list_move(cursor, &efx->ptp_data->evt_free_list);
 	}
-	ptp->evt_overflow = false;
 	spin_unlock_bh(&efx->ptp_data->evt_lock);
 
 	return rc;
@@ -1253,7 +1240,6 @@ int efx_ptp_probe(struct efx_nic *efx, struct efx_channel *channel)
 	spin_lock_init(&ptp->evt_lock);
 	for (pos = 0; pos < MAX_RECEIVE_EVENTS; pos++)
 		list_add(&ptp->rx_evts[pos].link, &ptp->evt_free_list);
-	ptp->evt_overflow = false;
 
 	/* Get the NIC PTP attributes and set up time conversions */
 	rc = efx_ptp_get_attributes(efx);
@@ -1635,13 +1621,9 @@ static void ptp_event_rx(struct efx_nic *efx, struct efx_ptp_data *ptp)
 		list_add_tail(&evt->link, &ptp->evt_list);
 
 		queue_work(ptp->workwq, &ptp->work);
-	} else if (!ptp->evt_overflow) {
-		/* Log a warning message and set the event overflow flag.
-		 * The message won't be logged again until the event queue
-		 * becomes empty.
-		 */
+	} else if (net_ratelimit()) {
+		/* Log a rate-limited warning message. */
 		netif_err(efx, rx_err, efx->net_dev, "PTP event queue overflow\n");
-		ptp->evt_overflow = true;
 	}
 	spin_unlock_bh(&ptp->evt_lock);
 }
