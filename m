From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 27/32] rt2x00: Put Hardware button in generic header
Date: Fri, 28 Apr 2006 00:03:17 +0200
Message-ID: <200604280003.18118.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2271025.03C2O3d55h";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.184]:37997 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751799AbWD0WCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:02:19 -0400
Received: by nproxy.gmail.com with SMTP id n29so1463914nfc
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:02:18 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2271025.03C2O3d55h
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Put the hardware button handling as much as possible
in the new generic header for PCI.
The individial .c files should now only contain
the polling function to check the state of the hardware button.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-27 21:57:18.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-27 22:03:48.000000000 +0200
@@ -38,10 +38,6 @@
 #include <net/iw_handler.h>
 #include <net/d80211.h>
=20
=2D#ifdef CONFIG_RT2400PCI_BUTTON
=2D#include <acpi/acpi_bus.h>
=2D#endif /* CONFIG_RT2400PCI_BUTTON */
=2D
 #include <asm/io.h>
=20
 /*
@@ -364,6 +360,24 @@ rt2x00_eeprom_multiread(
 		rt2x00_eeprom_read(rt2x00pci, word + counter, data++);
 }
=20
+#ifdef CONFIG_RT2400PCI_BUTTON
+/*
+ * Hardware button poll handler.
+ */
+static void
+rt2400pci_button_poll(unsigned long data)
+{
+	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)data;
+	u32			reg;
+
+	rt2x00_register_read(rt2x00pci, GPIOCSR, &reg);
+	rt2x00pci_button_status(
+		rt2x00pci, rt2x00_get_field32(reg, GPIOCSR_BIT0));
+}
+#else /* CONFIG_RT2400PCI_BUTTON */
+static void rt2400pci_button_poll(struct rt2x00_pci *rt2x00pci){}
+#endif /* CONFIG_RT2400PCI_BUTTON */
+
 /*
  * Configuration handlers.
  */
@@ -2258,24 +2272,10 @@ rt2400pci_initialize(struct pci_dev *pci
 	|| rt2400pci_init_hw(rt2x00pci))
 		goto exit_destroy_workqueue;
=20
=2D#ifdef CONFIG_RT2400PCI_BUTTON
=2D	strcpy(acpi_device_class(&rt2x00pci->acpi_dev), DRV_NAME "_button");
=2D	strcpy(acpi_device_bid(&rt2x00pci->acpi_dev), DRV_NAME);
=2D	strcpy(acpi_device_name(&rt2x00pci->acpi_dev), DRV_NAME);
=2D
=2D	init_timer(&rt2x00pci->poll_timer);
=2D
=2D	if (rt2x00_poll_delay
=2D	&& rt2x00pci->button_status !=3D BUTTON_STATUS_UNAVAILABLE) {
=2D		rt2x00pci->button_status =3D rt2400pci_poll(rt2x00pci);
=2D		rt2x00pci->poll_delay =3D rt2x00_poll_delay * (HZ / 10);
=2D		rt2x00pci->poll_timer.function =3D rt2400pci_poll_expire;
=2D		rt2x00pci->poll_timer.data =3D (unsigned long)rt2x00pci;
=2D		rt2x00pci->poll_timer.expires =3D
=2D			jiffies + rt2x00pci->poll_delay;
=2D		add_timer(&rt2x00pci->poll_timer);
=2D	};
=2D#endif /* CONFIG_RT2400PCI_BUTTON */
+	/*
+	 * If required start hardware button polling.
+	 */
+	rt2x00pci_button_start(rt2x00pci, rt2400pci_button_poll);
=20
 	return 0;
