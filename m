From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] mac80211: Add support for SIOCGIWRATE ioctl to provide rate information
Date: Mon, 11 Jun 2007 21:23:19 -0400
Message-ID: <20070612012319.GH20422@tuxdriver.com>
References: <20070610.181704.73383002.davem@davemloft.net> <20070612012228.GG20422@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2822 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757336AbXFLBy4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 21:54:56 -0400
Content-Disposition: inline
In-Reply-To: <20070612012228.GG20422@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Larry Finger <Larry.Finger@lwfinger.net>

At present, transmission rate information for mac80211 is available only
if verbose debugging is turned on, and then only in the logs. This patch
implements the SIOCGIWRATE ioctl, which adds the current transmission rate to
the output of iwconfig.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 net/mac80211/ieee80211_ioctl.c |   25 ++++++++++++++++++++++++-
 1 files changed, 24 insertions(+), 1 deletions(-)

diff --git a/net/mac80211/ieee80211_ioctl.c b/net/mac80211/ieee80211_ioctl.c
index 352f03b..66e8a97 100644
--- a/net/mac80211/ieee80211_ioctl.c
+++ b/net/mac80211/ieee80211_ioctl.c
@@ -838,6 +838,29 @@ static int ieee80211_ioctl_giwscan(struct net_device *dev,
 }
 
 
+static int ieee80211_ioctl_giwrate(struct net_device *dev,
+				  struct iw_request_info *info,
+				  struct iw_param *rate, char *extra)
+{
+	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
+	struct sta_info *sta;
+	struct ieee80211_sub_if_data *sdata;
+
+	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
+	if (sdata->type == IEEE80211_IF_TYPE_STA)
+		sta = sta_info_get(local, sdata->u.sta.bssid);
+	else
+		return -EOPNOTSUPP;
+	if (!sta)
+		return -ENODEV;
+	if (sta->txrate < local->oper_hw_mode->num_rates)
+		rate->value = local->oper_hw_mode->rates[sta->txrate].rate * 100000;
+	else
+		rate->value = 0;
+	sta_info_put(sta);
+	return 0;
+}
+
 static int ieee80211_ioctl_siwrts(struct net_device *dev,
 				  struct iw_request_info *info,
 				  struct iw_param *rts, char *extra)
@@ -1779,7 +1802,7 @@ static const iw_handler ieee80211_handler[] =
 	(iw_handler) NULL,				/* -- hole -- */
 	(iw_handler) NULL,				/* -- hole -- */
 	(iw_handler) NULL,				/* SIOCSIWRATE */
-	(iw_handler) NULL,				/* SIOCGIWRATE */
+	(iw_handler) ieee80211_ioctl_giwrate,		/* SIOCGIWRATE */
 	(iw_handler) ieee80211_ioctl_siwrts,		/* SIOCSIWRTS */
 	(iw_handler) ieee80211_ioctl_giwrts,		/* SIOCGIWRTS */
 	(iw_handler) ieee80211_ioctl_siwfrag,		/* SIOCSIWFRAG */
-- 
1.5.0.6

-- 
John W. Linville
linville@tuxdriver.com
