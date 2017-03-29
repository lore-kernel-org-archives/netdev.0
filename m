From: Sven Eckelmann <sven.eckelmann@openmesh.com>
Subject: Re: [REGRESSION] mac80211: IBSS vif queue stopped when started after 11s vif
Date: Wed, 29 Mar 2017 13:07:32 +0200
Message-ID: <5090047.94hdUy33Q8@bentobox>
References: <1978424.XTv2Qph05K@bentobox> <1490773761.7948.3.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart10574989.eB9QHksnCD"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Michal Kazior <michal.kazior@tieto.com>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:32911 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754184AbdC2LHr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 07:07:47 -0400
Received: by mail-wr0-f181.google.com with SMTP id w43so10108924wrb.0
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 04:07:45 -0700 (PDT)
In-Reply-To: <1490773761.7948.3.camel@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart10574989.eB9QHksnCD
Content-Type: multipart/mixed; boundary="nextPart4361064.gT7rcHJsbo"
Content-Transfer-Encoding: 7Bit

This is a multi-part message in MIME format.

--nextPart4361064.gT7rcHJsbo
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="iso-8859-1"

On Mittwoch, 29. M=E4rz 2017 09:49:21 CEST Johannes Berg wrote:
> > But I could be completely wrong about it. It would therefore be
> > interesting for me to know who would be responsible to start the
> > queues when ieee80211_do_open rejected it for IBSS.
>=20
> Well, once ieee80211_offchannel_return() is called, that should do the
> needful and end up in ieee80211_propagate_queue_wake().
>=20
> Can you check what the IBSS vif's queues are (vif->hw_queue[...])?

I've just dumped the data in ieee80211_propagate_queue_wake and checked whe=
n=20
the function returns. The test patch (sorry, really ugly debug printk stuff=
)=20
is attached. The most interesting part is that

    if (local->ops->wake_tx_queue)
    		return;

evaluates to true. The rest rest of the function is therefore always skippe=
d=20
for ath9k.

This was noticed when looking at the debug output:

    root@lede:/# dmesg|grep ieee80211_propagate_queue_wake
    [   20.865005] ieee80211_propagate_queue_wake:248 queue 00000000
    [   20.870839] ieee80211_propagate_queue_wake:248 queue 00000001
    [   20.876661] ieee80211_propagate_queue_wake:248 queue 00000002
    [   20.882487] ieee80211_propagate_queue_wake:248 queue 00000003
    [   21.794795] ieee80211_propagate_queue_wake:248 queue 00000000
    [   21.800629] ieee80211_propagate_queue_wake:248 queue 00000001
    [   21.806452] ieee80211_propagate_queue_wake:248 queue 00000002
    [   21.812278] ieee80211_propagate_queue_wake:248 queue 00000003
    [   21.830078] ieee80211_propagate_queue_wake:248 queue 00000000
    [   21.835918] ieee80211_propagate_queue_wake:248 queue 00000001
    [   21.841740] ieee80211_propagate_queue_wake:248 queue 00000002
    [   21.847566] ieee80211_propagate_queue_wake:248 queue 00000003
    [   23.320814] ieee80211_propagate_queue_wake:248 queue 00000000
    [   23.326643] ieee80211_propagate_queue_wake:248 queue 00000001
    [   23.332469] ieee80211_propagate_queue_wake:248 queue 00000002
    [   23.338294] ieee80211_propagate_queue_wake:248 queue 00000003
    [   41.930942] ieee80211_propagate_queue_wake:248 queue 00000000
    [   41.940709] ieee80211_propagate_queue_wake:248 queue 00000002
    [   46.949087] ieee80211_propagate_queue_wake:248 queue 00000000
    [   82.999021] ieee80211_propagate_queue_wake:248 queue 00000000

