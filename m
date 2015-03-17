From: Ulf Samuelsson <netdev@emagii.com>
Subject: Re: [PATCH] neighbour.c: Avoid GC directly after state change
Date: Wed, 18 Mar 2015 00:27:17 +0100
Message-ID: <5508B855.9090303@emagii.com>
References: <1426105727-64654-1-git-send-email-netdev@emagii.com> <55054259.30308@linux-ipv6.org> <5505DEC6.30006@emagii.com> <550662CB.50009@miraclelinux.com> <55073522.6010409@emagii.com> <55081E87.7020603@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>,
	ulf@emagii.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxf3.bahnhof.se ([213.80.101.27]:65195 "EHLO mxf3.bahnhof.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932388AbbCQX1a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2015 19:27:30 -0400
In-Reply-To: <55081E87.7020603@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Den 2015-03-17 13:31, YOSHIFUJI Hideaki skrev:
> Hello,
>
> Ulf Samuelsson wrote:
>> Den 2015-03-16 05:57, YOSHIFUJI Hideaki/=E5=90=89=E8=97=A4=E8=8B=B1=E6=
=98=8E skrev:
>>> Hello.
>>>
>>> Ulf Samuelsson wrote:
>>>> Den 2015-03-15 09:27, YOSHIFUJI Hideaki skrev:
>>>>> Hello.
>>>>>
>>>>> Ulf Samuelsson wrote:
>>>>>> From: Ulf Samuelsson <ulf@emagii.com>
>>>>>>
>>>>>> The neighbour state is changed in the ARP timer handler.
>>>>>> If the state is changed to NUD_STALE, then the neighbour
>>>>>> entry becomes a candidate for garbage collection.
>>>>>>
>>>>>> The garbage collection is handled by a "periodic work" routine.
>>>>>>
>>>>>> When :
>>>>>>
>>>>>>     * noone refers to the entry
>>>>>>     * the state is no longer valid (I.E: NUD_STALE).
>>>>> NUD_STALE is still valid.
>>>> Yes, my fault.
>>>> The condition which causes garbage collection to be skipped is.
>>>>
>>>>
>>>>      if (state & (NUD_PERMANENT | NUD_IN_TIMER)) {
>>>>
>>>>      NUD_STALE is not part of that, so GC will not be skipped,
>>>>      and therefore the patch is needed if you want to be able
>>>>      to use the API to modify the neigh statemachine..
>>>>>
>>>>>>     * the timeout value has  been reached or state is FAILED
>>>>>>
>>>>>> the "periodic work" routine will notify
>>>>>> the stack that the entry should be deleted.
>>>>>>
>>>>>> A user application monitoring and controlling the neighbour tabl=
e
>>>>>> using NETLINK may fail, if the "period work" routine is run
>>>>>> directly after the state has been changed to NUD_STALE,
>>>>>> but before the user application has had a chance to change
>>>>>> the state to something valid.
>>>>>>
>>>>>> The "period work" routine will detect the NUD_STALE state
>>>>>> and if the timeout value has been reached, it will notify the st=
ack
>>>>>> that the entry should be deleted.
>>>>>>
>>>>>> The patch adds a check in the periodic work routine
>>>>>> which will skip test for garbage collection
>>>>>> unless a number of ticks has passed since the last time
>>>>>> the neighbour entry state was changed.
>>>>>>
>>>>>> The feature is controlled through Kconfig
>>>>>>
>>>>>> The featuree is enabled by setting ARP_GC_APPLY_GUARDBAND
>>>>>> The guardband time (in ticks) is set in ARP_GC_GUARDBAND
>>>>>> Default time is 100 ms if HZ_### is set.
>>>>> We have "lower limit" not to start releasing neighbour entries.
>>>>> Try increasing gc_thresh1.
>>>> Why would  that work?
>>>>
>>>> The only place where this is used is
>>>>
>>>>      "if (atomic_read(&tbl->entries) < tbl->gc_thresh1)"
>>>>
>>>> tbl->entries is related to how many entries there are in the=20
>>>> neighbour table.
>>>>
>>>> The only way I think this would work, is if this is raised so high=
=20
>>>> that
>>>> garbage collection does not occur.
>>>>
>>>> That is not the intention.
>>>>
>>>> It does not solve the race condition between the timer_handler and=
=20
>>>> the periodic_work.
>>>
>>> I don't think it is a race.
>> And I think you are wrong and my logging shows that it is.
>
> We do not gurantee holding "stale" entries more than
> gc_thresh1, so it shall not be called as a race at all.


And that is a problem, which results in traffic loss.

>
>>
>>>
>>> You can try increasing gc_staletime to hold each entry based
>>> on last usage.  Plus, you can "confirm" neighbors by
>>> MSG_CONFIRM.
>>>
>>> Note that if the number of entries becomes high, "forced GC" will
>>> drop valid, "not connected" entries as well.
>>
>> I can try increasing gc_staletime, but its a waste of time, because=20
>> it is not the last usage which is interesting.
>> What is interesting is the time when the entry state was updated by=20
>> the timer handler.
>>
>> Pls explain further MSG_CONFIRM.
>
> Typically, base reachable time is set to 30sec and gc_staletime is
> set to 60sec.  So, entries are expected to be held for a while
> after it has become "stale", no?
>
> MSG_CONFIRM is a sendmsg() flag.  It allows user-space application
> to confirm reachability of neighbor.  It refreshes "confirmed"
> time. In neigh_periodic_work(), "used" time is updated to
> "confirmed" time if "used" time is before "confirmed" time.
>
May work, if the application was totally redesigned,

> ping(8), ping6(8), tftpd(8) use that flag, for example.
>
>
>> The problem occurs when the periodic_work routine runs immediately
>> after the timer handler has changes the state to NUD_STALE and
>> the entry has reached the expiry time.
>
> It is what we expect.
>
> In neigh_periodic_work(), you may try to release non-STALE
> entries first, and then STALE entries if the number of entries is
> still high.
That sounds much more complex than the proposed fix.

>
> --yoshfuji
