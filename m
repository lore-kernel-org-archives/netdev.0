From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 17/32] rt2x00: Put net_device structure in data_ring
Date: Fri, 28 Apr 2006 00:03:09 +0200
Message-ID: <200604280003.09753.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2067323.kvEN3I9dsK";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.190]:44908 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751790AbWD0WCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:02:09 -0400
Received: by nproxy.gmail.com with SMTP id x30so1388639nfb
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:02:08 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2067323.kvEN3I9dsK
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Change the structure stored in the data_ring structure
from the rt2x00_pci or rt2x00_usb to net_device.
This allows for better type checking, and the net_dev
is more often used in the interrupt handlers.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-27 21:48:21.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-27 21:49:08.000000000 +0200
@@ -760,10 +760,8 @@ rt2400pci_write_tx_desc(
 static void
 rt2400pci_beacondone(void *data)
 {
=2D	struct data_ring	*ring =3D (struct data_ring*)data;
=2D	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)ring->dev;
=2D	struct net_device	*net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
=2D	struct sk_buff		*skb;
+	struct data_ring		*ring =3D (struct data_ring*)data;
+	struct sk_buff			*skb;
 	struct ieee80211_tx_control	beacon;
=20
 	memset(&beacon, 0x00, sizeof(beacon));
@@ -771,11 +769,11 @@ rt2400pci_beacondone(void *data)
 	/*
 	 * TODO: What value should be passed as bss_idx?
 	 */
=2D	skb =3D ieee80211_beacon_get(net_dev, 0, &beacon);
+	skb =3D ieee80211_beacon_get(ring->net_dev, 0, &beacon);
 	if (!skb)
 		return;
=20
=2D	rt2400pci_beacon_update(net_dev, skb, &beacon);
+	rt2400pci_beacon_update(ring->net_dev, skb, &beacon);
=20
 	dev_kfree_skb_any(skb);
 }
@@ -784,8 +782,8 @@ static void
 rt2400pci_rxdone(void *data)
 {
 	struct data_ring	*ring =3D (struct data_ring*)data;
=2D	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)ring->dev;
=2D	struct net_device	*net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
+	struct rt2x00_pci	*rt2x00pci =3D
+		ieee80211_dev_hw_data(ring->net_dev);
 	struct data_entry	*entry;
 	struct sk_buff		*skb;
 	struct rxd		*rxd;
@@ -817,7 +815,8 @@ rt2400pci_rxdone(void *data)
 			rt2x00pci->rx_params.ssi =3D
 				rt2x00_get_field32(rxd->word2, RXD_W2_RSSI);
=20
=2D			__ieee80211_rx(net_dev, skb, &rt2x00pci->rx_params);
+			__ieee80211_rx(ring->net_dev,
+				skb, &rt2x00pci->rx_params);
 		}
=20
 		rt2x00_set_field32(&rxd->word0, RXD_W0_OWNER_NIC, 1);
@@ -835,8 +834,8 @@ static void
 rt2400pci_txdone(void *data)
 {
 	struct data_ring	*ring =3D (struct data_ring*)data;
=2D	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)ring->dev;
=2D	struct net_device	*net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
+	struct rt2x00_pci	*rt2x00pci =3D
+		ieee80211_dev_hw_data(ring->net_dev);
 	struct data_entry	*entry;
 	struct txd		*txd;
 	int			tx_status;
@@ -881,7 +880,8 @@ rt2400pci_txdone(void *data)
 		entry->tx_status.retry_count =3D rt2x00_get_field32(
 			txd->word0, TXD_W0_RETRY_COUNT);
=20
=2D		ieee80211_tx_status(net_dev, entry->skb, &entry->tx_status);
+		ieee80211_tx_status(ring->net_dev,
+			entry->skb, &entry->tx_status);
=20
 		rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
 		entry->skb =3D NULL;
