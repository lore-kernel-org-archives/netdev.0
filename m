From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH v2 1/2] Phonet: Implement Pipe Controller to support Nokia Slim Modems
Date: Wed, 29 Sep 2010 01:25:06 +0300
Message-ID: <201009290125.07068.remi.denis-courmont@nokia.com>
References: <1285564079-23066-1-git-send-email-kumar.sanghvi@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"STEricsson_nomadik_linux@list.st.com"
	<STEricsson_nomadik_linux@list.st.com>,
	"sudeep.divakaran@stericsson.com" <sudeep.divakaran@stericsson.com>,
	"gulshan.karmani@stericsson.com" <gulshan.karmani@stericsson.com>,
	Linus Walleij <linus.walleij@stericsson.com>
To: ext Kumar A Sanghvi <kumar.sanghvi@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw-sa02.nokia.com ([147.243.1.48]:33802 "EHLO
	mgw-sa02.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754381Ab0I1WYd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Sep 2010 18:24:33 -0400
In-Reply-To: <1285564079-23066-1-git-send-email-kumar.sanghvi@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 27 September 2010 08:07:59 ext Kumar A Sanghvi, you wrote:
> From: Kumar Sanghvi <kumar.sanghvi@stericsson.com>
>=20
> Phonet stack assumes the presence of Pipe Controller, either in Modem=
 or
> on Application Processing Engine user-space for the Pipe data.
> Nokia Slim Modems like WG2.5 used in ST-Ericsson U8500 platform do no=
t
> implement Pipe controller in them.
> This patch adds Pipe Controller implemenation to Phonet stack to supp=
ort
> Pipe data over Phonet stack for Nokia Slim Modems.
>=20
> Signed-off-by: Kumar Sanghvi <kumar.sanghvi@stericsson.com>
> Acked-by: Linus Walleij <linus.walleij@stericsson.com>
> ---
> Changes:
>=20
>  -v2: Correction for header retrieving after pskb_may_pull
>=20
>  include/linux/phonet.h   |    5 +
>  include/net/phonet/pep.h |   21 +++
>  net/phonet/Kconfig       |   11 ++
>  net/phonet/pep.c         |  448
> +++++++++++++++++++++++++++++++++++++++++++++- 4 files changed, 479
> insertions(+), 6 deletions(-)
>=20
> diff --git a/include/linux/phonet.h b/include/linux/phonet.h
> index 85e14a8..96f5625 100644
> --- a/include/linux/phonet.h
> +++ b/include/linux/phonet.h
> @@ -36,6 +36,11 @@
>  /* Socket options for SOL_PNPIPE level */
>  #define PNPIPE_ENCAP           1
>  #define PNPIPE_IFINDEX         2
> +#define PNPIPE_CREATE           3
> +#define PNPIPE_ENABLE           4
> +#define PNPIPE_DISABLE          5
> +#define PNPIPE_DESTROY          6
> +#define PNPIPE_INQ              7

As far as I know, you don't need to do that in kernel space. I don't kn=
ow the=20
internals of the STE modem. Regardless of having or not having a pipe=20
controller, Linux userspace can send pipe messages using a plain Phonet=
=20
datagram socket. This avoids adding ioctl()'s and protocol stuff in ker=
nel=20
space. Then, as far as kernel is concerned, only small changes to the d=
ata=20
path would be required.

Both the Nokia modem plugin for oFono, and the (closed-source) Nokia N9=
00 CSD-
GPRS service work that way. In other words, the pipe 'signaling' is don=
e in=20
userspace, while the pipe 'data' is done in kernel space for optimal=20
performance.

=46or some background - Phonet pipes work very much like FTP. There are=
 two=20
endpoints exchaning data, and one client ('owner') deciding which endpo=
ints=20
and when to establish a pipe between. In most case the client is also o=
ne of=20
the endpoint, but this is not required. With this patch, the client is =
tied to=20
being one of the endpoint. Arguably, this is not a problem for most use=
cases.=20
But I am not sure this belongs in *kernel* space. Sticking to the same=20
comparison: with FTP, you have TCP (data path) in kernel, but not FTP i=
tself=20
(signaling).

> @@ -791,6 +1171,48 @@ static int pep_setsockopt(struct sock *sk, int =
level,
> int optname,
>=20
>         lock_sock(sk);
>         switch (optname) {
> +#ifdef CONFIG_PHONET_PIPECTRLR
> +       case PNPIPE_CREATE:
> +               if (val) {
> +                       if (pn->pipe_state > PIPE_IDLE) {
> +                               err =3D -EFAULT;

Why EFAULT here? I can't see any user-space memory access failure.

> +                               break;
> +                       }
> +                       remote_pep =3D val & 0xFFFF;
> +                       pipe_handle =3D  (val >> 16) & 0xFF;
> +                       pn->remote_pep =3D remote_pep;
> +                       err =3D pipe_handler_create_pipe(sk, pipe_han=
dle,
> +                                       PNPIPE_CREATE);
> +                       break;
> +               }
> +
> +       case PNPIPE_ENABLE:
> +               if (pn->pipe_state !=3D PIPE_DISABLED) {
> +                       err =3D -EFAULT;

Same here.

> +                       break;
> +               }
> +               err =3D pipe_handler_enable_pipe(sk, PNPIPE_ENABLE);
> +               break;
> +
> +       case PNPIPE_DISABLE:
> +               if (pn->pipe_state !=3D PIPE_ENABLED) {
> +                       err =3D -EFAULT;

Ditto.

> +                       break;
> +               }
> +
> +               err =3D pipe_handler_enable_pipe(sk, PNPIPE_DISABLE);
> +               break;
> +
> +       case PNPIPE_DESTROY:
> +               if (pn->pipe_state < PIPE_DISABLED) {
> +                       err =3D -EFAULT;

And here,

> @@ -877,11 +1313,11 @@ static int pipe_skb_send(struct sock *sk, stru=
ct
> sk_buff *skb) } else
>                 ph->message_id =3D PNS_PIPE_DATA;
>         ph->pipe_handle =3D pn->pipe_handle;
> -
> -       err =3D pn_skb_send(sk, skb, &pipe_srv);
> -       if (err && pn_flow_safe(pn->tx_fc))
> -               atomic_inc(&pn->tx_credits);
> -       return err;
> +#ifdef CONFIG_PHONET_PIPECTRLR
> +       return pn_skb_send(sk, skb, &spn);
> +#else
> +       return pn_skb_send(sk, skb, &pipe_srv);
> +#endif
>  }

This reintroduces the bug that I fixed in=20
1a98214feef2221cd7c24b17cd688a5a9d85b2ea :-(

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki
