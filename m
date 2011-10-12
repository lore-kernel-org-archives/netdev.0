From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net: hold sock reference while processing tx
 timestamps
Date: Wed, 12 Oct 2011 21:52:39 +0200
Message-ID: <1318449159.2644.9.camel@edumazet-laptop>
References: <1318007501.3988.20.camel@jlt3.sipsolutions.net>
	 <56185ca8a7dc0223031ca0f0996302cac1b497eb.1318444117.git.richard.cochran@omicron.at>
	 (sfid-20111012_203706_058621_68EB8D6B) <1318447673.3933.47.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47666 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752878Ab1JLTwn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2011 15:52:43 -0400
Received: by wwf22 with SMTP id 22so577185wwf.1
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2011 12:52:42 -0700 (PDT)
In-Reply-To: <1318447673.3933.47.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 12 octobre 2011 =C3=A0 21:27 +0200, Johannes Berg a =C3=A9c=
rit :
> On Wed, 2011-10-12 at 20:36 +0200, Richard Cochran wrote:
> > The pair of functions,
> >=20
> >  * skb_clone_tx_timestamp()
> >  * skb_complete_tx_timestamp()
> >=20
> > were designed to allow timestamping in PHY devices. The first
> > function, called during the MAC driver's hard_xmit method, identifi=
es
> > PTP protocol packets, clones them, and gives them to the PHY device
> > driver. The PHY driver may hold onto the packet and deliver it at a
> > later time using the second function, which adds the packet to the
> > socket's error queue.
> >=20
> > As pointed out by Johannes, nothing prevents the socket from
> > disappearing while the cloned packet is sitting in the PHY driver
> > awaiting a timestamp. This patch fixes the issue by taking a refere=
nce
> > on the socket for each such packet. In addition, the comments
> > regarding the usage of these function are expanded to highlight the
> > rule that PHY drivers must use skb_complete_tx_timestamp() to relea=
se
> > the packet, in order to release the socket reference, too.
>=20
> This still needs a fix to the PHY driver right? It has a case that ca=
n
> kfree_skb() the skb instead of passing it back to
> complete_tx_timestamp().
>=20
> > -	if (!hwtstamps)
> > +	if (!hwtstamps) {
> > +		sock_put(sk);
> > +		kfree_skb(skb);
> >  		return;
> > +	}
>=20
> Is that right w/o skb->sk =3D NULL?
>=20
>=20
> The other thing I was wondering -- what if we just set truesize to 1 =
(we
> don't have any truesize checks) and account the skb to the socket
> normally. Not really a good way either though.
>=20

Changing truesize is not allowed here see below.

> FWIW I just decided to do it the other way around in mac80211 -- keep
> the original SKB that's charged to the socket for the error queue, an=
d
> use a clone to actually do the TX.

Hmm, please take a look at IFF_SKB_TX_SHARING stuff, added in commit
d88733150 (net: add IFF_SKB_TX_SHARED flag to priv_flags)
