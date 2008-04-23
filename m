From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] mac80211: Fix race between ieee80211_rx_bss_put and lookup
 routines.
Date: Wed, 23 Apr 2008 11:47:15 +0400
Message-ID: <480EE983.4020209@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	linux-wireless@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:51754 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751315AbYDWIbV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2008 04:31:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The put routine first decrements the users counter and then
(if it is zero) locks the sta_bss_lock and removes one from
the list and the hash.

Thus, any of ieee80211_sta_config_auth, ieee80211_rx_bss_get
or ieee80211_rx_mesh_bss_get can race with it by finding a
bss that is about to get kfree-ed.

Using atomic_dec_and_lock in ieee80211_rx_bss_put takes care
of this race.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 6b75cb6..dac3c2a 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -2248,10 +2248,13 @@ static void ieee80211_rx_bss_put(struct net_device *dev,
 				 struct ieee80211_sta_bss *bss)
 {
 	struct ieee80211_local *local = wdev_priv(dev->ieee80211_ptr);
-	if (!atomic_dec_and_test(&bss->users))
+
+	local_bh_disable();
+	if (!atomic_dec_and_lock(&bss->users, &local->sta_bss_lock)) {
+		local_bh_enable();
 		return;
+	}
 
-	spin_lock_bh(&local->sta_bss_lock);
 	__ieee80211_rx_bss_hash_del(dev, bss);
 	list_del(&bss->list);
 	spin_unlock_bh(&local->sta_bss_lock);
