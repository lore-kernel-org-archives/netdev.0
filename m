From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 13/32] rt2x00: Tune link depending on link quality
Date: Fri, 28 Apr 2006 00:03:04 +0200
Message-ID: <200604280003.05170.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2423948.iAkzzFSued";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.190]:44908 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751784AbWD0WCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:02:00 -0400
Received: by nproxy.gmail.com with SMTP id x30so1388639nfb
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:02:00 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2423948.iAkzzFSued
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Add link tuning capabilities, and call this function
every time the rxdone handler has finished.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-27 21:42:29.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-27 21:45:08.000000000 +0200
@@ -618,6 +618,41 @@ rt2400pci_config_rate(struct rt2x00_pci=20
 }
=20
 /*
+ * Link tuning
+ */
+static void
+rt2400pci_link_tuner(struct rt2x00_pci *rt2x00pci)
+{
+	u8			reg;
+	char			false_cca_delta;
+
+	/*
+	 * Read false CCA counter.
+	 */
+	rt2x00_bbp_read(rt2x00pci, 39, &reg);
+
+	/*
+	 * Determine difference with previous CCA counter.
+	 */
+	false_cca_delta =3D reg - rt2x00pci->false_cca;
+	rt2x00pci->false_cca =3D reg;
+
+	/*
+	 * Check if the difference is higher than the
+	 * threshold and if so, tune the link.
+	 */
+	if (false_cca_delta >=3D 8) {
+		/*
+		 * Read and update RX AGC VGC.
+		 */
+		rt2x00_bbp_read(rt2x00pci, 13, &reg);
+		reg +=3D 2;
+		if (reg < 0x20)
+			rt2x00_bbp_write(rt2x00pci, 13, reg);
+	}
+}
+
+/*
  * TX descriptor initialization
  */
 static void
@@ -779,6 +814,9 @@ rt2400pci_rxdone(void *data)
=20
 			memcpy(skb_put(skb, size), entry->data_addr, size);
=20
+			ring->params.rx.ssi =3D
+				rt2x00_get_field32(rxd->word2, RXD_W2_RSSI);
+
 			__ieee80211_rx(net_dev, skb, &ring->params.rx);
 		}
=20
@@ -786,6 +824,11 @@ rt2400pci_rxdone(void *data)
=20
 		rt2x00_ring_index_inc(&rt2x00pci->rx);
 	}
+
+	/*
+	 * Tune link for optimal performance.
+	 */
+	rt2400pci_link_tuner(rt2x00pci);
 }
=20
 static void
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	20=
06-04-27 21:36:19.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
h	2006-04-27 21:45:08.000000000 +0200
@@ -926,6 +926,11 @@ struct rt2x00_pci{
 	struct workqueue_struct		*workqueue;
=20
 	/*
+	 * False CCA count.
+	 */
+	int					false_cca;
+
+	/*
 	 * EEPROM bus width.
 	 */
 	u8					eeprom_width;
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 21:42:29.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 21:45:08.000000000 +0200
@@ -661,6 +661,51 @@ rt2500pci_config_rate(struct rt2x00_pci=20
 }
=20
 /*
+ * Link tuning
+ */
+static void
+rt2500pci_link_tuner(struct rt2x00_pci *rt2x00pci, char rssi)
+{
+	u32			reg;
+	u8			reg_r17;
+
+	/*
+	 * Don't perform any tuning during scan.
+	 */
+	if (rt2x00pci->scan)
+		return;
+
+	rt2x00_register_read(rt2x00pci, CSR0, &reg);
+	rt2x00_bbp_read(rt2x00pci, 17, &reg_r17);
+
+	if (reg < RT2560_VERSION_D)
+		goto dynamic_cca_tune;
+
+	if (rssi < 40) {
+		if (reg_r17 >=3D 0x41)
+			rt2x00_bbp_write(rt2x00pci, 17, reg_r17);
+		return;
+	} else if (rssi >=3D 62) {
+		if (reg_r17 !=3D 0x50)
+			rt2x00_bbp_write(rt2x00pci, 17, 0x50);
+		return;
+	} else if (reg_r17 >=3D 0x41) {
+		rt2x00_bbp_write(rt2x00pci, 17, reg_r17);
+		return;
+	}
+
+dynamic_cca_tune:
+	rt2x00_register_read(rt2x00pci, CNT3, &reg);
+
+	reg =3D rt2x00_get_field32(reg, CNT3_FALSE_CCA);
+
+	if (reg > 512 && reg_r17 < 0x40)
+		rt2x00_bbp_write(rt2x00pci, 17, ++reg_r17);
+	else if (reg < 100 && reg_r17 > 0x32)
+		rt2x00_bbp_write(rt2x00pci, 17, --reg_r17);
+}
+
+/*
  * TX descriptor initialization
  */
 static void
@@ -819,6 +864,14 @@ rt2500pci_rxdone(void *data)
 	struct sk_buff		*skb;
 	struct rxd		*rxd;
 	u16			size;
+	u8			rssi_count;
+	char			total_rssi;
+
+	/*
+	 * Initialize variable for average RSSI calculation.
+	 */
+	rssi_count =3D 0;
+	total_rssi =3D 0;
=20
 	while (1) {
 		entry =3D rt2x00_get_data_entry(ring);
@@ -843,12 +896,24 @@ rt2500pci_rxdone(void *data)
=20
 			memcpy(skb_put(skb, size), entry->data_addr, size);
=20
+			ring->params.rx.ssi =3D
+				rt2x00_get_field32(rxd->word2, RXD_W2_RSSI);
+
 			__ieee80211_rx(net_dev, skb, &ring->params.rx);
+
+			rssi_count++;
+			total_rssi +=3D ring->params.rx.ssi;
 		}
 		rt2x00_set_field32(&rxd->word0, RXD_W0_OWNER_NIC, 1);
=20
 		rt2x00_ring_index_inc(&rt2x00pci->rx);
 	}
