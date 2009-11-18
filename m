From: "Martin Schiller" <mschiller@tdt.de>
Subject: Patches for hso driver
Date: Wed, 18 Nov 2009 08:35:30 +0100
Message-ID: <DDA9430807DF40968BE983465235D580@mschille2>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_NextPart_000_0007_01CA682A.1640A190"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.tdt.de ([195.243.126.82]:50652 "EHLO ns.tdt.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755859AbZKRIdZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2009 03:33:25 -0500
Received: from ns (root@localhost)
	by ns.tdt.de (8.11.6/8.11.6/SuSE Linux 0.5) with SMTP id nAI7ZkX08056
	for <netdev@vger.kernel.org>; Wed, 18 Nov 2009 08:35:46 +0100
Received: from mschille2 (localhost [127.0.0.1])
	by ns.tdt.de (8.11.6/8.11.6/SuSE Linux 0.5) with ESMTP id nAI7Zjt08049
	for <netdev@vger.kernel.org>; Wed, 18 Nov 2009 08:35:46 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.

------=_NextPart_000_0007_01CA682A.1640A190
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=original
Content-Transfer-Encoding: 7bit

Hi,

I've found some problems in the hso driver for Option HSxPA devices.

The first and most important are 2 memory leaks in the buffer cleanup routines.
Have a look at the "hso-memleak.patch" file to see what I mean.

ATTENTION:
-------------------------------------------------------------------------------------
kmemleak still finds 1 remaining leak, but i can't find it:

unreferenced object 0xce461130 (size 32):
 comm "khubd", pid 1105, jiffies 17464
 backtrace:
   [<c10745b6>] create_object+0xe6/0x210
   [<c10747d7>] kmemleak_alloc+0x27/0x60
   [<c1071b0d>] kmem_cache_alloc+0xcd/0x120
   [<d0ba29a7>] hso_create_net_device+0x207/0x420 [hso]
   [<d0ba30c7>] hso_probe+0x417/0x690 [hso]
   [<d0998103>] usb_probe_interface+0x83/0x170 [usbcore]
   [<c113f9e2>] driver_probe_device+0x62/0x140
   [<c113fb81>] __device_attach+0x41/0x50
   [<c113f098>] bus_for_each_drv+0x48/0x70
   [<c113fc2d>] device_attach+0x6d/0x80
   [<c113eeed>] bus_probe_device+0x1d/0x40
   [<c113da66>] device_add+0x436/0x4f0
   [<d0997654>] usb_set_configuration+0x424/0x5c0 [usbcore]
   [<d099e68e>] generic_probe+0x2e/0xa0 [usbcore]
   [<d09979cf>] usb_probe_device+0x1f/0x30 [usbcore]
   [<c113f9e2>] driver_probe_device+0x62/0x140

Maybe anyone else have an idea for that.
-------------------------------------------------------------------------------------

The second patch "hso-disable_net.patch" stops the useless creation of an serial
ttyHS<x> for the Network Port, when disable_net=1 is set. By that, the order
of the ttyHS<x> is always the same, regardless if disable_net is set or not.

Best Regards,
Martin
------=_NextPart_000_0007_01CA682A.1640A190
Content-Type: application/octet-stream;
	name="hso-memleak.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="hso-memleak.patch"

Subject: memory leak in hso driver=0A=
=0A=
This patches fixes 2 memory leaks in the hso driver.=0A=
The first problem is, that the tx_buffer of a serial device will never =
be freed.=0A=
The second one is, that hso_net is also freed by free_netdev(). So, the =
rx urbs=0A=
and buffers must be freed before free_netdev().=0A=
=0A=
Signed-off-by: Martin Schiller <mschiller@tdt.de>=0A=
=0A=
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c=0A=
index b862e66..6865f3f 100644=0A=
--- a/drivers/net/usb/hso.c=0A=
+++ b/drivers/net/usb/hso.c=0A=
@@ -2312,6 +2312,7 @@ static void hso_serial_common_free(struct =
hso_serial *serial)=0A=
 	/* unlink and free TX URB */=0A=
 	usb_free_urb(serial->tx_urb);=0A=
 	kfree(serial->tx_data);=0A=
+	kfree(serial->tx_buffer);=0A=
 }=0A=
 =0A=
 static int hso_serial_common_create(struct hso_serial *serial, int =
num_urbs,=0A=
@@ -2438,7 +2439,6 @@ static void hso_free_net_device(struct hso_device =
*hso_dev)=0A=
 =0A=
 	if (hso_net->net) {=0A=
 		unregister_netdev(hso_net->net);=0A=
-		free_netdev(hso_net->net);=0A=
 	}=0A=
 =0A=
 	/* start freeing */=0A=
@@ -2451,6 +2451,10 @@ static void hso_free_net_device(struct hso_device =
*hso_dev)=0A=
 	kfree(hso_net->mux_bulk_tx_buf);=0A=
 	hso_net->mux_bulk_tx_buf =3D NULL;=0A=
 =0A=
+	if (hso_net->net) {=0A=
+		free_netdev(hso_net->net);=0A=
+	}=0A=
+=0A=
 	kfree(hso_dev);=0A=
 }=0A=
 =0A=

------=_NextPart_000_0007_01CA682A.1640A190
Content-Type: application/octet-stream;
	name="hso-disable_net.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="hso-disable_net.patch"

Subject: Fix interface order when disabled_net=3D1 in hso driver=0A=
=0A=
This patch stops the useless creation of an serial ttyHS<x> for the=0A=
Network Port, when disable_net=3D1 is set. By that, the order of the=0A=
ttyHS<x> is always the same, regardless if disable_net is set or not.=0A=
=0A=
Signed-off-by: Martin Schiller <mschiller@tdt.de>=0A=
=0A=
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c=0A=
index a11dfd0..e9210b7 100644=0A=
--- a/drivers/net/usb/hso.c=0A=
+++ b/drivers/net/usb/hso.c=0A=
@@ -2993,9 +2993,10 @@ static int hso_probe(struct usb_interface =
*interface,=0A=
 =0A=
 	case HSO_INTF_BULK:=0A=
 		/* It's a regular bulk interface */=0A=
-		if (((port_spec & HSO_PORT_MASK) =3D=3D HSO_PORT_NETWORK)=0A=
-		    && !disable_net)=0A=
+		if ((port_spec & HSO_PORT_MASK) =3D=3D HSO_PORT_NETWORK) {=0A=
+		    if (!disable_net)=0A=
 			hso_dev =3D hso_create_net_device(interface, port_spec);=0A=
+		}=0A=
 		else=0A=
 			hso_dev =3D=0A=
 			    hso_create_bulk_serial_device(interface, port_spec);=0A=

------=_NextPart_000_0007_01CA682A.1640A190--


