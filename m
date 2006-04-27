From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 28/32] rt2x00: Support TXRX led handling
Date: Fri, 28 Apr 2006 00:03:18 +0200
Message-ID: <200604280003.18909.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1302435.AkHDyMJPKG";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.191]:40300 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751791AbWD0WCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:02:19 -0400
Received: by nproxy.gmail.com with SMTP id x30so1388658nfb
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:02:19 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1302435.AkHDyMJPKG
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Create more advanced led handling, enable txrx activity
by switching on and off the led at interrupt time.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-27 22:03:48.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-27 22:04:19.000000000 +0200
@@ -669,6 +669,57 @@ rt2400pci_link_tuner(struct rt2x00_pci *
 }
=20
 /*
+ * LED functions.
+ */
+static void
+rt2400pci_enable_led(struct rt2x00_pci *rt2x00pci)
+{
+	u32			reg;
+
+	rt2x00_register_read(rt2x00pci, LEDCSR, &reg);
+
+	rt2x00_set_field32(&reg, LEDCSR_ON_PERIOD, 30);
+	rt2x00_set_field32(&reg, LEDCSR_OFF_PERIOD, 70);
+
+	if (rt2x00pci->led_mode =3D=3D LED_MODE_TXRX_ACTIVITY) {
+		rt2x00_set_field32(&reg, LEDCSR_LINK, 1);
+		rt2x00_set_field32(&reg, LEDCSR_ACTIVITY, 0);
+	} else if (rt2x00pci->led_mode =3D=3D LED_MODE_ASUS) {
+		rt2x00_set_field32(&reg, LEDCSR_LINK, 0);
+		rt2x00_set_field32(&reg, LEDCSR_ACTIVITY, 1);
+	} else {
+		rt2x00_set_field32(&reg, LEDCSR_LINK, 1);
+		rt2x00_set_field32(&reg, LEDCSR_ACTIVITY, 1);
+	}
+
+	rt2x00_register_write(rt2x00pci, LEDCSR, reg);
+}
+
+static void
+rt2400pci_disable_led(struct rt2x00_pci *rt2x00pci)
+{
+	u32			reg;
+
+	rt2x00_register_read(rt2x00pci, LEDCSR, &reg);
+	rt2x00_set_field32(&reg, LEDCSR_LINK, 0);
+	rt2x00_set_field32(&reg, LEDCSR_ACTIVITY, 0);
+	rt2x00_register_write(rt2x00pci, LEDCSR, reg);
+}
+
+static void
+rt2400pci_activity_led(struct rt2x00_pci *rt2x00pci, char activity)
+{
+	u32			reg;
+
+	if (rt2x00pci->led_mode !=3D LED_MODE_TXRX_ACTIVITY)
+		return;
+
+	rt2x00_register_read(rt2x00pci, LEDCSR, &reg);
+	rt2x00_set_field32(&reg, LEDCSR_ACTIVITY, activity);
+	rt2x00_register_write(rt2x00pci, LEDCSR, reg);
+}
+
+/*
  * Device state switch.
  * This will put the device to sleep, or awake it.
  */
@@ -882,6 +933,11 @@ rt2400pci_rxdone(void *data)
 	 * Tune link for optimal performance.
 	 */
 	rt2400pci_link_tuner(rt2x00pci);
+
+	/*
+	 * Update LED.
+	 */
+	rt2400pci_activity_led(rt2x00pci, 0);
 }
=20
 static void
