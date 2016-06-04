From: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH v2 2/2] b43: Completely remove support for phy_a
Date: Fri,  3 Jun 2016 21:11:52 -0700
Message-ID: <1465013512-30301-2-git-send-email-linux@roeck-us.net>
References: <1465013512-30301-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, m@bues.ch,
	Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1465013512-30301-1-git-send-email-linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Per Michael B=C3=BCsch: "All a-phy code is usused", so remove it all.

Signed-off-by: Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>
---
v2: Added patch

 drivers/net/wireless/broadcom/b43/main.c |  31 +---
 drivers/net/wireless/broadcom/b43/wa.c   | 283 +++--------------------=
--------
 drivers/net/wireless/broadcom/b43/xmit.c |  17 +-
 3 files changed, 24 insertions(+), 307 deletions(-)

diff --git a/drivers/net/wireless/broadcom/b43/main.c b/drivers/net/wir=
eless/broadcom/b43/main.c
index 4ee5c5853f9f..6e5d9095b195 100644
--- a/drivers/net/wireless/broadcom/b43/main.c
+++ b/drivers/net/wireless/broadcom/b43/main.c
@@ -3180,7 +3180,6 @@ static void b43_rate_memory_write(struct b43_wlde=
v *dev, u16 rate, int is_ofdm)
 static void b43_rate_memory_init(struct b43_wldev *dev)
 {
 	switch (dev->phy.type) {
-	case B43_PHYTYPE_A:
 	case B43_PHYTYPE_G:
 	case B43_PHYTYPE_N:
 	case B43_PHYTYPE_LP:
@@ -3194,8 +3193,6 @@ static void b43_rate_memory_init(struct b43_wldev=
 *dev)
 		b43_rate_memory_write(dev, B43_OFDM_RATE_36MB, 1);
 		b43_rate_memory_write(dev, B43_OFDM_RATE_48MB, 1);
 		b43_rate_memory_write(dev, B43_OFDM_RATE_54MB, 1);
-		if (dev->phy.type =3D=3D B43_PHYTYPE_A)
-			break;
 		/* fallthrough */
 	case B43_PHYTYPE_B:
 		b43_rate_memory_write(dev, B43_CCK_RATE_1MB, 0);
@@ -4604,14 +4601,6 @@ static int b43_phy_versioning(struct b43_wldev *=
dev)
 	if (radio_manuf !=3D 0x17F /* Broadcom */)
 		unsupported =3D 1;
 	switch (phy_type) {
-	case B43_PHYTYPE_A:
-		if (radio_id !=3D 0x2060)
-			unsupported =3D 1;
-		if (radio_rev !=3D 1)
-			unsupported =3D 1;
-		if (radio_manuf !=3D 0x17F)
-			unsupported =3D 1;
-		break;
 	case B43_PHYTYPE_B:
 		if ((radio_id & 0xFFF0) !=3D 0x2050)
 			unsupported =3D 1;
@@ -4766,10 +4755,7 @@ static void b43_set_synth_pu_delay(struct b43_wl=
dev *dev, bool idle)
 	u16 pu_delay;
=20
 	/* The time value is in microseconds. */
-	if (dev->phy.type =3D=3D B43_PHYTYPE_A)
-		pu_delay =3D 3700;
-	else
-		pu_delay =3D 1050;
+	pu_delay =3D 1050;
 	if (b43_is_mode(dev->wl, NL80211_IFTYPE_ADHOC) || idle)
 		pu_delay =3D 500;
 	if ((dev->phy.radio_ver =3D=3D 0x2050) && (dev->phy.radio_rev =3D=3D =
8))
@@ -4784,14 +4770,10 @@ static void b43_set_pretbtt(struct b43_wldev *d=
ev)
 	u16 pretbtt;
=20
 	/* The time value is in microseconds. */
-	if (b43_is_mode(dev->wl, NL80211_IFTYPE_ADHOC)) {
+	if (b43_is_mode(dev->wl, NL80211_IFTYPE_ADHOC))
 		pretbtt =3D 2;
-	} else {
-		if (dev->phy.type =3D=3D B43_PHYTYPE_A)
-			pretbtt =3D 120;
-		else
-			pretbtt =3D 250;
-	}
+	else
+		pretbtt =3D 250;
 	b43_shm_write16(dev, B43_SHM_SHARED, B43_SHM_SH_PRETBTT, pretbtt);
 	b43_write16(dev, B43_MMIO_TSF_CFP_PRETBTT, pretbtt);
 }
@@ -5380,10 +5362,6 @@ static void b43_supported_bands(struct b43_wldev=
 *dev, bool *have_2ghz_phy,
=20
 	/* As a fallback, try to guess using PHY type */
 	switch (dev->phy.type) {
-	case B43_PHYTYPE_A:
-		*have_2ghz_phy =3D false;
-		*have_5ghz_phy =3D true;
-		return;
 	case B43_PHYTYPE_G:
 	case B43_PHYTYPE_N:
 	case B43_PHYTYPE_LP:
@@ -5455,7 +5433,6 @@ static int b43_wireless_core_attach(struct b43_wl=
dev *dev)
 	/* We don't support 5 GHz on some PHYs yet */
 	if (have_5ghz_phy) {
 		switch (dev->phy.type) {
-		case B43_PHYTYPE_A:
 		case B43_PHYTYPE_G:
 		case B43_PHYTYPE_LP:
 		case B43_PHYTYPE_HT:
diff --git a/drivers/net/wireless/broadcom/b43/wa.c b/drivers/net/wirel=
ess/broadcom/b43/wa.c
index c218c08fb2f5..0e96c08d1e17 100644
--- a/drivers/net/wireless/broadcom/b43/wa.c
+++ b/drivers/net/wireless/broadcom/b43/wa.c
@@ -30,33 +30,6 @@
 #include "phy_common.h"
 #include "wa.h"
=20
-static void b43_wa_papd(struct b43_wldev *dev)
-{
-	u16 backup;
-
-	backup =3D b43_ofdmtab_read16(dev, B43_OFDMTAB_PWRDYN2, 0);
-	b43_ofdmtab_write16(dev, B43_OFDMTAB_PWRDYN2, 0, 7);
-	b43_ofdmtab_write16(dev, B43_OFDMTAB_UNKNOWN_APHY, 0, 0);
-	b43_dummy_transmission(dev, true, true);
-	b43_ofdmtab_write16(dev, B43_OFDMTAB_PWRDYN2, 0, backup);
-}
-
-static void b43_wa_auxclipthr(struct b43_wldev *dev)
-{
-	b43_phy_write(dev, B43_PHY_OFDM(0x8E), 0x3800);
-}
-
-static void b43_wa_afcdac(struct b43_wldev *dev)
-{
-	b43_phy_write(dev, 0x0035, 0x03FF);
-	b43_phy_write(dev, 0x0036, 0x0400);
-}
-
-static void b43_wa_txdc_offset(struct b43_wldev *dev)
-{
-	b43_ofdmtab_write16(dev, B43_OFDMTAB_DC, 0, 0x0051);
-}
-
 void b43_wa_initgains(struct b43_wldev *dev)
 {
 	struct b43_phy *phy =3D &dev->phy;
@@ -81,41 +54,6 @@ void b43_wa_initgains(struct b43_wldev *dev)
 		b43_phy_write(dev, 0x00BA, 0x3ED5);
 }
=20
-static void b43_wa_divider(struct b43_wldev *dev)
-{
-	b43_phy_mask(dev, 0x002B, ~0x0100);
-	b43_phy_write(dev, 0x008E, 0x58C1);
-}
-
-static void b43_wa_gt(struct b43_wldev *dev) /* Gain table. */
-{
-	if (dev->phy.rev <=3D 2) {
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN2, 0, 15);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN2, 1, 31);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN2, 2, 42);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN2, 3, 48);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN2, 4, 58);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN0, 0, 19);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN0, 1, 19);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN0, 2, 19);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN0, 3, 19);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN0, 4, 21);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN0, 5, 21);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN0, 6, 25);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN1, 0, 3);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN1, 1, 3);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN1, 2, 7);
-	} else {
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN0, 0, 19);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN0, 1, 19);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN0, 2, 19);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN0, 3, 19);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN0, 4, 21);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN0, 5, 21);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_GAIN0, 6, 25);
-	}
-}
-
 static void b43_wa_rssi_lt(struct b43_wldev *dev) /* RSSI lookup table=
 */
 {
 	int i;
@@ -133,15 +71,11 @@ static void b43_wa_rssi_lt(struct b43_wldev *dev) =
/* RSSI lookup table */
=20
 static void b43_wa_analog(struct b43_wldev *dev)
 {
-	struct b43_phy *phy =3D &dev->phy;
 	u16 ofdmrev;
=20
 	ofdmrev =3D b43_phy_read(dev, B43_PHY_VERSION_OFDM) & B43_PHYVER_VERS=
ION;
 	if (ofdmrev > 2) {
-		if (phy->type =3D=3D B43_PHYTYPE_A)
-			b43_phy_write(dev, B43_PHY_PWRDOWN, 0x1808);
-		else
-			b43_phy_write(dev, B43_PHY_PWRDOWN, 0x1000);
+		b43_phy_write(dev, B43_PHY_PWRDOWN, 0x1000);
 	} else {
 		b43_ofdmtab_write16(dev, B43_OFDMTAB_DAC, 3, 0x1044);
 		b43_ofdmtab_write16(dev, B43_OFDMTAB_DAC, 4, 0x7201);
@@ -149,26 +83,13 @@ static void b43_wa_analog(struct b43_wldev *dev)
 	}
 }
=20
-static void b43_wa_dac(struct b43_wldev *dev)
-{
-	if (dev->phy.analog =3D=3D 1)
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_DAC, 1,
-			(b43_ofdmtab_read16(dev, B43_OFDMTAB_DAC, 1) & ~0x0034) | 0x0008);
-	else
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_DAC, 1,
-			(b43_ofdmtab_read16(dev, B43_OFDMTAB_DAC, 1) & ~0x0078) | 0x0010);
-}
-
 static void b43_wa_fft(struct b43_wldev *dev) /* Fine frequency table =
*/
 {
 	int i;
=20
-	if (dev->phy.type =3D=3D B43_PHYTYPE_A)
-		for (i =3D 0; i < B43_TAB_FINEFREQA_SIZE; i++)
-			b43_ofdmtab_write16(dev, B43_OFDMTAB_DACRFPABB, i, b43_tab_finefreq=
a[i]);
-	else
-		for (i =3D 0; i < B43_TAB_FINEFREQG_SIZE; i++)
-			b43_ofdmtab_write16(dev, B43_OFDMTAB_DACRFPABB, i, b43_tab_finefreq=
g[i]);
+	for (i =3D 0; i < B43_TAB_FINEFREQG_SIZE; i++)
+		b43_ofdmtab_write16(dev, B43_OFDMTAB_DACRFPABB, i,
+				    b43_tab_finefreqg[i]);
 }
