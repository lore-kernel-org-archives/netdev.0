From: Erik Kline <ek@google.com>
Subject: Re: [PATCH v4 3/7] ipv6 addrconf: rtr_solicits == -1 means unlimited
Date: Mon, 26 Sep 2016 18:23:48 +0900
Message-ID: <CAAedzxq8E8guYP=DK4Uy=c4y1ZSy7Ozn15jYoLNg91TowLgeJQ@mail.gmail.com>
References: <20160925.060423.854801855957024790.davem@davemloft.net>
 <1474801390-6891-1-git-send-email-zenczykowski@gmail.com> <1474801390-6891-4-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Lorenzo Colitti <lorenzo@google.com>
To: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37903 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754994AbcIZJYL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 05:24:11 -0400
Received: by mail-wm0-f53.google.com with SMTP id l132so138364635wmf.1
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 02:24:10 -0700 (PDT)
In-Reply-To: <1474801390-6891-4-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25 September 2016 at 20:03, Maciej =C5=BBenczykowski
<zenczykowski@gmail.com> wrote:
> From: Maciej =C5=BBenczykowski <maze@google.com>
>
> This allows setting /proc/sys/net/ipv6/conf/*/router_solicitations
> to -1 meaning an unlimited number of retransmits.
>
> Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
> ---
>  net/ipv6/addrconf.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 3a835495fb53..6c63bf06fbcf 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3687,7 +3687,7 @@ static void addrconf_rs_timer(unsigned long data)
>         if (idev->if_flags & IF_RA_RCVD)
>                 goto out;
>
> -       if (idev->rs_probes++ < idev->cnf.rtr_solicits) {
> +       if (idev->rs_probes++ < idev->cnf.rtr_solicits || idev->cnf.rtr_s=
olicits =3D=3D -1) {
>                 write_unlock(&idev->lock);
>                 if (!ipv6_get_lladdr(dev, &lladdr, IFA_F_TENTATIVE))
>                         ndisc_send_rs(dev, &lladdr,
> @@ -3949,7 +3949,7 @@ static void addrconf_dad_completed(struct inet6_ifa=
ddr *ifp)
>         send_mld =3D ifp->scope =3D=3D IFA_LINK && ipv6_lonely_lladdr(ifp=
);
>         send_rs =3D send_mld &&
>                   ipv6_accept_ra(ifp->idev) &&
> -                 ifp->idev->cnf.rtr_solicits > 0 &&
> +                 ifp->idev->cnf.rtr_solicits !=3D 0 &&
>                   (dev->flags&IFF_LOOPBACK) =3D=3D 0;
>         read_unlock_bh(&ifp->idev->lock);
>
> @@ -5099,7 +5099,7 @@ static int inet6_set_iftoken(struct inet6_dev *idev=
, struct in6_addr *token)
>                 return -EINVAL;
>         if (!ipv6_accept_ra(idev))
>                 return -EINVAL;
> -       if (idev->cnf.rtr_solicits <=3D 0)
> +       if (idev->cnf.rtr_solicits =3D=3D 0)
>                 return -EINVAL;
>
>         write_lock_bh(&idev->lock);
> @@ -5699,6 +5699,7 @@ int addrconf_sysctl_ignore_routes_with_linkdown(str=
uct ctl_table *ctl,
>         return ret;
>  }
>
> +static int minus_one =3D -1;

Same question from part 2: const as well?

>  static int one =3D 1;
>  static int two_five_five =3D 255;
>
> @@ -5759,7 +5760,8 @@ static const struct ctl_table addrconf_sysctl[] =3D=
 {
>                 .data           =3D &ipv6_devconf.rtr_solicits,
>                 .maxlen         =3D sizeof(int),
>                 .mode           =3D 0644,
> -               .proc_handler   =3D proc_dointvec,
> +               .proc_handler   =3D proc_dointvec_minmax,
> +               .extra1         =3D &minus_one,
>         },
>         {
>                 .procname       =3D "router_solicitation_interval",
> --
> 2.8.0.rc3.226.g39d4020
>
