From: Jiri Slaby <jslaby@suse.cz>
Subject: Re: net/bluetooth: workqueue destruction WARNING in
 hci_unregister_dev
Date: Thu, 18 Feb 2016 15:00:37 +0100
Message-ID: <56C5CE85.6090808@suse.cz>
References: <CACT4Y+ax7zMOxe+kd4tw5Xdbvt=qPdBhXGO0j7qJwdn5tsfNNg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040302020607050402050800"
Cc: syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	Eric Dumazet <edumazet@google.com>, Tejun Heo <tj@kernel.org>,
	Takashi Iwai <tiwai@suse.com>
To: Dmitry Vyukov <dvyukov@google.com>,
	Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-bluetooth@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACT4Y+ax7zMOxe+kd4tw5Xdbvt=qPdBhXGO0j7qJwdn5tsfNNg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040302020607050402050800
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit

Cc Tejun (workqueues), Takashi (debug patch)

On 01/26/2016, 12:53 PM, Dmitry Vyukov wrote:
> Hello,
> 
> I've hit the following warning while running syzkaller fuzzer:

Hi,

I am hitting it over and over again using syzkaller.

> WARNING: CPU: 2 PID: 17409 at kernel/workqueue.c:3968
> destroy_workqueue+0x172/0x550()

Which of the warnings is it in your case?

I hit "(pwq != wq->dfl_pwq) && (pwq->refcnt > 1)". So I have this in the
code:
if (WARN_ON((pwq != wq->dfl_pwq) && (pwq->refcnt > 1))) {
        pr_info("%s: pwq=%p wq->dfl_pwq=%p pwq->refcnt=%d\n",
                        __func__, pwq, wq->dfl_pwq,
                        pwq->refcnt);
        mutex_unlock(&wq->mutex);
        return;
}

