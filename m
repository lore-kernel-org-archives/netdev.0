From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-04-10
Date: Thu, 10 Apr 2014 13:45:47 -0400
Message-ID: <20140410174547.GC13595@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="+QahgC5+KEYLbs62"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--+QahgC5+KEYLbs62
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.15 stream!

Chun-Yeow Yeoh gives us an ath9k_htc fix so that mac80211 can report
last_tx_rate correctly for those devices..

Fariya Fatima has a number of small fixes for things identified by
the static analysis folks in the new rsi driver.

Felix Fietkau brings an ath9k fix to better support some older chips,
and a fix for a scheduling while atomic bug introduced by an earlier
patch.

Janusz Dziedzic produced an ath9k fix to only enable DFS when a
related build option is selected.

Paul Bolle removes some dead code in rtlwifi.

Rafa=C5=82 Mi=C5=82ecki fixes some b43 code that was accessing some registe=
rs
with operations for the wrong register width.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit f34c4a35d87949fbb0e0f31eba3c054e9f8199ba:

  l2tp: take PMTU from tunnel UDP socket (2014-04-09 15:24:38 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 029d3ac9722d23e4f3b65656878cb3e4d9e280d4:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2014-04-10 09:58:06 -0400)

----------------------------------------------------------------

Chun-Yeow Yeoh (1):
      ath9k_htc: set IEEE80211_TX_STAT_AMPDU for acked aggregated frames

Fariya Fatima (6):
      rsi: Potential null pointer derefernce issue fixed.
      rsi: Fixed signedness bug reported by static code analyzer.
      rsi: Fixed issue relating to variable de-referenced before check 'ada=
pter'
      rsi: Fixed issue relating to return value.
      rsi: Fixed issue relating to index of q_num.
      rsi: Fixed issue relating to doing dma on stack error.

Felix Fietkau (2):
      ath9k_hw: reduce ANI firstep range for older chips
      ath9k: fix a scheduling while atomic bug in CSA handling

Janusz Dziedzic (1):
      ath9k: Enable DFS only when ATH9K_DFS_CERTIFIED

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Paul Bolle (1):
      rtlwifi: btcoexist: remove undefined Kconfig macros

Rafa=C5=82 Mi=C5=82ecki (1):
      b43: Fix machine check error due to improper access of B43_MMIO_PSM_P=
HY_HDR

 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |  4 +--
 drivers/net/wireless/ath/ath9k/beacon.c            |  7 ++---
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |  5 +++-
 drivers/net/wireless/ath/ath9k/init.c              |  2 ++
 drivers/net/wireless/b43/phy_n.c                   | 14 ++++-----
 drivers/net/wireless/rsi/rsi_91x_core.c            |  6 ++--
 drivers/net/wireless/rsi/rsi_91x_debugfs.c         | 35 ++++++++++--------=
----
 drivers/net/wireless/rsi/rsi_91x_mgmt.c            |  8 +++--
 drivers/net/wireless/rsi/rsi_91x_sdio.c            |  5 ++--
 drivers/net/wireless/rsi/rsi_91x_sdio_ops.c        |  6 ++--
 drivers/net/wireless/rsi/rsi_91x_usb.c             | 26 +++++++++++-----
 .../net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c  | 10 -------
 12 files changed, 66 insertions(+), 62 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar5008_phy.c b/drivers/net/wire=