Removing this is enough to fix the problem. And now you will propably say=20
"hey, this is not my code". And this is the reason why I have now CC'ed the=
=20
author of 80a83cfc434b ("mac80211: skip netdev queue control with software=
=20
queuing"). This change in ieee80211_propagate_queue_wake is basically break=
ing=20
the (delayed) startup of the ibss netdev queue [1] when the device was offc=
han=20
during the ieee80211_do_open of the ibss interface.

Not sure whether removing it in ieee80211_propagate_queue_wake will have ot=
her=20
odd side effects with software queuing. Maybe Michal Kazior can tell us if =
it=20
is safe to remove it.

> However, I also don't understand the difference between encrypted and
> unencrypted here.

My best guess is timing. LEDE is not using wpa_supplicant when encryption i=
s=20
disabled.

Kind regards,
	Sven

[1] https://lkml.kernel.org/r/1978424.XTv2Qph05K@bentobox
--nextPart4361064.gT7rcHJsbo
Content-Disposition: attachment; filename="999-test.patch"
Content-Transfer-Encoding: 7Bit
Content-Type: text/x-patch; charset="UTF-8"; name="999-test.patch"

diff --git a/net/mac80211/iface.c b/net/mac80211/iface.c
index 036fa1d..9a1079f 100644
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@ -517,6 +517,10 @@ int ieee80211_do_open(struct wireless_dev *wdev, bool coming_up)
 	u32 changed = 0;
 	int res;
 	u32 hw_reconf_flags = 0;
+	const char *ifname = "unknown";
+
+	if (sdata->dev)
+		ifname = sdata->dev->name;
 
 	switch (sdata->vif.type) {
 	case NL80211_IFTYPE_WDS:
@@ -745,11 +749,14 @@ int ieee80211_do_open(struct wireless_dev *wdev, bool coming_up)
 	if (sdata->vif.type == NL80211_IFTYPE_MONITOR ||
 	    sdata->vif.type == NL80211_IFTYPE_AP_VLAN) {
 		/* XXX: for AP_VLAN, actually track AP queues */
+		
+		printk("%s:%u netif_tx_start_all_queues %s\n", __func__, __LINE__, ifname);
 		netif_tx_start_all_queues(dev);
 	} else if (dev) {
 		unsigned long flags;
 		int n_acs = IEEE80211_NUM_ACS;
 		int ac;
+		int started = 0;
 
 		if (local->hw.queues < IEEE80211_NUM_ACS)
 			n_acs = 1;
@@ -762,11 +769,20 @@ int ieee80211_do_open(struct wireless_dev *wdev, bool coming_up)
 				int ac_queue = sdata->vif.hw_queue[ac];
 
 				if (local->queue_stop_reasons[ac_queue] == 0 &&
-				    skb_queue_empty(&local->pending[ac_queue]))
+				    skb_queue_empty(&local->pending[ac_queue])) {
+		//printk("%s:%u netif_start_subqueue type %u %s\n", __func__, __LINE__, sdata->vif.type, ifname);
 					netif_start_subqueue(dev, ac);
+					started = 1;
+				} else {
+		printk("%s:%u NOT netif_start_subqueue type %u stop_reasons %d queue_empty %d %s\n", __func__, __LINE__, sdata->vif.type, local->queue_stop_reasons[ac_queue], skb_queue_empty(&local->pending[ac_queue]), ifname);
+				}
 			}
+		} else {
+			printk("%s:%u NOT netif_start_subqueue type %u cab_queue %d stop_reasons %d queue_empty %d %s\n", __func__, __LINE__, sdata->vif.type, sdata->vif.cab_queue, local->queue_stop_reasons[sdata->vif.cab_queue], skb_queue_empty(&local->pending[sdata->vif.cab_queue]), ifname);
+
 		}
 		spin_unlock_irqrestore(&local->queue_stop_reason_lock, flags);
+		WARN_ON(started);
 	}
 
 	return 0;
