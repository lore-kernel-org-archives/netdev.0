From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net 1/4] pegasus: Use heap buffers for all register access
Date: Sat, 4 Feb 2017 16:56:03 +0000
Message-ID: <20170204165603.GV3442@decadent.org.uk>
References: <20170204165451.GU3442@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="sr8SBrQ3fbgntwtR"
Cc: linux-usb@vger.kernel.org, Petko Manolov <petkan@nucleusys.com>,
        Lisandro =?iso-8859-1?Q?Dami=E1n_Nicanor_P=E9rez?= Meyer
        <lisandro@debian.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53592 "EHLO
        shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751261AbdBDQ4Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2017 11:56:16 -0500
Content-Disposition: inline
In-Reply-To: <20170204165451.GU3442@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--sr8SBrQ3fbgntwtR
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Allocating USB buffers on the stack is not portable, and no longer
works on x86_64 (with VMAP_STACK enabled as per default).

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
References: https://bugs.debian.org/852556
Reported-by: Lisandro Dami=E1n Nicanor P=E9rez Meyer <lisandro@debian.org>
Tested-by: Lisandro Dami=E1n Nicanor P=E9rez Meyer <lisandro@debian.org>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/usb/pegasus.c | 29 +++++++++++++++++++++++++----
 1 file changed, 25 insertions(+), 4 deletions(-)

diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 24e803fe9a53..36674484c6fb 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -126,40 +126,61 @@ static void async_ctrl_callback(struct urb *urb)
=20
 static int get_registers(pegasus_t *pegasus, __u16 indx, __u16 size, void =
*data)
 {
+	u8 *buf;
 	int ret;
=20
+	buf =3D kmalloc(size, GFP_NOIO);
+	if (!buf)
+		return -ENOMEM;
+
 	ret =3D usb_control_msg(pegasus->usb, usb_rcvctrlpipe(pegasus->usb, 0),
 			      PEGASUS_REQ_GET_REGS, PEGASUS_REQT_READ, 0,
-			      indx, data, size, 1000);
+			      indx, buf, size, 1000);
 	if (ret < 0)
 		netif_dbg(pegasus, drv, pegasus->net,
 			  "%s returned %d\n", __func__, ret);
+	else if (ret <=3D size)
+		memcpy(data, buf, ret);
+	kfree(buf);
 	return ret;
 }
=20
-static int set_registers(pegasus_t *pegasus, __u16 indx, __u16 size, void =
*data)
+static int set_registers(pegasus_t *pegasus, __u16 indx, __u16 size,
+			 const void *data)
 {
+	u8 *buf;
 	int ret;
=20
+	buf =3D kmemdup(data, size, GFP_NOIO);
+	if (!buf)
+		return -ENOMEM;
+
 	ret =3D usb_control_msg(pegasus->usb, usb_sndctrlpipe(pegasus->usb, 0),
 			      PEGASUS_REQ_SET_REGS, PEGASUS_REQT_WRITE, 0,
-			      indx, data, size, 100);
+			      indx, buf, size, 100);
 	if (ret < 0)
 		netif_dbg(pegasus, drv, pegasus->net,
 			  "%s returned %d\n", __func__, ret);
+	kfree(buf);
 	return ret;
 }
=20
 static int set_register(pegasus_t *pegasus, __u16 indx, __u8 data)
 {
+	u8 *buf;
 	int ret;
=20
+	buf =3D kmemdup(&data, 1, GFP_NOIO);
+	if (!buf)
+		return -ENOMEM;
+
 	ret =3D usb_control_msg(pegasus->usb, usb_sndctrlpipe(pegasus->usb, 0),
 			      PEGASUS_REQ_SET_REG, PEGASUS_REQT_WRITE, data,
-			      indx, &data, 1, 1000);
+			      indx, buf, 1, 1000);
 	if (ret < 0)
 		netif_dbg(pegasus, drv, pegasus->net,
 			  "%s returned %d\n", __func__, ret);
+	kfree(buf);
 	return ret;
 }
=20


--sr8SBrQ3fbgntwtR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBWJYHo+e/yOyVhhEJAQo7vA//W4HMu4rND1+212MIJ0/jGev+rr9Y49RZ
UyjPqrUhzaBwrXWlKJvbwvUKf+IvbxpTjJAXiGC5w5M0vGChfkZ/7zTcE9otc+zB
sbE7H87NDXDxi4ABt8EeuyjbTATenz/GRK5fP9EkAD95iGCaBH9x2bpt/MJ364y4
Sy28SS4Pj4yHnV0202dhUT7SK1xext58NiUHgmymLrcJuAD7p2XzTjTJpGPxkdNc
PM1fCNtAlE2zKGv2aH/BbdqiRR6ea/zLx3tgu0cAYMDcsWSHFcO6333h+ahbo7yJ
TbF6FFyezc5P2tvyiIuDKYox7nuSnckZoK9oxGb2J7aYtUc9cc5DDSXnJ3x6VXx4
rnsnRoMBXp3tYMI8rq9+rYFw8BWlAHIp6QR/NxBdCnNkUG5VZVKmwnzQJbUhxvKN
4p0z7P/7/GhjWU0BLJJiwde+F/7ShMLzjrRM8WMAykT6VGgOUKIwqOZpKOWqw716
Wjm/7W34k6REh4oaPSUcTBgsw+jL4yccBIivKM6FsGyfaItzgp0TEfUEfVUMaPAf
C7o+hC2PUTsOX/2C5R322NagsCydGZHs2IkPwx+VgtIC3fMQod2LAicGby3mBQi5
+N1NzZWkzTxcxyqmPXsc0KuReqTAeQ6jT41fE4F2C9L1kIeRPFUy8DO0UVb3AVL8
7iviorKmr5g=
=ZWHF
-----END PGP SIGNATURE-----

--sr8SBrQ3fbgntwtR--