=20
 static void b43_wa_nft(struct b43_wldev *dev) /* Noise figure table */
@@ -176,21 +97,14 @@ static void b43_wa_nft(struct b43_wldev *dev) /* N=
oise figure table */
 	struct b43_phy *phy =3D &dev->phy;
 	int i;
=20
-	if (phy->type =3D=3D B43_PHYTYPE_A) {
-		if (phy->rev =3D=3D 2)
-			for (i =3D 0; i < B43_TAB_NOISEA2_SIZE; i++)
-				b43_ofdmtab_write16(dev, B43_OFDMTAB_AGC2, i, b43_tab_noisea2[i]);
-		else
-			for (i =3D 0; i < B43_TAB_NOISEA3_SIZE; i++)
-				b43_ofdmtab_write16(dev, B43_OFDMTAB_AGC2, i, b43_tab_noisea3[i]);
-	} else {
-		if (phy->rev =3D=3D 1)
-			for (i =3D 0; i < B43_TAB_NOISEG1_SIZE; i++)
-				b43_ofdmtab_write16(dev, B43_OFDMTAB_AGC2, i, b43_tab_noiseg1[i]);
-		else
-			for (i =3D 0; i < B43_TAB_NOISEG2_SIZE; i++)
-				b43_ofdmtab_write16(dev, B43_OFDMTAB_AGC2, i, b43_tab_noiseg2[i]);
-	}
+	if (phy->rev =3D=3D 1)
+		for (i =3D 0; i < B43_TAB_NOISEG1_SIZE; i++)
+			b43_ofdmtab_write16(dev, B43_OFDMTAB_AGC2, i,
+					    b43_tab_noiseg1[i]);
+	else
+		for (i =3D 0; i < B43_TAB_NOISEG2_SIZE; i++)
+			b43_ofdmtab_write16(dev, B43_OFDMTAB_AGC2, i,
+					    b43_tab_noiseg2[i]);
 }