+
+	/*
+	 * Tune link for optimal performance.
+	 */
+	if (total_rssi && rssi_count)
+		rt2500pci_link_tuner(rt2x00pci, total_rssi / rssi_count);
 }
=20
 static void
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 21:44:33.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 21:45:08.000000000 +0200
@@ -485,6 +485,68 @@ rt2500usb_config_rate(struct rt2x00_usb=20
 }
=20
 /*
+ * Link tuning
+ */
+static void
+rt2500usb_link_tuner(struct rt2x00_usb *rt2x00usb, char rssi)
+{
+	u16			reg;
+	u8			reg_r17;
+	u8			up_bound;
+	u8			low_bound;
+
+	/*
+	 * Don't perform any tuning during scan.
+	 */
+	if (rt2x00usb->scan)
+		return;
+
+	low_bound =3D 0x32;
+	if (rssi >=3D 43)
+		up_bound =3D 0x40;
+	else
+		up_bound =3D 0x40 - (43 - rssi);
+	if (up_bound < low_bound)
+		up_bound =3D low_bound;
+
+	if (rssi > 75) {
+		rt2x00_bbp_write(rt2x00usb, 24, 0x70);
+		rt2x00_bbp_write(rt2x00usb, 25, 0x40);
+		rt2x00_bbp_write(rt2x00usb, 61, 0x6d);
+	} else {
+		rt2x00_bbp_write(rt2x00usb, 24, 0x80);
+		rt2x00_bbp_write(rt2x00usb, 25, 0x50);
+		rt2x00_bbp_write(rt2x00usb, 61, 0x60);
+	}
+
+	rt2x00_bbp_read(rt2x00usb, 17, &reg_r17);
+
+	if (rssi > 80) {
+		if (reg_r17 !=3D 0x60)
+			rt2x00_bbp_write(rt2x00usb, 17, 0x60);
+		return;
+	} else if (rssi >=3D 62) {
+		if (reg_r17 !=3D 0x48)
+			rt2x00_bbp_write(rt2x00usb, 17, 0x48);
+		return;
+	} else if (rssi >=3D 46) {
+		if (reg_r17 !=3D 0x41)
+			rt2x00_bbp_write(rt2x00usb, 17, 0x41);
+		return;
+	} else if (reg_r17 > up_bound) {
+		rt2x00_bbp_write(rt2x00usb, 17, up_bound);
+		return;
+	}
+
+	rt2x00_register_read(rt2x00usb, STA_CSR3, &reg);
+
+	if (reg > 512 && reg_r17 < up_bound)
+		rt2x00_bbp_write(rt2x00usb, 17, ++reg_r17);
+	else if (reg < 100 && reg_r17 > low_bound)
+		rt2x00_bbp_write(rt2x00usb, 17, --reg_r17);
+}
+
+/*
  * TX descriptor initialization
  */
 static void
@@ -636,6 +698,14 @@ rt2500usb_rxdone(void *data)
 	struct sk_buff		*skb;
 	struct rxd		*rxd;
 	u16			size;
+	u8			rssi_count;
+	char			total_rssi;
+
+	/*
+	 * Initialize variable for average RSSI calculation.
+	 */
+	rssi_count =3D 0;
+	total_rssi =3D 0;
=20
 	while (1) {
 		entry =3D rt2x00_get_data_entry(ring);
@@ -670,13 +740,25 @@ rt2500usb_rxdone(void *data)
=20
 			memcpy(skb_put(skb, size), entry->data_addr, size);
=20
+			ring->params.rx.ssi =3D
+				rt2x00_get_field32(rxd->word1, RXD_W1_RSSI);
+
 			__ieee80211_rx(net_dev, skb, &ring->params.rx);
+
+			rssi_count++;
+			total_rssi +=3D ring->params.rx.ssi;
 		}
=20
 		usb_submit_urb(entry->urb, GFP_ATOMIC);
=20
 		rt2x00_ring_index_inc(ring);
 	}
+
+	/*
+	 * Tune link for optimal performance.
+	 */
+	if (total_rssi && rssi_count)
+		rt2500usb_link_tuner(rt2x00usb, total_rssi / rssi_count);
 }
=20
 static void

--nextPart2423948.iAkzzFSued
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+ZaqndE37Em0gRAvntAJ4tOxlv5D75xQ5IG6s9GYfl/1wBQgCdGMUS
I8YQGX8ncUZsb1LbX7okKGQ=
=2C+/
-----END PGP SIGNATURE-----

--nextPart2423948.iAkzzFSued--
