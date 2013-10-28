From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next v2 0/5] bonding: patchset for rcu use in bonding
Date: Mon, 28 Oct 2013 11:02:03 +0800
Message-ID: <526DD3AB.4040007@huawei.com>
References: <52688F33.30904@huawei.com> <20131027225317.GB11209@redhat.com> <526DBAC8.5000009@huawei.com> <20131028013428.GC11209@redhat.com>
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
Received: from szxga03-in.huawei.com ([119.145.14.66]:13114 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753066Ab3J1DEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 23:04:10 -0400
In-Reply-To: <20131028013428.GC11209@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/10/28 9:34, Veaceslav Falico wrote:
> On Mon, Oct 28, 2013 at 09:15:52AM +0800, Ding Tianhong wrote:
>> On 2013/10/28 6:53, Veaceslav Falico wrote:
>>> On Thu, Oct 24, 2013 at 11:08:35AM +0800, Ding Tianhong wrote:
>>>> Hi:
>>>>
>>>> The slave list will add and del by bond_master_upper_dev_link() and bond_upper_dev_unlink(),
>>>> which will call call_netdevice_notifiers(), even it is safe to call it in write bond lock now,
>>>> but we can't sure that whether it is safe later, because other drivers may deal NETDEV_CHANGEUPPER
>>>> in sleep way, so I didn't admit move the bond_upper_dev_unlink() in write bond lock.
>>>>
>>>> now the bond_for_each_slave only protect by rtnl_lock(), maybe use bond_for_each_slave_rcu is a good
>>>> way to protect slave list for bond, but as a system slow path, it is no need to transform bond_for_each_slave()
>>>> to bond_for_each_slave_rcu() in slow path, so in the patchset, I will remove the unused read bond lock
>>>> for monitor function, maybe it is a better way, I will wait to accept any relay for it.
>>>>
>>>> Thanks for the Veaceslav Falico opinion.
>>>>
>>>> v2: add and modify commit for patchset and patch, it will be the first step for the whole patchset.
>>>>
>>>> Ding Tianhong (5):
>>>>  bonding: remove bond read lock for bond_mii_monitor()
>>>>  bonding: remove bond read lock for bond_alb_monitor()
>>>>  bonding: remove bond read lock for bond_loadbalance_arp_mon()
>>>>  bonding: remove bond read lock for bond_activebackup_arp_mon()
>>>
>>> This patch introduces a regression by boot-test with active backup mode:
>>>
>>> bond_activebackup_arp_mon() is already not holding the bond->lock, however
>>> it might call bond_change_active_slave(), which does (in case of new_active):
>>>
>>>  912                         write_unlock_bh(&bond->curr_slave_lock);
>>>  913                         read_unlock(&bond->lock);
>>>  914  915                         call_netdevice_notifiers(NETDEV_BONDING_FAILOVER, bond->dev);
>>>  916                         if (should_notify_peers)
>>>  917                                 call_netdevice_notifiers(NETDEV_NOTIFY_PEERS,
>>>  918                                                          bond->dev);
>>>  919  920                         read_lock(&bond->lock);
>>>  921                         write_lock_bh(&bond->curr_slave_lock);
>>>
>>> so it drops the bond->lock (which wasn't taken previously), and then takes
>>> it (without anyone dropping it afterwards).
>>>
>>> I don't know how to fix it - cause a lot of other callers already take it,
>>> and we can't just drop them (we'd race), and we can't remove it here (cause
>>> we can't call notifiers while atomic).
>>>
>>> Which begs the question - was this patchset tested at all?
>>>
>>> [   21.796823] =====================================
>>> [   21.796823] [ BUG: bad unlock balance detected! ]
> ... snip ...
>>
>> Hi David:
>> yes, exactly I miss it and make a mistake, the bond_select_active_slave is still have the protect problem and
>> need to be processed, I miss it, sorry, I will send a patch to fix the bug soon.
>>
>> Hi Veaceslav:
>> sorry about the commit, I will pay more attention to the commit and test, thanks for your advise and report the bug,
>> I have to admin that I was too careless.
> 
> I'll ask you once again, even though it seems that my NACK doesn't block
> the patchset - try writing commit messages that actually describe why and
> how you do it.
> 
> It's, actually, not only for the reviewers - it's also really good for you
> - cause while writing the commit log you also understand a lot more what
> are you doing, and might spot some corner cases (like this one).
> 
> Sorry for being negative, however it costs me *much* more time to review
> patches without proper commit messages. I've done it once, twice, several
> times more - but that's it, I refuse to spend my time on your skipped
> homework.
> 
> It might also help to split patches into really small steps - as in - do
> only one thing at a time, and describe it. This will help evade bugs *a
> lot*. It also helps people who'll bisect it, bugfix it and review it -
> because every patch will be a small, well-documented change, instead of a
> chunk of code with a description 'lets remove bond->lock'.
> 
> Thank you and hope that helps.
> 

sincere receiving all opinions.
thanks.

Regards.
Ding
>>
>>
>>
>>
>>>>
>>>> -- 
>>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>> .
>>>
>>
>>
> 
> .
> 
