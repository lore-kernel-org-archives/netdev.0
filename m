From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCHv2] bonding: Do not try to send packets over dead link
 in TLB mode.
Date: Sat, 12 Jul 2014 19:57:36 +0200
Message-ID: <53C17710.9060005@redhat.com>
References: <1405113030-28877-1-git-send-email-maheshb@google.com> <CAF2d9jiH0dQka-vwDFKFmpjea5rY+ijhCOjovJ_kP6AA-jT_Lg@mail.gmail.com> <53C0F561.2090600@redhat.com> <CAF2d9jhuDH1PjBzaFL44GY+EV9fvZ1N=USJMk3OtuZtxZLUxAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58751 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751976AbaGLR5p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jul 2014 13:57:45 -0400
In-Reply-To: <CAF2d9jhuDH1PjBzaFL44GY+EV9fvZ1N=USJMk3OtuZtxZLUxAA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/12/2014 07:17 PM, Mahesh Bandewar wrote:
<snip>
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>
>> Did you have CONFIG_DEBUG_ATOMIC_SLEEP in your kernel config ?
>>
> Yes I do have that enabled (along with few other)!
> 
> CONFIG_DEBUG_SPINLOCK=y
> CONFIG_DEBUG_MUTEXES=y
> # CONFIG_DEBUG_WW_MUTEX_SLOWPATH is not set
> CONFIG_DEBUG_LOCK_ALLOC=y
> CONFIG_PROVE_LOCKING=y
> CONFIG_LOCKDEP=y
> # CONFIG_LOCK_STAT is not set
> # CONFIG_DEBUG_LOCKDEP is not set
> CONFIG_DEBUG_ATOMIC_SLEEP=y
> # CONFIG_DEBUG_LOCKING_API_SELFTESTS is not set
> # CONFIG_LOCK_TORTURE_TEST is not set
> CONFIG_TRACE_IRQFLAGS=y
> CONFIG_STACKTRACE=y
> # CONFIG_DEBUG_KOBJECT is not set
> CONFIG_DEBUG_BUGVERBOSE=y
> CONFIG_DEBUG_LIST=y
> 
> Is there something else that is required that I missed?
> 
Then I'd say you have to adjust your test to hit the codepath that has the
write_lock. It is very easy, here's one way (verbosely described):
$ modprobe bonding mode=5 miimon=1 updelay=1000 # we need miimon active
with updelay so we can have slaves in BOND_LINK_BACK state
$ echo 0 > tlb_dynamic_lb
$ ip l set bond0 up
$ echo +eth1 > slaves
$ echo +eth2 > slaves
$ ip l set eth1 down # bring eth1 down so it'll go in BOND_LINK_BACK once
it's up again and eth2 will be the active_slave
$ ip l set eth1 up; ip l set eth2 down; # make eth1 up and in
BOND_LINK_BACK state for updelay and force it as active by downing eth2,
thus executing your code with write_lock_bh

This is just 1 example, you can do it in many other ways that lead to
executing your function in atomic context. Another good idea would be to
take a look at how write_lock_bh is implemented, and how the atomic check
is done, then you'll see that it'll definitely trigger.

I hope this was helpful.

>> [  556.669144] BUG: sleeping function called from invalid context at
>> mm/slub.c:965
>> [  556.670262] in_atomic(): 1, irqs_disabled(): 0, pid: 3316, name: bash
>> [  556.670939] CPU: 1 PID: 3316 Comm: bash Tainted: G           OE
>> 3.16.0-rc2+ #3
>> [  556.670941] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
>> [  556.670943]  0000000000000000 ffff88005b60fc70 ffffffff816af012
>> ffff8800490cb900
>> [  556.670957]  ffff88005b60fc80 ffffffff8109c30a ffff88005b60fcc0
>> ffffffff811b2283
>> [  556.670961]  ffffffffa01f45ae ffff8800490cb900 0000000000000000
>> ffff880049d9ac00
>> [  556.670965] Call Trace:
>> [  556.670975]  [<ffffffff816af012>] dump_stack+0x4d/0x66
>> [  556.670981]  [<ffffffff8109c30a>] __might_sleep+0xca/0x100
>> [  556.670987]  [<ffffffff811b2283>] __kmalloc+0x63/0x270
>> [  556.670996]  [<ffffffffa01f45ae>] ?
>> bond_alb_handle_link_change+0x7e/0x180 [bonding]
>> [  556.671010]  [<ffffffffa01f45ae>] bond_alb_handle_link_change+0x7e/0x180
>> [bonding]
>> [  556.671068]  [<ffffffffa01eac62>] bond_change_active_slave+0x3b2/0x620
>> [bonding]
>> [  556.671076]  [<ffffffffa01eaf94>] bond_select_active_slave+0xc4/0x1a0
>> [bonding]
>> [  556.671082]  [<ffffffffa01ec00d>] bond_enslave+0xf9d/0xfc0 [bonding]
>> [  556.671089]  [<ffffffffa01f70df>] bond_option_slaves_set+0xff/0x130
>> [bonding]
>> [  556.671095]  [<ffffffffa01f83ff>] __bond_opt_set+0xdf/0x330 [bonding]
>> [  556.671100]  [<ffffffffa01f8697>] bond_opt_tryset_rtnl+0x47/0x80 [bonding]
>> [  556.671106]  [<ffffffffa01f52e5>] bonding_sysfs_store_option+0x35/0x60
>> [bonding]
>> [  556.671113]  [<ffffffff8141e6f8>] dev_attr_store+0x18/0x30
>> [  556.671118]  [<ffffffff812435ad>] sysfs_kf_write+0x3d/0x50
>> [  556.671121]  [<ffffffff812430a4>] kernfs_fop_write+0xe4/0x160
>> [  556.671126]  [<ffffffff811cc367>] vfs_write+0xb7/0x1f0
>> [  556.671129]  [<ffffffff811ccf19>] SyS_write+0x49/0xb0
>> [  556.671134]  [<ffffffff81106f36>] ? __audit_syscall_exit+0x1f6/0x2a0
>> [  556.671139]  [<ffffffff816b69d2>] system_call_fastpath+0x16/0x1b
>>
>> Cheers,
>>  Nik
