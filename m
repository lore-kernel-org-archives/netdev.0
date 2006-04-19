From: Daniel Drake <dsd@gentoo.org>
Subject: [PATCH] softmac: report SIOCGIWAP event upon association
Date: Wed, 19 Apr 2006 01:02:31 +0100 (BST)
Message-ID: <20060419000231.04C3C87C093@zog.reactivated.net>
Cc: softmac-dev@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta07-winn.ispmail.ntl.com ([81.103.221.47]:30965 "EHLO
	mtaout01-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1750861AbWDSAC0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Apr 2006 20:02:26 -0400
To: johannes@sipsolutions.net
Cc: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

wpa_supplicant requires some notification when association has completed, and
this is the way to do it.

Before this patch, wpa_supplicant just times out when trying to associate,
even though the association completed successfully in the background. This was
reported at 
http://www.mail-archive.com/bcm43xx-dev@lists.berlios.de/msg00959.html

After this patch, wpa_supplicant works for me. I have tested connecting to a
WEP network.

Signed-off-by: Daniel Drake <dsd@gentoo.org>

--- linux/net/ieee80211/softmac/ieee80211softmac_assoc.c.orig	2006-04-16 23:55:23.000000000 +0100
+++ linux/net/ieee80211/softmac/ieee80211softmac_assoc.c	2006-04-19 01:08:40.000000000 +0100
@@ -282,6 +282,8 @@ ieee80211softmac_associated(struct ieee8
 	struct ieee80211_assoc_response * resp,
 	struct ieee80211softmac_network *net)
 {
+	union iwreq_data wrqu;
+
 	mac->associnfo.associating = 0;
 	mac->associated = 1;
 	if (mac->set_bssid_filter)
@@ -290,6 +292,10 @@ ieee80211softmac_associated(struct ieee8
 	netif_carrier_on(mac->dev);
 	
 	mac->association_id = le16_to_cpup(&resp->aid);
+
+	wrqu.ap_addr.sa_family = ARPHRD_ETHER;
+	memcpy(wrqu.ap_addr.sa_data, net->bssid, ETH_ALEN);
+	wireless_send_event(mac->dev, SIOCGIWAP, &wrqu, NULL);
 }
 
 /* received frame handling functions */
