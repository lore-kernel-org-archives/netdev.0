From: Ben Greear <greearb@candelatech.com>
Subject: Re: ixgbe NULLL pointer dereference on OOM condition, 2.6.31.7
Date: Wed, 13 Jan 2010 13:18:27 -0800
Message-ID: <4B4E38A3.7010902@candelatech.com>
References: <4B424825.2070608@candelatech.com> <alpine.WNT.2.00.1001121757040.3168@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:60132 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755467Ab0AMVS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 16:18:28 -0500
In-Reply-To: <alpine.WNT.2.00.1001121757040.3168@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/12/2010 06:13 PM, Brandeburg, Jesse wrote:
> On Mon, 4 Jan 2010, Ben Greear wrote:
>
>> This is on a hacked 2.6.31.7 kernel.  I'm testing an application that creates
>> 30,000+ TCP connections (to self).  The system is 64-bit with 12GB of RAM, but
>> it can still run out of usable RAM (say, when I start another 10k connections
>> to bring it up to 40k).
>>
>> It looks like something in ixgbe isn't properly checking for inability
>> to allocate (or to have previously allocated) an skb, or perhaps some other
>> chunk of memory:
>>
>> [root@ct503-10G-09 ~]# BUG: unable to handle kernel NULL pointer dereference at 00000000000000e8
>> IP: [<ffffffffa0054ca0>] ixgbe_clean_rx_irq+0xe4/0x522 [ixgbe]
>
> Hi Ben, thanks for the report, is there a chance you can run gdb on your
> kernel (was it compiled with debug info?) and check the
> gdb>  l *(ixgbe_clean_rx_irq+0xe4)
>
> Sorry I'm so slow to respond.
>
> it seems there are some unwind problems after the recent round of patches
> to remove skb_dma_map/unmap, but those were only introduced in 2.6.33-rc1.
> Before that we weren't aware of any failure path issues.
>
> I'm building a kernel now to see if I can figure out the offset where
> you're showing the problem.

I was able to reproduce this against 2.6.31.9 + hackings, but it took around
3 hours of 30k connections and intermittent serious memory pressure.

This appears to be the identical place from the previous crash (there were no
ixgbe changes between .7 and .9 as far as I know).

# BUG: unable to handle kernel NULL pointer dereference at 00000000000000e8
IP: [<ffffffffa005760b>] ixgbe_clean_rx_irq+0xdf/0x525 [ixgbe]
PGD 0
Oops: 0000 [#1] PREEMPT SMP
last sysfs file: /sys/devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda/sda1/stat
CPU 6
Modules linked in: arc4 michael_mic wanlink nfs lockd fscache nfs_acl auth_rpcgss 8021q garp stp llc veth fuse macvlan pktgen ]
Pid: 0, comm: swapper Not tainted 2.6.31.9 #29 X8STi
RIP: 0010:[<ffffffffa005760b>]  [<ffffffffa005760b>] ixgbe_clean_rx_irq+0xdf/0x525 [ixgbe]
RSP: 0018:ffff8800280e5d90  EFLAGS: 00010287
RAX: 0000000000000042 RBX: 0000000000000000 RCX: ffffc90018ee3000
RDX: 0000000000000100 RSI: 0000000000000000 RDI: ffff88033084e480
RBP: ffff8800280e5e20 R08: 0000000000000000 R09: ffff88033084e380
R10: 0000000000000501 R11: ffff8800280e5dd0 R12: ffff88033040c2a0
R13: ffff88032e8f85c0 R14: ffff88030d074000 R15: 000000000000059c
FS:  0000000000000000(0000) GS:ffff8800280e2000(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00000000000000e8 CR3: 0000000001001000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffff88033255a000, task ffff88033250de80)
Stack:
  ffff8800280e5e30 ffffffffa0053cce 00000040280e5dd0 ffff8800280e5e3c
<0> ffff880332744800 ffff88033084e490 ffff88033084e480 ffff88032e8f8000
<0> 00000000280e5e01 0000006300000000 0000000000000000 0000000000000000
Call Trace:
  <IRQ>
  [<ffffffffa0053cce>] ? ixgbe_clean_tx_irq+0x125/0x3e5 [ixgbe]
  [<ffffffffa0057ab8>] ixgbe_clean_rxonly+0x67/0xe2 [ixgbe]
  [<ffffffff81351ba3>] net_rx_action+0xab/0x24d
  [<ffffffffa0053285>] ? napi_schedule+0x1b/0x1d [ixgbe]
  [<ffffffff81055206>] __do_softirq+0x114/0x220
  [<ffffffff81093bb5>] ? handle_IRQ_event+0x92/0x18a
  [<ffffffff81012d9c>] call_softirq+0x1c/0x30
  [<ffffffff81014306>] do_softirq+0x42/0x88
  [<ffffffff81055420>] irq_exit+0x3f/0x8f
  [<ffffffff81013a47>] do_IRQ+0xa0/0xb7
  [<ffffffff81012593>] ret_from_intr+0x0/0x11
  <EOI>
  [<ffffffff8124ecc8>] ? acpi_idle_enter_simple+0x10f/0x143
  [<ffffffff8124ecc1>] ? acpi_idle_enter_simple+0x108/0x143
  [<ffffffff8124e9d1>] ? acpi_idle_enter_bm+0xd3/0x2bb
  [<ffffffff81096982>] ? rcu_needs_cpu+0x32/0x43
  [<ffffffff81328772>] ? cpuidle_idle_call+0x94/0xca
  [<ffffffff81010c37>] ? cpu_idle+0x58/0xc6
  [<ffffffff813ebd34>] ? start_secondary+0x19c/0x1a0
