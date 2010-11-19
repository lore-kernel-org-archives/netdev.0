From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6 v2] filter: optimize sk_run_filter
Date: Fri, 19 Nov 2010 15:35:06 +0100
Message-ID: <1290177306.3034.129.camel@edumazet-laptop>
References: <1290160467.3034.33.camel@edumazet-laptop>
	 <1290165472.3034.109.camel@edumazet-laptop>
	 <AANLkTi=ed79a5HjGULPdwuqmUhj=W8BGzRh7tm2L11ef@mail.gmail.com>
	 <AANLkTi==Ovw8xFA1K6rVabg9MW0w6wd=2qvo=XojUXpM@mail.gmail.com>
	 <1290172607.3034.124.camel@edumazet-laptop>
	 <201011192317.CFB48465.OtLFOJOMHQSFFV@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, davem@davemloft.net, hagen@jauu.net,
	netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44799 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752255Ab0KSOfL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 09:35:11 -0500
Received: by wyb28 with SMTP id 28so4520284wyb.19
        for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 06:35:09 -0800 (PST)
In-Reply-To: <201011192317.CFB48465.OtLFOJOMHQSFFV@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 19 novembre 2010 =C3=A0 23:17 +0900, Tetsuo Handa a =C3=A9c=
rit :
> Just my thought again...
>=20
> Eric Dumazet wrote:
> > @@ -167,34 +168,36 @@ unsigned int sk_run_filter(struct sk_buff *sk=
b, struct sock_filter *filter, int
> >  	unsigned long memvalid =3D 0;
> >  	u32 tmp;
> >  	int k;
>=20
> Is this 'k' useful?
>=20

Yes this is useful, please read later we have :

	k =3D X + K;
	goto load_w;

K is readonly, k is a rw temp variable (on stack)

> > -	int pc;
> > =20
> >  	BUILD_BUG_ON(BPF_MEMWORDS > BITS_PER_LONG);
> >  	/*
> >  	 * Process array of filter instructions.
> >  	 */
> > -	for (pc =3D 0; pc < flen; pc++) {
> > -		const struct sock_filter *fentry =3D &filter[pc];
> > -		u32 f_k =3D fentry->k;
> > +	for (;; fentry++) {
> > +#if defined(CONFIG_X86_32)
> > +#define	K (fentry->k)
> > +#else
> > +		const u32 K =3D fentry->k;
>=20
> What happens if we use
>=20
> 	u32 f_k =3D fentry->k;
>=20
> and
>=20
> >  		case BPF_S_LD_W_ABS:
> > -			k =3D f_k;
> > +			k =3D K;
>=20
> remove this assignment and
>=20
> >  load_w:
> >  			ptr =3D load_pointer(skb, k, 4, &tmp);
>=20
> change to
>=20
> 	ptr =3D load_pointer(skb, (int) f_k, 4, &tmp);
>=20
> and
>=20
> >  		case BPF_S_LD_W_IND:
> > -			k =3D X + f_k;
> > +			k =3D X + K;
>=20
> change to
>=20
> 	f_k +=3D X;
>=20
> ?
> >  			goto load_w;


This wont work, K is really a constant, part of the filter program,
while k is the (existing) temp variable.


=20


