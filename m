From: Michael Wu <flamingice@sourmilk.net>
Subject: [PATCH] zd1211rw-d80211: Use ieee80211_tx_status
Date: Tue, 5 Dec 2006 23:26:46 -0500
Message-ID: <200612052326.51697.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3875355.5gGq4sHpbd";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.rutgers.edu ([128.6.72.243]:12121 "EHLO
	annwn13.rutgers.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759963AbWLFE1G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 23:27:06 -0500
To: Ulrich Kunitz <kune@deine-taler.de>, Daniel Drake <dsd@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3875355.5gGq4sHpbd
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

zd1211rw-d80211: Use ieee80211_tx_status

This makes zd1211rw-d80211 properly report the TX result of a frame via
ieee80211_tx_status. I'm not sure if we can do much better than this since
the hardware doesn't explicitly report the success/failure of TXed frames=20
that require ACKs. We have to guess which ACKs match up with which
frames we're trying to send.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
=2D--

 drivers/net/wireless/d80211/zd1211rw/zd_chip.h |    3 +
 drivers/net/wireless/d80211/zd1211rw/zd_mac.c  |   96 ++++++++++++++++++++=
++++
 drivers/net/wireless/d80211/zd1211rw/zd_mac.h  |    2 +
 drivers/net/wireless/d80211/zd1211rw/zd_usb.c  |    8 --
 4 files changed, 99 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_chip.h b/drivers/net/w=
ireless/d80211/zd1211rw/zd_chip.h
index 4eaec47..b9c225d 100644
=2D-- a/drivers/net/wireless/d80211/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/d80211/zd1211rw/zd_chip.h
@@ -467,8 +467,9 @@
 #define RX_FILTER_BEACON		(1 <<  8)
 #define RX_FILTER_DISASSOC		(1 << 10)
 #define RX_FILTER_AUTH			(1 << 11)
+#define RX_FILTER_ACK			(1 << 29)
 #define AP_RX_FILTER			0x0400feff
=2D#define STA_RX_FILTER			0x0000ffff
+#define STA_RX_FILTER			0x2000ffff
=20
 /* Monitor mode sets filter to 0xfffff */
