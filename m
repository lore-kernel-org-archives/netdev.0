From: Ben Greear <greearb@candelatech.com>
Subject: Re: kmemleak reports in kernel 3.9.5+
Date: Tue, 11 Jun 2013 11:36:18 -0700
Message-ID: <51B76E22.5090706@candelatech.com>
References: <51B61982.2050903@candelatech.com> <CAHkRjk5SDCbqr0Br24YQuHr=j7DmnpYk9CShrz1qiuYff7+qAw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHkRjk5SDCbqr0Br24YQuHr=j7DmnpYk9CShrz1qiuYff7+qAw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/10/2013 03:32 PM, Catalin Marinas wrote:
> On 10 June 2013 19:22, Ben Greear <greearb@candelatech.com> wrote:
>> We had a system go OOM while doing lots of wireless
>> stations.  (System had 8GB of RAM, so I suspect a leak).
>>
>> I enabled kmemleak in a 3.9.5 (plus some local patches) and
>> I see the entries below.  Any idea if these are real or not?
>>
>> unreferenced object 0xffff880212281c80 (size 128):
>>    comm "systemd", pid 1, jiffies 4294682684 (age 1159.517s)
>>    hex dump (first 32 bytes):
>>      60 39 27 12 02 88 ff ff 00 02 20 00 00 00 ad de  `9'....... .....
>>      10 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>>    backtrace:
>>      [<ffffffff815de7bf>] kmemleak_alloc+0x73/0x98
>>      [<ffffffff8118b4d4>] slab_post_alloc_hook+0x28/0x2a
>>      [<ffffffff8118d605>] __kmalloc+0xf9/0x122
>>      [<ffffffff8154946d>] kzalloc.clone.0+0xe/0x10
>>      [<ffffffff81549494>] fib_default_rule_add+0x25/0x7a
>>      [<ffffffffa014f5a9>] ip6mr_net_init+0x7e/0x118 [ipv6]
>>      [<ffffffff8152c992>] ops_init+0xd6/0xf7
>>      [<ffffffff8152cb51>] register_pernet_operations+0xc2/0x16b
>>      [<ffffffff8152cc87>] register_pernet_subsys+0x2e/0x47
>>      [<ffffffffa016db69>] 0xffffffffa016db69
>>      [<ffffffffa016d109>] 0xffffffffa016d109
>>      [<ffffffff8100207f>] do_one_initcall+0x7f/0x13e
>>      [<ffffffff810f3985>] do_init_module+0x44/0x18f
>>      [<ffffffff810f5da7>] load_module+0x14d1/0x168e
>>      [<ffffffff810f6114>] sys_init_module+0xfd/0x101
>>      [<ffffffff815f6599>] system_call_fastpath+0x16/0x1b
>
> No idea yet. You can try:
>
> echo clear > /sys/kernel/debug/kmemleak
>
> and see if there are more appearing after. All seem to have a common
> allocation path via debug_object_activate -> ... ->
> rcuhead_fixup_activate -> ... -> __debug_object_init.

I let the system run overnight, and there are a good many more
kmemleak reports this morning.  I have not yet tried the clear
option.

I have SLUB debugging enabled, so that is probably explains
the debug stuff in the stacks.

Here are some more that may be of interest.

unreferenced object 0xffff88010b719700 (size 40):
   comm "gua", pid 11301, jiffies 4352877266 (age 29217.682s)
   hex dump (first 32 bytes):
     00 e0 10 08 01 88 ff ff a0 68 1e 13 01 88 ff ff  .........h......
     01 00 00 00 00 00 00 00 70 3d 56 13 01 88 ff ff  ........p=V.....
   backtrace:
     [<ffffffff815de7bf>] kmemleak_alloc+0x73/0x98
     [<ffffffff8118b4d4>] slab_post_alloc_hook+0x28/0x2a
     [<ffffffff8118d9a7>] kmem_cache_alloc+0xb2/0x123
     [<ffffffff81316919>] __debug_object_init+0x43/0x35f
     [<ffffffff81316c4c>] debug_object_init_on_stack+0x17/0x19
     [<ffffffff810bb5fa>] hrtimer_init_on_stack+0x27/0x75
     [<ffffffff815ed663>] schedule_hrtimeout_range_clock+0x67/0x113
     [<ffffffff815ed722>] schedule_hrtimeout_range+0x13/0x15
     [<ffffffff811aa1fa>] poll_schedule_timeout+0x48/0x64
     [<ffffffff811aaff6>] do_select+0x519/0x550
     [<ffffffff811df227>] compat_core_sys_select+0x1c7/0x25a
     [<ffffffff811df526>] compat_sys_select+0x99/0xc1
     [<ffffffff815f7c4c>] sysenter_dispatch+0x7/0x26
     [<ffffffffffffffff>] 0xffffffffffffffff


unreferenced object 0xffff880111d33420 (size 40):
   comm "ps", pid 25114, jiffies 4352875696 (age 29219.150s)
   hex dump (first 32 bytes):
     c0 3c 68 0b 01 88 ff ff 70 41 ec 11 01 88 ff ff  .<h.....pA......
     01 00 00 00 00 00 00 00 e0 6c 5a 12 01 88 ff ff  .........lZ.....
   backtrace:
     [<ffffffff815de7bf>] kmemleak_alloc+0x73/0x98
     [<ffffffff8118b4d4>] slab_post_alloc_hook+0x28/0x2a
     [<ffffffff8118d9a7>] kmem_cache_alloc+0xb2/0x123
     [<ffffffff81316919>] __debug_object_init+0x43/0x35f
     [<ffffffff81316c62>] debug_object_init+0x14/0x16
     [<ffffffff810b4e0a>] rcuhead_fixup_activate+0x2b/0xba
     [<ffffffff81315f12>] debug_object_fixup+0x15/0x1d
     [<ffffffff81316557>] debug_object_activate+0x126/0x139
     [<ffffffff81118e4a>] __call_rcu.clone.1+0x58/0x22a
     [<ffffffff81119065>] call_rcu+0x17/0x19
     [<ffffffff8119be2b>] file_free+0x31/0x35
     [<ffffffff8119c05a>] __fput+0x1bb/0x1db
     [<ffffffff8119c0ca>] ____fput+0xe/0x10
     [<ffffffff810b48d5>] task_work_run+0x85/0xb0
     [<ffffffff810106c6>] do_notify_resume+0x6d/0x80
     [<ffffffff815f68d2>] int_signal+0x12/0x17

unreferenced object 0xffff88010cc92e60 (size 40):
   comm "updatedb", pid 24952, jiffies 4352871287 (age 29223.220s)
   hex dump (first 32 bytes):
     00 60 16 0e 01 88 ff ff d0 af 19 10 01 88 ff ff  .`..............
     01 00 00 00 00 00 00 00 a0 2d 39 0e 01 88 ff ff  .........-9.....
   backtrace:
     [<ffffffff815de7bf>] kmemleak_alloc+0x73/0x98
     [<ffffffff8118b4d4>] slab_post_alloc_hook+0x28/0x2a
     [<ffffffff8118d9a7>] kmem_cache_alloc+0xb2/0x123
     [<ffffffff81316919>] __debug_object_init+0x43/0x35f
     [<ffffffff81316c62>] debug_object_init+0x14/0x16
     [<ffffffff810b296c>] __init_work+0x27/0x29
     [<ffffffff81241371>] ext4_alloc_inode+0x173/0x1cb
     [<ffffffff811b0db4>] alloc_inode+0x1d/0x78
     [<ffffffff811b0e7c>] iget_locked+0x6d/0x12f
     [<ffffffff81229817>] ext4_iget+0x2c/0x932
     [<ffffffff8122f485>] ext4_lookup+0xd2/0x12a
     [<ffffffff811a3556>] lookup_real+0x2c/0x47
     [<ffffffff811a3e0c>] __lookup_hash+0x33/0x3c
     [<ffffffff811a5897>] walk_component+0x73/0x171
     [<ffffffff811a6e2c>] path_lookupat+0xa7/0x304
     [<ffffffff811a70b4>] filename_lookup+0x2b/0x82

