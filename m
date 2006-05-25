From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [RFC PATCH 2/2] Hardware button support for Wireless cards: rt2x00
Date: Thu, 25 May 2006 17:16:03 +0200
Message-ID: <200605251716.03726.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart9498218.4W3hmHiTsW";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.184]:55864 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S965200AbWEYPN3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 11:13:29 -0400
Received: by nf-out-0910.google.com with SMTP id o63so171654nfa
        for <netdev@vger.kernel.org>; Thu, 25 May 2006 08:13:28 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart9498218.4W3hmHiTsW
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Use radiobtn interface for radio hardware button support in rt2x00

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev/drivers/net/wireless/d80211/rt2x00/Kconfig wireless=
=2Ddev-radiobtn/drivers/net/wireless/d80211/rt2x00/Kconfig
=2D-- wireless-dev/drivers/net/wireless/d80211/rt2x00/Kconfig	2006-05-06 21=
:11:03.000000000 +0200
+++ wireless-dev-radiobtn/drivers/net/wireless/d80211/rt2x00/Kconfig	2006-0=
5-25 16:32:23.000000000 +0200
@@ -17,7 +17,7 @@ config RT2400PCI
=20
 config RT2400PCI_BUTTON
 	bool "Ralink rt2400 hardware button support"
=2D	depends on RT2400PCI && X86
+	depends on RT2400PCI && RADIOBTN
 	---help---
 	In some notebooks the rt2400 chipset is integrated in the machine,
 	with this option enabled the device will periodically poll the
@@ -40,7 +40,7 @@ config RT2500PCI
=20
 config RT2500PCI_BUTTON
 	bool "Ralink rt2500 hardware button support"
=2D	depends on RT2500PCI && X86
+	depends on RT2500PCI && RADIOBTN
 	---help---
 	In some notebooks the rt2500 chipset is integrated in the machine,
 	with this option enabled the device will periodically poll the
@@ -61,9 +61,9 @@ config RT61PCI
=20
 	When compiled as a module, this driver will be called "rt61pci.ko".
=20
=2Dconfig RT2500PCI_BUTTON
+config RT61PCI_BUTTON
 	bool "Ralink rt61 hardware button support"
=2D	depends on RT61PCI && X86
+	depends on RT61PCI && RADIOBTN
 	---help---
 	In some notebooks the rt61 chipset is integrated in the machine,
 	with this option enabled the device will periodically poll the
diff -uprN wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c wire=
less-dev-radiobtn/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
=2D-- wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	2006-05-0=
6 21:11:03.000000000 +0200
+++ wireless-dev-radiobtn/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-05-25 16:54:07.000000000 +0200
@@ -51,6 +51,7 @@
=20
 #ifdef CONFIG_RT2400PCI_BUTTON
 #define CONFIG_RT2X00_BUTTON
+#include <linux/radiobtn.h>
 #endif /* CONFIG_RT2400PCI_BUTTON */
=20
 #include "rt2x00.h"
@@ -364,18 +365,58 @@ rt2x00_eeprom_multiread(
 /*
  * Hardware button poll handler.
  */
=2Dstatic void
+static int
 rt2400pci_button_poll(unsigned long data)
 {
 	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)data;
 	u32			reg;
=20
 	rt2x00_register_read(rt2x00pci, GPIOCSR, &reg);
=2D	rt2x00pci_button_status(
=2D		rt2x00pci, rt2x00_get_field32(reg, GPIOCSR_BIT0));
+	return rt2x00_get_field32(reg, GPIOCSR_BIT0);
+}
+
+static void
+rt2400pci_enable_radio(unsigned long data)
+{
+	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)data;
+	struct net_device	*net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
+
+	rt2400pci_open(net_dev);
+}
+
+static void
+rt2400pci_disable_radio(unsigned long data)
+{
+	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)data;
+	struct net_device	*net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
+
+	rt2400pci_stop(net_dev);
+}
+
+static int
+rt2400pci_button_start(struct rt2x00_pci *rt2x00pci)
+{
+	struct radio_button	*button =3D &rt2x00pci->radio_button;
+
+	button->dev_name	=3D "rt2400pci";
+	button->data		=3D (unsigned long)rt2x00pci;
+	button->button_poll	=3D rt2400pci_button_poll;
+	button->enable_radio	=3D rt2400pci_enable_radio;
+	button->disable_radio	=3D rt2400pci_disable_radio;
+	button->poll_delay	=3D rt2x00_poll_delay;
+	button->current_state	=3D button->button_poll(button->data);
+
+	return radiobtn_register_device(button);
+}
+
+static void
+rt2400pci_button_stop(struct rt2x00_pci *rt2x00pci)
+{
+	radiobtn_unregister_device(&rt2x00pci->radio_button);
 }
 #else /* CONFIG_RT2400PCI_BUTTON */