@@ -987,10 +1043,13 @@ rt2400pci_interrupt(int irq, void *dev_i
=20
 	/*
 	 * 2 - Rx ring done interrupt.
+	 * Enable the TXRX activity led.
 	 */
=2D	if (rt2x00_get_field32(reg, CSR7_RXDONE))
+	if (rt2x00_get_field32(reg, CSR7_RXDONE)) {
 		queue_work(rt2x00pci->workqueue,
 			&rt2x00pci->ring[RING_RX].irq_work);
+		rt2400pci_activity_led(rt2x00pci, 1);
+	}
=20
 	/*
 	 * 3 - Atim ring transmit done interrupt.
@@ -1333,13 +1392,6 @@ rt2400pci_init_registers(struct rt2x00_p
 	rt2x00_set_field32(&reg, RALINKCSR_AR_BBP_ID1, 154);
 	rt2x00_register_write(rt2x00pci, RALINKCSR, reg);
=20
=2D	rt2x00_register_read(rt2x00pci, LEDCSR, &reg);
=2D	rt2x00_set_field32(&reg, LEDCSR_ON_PERIOD, 30);
=2D	rt2x00_set_field32(&reg, LEDCSR_OFF_PERIOD, 70);
=2D	rt2x00_set_field32(&reg, LEDCSR_LINK, 0);
=2D	rt2x00_set_field32(&reg, LEDCSR_ACTIVITY, 0);
=2D	rt2x00_register_write(rt2x00pci, LEDCSR, reg);
=2D
 	rt2x00_register_read(rt2x00pci, CSR1, &reg);
 	rt2x00_set_field32(&reg, CSR1_SOFT_RESET, 1);
 	rt2x00_set_field32(&reg, CSR1_BBP_RESET, 0);
@@ -1555,6 +1607,11 @@ rt2400pci_open(struct net_device *net_de
 	}
=20
 	/*
+	 * Enable LED
+	 */
+	rt2400pci_enable_led(rt2x00pci);
+
+	/*
 	 * Enable interrupts.
 	 */
 	rt2x00_register_read(rt2x00pci, CSR8, &reg);
@@ -1597,11 +1654,9 @@ rt2400pci_stop(struct net_device *net_de
 	rt2x00_register_write(rt2x00pci, RXCSR0, reg);
=20
 	/*
=2D	 * Switch off LED.
+	 * Disable LED
 	 */
=2D	rt2x00_register_read(rt2x00pci, LEDCSR, &reg);
=2D	rt2x00_set_field32(&reg, LEDCSR_LINK, 0);
=2D	rt2x00_register_write(rt2x00pci, LEDCSR, reg);
+	rt2400pci_disable_led(rt2x00pci);
=20
 	/*
 	 * Disable interrupts.
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 22:03:48.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 22:04:19.000000000 +0200
@@ -722,6 +722,57 @@ dynamic_cca_tune:
 }
=20
 /*
+ * LED functions.
+ */
+static void
+rt2500pci_enable_led(struct rt2x00_pci *rt2x00pci)
+{
+	u32			reg;
+
+	rt2x00_register_read(rt2x00pci, LEDCSR, &reg);
+
+	rt2x00_set_field32(&reg, LEDCSR_ON_PERIOD, 30);
+	rt2x00_set_field32(&reg, LEDCSR_OFF_PERIOD, 70);
+
+	if (rt2x00pci->led_mode =3D=3D LED_MODE_TXRX_ACTIVITY) {
+		rt2x00_set_field32(&reg, LEDCSR_LINK, 1);
+		rt2x00_set_field32(&reg, LEDCSR_ACTIVITY, 0);
+	} else if (rt2x00pci->led_mode =3D=3D LED_MODE_ASUS) {
+		rt2x00_set_field32(&reg, LEDCSR_LINK, 0);
+		rt2x00_set_field32(&reg, LEDCSR_ACTIVITY, 1);
+	} else {
+		rt2x00_set_field32(&reg, LEDCSR_LINK, 1);
+		rt2x00_set_field32(&reg, LEDCSR_ACTIVITY, 1);
+	}
+
+	rt2x00_register_write(rt2x00pci, LEDCSR, reg);
+}
+
+static void
+rt2500pci_disable_led(struct rt2x00_pci *rt2x00pci)
+{
+	u32			reg;
+
+	rt2x00_register_read(rt2x00pci, LEDCSR, &reg);
+	rt2x00_set_field32(&reg, LEDCSR_LINK, 0);
+	rt2x00_set_field32(&reg, LEDCSR_ACTIVITY, 0);
+	rt2x00_register_write(rt2x00pci, LEDCSR, reg);
+}
+
+static void
+rt2500pci_activity_led(struct rt2x00_pci *rt2x00pci, char activity)
+{
+	u32			reg;
+
+	if (rt2x00pci->led_mode !=3D LED_MODE_TXRX_ACTIVITY)
+		return;
+
+	rt2x00_register_read(rt2x00pci, LEDCSR, &reg);
+	rt2x00_set_field32(&reg, LEDCSR_ACTIVITY, activity);
+	rt2x00_register_write(rt2x00pci, LEDCSR, reg);
+}
+
+/*
  * Device state switch.
  * This will put the device to sleep, or awake it.
  */
@@ -962,6 +1013,11 @@ rt2500pci_rxdone(void *data)
 	 */
 	if (total_rssi && rssi_count)
 		rt2500pci_link_tuner(rt2x00pci, total_rssi / rssi_count);
+
+	/*
+	 * Update LED.
+	 */
+	rt2500pci_activity_led(rt2x00pci, 0);
 }
=20
 static void
@@ -1067,10 +1123,13 @@ rt2500pci_interrupt(int irq, void *dev_i
=20
 	/*
 	 * 2 - Rx ring done interrupt.
+	 * Enable the TXRX activity led.
 	 */
=2D	if (rt2x00_get_field32(reg, CSR7_RXDONE))
+	if (rt2x00_get_field32(reg, CSR7_RXDONE)) {
 		queue_work(rt2x00pci->workqueue,
 			&rt2x00pci->ring[RING_RX].irq_work);
+		rt2500pci_activity_led(rt2x00pci, 1);
+	}
=20
 	/*
 	 * 3 - Atim ring transmit done interrupt.
@@ -1435,13 +1494,6 @@ rt2500pci_init_registers(struct rt2x00_p
 	rt2x00_register_write(rt2x00pci, ARTCSR1, cpu_to_le32(0x1d21252d));
 	rt2x00_register_write(rt2x00pci, ARTCSR2, cpu_to_le32(0x1919191d));
=20
=2D	rt2x00_register_read(rt2x00pci, LEDCSR, &reg);
=2D	rt2x00_set_field32(&reg, LEDCSR_ON_PERIOD, 30);
=2D	rt2x00_set_field32(&reg, LEDCSR_OFF_PERIOD, 70);
=2D	rt2x00_set_field32(&reg, LEDCSR_LINK, 0);
=2D	rt2x00_set_field32(&reg, LEDCSR_ACTIVITY, 0);
=2D	rt2x00_register_write(rt2x00pci, LEDCSR, reg);
=2D
 	rt2x00_register_read(rt2x00pci, CSR1, &reg);
 	rt2x00_set_field32(&reg, CSR1_SOFT_RESET, 1);
 	rt2x00_set_field32(&reg, CSR1_BBP_RESET, 0);
@@ -1663,6 +1715,11 @@ rt2500pci_open(struct net_device *net_de
 	}
=20
 	/*
+	 * Enable LED
+	 */
+	rt2500pci_enable_led(rt2x00pci);
+
+	/*
 	 * Enable interrupts.
 	 */
 	rt2x00_register_read(rt2x00pci, CSR8, &reg);
@@ -1705,11 +1762,9 @@ rt2500pci_stop(struct net_device *net_de
 	rt2x00_register_write(rt2x00pci, RXCSR0, reg);
=20
 	/*
=2D	 * Switch off LED.
+	 * Disable LED
 	 */
=2D	rt2x00_register_read(rt2x00pci, LEDCSR, &reg);
=2D	rt2x00_set_field32(&reg, LEDCSR_LINK, 0);
=2D	rt2x00_register_write(rt2x00pci, LEDCSR, reg);
+	rt2500pci_disable_led(rt2x00pci);
=20
 	/*
 	 * Disable interrupts.
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 21:57:18.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 22:04:19.000000000 +0200
@@ -532,6 +532,59 @@ rt2500usb_link_tuner(struct rt2x00_usb *
 }
=20
 /*
+ * LED functions.
+ */
+static void
+rt2500usb_enable_led(struct rt2x00_usb *rt2x00usb)
+{
+	u16			reg;
+
+	rt2x00_register_read(rt2x00usb, MAC_CSR21, &reg);
+	rt2x00_set_field16_nb(&reg, MAC_CSR21_ON_PERIOD, 30);
+	rt2x00_set_field16_nb(&reg, MAC_CSR21_OFF_PERIOD, 70);
+	rt2x00_register_write(rt2x00usb, MAC_CSR21, reg);
+
+	rt2x00_register_read(rt2x00usb, MAC_CSR20, &reg);
+
+	if (rt2x00usb->led_mode =3D=3D LED_MODE_TXRX_ACTIVITY) {
+		rt2x00_set_field16_nb(&reg, MAC_CSR20_LINK, 1);
+		rt2x00_set_field16_nb(&reg, MAC_CSR20_ACTIVITY, 0);
+	} else if (rt2x00usb->led_mode =3D=3D LED_MODE_ASUS) {
+		rt2x00_set_field16_nb(&reg, MAC_CSR20_LINK, 0);
+		rt2x00_set_field16_nb(&reg, MAC_CSR20_ACTIVITY, 1);
+	} else {
+		rt2x00_set_field16_nb(&reg, MAC_CSR20_LINK, 1);
+		rt2x00_set_field16_nb(&reg, MAC_CSR20_ACTIVITY, 1);
+	}
+
+	rt2x00_register_write(rt2x00usb, MAC_CSR20, reg);
+}
+
+static void
+rt2500usb_disable_led(struct rt2x00_usb *rt2x00usb)
+{
+	u16			reg;
+
+	rt2x00_register_read(rt2x00usb, MAC_CSR20, &reg);
+	rt2x00_set_field16_nb(&reg, MAC_CSR20_LINK, 0);
+	rt2x00_set_field16_nb(&reg, MAC_CSR20_ACTIVITY, 0);
+	rt2x00_register_write(rt2x00usb, MAC_CSR20, reg);
+}
+
+static void
+rt2500usb_activity_led(struct rt2x00_usb *rt2x00usb, char activity)
+{
+	u16			reg;
+
+	if (rt2x00usb->led_mode !=3D LED_MODE_TXRX_ACTIVITY)
+		return;
+
+	rt2x00_register_read(rt2x00usb, MAC_CSR20, &reg);
+	rt2x00_set_field16_nb(&reg, MAC_CSR20_ACTIVITY, activity);
+	rt2x00_register_write(rt2x00usb, MAC_CSR20, reg);
+}
+
+/*
  * Device state switch.
  * This will put the device to sleep, or awake it.
  */
@@ -782,6 +835,11 @@ rt2500usb_rxdone(void *data)
 	 */
 	if (total_rssi && rssi_count)
 		rt2500usb_link_tuner(rt2x00usb, total_rssi / rssi_count);
+
+	/*
+	 * Update LED.
+	 */
+	rt2500usb_activity_led(rt2x00usb, 0);
 }
=20
 static void
@@ -857,9 +915,14 @@ rt2500usb_interrupt(struct urb *urb, str
 	if (!GET_FLAG(rt2x00usb, RADIO_ENABLED))
 		return;
=20
+	CLEAR_FLAG(entry, ENTRY_OWNER_NIC);
+
 	if (urb->status)
 		return;
=20
+	if (GET_FLAG(entry, ENTRY_TYPE_RX))
+		rt2500usb_activity_led(rt2x00usb, 1);
+
 	queue_work(rt2x00usb->workqueue, &entry->ring->irq_work);
 }
=20
@@ -1104,7 +1167,6 @@ rt2500usb_init_registers(struct rt2x00_u
 	rt2x00_register_write(rt2x00usb, TXRX_CSR21, 0xe78f);
 	rt2x00_register_write(rt2x00usb, MAC_CSR9, 0xff1d);
 	rt2x00_register_write(rt2x00usb, MAC_CSR1, 0x0004);
=2D	rt2x00_register_write(rt2x00usb, MAC_CSR20, 0x0000);
=20
 	reg =3D 0;
 	rt2x00_register_read(rt2x00usb, MAC_CSR0, &reg);
@@ -1321,6 +1383,11 @@ rt2500usb_open(struct net_device *net_de
 	rt2x00_set_field16_nb(&reg, TXRX_CSR2_DISABLE_RX, 0);
 	rt2x00_register_write(rt2x00usb, TXRX_CSR2, reg);
=20
+	/*
+	 * Enable LED
+	 */
+	rt2500usb_enable_led(rt2x00usb);
+
 	SET_FLAG(rt2x00usb, RADIO_ENABLED);
=20
 	return 0;
@@ -1348,16 +1415,16 @@ rt2500usb_stop(struct net_device *net_de
 	rt2x00_set_field16_nb(&reg, TXRX_CSR2_DISABLE_RX, 1);
 	rt2x00_register_write(rt2x00usb, TXRX_CSR2, reg);
=20
+	/*
+	 * Disable LED
+	 */
+	rt2500usb_disable_led(rt2x00usb);
+
 	entry =3D (struct data_entry*)rt2x00usb->ring[RING_RX].entry;
 	for (counter =3D 0; counter < rt2x00usb->ring[RING_RX].stats.limit; count=
er++) {
 		usb_kill_urb(entry[counter].urb);
 	}
=20
=2D	/*
=2D	 * Switch off LED.
=2D	 */
=2D	rt2x00_register_write(rt2x00usb, MAC_CSR20, 0);
=2D
 	rt2x00_vendor_request(rt2x00usb, USB_RX_CONTROL,
 		USB_VENDOR_REQUEST_OUT, 0x00, 0x00, NULL, 0);
=20

--nextPart1302435.AkHDyMJPKG
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+maqndE37Em0gRAv9sAJ9FHDgAA5NRLw8aAWKCkP8i/h9jygCggrBu
vuz4ekPxpBt2NtaDe267PT8=
=SsvX
-----END PGP SIGNATURE-----

--nextPart1302435.AkHDyMJPKG--
