From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: Regression on TX throughput when using bonding
Date: Thu, 14 Jun 2012 12:15:37 +0200
Message-ID: <CAL8zT=icffEiz9MeaNwMtzteQnXiaT4k++s0TPWt5zsnHxFbmw@mail.gmail.com>
References: <CAL8zT=j8pEVc7AHwJzk+4skj=1tfRYZ_C7CuXD_08T_VmkwoFg@mail.gmail.com>
 <1339665719.22704.692.camel@edumazet-glaptop> <1339667417.22704.707.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:34968 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755632Ab2FNKP6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 06:15:58 -0400
Received: by wibhn6 with SMTP id hn6so1742729wib.1
        for <netdev@vger.kernel.org>; Thu, 14 Jun 2012 03:15:57 -0700 (PDT)
In-Reply-To: <1339667417.22704.707.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/6/14 Eric Dumazet <eric.dumazet@gmail.com>:
> On Thu, 2012-06-14 at 11:22 +0200, Eric Dumazet wrote:
>
>> So you are saying that if you make skb_orphan_try() doing nothing, i=
t
>> solves your problem ?
>
> It probably does, if your application does an UDP flood, trying to se=
nd
> more than the link bandwidth. I guess only benchmarks workloads ever =
try
> to do that.
>
> bonding has no way to give congestion back, it has no Qdisc by defaul=
t.
>
> We probably can defer the skb_orphan_try() for bonding master, a bit
> like the IFF_XMIT_DST_RELEASE
>
> =C2=A0drivers/net/bonding/bond_main.c | =C2=A0 =C2=A02 +-
> =C2=A0include/linux/if.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0| =C2=A0 =C2=A03 +++
> =C2=A0net/core/dev.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0| =C2=A0 =C2=A05 +++--
> =C2=A03 files changed, 7 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 2ee8cf9..1b1e9c8 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -4343,7 +4343,7 @@ static void bond_setup(struct net_device *bond_=
dev)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0bond_dev->tx_queue_len =3D 0;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0bond_dev->flags |=3D IFF_MASTER|IFF_MULTIC=
AST;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0bond_dev->priv_flags |=3D IFF_BONDING;
> - =C2=A0 =C2=A0 =C2=A0 bond_dev->priv_flags &=3D ~(IFF_XMIT_DST_RELEA=
SE | IFF_TX_SKB_SHARING);
> + =C2=A0 =C2=A0 =C2=A0 bond_dev->priv_flags &=3D ~(IFF_XMIT_DST_RELEA=
SE | IFF_TX_SKB_SHARING | IFF_XMIT_ORPHAN);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* At first, we block adding VLANs. That's=
 the only way to
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * prevent problems that occur when adding=
 VLANs over an
> diff --git a/include/linux/if.h b/include/linux/if.h
> index f995c66..a788e7b 100644
> --- a/include/linux/if.h
> +++ b/include/linux/if.h
> @@ -81,6 +81,9 @@
> =C2=A0#define IFF_UNICAST_FLT =C2=A0 =C2=A0 =C2=A0 =C2=A00x20000 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 /* Supports unicast filtering =C2=A0 */
> =C2=A0#define IFF_TEAM_PORT =C2=A00x40000 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 /* device used as team port */
> =C2=A0#define IFF_SUPP_NOFCS 0x80000 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* d=
evice supports sending custom FCS */
> +#define IFF_XMIT_ORPHAN =C2=A0 =C2=A0 =C2=A0 =C2=A00x100000 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0/* dev_hard_start_xmit() is allowed to
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*=
 orphan skb
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*=
/
>
>
> =C2=A0#define IF_GET_IFACE =C2=A0 0x0001 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0/* for querying only */
> diff --git a/net/core/dev.c b/net/core/dev.c
> index cd09819..3435463 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2193,7 +2193,8 @@ int dev_hard_start_xmit(struct sk_buff *skb, st=
ruct net_device *dev,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!list_empt=
y(&ptype_all))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0dev_queue_xmit_nit(skb, dev);
>
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 skb_orphan_try(skb=
);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (dev->priv_flag=
s & IFF_XMIT_ORPHAN)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 skb_orphan_try(skb);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0features =3D n=
etif_skb_features(skb);
>
> @@ -5929,7 +5930,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_=
priv, const char *name,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_LIST_HEAD(&dev->napi_list);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_LIST_HEAD(&dev->unreg_list);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_LIST_HEAD(&dev->link_watch_list);
> - =C2=A0 =C2=A0 =C2=A0 dev->priv_flags =3D IFF_XMIT_DST_RELEASE;
> + =C2=A0 =C2=A0 =C2=A0 dev->priv_flags =3D IFF_XMIT_DST_RELEASE | IFF=
_XMIT_ORPHAN;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0setup(dev);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0dev->num_tx_queues =3D txqs;
>
>

It works
