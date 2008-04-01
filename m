From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Subject: Re: [PATCH 1 of 5] IPv6: do not wrap around when the lifetime has
	expired
Date: Wed, 2 Apr 2008 00:43:58 +0200
Message-ID: <20080401224358.GA32592@pirzuine>
References: <dd125a7f86968371046d.1206305169@pirzuine> <20080328.032539.66693379.yoshfuji@linux-ipv6.org> <20080327193854.GC8574@ens-lyon.fr> <20080328.120622.73826877.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, pekkas@netcore.fi
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pilet.ens-lyon.fr ([140.77.167.16]:48461 "EHLO
	pilet.ens-lyon.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874AbYDAWoC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 18:44:02 -0400
Content-Disposition: inline
In-Reply-To: <20080328.120622.73826877.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok, I think I missed something.

On Fri, Mar 28, 2008 at 12:06:22PM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20080327193854.GC8574@ens-lyon.fr> (at Thu, 27 Mar 2008 2=
0:38:54 +0100), Benoit Boissinot <benoit.boissinot@ens-lyon.org> says:
>=20
> > On Fri, Mar 28, 2008 at 03:25:39AM +0900, YOSHIFUJI Hideaki / =E5=90=
=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> > > In article <dd125a7f86968371046d.1206305169@pirzuine> (at Sun, 23=
 Mar 2008 21:46:09 +0100), Benoit Boissinot <benoit.boissinot@ens-lyon.=
org> says:
> > >=20
> > > > IPv6: do not wrap around when the lifetime has expired
> > > >=20
> > > > Instead of reporting overly large lifetimes to userspace,
> > > > report a lifetime of 0 when a lifetime has expired.
> > > >=20
> > > > Signed-off-by: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
> > >=20
> > > NAK.
> > >=20
> > > (signed) lifetime < 0 means it has expired, but 0 does not mean
> > > that the lifetime has expired, but it is being expired
> > > (within 1 second).

I re-checked the code, and while it is true that some path takes care
not to use a too big lifetime (one that is > 0x7fffffffUL/HZ), for
example:
- inet6_addr_{add,modify}
there are other places where there are no checks, eg:
- addrconf_prefix_rcv, ipv6_create_tempaddr

=46urthermore, at least for the case of the preferred lifetime, a lifet=
ime
of 0 received from RA means deprecated (=3D=3D expired ?).
And due to the rounding, if age =3D (now - ift->tsamp)/HZ
then (age =3D=3D lifetime) being true means that the lifetime has fully=
 expired right ?

In any case, the current code is buggy, because if preferred =3D=3D 1 a=
nd tval =3D=3D 2,
then we will send INFINITY_LIFETIME to userspace.

=46inally, cstamp and tstamp are sent via netlink, it could be useful t=
o
solve this issue from userspace, but it's useless as it is since the
tstamp sent is relative to the lifetime stored in the kernel, not
relative to the lifetime we send (we should send "jiffies" for it to be
useful).

regards,

Benoit
--=20
:wq
