From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6 addrconf: implement RFC7559 router solicitation backoff
Date: Wed, 28 Sep 2016 09:42:49 +0200
Message-ID: <1475048569.3276913.739336609.4398C277@webmail.messagingengine.com>
References: <1475045878-30455-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, Erik Kline <ek@google.com>,
        Lorenzo Colitti <lorenzo@google.com>,
        Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
To: =?UTF-8?Q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>,
        =?UTF-8?Q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:56123 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751021AbcI1Hmu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 03:42:50 -0400
In-Reply-To: <1475045878-30455-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, Sep 28, 2016, at 08:57, Maciej =C5=BBenczykowski wrote:
> From: Maciej =C5=BBenczykowski <maze@google.com>
>=20
> This implements:
>   https://tools.ietf.org/html/rfc7559
>=20
> Backoff is performed according to RFC3315 section 14:
>   https://tools.ietf.org/html/rfc3315#section-14
>=20
> We allow setting /proc/sys/net/ipv6/conf/*/router_solicitations
> to a negative value meaning an unlimited number of retransmits,
> and we make this the new default (inline with the RFC).
>=20
> We also add a new setting:
>   /proc/sys/net/ipv6/conf/*/router_solicitation_max_interval
> defaulting to 1 hour (per RFC recommendation).
>=20
> Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
> ---
>  include/linux/ipv6.h      |  1 +
>  include/net/addrconf.h    |  3 ++-
>  include/net/if_inet6.h    |  1 +
>  include/uapi/linux/ipv6.h |  1 +
>  net/ipv6/addrconf.c       | 51
>  ++++++++++++++++++++++++++++++++++++++++-------
>  5 files changed, 49 insertions(+), 8 deletions(-)
>=20
> diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> index c6dbcd84a2c7..7e9a789be5e0 100644
> --- a/include/linux/ipv6.h
> +++ b/include/linux/ipv6.h
> @@ -18,6 +18,7 @@ struct ipv6_devconf {
>  	__s32		dad_transmits;
>  	__s32		rtr_solicits;
>  	__s32		rtr_solicit_interval;
> +       __s32           rtr_solicit_max_interval;
>  	__s32		rtr_solicit_delay;
>  	__s32		force_mld_version;
>  	__s32		mldv1_unsolicited_report_interval;
> diff --git a/include/net/addrconf.h b/include/net/addrconf.h
> index 9826d3a9464c..f2d072787947 100644
> --- a/include/net/addrconf.h
> +++ b/include/net/addrconf.h
> @@ -1,8 +1,9 @@
>  #ifndef _ADDRCONF_H
>  #define _ADDRCONF_H
>=20=20
> -#define MAX_RTR_SOLICITATIONS          3
> +#define MAX_RTR_SOLICITATIONS          -1              /* unlimited */
>  #define RTR_SOLICITATION_INTERVAL       (4*HZ)
> +#define RTR_SOLICITATION_MAX_INTERVAL  (3600*HZ)       /* 1 hour */
>=20=20
>  #define MIN_VALID_LIFETIME              (2*3600)        /* 2 hours */
>=20=20
> diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
> index 1c8b6820b694..515352c6280a 100644
> --- a/include/net/if_inet6.h
> +++ b/include/net/if_inet6.h
> @@ -201,6 +201,7 @@ struct inet6_dev {
>  	struct ipv6_devstat	stats;
>=20=20
>  	struct timer_list	rs_timer;
> +       __s32                   rs_interval;    /* in jiffies */
>  	__u8			rs_probes;
>=20=20
>  	__u8			addr_gen_mode;
> diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
> index 395876060f50..8c2772340c3f 100644
> --- a/include/uapi/linux/ipv6.h
> +++ b/include/uapi/linux/ipv6.h
> @@ -177,6 +177,7 @@ enum {
>  	DEVCONF_DROP_UNICAST_IN_L2_MULTICAST,
>  	DEVCONF_DROP_UNSOLICITED_NA,
>  	DEVCONF_KEEP_ADDR_ON_DOWN,
> +       DEVCONF_RTR_SOLICIT_MAX_INTERVAL,
>  	DEVCONF_MAX
>  };
>=20=20
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 2f1f5d439788..49bee9bc5ff3 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -112,6 +112,27 @@ static inline u32 cstamp_delta(unsigned long cstamp)
>  	return (cstamp - INITIAL_JIFFIES) * 100UL / HZ;
>  }
>=20=20
> +static inline s32 rfc3315_s14_backoff_init(s32 irt)
> +{
> +       /* multiply 'initial retransmission time' by 0.9 .. 1.1 */
> +       u64 tmp =3D (900000 + prandom_u32() % 200001) * (u64)irt;
> +       do_div(tmp, 1000000);
> +       return (s32)tmp;
> +}
> +
> +static inline s32 rfc3315_s14_backoff_update(s32 rt, s32 mrt)
> +{
> +       /* multiply 'retransmission timeout' by 1.9 .. 2.1 */
> +       u64 tmp =3D (1900000 + prandom_u32() % 200001) * (u64)rt;
> +       do_div(tmp, 1000000);
> +       if ((s32)tmp > mrt) {
> +               /* multiply 'maximum retransmission time' by 0.9 .. 1.1
> */
> +               tmp =3D (900000 + prandom_u32() % 200001) * (u64)mrt;
> +               do_div(tmp, 1000000);

Could you use msecs_to_jiffies here to make the units more clear like I
proposed in the last mail? Or is there a reason not to?

Bye,
Hannes
