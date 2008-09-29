From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when
	gc_elasticity is exceeded
Date: Mon, 29 Sep 2008 18:38:01 -0400
Message-ID: <20080929223801.GA3157@hmsreliant.think-freely.org>
References: <20080929191254.GA20074@hmsreliant.think-freely.org> <48E138EB.1080001@cosmosbay.com> <20080929202731.GC20074@hmsreliant.think-freely.org> <48E141F3.9000903@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, davem@davemloft.net,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43519 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061AbYI2WkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 18:40:08 -0400
Content-Disposition: inline
In-Reply-To: <48E141F3.9000903@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 11:00:35PM +0200, Eric Dumazet wrote:
> Neil Horman a =E9crit :
>> On Mon, Sep 29, 2008 at 10:22:03PM +0200, Eric Dumazet wrote:
>>> Neil Horman a =E9crit :
>>>> Hey all-
>>>> 	We currently have the ability to disable our route cache secret i=
nterval
>>>> rebuild timer (by setting it to zero), but if we do that its possi=
ble for an
>>>> attacker (if they guess our route cache hash secret, to fill our s=
ystem with
>>>> routes that all hash to the same bucket, destroying our performanc=
e.  This patch
>>>> provides a backstop for that issues.  In the event that our rebuil=
d interval is
>>>> disabled (or very large), if any hash chain exceeds ip_rt_gc_elast=
icity, we do
>>>> an emergency hash rebuild.  During the hash rebuild we:
>>>> 1) warn the user of the emergency
>>>> 2) disable the rebuild timer
>>>> 3) invalidate the route caches
>>>> 4) re-enable the rebuild timer with its old value
>>>>
>>>> Regards
>>>> Neil
>>> This sounds not good at all to me.
>>>
>>> 1) Dont set ip_rt_secret_interval to zero, this is plain silly, sin=
ce
>>>   you give attackers infinite time to break your machine.
>>>
>>> To quote Herbert (who allowed to set this interval to 0)
>>>
>>>    "Let me first state that disabling the route cache hash rebuild
>>>     should not be done without extensive analysis on the risk profi=
le
>>>     and careful deliberation.
>>>
>>>     However, there are times when this can be done safely or for
>>>     testing.  For example, when you have mechanisms for ensuring
>>>     that offending parties do not exist in your network."
>>>
>> Thats really rather the motivation behind this.  The patch that Herb=
ert
>> submitted with that commit explicitly lets one disable their rebuild=
 timer.  I
>> agree its stupid to do that, but we added code to allow it.  This pr=
ovides a
>> patch to help people who are victimized because they've done exactly=
 this
>> (additionaly providing them a warning to stop doing it).
>
> Strange... many kernel parameters can be set to hazardous values that=
 make machine unusable...
>
> ip_rt_gc_interval can also be set to a very large value : No more rou=
te cache gc
>
If you want to talk philosophy, then I accept your premise: we can tune=
 the
kernel in ways that make it unusable.  Does that mean we should avoid d=
oing
things to prevent that and maintain usibility.  Ithink this patch accom=
plishes
that goal in its small way.
=20
>>
>>
>>> 2) Many machines have ip_rt_gc_elasticity set to 2,
>>>   because they have a huge hash table, but low chain depths.
>> Ok, that seem reasonable, and this isn't going to disallow that.  By=
 the same
>> resoning, people who have huge hash tables, and low chain depths won=
't
>> want their low chain length being violated, would they?  This patch =
will warn
>> them if their assumptions are being violated.
>
> Warn only ? If I read your patch, you not only warn in this case.
No, not warn only, Warn and correct is the clear intent here

> (you invalidate cache for each struct net, potentially wraping rt_gen=
id)
>
If you overflow your elasticity 2^16 times, yes (I think rt_genid is a =
16 bit
value, but I don't have the kernel in front of me).  I would hope that =
would be
enough warnings to make a sysadmin address the problem

> When you have 2^20 slots in route cache hash table, you dont care if =
few slots have 3 or 4 elements.
> And chance is very high that more than one slot has 3 or even 4 eleme=
nts, no need for an attacker.
Ok, then I would assert if your ok with a few chains getting to be X en=
tries in
length, then you should set your elasticity to be X.

>
> Now if you change your code to something like
>
> if (unlikely(chain_length > some_quite_big_number &&
>     ip_rt_secret_interval =3D=3D 0)) {
> 	do_something();
> }
>
> some_quite_big_number could be >=3D 30 or something...
>
I'd be ok with that, if some others chimed in with consensus on the mat=
ter.  I
felt that we had a value definining what chain length should be
(ip_rt_gc_elasticity is already used in comparison on chain length in
rt_intern_hash, so I was keeping with that).  But if some others speak =
up and
support a new sysctl, I can get behind that

> then it might be OK (at least it wont break common setups)
>
I don't think it will break many setups, the default value is 8 for thi=
s sysctl.
If someone has set it lower, and sees a warning, they won't loose their=
 system
altogether, they'll just see a momentary reduction in throughput, and a
warning to increase the value they have set.  Its going to far to say a=
nything
will 'break'.

Thanks & Regards
Neil

>
>
>

--=20
/****************************************************
 * Neil Horman <nhorman@tuxdriver.com>
 * Software Engineer, Red Hat
 ****************************************************/
