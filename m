From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 2/8] sfc: PTP: Moderate log message on event queue
 overflow
Date: Wed, 11 Dec 2013 01:53:46 +0000
Message-ID: <1386726826.1516.238.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:40930 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172Ab3LKBxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 20:53:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Laurence Evans <levans@solarflare.com>

Limit syslog flood if a PTP packet storm occurs.

Fixes: 7c236c43b838 ('sfc: Add support for IEEE-1588 PTP')
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ptp.c | 23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index 93a61a157d10..8b2cf783217c 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -220,6 +220,7 @@ struct efx_ptp_timeset {
  * @evt_list: List of MC receive events awaiting packets
  * @evt_free_list: List of free events
  * @evt_lock: Lock for manipulating evt_list and evt_free_list
+ * @evt_overflow: Boolean indicating that event list has overflowed
  * @rx_evts: Instantiated events (on evt_list and evt_free_list)
  * @workwq: Work queue for processing pending PTP operations
  * @work: Work task
@@ -270,6 +271,7 @@ struct efx_ptp_data {
 	struct list_head evt_list;
 	struct list_head evt_free_list;
 	spinlock_t evt_lock;
+	bool evt_overflow;
 	struct efx_ptp_event_rx rx_evts[MAX_RECEIVE_EVENTS];
 	struct workqueue_struct *workwq;
 	struct work_struct work;
@@ -635,6 +637,11 @@ static void efx_ptp_drop_time_expired_events(struct efx_nic *efx)
 			}
 		}
 	}
+	/* If the event overflow flag is set and the event list is now empty
+	 * clear the flag to re-enable the overflow warning message.
+	 */
+	if (ptp->evt_overflow && list_empty(&ptp->evt_list))
+		ptp->evt_overflow = false;
 	spin_unlock_bh(&ptp->evt_lock);
 }
 
@@ -676,6 +683,11 @@ static enum ptp_packet_state efx_ptp_match_rx(struct efx_nic *efx,
 			break;
 		}
 	}
+	/* If the event overflow flag is set and the event list is now empty
+	 * clear the flag to re-enable the overflow warning message.
+	 */
+	if (ptp->evt_overflow && list_empty(&ptp->evt_list))
+		ptp->evt_overflow = false;
 	spin_unlock_bh(&ptp->evt_lock);
 
 	return rc;
@@ -809,6 +821,7 @@ static int efx_ptp_stop(struct efx_nic *efx)
 	list_for_each_safe(cursor, next, &efx->ptp_data->evt_list) {
 		list_move(cursor, &efx->ptp_data->evt_free_list);
 	}
+	ptp->evt_overflow = false;
 	spin_unlock_bh(&efx->ptp_data->evt_lock);
 
 	return rc;
@@ -901,6 +914,7 @@ static int efx_ptp_probe_channel(struct efx_channel *channel)
 	spin_lock_init(&ptp->evt_lock);
 	for (pos = 0; pos < MAX_RECEIVE_EVENTS; pos++)
 		list_add(&ptp->rx_evts[pos].link, &ptp->evt_free_list);
+	ptp->evt_overflow = false;
 
 	ptp->phc_clock_info.owner = THIS_MODULE;
 	snprintf(ptp->phc_clock_info.name,
@@ -1299,8 +1313,13 @@ static void ptp_event_rx(struct efx_nic *efx, struct efx_ptp_data *ptp)
 		list_add_tail(&evt->link, &ptp->evt_list);
 
 		queue_work(ptp->workwq, &ptp->work);
-	} else {
-		netif_err(efx, rx_err, efx->net_dev, "No free PTP event");
+	} else if (!ptp->evt_overflow) {
+		/* Log a warning message and set the event overflow flag.
+		 * The message won't be logged again until the event queue
+		 * becomes empty.
+		 */
+		netif_err(efx, rx_err, efx->net_dev, "PTP event queue overflow\n");
+		ptp->evt_overflow = true;
 	}
 	spin_unlock_bh(&ptp->evt_lock);
 }


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
