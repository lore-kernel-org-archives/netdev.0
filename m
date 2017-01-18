From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: fs, net: deadlock between bind/splice on af_unix
Date: Wed, 18 Jan 2017 10:17:54 +0100
Message-ID: <CACT4Y+Y_3i=PThhVzHXYnCQm_xN72VQ0eN9Ae4uXyORq_a_Z6w@mail.gmail.com>
References: <CACT4Y+Z981V+QLHr=PnQy1Dvxrpp-nCDhQtf+5HuNAusH+Vqxw@mail.gmail.com>
 <CACT4Y+a-fTzW95ViVP3knhNTa=h6XFB0bMddcyQVeeV+LbXKHw@mail.gmail.com>
 <CAM_iQpXu+fyjmvrYRB9+VJCdSLS=7Jiet762hqWDANfsOM0XWw@mail.gmail.com>
 <20161209013208.GW1555@ZenIV.linux.org.uk> <CAM_iQpXjeG5=wZyQP-yOKcB4WRfgGRjeQ+NDHyeSWwdU50Xh5g@mail.gmail.com>
 <20161209064144.GZ1555@ZenIV.linux.org.uk> <CACT4Y+ad1s6HPdw-ocQ5YfFx7qCeWb3z1k7F9+9KsNmw6+Tszw@mail.gmail.com>
 <CAM_iQpWu+V2E_uxJLUjS+xM+94CKKR+Bv95UrFPuswUAuAGM+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Rainer Weikusat <rweikusat@mobileactivedefense.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        syzkaller <syzkaller@googlegroups.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpWu+V2E_uxJLUjS+xM+94CKKR+Bv95UrFPuswUAuAGM+w@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 17, 2017 at 10:21 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Mon, Jan 16, 2017 at 1:32 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>> On Fri, Dec 9, 2016 at 7:41 AM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>>> On Thu, Dec 08, 2016 at 10:32:00PM -0800, Cong Wang wrote:
>>>
>>>> > Why do we do autobind there, anyway, and why is it conditional on
>>>> > SOCK_PASSCRED?  Note that e.g. for SOCK_STREAM we can bloody well get
>>>> > to sending stuff without autobind ever done - just use socketpair()
>>>> > to create that sucker and we won't be going through the connect()
>>>> > at all.
>>>>
>>>> In the case Dmitry reported, unix_dgram_sendmsg() calls unix_autobind(),
>>>> not SOCK_STREAM.
>>>
>>> Yes, I've noticed.  What I'm asking is what in there needs autobind triggered
>>> on sendmsg and why doesn't the same need affect the SOCK_STREAM case?
>>>
>>>> I guess some lock, perhaps the u->bindlock could be dropped before
>>>> acquiring the next one (sb_writer), but I need to double check.
>>>
>>> Bad idea, IMO - do you *want* autobind being able to come through while
>>> bind(2) is busy with mknod?
>>
>>
>> Ping. This is still happening on HEAD.
>>
>
> Thanks for your reminder. Mind to give the attached patch (compile only)
> a try? I take another approach to fix this deadlock, which moves the
> unix_mknod() out of unix->bindlock. Not sure if there is any unexpected
> impact with this way.


I instantly hit:

general protection fault: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 0 PID: 8930 Comm: syz-executor1 Not tainted 4.10.0-rc4+ #177
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
task: ffff88003c908840 task.stack: ffff88003a9a0000
RIP: 0010:__lock_acquire+0xb3a/0x3430 kernel/locking/lockdep.c:3224
RSP: 0018:ffff88003a9a7218 EFLAGS: 00010006
RAX: dffffc0000000000 RBX: dffffc0000000000 RCX: 0000000000000000
RDX: 0000000000000003 RSI: 0000000000000000 RDI: 1ffff10007534e9d
RBP: ffff88003a9a7750 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000018 R11: 0000000000000000 R12: ffff88003c908840
R13: 0000000000000001 R14: ffffffff863504a0 R15: 0000000000000001
FS:  00007f4f8eb5d700(0000) GS:ffff88003fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020b1d000 CR3: 000000003bde9000 CR4: 00000000000006f0
Call Trace:
 lock_acquire+0x2a1/0x630 kernel/locking/lockdep.c:3753
 __raw_spin_lock include/linux/spinlock_api_smp.h:144 [inline]
 _raw_spin_lock+0x33/0x50 kernel/locking/spinlock.c:151
 spin_lock include/linux/spinlock.h:302 [inline]
 list_lru_add+0x10b/0x340 mm/list_lru.c:115
 d_lru_add fs/dcache.c:366 [inline]
 dentry_lru_add fs/dcache.c:421 [inline]
 dput.part.27+0x659/0x7c0 fs/dcache.c:784
 dput+0x1f/0x30 fs/dcache.c:753
 path_put+0x31/0x70 fs/namei.c:500
 unix_bind+0x424/0xea0 net/unix/af_unix.c:1072
 SYSC_bind+0x20e/0x4a0 net/socket.c:1413
 SyS_bind+0x24/0x30 net/socket.c:1399
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x4454b9
RSP: 002b:00007f4f8eb5cb58 EFLAGS: 00000292 ORIG_RAX: 0000000000000031
RAX: ffffffffffffffda RBX: 000000000000001d RCX: 00000000004454b9
RDX: 0000000000000008 RSI: 000000002002cff8 RDI: 000000000000001d
RBP: 00000000006dd230 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000292 R12: 0000000000700000
R13: 00007f4f8f2de9d0 R14: 00007f4f8f2dfc40 R15: 0000000000000000
Code: e9 03 f3 48 ab 48 81 c4 10 05 00 00 44 89 e8 5b 41 5c 41 5d 41
5e 41 5f 5d c3 4c 89 d2 48 b8 00 00 00 00 00 fc ff df 48 c1 ea 03 <80>
3c 02 00 0f 85 9e 26 00 00 49 81 3a e0 be 6b 85 41 bf 00 00
RIP: __lock_acquire+0xb3a/0x3430 kernel/locking/lockdep.c:3224 RSP:
ffff88003a9a7218
---[ end trace 78951d69744a2fe1 ]---
Kernel panic - not syncing: Fatal exception
Dumping ftrace buffer:
   (ftrace buffer empty)
Kernel Offset: disabled


and:


BUG: KASAN: use-after-free in list_lru_add+0x2fd/0x340
mm/list_lru.c:112 at addr ffff88006b301340
Read of size 8 by task syz-executor0/7116
CPU: 2 PID: 7116 Comm: syz-executor0 Not tainted 4.10.0-rc4+ #177
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:15 [inline]
 dump_stack+0x2ee/0x3ef lib/dump_stack.c:51
 kasan_object_err+0x1c/0x70 mm/kasan/report.c:165
 print_address_description mm/kasan/report.c:203 [inline]
 kasan_report_error mm/kasan/report.c:287 [inline]
 kasan_report+0x1b6/0x460 mm/kasan/report.c:307
 __asan_report_load8_noabort+0x14/0x20 mm/kasan/report.c:333
 list_lru_add+0x2fd/0x340 mm/list_lru.c:112
 d_lru_add fs/dcache.c:366 [inline]
 dentry_lru_add fs/dcache.c:421 [inline]
 dput.part.27+0x659/0x7c0 fs/dcache.c:784
 dput+0x1f/0x30 fs/dcache.c:753
 path_put+0x31/0x70 fs/namei.c:500
 unix_bind+0x424/0xea0 net/unix/af_unix.c:1072
 SYSC_bind+0x20e/0x4a0 net/socket.c:1413
 SyS_bind+0x24/0x30 net/socket.c:1399
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x4454b9
RSP: 002b:00007f1b034ebb58 EFLAGS: 00000292 ORIG_RAX: 0000000000000031
RAX: ffffffffffffffda RBX: 0000000000000016 RCX: 00000000004454b9
RDX: 0000000000000008 RSI: 000000002002eff8 RDI: 0000000000000016
RBP: 00000000006dd230 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000292 R12: 0000000000700000
R13: 00007f1b03c6d458 R14: 00007f1b03c6e5e8 R15: 0000000000000000
Object at ffff88006b301300, in cache vm_area_struct size: 192
Allocated:
PID = 1391

