From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-02-08
Date: Wed, 8 Feb 2012 15:37:02 -0500
Message-ID: <20120208203702.GE2929@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="rS8CxjVDS/+yyDmU"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42781 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956Ab2BHUqf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 15:46:35 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--rS8CxjVDS/+yyDmU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 7a73b08b50b075b114d0f608099e4634f9c73ae7

Dave,

This is a batch of fixes intended for 3.3.

Included is a fix for an association failure bug with mwifiex, and a fix
for a NULL pointer deref in that same driver.  There is also an ath9k
fix for a WEP-related regression, and another ath9k fix for an RTS/CTS
timeout regression.  A third ath9k fix address an oops during driver
initialization.  Also included is a zd1211rw fix for an issue where the
firmware would corrupt the duration_id setting and cause devices to be
unable to connect to zd1211rw-based APs.  A fix from me to reduce some
log spam from ath9k rounds-out the bunch.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit a1728800bed3b93b231d99e97c756f622b9991c2:

  net: enable TC35815 for MIPS again (2012-02-07 13:40:44 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

Amitkumar Karwar (2):
      mwifiex: handle association failure case correctly
      mwifiex: add NULL checks in driver unload path

Felix Fietkau (2):
      ath9k: fix a WEP crypto related regression
      ath9k_hw: fix a RTS/CTS timeout regression

Henrik Rydberg (1):
      bcma: don't fail for bad SPROM CRC

John W. Linville (2):
      ath9k: use WARN_ON_ONCE in ath_rc_get_highest_rix
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Mohammed Shafi Shajakhan (1):
      ath9k: Fix kernel panic during driver initilization

Tomas Vanek (1):
      zd1211rw: firmware needs duration_id set to zero for non-pspoll frames

 drivers/bcma/main.c                      |    4 +---
 drivers/net/wireless/ath/ath9k/hw.c      |    7 +++++--
 drivers/net/wireless/ath/ath9k/init.c    |    9 +++++----
 drivers/net/wireless/ath/ath9k/rc.c      |    2 +-
 drivers/net/wireless/ath/ath9k/recv.c    |    8 ++++++++
 drivers/net/wireless/mwifiex/init.c      |    3 ++-
 drivers/net/wireless/mwifiex/main.c      |   12 ++++++++----
 drivers/net/wireless/mwifiex/sta_ioctl.c |    8 +++++++-
 drivers/net/wireless/zd1211rw/zd_mac.c   |    8 ++++++++
 9 files changed, 45 insertions(+), 16 deletions(-)

diff --git a/drivers/bcma/main.c b/drivers/bcma/main.c
index febbc0a..ec31f7d 100644
--- a/drivers/bcma/main.c
+++ b/drivers/bcma/main.c
@@ -169,10 +169,8 @@ int bcma_bus_register(struct bcma_bus *bus)
 	err =3D bcma_sprom_get(bus);
 	if (err =3D=3D -ENOENT) {
 		pr_err("No SPROM available\n");
-	} else if (err) {
+	} else if (err)
 		pr_err("Failed to get SPROM: %d\n", err);
-		return -ENOENT;
-	}
=20
 	/* Register found cores */
 	bcma_register_cores(bus);
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath=
/ath9k/hw.c
index ee77595..87db1ee 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -1037,13 +1037,16 @@ void ath9k_hw_init_global_settings(struct ath_hw *a=
h)
=20
 	/*
 	 * Workaround for early ACK timeouts, add an offset to match the
-	 * initval's 64us ack timeout value.
+	 * initval's 64us ack timeout value. Use 48us for the CTS timeout.
 	 * This was initially only meant to work around an issue with delayed
 	 * BA frames in some implementations, but it has been found to fix ACK
 	 * timeout issues in other cases as well.
 	 */
-	if (conf->channel && conf->channel->band =3D=3D IEEE80211_BAND_2GHZ)
+	if (conf->channel && conf->channel->band =3D=3D IEEE80211_BAND_2GHZ) {
 		acktimeout +=3D 64 - sifstime - ah->slottime;
+		ctstimeout +=3D 48 - sifstime - ah->slottime;
+	}
+
=20
 	ath9k_hw_set_sifs_time(ah, sifstime);
 	ath9k_hw_setslottime(ah, slottime);
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/a=
th/ath9k/init.c
index abf9435..53a005d 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -822,6 +822,11 @@ int ath9k_init_device(u16 devid, struct ath_softc *sc,
 		ARRAY_SIZE(ath9k_tpt_blink));
 #endif
