From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 24/32] rt2x00: Use correct desc_addr and data_addr
Date: Fri, 28 Apr 2006 00:03:15 +0200
Message-ID: <200604280003.15911.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1805190.hTcAfM5gME";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.188]:30060 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751797AbWD0WCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:02:17 -0400
Received: by nproxy.gmail.com with SMTP id n29so1463863nfc
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:02:16 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1805190.hTcAfM5gME
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

USB buffer don't have a seperate descriptor ring and data ring.
The location of the descriptor area and data area depends
on the type of ring. Add functions to determine the correct
location and use these instead of the invalid desc_addr and data_addr
pointers.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 21:54:33.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 21:55:14.000000000 +0200
@@ -740,7 +740,7 @@ rt2500usb_rxdone(void *data)
=20
 	while (1) {
 		entry =3D rt2x00_get_data_entry(ring);
=2D		rxd =3D entry->desc_addr;
+		rxd =3D rt2x00usb_rxdesc_addr(entry);
=20
 		/*
 		* There has been a problem. Ignore packet.
@@ -769,7 +769,8 @@ rt2500usb_rxdone(void *data)
=20
 			skb_reserve(skb, NET_IP_ALIGN);
=20
=2D			memcpy(skb_put(skb, size), entry->data_addr, size);
+			memcpy(skb_put(skb, size),
+				rt2x00usb_rxdata_addr(entry), size);
=20
 			rt2x00usb->rx_params.ssi =3D
 				rt2x00_get_field32(rxd->word1, RXD_W1_RSSI);
@@ -805,7 +806,7 @@ rt2500usb_txdone(void *data)
=20
 	 while (!rt2x00_ring_empty(ring)) {
 		entry =3D rt2x00_get_data_entry_done(ring);
=2D		txd =3D entry->desc_addr;
+		txd =3D rt2x00usb_txdesc_addr(entry);
=20
 		ack =3D rt2x00_get_field32(txd->word0, TXD_W0_ACK);
 =09
@@ -937,16 +938,14 @@ rt2500usb_alloc_ring(
 			entry[counter].urb =3D usb_alloc_urb(0, GFP_KERNEL);
 		else
 			entry[counter].urb =3D NULL;
=2D		if (entry[counter].urb =3D=3D NULL)
+		if (!entry[counter].urb)
 			status =3D -ENOMEM;
 		entry[counter].skb =3D NULL;
=2D		entry[counter].desc_addr =3D ring->data_addr
=2D			+ (counter * ring->desc_size);
 		entry[counter].data_addr =3D ring->data_addr
=2D			+ (ring->stats.limit * ring->desc_size)
+			+ (counter * ring->desc_size)
 			+ (counter * ring->data_size);
 		entry[counter].data_dma =3D ring->data_dma
=2D			+ (ring->stats.limit * ring->desc_size)
+			+ (counter * ring->desc_size)
 			+ (counter * ring->data_size);
 	}
=20
@@ -959,7 +958,7 @@ rt2500usb_free_ring(struct rt2x00_usb *r
 	struct	data_entry	*entry;
 	u8			counter;
=20
=2D	if (ring->entry)
+	if (!ring->entry)
 		goto exit;
=20
 	entry =3D (struct data_entry*)ring->entry;
@@ -1091,9 +1090,9 @@ rt2500usb_init_registers(struct rt2x00_u
 		return -EBUSY;
=20
 	rt2x00_vendor_request(rt2x00usb, USB_DEVICE_MODE,
=2D		USB_VENDOR_REQUEST_OUT, USB_MODE_TEST, 0x00, NULL, 0);
+		USB_VENDOR_REQUEST_OUT, 0x00, USB_MODE_TEST, NULL, 0);
 	rt2x00_vendor_request(rt2x00usb, USB_SINGLE_WRITE,
=2D		USB_VENDOR_REQUEST_OUT, 0x0308, 0x00f0, NULL, 0);
+		USB_VENDOR_REQUEST_OUT, 0x0308, 0xf0, NULL, 0);
=20
 	rt2x00_register_write(rt2x00usb, TXRX_CSR2, 0x0001);
 	rt2x00_register_write(rt2x00usb, MAC_CSR13, 0x1111);
@@ -1242,9 +1241,9 @@ rt2500usb_tx(struct net_device *net_dev,
 		return NET_RX_DROP;
=20
 	entry =3D rt2x00_get_data_entry(ring);
=2D	txd =3D entry->desc_addr;
+	txd =3D rt2x00usb_txdesc_addr(entry);
=20
=2D	memcpy(entry->data_addr, skb->data, skb->len);
+	memcpy(rt2x00usb_txdata_addr(entry), skb->data, skb->len);
 	rt2500usb_write_tx_desc(rt2x00usb, txd, skb, control);
 	entry->skb =3D skb;
=20
@@ -1621,8 +1620,9 @@ rt2500usb_beacon_update(struct net_devic
 	 */
 	control->queue =3D IEEE80211_TX_QUEUE_BEACON;
=20
=2D	memcpy(entry->data_addr, skb->data, skb->len);
=2D	rt2500usb_write_tx_desc(rt2x00usb, entry->desc_addr, skb, control);
+	memcpy(rt2x00usb_txdata_addr(entry), skb->data, skb->len);
+	rt2500usb_write_tx_desc(rt2x00usb,
+		rt2x00usb_txdesc_addr(entry), skb, control);
=20
 	usb_fill_bulk_urb(
 		entry->urb,
@@ -1658,6 +1658,14 @@ rt2500usb_init_eeprom(struct rt2x00_usb=20
 	rt2x00_set_chip(&rt2x00usb->chip, RT2570,
 		rt2x00_get_field16(eeprom, EEPROM_ANTENNA_RF_TYPE));
=20
+	if (!rt2x00_rf(&rt2x00usb->chip, RF2522)
+	&& !rt2x00_rf(&rt2x00usb->chip, RF2523)
+	&& !rt2x00_rf(&rt2x00usb->chip, RF2524)
+	&& !rt2x00_rf(&rt2x00usb->chip, RF2525)
+	&& !rt2x00_rf(&rt2x00usb->chip, RF2525E)
+	&& !rt2x00_rf(&rt2x00usb->chip, RF5222))
+		return -ENODEV;
+
 	/*
 	 * 3 - Identify default antenna configuration.
 	 * Ralink devices have have antenna options for both TX as RX.
@@ -1691,26 +1699,27 @@ rt2500usb_init_mac(struct rt2x00_usb *rt
 {
 	struct net_device	*net_dev =3D usb_get_intfdata(
 						rt2x00usb->usb_intf);
=2D	u16			reg[3] =3D {0, 0, 0};
+	u16			eeprom[3] =3D {0, 0, 0};
=20
 	/*
 	 * Read MAC address from EEPROM.
 	 */
=2D	rt2x00_eeprom_multiread(rt2x00usb, EEPROM_MAC_ADDR, &reg[0], 6);
+	rt2x00_eeprom_multiread(rt2x00usb, EEPROM_MAC_ADDR, &eeprom[0], 6);
=20
=2D	net_dev->dev_addr[0] =3D rt2x00_get_field16(reg[0], MAC_CSR2_BYTE0);
=2D	net_dev->dev_addr[1] =3D rt2x00_get_field16(reg[0], MAC_CSR2_BYTE1);
=2D	net_dev->dev_addr[2] =3D rt2x00_get_field16(reg[1], MAC_CSR3_BYTE2);
=2D	net_dev->dev_addr[3] =3D rt2x00_get_field16(reg[1], MAC_CSR3_BYTE3);
=2D	net_dev->dev_addr[4] =3D rt2x00_get_field16(reg[2], MAC_CSR4_BYTE4);
=2D	net_dev->dev_addr[5] =3D rt2x00_get_field16(reg[2], MAC_CSR4_BYTE5);
+	net_dev->dev_addr[0] =3D rt2x00_get_field16(eeprom[0], MAC_CSR2_BYTE0);
+	net_dev->dev_addr[1] =3D rt2x00_get_field16(eeprom[0], MAC_CSR2_BYTE1);
+	net_dev->dev_addr[2] =3D rt2x00_get_field16(eeprom[1], MAC_CSR3_BYTE2);
+	net_dev->dev_addr[3] =3D rt2x00_get_field16(eeprom[1], MAC_CSR3_BYTE3);
+	net_dev->dev_addr[4] =3D rt2x00_get_field16(eeprom[2], MAC_CSR4_BYTE4);
+	net_dev->dev_addr[5] =3D rt2x00_get_field16(eeprom[2], MAC_CSR4_BYTE5);
=20
 	net_dev->addr_len =3D 6;
=20
 	/*
 	 * Write MAC address to register.
 	 */
=2D	rt2x00_register_multiwrite(rt2x00usb, MAC_CSR2, &reg[0], sizeof(reg));
+	rt2x00_register_multiwrite(rt2x00usb, MAC_CSR2,
+		&eeprom[0], sizeof(reg));
=20
 	return 0;
 }
@@ -1730,7 +1739,7 @@ rt2500usb_init_hw_channels(struct rt2x00
 		{ RF2523,	{ 0x00022010, 0x000e0111, 0x00000a1b } },
 		{ RF2524,	{ 0x00032020, 0x00000101, 0x00000a1b } },
 		{ RF2525,	{ 0x00022020, 0x00060111, 0x00000a1b } },
=2D		{ RF2525E,	{ 0x00022020, 0x00060111, 0x00000000 } },
+		{ RF2525E,	{ 0x00022010, 0x00060111, 0x00000000 } },
 		{ RF5222,	{ 0x00000000, 0x00000101, 0x00000000 } }
 	};
=20
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	20=
06-04-27 21:53:13.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
h	2006-04-27 21:55:14.000000000 +0200
@@ -683,6 +683,36 @@ struct data_entry{
 } __attribute__ ((packed));
=20
 /*
+ * The location of the descriptor is variating and depends
+ * on the fact if it is a TX or RX ring and the length of the packet.
+ * We need some small handlers to properly access the descriptors.
+ */
+static inline void*
+rt2x00usb_rxdata_addr(struct data_entry *entry)
+{
+	return entry->data_addr;
+}
+
+static inline void*
+rt2x00usb_rxdesc_addr(struct data_entry *entry)
+{
+	return entry->data_addr +
+		(entry->urb->actual_length - entry->ring->desc_size);
+}
+
+static inline void*
+rt2x00usb_txdata_addr(struct data_entry *entry)
+{
+	return entry->data_addr + entry->ring->desc_size;
+}
+
+static inline void*
+rt2x00usb_txdesc_addr(struct data_entry *entry)
+{
+	return entry->data_addr;
+}
+
+/*
  * Device specific structure.
  */
 struct rt2x00_usb{

--nextPart1805190.hTcAfM5gME
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+jaqndE37Em0gRAoYcAJ91cABxmh4gv5FEOsI4FSzZtH2iwwCgy8kI
eO/BFApqEHJrgwcFhXwAhu8=
=mBT+
-----END PGP SIGNATURE-----

--nextPart1805190.hTcAfM5gME--
