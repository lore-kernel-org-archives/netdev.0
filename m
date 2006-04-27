From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 10/32] rt2x00: Move TSF counting activation to correct funtion
Date: Fri, 28 Apr 2006 00:03:01 +0200
Message-ID: <200604280003.01974.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1435003.tussLW6AGl";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.188]:30060 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751782AbWD0WB5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:01:57 -0400
Received: by nproxy.gmail.com with SMTP id n29so1463863nfc
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:01:56 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1435003.tussLW6AGl
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Move the enabling of TSF counting into *_config_mode
where it actually belongs.
=46or rt2500usb this means that the rt2500usb_reset_tsf function
is now removed since it is still unknown in what registers the
TSF counters are stored in.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-27 21:41:52.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-27 21:42:29.000000000 +0200
@@ -385,6 +385,9 @@ rt2400pci_config_mode(struct rt2x00_pci=20
 {
 	u32			reg;
=20
+	/*
+	 * Apply hardware packet filter.
+	 */
 	rt2x00_register_read(rt2x00pci, RXCSR0, &reg);
=20
 	if (mode =3D=3D IW_MODE_ADHOC
@@ -408,6 +411,19 @@ rt2400pci_config_mode(struct rt2x00_pci=20
 	}
=20
 	rt2x00_register_write(rt2x00pci, RXCSR0, reg);
+
+	/*
+	 * Enable TSF counter.
+	 */
+	rt2x00_register_read(rt2x00pci, CSR14, &reg);
+	rt2x00_set_field32(&reg, CSR14_TSF_COUNT, 1);
+	if (mode =3D=3D IW_MODE_ADHOC)
+		rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 2);
+	else if (mode =3D=3D IW_MODE_INFRA)
+		rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 1);
+	else
+		rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 0);
+	rt2x00_register_write(rt2x00pci, CSR14, reg);
 }
=20
 static void
@@ -1723,21 +1739,10 @@ static void
 rt2400pci_reset_tsf(struct net_device *net_dev)
 {
 	struct rt2x00_pci	*rt2x00pci =3D ieee80211_dev_hw_data(net_dev);
=2D	struct ieee80211_conf	*conf =3D ieee80211_get_hw_conf(net_dev);
 	u32			reg =3D 0;
=20
 	rt2x00_register_write(rt2x00pci, CSR16, reg);
 	rt2x00_register_write(rt2x00pci, CSR17, reg);
=2D
=2D	rt2x00_register_read(rt2x00pci, CSR14, &reg);
=2D	rt2x00_set_field32(&reg, CSR14_TSF_COUNT, 1);
=2D	if (conf->mode =3D=3D IW_MODE_ADHOC)
=2D		rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 2);
=2D	else if (conf->mode =3D=3D IW_MODE_INFRA)
=2D		rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 1);
=2D	else
=2D		rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 0);
=2D	rt2x00_register_write(rt2x00pci, CSR14, reg);
 }
=20
 static int
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 21:41:52.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 21:42:29.000000000 +0200
@@ -385,6 +385,9 @@ rt2500pci_config_mode(struct rt2x00_pci=20
 {
 	u32			reg;
=20
+	/*
+	 * Apply hardware packet filter.
+	 */
 	rt2x00_register_read(rt2x00pci, RXCSR0, &reg);
=20
 	if (mode =3D=3D IW_MODE_ADHOC
@@ -411,6 +414,19 @@ rt2500pci_config_mode(struct rt2x00_pci=20
 	rt2x00_set_field32(&reg, RXCSR0_DROP_BCAST, 0);
=20
 	rt2x00_register_write(rt2x00pci, RXCSR0, reg);
+
+	/*
+	 * Enable TSF counter.
+	 */
+	rt2x00_register_read(rt2x00pci, CSR14, &reg);
+	rt2x00_set_field32(&reg, CSR14_TSF_COUNT, 1);
+	if (mode =3D=3D IW_MODE_ADHOC)
+		rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 2);
+	else if (mode =3D=3D IW_MODE_INFRA)
+		rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 1);
+	else
+		rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 0);
+	rt2x00_register_write(rt2x00pci, CSR14, reg);
 }
=20
 static void
