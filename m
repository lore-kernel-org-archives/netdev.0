From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 31/32] rt2x00: Correctly initialization and uninitialization of device
Date: Fri, 28 Apr 2006 00:03:20 +0200
Message-ID: <200604280003.21404.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1556838.3cV6Yeesnk";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.188]:30060 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751806AbWD0WCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:02:21 -0400
Received: by nproxy.gmail.com with SMTP id n29so1463863nfc
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:02:20 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1556838.3cV6Yeesnk
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

=46ix several hardware initialization and uninitalization
problems by incorrectly flushing workqueues.
=46ix the memory leak when freeing the ieee80211_hw structure.
Allow device to connect to 802.11g networks by default
instead of 802.11b.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-27 22:05:21.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-27 22:05:52.000000000 +0200
@@ -1719,6 +1719,11 @@ rt2400pci_stop(struct net_device *net_de
 	}
=20
 	/*
+	 * Flush out all pending work.
+	 */
+	flush_workqueue(rt2x00pci->workqueue);
+
+	/*
 	 * Free DMA rings.
 	 */
 	rt2400pci_free_rings(rt2x00pci);
@@ -2441,7 +2446,7 @@ rt2400pci_initialize(struct pci_dev *pci
=20
 	rt2x00pci->workqueue =3D create_singlethread_workqueue(DRV_NAME);
 	if (!rt2x00pci->workqueue)
=2D		goto exit_iounmap;
+		goto exit;
=20
 	/*
 	 * Initialize cofniguration work.
@@ -2457,21 +2462,25 @@ rt2400pci_initialize(struct pci_dev *pci
 	if (rt2400pci_init_eeprom(rt2x00pci)
 	|| rt2400pci_init_mac(rt2x00pci)
 	|| rt2400pci_init_hw(rt2x00pci))
=2D		goto exit_destroy_workqueue;
+		goto exit;
=20
 	/*
 	 * If required start hardware button polling.
 	 */
 	rt2x00pci_button_start(rt2x00pci, rt2400pci_button_poll);
=20
=2D	return 0;
+	/*
+	 * Register hardware.
+	 */
+	if (ieee80211_register_hw(net_dev, &rt2x00pci->hw)) {
+		ERROR("Failed to register device.\n");
+		goto exit;
+	}
=20
=2Dexit_destroy_workqueue:
=2D	destroy_workqueue(rt2x00pci->workqueue);
+	return 0;
=20
=2Dexit_iounmap:
=2D	iounmap(rt2x00pci->csr_addr);
=2D	rt2x00pci->csr_addr =3D NULL;
+exit:
+	rt2400pci_uninitialize(net_dev);
=20
 	return -ENODEV;
 }
