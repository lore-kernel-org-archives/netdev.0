From: Fan Du <fan.du@windriver.com>
Subject: Re: [PATCH] xfrm: Refactor xfrm_state timer management
Date: Mon, 5 Aug 2013 17:39:11 +0800
Message-ID: <51FF72BF.9040207@windriver.com>
References: <1375342790-2852-1-git-send-email-fan.du@windriver.com> <20130801.153512.307039655614237376.davem@davemloft.net> <51FB15F4.1030703@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Fan Du <fan.du@windriver.com>, <herbert@gondor.hengli.com.au>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:65461 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753153Ab3HEJig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 05:38:36 -0400
In-Reply-To: <51FB15F4.1030703@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B408=E6=9C=8802=E6=97=A5 10:14, Fan Du wrote:
>
>
> On 2013=E5=B9=B408=E6=9C=8802=E6=97=A5 06:35, David Miller wrote:
>> From: Fan Du<fan.du@windriver.com>
>> Date: Thu, 1 Aug 2013 15:39:50 +0800
>>
>>> Current xfrm_state timer management is vulnerable in below several =
ways:
>>>
>>> - Use hrtimer for timer, the timer handler use wall clock checking =
expire events
>>> commit e3c0d047 "Fix unexpected SA hard expiration after changing d=
ate" fix
>>> the partial problem by notify IKED with soft -> expire sequence whe=
n user
>>> changing system time forward. But it didn't fix the issue when use =
changing
>>> system time backwards, which is most crucial as SAs lifetime will b=
e a *bigger*
>>> one when doing so, thus buy much time for cracker.
>>>
>>> In short words, changing system time forward/backward can either re=
sult in
>>> long long lifetime SAs or sudden SA hard expired first.
>>>
>>> It actually can be fixed this by adding more flags, and with more c=
omplicated
>>> checking whether system time is being turned forward or backward. I=
 did it and
>>> eventually works well. But it's only for "add time expire", taking =
care of
>>> "use time expire" will add more logic into timer handler, and much =
more
>>> complicated.
>>>
>>> - When user give "use lifetime" by xfrm user configuration
>>> interface, current xfrm_state timer management will actually turn t=
he timer on
>>> even when no IP packet hit policy, and the "use lifetime" eventuall=
y become
>>> "add lifetime".
>>>
>>> The culprit is: with one timer for both "add lifetime" and "use lif=
etime", at the
>>> same time using wall clock to check two expire events. This patch t=
ries to solve
>>> it by:
>>> - Switch real time timer with monotonic timer against any system ti=
me changing
>>> - Use "add lifetime" to override "use lifetime" when both applied, =
as most popular
>>> IKED like Racoon2/StrongSwan use "add lifetime" only.
>>> - Start "add lifetime" timer only when xfrm_state is updated/added
>>> - Start "use lifetime" timer when actually SAs is used.
>>> - Start the timer with soft lifetime interval first, and then in ti=
mer handler
>>> rearm timer with hard lifetime to get rid of using wall clock.
>>>
>>> Signed-off-by: Fan Du<fan.du@windriver.com>
>>
>> This is getting way too complicated, there must be a much better way
>> to handle this.
>>
>> I suspect the thing to do is to have system time changes generate a
>> notifier when clock_was_set() is called.
>>
>> The XFRM code would walk the rules and pretend that we hit the soft
>> timeout for every rule that we haven't hit the soft timeout yet
>> already.
>>
>> If a rule hit the soft timeout, force a hard timeout.
>>
>> When forcing a soft timeout, adjust the hard timeout to be
>> (hard_timeout - soft_timeout) into the future.
>>
>> Because these other approaches are extremely fragile and
>> unmaintainable.
>>
> Hi, Dave
>
> Your idea is my initial approach to this issue :) but please let me t=
ry
> to explain this clearly to you.
>
> soft timeout and hard timeout should be independent of system clock,
> for example, set SA hard lifetime to 180s, soft lifetime to 153s,
> in this configuration, soft timeout is expected to happen after exact=
ly
> 153s, notifying IKED soft timeout from kernel has nothing to do with
> currently wall clock. The same is true for hard timeout. This is the =
way
> this patch following.
>
> But original xfrm design is using wall clock to check whether soft/ha=
rd
> timeout happen. That's because original designer think by "add lifeti=
me",
> the starting point for timing is when alloc this SA(xfrm_state_alloc)=
=2E
> This is improper, because the SA only takes effect when it's ready,
> and its lifetime should be timing from IKED has added/updated this SA
> (xfrm_state_add/update).
>
> Also original xfrm design doesn't start timer with soft lifetime firs=
t,
> A 1 second timeout is initiated to drive timer handler to calculate
> soft timeout, and then in the next timer interrupt calculate hard tim=
eout.
> So this timer actually timeout three times. And I think we don't need=
 to
> that at all.
>
> Last but not least, "use lifetime" should be started in
> xfrm_state_check_expire when this SA is indeed used for the first tim=
e.
> Original design mingle "add lifetime" and "use lifetime" together.
>
> That's the problem we have in current XFRM layer. I thought about whe=
never
> system clock is updated, notify XFRM layer, again transverse all xfrm=
_state
> need to take locks. And what about the SA when it just enter timer ha=
ndler
> and system clock is update. Notifier will delay quite a bit.
>
> The initiative to rework xfrm_state timer independent of system clock=
 is
> host needs to calibrate local time with GPS or ntp frequently, and SA=
s
> lifetime shouldn't be impacted.
>
>

Hi, Dave/Steffen

After three days of testing with below script, this patch is quite stro=
nger
enough for vibrated and random system clock change than current impleme=
ntation.
I'm not sure I made myself clear in previous lengthy reply. If not, ple=
ase
give one last chance to make my argument. If this patch is indeed not t=
he way
as you wish, please also tell me. I will try to fix this issue in one w=
ay or another :)

Thanks

while [ 1 ]
do
	if [ $RANDOM/2 ]
	then
		date -s "+$(($RANDOM%1000)) seconds"
	else
		date -s "-$(($RANDOM%1000)) seconds"
	fi
=09
	sleep $(($RANDOM%3))

	if [ $RANDOM/2 ]
	then
		date -s "+$(($RANDOM%1000)) seconds"
	else
		date -s "-$(($RANDOM%1000)) seconds"
	fi
	sleep $(($RANDOM%5))
done


--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
