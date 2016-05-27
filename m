From: Baozeng Ding <sploving1@gmail.com>
Subject: Re: BUG: net/netlink: KASAN: use-after-free in netlink_sock_destruct
Date: Fri, 27 May 2016 10:10:57 +0800
Message-ID: <cd3f3b6b-fbf0-2feb-909a-9c9b3875fba9@gmail.com>
References: <e1e236d9-11c1-02c6-b18b-7961fc3fd584@gmail.com>
 <1464275215.5939.93.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, chamaken@gmail.com, daniel@iogearbox.net,
	fw@strlen.de, herbert@gondor.apana.org.au, dh.herrmann@gmail.com,
	christophe.ricard@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33558 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932104AbcE0CLH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 22:11:07 -0400
Received: by mail-pf0-f196.google.com with SMTP id b124so10756028pfb.0
        for <netdev@vger.kernel.org>; Thu, 26 May 2016 19:11:07 -0700 (PDT)
In-Reply-To: <1464275215.5939.93.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2016/5/26 23:06, Eric Dumazet wrote:
> On Thu, 2016-05-26 at 22:48 +0800, Baozeng Ding wrote:
>> Hi all,
>> I've got the following report use-after-free in netlink_sock_destruct while running syzkaller.
>> Unfortunately no reproducer.The kernel version is 4.6 (May 15, on commit 2dcd0af568b0cf583645c8a317dd12e344b1c72a). Thanks.
>>
>> ==================================================================
>> BUG: KASAN: use-after-free in kfree_skb+0x28c/0x310 at addr ffff880036c1179c
>> Read of size 4 by task syz-executor/21618
>> =============================================================================
>> BUG skbuff_head_cache (Tainted: G        W      ): kasan: bad access detected
>> -----------------------------------------------------------------------------
>>
>> Disabling lock debugging due to kernel taint
>> INFO: Slab 0xffffea0000db0400 objects=25 used=3 fp=0xffff880036c116c0 flags=0x1fffc0000004080
>> INFO: Object 0xffff880036c11680 @offset=5760 fp=0xbbbbbbbbbbbbbbbb
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
>>  0000000000000002 ffff88006da07c40 ffffffff8295f5f1 ffff88003e0fc5c0
>>  ffff880036c11680 ffffea0000db0400 ffff880036c10000 ffff88006da07c70
>>  ffffffff8171144d ffff88003e0fc5c0 ffffea0000db0400 ffff880036c11680
>> Call Trace:
>>  [<     inline     >] __dump_stack /lib/dump_stack.c:15
>>  [<ffffffff8295f5f1>] dump_stack+0xb3/0x112 /lib/dump_stack.c:51
>>  [<ffffffff8171144d>] print_trailer+0x10d/0x190 /mm/slub.c:667
>>  [<ffffffff81717f3f>] object_err+0x2f/0x40 /mm/slub.c:674
>>  [<     inline     >] print_address_description /mm/kasan/report.c:179
>>  [<ffffffff8171a768>] kasan_report_error+0x218/0x530 /mm/kasan/report.c:275
>>  [<ffffffff81409ff0>] ? debug_check_no_locks_freed+0x290/0x290 /kernel/locking/lockdep.c:4212
>>  [<     inline     >] kasan_report /mm/kasan/report.c:297
>>  [<ffffffff8171ab3e>] __asan_report_load4_noabort+0x3e/0x40 /mm/kasan/report.c:317
>>  [<     inline     >] ? atomic_read /include/linux/compiler.h:222
>>  [<ffffffff84b66e7c>] ? kfree_skb+0x28c/0x310 /net/core/skbuff.c:699
>>  [<     inline     >] atomic_read /include/linux/compiler.h:222
>>  [<ffffffff84b66e7c>] kfree_skb+0x28c/0x310 /net/core/skbuff.c:699
>>  [<ffffffff84cea38b>] netlink_sock_destruct+0xeb/0x2b0 /net/netlink/af_netlink.c:334
>>  [<ffffffff84cea2a0>] ? __netlink_create+0x1d0/0x1d0 /net/netlink/af_netlink.c:577
>>  [<ffffffff84b5a3da>] sk_destruct+0x4a/0x4f0 /net/core/sock.c:1429
>>  [<ffffffff84b5a8d7>] __sk_free+0x57/0x200 /net/core/sock.c:1459
>>  [<ffffffff84b5aab0>] sk_free+0x30/0x40 /net/core/sock.c:1470
>>  [<     inline     >] sock_put /include/net/sock.h:1506
>>  [<ffffffff84cec004>] deferred_put_nlk_sk+0x34/0x40 /net/netlink/af_netlink.c:652
>>  [<     inline     >] __rcu_reclaim /kernel/rcu/rcu.h:118
>>  [<     inline     >] rcu_do_batch /kernel/rcu/tree.c:2681
>>  [<     inline     >] invoke_rcu_callbacks /kernel/rcu/tree.c:2947
>>  [<     inline     >] __rcu_process_callbacks /kernel/rcu/tree.c:2914
>>  [<ffffffff814672f1>] rcu_process_callbacks+0xa71/0x11d0 /kernel/rcu/tree.c:2931
>>  [<     inline     >] ? __rcu_reclaim /kernel/rcu/rcu.h:108
>>  [<     inline     >] ? rcu_do_batch /kernel/rcu/tree.c:2681
>>  [<     inline     >] ? invoke_rcu_callbacks /kernel/rcu/tree.c:2947
>>  [<     inline     >] ? __rcu_process_callbacks /kernel/rcu/tree.c:2914
>>  [<ffffffff8146729c>] ? rcu_process_callbacks+0xa1c/0x11d0 /kernel/rcu/tree.c:2931
>>  [<ffffffff84cebfd0>] ? __netlink_deliver_tap+0x7c0/0x7c0 /net/netlink/af_netlink.c:204
>>  [<ffffffff85ca969b>] __do_softirq+0x22b/0x8da /kernel/softirq.c:273
>>  [<     inline     >] invoke_softirq /kernel/softirq.c:350
>>  [<ffffffff813174dd>] irq_exit+0x15d/0x190 /kernel/softirq.c:391
>>  [<     inline     >] exiting_irq /./arch/x86/include/asm/apic.h:658
>>  [<ffffffff85ca8fdb>] smp_apic_timer_interrupt+0x7b/0xa0 /arch/x86/kernel/apic/apic.c:932
>>  [<ffffffff85ca756c>] apic_timer_interrupt+0x8c/0xa0 /arch/x86/entry/entry_64.S:454
>>  [<     inline     >] ? atomic_add_return /./arch/x86/include/asm/atomic.h:156
>>  [<     inline     >] ? kref_get /include/linux/kref.h:46
>>  [<ffffffff85c84e37>] ? klist_next+0x177/0x400 /lib/klist.c:393
>>  [<     inline     >] ? kref_get /include/linux/kref.h:46
>>  [<ffffffff85c84e28>] ? klist_next+0x168/0x400 /lib/klist.c:393
>>  [<ffffffff83254ebb>] class_dev_iter_next+0x8b/0xd0 /drivers/base/class.c:324
>>  [<ffffffff82c320d0>] ? tty_get_pgrp+0x80/0x80 /drivers/tty/tty_io.c:2525
>>  [<ffffffff83255bb1>] class_find_device+0x101/0x1c0 /drivers/base/class.c:428
>>  [<ffffffff83255ab0>] ? class_for_each_device+0x1d0/0x1d0 /drivers/base/class.c:375
>>  [<     inline     >] tty_get_device /drivers/tty/tty_io.c:3139
>>  [<ffffffff82c3e98b>] alloc_tty_struct+0x5fb/0x840 /drivers/tty/tty_io.c:3183
>>  [<ffffffff82c3e390>] ? do_SAK_work+0x20/0x20 /drivers/tty/tty_io.c:3112
>>  [<ffffffff85c9f960>] ? mutex_lock_interruptible_nested+0x980/0x980 ??:?
>>  [<ffffffff82c3ec48>] tty_init_dev+0x78/0x4b0 /drivers/tty/tty_io.c:1532
>>  [<     inline     >] tty_open_by_driver /drivers/tty/tty_io.c:2065
>>  [<ffffffff82c3fdb1>] tty_open+0xd31/0x1050 /drivers/tty/tty_io.c:2113
>>  [<ffffffff82c3f080>] ? tty_init_dev+0x4b0/0x4b0 /drivers/tty/tty_io.c:1543
>>  [<     inline     >] ? spin_unlock /include/linux/spinlock.h:347
>>  [<ffffffff8177237f>] ? chrdev_open+0xbf/0x4c0 /fs/char_dev.c:376
>>  [<ffffffff82c3f080>] ? tty_init_dev+0x4b0/0x4b0 /drivers/tty/tty_io.c:1543
>>  [<ffffffff817724ea>] chrdev_open+0x22a/0x4c0 /fs/char_dev.c:388
>>  [<ffffffff817722c0>] ? cdev_put+0x60/0x60 /fs/char_dev.c:338
>>  [<ffffffff81837a2e>] ? __fsnotify_parent+0x5e/0x2b0 /fs/notify/fsnotify.c:98
>>  [<ffffffff8269f0c9>] ? security_file_open+0x89/0x190 /security/security.c:840
>>  [<ffffffff8175dbb2>] do_dentry_open+0x6a2/0xcb0 /fs/open.c:736
>>  [<ffffffff817722c0>] ? cdev_put+0x60/0x60 /fs/char_dev.c:338
>>  [<ffffffff81761223>] vfs_open+0x113/0x210 /fs/open.c:849
>>  [<ffffffff8178600d>] ? may_open+0x1cd/0x260 /fs/namei.c:2776
>>  [<     inline     >] do_last /fs/namei.c:3249
>>  [<ffffffff817984d5>] path_openat+0x4ff5/0x5b70 /fs/namei.c:3385
>>  [<ffffffff817934e0>] ? path_lookupat+0x450/0x450 /fs/namei.c:2132
>>  [<     inline     >] ? __raw_spin_unlock /include/linux/spinlock_api_smp.h:153
>>  [<ffffffff85ca6162>] ? _raw_spin_unlock+0x22/0x30 /kernel/locking/spinlock.c:183
>>  [<ffffffff81409ff0>] ? debug_check_no_locks_freed+0x290/0x290 /kernel/locking/lockdep.c:4212
>>  [<ffffffff8171266e>] ? alloc_debug_processing+0x6e/0x1b0 /mm/slub.c:1085
>>  [<ffffffff8179c6ce>] do_filp_open+0x18e/0x250 /fs/namei.c:3420
>>  [<ffffffff8179c540>] ? user_path_mountpoint_at+0x40/0x40 /fs/namei.c:2575
>>  [<ffffffff817c2620>] ? do_dup2+0x410/0x410 /fs/file.c:262
>>  [<     inline     >] ? __raw_spin_unlock /include/linux/spinlock_api_smp.h:153
>>  [<ffffffff85ca6162>] ? _raw_spin_unlock+0x22/0x30 /kernel/locking/spinlock.c:183
>>  [<     inline     >] ? spin_unlock /include/linux/spinlock.h:347
>>  [<ffffffff817c43c3>] ? __alloc_fd+0x1e3/0x530 /fs/file.c:551
>>  [<ffffffff81761a31>] do_sys_open+0x201/0x420 /fs/open.c:1016
>>  [<ffffffff81761830>] ? filp_open+0x70/0x70 /fs/open.c:987
>>  [<     inline     >] SYSC_open /fs/open.c:1034
>>  [<ffffffff81761c7d>] SyS_open+0x2d/0x40 /fs/open.c:1029
>>  [<ffffffff85ca6900>] entry_SYSCALL_64_fastpath+0x23/0xc1 /arch/x86/entry/entry_64.S:207
>> Memory state around the buggy address:
>>  ffff880036c11680: fc fc fc fc fc fc fc fc fb fb fb fb fb fb fb fb
>>  ffff880036c11700: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
>>> ffff880036c11780: fb fb fb fb fc fc fc fc fc fc fc fc fc fc fc fc
>>                             ^
>>  ffff880036c11800: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>>  ffff880036c11880: fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc fc
>> ==================================================================
>> ==================================================================
>>
>> Best Regards,
>> Baozeng
> 
Sorry. I forgot to apply the patch. I will check it carefully before reporting a bug in future. Thank you, Eric.
> Are you sure this is not a dup of :
> 
> commit 92964c79b357efd980812c4de5c1fd2ec8bb5520
> Author: Herbert Xu <herbert@gondor.apana.org.au>
> Date:   Mon May 16 17:28:16 2016 +0800
> 
>     netlink: Fix dump skb leak/double free
>     
>     When we free cb->skb after a dump, we do it after releasing the
>     lock.  This means that a new dump could have started in the time
>     being and we'll end up freeing their skb instead of ours.
>     
>     This patch saves the skb and module before we unlock so we free
>     the right memory.
>     
>     Fixes: 16b304f3404f ("netlink: Eliminate kmalloc in netlink dump operation.")
>     Reported-by: Baozeng Ding <sploving1@gmail.com>
>     Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>     Acked-by: Cong Wang <xiyou.wangcong@gmail.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> 
