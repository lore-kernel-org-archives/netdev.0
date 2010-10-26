From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-10-26
Date: Tue, 26 Oct 2010 14:15:16 -0400
Message-ID: <20101026181515.GD2446@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave,

Here are some fixes intended for 2.6.37.  Highlights are some carl9170
fixes, a fix/cleanup for the earlier wl1251 move, various ath9k fixes,
a mac80211 fix relating to IBSS station expiry and a cfg80211 fix
related to processing country IEs.  One of the ath9k patches looks big,
but it is just changing a table of register initialization values in
order to correct a number of issues.  The associated changelogs are
reasonably descriptive of the issues involved.

Also included is a patch from Tejun as part of his work to remove
flush_scheduled_work().  I noticed you already included a similar
patch from Tejun, so I figured this was acceptable as well.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 43a951e9994fd218ab4e641f94a2fc53556c=
3675:

  ipv4: add __rcu annotations to ip_ra_chain (2010-10-25 14:18:28 -0700=
)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.g=
it master

Ben Greear (2):
      ath9k: Properly initialize ath_common->cc_lock.
      ath5k: Properly initialize ath_common->cc_lock.

Christian Lamparter (4):
      carl9170: fix async command buffer leak
      mac80211: don't sanitize invalid rates
      carl9170: fix memory leak issue in async cmd macro wrappers
      carl9170: fix scheduling while atomic

Don Fry (1):
      iwlwifi: quiet a noisy printk

=46elix Fietkau (3):
      ath9k: fix crash in ath_update_survey_stats
      ath9k: fix handling of rate control probe frames
      ath9k: resume aggregation immediately after a hardware reset

Grazvydas Ignotas (1):
      wl1251: fix module names

Luis R. Rodriguez (2):
      cfg80211: fix regression on processing country IEs
      ath9k_hw: Fix TX carrier leakage for IEEE compliance on AR9003 2.=
2

Rafa=C5=82 Mi=C5=82ecki (1):
      b43: N-PHY: fix infinite-loop-typo

Rajkumar Manoharan (1):
      mac80211: Fix ibss station got expired immediately

Senthil Balasubramanian (1):
      ath9k_hw: Fix divide by zero cases in paprd.

Tejun Heo (1):
      mac80211: cancel restart_work explicitly instead of depending on =
flush_scheduled_work()

 drivers/net/wireless/ath/ath5k/base.c              |    1 +
 .../net/wireless/ath/ath9k/ar9003_2p2_initvals.h   |  191 ++++++++++++=
++------
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c      |   14 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |    2 +-
 drivers/net/wireless/ath/ath9k/init.c              |    1 +
 drivers/net/wireless/ath/ath9k/main.c              |    7 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |    8 +-
 drivers/net/wireless/ath/carl9170/cmd.h            |   51 +++---
 drivers/net/wireless/ath/carl9170/main.c           |    2 +-
 drivers/net/wireless/ath/carl9170/usb.c            |   25 ++-
 drivers/net/wireless/b43/phy_n.c                   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |    3 +-
 drivers/net/wireless/wl1251/Makefile               |    8 +-
 net/mac80211/ibss.c                                |    1 +
 net/mac80211/main.c                                |    8 +-
 net/mac80211/rate.c                                |    3 +
 net/wireless/reg.c                                 |    2 +-
 17 files changed, 221 insertions(+), 108 deletions(-)

diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wirele=
ss/ath/ath5k/base.c
index f1ae75d..8251946 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -3580,6 +3580,7 @@ ath5k_pci_probe(struct pci_dev *pdev,
 	common->ah =3D sc->ah;
 	common->hw =3D hw;
 	common->cachelsz =3D csz << 2; /* convert to bytes */
+	spin_lock_init(&common->cc_lock);
=20
 	/* Initialize device */
 	ret =3D ath5k_hw_attach(sc);
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_2p2_initvals.h b/dri=
vers/net/wireless/ath/ath9k/ar9003_2p2_initvals.h
index ec98ab5..a14a5e4 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_2p2_initvals.h
+++ b/drivers/net/wireless/ath/ath9k/ar9003_2p2_initvals.h
@@ -34,6 +34,10 @@ static const u32 ar9300_2p2_radio_postamble[][5] =3D=
 {
=20
 static const u32 ar9300Modes_lowest_ob_db_tx_gain_table_2p2[][5] =3D {
 	/* Addr      5G_HT20     5G_HT40     2G_HT40     2G_HT20   */
+	{0x0000a2dc, 0x0380c7fc, 0x0380c7fc, 0x00637800, 0x00637800},
+	{0x0000a2e0, 0x0000f800, 0x0000f800, 0x03838000, 0x03838000},
+	{0x0000a2e4, 0x03ff0000, 0x03ff0000, 0x03fc0000, 0x03fc0000},
+	{0x0000a2e8, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x0000a410, 0x000050d9, 0x000050d9, 0x000050d9, 0x000050d9},
 	{0x0000a500, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x0000a504, 0x06000003, 0x06000003, 0x04000002, 0x04000002},
@@ -99,6 +103,30 @@ static const u32 ar9300Modes_lowest_ob_db_tx_gain_t=
able_2p2[][5] =3D {
 	{0x0000a5f4, 0x7782b08c, 0x7782b08c, 0x5d801eec, 0x5d801eec},
 	{0x0000a5f8, 0x7782b08c, 0x7782b08c, 0x5d801eec, 0x5d801eec},
 	{0x0000a5fc, 0x7782b08c, 0x7782b08c, 0x5d801eec, 0x5d801eec},
+	{0x0000a600, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000a604, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000a608, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000a60c, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000a610, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000a614, 0x01404000, 0x01404000, 0x01404000, 0x01404000},
+	{0x0000a618, 0x01404501, 0x01404501, 0x01404501, 0x01404501},
+	{0x0000a61c, 0x02008802, 0x02008802, 0x02008501, 0x02008501},
+	{0x0000a620, 0x0300cc03, 0x0300cc03, 0x0280ca03, 0x0280ca03},
+	{0x0000a624, 0x0300cc03, 0x0300cc03, 0x03010c04, 0x03010c04},
+	{0x0000a628, 0x0300cc03, 0x0300cc03, 0x04014c04, 0x04014c04},
+	{0x0000a62c, 0x03810c03, 0x03810c03, 0x04015005, 0x04015005},
+	{0x0000a630, 0x03810e04, 0x03810e04, 0x04015005, 0x04015005},
+	{0x0000a634, 0x03810e04, 0x03810e04, 0x04015005, 0x04015005},
+	{0x0000a638, 0x03810e04, 0x03810e04, 0x04015005, 0x04015005},
+	{0x0000a63c, 0x03810e04, 0x03810e04, 0x04015005, 0x04015005},
+	{0x0000b2dc, 0x0380c7fc, 0x0380c7fc, 0x00637800, 0x00637800},
+	{0x0000b2e0, 0x0000f800, 0x0000f800, 0x03838000, 0x03838000},
+	{0x0000b2e4, 0x03ff0000, 0x03ff0000, 0x03fc0000, 0x03fc0000},
+	{0x0000b2e8, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000c2dc, 0x0380c7fc, 0x0380c7fc, 0x00637800, 0x00637800},
+	{0x0000c2e0, 0x0000f800, 0x0000f800, 0x03838000, 0x03838000},
+	{0x0000c2e4, 0x03ff0000, 0x03ff0000, 0x03fc0000, 0x03fc0000},
+	{0x0000c2e8, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x00016044, 0x012492d4, 0x012492d4, 0x012492d4, 0x012492d4},
 	{0x00016048, 0x62480001, 0x62480001, 0x62480001, 0x62480001},
 	{0x00016068, 0x6db6db6c, 0x6db6db6c, 0x6db6db6c, 0x6db6db6c},
@@ -118,7 +146,7 @@ static const u32 ar9300Modes_fast_clock_2p2[][3] =3D=
 {
 	{0x00008014, 0x044c044c, 0x08980898},
 	{0x0000801c, 0x148ec02b, 0x148ec057},
 	{0x00008318, 0x000044c0, 0x00008980},
-	{0x00009e00, 0x03721821, 0x03721821},
+	{0x00009e00, 0x0372131c, 0x0372131c},
 	{0x0000a230, 0x0000000b, 0x00000016},
 	{0x0000a254, 0x00000898, 0x00001130},
 };
@@ -595,15 +623,16 @@ static const u32 ar9300_2p2_baseband_postamble[][=
5] =3D {
 	{0x0000982c, 0x05eea6d4, 0x05eea6d4, 0x05eea6d4, 0x05eea6d4},
 	{0x00009830, 0x0000059c, 0x0000059c, 0x0000119c, 0x0000119c},
 	{0x00009c00, 0x000000c4, 0x000000c4, 0x000000c4, 0x000000c4},
-	{0x00009e00, 0x0372161e, 0x0372161e, 0x037216a0, 0x037216a0},
-	{0x00009e04, 0x00802020, 0x00802020, 0x00802020, 0x00802020},
+	{0x00009e00, 0x0372111a, 0x0372111a, 0x037216a0, 0x037216a0},
+	{0x00009e04, 0x001c2020, 0x001c2020, 0x001c2020, 0x001c2020},
 	{0x00009e0c, 0x6c4000e2, 0x6d4000e2, 0x6d4000e2, 0x6c4000e2},
 	{0x00009e10, 0x7ec88d2e, 0x7ec88d2e, 0x7ec84d2e, 0x7ec84d2e},
-	{0x00009e14, 0x31395d5e, 0x3139605e, 0x3139605e, 0x31395d5e},
+	{0x00009e14, 0x37b95d5e, 0x37b9605e, 0x3379605e, 0x33795d5e},
 	{0x00009e18, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x00009e1c, 0x0001cf9c, 0x0001cf9c, 0x00021f9c, 0x00021f9c},
 	{0x00009e20, 0x000003b5, 0x000003b5, 0x000003ce, 0x000003ce},
 	{0x00009e2c, 0x0000001c, 0x0000001c, 0x00000021, 0x00000021},
+	{0x00009e3c, 0xcf946220, 0xcf946220, 0xcf946222, 0xcf946222},
 	{0x00009e44, 0x02321e27, 0x02321e27, 0x02291e27, 0x02291e27},
 	{0x00009e48, 0x5030201a, 0x5030201a, 0x50302012, 0x50302012},
 	{0x00009fc8, 0x0003f000, 0x0003f000, 0x0001a000, 0x0001a000},
@@ -624,16 +653,16 @@ static const u32 ar9300_2p2_baseband_postamble[][=
5] =3D {
 	{0x0000a28c, 0x00022222, 0x00022222, 0x00022222, 0x00022222},
 	{0x0000a2c4, 0x00158d18, 0x00158d18, 0x00158d18, 0x00158d18},
 	{0x0000a2d0, 0x00071981, 0x00071981, 0x00071981, 0x00071982},
-	{0x0000a2d8, 0xf999a83a, 0xf999a83a, 0xf999a83a, 0xf999a83a},
+	{0x0000a2d8, 0x7999a83a, 0x7999a83a, 0x7999a83a, 0x7999a83a},
 	{0x0000a358, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x0000a830, 0x0000019c, 0x0000019c, 0x0000019c, 0x0000019c},
-	{0x0000ae04, 0x00800000, 0x00800000, 0x00800000, 0x00800000},
+	{0x0000ae04, 0x001c0000, 0x001c0000, 0x001c0000, 0x001c0000},
 	{0x0000ae18, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x0000ae1c, 0x0000019c, 0x0000019c, 0x0000019c, 0x0000019c},
 	{0x0000ae20, 0x000001b5, 0x000001b5, 0x000001ce, 0x000001ce},
 	{0x0000b284, 0x00000000, 0x00000000, 0x00000150, 0x00000150},
 	{0x0000b830, 0x0000019c, 0x0000019c, 0x0000019c, 0x0000019c},
-	{0x0000be04, 0x00800000, 0x00800000, 0x00800000, 0x00800000},
+	{0x0000be04, 0x001c0000, 0x001c0000, 0x001c0000, 0x001c0000},
 	{0x0000be18, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x0000be1c, 0x0000019c, 0x0000019c, 0x0000019c, 0x0000019c},
 	{0x0000be20, 0x000001b5, 0x000001b5, 0x000001ce, 0x000001ce},
@@ -649,13 +678,13 @@ static const u32 ar9300_2p2_baseband_core[][2] =3D=
 {
 	{0x00009814, 0x9280c00a},
 	{0x00009818, 0x00000000},
 	{0x0000981c, 0x00020028},
-	{0x00009834, 0x5f3ca3de},
+	{0x00009834, 0x6400a290},
 	{0x00009838, 0x0108ecff},
 	{0x0000983c, 0x14750600},
 	{0x00009880, 0x201fff00},
 	{0x00009884, 0x00001042},
 	{0x000098a4, 0x00200400},
-	{0x000098b0, 0x52440bbe},
+	{0x000098b0, 0x32840bbe},
 	{0x000098d0, 0x004b6a8e},
 	{0x000098d4, 0x00000820},
 	{0x000098dc, 0x00000000},
@@ -681,7 +710,6 @@ static const u32 ar9300_2p2_baseband_core[][2] =3D =
{
 	{0x00009e30, 0x06336f77},
 	{0x00009e34, 0x6af6532f},
 	{0x00009e38, 0x0cc80c00},
-	{0x00009e3c, 0xcf946222},
 	{0x00009e40, 0x0d261820},
 	{0x00009e4c, 0x00001004},
 	{0x00009e50, 0x00ff03f1},
@@ -694,7 +722,7 @@ static const u32 ar9300_2p2_baseband_core[][2] =3D =
{
 	{0x0000a220, 0x00000000},
 	{0x0000a224, 0x00000000},
 	{0x0000a228, 0x10002310},
-	{0x0000a22c, 0x01036a1e},
+	{0x0000a22c, 0x01036a27},
 	{0x0000a23c, 0x00000000},
 	{0x0000a244, 0x0c000000},
 	{0x0000a2a0, 0x00000001},
@@ -702,10 +730,6 @@ static const u32 ar9300_2p2_baseband_core[][2] =3D=
 {
 	{0x0000a2c8, 0x00000000},
 	{0x0000a2cc, 0x18c43433},
 	{0x0000a2d4, 0x00000000},
-	{0x0000a2dc, 0x00000000},
-	{0x0000a2e0, 0x00000000},
-	{0x0000a2e4, 0x00000000},
-	{0x0000a2e8, 0x00000000},
 	{0x0000a2ec, 0x00000000},
 	{0x0000a2f0, 0x00000000},
 	{0x0000a2f4, 0x00000000},
@@ -753,33 +777,17 @@ static const u32 ar9300_2p2_baseband_core[][2] =3D=
 {
 	{0x0000a430, 0x1ce739ce},
 	{0x0000a434, 0x00000000},
 	{0x0000a438, 0x00001801},
-	{0x0000a43c, 0x00000000},
+	{0x0000a43c, 0x00100000},
 	{0x0000a440, 0x00000000},
 	{0x0000a444, 0x00000000},
 	{0x0000a448, 0x06000080},
 	{0x0000a44c, 0x00000001},
 	{0x0000a450, 0x00010000},
 	{0x0000a458, 0x00000000},
-	{0x0000a600, 0x00000000},
-	{0x0000a604, 0x00000000},
-	{0x0000a608, 0x00000000},
-	{0x0000a60c, 0x00000000},
-	{0x0000a610, 0x00000000},
-	{0x0000a614, 0x00000000},
-	{0x0000a618, 0x00000000},
-	{0x0000a61c, 0x00000000},
-	{0x0000a620, 0x00000000},
-	{0x0000a624, 0x00000000},
-	{0x0000a628, 0x00000000},
-	{0x0000a62c, 0x00000000},
-	{0x0000a630, 0x00000000},
-	{0x0000a634, 0x00000000},
-	{0x0000a638, 0x00000000},
-	{0x0000a63c, 0x00000000},
 	{0x0000a640, 0x00000000},
 	{0x0000a644, 0x3fad9d74},
 	{0x0000a648, 0x0048060a},
-	{0x0000a64c, 0x00000637},
+	{0x0000a64c, 0x00003c37},
 	{0x0000a670, 0x03020100},
 	{0x0000a674, 0x09080504},
 	{0x0000a678, 0x0d0c0b0a},
@@ -802,10 +810,6 @@ static const u32 ar9300_2p2_baseband_core[][2] =3D=
 {
 	{0x0000a8f4, 0x00000000},
 	{0x0000b2d0, 0x00000080},
 	{0x0000b2d4, 0x00000000},
-	{0x0000b2dc, 0x00000000},
-	{0x0000b2e0, 0x00000000},
-	{0x0000b2e4, 0x00000000},
-	{0x0000b2e8, 0x00000000},
 	{0x0000b2ec, 0x00000000},
 	{0x0000b2f0, 0x00000000},
 	{0x0000b2f4, 0x00000000},
@@ -820,10 +824,6 @@ static const u32 ar9300_2p2_baseband_core[][2] =3D=
 {
 	{0x0000b8f4, 0x00000000},
 	{0x0000c2d0, 0x00000080},
 	{0x0000c2d4, 0x00000000},
-	{0x0000c2dc, 0x00000000},
-	{0x0000c2e0, 0x00000000},
-	{0x0000c2e4, 0x00000000},
-	{0x0000c2e8, 0x00000000},
 	{0x0000c2ec, 0x00000000},
 	{0x0000c2f0, 0x00000000},
 	{0x0000c2f4, 0x00000000},
@@ -835,6 +835,10 @@ static const u32 ar9300_2p2_baseband_core[][2] =3D=
 {
=20
 static const u32 ar9300Modes_high_power_tx_gain_table_2p2[][5] =3D {
 	/* Addr      5G_HT20     5G_HT40     2G_HT40     2G_HT20   */
+	{0x0000a2dc, 0x0380c7fc, 0x0380c7fc, 0x00637800, 0x00637800},
+	{0x0000a2e0, 0x0000f800, 0x0000f800, 0x03838000, 0x03838000},
+	{0x0000a2e4, 0x03ff0000, 0x03ff0000, 0x03fc0000, 0x03fc0000},
+	{0x0000a2e8, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x0000a410, 0x000050d8, 0x000050d8, 0x000050d9, 0x000050d9},
 	{0x0000a500, 0x00002220, 0x00002220, 0x00000000, 0x00000000},
 	{0x0000a504, 0x04002222, 0x04002222, 0x04000002, 0x04000002},
@@ -855,7 +859,7 @@ static const u32 ar9300Modes_high_power_tx_gain_tab=
le_2p2[][5] =3D {
 	{0x0000a540, 0x49005e72, 0x49005e72, 0x38001660, 0x38001660},
 	{0x0000a544, 0x4e005eb2, 0x4e005eb2, 0x3b001861, 0x3b001861},
 	{0x0000a548, 0x53005f12, 0x53005f12, 0x3e001a81, 0x3e001a81},
-	{0x0000a54c, 0x59025eb5, 0x59025eb5, 0x42001a83, 0x42001a83},
+	{0x0000a54c, 0x59025eb2, 0x59025eb2, 0x42001a83, 0x42001a83},
 	{0x0000a550, 0x5e025f12, 0x5e025f12, 0x44001c84, 0x44001c84},
 	{0x0000a554, 0x61027f12, 0x61027f12, 0x48001ce3, 0x48001ce3},
 	{0x0000a558, 0x6702bf12, 0x6702bf12, 0x4c001ce5, 0x4c001ce5},
@@ -900,6 +904,30 @@ static const u32 ar9300Modes_high_power_tx_gain_ta=
ble_2p2[][5] =3D {
 	{0x0000a5f4, 0x6f82bf16, 0x6f82bf16, 0x56801eec, 0x56801eec},
 	{0x0000a5f8, 0x6f82bf16, 0x6f82bf16, 0x56801eec, 0x56801eec},
 	{0x0000a5fc, 0x6f82bf16, 0x6f82bf16, 0x56801eec, 0x56801eec},
+	{0x0000a600, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000a604, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000a608, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000a60c, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000a610, 0x00804000, 0x00804000, 0x00000000, 0x00000000},
+	{0x0000a614, 0x00804201, 0x00804201, 0x01404000, 0x01404000},
+	{0x0000a618, 0x0280c802, 0x0280c802, 0x01404501, 0x01404501},
+	{0x0000a61c, 0x0280ca03, 0x0280ca03, 0x02008501, 0x02008501},
+	{0x0000a620, 0x04c15104, 0x04c15104, 0x0280ca03, 0x0280ca03},
+	{0x0000a624, 0x04c15305, 0x04c15305, 0x03010c04, 0x03010c04},
+	{0x0000a628, 0x04c15305, 0x04c15305, 0x04014c04, 0x04014c04},
+	{0x0000a62c, 0x04c15305, 0x04c15305, 0x04015005, 0x04015005},
+	{0x0000a630, 0x04c15305, 0x04c15305, 0x04015005, 0x04015005},
+	{0x0000a634, 0x04c15305, 0x04c15305, 0x04015005, 0x04015005},
+	{0x0000a638, 0x04c15305, 0x04c15305, 0x04015005, 0x04015005},
+	{0x0000a63c, 0x04c15305, 0x04c15305, 0x04015005, 0x04015005},
+	{0x0000b2dc, 0x0380c7fc, 0x0380c7fc, 0x00637800, 0x00637800},
+	{0x0000b2e0, 0x0000f800, 0x0000f800, 0x03838000, 0x03838000},
+	{0x0000b2e4, 0x03ff0000, 0x03ff0000, 0x03fc0000, 0x03fc0000},
+	{0x0000b2e8, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000c2dc, 0x0380c7fc, 0x0380c7fc, 0x00637800, 0x00637800},
+	{0x0000c2e0, 0x0000f800, 0x0000f800, 0x03838000, 0x03838000},
+	{0x0000c2e4, 0x03ff0000, 0x03ff0000, 0x03fc0000, 0x03fc0000},
+	{0x0000c2e8, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x00016044, 0x056db2e6, 0x056db2e6, 0x056db2e6, 0x056db2e6},
 	{0x00016048, 0xae480001, 0xae480001, 0xae480001, 0xae480001},
 	{0x00016068, 0x6eb6db6c, 0x6eb6db6c, 0x6eb6db6c, 0x6eb6db6c},
@@ -913,6 +941,10 @@ static const u32 ar9300Modes_high_power_tx_gain_ta=
ble_2p2[][5] =3D {
=20
 static const u32 ar9300Modes_high_ob_db_tx_gain_table_2p2[][5] =3D {
 	/* Addr      5G_HT20     5G_HT40     2G_HT40     2G_HT20   */
+	{0x0000a2dc, 0x01feee00, 0x01feee00, 0x00637800, 0x00637800},
+	{0x0000a2e0, 0x0000f000, 0x0000f000, 0x03838000, 0x03838000},
+	{0x0000a2e4, 0x01ff0000, 0x01ff0000, 0x03fc0000, 0x03fc0000},
+	{0x0000a2e8, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x0000a410, 0x000050d8, 0x000050d8, 0x000050d9, 0x000050d9},
 	{0x0000a500, 0x00002220, 0x00002220, 0x00000000, 0x00000000},
 	{0x0000a504, 0x04002222, 0x04002222, 0x04000002, 0x04000002},
@@ -933,7 +965,7 @@ static const u32 ar9300Modes_high_ob_db_tx_gain_tab=
le_2p2[][5] =3D {
 	{0x0000a540, 0x49005e72, 0x49005e72, 0x38001660, 0x38001660},
 	{0x0000a544, 0x4e005eb2, 0x4e005eb2, 0x3b001861, 0x3b001861},
 	{0x0000a548, 0x53005f12, 0x53005f12, 0x3e001a81, 0x3e001a81},
-	{0x0000a54c, 0x59025eb5, 0x59025eb5, 0x42001a83, 0x42001a83},
+	{0x0000a54c, 0x59025eb2, 0x59025eb2, 0x42001a83, 0x42001a83},
 	{0x0000a550, 0x5e025f12, 0x5e025f12, 0x44001c84, 0x44001c84},
 	{0x0000a554, 0x61027f12, 0x61027f12, 0x48001ce3, 0x48001ce3},
 	{0x0000a558, 0x6702bf12, 0x6702bf12, 0x4c001ce5, 0x4c001ce5},
@@ -978,6 +1010,30 @@ static const u32 ar9300Modes_high_ob_db_tx_gain_t=
able_2p2[][5] =3D {
 	{0x0000a5f4, 0x6f82bf16, 0x6f82bf16, 0x56801eec, 0x56801eec},
 	{0x0000a5f8, 0x6f82bf16, 0x6f82bf16, 0x56801eec, 0x56801eec},
 	{0x0000a5fc, 0x6f82bf16, 0x6f82bf16, 0x56801eec, 0x56801eec},
+	{0x0000a600, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000a604, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000a608, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000a60c, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000a610, 0x00804000, 0x00804000, 0x00000000, 0x00000000},
+	{0x0000a614, 0x00804201, 0x00804201, 0x01404000, 0x01404000},
+	{0x0000a618, 0x0280c802, 0x0280c802, 0x01404501, 0x01404501},
+	{0x0000a61c, 0x0280ca03, 0x0280ca03, 0x02008501, 0x02008501},
+	{0x0000a620, 0x04c15104, 0x04c15104, 0x0280ca03, 0x0280ca03},
+	{0x0000a624, 0x04c15305, 0x04c15305, 0x03010c04, 0x03010c04},
+	{0x0000a628, 0x04c15305, 0x04c15305, 0x04014c04, 0x04014c04},
+	{0x0000a62c, 0x04c15305, 0x04c15305, 0x04015005, 0x04015005},
+	{0x0000a630, 0x04c15305, 0x04c15305, 0x04015005, 0x04015005},
+	{0x0000a634, 0x04c15305, 0x04c15305, 0x04015005, 0x04015005},
+	{0x0000a638, 0x04c15305, 0x04c15305, 0x04015005, 0x04015005},
+	{0x0000a63c, 0x04c15305, 0x04c15305, 0x04015005, 0x04015005},
+	{0x0000b2dc, 0x01feee00, 0x01feee00, 0x00637800, 0x00637800},
+	{0x0000b2e0, 0x0000f000, 0x0000f000, 0x03838000, 0x03838000},
+	{0x0000b2e4, 0x01ff0000, 0x01ff0000, 0x03fc0000, 0x03fc0000},
+	{0x0000b2e8, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000c2dc, 0x01feee00, 0x01feee00, 0x00637800, 0x00637800},
+	{0x0000c2e0, 0x0000f000, 0x0000f000, 0x03838000, 0x03838000},
+	{0x0000c2e4, 0x01ff0000, 0x01ff0000, 0x03fc0000, 0x03fc0000},
+	{0x0000c2e8, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x00016044, 0x056db2e4, 0x056db2e4, 0x056db2e4, 0x056db2e4},
 	{0x00016048, 0x8e480001, 0x8e480001, 0x8e480001, 0x8e480001},
 	{0x00016068, 0x6db6db6c, 0x6db6db6c, 0x6db6db6c, 0x6db6db6c},
@@ -1151,14 +1207,14 @@ static const u32 ar9300Common_rx_gain_table_2p2=
[][2] =3D {
 	{0x0000b074, 0x00000000},
 	{0x0000b078, 0x00000000},
 	{0x0000b07c, 0x00000000},
-	{0x0000b080, 0x32323232},
-	{0x0000b084, 0x2f2f3232},
-	{0x0000b088, 0x23282a2d},
-	{0x0000b08c, 0x1c1e2123},
-	{0x0000b090, 0x14171919},
-	{0x0000b094, 0x0e0e1214},
-	{0x0000b098, 0x03050707},
-	{0x0000b09c, 0x00030303},
+	{0x0000b080, 0x2a2d2f32},
+	{0x0000b084, 0x21232328},
+	{0x0000b088, 0x19191c1e},
+	{0x0000b08c, 0x12141417},
+	{0x0000b090, 0x07070e0e},
+	{0x0000b094, 0x03030305},
+	{0x0000b098, 0x00000003},
+	{0x0000b09c, 0x00000000},
 	{0x0000b0a0, 0x00000000},
 	{0x0000b0a4, 0x00000000},
 	{0x0000b0a8, 0x00000000},
@@ -1251,6 +1307,10 @@ static const u32 ar9300Common_rx_gain_table_2p2[=
][2] =3D {
=20
 static const u32 ar9300Modes_low_ob_db_tx_gain_table_2p2[][5] =3D {
 	/* Addr      5G_HT20     5G_HT40     2G_HT40     2G_HT20   */
+	{0x0000a2dc, 0x0380c7fc, 0x0380c7fc, 0x00637800, 0x00637800},
+	{0x0000a2e0, 0x0000f800, 0x0000f800, 0x03838000, 0x03838000},
+	{0x0000a2e4, 0x03ff0000, 0x03ff0000, 0x03fc0000, 0x03fc0000},
+	{0x0000a2e8, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x0000a410, 0x000050d9, 0x000050d9, 0x000050d9, 0x000050d9},
 	{0x0000a500, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x0000a504, 0x06000003, 0x06000003, 0x04000002, 0x04000002},
@@ -1316,6 +1376,30 @@ static const u32 ar9300Modes_low_ob_db_tx_gain_t=
able_2p2[][5] =3D {
 	{0x0000a5f4, 0x7782b08c, 0x7782b08c, 0x5d801eec, 0x5d801eec},
 	{0x0000a5f8, 0x7782b08c, 0x7782b08c, 0x5d801eec, 0x5d801eec},
 	{0x0000a5fc, 0x7782b08c, 0x7782b08c, 0x5d801eec, 0x5d801eec},
+	{0x0000a600, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000a604, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000a608, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000a60c, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000a610, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000a614, 0x01404000, 0x01404000, 0x01404000, 0x01404000},
+	{0x0000a618, 0x01404501, 0x01404501, 0x01404501, 0x01404501},
+	{0x0000a61c, 0x02008802, 0x02008802, 0x02008501, 0x02008501},
+	{0x0000a620, 0x0300cc03, 0x0300cc03, 0x0280ca03, 0x0280ca03},
+	{0x0000a624, 0x0300cc03, 0x0300cc03, 0x03010c04, 0x03010c04},
+	{0x0000a628, 0x0300cc03, 0x0300cc03, 0x04014c04, 0x04014c04},
+	{0x0000a62c, 0x03810c03, 0x03810c03, 0x04015005, 0x04015005},
+	{0x0000a630, 0x03810e04, 0x03810e04, 0x04015005, 0x04015005},
+	{0x0000a634, 0x03810e04, 0x03810e04, 0x04015005, 0x04015005},
+	{0x0000a638, 0x03810e04, 0x03810e04, 0x04015005, 0x04015005},
+	{0x0000a63c, 0x03810e04, 0x03810e04, 0x04015005, 0x04015005},
+	{0x0000b2dc, 0x0380c7fc, 0x0380c7fc, 0x00637800, 0x00637800},
+	{0x0000b2e0, 0x0000f800, 0x0000f800, 0x03838000, 0x03838000},
+	{0x0000b2e4, 0x03ff0000, 0x03ff0000, 0x03fc0000, 0x03fc0000},
+	{0x0000b2e8, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
+	{0x0000c2dc, 0x0380c7fc, 0x0380c7fc, 0x00637800, 0x00637800},
+	{0x0000c2e0, 0x0000f800, 0x0000f800, 0x03838000, 0x03838000},
+	{0x0000c2e4, 0x03ff0000, 0x03ff0000, 0x03fc0000, 0x03fc0000},
+	{0x0000c2e8, 0x00000000, 0x00000000, 0x00000000, 0x00000000},
 	{0x00016044, 0x012492d4, 0x012492d4, 0x012492d4, 0x012492d4},
 	{0x00016048, 0x66480001, 0x66480001, 0x66480001, 0x66480001},
 	{0x00016068, 0x6db6db6c, 0x6db6db6c, 0x6db6db6c, 0x6db6db6c},
@@ -1414,15 +1498,10 @@ static const u32 ar9300_2p2_mac_core[][2] =3D {
 	{0x00008144, 0xffffffff},
 	{0x00008168, 0x00000000},
 	{0x0000816c, 0x00000000},
-	{0x00008170, 0x18486200},
-	{0x00008174, 0x33332210},
-	{0x00008178, 0x00000000},
-	{0x0000817c, 0x00020000},
 	{0x000081c0, 0x00000000},
 	{0x000081c4, 0x33332210},
 	{0x000081c8, 0x00000000},
 	{0x000081cc, 0x00000000},
-	{0x000081d4, 0x00000000},
 	{0x000081ec, 0x00000000},
 	{0x000081f0, 0x00000000},
 	{0x000081f4, 0x00000000},
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_paprd.c b/drivers/ne=
t/wireless/ath/ath9k/ar9003_paprd.c
index 7c38229..716db41 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_paprd.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_paprd.c
@@ -347,6 +347,10 @@ static bool create_pa_curve(u32 *data_L, u32 *data=
_U, u32 *pa_table, u16 *gain)
 	    (((Y[6] - Y[3]) * 1 << scale_factor) +
 	     (x_est[6] - x_est[3])) / (x_est[6] - x_est[3]);
=20
+	/* prevent division by zero */
+	if (G_fxp =3D=3D 0)
+		return false;
+
 	Y_intercept =3D
 	    (G_fxp * (x_est[0] - x_est[3]) +
 	     (1 << scale_factor)) / (1 << scale_factor) + Y[3];
@@ -356,14 +360,12 @@ static bool create_pa_curve(u32 *data_L, u32 *dat=
a_U, u32 *pa_table, u16 *gain)
=20
 	for (i =3D 0; i <=3D 3; i++) {
 		y_est[i] =3D i * 32;
-
-		/* prevent division by zero */
-		if (G_fxp =3D=3D 0)
-			return false;
-
 		x_est[i] =3D ((y_est[i] * 1 << scale_factor) + G_fxp) / G_fxp;
 	}
=20
+	if (y_est[max_index] =3D=3D 0)
+		return false;
+
 	x_est_fxp1_nonlin =3D
 	    x_est[max_index] - ((1 << scale_factor) * y_est[max_index] +
 				G_fxp) / G_fxp;
@@ -457,6 +459,8 @@ static bool create_pa_curve(u32 *data_L, u32 *data_=
U, u32 *pa_table, u16 *gain)
=20
 	Q_scale_B =3D find_proper_scale(find_expn(abs(scale_B)), 10);
 	scale_B =3D scale_B / (1 << Q_scale_B);
+	if (scale_B =3D=3D 0)
+		return false;
 	Q_beta =3D find_proper_scale(find_expn(abs(beta_raw)), 10);
 	Q_alpha =3D find_proper_scale(find_expn(abs(alpha_raw)), 10);
 	beta_raw =3D beta_raw / (1 << Q_beta);
diff --git a/drivers/net/wireless/ath/ath9k/beacon.c b/drivers/net/wire=
less/ath/ath9k/beacon.c
index 4ed010d..19891e7 100644
--- a/drivers/net/wireless/ath/ath9k/beacon.c
+++ b/drivers/net/wireless/ath/ath9k/beacon.c
@@ -370,7 +370,7 @@ void ath_beacon_tasklet(unsigned long data)
 			ath_print(common, ATH_DBG_BSTUCK,
 				  "beacon is officially stuck\n");
 			sc->sc_flags |=3D SC_OP_TSF_RESET;
-			ath_reset(sc, false);
+			ath_reset(sc, true);
 		}
=20
 		return;
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wirele=
ss/ath/ath9k/init.c
index bc6c4df..95b41db 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -577,6 +577,7 @@ static int ath9k_init_softc(u16 devid, struct ath_s=
oftc *sc, u16 subsysid,
 	common->hw =3D sc->hw;
 	common->priv =3D sc;
 	common->debug_mask =3D ath9k_debug;
+	spin_lock_init(&common->cc_lock);
=20
 	spin_lock_init(&sc->wiphy_lock);
 	spin_lock_init(&sc->sc_resetlock);
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wirele=
ss/ath/ath9k/main.c
index 3ff0e47..c6ec800 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -182,6 +182,9 @@ static void ath_update_survey_stats(struct ath_soft=
c *sc)
 	struct ath_cycle_counters *cc =3D &common->cc_survey;
 	unsigned int div =3D common->clockrate * 1000;
=20
+	if (!ah->curchan)
+		return;
+
 	if (ah->power_mode =3D=3D ATH9K_PM_AWAKE)
 		ath_hw_cycle_counters_update(common);
=20
@@ -577,7 +580,7 @@ void ath_hw_check(struct work_struct *work)
=20
 		msleep(1);
 	}
-	ath_reset(sc, false);
+	ath_reset(sc, true);
=20
 out:
 	ath9k_ps_restore(sc);
@@ -595,7 +598,7 @@ void ath9k_tasklet(unsigned long data)
 	ath9k_ps_wakeup(sc);
=20
 	if (status & ATH9K_INT_FATAL) {
-		ath_reset(sc, false);
+		ath_reset(sc, true);
 		ath9k_ps_restore(sc);
 		return;
 	}
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wirele=
ss/ath/ath9k/xmit.c
index d077186..30ef2df 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -673,6 +673,7 @@ static enum ATH_AGGR_STATUS ath_tx_form_aggr(struct=
 ath_softc *sc,
 	u16 aggr_limit =3D 0, al =3D 0, bpad =3D 0,
 		al_delta, h_baw =3D tid->baw_size / 2;
 	enum ATH_AGGR_STATUS status =3D ATH_AGGR_DONE;
+	struct ieee80211_tx_info *tx_info;
=20
 	bf_first =3D list_first_entry(&tid->buf_q, struct ath_buf, list);
=20
@@ -699,6 +700,11 @@ static enum ATH_AGGR_STATUS ath_tx_form_aggr(struc=
t ath_softc *sc,
 			break;
 		}
=20
+		tx_info =3D IEEE80211_SKB_CB(bf->bf_mpdu);
+		if (nframes && ((tx_info->flags & IEEE80211_TX_CTL_RATE_CTRL_PROBE) =
||
+			!(tx_info->control.rates[0].flags & IEEE80211_TX_RC_MCS)))
+			break;
+
 		/* do not exceed subframe limit */
 		if (nframes >=3D min((int)h_baw, ATH_AMPDU_SUBFRAME_DEFAULT)) {
 			status =3D ATH_AGGR_LIMITED;
@@ -2157,7 +2163,7 @@ static void ath_tx_complete_poll_work(struct work=
_struct *work)
 		ath_print(ath9k_hw_common(sc->sc_ah), ATH_DBG_RESET,
 			  "tx hung, resetting the chip\n");
 		ath9k_ps_wakeup(sc);
-		ath_reset(sc, false);
+		ath_reset(sc, true);
 		ath9k_ps_restore(sc);
 	}
=20
diff --git a/drivers/net/wireless/ath/carl9170/cmd.h b/drivers/net/wire=
less/ath/carl9170/cmd.h
index f78728c..568174c 100644
--- a/drivers/net/wireless/ath/carl9170/cmd.h
+++ b/drivers/net/wireless/ath/carl9170/cmd.h
@@ -116,8 +116,9 @@ __regwrite_out :							\
 } while (0);
=20
=20
-#define carl9170_async_get_buf()					\
+#define carl9170_async_regwrite_get_buf()				\
 do {									\
+	__nreg =3D 0;							\
 	__cmd =3D carl9170_cmd_buf(__carl, CARL9170_CMD_WREG_ASYNC,	\
 				 CARL9170_MAX_CMD_PAYLOAD_LEN);		\
 	if (__cmd =3D=3D NULL) {						\
@@ -128,38 +129,42 @@ do {									\
=20
 #define carl9170_async_regwrite_begin(carl)				\
 do {									\
-	int __nreg =3D 0, __err =3D 0;					\
 	struct ar9170 *__carl =3D carl;					\
 	struct carl9170_cmd *__cmd;					\
-	carl9170_async_get_buf();					\
+	unsigned int __nreg;						\
+	int  __err =3D 0;							\
+	carl9170_async_regwrite_get_buf();				\
+
+#define carl9170_async_regwrite_flush()					\
+do {									\
+	if (__cmd =3D=3D NULL || __nreg =3D=3D 0)				\
+		break;							\
+									\
+	if (IS_ACCEPTING_CMD(__carl) && __nreg) {			\
+		__cmd->hdr.len =3D 8 * __nreg;				\
+		__err =3D __carl9170_exec_cmd(__carl, __cmd, true);	\
+		__cmd =3D NULL;						\
+		break;							\
+	}								\
+	goto __async_regwrite_out;					\
+} while (0)
=20
 #define carl9170_async_regwrite(r, v) do {				\
+	if (__cmd =3D=3D NULL)						\
+		carl9170_async_regwrite_get_buf();			\
 	__cmd->wreg.regs[__nreg].addr =3D cpu_to_le32(r);			\
 	__cmd->wreg.regs[__nreg].val =3D cpu_to_le32(v);			\
 	__nreg++;							\
-	if ((__nreg >=3D PAYLOAD_MAX/2)) {				\
-		if (IS_ACCEPTING_CMD(__carl)) {				\
-			__cmd->hdr.len =3D 8 * __nreg;			\
-			__err =3D __carl9170_exec_cmd(__carl, __cmd, true);\
-			__cmd =3D NULL;					\
-			carl9170_async_get_buf();			\
-		} else {						\
-			goto __async_regwrite_out;			\
-		}							\
-		__nreg =3D 0;						\
-		if (__err)						\
-			goto __async_regwrite_out;			\
-	}								\
+	if ((__nreg >=3D PAYLOAD_MAX / 2))				\
+		carl9170_async_regwrite_flush();			\
 } while (0)
=20
-#define carl9170_async_regwrite_finish()				\
+#define carl9170_async_regwrite_finish() do {				\
 __async_regwrite_out :							\
-	if (__err =3D=3D 0 && __nreg) {					\
-		__cmd->hdr.len =3D 8 * __nreg;				\
-		if (IS_ACCEPTING_CMD(__carl))				\
-			__err =3D __carl9170_exec_cmd(__carl, __cmd, true);\
-		__nreg =3D 0;						\
-	}
+	if (__cmd !=3D NULL && __err =3D=3D 0)				\
+		carl9170_async_regwrite_flush();			\
+	kfree(__cmd);							\
+} while (0)								\
=20
 #define carl9170_async_regwrite_result()				\
 	__err;								\
diff --git a/drivers/net/wireless/ath/carl9170/main.c b/drivers/net/wir=
eless/ath/carl9170/main.c
index 3cc99f3..980ae70 100644
--- a/drivers/net/wireless/ath/carl9170/main.c
+++ b/drivers/net/wireless/ath/carl9170/main.c
@@ -639,8 +639,8 @@ init:
 		if (err)
 			goto unlock;
 	} else {
-		err =3D carl9170_mod_virtual_mac(ar, vif_id, vif->addr);
 		rcu_read_unlock();
+		err =3D carl9170_mod_virtual_mac(ar, vif_id, vif->addr);
=20
 		if (err)
 			goto unlock;
diff --git a/drivers/net/wireless/ath/carl9170/usb.c b/drivers/net/wire=
less/ath/carl9170/usb.c
index c7f6193..d8607f4 100644
--- a/drivers/net/wireless/ath/carl9170/usb.c
+++ b/drivers/net/wireless/ath/carl9170/usb.c
@@ -591,16 +591,23 @@ int __carl9170_exec_cmd(struct ar9170 *ar, struct=
 carl9170_cmd *cmd,
 			const bool free_buf)
 {
 	struct urb *urb;
+	int err =3D 0;
=20
-	if (!IS_INITIALIZED(ar))
-		return -EPERM;
+	if (!IS_INITIALIZED(ar)) {
+		err =3D -EPERM;
+		goto err_free;
+	}
=20
-	if (WARN_ON(cmd->hdr.len > CARL9170_MAX_CMD_LEN - 4))
-		return -EINVAL;
+	if (WARN_ON(cmd->hdr.len > CARL9170_MAX_CMD_LEN - 4)) {
+		err =3D -EINVAL;
+		goto err_free;
+	}
=20
 	urb =3D usb_alloc_urb(0, GFP_ATOMIC);
-	if (!urb)
-		return -ENOMEM;
+	if (!urb) {
+		err =3D -ENOMEM;
+		goto err_free;
+	}
=20
 	usb_fill_int_urb(urb, ar->udev, usb_sndintpipe(ar->udev,
 		AR9170_USB_EP_CMD), cmd, cmd->hdr.len + 4,
@@ -613,6 +620,12 @@ int __carl9170_exec_cmd(struct ar9170 *ar, struct =
carl9170_cmd *cmd,
 	usb_free_urb(urb);
=20
 	return carl9170_usb_submit_cmd_urb(ar);
+
+err_free:
+	if (free_buf)
+		kfree(cmd);
+
+	return err;
 }
=20
 int carl9170_exec_cmd(struct ar9170 *ar, const enum carl9170_cmd_oids =
cmd,
diff --git a/drivers/net/wireless/b43/phy_n.c b/drivers/net/wireless/b4=
3/phy_n.c
index dfec549..e0f2d12 100644
--- a/drivers/net/wireless/b43/phy_n.c
+++ b/drivers/net/wireless/b43/phy_n.c
@@ -2964,7 +2964,7 @@ static int b43_nphy_rev2_cal_rx_iq(struct b43_wld=
ev *dev,
 					(2 - i));
 		}
=20
-		for (j =3D 0; i < 4; j++) {
+		for (j =3D 0; j < 4; j++) {
 			if (j < 3) {
 				cur_lna =3D lna[j];
 				cur_hpf1 =3D hpf1[j];
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-tx.c b/drivers/net/wi=
reless/iwlwifi/iwl-agn-tx.c
index db57aea..2b078a9 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
@@ -1227,7 +1227,8 @@ static int iwlagn_tx_status_reply_compressed_ba(s=
truct iwl_priv *priv,
 	struct ieee80211_tx_info *info;
=20
 	if (unlikely(!agg->wait_for_ba))  {
-		IWL_ERR(priv, "Received BA when not expected\n");
+		if (unlikely(ba_resp->bitmap))
+			IWL_ERR(priv, "Received BA when not expected\n");
 		return -EINVAL;
 	}
=20
diff --git a/drivers/net/wireless/wl1251/Makefile b/drivers/net/wireles=
s/wl1251/Makefile
index 4fe2468..58b4f93 100644
--- a/drivers/net/wireless/wl1251/Makefile
+++ b/drivers/net/wireless/wl1251/Makefile
@@ -1,6 +1,8 @@
 wl1251-objs		=3D main.o event.o tx.o rx.o ps.o cmd.o \
 			  acx.o boot.o init.o debugfs.o io.o
+wl1251_spi-objs		+=3D spi.o
+wl1251_sdio-objs	+=3D sdio.o
=20
-obj-$(CONFIG_WL1251)	+=3D wl1251.o
-obj-$(CONFIG_WL1251_SPI)	+=3D spi.o
-obj-$(CONFIG_WL1251_SDIO)	+=3D sdio.o
+obj-$(CONFIG_WL1251)		+=3D wl1251.o
+obj-$(CONFIG_WL1251_SPI)	+=3D wl1251_spi.o
+obj-$(CONFIG_WL1251_SDIO)	+=3D wl1251_sdio.o
diff --git a/net/mac80211/ibss.c b/net/mac80211/ibss.c
index ff60c02..239c483 100644
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@ -456,6 +456,7 @@ struct sta_info *ieee80211_ibss_add_sta(struct ieee=
80211_sub_if_data *sdata,
 	if (!sta)
 		return NULL;
=20
+	sta->last_rx =3D jiffies;
 	set_sta_flags(sta, WLAN_STA_AUTHORIZED);
=20
 	/* make sure mandatory rates are always added */
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 22bc42b..6b322fa 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -748,7 +748,7 @@ int ieee80211_register_hw(struct ieee80211_hw *hw)
 		hw->queues =3D IEEE80211_MAX_QUEUES;
=20
 	local->workqueue =3D
-		create_singlethread_workqueue(wiphy_name(local->hw.wiphy));
+		alloc_ordered_workqueue(wiphy_name(local->hw.wiphy), 0);
 	if (!local->workqueue) {
 		result =3D -ENOMEM;
 		goto fail_workqueue;
@@ -962,12 +962,6 @@ static void __exit ieee80211_exit(void)
 	rc80211_minstrel_ht_exit();
 	rc80211_minstrel_exit();
=20
-	/*
-	 * For key todo, it'll be empty by now but the work
-	 * might still be scheduled.
-	 */
-	flush_scheduled_work();
-
 	if (mesh_allocated)
 		ieee80211s_stop();
=20
diff --git a/net/mac80211/rate.c b/net/mac80211/rate.c
index 809cf23..33f7699 100644
--- a/net/mac80211/rate.c
+++ b/net/mac80211/rate.c
@@ -329,6 +329,9 @@ void rate_control_get_rate(struct ieee80211_sub_if_=
data *sdata,
 		 * if needed.
 		 */
 		for (i =3D 0; i < IEEE80211_TX_MAX_RATES; i++) {
+			/* Skip invalid rates */
+			if (info->control.rates[i].idx < 0)
+				break;
 			/* Rate masking supports only legacy rates for now */
 			if (info->control.rates[i].flags & IEEE80211_TX_RC_MCS)
 				continue;
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index d14bbf9..4b9f891 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -1167,7 +1167,7 @@ static int ignore_request(struct wiphy *wiphy,
 				return 0;
 			return -EALREADY;
 		}
-		return REG_INTERSECT;
+		return 0;
 	case NL80211_REGDOM_SET_BY_DRIVER:
 		if (last_request->initiator =3D=3D NL80211_REGDOM_SET_BY_CORE) {
 			if (regdom_changes(pending_request->alpha2))
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
