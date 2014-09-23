From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-09-23
Date: Tue, 23 Sep 2014 11:00:02 -0400
Message-ID: <20140923150002.GH23806@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="+g7M9IMkV8truYOl"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--+g7M9IMkV8truYOl
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please consider pulling this one last batch of fixes intended for the 3.17 =
stream!

For the NFC bits, Samuel says:

"Hopefully not too late for a handful of NFC fixes:

- 2 potential build failures for ST21NFCA and ST21NFCB, triggered by a
  depmod dependenyc cycle.
- One potential buffer overflow in the microread driver."

On top of that...

Emil Goode provides a fix for a brcmfmac off-by-one regression which
was introduced in the 3.17 cycle.

Loic Poulain fixes a polarity mismatch for a variable assignment
inside of rfkill-gpio.

Wojciech Dubowik prevents a NULL pointer dereference in ath9k.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit dda3b191eb6c5a56d443723dcb71ade60d97c04f:

  net: rfkill: gpio: Enable module auto-loading for ACPI based switches (20=
14-09-16 16:09:01 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git tags/=
master-2014-09-23

for you to fetch changes up to f8adaf0ae978252c9f7e29e96aefcd8fcaf806ba:

  brcmfmac: Fix off by one bug in brcmf_count_20mhz_channels() (2014-09-23 =
10:48:26 -0400)

----------------------------------------------------------------
Christophe Ricard (2):
      NFC: st21nfcb: Fix depmod dependency cycle
      NFC: st21nfca: Fix potential depmod dependency cycle

Dan Carpenter (1):
      NFC: microread: Potential overflows in microread_target_discovered()

Emil Goode (1):
      brcmfmac: Fix off by one bug in brcmf_count_20mhz_channels()

John W. Linville (1):
      Merge tag 'nfc-fixes-3.17-1' of git://git.kernel.org/.../sameo/nfc-fi=
xes

Loic Poulain (1):
      net: rfkill: gpio: Fix clock status

Wojciech Dubowik (1):
      ath9k: Fix NULL pointer dereference on early irq

 drivers/net/wireless/ath/ath9k/main.c                 |  2 +-
 drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c |  2 +-
 drivers/nfc/microread/microread.c                     | 16 ++++++++++++----
 drivers/nfc/st21nfca/Makefile                         |  5 +++--
 drivers/nfc/st21nfcb/Makefile                         |  5 +++--
 net/rfkill/rfkill-gpio.c                              |  2 +-
 6 files changed, 21 insertions(+), 11 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index e6ac8d2e610c..4b148bbb2bf6 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -513,7 +513,7 @@ irqreturn_t ath_isr(int irq, void *dev)
 	 * touch anything. Note this can happen early
 	 * on if the IRQ is shared.
 	 */
-	if (test_bit(ATH_OP_INVALID, &common->op_flags))
+	if (!ah || test_bit(ATH_OP_INVALID, &common->op_flags))
 		return IRQ_NONE;
=20
 	/* shared irq, not for us */
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/driver=
s/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index f3a9804988a6..16a246bfc343 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -4921,7 +4921,7 @@ static void brcmf_count_20mhz_channels(struct brcmf_c=
fg80211_info *cfg,
 	struct brcmu_chan ch;
 	int i;
=20
-	for (i =3D 0; i <=3D total; i++) {
+	for (i =3D 0; i < total; i++) {
 		ch.chspec =3D (u16)le32_to_cpu(chlist->element[i]);
 		cfg->d11inf.decchspec(&ch);
=20
diff --git a/drivers/nfc/microread/microread.c b/drivers/nfc/microread/micr=
oread.c
index f868333271aa..963a4a5dc88e 100644
--- a/drivers/nfc/microread/microread.c
+++ b/drivers/nfc/microread/microread.c
@@ -501,9 +501,13 @@ static void microread_target_discovered(struct nfc_hci=
_dev *hdev, u8 gate,
 		targets->sens_res =3D
 			 be16_to_cpu(*(u16 *)&skb->data[MICROREAD_EMCF_A_ATQA]);
 		targets->sel_res =3D skb->data[MICROREAD_EMCF_A_SAK];
-		memcpy(targets->nfcid1, &skb->data[MICROREAD_EMCF_A_UID],
-		       skb->data[MICROREAD_EMCF_A_LEN]);
 		targets->nfcid1_len =3D skb->data[MICROREAD_EMCF_A_LEN];
+		if (targets->nfcid1_len > sizeof(targets->nfcid1)) {
+			r =3D -EINVAL;
+			goto exit_free;
+		}
+		memcpy(targets->nfcid1, &skb->data[MICROREAD_EMCF_A_UID],
+		       targets->nfcid1_len);
 		break;
 	case MICROREAD_GATE_ID_MREAD_ISO_A_3:
 		targets->supported_protocols =3D
@@ -511,9 +515,13 @@ static void microread_target_discovered(struct nfc_hci=
_dev *hdev, u8 gate,
 		targets->sens_res =3D
 			 be16_to_cpu(*(u16 *)&skb->data[MICROREAD_EMCF_A3_ATQA]);
 		targets->sel_res =3D skb->data[MICROREAD_EMCF_A3_SAK];
-		memcpy(targets->nfcid1, &skb->data[MICROREAD_EMCF_A3_UID],
-		       skb->data[MICROREAD_EMCF_A3_LEN]);
 		targets->nfcid1_len =3D skb->data[MICROREAD_EMCF_A3_LEN];
+		if (targets->nfcid1_len > sizeof(targets->nfcid1)) {
+			r =3D -EINVAL;
+			goto exit_free;
+		}
+		memcpy(targets->nfcid1, &skb->data[MICROREAD_EMCF_A3_UID],
+		       targets->nfcid1_len);
 		break;
 	case MICROREAD_GATE_ID_MREAD_ISO_B:
 		targets->supported_protocols =3D NFC_PROTO_ISO14443_B_MASK;
diff --git a/drivers/nfc/st21nfca/Makefile b/drivers/nfc/st21nfca/Makefile
index db7a38ae05f7..7d688f97aa27 100644
--- a/drivers/nfc/st21nfca/Makefile
+++ b/drivers/nfc/st21nfca/Makefile
@@ -2,7 +2,8 @@
 # Makefile for ST21NFCA HCI based NFC driver
 #
=20
-st21nfca_i2c-objs  =3D i2c.o
+st21nfca_hci-objs =3D st21nfca.o st21nfca_dep.o
+obj-$(CONFIG_NFC_ST21NFCA)     +=3D st21nfca_hci.o
=20
-obj-$(CONFIG_NFC_ST21NFCA)     +=3D st21nfca.o st21nfca_dep.o
+st21nfca_i2c-objs  =3D i2c.o
 obj-$(CONFIG_NFC_ST21NFCA_I2C) +=3D st21nfca_i2c.o
diff --git a/drivers/nfc/st21nfcb/Makefile b/drivers/nfc/st21nfcb/Makefile
index 13d9f03b2fea..f4d835dd15f2 100644
--- a/drivers/nfc/st21nfcb/Makefile
+++ b/drivers/nfc/st21nfcb/Makefile
@@ -2,7 +2,8 @@
 # Makefile for ST21NFCB NCI based NFC driver
 #
=20
-st21nfcb_i2c-objs  =3D i2c.o
+st21nfcb_nci-objs =3D ndlc.o st21nfcb.o
+obj-$(CONFIG_NFC_ST21NFCB)     +=3D st21nfcb_nci.o
=20
-obj-$(CONFIG_NFC_ST21NFCB)     +=3D st21nfcb.o ndlc.o
+st21nfcb_i2c-objs =3D i2c.o
 obj-$(CONFIG_NFC_ST21NFCB_I2C) +=3D st21nfcb_i2c.o
diff --git a/net/rfkill/rfkill-gpio.c b/net/rfkill/rfkill-gpio.c
index 5fa54dd78e25..0f62326c0f5e 100644
--- a/net/rfkill/rfkill-gpio.c
+++ b/net/rfkill/rfkill-gpio.c
@@ -54,7 +54,7 @@ static int rfkill_gpio_set_power(void *data, bool blocked)
 	if (blocked && !IS_ERR(rfkill->clk) && rfkill->clk_enabled)
 		clk_disable(rfkill->clk);
=20
-	rfkill->clk_enabled =3D blocked;
+	rfkill->clk_enabled =3D !blocked;
=20
 	return 0;
 }
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--+g7M9IMkV8truYOl
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUIYryAAoJEJctW/TcYTgGaCYQAI1//0nnNDfvVvN4TfsEk/CD
aTNyfbisFAHy6ab9pwn4haxlXtopDHaTLCKc/XhSSnJAkI+B8LoIIIQBKN7qLrzN
FPPdrH8dtKoJln59Dz4D2/Fi09LZ+bbn6BWTmsuAVEAD7+jNkHXClNoJBBE6OisX
uC+TzILj1D2OYN/feLYCYaHN75m+M2sLOpGM9k885iPgxjCITK1rTL8CMdGWFipE
E9+lpJYRj4vaYCE/oJrDOXJM3y6DJMYAx3z10oAU6Drtt2F2Y/j44YlcfsPdVVuX
Rl8cutQqQp2Kh77Ux4gCTqNKzxiyEsDbjN/jEuQjsMgPivErDzsZOMtwHwtqd0Wu
l1O25JBA4LtcIbGwUlbHKmDafD7f3MjCppW+X7P+0dllVi+6tekd1zvsLY6wczQ1
puWQMafzZVKe8ImDAbf5ODGj4UvVrjReXMDdVUhfNesQrtg7WPkGob+fZfJjDs5s
baxGPrEohGPCQl+fFF043E0viDyVF+BNjCxhmxjMtCt9/otEj3OyaE1AdvBl5MRI
aaoJZU8NVgXJQhW4daKpqSST/gvI2wNdrckfHT58bTrH1uVSaWLTFNtbUv4ss7er
9dChV6eFCJS485+TpGWg/65ky93NE79pDY0xmas8ojsRTs5nBPHFy2xflBdgq628
ruH3SddcH4icQK5UAEWs
=W2oZ
-----END PGP SIGNATURE-----

--+g7M9IMkV8truYOl--
