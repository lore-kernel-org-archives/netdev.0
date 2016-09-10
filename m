From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: net/bluetooth: workqueue destruction WARNING in hci_unregister_dev
Date: Sat, 10 Sep 2016 11:33:48 +0200
Message-ID: <CACT4Y+Z2dP--yr5oJYPnAmTtzJDHbR6h=6d0nSdg6KB-qseEzg@mail.gmail.com>
References: <56C70618.3010902@suse.cz> <20160302154507.GC4282@mtj.duckdns.org>
 <56D7FFE1.90900@suse.cz> <20160311171205.GB24046@htj.duckdns.org>
 <56EA9C4D.2080803@suse.cz> <20160318205231.GO20028@mtj.duckdns.org>
 <56F01A1C.40208@suse.cz> <56F0FDCE.1040701@suse.cz> <CACT4Y+b+9Ubsbfs58nHAraG+7iXRBkrn=XyCTPDJLike7w-mjQ@mail.gmail.com>
 <CACT4Y+Zs6vkjHo9qHb4TrEiz3S4+quvvVQ9VWvj2Mx6pETGb9Q@mail.gmail.com>
 <20160905130832.GD20784@mtj.duckdns.org> <CACT4Y+axnBPkUpMyUC74TFwq-_3Aia-fQRoSSBwbZuiguhjEaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jiri Slaby <jslaby@suse.cz>, Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-bluetooth <linux-bluetooth@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>,
        Kostya Serebryany <kcc@google.com>,
        Alexander Potapenko <glider@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Takashi Iwai <tiwai@suse.com>
To: Tejun Heo <tj@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+axnBPkUpMyUC74TFwq-_3Aia-fQRoSSBwbZuiguhjEaA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 5, 2016 at 3:14 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Mon, Sep 5, 2016 at 3:08 PM, Tejun Heo <tj@kernel.org> wrote:
>> Hello,
>>
>> On Sat, Sep 03, 2016 at 12:58:33PM +0200, Dmitry Vyukov wrote:
>>> > I've seen it only several times in several months, so I don't it will
>>> > be helpful.
>>>
>>>
>>> Bad news: I hit it again.
>>> On 0f98f121e1670eaa2a2fbb675e07d6ba7f0e146f of linux-next, so I have
>>> bf389cabb3b8079c23f9762e62b05f291e2d5e99.
>>
>> Hmmm... we're not getting anywhere.  I've applied the following patch
>> to wq/for-4.8-fixes so that when this happens the next time we can
>> actually tell what the hell is going wrong.
>>
>> Thanks.
>>
>> ------ 8< ------
>> From 278930ada88c972d20025b0f20def27b1a09dff7 Mon Sep 17 00:00:00 2001
>> From: Tejun Heo <tj@kernel.org>
>> Date: Mon, 5 Sep 2016 08:54:06 -0400
>> Subject: [PATCH] workqueue: dump workqueue state on sanity check failures in
>>  destroy_workqueue()
>>
>> destroy_workqueue() performs a number of sanity checks to ensure that
>> the workqueue is empty before proceeding with destruction.  However,
>> it's not always easy to tell what's going on just from the warning
>> message.  Let's dump workqueue state after sanity check failures to
>> help debugging.
>>
>> Signed-off-by: Tejun Heo <tj@kernel.org>
>> Link: http://lkml.kernel.org/r/CACT4Y+Zs6vkjHo9qHb4TrEiz3S4+quvvVQ9VWvj2Mx6pETGb9Q@mail.gmail.com
>> Cc: Dmitry Vyukov <dvyukov@google.com>
>> ---
>>  kernel/workqueue.c | 2 ++
>>  1 file changed, 2 insertions(+)
>>
>> diff --git a/kernel/workqueue.c b/kernel/workqueue.c
>> index ef071ca..4eaec8b8 100644
>> --- a/kernel/workqueue.c
>> +++ b/kernel/workqueue.c
>> @@ -4021,6 +4021,7 @@ void destroy_workqueue(struct workqueue_struct *wq)
>>                 for (i = 0; i < WORK_NR_COLORS; i++) {
>>                         if (WARN_ON(pwq->nr_in_flight[i])) {
>>                                 mutex_unlock(&wq->mutex);
>> +                               show_workqueue_state();
>>                                 return;
>>                         }
>>                 }
>> @@ -4029,6 +4030,7 @@ void destroy_workqueue(struct workqueue_struct *wq)
>>                     WARN_ON(pwq->nr_active) ||
>>                     WARN_ON(!list_empty(&pwq->delayed_works))) {
>>                         mutex_unlock(&wq->mutex);
>> +                       show_workqueue_state();
>>                         return;
>>                 }
>>         }
>
>
> Applied this to my test tree.


Hit the WARNING with the patch. It showed "Showing busy workqueues and
worker pools:" after the WARNING, but then no queue info. Was it
already destroyed and removed from the list?...