[<ffffffff812b2686>] save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57

[<ffffffff81a0e713>] save_stack+0x43/0xd0 mm/kasan/kasan.c:502

[<ffffffff81a0e9da>] set_track mm/kasan/kasan.c:514 [inline]
[<ffffffff81a0e9da>] kasan_kmalloc+0xaa/0xd0 mm/kasan/kasan.c:605

[<ffffffff81a0efd2>] kasan_slab_alloc+0x12/0x20 mm/kasan/kasan.c:544

[<ffffffff81a0a5e2>] kmem_cache_alloc+0x102/0x680 mm/slab.c:3563

[<ffffffff8144093b>] dup_mmap kernel/fork.c:609 [inline]
[<ffffffff8144093b>] dup_mm kernel/fork.c:1145 [inline]
[<ffffffff8144093b>] copy_mm kernel/fork.c:1199 [inline]
[<ffffffff8144093b>] copy_process.part.42+0x503b/0x5fd0 kernel/fork.c:1669

[<ffffffff81441e10>] copy_process kernel/fork.c:1494 [inline]
[<ffffffff81441e10>] _do_fork+0x200/0xff0 kernel/fork.c:1950

[<ffffffff81442cd7>] SYSC_clone kernel/fork.c:2060 [inline]
[<ffffffff81442cd7>] SyS_clone+0x37/0x50 kernel/fork.c:2054

[<ffffffff81009798>] do_syscall_64+0x2e8/0x930 arch/x86/entry/common.c:280

[<ffffffff841cadc9>] return_from_SYSCALL_64+0x0/0x7a
Freed:
PID = 5275

[<ffffffff812b2686>] save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:57

[<ffffffff81a0e713>] save_stack+0x43/0xd0 mm/kasan/kasan.c:502

[<ffffffff81a0f04f>] set_track mm/kasan/kasan.c:514 [inline]
[<ffffffff81a0f04f>] kasan_slab_free+0x6f/0xb0 mm/kasan/kasan.c:578

[<ffffffff81a0c3b1>] __cache_free mm/slab.c:3505 [inline]
[<ffffffff81a0c3b1>] kmem_cache_free+0x71/0x240 mm/slab.c:3765

[<ffffffff81976992>] remove_vma+0x162/0x1b0 mm/mmap.c:175

[<ffffffff8197f72f>] exit_mmap+0x2ef/0x490 mm/mmap.c:2952

[<ffffffff814390bb>] __mmput kernel/fork.c:873 [inline]
[<ffffffff814390bb>] mmput+0x22b/0x6e0 kernel/fork.c:895

[<ffffffff81453a3f>] exit_mm kernel/exit.c:521 [inline]
[<ffffffff81453a3f>] do_exit+0x9cf/0x28a0 kernel/exit.c:826

[<ffffffff8145a369>] do_group_exit+0x149/0x420 kernel/exit.c:943

[<ffffffff81489630>] get_signal+0x7e0/0x1820 kernel/signal.c:2313

[<ffffffff8127ca92>] do_signal+0xd2/0x2190 arch/x86/kernel/signal.c:807

[<ffffffff81007900>] exit_to_usermode_loop+0x200/0x2a0
arch/x86/entry/common.c:156

[<ffffffff81009413>] prepare_exit_to_usermode
arch/x86/entry/common.c:190 [inline]
[<ffffffff81009413>] syscall_return_slowpath+0x4d3/0x570
arch/x86/entry/common.c:259

[<ffffffff841cada2>] entry_SYSCALL_64_fastpath+0xc0/0xc2
Memory state around the buggy address:
 ffff88006b301200: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
 ffff88006b301280: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
>ffff88006b301300: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
                                           ^
 ffff88006b301380: fb fb fb fb fb fb fb fb fc fc fc fc fc fc fc fc
 ffff88006b301400: fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb fb
==================================================================
