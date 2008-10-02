From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when gc_elasticity
 is exceeded
Date: Thu, 02 Oct 2008 16:20:52 +0200
Message-ID: <48E4D8C4.6020206@cosmosbay.com>
References: <48E141F3.9000903@cosmosbay.com>	<20080929223801.GA3157@hmsreliant.think-freely.org>	<48E1C104.2080801@cosmosbay.com>	<20080930.071023.07946874.davem@davemloft.net>	<48E25F02.8030303@cosmosbay.com>	<20081001180846.GB3566@hmsreliant.think-freely.org> <20081002010101.6f0a1fa5.billfink@mindspring.com> <48E470AC.10305@cosmosbay.com> <48E4832A.3070804@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2e.orange.fr ([80.12.242.111]:32752 "EHLO smtp2e.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752504AbYJBOVA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 10:21:00 -0400
In-Reply-To: <48E4832A.3070804@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =C3=A9crit :
> Eric Dumazet a =C3=A9crit :
>> Bill Fink a =C3=A9crit :
>>> I believe the general rule of thumb for something like this is at
>>> least two standard deviations.  For a normal distribution, one stan=
dard
>>> deviation covers about 68 % of the sample universe, while two stand=
ard
>>> deviations covers about 95 % (three standard deviations covers 99.7=
3 %).
>>> See the Wikipedia entry:
>>>
>>>     http://en.wikipedia.org/wiki/Standard_deviation
>>>
>>
>> Thanks Bill for the pointer, this is the trick.
>>
>> I believe we should target "4=CF=83 99.993666% " case.
>>
>> But we dont need to really compute Standard deviation at runtime, on=
ly=20
>> find an (upper) approximation of it.
>>
>> For elasticity=3D4 and 512*1024 samples (mean < 4), I guess 4=CF=83 =
can be=20
>> approximated by 20 or something.
>>
>=20
> Good estimation of Standard Deviation could be computed for free
> in rt_check_expire(). (each runs scans 20% of hash table with default=
=20
> tunables timeout & ip_rt_gc_interval)
>=20
> We could update 4=CF=83 estimation in this function, every minute=20
> (ip_rt_gc_interval)
>=20
> At softirq time we then can detect a particular hash chain is
> longer than 4=CF=83 estimation and trigger an appropriate action.
>=20
> This action is to : flush table, and while we do that, expand hash ta=
ble
> if its current size is under ip_rt_max_size/elasticity...
>=20

I ran again my litle dirty program that reads /proc/kcore to explore rt
hash table on a busy server and found :


hptr=3D0xffff81082ec00000 hsize=3D524288
total=3D2299242 dst entries
4306 chains of length 0
23807 chains of length 1
60119 chains of length 2
95112 chains of length 3
106364 chains of length 4
92307 chains of length 5
65743 chains of length 6
39710 chains of length 7
20997 chains of length 8
15775 chains of length 9
39 chains of length 10
7 chains of length 11
2 chains of length 12

avg =3D 4.38546
sd =3D 1.94614
X =3D avg + 4*sd =3D 12.17

I tried various elasticity settings and found litle variations of X

This is because lot of entries are in use (refcnt>1) and can
not be freed, regardless of elasticity.




