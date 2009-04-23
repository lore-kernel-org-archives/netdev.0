From: David Woodhouse <dwmw2@infradead.org>
Subject: tun: add IFF_TUN_EXCL flag to avoid opening a persistent device.
Date: Thu, 23 Apr 2009 18:04:18 +0100
Message-ID: <1240506258.15245.11.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:60488 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395AbZDWRE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 13:04:26 -0400
Received: from [158.43.2.102] (helo=[10.250.128.20])
	by bombadil.infradead.org with esmtpsa (Exim 4.69 #1 (Red Hat Linux))
	id 1Lx2LU-0003w7-Uu
	for netdev@vger.kernel.org; Thu, 23 Apr 2009 17:04:21 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When creating a certain types of VPN, NetworkManager will first attempt
to find an available tun device by iterating through 'vpn%d' until it
finds one that isn't already busy. Then it'll set that to be persistent
and owned by the otherwise unprivileged user that the VPN d=C3=A6mon it=
self
runs as.

There's a race condition here -- during the period where the vpn%d
device is created and we're waiting for the VPN d=C3=A6mon to actually
connect and use it, if we try to create _another_ device we could end u=
p
re-using the same one -- because trying to open it again doesn't get
-EBUSY as it would while it's _actually_ busy.

So solve this, we add an IFF_TUN_EXCL flag which causes tun_set_iff() t=
o
fail if it would be opening an existing persistent tundevice -- so that
we can make sure we're getting an entirely _new_ device.

Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 16716ae..0488380 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -867,6 +867,8 @@ static int tun_set_iff(struct net *net, struct file=
 *file, struct ifreq *ifr)
=20
 	dev =3D __dev_get_by_name(net, ifr->ifr_name);
 	if (dev) {
+		if (ifr->ifr_flags & IFF_TUN_EXCL)
+			return -EBUSY;
 		if ((ifr->ifr_flags & IFF_TUN) && dev->netdev_ops =3D=3D &tun_netdev=
_ops)
 			tun =3D netdev_priv(dev);
 		else if ((ifr->ifr_flags & IFF_TAP) && dev->netdev_ops =3D=3D &tap_n=
etdev_ops)
diff --git a/include/linux/if_tun.h b/include/linux/if_tun.h
index 049d6c9..915ba57 100644
--- a/include/linux/if_tun.h
+++ b/include/linux/if_tun.h
@@ -55,6 +55,7 @@
 #define IFF_NO_PI	0x1000
 #define IFF_ONE_QUEUE	0x2000
 #define IFF_VNET_HDR	0x4000
+#define IFF_TUN_EXCL	0x8000
=20
 /* Features for GSO (TUNSETOFFLOAD). */
 #define TUN_F_CSUM	0x01	/* You can hand me unchecksummed packets. */

--=20
David Woodhouse                            Open Source Technology Centr=
e
David.Woodhouse@intel.com                              Intel Corporatio=
n

