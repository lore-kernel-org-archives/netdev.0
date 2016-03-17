From: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: net/bluetooth: workqueue destruction WARNING in
 hci_unregister_dev
Date: Thu, 17 Mar 2016 13:00:13 +0100
Message-ID: <56EA9C4D.2080803@suse.cz>
References: <CACT4Y+ax7zMOxe+kd4tw5Xdbvt=qPdBhXGO0j7qJwdn5tsfNNg@mail.gmail.com>
 <56C5CE85.6090808@suse.cz>
 <CACT4Y+bVXfY=wBZ+08rq16tHFw9s3YDrE_LCS=to-GF70AffRQ@mail.gmail.com>
 <20160218174427.GG13177@mtj.duckdns.org> <56C6EC62.8080107@suse.cz>
 <56C70618.3010902@suse.cz> <20160302154507.GC4282@mtj.duckdns.org>
 <56D7FFE1.90900@suse.cz> <20160311171205.GB24046@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060805040801090200020406"
Cc: Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>,
	Gustavo Padovan <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>,
	Johan Hedberg <johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	syzkaller <syzkaller-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>,
	Kostya Serebryany <kcc-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Alexander Potapenko <glider-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Sasha Levin <sasha.levin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Takashi Iwai <tiwai-IBi9RG/b67k@public.gmane.org>
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160311171205.GB24046-piEFEHQLUPpN0TnZuCh8vA@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060805040801090200020406
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit

Hello,

On 03/11/2016, 06:12 PM, Tejun Heo wrote:
> On Thu, Mar 03, 2016 at 10:12:01AM +0100, Jiri Slaby wrote:
>> On 03/02/2016, 04:45 PM, Tejun Heo wrote:
>>> On Fri, Feb 19, 2016 at 01:10:00PM +0100, Jiri Slaby wrote:
>>>>> 1. didn't help, the problem persists. So I haven't applied the patch from 2.
>>>>
>>>> FWIW I dumped more info about the wq:
>>>> wq->name='hci0' pwq=ffff8800390d7600 wq->dfl_pwq=ffff8800390d5200
>>>> pwq->refcnt=2 pwq->nr_active=0 delayed_works: <nothing>
>>>
>>> Can you please print out the same info for all pwq's during shutdown?
>>> It looks like we're leaking pwq refcnt but I can't spot a place where
>>> that could happen on an empty pwq.
>>
>> I have not done that yet, but today, I see:
>> destroy_workqueue: name='req_hci0' pwq=ffff88002f590300
>> wq->dfl_pwq=ffff88002f591e00 pwq->refcnt=2 pwq->nr_active=0 delayed_works:
>>    pwq 12: cpus=0-1 node=0 flags=0x4 nice=-20 active=0/1
>>      in-flight: 18568:wq_barrier_func
> 
> So, this means that there's flush_work() racing against workqueue
> destruction, which can't be safe. :(

