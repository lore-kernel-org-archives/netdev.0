From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 15/32] rt2x00: Move rx_params to correct location
Date: Fri, 28 Apr 2006 00:03:07 +0200
Message-ID: <200604280003.07505.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart54585637.47t6Rbm7xQ";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.190]:44908 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751791AbWD0WCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:02:04 -0400
Received: by nproxy.gmail.com with SMTP id x30so1388639nfb
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:02:04 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart54585637.47t6Rbm7xQ
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Store rx_params seperately outside the ring structure.
This is more safer and required because of some changes
in the way the rings are stored in the structure in the following
patches.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-27 21:47:22.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-27 21:47:52.000000000 +0200
@@ -475,8 +475,8 @@ rt2400pci_config_channel(struct rt2x00_p
 	/*
 	 * Update active info for RX.
 	 */
=2D	rt2x00pci->rx.params.rx.freq =3D freq;
=2D	rt2x00pci->rx.params.rx.channel =3D channel;
+	rt2x00pci->rx_params.freq =3D freq;
+	rt2x00pci->rx_params.channel =3D channel;
=20
 	/*
 	 * Clear false CRC during channel switch.
@@ -534,7 +534,7 @@ rt2400pci_config_antenna(struct rt2x00_p
 	/*
 	 * Update active info for RX.
 	 */
=2D	rt2x00pci->rx.params.rx.antenna =3D antenna;
+	rt2x00pci->rx_params.antenna =3D antenna;
 }
=20
 static void
@@ -814,10 +814,10 @@ rt2400pci_rxdone(void *data)
=20
 			memcpy(skb_put(skb, size), entry->data_addr, size);
=20
=2D			ring->params.rx.ssi =3D
+			rt2x00pci->rx_params.ssi =3D
 				rt2x00_get_field32(rxd->word2, RXD_W2_RSSI);
=20
=2D			__ieee80211_rx(net_dev, skb, &ring->params.rx);
+			__ieee80211_rx(net_dev, skb, &rt2x00pci->rx_params);
 		}
=20
 		rt2x00_set_field32(&rxd->word0, RXD_W0_OWNER_NIC, 1);
@@ -981,8 +981,8 @@ rt2400pci_alloc_ring(
 	/*
 	 * Initialize ring parameters.
 	 */
=2D	ring->params.tx.cw_min =3D 5;	/* cw_min: 2^5 =3D 32. */
=2D	ring->params.tx.cw_max =3D 10;	/* cw_max: 2^10 =3D 1024. */
+	ring->tx_params.cw_min =3D 5;	/* cw_min: 2^5 =3D 32. */
+	ring->tx_params.cw_max =3D 10;	/* cw_max: 2^10 =3D 1024. */
=20
 	rt2x00_ring_index_clear(ring);
=20
@@ -1374,7 +1374,7 @@ rt2400pci_tx(struct net_device *net_dev,
 	 * queue. This is the alternative since we cannot
 	 * set the CWmin and CWmax per descriptor.
 	 */
=2D	rt2400pci_config_cw(rt2x00pci, &ring->params.tx);
+	rt2400pci_config_cw(rt2x00pci, &ring->tx_params);
 	rt2x00_register_write(rt2x00pci, TXCSR0, reg);
=20
 	return 0;
@@ -1544,7 +1544,7 @@ rt2400pci_config_update(void *data)
 	/*
 	 * Update active info for RX.
 	 */
=2D	rt2x00pci->rx.params.rx.phymode =3D conf->phymode;
+	rt2x00pci->rx_params.phymode =3D conf->phymode;
 }
=20
 static int
@@ -1599,7 +1599,7 @@ rt2400pci_scan(void *data)
 	 * Switch channel and update active info for RX.
 	 */
 	if (rt2x00pci->scan->state =3D=3D IEEE80211_SCAN_START) {
=2D		rt2x00pci->rx.params.rx.phymode =3D
+		rt2x00pci->rx_params.phymode =3D
 			rt2x00pci->scan->conf.scan_phymode;
=20
 		rt2400pci_config_channel(rt2x00pci,
@@ -1610,7 +1610,7 @@ rt2400pci_scan(void *data)
 		rt2400pci_config_txpower(rt2x00pci,
 			rt2x00pci->scan->conf.scan_power_level);
 	} else {
=2D		rt2x00pci->rx.params.rx.phymode =3D
+		rt2x00pci->rx_params.phymode =3D
 			rt2x00pci->scan->conf.running_phymode;
=20
 		rt2400pci_config_channel(rt2x00pci,
@@ -1726,7 +1726,7 @@ rt2400pci_conf_tx(struct net_device *net
 	else
 		return -EINVAL;
=20
=2D	memcpy(&ring->params, params, sizeof(*params));
+	memcpy(&ring->tx_params, params, sizeof(*params));
=20
 	/*
 	 * TODO: We can't use different cw_min and cw_max variables
@@ -1737,14 +1737,14 @@ rt2400pci_conf_tx(struct net_device *net
 	 * RT2400 registers require to know the bit number 'n'.
 	 */
 	if (params->cw_min)
=2D		ring->params.tx.cw_min =3D HIGHEST_BIT16(params->cw_min) + 1;
+		ring->tx_params.cw_min =3D HIGHEST_BIT16(params->cw_min) + 1;
 	else
=2D		ring->params.tx.cw_min =3D 5; /* cw_min: 2^5 =3D 32. */
+		ring->tx_params.cw_min =3D 5; /* cw_min: 2^5 =3D 32. */
=20
 	if (params->cw_max)
=2D		ring->params.tx.cw_max =3D HIGHEST_BIT16(params->cw_max) + 1;
+		ring->tx_params.cw_max =3D HIGHEST_BIT16(params->cw_max) + 1;
 	else
=2D		ring->params.tx.cw_max =3D 10; /* cw_min: 2^10 =3D 1024. */
+		ring->tx_params.cw_max =3D 10; /* cw_min: 2^10 =3D 1024. */
=20
 	return 0;
 }
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	20=
06-04-27 21:47:22.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
h	2006-04-27 21:47:52.000000000 +0200
@@ -926,6 +926,11 @@ struct rt2x00_pci{
 	struct workqueue_struct		*workqueue;
=20
 	/*
+	 * RX ring parameters.
+	 */
+	struct ieee80211_rx_status		rx_params;
+
+	/*
 	 * False CCA count.
 	 */
 	int					false_cca;
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 21:47:22.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 21:47:52.000000000 +0200
@@ -510,8 +510,8 @@ rt2500pci_config_channel(struct rt2x00_p
 	/*
 	 * Update active info for RX.
 	 */
=2D	rt2x00pci->rx.params.rx.freq =3D freq;
=2D	rt2x00pci->rx.params.rx.channel =3D channel;
+	rt2x00pci->rx_params.freq =3D freq;
+	rt2x00pci->rx_params.channel =3D channel;
=20
 	/*
 	 * Clear false CRC during channel switch.
@@ -589,7 +589,7 @@ rt2500pci_config_antenna(struct rt2x00_p
 	/*
 	 * Update active info for RX.
 	 */
=2D	rt2x00pci->rx.params.rx.antenna =3D antenna;
+	rt2x00pci->rx_params.antenna =3D antenna;
 }
=20
 static void
@@ -733,16 +733,16 @@ rt2500pci_write_tx_desc(
 	rt2x00_set_field32(&txd->word0, TXD_W0_ACK, !control->no_ack);
=20
 	if (control->queue =3D=3D IEEE80211_TX_QUEUE_DATA0) {
=2D		params =3D &rt2x00pci->prio.params.tx;
+		params =3D &rt2x00pci->prio.tx_params;
 		rt2x00_set_field32(&txd->word0, TXD_W0_TIMESTAMP, 0);
 	} else if (control->queue =3D=3D IEEE80211_TX_QUEUE_DATA1) {
=2D		params =3D &rt2x00pci->tx.params.tx;
+		params =3D &rt2x00pci->tx.tx_params;
 		rt2x00_set_field32(&txd->word0, TXD_W0_TIMESTAMP, 0);
 	} else if (IEEE80211_TX_QUEUE_AFTER_BEACON) {
=2D		params =3D &rt2x00pci->atim.params.tx;
+		params =3D &rt2x00pci->atim.tx_params;
 		rt2x00_set_field32(&txd->word0, TXD_W0_TIMESTAMP, 0);
 	} else if (IEEE80211_TX_QUEUE_BEACON) {
=2D		params =3D &rt2x00pci->beacon.params.tx;
+		params =3D &rt2x00pci->beacon.tx_params;
 		rt2x00_set_field32(&txd->word0, TXD_W0_TIMESTAMP, 1);
 	}
=20
@@ -896,13 +896,13 @@ rt2500pci_rxdone(void *data)
=20
 			memcpy(skb_put(skb, size), entry->data_addr, size);
=20
=2D			ring->params.rx.ssi =3D
+			rt2x00pci->rx_params.ssi =3D
 				rt2x00_get_field32(rxd->word2, RXD_W2_RSSI);
=20
=2D			__ieee80211_rx(net_dev, skb, &ring->params.rx);
+			__ieee80211_rx(net_dev, skb, &rt2x00pci->rx_params);
=20
 			rssi_count++;
=2D			total_rssi +=3D ring->params.rx.ssi;
+			total_rssi +=3D rt2x00pci->rx_params.ssi;
 		}
 		rt2x00_set_field32(&rxd->word0, RXD_W0_OWNER_NIC, 1);
=20
@@ -1066,9 +1066,9 @@ rt2500pci_alloc_ring(
 	/*
 	 * Initialize ring parameters.
 	 */
=2D	ring->params.tx.aifs =3D 2;
=2D	ring->params.tx.cw_min =3D 5;	/* cw_min: 2^5 =3D 32. */
=2D	ring->params.tx.cw_max =3D 10;	/* cw_max: 2^10 =3D 1024. */
+	ring->tx_params.aifs =3D 2;
+	ring->tx_params.cw_min =3D 5;	/* cw_min: 2^5 =3D 32. */
+	ring->tx_params.cw_max =3D 10;	/* cw_max: 2^10 =3D 1024. */
=20
 	rt2x00_ring_index_clear(ring);
=20
@@ -1657,7 +1657,7 @@ rt2500pci_config_update(void *data)
 	/*
 	 * Update active info for RX.
 	 */
=2D	rt2x00pci->rx.params.rx.phymode =3D conf->phymode;
+	rt2x00pci->rx_params.phymode =3D conf->phymode;
 }
=20
 static int
@@ -1712,7 +1712,7 @@ rt2500pci_scan(void *data)
 	 * Switch channel and update active info for RX.
 	 */
 	if (rt2x00pci->scan->state =3D=3D IEEE80211_SCAN_START) {
=2D		rt2x00pci->rx.params.rx.phymode =3D
+		rt2x00pci->rx_params.phymode =3D
 			rt2x00pci->scan->conf.scan_phymode;
 =09
 		rt2500pci_config_channel(rt2x00pci,
@@ -1721,7 +1721,7 @@ rt2500pci_scan(void *data)
 			rt2x00pci->scan->conf.scan_freq,
 			rt2x00pci->scan->conf.scan_power_level);
 	} else {
=2D		rt2x00pci->rx.params.rx.phymode =3D
+		rt2x00pci->rx_params.phymode =3D
 			rt2x00pci->scan->conf.running_phymode;
 =09
 		rt2500pci_config_channel(rt2x00pci,
@@ -1835,24 +1835,24 @@ rt2500pci_conf_tx(struct net_device *net
 	else
 		return -EINVAL;
=20
=2D	memcpy(&ring->params, params, sizeof(*params));
+	memcpy(&ring->tx_params, params, sizeof(*params));
=20
 	/*
 	 * The passed variables are stored as real value ((2^n)-1).
 	 * RT2400 registers require to know the bit number 'n'.
 	 */
 	if (params->cw_min)
=2D		ring->params.tx.cw_min =3D HIGHEST_BIT16(params->cw_min) + 1;
+		ring->tx_params.cw_min =3D HIGHEST_BIT16(params->cw_min) + 1;
 	else
=2D		ring->params.tx.cw_min =3D 5; /* cw_min: 2^5 =3D 32. */
+		ring->tx_params.cw_min =3D 5; /* cw_min: 2^5 =3D 32. */
=20
 	if (params->cw_max)
=2D		ring->params.tx.cw_max =3D HIGHEST_BIT16(params->cw_max) + 1;
+		ring->tx_params.cw_max =3D HIGHEST_BIT16(params->cw_max) + 1;
 	else
=2D		ring->params.tx.cw_max =3D 10; /* cw_min: 2^10 =3D 1024. */
+		ring->tx_params.cw_max =3D 10; /* cw_min: 2^10 =3D 1024. */
=20
 	if (!params->aifs)
=2D		ring->params.tx.aifs =3D 2;
+		ring->tx_params.aifs =3D 2;
=20
 	return 0;
 }
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	20=
06-04-27 21:47:22.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
h	2006-04-27 21:47:52.000000000 +0200
@@ -1196,6 +1196,11 @@ struct rt2x00_pci{
 	struct workqueue_struct		*workqueue;
=20
 	/*
+	 * RX ring parameters.
+	 */
+	struct ieee80211_rx_status		rx_params;
+
+	/*
 	 * Alignment.
 	 */
 	u16					__pad;
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 21:47:22.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 21:47:52.000000000 +0200
@@ -435,7 +435,7 @@ rt2500usb_config_antenna(struct rt2x00_u
 	/*
 	 * Update active info for RX.
 	 */
=2D	rt2x00usb->rx.params.rx.antenna =3D antenna;
+	rt2x00usb->rx_params.antenna =3D antenna;
 }
=20
 static void
@@ -573,16 +573,16 @@ rt2500usb_write_tx_desc(
 	rt2x00_set_field32(&txd->word0, TXD_W0_ACK, !control->no_ack);
=20
 	if (control->queue =3D=3D IEEE80211_TX_QUEUE_DATA0) {
=2D		params =3D &rt2x00usb->prio.params.tx;
+		params =3D &rt2x00usb->prio.tx_params;
 		rt2x00_set_field32(&txd->word0, TXD_W0_TIMESTAMP, 0);
 	} else if (control->queue =3D=3D IEEE80211_TX_QUEUE_DATA1) {
=2D		params =3D &rt2x00usb->tx.params.tx;
+		params =3D &rt2x00usb->tx.tx_params;
 		rt2x00_set_field32(&txd->word0, TXD_W0_TIMESTAMP, 0);
 	} else if (IEEE80211_TX_QUEUE_AFTER_BEACON) {
=2D		params =3D &rt2x00usb->atim.params.tx;
+		params =3D &rt2x00usb->atim.tx_params;
 		rt2x00_set_field32(&txd->word0, TXD_W0_TIMESTAMP, 0);
 	} else if (IEEE80211_TX_QUEUE_BEACON) {
=2D		params =3D &rt2x00usb->beacon.params.tx;
+		params =3D &rt2x00usb->beacon.tx_params;
 		rt2x00_set_field32(&txd->word0, TXD_W0_TIMESTAMP, 1);
 	}
=20
@@ -740,13 +740,13 @@ rt2500usb_rxdone(void *data)
=20
 			memcpy(skb_put(skb, size), entry->data_addr, size);
=20
=2D			ring->params.rx.ssi =3D
+			rt2x00usb->rx_params.ssi =3D
 				rt2x00_get_field32(rxd->word1, RXD_W1_RSSI);
=20
=2D			__ieee80211_rx(net_dev, skb, &ring->params.rx);
+			__ieee80211_rx(net_dev, skb, &rt2x00usb->rx_params);
=20
 			rssi_count++;
=2D			total_rssi +=3D ring->params.rx.ssi;
+			total_rssi +=3D rt2x00usb->rx_params.ssi;
 		}
=20
 		usb_submit_urb(entry->urb, GFP_ATOMIC);
@@ -855,9 +855,9 @@ rt2500usb_alloc_ring(
 	/*
 	 * Initialize ring parameters.
 	 */
=2D	ring->params.tx.aifs =3D 2;
=2D	ring->params.tx.cw_min =3D 5;	/* cw_min: 2^5 =3D 32. */
=2D	ring->params.tx.cw_max =3D 10;	/* cw_max: 2^10 =3D 1024. */
+	ring->tx_params.aifs =3D 2;
+	ring->tx_params.cw_min =3D 5;	/* cw_min: 2^5 =3D 32. */
+	ring->tx_params.cw_max =3D 10;	/* cw_max: 2^10 =3D 1024. */
=20
 	rt2x00_ring_index_clear(ring);
=20
@@ -1394,7 +1394,7 @@ rt2500usb_config_update(void *data)
 	/*
 	 * Update active info for RX.
 	 */
=2D	rt2x00usb->rx.params.rx.phymode =3D conf->phymode;
+	rt2x00usb->rx_params.phymode =3D conf->phymode;
 }
=20
 static int
@@ -1450,7 +1450,7 @@ rt2500usb_scan(void *data)
 	 * Switch channel and update active info for RX.
 	 */
 	if (rt2x00usb->scan->state =3D=3D IEEE80211_SCAN_START) {
=2D		rt2x00usb->rx.params.rx.phymode =3D
+		rt2x00usb->rx_params.phymode =3D
 			rt2x00usb->scan->conf.scan_phymode;
 =09
 		rt2500usb_config_channel(rt2x00usb,
@@ -1459,7 +1459,7 @@ rt2500usb_scan(void *data)
 			rt2x00usb->scan->conf.scan_freq,
 			rt2x00usb->scan->conf.scan_power_level);
 	} else {
=2D		rt2x00usb->rx.params.rx.phymode =3D
+		rt2x00usb->rx_params.phymode =3D
 			rt2x00usb->scan->conf.running_phymode;
 =09
 		rt2500usb_config_channel(rt2x00usb,
@@ -1558,24 +1558,24 @@ rt2500usb_conf_tx(struct net_device *net
 	else
 		return -EINVAL;
=20
=2D	memcpy(&ring->params, params, sizeof(*params));
+	memcpy(&ring->tx_params, params, sizeof(*params));
=20
 	/*
 	 * The passed variables are stored as real value ((2^n)-1).
 	 * RT2400 registers require to know the bit number 'n'.
 	 */
 	if (params->cw_min)
=2D		ring->params.tx.cw_min =3D HIGHEST_BIT16(params->cw_min) + 1;
+		ring->tx_params.cw_min =3D HIGHEST_BIT16(params->cw_min) + 1;
 	else
=2D		ring->params.tx.cw_min =3D 5; /* cw_min: 2^5 =3D 32. */
+		ring->tx_params.cw_min =3D 5; /* cw_min: 2^5 =3D 32. */
=20
 	if (params->cw_max)
=2D		ring->params.tx.cw_max =3D HIGHEST_BIT16(params->cw_max) + 1;
+		ring->tx_params.cw_max =3D HIGHEST_BIT16(params->cw_max) + 1;
 	else
=2D		ring->params.tx.cw_max =3D 10; /* cw_min: 2^10 =3D 1024. */
+		ring->tx_params.cw_max =3D 10; /* cw_min: 2^10 =3D 1024. */
=20
 	if (!params->aifs)
=2D		ring->params.tx.aifs =3D 2;
+		ring->tx_params.aifs =3D 2;
=20
 	return 0;
 }
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	20=
06-04-27 21:47:22.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
h	2006-04-27 21:47:52.000000000 +0200
@@ -714,6 +714,11 @@ struct rt2x00_usb{
 	struct workqueue_struct		*workqueue;
=20
 	/*
+	 * RX ring parameters.
+	 */
+	struct ieee80211_rx_status		rx_params;
+
+	/*
 	 * Alignment.
 	 */
 	u8					__pad1;
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h =
wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00.h
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2006-=
04-27 21:39:24.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00.h	2=
006-04-27 21:47:52.000000000 +0200
@@ -465,19 +465,9 @@ struct data_ring{
 	struct ieee80211_tx_queue_stats_data	stats;
=20
 	/*
=2D	 * Queue parameters.
=2D	 * We can safely put the following structures inside
=2D	 * the same union since a ring is either TX or RX
=2D	 * so they will never be used at the same time.
=2D	 * The ieee80211_rx_status structures is stored here, when
=2D	 * configuration changes have been passed to us, we can
=2D	 * change it to show the active configuration. And received
=2D	 * frames will always have the correct settings.
=2D	 */
=2D	union {
=2D		struct ieee80211_rx_status		rx;
=2D		struct ieee80211_tx_queue_params	tx;
=2D	}					params;
+	 * TX Queue parameters.
+	 */
+	struct ieee80211_tx_queue_params	tx_params;
=20
 	/*
 	 * Base address for data ring.

--nextPart54585637.47t6Rbm7xQ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+baqndE37Em0gRAvwQAJ0eHrKpQwJOjVZlDkkheLzIWLJhCACfWmDo
XrD1Z0f06E1fMYlzLfXm4ZE=
=/q76
-----END PGP SIGNATURE-----

--nextPart54585637.47t6Rbm7xQ--
