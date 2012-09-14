From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-09-14
Date: Fri, 14 Sep 2012 13:46:55 -0400
Message-ID: <20120914174655.GC17463@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OXfL5xGRrasGEqWY"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--OXfL5xGRrasGEqWY
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 7a253c2954dad9d70fa2e07b45b55ea4bee6c6c7

Dave,

This is a batch of fixes intended for the 3.6 stream.

Arend van Spriel sends a simple thinko fix to correct a constant,
preventing the setting of an invalid power level.

Colin Ian King gives us a simple allocation failure check to avoid a
NULL pointer dereference.

Felix Fietkau sends another ath9k tx power patch, this time disabling a
feature that has been reported to cause rx problems.

Hante Meuleman provides a pair of endian fixes for brcmfmac.

Larry Finger offers an rtlwifi fix that avoids a system lockup related
to loading the wrong firmware for RTL8188CE devices.

These have been in linux-next for a few days and I think they should be
included in the final 3.6 kernel if possible.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 6af773e786ad617b0264ebe06ba60675c01f3e51:

  pktgen: fix crash with vlan and packet size less than 46 (2012-09-13 17:1=
0:00 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 7a253c2954dad9d70fa2e07b45b55ea4bee6c6c7:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2012-09-14 11:39:39 -0400)

----------------------------------------------------------------

Arend van Spriel (1):
      brcmsmac: fix mismatch in number of custom regulatory rules

Colin Ian King (1):
      brcm80211: fix missing allocation failure check

Felix Fietkau (1):
      ath9k: make PA linearization optional, disabled by default and fix ch=
ecks

Hante Meuleman (2):
      brcmfmac: fix big endian bug in i-scan.
      brcmfmac: Fix big endian host configuration data.

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Larry Finger (1):
      rtlwifi: rtl8192ce: Log message that B_CUT device may not work

 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |  4 ++++
 drivers/net/wireless/ath/ath9k/debug.c             |  2 ++
 drivers/net/wireless/ath/ath9k/hw.c                |  4 ----
 drivers/net/wireless/ath/ath9k/hw.h                |  3 +--
 drivers/net/wireless/ath/ath9k/link.c              |  2 +-
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |  2 ++
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   | 26 +++++++++++++-----=
----
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |  6 +++--
 drivers/net/wireless/brcm80211/brcmsmac/channel.c  |  2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/def.h       |  1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        | 12 ++++++++--
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |  6 +++--
 12 files changed, 46 insertions(+), 24 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/w=
ireless/ath/ath9k/ar9003_eeprom.c
index 2588848..d066f25 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
@@ -2982,6 +2982,10 @@ static u32 ath9k_hw_ar9300_get_eeprom(struct ath_hw =
*ah,
 	case EEP_RX_MASK:
 		return pBase->txrxMask & 0xf;
 	case EEP_PAPRD:
+		if (AR_SREV_9462(ah))
+			return false;
+		if (!ah->config.enable_paprd);
+			return false;
 		return !!(pBase->featureEnable & BIT(5));
 	case EEP_CHAIN_MASK_REDUCE:
 		return (pBase->miscConfiguration >> 0x3) & 0x1;
diff --git a/drivers/net/wireless/ath/ath9k/debug.c b/drivers/net/wireless/=
ath/ath9k/debug.c
index 68b643c..c8ef301 100644
--- a/drivers/net/wireless/ath/ath9k/debug.c
+++ b/drivers/net/wireless/ath/ath9k/debug.c
@@ -1577,6 +1577,8 @@ int ath9k_init_debug(struct ath_hw *ah)
 			    sc->debug.debugfs_phy, sc, &fops_tx_chainmask);
 	debugfs_create_file("disable_ani", S_IRUSR | S_IWUSR,
 			    sc->debug.debugfs_phy, sc, &fops_disable_ani);
