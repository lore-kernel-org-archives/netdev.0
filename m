From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: [PATCH 18/32] rt2x00: Make sure device has reached requested state while suspend/resume
Date: Fri, 28 Apr 2006 00:03:10 +0200
Message-ID: <200604280003.10710.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2767725.o4s6eHzY6B";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.191]:40300 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751794AbWD0WCL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 18:02:11 -0400
Received: by nproxy.gmail.com with SMTP id x30so1388658nfb
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2006 15:02:10 -0700 (PDT)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2767725.o4s6eHzY6B
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rom: Ivo van Doorn <IvDoorn@gmail.com>

Add the *_set_state functions which makes sure
the device is switching state to awake or sleep.
=46ix bad behaviour in the suspend routine,
and disable the radio before suspending.

Signed-off-by: Ivo van Doorn <IvDoorn@gmail.com>

diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2400pci.c	20=
06-04-27 21:49:08.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2400pci.=
c	2006-04-27 21:49:59.000000000 +0200
@@ -653,6 +653,44 @@ rt2400pci_link_tuner(struct rt2x00_pci *
 }
=20
 /*
+ * Device state switch.
+ * This will put the device to sleep, or awake it.
+ */
+static int
+rt2400pci_set_state(struct rt2x00_pci *rt2x00pci, enum dev_state state)
+{
+	u32			reg;
+	int			counter;
+	char			put_to_sleep;
+
+	put_to_sleep =3D (state !=3D STATE_AWAKE);
+
+	rt2x00_register_read(rt2x00pci, PWRCSR1, &reg);
+	rt2x00_set_field32(&reg, PWRCSR1_SET_STATE, 1);
+	rt2x00_set_field32(&reg, PWRCSR1_BBP_DESIRE_STATE, state);
+	rt2x00_set_field32(&reg, PWRCSR1_RF_DESIRE_STATE, state);
+	rt2x00_set_field32(&reg, PWRCSR1_PUT_TO_SLEEP, put_to_sleep);
+	rt2x00_register_write(rt2x00pci, PWRCSR1, reg);
+
+	/*
+	 * Device is not guarenteed to be in the requested state yet.
+	 * We must wait untill the register indicates that the
+	 * device has entered the correct state.
+	 */
+	for (counter =3D 0; counter < REGISTER_BUSY_COUNT; counter++) {
+		rt2x00_register_read(rt2x00pci, PWRCSR1, &reg);
+		if ((rt2x00_get_field32(reg, PWRCSR1_BBP_CURR_STATE) =3D=3D state)
+		&& (rt2x00_get_field32(reg, PWRCSR1_RF_CURR_STATE) =3D=3D state))
+			return 0;
+		msleep(10);
+	}
+
+	NOTICE("Device failed to %s.\n" , put_to_sleep ? "suspend" : "resume");
+
+	return -EBUSY;
+}
+
+/*
  * TX descriptor initialization
  */
 static void