(I sent a similar one to the ext4 mailing list already.)


unreferenced object 0xffff8801c6d2eb80 (size 40):
   comm "softirq", pid 0, jiffies 4296641468 (age 85451.733s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 70 01 6e 7b 01 88 ff ff  ........p.n{....
     02 00 00 00 00 00 00 00 58 54 24 ca 01 88 ff ff  ........XT$.....
   backtrace:
     [<ffffffff815de7bf>] kmemleak_alloc+0x73/0x98
     [<ffffffff8118b4d4>] slab_post_alloc_hook+0x28/0x2a
     [<ffffffff8118d9a7>] kmem_cache_alloc+0xb2/0x123
     [<ffffffff81316919>] __debug_object_init+0x43/0x35f
     [<ffffffff81316c62>] debug_object_init+0x14/0x16
     [<ffffffff810a70df>] init_timer_key+0x2e/0xb3
     [<ffffffffa0128e4d>] ipv6_add_addr+0x19f/0x3bc [ipv6]
     [<ffffffffa012c885>] addrconf_add_linklocal+0x4c/0x7f [ipv6]
     [<ffffffffa012d06a>] addrconf_notify+0x773/0x95e [ipv6]
     [<ffffffff815f30d6>] notifier_call_chain+0x37/0x63
     [<ffffffff810bc994>] raw_notifier_call_chain+0x14/0x16
     [<ffffffff815333ae>] call_netdevice_notifiers+0x4a/0x4f
     [<ffffffff8153404d>] netdev_state_change+0x27/0x3a
     [<ffffffff815418ef>] linkwatch_do_dev+0x46/0x54
     [<ffffffff81541b0e>] __linkwatch_run_queue+0x180/0x1ca
     [<ffffffff81541b7d>] linkwatch_event+0x25/0x2c


unreferenced object 0xffff8801c8e41e78 (size 192):
   comm "kworker/u:2", pid 157, jiffies 4295509873 (age 86582.869s)
   hex dump (first 32 bytes):
     41 0d 00 30 02 00 00 00 6b 6b 6b 6b 6b 6b 6b 6b  A..0....kkkkkkkk
     6b 6b 6b 6b 6b 6b 6b 6b 69 00 00 00 00 0c 2e 32  kkkkkkkki......2
   backtrace:
     [<ffffffff815de7bf>] kmemleak_alloc+0x73/0x98
     [<ffffffff8118b4d4>] slab_post_alloc_hook+0x28/0x2a
     [<ffffffff8118d605>] __kmalloc+0xf9/0x122
     [<ffffffffa027cb27>] cfg80211_inform_bss_frame+0x114/0x1f8 [cfg80211]
     [<ffffffffa03d6865>] ieee80211_bss_info_update+0x66/0x21f [mac80211]
     [<ffffffffa040aec6>] ieee80211_rx_bss_info+0x12f/0x1ca [mac80211]
     [<ffffffffa040b017>] ieee80211_rx_mgmt_probe_resp+0xb6/0x197 [mac80211]
     [<ffffffffa040e8a3>] ieee80211_sta_rx_queued_mgmt+0xdd/0x60e [mac80211]
     [<ffffffffa03df0ee>] ieee80211_iface_work+0x238/0x2cc [mac80211]
     [<ffffffff810b0cd3>] process_one_work+0x292/0x42e
     [<ffffffff810b36af>] worker_thread+0x14f/0x264
     [<ffffffff810b7bea>] kthread+0xc7/0xcf
     [<ffffffff815f64ec>] ret_from_fork+0x7c/0xb0
     [<ffffffffffffffff>] 0xffffffffffffffff

(I plan to investigate the one above...I have some understanding of
the wifi code, and have some patches of my own applied to that code.)


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
