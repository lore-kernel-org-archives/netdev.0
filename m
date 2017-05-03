From: "Gao Feng" <gfree.wind@foxmail.com>
Subject: RE: [PATCH net v3] driver: veth: Fix one possbile memleak when fail to register_netdevice
Date: Wed, 3 May 2017 10:07:36 +0800
Message-ID: <000c01d2c3b2$0925e880$1b71b980$@foxmail.com>
References: <1493437911-27167-1-git-send-email-gfree.wind@foxmail.com> <CADvbK_cEHXTSXx5Qa17TfeUXnYiBq8ptR+=5e-fbzPF0r4DNhQ@mail.gmail.com> <000601d2c333$abb526d0$031f7470$@vip.163.com> <CADvbK_cVS=M3tuz0QQT18D32UzLkdL0RMHuFxqcBgtfq_w7+9Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "'davem'" <davem@davemloft.net>, <jarod@redhat.com>,
        "'Stephen Hemminger'" <stephen@networkplumber.org>,
        <dsa@cumulusnetworks.com>, "'network dev'" <netdev@vger.kernel.org>
To: "'Xin Long'" <lucien.xin@gmail.com>,
        "'Gao Feng'" <gfree.wind@vip.163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg298.qq.com ([184.105.67.102]:59395 "EHLO smtpbg298.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751118AbdECCHy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 22:07:54 -0400
In-Reply-To: <CADvbK_cVS=M3tuz0QQT18D32UzLkdL0RMHuFxqcBgtfq_w7+9Q@mail.gmail.com>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: netdev-owner@vger.kernel.org =
[mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Xin Long
> Sent: Wednesday, May 3, 2017 12:59 AM
> On Tue, May 2, 2017 at 7:03 PM, Gao Feng <gfree.wind@vip.163.com> =
wrote:
> >> From: Xin Long [mailto:lucien.xin@gmail.com]
> >> Sent: Tuesday, May 2, 2017 3:56 PM
> >> On Sat, Apr 29, 2017 at 11:51 AM,  <gfree.wind@foxmail.com> wrote:
> >> > From: Gao Feng <gfree.wind@foxmail.com>
> > [...]
> >> > -static void veth_dev_free(struct net_device *dev)
> >> > +static void veth_destructor_free(struct net_device *dev)
> >> >  {
> >> >         free_percpu(dev->vstats);
> >> > +}
> >> not sure why you needed to add this function.
> >> to use free_percpu() directly may be clearer.
> >
> > Because both of ndo_uninit and destructor need to perform same free
> statements.
> > It is good at maintain the codes with the common function.
> >>
> >> > +
> >> > +static void veth_dev_uninit(struct net_device *dev) {
> >> call free_percpu() here, no need to check dev->reg_state.
> >> free_percpu will just return if dev->vstats is NULL.
> >
> > It would break the original design if don't check the reg_state.
> > The original logic is that free the resources in the destructor, not =
in ndo_init.
> I got what you're doing now, can you pls try to fix this with:
>=20
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -219,10 +219,9 @@ static int veth_dev_init(struct net_device *dev)
>         return 0;
>  }
>=20
> -static void veth_dev_free(struct net_device *dev)
> +static void veth_dev_uninit(struct net_device *dev)
>  {
>         free_percpu(dev->vstats);
> -       free_netdev(dev);
>  }
>=20
>  #ifdef CONFIG_NET_POLL_CONTROLLER
> @@ -279,6 +278,7 @@ static void veth_set_rx_headroom(struct net_device
> *dev, int new_hr)
>=20
>  static const struct net_device_ops veth_netdev_ops =3D {
>         .ndo_init            =3D veth_dev_init,
> +       .ndo_uninit          =3D veth_dev_uninit,
>         .ndo_open            =3D veth_open,
>         .ndo_stop            =3D veth_close,
>         .ndo_start_xmit      =3D veth_xmit,
> @@ -317,7 +317,7 @@ static void veth_setup(struct net_device *dev)
>                                NETIF_F_HW_VLAN_STAG_TX |
>                                NETIF_F_HW_VLAN_CTAG_RX |
>                                NETIF_F_HW_VLAN_STAG_RX);
> -       dev->destructor =3D veth_dev_free;
> +       dev->destructor =3D free_netdev;
>         dev->max_mtu =3D ETH_MAX_MTU;
>=20
>         dev->hw_features =3D VETH_FEATURES;
>=20
>=20
> just as what other virtual nic drivers do (vxlan, geneve, macsec, =
bridge ....)
>=20

The fix you mentioned change the original logic.
The dev->vstats is freed in advance in the ndo_uninit, not destructor.
It may break the backward.

Regards
Feng
