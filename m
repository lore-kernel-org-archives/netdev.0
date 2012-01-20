From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: [PATCH] net: usb: qmi_wwan: New driver for Huawei QMI based WWAN devices
Date: Fri, 20 Jan 2012 02:37:22 +0100
Message-ID: <1327023442-4304-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>,
	Dan Williams <dcbw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some WWAN LTE/3G devices based on chipsets from Qualcomm provide
near standard CDC ECM interfaces in addition to the usual serial
interfaces.   The Huawei E392/E398 are examples of such devices.

These typically cannot be fully configured using AT commands
over a serial interface.  It is necessary to speak the proprietary
Qualcomm MSM Interface (QMI) protocol to the device to enable the
ethernet proxy functionality.

The devices embed the QMI protocol in CDC on the control interface,
using standard CDC commands and notifications. The do not otherwise
use CDC commands for the ethernet function.  This driver does
therefore not need access to any other aspects of the control
interface than the descriptors attached to it.

Another driver, cdc-wdm, will provide userspace access to the
QMI protocol independently of this driver.  To facilitate this,
this driver avoids binding to the control interface, and uses
only the associated data interface after parsing the common CDC
functional descriptors on the control interface.

You will want both the cdc-wdm and option drivers as companions to
this driver, to have full access to all interfaces and protocols
exported by the device.

Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
---
So this is the third attempt on supporting the Huawei E392 modem
(and most likely a number of others, but I haven't tested that)
But I'm reluctant to call this version 3 of anythin, as the changes=20
since the last attempt are 100%:

 - all QMI code is gone and left for userspace where it belongs,=20
   thanks to convincing comments from Dan Williams and Marcel
   Holtmann
 - the accompanying code to export QMI to userspace is gone, as
   this is now done by the already existing cdc-wdm driver!
 - the patch against cdc-ether relaxing its descriptor parsing is=20
   also gone, as the driver must do its own descriptor parsing
   anyway to leave the control interface for cdc-wdm

There is a required set of changes to cdc-wdm to fully support
this device, but those are orthogonal to this driver.  The inter-
dependencies are all in userspace now :-)

So how do you use this?  You need
a) a patched cdc-wdm, or manually binding cdc-wdm to the control
   interface.  Note that you will need at least one patch from the
   last set I posted on linux-usb as the cdc-wdm driver otherwise
   will lockup!
b) a QMI userspace client.  perl and hexdump will do :-)  Dan=20
   Williams will probably provive a very nice alternative in=20
   ModemManager. He has some QMI decoding stuff in the /decode=20
   directory of the ModemManager repo.  I've been using that code
   for monitoring whats going on, with good results

The basic QMI commands needed to start a network session are,
assuming that you've got PIN code, APN name and such stuff out
of the way using standard GSM AT commands on one of the ttyUSBx
devices:

1) request a client ID for the QMI_WDS subsystem:
     perl -e 'print pack("C*", map { hex } @ARGV)' 1 f 0 0 0 0 0 1 22 0=
 4 0 1 1 0 1 >/dev/cdc-wdm2
=20
   you will need to parse the ID from reply for the next command.  It=20
   will be the very last byte in the reply (assumin success).  Initiall=
y
   it will also most likely be 1.

2) send a start connction message:
     perl -e 'print pack("C*", map { hex } @ARGV)' 1 c 0 0 1 3 0 2 0 20=
 0 0 0 >/dev/cdc-wdm2
                                     "3" is the client ID ---^

   the reply will contain a 4 byte handle which you will need to=20
   disconnect.

That's it! =20


Watching the output of those commands using Dans code to parse it:

bjorn@nemi:~$ /usr/local/src/git/modemmanager/decode/qmidevdebug.py /de=
v/cdc-wdm2
read 16 bytes

QMUX Header:
  len:    0x000f
  sender: 0x00 (client)
  svc:    0x00 (ctl)
  cid:    0x00=20

QMI Header:
  Flags:  0x00 (request)
  TXN:    0x0001
  Cmd:    0x0022 (GET_CLIENT_ID)
  Size:   0x0004

  TLV:    0x01 (CTL/Get Client ID Request/Type)
  Size:   0x0001
  Data:   01


read 24 bytes

QMUX Header:
  len:    0x0017
  sender: 0x80 (service)
  svc:    0x00 (ctl)
  cid:    0x00=20

