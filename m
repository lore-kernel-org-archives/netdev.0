From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 0/4] bonding work-queues, try_rtnl() & notifications
Date: Thu, 12 Mar 2015 15:24:49 +0100
Message-ID: <5501A1B1.3030907@redhat.com>
References: <1426139673-26995-1-git-send-email-maheshb@google.com>	 <550181E6.2080100@redhat.com> <1426169466.11398.158.camel@edumazet-glaptop2.roam.corp.google.com> <5501A107.5040400@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	David Miller <davem@davemloft.net>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52140 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754025AbbCLOZD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2015 10:25:03 -0400
In-Reply-To: <5501A107.5040400@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/15 15:21, Nikolay Aleksandrov wrote:
> On 12/03/15 15:11, Eric Dumazet wrote:
>> On Thu, 2015-03-12 at 13:09 +0100, Nikolay Aleksandrov wrote:
>>> On 12/03/15 06:54, Mahesh Bandewar wrote:
>>>> This patch series tries to address the issue discovered in various work-
>>>> queues and the way these handlers deal with the RTNL. Especially for 
>>>> notification handling. If RTNL can not be acquired, these handlers ignore
>>>> sending notifications and just re-arm the timer. This could be very 
>>>> problematic if the re-arm timer has larger value (e.g. in minutes).
>>>>
>>>>
>>>> Mahesh Bandewar (4):
>>>>   bonding: Handle notifications during work-queue processing gracefully
>>>>   bonding: Do not ignore notifications for miimon-work-queue
>>>>   bonding: Do not ignore notifications for AD-work-queue
>>>>   bonding: Do not ignore notifications for ARP-work-queue
>>>>
>>>>  drivers/net/bonding/bond_3ad.c  | 22 ++++++++++++---
>>>>  drivers/net/bonding/bond_main.c | 62 ++++++++++++++++++++++++-----------------
>>>>  include/net/bonding.h           | 22 +++++++++++++++
>>>>  3 files changed, 77 insertions(+), 29 deletions(-)
>>>>
>>>
>>> Hello Mahesh,
>>> The current behaviour was chosen as a best-effort type because such change
>>> could skew the monitoring/AD timers because you re-schedule every time you
>>> cannot acquire rtnl and move their timers with 1 tick ahead which could lead 
>>> to false link drops, state machines running late and so on.
>>> Currently the monitoring/AD functions have priority over the notifications as in
>>> we might miss a notification but we try not to miss a monitoring/AD event, thus I'd
>>> suggest to solve this in a different manner. If you'd like to have the best of both
>>> worlds i.e. not miss a monitoring event and also not miss any notifications you should
>>> use a different strategy. 
>>
>>
>> I think I disagree here.
>>
>> All rtnl_trylock() call sites must be very careful about what they are
>> doing.
>>
>> bonding is not, and we should fix this.
>>
>> Mahesh fix seems very reasonable. If you need something else, please
>> provide your own patch.
>>
>> When code is the following :
>>
>>         if (!rtnl_trylock())
>>                  return;
>>         call_netdevice_notifiers(NETDEV_NOTIFY_PEERS, bond->dev);
>>         rtnl_unlock();
>>
>> Then, one must understand what happens if at this point rtnl_trylock()
>> never succeeds.
>>
>> Like, what happens if you remove the whole thing.
>>
>> If the code is not needed, remove it, instead of having flaky behavior.
>>
> 
> I agree that it should be fixed and that would work, my only concern is that in
> rare cases this might lead to skewing of the monitoring/AD timers because with
> every failed attempt at obtaining rtnl it moves the associated timer with 1 tick
> ahead, because when it successfully obtains it then the timer gets re-armed with the
> full timeout. What I suggested has already been done actually by the slave array update
> which uses a work item of its own because of the rtnl update, so we could just pull all
> of the call sites that request rtnl in a single work item which checks some bits and
> calls the appropriate notifications or re-schedules itself if necessary, that would keep
> all the monitoring/AD timers closer to being correct.
> I can see that this would be a very rare case so I don't have a strong feeling about
> my argument, I just wanted to make sure it gets considered. If you and the others decide
> it's not worth it, then so be it. Also pulling all rtnl call sites in a single place
> looks cleaner to me instead of having the same logic in each work item's function.
> 
> Cheers,
>  Nik
> 

Well, of course that has its own problems of missed updates. Hrm.. Okay let's leave it
this way. Never mind my argument about the timer skewing, consider only fixing the RCU
problem.

Nik