=2Dstatic void rt2400pci_button_poll(struct rt2x00_pci *rt2x00pci){}
+static int rt2400pci_button_start(struct rt2x00_pci *rt2x00pci){return 0;}
+static void rt2400pci_button_stop(struct rt2x00_pci *rt2x00pci){}
 #endif /* CONFIG_RT2400PCI_BUTTON */
=20
 /*
@@ -2471,7 +2512,7 @@ rt2400pci_initialize(struct pci_dev *pci
 	/*
 	 * If required start hardware button polling.
 	 */
=2D	rt2x00pci_button_start(rt2x00pci, rt2400pci_button_poll);
+	rt2400pci_button_start(rt2x00pci);
=20
 	/*
 	 * Register hardware.
@@ -2502,7 +2543,7 @@ rt2400pci_uninitialize(struct net_device
 	/*
 	 * Shutdown poll_timer for hardware button.
 	 */
=2D	rt2x00pci_button_stop(rt2x00pci);
+	rt2400pci_button_stop(rt2x00pci);
=20
 	kfree(rt2x00pci->eeprom);
=20
diff -uprN wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c wire=
less-dev-radiobtn/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
=2D-- wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	2006-05-0=
6 21:11:03.000000000 +0200
+++ wireless-dev-radiobtn/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-05-25 16:53:54.000000000 +0200
@@ -51,6 +51,7 @@
=20
 #ifdef CONFIG_RT2500PCI_BUTTON
 #define CONFIG_RT2X00_BUTTON
+#include <linux/radiobtn.h>
 #endif /* CONFIG_RT2500PCI_BUTTON */
=20
 #include "rt2x00.h"
@@ -364,18 +365,58 @@ rt2x00_eeprom_multiread(
 /*
  * Hardware button poll handler.
  */
=2Dstatic void
+static int
 rt2500pci_button_poll(unsigned long data)
 {
 	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)data;
 	u32			reg;
=20
 	rt2x00_register_read(rt2x00pci, GPIOCSR, &reg);
=2D	rt2x00pci_button_status(
=2D		rt2x00pci, rt2x00_get_field32(reg, GPIOCSR_BIT0));
+	return rt2x00_get_field32(reg, GPIOCSR_BIT0);
+}
+
+static void
+rt2500pci_enable_radio(unsigned long data)
+{
+	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)data;
+	struct net_device	*net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
+
+	rt2500pci_open(net_dev);
+}
+
+static void
+rt2500pci_disable_radio(unsigned long data)
+{
+	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)data;
+	struct net_device	*net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
+
+	rt2500pci_stop(net_dev);
+}
+
+static int
+rt2500pci_button_start(struct rt2x00_pci *rt2x00pci)
+{
+	struct radio_button	*button =3D &rt2x00pci->radio_button;
+
+	button->dev_name	=3D "rt2500pci";
+	button->data		=3D (unsigned long)rt2x00pci;
+	button->button_poll	=3D rt2500pci_button_poll;
+	button->enable_radio	=3D rt2500pci_enable_radio;
+	button->disable_radio	=3D rt2500pci_disable_radio;
+	button->poll_delay	=3D rt2x00_poll_delay;
+	button->current_state	=3D button->button_poll(button->data);
+
+	return radiobtn_register_device(button);
+}
+
+static void
+rt2500pci_button_stop(struct rt2x00_pci *rt2x00pci)
+{
+	radiobtn_unregister_device(&rt2x00pci->radio_button);
 }
 #else /* CONFIG_RT2500PCI_BUTTON */
=2Dstatic void rt2500pci_button_poll(struct rt2x00_pci *rt2x00pci){}
+static int rt2500pci_button_start(struct rt2x00_pci *rt2x00pci){return 0;}
+static void rt2500pci_button_stop(struct rt2x00_pci *rt2x00pci){}
 #endif /* CONFIG_RT2500PCI_BUTTON */
=20
 /*
@@ -2774,7 +2815,7 @@ rt2500pci_initialize(struct pci_dev *pci
 	/*
 	 * If required start hardware button polling.
 	 */
=2D	rt2x00pci_button_start(rt2x00pci, rt2500pci_button_poll);
+	rt2500pci_button_start(rt2x00pci);
=20
 	/*
 	 * Register hardware.
@@ -2805,7 +2846,7 @@ rt2500pci_uninitialize(struct net_device
 	/*
 	 * Shutdown poll_timer for hardware button.
 	 */
=2D	rt2x00pci_button_stop(rt2x00pci);
+	rt2500pci_button_stop(rt2x00pci);
=20
 	kfree(rt2x00pci->eeprom);
