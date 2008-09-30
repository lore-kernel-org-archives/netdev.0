From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when	gc_elasticity
 is exceeded
Date: Tue, 30 Sep 2008 08:02:44 +0200
Message-ID: <48E1C104.2080801@cosmosbay.com>
References: <20080929191254.GA20074@hmsreliant.think-freely.org> <48E138EB.1080001@cosmosbay.com> <20080929202731.GC20074@hmsreliant.think-freely.org> <48E141F3.9000903@cosmosbay.com> <20080929223801.GA3157@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, davem@davemloft.net,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.152]:42263 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751158AbYI3GC4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2008 02:02:56 -0400
In-Reply-To: <20080929223801.GA3157@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> On Mon, Sep 29, 2008 at 11:00:35PM +0200, Eric Dumazet wrote:
>> Neil Horman a =E9crit :
>>> On Mon, Sep 29, 2008 at 10:22:03PM +0200, Eric Dumazet wrote:
>>>> Neil Horman a =E9crit :
>>>>> Hey all-
>>>>> 	We currently have the ability to disable our route cache secret =
interval
>>>>> rebuild timer (by setting it to zero), but if we do that its poss=
ible for an
>>>>> attacker (if they guess our route cache hash secret, to fill our =
system with
>>>>> routes that all hash to the same bucket, destroying our performan=
ce.  This patch
>>>>> provides a backstop for that issues.  In the event that our rebui=
ld interval is
>>>>> disabled (or very large), if any hash chain exceeds ip_rt_gc_elas=
ticity, we do
>>>>> an emergency hash rebuild.  During the hash rebuild we:
>>>>> 1) warn the user of the emergency
>>>>> 2) disable the rebuild timer
>>>>> 3) invalidate the route caches
>>>>> 4) re-enable the rebuild timer with its old value
>>>>>
>>>>> Regards
>>>>> Neil
>>>> This sounds not good at all to me.
>>>>
>>>> 1) Dont set ip_rt_secret_interval to zero, this is plain silly, si=
nce
>>>>   you give attackers infinite time to break your machine.
>>>>
>>>> To quote Herbert (who allowed to set this interval to 0)
>>>>
>>>>    "Let me first state that disabling the route cache hash rebuild
>>>>     should not be done without extensive analysis on the risk prof=
ile
>>>>     and careful deliberation.
>>>>
>>>>     However, there are times when this can be done safely or for
>>>>     testing.  For example, when you have mechanisms for ensuring
>>>>     that offending parties do not exist in your network."
>>>>
>>> Thats really rather the motivation behind this.  The patch that Her=
bert
>>> submitted with that commit explicitly lets one disable their rebuil=
d timer.  I
>>> agree its stupid to do that, but we added code to allow it.  This p=
rovides a
>>> patch to help people who are victimized because they've done exactl=
y this
>>> (additionaly providing them a warning to stop doing it).
>> Strange... many kernel parameters can be set to hazardous values tha=
t make machine unusable...
>>
>> ip_rt_gc_interval can also be set to a very large value : No more ro=
ute cache gc
>>
> If you want to talk philosophy, then I accept your premise: we can tu=
ne the
> kernel in ways that make it unusable.  Does that mean we should avoid=
 doing
> things to prevent that and maintain usibility.  Ithink this patch acc=
omplishes
> that goal in its small way.
> =20
>>>
>>>> 2) Many machines have ip_rt_gc_elasticity set to 2,
>>>>   because they have a huge hash table, but low chain depths.
>>> Ok, that seem reasonable, and this isn't going to disallow that.  B=
y the same
>>> resoning, people who have huge hash tables, and low chain depths wo=
n't
>>> want their low chain length being violated, would they?  This patch=
 will warn
>>> them if their assumptions are being violated.
>> Warn only ? If I read your patch, you not only warn in this case.
> No, not warn only, Warn and correct is the clear intent here
>=20
>> (you invalidate cache for each struct net, potentially wraping rt_ge=
nid)
>>
> If you overflow your elasticity 2^16 times, yes (I think rt_genid is =
a 16 bit
> value, but I don't have the kernel in front of me).  I would hope tha=
t would be
> enough warnings to make a sysadmin address the problem
>=20
>> When you have 2^20 slots in route cache hash table, you dont care if=
 few slots have 3 or 4 elements.
>> And chance is very high that more than one slot has 3 or even 4 elem=
ents, no need for an attacker.
> Ok, then I would assert if your ok with a few chains getting to be X =
entries in
> length, then you should set your elasticity to be X.

Nope. We set elasticity to 2 when we want to trigger code starting at l=
ine 1048

        if (cand) {
                if (chain_length > ip_rt_gc_elasticity) {
                        *candp =3D cand->u.dst.rt_next;
                        rt_free(cand);
                }
        }

That is, freeing one entry if chain length is > 2 AND one entry is free=
able.
This means that *some* chains eventually can have live entries and leng=
th > 2
without any problem. This is not an emergency case. I have seen on real=
=20
machines some chains hitting length of 13 (elasticity=3D2), that was no=
rmal traffic,
and rt cache was on equilibrium.

Your patch adds to the "if (chain_length > elasticity)" case :

If no entry is freeable in this slot, invalidate *all* cache and put a =
warning.

Invalidating live entries is puting a high pressure on dst_garbage.list=
=2E
Having 1.000.000 entries in this list is not very cool, and should be d=
one
only if really necessary.

When you know you have about 1.000.000 live entries in rt cache, you
can safely make your hash table sized to 2^20 slots, and elasticity set=
 to 2
so that average chain length is <=3D 2, reducing cache misses at lookup=
 time.

That is quite important to be able to handle 100.000 packets per second

>=20
>> Now if you change your code to something like
>>
>> if (unlikely(chain_length > some_quite_big_number &&
>>     ip_rt_secret_interval =3D=3D 0)) {
>> 	do_something();
>> }
>>
>> some_quite_big_number could be >=3D 30 or something...
>>
> I'd be ok with that, if some others chimed in with consensus on the m=
atter.  I
> felt that we had a value definining what chain length should be
> (ip_rt_gc_elasticity is already used in comparison on chain length in
> rt_intern_hash, so I was keeping with that).  But if some others spea=
k up and
> support a new sysctl, I can get behind that

I said 30, but could have said 100. No need for a sysctl.
If only one chain is really that long (and attacked), all its entries a=
re hot.
If many chains are hit, then other rt...sysctl_params will control and =
limit cache grow.

>=20
>> then it might be OK (at least it wont break common setups)
>>
> I don't think it will break many setups, the default value is 8 for t=
his sysctl.
> If someone has set it lower, and sees a warning, they won't loose the=
ir system
> altogether, they'll just see a momentary reduction in throughput, and=
 a
> warning to increase the value they have set.  Its going to far to say=
 anything
> will 'break'.

I spent many days so that route cache doesnt crash some big machines I =
have around,
I have feelings your patch will make them crawl again, unless sysadmin =
is smart
enough to change once again rt sysctls.
So my replies are not just random things from me.

When a machine is targeted by a DDOS attack, about all slots of the has=
h table
are fully loaded (ie chain length >=3D elasticity). We dont need to inv=
alidate=20
the cache, but find an equilibrium, with small adjustements.

Thank you




