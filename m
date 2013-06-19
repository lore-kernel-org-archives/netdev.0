From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net-next 1/2] macvtap: Let TUNSETOFFLOAD actually controll
 offload features.
Date: Wed, 19 Jun 2013 14:59:07 -0400
Message-ID: <51C1FF7B.9050502@redhat.com>
References: <1371653272-11703-1-git-send-email-vyasevic@redhat.com>   <1371653272-11703-2-git-send-email-vyasevic@redhat.com>  <1371655038.3252.312.camel@edumazet-glaptop> <51C1CDBC.4040003@redhat.com> <1371656769.3252.320.camel@edumazet-glaptop> <51C1DA58.4010204@redhat.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, mst@redhat.com, jasowang@redhat.com
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1971 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756776Ab3FSS7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 14:59:14 -0400
In-Reply-To: <51C1DA58.4010204@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd

MST suggested I add you.  Do you remember the reason
why macvtap uses rcu_read_lock_bh() instead of plain
rcu_read_lock()?  Additionally it seems to use
synchronize_rcu(), not the _bh() version.

Thanks
-vlad

On 06/19/2013 12:20 PM, Vlad Yasevich wrote:
> On 06/19/2013 11:46 AM, Eric Dumazet wrote:
>> On Wed, 2013-06-19 at 11:26 -0400, Vlad Yasevich wrote:
>>
>>> I think I do since vlan pointer may change even when I am holding
>>> rtnl.  rtnl is needed to change features.  rcu is needed to get
>>> the vlan pointer.
>>>
>>>> (A BH handler will not change q->vlan )
>>>
>>> No, but the _bh rcu calls seem to be used when dereferencing q->vlan.
>>> I am not sure the reason for that...
>>
>> You mix the reader/fast path, properly using RCU,
>> and the writer path, using macvtap_lock ( a spinlock ).
>>
>> That's clear sign you missed something.
>>
>
> I don't think I need macvtap_lock as I am not modifying the relationship
> between q and vlan.  I am attempting to modify the macvlan device
> features.  So macvtap_lock does not apply, and _rcu is used.
>
> Looking at the entire macvtap driver, only the _bh variants of rcu
> are used throughout the driver,  including in the ioctl() function.  I
> am not sure why the driver requires BH to be disabled, but that
> seems to be the case.
>
>>>
>>>>
>>>> BTW, it looks like ->vlan is protected by macvtap_lock
>>>
>>> Right.  This is why I use rcu to get vlan.  rtnl is needed to avoid
>>> asserts in the feature change code.
>>
>> The management should be allowed to sleep, and rcu_read_lock_bh()
>> disallows that.
>>
>> Maybe some driver callback will really sleep and crash after your patch.
>>
>> vi +69 drivers/net/macvtap.c
>>
>> /*
>>   * RCU usage:
>>   * The macvtap_queue and the macvlan_dev are loosely coupled, the
>>   * pointers from one to the other can only be read while rcu_read_lock
>>   * or macvtap_lock is held.
>>
>> Your patch does not respect the rules of this driver.
>
> Why not?  It uses rcu to acquire the pointer thus following the rules.
> The use of  the pointer is within the critical section so we are
> guaranteed to have a valid pointer.
>
>>
>> macvtap_lock is always acquired from process context, without any need
>> for _bh variant.
>>
>
> No, the lock is acquired only when modifying the relationship between
> the macvtap_queue and macvtap_dev.
>
>
>> Quite frankly, I would switch this driver to use a mutex for
>> macvtap_lock.
>>
>> And simply remove it, as RTNL is most probably already owned.
>>
>
> That's the issue.  RTNL is not owned in the ioctl case.  In fact
> rtnl_lock was added to the patch because RTNL asserts were triggered
> when changing device features.
>
> -vlad
>
>
>>
>>
>>
>>
>
