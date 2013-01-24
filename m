From: Ben Greear <greearb@candelatech.com>
Subject: Re: 3.7.3+:  Bad paging request in ip_rcv_finish while running NFS
 traffic.
Date: Wed, 23 Jan 2013 16:38:44 -0800
Message-ID: <51008294.2010201@candelatech.com>
References: <50FDADF4.3060601@candelatech.com>  <50FDDE35.7070806@candelatech.com>  <1358829606.3464.3151.camel@edumazet-glaptop>  <50FE2A57.3040804@candelatech.com>  <50FEC796.5090404@candelatech.com>  <1358875020.3464.4006.camel@edumazet-glaptop>  <1358875607.3464.4020.camel@edumazet-glaptop>  <50FF102F.2050008@candelatech.com> <50FF4BC9.1060206@candelatech.com>  <5100785D.8040101@candelatech.com>  <1358985688.12374.1247.camel@edumazet-glaptop>  <51007CA8.2050105@candelatech.com> <1358987031.12374.1276.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:57778 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752156Ab3AXAiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 19:38:46 -0500
In-Reply-To: <1358987031.12374.1276.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/2013 04:23 PM, Eric Dumazet wrote:
> On Wed, 2013-01-23 at 16:13 -0800, Ben Greear wrote:
>> On 01/23/2013 04:01 PM, Eric Dumazet wrote:

>> I was worried that the dev_seq_stop might be called
>> incorrectly causing an asymetric unlock.  I have no
>> idea how that might happened, but several crashes
>> have that dev_seq_stop method listed, so it got me suspicious.
>
> dev_seq_stop() is some word in the kernel stack, result of a prior
> system call. Stack is not cleanup.
>
> Each function reserves an amount of stack but not always write on all
> reserved space (some automatic variables might be not set)
>
> Note the "? " before the name : linux printed the symbol but this was
> not a call site for this particular call graph. Its only an extra
> indication, that can be useful sometimes.

Ahh, thanks for that info...I'd never quite pieced that together
before.

Here's another crash.  Interestingly, the dst is bad before the rcu-read-lock()
(the bug is from the first of the 'deadbeef' debugging code below)

Perhaps other useful info:  The skb->dev claims to be 'lo'.  The dst 'pointer'
in the skb has 0x1 set, so it is the 'noref' variant.


static int __netif_receive_skb(struct sk_buff *skb)
{
	struct packet_type *ptype, *pt_prev;
	rx_handler_func_t *rx_handler;
	struct net_device *orig_dev;
	struct net_device *null_or_dev;
	bool deliver_exact = false;
	int ret = NET_RX_DROP;
	__be16 type;
	unsigned long pflags = current->flags;

	net_timestamp_check(!netdev_tstamp_prequeue, skb);

	trace_netif_receive_skb(skb);

	/*
	 * PFMEMALLOC skbs are special, they should
	 * - be delivered to SOCK_MEMALLOC sockets only
	 * - stay away from userspace
	 * - have bounded memory usage
	 *
	 * Use PF_MEMALLOC as this saves us from propagating the allocation
	 * context down to all allocation sites.
	 */
	if (sk_memalloc_socks() && skb_pfmemalloc(skb))
		current->flags |= PF_MEMALLOC;

	/* if we've gotten here through NAPI, check netpoll */
	if (netpoll_receive_skb(skb))
		goto out;

	orig_dev = skb->dev;

	skb_reset_network_header(skb);
	skb_reset_transport_header(skb);
	skb_reset_mac_len(skb);

	pt_prev = NULL;

	if (skb_dst(skb)) {
		if (skb_dst(skb)->input == 0xdeadbeef) {
			printk("bad dst: %lu, skb->dev: %s  len: %i\n",
			       skb->_skb_refdst, skb->dev->name, skb->len);
			BUG_ON(1);
		}
	}
	
	rcu_read_lock();

	if (skb_dst(skb)) {
		if (skb_dst(skb)->input == 0xdeadbeef) {
			printk("bad dst: %lu, skb->dev: %s  len: %i\n",
			       skb->_skb_refdst, skb->dev->name, skb->len);
			BUG_ON(1);
		}
	}
	
	
another_round:
	skb->skb_iif = skb->dev->ifindex;

	__this_cpu_inc(softnet_data.processed);
...



[root@lf1011-12060006 ~]# bad dst: 18446612148864241601, skb->dev: lo  len: 3232
------------[ cut here ]------------
kernel BUG at /home/greearb/git/linux-3.7.dev.y/net/core/dev.c:3266!
invalid opcode: 0000 [#1] PREEMPT SMP
Modules linked in: macvlan pktgen lockd sunrpc uinput coretemp hwmon kvm_intel kvm microcode iTCO_wdt iTe
CPU 4
Pid: 35, comm: ksoftirqd/4 Tainted: G         C O 3.7.3+ #50 Iron Systems Inc. EE2610R/X8ST3
RIP: 0010:[<ffffffff81473d22>]  [<ffffffff81473d22>] __netif_receive_skb+0x101/0x5b8
RSP: 0018:ffff88040d711c58  EFLAGS: 00010296
RAX: 0000000000000036 RBX: ffff88041fc93e80 RCX: 000000000000a6a5
RDX: ffffffff810883a6 RSI: 00000000000005fc RDI: 0000000000000246
RBP: ffff88040d711cb8 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000004 R11: 0000000000000000 R12: ffff88041fc93fd0
R13: 0000000000000040 R14: ffff88040d3f8000 R15: ffff88041fc93f80
FS:  0000000000000000(0000) GS:ffff88041fc80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 000000000262c118 CR3: 00000003da651000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process ksoftirqd/4 (pid: 35, threadinfo ffff88040d710000, task ffff88040d701f50)
Stack:
  0000000000000046 0420804000000100 ffffffff81aaf0a0 ffff8803da901200
  000000000d711cb8 ffffffff81aaf0a0 ffff8803ffa90428 ffff88041fc93e80
  ffff88041fc93fd0 0000000000000040 0000000000000024 ffff88041fc93f80
Call Trace:
  [<ffffffff814742d2>] process_backlog+0xf9/0x1da
  [<ffffffff814766db>] net_rx_action+0xad/0x218
  [<ffffffff8108d50a>] __do_softirq+0x9c/0x161
  [<ffffffff8108d5f2>] run_ksoftirqd+0x23/0x42
  [<ffffffff810a7ebe>] smpboot_thread_fn+0x253/0x259
  [<ffffffff810a7c6b>] ? test_ti_thread_flag.clone.0+0x11/0x11
  [<ffffffff810a0a6d>] kthread+0xc2/0xca
  [<ffffffff810a09ab>] ? __init_kthread_worker+0x56/0x56
  [<ffffffff81537dbc>] ret_from_fork+0x7c/0xb0
  [<ffffffff810a09ab>] ? __init_kthread_worker+0x56/0x56
Code: fc ff ff ba ef be ad de 48 39 50 50 75 21 48 8b 45 b8 48 c7 c7 50 ea 82 81 8b 48 68 48 8b 50 20 48
RIP  [<ffffffff81473d22>] __netif_receive_skb+0x101/0x5b8
  RSP <ffff88040d711c58>
---[ end trace e5f94dc78f5e5277 ]---
Kernel panic - not syncing: Fatal exception in interrupt
>
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