=20
@@ -2294,13 +2294,10 @@ rt2400pci_uninitialize(struct net_device
 {
 	struct rt2x00_pci	*rt2x00pci =3D ieee80211_dev_hw_data(net_dev);
=20
=2D#ifdef CONFIG_RT2400PCI_BUTTON
 	/*
 	 * Shutdown poll_timer for hardware button.
 	 */
=2D	rt2x00pci->button_status =3D BUTTON_STATUS_UNAVAILABLE;
=2D	del_timer_sync(&rt2x00pci->poll_timer);
=2D#endif /* CONFIG_RT2400PCI_BUTTON */
+	rt2x00pci_button_stop(rt2x00pci);
=20
 	kfree(rt2x00pci->eeprom);
=20
@@ -2506,40 +2503,6 @@ rt2400pci_resume(struct pci_dev *pci_dev
 }
 #endif /* CONFIG_PM */
=20
=2D#ifdef CONFIG_RT2400PCI_BUTTON
=2Dstatic int
=2Drt2400pci_poll(struct rt2x00_pci *rt2x00pci)
=2D{
=2D	u32			reg;
=2D
=2D	rt2x00_register_read(rt2x00pci, GPIOCSR, &reg);
=2D	return rt2x00_get_field32(reg, GPIOCSR_BIT0);
=2D}
=2D
=2Dstatic void
=2Drt2400pci_poll_expire(unsigned long data)
=2D{
=2D	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)data;
=2D	u16			status;
=2D
=2D	status =3D rt2400pci_poll(rt2x00pci);
=2D
=2D	if (rt2x00pci->button_status !=3D BUTTON_STATUS_UNAVAILABLE)
=2D		return;
=2D
=2D	if (status !=3D rt2x00pci->button_status) {
=2D		rt2x00pci->button_status =3D status;
=2D		acpi_bus_generate_event(&rt2x00pci->acpi_dev,
=2D			ACPI_TYPE_EVENT, rt2x00pci->button_status);
=2D	}
=2D
=2D	rt2x00pci->poll_timer.expires =3D jiffies + rt2x00pci->poll_delay;
=2D
=2D	if (rt2x00pci->button_status !=3D BUTTON_STATUS_UNAVAILABLE)
=2D		add_timer(&rt2x00pci->poll_timer);
=2D}
=2D#endif /* CONFIG_RT2400PCI_BUTTON */
=2D
 /*
  * RT2400pci module information.
  */
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.h	20=
06-04-27 21:57:18.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
h	2006-04-27 22:03:48.000000000 +0200
@@ -863,21 +863,4 @@ static int rt2400pci_beacon_update(struc
 	struct sk_buff *skb, struct ieee80211_tx_control *control);
 static int rt2400pci_tx_last_beacon(struct net_device *net_dev);
=20
=2D/*
=2D * HW button support structures and variables.
=2D * The delay between each poll is set by the module parameter.
=2D */
=2D#ifdef CONFIG_RT2400PCI_BUTTON
=2D/*
=2D * Module parameter.
=2D */
=2Dstatic int rt2x00_poll_delay =3D 100;
=2D
=2D/*
=2D * Declaration of several required functions.
=2D */
=2Dstatic int rt2400pci_poll(struct rt2x00_pci *rt2x00pci);
=2Dstatic void rt2400pci_poll_expire(unsigned long data);
=2D#endif /* CONFIG_RT2400PCI_BUTTON */
=2D
 #endif /* RT2400PCI_H */
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 21:57:18.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 22:03:48.000000000 +0200
@@ -38,10 +38,6 @@
 #include <net/iw_handler.h>
 #include <net/d80211.h>
=20
=2D#ifdef CONFIG_RT2500PCI_BUTTON
=2D#include <acpi/acpi_bus.h>
=2D#endif /* CONFIG_RT2500PCI_BUTTON */
=2D
 #include <asm/io.h>
=20
 /*
@@ -364,6 +360,24 @@ rt2x00_eeprom_multiread(
 		rt2x00_eeprom_read(rt2x00pci, word + counter, data++);
 }
=20
+#ifdef CONFIG_RT2500PCI_BUTTON
+/*
+ * Hardware button poll handler.
+ */
+static void
+rt2500pci_button_poll(unsigned long data)
+{
+	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)data;
+	u32			reg;
+
+	rt2x00_register_read(rt2x00pci, GPIOCSR, &reg);
+	rt2x00pci_button_status(
+		rt2x00pci, rt2x00_get_field32(reg, GPIOCSR_BIT0));
+}
+#else /* CONFIG_RT2500PCI_BUTTON */
+static void rt2500pci_button_poll(struct rt2x00_pci *rt2x00pci){}
+#endif /* CONFIG_RT2500PCI_BUTTON */
+
 /*
  * Configuration handlers.
  */
@@ -2547,24 +2561,10 @@ rt2500pci_initialize(struct pci_dev *pci
 	|| rt2500pci_init_hw(rt2x00pci))
 		goto exit_destroy_workqueue;
=20
=2D#ifdef CONFIG_RT2500PCI_BUTTON
=2D	strcpy(acpi_device_class(&rt2x00pci->acpi_dev), DRV_NAME "_button");
=2D	strcpy(acpi_device_bid(&rt2x00pci->acpi_dev), DRV_NAME);
=2D	strcpy(acpi_device_name(&rt2x00pci->acpi_dev), DRV_NAME);
=2D
=2D	init_timer(&rt2x00pci->poll_timer);
=2D
=2D	if (rt2x00_poll_delay
=2D	&& rt2x00pci->button_status !=3D BUTTON_STATUS_UNAVAILABLE) {
=2D		rt2x00pci->button_status =3D rt2500pci_poll(rt2x00pci);
=2D		rt2x00pci->poll_delay =3D rt2x00_poll_delay * (HZ / 10);
=2D		rt2x00pci->poll_timer.function =3D rt2500pci_poll_expire;
=2D		rt2x00pci->poll_timer.data =3D (unsigned long)rt2x00pci;
=2D		rt2x00pci->poll_timer.expires =3D
=2D			jiffies + rt2x00pci->poll_delay;
=2D		add_timer(&rt2x00pci->poll_timer);
=2D	};
=2D#endif /* CONFIG_RT2500PCI_BUTTON */
+	/*
+	 * If required start hardware button polling.
+	 */
+	rt2x00pci_button_start(rt2x00pci, rt2500pci_button_poll);
=20
 	return 0;
