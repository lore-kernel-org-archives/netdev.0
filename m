From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH] tun: fix carrier on/off status
Date: Mon, 28 Jan 2013 12:11:11 +0200
Message-ID: <20130128101111.GB5337@redhat.com>
References: <5103B01D.5070303@gmx.de>
 <3592886.xagLc7Uij9@jason-thinkpad-t430s>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>,
	netdev@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62402 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754205Ab3A1KHF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 05:07:05 -0500
Content-Disposition: inline
In-Reply-To: <3592886.xagLc7Uij9@jason-thinkpad-t430s>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit c8d68e6be1c3b242f1c598595830890b65cea64a removed carrier off cal=
l
from tun_detach since it's now called on queue disable and not only on
tun close.  This confuses userspace which used this flag to detect a
free tun. To fix, move on/off calls to setiff/close respectively.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

---

On Mon, Jan 28, 2013 at 05:38:24PM +0800, Jason Wang wrote:
> On Saturday, January 26, 2013 11:29:49 AM Toralf F=F6rster wrote:
> > Re: How to find an unused TAP device with kernel 3.8 ?
> > With kernel 3.8. I just realized that all pre-defined TAP devices a=
re
> > RUNNING even if no virtual linux system is using it. Now I'm wonder=
ing
> > whether this is a new feature of the upcoming kernel, a bug of the =
old -
> > and how I can avoid that.
> >=20
> > Background : When I start a user mode linux instance, I currently g=
rep
> > for the next free tap device in this way :
> >=20
> > Code:
> > for t in $(ifconfig | grep "^tap" | cut -f1 -d:)
> > do
> >    ethtool $t | grep -q 'Link detected: no'
> >    if [[ $? -eq 0 ]]; then
> >       NET=3D"tuntap,$t"
> >       break
> >    fi
> > done
> >=20
> > but this doesn't work now anymore.
> >=20
> > Here is the diff in dmesg
> >=20
> > $ diff 3.7.1 3.8.0-rc1+ | grep UP
> >=20
> > < br0: flags=3D4355<UP,BROADCAST,PROMISC,MULTICAST>  mtu 1500
> >=20
> > > br0: flags=3D4419<UP,BROADCAST,RUNNING,PROMISC,MULTICAST>  mtu 15=
00
> >=20
> > < tap0: flags=3D4099<UP,BROADCAST,MULTICAST>  mtu 1500
> >=20
> > > tap0: flags=3D4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
> >=20
> > more details : http://forums.gentoo.org/viewtopic-p-7211498.html#72=
11498
>=20
> Looks like something wrong with the carrier detection of tap.
>=20
> Please try the following patch to see if it helps.
>=20
> Thanks.
>=20
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c                   =
                                                                       =
                             =20
> index cc09b67..d8a53c3 100644                                        =
                                                                       =
                             =20
> --- a/drivers/net/tun.c                                              =
                                                                       =
                             =20
> +++ b/drivers/net/tun.c                                              =
                                                                       =
                             =20
> @@ -438,6 +438,9 @@ static void __tun_detach(struct tun_file *tfile, =
bool clean)
>                 sock_put(&tfile->sk);                                =
                                                                       =
                             =20
>         }                                                            =
                                                                       =
                             =20
>                                                                      =
                                                                       =
                             =20
> +       if (tun && tun->numqueues =3D=3D 0)                          =
                                                                       =
                                 =20
> +               netif_carrier_off(tun->dev);                         =
                                                                       =
                             =20
> +                                                                    =
                                                                       =
                             =20
>         if (clean) {                                                 =
                                                                       =
                             =20
>                 if (tun && tun->numqueues =3D=3D 0 && tun->numdisable=
d =3D=3D 0 &&                                                          =
                                     =20
>                     !(tun->flags & TUN_PERSIST))                     =
                                                                       =
                             =20
> @@ -473,6 +476,7 @@ static void tun_detach_all(struct net_device *dev=
)
>         BUG_ON(tun->numqueues !=3D 0);                               =
                                                                       =
                               =20
>                                                                      =
                                                                       =
                             =20
>         synchronize_net();                                           =
                                                                       =
                             =20
> +       netif_carrier_off(dev);                                      =
                                                                       =
                             =20
>         for (i =3D 0; i < n; i++) {                                  =
                                                                       =
                               =20
>                 tfile =3D rtnl_dereference(tun->tfiles[i]);          =
                                                                       =
                               =20
>                 /* Drop read queue */                                =
                                                                       =
                             =20
> @@ -531,6 +535,7 @@ static int tun_attach(struct tun_struct *tun, str=
uct file *file)
>                 sock_hold(&tfile->sk);                               =
                                                                       =
                             =20
>                                                                      =
                                                                       =
                             =20
>         tun_set_real_num_queues(tun);                                =
                                                                       =
                             =20
> +       netif_carrier_on(tun->dev);                                  =
                                                                       =
                             =20
>                                                                      =
                                                                       =
                             =20
>         /* device is allowed to go away first, so no need to hold ext=
ra                                                                     =
                             =20
>          * refcnt.                                                   =
                                                                       =
                             =20
This will set carrier off if all queues are disabled, which I think is =
a
problem as it would confuse the script. How about the following instead=
:

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index af372d0..00dfdad 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1644,10 +1644,10 @@ static int tun_set_iff(struct net *net, struct =
file *file, struct ifreq *ifr)
 		    device_create_file(&tun->dev->dev, &dev_attr_owner) ||
 		    device_create_file(&tun->dev->dev, &dev_attr_group))
 			pr_err("Failed to create tun sysfs files\n");
-
-		netif_carrier_on(tun->dev);
 	}
=20
+	netif_carrier_on(tun->dev);
+
 	tun_debug(KERN_INFO, tun, "tun_set_iff\n");
=20
 	if (ifr->ifr_flags & IFF_NO_PI)
@@ -2124,6 +2124,8 @@ static int tun_chr_close(struct inode *inode, str=
uct file *file)
 	struct tun_file *tfile =3D file->private_data;
 	struct net *net =3D tfile->net;
=20
+	netif_carrier_off(tun->dev);
+
 	tun_detach(tfile, true);
 	put_net(net);
=20


--=20
MST