QMI Header:
  Flags:  0x02 (response)
  TXN:    0x0001
  Cmd:    0x0022 (GET_CLIENT_ID)
  Size:   0x000c

  TLV:    0x02 (CTL/Get Client ID Response/Result Code)
  Size:   0x0004
  Status: 0 (SUCCESS)
  Error:  0

  TLV:    0x01 (CTL/Get Client ID Response/ID)
  Size:   0x0002
  Data:   01 03


read 13 bytes

QMUX Header:
  len:    0x000c
  sender: 0x00 (client)
  svc:    0x01 (wds)
  cid:    0x03=20

QMI Header:
  Flags:  0x00 (request)
  TXN:    0x0002
  Cmd:    0x0020 (START_NET)
  Size:   0x0000


read 27 bytes

QMUX Header:
  len:    0x001a
  sender: 0x80 (service)
  svc:    0x01 (wds)
  cid:    0x03=20

QMI Header:
  Flags:  0x02 (response)
  TXN:    0x0002
  Cmd:    0x0020 (START_NET)
  Size:   0x000e

  TLV:    0x02 (WDS/Start Network Interface Response/Result Code)
  Size:   0x0004
  Status: 0 (SUCCESS)
  Error:  0

  TLV:    0x01 (WDS/Start Network Interface Response/Packet Data Handle=
)
  Size:   0x0004
  Data:   e8 90 15 02


read 22 bytes

QMUX Header:
  len:    0x0015
  sender: 0x80 (service)
  svc:    0x01 (wds)
  cid:    0xff (broadcast)

QMI Header:
  Flags:  0x04 (indication)
  TXN:    0x0000
  Cmd:    0x0022 (GET_PKT_STATUS)
  Size:   0x0009

  TLV:    0x01 (WDS/Packet Service Status Report/Status)
  Size:   0x0002
  Data:   02 00

  TLV:    0x12 (!!! UNKNOWN !!!)
  Size:   0x0001
  Data:   04



The last message is an unsolicited notification telling us that
we are connected.  The device uses these instead of the CDC
notifications.  Which is lucky, as that allows us to just
let the cdc-wdm driver own the notification endpoint.



 drivers/net/usb/Kconfig    |   22 ++++
 drivers/net/usb/Makefile   |    1 +
 drivers/net/usb/qmi_wwan.c |  228 ++++++++++++++++++++++++++++++++++++=
++++++++
 3 files changed, 251 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/usb/qmi_wwan.c

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 2335761..4bad899 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -398,6 +398,27 @@ config USB_NET_KALMIA
 	  To compile this driver as a module, choose M here: the
 	  module will be called kalmia.
=20
+config USB_NET_QMI_WWAN
+	tristate "QMI WWAN driver for Qualcomm MSM based 3G and LTE modems"
+	depends on USB_USBNET
+	help
+	  Support WWAN LTE/3G devices based on Qualcomm Mobile Data Modem
+	  (MDM) chipsets.  Examples of such devices are
+	    * Huawei E392/E398
+
+	  This driver will only drive the ethernet part of the chips.
+	  The devices require additional configuration to be usable.
+	  Multiple management interfaces with linux drivers are
+	  available:
+
+	    * option: AT commands on /dev/ttyUSBx
+	    * cdc-wdm: Qualcomm MSM Interface (QMI) protocol on /dev/cdc-wdmx
+
+	  A modem manager with support for QMI is recommended.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called qmi_wwan.
+
 config USB_HSO
 	tristate "Option USB High Speed Mobile Devices"
 	depends on USB && RFKILL
@@ -461,4 +482,5 @@ config USB_VL600
=20
 	  http://ubuntuforums.org/showpost.php?p=3D10589647&postcount=3D17
=20
+
 endmenu
diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index c203fa2..a2e2d72 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -29,4 +29,5 @@ obj-$(CONFIG_USB_SIERRA_NET)	+=3D sierra_net.o
 obj-$(CONFIG_USB_NET_CX82310_ETH)	+=3D cx82310_eth.o
 obj-$(CONFIG_USB_NET_CDC_NCM)	+=3D cdc_ncm.o
 obj-$(CONFIG_USB_VL600)		+=3D lg-vl600.o