[ 186.994195] blk_update_request: critical target error, dev sr0, sector 0
[ 187.031368] sr 1:0:0:0: [sr0] tag#0 FAILED Result: hostbyte=DID_OK
driverbyte=DRIVER_SENSE
[ 187.032172] sr 1:0:0:0: [sr0] tag#0 Sense Key : Illegal Request [current]
[ 187.032816] sr 1:0:0:0: [sr0] tag#0 Add. Sense: Invalid command operation code
[ 187.033432] sr 1:0:0:0: [sr0] tag#0 CDB: Write(10) 2a 00 00 00 00 00
00 00 02 00
[ 187.034124] blk_update_request: critical target error, dev sr0, sector 0
[ 187.069408] sr 1:0:0:0: [sr0] tag#0 FAILED Result: hostbyte=DID_OK
driverbyte=DRIVER_SENSE
[ 187.070127] sr 1:0:0:0: [sr0] tag#0 Sense Key : Illegal Request [current]
[ 187.070744] sr 1:0:0:0: [sr0] tag#0 Add. Sense: Invalid command operation code
[ 187.071368] sr 1:0:0:0: [sr0] tag#0 CDB: Write(10) 2a 00 00 00 00 00
00 00 04 00
[ 187.071982] blk_update_request: critical target error, dev sr0, sector 0
[ 187.098397] sr 1:0:0:0: [sr0] tag#0 FAILED Result: hostbyte=DID_OK
driverbyte=DRIVER_SENSE
[ 187.099194] sr 1:0:0:0: [sr0] tag#0 Sense Key : Illegal Request [current]
[ 187.099863] sr 1:0:0:0: [sr0] tag#0 Add. Sense: Invalid command operation code
[ 187.100527] sr 1:0:0:0: [sr0] tag#0 CDB: Write(10) 2a 00 00 00 00 00
00 00 04 00
[ 187.101206] blk_update_request: critical target error, dev sr0, sector 0
[ 187.104486] VFS: Dirty inode writeback failed for block device sr0 (err=-5).
[ 198.113128] ------------[ cut here ]------------
[ 198.113838] WARNING: CPU: 2 PID: 26691 at kernel/workqueue.c:4042
destroy_workqueue+0x17b/0x630
[ 198.114628] Modules linked in:
[ 198.115009] CPU: 2 PID: 26691 Comm: syz-executor Not tainted
4.8.0-rc5-next-20160909+ #23
[ 198.115615] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS Bochs 01/01/2011
[ 198.116032] ffff880060f4f880 ffffffff82d88e39 ffffffff87098a20
fffffbfff10d6ad0
[ 198.116032] 0000000000000000 0000000000000000 ffffffff87098a20
ffffffff813b5abb
[ 198.116032] 0000000000000009 ffff880060f4f8c8 ffffffff81354c3f
ffff880060f4f8e8
[ 198.116032] Call Trace:
[ 198.116032] [<ffffffff82d88e39>] dump_stack+0x12e/0x185
[ 198.116032] [<ffffffff813b5abb>] ? destroy_workqueue+0x17b/0x630
[ 198.116032] [<ffffffff81354c3f>] __warn+0x19f/0x1e0
[ 198.116032] [<ffffffff81354e4c>] warn_slowpath_null+0x2c/0x40
[ 198.116032] [<ffffffff813b5abb>] destroy_workqueue+0x17b/0x630
[ 198.116032] [<ffffffff8642b43f>] hci_unregister_dev+0x3df/0x8a0
[ 198.116032] [<ffffffff8195bc70>] ? fcntl_setlk+0xc30/0xc30
[ 198.116032] [<ffffffff84c86b70>] ? vhci_flush+0x50/0x50
[ 198.116032] [<ffffffff84c86be6>] vhci_release+0x76/0xf0
[ 198.116032] [<ffffffff8183c71c>] __fput+0x28c/0x780
[ 198.116032] [<ffffffff8183cc95>] ____fput+0x15/0x20
[ 198.116032] [<ffffffff813bc6d3>] task_work_run+0xf3/0x170
[ 198.116032] [<ffffffff81364c58>] do_exit+0x868/0x2de0
[ 198.116032] [<ffffffff81934de0>] ? userfaultfd_ioctl+0x27b0/0x27b0
[ 198.116032] [<ffffffff8146c180>] ? debug_check_no_locks_freed+0x3c0/0x3c0
[ 198.116032] [<ffffffff813643f0>] ? mm_update_next_owner+0x640/0x640
[ 198.116032] [<ffffffff819323d0>] ? userfaultfd_release+0x620/0x620
[ 198.116032] [<ffffffff8137fd32>] ? __dequeue_signal+0x132/0x540
[ 198.116032] [<ffffffff8137f896>] ? recalc_sigpending_tsk+0xd6/0x180
[ 198.116032] [<ffffffff81367348>] do_group_exit+0x108/0x330
[ 198.116032] [<ffffffff8138adea>] get_signal+0x62a/0x15d0
[ 198.116032] [<ffffffff811d0333>] do_signal+0x83/0x1e20
[ 198.116032] [<ffffffff81761920>] ? __pmd_alloc+0x3f0/0x3f0
[ 198.116032] [<ffffffff811d02b0>] ? setup_sigcontext+0x7d0/0x7d0
[ 198.116032] [<ffffffff8125d3c5>] ? kvm_clock_get_cycles+0x25/0x30
[ 198.116032] [<ffffffff817720d0>] ? find_vma+0x30/0x150
[ 198.116032] [<ffffffff8126b128>] ? __do_page_fault+0x198/0xbb0
[ 198.116032] [<ffffffff81510500>] ? do_futex+0x17d0/0x17d0
[ 198.116032] [<ffffffff81006335>] exit_to_usermode_loop+0x1a5/0x210
[ 198.116032] [<ffffffff81008384>] prepare_exit_to_usermode+0x154/0x190
[ 198.116032] [<ffffffff86df20b4>] retint_user+0x8/0x23
[ 198.137668] ---[ end trace 1beeef55c15054c4 ]---
[ 198.138229] Showing busy workqueues and worker pools:
[ 198.219611] sr 1:0:0:0: [sr0] tag#0 FAILED Result: hostbyte=DID_OK
driverbyte=DRIVER_SENSE
[ 198.220424] sr 1:0:0:0: [sr0] tag#0 Sense Key : Illegal Request [current]
[ 198.221207] sr 1:0:0:0: [sr0] tag#0 Add. Sense: Invalid command operation code
[ 198.222086] sr 1:0:0:0: [sr0] tag#0 CDB: Write(10) 2a 00 00 00 00 00
00 00 04 00
[ 198.222872] blk_update_request: critical target error, dev sr0, sector 0
[ 198.223637] buffer_io_error: 78 callbacks suppressed
[ 198.224152] Buffer I/O error on dev sr0, logical block 0, lost async
page write
[ 198.225336] Buffer I/O error on dev sr0, logical block 1, lost async
page write
[ 198.226211] Buffer I/O error on dev sr0, logical block 2, lost async
page write
[ 198.227031] Buffer I/O error on dev sr0, logical block 3, lost async
page write
[ 198.227887] Buffer I/O error on dev sr0, logical block 4, lost async
page write
[ 198.228841] Buffer I/O error on dev sr0, logical block 5, lost async
page write
[ 198.229653] Buffer I/O error on dev sr0, logical block 6, lost async
page write
[ 198.230344] Buffer I/O error on dev sr0, logical block 7, lost async
page write
[ 198.231156] Buffer I/O error on dev sr0, logical block 8, lost async
page write
[ 198.231973] Buffer I/O error on dev sr0, logical block 9, lost async
page write
[ 198.244460] sr 1:0:0:0: [sr0] tag#0 FAILED Result: hostbyte=DID_OK
driverbyte=DRIVER_SENSE
[ 198.245272] sr 1:0:0:0: [sr0] tag#0 Sense Key : Illegal Request [current]
[ 198.245939] sr 1:0:0:0: [sr0] tag#0 Add. Sense: Invalid command operation code
[ 198.246554] sr 1:0:0:0: [sr0] tag#0 CDB: Write(10) 2a 00 00 00 00 00
00 00 02 00
[ 198.247265] blk_update_request: critical target error, dev sr0, sector 0
[ 198.275421] sr 1:0:0:0: [sr0] tag#0 FAILED Result: hostbyte=DID_OK
driverbyte=DRIVER_SENSE
[ 198.276249] sr 1:0:0:0: [sr0] tag#0 Sense Key : Illegal Request [current]
[ 198.276865] sr 1:0:0:0: [sr0] tag#0 Add. Sense: Invalid command operation code
[ 198.277466] sr 1:0:0:0: [sr0] tag#0 CDB: Write(10) 2a 00 00 00 00 00
00 00 04 00
[ 198.277998] blk_update_request: critical target error, dev sr0, sector 0
[ 198.333417] sr 1:0:0:0: [sr0] tag#0 FAILED Result: hostbyte=DID_OK
driverbyte=DRIVER_SENSE
[ 198.334161] sr 1:0:0:0: [sr0] tag#0 Sense Key : Illegal Request [current]
[ 198.334734] sr 1:0:0:0: [sr0] tag#0 Add. Sense: Invalid command operation code
[ 198.335433] sr 1:0:0:0: [sr0] tag#0 CDB: Write(10) 2a 00 00 00 00 00
00 00 04 00
[ 198.336095] blk_update_request: critical target error, dev sr0, sector 0
[ 198.337116] VFS: Dirty inode writeback failed for block device sr0 (err=-5).