=20
diff -uprN wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h wire=
less-dev-radiobtn/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h
=2D-- wireless-dev/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h	2006-05-0=
6 21:11:03.000000000 +0200
+++ wireless-dev-radiobtn/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h	20=
06-05-25 16:33:46.000000000 +0200
@@ -45,37 +45,6 @@
 #define EEPROM_READ_OPCODE		0x06
=20
 /*
=2D * HW button structure.
=2D */
=2D#ifdef CONFIG_RT2X00_BUTTON
=2D#include <acpi/acpi_bus.h>
=2D
=2Dstruct rt2x00_button{
=2D	/*
=2D	 * ACPI device for generation of ACPI events.
=2D	 */
=2D	struct acpi_device			acpi_dev;
=2D
=2D	/*
=2D	 * Timer for register polling.
=2D	 */
=2D	struct timer_list			poll_timer;
=2D
=2D	/*
=2D	 * Timer delay.
=2D	 */
=2D	short					poll_delay;
=2D
=2D	/*
=2D	 * Current status of button.
=2D	 */
=2D	short					button_status:1;
=2D	short					active_poll:1;
=2D	short					__pad:14;
=2D};
=2D#endif /* CONFIG_RT2X00_BUTTON */
=2D
=2D/*
  * data_entry
  * The data ring is a list of data entries.
  * Each entry holds a reference to the descriptor
@@ -123,7 +92,7 @@ struct rt2x00_pci{
 	struct pci_dev				*pci_dev;
=20
 #ifdef CONFIG_RT2X00_BUTTON
=2D	struct rt2x00_button			button;
+	struct radio_button			button;
 #endif /* CONFIG_RT2X00_BUTTON */
=20
 	/*
@@ -267,85 +236,11 @@ rt2x00pci_get_ring(struct rt2x00_pci *rt
 	return NULL;
 }
=20
=2D/*
=2D * HW button variables & functions.
=2D * The delay between each poll is set by the module parameter.
=2D */
 #ifdef CONFIG_RT2X00_BUTTON
 /*
  * Module parameter.
  */
 static short rt2x00_poll_delay =3D 0;
=2D
=2Dstatic inline void
=2Drt2x00pci_button_status(struct rt2x00_pci *rt2x00pci, char status)
=2D{
=2D	struct rt2x00_button	*button =3D &rt2x00pci->button;
=2D
=2D	if (!button->active_poll)
=2D		return;
=2D
=2D	if (status !=3D button->button_status) {
=2D		button->button_status =3D status;
=2D		acpi_bus_generate_event(
=2D			&button->acpi_dev, ACPI_TYPE_EVENT, status);
=2D	}
=2D
=2D	button->poll_timer.expires =3D jiffies + button->poll_delay;
=2D
=2D	if (button->active_poll)
=2D		add_timer(&button->poll_timer);
=2D}
=2D
=2Dstatic inline void
=2Drt2x00pci_button_start(struct rt2x00_pci *rt2x00pci,
=2D	void (*handler)(unsigned long data))
=2D{
=2D	struct rt2x00_button	*button =3D &rt2x00pci->button;
=2D
=2D	/*
=2D	 * Only enable polling when the user has
=2D	 * set the poll delay module parameter,
=2D	 * and the device contains a hardware button.
=2D	 */
=2D	if(!GET_FLAG(rt2x00pci, HARDWARE_BUTTON) || !rt2x00_poll_delay)
=2D		return;
=2D
=2D	strcpy(acpi_device_class(&button->acpi_dev), DRV_NAME "_button");
=2D	strcpy(acpi_device_bid(&button->acpi_dev), DRV_NAME);
=2D	strcpy(acpi_device_name(&button->acpi_dev), DRV_NAME);
=2D
=2D	init_timer(&button->poll_timer);
=2D
=2D	button->poll_delay =3D rt2x00_poll_delay * (HZ / 10);
=2D	button->button_status =3D 0;
=2D	button->active_poll =3D 1;
=2D
=2D	button->poll_timer.function =3D handler;
=2D	button->poll_timer.data =3D (unsigned long)rt2x00pci;
=2D	button->poll_timer.expires =3D jiffies + button->poll_delay;
=2D
=2D	add_timer(&button->poll_timer);
=2D}
=2D
=2Dstatic inline void
=2Drt2x00pci_button_stop(struct rt2x00_pci *rt2x00pci)
=2D{
=2D	/*
=2D	 * Shutdown poll_timer for hardware button,
=2D	 * make sure only to disable polling when
=2D	 * it was enabled in the first place.
=2D	 */
=2D	if(!rt2x00pci->button.active_poll)
=2D		return;
=2D
=2D	rt2x00pci->button.active_poll =3D 0;
=2D	del_timer_sync(&rt2x00pci->button.poll_timer);
=2D}
=2D#else /* CONFIG_RT2X00_BUTTON */
=2Dstatic inline void rt2x00pci_button_start(struct rt2x00_pci *rt2x00pci,
=2D	int (*handler)(struct rt2x00_pci *rt2x00pci)){}
=2Dstatic inline void rt2x00pci_button_stop(struct rt2x00_pci *rt2x00pci){}
 #endif /* CONFIG_RT2X00_BUTTON */