@@ -1809,21 +1825,10 @@ static void
 rt2500pci_reset_tsf(struct net_device *net_dev)
 {
 	struct rt2x00_pci	*rt2x00pci =3D ieee80211_dev_hw_data(net_dev);
=2D	struct ieee80211_conf	*conf =3D ieee80211_get_hw_conf(net_dev);
 	u32			reg =3D 0;
=20
 	rt2x00_register_write(rt2x00pci, CSR16, reg);
 	rt2x00_register_write(rt2x00pci, CSR17, reg);
=2D
=2D	rt2x00_register_read(rt2x00pci, CSR14, &reg);
=2D	rt2x00_set_field32(&reg, CSR14_TSF_COUNT, 1);
=2D	if (conf->mode =3D=3D IW_MODE_ADHOC)
=2D		rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 2);
=2D	else if (conf->mode =3D=3D IW_MODE_INFRA)
=2D		rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 1);
=2D	else
=2D		rt2x00_set_field32(&reg, CSR14_TSF_SYNC, 0);
=2D	rt2x00_register_write(rt2x00pci, CSR14, reg);
 }
=20
 static int
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 21:41:52.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 21:42:29.000000000 +0200
@@ -268,6 +268,9 @@ rt2500usb_config_mode(struct rt2x00_usb=20
 {
 	u16			reg;
=20
+	/*
+	 * Apply hardware packet filter.
+	 */
 	rt2x00_register_read(rt2x00usb, TXRX_CSR2, &reg);
=20
 	if (mode =3D=3D IW_MODE_ADHOC
@@ -1509,24 +1512,6 @@ rt2500usb_get_tx_stats(struct net_device
 	return 0;
 }
=20
=2Dstatic void
=2Drt2500usb_reset_tsf(struct net_device *net_dev)
=2D{
=2D	struct rt2x00_usb	*rt2x00usb =3D ieee80211_dev_hw_data(net_dev);
=2D	struct ieee80211_conf	*conf =3D ieee80211_get_hw_conf(net_dev);
=2D	u16			reg =3D 0;
=2D
=2D	rt2x00_register_read(rt2x00usb, TXRX_CSR19, &reg);
=2D	rt2x00_set_field16_nb(&reg, TXRX_CSR19_TSF_COUNT, 1);
=2D	if (conf->mode =3D=3D IW_MODE_ADHOC)
=2D		rt2x00_set_field16_nb(&reg, TXRX_CSR19_TSF_SYNC, 2);
=2D	else if (conf->mode =3D=3D IW_MODE_INFRA)
=2D		rt2x00_set_field16_nb(&reg, TXRX_CSR19_TSF_SYNC, 1);
=2D	else
=2D		rt2x00_set_field16_nb(&reg, TXRX_CSR19_TSF_SYNC, 0);
=2D	rt2x00_register_write(rt2x00usb, TXRX_CSR19, reg);
=2D}
=2D
 static int
 rt2500usb_beacon_update(struct net_device *net_dev,
 	struct sk_buff *skb, struct ieee80211_tx_control *control)
@@ -1880,7 +1865,6 @@ rt2500usb_init_hw(struct rt2x00_usb *rt2
 	hw->set_mac_address	=3D rt2500usb_set_mac_address;
 	hw->conf_tx		=3D rt2500usb_conf_tx;
 	hw->get_tx_stats	=3D rt2500usb_get_tx_stats;
=2D	hw->reset_tsf		=3D rt2500usb_reset_tsf;
 	hw->beacon_update	=3D rt2500usb_beacon_update;
=20
 	/*
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.h	20=
06-04-27 21:36:19.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
h	2006-04-27 21:42:29.000000000 +0200
@@ -748,7 +748,6 @@ static int rt2500usb_conf_tx(struct net_
 	int queue, const struct ieee80211_tx_queue_params *params);
 static int rt2500usb_get_tx_stats(struct net_device *net_dev,
 	struct ieee80211_tx_queue_stats *stats);
=2Dstatic void rt2500usb_reset_tsf(struct net_device *net_dev);
 static int rt2500usb_beacon_update(struct net_device *net_dev,
 	struct sk_buff *skb, struct ieee80211_tx_control *control);
=20

--nextPart1435003.tussLW6AGl
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+VaqndE37Em0gRArlWAJ938isuvGRoogFGFejGeGPLdWEqWwCeNCSy
CiujJPvuSMPAt3mrlvRibSs=
=UU50
-----END PGP SIGNATURE-----

--nextPart1435003.tussLW6AGl--
