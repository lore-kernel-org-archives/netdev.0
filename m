From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] net: fold network name hash (v2)
Date: Wed, 28 Oct 2009 08:57:27 -0700
Message-ID: <20091028085727.7fc09ab0@nehalam>
References: <9986527.24561256620662709.JavaMail.root@tahiti.vyatta.com>
	<19864844.24581256620784317.JavaMail.root@tahiti.vyatta.com>
	<20091026.222428.80364204.davem@davemloft.net>
	<20091027102251.244ee681@nehalam>
	<20091027150436.56e673cd@nehalam>
	<4AE7DF8E.3020607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, opurdila@ixiacom.com,
	viro@zeniv.linux.org.uk
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56073 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754634AbZJ1P52 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 11:57:28 -0400
In-Reply-To: <4AE7DF8E.3020607@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Oct 2009 07:07:10 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > The full_name_hash does not produce a value that is evenly distribu=
ted
> > over the lower 8 bits. This causes name hash to be unbalanced with =
large
> > number of names. There is a standard function to fold in upper bits
> > so use that.
> >=20
> > This is independent of possible improvements to full_name_hash()
> > in future.
>=20
> >  static inline struct hlist_head *dev_name_hash(struct net *net, co=
nst char *name)
> >  {
> >  	unsigned hash =3D full_name_hash(name, strnlen(name, IFNAMSIZ));
> > -	return &net->dev_name_head[hash & ((1 << NETDEV_HASHBITS) - 1)];
> > +	return &net->dev_name_head[hash_long(hash, NETDEV_HASHBITS)];
> >  }
> > =20
> >  static inline struct hlist_head *dev_index_hash(struct net *net, i=
nt ifindex)
>=20
> full_name_hash() returns an "unsigned int", which is guaranteed to be=
 32 bits
>=20
> You should therefore use hash_32(hash, NETDEV_HASHBITS),
> not hash_long() that maps to hash_64() on 64 bit arches, which is
> slower and certainly not any better with a 32bits input.

OK, I was following precedent. Only a couple places use hash_32, most u=
se
hash_long().

Using the upper bits does give better distribution.
With 100,000 network names:

               Time       Ratio       Max   StdDev
hash_32       0.002123     1.00       422  11.07
hash_64       0.002927     1.00       400   3.97

The time field is pretty meaningless for such a small sample
