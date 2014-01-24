From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2014-01-24
Date: Fri, 24 Jan 2014 14:39:33 -0500
Message-ID: <20140124193933.GL4309@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="7AUc2qLy4jB3hD7Z"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--7AUc2qLy4jB3hD7Z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull these fixes for the 3.14 stream!

For the iwlwifi fix, Emmanuel says:

"A critical bug has been reported on all NICs supported by iwldvm.
iwlwifi would simply panic upon interface up This patch fixes this. The
offending code is by me and is present in wireless-next.git and hence in
net-next.git."

Along with that...

Andreas Fenkart corrects a WoWLAN problem with mwifiex.

Roman Dubtsov adds a device ID to rt2800usb.

Sujith Manoharan re-enables a mistakenly commented-out line of code in
ath9k, and also fixes and interrupt mitigation issue for that driver.

ZHAO Gang fixes an incorrect assignment (reverse/wrong API call) in b43.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit f55aa836fb7a90b62cb2c533b899e331cdffcf0c:

  rtnetlink: remove IFLA_BOND_SLAVE definition (2014-01-24 00:36:48 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 5746cc2a6923b4e4726d9be8aa155461829be360:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2014-01-24 13:25:15 -0500)

----------------------------------------------------------------

Andreas Fenkart (1):
      mwifiex: fix wakeup on magic packet

Emmanuel Grumbach (1):
      iwlwifi: pcie: don't panic on host commands in iwldvm

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Roman Dubtsov (1):
      rt2x00: rt2800usb: mark D-Link DWA-137 as supported

Sujith Manoharan (2):
      ath9k: Fix code mistake
      ath9k: Fix RX interrupt mitigation

ZHAO Gang (1):
      b43: fix the wrong assignment of status.freq in b43_rx()

 drivers/net/wireless/ath/ath9k/hw.c     | 12 ++++++++++--
 drivers/net/wireless/ath/ath9k/hw.h     |  2 ++
 drivers/net/wireless/ath/ath9k/main.c   |  2 +-
 drivers/net/wireless/b43/xmit.c         |  4 ++--
 drivers/net/wireless/iwlwifi/pcie/tx.c  |  4 +++-
 drivers/net/wireless/mwifiex/cfg80211.c |  2 +-
 drivers/net/wireless/rt2x00/rt2800usb.c |  1 +
 7 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath=
/ath9k/hw.c
index ce41658a6003..fbf43c05713f 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -358,6 +358,14 @@ static void ath9k_hw_init_config(struct ath_hw *ah)
=20
 	ah->config.rx_intr_mitigation =3D true;
=20
+	if (AR_SREV_9300_20_OR_LATER(ah)) {
+		ah->config.rimt_last =3D 500;
+		ah->config.rimt_first =3D 2000;
+	} else {
+		ah->config.rimt_last =3D 250;
+		ah->config.rimt_first =3D 700;
+	}
+
 	/*
 	 * We need this for PCI devices only (Cardbus, PCI, miniPCI)
 	 * _and_ if on non-uniprocessor systems (Multiprocessor/HT).
@@ -1876,8 +1884,8 @@ int ath9k_hw_reset(struct ath_hw *ah, struct ath9k_ch=
annel *chan,
 		REG_WRITE(ah, AR_OBS, 8);
=20
 	if (ah->config.rx_intr_mitigation) {
-		REG_RMW_FIELD(ah, AR_RIMT, AR_RIMT_LAST, 500);
-		REG_RMW_FIELD(ah, AR_RIMT, AR_RIMT_FIRST, 2000);
+		REG_RMW_FIELD(ah, AR_RIMT, AR_RIMT_LAST, ah->config.rimt_last);
+		REG_RMW_FIELD(ah, AR_RIMT, AR_RIMT_FIRST, ah->config.rimt_first);
 	}
=20
 	if (ah->config.tx_intr_mitigation) {
diff --git a/drivers/net/wireless/ath/ath9k/hw.h b/drivers/net/wireless/ath=
/ath9k/hw.h
index e766399bdcda..0acd4b5a4892 100644
--- a/drivers/net/wireless/ath/ath9k/hw.h
+++ b/drivers/net/wireless/ath/ath9k/hw.h
@@ -310,6 +310,8 @@ struct ath9k_ops_config {
 	u8 max_txtrig_level;
 	u16 ani_poll_interval; /* ANI poll interval in ms */
 	u16 hw_hang_checks;
+	u16 rimt_first;
+	u16 rimt_last;
=20
 	/* Platform specific config */
 	u32 aspm_l1_fix;
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index 73a36551a5ed..5924f72dd493 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -524,7 +524,7 @@ void ath9k_tasklet(unsigned long data)
 			 * successfully after a GTT interrupt, the GTT counter
 			 * gets reset to zero here.
 			 */
