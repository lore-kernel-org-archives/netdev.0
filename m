From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
	gc_elasticity is exceeded
Date: Tue, 7 Oct 2008 06:54:59 -0400
Message-ID: <20081007105459.GA1455@hmsreliant.think-freely.org>
References: <20081002010101.6f0a1fa5.billfink@mindspring.com> <48E470AC.10305@cosmosbay.com> <48E4832A.3070804@cosmosbay.com> <20081003003158.GA19230@localhost.localdomain> <20081003203640.GA13354@hmsreliant.think-freely.org> <48E9ED3D.2020005@cosmosbay.com> <20081006205422.GD16939@hmsreliant.think-freely.org> <48EA8162.4050409@cosmosbay.com> <20081006225210.GA29794@hmsreliant.think-freely.org> <48EAEFF9.1000606@cosmosbay.com>
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
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35559 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752850AbYJGK51 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 06:57:27 -0400
Content-Disposition: inline
In-Reply-To: <48EAEFF9.1000606@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 07, 2008 at 07:13:29AM +0200, Eric Dumazet wrote:
> Neil Horman a =E9crit :
>> On Mon, Oct 06, 2008 at 11:21:38PM +0200, Eric Dumazet wrote:
>>> Neil Horman a =E9crit :
>>>> So, I've been playing with this patch, and I've not figured out ea=
ctly whats
>>>> bothering me yet, since the math seems right, but something doesn'=
t seem right
>>>> about the outcome of this algorithm.  I've tested with my local sy=
stem, and all
>>>> works well, because the route cache is well behaved, and the sd va=
lue always
>>>> works out to be very small, so ip_rt_gc_elasticity is used.  So I'=
ve been
>>>> working through some scenarios by hand to see what this looks like=
 using larger
>>>> numbers.  If i assume ip_rt_gc_interval is 60, and rt_hash_log is =
17, my sample
>>>> count here is 7864320 samples per run.  If within that sample 3932=
16 (about 4%)
>>>> of the buckets have one entry on the chain, and all the rest are z=
eros, my hand
>>>> calculations result in a standard deviation of approximately 140 a=
nd an average
>>>> of .4.  That imples that in that sample set any one chain could be=
 almost 500
>>>> entires long before it triggered a cache rebuld.  Does that seem r=
easonable?
>>>>
>>> if rt_hash_log is 17, and interval is 60, then you should scan (60 =
<<=20
>>> 17)/300 slots. That's 26214 slots. (ie 20% of the 2^17 slots)
>>>
>>> I have no idea how you can have sd =3D 140, even if scaled by (1 <<=
 3)
>>> with slots being empty or with one entry only...
>>>
>> I don't either, that was my concern :).
>>
>>> If 4% of your slots have one element, then average length is 0.04 :=
)
>>>
>> Yes, and the average worked out properly, which is why I was concern=
ed.
>>
>> If you take an even simpler case, like you state above (I admit I mi=
seed the
>> /300 part of the sample, but no matter).
>>
>> samples =3D 26214
>> Assume each sample has a chain length of 1
>>
>> sum =3D 26214 * (1 << 3) =3D 209712
>> sum2 =3D sum * sum =3D s09712 * 209712 =3D 43979122944
>> avg =3D sum / samples =3D 209712 / 26214 =3D 8 (correct)
>> sd =3D sqrt(sum2 / samples - avg*avg) =3D sqrt(43979122944/26214 - 6=
4) =3D 1295
>> sd >> 3 =3D 1295.23 >> 3 =3D 161
>>
>>
>> Clearly, given the assumption that every chain in the sample set has=
 1 entry,
>> giving us an average of one, the traditional method of computing sta=
ndard
>> deviation should have yielded an sd of 0 exactly, since every sample=
 was
>> precisely the average. However, the math above gives us something si=
gnificantly
>> larger.  I'm hoping I missed something, but I don't think I have. =20
>>
>
> Famous last sentence ;)
>
> You made some errors in your hand calculations.
> sum2 is the sum of squares. Its not sum * sum.
>
> If all slots have one entry, all "lengths" are (1<<3), and their 'squ=
are=20
> scaled by 6' is (1 << 6) . So sum2 =3D 26214 * (1 << 6) =3D 1677696
> avg =3D sum / samples =3D 209712 / 26214 =3D (1 << 3)
> sd =3D sqrt(sum2 / samples - avg*avg) =3D sqrt(64 - 64) =3D 0 (this i=
s what we expected)
>
> Now if you have 4 % of slots with one entry, and 96 % that are empty,
> you should have /* real maths */
> avg =3D 0.04
> sd =3D sqrt(0.04 - 0.04*0.04) =3D sqrt(0.0384) =3D 0.195959
> avg + 4*sd =3D 0.82
>
> /* fixed point math */
> sum =3D 0.04 * 26214 * (1<<3) =3D 1048 * (1<<3) =3D 8384 sum2 =3D 104=
8 * (1 << 6)=20
> =3D 67072
> avg << 3 =3D 8384/26214 =3D 0   (with 3 bits for fractional part, we =
do have rounding error)
> sd << 3 =3D sqrt(67072/26214 - 0) =3D 1
> (avg + 4*sd) << 3 =3D 4  -> final result is 4>>3 =3D 0 (expected)
>
> Now if 50% of slots have one entry, we get :
> /* real maths */
> avg =3D 0.5
> sd =3D sqrt(0.5 - 0.5*0.5) =3D sqrt(0.25) =3D 0.5
> avg + 4*sd =3D 2.5
>
> /* fixed point math */
> sum =3D 0.5 * 26214 * (1<<3) =3D 104856
> sum2 =3D 13107 * (1<<6) =3D 838848
> avg << 3 =3D 104856/26214 =3D 4
> sd << 3 =3D sqrt(838848/26214 - 4*4) =3D sqrt(32 - 16) =3D 4 (avg + 4=
*sd) << 3=20
> =3D 20  -> final result is 20>>3 =3D 2 (expected)
>
>
> Hope this helps
>


Gaaa! Yes, embarrasing as it may be, that clarifies it for me.  Sorry, =
I missed
the the fact that sum2 is the sum of squares rather than the sqare of t=
he sum.
Stupid of me.  Ok, so this actually works rather well then. I'll keep t=
esting.

Thanks!
Neil

>
>
>

--=20
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
