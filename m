From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-01-04 #2
Date: Wed, 4 Jan 2012 11:43:40 -0500
Message-ID: <20120104164339.GG2540@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="p2kqVDKq5asng8Dg"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--p2kqVDKq5asng8Dg
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Here are a handful of straggler wireless fixes for 3.2.  Included is
a NULL pointer fix for mwifiex, a regression fix for handling rx
header lengths for differnt b43 firmwares in PIO mode, a revert of
a one-liner for Bluetooth HCI that was causing uncomfortable delays
during resume, and an ath9k fix for a panic when running in AP mode
with aggregation disabled.

The Bluetooth fix is a one-liner change of a delay value.  The mwifiex,
b43, and ath9k fixes are relatively small and isolated to their
respective drivers.

Please let me know if there are problems!

John

---

The following changes since commit 405cc2736527bd506fd8f652308b03b2c8a1e8b9:

  fix CAN MAINTAINERS SCM tree type (2012-01-03 14:57:43 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

Amitkumar Karwar (1):
      mwifiex: fix crash during simultaneous scan and connect

Guennadi Liakhovetski (1):
      b43: fix regression in PIO case

Gustavo F. Padovan (1):
      Revert "Bluetooth: Increase HCI reset timeout in hci_dev_do_close"

John W. Linville (2):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetooth
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Mohammed Shafi Shajakhan (1):
      ath9k: Fix kernel panic in AR2427 in AP mode

 drivers/net/wireless/ath/ath9k/main.c    |    3 +++
 drivers/net/wireless/b43/pio.c           |   16 +++++++++++++---
 drivers/net/wireless/mwifiex/sta_ioctl.c |    7 ++++++-
 net/bluetooth/hci_core.c                 |    2 +-
 4 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/a=
th/ath9k/main.c
index d2348a5..a9c5ae7 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -1843,6 +1843,9 @@ static void ath9k_sta_notify(struct ieee80211_hw *hw,
 	struct ath_softc *sc =3D hw->priv;
 	struct ath_node *an =3D (struct ath_node *) sta->drv_priv;
=20
+	if (!(sc->sc_flags & SC_OP_TXAGGR))
+		return;
+
 	switch (cmd) {
 	case STA_NOTIFY_SLEEP:
 		an->sleeping =3D true;
diff --git a/drivers/net/wireless/b43/pio.c b/drivers/net/wireless/b43/pio.c
index fcff923..279a53e 100644
--- a/drivers/net/wireless/b43/pio.c
+++ b/drivers/net/wireless/b43/pio.c
@@ -617,9 +617,19 @@ static bool pio_rx_frame(struct b43_pio_rxqueue *q)
 	const char *err_msg =3D NULL;
 	struct b43_rxhdr_fw4 *rxhdr =3D
 		(struct b43_rxhdr_fw4 *)wl->pio_scratchspace;
+	size_t rxhdr_size =3D sizeof(*rxhdr);
=20
 	BUILD_BUG_ON(sizeof(wl->pio_scratchspace) < sizeof(*rxhdr));
-	memset(rxhdr, 0, sizeof(*rxhdr));
+	switch (dev->fw.hdr_format) {
+	case B43_FW_HDR_410:
+	case B43_FW_HDR_351:
+		rxhdr_size -=3D sizeof(rxhdr->format_598) -
+			sizeof(rxhdr->format_351);
+		break;
+	case B43_FW_HDR_598:
+		break;
+	}
+	memset(rxhdr, 0, rxhdr_size);
=20
 	/* Check if we have data and wait for it to get ready. */
 	if (q->rev >=3D 8) {
@@ -657,11 +667,11 @@ data_ready:
=20
 	/* Get the preamble (RX header) */
 	if (q->rev >=3D 8) {
-		b43_block_read(dev, rxhdr, sizeof(*rxhdr),
+		b43_block_read(dev, rxhdr, rxhdr_size,
 			       q->mmio_base + B43_PIO8_RXDATA,
 			       sizeof(u32));
 	} else {
-		b43_block_read(dev, rxhdr, sizeof(*rxhdr),
+		b43_block_read(dev, rxhdr, rxhdr_size,
 			       q->mmio_base + B43_PIO_RXDATA,
 			       sizeof(u16));
 	}
diff --git a/drivers/net/wireless/mwifiex/sta_ioctl.c b/drivers/net/wireles=
s/mwifiex/sta_ioctl.c
index ea4a29b..1679c25 100644
--- a/drivers/net/wireless/mwifiex/sta_ioctl.c
+++ b/drivers/net/wireless/mwifiex/sta_ioctl.c
@@ -55,9 +55,14 @@ int mwifiex_wait_queue_complete(struct mwifiex_adapter *=
adapter)
 {
 	bool cancel_flag =3D false;
 	int status =3D adapter->cmd_wait_q.status;
-	struct cmd_ctrl_node *cmd_queued =3D adapter->cmd_queued;
+	struct cmd_ctrl_node *cmd_queued;
=20
+	if (!adapter->cmd_queued)
+		return 0;
+
+	cmd_queued =3D adapter->cmd_queued;
 	adapter->cmd_queued =3D NULL;
+
 	dev_dbg(adapter->dev, "cmd pending\n");
 	atomic_inc(&adapter->cmd_pending);
=20
diff --git a/net/bluetooth/hci_core.c b/net/bluetooth/hci_core.c
index be84ae3..b84458d 100644
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -613,7 +613,7 @@ static int hci_dev_do_close(struct hci_dev *hdev)
 	if (!test_bit(HCI_RAW, &hdev->flags)) {
 		set_bit(HCI_INIT, &hdev->flags);
 		__hci_request(hdev, hci_reset_req, 0,
-					msecs_to_jiffies(HCI_INIT_TIMEOUT));
+					msecs_to_jiffies(250));
 		clear_bit(HCI_INIT, &hdev->flags);
 	}
=20
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--p2kqVDKq5asng8Dg
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPBIG7AAoJEJctW/TcYTgGXmEP/0+PLaTaO14MHFWQfwWnoU9h
5d7zYWFzqrrdPx6+ll/yYSmTN3nKnnJfiqyAm64ZQ/ET6AP0sAwAM/wHyKlsQiyo
p3+nPiglxzqtsCdu41+tjsbETNVplOzs/cEmh4b0yqIlcHO0dSMqlZd8lZQ8q/n5
QgrE9MrhTyhtc/+eCh6UgUB/Vu45HQrS6mO/t39vk/z90wrqrynBXyKT8rQwYM5O
cRO7YHLaSOMqx6JLnQ2DW8Jr1ReZSGEbzVtT/yoO6gLQhagWwkwxXPr+lnp0Wbes
FTqx3/pQe8oPCClir1s1m8ha5C1Pix5PH72ErmV4vEsg9sUcK2RizPTO3CNix3YW
d2pKmoQSP3tuNfRTFNtKziTXWU3wOtvfBlFOh3B4lqa08Ze4euO+5mqP70VwMNoG
exOh/+5KQPZmegvfOUvzkl+k7Jw51HvKwbGAF5amSlUR18kVr0YyZfj9H7Wt2Hk+
nSablpBHdsnchECAigDPIJ7Y93XH/rmqq46mp5Q9OeQl0+vbVaZeUNB6dSa/yAFk
btoeY7VPcaAkNIY4jALPJcSh0IDcA4TiDQ7GFuwyRHnWOadUsD8+vbHcM/q6mQgL
5E2ltQ6hnRjk4xiT68osAjjOtOtvt6JTydwAlnQSW/PkqaChYARO+BsXZqhMUSqV
D7FrwRDQiEubeMQy7e3t
=kKef
-----END PGP SIGNATURE-----

--p2kqVDKq5asng8Dg--