@@ -2482,26 +2491,39 @@ rt2400pci_uninitialize(struct net_device
 	struct rt2x00_pci	*rt2x00pci =3D ieee80211_dev_hw_data(net_dev);
=20
 	/*
+	 * Unregister hardware.
+	 */
+	ieee80211_unregister_hw(net_dev);
+
+	/*
 	 * Shutdown poll_timer for hardware button.
 	 */
 	rt2x00pci_button_stop(rt2x00pci);
=20
 	kfree(rt2x00pci->eeprom);
=20
+	/*
+	 * Release CSR memory.
+	 */
 	if (likely(rt2x00pci->csr_addr)) {
 		iounmap(rt2x00pci->csr_addr);
 		rt2x00pci->csr_addr =3D NULL;
 	}
=20
+	/*
+	 * Free workqueue.
+	 */
 	if (likely(rt2x00pci->workqueue)) {
=2D		flush_workqueue(rt2x00pci->workqueue);
 		destroy_workqueue(rt2x00pci->workqueue);
 		rt2x00pci->workqueue =3D NULL;
 	}
=20
+	/*
+	 * Free ieee80211_hw memory.
+	 */
 	if (likely(rt2x00pci->hw.modes)) {
=2D			kfree(rt2x00pci->hw.modes->channels);
=2D			kfree(rt2x00pci->hw.modes->rates);
+		kfree(rt2x00pci->hw.modes->channels);
+		kfree(rt2x00pci->hw.modes->rates);
 		kfree(rt2x00pci->hw.modes);
 		rt2x00pci->hw.modes =3D NULL;
 	}
@@ -2514,7 +2536,6 @@ static int
 rt2400pci_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 {
 	struct net_device	*net_dev;
=2D	struct rt2x00_pci	*rt2x00pci;
 	int			status;
=20
 	if (unlikely(id->driver_data !=3D RT2460)) {
@@ -2559,19 +2580,9 @@ rt2400pci_probe(struct pci_dev *pci_dev,
 		ERROR("Failed to initialize device.\n");
 		goto exit_free_device;
 	}
=2D	rt2x00pci =3D ieee80211_dev_hw_data(net_dev);
=2D
=2D	status =3D ieee80211_register_hw(net_dev, &rt2x00pci->hw);
=2D	if (status) {
=2D		ERROR("Failed to register device.\n");
=2D		goto exit_uninitialize_device;
=2D	}
=20
 	return 0;
=20
=2Dexit_uninitialize_device:
=2D	rt2400pci_uninitialize(net_dev);
=2D
 exit_free_device:
 	ieee80211_free_hw(net_dev);
=20
@@ -2592,7 +2603,7 @@ rt2400pci_remove(struct pci_dev *pci_dev
 {
 	struct net_device	*net_dev =3D pci_get_drvdata(pci_dev);
=20
=2D	ieee80211_unregister_hw(net_dev);
+	net_dev->stop(net_dev);
=20
 	rt2400pci_uninitialize(net_dev);
=20
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 22:05:21.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 22:05:52.000000000 +0200
@@ -1845,6 +1845,11 @@ rt2500pci_stop(struct net_device *net_de
 	}
=20
 	/*
+	 * Flush out all pending work.
+	 */
+	flush_workqueue(rt2x00pci->workqueue);
+
+	/*
 	 * Free DMA rings.
 	 */
 	rt2500pci_free_rings(rt2x00pci);
@@ -2675,22 +2680,22 @@ rt2500pci_init_hw(struct rt2x00_pci *rt2
 	}
=20
 	/*
=2D	 * Intitialize 802.11b
=2D	 * Rates: CCK.
+	 * Intitialize 802.11g
+	 * Rates: CCK, OFDM.
 	 * Channels: OFDM.
 	 */
=2D	hw->modes[0].mode =3D MODE_IEEE80211B;
+	hw->modes[0].mode =3D MODE_IEEE80211G;
 	hw->modes[0].num_channels =3D 14;
=2D	hw->modes[0].num_rates =3D 4;
+	hw->modes[0].num_rates =3D 12;
=20
 	/*
=2D	 * Intitialize 802.11g
=2D	 * Rates: CCK, OFDM.
+	 * Intitialize 802.11b
+	 * Rates: CCK.
 	 * Channels: OFDM.
 	 */
=2D	hw->modes[1].mode =3D MODE_IEEE80211G;
+	hw->modes[1].mode =3D MODE_IEEE80211B;
 	hw->modes[1].num_channels =3D 14;
=2D	hw->modes[1].num_rates =3D 12;
+	hw->modes[1].num_rates =3D 4;
 	hw->modes[1].channels =3D hw->modes[0].channels;
 	hw->modes[1].rates =3D hw->modes[0].rates;
=20
@@ -2747,7 +2752,7 @@ rt2500pci_initialize(struct pci_dev *pci
=20
 	rt2x00pci->workqueue =3D create_singlethread_workqueue(DRV_NAME);
 	if (!rt2x00pci->workqueue)
=2D		goto exit_iounmap;
+		goto exit;
=20
 	/*
 	 * Initialize cofniguration work.
@@ -2763,21 +2768,25 @@ rt2500pci_initialize(struct pci_dev *pci
 	if (rt2500pci_init_eeprom(rt2x00pci)
 	|| rt2500pci_init_mac(rt2x00pci)
 	|| rt2500pci_init_hw(rt2x00pci))
=2D		goto exit_destroy_workqueue;
+		goto exit;
=20
 	/*
 	 * If required start hardware button polling.
 	 */
 	rt2x00pci_button_start(rt2x00pci, rt2500pci_button_poll);
=20
=2D	return 0;
+	/*
+	 * Register hardware.
+	 */
+	if (ieee80211_register_hw(net_dev, &rt2x00pci->hw)) {
+		ERROR("Failed to register device.\n");
+		goto exit;
+	}
=20
=2Dexit_destroy_workqueue:
=2D	destroy_workqueue(rt2x00pci->workqueue);
+	return 0;
=20
=2Dexit_iounmap:
=2D	iounmap(rt2x00pci->csr_addr);
=2D	rt2x00pci->csr_addr =3D NULL;
+exit:
+	rt2500pci_uninitialize(net_dev);
=20
 	return -ENODEV;
 }
@@ -2788,25 +2797,42 @@ rt2500pci_uninitialize(struct net_device
 	struct rt2x00_pci	*rt2x00pci =3D ieee80211_dev_hw_data(net_dev);
=20
 	/*
+	 * Unregister hardware.
+	 */
+	ieee80211_unregister_hw(net_dev);
+
+	/*
 	 * Shutdown poll_timer for hardware button.
 	 */
 	rt2x00pci_button_stop(rt2x00pci);
=20
 	kfree(rt2x00pci->eeprom);
=20
+	/*
+	 * Release CSR memory.
+	 */
 	if (likely(rt2x00pci->csr_addr)) {
 		iounmap(rt2x00pci->csr_addr);
 		rt2x00pci->csr_addr =3D NULL;
 	}
=20
+	/*
+	 * Free workqueue.
+	 */
 	if (likely(rt2x00pci->workqueue)) {
=2D		flush_workqueue(rt2x00pci->workqueue);
 		destroy_workqueue(rt2x00pci->workqueue);
 		rt2x00pci->workqueue =3D NULL;
 	}
=20
=2D	kfree(rt2x00pci->hw.modes);
=2D	rt2x00pci->hw.modes =3D NULL;
+	/*
+	 * Free ieee80211_hw memory.
+	 */
+	if (likely(rt2x00pci->hw.modes)) {
+		kfree(rt2x00pci->hw.modes->channels);
+		kfree(rt2x00pci->hw.modes->rates);
+		kfree(rt2x00pci->hw.modes);
+		rt2x00pci->hw.modes =3D NULL;
+	}
 }
=20
 /*
@@ -2816,7 +2842,6 @@ static int
 rt2500pci_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 {
 	struct net_device	*net_dev;
=2D	struct rt2x00_pci	*rt2x00pci;
 	int			status;
=20
 	if (unlikely(id->driver_data !=3D RT2560)) {
@@ -2861,19 +2886,9 @@ rt2500pci_probe(struct pci_dev *pci_dev,
 		ERROR("Failed to initialize device.\n");
 		goto exit_free_device;
 	}
=2D	rt2x00pci =3D ieee80211_dev_hw_data(net_dev);
=2D
=2D	status =3D ieee80211_register_hw(net_dev, &rt2x00pci->hw);
=2D	if (status) {
=2D		ERROR("Failed to register device.\n");
=2D		goto exit_uninitialize_device;
=2D	}
=20
 	return 0;
=20
=2Dexit_uninitialize_device:
=2D	rt2500pci_uninitialize(net_dev);
=2D
 exit_free_device:
 	ieee80211_free_hw(net_dev);
=20
@@ -2894,7 +2909,7 @@ rt2500pci_remove(struct pci_dev *pci_dev
 {
 	struct net_device	*net_dev =3D pci_get_drvdata(pci_dev);
=20
=2D	ieee80211_unregister_hw(net_dev);
+	net_dev->stop(net_dev);
=20
 	rt2500pci_uninitialize(net_dev);
=20
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 22:05:21.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 22:05:52.000000000 +0200
@@ -1480,8 +1480,6 @@ static int
 rt2500usb_stop(struct net_device *net_dev)
 {
 	struct rt2x00_usb	*rt2x00usb =3D ieee80211_dev_hw_data(net_dev);
=2D	struct data_entry	*entry;
=2D	int			counter;
 	u16			reg;
=20
 	CLEAR_FLAG(rt2x00usb, RADIO_ENABLED);
@@ -1498,11 +1496,6 @@ rt2500usb_stop(struct net_device *net_de
 	 */
 	rt2500usb_disable_led(rt2x00usb);
=20
=2D	entry =3D (struct data_entry*)rt2x00usb->ring[RING_RX].entry;
=2D	for (counter =3D 0; counter < rt2x00usb->ring[RING_RX].stats.limit; cou=
nter++) {
=2D		usb_kill_urb(entry[counter].urb);
=2D	}
=2D
 	rt2x00_vendor_request(rt2x00usb, USB_RX_CONTROL,
 		USB_VENDOR_REQUEST_OUT, 0x00, 0x00, NULL, 0);
=20
@@ -1518,6 +1511,11 @@ rt2500usb_stop(struct net_device *net_de
 	}
=20
 	/*
+	 * Flush out all pending work.
+	 */
+	flush_workqueue(rt2x00usb->workqueue);
+
+	/*
 	 * Free DMA rings.
 	 */
 	rt2500usb_free_rings(rt2x00usb);
@@ -2296,22 +2294,23 @@ rt2500usb_init_hw(struct rt2x00_usb *rt2
 	}
=20
 	/*
=2D	 * Intitialize 802.11b
=2D	 * Rates: CCK.
+	 * Intitialize 802.11g
+	 * Rates: CCK, OFDM.
 	 * Channels: OFDM.
 	 */
=2D	hw->modes[0].mode =3D MODE_IEEE80211B;
+	hw->modes[0].mode =3D MODE_IEEE80211G;
 	hw->modes[0].num_channels =3D 14;
=2D	hw->modes[0].num_rates =3D 4;
+	hw->modes[0].num_rates =3D 12;
+
=20
 	/*
=2D	 * Intitialize 802.11g
=2D	 * Rates: CCK, OFDM.
+	 * Intitialize 802.11b
+	 * Rates: CCK.
 	 * Channels: OFDM.
 	 */
=2D	hw->modes[1].mode =3D MODE_IEEE80211G;
+	hw->modes[1].mode =3D MODE_IEEE80211B;
 	hw->modes[1].num_channels =3D 14;
=2D	hw->modes[1].num_rates =3D 12;
+	hw->modes[1].num_rates =3D 4;
 	hw->modes[1].channels =3D hw->modes[0].channels;
 	hw->modes[1].rates =3D hw->modes[0].rates;
=20
@@ -2376,12 +2375,23 @@ rt2500usb_initialize(struct usb_interfac
=20
 	if (rt2500usb_init_eeprom(rt2x00usb)
 	|| rt2500usb_init_mac(rt2x00usb)
=2D	|| rt2500usb_init_hw(rt2x00usb)) {
=2D		destroy_workqueue(rt2x00usb->workqueue);
=2D		return -ENODEV;
+	|| rt2500usb_init_hw(rt2x00usb))
+		goto exit;
+
+	/*
+	 * Register hardware.
+	 */
+	if (ieee80211_register_hw(net_dev, &rt2x00usb->hw)) {
+		ERROR("Failed to register device.\n");
+		goto exit;
 	}
=20
 	return 0;
+
+exit:
+	rt2500usb_uninitialize(net_dev);
+
+	return -ENODEV;
 }
=20
 static void
@@ -2389,16 +2399,30 @@ rt2500usb_uninitialize(struct net_device
 {
 	struct rt2x00_usb	*rt2x00usb =3D ieee80211_dev_hw_data(net_dev);
=20
+	/*
+	 * Unregister hardware.
+	 */
+	ieee80211_unregister_hw(net_dev);
+
 	kfree(rt2x00usb->eeprom);
=20
+	/*
+	 * Free workqueue.
+	 */
 	if (likely(rt2x00usb->workqueue)) {
=2D		flush_workqueue(rt2x00usb->workqueue);
 		destroy_workqueue(rt2x00usb->workqueue);
 		rt2x00usb->workqueue =3D NULL;
 	}
=20
=2D	kfree(rt2x00usb->hw.modes);
=2D	rt2x00usb->hw.modes =3D NULL;
+	/*
+	 * Free ieee80211_hw memory.
+	 */
+	if (likely(rt2x00usb->hw.modes)) {
+		kfree(rt2x00usb->hw.modes->channels);
+		kfree(rt2x00usb->hw.modes->rates);
+		kfree(rt2x00usb->hw.modes);
+		rt2x00usb->hw.modes =3D NULL;
+	}
 }
=20
 /*
@@ -2409,7 +2433,6 @@ rt2500usb_probe(struct usb_interface *us
 {
 	struct usb_device	*usb_dev =3D interface_to_usbdev(usb_intf);
 	struct net_device	*net_dev;
=2D	struct rt2x00_usb	*rt2x00usb;
 	int			status;
=20
 	if (unlikely(id->driver_info !=3D RT2570)) {
@@ -2433,19 +2456,9 @@ rt2500usb_probe(struct usb_interface *us
 		ERROR("Failed to initialize device.\n");
 		goto exit_free_device;
 	}
=2D	rt2x00usb =3D ieee80211_dev_hw_data(net_dev);
=2D
=2D	status =3D ieee80211_register_hw(net_dev, &rt2x00usb->hw);
=2D	if (status) {
=2D		ERROR("Failed to register device.\n");
=2D		goto exit_uninitialize_device;
=2D	}
=20
 	return 0;
=20
=2Dexit_uninitialize_device:
=2D	rt2500usb_uninitialize(net_dev);
=2D
 exit_free_device:
 	ieee80211_free_hw(net_dev);
=20
@@ -2460,7 +2473,7 @@ rt2500usb_disconnect(struct usb_interfac
 {
 	struct net_device	*net_dev =3D usb_get_intfdata(usb_intf);
=20
=2D	ieee80211_unregister_hw(net_dev);
+	net_dev->stop(net_dev);
=20
 	rt2500usb_uninitialize(net_dev);
=20

--nextPart1556838.3cV6Yeesnk
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+paqndE37Em0gRAq2GAKCrbLOOita/o2B9Lu22hlyQmgwO7ACfWArQ
igbzHqE3Ap8mGigsn+OntXE=
=M90F
-----END PGP SIGNATURE-----

--nextPart1556838.3cV6Yeesnk--