+	debugfs_create_bool("paprd", S_IRUSR | S_IWUSR, sc->debug.debugfs_phy,
+			    &sc->sc_ah->config.enable_paprd);
 	debugfs_create_file("regidx", S_IRUSR | S_IWUSR, sc->debug.debugfs_phy,
 			    sc, &fops_regidx);
 	debugfs_create_file("regval", S_IRUSR | S_IWUSR, sc->debug.debugfs_phy,
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath=
/ath9k/hw.c
index 48af401..4faf0a3 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -2497,10 +2497,6 @@ int ath9k_hw_fill_cap_info(struct ath_hw *ah)
 		pCap->rx_status_len =3D sizeof(struct ar9003_rxs);
 		pCap->tx_desc_len =3D sizeof(struct ar9003_txc);
 		pCap->txs_len =3D sizeof(struct ar9003_txs);
-		if (!ah->config.paprd_disable &&
-		    ah->eep_ops->get_eeprom(ah, EEP_PAPRD) &&
-		    !AR_SREV_9462(ah))
-			pCap->hw_caps |=3D ATH9K_HW_CAP_PAPRD;
 	} else {
 		pCap->tx_desc_len =3D sizeof(struct ath_desc);
 		if (AR_SREV_9280_20(ah))
diff --git a/drivers/net/wireless/ath/ath9k/hw.h b/drivers/net/wireless/ath=
/ath9k/hw.h
index 6599a75..de6968f 100644
--- a/drivers/net/wireless/ath/ath9k/hw.h
+++ b/drivers/net/wireless/ath/ath9k/hw.h
@@ -236,7 +236,6 @@ enum ath9k_hw_caps {
 	ATH9K_HW_CAP_LDPC			=3D BIT(6),
 	ATH9K_HW_CAP_FASTCLOCK			=3D BIT(7),
 	ATH9K_HW_CAP_SGI_20			=3D BIT(8),
-	ATH9K_HW_CAP_PAPRD			=3D BIT(9),
 	ATH9K_HW_CAP_ANT_DIV_COMB		=3D BIT(10),
 	ATH9K_HW_CAP_2GHZ			=3D BIT(11),
 	ATH9K_HW_CAP_5GHZ			=3D BIT(12),
@@ -287,12 +286,12 @@ struct ath9k_ops_config {
 	u8 pcie_clock_req;
 	u32 pcie_waen;
 	u8 analog_shiftreg;
-	u8 paprd_disable;
 	u32 ofdm_trig_low;
 	u32 ofdm_trig_high;
 	u32 cck_trig_high;
 	u32 cck_trig_low;
 	u32 enable_ani;
+	u32 enable_paprd;
 	int serialize_regmode;
 	bool rx_intr_mitigation;
 	bool tx_intr_mitigation;
diff --git a/drivers/net/wireless/ath/ath9k/link.c b/drivers/net/wireless/a=
th/ath9k/link.c
index 825a29c..7b88b9c 100644
--- a/drivers/net/wireless/ath/ath9k/link.c
+++ b/drivers/net/wireless/ath/ath9k/link.c
@@ -423,7 +423,7 @@ set_timer:
 		cal_interval =3D min(cal_interval, (u32)short_cal_interval);
=20
 	mod_timer(&common->ani.timer, jiffies + msecs_to_jiffies(cal_interval));
-	if ((sc->sc_ah->caps.hw_caps & ATH9K_HW_CAP_PAPRD) && ah->caldata) {
+	if (ah->eep_ops->get_eeprom(ah, EEP_PAPRD) && ah->caldata) {
 		if (!ah->caldata->paprd_done)
 			ieee80211_queue_work(sc->hw, &sc->paprd_work);
 		else if (!ah->paprd_table_write_done)
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c b/drive=
rs/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c
index 49765d3..7c4ee72 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c
@@ -638,6 +638,8 @@ static int brcmf_sdio_pd_probe(struct platform_device *=
pdev)
=20
 		oobirq_entry =3D kzalloc(sizeof(struct brcmf_sdio_oobirq),
 				       GFP_KERNEL);
+		if (!oobirq_entry)
+			return -ENOMEM;
 		oobirq_entry->irq =3D res->start;
 		oobirq_entry->flags =3D res->flags & IRQF_TRIGGER_MASK;
 		list_add_tail(&oobirq_entry->list, &oobirq_lh);
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c b/drivers=
/net/wireless/brcm80211/brcmfmac/dhd_common.c
index 2621dd3..6f70953 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_common.c
@@ -764,8 +764,11 @@ static void brcmf_c_arp_offload_set(struct brcmf_pub *=
drvr, int arp_mode)
 {
 	char iovbuf[32];
 	int retcode;
+	__le32 arp_mode_le;
=20
-	brcmf_c_mkiovar("arp_ol", (char *)&arp_mode, 4, iovbuf, sizeof(iovbuf));
+	arp_mode_le =3D cpu_to_le32(arp_mode);
+	brcmf_c_mkiovar("arp_ol", (char *)&arp_mode_le, 4, iovbuf,
+			sizeof(iovbuf));
 	retcode =3D brcmf_proto_cdc_set_dcmd(drvr, 0, BRCMF_C_SET_VAR,
 				   iovbuf, sizeof(iovbuf));
 	retcode =3D retcode >=3D 0 ? 0 : retcode;
@@ -781,8 +784,11 @@ static void brcmf_c_arp_offload_enable(struct brcmf_pu=
b *drvr, int arp_enable)
 {
 	char iovbuf[32];
 	int retcode;
+	__le32 arp_enable_le;
=20
-	brcmf_c_mkiovar("arpoe", (char *)&arp_enable, 4,
+	arp_enable_le =3D cpu_to_le32(arp_enable);
+
+	brcmf_c_mkiovar("arpoe", (char *)&arp_enable_le, 4,
 			iovbuf, sizeof(iovbuf));
 	retcode =3D brcmf_proto_cdc_set_dcmd(drvr, 0, BRCMF_C_SET_VAR,
 				   iovbuf, sizeof(iovbuf));
@@ -800,10 +806,10 @@ int brcmf_c_preinit_dcmds(struct brcmf_pub *drvr)
 	char iovbuf[BRCMF_EVENTING_MASK_LEN + 12];	/*  Room for
 				 "event_msgs" + '\0' + bitvec  */
 	char buf[128], *ptr;
-	u32 roaming =3D 1;
-	uint bcn_timeout =3D 3;
-	int scan_assoc_time =3D 40;
-	int scan_unassoc_time =3D 40;
+	__le32 roaming_le =3D cpu_to_le32(1);
+	__le32 bcn_timeout_le =3D cpu_to_le32(3);
+	__le32 scan_assoc_time_le =3D cpu_to_le32(40);
+	__le32 scan_unassoc_time_le =3D cpu_to_le32(40);
 	int i;
 	struct brcmf_bus_dcmd *cmdlst;
 	struct list_head *cur, *q;
@@ -829,14 +835,14 @@ int brcmf_c_preinit_dcmds(struct brcmf_pub *drvr)
=20
 	/* Setup timeout if Beacons are lost and roam is off to report
 		 link down */
-	brcmf_c_mkiovar("bcn_timeout", (char *)&bcn_timeout, 4, iovbuf,
+	brcmf_c_mkiovar("bcn_timeout", (char *)&bcn_timeout_le, 4, iovbuf,
 		    sizeof(iovbuf));
 	brcmf_proto_cdc_set_dcmd(drvr, 0, BRCMF_C_SET_VAR, iovbuf,
 				  sizeof(iovbuf));
=20
 	/* Enable/Disable build-in roaming to allowed ext supplicant to take
 		 of romaing */
-	brcmf_c_mkiovar("roam_off", (char *)&roaming, 4,
+	brcmf_c_mkiovar("roam_off", (char *)&roaming_le, 4,
 		      iovbuf, sizeof(iovbuf));
 	brcmf_proto_cdc_set_dcmd(drvr, 0, BRCMF_C_SET_VAR, iovbuf,
 				  sizeof(iovbuf));
@@ -848,9 +854,9 @@ int brcmf_c_preinit_dcmds(struct brcmf_pub *drvr)
 				  sizeof(iovbuf));
=20
 	brcmf_proto_cdc_set_dcmd(drvr, 0, BRCMF_C_SET_SCAN_CHANNEL_TIME,
-			 (char *)&scan_assoc_time, sizeof(scan_assoc_time));
+		 (char *)&scan_assoc_time_le, sizeof(scan_assoc_time_le));
 	brcmf_proto_cdc_set_dcmd(drvr, 0, BRCMF_C_SET_SCAN_UNASSOC_TIME,
-			 (char *)&scan_unassoc_time, sizeof(scan_unassoc_time));
+		 (char *)&scan_unassoc_time_le, sizeof(scan_unassoc_time_le));
=20
 	/* Set and enable ARP offload feature */
 	brcmf_c_arp_offload_set(drvr, BRCMF_ARPOL_MODE);
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/driver=
s/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index c36e923..50b5553 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -500,8 +500,10 @@ static void wl_iscan_prep(struct brcmf_scan_params_le =
*params_le,
 	params_le->active_time =3D cpu_to_le32(-1);
 	params_le->passive_time =3D cpu_to_le32(-1);
 	params_le->home_time =3D cpu_to_le32(-1);
-	if (ssid && ssid->SSID_len)
-		memcpy(&params_le->ssid_le, ssid, sizeof(struct brcmf_ssid));
+	if (ssid && ssid->SSID_len) {
+		params_le->ssid_le.SSID_len =3D cpu_to_le32(ssid->SSID_len);
+		memcpy(&params_le->ssid_le.SSID, ssid->SSID, ssid->SSID_len);
+	}
 }
=20
 static s32
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/channel.c b/drivers/ne=
t/wireless/brcm80211/brcmsmac/channel.c
index 7ed7d75..64a48f0 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/channel.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/channel.c
@@ -77,7 +77,7 @@
 					 NL80211_RRF_NO_IBSS)
=20
 static const struct ieee80211_regdomain brcms_regdom_x2 =3D {
-	.n_reg_rules =3D 7,
+	.n_reg_rules =3D 6,
 	.alpha2 =3D "X2",
 	.reg_rules =3D {
 		BRCM_2GHZ_2412_2462,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/def.h b/drivers/net/wir=
eless/rtlwifi/rtl8192ce/def.h
index 04c3aef..2925094 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/def.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/def.h
@@ -117,6 +117,7 @@
=20
 #define CHIP_VER_B			BIT(4)
 #define CHIP_92C_BITMASK		BIT(0)
+#define CHIP_UNKNOWN			BIT(7)
 #define CHIP_92C_1T2R			0x03
 #define CHIP_92C			0x01
 #define CHIP_88C			0x00
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wire=
less/rtlwifi/rtl8192ce/hw.c
index bd0da7e..dd4bb09 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -994,8 +994,16 @@ static enum version_8192c _rtl92ce_read_chip_version(s=
truct ieee80211_hw *hw)
 		version =3D (value32 & TYPE_ID) ? VERSION_A_CHIP_92C :
 			   VERSION_A_CHIP_88C;
 	} else {
-		version =3D (value32 & TYPE_ID) ? VERSION_B_CHIP_92C :
-			   VERSION_B_CHIP_88C;
+		version =3D (enum version_8192c) (CHIP_VER_B |
+				((value32 & TYPE_ID) ? CHIP_92C_BITMASK : 0) |
+				((value32 & VENDOR_ID) ? CHIP_VENDOR_UMC : 0));
+		if ((!IS_CHIP_VENDOR_UMC(version)) && (value32 &
+		     CHIP_VER_RTL_MASK)) {
+			version =3D (enum version_8192c)(version |
+				   ((((value32 & CHIP_VER_RTL_MASK) =3D=3D BIT(12))
+				   ? CHIP_VENDOR_UMC_B_CUT : CHIP_UNKNOWN) |
+				   CHIP_VENDOR_UMC));
+		}
 	}
=20
 	switch (version) {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c b/drivers/net/wire=
less/rtlwifi/rtl8192ce/sw.c
index 3aa927f..7d8f964 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
@@ -162,10 +162,12 @@ int rtl92c_init_sw_vars(struct ieee80211_hw *hw)
=20
 	/* request fw */
 	if (IS_VENDOR_UMC_A_CUT(rtlhal->version) &&
-	    !IS_92C_SERIAL(rtlhal->version))
+	    !IS_92C_SERIAL(rtlhal->version)) {
 		rtlpriv->cfg->fw_name =3D "rtlwifi/rtl8192cfwU.bin";
-	else if (IS_81xxC_VENDOR_UMC_B_CUT(rtlhal->version))
+	} else if (IS_81xxC_VENDOR_UMC_B_CUT(rtlhal->version)) {
 		rtlpriv->cfg->fw_name =3D "rtlwifi/rtl8192cfwU_B.bin";
+		pr_info("****** This B_CUT device may not work with kernels 3.6 and earl=
ier\n");
+	}
=20
 	rtlpriv->max_fw_size =3D 0x4000;
 	pr_info("Using firmware %s\n", rtlpriv->cfg->fw_name);
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--OXfL5xGRrasGEqWY
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQU22PAAoJEJctW/TcYTgGO0MP/0uklXMuJi1LHtr5QgPQdpQV
+U3EceP/LKfPucyjWBcLDCrDRt8PLAt+NzVpBzoWnImZ3O6/16jzWjYZT773Kd0o
4NM7Y0GsAruQT9AYJVg6LobR9iLqKg2c85MyPuVtuXFgOz4NxxDeMtXPewyqecUS
VsdCFZuzuCS7Ohp15gClCEURMUl72wmMzAJ0XMFNFm7MbOLEW1/7KoEmPwEJCXEg
fJ3Ofqdy1OdUnjohe329VtjkNMCGmRsw0Mx55Oz7HqRjAZiJ0GjbCFS60ftOqNLt
MFoX4YKCvJNcg78a0BsmyA3cdte1XVcbSBJHF65McVsZMPMqaJ+uvZhEOy3mGPv+
xeK1stWVbQuduk5X6T1Srr7ZqcWLLAFKGFKVHieQe37tXfFaQF+3Nfz8gFi/Ajg4
oowz5+MwHcUmp64x/f7sYkNJgsszIY22Gly0PLDiYKWYlhLvOUXLJprYT+Z6p7Hp
riWO8x5U5y9o7CUn3/nUg7XIf2Iismd1OoOQmj/4uSNAQqrH+uoBniYVofe7idIR
raUKgEGAh12dMc+RwojU2Ir6usEjFW8xprvANW4JVUY5NtPX3nrzomMknji3fsRb
Ex1fpHQl7UoIVE59c/P4ItHQ3jJi2vRNnGW2yCk/z8LMMIPup9K3LuwPth0tUnEL
2YFjms8rUFld2j/YHzJY
=33F3
-----END PGP SIGNATURE-----

--OXfL5xGRrasGEqWY--
