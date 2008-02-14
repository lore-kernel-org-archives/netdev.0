From: "Jann Traschewski" <jann@gmx.de>
Subject: Re: [PATCH][AX25] ax25_out: check skb for NULL in ax25_kick()
Date: Thu, 14 Feb 2008 01:49:29 +0100
Message-ID: <025801c86ea3$75add3f0$453c822c@dg8ngn>
References: <20080206074529.GC4496@ff.dom.local> <20080213115607.GB2867@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "'Bernard Pidoux F6BVP'" <f6bvp@free.fr>,
	"'Ralf Baechle'" <ralf@linux-mips.org>, <netdev@vger.kernel.org>
To: "'Jarek Poplawski'" <jarkao2@gmail.com>,
	"'David Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:51493 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1759325AbYBNAtg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 19:49:36 -0500
In-Reply-To: <20080213115607.GB2867@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applied and stable with Kernel 2.6.24.2 since 12 hours.
Regards,
Jann

> -----Urspr=FCngliche Nachricht-----
> Von: Jarek Poplawski [mailto:jarkao2@gmail.com]=20
> Gesendet: Mittwoch, 13. Februar 2008 12:56
> An: David Miller
> Cc: Jann Traschewski; Bernard Pidoux F6BVP; Ralf Baechle;=20
> netdev@vger.kernel.org
> Betreff: [PATCH][AX25] ax25_out: check skb for NULL in ax25_kick()
>=20
> Hi,
>=20
> Here is an "official" version of "testing patch #2" from this thread.
> The only difference: ax25->vs is changed only after checking=20
> skb is not NULL (plus a comment). IMHO it could be applied.
>=20
> Thanks,
> Jarek P.
>=20
> ---------------->
>=20
> Subject: [AX25] ax25_out: check skb for NULL in ax25_kick()
>=20
> According to some OOPS reports ax25_kick tries to clone NULL=20
> skbs sometimes. It looks like a race with=20
> ax25_clear_queues(). Probably there is no need to add more=20
> than a simple check for this yet.
> Another report suggested there are probably also cases where ax25
> ->paclen =3D=3D 0 can happen in ax25_output(); this wasn't confirmed
> during testing but let's leave this debugging check for some time.
>=20
>=20
> Reported-and-tested-by: Jann Traschewski <jann@gmx.de>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
>=20
> ---
>=20
> diff -Nurp 2.6.24-mm1-/net/ax25/ax25_out.c=20
> 2.6.24-mm1+/net/ax25/ax25_out.c
> --- 2.6.24-mm1-/net/ax25/ax25_out.c	2008-01-24=20
> 22:58:37.000000000 +0000
> +++ 2.6.24-mm1+/net/ax25/ax25_out.c	2008-02-13=20
> 10:43:50.000000000 +0000
> @@ -117,6 +117,12 @@ void ax25_output(ax25_cb *ax25, int pacl
>  	unsigned char *p;
>  	int frontlen, len, fragno, ka9qfrag, first =3D 1;
> =20
> +	if (paclen < 16) {
> +		WARN_ON_ONCE(1);
> +		kfree_skb(skb);
> +		return;
> +	}
> +
>  	if ((skb->len - 1) > paclen) {
>  		if (*skb->data =3D=3D AX25_P_TEXT) {
>  			skb_pull(skb, 1); /* skip PID */
> @@ -251,8 +257,6 @@ void ax25_kick(ax25_cb *ax25)
>  	if (start =3D=3D end)
>  		return;
> =20
> -	ax25->vs =3D start;
> -
>  	/*
>  	 * Transmit data until either we're out of data to send or
>  	 * the window is full. Send a poll on the final I frame=20
> if @@ -261,8 +265,13 @@ void ax25_kick(ax25_cb *ax25)
> =20
>  	/*
>  	 * Dequeue the frame and copy it.
> +	 * Check for race with ax25_clear_queues().
>  	 */
>  	skb  =3D skb_dequeue(&ax25->write_queue);
> +	if (!skb)
> +		return;
> +
> +	ax25->vs =3D start;
> =20
>  	do {
>  		if ((skbn =3D skb_clone(skb, GFP_ATOMIC)) =3D=3D NULL) {

