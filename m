From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-03-14
Date: Fri, 14 Mar 2014 14:20:26 -0400
Message-ID: <20140314182024.GA20339@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="X1bOJ3K7DJ5YkBrT"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--X1bOJ3K7DJ5YkBrT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull these last(?) few wireless bits intended for the 3.14
stream.  Each is here to address a problem found with a patch already
merged...

Dave Jones gives us a memory leak fix, for an error path in brcmfmac.

Felix Fietkau moves a small delay to make it actually reachable.

Helmut Schaa fixes an ath9k sequence numbering problem for non-data
frames.

Stanislaw Gruszka reverts an earlier fix that was found to cause
random connection drops on RT5390 PCI adapters

Please let me know if there are problems!  I'll be back from watching
the Veronica Mars movie by about 9pm... :-)

Thanks,

John

---

The following changes since commit c60f7d5a8e7c639de5d9dfe07e1e91d302d506e4:

  Merge branch 'drm-fixes' of git://people.freedesktop.org/~airlied/linux (=
2014-03-13 21:32:16 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 8c35743fdc3c013cbb9832dc9c5eb04362b86cbb:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2014-03-14 14:09:47 -0400)

----------------------------------------------------------------

Dave Jones (1):
      brcmfmac: fix skb leak in brcmf_sdio_txpkt_prep_sg error path.

Felix Fietkau (1):
      ath9k_hw: fix unreachable code in baseband hang detection code

Helmut Schaa (1):
      ath9k: Fix sequence number assignment for non-data frames

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Stanislaw Gruszka (1):
      Revert "rt2x00: rt2800lib: Update BBP register initialization for RT5=
3xx"

 drivers/net/wireless/ath/ath9k/hw.c                | 3 +--
 drivers/net/wireless/ath/ath9k/xmit.c              | 4 ++--
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c | 4 +++-
 drivers/net/wireless/rt2x00/rt2800lib.c            | 6 +++---
 4 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath=
/ath9k/hw.c
index 303ce27964c1..9078a6c5a74e 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -1548,6 +1548,7 @@ bool ath9k_hw_check_alive(struct ath_hw *ah)
 		if (reg !=3D last_val)
 			return true;
=20
+		udelay(1);
 		last_val =3D reg;
 		if ((reg & 0x7E7FFFEF) =3D=3D 0x00702400)
 			continue;
@@ -1560,8 +1561,6 @@ bool ath9k_hw_check_alive(struct ath_hw *ah)
 		default:
 			return true;
 		}
-
-		udelay(1);
 	} while (count-- > 0);
=20
 	return false;
