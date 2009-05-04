From: "Jann Traschewski" <jann@gmx.de>
Subject: Re: [BUG][AX25] 2.6.28.5 "inconsistent lock state" (2 CPUs / SMPenabled)
Date: Mon, 4 May 2009 13:45:01 +0200
Message-ID: <F35CF6D4C5284C44BA1EE8EC879FDB08@A050313B>
References: <4152EA8442834D52AA9C100377B9ABE2@A050313B> <20090504073153.GA5354@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: "'Jarek Poplawski'" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:42261 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752153AbZEDLpM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2009 07:45:12 -0400
In-Reply-To: <20090504073153.GA5354@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks. Patch applied. It could take a long time until the problem will
occur again...

> -----Urspr=FCngliche Nachricht-----
> Von: Jarek Poplawski [mailto:jarkao2@gmail.com]=20
> Gesendet: Montag, 4. Mai 2009 09:32
> An: Jann Traschewski
> Cc: netdev@vger.kernel.org
> Betreff: Re: [BUG][AX25] 2.6.28.5 "inconsistent lock state"=20
> (2 CPUs / SMPenabled)
>=20
> On 03-05-2009 10:06, Jann Traschewski wrote:
> > Hi,
> >=20
> > the AX.25 code has still some problems with SMP and=20
> locking. I turned=20
> > on lock debugging on my machine with a lot of AX.25=20
> traffic. Although=20
> > it did take serveral days until I got this:
> >=20
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > [ INFO: inconsistent lock state ]
> > 2.6.28.5-dg8ngn #1
> > ---------------------------------
> > inconsistent {softirq-on-R} -> {in-softirq-W} usage.
> > swapper/0 [HC0[0]:SC1[2]:HE1:SE0] takes:
> >  (clock-AF_AX25){-+-?}, at: [<f859ed33>]=20
> > ax25_destroy_socket+0xb6/0x1c4 [ax25] {softirq-on-R} state was=20
> > registered at:
> >   [<c013a751>] __lock_acquire+0x4e4/0x65e
> >   [<c0124d14>] local_bh_enable+0xa5/0xa9
> >   [<c013a914>] lock_acquire+0x49/0x61
> >   [<c025a221>] sock_def_wakeup+0x11/0x3d
> >   [<c02ca449>] _read_lock+0x19/0x24
> >   [<c025a221>] sock_def_wakeup+0x11/0x3d
> >   [<c025a221>] sock_def_wakeup+0x11/0x3d
> >   [<f859fb9c>] ax25_release+0x17e/0x1ab [ax25]
> >   [<c025847f>] sock_release+0x11/0x59
> >   [<c0258883>] sock_close+0x19/0x1c
> ...
>=20
> Hi,
>=20
> Could you try this patch?
>=20
> Thanks,
> Jarek P.
> ---
>=20
>  net/ax25/af_ax25.c |   17 +++++++++++++++--
>  1 files changed, 15 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/ax25/af_ax25.c b/net/ax25/af_ax25.c index=20
> fd9d06f..f2fec78 100644
> --- a/net/ax25/af_ax25.c
> +++ b/net/ax25/af_ax25.c
> @@ -314,8 +314,21 @@ void ax25_destroy_socket(ax25_cb *ax25)
>  				/* A pending connection */
>  				ax25_cb *sax25 =3D ax25_sk(skb->sk);
> =20
> -				/* Queue the unaccepted socket=20
> for death */
> -				sock_orphan(skb->sk);
> +				/*
> +				 * Queue the unaccepted socket=20
> for death.
> +				 * Btw., it was never grafted,=20
> so sock_orphan()
> +				 * is unnecessary.
> +				 */
> +				if (unlikely(skb->sk->sk_socket)) {
> +					/*
> +					 * This is old code, so=20
> let's leave it
> +					 * for some time for debugging.
> +					 */
> +					sock_orphan(skb->sk);
> +					WARN_ON_ONCE(1);
> +				} else {
> +					sock_set_flag(skb->sk,=20
> SOCK_DEAD);
> +				}
> =20
>  				/* 9A4GL: hack to release=20
> unaccepted sockets */
>  				skb->sk->sk_state =3D TCP_LISTEN;

