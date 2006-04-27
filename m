From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 19/32] rt2x00: Fix panics in interrupt handlers
Date: Fri, 28 Apr 2006 00:03:11 +0200
Message-ID: <200604280003.11902.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3468622.7nNeDuNBBn";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.190]:44908 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751791AbWD0WCN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:02:13 -0400
Received: by nproxy.gmail.com with SMTP id x30so1388639nfb
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:02:12 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3468622.7nNeDuNBBn
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

=46ix panics when the interrupt handlers are being
run while the ring is empty.
During the interrupt handling break the loop
correctly when an error has been detected,
more work is being done after the loop.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-27 21:49:59.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-27 21:50:36.000000000 +0200
@@ -844,7 +844,7 @@ rt2400pci_rxdone(void *data)
 		&& !rt2x00_get_field32(rxd->word0, RXD_W0_PHYSICAL_ERROR)) {
 			skb =3D dev_alloc_skb(size + NET_IP_ALIGN);
 			if (!skb)
=2D				return;
+				break;
=20
 			skb_reserve(skb, NET_IP_ALIGN);
=20
@@ -859,7 +859,7 @@ rt2400pci_rxdone(void *data)
=20
 		rt2x00_set_field32(&rxd->word0, RXD_W0_OWNER_NIC, 1);
=20
=2D		rt2x00_ring_index_inc(&rt2x00pci->rx);
+		rt2x00_ring_index_inc(ring);
 	}
=20
 	/*
@@ -879,7 +879,7 @@ rt2400pci_txdone(void *data)
 	int			tx_status;
 	int			ack;
=20
=2D	do {
+	 while (!rt2x00_ring_empty(ring)) {
 		entry =3D rt2x00_get_data_entry_done(ring);
 		txd =3D entry->desc_addr;
=20
@@ -925,7 +925,7 @@ rt2400pci_txdone(void *data)
 		entry->skb =3D NULL;
=20
 		rt2x00_ring_index_done_inc(ring);
=2D	} while (!rt2x00_ring_empty(ring));
+	}
=20
 	/*
 	 * Check if we are waiting on an empty queue
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 21:49:59.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 21:50:36.000000000 +0200
@@ -926,7 +926,7 @@ rt2500pci_rxdone(void *data)
 		&& !rt2x00_get_field32(rxd->word0, RXD_W0_PHYSICAL_ERROR)) {
 			skb =3D dev_alloc_skb(size + NET_IP_ALIGN);
 			if (!skb)
=2D				return;
+				break;
=20
 			skb_reserve(skb, NET_IP_ALIGN);
=20
@@ -943,7 +943,7 @@ rt2500pci_rxdone(void *data)
 		}
 		rt2x00_set_field32(&rxd->word0, RXD_W0_OWNER_NIC, 1);
=20
=2D		rt2x00_ring_index_inc(&rt2x00pci->rx);
+		rt2x00_ring_index_inc(ring);
 	}
=20
 	/*
@@ -964,7 +964,7 @@ rt2500pci_txdone(void *data)
 	int			tx_status;
 	int			ack;
=20
=2D	do {
+	 while (!rt2x00_ring_empty(ring)) {
 		entry =3D rt2x00_get_data_entry_done(ring);
 		txd =3D entry->desc_addr;
=20
@@ -1010,7 +1010,7 @@ rt2500pci_txdone(void *data)
 		entry->skb =3D NULL;
=20
 		rt2x00_ring_index_done_inc(ring);
=2D	} while (!rt2x00_ring_empty(ring));
+	}
=20
 	/*
 	 * Check if we are waiting on an empty queue
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 21:49:59.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 21:50:36.000000000 +0200
@@ -808,7 +808,7 @@ rt2500usb_txdone(void *data)
 	struct txd		*txd;
 	int			ack;
=20
=2D	do {
+	 while (!rt2x00_ring_empty(ring)) {
 		entry =3D rt2x00_get_data_entry_done(ring);
 		txd =3D entry->desc_addr;
=20
@@ -843,7 +843,7 @@ rt2500usb_txdone(void *data)
 		entry->skb =3D NULL;
 =09
 		rt2x00_ring_index_done_inc(entry->ring);
=2D	} while (!rt2x00_ring_empty(ring));
+	}
=20
 	/*
 	 * Check if we are waiting on an empty queue

--nextPart3468622.7nNeDuNBBn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+faqndE37Em0gRAp1jAJ9hw2tvXZFfj1Cqbd5y4gXKAIHqlwCfWnpO
JLIz3dDzbq4D7BLlu0l488A=
=EcsA
-----END PGP SIGNATURE-----

--nextPart3468622.7nNeDuNBBn--