=20
+	INIT_WORK(&sc->hw_reset_work, ath_reset_work);
+	INIT_WORK(&sc->hw_check_work, ath_hw_check);
+	INIT_WORK(&sc->paprd_work, ath_paprd_calibrate);
+	INIT_DELAYED_WORK(&sc->hw_pll_work, ath_hw_pll_work);
+
 	/* Register with mac80211 */
 	error =3D ieee80211_register_hw(hw);
 	if (error)
@@ -840,10 +845,6 @@ int ath9k_init_device(u16 devid, struct ath_softc *sc,
 			goto error_world;
 	}
=20
-	INIT_WORK(&sc->hw_reset_work, ath_reset_work);
-	INIT_WORK(&sc->hw_check_work, ath_hw_check);
-	INIT_WORK(&sc->paprd_work, ath_paprd_calibrate);
-	INIT_DELAYED_WORK(&sc->hw_pll_work, ath_hw_pll_work);
 	sc->last_rssi =3D ATH_RSSI_DUMMY_MARKER;
=20
 	ath_init_leds(sc);
diff --git a/drivers/net/wireless/ath/ath9k/rc.c b/drivers/net/wireless/ath=
/ath9k/rc.c
index b3c3798..635b592 100644
--- a/drivers/net/wireless/ath/ath9k/rc.c
+++ b/drivers/net/wireless/ath/ath9k/rc.c
@@ -694,7 +694,7 @@ static u8 ath_rc_get_highest_rix(struct ath_softc *sc,
 		return rate;
=20
 	/* This should not happen */
-	WARN_ON(1);
+	WARN_ON_ONCE(1);
=20
 	rate =3D ath_rc_priv->valid_rate_index[0];
=20
diff --git a/drivers/net/wireless/ath/ath9k/recv.c b/drivers/net/wireless/a=
th/ath9k/recv.c
index 0e666fb..7e1a91a 100644
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@ -822,6 +822,14 @@ static bool ath9k_rx_accept(struct ath_common *common,
 		(ATH9K_RXERR_DECRYPT | ATH9K_RXERR_CRC | ATH9K_RXERR_MIC |
 		 ATH9K_RXERR_KEYMISS));
=20
+	/*
+	 * Key miss events are only relevant for pairwise keys where the
+	 * descriptor does contain a valid key index. This has been observed
+	 * mostly with CCMP encryption.
+	 */
+	if (rx_stats->rs_keyix =3D=3D ATH9K_RXKEYIX_INVALID)
+		rx_stats->rs_status &=3D ~ATH9K_RXERR_KEYMISS;
+
 	if (!rx_stats->rs_datalen)
 		return false;
         /*
diff --git a/drivers/net/wireless/mwifiex/init.c b/drivers/net/wireless/mwi=
fiex/init.c
index e05b417..1d0ec57 100644
--- a/drivers/net/wireless/mwifiex/init.c
+++ b/drivers/net/wireless/mwifiex/init.c
@@ -382,7 +382,8 @@ mwifiex_free_adapter(struct mwifiex_adapter *adapter)
=20
 	adapter->if_ops.cleanup_if(adapter);
=20
-	dev_kfree_skb_any(adapter->sleep_cfm);
+	if (adapter->sleep_cfm)
+		dev_kfree_skb_any(adapter->sleep_cfm);
 }
=20
 /*
diff --git a/drivers/net/wireless/mwifiex/main.c b/drivers/net/wireless/mwi=
fiex/main.c
index 84be196..b728f54 100644
--- a/drivers/net/wireless/mwifiex/main.c
+++ b/drivers/net/wireless/mwifiex/main.c
@@ -822,7 +822,9 @@ int mwifiex_remove_card(struct mwifiex_adapter *adapter=
, struct semaphore *sem)
 			continue;
=20
 		rtnl_lock();
-		mwifiex_del_virtual_intf(priv->wdev->wiphy, priv->netdev);
+		if (priv->wdev && priv->netdev)
+			mwifiex_del_virtual_intf(priv->wdev->wiphy,
+						 priv->netdev);
 		rtnl_unlock();
 	}
=20
@@ -830,9 +832,11 @@ int mwifiex_remove_card(struct mwifiex_adapter *adapte=
r, struct semaphore *sem)
 	if (!priv)
 		goto exit_remove;
=20
-	wiphy_unregister(priv->wdev->wiphy);
-	wiphy_free(priv->wdev->wiphy);
-	kfree(priv->wdev);
+	if (priv->wdev) {
+		wiphy_unregister(priv->wdev->wiphy);
+		wiphy_free(priv->wdev->wiphy);
+		kfree(priv->wdev);
+	}
=20
 	mwifiex_terminate_workqueue(adapter);
=20
diff --git a/drivers/net/wireless/mwifiex/sta_ioctl.c b/drivers/net/wireles=
s/mwifiex/sta_ioctl.c
index 470ca75..b0fbf5d 100644
--- a/drivers/net/wireless/mwifiex/sta_ioctl.c
+++ b/drivers/net/wireless/mwifiex/sta_ioctl.c
@@ -54,7 +54,7 @@ int mwifiex_copy_mcast_addr(struct mwifiex_multicast_list=
 *mlist,
 int mwifiex_wait_queue_complete(struct mwifiex_adapter *adapter)
 {
 	bool cancel_flag =3D false;
-	int status =3D adapter->cmd_wait_q.status;
+	int status;
 	struct cmd_ctrl_node *cmd_queued;
=20
 	if (!adapter->cmd_queued)
@@ -79,6 +79,8 @@ int mwifiex_wait_queue_complete(struct mwifiex_adapter *a=
dapter)
 		mwifiex_cancel_pending_ioctl(adapter);
 		dev_dbg(adapter->dev, "cmd cancel\n");
 	}
+
+	status =3D adapter->cmd_wait_q.status;
 	adapter->cmd_wait_q.status =3D 0;
=20
 	return status;
@@ -240,6 +242,8 @@ int mwifiex_bss_start(struct mwifiex_private *priv, str=
uct cfg80211_bss *bss,
=20
 		if (!netif_queue_stopped(priv->netdev))
 			mwifiex_stop_net_dev_queue(priv->netdev, adapter);
+		if (netif_carrier_ok(priv->netdev))
+			netif_carrier_off(priv->netdev);
=20
 		/* Clear any past association response stored for
 		 * application retrieval */
@@ -271,6 +275,8 @@ int mwifiex_bss_start(struct mwifiex_private *priv, str=
uct cfg80211_bss *bss,
=20
 		if (!netif_queue_stopped(priv->netdev))
 			mwifiex_stop_net_dev_queue(priv->netdev, adapter);
+		if (netif_carrier_ok(priv->netdev))
+			netif_carrier_off(priv->netdev);
=20
 		if (!ret) {
 			dev_dbg(adapter->dev, "info: network found in scan"
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/=
zd1211rw/zd_mac.c
index 0a70149..98a574a 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -866,6 +866,14 @@ static int fill_ctrlset(struct zd_mac *mac,
=20
 	ZD_ASSERT(frag_len <=3D 0xffff);
=20
+	/*
+	 * Firmware computes the duration itself (for all frames except PSPoll)
+	 * and needs the field set to 0 at input, otherwise firmware messes up
+	 * duration_id and sets bits 14 and 15 on.
+	 */
+	if (!ieee80211_is_pspoll(hdr->frame_control))
+		hdr->duration_id =3D 0;
+
 	txrate =3D ieee80211_get_tx_rate(mac->hw, info);
=20
 	cs->modulation =3D txrate->hw_value;
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--rS8CxjVDS/+yyDmU
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPMtzuAAoJEJctW/TcYTgGhrIP/i3hwdDSFnyEtQfz8tU7uRSn
uqXzkz1YbcVUFmEcqynnsB0C+1r1jgM5gaYf/AY2SWSOmLKvd7d6ebuXRnEwQxFg
pH9k0tKOjC3XGmqk39V2f4rDF9jh7Li1VnXnP3jP/EeP5i4sIaOkDCIRXHjAjtp7
JRnDhphacUueCvWaGXtKwJftnkXbahMHeNDJTX6QDaxfG+qJEYS5TW7FSn7kavcM
EkNBia8KltnD+dEoRdEPuy7BCRapP5HdMcTByUWjxT+rgR+62bOVmCWSON88RBu+
kblQjH5KrHbrG1jEyKT1iE53vrYl3Mc6rf4bfsnwX1erqlC7u2XKoY12X8wmGE3F
HyETBNajhLgEzgpJfaYqBO+qC/HkAFIkkFWq3yBozrzTj9IwSOMQIXUjnj2PH3vr
xAfUopyA6yPxtw0gRIsQGLqgTqaGoQgI0EKRPLtsyVHoBdwkkobLHDcyl/mfsrO9
8RUI/sSccJ25yfTwKHlmRokW/V5f7HJybXBzxh4vVv1Uo8LJ4BnIpb0Q1n+e52b0
qT3O8L81fobBYBqDmBbMqjZRcDMqcDoVZh4hSdHigEADEv2dEpmo3AUIPbvPIB0g
2UqponIdhj1BGrAQgcyYH2qs9fDIXBie+WfddCEMtmFRKoCM6erVlvVcy0PYAcBF
WzpDyQqU1XC5JOf1TeHw
=6V+s
-----END PGP SIGNATURE-----

--rS8CxjVDS/+yyDmU--