=20
@@ -2583,13 +2583,10 @@ rt2500pci_uninitialize(struct net_device
 {
 	struct rt2x00_pci	*rt2x00pci =3D ieee80211_dev_hw_data(net_dev);
=20
=2D#ifdef CONFIG_RT2500PCI_BUTTON
 	/*
 	 * Shutdown poll_timer for hardware button.
 	 */
=2D	rt2x00pci->button_status =3D BUTTON_STATUS_UNAVAILABLE;
=2D	del_timer_sync(&rt2x00pci->poll_timer);
=2D#endif /* CONFIG_RT2500PCI_BUTTON */
+	rt2x00pci_button_stop(rt2x00pci);
=20
 	kfree(rt2x00pci->eeprom);
=20
@@ -2791,40 +2788,6 @@ rt2500pci_resume(struct pci_dev *pci_dev
 }
 #endif /* CONFIG_PM */
=20
=2D#ifdef CONFIG_RT2500PCI_BUTTON
=2Dstatic int
=2Drt2500pci_poll(struct rt2x00_pci *rt2x00pci)
=2D{
=2D	u32			reg;
=2D
=2D	rt2x00_register_read(rt2x00pci, GPIOCSR, &reg);
=2D	return rt2x00_get_field32(reg, GPIOCSR_BIT0);
=2D}
=2D
=2Dstatic void
=2Drt2500pci_poll_expire(unsigned long data)
=2D{
=2D	struct rt2x00_pci	*rt2x00pci =3D (struct rt2x00_pci*)data;
=2D	u16			status;
=2D
=2D	status =3D rt2500pci_poll(rt2x00pci);
=2D
=2D	if (rt2x00pci->button_status !=3D BUTTON_STATUS_UNAVAILABLE)
=2D		return;
=2D
=2D	if (status !=3D rt2x00pci->button_status) {
=2D		rt2x00pci->button_status =3D status;
=2D		acpi_bus_generate_event(&rt2x00pci->acpi_dev,
=2D			ACPI_TYPE_EVENT, rt2x00pci->button_status);
=2D	}
=2D
=2D	rt2x00pci->poll_timer.expires =3D jiffies + rt2x00pci->poll_delay;
=2D
=2D	if (rt2x00pci->button_status !=3D BUTTON_STATUS_UNAVAILABLE)
=2D		add_timer(&rt2x00pci->poll_timer);
=2D}
=2D#endif /* CONFIG_RT2500PCI_BUTTON */
=2D
 /*
  * RT2500pci module information.
  */
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.h	20=
06-04-27 21:57:18.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
h	2006-04-27 22:03:48.000000000 +0200
@@ -1132,21 +1132,4 @@ static int rt2500pci_beacon_update(struc
 	struct sk_buff *skb, struct ieee80211_tx_control *control);
 static int rt2500pci_tx_last_beacon(struct net_device *net_dev);
=20
=2D/*
=2D * HW button support structures and variables.
=2D * The delay between each poll is set by the module parameter.
=2D */
=2D#ifdef CONFIG_RT2500PCI_BUTTON
=2D/*
=2D * Module parameter.
=2D */
=2Dstatic int rt2x00_poll_delay =3D 100;
=2D
=2D/*
=2D * Declaration of several required functions.
=2D */
=2Dstatic int rt2500pci_poll(struct rt2x00_pci *rt2x00pci);
=2Dstatic void rt2500pci_poll_expire(unsigned long data);
=2D#endif /* CONFIG_RT2500PCI_BUTTON */
=2D
 #endif /* RT2500PCI_H */
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00pci=
=2Eh wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00pci=
=2Eh
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2x00pci.h	20=
06-04-27 22:00:04.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2x00pci.=
h	2006-04-27 22:03:48.000000000 +0200
@@ -45,6 +45,37 @@
 #define EEPROM_READ_OPCODE		0x06
=20
 /*
+ * HW button structure.
+ */
+#ifdef CONFIG_RT2X00_BUTTON
+#include <acpi/acpi_bus.h>
+
+struct rt2x00_button{
+	/*
+	 * ACPI device for generation of ACPI events.
+	 */
+	struct acpi_device			acpi_dev;
+
+	/*
+	 * Timer for register polling.
+	 */
+	struct timer_list			poll_timer;
+
+	/*
+	 * Timer delay.
+	 */
+	short					poll_delay;
+
+	/*
+	 * Current status of button.
+	 */
+	short					button_status:1;
+	short					active_poll:1;
+	short					__pad:14;
+} __attribute__ ((packed));
+#endif /* CONFIG_RT2X00_BUTTON */
+
+/*
  * data_entry
  * The data ring is a list of data entries.
  * Each entry holds a reference to the descriptor
@@ -92,28 +123,7 @@ struct rt2x00_pci{
 	struct pci_dev				*pci_dev;
=20
 #ifdef CONFIG_RT2X00_BUTTON
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
=2D	u16					poll_delay;
=2D
=2D	/*
=2D	 * Current status of button.
=2D	 */
=2D	u16					button_status;
=2D#define BUTTON_STATUS_UNAVAILABLE		2
=2D#define BUTTON_STATUS_ON			1
=2D#define BUTTON_STATUS_OFF			0
+	struct rt2x00_button			button;
 #endif /* CONFIG_RT2X00_BUTTON */
=20
 	/*
@@ -257,4 +267,85 @@ rt2x00pci_get_ring(struct rt2x00_pci *rt
 	return NULL;
 }
=20
+/*
+ * HW button variables & functions.
+ * The delay between each poll is set by the module parameter.
+ */
+#ifdef CONFIG_RT2X00_BUTTON
+/*
+ * Module parameter.
+ */
+static short rt2x00_poll_delay =3D 0;
+
+static inline void
+rt2x00pci_button_status(struct rt2x00_pci *rt2x00pci, char status)
+{
+	struct rt2x00_button	*button =3D &rt2x00pci->button;
+
+	if (!button->active_poll)
+		return;
+
+	if (status !=3D button->button_status) {
+		button->button_status =3D status;
+		acpi_bus_generate_event(
+			&button->acpi_dev, ACPI_TYPE_EVENT, status);
+	}
+
+	button->poll_timer.expires =3D jiffies + button->poll_delay;
+
+	if (button->active_poll)
+		add_timer(&button->poll_timer);
+}
+
+static inline void
+rt2x00pci_button_start(struct rt2x00_pci *rt2x00pci,
+	void (*handler)(unsigned long data))
+{
+	struct rt2x00_button	*button =3D &rt2x00pci->button;
+
+	/*
+	 * Only enable polling when the user has
+	 * set the poll delay module parameter,
+	 * and the device contains a hardware button.
+	 */
+	if(!GET_FLAG(rt2x00pci, HARDWARE_BUTTON) || !rt2x00_poll_delay)
+		return;
+
+	strcpy(acpi_device_class(&button->acpi_dev), DRV_NAME "_button");
+	strcpy(acpi_device_bid(&button->acpi_dev), DRV_NAME);
+	strcpy(acpi_device_name(&button->acpi_dev), DRV_NAME);
+
+	init_timer(&button->poll_timer);
+
+	button->poll_delay =3D rt2x00_poll_delay * (HZ / 10);
+	button->button_status =3D 0;
+	button->active_poll =3D 1;
+
+	button->poll_timer.function =3D handler;
+	button->poll_timer.data =3D (unsigned long)rt2x00pci;
+	button->poll_timer.expires =3D jiffies + button->poll_delay;
+
+	add_timer(&button->poll_timer);
+}
+
+static inline void
+rt2x00pci_button_stop(struct rt2x00_pci *rt2x00pci)
+{
+	/*
+	 * Shutdown poll_timer for hardware button,
+	 * make sure only to disable polling when
+	 * it was enabled in the first place.
+	 */
+	if(!rt2x00pci->button.active_poll)
+		return;
+
+	rt2x00pci->button.active_poll =3D 0;
+	del_timer_sync(&rt2x00pci->button.poll_timer);
+}
+#else /* CONFIG_RT2X00_BUTTON */
+static inline void rt2x00pci_button_start(struct rt2x00_pci *rt2x00pci,
+	int (*handler)(struct rt2x00_pci *rt2x00pci)){}
+static inline void rt2x00pci_button_stop(struct rt2x00_pci *rt2x00pci){}
+#endif /* CONFIG_RT2X00_BUTTON */
+
 #endif /* RT2X00PCI_H */

--nextPart2271025.03C2O3d55h
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+maqndE37Em0gRAg9JAJ9YFus2z5pVh4QPkFBw2WdxmZnBaACg338M
DZTRA+tQC/2Yp1THVnHSp/4=
=WObL
-----END PGP SIGNATURE-----

--nextPart2271025.03C2O3d55h--