@@ -1190,6 +1228,9 @@ rt2400pci_init_registers(struct rt2x00_p
 {
 	u32		reg;
=20
+	if (rt2400pci_set_state(rt2x00pci, STATE_AWAKE))
+		return -EBUSY;
+
 	rt2x00_register_write(rt2x00pci, PWRCSR0, cpu_to_le32(0x3f3b3100));
=20
 	rt2x00_register_write(rt2x00pci, PSCSR0, cpu_to_le32(0x00020002));
@@ -2342,57 +2383,42 @@ rt2400pci_remove(struct pci_dev *pci_dev
 }
=20
 #ifdef CONFIG_PM
=2Dstatic int rt2400pci_resume(struct pci_dev *pci_dev);
=2D
 static int
 rt2400pci_suspend(struct pci_dev *pci_dev, pm_message_t state)
 {
 	struct net_device	*net_dev =3D pci_get_drvdata(pci_dev);
 	struct rt2x00_pci	*rt2x00pci =3D ieee80211_dev_hw_data(net_dev);
=2D	int			counter;
=2D	u32			reg;
=20
 	NOTICE("Going to sleep.\n");
=20
=2D	if (ieee80211_netif_oper(net_dev, NETIF_DETACH))
=2D		return -EBUSY;
=2D
=2D	rt2x00_register_read(rt2x00pci, PWRCSR1, &reg);
=2D	rt2x00_set_field32(&reg, PWRCSR1_SET_STATE, 1);
=2D	rt2x00_set_field32(&reg, PWRCSR1_BBP_DESIRE_STATE, 1);
=2D	rt2x00_set_field32(&reg, PWRCSR1_RF_DESIRE_STATE, 1);
=2D	rt2x00_set_field32(&reg, PWRCSR1_PUT_TO_SLEEP, 1);
=2D	rt2x00_register_write(rt2x00pci, PWRCSR1, reg);
=2D
 	/*
=2D	 * Device is not guarenteed to be asleep yet.
=2D	 * We must wait untill the register indicates
=2D	 * device has been correctly put to sleep.
+	 * If radio was enabled, stop radio and
+	 * set the resume flag to the radio will be enabled
+	 * when resuming.
 	 */
=2D	for (counter =3D 0; counter < REGISTER_BUSY_COUNT; counter++) {
=2D		rt2x00_register_read(rt2x00pci, PWRCSR1, &reg);
=2D		if ((rt2x00_get_field32(reg, PWRCSR1_BBP_CURR_STATE) =3D=3D 1)
=2D		&& (rt2x00_get_field32(reg, PWRCSR1_RF_CURR_STATE) =3D=3D 1))
=2D			break;
=2D		NOTICE("Waiting for device to sleep.\n");
=2D		msleep(10);
+	if (GET_FLAG(rt2x00pci, RADIO_ENABLED)) {
+		if (net_dev->stop(net_dev))
+			return -EBUSY;
+		SET_FLAG(rt2x00pci, RADIO_RESUME);
 	}
=20
=2D	if (counter =3D=3D REGISTER_BUSY_COUNT)
=2D		goto exit;
=2D
=2D	if (pci_enable_wake(pci_dev, pci_choose_state(pci_dev, state), 1)
=2D	|| pci_save_state(pci_dev)
=2D	|| pci_set_power_state(pci_dev, pci_choose_state(pci_dev, state)))
=2D		goto exit;
=2D
=2D	return 0;
+	/*
+	 * Set device mode to sleep for power management.
+	 */
+	if (rt2400pci_set_state(rt2x00pci, STATE_SLEEP))
+		return -EBUSY;
=20
=2Dexit:
=2D	ERROR("Failed to suspend device.\n");
+	/*
+	 * Uninitialize hardware.
+	 */
+	rt2400pci_uninitialize(net_dev);
=20
=2D	rt2400pci_resume(pci_dev);
=2D	return -EIO;
+	/*
+	 * Disable PCI.
+	 */
+	pci_save_state(pci_dev);
+	pci_disable_device(pci_dev);
+	return pci_set_power_state(pci_dev, pci_choose_state(pci_dev, state));
 }
=20
 static int
@@ -2400,25 +2426,44 @@ rt2400pci_resume(struct pci_dev *pci_dev
 {
 	struct net_device	*net_dev =3D pci_get_drvdata(pci_dev);
 	struct rt2x00_pci	*rt2x00pci =3D ieee80211_dev_hw_data(net_dev);
=2D	u32			reg;
=20
 	NOTICE("Waking up.\n");
=20
+	/*
+	 * Enable PCI.
+	 */
 	if (pci_set_power_state(pci_dev, PCI_D0)
=2D	|| pci_restore_state(pci_dev)
=2D	|| pci_enable_wake(pci_dev, PCI_D0, 0)) {
+	|| pci_enable_device(pci_dev)
+	|| pci_restore_state(pci_dev)) {
 		ERROR("Failed to resume device.\n");
 		return -EIO;
 	}
=20
=2D	rt2x00_register_read(rt2x00pci, PWRCSR1, &reg);
=2D	rt2x00_set_field32(&reg, PWRCSR1_SET_STATE, 1);
=2D	rt2x00_set_field32(&reg, PWRCSR1_BBP_DESIRE_STATE, 3);
=2D	rt2x00_set_field32(&reg, PWRCSR1_RF_DESIRE_STATE, 3);
=2D	rt2x00_set_field32(&reg, PWRCSR1_PUT_TO_SLEEP, 0);
=2D	rt2x00_register_write(rt2x00pci, PWRCSR1, reg);
+	/*
+	 * Initialize hardware.
+	 */
+	if (rt2400pci_initialize(pci_dev, net_dev)) {
+		ERROR("Failed to initialize device.\n");
+		return -ENOMEM;
+	}
=20
=2D	return ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+	/*
+	 * Set device mode to awake.
+	 */
+	if (rt2400pci_set_state(rt2x00pci, STATE_AWAKE))
+		return -EBUSY;
+
+	/*
+	 * Only enable radio when it was enabled
+	 * when we suspended.
+	 */
+	if (GET_FLAG(rt2x00pci, RADIO_RESUME)) {
+		if (net_dev->open(net_dev))
+			return -EBUSY;
+		CLEAR_FLAG(rt2x00pci, RADIO_RESUME);
+	}
+
+	return 0;
 }
 #endif /* CONFIG_PM */
=20
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500pci.c	20=
06-04-27 21:49:08.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500pci.=
c	2006-04-27 21:49:59.000000000 +0200
@@ -706,6 +706,44 @@ dynamic_cca_tune:
 }
=20
 /*
+ * Device state switch.
+ * This will put the device to sleep, or awake it.
+ */
+static int
+rt2500pci_set_state(struct rt2x00_pci *rt2x00pci, enum dev_state state)
+{
+	u32			reg;
+	int			counter;
+	char			put_to_sleep;
+
+	put_to_sleep =3D (state !=3D STATE_AWAKE);
+
+	rt2x00_register_read(rt2x00pci, PWRCSR1, &reg);
+	rt2x00_set_field32(&reg, PWRCSR1_SET_STATE, 1);
+	rt2x00_set_field32(&reg, PWRCSR1_BBP_DESIRE_STATE, state);
+	rt2x00_set_field32(&reg, PWRCSR1_RF_DESIRE_STATE, state);
+	rt2x00_set_field32(&reg, PWRCSR1_PUT_TO_SLEEP, put_to_sleep);
+	rt2x00_register_write(rt2x00pci, PWRCSR1, reg);
+
+	/*
+	 * Device is not guarenteed to be in the requested state yet.
+	 * We must wait untill the register indicates that the
+	 * device has entered the correct state.
+	 */
+	for (counter =3D 0; counter < REGISTER_BUSY_COUNT; counter++) {
+		rt2x00_register_read(rt2x00pci, PWRCSR1, &reg);
+		if ((rt2x00_get_field32(reg, PWRCSR1_BBP_CURR_STATE) =3D=3D state)
+		&& (rt2x00_get_field32(reg, PWRCSR1_RF_CURR_STATE) =3D=3D state))
+			return 0;
+		msleep(10);
+	}
+
+	NOTICE("Device failed to %s.\n" , put_to_sleep ? "suspend" : "resume");
+
+	return -EBUSY;
+}
+
+/*
  * TX descriptor initialization
  */
 static void
@@ -1272,6 +1310,9 @@ rt2500pci_init_registers(struct rt2x00_p
 {
 	u32		reg;
=20
+	if (rt2500pci_set_state(rt2x00pci, STATE_AWAKE))
+		return -EBUSY;
+
 	rt2x00_register_write(rt2x00pci, PWRCSR0, cpu_to_le32(0x3f3b3100));
=20
 	rt2x00_register_write(rt2x00pci, PSCSR0, cpu_to_le32(0x00020002));
@@ -2636,57 +2677,42 @@ rt2500pci_remove(struct pci_dev *pci_dev
 }
=20
 #ifdef CONFIG_PM
=2Dstatic int rt2500pci_resume(struct pci_dev *pci_dev);
=2D
 static int
 rt2500pci_suspend(struct pci_dev *pci_dev, pm_message_t state)
 {
 	struct net_device	*net_dev =3D pci_get_drvdata(pci_dev);
 	struct rt2x00_pci	*rt2x00pci =3D ieee80211_dev_hw_data(net_dev);
=2D	int			counter;
=2D	u32			reg;
=20
 	NOTICE("Going to sleep.\n");
=20
=2D	if (ieee80211_netif_oper(net_dev, NETIF_DETACH))
=2D		return -EBUSY;
=2D
=2D	rt2x00_register_read(rt2x00pci, PWRCSR1, &reg);
=2D	rt2x00_set_field32(&reg, PWRCSR1_SET_STATE, 1);
=2D	rt2x00_set_field32(&reg, PWRCSR1_BBP_DESIRE_STATE, 1);
=2D	rt2x00_set_field32(&reg, PWRCSR1_RF_DESIRE_STATE, 1);
=2D	rt2x00_set_field32(&reg, PWRCSR1_PUT_TO_SLEEP, 1);
=2D	rt2x00_register_write(rt2x00pci, PWRCSR1, reg);
=2D
 	/*
=2D	 * Device is not guarenteed to be asleep yet.
=2D	 * We must wait untill the register indicates
=2D	 * device has been correctly put to sleep.
+	 * If radio was enabled, stop radio and
+	 * set the resume flag to the radio will be enabled
+	 * when resuming.
 	 */
=2D	for (counter =3D 0; counter < REGISTER_BUSY_COUNT; counter++) {
=2D		rt2x00_register_read(rt2x00pci, PWRCSR1, &reg);
=2D		if ((rt2x00_get_field32(reg, PWRCSR1_BBP_CURR_STATE) =3D=3D 1)
=2D		&& (rt2x00_get_field32(reg, PWRCSR1_RF_CURR_STATE) =3D=3D 1))
=2D			break;
=2D		NOTICE("Waiting for device to sleep.\n");
=2D		msleep(10);
+	if (GET_FLAG(rt2x00pci, RADIO_ENABLED)) {
+		if (net_dev->stop(net_dev))
+			return -EBUSY;
+		SET_FLAG(rt2x00pci, RADIO_RESUME);
 	}
=20
=2D	if (counter =3D=3D REGISTER_BUSY_COUNT)
=2D		goto exit;
=2D
=2D	if (pci_enable_wake(pci_dev, pci_choose_state(pci_dev, state), 1)
=2D	|| pci_save_state(pci_dev)
=2D	|| pci_set_power_state(pci_dev, pci_choose_state(pci_dev, state)))
=2D		goto exit;
=2D
=2D	return 0;
+	/*
+	 * Set device mode to sleep for power management.
+	 */
+	if (rt2500pci_set_state(rt2x00pci, STATE_SLEEP))
+		return -EBUSY;
=20
=2Dexit:
=2D	ERROR("Failed to suspend device.\n");
+	/*
+	 * Uninitialize hardware.
+	 */
+	rt2500pci_uninitialize(net_dev);
=20
=2D	rt2500pci_resume(pci_dev);
=2D	return -EIO;
+	/*
+	 * Disable PCI.
+	 */
+	pci_save_state(pci_dev);
+	pci_disable_device(pci_dev);
+	return pci_set_power_state(pci_dev, pci_choose_state(pci_dev, state));
 }
=20
 static int
@@ -2694,25 +2720,44 @@ rt2500pci_resume(struct pci_dev *pci_dev
 {
 	struct net_device	*net_dev =3D pci_get_drvdata(pci_dev);
 	struct rt2x00_pci	*rt2x00pci =3D ieee80211_dev_hw_data(net_dev);
=2D	u32			reg;
=20
 	NOTICE("Waking up.\n");
=20
+	/*
+	 * Enable PCI.
+	 */
 	if (pci_set_power_state(pci_dev, PCI_D0)
=2D	|| pci_restore_state(pci_dev)
=2D	|| pci_enable_wake(pci_dev, PCI_D0, 0)) {
+	|| pci_enable_device(pci_dev)
+	|| pci_restore_state(pci_dev)) {
 		ERROR("Failed to resume device.\n");
 		return -EIO;
 	}
=20
=2D	rt2x00_register_read(rt2x00pci, PWRCSR1, &reg);
=2D	rt2x00_set_field32(&reg, PWRCSR1_SET_STATE, 1);
=2D	rt2x00_set_field32(&reg, PWRCSR1_BBP_DESIRE_STATE, 3);
=2D	rt2x00_set_field32(&reg, PWRCSR1_RF_DESIRE_STATE, 3);
=2D	rt2x00_set_field32(&reg, PWRCSR1_PUT_TO_SLEEP, 0);
=2D	rt2x00_register_write(rt2x00pci, PWRCSR1, reg);
+	/*
+	 * Initialize hardware.
+	 */
+	if (rt2500pci_initialize(pci_dev, net_dev)) {
+		ERROR("Failed to initialize device.\n");
+		return -ENOMEM;
+	}
=20
=2D	return ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+	/*
+	 * Set device mode to awake.
+	 */
+	if (rt2500pci_set_state(rt2x00pci, STATE_AWAKE))
+		return -EBUSY;
+
+	/*
+	 * Only enable radio when it was enabled
+	 * when we suspended.
+	 */
+	if (GET_FLAG(rt2x00pci, RADIO_RESUME)) {
+		if (net_dev->open(net_dev))
+			return -EBUSY;
+		CLEAR_FLAG(rt2x00pci, RADIO_RESUME);
+	}
+
+	return 0;
 }
 #endif /* CONFIG_PM */
=20
diff -uprN wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb=
=2Ec
=2D-- wireless-dev-rt2x00/drivers/net/wireless/d80211/rt2x00/rt2500usb.c	20=
06-04-27 21:49:08.000000000 +0200
+++ wireless-dev-rt2x00-patch/drivers/net/wireless/d80211/rt2x00/rt2500usb.=
c	2006-04-27 21:49:59.000000000 +0200
@@ -547,6 +547,46 @@ rt2500usb_link_tuner(struct rt2x00_usb *
 }
=20
 /*
+ * Device state switch.
+ * This will put the device to sleep, or awake it.
+ */
+static int
+rt2500usb_set_state(struct rt2x00_usb *rt2x00usb, enum dev_state state)
+{
+	u16			reg;
+	int			counter;
+	char			put_to_sleep;
+
+	put_to_sleep =3D (state !=3D STATE_AWAKE);
+
+	rt2x00_register_read(rt2x00usb, MAC_CSR17, &reg);
+	rt2x00_set_field16_nb(&reg, MAC_CSR17_SET_STATE, 1);
+	rt2x00_set_field16_nb(&reg, MAC_CSR17_BBP_DESIRE_STATE, state);
+	rt2x00_set_field16_nb(&reg, MAC_CSR17_RF_DESIRE_STATE, state);
+	rt2x00_set_field16_nb(&reg, MAC_CSR17_PUT_TO_SLEEP, put_to_sleep);
+	rt2x00_register_write(rt2x00usb, MAC_CSR17, reg);
+
+	/*
+	 * Device is not guarenteed to be in the requested state yet.
+	 * We must wait untill the register indicates that the
+	 * device has entered the correct state.
+	 */
+	for (counter =3D 0; counter < REGISTER_BUSY_COUNT; counter++) {
+		rt2x00_register_read(rt2x00usb, MAC_CSR17, &reg);
+		if ((rt2x00_get_field16_nb(
+			reg, MAC_CSR17_BBP_CURR_STATE) =3D=3D state)
+		&& (rt2x00_get_field16_nb(
+			reg, MAC_CSR17_RF_CURR_STATE) =3D=3D state))
+			return 0;
+		msleep(10);
+	}
+
+	NOTICE("Device failed to %s.\n" , put_to_sleep ? "suspend" : "resume");
+
+	return -EBUSY;
+}
+
+/*
  * TX descriptor initialization
  */
 static void
@@ -1082,6 +1122,9 @@ rt2500usb_init_registers(struct rt2x00_u
 {
 	u16			reg;
=20
+	if (rt2500usb_set_state(rt2x00usb, STATE_AWAKE))
+		return -EBUSY;
+
 	rt2x00_vendor_request(rt2x00usb, USB_DEVICE_MODE,
 		USB_VENDOR_REQUEST_OUT, USB_MODE_TEST, 0x00, NULL, 0);
 	rt2x00_vendor_request(rt2x00usb, USB_SINGLE_WRITE,
@@ -2221,44 +2264,42 @@ rt2500usb_disconnect(struct usb_interfac
 }
=20
 #ifdef CONFIG_PM
=2Dstatic int rt2500usb_resume(struct usb_interface *usb_intf);
=2D
 static int
 rt2500usb_suspend(struct usb_interface *usb_intf, pm_message_t state)
 {
 	struct net_device	*net_dev =3D usb_get_intfdata(usb_intf);
 	struct rt2x00_usb	*rt2x00usb =3D ieee80211_dev_hw_data(net_dev);
=2D	int			counter;
=2D	u16			reg;
=20
 	NOTICE("Going to sleep.\n");
=20
=2D	if (ieee80211_netif_oper(net_dev, NETIF_DETACH))
+	/*
+	 * If radio was enabled, stop radio and
+	 * set the resume flag to the radio will be enabled
+	 * when resuming.
+	 */
+	if (GET_FLAG(rt2x00usb, RADIO_ENABLED)) {
+		if (net_dev->stop(net_dev))
+			return -EBUSY;
+		SET_FLAG(rt2x00usb, RADIO_RESUME);
+	}
+
+	/*
+	 * Set device mode to sleep for power management.
+	 */
+	if (rt2500usb_set_state(rt2x00usb, STATE_SLEEP))
 		return -EBUSY;
=20
=2D	rt2x00_register_read(rt2x00usb, MAC_CSR17, &reg);
=2D	rt2x00_set_field16_nb(&reg, MAC_CSR17_SET_STATE, 1);
=2D	rt2x00_set_field16_nb(&reg, MAC_CSR17_BBP_DESIRE_STATE, 1);
=2D	rt2x00_set_field16_nb(&reg, MAC_CSR17_RF_DESIRE_STATE, 1);
=2D	rt2x00_set_field16_nb(&reg, MAC_CSR17_PUT_TO_SLEEP, 1);
=2D	rt2x00_register_write(rt2x00usb, MAC_CSR17, reg);
+	/*
+	 * Uninitialize hardware.
+	 */
+	rt2500usb_uninitialize(net_dev);
=20
 	/*
=2D	 * Device is not guarenteed to be asleep yet.
=2D	 * We must wait untill the register indicates
=2D	 * device has been correctly put to sleep.
+	 * Decrease usbdev refcount.
 	 */
=2D	for (counter =3D 0; counter < REGISTER_BUSY_COUNT; counter++) {
=2D		rt2x00_register_read(rt2x00usb, MAC_CSR17, &reg);
=2D		if ((rt2x00_get_field16_nb(reg, MAC_CSR17_BBP_CURR_STATE) =3D=3D 1)
=2D		&& (rt2x00_get_field16_nb(reg, MAC_CSR17_RF_CURR_STATE) =3D=3D 1))
=2D	return 0;
=2D		NOTICE("Waiting for device to sleep.\n");
=2D		msleep(10);
=2D	}
+	usb_put_dev(interface_to_usbdev(usb_intf));
=20
=2D	rt2500usb_resume(usb_intf);
=2D	return -EIO;
+	return 0;
 }
=20
 static int
@@ -2266,18 +2307,39 @@ rt2500usb_resume(struct usb_interface *u
 {
 	struct net_device	*net_dev =3D usb_get_intfdata(usb_intf);
 	struct rt2x00_usb	*rt2x00usb =3D ieee80211_dev_hw_data(net_dev);
=2D	u16			reg;
=20
 	NOTICE("Waking up.\n");
=20
=2D	rt2x00_register_read(rt2x00usb, MAC_CSR17, &reg);
=2D	rt2x00_set_field16_nb(&reg, MAC_CSR17_SET_STATE, 1);
=2D	rt2x00_set_field16_nb(&reg, MAC_CSR17_BBP_DESIRE_STATE, 3);
=2D	rt2x00_set_field16_nb(&reg, MAC_CSR17_RF_DESIRE_STATE, 3);
=2D	rt2x00_set_field16_nb(&reg, MAC_CSR17_PUT_TO_SLEEP, 0);
=2D	rt2x00_register_write(rt2x00usb, MAC_CSR17, reg);
+	/*
+	 * Increase usbdev refcount.
+	 */
+	usb_get_dev(interface_to_usbdev(usb_intf));
=20
=2D	return ieee80211_netif_oper(net_dev, NETIF_ATTACH);
+	/*
+	 * Initialize hardware.
+	 */
+	if (rt2500usb_initialize(usb_intf, net_dev)) {
+		ERROR("Failed to initialize device.\n");
+		return -ENOMEM;
+	}
+
+	/*
+	 * Set device mode to awake.
+	 */
+	if (rt2500usb_set_state(rt2x00usb, STATE_AWAKE))
+		return -EBUSY;
+
+	/*
+	 * Only enable radio when it was enabled
+	 * when we suspended.
+	 */
+	if (GET_FLAG(rt2x00usb, RADIO_RESUME)) {
+		if (net_dev->open(net_dev))
+			return -EBUSY;
+		CLEAR_FLAG(rt2x00usb, RADIO_RESUME);
+	}
+
+	return 0;
 }
 #endif /* CONFIG_PM */
=20

--nextPart2767725.o4s6eHzY6B
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUT+eaqndE37Em0gRAsFbAKDhX75I8+OQs4Oa10R2x38pEP1IzACghy+J
zyLhbWLwWNn+WLm1HwrtT0s=
=ojy9
-----END PGP SIGNATURE-----

--nextPart2767725.o4s6eHzY6B--
