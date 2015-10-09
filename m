From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [4.1.3-rt8] [report][cpuhotplug] BUG: spinlock bad magic on CPU#0,
 sh/137
Date: Fri, 9 Oct 2015 09:25:49 -0500
Message-ID: <5617CE6D.9060800@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, Eric Dumazet <edumazet@google.com>,
	<netdev@vger.kernel.org>
To: <linux-rt-users@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

I can constantly see below error report with 4.1 RT-kernel on TI ARM dra7-evm 
if I'm trying to unplug cpu1:

[   57.737589] CPU1: shutdown
[   57.767537] BUG: spinlock bad magic on CPU#0, sh/137
[   57.767546]  lock: 0xee994730, .magic: 00000000, .owner: <none>/-1, .owner_cpu: 0
[   57.767552] CPU: 0 PID: 137 Comm: sh Not tainted 4.1.10-rt8-01700-g2c38702-dirty #55
[   57.767555] Hardware name: Generic DRA74X (Flattened Device Tree)
[   57.767568] [<c001acd0>] (unwind_backtrace) from [<c001534c>] (show_stack+0x20/0x24)
[   57.767579] [<c001534c>] (show_stack) from [<c075560c>] (dump_stack+0x84/0xa0)
[   57.767593] [<c075560c>] (dump_stack) from [<c00aca48>] (spin_dump+0x84/0xac)
[   57.767603] [<c00aca48>] (spin_dump) from [<c00acaa4>] (spin_bug+0x34/0x38)
[   57.767614] [<c00acaa4>] (spin_bug) from [<c00acc10>] (do_raw_spin_lock+0x168/0x1c0)
[   57.767624] [<c00acc10>] (do_raw_spin_lock) from [<c075b4cc>] (_raw_spin_lock+0x4c/0x54)
[   57.767631] [<c075b4cc>] (_raw_spin_lock) from [<c07599fc>] (rt_spin_lock_slowlock+0x5c/0x374)
[   57.767638] [<c07599fc>] (rt_spin_lock_slowlock) from [<c075bcf4>] (rt_spin_lock+0x38/0x70)
[   57.767649] [<c075bcf4>] (rt_spin_lock) from [<c06333c0>] (skb_dequeue+0x28/0x7c)
[   57.767662] [<c06333c0>] (skb_dequeue) from [<c06476ec>] (dev_cpu_callback+0x1b8/0x240)
[   57.767673] [<c06476ec>] (dev_cpu_callback) from [<c007566c>] (notifier_call_chain+0x3c/0xb4)
[   57.767683] [<c007566c>] (notifier_call_chain) from [<c0075708>] (__raw_notifier_call_chain+0x24/0x2c)
[   57.767692] [<c0075708>] (__raw_notifier_call_chain) from [<c004f2a4>] (cpu_notify+0x34/0x50)
[   57.767699] [<c004f2a4>] (cpu_notify) from [<c004f65c>] (cpu_notify_nofail+0x18/0x24)
[   57.767707] [<c004f65c>] (cpu_notify_nofail) from [<c074f304>] (_cpu_down+0x3e8/0x55c)
[   57.767715] [<c074f304>] (_cpu_down) from [<c004ff74>] (disable_nonboot_cpus+0x118/0x5dc)
[   57.767722] [<c004ff74>] (disable_nonboot_cpus) from [<c00b091c>] (suspend_enter+0x2c4/0xd18)
[   57.767730] [<c00b091c>] (suspend_enter) from [<c00b1454>] (suspend_devices_and_enter+0xe4/0x65c)
[   57.767737] [<c00b1454>] (suspend_devices_and_enter) from [<c00b208c>] (enter_state+0x6c0/0x1050)
[   57.767744] [<c00b208c>] (enter_state) from [<c00b2a40>] (pm_suspend+0x24/0x84)
[   57.767751] [<c00b2a40>] (pm_suspend) from [<c00af460>] (state_store+0x74/0xc8)
[   57.767760] [<c00af460>] (state_store) from [<c040a660>] (kobj_attr_store+0x1c/0x28)
[   57.767771] [<c040a660>] (kobj_attr_store) from [<c024563c>] (sysfs_kf_write+0x5c/0x60)
[   57.767781] [<c024563c>] (sysfs_kf_write) from [<c0244720>] (kernfs_fop_write+0xc8/0x1ac)
[   57.767792] [<c0244720>] (kernfs_fop_write) from [<c01c3974>] (__vfs_write+0x38/0xec)
[   57.767801] [<c01c3974>] (__vfs_write) from [<c01c4290>] (vfs_write+0xa0/0x174)
[   57.767811] [<c01c4290>] (vfs_write) from [<c01c4b30>] (SyS_write+0x54/0xb0)
[   57.767822] [<c01c4b30>] (SyS_write) from [<c0010b20>] (ret_fast_syscall+0x0/0x54)
[   57.768224] Powerdomain (l3init_pwrdm) didn't enter target state 1

I'm working with TI RT-kernel:
git://git.ti.com/ti-linux-kernel/ti-linux-kernel.git
branch: ti-rt-linux-4.1.y

It looks like this backtrace was introduces by 

commit 91df05da13a6c6c358e71182e80f19f3c48d1615
Author: Thomas Gleixner <tglx@linutronix.de>
Date:   Tue Jul 12 15:38:34 2011 +0200

    net: Use skbufhead with raw lock


I see the potential fix for this issue as below: 

index 4969c0d..f8c23de 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7217,7 +7217,7 @@ static int dev_cpu_callback(struct notifier_block *nfb,
                netif_rx_ni(skb);
                input_queue_head_incr(oldsd);
        }
-       while ((skb = skb_dequeue(&oldsd->input_pkt_queue))) {
+       while ((skb = __skb_dequeue(&oldsd->input_pkt_queue))) {
                netif_rx_ni(skb);
                input_queue_head_incr(oldsd);
        }

input_pkt_queue is per-cpu queue and at this moment cpu is dead already,
so no one should touch it. But I'm not sure if my assumption is correct.

-- 
regards,
-grygorii
