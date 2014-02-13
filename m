From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: ovs inconsistent lock state
Date: Thu, 13 Feb 2014 11:21:12 -0800
Message-ID: <CALnjE+q7EVKziktx0K9PQwLjKv3Xv8zwOd2JMeNvx-8wzNjsGQ@mail.gmail.com>
References: <20140213171307.GC2829@minipsycho.orion>
	<CALnjE+oKrqMVWCrS3kSomxnsSJMFDpFsK8KY+oK1kVTd0Lb8Wg@mail.gmail.com>
	<20140213181257.GD2829@minipsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:57027 "HELO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750975AbaBMTVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 14:21:14 -0500
Received: by mail-vb0-f42.google.com with SMTP id i11so5453168vbh.1
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 11:21:13 -0800 (PST)
In-Reply-To: <20140213181257.GD2829@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 13, 2014 at 10:12 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Thu, Feb 13, 2014 at 06:42:03PM CET, pshelar@nicira.com wrote:
>>On Thu, Feb 13, 2014 at 9:13 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>> Hi.
>>>
>>> On current net-next I'm getting following message once I add a dp:
>>>
>>> [ 3014.523665] =================================
>>> [ 3014.524118] [ INFO: inconsistent lock state ]
>>> [ 3014.524118] 3.14.0-rc2+ #1 Not tainted
>>> [ 3014.524118] ---------------------------------
>>> [ 3014.524118] inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
>>> [ 3014.524118] swapper/1/0 [HC0[0]:SC1[5]:HE1:SE0] takes:
>>> [ 3014.524118]  (&(&flow->stats.stat->lock)->rlock){+.?...}, at: [<ffffffffa021b6ef>] ovs_flow_stats_update+0x4f/0xd0 [openvswitch]
>>> [ 3014.524118] {SOFTIRQ-ON-W} state was registered at:
>>> [ 3014.524118]   [<ffffffff810d6843>] __lock_acquire+0x5a3/0x1c30
>>> [ 3014.524118]   [<ffffffff810d7f80>] lock_acquire+0xb0/0x150
>>> [ 3014.524118]   [<ffffffff81705c99>] _raw_spin_lock+0x39/0x50
>>> [ 3014.524118]   [<ffffffffa021b8d3>] ovs_flow_stats_get+0x163/0x1b0 [openvswitch]
>>> [ 3014.524118]   [<ffffffffa0218ce5>] ovs_flow_cmd_fill_info+0x165/0x2b0 [openvswitch]
>>> [ 3014.524118]   [<ffffffffa021904c>] ovs_flow_cmd_build_info.constprop.27+0x6c/0xa0 [openvswitch]
>>> [ 3014.524118]   [<ffffffffa0219519>] ovs_flow_cmd_new_or_set+0x499/0x4f0 [openvswitch]
>>> [ 3014.524118]   [<ffffffff8161bf09>] genl_family_rcv_msg+0x199/0x390
>>> [ 3014.524118]   [<ffffffff8161c18e>] genl_rcv_msg+0x8e/0xd0
>>> [ 3014.524118]   [<ffffffff8161a189>] netlink_rcv_skb+0xa9/0xc0
>>> [ 3014.524118]   [<ffffffff8161a6a8>] genl_rcv+0x28/0x40
>>> [ 3014.524118]   [<ffffffff816197d0>] netlink_unicast+0xf0/0x1b0
>>> [ 3014.524118]   [<ffffffff81619b8f>] netlink_sendmsg+0x2ff/0x740
>>> [ 3014.524118]   [<ffffffff815ce86b>] sock_sendmsg+0x8b/0xc0
>>> [ 3014.524118]   [<ffffffff815cf369>] ___sys_sendmsg+0x389/0x3a0
>>> [ 3014.524118]   [<ffffffff815cfa62>] __sys_sendmsg+0x42/0x80
>>> [ 3014.524118]   [<ffffffff815cfab2>] SyS_sendmsg+0x12/0x20
>>> [ 3014.524118]   [<ffffffff8170f829>] system_call_fastpath+0x16/0x1b
>>> [ 3014.524118] irq event stamp: 6163288
>>> [ 3014.524118] hardirqs last  enabled at (6163288): [<ffffffff8169f8a0>] ip6_finish_output2+0x380/0x670
>>> [ 3014.524118] hardirqs last disabled at (6163287): [<ffffffff8169f85b>] ip6_finish_output2+0x33b/0x670
>>> [ 3014.524118] softirqs last  enabled at (6163266): [<ffffffff810888a2>] _local_bh_enable+0x22/0x50
>>> [ 3014.524118] softirqs last disabled at (6163267): [<ffffffff81089f15>] irq_exit+0xc5/0xd0
>>> [ 3014.524118]
>>> other info that might help us debug this:
>>> [ 3014.524118]  Possible unsafe locking scenario:
>>>
>>> [ 3014.524118]        CPU0
>>> [ 3014.524118]        ----
>>> [ 3014.524118]   lock(&(&flow->stats.stat->lock)->rlock);
>>> [ 3014.524118]   <Interrupt>
>>> [ 3014.524118]     lock(&(&flow->stats.stat->lock)->rlock);
>>> [ 3014.524118]
>>>  *** DEADLOCK ***
>>>
>>> [ 3014.524118] 5 locks held by swapper/1/0:
>>> [ 3014.524118]  #0:  (((&idev->mc_ifc_timer))){+.-...}, at: [<ffffffff81090095>] call_timer_fn+0x5/0x180
>>> [ 3014.524118]  #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff816c5755>] mld_sendpack+0x5/0x330
>>> [ 3014.524118]  #2:  (rcu_read_lock_bh){.+....}, at: [<ffffffff8169f579>] ip6_finish_output2+0x59/0x670
>>> [ 3014.524118]  #3:  (rcu_read_lock_bh){.+....}, at: [<ffffffff815eb585>] __dev_queue_xmit+0x5/0x6a0
>>> [ 3014.524118]  #4:  (rcu_read_lock){.+.+..}, at: [<ffffffffa0221995>] internal_dev_xmit+0x5/0x90 [openvswitch]
>>> [ 3014.524118]
>>> stack backtrace:
>>> [ 3014.524118] CPU: 1 PID: 0 Comm: swapper/1 Not tainted 3.14.0-rc2+ #1
>>> [ 3014.524118] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
>>> [ 3014.524118]  ffffffff82338940 ffff8800bb2838f0 ffffffff816fd1ac ffff8800b6b33570
>>> [ 3014.524118]  ffff8800bb283940 ffffffff816f9144 0000000000000005 ffff880000000001
>>> [ 3014.524118]  ffff880000000000 0000000000000006 ffff8800b6b33570 ffffffff810d4380
>>> [ 3014.524118] Call Trace:
>>> [ 3014.524118]  <IRQ>  [<ffffffff816fd1ac>] dump_stack+0x4d/0x66
>>> [ 3014.524118]  [<ffffffff816f9144>] print_usage_bug+0x1f3/0x204
>>> [ 3014.524118]  [<ffffffff810d4380>] ? check_usage_backwards+0x130/0x130
>>> [ 3014.524118]  [<ffffffff810d4da0>] mark_lock+0x270/0x300
>>> [ 3014.524118]  [<ffffffff810d6718>] __lock_acquire+0x478/0x1c30
>>> [ 3014.524118]  [<ffffffff810d4ede>] ? mark_held_locks+0xae/0x130
>>> [ 3014.524118]  [<ffffffffa0220047>] ? find_bucket.isra.1+0x67/0x70 [openvswitch]
>>> [ 3014.524118]  [<ffffffffa0220228>] ? masked_flow_lookup+0x78/0x140 [openvswitch]
>>> [ 3014.524118]  [<ffffffff810d669a>] ? __lock_acquire+0x3fa/0x1c30
>>> [ 3014.524118]  [<ffffffff810d7f80>] lock_acquire+0xb0/0x150
>>> [ 3014.524118]  [<ffffffffa021b6ef>] ? ovs_flow_stats_update+0x4f/0xd0 [openvswitch]
>>> [ 3014.524118]  [<ffffffff81705c99>] _raw_spin_lock+0x39/0x50
>>> [ 3014.524118]  [<ffffffffa021b6ef>] ? ovs_flow_stats_update+0x4f/0xd0 [openvswitch]
>>> [ 3014.524118]  [<ffffffffa021b6ef>] ovs_flow_stats_update+0x4f/0xd0 [openvswitch]
>>> [ 3014.524118]  [<ffffffffa021ac75>] ovs_dp_process_received_packet+0x75/0x100 [openvswitch]
>>> [ 3014.524118]  [<ffffffffa02213ea>] ovs_vport_receive+0x2a/0x30 [openvswitch]
>>> [ 3014.524118]  [<ffffffffa02219e6>] internal_dev_xmit+0x56/0x90 [openvswitch]
>>> [ 3014.524118]  [<ffffffffa0221995>] ? internal_dev_xmit+0x5/0x90 [openvswitch]
>>> [ 3014.524118]  [<ffffffff815eb276>] dev_hard_start_xmit+0x316/0x620
>>> [ 3014.524118]  [<ffffffff815eb8ff>] __dev_queue_xmit+0x37f/0x6a0
>>> [ 3014.524118]  [<ffffffff815eb585>] ? __dev_queue_xmit+0x5/0x6a0
>>> [ 3014.524118]  [<ffffffff8169f8a0>] ? ip6_finish_output2+0x380/0x670
>>> [ 3014.524118]  [<ffffffff815ebc30>] dev_queue_xmit+0x10/0x20
>>> [ 3014.524118]  [<ffffffff8169f900>] ip6_finish_output2+0x3e0/0x670
>>> [ 3014.524118]  [<ffffffff816a31aa>] ? ip6_finish_output+0x9a/0x200
>>> [ 3014.524118]  [<ffffffff816a31aa>] ip6_finish_output+0x9a/0x200
>>> [ 3014.524118]  [<ffffffff816a335f>] ip6_output+0x4f/0x1d0
>>> [ 3014.524118]  [<ffffffff816c58e6>] mld_sendpack+0x196/0x330
>>> [ 3014.524118]  [<ffffffff816c5755>] ? mld_sendpack+0x5/0x330
>>> [ 3014.524118]  [<ffffffff816c63cd>] mld_ifc_timer_expire+0x19d/0x2d0
>>> [ 3014.524118]  [<ffffffff816c6230>] ? mld_dad_timer_expire+0x70/0x70
>>> [ 3014.524118]  [<ffffffff8109010a>] call_timer_fn+0x7a/0x180
>>> [ 3014.524118]  [<ffffffff81090095>] ? call_timer_fn+0x5/0x180
>>> [ 3014.524118]  [<ffffffff816c6230>] ? mld_dad_timer_expire+0x70/0x70
>>> [ 3014.524118]  [<ffffffff8109054c>] run_timer_softirq+0x20c/0x2c0
>>> [ 3014.524118]  [<ffffffff810899fd>] __do_softirq+0x12d/0x310
>>> [ 3014.524118]  [<ffffffff81089f15>] irq_exit+0xc5/0xd0
>>> [ 3014.524118]  [<ffffffff81711b75>] smp_apic_timer_interrupt+0x45/0x60
>>> [ 3014.524118]  [<ffffffff817104b2>] apic_timer_interrupt+0x72/0x80
>>> [ 3014.524118]  <EOI>  [<ffffffff81052486>] ? native_safe_halt+0x6/0x10
>>> [ 3014.524118]  [<ffffffff8101ec04>] default_idle+0x24/0xe0
>>> [ 3014.524118]  [<ffffffff8101f54e>] arch_cpu_idle+0x2e/0x40
>>> [ 3014.524118]  [<ffffffff810e96ae>] cpu_startup_entry+0x9e/0x280
>>> [ 3014.524118]  [<ffffffff81044929>] start_secondary+0x1d9/0x280
>>> --
>>
>>Since ovs disable bh while reading stats from local cpu, deadlock can
>>not occur. This is false positive.
>
> I fail to see where bh is disabled. ovs_dp_process_received_packet() is
> called with rcu_read_lock...
>
ovs_dp_process_received_packet() is called in bottom half context on
every packet recv for ovs.


>>
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