-			/* sc->gtt_cnt =3D 0; */
+			sc->gtt_cnt =3D 0;
=20
 			ath_tx_edma_tasklet(sc);
 		} else {
diff --git a/drivers/net/wireless/b43/xmit.c b/drivers/net/wireless/b43/xmi=
t.c
index 4ae63f4ddfb2..50e5ddb12fb3 100644
--- a/drivers/net/wireless/b43/xmit.c
+++ b/drivers/net/wireless/b43/xmit.c
@@ -821,10 +821,10 @@ void b43_rx(struct b43_wldev *dev, struct sk_buff *sk=
b, const void *_rxhdr)
 		 * channel number in b43. */
 		if (chanstat & B43_RX_CHAN_5GHZ) {
 			status.band =3D IEEE80211_BAND_5GHZ;
-			status.freq =3D b43_freq_to_channel_5ghz(chanid);
+			status.freq =3D b43_channel_to_freq_5ghz(chanid);
 		} else {
 			status.band =3D IEEE80211_BAND_2GHZ;
-			status.freq =3D b43_freq_to_channel_2ghz(chanid);
+			status.freq =3D b43_channel_to_freq_2ghz(chanid);
 		}
 		break;
 	default:
diff --git a/drivers/net/wireless/iwlwifi/pcie/tx.c b/drivers/net/wireless/=
iwlwifi/pcie/tx.c
index 3b14fa8abfc7..3d549008b3e2 100644
--- a/drivers/net/wireless/iwlwifi/pcie/tx.c
+++ b/drivers/net/wireless/iwlwifi/pcie/tx.c
@@ -289,13 +289,15 @@ static void iwl_pcie_txq_inval_byte_cnt_tbl(struct iw=
l_trans *trans,
  */
 void iwl_pcie_txq_inc_wr_ptr(struct iwl_trans *trans, struct iwl_txq *txq)
 {
+	struct iwl_trans_pcie *trans_pcie =3D IWL_TRANS_GET_PCIE_TRANS(trans);
 	u32 reg =3D 0;
 	int txq_id =3D txq->q.id;
=20
 	if (txq->need_update =3D=3D 0)
 		return;
=20
-	if (trans->cfg->base_params->shadow_reg_enable) {
+	if (trans->cfg->base_params->shadow_reg_enable ||
+	    txq_id =3D=3D trans_pcie->cmd_queue) {
 		/* shadow register enabled */
 		iwl_write32(trans, HBUS_TARG_WRPTR,
 			    txq->q.write_ptr | (txq_id << 8));
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless=
/mwifiex/cfg80211.c
index f37b403e83d0..8bfc07cd330e 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -2449,7 +2449,7 @@ static int mwifiex_cfg80211_suspend(struct wiphy *wip=
hy,
 		       ETH_ALEN);
 		mef_entry->filter[filt_num].byte_seq[MWIFIEX_MEF_MAX_BYTESEQ] =3D
 								ETH_ALEN;
-		mef_entry->filter[filt_num].offset =3D 14;
+		mef_entry->filter[filt_num].offset =3D 28;
 		mef_entry->filter[filt_num].filt_type =3D TYPE_EQ;
 		if (filt_num)
 			mef_entry->filter[filt_num].filt_action =3D TYPE_OR;
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless=
/rt2x00/rt2800usb.c
index 5c5c4906c6b6..caddc1b427a9 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -989,6 +989,7 @@ static struct usb_device_id rt2800usb_device_table[] =
=3D {
 	{ USB_DEVICE(0x07d1, 0x3c15) },
 	{ USB_DEVICE(0x07d1, 0x3c16) },
 	{ USB_DEVICE(0x07d1, 0x3c17) },
+	{ USB_DEVICE(0x2001, 0x3317) },
 	{ USB_DEVICE(0x2001, 0x3c1b) },
 	/* Draytek */
 	{ USB_DEVICE(0x07fa, 0x7712) },
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--7AUc2qLy4jB3hD7Z
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJS4sF1AAoJEJctW/TcYTgGSGMP/RKEjGIxZtG4Qaj4TyccHF9o
K+mHv1UbEwdkWXPvNd1a10NmnNFYv41Bwq8fHkakM299TpYl0ms8yB1m3rjy1JLJ
I5+VrZTTJnynPMNApyT6djr6KPiRmcIK8IkQF7bGWQVL82MuZ7BJCbDgVoIFb0Jt
Y0ACkmScPJ4JNYN+GMTOnNyFtnAfckHTwVrAmg8xflTN0/recBUYhB376DvNISgC
tEsrL5UynMC+RK6rQGsBPJu9f/LVKNkV91CHryYl+WtKZZnqwWAyXO4Tlpa7F1i4
R0SlQS0AL9ki9atmnzMN/Kigo5dmzpCmITdibc/x9j3nhvNKRF1Ilyg0T/MWlU+z
DVBYiiZRXNubueqTUfcW2NlV1175VAWzuh+lEud9fzuyMI9QESwCAWJW6SQUjBQq
tSviZ5sZB70Zdqq52hfNSFsYqp9hzQHXV8nxOF4XvVav7iokUyqxNawMRLyrif/w
iYhk0htoKygpphsLaSvl4bueQ0Gy40OwV7hHWTyeTxoe89Tdkb4eYGI0cI3VghY/
WUYATX19y0e+0ZyYJCw8+1/yGK8IMm21uanHVYqYrqlQsMtTa6PkkNc+C3gR1kx8
VjSYDsUriXz5FCYgpGT4wzB93z+Nucs9SvDAWPpeNQ8/l7gyBbqYTWOfeFmDTwDT
QCqg+ewSYz9WKwGEH7Hu
=qKuS
-----END PGP SIGNATURE-----

--7AUc2qLy4jB3hD7Z--
