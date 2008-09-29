From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when	gc_elasticity
 is exceeded
Date: Mon, 29 Sep 2008 23:00:35 +0200
Message-ID: <48E141F3.9000903@cosmosbay.com>
References: <20080929191254.GA20074@hmsreliant.think-freely.org> <48E138EB.1080001@cosmosbay.com> <20080929202731.GC20074@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, davem@davemloft.net,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2a.orange.fr ([80.12.242.139]:51855 "EHLO smtp2a.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752546AbYI2VAp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 17:00:45 -0400
In-Reply-To: <20080929202731.GC20074@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> On Mon, Sep 29, 2008 at 10:22:03PM +0200, Eric Dumazet wrote:
>> Neil Horman a =E9crit :
>>> Hey all-
>>> 	We currently have the ability to disable our route cache secret in=
terval
>>> rebuild timer (by setting it to zero), but if we do that its possib=
le for an
>>> attacker (if they guess our route cache hash secret, to fill our sy=
stem with
>>> routes that all hash to the same bucket, destroying our performance=
=2E  This patch
>>> provides a backstop for that issues.  In the event that our rebuild=
 interval is
>>> disabled (or very large), if any hash chain exceeds ip_rt_gc_elasti=
city, we do
>>> an emergency hash rebuild.  During the hash rebuild we:
>>> 1) warn the user of the emergency
>>> 2) disable the rebuild timer
>>> 3) invalidate the route caches
>>> 4) re-enable the rebuild timer with its old value
>>>
>>> Regards
>>> Neil
>> This sounds not good at all to me.
>>
>> 1) Dont set ip_rt_secret_interval to zero, this is plain silly, sinc=
e
>>   you give attackers infinite time to break your machine.
>>
>> To quote Herbert (who allowed to set this interval to 0)
>>
>>    "Let me first state that disabling the route cache hash rebuild
>>     should not be done without extensive analysis on the risk profil=
e
>>     and careful deliberation.
>>
>>     However, there are times when this can be done safely or for
>>     testing.  For example, when you have mechanisms for ensuring
>>     that offending parties do not exist in your network."
>>
> Thats really rather the motivation behind this.  The patch that Herbe=
rt
> submitted with that commit explicitly lets one disable their rebuild =
timer.  I
> agree its stupid to do that, but we added code to allow it.  This pro=
vides a
> patch to help people who are victimized because they've done exactly =
this
> (additionaly providing them a warning to stop doing it).

Strange... many kernel parameters can be set to hazardous values that m=
ake machine unusable...

ip_rt_gc_interval can also be set to a very large value : No more route=
 cache gc

>=20
>=20
>> 2) Many machines have ip_rt_gc_elasticity set to 2,
>>   because they have a huge hash table, but low chain depths.
> Ok, that seem reasonable, and this isn't going to disallow that.  By =
the same
> resoning, people who have huge hash tables, and low chain depths won'=
t
> want their low chain length being violated, would they?  This patch w=
ill warn
> them if their assumptions are being violated.

Warn only ? If I read your patch, you not only warn in this case.
(you invalidate cache for each struct net, potentially wraping rt_genid=
)

When you have 2^20 slots in route cache hash table, you dont care if fe=
w slots have 3 or 4 elements.
And chance is very high that more than one slot has 3 or even 4 element=
s, no need for an attacker.

Now if you change your code to something like

 if (unlikely(chain_length > some_quite_big_number &&
     ip_rt_secret_interval =3D=3D 0)) {
 	do_something();
 }

some_quite_big_number could be >=3D 30 or something...

then it might be OK (at least it wont break common setups)