@@ -975,7 +975,7 @@ rt2400pci_alloc_ring(
 	/*
 	 *Set device structure.
 	 */
=2D	ring->dev =3D rt2x00pci;
+	ring->net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
=20
 	/*
 	 * Initialize work structure for deferred work.
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 21:48:21.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 21:49:08.000000000 +0200
@@ -834,10 +834,8 @@ rt2500pci_write_tx_desc(
 static void
 rt2500pci_beacondone(void *data)
 {
=2D	struct data_ring	*ring =3D (struct data_ring*)data;
=2D	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)ring->dev;
=2D	struct net_device	*net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
=2D	struct sk_buff		*skb;
+	struct data_ring		*ring =3D (struct data_ring*)data;
+	struct sk_buff			*skb;
 	struct ieee80211_tx_control	beacon;
=20
 	memset(&beacon, 0x00, sizeof(beacon));
@@ -845,11 +843,11 @@ rt2500pci_beacondone(void *data)
 	/*
 	 * TODO: What value should be passed as bss_idx?
 	 */
=2D	skb =3D ieee80211_beacon_get(net_dev, 0, &beacon);
+	skb =3D ieee80211_beacon_get(ring->net_dev, 0, &beacon);
 	if (!skb)
 		return;
=20
=2D	rt2500pci_beacon_update(net_dev, skb, &beacon);
+	rt2500pci_beacon_update(ring->net_dev, skb, &beacon);
=20
 	dev_kfree_skb_any(skb);
 }
@@ -858,8 +856,8 @@ static void
 rt2500pci_rxdone(void *data)
 {
 	struct data_ring	*ring =3D (struct data_ring*)data;
=2D	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)ring->dev;
=2D	struct net_device	*net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
+	struct rt2x00_pci	*rt2x00pci =3D
+		ieee80211_dev_hw_data(ring->net_dev);
 	struct data_entry	*entry;
 	struct sk_buff		*skb;
 	struct rxd		*rxd;
@@ -899,7 +897,8 @@ rt2500pci_rxdone(void *data)
 			rt2x00pci->rx_params.ssi =3D
 				rt2x00_get_field32(rxd->word2, RXD_W2_RSSI);
=20
=2D			__ieee80211_rx(net_dev, skb, &rt2x00pci->rx_params);
+			__ieee80211_rx(ring->net_dev,
+				skb, &rt2x00pci->rx_params);
=20
 			rssi_count++;
 			total_rssi +=3D rt2x00pci->rx_params.ssi;
@@ -920,8 +919,8 @@ static void
 rt2500pci_txdone(void *data)
 {
 	struct data_ring	*ring =3D (struct data_ring*)data;
=2D	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)ring->dev;
=2D	struct net_device	*net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
+	struct rt2x00_pci	*rt2x00pci =3D
+		ieee80211_dev_hw_data(ring->net_dev);
 	struct data_entry	*entry;
 	struct txd		*txd;
 	int			tx_status;
@@ -966,7 +965,8 @@ rt2500pci_txdone(void *data)
 		entry->tx_status.retry_count =3D rt2x00_get_field32(
 			txd->word0, TXD_W0_RETRY_COUNT);
=20
=2D		ieee80211_tx_status(net_dev, entry->skb, &entry->tx_status);
+		ieee80211_tx_status(ring->net_dev,
+			entry->skb, &entry->tx_status);
=20
 		rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 0);
 		entry->skb =3D NULL;
@@ -1060,7 +1060,7 @@ rt2500pci_alloc_ring(
 	/*
 	 *Set device structure.
 	 */
=2D	ring->dev =3D rt2x00pci;
+	ring->net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
=20
 	/*
 	 * Initialize work structure for deferred work.
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 21:48:21.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 21:49:08.000000000 +0200
@@ -666,11 +666,8 @@ rt2500usb_write_tx_desc(
 static void
 rt2500usb_beacondone(void *data)
 {
=2D	struct data_ring	*ring =3D (struct data_ring*)data;
=2D	struct rt2x00_usb	*rt2x00usb =3D (struct rt2x00_usb*)ring->dev;
=2D	struct net_device	*net_dev =3D usb_get_intfdata(
=2D						rt2x00usb->usb_intf);
=2D	struct sk_buff		*skb;
+	struct data_ring		*ring =3D (struct data_ring*)data;
+	struct sk_buff			*skb;
 	struct ieee80211_tx_control	beacon;
=20
 	memset(&beacon, 0x00, sizeof(beacon));
@@ -678,11 +675,11 @@ rt2500usb_beacondone(void *data)
 	/*
 	 * TODO: What value should be passed as bss_idx?
 	 */
=2D	skb =3D ieee80211_beacon_get(net_dev, 0, &beacon);
+	skb =3D ieee80211_beacon_get(ring->net_dev, 0, &beacon);
 	if (!skb)
 		return;
=20
=2D	rt2500usb_beacon_update(net_dev, skb, &beacon);
+	rt2500usb_beacon_update(ring->net_dev, skb, &beacon);
=20
 	dev_kfree_skb_any(skb);
 }
