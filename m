From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG in skb_pull with e1000e, PPTP, and L2TP
Date: Tue, 18 Oct 2011 05:51:19 +0200
Message-ID: <1318909879.2571.43.camel@edumazet-laptop>
References: <CAJuWrdtOru6KSNTxXhhQNEZUTaX5KvyF7macx4RZYxMzcAo0KQ@mail.gmail.com>
	 <1318904666.2571.33.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Bradley Peterson <despite@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:52782 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608Ab1JRDvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 23:51:24 -0400
Received: by wwn22 with SMTP id 22so4360846wwn.1
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 20:51:23 -0700 (PDT)
In-Reply-To: <1318904666.2571.33.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 octobre 2011 =C3=A0 04:24 +0200, Eric Dumazet a =C3=A9crit =
:

> diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
> index eae542a..d0197e3 100644
> --- a/drivers/net/ppp/pptp.c
> +++ b/drivers/net/ppp/pptp.c
> @@ -305,11 +305,16 @@ static int pptp_rcv_core(struct sock *sk, struc=
t sk_buff *skb)
>  	}
> =20
>  	header =3D (struct pptp_gre_header *)(skb->data);
> +	headersize  =3D sizeof(*header);
> =20
>  	/* test if acknowledgement present */
>  	if (PPTP_GRE_IS_A(header->ver)) {
> -		__u32 ack =3D (PPTP_GRE_IS_S(header->flags)) ?
> -				header->ack : header->seq; /* ack in different place if S =3D 0 =
*/
> +		__u32 ack;
> +
> +		if (!pskb_may_pull(skb, headersize))
> +			goto drop;

Oh well, this is buggy, I need to set header again, I'll send an update=
d
patch

		header =3D (struct pptp_gre_header *)(skb->data);

> +		ack =3D (PPTP_GRE_IS_S(header->flags)) ?
> +			header->ack : header->seq; /* ack in different place if S =3D 0 *=
/
> =20
