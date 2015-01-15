From: subashab@codeaurora.org
Subject: [PATCH] net: core: Fix race by  protecting process_queues at CPU
 hotplug
Date: Thu, 15 Jan 2015 03:13:25 -0000
Message-ID: <75547b88b7e2d15b35339a6321c3a929.squirrel@www.codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:56713 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751122AbbAODN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 22:13:26 -0500
Received: from www.codeaurora.org (pdx-caf-fw-vip.codeaurora.org [198.145.11.226])
	by smtp.codeaurora.org (Postfix) with ESMTP id E966114155C
	for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 03:13:24 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am seeing frequent crashes in high throughput conditions in a
multiprocessor system with kernel version 3.10 where cores are getting hot
plugged. I have pinned the network stack to a particular core using
receive packet steering (RPS). At the time of crash, it looks like a
contention of the process_queue between dev_cpu_callback and
process_backlog.

The following is the log at the moment of the crash
 75241.598056:   <6> Unable to handle kernel NULL pointer dereference at
virtual address 00000004
 75241.598064:   <6> pgd = c0004000
 75241.598072:   <2> [00000004] *pgd=00000000
 75241.598082:   <6> Internal error: Oops: 817 [#1] PREEMPT SMP ARM
 75241.598096:   <2> Modules linked in: wlan(O) [last unloaded: wlan]
 75241.598106:   <6> CPU: 0 PID: 3 Comm: ksoftirqd/0 Tainted: G        W 
O 3.10.49-g0b78c2e-00003-g2eab3e3 #1
 75241.598113:   <6> task: ee870a80 ti: ee888000 task.ti: ee888000
 75241.598133:   <2> PC is at process_backlog+0x78/0x140
 75241.598142:   <2> LR is at __netif_receive_skb_core+0x6fc/0x724

Here is the call stack involved in the crash
-006|__skb_unlink
-006|__skb_dequeue
-006|dev_cpu_callback
-007|notifier_call_chain
-008|__raw_notifier_call_chain
-009|notifier_to_errno
-009|__cpu_notify
-010|cpu_notify_nofail
-011|check_for_tasks
-011|cpu_down
-012|disable_nonboot_cpus()
-013|suspend_enter
-013|suspend_devices_and_enter
-014|enter_state
-014|pm_suspend
-015|state_store
-016|kobj_attr_store
-017|flush_write_buffer
-017|sysfs_write_file
-018|vfs_write
-019|SYSC_write
-019|sys_write
-020|ret_fast_syscall

I have a fix in mind in which the process queues are protected using spin
locks. I do not observe the crash with this patch. Since this patch is in
the hot path for incoming packet processing, I would like some reviews of
this patch. I would also like to know if there are any potential
performance bottlenecks due to this change.

    net: core: Protect process_queues at CPU hotplug

    When a CPU is hotplugged while processing incoming packets,
    dev_cpu_callback() will copy the poll list from the offline
    CPU and raise the softIRQ. In the same context, it will also
    process process_queue of the offline CPU by de-queueing and
    calling netif_rx. Due to this there is a potential for race
    condition between process_backlog() and dev_cpu_callback()
    accessing the same process_queue resource. This patch
    protects this concurrent access by locking.

    Signed-off-by: Prasad Sodagudi <psodagud@codeaurora.org>
    Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>

diff --git a/net/core/dev.c b/net/core/dev.c
index df0b522..aa8f503 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3640,6 +3640,7 @@ static void flush_backlog(void *arg)
        struct net_device *dev = arg;
        struct softnet_data *sd = &__get_cpu_var(softnet_data);
        struct sk_buff *skb, *tmp;
+       unsigned long flags;

        rps_lock(sd);
        skb_queue_walk_safe(&sd->input_pkt_queue, skb, tmp) {
@@ -3651,6 +3652,7 @@ static void flush_backlog(void *arg)
        }
        rps_unlock(sd);

+       spin_lock_irqsave(&sd->process_queue.lock, flags);
        skb_queue_walk_safe(&sd->process_queue, skb, tmp) {
                if (skb->dev == dev) {
                        __skb_unlink(skb, &sd->process_queue);
@@ -3658,6 +3660,7 @@ static void flush_backlog(void *arg)
                        input_queue_head_incr(sd);
                }
        }
+       spin_unlock_irqrestore(&sd->process_queue.lock, flags);
 }

 static int napi_gro_complete(struct sk_buff *skb)
@@ -4021,7 +4024,7 @@ static int process_backlog(struct napi_struct *napi,
int quota)
 {
        int work = 0;
        struct softnet_data *sd = container_of(napi, struct softnet_data,
backlog);
-
+       unsigned long flags;
 #ifdef CONFIG_RPS
        /* Check if we have pending ipi, its better to send them now,
         * not waiting net_rx_action() end.
@@ -4032,18 +4035,19 @@ static int process_backlog(struct napi_struct
*napi, int quota)
        }
 #endif
        napi->weight = weight_p;
-       local_irq_disable();
+       spin_lock_irqsave(&sd->process_queue.lock, flags);
        while (work < quota) {
                struct sk_buff *skb;
                unsigned int qlen;

                while ((skb = __skb_dequeue(&sd->process_queue))) {
-                       local_irq_enable();
+                       spin_unlock_irqrestore(&sd->process_queue.lock,
flags);
                        __netif_receive_skb(skb);
-                       local_irq_disable();
+                       spin_lock_irqsave(&sd->process_queue.lock, flags);
                        input_queue_head_incr(sd);
                        if (++work >= quota) {
-                               local_irq_enable();
+                              
spin_unlock_irqrestore(&sd->process_queue.lock,
+                                                      flags);
                                return work;
                        }
                }
@@ -4054,6 +4058,7 @@ static int process_backlog(struct napi_struct *napi,
int quota)
                        skb_queue_splice_tail_init(&sd->input_pkt_queue,
                                                   &sd->process_queue);

+
                if (qlen < quota - work) {
                        /*
                         * Inline a custom version of __napi_complete().
@@ -4069,7 +4074,7 @@ static int process_backlog(struct napi_struct *napi,
int quota)
                }
                rps_unlock(sd);
        }
-       local_irq_enable();
+       spin_unlock_irqrestore(&sd->process_queue.lock, flags);

        return work;
 }
@@ -5991,6 +5996,7 @@ static int dev_cpu_callback(struct notifier_block *nfb,
        struct sk_buff *skb;
        unsigned int cpu, oldcpu = (unsigned long)ocpu;
        struct softnet_data *sd, *oldsd;
+       unsigned long flags;

        if (action != CPU_DEAD && action != CPU_DEAD_FROZEN)
                return NOTIFY_OK;
@@ -6024,11 +6030,15 @@ static int dev_cpu_callback(struct notifier_block
*nfb,
        raise_softirq_irqoff(NET_TX_SOFTIRQ);
        local_irq_enable();

+       spin_lock_irqsave(&oldsd->process_queue.lock, flags);
        /* Process offline CPU's input_pkt_queue */
        while ((skb = __skb_dequeue(&oldsd->process_queue))) {
+               spin_unlock_irqrestore(&oldsd->process_queue.lock, flags);
                netif_rx(skb);
+               spin_lock_irqsave(&oldsd->process_queue.lock, flags);
                input_queue_head_incr(oldsd);
        }
+       spin_unlock_irqrestore(&oldsd->process_queue.lock, flags);
        while ((skb = __skb_dequeue(&oldsd->input_pkt_queue))) {
                netif_rx(skb);
                input_queue_head_incr(oldsd);

Thanks
KS

The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum,
 a Linux Foundation Collaborative Project
