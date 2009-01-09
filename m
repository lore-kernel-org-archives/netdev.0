From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] tcp: splice as many packets as possible at once
Date: Fri, 9 Jan 2009 23:17:44 +0100
Message-ID: <20090109221744.GA4819@1wt.eu>
References: <20090108173028.GA22531@1wt.eu> <49667534.5060501@zeus.com> <20090108.135515.85489589.davem@davemloft.net> <4966F2F4.9080901@cosmosbay.com> <49677074.5090802@cosmosbay.com> <20090109185448.GA1999@1wt.eu> <4967B8C5.10803@cosmosbay.com> <20090109212400.GA3727@1wt.eu> <20090109220737.GA4111@1wt.eu> <4967CBB9.1060403@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, ben@zeus.com,
	jarkao2@gmail.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1351 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759314AbZAIWSH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 17:18:07 -0500
Content-Disposition: inline
In-Reply-To: <4967CBB9.1060403@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2009 at 11:12:09PM +0100, Eric Dumazet wrote:
> Willy Tarreau a =E9crit :
> > On Fri, Jan 09, 2009 at 10:24:00PM +0100, Willy Tarreau wrote:
> >> On Fri, Jan 09, 2009 at 09:51:17PM +0100, Eric Dumazet wrote:
> >> (...)
> >>>> Also, in your second mail, you're saying that your change
> >>>> might return more data than requested by the user. I can't
> >>>> find why, could you please explain to me, as I'm still quite
> >>>> ignorant in this area ?
> >>> Well, I just tested various user programs and indeed got this
> >>> strange result :
> >>>
> >>> Here I call splice() with len=3D1000 (0x3e8), and you can see
> >>> it gives a result of 1460 at the second call.
> >=20
> > OK finally I could reproduce it and found why we have this. It's
> > expected in fact.
> >=20
> > The problem when we loop in tcp_read_sock() is that tss->len is
> > not decremented by the amount of bytes read, this one is done
> > only in tcp_splice_read() which is outer.
> >=20
> > The solution I found was to do just like other callers, which means
> > use desc->count to keep the remaining number of bytes we want to
> > read. In fact, tcp_read_sock() is designed to use that one as a sto=
p
> > condition, which explains why you first had to hide it.
> >=20
> > Now with the attached patch as a replacement for my previous one,
> > both issues are solved :
> >   - I splice 1000 bytes if I ask to do so
> >   - I splice as much as possible if available (typically 23 kB).
> >=20
> > My observed performances are still at the top of earlier results
> > and IMHO that way of counting bytes makes sense for an actor called
> > from tcp_read_sock().
> >=20
> > diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> > index 35bcddf..51ff3aa 100644
> > --- a/net/ipv4/tcp.c
> > +++ b/net/ipv4/tcp.c
> > @@ -522,8 +522,12 @@ static int tcp_splice_data_recv(read_descripto=
r_t *rd_desc, struct sk_buff *skb,
> >  				unsigned int offset, size_t len)
> >  {
> >  	struct tcp_splice_state *tss =3D rd_desc->arg.data;
> > +	int ret;
> > =20
> > -	return skb_splice_bits(skb, offset, tss->pipe, tss->len, tss->fla=
gs);
> > +	ret =3D skb_splice_bits(skb, offset, tss->pipe, rd_desc->count, t=
ss->flags);
> > +	if (ret > 0)
> > +		rd_desc->count -=3D ret;
> > +	return ret;
> >  }
> > =20
> >  static int __tcp_splice_read(struct sock *sk, struct tcp_splice_st=
ate *tss)
> > @@ -531,6 +535,7 @@ static int __tcp_splice_read(struct sock *sk, s=
truct tcp_splice_state *tss)
> >  	/* Store TCP splice context information in read_descriptor_t. */
> >  	read_descriptor_t rd_desc =3D {
> >  		.arg.data =3D tss,
> > +		.count =3D tss->len,
> >  	};
> > =20
> >  	return tcp_read_sock(sk, &rd_desc, tcp_splice_data_recv);
> >=20
>=20
> OK, I came to a different patch. Please check other tcp_read_sock() c=
allers in tree :)

I've seen the other callers, but they all use desc->count for their own
purpose. That's how I understood what it was used for :-)

I think it's better not to change the API here and use tcp_read_sock()
how it's supposed to be used. Also, the less parameters to the function=
,
the better.

However I'm OK for the !timeo before release_sock/lock_sock. I just
don't know if we can put the rest of the if above or not. I don't
know what changes we're supposed to collect by doing release_sock/
lock_sock before the if().

Regards,
Willy

