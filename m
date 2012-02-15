From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] Netfilter: xt_LOG: Add timestamp support
Date: Wed, 15 Feb 2012 05:56:28 +0100
Message-ID: <1329281788.2555.24.camel@edumazet-laptop>
References: <1329262573-22048-1-git-send-email-richard@nod.at>
	 <1329262573-22048-2-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jengelh@medozas.de,
	rostedt@goodmis.org, pablo@netfilter.org, basti@b-bl.de
To: Richard Weinberger <richard@nod.at>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329262573-22048-2-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 15 f=C3=A9vrier 2012 =C3=A0 00:36 +0100, Richard Weinberger=
 a =C3=A9crit :
> Using XT_LOG_ADD_TIMESTAMP it is possible to have a timestamp
> directly in the log message.
>=20
> Signed-off-by: Richard Weinberger <richard@nod.at>
> ---
>  include/linux/netfilter/xt_LOG.h |    1 +
>  net/netfilter/xt_LOG.c           |   10 ++++++++++
>  2 files changed, 11 insertions(+), 0 deletions(-)
>=20
> diff --git a/include/linux/netfilter/xt_LOG.h b/include/linux/netfilt=
er/xt_LOG.h
> index e4b1177..d84710c 100644
> --- a/include/linux/netfilter/xt_LOG.h
> +++ b/include/linux/netfilter/xt_LOG.h
> @@ -8,6 +8,7 @@
>  #define XT_LOG_UID		0x08	/* Log UID owning local socket */
>  #define XT_LOG_NFLOG		0x10	/* Unsupported, don't reuse */
>  #define XT_LOG_MACDECODE	0x20	/* Decode MAC header */
> +#define XT_LOG_ADD_TIMESTAMP	0x40	/* Add a timestamp */
>  #define XT_LOG_MASK		0x6f
> =20
>  struct xt_log_info {
> diff --git a/net/netfilter/xt_LOG.c b/net/netfilter/xt_LOG.c
> index 211d341..bd59dfd 100644
> --- a/net/netfilter/xt_LOG.c
> +++ b/net/netfilter/xt_LOG.c
> @@ -490,6 +490,16 @@ log_packet_common(struct sbuff *m,
>  	if (loginfo->type =3D=3D NF_LOG_TYPE_LOG)
>  		sb_add(m, "<%d>", loginfo->u.log.level);
> =20
> +	if (loginfo->u.log.logflags & XT_LOG_ADD_TIMESTAMP) {
> +		static struct timespec tv;

Please remove 'static', its unsafe on SMP and useless anyway.

> +		unsigned int msec;
> +
> +		getnstimeofday(&tv);
> +		msec =3D tv.tv_nsec;
> +		do_div(msec, 1000000);

why do_div() ? Its not an u64=20

Just use tv.tv_nsec / NSEC_PER_MSEC


> +		sb_add(m, "TIMESTAMP=3D%li.%03li ", tv.tv_sec, msec);
> +	}
> +
>  	sb_add(m, "%sIN=3D%s OUT=3D%s ", prefix, in ? in->name : "",
>  	       out ? out->name : "");
>  #ifdef CONFIG_BRIDGE_NETFILTER
