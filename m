From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 2/2] NET: cdc-phonet, handle empty phonet header
Date: Sun, 13 Mar 2011 17:54:31 +0100
Message-ID: <1300035271-8138-2-git-send-email-jslaby@suse.cz>
References: <1300035271-8138-1-git-send-email-jslaby@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jirislaby@gmail.com, netdev@vger.kernel.org, gregkh@suse.de,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Slaby <jslaby@suse.cz>,
	=?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1300035271-8138-1-git-send-email-jslaby@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, for N 5800 XM I get:
cdc_phonet: probe of 1-6:1.10 failed with error -22

It's because phonet_header is empty. Extra altsetting looks like
there:
E 05 24 00 01 10 03 24 ab 05 24 06 0a 0b 04 24 fd  .$....$..$....$.
E 00                                               .

I don't see the header used anywhere so just check if the phonet
descriptor is there, not the structure itself.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
Cc: David S. Miller <davem@davemloft.net>
---
 drivers/net/usb/cdc-phonet.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.=
c
index 4cf4e36..f967913 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -328,13 +328,13 @@ int usbpn_probe(struct usb_interface *intf, const=
 struct usb_device_id *id)
 {
 	static const char ifname[] =3D "usbpn%d";
 	const struct usb_cdc_union_desc *union_header =3D NULL;
-	const struct usb_cdc_header_desc *phonet_header =3D NULL;
 	const struct usb_host_interface *data_desc;
 	struct usb_interface *data_intf;
 	struct usb_device *usbdev =3D interface_to_usbdev(intf);
 	struct net_device *dev;
 	struct usbpn_dev *pnd;
 	u8 *data;
+	int phonet =3D 0;
 	int len, err;
=20
 	data =3D intf->altsetting->extra;
@@ -355,10 +355,7 @@ int usbpn_probe(struct usb_interface *intf, const =
struct usb_device_id *id)
 					(struct usb_cdc_union_desc *)data;
 				break;
 			case 0xAB:
-				if (phonet_header || dlen < 5)
-					break;
-				phonet_header =3D
-					(struct usb_cdc_header_desc *)data;
+				phonet =3D 1;
 				break;
 			}
 		}
@@ -366,7 +363,7 @@ int usbpn_probe(struct usb_interface *intf, const s=
truct usb_device_id *id)
 		len -=3D dlen;
 	}
=20
-	if (!union_header || !phonet_header)
+	if (!union_header || !phonet)
 		return -EINVAL;
=20
 	data_intf =3D usb_ifnum_to_if(usbdev, union_header->bSlaveInterface0)=
;
--=20
1.7.4.1
