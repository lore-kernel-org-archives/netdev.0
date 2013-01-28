From: Jason Wang <jasowang@redhat.com>
Subject: Re: How to find an unused TAP device with kernel 3.8 ?
Date: Mon, 28 Jan 2013 17:38:24 +0800
Message-ID: <3592886.xagLc7Uij9@jason-thinkpad-t430s>
References: <5103B01D.5070303@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
To: Toralf =?ISO-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5103B01D.5070303@gmx.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday, January 26, 2013 11:29:49 AM Toralf F=F6rster wrote:
> With kernel 3.8. I just realized that all pre-defined TAP devices are
> RUNNING even if no virtual linux system is using it. Now I'm wonderin=
g
> whether this is a new feature of the upcoming kernel, a bug of the ol=
d -
> and how I can avoid that.
>=20
> Background : When I start a user mode linux instance, I currently gre=
p
> for the next free tap device in this way :
>=20
> Code:
> for t in $(ifconfig | grep "^tap" | cut -f1 -d:)
> do
>    ethtool $t | grep -q 'Link detected: no'
>    if [[ $? -eq 0 ]]; then
>       NET=3D"tuntap,$t"
>       break
>    fi
> done
>=20
> but this doesn't work now anymore.
>=20
> Here is the diff in dmesg
>=20
> $ diff 3.7.1 3.8.0-rc1+ | grep UP
>=20
> < br0: flags=3D4355<UP,BROADCAST,PROMISC,MULTICAST>  mtu 1500
>=20
> > br0: flags=3D4419<UP,BROADCAST,RUNNING,PROMISC,MULTICAST>  mtu 1500
>=20
> < tap0: flags=3D4099<UP,BROADCAST,MULTICAST>  mtu 1500
>=20
> > tap0: flags=3D4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
>=20
> more details : http://forums.gentoo.org/viewtopic-p-7211498.html#7211=
498

Looks like something wrong with the carrier detection of tap.

Please try the following patch to see if it helps.

Thanks.

diff --git a/drivers/net/tun.c b/drivers/net/tun.c                     =
                                                                       =
                           =20
index cc09b67..d8a53c3 100644                                          =
                                                                       =
                           =20
--- a/drivers/net/tun.c                                                =
                                                                       =
                           =20
+++ b/drivers/net/tun.c                                                =
                                                                       =
                           =20
@@ -438,6 +438,9 @@ static void __tun_detach(struct tun_file *tfile, bo=
ol clean)
                sock_put(&tfile->sk);                                  =
                                                                       =
                           =20
        }                                                              =
                                                                       =
                           =20
                                                                       =
                                                                       =
                           =20
+       if (tun && tun->numqueues =3D=3D 0)                            =
                                                                       =
                               =20
+               netif_carrier_off(tun->dev);                           =
                                                                       =
                           =20
+                                                                      =
                                                                       =
                           =20
        if (clean) {                                                   =
                                                                       =
                           =20
                if (tun && tun->numqueues =3D=3D 0 && tun->numdisabled =
=3D=3D 0 &&                                                            =
                                   =20
                    !(tun->flags & TUN_PERSIST))                       =
                                                                       =
                           =20
@@ -473,6 +476,7 @@ static void tun_detach_all(struct net_device *dev)
        BUG_ON(tun->numqueues !=3D 0);                                 =
                                                                       =
                             =20
                                                                       =
                                                                       =
                           =20
        synchronize_net();                                             =
                                                                       =
                           =20
+       netif_carrier_off(dev);                                        =
                                                                       =
                           =20
        for (i =3D 0; i < n; i++) {                                    =
                                                                       =
                             =20
                tfile =3D rtnl_dereference(tun->tfiles[i]);            =
                                                                       =
                             =20
                /* Drop read queue */                                  =
                                                                       =
                           =20
@@ -531,6 +535,7 @@ static int tun_attach(struct tun_struct *tun, struc=
t file *file)
                sock_hold(&tfile->sk);                                 =
                                                                       =
                           =20
                                                                       =
                                                                       =
                           =20
        tun_set_real_num_queues(tun);                                  =
                                                                       =
                           =20
+       netif_carrier_on(tun->dev);                                    =
                                                                       =
                           =20
                                                                       =
                                                                       =
                           =20
        /* device is allowed to go away first, so no need to hold extra=
                                                                       =
                           =20
         * refcnt.                                                     =
                                                                       =
                           =20
--                                                                     =
                                                                       =
                           =20
1.7.1 =20
