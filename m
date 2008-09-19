From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH 10/14] Phonet: Phonet datagram transport protocol
Date: Fri, 19 Sep 2008 09:33:33 +0300
Message-ID: <200809190933.33638.remi.denis-courmont@nokia.com>
References: <200809161757.38571.remi.denis-courmont@nokia.com> <1221577694-4513-10-git-send-email-remi.denis-courmont@nokia.com> <20080916170644.GM8702@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "ext Arnaldo Carvalho de Melo" <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:25159 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750842AbYISGeR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 02:34:17 -0400
In-Reply-To: <20080916170644.GM8702@ghostprotocols.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 16 September 2008 20:06:44 ext Arnaldo Carvalho de Melo, you=
 wrote:
> > +/*
> > + * Prepends an ISI header and sends a datagram.
> > + */
> > +static int pn_send(struct sk_buff *skb, struct net_device *dev,
> > +			u16 dst, u16 src, u8 res)
> > +{
> > +	struct phonethdr *ph;
> > +	int err;
> > +
> > +	if (skb->len > 0xfffd) {
>
> wow, what a magic number! :-)

Taking into account that we push sizeof(*ph) in-between, this protects =
against=20
protocol overflow a few lines down:
    ph->length =3D __cpu_to_be16(skb->len + 2 - sizeof(*ph));

I guess it deserves a /* comment */.

By the way, is the protocol stack or the device driver responsible for =
not=20
transmitting above the MTU?

> > +	skb_reset_transport_header(skb);
> > +	WARN_ON(skb_headroom(skb) & 1); /* HW assumes word alignment */
> > +	ph =3D (struct phonethdr *)skb_push(skb, sizeof(struct phonethdr)=
);
> > +	skb_reset_network_header(skb);
>
> Here you could just use:
>
> 	ph =3D (struct phonethdr *)skb_network_header(skb);
>
> 	or even just:
>
> 	ph =3D pn_hdr(skb);
>
> 	as other protocols such as IP do (see ip_hdr())

Right.

> > +	ph->rdev =3D pn_dev(dst);
> > +	ph->sdev =3D pn_dev(src);
> > +	ph->function =3D res;
> > +	ph->length =3D __cpu_to_be16(skb->len + 2 - sizeof(*ph));
> > +	ph->robj =3D pn_obj(dst);
> > +	ph->sobj =3D pn_obj(src);
> > +
> > +	skb->protocol =3D __constant_htons(ETH_P_PHONET);
>
> No need for __constant_htons(CONSTANT), htons will do the right thing
> and the code will be shorter, clearer.

Ok. There are quite many of these in net/ though... is that reserved fo=
r=20
switch/case only?

(...)

> > +static int pn_ioctl(struct sock *sk, int cmd, unsigned long arg)
> > +{
> > +	struct sk_buff *skb;
> > +	int answ;
> > +
> > +	switch (cmd) {
> > +	case SIOCINQ:
> > +		spin_lock_bh(&sk->sk_receive_queue.lock);
> > +		skb =3D skb_peek(&sk->sk_receive_queue);
> > +		answ =3D skb ? skb->len : 0;
> > +		spin_unlock_bh(&sk->sk_receive_queue.lock);
> > +		return put_user(answ, (int __user *)arg);
>
> Why not use lock_sock/release_sock as tcp?

The socket lock was not taken on the RX path, as I was not using=20
sk_receive_skb(). I believe no state needs protection from softirq in t=
he=20
datagram protocol, other than the receive queue itself.

Of course, with sk_receive_skb(), I guess I could use lock_sock().

Thanks many times for the review,

--=20
R=E9mi Denis-Courmont
Maemo Software, Nokia Devices R&D
