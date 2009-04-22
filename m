From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] snmp: add missing counters for RFC 4293
Date: Wed, 22 Apr 2009 19:39:55 +0200
Message-ID: <49EF566B.70203@cosmosbay.com>
References: <49EEA7E3.3080507@cosmosbay.com> <20090422.020837.58106317.davem@davemloft.net> <49EEE4F1.4020705@cosmosbay.com> <20090422.025003.92631170.davem@davemloft.net> <20090422165034.GC17947@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:37519 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750755AbZDVRkF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 13:40:05 -0400
In-Reply-To: <20090422165034.GC17947@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> On Wed, Apr 22, 2009 at 02:50:03AM -0700, David Miller wrote:
>> From: Eric Dumazet <dada1@cosmosbay.com>
>> Date: Wed, 22 Apr 2009 11:35:45 +0200
>>
>>> So RFC4293 tells corresponding Octets variables should be supported=
 :
>>>
>>>  InOctets, InMcastOctets, OutMcastOctets, OutBcastOctets, OutOctets
>>>
>>> And I dont see them in /proc/net/snmp or /proc/net/netstat
>>>
>>> Mitsuru added :
>>>
>>>        SNMP_MIB_ITEM("InNoRoutes", IPSTATS_MIB_INNOROUTES),
>>>        SNMP_MIB_ITEM("InTruncatedPkts", IPSTATS_MIB_INTRUNCATEDPKTS=
),
>>>        SNMP_MIB_ITEM("InMcastPkts", IPSTATS_MIB_INMCASTPKTS),
>>>        SNMP_MIB_ITEM("OutMcastPkts", IPSTATS_MIB_OUTMCASTPKTS),
>>>        SNMP_MIB_ITEM("InBcastPkts", IPSTATS_MIB_INBCASTPKTS),
>>>        SNMP_MIB_ITEM("OutBcastPkts", IPSTATS_MIB_OUTBCASTPKTS),
>>>
>>> And Neil adds : InOctets, OutOctets, InMcastOctets and OutMcastOcte=
ts
>>>
>>> Neil, you forgot OutBcastOctets :)
>> Fair enough.  Neil I wait for an updated patch :-)
>>
>=20
> As promised, new patch, tested and ready to go.  This variant puts al=
l the stats
> at the end of the IpExt stats line in /proc/net/snmp, and at the end =
of
> /proc/net/dev_snmp6/<iface>, so it shouldn't break any readers of tho=
se files.
>=20
> Also, Eric, I know you mentioned the need for OutBcastOctets, and int=
uitively I
> thought it should be there as well, but looking at RFC 4293, [In|Out]=
BcastOctets
> isn't defined.  I started to wonder if perhaps the RFC assumed that M=
castOctets
> was assumed to include broadcast frames (i.e. all hosts multicast), b=
ut I
> decided that the smartest thing to do was correlate McastPkts and Mca=
stOctets.
> If someone wants to make an argument for including broadcast explicit=
ly in both
> counters, then we can deal with that in a subsequent patch.

Yes, I found it on page 7, on diagram.

OutBcastPkts (1) =20

Legend (1) is : (1) The HC counters and octet counters are also found a=
t these points
       but have been left out for clarity.

So apparently RFC forgot OutBcastOctets/InBcastOctets somewhere, oh wel=
l...

We actually have=20

IpExt: InNoRoutes InTruncatedPkts InMcastPkts OutMcastPkts InBcastPkts =
OutBcastPkts

It would make sense to add : InOctets OutOctets InMcastOctets OutMcastO=
ctets InBcastOctets OutBcastOctets
Even if not fully tagged in RFC...


You could actually use new macros, to update both packet count and byte=
s count at once.
(less calls to get_cpu()/put_cpu(), and per_cpu_ptr(), thats pretty exp=
ensive if CONFIG_PREEMPT


#define SNMP_ADD_PB_STATS(mib, bytesfield, bytes, packetsfield) 	\
	do { 	__typeof__(mib) *ptr =3D per_cpu_ptr(mib[!in_softirq()], get_cpu=
()); \
		ptr->mibs[bytesfield] +=3D bytes; \
		ptr->mibs[packetsfield]++; \
		put_cpu(); \
	} while (0)

#define SNMP_ADD_PB_STATS_BH(mib, bytesfield, bytes, packetsfield) 	\
	do { 	__typeof__(mib) *ptr =3D per_cpu_ptr(mib[0], get_cpu()); \
		ptr->mibs[bytesfield] +=3D bytes; \
		ptr->mibs[packetsfield]++; \
		put_cpu(); \
	} while (0)


PB as Packet & Bytes, maybe name is wrong :)