@@ -816,6 +832,10 @@ static void ieee80211_do_stop(struct ieee80211_sub_if_data *sdata,
 	struct cfg80211_chan_def chandef;
 	bool cancel_scan;
 	struct cfg80211_nan_func *func;
+	const char *ifname = "unknown";
+
+	if (sdata->dev)
+		ifname = sdata->dev->name;
 
 	clear_bit(SDATA_STATE_RUNNING, &sdata->state);
 
@@ -826,8 +846,10 @@ static void ieee80211_do_stop(struct ieee80211_sub_if_data *sdata,
 	/*
 	 * Stop TX on this interface first.
 	 */
-	if (sdata->dev)
+	if (sdata->dev) {
+		printk("%s:%u netif_tx_stop_all_queues %s\n", __func__, __LINE__, ifname);
 		netif_tx_stop_all_queues(sdata->dev);
+	}
 
 	ieee80211_roc_purge(local, sdata);
 
diff --git a/net/mac80211/offchannel.c b/net/mac80211/offchannel.c
index fc2a601..6681c5c 100644
--- a/net/mac80211/offchannel.c
+++ b/net/mac80211/offchannel.c
@@ -118,6 +118,7 @@ void ieee80211_offchannel_stop_vifs(struct ieee80211_local *local)
 	 * Stop queues and transmit all frames queued by the driver
 	 * before sending nullfunc to enable powersave at the AP.
 	 */
+	printk("%s:%u ieee80211_stop_queues_by_reason\n", __func__, __LINE__);
 	ieee80211_stop_queues_by_reason(&local->hw, IEEE80211_MAX_QUEUE_MAP,
 					IEEE80211_QUEUE_STOP_REASON_OFFCHANNEL,
 					false);
@@ -183,6 +184,7 @@ void ieee80211_offchannel_return(struct ieee80211_local *local)
 	}
 	mutex_unlock(&local->iflist_mtx);
 
+	printk("%s:%u ieee80211_offchannel_return\n", __func__, __LINE__);
 	ieee80211_wake_queues_by_reason(&local->hw, IEEE80211_MAX_QUEUE_MAP,
 					IEEE80211_QUEUE_STOP_REASON_OFFCHANNEL,
 					false);
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 73069f9..8bb0853 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -243,10 +243,15 @@ void ieee80211_propagate_queue_wake(struct ieee80211_local *local, int queue)
 {
 	struct ieee80211_sub_if_data *sdata;
 	int n_acs = IEEE80211_NUM_ACS;
+	const char *ifname = "unknown";
+
+	printk("%s:%u queue %08x\n", __func__, __LINE__, queue);
 
 	if (local->ops->wake_tx_queue)
 		return;
 
+	printk("%s:%u queue %08x\n", __func__, __LINE__, queue);
+
 	if (local->hw.queues < IEEE80211_NUM_ACS)
 		n_acs = 1;
 
@@ -256,13 +261,24 @@ void ieee80211_propagate_queue_wake(struct ieee80211_local *local, int queue)
 		if (!sdata->dev)
 			continue;
 
+		ifname = sdata->dev->name;
+
+		printk("%s:%u %s queue %08x\n", __func__, __LINE__, ifname, queue);
+
 		if (sdata->vif.cab_queue != IEEE80211_INVAL_HW_QUEUE &&
 		    local->queue_stop_reasons[sdata->vif.cab_queue] != 0)
 			continue;
 
+
+		printk("%s:%u %s\n", __func__, __LINE__, ifname);
+
 		for (ac = 0; ac < n_acs; ac++) {
 			int ac_queue = sdata->vif.hw_queue[ac];
 
+			printk("%s:%u %s queue %08x sdata->vif.hw_queue[ac] %08x\n", __func__, __LINE__, ifname, queue, ac_queue);
+			printk("%s:%u %s queue %08x local->queue_stop_reasons[ac_queue] %08x\n", __func__, __LINE__, ifname, queue, local->queue_stop_reasons[ac_queue]);
+			printk("%s:%u %s queue %08x skb_queue_empty(...) %08x\n", __func__, __LINE__, ifname, queue, skb_queue_empty(&local->pending[ac_queue]));
+
 			if (ac_queue == queue ||
 			    (sdata->vif.cab_queue == queue &&
 			     local->queue_stop_reasons[ac_queue] == 0 &&

--nextPart4361064.gT7rcHJsbo--

--nextPart10574989.eB9QHksnCD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEF10rh2Elc9zjMuACXYcKB8Eme0YFAljblXQACgkQXYcKB8Em
e0ZtchAAyY80a6mKUIoZW9OKM3XxuHujKdzfwrlVpRl+pb1AnHaAqDQS0LkP1oHZ
EX2brcl8n0aXNoWxVOjue0jcMxEEi8x37q0bFFbrzUPb+YDFcVh+oCPqbybV5pr7
/ZDRGEGJ9QFrSBG8sugZa3em/7XCYMejsKqLJW4jc0ZYwHtbAkN5dSR9CKYd4eUt
jMkTkV6hScKJq6Kzi2oTpLGujASGgdckiYyqiyozZwZPIhr+IAEqsJP+LTvwcKPV
YH5BWsxGwhrev4IQHR8xna56O7TPdZwCmxPQeAEN41FPDSU+zEBkx1KbV/fjnTDB
qfRtiHuAdUGmBNLtuWirK9eQYk7dsfkhAsEQ8G8KG1AfC9B0ySdaIPJfU5lBsgmf
TcpMQ5z7d/5qbDjACLrcYluocSiS4cKFfQAullXQR4UEg8r9WJd/HKgOIvwine7g
tHiBYCK1mxDFTw81XZb+YW/IJKbj5mCzaTjakyEo6QQ4Yx5eJSCByShEbZAWwAim
2tikrxKN/8LydLY3D7UUZlpmYXoIJPywHVN8Z+4Ik/v1fl2buvv4ZeiI3yk2Sue7
TQfSXCorffiSghwDzEbRY7I0Sc58HahWXHldVO6hyhb3jzCQbZkIyXwHoLMiXYnU
PjGkXsYHGLP4rr3BTfDBNak2hI39le44WckZgObbvrbdw6W4Rag=
=+rNn
-----END PGP SIGNATURE-----

--nextPart10574989.eB9QHksnCD--
