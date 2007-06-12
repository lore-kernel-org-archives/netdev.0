From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] mac80211: Don't stop tx queue on master device while scanning.
Date: Mon, 11 Jun 2007 21:18:43 -0400
Message-ID: <20070612011843.GF20422@tuxdriver.com>
References: <20070612011616.GC20422@tuxdriver.com> <20070612011716.GD20422@tuxdriver.com> <20070612011802.GE20422@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2817 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757065AbXFLByt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 21:54:49 -0400
Content-Disposition: inline
In-Reply-To: <20070612011802.GE20422@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mattias Nissler <mattias.nissler@gmx.de>

mac80211 stops the tx queues during scans. This is wrong with respect
to the master deivce tx queue, since stopping it prevents any probes
from being sent during the scan. Instead, they accumulate in the queue
and are only sent after the scan is finished, which is obviously
wrong.

Signed-off-by: Mattias Nissler <mattias.nissler@gmx.de>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 net/mac80211/ieee80211_sta.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/net/mac80211/ieee80211_sta.c b/net/mac80211/ieee80211_sta.c
index 9f30ae4..91b545c 100644
--- a/net/mac80211/ieee80211_sta.c
+++ b/net/mac80211/ieee80211_sta.c
@@ -2592,11 +2592,17 @@ void ieee80211_scan_completed(struct ieee80211_hw *hw)
 
 	read_lock(&local->sub_if_lock);
 	list_for_each_entry(sdata, &local->sub_if_list, list) {
+
+		/* No need to wake the master device. */
+		if (sdata->dev == local->mdev)
+			continue;
+
 		if (sdata->type == IEEE80211_IF_TYPE_STA) {
 			if (sdata->u.sta.associated)
 				ieee80211_send_nullfunc(local, sdata, 0);
 			ieee80211_sta_timer((unsigned long)sdata);
 		}
+
 		netif_wake_queue(sdata->dev);
 	}
 	read_unlock(&local->sub_if_lock);
@@ -2738,6 +2744,12 @@ static int ieee80211_sta_start_scan(struct net_device *dev,
 
 	read_lock(&local->sub_if_lock);
 	list_for_each_entry(sdata, &local->sub_if_list, list) {
+
+		/* Don't stop the master interface, otherwise we can't transmit
+		 * probes! */
+		if (sdata->dev == local->mdev)
+			continue;
+
 		netif_stop_queue(sdata->dev);
 		if (sdata->type == IEEE80211_IF_TYPE_STA &&
 		    sdata->u.sta.associated)
-- 
1.5.0.6

-- 
John W. Linville
linville@tuxdriver.com
