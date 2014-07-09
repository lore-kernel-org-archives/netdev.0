From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH] bonding: Do not try to send packets over dead link in
 TLB mode.
Date: Wed, 09 Jul 2014 23:07:38 +0200
Message-ID: <53BDAF1A.4050701@redhat.com>
References: <1404868198-24839-1-git-send-email-maheshb@google.com> <20140709102441.GB1227@redhat.com> <53BD18A7.6090109@redhat.com> <20140709120437.GC1227@redhat.com> <1404911849.3515.28.camel@edumazet-glaptop2.roam.corp.google.com> <20140709132709.GA11974@redhat.com> <CAF2d9ji-E4Og94X+NbcGs=WKSemryy6-WoPKzSVCaM13Rqjiug@mail.gmail.com> <CAF2d9jhJuisK1TmePtz-X79-oDmQHGHhvipAVAE=5Y2cu7tSEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>
To: Mahesh Bandewar <maheshb@google.com>,
	Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16656 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750724AbaGIVHu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2014 17:07:50 -0400
In-Reply-To: <CAF2d9jhJuisK1TmePtz-X79-oDmQHGHhvipAVAE=5Y2cu7tSEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/09/2014 07:24 PM, Mahesh Bandewar wrote:
> On Wed, Jul 9, 2014 at 10:15 AM, Mahesh Bandewar <maheshb@google.com> wrote:
>> On Wed, Jul 9, 2014 at 6:27 AM, Veaceslav Falico <vfalico@redhat.com> wrote:
>>> On Wed, Jul 09, 2014 at 03:17:29PM +0200, Eric Dumazet wrote:
>>>>
>>>> On Wed, 2014-07-09 at 14:04 +0200, Veaceslav Falico wrote:
>>>>>
>>>>> On Wed, Jul 09, 2014 at 12:25:43PM +0200, Nikolay Aleksandrov wrote:
>>>>>> On 07/09/2014 12:24 PM, Veaceslav Falico wrote:
>>>>>>> On Tue, Jul 08, 2014 at 06:09:58PM -0700, Mahesh Bandewar wrote:
>>>>> ...snip...
>>>>>>>> +    spin_lock(&bond_info->slave_arr_lock);
>>>>>>>
>>>>>>> I don't think you can re-enter bond_alb_handle_link_change(), as it's
>>>>>>> protected either by rtnl or write-lock curr_active_slave.
>>>>>>>
>>>>>> Actually a very good catch :-)
>>>>>> Maybe the allocation above should be done with GFP_ATOMIC.
>>>>>
>>>>> For the record - it's indeed always under rtnl, so ASSERT_RTNL() (from
>>>>> your
>>>>> other email) is a good idea.
>>>>
>>>>
>>>> Strange. I basically suggested the ASSERT_RTNL() to Mahesh few days ago
>>>> and he tried this. But the assert triggered with miimon, so Mahesh added
>>>> back the spinlock.
>>>
>>>
>>> That's indeed strange... From the code:
>>>
>>> 2103                 if (!rtnl_trylock()) {
>>> 2104                         delay = 1;
>>> 2105                         should_notify_peers = false;
>>> 2106                         goto re_arm;
>>> 2107                 }
>>> 2108
>>> 2109                 bond_miimon_commit(bond);
>>> 2110
>>> 2111                 rtnl_unlock();  /* might sleep, hold no other locks */
>>>
>>> And we can get there only through bond_miimon_commit(), as part of the
>>> miimon.
>>>
>>> Maybe you've hit the kmalloc(GFP_KERNEL) warning?
>>
>> Hmm, actually as Eric mentioned, I did try removing the spinlock to
>> just use RTNL but assert failed and it wasn't sleepable fn called in
>> atomic context message (I assume that is what you are suggesting from
>> kmalloc warning).
>>
>> I managed to find the stack trace for that -
>>
>> RTNL: assertion failed at drivers/net/bonding/bond_alb.c (1371)
>> CPU: 2 PID: 3571 Comm: kworker/u16:7 Not tainted 3.11.10-smp-DEV #91
>> Workqueue: bond0 bond_mii_monitor [bonding]
>>  ffff8801175e4800 ffff880113b53d38 ffffffff97f97cab 000000000000004d
>>  ffff8801175c6800 ffff880113b53d58 ffffffffc046a17c ffff8801175c6800
>>  ffff8801175e4800 ffff880113b53d88 ffffffffc045ef27 0000000000000000
>> Call Trace:
>>  [<ffffffff97f97cab>] dump_stack+0x46/0x58
>>  [<ffffffffc046a17c>] bond_alb_handle_link_change+0x16c/0x180 [bonding]
>>  [<ffffffffc045ef27>] bond_handle_link_change+0x57/0x80 [bonding]
>>  [<ffffffffc0462d79>] bond_mii_monitor+0x679/0x6e0 [bonding]
>>  [<ffffffff97a6a7c0>] process_one_work+0x140/0x3f0
>>  [<ffffffff97a6aef1>] worker_thread+0x121/0x370
>>  [<ffffffff97a6add0>] ? rescuer_thread+0x320/0x320
>>  [<ffffffff97a720a0>] kthread+0xc0/0xd0
>>  [<ffffffff97a71fe0>] ? flush_kthread_worker+0x80/0x80
>>  [<ffffffff97fa291c>] ret_from_fork+0x7c/0xb0
>>  [<ffffffff97a71fe0>] ? flush_kthread_worker+0x80/0x80
> 
> Please note that I got this assert-fail on 3.10 kernel and haven't
> verified if things have changed in mii_monitor context since then.
> 
Okay, this is definitely it. Moreover I cannot find
"bond_handle_link_change" function in any bonding version, google search
also shows up empty.

Could you please test this patch with the tree that it is intended for ?
I'm pretty certain that there won't be any problem.

And one more thing, please update the CC list, Jay's email now is:
j.vosburgh@gmail.com
according to the MAINTAINERS file.

Thanks,
 Nik