@@ -691,9 +688,8 @@ static void
 rt2500usb_rxdone(void *data)
 {
 	struct data_ring	*ring =3D (struct data_ring*)data;
=2D	struct rt2x00_usb	*rt2x00usb =3D (struct rt2x00_usb*)ring->dev;
=2D	struct net_device	*net_dev =3D usb_get_intfdata(
=2D						rt2x00usb->usb_intf);
+	struct rt2x00_usb	*rt2x00usb =3D
+		ieee80211_dev_hw_data(ring->net_dev);
 	struct data_entry	*entry;
 	struct sk_buff		*skb;
 	struct rxd		*rxd;
@@ -743,7 +739,8 @@ rt2500usb_rxdone(void *data)
 			rt2x00usb->rx_params.ssi =3D
 				rt2x00_get_field32(rxd->word1, RXD_W1_RSSI);
=20
=2D			__ieee80211_rx(net_dev, skb, &rt2x00usb->rx_params);
+			__ieee80211_rx(ring->net_dev,
+				skb, &rt2x00usb->rx_params);
=20
 			rssi_count++;
 			total_rssi +=3D rt2x00usb->rx_params.ssi;
@@ -765,9 +762,8 @@ static void
 rt2500usb_txdone(void *data)
 {
 	struct data_ring	*ring =3D (struct data_ring*)data;
=2D	struct rt2x00_usb	*rt2x00usb =3D (struct rt2x00_usb*)ring->dev;
=2D	struct net_device	*net_dev =3D usb_get_intfdata(
=2D						rt2x00usb->usb_intf);
+	struct rt2x00_usb	*rt2x00usb =3D
+		ieee80211_dev_hw_data(ring->net_dev);
 	struct data_entry	*entry;
 	struct txd		*txd;
 	int			ack;
@@ -801,7 +797,8 @@ rt2500usb_txdone(void *data)
 		rt2x00_bbp_read(rt2x00usb, 0,
 			(u8*)&entry->tx_status.ack_signal);
 =09
=2D		ieee80211_tx_status(net_dev, entry->skb, &entry->tx_status);
+		ieee80211_tx_status(ring->net_dev,
+			entry->skb, &entry->tx_status);
 =09
 		entry->skb =3D NULL;
 =09
@@ -825,7 +822,8 @@ static void
 rt2500usb_interrupt(struct urb *urb, struct pt_regs *regs)
 {
 	struct data_ring	*ring =3D (struct data_ring*)urb->context;
=2D	struct rt2x00_usb	*rt2x00usb =3D (struct rt2x00_usb*)ring->dev;
+	struct rt2x00_usb	*rt2x00usb =3D
+		ieee80211_dev_hw_data(ring->net_dev);
=20
 	queue_work(rt2x00usb->workqueue, &ring->irq_work);
 }
@@ -849,7 +847,7 @@ rt2500usb_alloc_ring(
 	/*
 	 *Set device structure.
 	 */
=2D	ring->dev =3D rt2x00usb;
+	ring->net_dev =3D usb_get_intfdata(rt2x00usb->usb_intf);
=20
 	/*
 	 * Initialize work structure for deferred work.
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h =
wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00.h
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-=
04-27 21:48:21.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2=
006-04-27 21:49:08.000000000 +0200
@@ -436,9 +436,9 @@ rt2x00_rf(const struct _rt2x00_chip *chi
  */
 struct data_ring{
 	/*
=2D	 * Pointer to device structure.
+	 * net_device where this ring belongs to.
 	 */
=2D	void					*dev;
+	struct net_device			*net_dev;
=20
 	/*
 	 * Work structure for bottom half interrupt handling.

--nextPart2067323.kvEN3I9dsK
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+daqndE37Em0gRAkwFAJ46Wg02ATG20cE3VCP1aDxzU8l5owCePKec
JgDsPANOfASrUieDEjqtdEw=
=cqIj
-----END PGP SIGNATURE-----

--nextPart2067323.kvEN3I9dsK--
