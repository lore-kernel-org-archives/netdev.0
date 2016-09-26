From: Erik Kline <ek@google.com>
Subject: Re: [PATCH v4 4/7] ipv6 addrconf: add new sysctl 'router_solicitation_max_interval'
Date: Mon, 26 Sep 2016 18:29:01 +0900
Message-ID: <CAAedzxqxZO=SOefYyTe8y_f2Tw2_d9tfMWW=5a7PfGqd6cYLGw@mail.gmail.com>
References: <20160925.060423.854801855957024790.davem@davemloft.net>
 <1474801390-6891-1-git-send-email-zenczykowski@gmail.com> <1474801390-6891-5-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Lorenzo Colitti <lorenzo@google.com>
To: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:33983 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1761370AbcIZJ3X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 05:29:23 -0400
Received: by mail-wm0-f48.google.com with SMTP id 197so22718431wmk.1
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 02:29:23 -0700 (PDT)
In-Reply-To: <1474801390-6891-5-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25 September 2016 at 20:03, Maciej =C5=BBenczykowski
<zenczykowski@gmail.com> wrote:
> From: Maciej =C5=BBenczykowski <maze@google.com>
>
> Accessible via:
>   /proc/sys/net/ipv6/conf/*/router_solicitation_max_interval
>
> For now we default it to the same value as the normal interval.
>
> Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
> ---
>  include/linux/ipv6.h      |  1 +
>  include/net/addrconf.h    |  1 +
>  include/uapi/linux/ipv6.h |  1 +
>  net/ipv6/addrconf.c       | 11 +++++++++++
>  4 files changed, 14 insertions(+)
>
> diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> index c6dbcd84a2c7..7e9a789be5e0 100644
> --- a/include/linux/ipv6.h
> +++ b/include/linux/ipv6.h
> @@ -18,6 +18,7 @@ struct ipv6_devconf {
>         __s32           dad_transmits;
>         __s32           rtr_solicits;
>         __s32           rtr_solicit_interval;
> +       __s32           rtr_solicit_max_interval;
>         __s32           rtr_solicit_delay;
>         __s32           force_mld_version;
>         __s32           mldv1_unsolicited_report_interval;
> diff --git a/include/net/addrconf.h b/include/net/addrconf.h
> index 9826d3a9464c..275e5af4c2f4 100644
> --- a/include/net/addrconf.h
> +++ b/include/net/addrconf.h
> @@ -3,6 +3,7 @@
>
>  #define MAX_RTR_SOLICITATIONS          3
>  #define RTR_SOLICITATION_INTERVAL      (4*HZ)
> +#define RTR_SOLICITATION_MAX_INTERVAL  (4*HZ)
>
>  #define MIN_VALID_LIFETIME             (2*3600)        /* 2 hours */
>
> diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
> index 395876060f50..8c2772340c3f 100644
> --- a/include/uapi/linux/ipv6.h
> +++ b/include/uapi/linux/ipv6.h
> @@ -177,6 +177,7 @@ enum {
>         DEVCONF_DROP_UNICAST_IN_L2_MULTICAST,
>         DEVCONF_DROP_UNSOLICITED_NA,
>         DEVCONF_KEEP_ADDR_ON_DOWN,
> +       DEVCONF_RTR_SOLICIT_MAX_INTERVAL,
>         DEVCONF_MAX
>  };
>
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 6c63bf06fbcf..255be34cdbce 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -187,6 +187,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly=
 =3D {
>         .dad_transmits          =3D 1,
>         .rtr_solicits           =3D MAX_RTR_SOLICITATIONS,
>         .rtr_solicit_interval   =3D RTR_SOLICITATION_INTERVAL,
> +       .rtr_solicit_max_interval =3D RTR_SOLICITATION_MAX_INTERVAL,
>         .rtr_solicit_delay      =3D MAX_RTR_SOLICITATION_DELAY,
>         .use_tempaddr           =3D 0,
>         .temp_valid_lft         =3D TEMP_VALID_LIFETIME,
> @@ -232,6 +233,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_m=
ostly =3D {
>         .dad_transmits          =3D 1,
>         .rtr_solicits           =3D MAX_RTR_SOLICITATIONS,
>         .rtr_solicit_interval   =3D RTR_SOLICITATION_INTERVAL,
> +       .rtr_solicit_max_interval =3D RTR_SOLICITATION_MAX_INTERVAL,
>         .rtr_solicit_delay      =3D MAX_RTR_SOLICITATION_DELAY,
>         .use_tempaddr           =3D 0,
>         .temp_valid_lft         =3D TEMP_VALID_LIFETIME,
> @@ -4891,6 +4893,8 @@ static inline void ipv6_store_devconf(struct ipv6_d=
evconf *cnf,
>         array[DEVCONF_RTR_SOLICITS] =3D cnf->rtr_solicits;
>         array[DEVCONF_RTR_SOLICIT_INTERVAL] =3D
>                 jiffies_to_msecs(cnf->rtr_solicit_interval);
> +       array[DEVCONF_RTR_SOLICIT_MAX_INTERVAL] =3D
> +               jiffies_to_msecs(cnf->rtr_solicit_max_interval);
>         array[DEVCONF_RTR_SOLICIT_DELAY] =3D
>                 jiffies_to_msecs(cnf->rtr_solicit_delay);
>         array[DEVCONF_FORCE_MLD_VERSION] =3D cnf->force_mld_version;
> @@ -5771,6 +5775,13 @@ static const struct ctl_table addrconf_sysctl[] =
=3D {
>                 .proc_handler   =3D proc_dointvec_jiffies,
>         },
>         {
> +               .procname       =3D "router_solicitation_max_interval",
> +               .data           =3D &ipv6_devconf.rtr_solicit_max_interva=
l,
> +               .maxlen         =3D sizeof(int),
> +               .mode           =3D 0644,
> +               .proc_handler   =3D proc_dointvec_jiffies,
> +       },
> +       {
>                 .procname       =3D "router_solicitation_delay",
>                 .data           =3D &ipv6_devconf.rtr_solicit_delay,
>                 .maxlen         =3D sizeof(int),
> --
> 2.8.0.rc3.226.g39d4020
>

Acked-by: Erik Kline <ek@google.com>
