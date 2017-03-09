From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [net/bpf] 3051bf36c2 BUG: unable to handle kernel paging request
 at 0000a7cf
Date: Thu, 9 Mar 2017 09:34:51 +0800
Message-ID: <20170309013451.cekwp6r2p5oaixy6@wfg-t540p.sh.intel.com>
References: <20170301125426.l4nf65rx4wahohyl@wfg-t540p.sh.intel.com>
 <20170302202338.ci6wwb3yzjmdy4n2@wfg-t540p.sh.intel.com>
 <58B88353.2010508@iogearbox.net>
 <CA+55aFy97mLPLb4WXmRn-xLMNt+bNkrb_vaBsh+HOMLLnKPv7Q@mail.gmail.com>
 <58C08535.3070000@iogearbox.net>
 <CA+55aFwaNhP918b0zgpP8G6qGXHP+Qw69hEV+271tPMXu1+p8A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        Thomas Gleixner <tglx@linutronix.de>,
        Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>,
        Network Development <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        ast@fb.com, the arch/x86 maintainers <x86@kernel.org>,
        Kees Cook <keescook@chromium.org>,
        Laura Abbott <labbott@redhat.com>,
        David Miller <davem@davemloft.net>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFwaNhP918b0zgpP8G6qGXHP+Qw69hEV+271tPMXu1+p8A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 08, 2017 at 02:43:44PM -0800, Linus Torvalds wrote:
>On Wed, Mar 8, 2017 at 2:27 PM, Daniel Borkmann <daniel@iogearbox.net> wrote:
>>
>> The issue seems to be accessing buff first (can be read or write access)
>> and then doing set_memory_ro() doesn't make it read-only immediately,
>> meaning the subsequent call into probe_kernel_write() will succeed without
>> error.
>>
>> Then, if I don't touch buff first and only do the set_memory_ro() seems
>> to work and probe_kernel_write() will then fail as expected due to pages
>> being read-only now.
>
>Ok, that definitely sounds like a TLB invalidate didn't happen.
>
>> Now, if I access buff, do the set_memory_ro() and then a msleep(0), for
>> example, it "kind of" works most of the time (see last log extract below),
>> and probe_kernel_write() will fail.
>
>Yeah, very much consistent with a missing TLB invalidate. Scheduling
>will end up invalidating it, although if it's a global page even that
>might not do it (but eventually the entry will just get flushed due to
>other activity).
>
>> None of this seems an issue with x86_64 and the test_setmem runs fine all
>> the time, same for the actual BPF stuff.
>
>The code does look somewhat confused about when to actually flush
>things - see my earlier note about NX - but it would seem to always do
>__flush_tlb_all() unless I missed something. At least as long as
>CPA_FLUSHTLB is set. Maybe some case forgets to set that..

Not sure if it's relevant, but out of 189 boots there are 2 boots
showing the below "CPA: called for zero pte." warning.

