From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch] d80211: fix crash in ieee80211_rx_michael_mic_report()
Date: Fri, 25 Aug 2006 14:12:37 -0700
Message-ID: <20060825211237.GA5515@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	Elliot Schwartz <elliot@devicescape.com>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-42.dex002.intermedia.net ([64.78.21.132]:33405 "EHLO
	dhost002-42.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S964796AbWHYVMm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 17:12:42 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="michael_mic_failure_crash.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes a crash at ieee80211.c line 3461, ieee80211_rx_michael_mic_report()
(rx->sdata->type == IEEE80211_IF_TYPE_AP).  rx.sdata needs to be set before
calling ieee80211_rx_michael_mic_report().

Signed-off-by: Elliot Schwartz <elliot@devicescape.com>
Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c
+++ wireless-dev/net/d80211/ieee80211.c
@@ -3582,6 +3582,11 @@ void __ieee80211_rx(struct net_device *d
 	else
 		sta = rx.sta = NULL;
 
+	if (sta) {
+		rx.dev = sta->dev;
+		rx.sdata = IEEE80211_DEV_TO_SUB_IF(rx.dev);
+	}
+
         if ((status->flag & RX_FLAG_MMIC_ERROR)) {
 		ieee80211_rx_michael_mic_report(dev, hdr, sta, &rx);
 		goto end;
@@ -3597,8 +3602,6 @@ void __ieee80211_rx(struct net_device *d
 
 	if (sta && !sta->assoc_ap && !(sta->flags & WLAN_STA_WDS) &&
 	    !local->iff_promiscs && !multicast) {
-		rx.dev = sta->dev;
-		rx.sdata = IEEE80211_DEV_TO_SUB_IF(rx.dev);
 		rx.u.rx.ra_match = 1;
 		ieee80211_invoke_rx_handlers(local, local->rx_handlers, &rx,
 					     sta);

--