+obj-$(CONFIG_USB_NET_QMI_WWAN)	+=3D qmi_wwan.o
=20
diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
new file mode 100644
index 0000000..739e6de
--- /dev/null
+++ b/drivers/net/usb/qmi_wwan.c
@@ -0,0 +1,228 @@
+/*
+ * Copyright (c) 2012  Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/usb.h>
+#include <linux/usb/cdc.h>
+#include <linux/usb/usbnet.h>
+
+/* The name of the CDC Device Management driver */
+#define DM_DRIVER "cdc_wdm"
+
+/*
+ * This driver supports wwan (3G/LTE/?) devices using a vendor
+ * specific management protocol called Qualcomm MSM Interface (QMI) -
+ * in addition to the more common AT commands over serial interface
+ * management
+ *
+ * QMI is wrapped in CDC, using CDC encapsulated commands on the
+ * control ("master") interface of a two-interface CDC Union
+ * resembling standard CDC ECM.  The devices do not use the control
+ * interface for any other CDC messages.  Most likely because the
+ * management protocol is used in place of the standard CDC
+ * notifications NOTIFY_NETWORK_CONNECTION and NOTIFY_SPEED_CHANGE
+ *
+ * Handling a protocol like QMI is out of the scope for any driver.
+ * It can be exported as a character device using the cdc-wdm driver,
+ * which will enable userspace applications ("modem managers") to
+ * handle it.  This may be required to use the network interface
+ * provided by the driver.
+ *
+ * These devices may alternatively/additionally be configured using AT
+ * commands on any of the serial interfaces driven by the option drive=
r
+ *
+ * This driver binds only to the data ("slave") interface to enable
+ * the cdc-wdm driver to bind to the control interface.  It still
+ * parses the CDC functional descriptors on the control interface to
+ *  a) verify that this is indeed a handled interface (CDC Union
+ *     header lists it as slave)
+ *  b) get MAC address and other ethernet config from the CDC Ethernet
+ *     header
+ *  c) enable user bind requests against the control interface, which
+ *     is the common way to bind to CDC Ethernet Control Model type
+ *     interfaces
+ *  d) provide a hint to the user about which interface is the
+ *     corresponding management interface
+ */
+
+static int qmi_wwan_bind(struct usbnet *dev, struct usb_interface *int=
f)
+{
+	int status =3D -1;
+	struct usb_interface *control =3D NULL;
+	u8 *buf =3D intf->cur_altsetting->extra;
+	int len =3D intf->cur_altsetting->extralen;
+	struct usb_interface_descriptor *desc =3D &intf->cur_altsetting->desc=
;
+	struct usb_cdc_union_desc *cdc_union =3D NULL;
+	struct usb_cdc_ether_desc *cdc_ether =3D NULL;
+	u32 required =3D 1 << USB_CDC_HEADER_TYPE | 1 << USB_CDC_UNION_TYPE;
+	u32 found =3D 0;
+
+	/*
+	 * assume a data interface has no additional descriptors and
+	 * that the control and data interface are numbered
+	 * consecutively - this holds for the Huawei device at least
+	 */
+	if (len =3D=3D 0 && desc->bInterfaceNumber > 0) {
+		control =3D usb_ifnum_to_if(dev->udev, desc->bInterfaceNumber - 1);
+		if (!control)
+			goto err;
+
+		buf =3D control->cur_altsetting->extra;
+		len =3D control->cur_altsetting->extralen;
+		dev_dbg(&intf->dev, "guessing \"control\" =3D> %s, \"data\" =3D> thi=
s\n",
+			dev_name(&control->dev));
+	}
+
+	while (len > 3) {
+		struct usb_descriptor_header *h =3D (void *)buf;
+
+		/* ignore any misplaced descriptors */
+		if (h->bDescriptorType !=3D USB_DT_CS_INTERFACE)
+			goto next_desc;
+
+		/* buf[2] is CDC descriptor subtype */
+		switch (buf[2]) {
+		case USB_CDC_HEADER_TYPE:
+			if (found & 1 << USB_CDC_HEADER_TYPE) {
+				dev_dbg(&intf->dev, "extra CDC header\n");
+				goto err;
+			}
+			if (h->bLength !=3D sizeof(struct usb_cdc_header_desc)) {
+				dev_dbg(&intf->dev, "CDC header len %u\n", h->bLength);
+				goto err;
+			}
+			break;
+		case USB_CDC_UNION_TYPE:
+			if (found & 1 << USB_CDC_UNION_TYPE) {
+				dev_dbg(&intf->dev, "extra CDC union\n");
+				goto err;
+			}
+			if (h->bLength !=3D sizeof(struct usb_cdc_union_desc)) {
+				dev_dbg(&intf->dev, "CDC union len %u\n", h->bLength);
+				goto err;
+			}
+			cdc_union =3D (struct usb_cdc_union_desc *)buf;
+			break;
+		case USB_CDC_ETHERNET_TYPE:
+			if (found & 1 << USB_CDC_ETHERNET_TYPE) {
+				dev_dbg(&intf->dev, "extra CDC ether\n");
+				goto err;
+			}
+			if (h->bLength !=3D sizeof(struct usb_cdc_ether_desc)) {
+				dev_dbg(&intf->dev, "CDC ether len %u\n",  h->bLength);
+				goto err;
+			}
+			cdc_ether =3D (struct usb_cdc_ether_desc *)buf;
+			break;
+		}
+
+		/*
+		 * Remember which CDC functional descriptors we've seen.  Works
+		 * for all types we care about, of which USB_CDC_ETHERNET_TYPE
+		 * (0x0f) is the highest numbered
+		 */
+		if (buf[2] < 32)
+			found |=3D 1 << buf[2];
+
+next_desc:
+		len -=3D h->bLength;
+		buf +=3D h->bLength;
+	}
+
+	/* did we find all the required ones? */
+	if ((found & required) !=3D required) {
+		dev_err(&intf->dev, "CDC functional descriptors missing\n");
+		goto err;
+	}
+
+	/* give the user a helpful hint if trying to bind to the wrong interf=
ace */
+	if (cdc_union && desc->bInterfaceNumber =3D=3D cdc_union->bMasterInte=
rface0) {
+		dev_err(&intf->dev, "leaving \"control\" interface for " DM_DRIVER "=
 - try binding to %s instead!\n",
+			dev_name(&usb_ifnum_to_if(dev->udev, cdc_union->bSlaveInterface0)->=
dev));
+		goto err;
+	}
+
+	/* errors aren't fatal - we can live with the dynamic address */
+	if (cdc_ether) {
+		dev->hard_mtu =3D le16_to_cpu(cdc_ether->wMaxSegmentSize);
+		usbnet_get_ethernet_addr(dev, cdc_ether->iMACAddress);
+	}
+
+	/* success! point the user to the management interface */
+	if (control)
+		dev_info(&intf->dev, "Use \"" DM_DRIVER "\" for QMI interface %s\n",
+			dev_name(&control->dev));
+
+	/* XXX: add a sysfs symlink somewhere to help management applications=
 find it? */
+
+	/* collect bulk endpoints now that we know intf =3D=3D "data" interfa=
ce */
+	status =3D usbnet_get_endpoints(dev, intf);
+
+err:
+	return status;
+}
+
+/* stolen from cdc_ether.c */
+static int qmi_wwan_manage_power(struct usbnet *dev, int on)
+{
+	dev->intf->needs_remote_wakeup =3D on;
+	return 0;
+}
+
+static const struct driver_info	qmi_wwan_info =3D {
+	.description	=3D "QMI speaking wwan device",
+	.flags		=3D FLAG_WWAN,
+	.bind		=3D qmi_wwan_bind,
+	.manage_power	=3D qmi_wwan_manage_power,
+};
+
+#define HUAWEI_VENDOR_ID	0x12D1
+
+static const struct usb_device_id products[] =3D {
+{
+	/* Huawei E392, E398 and possibly others sharing both device id and m=
ore... */
+	.match_flags        =3D USB_DEVICE_ID_MATCH_VENDOR | USB_DEVICE_ID_MA=
TCH_INT_INFO,
+	.idVendor           =3D HUAWEI_VENDOR_ID,
+	.bInterfaceClass    =3D USB_CLASS_VENDOR_SPEC,
+	.bInterfaceSubClass =3D 1,
+	.bInterfaceProtocol =3D 8, /* NOTE: This is the *slave* interface of =
the CDC Union! */
+	.driver_info        =3D (unsigned long)&qmi_wwan_info,
+}, {
+},	/* END */
+};
+MODULE_DEVICE_TABLE(usb, products);
+
+static struct usb_driver qmi_wwan_driver =3D {
+	.name		      =3D "qmi_wwan",
+	.id_table	      =3D products,
+	.probe		      =3D	usbnet_probe,
+	.disconnect	      =3D usbnet_disconnect,
+	.suspend	      =3D usbnet_suspend,
+	.resume		      =3D	usbnet_resume,
+	.reset_resume         =3D usbnet_resume,
+	.supports_autosuspend =3D 1,
+};
+
+static int __init qmi_wwan_init(void)
+{
+	return usb_register(&qmi_wwan_driver);
+}
+module_init(qmi_wwan_init);
+
+static void __exit qmi_wwan_exit(void)
+{
+	usb_deregister(&qmi_wwan_driver);
+}
+module_exit(qmi_wwan_exit);
+
+MODULE_AUTHOR("Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>");
+MODULE_DESCRIPTION("Qualcomm MSM Interface (QMI) WWAN driver");
+MODULE_LICENSE("GPL");
--=20
1.7.8.3

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
