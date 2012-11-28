From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP and reordering
Date: Wed, 28 Nov 2012 08:09:42 -0800
Message-ID: <1354118982.14302.356.camel@edumazet-glaptop>
References: <CAAeewD8zsfb6QPFecvPab_oK3D3T7eG_M53MVvfJ2QrxUFxWSQ@mail.gmail.com>
	 <50B4F2DA.8020206@hp.com>
	 <CAAeewD9MtEx4uF6ezbBj7Ci5OzX8VK7p=WQ2TB3PfjmznA4X0w@mail.gmail.com>
	 <20121127.210611.1127622873924794001.davem@davemloft.net>
	 <1354089566.21562.20.camel@shinybook.infradead.org>
	 <CAGK4HS8=NfcyvcNjC3h1wEjgQFCYoNeuWXj8n5Ruukeg+6j=SQ@mail.gmail.com>
	 <1354093703.21562.23.camel@shinybook.infradead.org>
	 <1354100552.14302.78.camel@edumazet-glaptop>
	 <1354103355.21562.46.camel@shinybook.infradead.org>
	 <1354105619.14302.89.camel@edumazet-glaptop>
	 <1354106362.21562.51.camel@shinybook.infradead.org>
	 <1354107140.14302.140.camel@edumazet-glaptop>
	 <1354117635.21562.63.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vijay Subramanian <subramanian.vijay@gmail.com>,
	David Miller <davem@davemloft.net>, saku@ytti.fi,
	rick.jones2@hp.com, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f174.google.com ([209.85.210.174]:57449 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752079Ab2K1QJq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 11:09:46 -0500
Received: by mail-ia0-f174.google.com with SMTP id y25so10000475iay.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 08:09:46 -0800 (PST)
In-Reply-To: <1354117635.21562.63.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-11-28 at 15:47 +0000, David Woodhouse wrote:
> On Wed, 2012-11-28 at 04:52 -0800, Eric Dumazet wrote:
> > BQL is nice for high speed adapters.
>=20
> For adapters with hugely deep queues, surely? There's a massive
> correlation between the two, of course =E2=80=94 but PPP over L2TP or=
 PPPoE
> ought to be included in the classification, right?
>=20
> > For slow one, you always can stop the queue for each packet given t=
o
> > start_xmit()
> >=20
> > And restart the queue at TX completion.
>=20
> Well yes, but only if we get notified of TX completion.
>=20
> It's simple enough for the tty-based channels, and we can do it with =
a
> vcc->pop() function for PPPoATM. But for PPPoE and L2TP, how do we do
> it? We can install a skb destructor... but then we're stomping on TSQ=
's
> use of the destructor by orphaning it too soon.
>=20
> I'm pondering something along the lines of
>=20
> 	if (skb->destructor) {
> 		newskb =3D skb_clone(skb, GFP_KERNEL);
> 		if (newskb) {
> 	             skb_shinfo(newskb) =3D skb;
> 		     skb =3D newskb;
> 	        }=20
> 	 }
> 	 skb_orphan(skb);
> 	 skb->destructor =3D ppp_chan_tx_completed;
>=20
>=20
> ... and then ppp_chan_tx_completed can also destroy the original skb
> (and hence invoke TSQ's destructor too) when the time comes. And in t=
he
> (common?) case where we don't have an existing destructor, we don't
> bother with the skb_clone.
>=20
> But I wish there was a nicer way to chain destructors. And no, I don'=
t
> count what GSO does. We can't use the cb here anyway since we're pass=
ing
> it down the stack.
>=20

My point was that if you limit number of in flight packet to 1,
its relatively easy to add glue in the priv dev data, so that you chain
the destructor without adding yet another fields in all skbs.

At start_xmit() do the following instead of skb_orphan(skb)

if (skb->destructor) {
     BUG_ON(priv->save_destructor);
     priv->save_destructor =3D skb->destructor;
     priv->save_sk =3D skb->sk;
     skb->sk =3D &priv->fake_sk;
}

skb->destructor =3D my_destructor;
/* stop the queue */
=2E..
}


void my_destructor(struct sk_buff *skb)
{
    struct .... *priv =3D container_of(skb, struct ..., priv.fake_sk);

    skb->sk =3D skb->save_sk;
    priv->save_destructor(skb);
    priv->save_destructor =3D NULL;
    /* restart the queue */
    ...
}

Something like that.
