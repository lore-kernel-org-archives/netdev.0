From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: Re: PROBLEM: pppol2tp over pppoe NULL pointer dereference
Date: Wed, 02 Nov 2011 16:54:30 +0100
Message-ID: <4EB167B6.4040202@dti2.net>
References: <CAKpUy7Z5KOfHbKfBp-qg+77cED=OxUAkm2P4pQacHaHKmKBQpw@mail.gmail.com>  <1320186916.4728.1.camel@edumazet-laptop>  <CAKpUy7ZTpXtUDXB+NCxa4QBr3qiwo7aBW9DmUY8ADqO8FgrUpw@mail.gmail.com> <1320217652.30178.1.camel@edumazet-laptop>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Misha Labjuk <spiked.yar@gmail.com>, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:63647 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932383Ab1KBP7e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 11:59:34 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v12.5.0)
	with ESMTP id md50019462333.msg
	for <netdev@vger.kernel.org>; Wed, 02 Nov 2011 16:54:33 +0100
In-Reply-To: <1320217652.30178.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El 02/11/2011 8:07, Eric Dumazet escribi=C3=B3:
> Le mercredi 02 novembre 2011 =C3=A0 09:04 +0400, Misha Labjuk a =C3=A9=
crit :
>> 2011/11/2 Eric Dumazet <eric.dumazet@gmail.com>:
>>>
>>> On what kind of NIC this is happening ?
>>>
>>
>> Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit
>> Ethernet controller (rev 02)
>> Kernel driver in use: r8169
>=20
> OK thanks, could you try the following patch as well ?
>=20
> If we release reorder_q.lock, we must not keep a dangling pointer (tm=
p)
> and restart the whole loop.
>=20
> diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
> index 34b2dde..bf8d50c 100644
> --- a/net/l2tp/l2tp_core.c
> +++ b/net/l2tp/l2tp_core.c
> @@ -397,6 +397,7 @@ static void l2tp_recv_dequeue(struct l2tp_session=
 *session)
>  	 * expect to send up next, dequeue it and any other
>  	 * in-sequence packets behind it.
>  	 */
> +start:
>  	spin_lock_bh(&session->reorder_q.lock);
>  	skb_queue_walk_safe(&session->reorder_q, skb, tmp) {
>  		if (time_after(jiffies, L2TP_SKB_CB(skb)->expires)) {
> @@ -433,7 +434,7 @@ static void l2tp_recv_dequeue(struct l2tp_session=
 *session)
>  		 */
>  		spin_unlock_bh(&session->reorder_q.lock);
>  		l2tp_recv_dequeue_skb(session, skb);
> -		spin_lock_bh(&session->reorder_q.lock);
> +		goto start;
>  	}
> =20
>  out:
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20

	I've been using this same exact patch on an old kernel since a while a=
go. I had
one system that crashed here, now decommissioned. After some testing I =
was
unable to reproduce the bug in another systems but on the one that exhi=
bited the
problem it fixed the crashes.

	Regards,
		Jorge
--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
Jorge Boncompte - Ingenieria y Gestion de RED
DTI2 - Desarrollo de la Tecnologia de las Comunicaciones
--------------------------------------------------------------
C/ Abogado Enriquez Barrios, 5   14004 CORDOBA (SPAIN)
Tlf: +34 957 761395 / FAX: +34 957 450380
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
- There is only so much duct tape you can put on something
  before it just becomes a giant ball of duct tape.
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