diff --git a/drivers/net/wireless/ath/ath9k/xmit.c b/drivers/net/wireless/a=
th/ath9k/xmit.c
index f042a18c8495..55897d508a76 100644
--- a/drivers/net/wireless/ath/ath9k/xmit.c
+++ b/drivers/net/wireless/ath/ath9k/xmit.c
@@ -2063,7 +2063,7 @@ static struct ath_buf *ath_tx_setup_buffer(struct ath=
_softc *sc,
=20
 	ATH_TXBUF_RESET(bf);
=20
-	if (tid) {
+	if (tid && ieee80211_is_data_present(hdr->frame_control)) {
 		fragno =3D le16_to_cpu(hdr->seq_ctrl) & IEEE80211_SCTL_FRAG;
 		seqno =3D tid->seq_next;
 		hdr->seq_ctrl =3D cpu_to_le16(tid->seq_next << IEEE80211_SEQ_SEQ_SHIFT);
@@ -2186,7 +2186,7 @@ int ath_tx_start(struct ieee80211_hw *hw, struct sk_b=
uff *skb,
 		txq->stopped =3D true;
 	}
=20
-	if (txctl->an)
+	if (txctl->an && ieee80211_is_data_present(hdr->frame_control))
 		tid =3D ath_get_skb_tid(sc, txctl->an, skb);
=20
 	if (info->flags & IEEE80211_TX_CTL_PS_RESPONSE) {
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/n=
et/wireless/brcm80211/brcmfmac/dhd_sdio.c
index 119ee6eaf1c3..ddaa9efd053d 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
@@ -1948,8 +1948,10 @@ static int brcmf_sdio_txpkt_prep_sg(struct brcmf_sdi=
o *bus,
 		if (pkt_pad =3D=3D NULL)
 			return -ENOMEM;
 		ret =3D brcmf_sdio_txpkt_hdalign(bus, pkt_pad);
-		if (unlikely(ret < 0))
+		if (unlikely(ret < 0)) {
+			kfree_skb(pkt_pad);
 			return ret;
+		}
 		memcpy(pkt_pad->data,
 		       pkt->data + pkt->len - tail_chop,
 		       tail_chop);
diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c b/drivers/net/wireless=
/rt2x00/rt2800lib.c
index 7f8b5d156c8c..41d4a8167dc3 100644
--- a/drivers/net/wireless/rt2x00/rt2800lib.c
+++ b/drivers/net/wireless/rt2x00/rt2800lib.c
@@ -5460,14 +5460,15 @@ static void rt2800_init_bbp_53xx(struct rt2x00_dev =
*rt2x00dev)
=20
 	rt2800_bbp_write(rt2x00dev, 68, 0x0b);
=20
-	rt2800_bbp_write(rt2x00dev, 69, 0x0d);
-	rt2800_bbp_write(rt2x00dev, 70, 0x06);
+	rt2800_bbp_write(rt2x00dev, 69, 0x12);
 	rt2800_bbp_write(rt2x00dev, 73, 0x13);
 	rt2800_bbp_write(rt2x00dev, 75, 0x46);
 	rt2800_bbp_write(rt2x00dev, 76, 0x28);
=20
 	rt2800_bbp_write(rt2x00dev, 77, 0x59);
=20
+	rt2800_bbp_write(rt2x00dev, 70, 0x0a);
+
 	rt2800_bbp_write(rt2x00dev, 79, 0x13);
 	rt2800_bbp_write(rt2x00dev, 80, 0x05);
 	rt2800_bbp_write(rt2x00dev, 81, 0x33);
@@ -5510,7 +5511,6 @@ static void rt2800_init_bbp_53xx(struct rt2x00_dev *r=
t2x00dev)
 	if (rt2x00_rt(rt2x00dev, RT5392)) {
 		rt2800_bbp_write(rt2x00dev, 134, 0xd0);
 		rt2800_bbp_write(rt2x00dev, 135, 0xf6);
-		rt2800_bbp_write(rt2x00dev, 148, 0x84);
 	}
=20
 	rt2800_disable_unused_dac_adc(rt2x00dev);
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--X1bOJ3K7DJ5YkBrT
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTI0hoAAoJEJctW/TcYTgGsygP/09UNlNDX67Js43btH+TWu+z
ra0cWgfLsG/6stS19slFNv4tsxXtmI5IFO3mxdq+cP89irirro8kb1qBtbq+Xlii
w8tDkpR5+gE6MHYoPqmdQWDezuSDSlqnnmFS1dpBAro/oiDIxApS0A7+sY1Vy514
rzPdDznt3xQFPkm1nQVUGGw3n5+WaIbzqXiYQIaF11Vjc5WjMM4sPvwj9u9t720q
0dSFoSMtqPZhQLxBn/Erb9GwH+keMrNvQTcFzPGBm7IH+UwIYLz3U7WpOtNThtzk
IgQ0oZnH84C/hWl8or5vYdLU/w02RFqvMdAvQmtKMoqIVfbItbeDNMQOF+cNpCMZ
YhZGYyrRmsqUtd8c+S45J4iTTkNUVPyJZnyVDYkELKmhoSXlqaL+C7palHbZ3Q3l
UuabzaojZp3NTrYeBB2jCYSYELqr5ox4zE3c34lXqU9Pu6E/I3B/NDJjNKCn9DIw
ws6MI2bukWgibsg8O6QJ+EHise0BvoiA8aG5RmSF7uPaXGgRuef6qZqxxi6zAgVw
4mWHOxF0hrHcslnAnK8kxzIlujsFHNp5V1QUU04TXwewMM0yvix4Z2XsHD8iMXYh
Hc2CZp0QtMMPGzjIb/dFElmFl/PYvgXcj8U5v2i96VgEBDjLruUwbWmslzN/23Ba
VcF/WBWW5Sdy3rAjYiHj
=n/AS
-----END PGP SIGNATURE-----

--X1bOJ3K7DJ5YkBrT--
