From: Peter Wu <lekensteyn@gmail.com>
Subject: [PATCH] r8169: cancel work queue when interface goes down
Date: Sun, 21 Jul 2013 10:51:46 +0200
Message-ID: <1574882.LCoXNHVmA8@al>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:43602 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753641Ab3GUIvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jul 2013 04:51:52 -0400
Received: by mail-ea0-f174.google.com with SMTP id o10so3189053eaj.5
        for <netdev@vger.kernel.org>; Sun, 21 Jul 2013 01:51:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the work queue is initialised in rtl_open, used to dispatch rtl_task
and canceled in rtl_remove_one (when the PCI device gets removed). This causes a
lockdep warning when the work queue is uninitialised:

[  106.005403] INFO: trying to register non-static key.
[  106.005416] the code is fine but needs lockdep annotation.
[  106.005419] turning off the locking correctness validator.
[  106.005426] CPU: 3 PID: 2576 Comm: tee Tainted: G        W  O 3.11.0-rc1-cold-00021-g3aaf2fe-dirty #1
[  106.005429] Hardware name: Gigabyte Technology Co., Ltd. To be filled by O.E.M./Z68X-UD3H-B3, BIOS U1l 03/08/2013
[  106.005433]  ffff8806014fbf60 ffff880601521b58 ffffffff8166d3e7 0000000000000000
[  106.005498]  ffff8805fc0598f8 ffff880601521bf8 ffffffff810ad6d6 ffff880601521bb8
[  106.005508]  ffffffff00000000 ffff880600000000 0000000600000000 ffff880601521ce0
[  106.005520] Call Trace:
[  106.005531]  [<ffffffff8166d3e7>] dump_stack+0x55/0x76
[  106.005540]  [<ffffffff810ad6d6>] __lock_acquire+0x9b6/0xab0
[  106.005546]  [<ffffffff810adf76>] ? lockdep_init_map.part.40+0x46/0x590
[  106.005554]  [<ffffffff81069f35>] ? flush_work+0x5/0xb0
[  106.005560]  [<ffffffff810ade80>] lock_acquire+0x90/0x140
[  106.005565]  [<ffffffff81069f35>] ? flush_work+0x5/0xb0
[  106.005571]  [<ffffffff81069f78>] flush_work+0x48/0xb0
[  106.005577]  [<ffffffff81069f35>] ? flush_work+0x5/0xb0
[  106.005582]  [<ffffffff810abbb4>] ? mark_held_locks+0x74/0x140
[  106.005589]  [<ffffffff8106afb1>] ? __cancel_work_timer+0x71/0x110
[  106.005594]  [<ffffffff810abe3d>] ? trace_hardirqs_on_caller+0x7d/0x150
[  106.005600]  [<ffffffff8106afbd>] __cancel_work_timer+0x7d/0x110
[  106.005607]  [<ffffffff8106b080>] cancel_work_sync+0x10/0x20
[  106.005615]  [<ffffffffa03663c3>] rtl_remove_one+0x63/0x150 [r8169]
[  106.005621]  [<ffffffff8134a626>] pci_device_remove+0x46/0xc0
[  106.005628]  [<ffffffff8141832f>] __device_release_driver+0x7f/0xf0
[  106.005632]  [<ffffffff814183ce>] device_release_driver+0x2e/0x40
[  106.005640]  [<ffffffff81417213>] driver_unbind+0xa3/0xc0
[  106.005646]  [<ffffffff814165f4>] drv_attr_store+0x24/0x40
[  106.005652]  [<ffffffff811fe0f6>] sysfs_write_file+0xe6/0x170
[  106.005659]  [<ffffffff81187f7e>] vfs_write+0xce/0x200
[  106.005664]  [<ffffffff81188485>] SyS_write+0x55/0xa0
[  106.005672]  [<ffffffff81682982>] system_call_fastpath+0x16/0x1b

Now let's have a look at the users of this work queue and their call stack:
rtl_open
-> INIT_WORK
-> rtl_lock_work
   -> set_bit(RTL_FLAG_TASK_ENABLED)

rtl_task
-> rtl_lock_work
   -> if not test_bit(RTL_FLAG_TASK_ENABLED), rtl_unlock_work and return
   -> clear bit and do work

rtl_remove_one
-> cancel_work_sync
-> netif_napi_del
   -> rtl_schedule_task(flag)
      -> test if flag is already scheduled, if not, schedule_work()
-> unregister_netdev
   -> rtl8169_close
      -> rtl_lock_work
         -> clear_bit(RTL_FLAG_TASK_ENABLED)

Note that the work queue is initialised when the network interface goes up
and that the work queue is canceled when the PCI device gets removed.  A network
interface does not need to get up, this may be the case when the link is not
connected. This means that the work queue is not initialised. Either the work
queue should be initialised in rtl_init_one (to match rtl_remove_one) or the
work should be canceled in rtl_close (as suggested by Francois Romieu[2]).

Let's move cancel_work_sync from rtl_remove_one to somewhere in rtl_close. It
must be established that after rtl_close, no work is scheduled.  After
rtl_init_one, netapi can call rtl8169_poll which can cause a new task to get
scheduled. Assume that this happens, then a task is scheduled. Now let the PCI
device get deleted (such that rtl_remove_one gets called). Under the lock in
rtl_close, work could still be scheduled, but not execute (since rtl_task needs
to acquire the lock before dispatching work). After
`set_bit(RTL_FLAG_TASK_ENABLED)`, no scheduled work will be executed. Now we
have two places to put cancel_work_sync:

1. Under the lock right after clearing the enabled bit.
2. After the lock has released.

The first option seemed nicer as it there is full certainty that no scheduled
tasks are executed nor scheduled after the lock has been released. It turns out,
however, that a deadlock could occur (thanks lockdep!):

1. CPU0: rtl_close: lock(&tp->wk.mutex) (trying to lock for clearing flags)
2. CPU1: rtl_task: lock(&tp->wk.work) (because scheduled work gets dispatched)
3. CPU1: rtl_task: lock(&tp->wk.mutex) (trying to lock to test flags)
4. CPU0: rtl_close: lock(&tp->wk.work) (trying to cancel work)
5. *** DEADLOCK ***

So, cancel_work_put has to be put after releasing the mutex.

 [2]: http://www.spinics.net/lists/netdev/msg243503.html

Signed-off-by: Peter Wu <lekensteyn@gmail.com>
---
In an earlier mail, I mentioned that I have a issue where I get log spam
("PHY reset until link up"). Although it is dispatched through the work queue,
this patch does not appear to solve the problem as the issue occurs when the
interface is up (happens automatically when a device is bound by the driver?).
---
 drivers/net/ethernet/realtek/r8169.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 4106a74..880015c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6468,6 +6468,8 @@ static int rtl8169_close(struct net_device *dev)
 	rtl8169_down(dev);
 	rtl_unlock_work(tp);
 
+	cancel_work_sync(&tp->wk.work);
+
 	free_irq(pdev->irq, dev);
 
 	dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->RxDescArray,
@@ -6793,8 +6795,6 @@ static void rtl_remove_one(struct pci_dev *pdev)
 		rtl8168_driver_stop(tp);
 	}
 
-	cancel_work_sync(&tp->wk.work);
-
 	netif_napi_del(&tp->napi);
 
 	unregister_netdev(dev);
-- 
1.8.3.2