=20
 static void b43_wa_rt(struct b43_wldev *dev) /* Rotor table */
@@ -201,14 +115,6 @@ static void b43_wa_rt(struct b43_wldev *dev) /* Ro=
tor table */
 		b43_ofdmtab_write32(dev, B43_OFDMTAB_ROTOR, i, b43_tab_rotor[i]);
 }
=20
-static void b43_write_null_nst(struct b43_wldev *dev)
-{
-	int i;
-
-	for (i =3D 0; i < B43_TAB_NOISESCALE_SIZE; i++)
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_NOISESCALE, i, 0);
-}
-
 static void b43_write_nst(struct b43_wldev *dev, const u16 *nst)
 {
 	int i;
@@ -221,24 +127,13 @@ static void b43_wa_nst(struct b43_wldev *dev) /* =
Noise scale table */
 {
 	struct b43_phy *phy =3D &dev->phy;
=20
-	if (phy->type =3D=3D B43_PHYTYPE_A) {
-		if (phy->rev <=3D 1)
-			b43_write_null_nst(dev);
-		else if (phy->rev =3D=3D 2)
-			b43_write_nst(dev, b43_tab_noisescalea2);
-		else if (phy->rev =3D=3D 3)
-			b43_write_nst(dev, b43_tab_noisescalea3);
-		else
+	if (phy->rev >=3D 6) {
+		if (b43_phy_read(dev, B43_PHY_ENCORE) & B43_PHY_ENCORE_EN)
 			b43_write_nst(dev, b43_tab_noisescaleg3);
+		else
+			b43_write_nst(dev, b43_tab_noisescaleg2);
 	} else {
-		if (phy->rev >=3D 6) {
-			if (b43_phy_read(dev, B43_PHY_ENCORE) & B43_PHY_ENCORE_EN)
-				b43_write_nst(dev, b43_tab_noisescaleg3);
-			else
-				b43_write_nst(dev, b43_tab_noisescaleg2);
-		} else {
-			b43_write_nst(dev, b43_tab_noisescaleg1);
-		}
+		b43_write_nst(dev, b43_tab_noisescaleg1);
 	}
 }
=20
@@ -251,41 +146,13 @@ static void b43_wa_art(struct b43_wldev *dev) /* =
ADV retard table */
 				i, b43_tab_retard[i]);
 }