=20
 #endif /* RT2X00PCI_H */
diff -uprN wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c wirele=
ss-dev-radiobtn/drivers/net/wireless/d80211/rt2x00/rt61pci.c
=2D-- wireless-dev/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006-05-06 =
21:11:03.000000000 +0200
+++ wireless-dev-radiobtn/drivers/net/wireless/d80211/rt2x00/rt61pci.c	2006=
=2D05-25 16:54:30.000000000 +0200
@@ -52,6 +52,7 @@
=20
 #ifdef CONFIG_RT61PCI_BUTTON
 #define CONFIG_RT2X00_BUTTON
+#include <linux/radiobtn.h>
 #endif /* CONFIG_RT61PCI_BUTTON */
=20
 #include "rt2x00.h"
@@ -400,18 +401,58 @@ rt2x00_eeprom_multiread(
 /*
  * Hardware button poll handler.
  */
=2Dstatic void
+static int
 rt61pci_button_poll(unsigned long data)
 {
 	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)data;
 	u32			reg;
=20
 	rt2x00_register_read(rt2x00pci, MAC_CSR13, &reg);
=2D	rt2x00pci_button_status(
=2D		rt2x00pci, rt2x00_get_field32(reg, MAC_CSR13_BIT5));
+	return rt2x00_get_field32(reg, MAC_CSR13_BIT5);
+}
+
+static void
+rt61pci_enable_radio(unsigned long data)
+{
+	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)data;
+	struct net_device	*net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
+
+	rt61pci_open(net_dev);
+}
+
+static void
+rt61pci_disable_radio(unsigned long data)
+{
+	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)data;
+	struct net_device	*net_dev =3D pci_get_drvdata(rt2x00pci->pci_dev);
+
+	rt61pci_stop(net_dev);
+}
+
+static int
+rt61pci_button_start(struct rt2x00_pci *rt2x00pci)
+{
+	struct radio_button	*button =3D &rt2x00pci->radio_button;
+
+	button->dev_name	=3D "rt61pci";
+	button->data		=3D (unsigned long)rt2x00pci;
+	button->button_poll	=3D rt61pci_button_poll;
+	button->enable_radio	=3D rt61pci_enable_radio;
+	button->disable_radio	=3D rt61pci_disable_radio;
+	button->poll_delay	=3D rt2x00_poll_delay;
+	button->current_state	=3D button->button_poll(button->data);
+
+	return radiobtn_register_device(button);
+}
+
+static void
+rt61pci_button_stop(struct rt2x00_pci *rt2x00pci)
+{
+	radiobtn_unregister_device(&rt2x00pci->radio_button);
 }
 #else /* CONFIG_RT61PCI_BUTTON */
=2Dstatic void rt61pci_button_poll(struct rt2x00_pci *rt2x00pci){}
+static int rt61pci_button_start(struct rt2x00_pci *rt2x00pci){return 0;}
+static void rt61pci_button_stop(struct rt2x00_pci *rt2x00pci){}
 #endif /* CONFIG_RT61PCI_BUTTON */
=20
 /*
@@ -3324,7 +3365,7 @@ rt61pci_initialize(struct pci_dev *pci_d
 	/*
 	 * If required start hardware button polling.
 	 */
=2D	rt2x00pci_button_start(rt2x00pci, rt61pci_button_poll);
+	rt61pci_button_start(rt2x00pci);
=20
 	/*
 	 * Register hardware.
@@ -3355,7 +3396,7 @@ rt61pci_uninitialize(struct net_device *
 	/*
 	 * Shutdown poll_timer for hardware button.
 	 */
=2D	rt2x00pci_button_stop(rt2x00pci);
+	rt61pci_button_stop(rt2x00pci);
=20
 	kfree(rt2x00pci->eeprom);
=20

--nextPart9498218.4W3hmHiTsW
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEdcozaqndE37Em0gRAhJ8AJoDwxvuBioPKC0ia5YDQS/rjkUCWgCeLhod
0azdm+QgbwaB5TusaoCk/UE=
=4cuY
-----END PGP SIGNATURE-----

--nextPart9498218.4W3hmHiTsW--
