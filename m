From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] snmp: add missing counters for RFC 4293
Date: Thu, 23 Apr 2009 18:37:07 +0200
Message-ID: <49F09933.2010200@cosmosbay.com>
References: <49EEA7E3.3080507@cosmosbay.com> <20090422.020837.58106317.davem@davemloft.net> <49EEE4F1.4020705@cosmosbay.com> <20090422.025003.92631170.davem@davemloft.net> <20090422165034.GC17947@hmsreliant.think-freely.org> <49EF566B.70203@cosmosbay.com> <20090423152823.GA30405@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47709 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751422AbZDWQhU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 12:37:20 -0400
In-Reply-To: <20090423152823.GA30405@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> On Wed, Apr 22, 2009 at 07:39:55PM +0200, Eric Dumazet wrote:
>> <previous contents snipped>
>>
>=20
>=20
> ok, new patch, functionally equivalent, with the following enhancemen=
ts:
>=20
> 1) Replaces INRECEIVES/OUTREQUESTS with INPKTS/OUTPKTS.  I did this
>    so that I could use the dual count update in (2) for INPKTS/INOCTE=
TS
>    and OUTPKTS/OUTOCTETS
> 2) Added dual stat update routines for IP/IP6, named *_UPD_PO_STATS[_=
BH]
>    which updates a pair of stats, a P(acket) count, and an (O)ctet co=
unt
> 3) Added BCASTPKS/BCASTOCTETS for completeness
>=20
>=20
>=20
> The IP MIB (RFC 4293) defines stats for InOctets, OutOctets, InMcastO=
ctets and
> OutMcastOctets:
> http://tools.ietf.org/html/rfc4293
> But it seems we don't track those in any way that easy to separate fr=
om other
> protocols.  This patch adds those missing counters to the stats file.=
 Tested
> successfully by me
>=20
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>=20



> +#define SNMP_UPD_PO_STATS(mib, basefield, addend)	\
> +	do { \
> +		int __cpu =3D get_cpu(); \
> +		per_cpu_ptr(mib[!in_softirq()], __cpu)->mibs[basefield##PKTS]++; \
> +		per_cpu_ptr(mib[!in_softirq()], __cpu)->mibs[basefield##OCTETS] +=3D=
 addend;\
> +		put_cpu(); \
> +	} while (0)

=46ollowing should be faster, because per_cpu_ptr() and !in_softirq() f=
actorization.

> +#define SNMP_UPD_PO_STATS(mib, basefield, addend)	\
> +	do { \
> +		__typeof__(mib[0]) ptr =3D per_cpu_ptr(mib[!in_softirq()], get_cpu=
()); \
> +		ptr->mibs[basefield##PKTS]++; \
> +		ptr->mibs[basefield##OCTETS] +=3D addend;\
> +		put_cpu(); \
> +	} while (0)

BTW, we miss HC (64bits) values on 32bit arches, and some RFC (not 4293=
, but in 4113) mention they
 should be provided if counters can be updated more than 1 million time=
s per second.

And for Octets counters, this is definitly the case with 100 Mbit netwo=
rks... Oh well

