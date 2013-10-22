From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 0/5] bonding: patchset for rcu use in bonding
Date: Tue, 22 Oct 2013 10:16:24 +0800
Message-ID: <5265DFF8.8090007@huawei.com>
References: <5264ECBC.2090208@huawei.com> <20131021091336.GB692@redhat.com> <5264F397.50608@huawei.com> <20131021093549.GC692@redhat.com> <52651ECB.1080901@huawei.com> <20131021124144.GD692@redhat.com> <20131021132136.GE692@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:9598 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753021Ab3JVCQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 22:16:54 -0400
In-Reply-To: <20131021132136.GE692@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/10/21 21:21, Veaceslav Falico wrote:
> On Mon, Oct 21, 2013 at 02:41:44PM +0200, Veaceslav Falico wrote:
>> On Mon, Oct 21, 2013 at 08:32:11PM +0800, Ding Tianhong wrote:
>>> On 2013/10/21 17:35, Veaceslav Falico wrote:
>>>> On Mon, Oct 21, 2013 at 05:27:51PM +0800, Ding Tianhong wrote:
>>>>> On 2013/10/21 17:13, Veaceslav Falico wrote:
>>>>>> On Mon, Oct 21, 2013 at 04:58:36PM +0800, Ding Tianhong wrote:
>>>>>>> Hi:
>>>>>>>
>>>>>>> The Patch Set will remove the invalid lock for bond work queue and replace it
>>>>>>> with rtnl lock, as read lock for bond could not protect slave list any more.
>>>>>>
>>>>>> rtnl lock is a lot more expensive than bond lock, and not only for bond,
>>>>>> but for all the networking stack.
>>>>>>
>>>>>> Why is the bond->lock invalid? It correctly protects slaves from being
>>>>>> modified concurrently.
>>>>>>
>>>>>> I don't see the point in this patchset.
>>>>>>
>>>>>
>>>>> yes, rtnl lock is a big lock, but I think bond->lock could not protect
>>>>> bond_for_each_slave any more, am I miss something?
>>>>
>>>> Why can't it protect bond_for_each_slave()?
>>>>
>>>
>>> bond_master_upper_dev_link() and bond_upper_dev_unlink() was only in rtnl lock,
>>> bond_for_each_slave may changed while loop in bond read lock, but it sees that
>>> nothing serious will happen yet.
>>> Maybe I miss something.
>>
>> Even if it is unsafe to use bond_for_each_slave() while holding bond->lock
>> - it means that we must protect the list by locking the
>> bond_upper_dev_(un)link() via bond->lock, but not by removing bond->lock
>> from everywhere where it is now. And I'm not that sure if it's safe or not.
> 
> I've quickly looked over the code - yes, theoretically we could race
> between bond_for_each_slave() that is not rtnl-protected and
> bond_upper_dev_(un)link().
> 
> Your patchset, also, doesn't 'replace' bond->lock with rtnl_lock(), cause
> everywhere the rtnl_lock() is already present, it just moves it around,
> while removing the bond->lock.
> 
> The commit message is wrong and says actually nothing why is it done, how
> is it done, why it's safe to do so and what do we get in the end. For every
> patch, and the cover letter is also not an exception.
> 

It is my fault, too lazy to describe the detail for the patch and occurs so many
missmatch, I'll fix it later.

> I'd suggest you either:
> 
> 1) add bond->lock around bond_upper_dev_(un)link() (GFP_ATOMIC might be needed).
> 

bond_upper_dev_(un)link() will call call_netdevice_notifiers(), it is not safe to call it
in read lock, call_netdevice_notifiers() may sleep or schedule, and sometimes
call_netdevice_notifiers() will read bond lock again.

> or
> 
> 2) add ASSERT_RTNL() to bond_for_each_slave() macro, catch all the offenders
> and remove the bond->lock from them. Also, I'm not that sure that it's safe
> to do so - cause one of the slaves (not the slave list) might change, and
> we might have race conditions there.
> 

yes, it is not a good idea, as your meaning, it is a big cost, but monitor is a slow path,
I think the cost is acceptable,whatever we should find a better way.

> or
> 
> 3) move bond_for_each_slave() to bond_for_each_slave_rcu() where appropriate.
> 
> And in any case write specific commit messages - bonding's code is really
> old and full of locks that were placed for some reason (and the reason
> might have gone away long ago, too), so it's really hard to say if the
> change is safe or not.

above all, the 3) is the wise idea, rtnl or rcu, every one is enough for 
bond_for_each_slave().
> 
> I'd personally go for either 3) (preferred), or 1).
> 
> Sorry, I'm a bit tired of going in-depth on your patches. Start either
> doing patches with commit messages that *prove* me that you're right (I'll,
> obviously, verify it - but at least I'll know what you're doing, and won't
> have to figure it out from code), or I'll start explicitly NAKing them.
> 
> Sorry again, but I don't really have time for that. I didn't have time to
> review your last patchset (RCUifying the remaining transmit path), and now
> I can understand nothing from their commit description, except that you've
> changed bond_for_each_slave() to bond_for_each_slave_rcu() and bond->lock
> to rcu_read_lock(). I'm not saying that they're wrong, just that they're
> really hard to understand.
> 
> So, please, start writing commit messages.
> 


>>
>>>
>>> Ding
>>>
>>>
>>>>>
>>>>> Ding
>>>>>
>>>>>>>
>>>>>>> Ding Tianhong (5):
>>>>>>> bonding: remove bond read lock for bond_mii_monitor()
>>>>>>> bonding: remove bond read lock for bond_alb_monitor()
>>>>>>> bonding: remove bond read lock for bond_loadbalance_arp_mon()
>>>>>>> bonding: remove bond read lock for bond_activebackup_arp_mon()
>>>>>>> bonding: remove bond read lock for bond_3ad_state_machine_handler()
>>>>>>>
>>>>>>> drivers/net/bonding/bond_3ad.c  |   9 ++--
>>>>>>> drivers/net/bonding/bond_alb.c  |  20 ++------
>>>>>>> drivers/net/bonding/bond_main.c | 100 +++++++++++++---------------------------
>>>>>>> 3 files changed, 40 insertions(+), 89 deletions(-)
>>>>>>>
>>>>>>> -- 
>>>>>>> 1.8.2.1
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>>
>>>>>>
>>>>>
>>>>>
>>>>
>>>> .
>>>>
>>>
>>>
>> -- 
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> .
> 
