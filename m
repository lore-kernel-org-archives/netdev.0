From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 03/18] ipw2200: generates a scan event after a scan has completed
Date: Thu, 13 Apr 2006 17:19:25 +0800
Message-ID: <20060413091925.GA28720@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr20.intel.com ([134.134.136.19]:58032 "EHLO
	orsfmr005.jf.intel.com") by vger.kernel.org with ESMTP
	id S964843AbWDMJ0a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:26:30 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch make ipw2200 generate the scan event every time a scan has
completed, so that user space know when to get fresh results.
Dan Williams would like to go towards this model in Network Manager
rather than having to poll.

Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |   21 ++++++++++++++++++++-
 1 files changed, 20 insertions(+), 1 deletions(-)

edf85b053dafee701cbdda19507485455f97e544
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index a4d8d49..536af9f 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -4489,6 +4489,24 @@ static void ipw_rx_notification(struct i
 				 && priv->status & STATUS_ASSOCIATED)
 				queue_delayed_work(priv->workqueue,
 						   &priv->request_scan, HZ);
+
+			/* Send an empty event to user space.
+			 * We don't send the received data on the event because
+			 * it would require us to do complex transcoding, and
+			 * we want to minimise the work done in the irq handler
+			 * Use a request to extract the data.
+			 * Also, we generate this even for any scan, regardless
+			 * on how the scan was initiated. User space can just
+			 * sync on periodic scan to get fresh data...
+			 * Jean II */
+			if (x->status == SCAN_COMPLETED_STATUS_COMPLETE) {
+				union iwreq_data wrqu;
+
+				wrqu.data.length = 0;
+				wrqu.data.flags = 0;
+				wireless_send_event(priv->net_dev, SIOCGIWSCAN,
+						    &wrqu, NULL);
+			}
 			break;
 		}
 
@@ -8382,7 +8400,8 @@ static int ipw_wx_get_range(struct net_d
 	/* Event capability (kernel + driver) */
 	range->event_capa[0] = (IW_EVENT_CAPA_K_0 |
 				IW_EVENT_CAPA_MASK(SIOCGIWTHRSPY) |
-				IW_EVENT_CAPA_MASK(SIOCGIWAP));
+				IW_EVENT_CAPA_MASK(SIOCGIWAP) |
+				IW_EVENT_CAPA_MASK(SIOCGIWSCAN));
 	range->event_capa[1] = IW_EVENT_CAPA_K_1;
 
 	range->enc_capa = IW_ENC_CAPA_WPA | IW_ENC_CAPA_WPA2 |
-- 
1.2.6