But I cannot trigger the WARN_ONs in the attached patch, so I am
confused how this can happen :(. (While I am still seeing the destroy
WARNINGs.)

BTW. what did you mean by dumping the states at shutdown? Is it still
relevant?

thanks,
-- 
js
suse labs

--------------060805040801090200020406
Content-Type: text/x-patch;
 name="vhci_debug.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="vhci_debug.patch"

---
 include/linux/workqueue.h        |    1 +
 include/net/bluetooth/hci_core.h |    5 +++++
 kernel/reboot.c                  |    1 +
 kernel/workqueue.c               |   34 +++++++++++++++++++++++++++++++---
 net/bluetooth/hci_core.c         |   39 +++++++++++++++++++++++++++++++++++----
 5 files changed, 73 insertions(+), 7 deletions(-)

--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -312,6 +312,7 @@ enum {
 	__WQ_DRAINING		= 1 << 16, /* internal: workqueue is draining */
 	__WQ_ORDERED		= 1 << 17, /* internal: workqueue is ordered */
 	__WQ_LEGACY		= 1 << 18, /* internal: create*_workqueue() */
+	__WQ_DESTROYING		= 1 << 19,
 
 	WQ_MAX_ACTIVE		= 512,	  /* I like 512, better ideas? */
 	WQ_MAX_UNBOUND_PER_CPU	= 4,	  /* 4 * #cpus for unbound wq */
--- a/include/net/bluetooth/hci_core.h
+++ b/include/net/bluetooth/hci_core.h
@@ -312,6 +312,11 @@ struct hci_dev {
 
 	struct workqueue_struct	*workqueue;
 	struct workqueue_struct	*req_workqueue;
+#define HCI_WQ_A	0
+#define HCI_WQ_D	1
+#define HCI_WQR_A	8
+#define HCI_WQR_D	9
+	unsigned long		wq_status;
 
 	struct work_struct	power_on;
 	struct delayed_work	power_off;
--- a/kernel/reboot.c
+++ b/kernel/reboot.c
@@ -231,6 +231,7 @@ static void kernel_shutdown_prepare(enum
 		(state == SYSTEM_HALT) ? SYS_HALT : SYS_POWER_OFF, NULL);
 	system_state = state;
 	usermodehelper_disable();
+	show_workqueue_state();
 	device_shutdown();
 }
 /**
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
@@ -2804,6 +2807,9 @@ static bool start_flush_work(struct work
 		pwq = worker->current_pwq;
 	}
 
+	if (WARN_ON(pwq->wq->flags & __WQ_DESTROYING))
+		return false;
+
 	check_flush_dependency(pwq->wq, work);
 
 	insert_wq_barrier(pwq, barr, work, worker);
@@ -2821,6 +2827,8 @@ static bool start_flush_work(struct work
 		lock_map_acquire_read(&pwq->wq->lockdep_map);
 	lock_map_release(&pwq->wq->lockdep_map);
 
+	WARN_ON(pwq->wq->flags & __WQ_DESTROYING);
+
 	return true;
 already_gone:
 	spin_unlock_irq(&pool->lock);
@@ -3998,6 +4006,8 @@ err_destroy:
 }
 EXPORT_SYMBOL_GPL(__alloc_workqueue_key);
 
+static void show_pwq(struct pool_workqueue *pwq);
+
 /**
  * destroy_workqueue - safely terminate a workqueue
  * @wq: target workqueue
@@ -4010,6 +4020,7 @@ void destroy_workqueue(struct workqueue_
 	int node;
 
 	/* drain it before proceeding with destruction */
+	wq->flags |= __WQ_DESTROYING;
 	drain_workqueue(wq);
 
 	/* sanity checks */
@@ -4024,9 +4035,26 @@ void destroy_workqueue(struct workqueue_
 			}
 		}
 
-		if (WARN_ON((pwq != wq->dfl_pwq) && (pwq->refcnt > 1)) ||
-		    WARN_ON(pwq->nr_active) ||
-		    WARN_ON(!list_empty(&pwq->delayed_works))) {
+		if ((pwq != wq->dfl_pwq) && (pwq->refcnt > 1)) {
+			pr_info("%s: name='%s' pwq=%p wq->dfl_pwq=%p pwq->refcnt=%d pwq->nr_active=%d delayed_works:",
+					__func__, wq->name, pwq, wq->dfl_pwq,
+					pwq->refcnt, pwq->nr_active);
+
+			show_pwq(pwq);
+
+			mutex_unlock(&wq->mutex);
+			WARN_ON(1);
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
@@ -1471,7 +1471,11 @@ int hci_dev_open(__u16 dev)
 	 * has finished. This means that error conditions like RFKILL
 	 * or no valid public or static random address apply.
 	 */
+	WARN_ON(test_bit(HCI_WQR_D, &hdev->wq_status));
+	WARN_ON(!test_bit(HCI_WQR_A, &hdev->wq_status));
 	flush_workqueue(hdev->req_workqueue);
+	WARN_ON(test_bit(HCI_WQR_D, &hdev->wq_status));
+	WARN_ON(!test_bit(HCI_WQR_A, &hdev->wq_status));
 
 	/* For controllers not using the management interface and that
 	 * are brought up using legacy ioctl, set the HCI_BONDABLE bit
@@ -2467,6 +2471,8 @@ static void hci_cmd_timeout(struct work_
 	struct hci_dev *hdev = container_of(work, struct hci_dev,
 					    cmd_timer.work);
 
+	if (WARN_ON(hci_dev_test_flag(hdev, HCI_UNREGISTER)))
+		return;
 	if (hdev->sent_cmd) {
 		struct hci_command_hdr *sent = (void *) hdev->sent_cmd->data;
 		u16 opcode = __le16_to_cpu(sent->opcode);
@@ -3043,15 +3049,17 @@ int hci_register_dev(struct hci_dev *hde
 
 	BT_DBG("%p name %s bus %d", hdev, hdev->name, hdev->bus);
 
-	hdev->workqueue = alloc_workqueue("%s", WQ_HIGHPRI | WQ_UNBOUND |
-					  WQ_MEM_RECLAIM, 1, hdev->name);
+	hdev->workqueue = alloc_workqueue("%s", WQ_HIGHPRI | WQ_UNBOUND
+					  , 1, hdev->name);
+	set_bit(HCI_WQ_A, &hdev->wq_status);
 	if (!hdev->workqueue) {
 		error = -ENOMEM;
 		goto err;
 	}
 
-	hdev->req_workqueue = alloc_workqueue("%s", WQ_HIGHPRI | WQ_UNBOUND |
-					      WQ_MEM_RECLAIM, 1, hdev->name);
+	hdev->req_workqueue = alloc_workqueue("req_%s", WQ_HIGHPRI | WQ_UNBOUND
+					      , 1, hdev->name);
+	set_bit(HCI_WQR_A, &hdev->wq_status);
 	if (!hdev->req_workqueue) {
 		destroy_workqueue(hdev->workqueue);
 		error = -ENOMEM;
@@ -3108,8 +3116,12 @@ int hci_register_dev(struct hci_dev *hde
 	return id;
 
 err_wqueue:
+	set_bit(HCI_WQ_D, &hdev->wq_status);
 	destroy_workqueue(hdev->workqueue);
+	clear_bit(HCI_WQ_A, &hdev->wq_status);
+	set_bit(HCI_WQR_D, &hdev->wq_status);
 	destroy_workqueue(hdev->req_workqueue);
+	clear_bit(HCI_WQR_A, &hdev->wq_status);
 err:
 	ida_simple_remove(&hci_index_ida, hdev->id);
 
@@ -3160,7 +3172,9 @@ void hci_unregister_dev(struct hci_dev *
 	debugfs_remove_recursive(hdev->debugfs);
 
 	destroy_workqueue(hdev->workqueue);
+	set_bit(HCI_WQR_D, &hdev->wq_status);
 	destroy_workqueue(hdev->req_workqueue);
+	clear_bit(HCI_WQR_A, &hdev->wq_status);
 
 	hci_dev_lock(hdev);
 	hci_bdaddr_list_clear(&hdev->blacklist);
@@ -3225,6 +3239,11 @@ int hci_recv_frame(struct hci_dev *hdev,
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
@@ -3248,6 +3267,9 @@ EXPORT_SYMBOL(hci_recv_frame);
 /* Receive diagnostic message from HCI drivers */
 int hci_recv_diag(struct hci_dev *hdev, struct sk_buff *skb)
 {
+	if (WARN_ON(hci_dev_test_flag(hdev, HCI_UNREGISTER)))
+		return -ENXIO;
+
 	/* Mark as diagnostic packet */
 	hci_skb_pkt_type(skb) = HCI_DIAG_PKT;
 
@@ -3326,6 +3348,9 @@ int hci_send_cmd(struct hci_dev *hdev, _
 {
 	struct sk_buff *skb;
 
+	if (WARN_ON(hci_dev_test_flag(hdev, HCI_UNREGISTER)))
+		return -ENXIO;
+
 	BT_DBG("%s opcode 0x%4.4x plen %d", hdev->name, opcode, plen);
 
 	skb = hci_prepare_cmd(hdev, opcode, plen, param);
@@ -3461,6 +3486,9 @@ void hci_send_acl(struct hci_chan *chan,
 {
 	struct hci_dev *hdev = chan->conn->hdev;
 
+	if (WARN_ON(hci_dev_test_flag(hdev, HCI_UNREGISTER)))
+		return;
+
 	BT_DBG("%s chan %p flags 0x%4.4x", hdev->name, chan, flags);
 
 	hci_queue_acl(chan, &chan->data_q, skb, flags);
@@ -3474,6 +3502,9 @@ void hci_send_sco(struct hci_conn *conn,
 	struct hci_dev *hdev = conn->hdev;
 	struct hci_sco_hdr hdr;
 
+	if (WARN_ON(hci_dev_test_flag(hdev, HCI_UNREGISTER)))
+		return;
+
 	BT_DBG("%s len %d", hdev->name, skb->len);
 
 	hdr.handle = cpu_to_le16(conn->handle);

--------------060805040801090200020406--
