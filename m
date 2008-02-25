From: "Jann Traschewski" <jann@gmx.de>
Subject: Re: [BUG][AX25] spinlock lockup
Date: Mon, 25 Feb 2008 12:42:20 +0100
Message-ID: <000601c877a3$7b3d5210$453c822c@dg8ngn>
References: <001a01c87692$cfca8d00$453c822c@dg8ngn> <20080224195101.GA2961@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, "'Ralf Baechle'" <ralf@linux-mips.org>
To: "'Jarek Poplawski'" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:43475 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751863AbYBYLmZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Feb 2008 06:42:25 -0500
In-Reply-To: <20080224195101.GA2961@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applied. Thanks!
Regards,
Jann

> -----Urspr=FCngliche Nachricht-----
> Von: Jarek Poplawski [mailto:jarkao2@gmail.com]=20
> Gesendet: Sonntag, 24. Februar 2008 20:51
> An: Jann Traschewski
> Cc: netdev@vger.kernel.org; 'Ralf Baechle'
> Betreff: Re: [BUG][AX25] spinlock lockup
>=20
> On Sun, Feb 24, 2008 at 04:10:29AM +0100, Jann Traschewski wrote:
> > Hello,
>=20
> Hi!
>=20
> > I got a "spinlock lockup" using the latest Kernel 2.6.24.2=20
> with recent=20
> > patches from Jarek Poplawski applied.
> ...
> >  ppp_deflate nf_nat zlib_deflateBUG: unable to handle kernel NULL=20
> > pointer dereference zlib_inflate nf_conntrack_ipv4 bsd_comp slhc=20
> > ppp_async xt_state
> ...
> > EIP is at skb_append+0x1b/0x30
> ...
> > 00000010 BUG: spinlock lockup on CPU#1, bcm/12213, f40846b8
>=20
> Looks like 2 in 1: NULL pointer dereference and (later?) lockup.
>=20
> There is only one function in AX25 calling skb_append(), and=20
> it really looks suspicious: appends skb after previously=20
> enqueued one, but in the meantime this previous skb could be=20
> removed from the queue.
>=20
> Here is a patch for testing: it fixes this simple way, so=20
> this is not fully compatible with the current method, but=20
> let's check if this could be a problem?
>=20
> Regards,
> Jarek P.
>=20
> (testing patch #1)
>=20
> ---
>=20
>  net/ax25/ax25_subr.c |   11 +++--------
>  1 files changed, 3 insertions(+), 8 deletions(-)
>=20
> diff --git a/net/ax25/ax25_subr.c b/net/ax25/ax25_subr.c=20
> index d8f2157..034aa10 100644
> --- a/net/ax25/ax25_subr.c
> +++ b/net/ax25/ax25_subr.c
> @@ -64,20 +64,15 @@ void ax25_frames_acked(ax25_cb *ax25,=20
> unsigned short nr)
> =20
>  void ax25_requeue_frames(ax25_cb *ax25)  {
> -	struct sk_buff *skb, *skb_prev =3D NULL;
> +	struct sk_buff *skb;
> =20
>  	/*
>  	 * Requeue all the un-ack-ed frames on the output queue=20
> to be picked
>  	 * up by ax25_kick called from the timer. This=20
> arrangement handles the
>  	 * possibility of an empty output queue.
>  	 */
> -	while ((skb =3D skb_dequeue(&ax25->ack_queue)) !=3D NULL) {
> -		if (skb_prev =3D=3D NULL)
> -			skb_queue_head(&ax25->write_queue, skb);
> -		else
> -			skb_append(skb_prev, skb, &ax25->write_queue);
> -		skb_prev =3D skb;
> -	}
> +	while ((skb =3D skb_dequeue_tail(&ax25->ack_queue)) !=3D NULL)
> +		skb_queue_head(&ax25->write_queue, skb);
>  }
> =20
>  /*

