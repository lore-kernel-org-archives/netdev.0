From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] snmp: add missing counters for RFC 4293
Date: Thu, 23 Apr 2009 13:25:24 -0400
Message-ID: <20090423172524.GC30405@hmsreliant.think-freely.org>
References: <49EEA7E3.3080507@cosmosbay.com> <20090422.020837.58106317.davem@davemloft.net> <49EEE4F1.4020705@cosmosbay.com> <20090422.025003.92631170.davem@davemloft.net> <20090422165034.GC17947@hmsreliant.think-freely.org> <49EF566B.70203@cosmosbay.com> <20090423152823.GA30405@hmsreliant.think-freely.org> <49F09933.2010200@cosmosbay.com> <20090423165620.GB30405@hmsreliant.think-freely.org> <49F0A1C8.5080601@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50114 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752946AbZDWRZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 13:25:33 -0400
Content-Disposition: inline
In-Reply-To: <49F0A1C8.5080601@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 23, 2009 at 07:13:44PM +0200, Eric Dumazet wrote:
> Neil Horman a =E9crit :
> > On Thu, Apr 23, 2009 at 06:37:07PM +0200, Eric Dumazet wrote:
> >> Neil Horman a =E9crit :
> >>> On Wed, Apr 22, 2009 at 07:39:55PM +0200, Eric Dumazet wrote:
> >>>> <previous contents snipped>
> >>>>
> >>>
> >>> ok, new patch, functionally equivalent, with the following enhanc=
ements:
> >>>
> >>> 1) Replaces INRECEIVES/OUTREQUESTS with INPKTS/OUTPKTS.  I did th=
is
> >>>    so that I could use the dual count update in (2) for INPKTS/IN=
OCTETS
> >>>    and OUTPKTS/OUTOCTETS
> >>> 2) Added dual stat update routines for IP/IP6, named *_UPD_PO_STA=
TS[_BH]
> >>>    which updates a pair of stats, a P(acket) count, and an (O)cte=
t count
> >>> 3) Added BCASTPKS/BCASTOCTETS for completeness
> >>>
> >>>
> >>>
> >>> The IP MIB (RFC 4293) defines stats for InOctets, OutOctets, InMc=
astOctets and
> >>> OutMcastOctets:
> >>> http://tools.ietf.org/html/rfc4293
> >>> But it seems we don't track those in any way that easy to separat=
e from other
> >>> protocols.  This patch adds those missing counters to the stats f=
ile. Tested
> >>> successfully by me
> >>>
> >>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> >>>
> >>
> >>
> >>> +#define SNMP_UPD_PO_STATS(mib, basefield, addend)	\
> >>> +	do { \
> >>> +		int __cpu =3D get_cpu(); \
> >>> +		per_cpu_ptr(mib[!in_softirq()], __cpu)->mibs[basefield##PKTS]+=
+; \
> >>> +		per_cpu_ptr(mib[!in_softirq()], __cpu)->mibs[basefield##OCTETS=
] +=3D addend;\
> >>> +		put_cpu(); \
> >>> +	} while (0)
> >> Following should be faster, because per_cpu_ptr() and !in_softirq(=
) factorization.
> >>
> >>> +#define SNMP_UPD_PO_STATS(mib, basefield, addend)	\
> >>> +	do { \
> >>> +		__typeof__(mib[0]) ptr =3D per_cpu_ptr(mib[!in_softirq()], get=
_cpu()); \
> >>> +		ptr->mibs[basefield##PKTS]++; \
> >>> +		ptr->mibs[basefield##OCTETS] +=3D addend;\
> >>> +		put_cpu(); \
> >>> +	} while (0)
> >> BTW, we miss HC (64bits) values on 32bit arches, and some RFC (not=
 4293, but in 4113) mention they
> >>  should be provided if counters can be updated more than 1 million=
 times per second.
> >>
> >> And for Octets counters, this is definitly the case with 100 Mbit =
networks... Oh well
> > Yeah, I was wondering about this.  Think it would be worthwhile to =
export all of
> > these counters as 64 bit, rather than 32 bit?  Userspace can then h=
ave the HC
> > counters, and downcast to the standard 32 bit flavors.  I'd like th=
is patch to
> > stand as it is, but I think that might be a good subsequent change =
to make
>=20
> Well, maintaining 64bits counters on 32bit is going to be hard, since
> we dont want a reader to get mangled values while folding SNMP values=
=20
>=20
> Either we use same tricks than netfilter (so that updates can use reg=
ular ptr->field +=3D bytes)
> and look the mess...
>=20
> Either we use expensive locking...
>=20
> At least, your SNMP_UPD_PO_STATS macros can be changed later if we re=
ally want
> HC values.
>=20
Perhaps we could define the size of each counter at compile time, so th=
at at
least 64 bit systems can have sane counters?

Btw, I will repost one more time to take in the above enhancement you s=
uggested
regarding the limited use of per_cpu_ptr and in_softirq (my last post m=
ade it
sound like I wouldnt)

Neil

>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
