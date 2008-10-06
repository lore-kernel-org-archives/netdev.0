From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
	gc_elasticity is exceeded
Date: Mon, 6 Oct 2008 18:52:10 -0400
Message-ID: <20081006225210.GA29794@hmsreliant.think-freely.org>
References: <48E25F02.8030303@cosmosbay.com> <20081001180846.GB3566@hmsreliant.think-freely.org> <20081002010101.6f0a1fa5.billfink@mindspring.com> <48E470AC.10305@cosmosbay.com> <48E4832A.3070804@cosmosbay.com> <20081003003158.GA19230@localhost.localdomain> <20081003203640.GA13354@hmsreliant.think-freely.org> <48E9ED3D.2020005@cosmosbay.com> <20081006205422.GD16939@hmsreliant.think-freely.org> <48EA8162.4050409@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bill Fink <billfink@mindspring.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46184 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752970AbYJFWyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 18:54:16 -0400
Content-Disposition: inline
In-Reply-To: <48EA8162.4050409@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 06, 2008 at 11:21:38PM +0200, Eric Dumazet wrote:
> Neil Horman a =E9crit :
>> So, I've been playing with this patch, and I've not figured out eact=
ly whats
>> bothering me yet, since the math seems right, but something doesn't =
seem right
>> about the outcome of this algorithm.  I've tested with my local syst=
em, and all
>> works well, because the route cache is well behaved, and the sd valu=
e always
>> works out to be very small, so ip_rt_gc_elasticity is used.  So I've=
 been
>> working through some scenarios by hand to see what this looks like u=
sing larger
>> numbers.  If i assume ip_rt_gc_interval is 60, and rt_hash_log is 17=
, my sample
>> count here is 7864320 samples per run.  If within that sample 393216=
 (about 4%)
>> of the buckets have one entry on the chain, and all the rest are zer=
os, my hand
>> calculations result in a standard deviation of approximately 140 and=
 an average
>> of .4.  That imples that in that sample set any one chain could be a=
lmost 500
>> entires long before it triggered a cache rebuld.  Does that seem rea=
sonable?
>>
>
> if rt_hash_log is 17, and interval is 60, then you should scan (60 <<=
=20
> 17)/300 slots. That's 26214 slots. (ie 20% of the 2^17 slots)
>
> I have no idea how you can have sd =3D 140, even if scaled by (1 << 3=
)
> with slots being empty or with one entry only...
>
I don't either, that was my concern :).

> If 4% of your slots have one element, then average length is 0.04 :)
>
Yes, and the average worked out properly, which is why I was concerned.

If you take an even simpler case, like you state above (I admit I misee=
d the
/300 part of the sample, but no matter).

samples =3D 26214
Assume each sample has a chain length of 1

sum =3D 26214 * (1 << 3) =3D 209712
sum2 =3D sum * sum =3D s09712 * 209712 =3D 43979122944
avg =3D sum / samples =3D 209712 / 26214 =3D 8 (correct)
sd =3D sqrt(sum2 / samples - avg*avg) =3D sqrt(43979122944/26214 - 64) =
=3D 1295
sd >> 3 =3D 1295.23 >> 3 =3D 161


Clearly, given the assumption that every chain in the sample set has 1 =
entry,
giving us an average of one, the traditional method of computing standa=
rd
deviation should have yielded an sd of 0 exactly, since every sample wa=
s
precisely the average. However, the math above gives us something signi=
ficantly
larger.  I'm hoping I missed something, but I don't think I have. =20

Neil

>
>
>
>
>

--=20
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
