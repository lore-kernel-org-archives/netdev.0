From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH 3/3] d80211: fix workqueue breakage
Date: Tue, 12 Dec 2006 12:55:53 -0500
Message-ID: <200612121255.58183.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1340665.txev2NU5CQ";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:48092 "EHLO
	annwn13.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932308AbWLLR4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 12:56:42 -0500
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1340665.txev2NU5CQ
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

d80211: fix workqueue breakage

This patch updates d80211 to use the new workqueue API.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 net/d80211/ieee80211.c       |    7 ++++---
 net/d80211/ieee80211_i.h     |    8 +++++---
 net/d80211/ieee80211_iface.c |    2 +-
 net/d80211/ieee80211_sta.c   |   26 ++++++++++++++------------
 net/d80211/sta_info.c        |    7 ++++---
 5 files changed, 28 insertions(+), 22 deletions(-)

diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 6e10db5..76ee491 100644
=2D-- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -2092,13 +2092,13 @@ void ieee80211_if_shutdown(struct net_de
 	case IEEE80211_IF_TYPE_IBSS:
 		sdata->u.sta.state =3D IEEE80211_DISABLED;
 		cancel_delayed_work(&sdata->u.sta.work);
=2D		if (local->scan_work.data =3D=3D sdata->dev) {
+		if (local->scan_dev =3D=3D sdata->dev) {
 			local->sta_scanning =3D 0;
 			cancel_delayed_work(&local->scan_work);
 			flush_scheduled_work();
 			/* see comment in ieee80211_unregister_hw to
 			 * understand why this works */
=2D			local->scan_work.data =3D NULL;
+			local->scan_dev =3D NULL;
 		} else
 			flush_scheduled_work();
 		break;
@@ -4486,6 +4486,7 @@ struct ieee80211_hw *ieee80211_alloc_hw(
 	INIT_LIST_HEAD(&local->sub_if_list);
=20
         spin_lock_init(&local->generic_lock);
+	INIT_DELAYED_WORK(&local->scan_work, ieee80211_sta_scan_work);
 	init_timer(&local->stat_timer);
 	local->stat_timer.function =3D ieee80211_stat_refresh;
 	local->stat_timer.data =3D (unsigned long) local;
@@ -4686,7 +4687,7 @@ void ieee80211_unregister_hw(struct ieee
=20
 	if (local->stat_time)
 		del_timer_sync(&local->stat_timer);
=2D	if (local->scan_work.data) {
+	if (local->scan_dev) {
 		local->sta_scanning =3D 0;
 		cancel_delayed_work(&local->scan_work);
 		flush_scheduled_work();
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index ef303da..b7b4b35 100644
=2D-- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -240,7 +240,7 @@ struct ieee80211_if_sta {
 		IEEE80211_ASSOCIATE, IEEE80211_ASSOCIATED,
 		IEEE80211_IBSS_SEARCH, IEEE80211_IBSS_JOINED
 	} state;
=2D	struct work_struct work;
+	struct delayed_work work;
 	u8 bssid[ETH_ALEN], prev_bssid[ETH_ALEN];
 	u8 ssid[IEEE80211_MAX_SSID_LEN];
 	size_t ssid_len;
@@ -429,7 +429,8 @@ struct ieee80211_local {
 	int scan_channel_idx;
 	enum { SCAN_SET_CHANNEL, SCAN_SEND_PROBE } scan_state;
 	unsigned long last_scan_completed;
=2D	struct work_struct scan_work;
+	struct delayed_work scan_work;
+	struct net_device *scan_dev;
 	int scan_oper_channel;
 	int scan_oper_channel_val;
 	int scan_oper_power_level;
@@ -638,7 +639,8 @@ int ieee80211_set_compression(struct iee
 			      struct net_device *dev, struct sta_info *sta);
 int ieee80211_init_client(struct net_device *dev);
 /* ieee80211_sta.c */
=2Dvoid ieee80211_sta_work(void *ptr);
+void ieee80211_sta_work(struct work_struct *work);
+void ieee80211_sta_scan_work(struct work_struct *work);
 void ieee80211_sta_rx_mgmt(struct net_device *dev, struct sk_buff *skb,
 			   struct ieee80211_rx_status *rx_status);
 int ieee80211_sta_set_ssid(struct net_device *dev, char *ssid, size_t len);
diff --git a/net/d80211/ieee80211_iface.c b/net/d80211/ieee80211_iface.c
index 3e9d531..288dce5 100644
=2D-- a/net/d80211/ieee80211_iface.c
+++ b/net/d80211/ieee80211_iface.c
@@ -185,7 +185,7 @@ void ieee80211_if_set_type(struct net_de
 		struct ieee80211_if_sta *ifsta;
=20
 		ifsta =3D &sdata->u.sta;
=2D		INIT_WORK(&ifsta->work, ieee80211_sta_work, dev);
+		INIT_DELAYED_WORK(&ifsta->work, ieee80211_sta_work);
=20
 		ifsta->capab =3D WLAN_CAPABILITY_ESS;
 		ifsta->auth_algs =3D IEEE80211_AUTH_ALG_OPEN |
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 04bd5cd..35eb5a2 100644
=2D-- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -1837,10 +1837,11 @@ static void ieee80211_sta_merge_ibss(str
 }
=20
=20
=2Dvoid ieee80211_sta_work(void *ptr)
+void ieee80211_sta_work(struct work_struct *work)
 {
=2D	struct net_device *dev =3D ptr;
=2D	struct ieee80211_sub_if_data *sdata;
+	struct ieee80211_sub_if_data *sdata =3D
+		container_of(work, struct ieee80211_sub_if_data, u.sta.work.work);
+	struct net_device *dev =3D sdata->dev;
 	struct ieee80211_if_sta *ifsta;
=20
 	if (!netif_running(dev))
@@ -2407,7 +2408,7 @@ static int ieee80211_active_scan(struct
 void ieee80211_scan_completed(struct ieee80211_hw *hw)
 {
 	struct ieee80211_local *local =3D hw_to_local(hw);
=2D	struct net_device *dev =3D local->scan_work.data;
+	struct net_device *dev =3D local->scan_dev;
 	struct ieee80211_sub_if_data *sdata =3D IEEE80211_DEV_TO_SUB_IF(dev);
 	union iwreq_data wrqu;
=20
@@ -2428,10 +2429,11 @@ void ieee80211_scan_completed(struct iee
 }
 EXPORT_SYMBOL(ieee80211_scan_completed);
=20
=2Dstatic void ieee80211_sta_scan_work(void *ptr)
+void ieee80211_sta_scan_work(struct work_struct *work)
 {
=2D	struct net_device *dev =3D ptr;
=2D	struct ieee80211_local *local =3D dev->ieee80211_ptr;
+	struct ieee80211_local *local =3D
+		container_of(work, struct ieee80211_local, scan_work.work);
+	struct net_device *dev =3D local->scan_dev;
         struct ieee80211_sub_if_data *sdata =3D IEEE80211_DEV_TO_SUB_IF(de=
v);
 	struct ieee80211_hw_modes *mode;
 	struct ieee80211_channel *chan;
@@ -2514,7 +2516,7 @@ static void ieee80211_sta_scan_work(void
 		if (next_delay)
 			schedule_delayed_work(&local->scan_work, next_delay);
 		else
=2D			schedule_work(&local->scan_work);
+			schedule_work(&local->scan_work.work);
 	}
 }
=20
@@ -2547,7 +2549,7 @@ int ieee80211_sta_req_scan(struct net_de
 	 * scan */
=20
 	if (local->sta_scanning) {
=2D		if (local->scan_work.data =3D=3D dev)
+		if (local->scan_dev =3D=3D dev)
 			return 0;
 		return -EBUSY;
 	}
@@ -2559,7 +2561,7 @@ int ieee80211_sta_req_scan(struct net_de
 					    ssid, ssid_len);
 		if (!rc) {
 			local->sta_scanning =3D 1;
=2D			local->scan_work.data =3D dev;
+			local->scan_dev =3D dev;
 		}
 		return rc;
 	}
@@ -2577,8 +2579,8 @@ int ieee80211_sta_req_scan(struct net_de
 	local->scan_state =3D SCAN_SET_CHANNEL;
 	local->scan_hw_mode_idx =3D 0;
 	local->scan_channel_idx =3D 0;
=2D	INIT_WORK(&local->scan_work, ieee80211_sta_scan_work, dev);
=2D	schedule_work(&local->scan_work);
+	local->scan_dev =3D dev;
+	schedule_work(&local->scan_work.work);
=20
 	return 0;
 }
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index 0c42ae8..1e52e22 100644
=2D-- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -342,9 +342,10 @@ static void sta_info_cleanup(unsigned lo
 }
=20
=20
=2Dstatic void sta_info_proc_add_task(void *data)
+static void sta_info_proc_add_task(struct work_struct *work)
 {
=2D	struct ieee80211_local *local =3D data;
+	struct ieee80211_local *local =3D
+		container_of(work, struct ieee80211_local, sta_proc_add);
 	struct sta_info *sta, *tmp;
=20
 	while (1) {
@@ -395,7 +396,7 @@ void sta_info_init(struct ieee80211_loca
 	local->sta_cleanup.data =3D (unsigned long) local;
 	local->sta_cleanup.function =3D sta_info_cleanup;
=20
=2D	INIT_WORK(&local->sta_proc_add, sta_info_proc_add_task, local);
+	INIT_WORK(&local->sta_proc_add, sta_info_proc_add_task);
 }
=20
 int sta_info_start(struct ieee80211_local *local)

--nextPart1340665.txev2NU5CQ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD4DBQBFfu0uT3Oqt9AH4aERAibsAJj0Rc5lpwY39ck1BGyjZ//Et5tJAJ41YotM
U1MEQHTQbCiPich8+38rCA==
=xiaK
-----END PGP SIGNATURE-----

--nextPart1340665.txev2NU5CQ--
