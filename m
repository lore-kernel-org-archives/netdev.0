From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net 2/4] rtl8150: Use heap buffers for all register access
Date: Sat, 4 Feb 2017 16:56:32 +0000
Message-ID: <20170204165631.GW3442@decadent.org.uk>
References: <20170204165451.GU3442@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="9I0HVnGRacHebCDW"
Cc: linux-usb@vger.kernel.org, Petko Manolov <petkan@nucleusys.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53597 "EHLO
        shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751299AbdBDQ4d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 11:56:33 -0500
Content-Disposition: inline
In-Reply-To: <20170204165451.GU3442@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--9I0HVnGRacHebCDW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Allocating USB buffers on the stack is not portable, and no longer
works on x86_64 (with VMAP_STACK enabled as per default).

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/usb/rtl8150.c | 34 +++++++++++++++++++++++++++-------
 1 file changed, 27 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index 95b7bd0d7abc..c81c79110cef 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -155,16 +155,36 @@ static const char driver_name [] =3D "rtl8150";
 */
 static int get_registers(rtl8150_t * dev, u16 indx, u16 size, void *data)
 {
-	return usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
-			       RTL8150_REQ_GET_REGS, RTL8150_REQT_READ,
-			       indx, 0, data, size, 500);
+	void *buf;
+	int ret;
+
+	buf =3D kmalloc(size, GFP_NOIO);
+	if (!buf)
+		return -ENOMEM;
+
+	ret =3D usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
+			      RTL8150_REQ_GET_REGS, RTL8150_REQT_READ,
+			      indx, 0, buf, size, 500);
+	if (ret > 0 && ret <=3D size)
+		memcpy(data, buf, ret);
+	kfree(buf);
+	return ret;
 }
=20
-static int set_registers(rtl8150_t * dev, u16 indx, u16 size, void *data)
+static int set_registers(rtl8150_t * dev, u16 indx, u16 size, const void *=
data)
 {
-	return usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
-			       RTL8150_REQ_SET_REGS, RTL8150_REQT_WRITE,
-			       indx, 0, data, size, 500);
+	void *buf;
+	int ret;
+
+	buf =3D kmemdup(data, size, GFP_NOIO);
+	if (!buf)
+		return -ENOMEM;
+
+	ret =3D usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
+			      RTL8150_REQ_SET_REGS, RTL8150_REQT_WRITE,
+			      indx, 0, buf, size, 500);
+	kfree(buf);
+	return ret;
 }
=20
 static void async_set_reg_cb(struct urb *urb)


--9I0HVnGRacHebCDW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBWJYHv+e/yOyVhhEJAQrWuRAAvvqzYnSYRkYt9iHOysbmwV8mgMmALLHd
T7rMhjdhhqfuUdaCIsmU1fX76JxnOkYK80pjHFJDfaCBLf6wyCZARyj7MFyQIZrX
kNLL8j8UMGSzmzb7eQeqnQrvd4jDQZyT/02O2MaCKyrS2RFWtjQKriNqlX9geBSr
pt8rAnobXNendVxuQSPeYTiakKvmyCsgLXUFnUA/r246S/Gj7tmyOl4u819HAnYs
DnSS9HKS0tI/AG7NxtRICUsxT26nZrxWdyXzj/yc6aM77bjIdAhyI5NpL5p2vw//
qVpLTF4BKKisJxO860xuJtG3v7B+YzCFgF/YW+EWu1HYcx1JYMhE9e/sy2ixEuHv
Xe2hnIVIMreLJRxEfOAJm17iUYoLOJ1VX1x6cXipmIsHw9zaV5GByz97R6AQOIDr
jFKFMT5v45bju8SyJHuqjAX4fq7rw4sd6V838VK2d5BbVt345Zw4EpcUc6VrpYOi
UdgGdSOav+oKEmMiVYEG3KFUl0k2t7tWdHkP264tpNklA/5AVXDDX9oQtsBlRV2n
lR5adF5bDljxU8Zu+47771bG56WistjoOfeJFBCKwNsIr9mtlPllAK3jcr7/mJE/
8rd2QQv1RqxOKQXIHC89UbK21sGsE9bn13mj4gtZUGf7VUatzeMixCiP15euICRE
EmfgoAZTcYk=
=m99u
-----END PGP SIGNATURE-----

--9I0HVnGRacHebCDW--
