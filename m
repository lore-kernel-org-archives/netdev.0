From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] snmp: add missing counters for RFC 4293
Date: Wed, 22 Apr 2009 14:44:11 -0400
Message-ID: <20090422184411.GE17947@hmsreliant.think-freely.org>
References: <49EEA7E3.3080507@cosmosbay.com> <20090422.020837.58106317.davem@davemloft.net> <49EEE4F1.4020705@cosmosbay.com> <20090422.025003.92631170.davem@davemloft.net> <20090422165034.GC17947@hmsreliant.think-freely.org> <49EF566B.70203@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:47722 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750743AbZDVSoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 14:44:21 -0400
Content-Disposition: inline
In-Reply-To: <49EF566B.70203@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 22, 2009 at 07:39:55PM +0200, Eric Dumazet wrote:
> Neil Horman a =E9crit :
> > On Wed, Apr 22, 2009 at 02:50:03AM -0700, David Miller wrote:
> >> From: Eric Dumazet <dada1@cosmosbay.com>
> >> Date: Wed, 22 Apr 2009 11:35:45 +0200
> >>
> >>> So RFC4293 tells corresponding Octets variables should be support=
ed :
> >>>
> >>>  InOctets, InMcastOctets, OutMcastOctets, OutBcastOctets, OutOcte=
ts
> >>>
> >>> And I dont see them in /proc/net/snmp or /proc/net/netstat
> >>>
> >>> Mitsuru added :
> >>>
> >>>        SNMP_MIB_ITEM("InNoRoutes", IPSTATS_MIB_INNOROUTES),
> >>>        SNMP_MIB_ITEM("InTruncatedPkts", IPSTATS_MIB_INTRUNCATEDPK=
TS),
> >>>        SNMP_MIB_ITEM("InMcastPkts", IPSTATS_MIB_INMCASTPKTS),
> >>>        SNMP_MIB_ITEM("OutMcastPkts", IPSTATS_MIB_OUTMCASTPKTS),
> >>>        SNMP_MIB_ITEM("InBcastPkts", IPSTATS_MIB_INBCASTPKTS),
> >>>        SNMP_MIB_ITEM("OutBcastPkts", IPSTATS_MIB_OUTBCASTPKTS),
> >>>
> >>> And Neil adds : InOctets, OutOctets, InMcastOctets and OutMcastOc=
tets
> >>>
> >>> Neil, you forgot OutBcastOctets :)
> >> Fair enough.  Neil I wait for an updated patch :-)
> >>
> >=20
> > As promised, new patch, tested and ready to go.  This variant puts =
all the stats
> > at the end of the IpExt stats line in /proc/net/snmp, and at the en=
d of
> > /proc/net/dev_snmp6/<iface>, so it shouldn't break any readers of t=
hose files.
> >=20
> > Also, Eric, I know you mentioned the need for OutBcastOctets, and i=
ntuitively I
> > thought it should be there as well, but looking at RFC 4293, [In|Ou=
t]BcastOctets
> > isn't defined.  I started to wonder if perhaps the RFC assumed that=
 McastOctets
> > was assumed to include broadcast frames (i.e. all hosts multicast),=
 but I
> > decided that the smartest thing to do was correlate McastPkts and M=
castOctets.
> > If someone wants to make an argument for including broadcast explic=
itly in both
> > counters, then we can deal with that in a subsequent patch.
>=20
> Yes, I found it on page 7, on diagram.
>=20
> OutBcastPkts (1) =20
>=20
> Legend (1) is : (1) The HC counters and octet counters are also found=
 at these points
>        but have been left out for clarity.
>=20
> So apparently RFC forgot OutBcastOctets/InBcastOctets somewhere, oh w=
ell...
>=20
> We actually have=20
>=20
> IpExt: InNoRoutes InTruncatedPkts InMcastPkts OutMcastPkts InBcastPkt=
s OutBcastPkts
>=20
> It would make sense to add : InOctets OutOctets InMcastOctets OutMcas=
tOctets InBcastOctets OutBcastOctets
> Even if not fully tagged in RFC...
>=20
I suppose, I'm just trying to avoid collecting data for stats that the =
snmp
agent doesn't recognize the oid for, but I suppose it couldn't hurt.

>=20
> You could actually use new macros, to update both packet count and by=
tes count at once.
> (less calls to get_cpu()/put_cpu(), and per_cpu_ptr(), thats pretty e=
xpensive if CONFIG_PREEMPT
>=20
>=20
> #define SNMP_ADD_PB_STATS(mib, bytesfield, bytes, packetsfield) 	\
> 	do { 	__typeof__(mib) *ptr =3D per_cpu_ptr(mib[!in_softirq()], get_c=
pu()); \
> 		ptr->mibs[bytesfield] +=3D bytes; \
> 		ptr->mibs[packetsfield]++; \
> 		put_cpu(); \
> 	} while (0)
>=20
> #define SNMP_ADD_PB_STATS_BH(mib, bytesfield, bytes, packetsfield) 	\
> 	do { 	__typeof__(mib) *ptr =3D per_cpu_ptr(mib[0], get_cpu()); \
> 		ptr->mibs[bytesfield] +=3D bytes; \
> 		ptr->mibs[packetsfield]++; \
> 		put_cpu(); \
> 	} while (0)
>=20
>=20
> PB as Packet & Bytes, maybe name is wrong :)
>=20
Yeah, that makes sense, and I like the way it looks a bit better.  I'll=
 update
the patch later this evening

Thanks!
Neil


>=20
