From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: Re: [PATCH 2.5.70] e100 initialize fields prior to register_netdevice
Date: Thu, 29 May 2003 16:48:51 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0305291643550.23177-100000@localhost.localdomain>
References: <C6F5CF431189FA4CBAEC9E7DD5441E0101BE5F5E@orsmsx402.jf.intel.com>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Stephen Hemminger <shemminger@osdl.org>,
   "David S. Miller" <davem@redhat.com>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <C6F5CF431189FA4CBAEC9E7DD5441E0101BE5F5E@orsmsx402.jf.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 29 May 2003, Jeff Garzik wrote:

>=20
> Stephen Hemminger wrote:
[cut]
> > This patch moves the initialization earlier before registration.=A0 I=
t
> > probably closes other races as well, where some program could access=20
> > the e100 driver before the pointers were setup.
>=20
>=20
> Agreed.=A0 I consider this a rather serious bug, that could cause crash=
es
> in multiple corner cases; sysfs being only one of those cases.
>=20
> I'm going to go ahead and apply this to 2.5.
>=20
> Stephen, could I get you to send me a similar patch for 2.4?
> (it doesn't apply cleanly)=A0 It's very much a bug in 2.4 also.
>=20
> =A0=A0=A0=A0=A0=A0=A0 Jeff

Wait!  More work is required, otherwise VLANs, checksum offloading and SG
support are broken.  Here's a patch that applies on top of Stephen's to
address this.  USE_IPCB needs to be defined before filling out
netdev->features.

Again, not an issue for 2.4 e100 driver.

-scott

--- linux-2.5.70/drivers/net/e100/e100_main.c.orig	2003-05-29 16:40:00.00=
0000000 -0700
+++ linux-2.5.70/drivers/net/e100/e100_main.c	2003-05-29 16:40:27.0000000=
00 -0700
@@ -614,26 +614,6 @@
 		goto err_dealloc;
 	}
=20
-	dev->vlan_rx_register =3D e100_vlan_rx_register;
-	dev->vlan_rx_add_vid =3D e100_vlan_rx_add_vid;
-	dev->vlan_rx_kill_vid =3D e100_vlan_rx_kill_vid;
-	dev->irq =3D pcid->irq;
-	dev->open =3D &e100_open;
-	dev->hard_start_xmit =3D &e100_xmit_frame;
-	dev->stop =3D &e100_close;
-	dev->change_mtu =3D &e100_change_mtu;
-	dev->get_stats =3D &e100_get_stats;
-	dev->set_multicast_list =3D &e100_set_multi;
-	dev->set_mac_address =3D &e100_set_mac;
-	dev->do_ioctl =3D &e100_ioctl;
-	if (bdp->flags & USE_IPCB)
-		dev->features =3D NETIF_F_SG | NETIF_F_HW_CSUM |
-				NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
-
-	if ((rc =3D register_netdev(dev)) !=3D 0) {
-		goto err_pci;
-	}
-
 	if (((bdp->pdev->device > 0x1030)
 	       && (bdp->pdev->device < 0x103F))
 	    || ((bdp->pdev->device >=3D 0x1050)
@@ -657,6 +637,27 @@
 	} else {
 		bdp->rfd_size =3D 16;
 	}
+
+	dev->vlan_rx_register =3D e100_vlan_rx_register;
+	dev->vlan_rx_add_vid =3D e100_vlan_rx_add_vid;
+	dev->vlan_rx_kill_vid =3D e100_vlan_rx_kill_vid;
+	dev->irq =3D pcid->irq;
+	dev->open =3D &e100_open;
+	dev->hard_start_xmit =3D &e100_xmit_frame;
+	dev->stop =3D &e100_close;
+	dev->change_mtu =3D &e100_change_mtu;
+	dev->get_stats =3D &e100_get_stats;
+	dev->set_multicast_list =3D &e100_set_multi;
+	dev->set_mac_address =3D &e100_set_mac;
+	dev->do_ioctl =3D &e100_ioctl;
+	if (bdp->flags & USE_IPCB)
+		dev->features =3D NETIF_F_SG | NETIF_F_HW_CSUM |
+				NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+
+	if ((rc =3D register_netdev(dev)) !=3D 0) {
+		goto err_pci;
+	}
+
 	e100_check_options(e100nics, bdp);
=20
 	if (!e100_init(bdp)) {