less/ath/ath9k/ar5008_phy.c
index 3b3e91057a4c..00fb8badbacc 100644
--- a/drivers/net/wireless/ath/ath9k/ar5008_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar5008_phy.c
@@ -1004,11 +1004,9 @@ static bool ar5008_hw_ani_control_new(struct ath_hw =
*ah,
 	case ATH9K_ANI_FIRSTEP_LEVEL:{
 		u32 level =3D param;
=20
-		value =3D level * 2;
+		value =3D level;
 		REG_RMW_FIELD(ah, AR_PHY_FIND_SIG,
 			      AR_PHY_FIND_SIG_FIRSTEP, value);
-		REG_RMW_FIELD(ah, AR_PHY_FIND_SIG_LOW,
-			      AR_PHY_FIND_SIG_FIRSTEP_LOW, value);
=20
 		if (level !=3D aniState->firstepLevel) {
 			ath_dbg(common, ANI,
diff --git a/drivers/net/wireless/ath/ath9k/beacon.c b/drivers/net/wireless=
/ath/ath9k/beacon.c
index 471e0f624e81..bd9e634879e6 100644
--- a/drivers/net/wireless/ath/ath9k/beacon.c
+++ b/drivers/net/wireless/ath/ath9k/beacon.c
@@ -312,10 +312,9 @@ static void ath9k_csa_update_vif(void *data, u8 *mac, =
struct ieee80211_vif *vif)
=20
 void ath9k_csa_update(struct ath_softc *sc)
 {
-	ieee80211_iterate_active_interfaces(sc->hw,
-					    IEEE80211_IFACE_ITER_NORMAL,
-					    ath9k_csa_update_vif,
-					    sc);
+	ieee80211_iterate_active_interfaces_atomic(sc->hw,
+						   IEEE80211_IFACE_ITER_NORMAL,
+						   ath9k_csa_update_vif, sc);
 }
=20
 void ath9k_beacon_tasklet(unsigned long data)
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c b/drivers/net/wi=
reless/ath/ath9k/htc_drv_txrx.c
index e8149e3dbdd5..289f3d8924b5 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_txrx.c
@@ -471,8 +471,11 @@ static void ath9k_htc_tx_process(struct ath9k_htc_priv=
 *priv,
 	if (!txok || !vif || !txs)
 		goto send_mac80211;
=20
-	if (txs->ts_flags & ATH9K_HTC_TXSTAT_ACK)
+	if (txs->ts_flags & ATH9K_HTC_TXSTAT_ACK) {
 		tx_info->flags |=3D IEEE80211_TX_STAT_ACK;
+		if (tx_info->flags & IEEE80211_TX_CTL_AMPDU)
+			tx_info->flags |=3D IEEE80211_TX_STAT_AMPDU;
+	}
=20
 	if (txs->ts_flags & ATH9K_HTC_TXSTAT_FILT)
 		tx_info->flags |=3D IEEE80211_TX_STAT_TX_FILTERED;
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/a=
th/ath9k/init.c
index c0a4e866edca..cbbb02a6b13b 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -670,6 +670,7 @@ static const struct ieee80211_iface_combination if_comb=
[] =3D {
 		.num_different_channels =3D 1,
 		.beacon_int_infra_match =3D true,
 	},
+#ifdef CONFIG_ATH9K_DFS_CERTIFIED
 	{
 		.limits =3D if_dfs_limits,
 		.n_limits =3D ARRAY_SIZE(if_dfs_limits),
@@ -679,6 +680,7 @@ static const struct ieee80211_iface_combination if_comb=
[] =3D {
 		.radar_detect_widths =3D	BIT(NL80211_CHAN_WIDTH_20_NOHT) |
 					BIT(NL80211_CHAN_WIDTH_20),
 	}
+#endif
 };
=20
 static void ath9k_set_hw_capab(struct ath_softc *sc, struct ieee80211_hw *=
hw)
diff --git a/drivers/net/wireless/b43/phy_n.c b/drivers/net/wireless/b43/ph=
y_n.c
index 05ee7f10cc8f..24ccbe96e0c8 100644
--- a/drivers/net/wireless/b43/phy_n.c
+++ b/drivers/net/wireless/b43/phy_n.c
@@ -5176,22 +5176,22 @@ static void b43_nphy_channel_setup(struct b43_wldev=
 *dev,
 	int ch =3D new_channel->hw_value;
=20
 	u16 old_band_5ghz;
-	u32 tmp32;
+	u16 tmp16;
=20
 	old_band_5ghz =3D
 		b43_phy_read(dev, B43_NPHY_BANDCTL) & B43_NPHY_BANDCTL_5GHZ;
 	if (new_channel->band =3D=3D IEEE80211_BAND_5GHZ && !old_band_5ghz) {
-		tmp32 =3D b43_read32(dev, B43_MMIO_PSM_PHY_HDR);
-		b43_write32(dev, B43_MMIO_PSM_PHY_HDR, tmp32 | 4);
+		tmp16 =3D b43_read16(dev, B43_MMIO_PSM_PHY_HDR);
+		b43_write16(dev, B43_MMIO_PSM_PHY_HDR, tmp16 | 4);
 		b43_phy_set(dev, B43_PHY_B_BBCFG, 0xC000);
-		b43_write32(dev, B43_MMIO_PSM_PHY_HDR, tmp32);
+		b43_write16(dev, B43_MMIO_PSM_PHY_HDR, tmp16);
 		b43_phy_set(dev, B43_NPHY_BANDCTL, B43_NPHY_BANDCTL_5GHZ);
 	} else if (new_channel->band =3D=3D IEEE80211_BAND_2GHZ && old_band_5ghz)=
 {
 		b43_phy_mask(dev, B43_NPHY_BANDCTL, ~B43_NPHY_BANDCTL_5GHZ);
-		tmp32 =3D b43_read32(dev, B43_MMIO_PSM_PHY_HDR);
-		b43_write32(dev, B43_MMIO_PSM_PHY_HDR, tmp32 | 4);
+		tmp16 =3D b43_read16(dev, B43_MMIO_PSM_PHY_HDR);
+		b43_write16(dev, B43_MMIO_PSM_PHY_HDR, tmp16 | 4);
 		b43_phy_mask(dev, B43_PHY_B_BBCFG, 0x3FFF);
-		b43_write32(dev, B43_MMIO_PSM_PHY_HDR, tmp32);
+		b43_write16(dev, B43_MMIO_PSM_PHY_HDR, tmp16);
 	}
=20
 	b43_chantab_phy_upload(dev, e);
diff --git a/drivers/net/wireless/rsi/rsi_91x_core.c b/drivers/net/wireless=
/rsi/rsi_91x_core.c
index e89535e86caf..1a8d32138593 100644
--- a/drivers/net/wireless/rsi/rsi_91x_core.c
+++ b/drivers/net/wireless/rsi/rsi_91x_core.c
@@ -102,10 +102,10 @@ static u8 rsi_core_determine_hal_queue(struct rsi_com=
mon *common)
 	}
=20
 get_queue_num:
-	q_num =3D 0;
 	recontend_queue =3D false;
=20
 	q_num =3D rsi_determine_min_weight_queue(common);
+
 	q_len =3D skb_queue_len(&common->tx_queue[ii]);
 	ii =3D q_num;
=20
@@ -118,7 +118,9 @@ get_queue_num:
 		}
 	}
=20
-	common->tx_qinfo[q_num].pkt_contended =3D 0;
+	if (q_num < NUM_EDCA_QUEUES)
+		common->tx_qinfo[q_num].pkt_contended =3D 0;
+
 	/* Adjust the back off values for all queues again */
 	recontend_queue =3D rsi_recalculate_weights(common);
=20
diff --git a/drivers/net/wireless/rsi/rsi_91x_debugfs.c b/drivers/net/wirel=
ess/rsi/rsi_91x_debugfs.c
index 7e4ef4554411..c466246a323f 100644
--- a/drivers/net/wireless/rsi/rsi_91x_debugfs.c
+++ b/drivers/net/wireless/rsi/rsi_91x_debugfs.c
@@ -289,32 +289,29 @@ int rsi_init_dbgfs(struct rsi_hw *adapter)
 	const struct rsi_dbg_files *files;
=20
 	dev_dbgfs =3D kzalloc(sizeof(*dev_dbgfs), GFP_KERNEL);
+	if (!dev_dbgfs)
+		return -ENOMEM;
+
 	adapter->dfsentry =3D dev_dbgfs;
=20
 	snprintf(devdir, sizeof(devdir), "%s",
 		 wiphy_name(adapter->hw->wiphy));
-	dev_dbgfs->subdir =3D debugfs_create_dir(devdir, NULL);
=20
-	if (IS_ERR(dev_dbgfs->subdir)) {
-		if (dev_dbgfs->subdir =3D=3D ERR_PTR(-ENODEV))
-			rsi_dbg(ERR_ZONE,
-				"%s:Debugfs has not been mounted\n", __func__);
-		else
-			rsi_dbg(ERR_ZONE, "debugfs:%s not created\n", devdir);
+	dev_dbgfs->subdir =3D debugfs_create_dir(devdir, NULL);
=20
-		adapter->dfsentry =3D NULL;
+	if (!dev_dbgfs->subdir) {
 		kfree(dev_dbgfs);
-		return (int)PTR_ERR(dev_dbgfs->subdir);
-	} else {
-		for (ii =3D 0; ii < adapter->num_debugfs_entries; ii++) {
-			files =3D &dev_debugfs_files[ii];
-			dev_dbgfs->rsi_files[ii] =3D
-			debugfs_create_file(files->name,
-					    files->perms,
-					    dev_dbgfs->subdir,
-					    common,
-					    &files->fops);
-		}
+		return -ENOMEM;
+	}
+
+	for (ii =3D 0; ii < adapter->num_debugfs_entries; ii++) {
+		files =3D &dev_debugfs_files[ii];
+		dev_dbgfs->rsi_files[ii] =3D
+		debugfs_create_file(files->name,
+				    files->perms,
+				    dev_dbgfs->subdir,
+				    common,
+				    &files->fops);
 	}
 	return 0;
 }
diff --git a/drivers/net/wireless/rsi/rsi_91x_mgmt.c b/drivers/net/wireless=
/rsi/rsi_91x_mgmt.c
index 2361a6849ad7..73694295648f 100644
--- a/drivers/net/wireless/rsi/rsi_91x_mgmt.c
+++ b/drivers/net/wireless/rsi/rsi_91x_mgmt.c
@@ -738,7 +738,7 @@ int rsi_hal_load_key(struct rsi_common *common,
  *
  * Return: 0 on success, corresponding error code on failure.
  */
-static u8 rsi_load_bootup_params(struct rsi_common *common)
+static int rsi_load_bootup_params(struct rsi_common *common)
 {
 	struct sk_buff *skb;
 	struct rsi_boot_params *boot_params;
@@ -1272,6 +1272,7 @@ int rsi_mgmt_pkt_recv(struct rsi_common *common, u8 *=
msg)
 {
 	s32 msg_len =3D (le16_to_cpu(*(__le16 *)&msg[0]) & 0x0fff);
 	u16 msg_type =3D (msg[2]);
+	int ret;
=20
 	rsi_dbg(FSM_ZONE, "%s: Msg Len: %d, Msg Type: %4x\n",
 		__func__, msg_len, msg_type);
@@ -1284,8 +1285,9 @@ int rsi_mgmt_pkt_recv(struct rsi_common *common, u8 *=
msg)
 		if (common->fsm_state =3D=3D FSM_CARD_NOT_READY) {
 			rsi_set_default_parameters(common);
=20
-			if (rsi_load_bootup_params(common))
-				return -ENOMEM;
+			ret =3D rsi_load_bootup_params(common);
+			if (ret)
+				return ret;
 			else
 				common->fsm_state =3D FSM_BOOT_PARAMS_SENT;
 		} else {
diff --git a/drivers/net/wireless/rsi/rsi_91x_sdio.c b/drivers/net/wireless=
/rsi/rsi_91x_sdio.c
index 852453f386e2..2e39d38d6a9e 100644
--- a/drivers/net/wireless/rsi/rsi_91x_sdio.c
+++ b/drivers/net/wireless/rsi/rsi_91x_sdio.c
@@ -756,12 +756,13 @@ fail:
 static void rsi_disconnect(struct sdio_func *pfunction)
 {
 	struct rsi_hw *adapter =3D sdio_get_drvdata(pfunction);
-	struct rsi_91x_sdiodev *dev =3D
-		(struct rsi_91x_sdiodev *)adapter->rsi_dev;
+	struct rsi_91x_sdiodev *dev;
=20
 	if (!adapter)
 		return;
=20
+	dev =3D (struct rsi_91x_sdiodev *)adapter->rsi_dev;
+
 	dev->write_fail =3D 2;
 	rsi_mac80211_detach(adapter);
=20
diff --git a/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c b/drivers/net/wire=
less/rsi/rsi_91x_sdio_ops.c
index f1cb99cafed8..20d11ccfffe3 100644
--- a/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c
+++ b/drivers/net/wireless/rsi/rsi_91x_sdio_ops.c
@@ -247,7 +247,7 @@ static int rsi_process_pkt(struct rsi_common *common)
 	if (!common->rx_data_pkt) {
 		rsi_dbg(ERR_ZONE, "%s: Failed in memory allocation\n",
 			__func__);
-		return -1;
+		return -ENOMEM;
 	}
=20
 	status =3D rsi_sdio_host_intf_read_pkt(adapter,
@@ -260,12 +260,10 @@ static int rsi_process_pkt(struct rsi_common *common)
 	}
=20
 	status =3D rsi_read_pkt(common, rcv_pkt_len);
-	kfree(common->rx_data_pkt);
-	return status;
=20
 fail:
 	kfree(common->rx_data_pkt);
-	return -1;
+	return status;
 }
=20
 /**
diff --git a/drivers/net/wireless/rsi/rsi_91x_usb.c b/drivers/net/wireless/=
rsi/rsi_91x_usb.c
index bb1bf96670eb..4c46e5631e2f 100644
--- a/drivers/net/wireless/rsi/rsi_91x_usb.c
+++ b/drivers/net/wireless/rsi/rsi_91x_usb.c
@@ -154,24 +154,30 @@ static int rsi_usb_reg_read(struct usb_device *usbdev,
 			    u16 *value,
 			    u16 len)
 {
-	u8 temp_buf[4];
-	int status =3D 0;
+	u8 *buf;
+	int status =3D -ENOMEM;
+
+	buf  =3D kmalloc(0x04, GFP_KERNEL);
+	if (!buf)
+		return status;
=20
 	status =3D usb_control_msg(usbdev,
 				 usb_rcvctrlpipe(usbdev, 0),
 				 USB_VENDOR_REGISTER_READ,
 				 USB_TYPE_VENDOR,
 				 ((reg & 0xffff0000) >> 16), (reg & 0xffff),
-				 (void *)temp_buf,
+				 (void *)buf,
 				 len,
 				 HZ * 5);
=20
-	*value =3D (temp_buf[0] | (temp_buf[1] << 8));
+	*value =3D (buf[0] | (buf[1] << 8));
 	if (status < 0) {
 		rsi_dbg(ERR_ZONE,
 			"%s: Reg read failed with error code :%d\n",
 			__func__, status);
 	}
+	kfree(buf);
+
 	return status;
 }
=20
@@ -190,8 +196,12 @@ static int rsi_usb_reg_write(struct usb_device *usbdev,
 			     u16 value,
 			     u16 len)
 {
-	u8 usb_reg_buf[4];
-	int status =3D 0;
+	u8 *usb_reg_buf;
+	int status =3D -ENOMEM;
+
+	usb_reg_buf  =3D kmalloc(0x04, GFP_KERNEL);
+	if (!usb_reg_buf)
+		return status;
=20
 	usb_reg_buf[0] =3D (value & 0x00ff);
 	usb_reg_buf[1] =3D (value & 0xff00) >> 8;
@@ -212,6 +222,8 @@ static int rsi_usb_reg_write(struct usb_device *usbdev,
 			"%s: Reg write failed with error code :%d\n",
 			__func__, status);
 	}
+	kfree(usb_reg_buf);
+
 	return status;
 }
=20
@@ -286,7 +298,7 @@ int rsi_usb_write_register_multiple(struct rsi_hw *adap=
ter,
 		return -ENOMEM;
=20
 	while (count) {
-		transfer =3D min_t(int, count, 4096);
+		transfer =3D (u8)(min_t(u32, count, 4096));
 		memcpy(buf, data, transfer);
 		status =3D usb_control_msg(dev->usbdev,
 					 usb_sndctrlpipe(dev->usbdev, 0),
diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c b/driver=
s/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
index b6722de64a31..33da3dfcfa4f 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.c
@@ -625,17 +625,7 @@ bool exhalbtc_initlize_variables(struct rtl_priv *adap=
ter)
 	else
 		btcoexist->binded =3D true;
=20
-#if (defined(CONFIG_PCI_HCI))
-	btcoexist->chip_interface =3D BTC_INTF_PCI;
-#elif (defined(CONFIG_USB_HCI))
-	btcoexist->chip_interface =3D BTC_INTF_USB;
-#elif (defined(CONFIG_SDIO_HCI))
-	btcoexist->chip_interface =3D BTC_INTF_SDIO;
-#elif (defined(CONFIG_GSPI_HCI))
-	btcoexist->chip_interface =3D BTC_INTF_GSPI;
-#else
 	btcoexist->chip_interface =3D BTC_INTF_UNKNOWN;
-#endif
=20
 	if (NULL =3D=3D btcoexist->adapter)
 		btcoexist->adapter =3D adapter;
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--+QahgC5+KEYLbs62
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTRtjLAAoJEJctW/TcYTgG5EQP/jUOILjHg6e4ozbEP1n8vfaQ
k5xjG0rjz6LUYntGrSnKIX+FrMaRdb8k9CvayJGPhOsr494SIt6XrvKsbeVkRAxq
mnLC9bnjH9RX+8HDD9R3uRmuGqcrSKopQdUFVGvAIO3+wvWe2CUYJR2BLhH4APmq
gJOgVirncCHGpkXSnqId0WWx2jbrUtM4AnsGNGfFnK2dQV7AN+8S4waAmnZ8SLUV
kstNs0pByc4Po9QFL3qZQZHirROST8nYXcAifipj1A6+MeBZjLA9lHpe4pfUC4FC
Zo4xmVQwRKvnMI7gq3IFgunFCGdRqhggdHL3ilUZ1v06EOTFToE+sNSNmY9TLXgL
TOAOq8vu/p037Jo9y0jdRPu9mQiK+/sgUJagP3gsZ5w+vSrXw97lJXJTpmqf1s5l
/88s2/6BEbyQd5pOU1Jn/7n7ynncGpM+qzoApCiW+7pz7ianCmM/mL8ILAABCLbi
BGXb1C5eAdaG8mhD53ohHtYXregRX1Z0Ystoqs150lxgy1symoXXnV9WMp1pR+qC
q1xfCx+monTNrUmeQjJITDO13bEUmLnDPl/g0+4rDEfk4awk51BT/0PJV0NK6GgS
br9zzV+IXsmq+dZk+a/E/G2vUfBEc3YYAco7T5S6tIrywS9hLPvhqdIjoTgMZrUe
443dQSS9NuxsuiLwLRYh
=qpRl
-----END PGP SIGNATURE-----

--+QahgC5+KEYLbs62--
