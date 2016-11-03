From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: bpf: kernel BUG in htab_elem_free
Date: Thu, 3 Nov 2016 08:15:37 -0600
Message-ID: <CACT4Y+a2W++HSgMXqFSqNDuexudHf0buZqtt7pBHrAKz57pFeQ@mail.gmail.com>
References: <CACT4Y+YUWArFF=6VGJvzTEr7C7E323gOCno7fyw36xBYC7MH=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: Alexei Starovoitov <ast@kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+YUWArFF=6VGJvzTEr7C7E323gOCno7fyw36xBYC7MH=w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 2, 2016 at 11:14 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> Here we go.
>
> The following program triggers kernel BUG in htab_elem_free.
> On commit 0c183d92b20b5c84ca655b45ef57b3318b83eb9e (Oct 31).
> Run as "while true; do ./a.out; done".
>
> ------------[ cut here ]------------
> kernel BUG at mm/slub.c:3866!
> invalid opcode: 0000 [#1] SMP KASAN
> Modules linked in:
> CPU: 1 PID: 1542 Comm: kworker/1:2 Not tainted 4.9.0-rc3+ #20
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> Workqueue: events bpf_map_free_deferred
> task: ffff88003b9c0040 task.stack: ffff88003cb70000
> RIP: 0010:[<ffffffff814c9f00>]  [<ffffffff814c9f00>] kfree+0x140/0x1a0
> RSP: 0018:ffff88003cb77c50  EFLAGS: 00010246
> RAX: ffffea0000fb0aa0 RBX: ffff88003ec2a1a8 RCX: 0000000000000000
> RDX: 0000000000000000 RSI: 1ffff10007b50401 RDI: ffff88003ec2a1a8
> RBP: ffff88003cb77c70 R08: 0000000000021800 R09: 0000000000000000
> R10: 0000000000000000 R11: 0000000000000000 R12: ffffea0000fb0a80
> R13: ffffffff81392bcb R14: 0000000000000000 R15: ffff88003ec2a1a8
> FS:  0000000000000000(0000) GS:ffff88003ed00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 00000000205d7000 CR3: 0000000037d29000 CR4: 00000000000006e0
> Stack:
>  dffffc0000000000 ffff88003da82008 ffff88003b75bb88 0000000000000000
>  ffff88003cb77ce0 ffffffff81392bcb ffffffff81acf4f8 ffff88003b75bc04
>  ffff88003b75bbe0 ffffed00076eb772 ffff88003b75bb90 000000003cb77ce0
> Call Trace:
>  [<     inline     >] htab_elem_free kernel/bpf/hashtab.c:388
>  [<     inline     >] delete_all_elements kernel/bpf/hashtab.c:690
>  [<ffffffff81392bcb>] htab_map_free+0x30b/0x470 kernel/bpf/hashtab.c:711
>  [<ffffffff8137e9dc>] bpf_map_free_deferred+0xac/0xd0 kernel/bpf/syscall.c:97
>  [<ffffffff8114f937>] process_one_work+0x8a7/0x1300 kernel/workqueue.c:2096
>  [<ffffffff8115047d>] worker_thread+0xed/0x14e0 kernel/workqueue.c:2230
>  [<ffffffff811619dc>] kthread+0x1ec/0x260 kernel/kthread.c:209
>  [<ffffffff82fa78c5>] ret_from_fork+0x25/0x30 arch/x86/entry/entry_64.S:433
> Code: 83 c4 18 48 89 da 4c 89 ee ff d0 49 8b 04 24 48 85 c0 75 e6 e9
> e9 fe ff ff 49 8b 04 24 f6 c4 40 75 0b 49 8b 44 24 20 a8 01 75 02 <0f>
> 0b 48 89 df e8 56 35 00 00 49 8b 04 24 31 f6 f6 c4 40 74 05
> RIP  [<     inline     >] PageCompound ./include/linux/page-flags.h:157
> RIP  [<ffffffff814c9f00>] kfree+0x140/0x1a0 mm/slub.c:3866
>  RSP <ffff88003cb77c50>
> ---[ end trace 1dc58d6aeb2596aa ]---
> ==================================================================
> BUG: KASAN: stack-out-of-bounds in complete+0x68/0x70 at addr ffff88003cb77ed8
> Read of size 4 by task kworker/1:2/1542
> page:ffffea0000f2ddc0 count:0 mapcount:0 mapping:          (null) index:0x0
> flags: 0x100000000000000()
> page dumped because: kasan: bad access detected
> CPU: 1 PID: 1542 Comm: kworker/1:2 Tainted: G      D         4.9.0-rc3+ #20
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  ffff88003cb77ce0 ffffffff81acf609 ffffed000796efdb ffffed000796efdb
>  0000000000000004 0000000000000000 ffff88003cb77d60 ffffffff814cdbfb
>  ffff88003c8d97c8 dffffc0000000000 ffffffff811dd038 0000000000000097
> Call Trace:
>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>  [<ffffffff81acf609>] dump_stack+0x83/0xba lib/dump_stack.c:51
>  [<     inline     >] kasan_report_error mm/kasan/report.c:204
>  [<ffffffff814cdbfb>] kasan_report+0x4cb/0x500 mm/kasan/report.c:303
>  [<ffffffff814cdc84>] __asan_report_load4_noabort+0x14/0x20
> mm/kasan/report.c:328
>  [<ffffffff811dd038>] complete+0x68/0x70 kernel/sched/completion.c:34
>  [<     inline     >] complete_vfork_done kernel/fork.c:1030
>  [<ffffffff810fa8c2>] mm_release+0x222/0x3f0 kernel/fork.c:1114
>  [<     inline     >] exit_mm kernel/exit.c:467
>  [<ffffffff8110b501>] do_exit+0x3a1/0x2960 kernel/exit.c:815
>  [<ffffffff82fa8b97>] rewind_stack_do_exit+0x17/0x20
> arch/x86/entry/entry_64.S:1526
> Memory state around the buggy address:
>  ffff88003cb77d80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
>  ffff88003cb77e00: 00 00 00 00 00 00 00 00 f1 f1 f1 f1 00 f4 f4 f4
>>ffff88003cb77e80: f2 f2 f2 f2 00 f4 f4 f4 f2 f2 f2 f2 00 00 f4 f4
>                                                     ^
>  ffff88003cb77f00: f3 f3 f3 f3 00 00 00 00 00 00 00 00 00 00 00 00
>  ffff88003cb77f80: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
> ==================================================================
> BUG: unable to handle kernel
> paging request at ffffffffffffffd8
> IP: [<ffffffff81163c5d>] kthread_data+0x4d/0x70 kernel/kthread.c:137
> PGD 360d067 [   48.581115] PUD 360f067
> PMD 0 [   48.581840]
> Oops: 0000 [#2] SMP KASAN
> Modules linked in:
> CPU: 1 PID: 1542 Comm: kworker/1:2 Tainted: G    B D         4.9.0-rc3+ #20
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> task: ffff88003b9c0040 task.stack: ffff88003cb70000
> RIP: 0010:[<ffffffff81163c5d>]  [<ffffffff81163c5d>] kthread_data+0x4d/0x70
> RSP: 0018:ffff88003cb77c78  EFLAGS: 00010046
> RAX: dffffc0000000000 RBX: 0000000000000000 RCX: 0000000000000000
> RDX: 1ffffffffffffffb RSI: ffff88003b9c00c0 RDI: ffffffffffffffd8
> RBP: ffff88003cb77c80 R08: ffff88003ed20a48 R09: ffff88003ed20a40
> R10: 0000000000000000 R11: 0000000000000000 R12: ffff88003ed20980
> R13: ffff88003b9c0040 R14: ffff88003b9c0094 R15: 0000000000000040
> FS:  0000000000000000(0000) GS:ffff88003ed00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: 0000000000000028 CR3: 000000000360c000 CR4: 00000000000006e0
> Stack:
>  ffff88003b9c0040 ffff88003cb77ca0 ffffffff81155e77 0000000000020980
>  ffff88003ed20980 ffff88003cb77db8 ffffffff82f9b1a2 0000000000000000
>  ffff88003ddd2670 00ff88003ddd2640 ffff88003ed211f8 1ffff1000796ef9e
> Call Trace:
>  [<ffffffff81155e77>] wq_worker_sleeping+0x17/0x210 kernel/workqueue.c:876
>  [<ffffffff82f9b1a2>] __schedule+0xc62/0x1730 kernel/sched/core.c:3380
>  [<ffffffff8118c781>] do_task_dead+0x81/0xa0 kernel/sched/core.c:3431
>  [<ffffffff8110c7f8>] do_exit+0x1698/0x2960 kernel/exit.c:885
>  [<ffffffff82fa8b97>] rewind_stack_do_exit+0x17/0x20
> arch/x86/entry/entry_64.S:1526
> Code: c1 ea 03 80 3c 02 00 75 29 48 8b 9b 30 05 00 00 48 b8 00 00 00
> 00 00 fc ff df 48 8d 7b d8 48 89 fa 48 c1 ea 03 80 3c 02 00 75 0e <48>
> 8b 43 d8 5b 5d c3 e8 27 a0 36 00 eb d0 e8 20 a0 36 00 eb eb
> RIP  [<ffffffff81163c5d>] kthread_data+0x4d/0x70 kernel/kthread.c:137
>  RSP <ffff88003cb77c78>
> CR2: ffffffffffffffd8
> ---[ end trace 1dc58d6aeb2596ab ]---
> Fixing recursive fault but reboot is needed!
>
>
> // autogenerated by syzkaller (http://github.com/google/syzkaller)
>
> #ifndef __NR_bpf
> #define __NR_bpf 321
> #endif
>
> #include <fcntl.h>
> #include <pthread.h>
> #include <signal.h>
> #include <stddef.h>
> #include <stdint.h>
> #include <stdio.h>
> #include <stdlib.h>
> #include <string.h>
> #include <sys/ioctl.h>
> #include <sys/stat.h>
> #include <sys/syscall.h>
> #include <sys/types.h>
> #include <unistd.h>
>
> long r[14];
> void* thr(void* arg)
> {
>   switch ((long)arg) {
>   case 0:
>     r[0] =
>         syscall(__NR_mmap, 0x20000000ul, 0x16000ul, 0x3ul,
>                         0x32ul, 0xfffffffffffffffful, 0x0ul, 0, 0, 0);
>     break;
>   case 1:
>     (*(uint32_t*)0x20011000 = (uint32_t)0x1);
>     (*(uint32_t*)0x20011004 = (uint32_t)0x8);
>     (*(uint32_t*)0x20011008 = (uint32_t)0x3);
>     (*(uint32_t*)0x2001100c = (uint32_t)0x1);
>     (*(uint32_t*)0x20011010 = (uint32_t)0x1);
>     r[6] = syscall(__NR_bpf, 0x0ul, 0x20011000ul, 0x14ul, 0, 0,
>                            0, 0, 0, 0);
>     break;
>   case 2:
>     (*(uint32_t*)0x20013000 = r[6]);
>     (*(uint64_t*)0x20013008 = (uint64_t)0x20013fb3);
>     (*(uint64_t*)0x20013010 = (uint64_t)0x20012ff1);
>     (*(uint64_t*)0x20013018 = (uint64_t)0x0);
>     (memcpy(
>         (void*)0x20013fb3,
>         "\x3e\x51\x32\xbe\xd5\x24\x20\xb2\x50\x7a\x4d\xb5\xec\xb3\x8f"
>         "\x65\x7f\xac\x61\x9a\xf0\x29\x3f\x77\x07\x2f\x2f\x60\xe9\x78"
>         "\xc5\x79\x45\x16\x67\xf6\x64\xb4\xd5\xb2\x11\x88\x5f\x4f\x32"
>         "\xba\xa8\x80\x8f\x7a\xea\x01\x1d\xe4\x08\xa4\x65\x73\x07\x91"
>         "\x48\xd5\xc3\xf2\xc4\x08\x29\x8f\x88\x95\xc3\xd5\xf6\x86\x0f"
>         "\x42\xab\x05\xf7\xfa\x2b\x12\x78\xb3\x4d\x17\x8c\x27\x57\x8b"
>         "\x79\xdc\x4f\x8a\x7a\xf5\x8c\x8a\xc2\x18\x03\xa0\xf9\x5f\x7a",
>         105));
>     (memcpy(
>         (void*)0x20012ff1,
>         "\xb1\xb0\x4b\x14\x9e\xfa\xbc\xb2\xaf\x4b\x4a\x02\xbc\x9b\xc5",
>         15));
>     r[13] = syscall(__NR_bpf, 0x2ul, 0x20013000ul, 0x20ul, 0, 0,
>                             0, 0, 0, 0);
>     break;
>   }
>   return 0;
> }
>
> int main()
> {
>   long i;
>   pthread_t th[6];
>
>   memset(r, -1, sizeof(r));
>   srand(getpid());
>   for (i = 0; i < 3; i++) {
>     pthread_create(&th[i], 0, thr, (void*)i);
>     usleep(10000);
>   }
>   for (i = 0; i < 3; i++) {
>     pthread_create(&th[3 + i], 0, thr, (void*)i);
>     if (rand() % 2)
>       usleep(rand() % 10000);
>   }
>   usleep(100000);
>   return 0;
> }


Sometimes it crashes with "unable to handle kernel paging request" :

BUG: unable to handle kernel paging request at ffffeb83fffec020
IP: [<     inline     >] virt_to_head_page include/linux/mm.h:555
IP: [<ffffffff814c9e15>] kfree+0x55/0x1a0 mm/slub.c:3864
PGD 0 [ 1103.309066]
Oops: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 3 PID: 5460 Comm: kworker/3:3 Not tainted 4.9.0-rc3+ #20
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
Workqueue: events bpf_map_free_deferred
task: ffff8800676b6e40 task.stack: ffff880067680000
RIP: 0010:[<ffffffff814c9e15>]  [<     inline     >] virt_to_head_page
include/linux/mm.h:555
RIP: 0010:[<ffffffff814c9e15>]  [<ffffffff814c9e15>] kfree+0x55/0x1a0
mm/slub.c:3864
RSP: 0018:ffff880067687c50  EFLAGS: 00010286
RAX: ffffea0000000000 RBX: ffffe8ffffb00748 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 1ffff1000db56cb5 RDI: ffffe8ffffb00748
RBP: ffff880067687c70 R08: 0000000000003400 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000000 R12: ffffeb83fffec000
R13: ffffffff81392bcb R14: 0000000000000000 R15: ffffe8ffffb00748
FS:  0000000000000000(0000) GS:ffff88006e500000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: ffffeb83fffec020 CR3: 000000003d24f000 CR4: 00000000000006e0
DR0: 0000000000000007 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
Stack:
 dffffc0000000000 ffff88006dab65a8 ffff88006d0490c8 0000000000000000
 ffff880067687ce0 ffffffff81392bcb ffffffff81acf4f8 ffff88006d049144
 ffff88006d049120 ffffed000da0921a ffff88006d0490d0 0000000067687ce0
Call Trace:
 [<     inline     >] htab_elem_free kernel/bpf/hashtab.c:388
 [<     inline     >] delete_all_elements kernel/bpf/hashtab.c:690
 [<ffffffff81392bcb>] htab_map_free+0x30b/0x470 kernel/bpf/hashtab.c:711
 [<ffffffff8137e9dc>] bpf_map_free_deferred+0xac/0xd0 kernel/bpf/syscall.c:97
 [<ffffffff8114f937>] process_one_work+0x8a7/0x1300 kernel/workqueue.c:2096
 [<ffffffff8115047d>] worker_thread+0xed/0x14e0 kernel/workqueue.c:2230
 [<ffffffff811619dc>] kthread+0x1ec/0x260 kernel/kthread.c:209
 [<ffffffff82fa78c5>] ret_from_fork+0x25/0x30 arch/x86/entry/entry_64.S:433
Code: 48 01 d8 0f 82 53 01 00 00 49 bc 00 00 00 80 ff 77 00 00 49 01
c4 48 b8 00 00 00 00 00 ea ff ff 49 c1 ec 0c 49 c1 e4 06 49 01 c4 <49>
8b 44 24 20 48 8d 50 ff a8 01 4c 0f 45 e2 49 8b 54 24 20 48
RIP  [<     inline     >] virt_to_head_page include/linux/mm.h:555
RIP  [<ffffffff814c9e15>] kfree+0x55/0x1a0 mm/slub.c:3864
 RSP <ffff880067687c50>
CR2: ffffeb83fffec020
---[ end trace 9271605118c02ee3 ]---
Kernel panic - not syncing: Fatal exception
Dumping ftrace buffer:
   (ftrace buffer empty)
Kernel Offset: disabled
reboot: cpu_has_vmx: ecx=80a02021 1