=20
diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_mac.c b/drivers/net/wi=
reless/d80211/zd1211rw/zd_mac.c
index a76fa6a..6ee650f 100644
=2D-- a/drivers/net/wireless/d80211/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/d80211/zd1211rw/zd_mac.c
@@ -153,6 +153,7 @@ static int zd_mac_stop(struct ieee80211_
 {
 	struct zd_mac *mac =3D zd_dev_mac(dev);
 	struct zd_chip *chip =3D &mac->chip;
+	struct sk_buff *skb;
=20
 	/*
 	 * The order here deliberately is a little different from the open()
@@ -167,6 +168,13 @@ static int zd_mac_stop(struct ieee80211_
 	zd_chip_switch_radio_off(chip);
 	zd_chip_disable_int(chip);
=20
+	while ((skb =3D skb_dequeue(&mac->tx_queue))) {
+		struct ieee80211_tx_control *control =3D
+			*(struct ieee80211_tx_control **)skb->cb;
+		kfree(control);
+		kfree_skb(skb);
+	}
+
 	return 0;
 }
=20
@@ -312,6 +320,7 @@ static int zd_mac_tx(struct ieee80211_hw
 		     struct ieee80211_tx_control *control)
 {
 	struct zd_mac *mac =3D zd_dev_mac(dev);
+	struct ieee80211_tx_control *control_copy;
 	int r;
=20
 	if (skb_headroom(skb) < dev->extra_tx_headroom &&
@@ -325,11 +334,43 @@ static int zd_mac_tx(struct ieee80211_hw
 	if (r)
 		return r;
=20
=2D	/* FIXME: figure out how to check if the TXed packet was ACKed */
=2D	kfree_skb(skb);
+	if (control->flags & IEEE80211_TXCTL_NO_ACK) {
+		kfree_skb(skb);
+		return 0;
+	}
+
+	control_copy =3D kmalloc(sizeof(*control_copy), GFP_ATOMIC);
+	if (control_copy)
+		memcpy(control_copy, control, sizeof(*control_copy));
+
+	*(struct ieee80211_tx_control **)skb->cb =3D control_copy;
+	skb_pull(skb, sizeof(struct zd_ctrlset));
+	skb_queue_tail(&mac->tx_queue, skb);
 	return 0;
 }
=20
+void zd_mac_tx_failed(struct ieee80211_hw *dev)
+{
+	struct zd_mac *mac =3D zd_dev_mac(dev);
+	struct ieee80211_tx_control *control;
+	struct sk_buff *skb;
+
+	skb =3D skb_dequeue(&mac->tx_queue);
+	if (!skb)
+		return;
+
+	control =3D *(struct ieee80211_tx_control **)skb->cb;
+	if (control) {
+		struct ieee80211_tx_status status =3D {{0}};
+		memcpy(&status.control, control, sizeof(status.control));
+		ieee80211_tx_status_irqsafe(dev, skb, &status);
+		kfree(control);
+	} else
+		kfree_skb(skb);
+
+	return;
+}
+
 struct zd_rt_hdr {
 	struct ieee80211_radiotap_header rt_hdr;
 	u8  rt_flags;
@@ -391,6 +432,52 @@ static int fill_rx_stats(struct ieee8021
 	return 0;
 }
=20
+static int filter_ack(struct ieee80211_hw *dev, struct ieee80211_hdr *rx_h=
dr,
+		      struct ieee80211_rx_status *stats)
+{
+	struct zd_mac *mac =3D zd_dev_mac(dev);
+	u16 fc =3D le16_to_cpu(rx_hdr->frame_control);
+	struct sk_buff *skb;
+	struct ieee80211_hdr *tx_hdr;
+	struct ieee80211_tx_control *control;
+	struct ieee80211_tx_status status =3D {{0}};
+
+	if ((fc & (IEEE80211_FCTL_FTYPE | IEEE80211_FCTL_STYPE)) !=3D
+	    (IEEE80211_FTYPE_CTL | IEEE80211_STYPE_ACK))
+		return 0;
+
+	spin_lock(&mac->tx_queue.lock);
+
+	skb =3D skb_peek(&mac->tx_queue);
+	if (!skb) {
+		spin_unlock(&mac->tx_queue.lock);
+		return 1;
+	}
+
+	tx_hdr =3D (struct ieee80211_hdr *) skb->data;
+
+	if (!memcmp(tx_hdr->addr2, rx_hdr->addr1, ETH_ALEN))
+		skb =3D __skb_dequeue(&mac->tx_queue);
+	else {
+		spin_unlock(&mac->tx_queue.lock);
+		return 1;
+	}
+
+	spin_unlock(&mac->tx_queue.lock);
+
+	control =3D *(struct ieee80211_tx_control **)skb->cb;
+	if (control) {
+		memcpy(&status.control, control, sizeof(status.control));
+		status.flags =3D IEEE80211_TX_STATUS_ACK;
+		status.ack_signal =3D stats->ssi;
+		ieee80211_tx_status_irqsafe(dev, skb, &status);
+		kfree(control);
+	} else
+		kfree_skb(skb);
+
+	return 1;
+}
+
 int zd_mac_rx(struct ieee80211_hw *dev, const u8 *buffer, unsigned int len=
gth)
 {
 	int r;
@@ -411,6 +498,10 @@ int zd_mac_rx(struct ieee80211_hw *dev,
 		  sizeof(struct rx_status);
 	buffer +=3D ZD_PLCP_HEADER_SIZE;
=20
+	if (length =3D=3D (10 /* IEEE80211_1ADDR_LEN */ + FCS_LEN) &&
+	    filter_ack(dev, (struct ieee80211_hdr *)buffer, &stats))
+		return 0;
+
 	skb =3D dev_alloc_skb(sizeof(struct zd_rt_hdr) + length);
 	if (!skb)
 		return -ENOMEM;
@@ -523,6 +614,7 @@ struct ieee80211_hw *zd_mac_alloc(struct
 	dev->queues =3D 1;
 	dev->extra_tx_headroom =3D sizeof(struct zd_ctrlset);
=20
+	skb_queue_head_init(&mac->tx_queue);
 	zd_chip_init(&mac->chip, dev, intf);
 	housekeeping_init(mac);
=20
diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_mac.h b/drivers/net/wi=
reless/d80211/zd1211rw/zd_mac.h
index cccf66c..e2ba410 100644
=2D-- a/drivers/net/wireless/d80211/zd1211rw/zd_mac.h
+++ b/drivers/net/wireless/d80211/zd1211rw/zd_mac.h
@@ -135,6 +135,7 @@ struct zd_mac {
 	int mode;
 	int associated;
 	u8 *hwaddr;
+	struct sk_buff_head tx_queue;
 	struct ieee80211_channel channels[14];
 	struct ieee80211_rate rates[12];
 	struct ieee80211_hw_modes modes[2];
@@ -163,6 +164,7 @@ void zd_mac_clear(struct zd_mac *mac);
 int zd_mac_init_hw(struct ieee80211_hw *dev, u8 device_type);
=20
 int zd_mac_rx(struct ieee80211_hw *dev, const u8 *buffer, unsigned int len=
gth);
+void zd_mac_tx_failed(struct ieee80211_hw *dev);
=20
 #ifdef DEBUG
 void zd_dump_rx_status(const struct rx_status *status);
diff --git a/drivers/net/wireless/d80211/zd1211rw/zd_usb.c b/drivers/net/wi=
reless/d80211/zd1211rw/zd_usb.c
index 9112820..bacb019 100644
=2D-- a/drivers/net/wireless/d80211/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/d80211/zd1211rw/zd_usb.c
@@ -398,12 +398,6 @@ out:
 	spin_unlock(&intr->lock);
 }
=20
=2Dstatic inline void handle_retry_failed_int(struct urb *urb)
=2D{
=2D	dev_dbg_f(urb_dev(urb), "retry failed interrupt\n");
=2D}
=2D
=2D
 static void int_urb_complete(struct urb *urb)
 {
 	int r;
@@ -439,7 +433,7 @@ static void int_urb_complete(struct urb
 		handle_regs_int(urb);
 		break;
 	case USB_INT_ID_RETRY_FAILED:
=2D		handle_retry_failed_int(urb);
+		zd_mac_tx_failed(zd_usb_to_dev(urb->context));
 		break;
 	default:
 		dev_dbg_f(urb_dev(urb), "error: urb %p unknown id %x\n", urb,

--nextPart3875355.5gGq4sHpbd
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFdkaLT3Oqt9AH4aERAr9nAJ40LnwaRawItgoAoBdZIyQLDwMjdwCfR2G7
sOMbBk3eX8wTIod3PZiBISo=
=g+yC
-----END PGP SIGNATURE-----

--nextPart3875355.5gGq4sHpbd--