=20
-static void b43_wa_txlna_gain(struct b43_wldev *dev)
-{
-	b43_ofdmtab_write16(dev, B43_OFDMTAB_DC, 13, 0x0000);
-}
-
-static void b43_wa_crs_reset(struct b43_wldev *dev)
-{
-	b43_phy_write(dev, 0x002C, 0x0064);
-}
-
-static void b43_wa_2060txlna_gain(struct b43_wldev *dev)
-{
-	b43_hf_write(dev, b43_hf_read(dev) |
-			 B43_HF_2060W);
-}
-
-static void b43_wa_lms(struct b43_wldev *dev)
-{
-	b43_phy_maskset(dev, 0x0055, 0xFFC0, 0x0004);
-}
-
-static void b43_wa_mixedsignal(struct b43_wldev *dev)
-{
-	b43_ofdmtab_write16(dev, B43_OFDMTAB_DAC, 1, 3);
-}
-
 static void b43_wa_msst(struct b43_wldev *dev) /* Min sigma square tab=
le */
 {
 	struct b43_phy *phy =3D &dev->phy;
 	int i;
 	const u16 *tab;
=20
-	if (phy->type =3D=3D B43_PHYTYPE_A) {
-		tab =3D b43_tab_sigmasqr1;
-	} else if (phy->type =3D=3D B43_PHYTYPE_G) {
+	if (phy->type =3D=3D B43_PHYTYPE_G) {
 		tab =3D b43_tab_sigmasqr2;
 	} else {
 		B43_WARN_ON(1);
@@ -298,13 +165,6 @@ static void b43_wa_msst(struct b43_wldev *dev) /* =
Min sigma square table */
 	}
 }
=20
-static void b43_wa_iqadc(struct b43_wldev *dev)
-{
-	if (dev->phy.analog =3D=3D 4)
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_DAC, 0,
-			b43_ofdmtab_read16(dev, B43_OFDMTAB_DAC, 0) & ~0xF000);
-}
-
 static void b43_wa_crs_ed(struct b43_wldev *dev)
 {
 	struct b43_phy *phy =3D &dev->phy;
@@ -450,38 +310,6 @@ static void b43_wa_cpll_nonpilot(struct b43_wldev =
*dev)
 	b43_ofdmtab_write16(dev, B43_OFDMTAB_UNKNOWN_11, 1, 0);
 }
