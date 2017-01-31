From: Anoob Soman <anoob.soman@citrix.com>
Subject: Re: [PATCH net] packet: call fanout_release, while UNREGISTERING a
 netdev
Date: Tue, 31 Jan 2017 18:14:52 +0000
Message-ID: <61fb944f-776c-00ff-dd05-d33e263f205a@citrix.com>
References: <1475676774-18726-1-git-send-email-anoob.soman@citrix.com>
 <20161006.205052.1380596858044266995.davem@davemloft.net>
 <1485797189.6360.98.camel@edumazet-glaptop3.roam.corp.google.com>
 <10e9ac4b-585e-2878-0141-f00020a027f0@citrix.com>
 <1485805493.6360.113.camel@edumazet-glaptop3.roam.corp.google.com>
 <d2b23842-f6db-c2c9-d22c-d7e0945abc15@citrix.com>
 <1485885650.6360.122.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ctxuk.citrix.com ([185.25.65.24]:40040 "EHLO
        SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751580AbdAaSSs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:18:48 -0500
In-Reply-To: <1485885650.6360.122.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 31/01/17 18:00, Eric Dumazet wrote:
> On Tue, 2017-01-31 at 17:03 +0000, Anoob Soman wrote:
>> On 30/01/17 19:44, Eric Dumazet wrote:
>>> On Mon, 2017-01-30 at 19:08 +0000, Anoob Soman wrote:
>>>> On 30/01/17 17:26, Eric Dumazet wrote:
>>>>> On Thu, 2016-10-06 at 20:50 -0400, David Miller wrote:
>>>>>> From: Anoob Soman <anoob.soman@citrix.com>
>>>>>> Date: Wed, 5 Oct 2016 15:12:54 +0100
>>>>>>
>>>>>>> If a socket has FANOUT sockopt set, a new proto_hook is registered
>>>>>>> as part of fanout_add(). When processing a NETDEV_UNREGISTER event in
>>>>>>> af_packet, __fanout_unlink is called for all sockets, but prot_hook which was
>>>>>>> registered as part of fanout_add is not removed. Call fanout_release, on a
>>>>>>> NETDEV_UNREGISTER, which removes prot_hook and removes fanout from the
>>>>>>> fanout_list.
>>>>>>>
>>>>>>> This fixes BUG_ON(!list_empty(&dev->ptype_specific)) in netdev_run_todo()
>>>>>>>
>>>>>>> Signed-off-by: Anoob Soman <anoob.soman@citrix.com>
>>>>>> Applied and queued up for -stable, thanks.
>>>>> This commit (6664498280cf "packet: call fanout_release, while
>>>>> UNREGISTERING a netdev")
>>>>> looks buggy :
>>>>>
>>>>> We end up calling fanout_release() while holding a spinlock
>>>>> ( spin_lock(&po->bind_lock); )
>>>>>
>>>>> But fanout_release() grabs a mutex ( mutex_lock(&fanout_mutex) ), and
>>>>> this is absolutely not valid while holding a spinlock.
>>>> Yes, that is wrong.
>>>>
>>>>> Anoob, can you cook a fix, I guess you have a way to reproduce the thing
>>>>> that wanted a kernel patch ?
>>>>>
>>>>> (Please build your test kernel with CONFIG_LOCKDEP=y)
>>>> Sure, I am planning to move fanout_release(sk) after
>>>> spin_unlock(bind_lock). Something like this.
>>>>                                    }
>>>>                                    if (msg == NETDEV_UNREGISTER) {
>>>>                                            packet_cached_dev_reset(po);
>>>> -                                       fanout_release(sk);
>>>>                                            po->ifindex = -1;
>>>>                                            if (po->prot_hook.dev)
>>>> dev_put(po->prot_hook.dev);
>>>>                                            po->prot_hook.dev = NULL;
>>>>                                    }
>>>>                                    spin_unlock(&po->bind_lock);
>>>> +                               if (msg == NETDEV_UNREGISTER) {
>>>> +                                       fanout_release(sk);
>>>> +                               }
>>>>                            }
>>>>                            break;
>>>>
>>>> I will quickly test it out.
>>> It wont be enough.
>>>
>>> You need to also fix a race if two cpus call fanout_release(sk) at the
>>> same time.
>>>
>>> Thanks.
>>>
>>>
>>>
>> Hi Eric,
>>
>> I have ran into some problem trying to enable CONFIG_LOCKDEP. I think
>> this particular scenario, taking mutex_lock() while holding a spin_lock
>> debugging, requires CONFIG_DEBUG_ATOMIC_SLEEP to be enabled.
>> CONFIG_DEBUG_ATOMIC_SLEEP, selects CONFIG_PREEMPT_COUNT and my kernel
>> doesn't behave well if PREEMPTION is enabled. I am trying to reproduce
>> this issue in a way that I might be able to use debug_atomic_sleep.
>>
>> Meanwhile, I have modified patch fix the race.
>
> So you can definitely have in a .config all these at the same time
> (LOCKDEP,  non PREEMPT, and DEBUG_ATOMIC_SLEEP)
>
>
>
>
> $ egrep "DEBUG_ATOMIC_SLEEP|PREEMPT|LOCKDEP" .config
> CONFIG_LOCKDEP_SUPPORT=y
> CONFIG_PREEMPT_NOTIFIERS=y
> CONFIG_PREEMPT_NONE=y
> # CONFIG_PREEMPT_VOLUNTARY is not set
> # CONFIG_PREEMPT is not set
> CONFIG_PREEMPT_COUNT=y
> CONFIG_LOCKDEP=y
> # CONFIG_DEBUG_LOCKDEP is not set
> CONFIG_DEBUG_ATOMIC_SLEEP=y
>

yes, thats exactly what I have.

$ egrep "DEBUG_ATOMIC_SLEEP|PREEMPT|LOCKDEP" .config
CONFIG_LOCKDEP_SUPPORT=y
# CONFIG_PREEMPT_NONE is not set
CONFIG_PREEMPT_VOLUNTARY=y
# CONFIG_PREEMPT is not set
CONFIG_PREEMPT_COUNT=y
CONFIG_LOCKDEP=y
# CONFIG_DEBUG_LOCKDEP is not set
CONFIG_DEBUG_ATOMIC_SLEEP=y

I initially thought CONFIG_PREEMPT_COUNT enables CONFIG_PREEMPT, but 
looks like all it does is to inc/dec preempt_count.

Let me give the test a spin again, and see why everything seems to fall 
apart.

>
>
