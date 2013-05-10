From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2013-05-10
Date: Fri, 10 May 2013 11:22:02 -0400
Message-ID: <20130510152202.GD2103@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="LZvS9be/3tNcYl/X"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--LZvS9be/3tNcYl/X
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Here is a batch of fixes intended for the 3.10 stream.

Amitkumar Karwar provides an mwifiex fix to plug a memory leak when
the driver is unloaded.

Bing Zhao brings an mwifiex fix for some flag handling that leads to
log spam and an unusable interface.

Daniel Drake offers an mwifiex fix for multicast filter setup, to
correctly implement wakeup behaviour for multicast WOL.

Felix Fietkau fixes an ath9k problem that produces logspam and keycache
errors due to a bad return code.

Stanislaw Gruszka produces an fix for a WARNING from ath5k, and an
iwl4965 workaround to stop advertising a feature that doesn't work with
the current mac80211 implementation.

Sujith Manoharan gives us an ath9k fix to reprogram the HW beacon timers
after a TSF update, and an initvals fix for the AR9565 device.

Thommy Jakobsson fixes an rx descriptor underrun on b43.

Please let me know if there are problems!

John

---

The following changes since commit 70eba4226d9718946941c7be0c8cb66d431e7686:

  Merge tag 'please-pull-pstore' of git://git.kernel.org/pub/scm/linux/kern=
el/git/aegl/linux (2013-05-09 16:42:10 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 4f81d715b90b7ebe049dd906511c47956086ad44:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-05-10 10:29:24 -0400)

----------------------------------------------------------------

Amitkumar Karwar (1):
      mwifiex: fix memory leak issue when driver unload

Bing Zhao (1):
      mwifiex: clear is_suspended flag when interrupt is received early

Daniel Drake (1):
      mwifiex: fix setting of multicast filter

Felix Fietkau (1):
      ath9k: fix key allocation error handling for powersave keys

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Stanislaw Gruszka (2):
      ath5k: do not reschedule tx_complete_work on stop
      iwl4965: workaround connection regression on passive channel

Sujith Manoharan (2):
      ath9k: Fix beacon reconfiguration
      ath9k: Update initvals for AR9565

Thommy Jakobsson (1):
      B43: Handle DMA RX descriptor underrun

 drivers/net/wireless/ath/ath5k/base.c              |   5 +
 .../net/wireless/ath/ath9k/ar9565_1p0_initvals.h   | 138 +++++++++++------=
----
 drivers/net/wireless/ath/ath9k/main.c              |  10 +-
 drivers/net/wireless/b43/dma.c                     |  19 +++
 drivers/net/wireless/b43/dma.h                     |   4 +-
 drivers/net/wireless/b43/main.c                    |  43 +++----
 drivers/net/wireless/iwlegacy/4965-mac.c           |   3 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   3 -
 drivers/net/wireless/mwifiex/cmdevt.c              |   1 +
 drivers/net/wireless/mwifiex/main.c                |   1 +
 drivers/net/wireless/mwifiex/sta_ioctl.c           |  21 +---
 11 files changed, 131 insertions(+), 117 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/a=
th/ath5k/base.c
index 9b20d9e..7f702fe 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -2369,6 +2369,9 @@ ath5k_tx_complete_poll_work(struct work_struct *work)
 	int i;
 	bool needreset =3D false;
=20
+	if (!test_bit(ATH_STAT_STARTED, ah->status))
+		return;
+
 	mutex_lock(&ah->lock);