=20
-static void b43_wa_rssi_adc(struct b43_wldev *dev)
-{
-	if (dev->phy.analog =3D=3D 4)
-		b43_phy_write(dev, 0x00DC, 0x7454);
-}
-
-static void b43_wa_boards_a(struct b43_wldev *dev)
-{
-	if (dev->dev->board_vendor =3D=3D SSB_BOARDVENDOR_BCM &&
-	    dev->dev->board_type =3D=3D SSB_BOARD_BU4306 &&
-	    dev->dev->board_rev < 0x30) {
-		b43_phy_write(dev, 0x0010, 0xE000);
-		b43_phy_write(dev, 0x0013, 0x0140);
-		b43_phy_write(dev, 0x0014, 0x0280);
-	} else {
-		if (dev->dev->board_type =3D=3D SSB_BOARD_MP4318 &&
-		    dev->dev->board_rev < 0x20) {
-			b43_phy_write(dev, 0x0013, 0x0210);
-			b43_phy_write(dev, 0x0014, 0x0840);
-		} else {
-			b43_phy_write(dev, 0x0013, 0x0140);
-			b43_phy_write(dev, 0x0014, 0x0280);
-		}
-		if (dev->phy.rev <=3D 4)
-			b43_phy_write(dev, 0x0010, 0xE000);
-		else
-			b43_phy_write(dev, 0x0010, 0x2000);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_DC, 1, 0x0039);
-		b43_ofdmtab_write16(dev, B43_OFDMTAB_UNKNOWN_APHY, 7, 0x0040);
-	}
-}
-
 static void b43_wa_boards_g(struct b43_wldev *dev)
 {
 	struct ssb_sprom *sprom =3D dev->dev->bus_sprom;
@@ -518,80 +346,7 @@ void b43_wa_all(struct b43_wldev *dev)
 {
 	struct b43_phy *phy =3D &dev->phy;
=20
-	if (phy->type =3D=3D B43_PHYTYPE_A) {
-		switch (phy->rev) {
-		case 2:
-			b43_wa_papd(dev);
-			b43_wa_auxclipthr(dev);
-			b43_wa_afcdac(dev);
-			b43_wa_txdc_offset(dev);
-			b43_wa_initgains(dev);
-			b43_wa_divider(dev);
-			b43_wa_gt(dev);
-			b43_wa_rssi_lt(dev);
-			b43_wa_analog(dev);
-			b43_wa_dac(dev);
-			b43_wa_fft(dev);
-			b43_wa_nft(dev);
-			b43_wa_rt(dev);
-			b43_wa_nst(dev);
-			b43_wa_art(dev);
-			b43_wa_txlna_gain(dev);
-			b43_wa_crs_reset(dev);
-			b43_wa_2060txlna_gain(dev);
-			b43_wa_lms(dev);
-			break;
-		case 3:
-			b43_wa_papd(dev);
-			b43_wa_mixedsignal(dev);
-			b43_wa_rssi_lt(dev);
-			b43_wa_txdc_offset(dev);
-			b43_wa_initgains(dev);
-			b43_wa_dac(dev);
-			b43_wa_nft(dev);
-			b43_wa_nst(dev);
-			b43_wa_msst(dev);
-			b43_wa_analog(dev);
-			b43_wa_gt(dev);
-			b43_wa_txpuoff_rxpuon(dev);
-			b43_wa_txlna_gain(dev);
-			break;
-		case 5:
-			b43_wa_iqadc(dev);
-		case 6:
-			b43_wa_papd(dev);
-			b43_wa_rssi_lt(dev);
-			b43_wa_txdc_offset(dev);
-			b43_wa_initgains(dev);
-			b43_wa_dac(dev);
-			b43_wa_nft(dev);
-			b43_wa_nst(dev);
-			b43_wa_msst(dev);
-			b43_wa_analog(dev);
-			b43_wa_gt(dev);
-			b43_wa_txpuoff_rxpuon(dev);
-			b43_wa_txlna_gain(dev);
-			break;
-		case 7:
-			b43_wa_iqadc(dev);
-			b43_wa_papd(dev);
-			b43_wa_rssi_lt(dev);
-			b43_wa_txdc_offset(dev);
-			b43_wa_initgains(dev);
-			b43_wa_dac(dev);
-			b43_wa_nft(dev);
-			b43_wa_nst(dev);
-			b43_wa_msst(dev);
-			b43_wa_analog(dev);
-			b43_wa_gt(dev);
-			b43_wa_txpuoff_rxpuon(dev);
-			b43_wa_txlna_gain(dev);
-			b43_wa_rssi_adc(dev);
-		default:
-			B43_WARN_ON(1);
-		}
-		b43_wa_boards_a(dev);
-	} else if (phy->type =3D=3D B43_PHYTYPE_G) {
+	if (phy->type =3D=3D B43_PHYTYPE_G) {
 		switch (phy->rev) {
 		case 1://XXX review rev1
 			b43_wa_crs_ed(dev);
diff --git a/drivers/net/wireless/broadcom/b43/xmit.c b/drivers/net/wir=
eless/broadcom/b43/xmit.c
index f6201264de49..6ddd2a125ddc 100644
--- a/drivers/net/wireless/broadcom/b43/xmit.c
+++ b/drivers/net/wireless/broadcom/b43/xmit.c
@@ -642,11 +642,7 @@ static s8 b43_rssinoise_postprocess(struct b43_wld=
ev *dev, u8 in_rssi)
 	struct b43_phy *phy =3D &dev->phy;
 	s8 ret;
=20
-	if (phy->type =3D=3D B43_PHYTYPE_A) {
-		//TODO: Incomplete specs.
-		ret =3D 0;
-	} else
-		ret =3D b43_rssi_postprocess(dev, in_rssi, 0, 1, 1);
+	ret =3D b43_rssi_postprocess(dev, in_rssi, 0, 1, 1);
=20
 	return ret;
 }
@@ -663,7 +659,6 @@ void b43_rx(struct b43_wldev *dev, struct sk_buff *=
skb, const void *_rxhdr)
 	u16 uninitialized_var(chanstat), uninitialized_var(mactime);
 	u32 uninitialized_var(macstat);
 	u16 chanid;
-	u16 phytype;
 	int padding, rate_idx;
=20
 	memset(&status, 0, sizeof(status));
@@ -684,7 +679,6 @@ void b43_rx(struct b43_wldev *dev, struct sk_buff *=
skb, const void *_rxhdr)
 		chanstat =3D le16_to_cpu(rxhdr->format_351.channel);
 		break;
 	}
-	phytype =3D chanstat & B43_RX_CHAN_PHYTYPE;
=20
 	if (unlikely(macstat & B43_RX_MAC_FCSERR)) {
 		dev->wl->ieee_stats.dot11FCSErrorCount++;
@@ -755,7 +749,6 @@ void b43_rx(struct b43_wldev *dev, struct sk_buff *=
skb, const void *_rxhdr)
 		else
 			status.signal =3D max(rxhdr->power0, rxhdr->power1);
 		break;
-	case B43_PHYTYPE_A:
 	case B43_PHYTYPE_B:
 	case B43_PHYTYPE_G:
 	case B43_PHYTYPE_LP:
@@ -802,14 +795,6 @@ void b43_rx(struct b43_wldev *dev, struct sk_buff =
*skb, const void *_rxhdr)
=20
 	chanid =3D (chanstat & B43_RX_CHAN_ID) >> B43_RX_CHAN_ID_SHIFT;
 	switch (chanstat & B43_RX_CHAN_PHYTYPE) {
-	case B43_PHYTYPE_A:
-		status.band =3D NL80211_BAND_5GHZ;
-		B43_WARN_ON(1);
-		/* FIXME: We don't really know which value the "chanid" contains.
-		 *        So the following assignment might be wrong. */
-		status.freq =3D
-			ieee80211_channel_to_frequency(chanid, status.band);
-		break;
 	case B43_PHYTYPE_G:
 		status.band =3D NL80211_BAND_2GHZ;
 		/* Somewhere between 478.104 and 508.1084 firmware for G-PHY
--=20
2.5.0

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