Code: 25 e0 7f 00 00 ba 00 01 00 00 45 0f b7 7e 0c c1 f8 05 3d 00 01 00 00 0f 47 c2 eb 08 41 0f b7 46 0c 45 31 ff 48 8b 19 48
RIP  [<ffffffffa005760b>] ixgbe_clean_rx_irq+0xdf/0x525 [ixgbe]
  RSP <ffff8800280e5d90>
CR2: 00000000000000e8
---[ end trace 7c6f3b3b09f60762 ]---
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 0, comm: swapper Tainted: G      D    2.6.31.9 #29
Call Trace:
  <IRQ>  [<ffffffff813efa5b>] panic+0x84/0x136
  [<ffffffff813f2e26>] oops_end+0xb1/0xc1
  [<ffffffff810328fa>] no_context+0x1f1/0x200
  [<ffffffff813f1d39>] ? _spin_unlock+0x2a/0x35
  [<ffffffff810955d6>] ? handle_edge_irq+0x105/0x10e
  [<ffffffff81032aa7>] __bad_area_nosemaphore+0x19e/0x1c4
  [<ffffffff8105542d>] ? irq_exit+0x4c/0x8f
  [<ffffffff81013a47>] ? do_IRQ+0xa0/0xb7
  [<ffffffff81012593>] ? ret_from_intr+0x0/0x11
  [<ffffffff81032adb>] bad_area_nosemaphore+0xe/0x10
  [<ffffffff813f4303>] do_page_fault+0x15f/0x296
  [<ffffffff813f22f5>] page_fault+0x25/0x30
  [<ffffffffa005760b>] ? ixgbe_clean_rx_irq+0xdf/0x525 [ixgbe]
  [<ffffffffa0053cce>] ? ixgbe_clean_tx_irq+0x125/0x3e5 [ixgbe]
  [<ffffffffa0057ab8>] ixgbe_clean_rxonly+0x67/0xe2 [ixgbe]
  [<ffffffff81351ba3>] net_rx_action+0xab/0x24d
  [<ffffffffa0053285>] ? napi_schedule+0x1b/0x1d [ixgbe]
  [<ffffffff81055206>] __do_softirq+0x114/0x220
  [<ffffffff81093bb5>] ? handle_IRQ_event+0x92/0x18a
  [<ffffffff81012d9c>] call_softirq+0x1c/0x30
  [<ffffffff81014306>] do_softirq+0x42/0x88
  [<ffffffff81055420>] irq_exit+0x3f/0x8f
  [<ffffffff81013a47>] do_IRQ+0xa0/0xb7
  [<ffffffff81012593>] ret_from_intr+0x0/0x11
  <EOI>  [<ffffffff8124ecc8>] ? acpi_idle_enter_simple+0x10f/0x143
  [<ffffffff8124ecc1>] ? acpi_idle_enter_simple+0x108/0x143
  [<ffffffff8124e9d1>] ? acpi_idle_enter_bm+0xd3/0x2bb
  [<ffffffff81096982>] ? rcu_needs_cpu+0x32/0x43
  [<ffffffff81328772>] ? cpuidle_idle_call+0x94/0xca
  [<ffffffff81010c37>] ? cpu_idle+0x58/0xc6
  [<ffffffff813ebd34>] ? start_secondary+0x19c/0x1a0


I re-compiled with symbols, and ran gdb against that new ixgbe.ko
file:

(gdb) l *(ixgbe_clean_rx_irq+0xdf)
0x662f is in ixgbe_clean_rx_irq (/home/greearb/git/linux-2.6.dev.31.y/drivers/net/ixgbe/ixgbe_main.c:744).
739				len = le16_to_cpu(rx_desc->wb.upper.length);
740			}
741	
742			cleaned = true;
743			skb = rx_buffer_info->skb;
744			prefetch(skb->data - NET_IP_ALIGN);
745			rx_buffer_info->skb = NULL;
746	
747			if (rx_buffer_info->dma) {
748				pci_unmap_single(pdev, rx_buffer_info->dma,
(gdb)


For the previous crash that started this thread, the listing is this:

(gdb) l *(ixgbe_clean_rx_irq+0xe4)
0x6634 is in ixgbe_clean_rx_irq (/home/greearb/git/linux-2.6.dev.31.y/drivers/net/ixgbe/ixgbe_main.c:744).
739				len = le16_to_cpu(rx_desc->wb.upper.length);
740			}
741	
742			cleaned = true;
743			skb = rx_buffer_info->skb;
744			prefetch(skb->data - NET_IP_ALIGN);
745			rx_buffer_info->skb = NULL;
746	
747			if (rx_buffer_info->dma) {
748				pci_unmap_single(pdev, rx_buffer_info->dma,


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

