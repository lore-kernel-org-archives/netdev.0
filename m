From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when gc_elasticity
 is exceeded
Date: Thu, 02 Oct 2008 10:15:38 +0200
Message-ID: <48E4832A.3070804@cosmosbay.com>
References: <48E141F3.9000903@cosmosbay.com>	<20080929223801.GA3157@hmsreliant.think-freely.org>	<48E1C104.2080801@cosmosbay.com>	<20080930.071023.07946874.davem@davemloft.net>	<48E25F02.8030303@cosmosbay.com>	<20081001180846.GB3566@hmsreliant.think-freely.org> <20081002010101.6f0a1fa5.billfink@mindspring.com> <48E470AC.10305@cosmosbay.com>
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
Received: from smtp2e.orange.fr ([80.12.242.111]:61217 "EHLO smtp2e.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752263AbYJBITq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 04:19:46 -0400
In-Reply-To: <48E470AC.10305@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =C3=A9crit :
> Bill Fink a =C3=A9crit :
>> On Wed, 1 Oct 2008, Neil Horman wrote:
>>
>>> Hey all-
>>>     Since Eric mentioned the use of statistical analysis to determi=
ne if
>>> hash chains were growing improperly, I thought I would take a stab =
at=20
>>> such an
>>> approach.  I'm no statistics expert, but it would seem to me that s=
imply
>>> computing the standard deviation of all the non-zero chain lengths=20
>>> would give a
>>> good guide point to determine if we needed to invalidate our hash=20
>>> table.  I've
>>> written the below implementation.  I've not tested it (I'll be doin=
g=20
>>> that here
>>> shortly for the next few days), but I wanted to post it to get=20
>>> feedback from you
>>> all on the subject.  The highlights are:
>>>
>>> 1) We add a counter to rt_hash_bucket structure to track the length=
=20
>>> of each
>>> individual chain.  I realize this is sub-optimal, as it adds=20
>>> potentially lots of
>>> memory to hash table as a whole (4 bytes * number of hash buckets).=
 =20
>>> I'm afraid
>>> I've not come up with a better way to track that yet.  We also trac=
k=20
>>> the total
>>> number of route entries and the number of non-zero length chains. =20
>>> Lastly we
>>> also maintain a global maximum chain length which defines the longe=
st=20
>>> chain we
>>> will tolerate in the route table.  This patch defines it as the mea=
n=20
>>> chain
>>> length plus one standard deviation.
>>
>> I believe the general rule of thumb for something like this is at
>> least two standard deviations.  For a normal distribution, one stand=
ard
>> deviation covers about 68 % of the sample universe, while two standa=
rd
>> deviations covers about 95 % (three standard deviations covers 99.73=
 %).
>> See the Wikipedia entry:
>>
>>     http://en.wikipedia.org/wiki/Standard_deviation
>>
>=20
> Thanks Bill for the pointer, this is the trick.
>=20
> I believe we should target "4=CF=83 99.993666% " case.
>=20
> But we dont need to really compute Standard deviation at runtime, onl=
y=20
> find an (upper) approximation of it.
>=20
> For elasticity=3D4 and 512*1024 samples (mean < 4), I guess 4=CF=83 c=
an be=20
> approximated by 20 or something.
>=20

Good estimation of Standard Deviation could be computed for free
in rt_check_expire(). (each runs scans 20% of hash table with=20
default tunables timeout & ip_rt_gc_interval)

We could update 4=CF=83 estimation in this function, every minute (ip_r=
t_gc_interval)

At softirq time we then can detect a particular hash chain is
longer than 4=CF=83 estimation and trigger an appropriate action.

This action is to : flush table, and while we do that, expand hash tabl=
e
if its current size is under ip_rt_max_size/elasticity...




