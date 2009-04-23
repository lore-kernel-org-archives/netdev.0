From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] snmp: add missing counters for RFC 4293
Date: Thu, 23 Apr 2009 12:56:20 -0400
Message-ID: <20090423165620.GB30405@hmsreliant.think-freely.org>
References: <49EEA7E3.3080507@cosmosbay.com> <20090422.020837.58106317.davem@davemloft.net> <49EEE4F1.4020705@cosmosbay.com> <20090422.025003.92631170.davem@davemloft.net> <20090422165034.GC17947@hmsreliant.think-freely.org> <49EF566B.70203@cosmosbay.com> <20090423152823.GA30405@hmsreliant.think-freely.org> <49F09933.2010200@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39481 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbZDWQ4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 12:56:24 -0400
Content-Disposition: inline
In-Reply-To: <49F09933.2010200@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 23, 2009 at 06:37:07PM +0200, Eric Dumazet wrote:
> Neil Horman a =E9crit :
> > On Wed, Apr 22, 2009 at 07:39:55PM +0200, Eric Dumazet wrote:
> >> <previous contents snipped>
> >>
> >=20
> >=20
> > ok, new patch, functionally equivalent, with the following enhancem=
ents:
> >=20
> > 1) Replaces INRECEIVES/OUTREQUESTS with INPKTS/OUTPKTS.  I did this
> >    so that I could use the dual count update in (2) for INPKTS/INOC=
TETS
> >    and OUTPKTS/OUTOCTETS
> > 2) Added dual stat update routines for IP/IP6, named *_UPD_PO_STATS=
[_BH]
> >    which updates a pair of stats, a P(acket) count, and an (O)ctet =
count
> > 3) Added BCASTPKS/BCASTOCTETS for completeness
> >=20
> >=20
> >=20
> > The IP MIB (RFC 4293) defines stats for InOctets, OutOctets, InMcas=
tOctets and
> > OutMcastOctets:
> > http://tools.ietf.org/html/rfc4293
> > But it seems we don't track those in any way that easy to separate =
from other
> > protocols.  This patch adds those missing counters to the stats fil=
e. Tested
> > successfully by me
> >=20
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >=20
>=20
>=20
>=20
> > +#define SNMP_UPD_PO_STATS(mib, basefield, addend)	\
> > +	do { \
> > +		int __cpu =3D get_cpu(); \
> > +		per_cpu_ptr(mib[!in_softirq()], __cpu)->mibs[basefield##PKTS]++;=
 \
> > +		per_cpu_ptr(mib[!in_softirq()], __cpu)->mibs[basefield##OCTETS] =
+=3D addend;\
> > +		put_cpu(); \
> > +	} while (0)
>=20
> Following should be faster, because per_cpu_ptr() and !in_softirq() f=
actorization.
>=20
> > +#define SNMP_UPD_PO_STATS(mib, basefield, addend)	\
> > +	do { \
> > +		__typeof__(mib[0]) ptr =3D per_cpu_ptr(mib[!in_softirq()], get_c=
pu()); \
> > +		ptr->mibs[basefield##PKTS]++; \
> > +		ptr->mibs[basefield##OCTETS] +=3D addend;\
> > +		put_cpu(); \
> > +	} while (0)
>=20
> BTW, we miss HC (64bits) values on 32bit arches, and some RFC (not 42=
93, but in 4113) mention they
>  should be provided if counters can be updated more than 1 million ti=
mes per second.
>=20
> And for Octets counters, this is definitly the case with 100 Mbit net=
works... Oh well
Yeah, I was wondering about this.  Think it would be worthwhile to expo=
rt all of
these counters as 64 bit, rather than 32 bit?  Userspace can then have =
the HC
counters, and downcast to the standard 32 bit flavors.  I'd like this p=
atch to
stand as it is, but I think that might be a good subsequent change to m=
ake

Neil

>=20
>=20
