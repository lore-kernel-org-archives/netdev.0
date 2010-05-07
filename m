From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: TCP-MD5 checksum failure on x86_64 SMP
Date: Fri, 7 May 2010 10:14:51 -0700
Message-ID: <20100507101451.1b4286b7@nehalam>
References: <1273085598.2367.233.camel@edumazet-laptop>
	<i2y571fb4001005060455m39bed7f7if5fcfc45b12bc4d3@mail.gmail.com>
	<1273147586.2357.63.camel@edumazet-laptop>
	<20100506.220443.135536330.davem@davemloft.net>
	<1273210329.2222.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bhaskie@gmail.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56067 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752591Ab0EGRPF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 13:15:05 -0400
In-Reply-To: <1273210329.2222.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 07 May 2010 07:32:09 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le jeudi 06 mai 2010 =E0 22:04 -0700, David Miller a =E9crit :
> > From: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> > > This code should be completely rewritten for linux-2.6.35, its ve=
ry ugly
> > > and over complex, yet it is not scalable.
> > >=20
> > > It could use true percpu data, with no central lock or refcount.
> >=20
> > Yes I've always disliked the way the TCP MD5 pool stuff is coded, i=
t's
> > frankly crap and this is like the 5th major bug that had to get fix=
ed
> > in it. :-)
> >=20
> > But let's fix this as simply as possible in net-2.6 and -stable, so=
 Eric
> > let me know when you have a tested patch for me to apply.
>=20
> There are so many things ...
>=20
> I am comtemplating commit aa133076
>=20
> __tcp_alloc_md5sig_pool() now do a :=20
>=20
> p =3D kzalloc(sizeof(*p), sk->sk_allocation);
>=20
> But later call :
>=20
> hash =3D crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
>=20
> (GFP_KERNEL allocations for sure)
>=20
>=20
> tcp_v4_parse_md5_keys() also use :
>=20
> p =3D kzalloc(sizeof(*p), sk->sk_allocation);
>=20
> right after a (possibly sleeping) copy_from_user()
>=20
> Oh well...
>=20
>=20
> I'll test the already suggested patch before official submission,
> thanks.

=46orget the per cpu data; the pool should just be scrapped.

The only reason the pool exists is that the crypto hash state which
should just be moved into the md5_info (88 bytes).  The pseudo
header can just be generated on the stack before passing to the crypto
code.

