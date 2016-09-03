From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/bluetooth: workqueue destruction WARNING in hci_unregister_dev
Date: Sat, 3 Sep 2016 12:58:33 +0200
Message-ID: <CACT4Y+Zs6vkjHo9qHb4TrEiz3S4+quvvVQ9VWvj2Mx6pETGb9Q@mail.gmail.com>
References: <CACT4Y+ax7zMOxe+kd4tw5Xdbvt=qPdBhXGO0j7qJwdn5tsfNNg@mail.gmail.com>
 <56C5CE85.6090808@suse.cz> <CACT4Y+bVXfY=wBZ+08rq16tHFw9s3YDrE_LCS=to-GF70AffRQ@mail.gmail.com>
 <20160218174427.GG13177@mtj.duckdns.org> <56C6EC62.8080107@suse.cz>
 <56C70618.3010902@suse.cz> <20160302154507.GC4282@mtj.duckdns.org>
 <56D7FFE1.90900@suse.cz> <20160311171205.GB24046@htj.duckdns.org>
 <56EA9C4D.2080803@suse.cz> <20160318205231.GO20028@mtj.duckdns.org>
 <56F01A1C.40208@suse.cz> <56F0FDCE.1040701@suse.cz> <CACT4Y+b+9Ubsbfs58nHAraG+7iXRBkrn=XyCTPDJLike7w-mjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tejun Heo <tj@kernel.org>, Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-bluetooth <linux-bluetooth@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Sasha Levin <sasha.levin@oracle.com>,
        Eric Dumazet <edumazet@google.com>,
        Takashi Iwai <tiwai@suse.com>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:34145 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753169AbcICLAU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Sep 2016 07:00:20 -0400
Received: by mail-lf0-f45.google.com with SMTP id p41so80765500lfi.1
        for <netdev@vger.kernel.org>; Sat, 03 Sep 2016 03:58:55 -0700 (PDT)