if (WARN_ON(pwq->nr_active)) {
...

And the values are:
pwq=ffff88006e271500 wq->dfl_pwq=ffff88006e272400 pwq->refcnt=2
pwq=ffff88002ec48300 wq->dfl_pwq=ffff88002ec4bc00 pwq->refcnt=2
pwq=ffff880020f76400 wq->dfl_pwq=ffff880020f75500 pwq->refcnt=2
pwq=ffff88002a908f00 wq->dfl_pwq=ffff88002a90bc00 pwq->refcnt=1
pwq=ffff8800348e0300 wq->dfl_pwq=ffff8800348e0000 pwq->refcnt=2
pwq=ffff88006e276400 wq->dfl_pwq=ffff88006e275800 pwq->refcnt=2


Note the single "pwq->refcnt=1" in there. So this is perhaps a race?

Takashi also provided me with a debug patch included in the attached
patch. It did not trigger though.

> CPU: 2 PID: 17409 Comm: syz-executor Not tainted 4.5.0-rc1+ #283
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>  00000000ffffffff ffff88003665f8a0 ffffffff8299a06d 0000000000000000
>  ffff88003599c740 ffffffff8643f0c0 ffff88003665f8e0 ffffffff8134fcf9
>  ffffffff8139d4c2 ffffffff8643f0c0 0000000000000f80 ffff8800630c5ae8
> Call Trace:
>  [<     inline     >] __dump_stack lib/dump_stack.c:15
>  [<ffffffff8299a06d>] dump_stack+0x6f/0xa2 lib/dump_stack.c:50
>  [<ffffffff8134fcf9>] warn_slowpath_common+0xd9/0x140 kernel/panic.c:482
>  [<ffffffff8134ff29>] warn_slowpath_null+0x29/0x30 kernel/panic.c:515
>  [<ffffffff8139d4c2>] destroy_workqueue+0x172/0x550 kernel/workqueue.c:3968
>  [<ffffffff85a714a4>] hci_unregister_dev+0x264/0x700
> net/bluetooth/hci_core.c:3162
>  [<ffffffff84595ce6>] vhci_release+0x76/0xe0 drivers/bluetooth/hci_vhci.c:341
>  [<ffffffff817b2376>] __fput+0x236/0x780 fs/file_table.c:208
>  [<ffffffff817b2945>] ____fput+0x15/0x20 fs/file_table.c:244
>  [<ffffffff813ad760>] task_work_run+0x170/0x210 kernel/task_work.c:115
>  [<     inline     >] exit_task_work include/linux/task_work.h:21
>  [<ffffffff81358da5>] do_exit+0x8b5/0x2c60 kernel/exit.c:748
>  [<ffffffff8135b2c8>] do_group_exit+0x108/0x330 kernel/exit.c:878
>  [<ffffffff8137e434>] get_signal+0x5e4/0x14f0 kernel/signal.c:2307
>  [<ffffffff811a1db3>] do_signal+0x83/0x1c90 arch/x86/kernel/signal.c:712
>  [<ffffffff81006685>] exit_to_usermode_loop+0x1a5/0x210
> arch/x86/entry/common.c:247
>  [<     inline     >] prepare_exit_to_usermode arch/x86/entry/common.c:282
>  [<ffffffff810084ea>] syscall_return_slowpath+0x2ba/0x340
> arch/x86/entry/common.c:344
>  [<ffffffff863597a2>] int_ret_from_sys_call+0x25/0x9f
> arch/x86/entry/entry_64.S:281
> ---[ end trace f627386faee7426f ]---
> 
> Unfortunately I cannot reproduce it in a controlled environment, but
> I've hit it twice in different VMs. So maybe if you see something
> obvious there. Is it possible that something is submitted into the
> workqueue between it is drained and destroyed in hci_unregister_dev?
> 
> On commit 92e963f50fc74041b5e9e744c330dca48e04f08d (Jan 24).
> 

thanks,
-- 
js
suse labs

--------------040302020607050402050800
Content-Type: text/x-patch;
 name="vhci_debug.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="vhci_debug.patch"

---
 include/linux/workqueue.h |    1 +
 kernel/workqueue.c        |   23 ++++++++++++++++++++---
 net/bluetooth/hci_core.c  |   19 +++++++++++++++++++
 3 files changed, 40 insertions(+), 3 deletions(-)

--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -312,6 +312,7 @@ enum {
 	__WQ_DRAINING		= 1 << 16, /* internal: workqueue is draining */
 	__WQ_ORDERED		= 1 << 17, /* internal: workqueue is ordered */
 	__WQ_LEGACY		= 1 << 18, /* internal: create*_workqueue() */
+	__WQ_DESTROYING		= 1 << 19,
 
 	WQ_MAX_ACTIVE		= 512,	  /* I like 512, better ideas? */
 	WQ_MAX_UNBOUND_PER_CPU	= 4,	  /* 4 * #cpus for unbound wq */
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -1366,6 +1366,9 @@ static void __queue_work(int cpu, struct
 	unsigned int work_flags;
 	unsigned int req_cpu = cpu;
 
+	if (WARN_ON(wq->flags & __WQ_DESTROYING))
+		return;
+
 	/*
 	 * While a work item is PENDING && off queue, a task trying to
 	 * steal the PENDING will busy-loop waiting for it to either get
@@ -4010,6 +4013,7 @@ void destroy_workqueue(struct workqueue_
 	int node;
 
 	/* drain it before proceeding with destruction */
+	wq->flags |= __WQ_DESTROYING;
 	drain_workqueue(wq);
 
 	/* sanity checks */
@@ -4024,9 +4028,22 @@ void destroy_workqueue(struct workqueue_
 			}
 		}
 
-		if (WARN_ON((pwq != wq->dfl_pwq) && (pwq->refcnt > 1)) ||
-		    WARN_ON(pwq->nr_active) ||
-		    WARN_ON(!list_empty(&pwq->delayed_works))) {
+		if (WARN_ON((pwq != wq->dfl_pwq) && (pwq->refcnt > 1))) {
+			pr_info("%s: pwq=%p wq->dfl_pwq=%p pwq->refcnt=%d\n",
+					__func__, pwq, wq->dfl_pwq,
+					pwq->refcnt);
+			mutex_unlock(&wq->mutex);
+			return;
+		}
+
+		if (WARN_ON(pwq->nr_active)) {
+			pr_info("%s: %ps\n", __func__, wq);
+			mutex_unlock(&wq->mutex);
+			return;
+		}
+
+		if (WARN_ON(!list_empty(&pwq->delayed_works))) {
+			pr_info("%s: %ps\n", __func__, wq);
 			mutex_unlock(&wq->mutex);
 			return;
 		}
--- a/net/bluetooth/hci_core.c
+++ b/net/bluetooth/hci_core.c
@@ -2467,6 +2467,8 @@ static void hci_cmd_timeout(struct work_
 	struct hci_dev *hdev = container_of(work, struct hci_dev,
 					    cmd_timer.work);
 
+	if (WARN_ON(hci_dev_test_flag(hdev, HCI_UNREGISTER)))
+		return;
 	if (hdev->sent_cmd) {
 		struct hci_command_hdr *sent = (void *) hdev->sent_cmd->data;
 		u16 opcode = __le16_to_cpu(sent->opcode);
@@ -3225,6 +3227,11 @@ int hci_recv_frame(struct hci_dev *hdev,
 		return -ENXIO;
 	}
 
+	if (WARN_ON(hci_dev_test_flag(hdev, HCI_UNREGISTER))) {
+		kfree_skb(skb);
+		return -ENXIO;
+	}
+
 	if (hci_skb_pkt_type(skb) != HCI_EVENT_PKT &&
 	    hci_skb_pkt_type(skb) != HCI_ACLDATA_PKT &&
 	    hci_skb_pkt_type(skb) != HCI_SCODATA_PKT) {
@@ -3248,6 +3255,9 @@ EXPORT_SYMBOL(hci_recv_frame);
 /* Receive diagnostic message from HCI drivers */
 int hci_recv_diag(struct hci_dev *hdev, struct sk_buff *skb)
 {
+	if (WARN_ON(hci_dev_test_flag(hdev, HCI_UNREGISTER)))
+		return -ENXIO;
+
 	/* Mark as diagnostic packet */
 	hci_skb_pkt_type(skb) = HCI_DIAG_PKT;
 
@@ -3326,6 +3336,9 @@ int hci_send_cmd(struct hci_dev *hdev, _
 {
 	struct sk_buff *skb;
 
+	if (WARN_ON(hci_dev_test_flag(hdev, HCI_UNREGISTER)))
+		return -ENXIO;
+
 	BT_DBG("%s opcode 0x%4.4x plen %d", hdev->name, opcode, plen);
 
 	skb = hci_prepare_cmd(hdev, opcode, plen, param);
@@ -3461,6 +3474,9 @@ void hci_send_acl(struct hci_chan *chan,
 {
 	struct hci_dev *hdev = chan->conn->hdev;
 
+	if (WARN_ON(hci_dev_test_flag(hdev, HCI_UNREGISTER)))
+		return;
+
 	BT_DBG("%s chan %p flags 0x%4.4x", hdev->name, chan, flags);
 
 	hci_queue_acl(chan, &chan->data_q, skb, flags);
@@ -3474,6 +3490,9 @@ void hci_send_sco(struct hci_conn *conn,
 	struct hci_dev *hdev = conn->hdev;
 	struct hci_sco_hdr hdr;
 
+	if (WARN_ON(hci_dev_test_flag(hdev, HCI_UNREGISTER)))
+		return;
+
 	BT_DBG("%s len %d", hdev->name, skb->len);
 
 	hdr.handle = cpu_to_le16(conn->handle);

--------------040302020607050402050800--
