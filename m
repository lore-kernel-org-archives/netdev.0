From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/bluetooth: workqueue destruction WARNING in hci_unregister_dev
Date: Thu, 18 Feb 2016 15:22:36 +0100
Message-ID: <CACT4Y+bVXfY=wBZ+08rq16tHFw9s3YDrE_LCS=to-GF70AffRQ@mail.gmail.com>
References: <CACT4Y+ax7zMOxe+kd4tw5Xdbvt=qPdBhXGO0j7qJwdn5tsfNNg@mail.gmail.com>
 <56C5CE85.6090808@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>, Tejun Heo <tj@kernel.org>,
	Takashi Iwai <tiwai@suse.com>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56C5CE85.6090808@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 18, 2016 at 3:00 PM, Jiri Slaby <jslaby@suse.cz> wrote:
> Cc Tejun (workqueues), Takashi (debug patch)
>
> On 01/26/2016, 12:53 PM, Dmitry Vyukov wrote:
>> Hello,
>>
>> I've hit the following warning while running syzkaller fuzzer:
>
> Hi,
>
> I am hitting it over and over again using syzkaller.
>
>> WARNING: CPU: 2 PID: 17409 at kernel/workqueue.c:3968
>> destroy_workqueue+0x172/0x550()
>
> Which of the warnings is it in your case?


The line number points to WARN_ON(pwq->nr_active), but there can well
be a off-by-one error, so I am not sure.
If you are hitting it all the time, so probably it is the same. Or at
least if makes sense to fix yours first since it is more easily
reproducible.


> I hit "(pwq != wq->dfl_pwq) && (pwq->refcnt > 1)". So I have this in the
> code:
> if (WARN_ON((pwq != wq->dfl_pwq) && (pwq->refcnt > 1))) {
>         pr_info("%s: pwq=%p wq->dfl_pwq=%p pwq->refcnt=%d\n",
>                         __func__, pwq, wq->dfl_pwq,
>                         pwq->refcnt);
>         mutex_unlock(&wq->mutex);
>         return;
> }
>
> if (WARN_ON(pwq->nr_active)) {
> ...
>
> And the values are:
> pwq=ffff88006e271500 wq->dfl_pwq=ffff88006e272400 pwq->refcnt=2
> pwq=ffff88002ec48300 wq->dfl_pwq=ffff88002ec4bc00 pwq->refcnt=2
> pwq=ffff880020f76400 wq->dfl_pwq=ffff880020f75500 pwq->refcnt=2
> pwq=ffff88002a908f00 wq->dfl_pwq=ffff88002a90bc00 pwq->refcnt=1
> pwq=ffff8800348e0300 wq->dfl_pwq=ffff8800348e0000 pwq->refcnt=2
> pwq=ffff88006e276400 wq->dfl_pwq=ffff88006e275800 pwq->refcnt=2
>
>
> Note the single "pwq->refcnt=1" in there. So this is perhaps a race?
>
> Takashi also provided me with a debug patch included in the attached
> patch. It did not trigger though.
>
>> CPU: 2 PID: 17409 Comm: syz-executor Not tainted 4.5.0-rc1+ #283
>> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>>  00000000ffffffff ffff88003665f8a0 ffffffff8299a06d 0000000000000000
>>  ffff88003599c740 ffffffff8643f0c0 ffff88003665f8e0 ffffffff8134fcf9
>>  ffffffff8139d4c2 ffffffff8643f0c0 0000000000000f80 ffff8800630c5ae8
>> Call Trace:
>>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>>  [<ffffffff8299a06d>] dump_stack+0x6f/0xa2 lib/dump_stack.c:50
>>  [<ffffffff8134fcf9>] warn_slowpath_common+0xd9/0x140 kernel/panic.c:482
>>  [<ffffffff8134ff29>] warn_slowpath_null+0x29/0x30 kernel/panic.c:515
>>  [<ffffffff8139d4c2>] destroy_workqueue+0x172/0x550 kernel/workqueue.c:3968
>>  [<ffffffff85a714a4>] hci_unregister_dev+0x264/0x700
>> net/bluetooth/hci_core.c:3162
>>  [<ffffffff84595ce6>] vhci_release+0x76/0xe0 drivers/bluetooth/hci_vhci.c:341
>>  [<ffffffff817b2376>] __fput+0x236/0x780 fs/file_table.c:208
>>  [<ffffffff817b2945>] ____fput+0x15/0x20 fs/file_table.c:244
>>  [<ffffffff813ad760>] task_work_run+0x170/0x210 kernel/task_work.c:115
>>  [<     inline     >] exit_task_work include/linux/task_work.h:21
>>  [<ffffffff81358da5>] do_exit+0x8b5/0x2c60 kernel/exit.c:748
>>  [<ffffffff8135b2c8>] do_group_exit+0x108/0x330 kernel/exit.c:878
>>  [<ffffffff8137e434>] get_signal+0x5e4/0x14f0 kernel/signal.c:2307
>>  [<ffffffff811a1db3>] do_signal+0x83/0x1c90 arch/x86/kernel/signal.c:712
>>  [<ffffffff81006685>] exit_to_usermode_loop+0x1a5/0x210
>> arch/x86/entry/common.c:247
>>  [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:282
>>  [<ffffffff810084ea>] syscall_return_slowpath+0x2ba/0x340
>> arch/x86/entry/common.c:344
>>  [<ffffffff863597a2>] int_ret_from_sys_call+0x25/0x9f
>> arch/x86/entry/entry_64.S:281
>> ---[ end trace f627386faee7426f ]---
>>
>> Unfortunately I cannot reproduce it in a controlled environment, but
>> I've hit it twice in different VMs. So maybe if you see something
>> obvious there. Is it possible that something is submitted into the
>> workqueue between it is drained and destroyed in hci_unregister_dev?
>>
>> On commit 92e963f50fc74041b5e9e744c330dca48e04f08d (Jan 24).
>>
>
> thanks,
> --
> js
> suse labs