In-Reply-To: <CACT4Y+b+9Ubsbfs58nHAraG+7iXRBkrn=XyCTPDJLike7w-mjQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 22, 2016 at 1:32 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Tue, Mar 22, 2016 at 9:09 AM, Jiri Slaby <jslaby@suse.cz> wrote:
>> On 03/21/2016, 04:58 PM, Jiri Slaby wrote:
>>> Hello,
>>>
>>> On 03/18/2016, 09:52 PM, Tejun Heo wrote:
>>>> On Thu, Mar 17, 2016 at 01:00:13PM +0100, Jiri Slaby wrote:
>>>>>>> I have not done that yet, but today, I see:
>>>>>>> destroy_workqueue: name='req_hci0' pwq=ffff88002f590300
>>>>>>> wq->dfl_pwq=ffff88002f591e00 pwq->refcnt=2 pwq->nr_active=0 delayed_works:
>>>>>>>    pwq 12: cpus=0-1 node=0 flags=0x4 nice=-20 active=0/1
>>>>>>>      in-flight: 18568:wq_barrier_func
>>>>>>
>>>>>> So, this means that there's flush_work() racing against workqueue
>>>>>> destruction, which can't be safe. :(
>>>>>
>>>>> But I cannot trigger the WARN_ONs in the attached patch, so I am
>>>>> confused how this can happen :(. (While I am still seeing the destroy
>>>>> WARNINGs.)
>>>>
>>>> So, no operations should be in progress when destroy_workqueue() is
>>>> called.  If somebody was flushing a work item, the flush call must
>>>> have returned before destroy_workqueue() was invoked, which doesn't
>>>> seem to be the case here.  Can you trigger BUG_ON() or sysrq-t when
>>>> the above triggers?  There must be a task which is flushing a work
>>>> item there and it shouldn't be difficult to pinpoint what's going on
>>>> from it.
>>>
>>> The output of sysrq-t is here (> 200k), but I cannot see anything
>>> suspicious in it:
>>> http://www.fi.muni.cz/~xslaby/sklad/panics/jctl.txt
>>
>> Hmm, so I seem I cannot reproduce with this hunk:
>> --- a/net/bluetooth/hci_core.c
>> +++ b/net/bluetooth/hci_core.c
>> @@ -3139,10 +3139,10 @@ void hci_unregister_dev(struct hci_dev *hdev)
>>         list_del(&hdev->list);
>>         write_unlock(&hci_dev_list_lock);
>>
>> -       hci_dev_do_close(hdev);
>> -
>>         cancel_work_sync(&hdev->power_on);
>>
>> +       hci_dev_do_close(hdev);
>> +
>>         if (!test_bit(HCI_INIT, &hdev->flags) &&
>>             !hci_dev_test_flag(hdev, HCI_SETUP) &&
>>             !hci_dev_test_flag(hdev, HCI_CONFIG)) {
>>
>>
>>
>> I cannot explain why though. I do not see how it matters in this
>> particular case...
>>
>> Dmitry, could you apply it too? But I don't know how often you see the
>> warning.
>
> I've seen it only several times in several months, so I don't it will
> be helpful.


Bad news: I hit it again.
On 0f98f121e1670eaa2a2fbb675e07d6ba7f0e146f of linux-next, so I have
bf389cabb3b8079c23f9762e62b05f291e2d5e99.

WARNING: CPU: 3 PID: 23168 at kernel/workqueue.c:4029
destroy_workqueue+0x172/0x620
CPU: 3 PID: 23168 Comm: syz-executor Not tainted 4.8.0-rc3-next-20160825+ #8
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
 ffffffff886b6fe0 ffff880037be77a8 ffffffff82db38d9 ffffffff00000016
 fffffbfff10d6dfc ffffffff8708f000 ffff880037be7880 ffffffff8709be00
 dffffc0000000000 0000000000000009 ffff880037be7870 ffffffff816cf888
Call Trace:
 [<     inline     >] __dump_stack lib/dump_stack.c:15
 [<ffffffff82db38d9>] dump_stack+0x12e/0x185 lib/dump_stack.c:51
 [<ffffffff816cf888>] panic+0x1e4/0x3fb kernel/panic.c:179
 [<ffffffff813863b4>] __warn+0x1c4/0x1e0 kernel/panic.c:542
 [<ffffffff8138659c>] warn_slowpath_null+0x2c/0x40 kernel/panic.c:585
 [<ffffffff813dc6d2>] destroy_workqueue+0x172/0x620 kernel/workqueue.c:4029
 [<ffffffff8645973f>] hci_unregister_dev+0x3df/0x8a0
net/bluetooth/hci_core.c:3170
 [<ffffffff84cb6926>] vhci_release+0x76/0xf0 drivers/bluetooth/hci_vhci.c:354
 [<ffffffff81868bbc>] __fput+0x28c/0x780 fs/file_table.c:208
 [<ffffffff81869135>] ____fput+0x15/0x20 fs/file_table.c:244
 [<ffffffff813ebf63>] task_work_run+0xf3/0x170
 [<     inline     >] exit_task_work include/linux/task_work.h:21
 [<ffffffff81394218>] do_exit+0x868/0x2e70 kernel/exit.c:828
 [<ffffffff81396998>] do_group_exit+0x108/0x330 kernel/exit.c:958
 [<ffffffff813ba4aa>] get_signal+0x62a/0x15d0 kernel/signal.c:2307
 [<ffffffff81202333>] do_signal+0x83/0x1f60 arch/x86/kernel/signal.c:805
 [<ffffffff81006345>] exit_to_usermode_loop+0x1a5/0x210
arch/x86/entry/common.c:163
 [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:198
 [<ffffffff8100869f>] syscall_return_slowpath+0x2bf/0x340
arch/x86/entry/common.c:267
 [<ffffffff86e1079c>] entry_SYSCALL_64_fastpath+0xbf/0xc1
