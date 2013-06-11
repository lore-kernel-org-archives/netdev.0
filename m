From: Ben Greear <greearb@candelatech.com>
Subject: Re: kmemleak reports in kernel 3.9.5+
Date: Tue, 11 Jun 2013 12:52:41 -0700
Message-ID: <51B78009.2060808@candelatech.com>
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

I tried the command below, and it printed out quite a few things.


I'll try building a kernel without the extra SLUB debugging
to see if that helps.

Also, I read the kmemleak.txt documentation, but a question remains:

If I enable kmemleak at compile time, but disable it at boot
time using kmemleak=off, is there any significant runtime overhead?


[root@LEC2220-1 ~]# echo clear > /debug/kmemleak;sleep 60;echo scan > /debug/kmemleak; cat /debug/kmemleak
unreferenced object 0xffff88021867e450 (size 40):
   comm "chrony-helper", pid 1138, jiffies 4294699268 (age 91773.781s)
   hex dump (first 32 bytes):
     d0 cf e5 18 02 88 ff ff 80 0b be 19 02 88 ff ff  ................
     01 00 00 00 00 00 00 00 f0 34 a3 12 02 88 ff ff  .........4......
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
     [<ffffffff811971f6>] put_object+0x46/0x4a
     [<ffffffff811974e3>] delete_object_full+0x2d/0x32
     [<ffffffff815de663>] kmemleak_free+0x59/0x7a
     [<ffffffff8118bc0a>] slab_free_hook+0x21/0x87
     [<ffffffff8118e888>] kmem_cache_free+0xbe/0x15d
     [<ffffffff811acb71>] __d_free+0x56/0x5b
unreferenced object 0xffff880211893b50 (size 40):
   comm "nmcli", pid 1178, jiffies 4294699660 (age 91773.390s)
   hex dump (first 32 bytes):
     00 00 00 00 00 00 00 00 f0 ac bd 19 02 88 ff ff  ................
     01 00 00 00 00 00 00 00 e0 6c 6e 01 02 88 ff ff  .........ln.....
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
     [<ffffffff8109ccc1>] do_exit+0x3c9/0x978
     [<ffffffff8109d2f3>] do_group_exit+0x83/0xae
....


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