=20
 	for (i =3D 0; i < ARRAY_SIZE(ah->txqs); i++) {
@@ -2676,6 +2679,7 @@ done:
 	mmiowb();
 	mutex_unlock(&ah->lock);
=20
+	set_bit(ATH_STAT_STARTED, ah->status);
 	ieee80211_queue_delayed_work(ah->hw, &ah->tx_complete_work,
 			msecs_to_jiffies(ATH5K_TX_COMPLETE_POLL_INT));
=20
@@ -2737,6 +2741,7 @@ void ath5k_stop(struct ieee80211_hw *hw)
=20
 	ath5k_stop_tasklets(ah);
=20
+	clear_bit(ATH_STAT_STARTED, ah->status);
 	cancel_delayed_work_sync(&ah->tx_complete_work);
=20
 	if (!ath5k_modparam_no_hw_rfkill_switch)
diff --git a/drivers/net/wireless/ath/ath9k/ar9565_1p0_initvals.h b/drivers=
/net/wireless/ath/ath9k/ar9565_1p0_initvals.h
index 0c2ac0c..e85a8b0 100644
--- a/drivers/net/wireless/ath/ath9k/ar9565_1p0_initvals.h
+++ b/drivers/net/wireless/ath/ath9k/ar9565_1p0_initvals.h
@@ -233,9 +233,9 @@ static const u32 ar9565_1p0_baseband_core[][2] =3D {
 	{0x00009d10, 0x01834061},
 	{0x00009d14, 0x00c00400},
 	{0x00009d18, 0x00000000},
-	{0x00009e08, 0x0078230c},
-	{0x00009e24, 0x990bb515},
-	{0x00009e28, 0x126f0000},
+	{0x00009e08, 0x0038230c},
+	{0x00009e24, 0x9907b515},
+	{0x00009e28, 0x126f0600},
 	{0x00009e30, 0x06336f77},
 	{0x00009e34, 0x6af6532f},
 	{0x00009e38, 0x0cc80c00},
@@ -337,7 +337,7 @@ static const u32 ar9565_1p0_baseband_core[][2] =3D {
=20
 static const u32 ar9565_1p0_baseband_postamble[][5] =3D {
 	/* Addr      5G_HT20     5G_HT40     2G_HT40     2G_HT20   */
-	{0x00009810, 0xd00a8005, 0xd00a8005, 0xd00a8005, 0xd00a800d},
+	{0x00009810, 0xd00a8005, 0xd00a8005, 0xd00a8005, 0xd00a8009},
 	{0x00009820, 0x206a022e, 0x206a022e, 0x206a012e, 0x206a01ae},
 	{0x00009824, 0x5ac640d0, 0x5ac640d0, 0x5ac640d0, 0x63c640da},
 	{0x00009828, 0x06903081, 0x06903081, 0x06903881, 0x09143c81},
@@ -345,9 +345,9 @@ static const u32 ar9565_1p0_baseband_postamble[][5] =3D=
 {
 	{0x00009830, 0x0000059c, 0x0000059c, 0x0000059c, 0x0000059c},
 	{0x00009c00, 0x000000c4, 0x000000c4, 0x000000c4, 0x000000c4},
 	{0x00009e00, 0x0372111a, 0x0372111a, 0x037216a0, 0x037216a0},
-	{0x00009e04, 0x00802020, 0x00802020, 0x00802020, 0x00802020},
-	{0x00009e0c, 0x6c4000e2, 0x6d4000e2, 0x6d4000e2, 0x6c4000d8},
-	{0x00009e10, 0x7ec88d2e, 0x7ec88d2e, 0x7ec84d2e, 0x7ec86d2e},
+	{0x00009e04, 0x00802020, 0x00802020, 0x00142020, 0x00142020},
+	{0x00009e0c, 0x6c4000e2, 0x6d4000e2, 0x6d4000e2, 0x6c4000e2},
+	{0x00009e10, 0x7ec88d2e, 0x7ec88d2e, 0x7ec84d2e, 0x7ec84d2e},
 	{0x00009e14, 0x37b95d5e, 0x37b9605e, 0x3379605e, 0x33795d5e},
 	{0x00009e18, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x00009e1c, 0x0001cf9c, 0x0001cf9c, 0x00021f9c, 0x00021f9c},
@@ -450,6 +450,8 @@ static const u32 ar9565_1p0_soc_postamble[][5] =3D {
=20
 static const u32 ar9565_1p0_Common_rx_gain_table[][2] =3D {
 	/* Addr      allmodes  */
+	{0x00004050, 0x00300300},
+	{0x0000406c, 0x00100000},
 	{0x0000a000, 0x00010000},
 	{0x0000a004, 0x00030002},
 	{0x0000a008, 0x00050004},
@@ -498,27 +500,27 @@ static const u32 ar9565_1p0_Common_rx_gain_table[][2]=
 =3D {
 	{0x0000a0b4, 0x00000000},
 	{0x0000a0b8, 0x00000000},
 	{0x0000a0bc, 0x00000000},
-	{0x0000a0c0, 0x001f0000},
-	{0x0000a0c4, 0x01000101},
-	{0x0000a0c8, 0x011e011f},
-	{0x0000a0cc, 0x011c011d},
-	{0x0000a0d0, 0x02030204},
-	{0x0000a0d4, 0x02010202},
-	{0x0000a0d8, 0x021f0200},
-	{0x0000a0dc, 0x0302021e},
-	{0x0000a0e0, 0x03000301},
-	{0x0000a0e4, 0x031e031f},
-	{0x0000a0e8, 0x0402031d},
-	{0x0000a0ec, 0x04000401},
-	{0x0000a0f0, 0x041e041f},
-	{0x0000a0f4, 0x0502041d},
-	{0x0000a0f8, 0x05000501},
-	{0x0000a0fc, 0x051e051f},
-	{0x0000a100, 0x06010602},
-	{0x0000a104, 0x061f0600},
-	{0x0000a108, 0x061d061e},
-	{0x0000a10c, 0x07020703},
-	{0x0000a110, 0x07000701},
+	{0x0000a0c0, 0x00bf00a0},
+	{0x0000a0c4, 0x11a011a1},
+	{0x0000a0c8, 0x11be11bf},
+	{0x0000a0cc, 0x11bc11bd},
+	{0x0000a0d0, 0x22632264},
+	{0x0000a0d4, 0x22612262},
+	{0x0000a0d8, 0x227f2260},
+	{0x0000a0dc, 0x4322227e},
+	{0x0000a0e0, 0x43204321},
+	{0x0000a0e4, 0x433e433f},
+	{0x0000a0e8, 0x4462433d},
+	{0x0000a0ec, 0x44604461},
+	{0x0000a0f0, 0x447e447f},
+	{0x0000a0f4, 0x5582447d},
+	{0x0000a0f8, 0x55805581},
+	{0x0000a0fc, 0x559e559f},
+	{0x0000a100, 0x66816682},
+	{0x0000a104, 0x669f6680},
+	{0x0000a108, 0x669d669e},
+	{0x0000a10c, 0x77627763},
+	{0x0000a110, 0x77607761},
 	{0x0000a114, 0x00000000},
 	{0x0000a118, 0x00000000},
 	{0x0000a11c, 0x00000000},
@@ -530,27 +532,27 @@ static const u32 ar9565_1p0_Common_rx_gain_table[][2]=
 =3D {
 	{0x0000a134, 0x00000000},
 	{0x0000a138, 0x00000000},
 	{0x0000a13c, 0x00000000},
-	{0x0000a140, 0x001f0000},
-	{0x0000a144, 0x01000101},
-	{0x0000a148, 0x011e011f},
-	{0x0000a14c, 0x011c011d},
-	{0x0000a150, 0x02030204},
-	{0x0000a154, 0x02010202},
-	{0x0000a158, 0x021f0200},
-	{0x0000a15c, 0x0302021e},
-	{0x0000a160, 0x03000301},
-	{0x0000a164, 0x031e031f},
-	{0x0000a168, 0x0402031d},
-	{0x0000a16c, 0x04000401},
-	{0x0000a170, 0x041e041f},
-	{0x0000a174, 0x0502041d},
-	{0x0000a178, 0x05000501},
-	{0x0000a17c, 0x051e051f},
-	{0x0000a180, 0x06010602},
-	{0x0000a184, 0x061f0600},
-	{0x0000a188, 0x061d061e},
-	{0x0000a18c, 0x07020703},
-	{0x0000a190, 0x07000701},
+	{0x0000a140, 0x00bf00a0},
+	{0x0000a144, 0x11a011a1},
+	{0x0000a148, 0x11be11bf},
+	{0x0000a14c, 0x11bc11bd},
+	{0x0000a150, 0x22632264},
+	{0x0000a154, 0x22612262},
+	{0x0000a158, 0x227f2260},
+	{0x0000a15c, 0x4322227e},
+	{0x0000a160, 0x43204321},
+	{0x0000a164, 0x433e433f},
+	{0x0000a168, 0x4462433d},
+	{0x0000a16c, 0x44604461},
+	{0x0000a170, 0x447e447f},
+	{0x0000a174, 0x5582447d},
+	{0x0000a178, 0x55805581},
+	{0x0000a17c, 0x559e559f},
+	{0x0000a180, 0x66816682},
+	{0x0000a184, 0x669f6680},
+	{0x0000a188, 0x669d669e},
+	{0x0000a18c, 0x77e677e7},
+	{0x0000a190, 0x77e477e5},
 	{0x0000a194, 0x00000000},
 	{0x0000a198, 0x00000000},
 	{0x0000a19c, 0x00000000},
@@ -770,7 +772,7 @@ static const u32 ar9565_1p0_Modes_lowest_ob_db_tx_gain_=
table[][5] =3D {
=20
 static const u32 ar9565_1p0_pciephy_clkreq_disable_L1[][2] =3D {
 	/* Addr      allmodes  */
-	{0x00018c00, 0x18213ede},
+	{0x00018c00, 0x18212ede},
 	{0x00018c04, 0x000801d8},
 	{0x00018c08, 0x0003780c},
 };
@@ -889,8 +891,8 @@ static const u32 ar9565_1p0_common_wo_xlna_rx_gain_tabl=
e[][2] =3D {
 	{0x0000a180, 0x66816682},
 	{0x0000a184, 0x669f6680},
 	{0x0000a188, 0x669d669e},
-	{0x0000a18c, 0x77627763},
-	{0x0000a190, 0x77607761},
+	{0x0000a18c, 0x77e677e7},
+	{0x0000a190, 0x77e477e5},
 	{0x0000a194, 0x00000000},
 	{0x0000a198, 0x00000000},
 	{0x0000a19c, 0x00000000},
@@ -1114,7 +1116,7 @@ static const u32 ar9565_1p0_modes_high_ob_db_tx_gain_=
table[][5] =3D {
 	{0x0000a2e0, 0xffecec00, 0xffecec00, 0xfd339c84, 0xfd339c84},
 	{0x0000a2e4, 0xfc0f0000, 0xfc0f0000, 0xfec3e000, 0xfec3e000},
 	{0x0000a2e8, 0xfc100000, 0xfc100000, 0xfffc0000, 0xfffc0000},
-	{0x0000a410, 0x000050d9, 0x000050d9, 0x000050d9, 0x000050d9},
+	{0x0000a410, 0x000050d9, 0x000050d9, 0x000050df, 0x000050df},
 	{0x0000a500, 0x00002220, 0x00002220, 0x00000000, 0x00000000},
 	{0x0000a504, 0x06002223, 0x06002223, 0x04000002, 0x04000002},
 	{0x0000a508, 0x0b022220, 0x0b022220, 0x08000004, 0x08000004},
@@ -1140,13 +1142,13 @@ static const u32 ar9565_1p0_modes_high_ob_db_tx_gai=
n_table[][5] =3D {
 	{0x0000a558, 0x69027f56, 0x69027f56, 0x53001ce5, 0x53001ce5},
 	{0x0000a55c, 0x6d029f56, 0x6d029f56, 0x57001ce9, 0x57001ce9},
 	{0x0000a560, 0x73049f56, 0x73049f56, 0x5b001ceb, 0x5b001ceb},
-	{0x0000a564, 0x7804ff56, 0x7804ff56, 0x5d001eec, 0x5d001eec},
-	{0x0000a568, 0x7804ff56, 0x7804ff56, 0x5d001eec, 0x5d001eec},
-	{0x0000a56c, 0x7804ff56, 0x7804ff56, 0x5d001eec, 0x5d001eec},
-	{0x0000a570, 0x7804ff56, 0x7804ff56, 0x5d001eec, 0x5d001eec},
-	{0x0000a574, 0x7804ff56, 0x7804ff56, 0x5d001eec, 0x5d001eec},
-	{0x0000a578, 0x7804ff56, 0x7804ff56, 0x5d001eec, 0x5d001eec},
-	{0x0000a57c, 0x7804ff56, 0x7804ff56, 0x5d001eec, 0x5d001eec},
+	{0x0000a564, 0x7804ff56, 0x7804ff56, 0x60001cf0, 0x60001cf0},
+	{0x0000a568, 0x7804ff56, 0x7804ff56, 0x61001cf1, 0x61001cf1},
+	{0x0000a56c, 0x7804ff56, 0x7804ff56, 0x62001cf2, 0x62001cf2},
+	{0x0000a570, 0x7804ff56, 0x7804ff56, 0x63001cf3, 0x63001cf3},
+	{0x0000a574, 0x7804ff56, 0x7804ff56, 0x64001cf4, 0x64001cf4},
+	{0x0000a578, 0x7804ff56, 0x7804ff56, 0x66001ff6, 0x66001ff6},
+	{0x0000a57c, 0x7804ff56, 0x7804ff56, 0x66001ff6, 0x66001ff6},
 	{0x0000a600, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x0000a604, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x0000a608, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
@@ -1174,7 +1176,7 @@ static const u32 ar9565_1p0_modes_high_power_tx_gain_=
table[][5] =3D {
 	{0x0000a2e0, 0xffecec00, 0xffecec00, 0xfd339c84, 0xfd339c84},
 	{0x0000a2e4, 0xfc0f0000, 0xfc0f0000, 0xfec3e000, 0xfec3e000},
 	{0x0000a2e8, 0xfc100000, 0xfc100000, 0xfffc0000, 0xfffc0000},
-	{0x0000a410, 0x000050d9, 0x000050d9, 0x000050d9, 0x000050d9},
+	{0x0000a410, 0x000050d9, 0x000050d9, 0x000050df, 0x000050df},
 	{0x0000a500, 0x00002220, 0x00002220, 0x00000000, 0x00000000},
 	{0x0000a504, 0x06002223, 0x06002223, 0x04000002, 0x04000002},
 	{0x0000a508, 0x0a022220, 0x0a022220, 0x08000004, 0x08000004},
@@ -1200,13 +1202,13 @@ static const u32 ar9565_1p0_modes_high_power_tx_gai=
n_table[][5] =3D {
 	{0x0000a558, 0x66027f56, 0x66027f56, 0x4c001ce5, 0x4c001ce5},
 	{0x0000a55c, 0x6a029f56, 0x6a029f56, 0x50001ce9, 0x50001ce9},
 	{0x0000a560, 0x70049f56, 0x70049f56, 0x54001ceb, 0x54001ceb},
-	{0x0000a564, 0x7504ff56, 0x7504ff56, 0x56001eec, 0x56001eec},
-	{0x0000a568, 0x7504ff56, 0x7504ff56, 0x56001eec, 0x56001eec},
-	{0x0000a56c, 0x7504ff56, 0x7504ff56, 0x56001eec, 0x56001eec},
-	{0x0000a570, 0x7504ff56, 0x7504ff56, 0x56001eec, 0x56001eec},
-	{0x0000a574, 0x7504ff56, 0x7504ff56, 0x56001eec, 0x56001eec},
-	{0x0000a578, 0x7504ff56, 0x7504ff56, 0x56001eec, 0x56001eec},
-	{0x0000a57c, 0x7504ff56, 0x7504ff56, 0x56001eec, 0x56001eec},
+	{0x0000a564, 0x7504ff56, 0x7504ff56, 0x59001cf0, 0x59001cf0},
+	{0x0000a568, 0x7504ff56, 0x7504ff56, 0x5a001cf1, 0x5a001cf1},
+	{0x0000a56c, 0x7504ff56, 0x7504ff56, 0x5b001cf2, 0x5b001cf2},
+	{0x0000a570, 0x7504ff56, 0x7504ff56, 0x5c001cf3, 0x5c001cf3},
+	{0x0000a574, 0x7504ff56, 0x7504ff56, 0x5d001cf4, 0x5d001cf4},
+	{0x0000a578, 0x7504ff56, 0x7504ff56, 0x5f001ff6, 0x5f001ff6},
+	{0x0000a57c, 0x7504ff56, 0x7504ff56, 0x5f001ff6, 0x5f001ff6},
 	{0x0000a600, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x0000a604, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x0000a608, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index 6963862..a18414b 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -227,13 +227,13 @@ static bool ath_complete_reset(struct ath_softc *sc, =
bool start)
 		if (!test_bit(SC_OP_BEACONS, &sc->sc_flags))
 			goto work;
=20
-		ath9k_set_beacon(sc);
-
 		if (ah->opmode =3D=3D NL80211_IFTYPE_STATION &&
 		    test_bit(SC_OP_PRIM_STA_VIF, &sc->sc_flags)) {
 			spin_lock_irqsave(&sc->sc_pm_lock, flags);
 			sc->ps_flags |=3D PS_BEACON_SYNC | PS_WAIT_FOR_BEACON;
 			spin_unlock_irqrestore(&sc->sc_pm_lock, flags);
+		} else {
+			ath9k_set_beacon(sc);
 		}
 	work:
 		ath_restart_work(sc);
@@ -1332,6 +1332,7 @@ static int ath9k_sta_add(struct ieee80211_hw *hw,
 	struct ath_common *common =3D ath9k_hw_common(sc->sc_ah);
 	struct ath_node *an =3D (struct ath_node *) sta->drv_priv;
 	struct ieee80211_key_conf ps_key =3D { };
+	int key;
=20
 	ath_node_attach(sc, sta, vif);
=20
@@ -1339,7 +1340,9 @@ static int ath9k_sta_add(struct ieee80211_hw *hw,
 	    vif->type !=3D NL80211_IFTYPE_AP_VLAN)
 		return 0;
=20
-	an->ps_key =3D ath_key_config(common, vif, sta, &ps_key);
+	key =3D ath_key_config(common, vif, sta, &ps_key);
+	if (key > 0)
+		an->ps_key =3D key;
=20
 	return 0;
 }
@@ -1356,6 +1359,7 @@ static void ath9k_del_ps_key(struct ath_softc *sc,
 	    return;
=20
 	ath_key_delete(common, &ps_key);
+	an->ps_key =3D 0;
 }
=20
 static int ath9k_sta_remove(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/b43/dma.c b/drivers/net/wireless/b43/dma.c
index 523355b..f7c70b3 100644
--- a/drivers/net/wireless/b43/dma.c
+++ b/drivers/net/wireless/b43/dma.c
@@ -1728,6 +1728,25 @@ drop_recycle_buffer:
 	sync_descbuffer_for_device(ring, dmaaddr, ring->rx_buffersize);
 }
=20
+void b43_dma_handle_rx_overflow(struct b43_dmaring *ring)
+{
+	int current_slot, previous_slot;
+
+	B43_WARN_ON(ring->tx);
+
+	/* Device has filled all buffers, drop all packets and let TCP
+	 * decrease speed.
+	 * Decrement RX index by one will let the device to see all slots
+	 * as free again
+	 */
+	/*
+	*TODO: How to increase rx_drop in mac80211?
+	*/
+	current_slot =3D ring->ops->get_current_rxslot(ring);
+	previous_slot =3D prev_slot(ring, current_slot);
+	ring->ops->set_current_rxslot(ring, previous_slot);
+}
+
 void b43_dma_rx(struct b43_dmaring *ring)
 {
 	const struct b43_dma_ops *ops =3D ring->ops;
diff --git a/drivers/net/wireless/b43/dma.h b/drivers/net/wireless/b43/dma.h
index 9fdd198..df8c8cd 100644
--- a/drivers/net/wireless/b43/dma.h
+++ b/drivers/net/wireless/b43/dma.h
@@ -9,7 +9,7 @@
 /* DMA-Interrupt reasons. */
 #define B43_DMAIRQ_FATALMASK	((1 << 10) | (1 << 11) | (1 << 12) \
 					 | (1 << 14) | (1 << 15))
-#define B43_DMAIRQ_NONFATALMASK	(1 << 13)
+#define B43_DMAIRQ_RDESC_UFLOW		(1 << 13)
 #define B43_DMAIRQ_RX_DONE		(1 << 16)
=20
 /*** 32-bit DMA Engine. ***/
@@ -295,6 +295,8 @@ int b43_dma_tx(struct b43_wldev *dev,
 void b43_dma_handle_txstatus(struct b43_wldev *dev,
 			     const struct b43_txstatus *status);
=20
+void b43_dma_handle_rx_overflow(struct b43_dmaring *ring);
+
 void b43_dma_rx(struct b43_dmaring *ring);
=20
 void b43_dma_direct_fifo_rx(struct b43_wldev *dev,
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/mai=
n.c
index d377f77..6dd07e2 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -1902,30 +1902,18 @@ static void b43_do_interrupt_thread(struct b43_wlde=
v *dev)
 		}
 	}
=20
-	if (unlikely(merged_dma_reason & (B43_DMAIRQ_FATALMASK |
-					  B43_DMAIRQ_NONFATALMASK))) {
-		if (merged_dma_reason & B43_DMAIRQ_FATALMASK) {
-			b43err(dev->wl, "Fatal DMA error: "
-			       "0x%08X, 0x%08X, 0x%08X, "
-			       "0x%08X, 0x%08X, 0x%08X\n",
-			       dma_reason[0], dma_reason[1],
-			       dma_reason[2], dma_reason[3],
-			       dma_reason[4], dma_reason[5]);
-			b43err(dev->wl, "This device does not support DMA "
+	if (unlikely(merged_dma_reason & (B43_DMAIRQ_FATALMASK))) {
+		b43err(dev->wl,
+			"Fatal DMA error: 0x%08X, 0x%08X, 0x%08X, 0x%08X, 0x%08X, 0x%08X\n",
+			dma_reason[0], dma_reason[1],
+			dma_reason[2], dma_reason[3],
+			dma_reason[4], dma_reason[5]);
+		b43err(dev->wl, "This device does not support DMA "
 			       "on your system. It will now be switched to PIO.\n");
-			/* Fall back to PIO transfers if we get fatal DMA errors! */
-			dev->use_pio =3D true;
-			b43_controller_restart(dev, "DMA error");
-			return;
-		}
-		if (merged_dma_reason & B43_DMAIRQ_NONFATALMASK) {
-			b43err(dev->wl, "DMA error: "
-			       "0x%08X, 0x%08X, 0x%08X, "
-			       "0x%08X, 0x%08X, 0x%08X\n",
-			       dma_reason[0], dma_reason[1],
-			       dma_reason[2], dma_reason[3],
-			       dma_reason[4], dma_reason[5]);
-		}
+		/* Fall back to PIO transfers if we get fatal DMA errors! */
+		dev->use_pio =3D true;
+		b43_controller_restart(dev, "DMA error");
+		return;
 	}
=20
 	if (unlikely(reason & B43_IRQ_UCODE_DEBUG))
@@ -1944,6 +1932,11 @@ static void b43_do_interrupt_thread(struct b43_wldev=
 *dev)
 		handle_irq_noise(dev);
=20
 	/* Check the DMA reason registers for received data. */
+	if (dma_reason[0] & B43_DMAIRQ_RDESC_UFLOW) {
+		if (B43_DEBUG)
+			b43warn(dev->wl, "RX descriptor underrun\n");
+		b43_dma_handle_rx_overflow(dev->dma.rx_ring);
+	}
 	if (dma_reason[0] & B43_DMAIRQ_RX_DONE) {
 		if (b43_using_pio_transfers(dev))
 			b43_pio_rx(dev->pio.rx_queue);
@@ -2001,7 +1994,7 @@ static irqreturn_t b43_do_interrupt(struct b43_wldev =
*dev)
 		return IRQ_NONE;
=20
 	dev->dma_reason[0] =3D b43_read32(dev, B43_MMIO_DMA0_REASON)
-	    & 0x0001DC00;
+	    & 0x0001FC00;
 	dev->dma_reason[1] =3D b43_read32(dev, B43_MMIO_DMA1_REASON)
 	    & 0x0000DC00;
 	dev->dma_reason[2] =3D b43_read32(dev, B43_MMIO_DMA2_REASON)
@@ -3130,7 +3123,7 @@ static int b43_chip_init(struct b43_wldev *dev)
 		b43_write32(dev, 0x018C, 0x02000000);
 	}
 	b43_write32(dev, B43_MMIO_GEN_IRQ_REASON, 0x00004000);
-	b43_write32(dev, B43_MMIO_DMA0_IRQ_MASK, 0x0001DC00);
+	b43_write32(dev, B43_MMIO_DMA0_IRQ_MASK, 0x0001FC00);
 	b43_write32(dev, B43_MMIO_DMA1_IRQ_MASK, 0x0000DC00);
 	b43_write32(dev, B43_MMIO_DMA2_IRQ_MASK, 0x0000DC00);
 	b43_write32(dev, B43_MMIO_DMA3_IRQ_MASK, 0x0001DC00);
diff --git a/drivers/net/wireless/iwlegacy/4965-mac.c b/drivers/net/wireles=
s/iwlegacy/4965-mac.c
index b8f82e6..9a95045 100644
--- a/drivers/net/wireless/iwlegacy/4965-mac.c
+++ b/drivers/net/wireless/iwlegacy/4965-mac.c
@@ -5741,8 +5741,7 @@ il4965_mac_setup_register(struct il_priv *il, u32 max=
_probe_length)
 	hw->flags =3D
 	    IEEE80211_HW_SIGNAL_DBM | IEEE80211_HW_AMPDU_AGGREGATION |
 	    IEEE80211_HW_NEED_DTIM_BEFORE_ASSOC | IEEE80211_HW_SPECTRUM_MGMT |
-	    IEEE80211_HW_REPORTS_TX_ACK_STATUS | IEEE80211_HW_SUPPORTS_PS |
-	    IEEE80211_HW_SUPPORTS_DYNAMIC_PS;
+	    IEEE80211_HW_SUPPORTS_PS | IEEE80211_HW_SUPPORTS_DYNAMIC_PS;
 	if (il->cfg->sku & IL_SKU_N)
 		hw->flags |=3D
 		    IEEE80211_HW_SUPPORTS_DYNAMIC_SMPS |
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless=
/mwifiex/cfg80211.c
index d3c8ece..e42b266 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -2234,9 +2234,6 @@ int mwifiex_del_virtual_intf(struct wiphy *wiphy, str=
uct wireless_dev *wdev)
 	if (wdev->netdev->reg_state =3D=3D NETREG_REGISTERED)
 		unregister_netdevice(wdev->netdev);
=20
-	if (wdev->netdev->reg_state =3D=3D NETREG_UNREGISTERED)
-		free_netdev(wdev->netdev);
-
 	/* Clear the priv in adapter */
 	priv->netdev =3D NULL;
=20
diff --git a/drivers/net/wireless/mwifiex/cmdevt.c b/drivers/net/wireless/m=
wifiex/cmdevt.c
index 74db0d2..26755d9 100644
--- a/drivers/net/wireless/mwifiex/cmdevt.c
+++ b/drivers/net/wireless/mwifiex/cmdevt.c
@@ -1191,6 +1191,7 @@ mwifiex_process_hs_config(struct mwifiex_adapter *ada=
pter)
 	adapter->if_ops.wakeup(adapter);
 	adapter->hs_activated =3D false;
 	adapter->is_hs_configured =3D false;
+	adapter->is_suspended =3D false;
 	mwifiex_hs_activated_event(mwifiex_get_priv(adapter,
 						    MWIFIEX_BSS_ROLE_ANY),
 				   false);
diff --git a/drivers/net/wireless/mwifiex/main.c b/drivers/net/wireless/mwi=
fiex/main.c
index 121443a..2eb88ea 100644
--- a/drivers/net/wireless/mwifiex/main.c
+++ b/drivers/net/wireless/mwifiex/main.c
@@ -655,6 +655,7 @@ void mwifiex_init_priv_params(struct mwifiex_private *p=
riv,
 						struct net_device *dev)
 {
 	dev->netdev_ops =3D &mwifiex_netdev_ops;
+	dev->destructor =3D free_netdev;
 	/* Initialize private structure */
 	priv->current_key_index =3D 0;
 	priv->media_connected =3D false;
diff --git a/drivers/net/wireless/mwifiex/sta_ioctl.c b/drivers/net/wireles=
s/mwifiex/sta_ioctl.c
index 311d0b2..1a8a19d 100644
--- a/drivers/net/wireless/mwifiex/sta_ioctl.c
+++ b/drivers/net/wireless/mwifiex/sta_ioctl.c
@@ -96,7 +96,7 @@ int mwifiex_request_set_multicast_list(struct mwifiex_pri=
vate *priv,
 	} else {
 		/* Multicast */
 		priv->curr_pkt_filter &=3D ~HostCmd_ACT_MAC_PROMISCUOUS_ENABLE;
-		if (mcast_list->mode =3D=3D MWIFIEX_MULTICAST_MODE) {
+		if (mcast_list->mode =3D=3D MWIFIEX_ALL_MULTI_MODE) {
 			dev_dbg(priv->adapter->dev,
 				"info: Enabling All Multicast!\n");
 			priv->curr_pkt_filter |=3D
@@ -108,20 +108,11 @@ int mwifiex_request_set_multicast_list(struct mwifiex=
_private *priv,
 				dev_dbg(priv->adapter->dev,
 					"info: Set multicast list=3D%d\n",
 				       mcast_list->num_multicast_addr);
-				/* Set multicast addresses to firmware */
-				if (old_pkt_filter =3D=3D priv->curr_pkt_filter) {
-					/* Send request to firmware */
-					ret =3D mwifiex_send_cmd_async(priv,
-						HostCmd_CMD_MAC_MULTICAST_ADR,
-						HostCmd_ACT_GEN_SET, 0,
-						mcast_list);
-				} else {
-					/* Send request to firmware */
-					ret =3D mwifiex_send_cmd_async(priv,
-						HostCmd_CMD_MAC_MULTICAST_ADR,
-						HostCmd_ACT_GEN_SET, 0,
-						mcast_list);
-				}
+				/* Send multicast addresses to firmware */
+				ret =3D mwifiex_send_cmd_async(priv,
+					HostCmd_CMD_MAC_MULTICAST_ADR,
+					HostCmd_ACT_GEN_SET, 0,
+					mcast_list);
 			}
 		}
 	}
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--LZvS9be/3tNcYl/X
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRjRCaAAoJEJctW/TcYTgGmCcP/0VUr/71UyLU6Lp2RfSa2VXj
3EedMSISNksa9//nIzKIZy0gQTK9vD66x0BsrtTr0aFx5tXB0RQMR0QW7X2A5qss
yJlPQ2MKuIaz9+IEpUX9xTsHfTUYcRXDLo8ddsttrXEJwpUhG6ZxsayoCgs4ENWi
BNzoHxXB4iMBmqC3VeEXq5m7iNgOtwl7qQNgf6TXvBEj1XbPebtFAVQF8sf4rL8x
wLN+pZj1hWeoY2WNuwSU/e4Tz/z0g5s4d4RO2mAIDFZFraGGIvcgkGkgKdc0XXQb
Izgui3SbTn2+dQDd+Z5tVrMAv2dSVwtnjw7Aj/OFHF6t08PhFm/IDfyFHqRYeKyV
UlDYI/8meXQR9UYXvwxroJ4VjIEle3EI2apcWhhPox3qWzUU7S2d5Ddjsnp7FwMp
vwp+qMR2zzlv6EaMS5JRglJDwEilsQQeui6s3M/iFAakKSe9z893d+gTBr/rAlT1
MJiI2n0VZdQvEni5qx6qaQW+Sj9HxOssKweH3ECf2fzovbqR3oa4Y7wkVleIKGFR
tzEJk2A+NG74vnxWSga2FcnKnPOAgOqxImhdEVbdpnaqtC718bfJiyweN8GC4CsD
xqbIixu6vI384JSowIlTE2vG4dntcsU5F/6H1tu1YD1zSzwLFqCc4JSAGdQUFx1A
FFgimsX1OKVRvc5/G9PC
=Qwt0
-----END PGP SIGNATURE-----

--LZvS9be/3tNcYl/X--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
