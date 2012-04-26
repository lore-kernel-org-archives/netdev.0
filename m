From: Karsten Keil <keil@b1-systems.de>
Subject: Re: [PATCH 1/8] isdn/gigaset: ratelimit CAPI message dumps
Date: Thu, 26 Apr 2012 08:39:45 +0200
Message-ID: <4F98EDB1.5090702@b1-systems.de>
References: <20120425-patch-gigaset-00.tilman@imap.cc> <20120425-patch-gigaset-01.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>,
	Hansjoerg Lipp <hjlipp@web.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.b1-systems.de ([217.11.58.35]:46478 "EHLO mx1.b1-systems.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752728Ab2DZGwD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2012 02:52:03 -0400
In-Reply-To: <20120425-patch-gigaset-01.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 26.04.2012 01:02, schrieb Tilman Schmidt:
> Introduce a global ratelimit for CAPI message dumps to protect
> against possible log flood.
> Drop the ratelimit for ignored messages which is now covered by the
> global one.
>=20

Hmm, I think the only CAPI messages which would need a ratelimit are
related to the DATA_B3 messages. If you need CAPI debug messages in mos=
t
cases you do not need all of the DATA_B3, but you do not want to miss
any other message related to the call control. With a general rate limi=
t
you do not have the control, which messages are logged and which are no=
t.
And here maybe some cases, when even the DATA_B3 are important (e.g.
searching bugs in flow control), so I would make it still conditional
to allow to print all messages.
And I'm not sure, if this is really something for stable.

> Signed-off-by: Tilman Schmidt <tilman@imap.cc>
> CC: stable <stable@kernel.org>
> ---
>  drivers/isdn/gigaset/capi.c |   22 +++++++++-------------
>  1 files changed, 9 insertions(+), 13 deletions(-)
>=20
> diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.=
c
> index 343b5c8..292ca2f 100644
> --- a/drivers/isdn/gigaset/capi.c
> +++ b/drivers/isdn/gigaset/capi.c
> @@ -14,6 +14,7 @@
>  #include "gigaset.h"
>  #include <linux/proc_fs.h>
>  #include <linux/seq_file.h>
> +#include <linux/ratelimit.h>
>  #include <linux/isdn/capilli.h>
>  #include <linux/isdn/capicmd.h>
>  #include <linux/isdn/capiutil.h>
> @@ -223,10 +224,14 @@ get_appl(struct gigaset_capi_ctr *iif, u16 appl=
)
>  static inline void dump_cmsg(enum debuglevel level, const char *tag,=
 _cmsg *p)
>  {
>  #ifdef CONFIG_GIGASET_DEBUG
> +	/* dump at most 20 messages in 20 secs */
> +	static DEFINE_RATELIMIT_STATE(msg_dump_ratelimit, 20 * HZ, 20);
>  	_cdebbuf *cdb;
> =20
>  	if (!(gigaset_debuglevel & level))
>  		return;
> +	if (!___ratelimit(&msg_dump_ratelimit, tag))
> +		return;
> =20
>  	cdb =3D capi_cmsg2str(p);
>  	if (cdb) {
> @@ -2059,12 +2064,6 @@ static void do_reset_b3_req(struct gigaset_cap=
i_ctr *iif,
>  }
> =20
>  /*
> - * dump unsupported/ignored messages at most twice per minute,
> - * some apps send those very frequently
> - */
> -static unsigned long ignored_msg_dump_time;
> -
> -/*
>   * unsupported CAPI message handler
>   */
>  static void do_unsupported(struct gigaset_capi_ctr *iif,
> @@ -2073,8 +2072,7 @@ static void do_unsupported(struct gigaset_capi_=
ctr *iif,
>  {
>  	/* decode message */
>  	capi_message2cmsg(&iif->acmsg, skb->data);
> -	if (printk_timed_ratelimit(&ignored_msg_dump_time, 30 * 1000))
> -		dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
> +	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
>  	send_conf(iif, ap, skb, CapiMessageNotSupportedInCurrentState);
>  }
> =20
> @@ -2085,11 +2083,9 @@ static void do_nothing(struct gigaset_capi_ctr=
 *iif,
>  		       struct gigaset_capi_appl *ap,
>  		       struct sk_buff *skb)
>  {
> -	if (printk_timed_ratelimit(&ignored_msg_dump_time, 30 * 1000)) {
> -		/* decode message */
> -		capi_message2cmsg(&iif->acmsg, skb->data);
> -		dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
> -	}
> +	/* decode message */
> +	capi_message2cmsg(&iif->acmsg, skb->data);
> +	dump_cmsg(DEBUG_CMD, __func__, &iif->acmsg);
>  	dev_kfree_skb_any(skb);
>  }
> =20


--=20
Karsten Keil
Linux Kernel Development
Tel: +49 175 7249132
Mail: keil@b1-systems.de

B1 Systems GmbH
Osterfeldstra=DFe 7 / 85088 Vohburg / http://www.b1-systems.de
GF: Ralph Dehner / Unternehmenssitz: Vohburg / AG: Ingolstadt,HRB 3537