[    7.116932] random: trinity: uninitialized urandom read (4 bytes read)
[   16.366468] sock: process `trinity-main' is using obsolete setsockopt SO_BSDCOMPAT
[   17.202396] BUG: unable to handle kernel paging request at 655d9eb2
[   17.204081] IP: __release_sock+0x6e/0x100
[   17.205207] *pde = 00000000
[   17.205208]
[   17.206755] Oops: 0000 [#1]
[   17.207686] CPU: 0 PID: 382 Comm: trinity-main Not tainted 4.10.0-rc8-02017-g9d876e7 #1
[   17.209819] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-20161025_171302-gandalf 04/01/2014
[   17.212431] task: d625d200 task.stack: d6222000
[   17.213655] EIP: __release_sock+0x6e/0x100
[   17.214833] EFLAGS: 00010246 CPU: 0
[   17.215951] EAX: 00000000 EBX: 655d9eb2 ECX: 00000000 EDX: 00000201
[   17.217587] ESI: 00000605 EDI: d6064800 EBP: d6223ef4 ESP: d6223ee8
[   17.219185]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[   17.220602] CR0: 80050033 CR2: 655d9eb2 CR3: 1610f000 CR4: 00000610
[   17.221966] DR0: 080cb000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[   17.223444] DR6: ffff0ff0 DR7: 00000600
[   17.224343] Call Trace:
[   17.225007]  release_sock+0x2e/0x80
[   17.225900]  sock_setsockopt+0x8c/0x880
[   17.226857]  SyS_socketcall+0x658/0x6a0
[   17.227804]  do_fast_syscall_32+0x9a/0x160
[   17.228765]  entry_SYSENTER_32+0x4c/0x7b
[   17.229694] EIP: 0xb7777cc5
[   17.230428] EFLAGS: 00000282 CPU: 0
[   17.231263] EAX: ffffffda EBX: 0000000e ECX: bfedce00 EDX: bfedce80
[   17.232582] ESI: 0000001a EDI: 000000ae EBP: b754f93c ESP: bfedcdec
[   17.233882]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 007b
[   17.235044] Code: eb 29 8d 76 00 89 da 89 f8 ff 97 98 01 00 00 31 c9 ba 06 08 00 00 b8 d8 19 b1 c1 e8 ed 3d 85 ff e8 e8 62 04 00 85 f6 89 f3 74 42 <8b>
 33 0f 18 06 8b 43 48 a8 01 74 0e 83 e0 fe 74 09 80 3d 3d 9c
[   17.240429] EIP: __release_sock+0x6e/0x100 SS:ESP: 0068:d6223ee8
[   17.241689] CR2: 00000000655d9eb2
[   17.242509] ---[ end trace dc10480164c75444 ]---
[   17.243569] ------------[ cut here ]------------
[   17.243574] WARNING: CPU: 0 PID: 15 at arch/x86/mm/pageattr.c:1150 __cpa_process_fault+0x388/0x390
[   17.243575] CPA: called for zero pte. vaddr = d7ab4000 cpa->vaddr = d7ab4000
[   17.243577] CPU: 0 PID: 15 Comm: kworker/0:1 Tainted: G      D         4.10.0-rc8-02017-g9d876e7 #1
[   17.243578] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-20161025_171302-gandalf 04/01/2014
[   17.243582] Workqueue: events bpf_prog_free_deferred
[   17.243583] Call Trace:
[   17.243588]  dump_stack+0x16/0x25
[   17.243588]  dump_stack+0x16/0x25
[   17.243590]  __warn+0xd1/0xf0
[   17.243592]  ? __cpa_process_fault+0x388/0x390
[   17.243593]  warn_slowpath_fmt+0x3b/0x40
[   17.243594]  __cpa_process_fault+0x388/0x390
[   17.243596]  ? lookup_address_in_pgd+0xa/0x90
[   17.243598]  __change_page_attr+0x520/0x6c0
[   17.243600]  ? pfn_range_is_mapped+0xe/0x80
[   17.243601]  __change_page_attr_set_clr+0x38/0x180
[   17.243603]  change_page_attr_set_clr+0x107/0x3f0
[   17.243605]  ? dequeue_entity+0x86/0x230
[   17.243607]  set_memory_rw+0x3a/0x40
[   17.243608]  bpf_prog_free_deferred+0x16/0x30
[   17.243612]  process_one_work+0xfc/0x440
[   17.243614]  ? pick_next_task_fair+0x149/0x1d0
[   17.243615]  worker_thread+0x37/0x4e0
[   17.243617]  kthread+0xdd/0x110
[   17.243618]  ? process_one_work+0x440/0x440
[   17.243620]  ? __kthread_create_on_node+0x100/0x100
[   17.243622]  ret_from_fork+0x21/0x2c
[   17.243623] ---[ end trace dc10480164c75445 ]---
[   17.243627] BUG: unable to handle kernel NULL pointer dereference at 00000007
[   17.243630] IP: ___cache_free+0x14/0x140
[   17.243631] *pde = 00000000
[   17.243631]
[   17.243633] Oops: 0000 [#2]
[   17.243635] CPU: 0 PID: 15 Comm: kworker/0:1 Tainted: G      D W       4.10.0-rc8-02017-g9d876e7 #1
[   17.243635] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.9.3-20161025_171302-gandalf 04/01/2014
[   17.243636] Workqueue: events bpf_prog_free_deferred
[   17.243637] task: d524e8c0 task.stack: d5254000
[   17.243639] EIP: ___cache_free+0x14/0x140
[   17.243640] EFLAGS: 00010046 CPU: 0
[   17.243641] EAX: d6945af8 EBX: 00000003 ECX: c10dc08e EDX: 3beb072d
[   17.243642] ESI: d6945af8 EDI: 3beb072d EBP: d5255f00 ESP: d5255ed4
[   17.243643]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
[   17.243644] CR0: 80050033 CR2: 00000007 CR3: 1610f000 CR4: 00000610
[   17.243647] DR0: 080cb000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[   17.243648] DR6: ffff0ff0 DR7: 00000600
[   17.243648] Call Trace:
[   17.243650]  kfree+0x64/0xe0
[   17.243652]  ? bpf_prog_free_deferred+0x1e/0x30
[   17.243653]  bpf_prog_free_deferred+0x1e/0x30
[   17.243654]  process_one_work+0xfc/0x440
[   17.243656]  ? pick_next_task_fair+0x149/0x1d0
[   17.243658]  worker_thread+0x37/0x4e0
[   17.243659]  kthread+0xdd/0x110
[   17.243661]  ? process_one_work+0x440/0x440
[   17.243662]  ? __kthread_create_on_node+0x100/0x100
[   17.243664]  ret_from_fork+0x21/0x2c
[   17.243664] Code: 89 da 89 f0 ff 0d 64 3e b4 c1 e8 f8 fe ff ff 83 c4 14 5b 5e 5d c3 90 55 89 e5 57 56 53 83 ec 20 e8 d2 21 72 00 8b 18 89 c6 89 d7 <8b> 43 04 39 03 73 65 a1 a0 fa 4b c2 85 c0 7f 1c 8b 03 8d 50 01
[   17.243684] EIP: ___cache_free+0x14/0x140 SS:ESP: 0068:d5255ed4
[   17.243684] CR2: 0000000000000007
[   17.243685] ---[ end trace dc10480164c75446 ]---
[   17.243686] Kernel panic - not syncing: Fatal exception
[   17.243687] Kernel Offset: disabled

Regards,
Fengguang
